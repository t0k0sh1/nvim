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

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "Coverage" })
end

local function project_root()
  return vim.fs.root(0, { "uv.lock", "pyproject.toml", ".git" })
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

function M.run()
  if vim.bo.filetype ~= "python" then
    notify("Run coverage from a Python buffer", vim.log.levels.WARN)
    return
  end
  if running then
    notify("Coverage is already running")
    return
  end
  if vim.fn.executable("uv") ~= 1 then
    notify("uv was not found", vim.log.levels.ERROR)
    return
  end

  local root = project_root()
  if not root then
    notify("Could not find the Python project root", vim.log.levels.ERROR)
    return
  end

  local cache_dir = vim.fs.joinpath(vim.fn.stdpath("cache"), "coverage")
  vim.fn.mkdir(cache_dir, "p")
  local project_id = vim.fn.sha256(root):sub(1, 12)
  local report = vim.fs.joinpath(cache_dir, project_id .. ".lcov")
  local data_file = vim.fs.joinpath(cache_dir, project_id .. ".data")
  running = true
  notify("Running pytest with coverage...")

  vim.system({
    "uv",
    "run",
    "pytest",
    "--cov",
    "--cov-report=lcov:" .. report,
  }, {
    cwd = root,
    text = true,
    env = { COVERAGE_FILE = data_file },
  }, function(result)
    vim.schedule(function()
      running = false
      if result.code ~= 0 then
        local output = result.stderr ~= "" and result.stderr or result.stdout
        output = vim.trim(output or "")
        notify("Coverage run failed:\n" .. output:sub(-4000), vim.log.levels.ERROR)
        return
      end

      remove_blank_line_entries(report, root)
      coverage.load_lcov(report, true)
      current = true
      visible = true
      current_report = report
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
  pattern = "*.py",
  callback = function()
    if not current then
      return
    end

    coverage.clear()
    current = false
    visible = false
    current_report = nil
    notify("Cleared stale coverage after code changes")
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("reload_coverage_for_opened_buffers", { clear = true }),
  pattern = "*.py",
  callback = function()
    if current and current_report then
      coverage.load_lcov(current_report, visible)
    end
  end,
})

return M
