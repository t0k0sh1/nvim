local coverage = require("coverage")

coverage.setup({
  auto_reload = false,
  highlights = {
    covered = { fg = "#A6E22E" },
    uncovered = { fg = "#F92672" },
    partial = { fg = "#E6DB74" },
  },
  signs = {
    covered = { hl = "CoverageCovered", text = "" },
    uncovered = { hl = "CoverageUncovered", text = "" },
    partial = { hl = "CoveragePartial", text = "" },
  },
})

local function apply_line_highlights()
  vim.api.nvim_set_hl(0, "CoverageCoveredLine", { bg = "#112A1A" })
  vim.api.nvim_set_hl(0, "CoverageUncoveredLine", { bg = "#361720" })
  vim.api.nvim_set_hl(0, "CoveragePartialLine", { bg = "#342D16" })

  local signs = require("coverage.signs")
  vim.fn.sign_define(signs.name("covered"), { text = "", linehl = "CoverageCoveredLine" })
  vim.fn.sign_define(signs.name("uncovered"), { text = "", linehl = "CoverageUncoveredLine" })
  vim.fn.sign_define(signs.name("partial"), { text = "", linehl = "CoveragePartialLine" })
end

apply_line_highlights()
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("coverage_line_highlights", { clear = true }),
  callback = apply_line_highlights,
})

local M = {}
local running = false
local current = false
local visible = false
local current_report
local current_filetypes
local current_loader

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "Coverage" })
end

local function project_root(markers)
  return vim.fs.root(0, markers)
end

local function remove_blank_line_entries(report, root)
  local output = {}
  local source_lines

  for _, line in ipairs(vim.fn.readfile(report)) do
    local source = line:match("^SF:(.+)$")
    if source then
      local source_path = vim.fs.normalize(source)
      if not vim.startswith(source_path, "/") then
        source_path = vim.fs.joinpath(root, source_path)
      end
      source_lines = vim.fn.filereadable(source_path) == 1 and vim.fn.readfile(source_path) or nil
      line = "SF:" .. source_path
    end

    local line_number = line:match("^DA:(%d+),") or line:match("^BRDA:(%d+),")
    local source_line = line_number and source_lines and source_lines[tonumber(line_number)]
    if not source_line or source_line:find("%S") then
      -- coverage.py writes descriptive LCOV branch IDs, while nvim-coverage
      -- expects the third BRDA field to be numeric.
      local branch_prefix, taken = line:match("^(BRDA:%d+,%d+),[^,]+,([^,]+)$")
      if branch_prefix then
        line = branch_prefix .. ",0," .. taken
      end
      table.insert(output, line)
    end
  end

  vim.fn.writefile(output, report)
end

local function convert_go_coverprofile_to_lcov(report, root)
  local module
  for _, line in ipairs(vim.fn.readfile(vim.fs.joinpath(root, "go.mod"))) do
    module = line:match("^module%s+(.+)$")
    if module then
      break
    end
  end

  local files = {}
  local source_cache = {}
  for _, line in ipairs(vim.fn.readfile(report)) do
    local source, first, last, statements, count = line:match("^(.+):(%d+)%.%d+,(%d+)%.%d+ (%d+) (%d+)$")
    if source then
      local relative = module and source:match("^" .. vim.pesc(module) .. "/(.+)$") or source
      local source_path = vim.fs.joinpath(root, relative)
      local source_lines = source_cache[source_path]
      if not source_lines then
        source_lines = vim.fn.readfile(source_path)
        source_cache[source_path] = source_lines
      end
      files[source_path] = files[source_path] or {}

      for line_number = tonumber(first), tonumber(last) do
        local source_line = source_lines[line_number]
        if source_line and source_line:find("%S") then
          files[source_path][line_number] = math.max(files[source_path][line_number] or 0, tonumber(count))
        end
      end
    end
  end

  local output = { "TN:" }
  local paths = vim.tbl_keys(files)
  table.sort(paths)
  for _, source_path in ipairs(paths) do
    table.insert(output, "SF:" .. source_path)
    local line_numbers = vim.tbl_keys(files[source_path])
    table.sort(line_numbers)
    local covered = 0
    for _, line_number in ipairs(line_numbers) do
      local count = files[source_path][line_number]
      covered = covered + (count > 0 and 1 or 0)
      table.insert(output, string.format("DA:%d,%d", line_number, count))
    end
    table.insert(output, "LF:" .. #line_numbers)
    table.insert(output, "LH:" .. covered)
    table.insert(output, "end_of_record")
  end

  vim.fn.writefile(output, report)
end

local function runner_for(filetype, cache_dir)
  if filetype == "python" then
    local root = project_root({ "uv.lock", "pyproject.toml", ".git" })
    if not root then
      return nil, "Could not find the Python project root"
    end
    if vim.fn.executable("uv") ~= 1 then
      return nil, "uv was not found"
    end

    local project_id = vim.fn.sha256(root):sub(1, 12)
    local report = vim.fs.joinpath(cache_dir, project_id .. ".lcov")
    return {
      filetypes = { "python" },
      root = root,
      report = report,
      command = { "uv", "run", "pytest", "--cov", "--cov-report=lcov:" .. report },
      env = { COVERAGE_FILE = vim.fs.joinpath(cache_dir, project_id .. ".data") },
      message = "Running pytest with coverage...",
      prepare = remove_blank_line_entries,
      load = function(place)
        coverage.load_lcov(report, place)
      end,
    }
  end

  if filetype == "go" then
    local root = project_root({ "go.work", "go.mod", ".git" })
    if not root or vim.fn.filereadable(vim.fs.joinpath(root, "go.mod")) ~= 1 then
      return nil, "Could not find the Go project root"
    end
    if vim.fn.executable("go") ~= 1 then
      return nil, "go was not found"
    end

    local project_id = vim.fn.sha256(root):sub(1, 12)
    local report = vim.fs.joinpath(cache_dir, project_id .. ".lcov")
    return {
      filetypes = { "go" },
      root = root,
      report = report,
      command = { "go", "test", "./...", "-coverprofile=" .. report },
      message = "Running Go tests with coverage...",
      prepare = convert_go_coverprofile_to_lcov,
      load = function(place)
        coverage.load_lcov(report, place)
      end,
    }
  end

  if filetype == "rust" then
    local root = project_root({ "Cargo.toml", ".git" })
    if not root or vim.fn.filereadable(vim.fs.joinpath(root, "Cargo.toml")) ~= 1 then
      return nil, "Could not find the Rust project root"
    end
    if vim.fn.executable("cargo") ~= 1 then
      return nil, "cargo was not found"
    end
    if vim.fn.executable("cargo-llvm-cov") ~= 1 then
      return nil, "cargo-llvm-cov was not found"
    end
    if vim.fn.executable("cargo-nextest") ~= 1 then
      return nil, "cargo-nextest was not found"
    end

    local project_id = vim.fn.sha256(root):sub(1, 12)
    local report = vim.fs.joinpath(cache_dir, project_id .. ".lcov")
    return {
      filetypes = { "rust" },
      root = root,
      report = report,
      command = {
        "cargo",
        "llvm-cov",
        "nextest",
        "--lcov",
        "--output-path",
        report,
      },
      message = "Running Rust tests with coverage...",
      prepare = remove_blank_line_entries,
      load = function(place)
        coverage.load_lcov(report, place)
      end,
    }
  end

  local javascript_filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }
  if vim.tbl_contains(javascript_filetypes, filetype) then
    local javascript_tests = require("core.javascript_test_runner")
    local root = javascript_tests.root(vim.api.nvim_buf_get_name(0))
    if not root then
      return nil, "Could not find the JavaScript project root"
    end

    local test_runner = javascript_tests.detect(root)
    if not test_runner then
      return nil, "Could not detect Bun or Vitest"
    end

    local project_id = vim.fn.sha256(root):sub(1, 12)
    local report_dir = vim.fs.joinpath(cache_dir, project_id .. "-" .. test_runner)
    vim.fn.mkdir(report_dir, "p")
    local report = vim.fs.joinpath(report_dir, "lcov.info")
    local command
    local runner_name = test_runner == "bun" and "Bun" or "Vitest"

    if test_runner == "bun" then
      if vim.fn.executable("bun") ~= 1 then
        return nil, "bun was not found"
      end
      command = {
        "bun",
        "test",
        "--coverage",
        "--coverage-reporter=lcov",
        "--coverage-dir=" .. report_dir,
      }
    else
      local vitest = vim.fs.joinpath(root, "node_modules", ".bin", "vitest")
      if vim.fn.executable(vitest) ~= 1 then
        return nil, "vitest was not found; install the project dependencies"
      end
      command = {
        vitest,
        "run",
        "--coverage",
        "--coverage.reporter=lcov",
        "--coverage.reportsDirectory=" .. report_dir,
      }
    end

    return {
      filetypes = javascript_filetypes,
      root = root,
      report = report,
      command = command,
      message = "Running " .. runner_name .. " tests with coverage...",
      prepare = remove_blank_line_entries,
      load = function(place)
        coverage.load_lcov(report, place)
      end,
    }
  end

  return nil, "Coverage is not configured for " .. filetype
end

function M.run()
  if running then
    notify("Coverage is already running")
    return
  end

  local cache_dir = vim.fs.joinpath(vim.fn.stdpath("cache"), "coverage")
  vim.fn.mkdir(cache_dir, "p")
  local runner, error_message = runner_for(vim.bo.filetype, cache_dir)
  if not runner then
    notify(error_message, vim.log.levels.ERROR)
    return
  end

  running = true
  notify(runner.message)

  vim.system(runner.command, {
    cwd = runner.root,
    text = true,
    env = runner.env,
  }, function(result)
    vim.schedule(function()
      running = false
      if result.code ~= 0 then
        local output = result.stderr ~= "" and result.stderr or result.stdout
        output = vim.trim(output or "")
        notify("Coverage run failed:\n" .. output:sub(-4000), vim.log.levels.ERROR)
        return
      end

      runner.prepare(runner.report, runner.root)
      runner.load(true)
      current = true
      visible = true
      current_report = runner.report
      current_filetypes = runner.filetypes
      current_loader = runner.load
      vim.cmd.redraw()
      notify("Coverage results displayed")
    end)
  end)
end

function M.toggle()
  if not current then
    notify("Run coverage with <leader>tc first")
    return
  end
  coverage.toggle()
  visible = not visible
end

function M.summary()
  if not current then
    notify("Run coverage with <leader>tc first")
    return
  end
  coverage.summary()
end

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
  group = vim.api.nvim_create_augroup("clear_stale_coverage", { clear = true }),
  pattern = { "*.py", "*.go", "*.rs", "*.js", "*.jsx", "*.ts", "*.tsx" },
  callback = function()
    if not current then
      return
    end

    coverage.clear()
    current = false
    visible = false
    current_report = nil
    current_filetypes = nil
    current_loader = nil
    notify("Cleared stale coverage after code changes")
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("reload_coverage_for_opened_buffers", { clear = true }),
  callback = function()
    if current and current_report and current_loader and vim.tbl_contains(current_filetypes or {}, vim.bo.filetype) then
      current_loader(visible)
    end
  end,
})

return M
