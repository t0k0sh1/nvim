local neotest = require("neotest")

local function python_command(root)
  if vim.fn.filereadable(vim.fs.joinpath(root, "uv.lock")) == 1 then
    return { "uv", "run", "--project", root, "python" }
  end

  local executable_dir = vim.uv.os_uname().sysname == "Windows_NT" and "Scripts" or "bin"
  local environments = { vim.fs.joinpath(root, ".venv") }
  if vim.env.VIRTUAL_ENV then
    table.insert(environments, 1, vim.env.VIRTUAL_ENV)
  end
  for _, environment in ipairs(environments) do
    if environment then
      local python = vim.fs.joinpath(environment, executable_dir, "python")
      if vim.fn.executable(python) == 1 then
        return { python }
      end
    end
  end

  local python = vim.fn.exepath("python3")
  return { python ~= "" and python or "python" }
end

local javascript_tests = require("core.javascript_test_runner")

local bun_adapter = require("neotest-bun")
local bun_root = bun_adapter.root
bun_adapter.root = function(path)
  local root = bun_root(path)
  return root and javascript_tests.detect(root) == "bun" and root or nil
end
bun_adapter.is_test_file = function(path)
  return javascript_tests.is_test_file(path, "bun")
end

local vitest_adapter = require("neotest-vitest")({
  is_test_file = function(path)
    return javascript_tests.is_test_file(path, "vitest")
  end,
})
local vitest_root = vitest_adapter.root
vitest_adapter.root = function(path)
  local root = vitest_root(path)
  return root and javascript_tests.detect(root) == "vitest" and root or nil
end

local gtest_adapter
if pcall(vim.treesitter.language.add, "cpp") then
  gtest_adapter = require("neotest-gtest").setup({
    root = require("neotest.lib").files.match_root_pattern("CMakeLists.txt", "compile_commands.json", ".git"),
    mappings = { configure = "C" },
  })
  local gtest_discover_positions = gtest_adapter.discover_positions
  gtest_adapter.discover_positions = function(path)
    -- Neovim 0.12 returns capture lists from iter_matches even with all=false,
    -- while neotest-gtest currently expects one node per capture.
    local query_class = getmetatable(vim.treesitter.query.parse("cpp", "(identifier) @id")).__index
    local iter_matches = query_class.iter_matches
    local deprecate = vim.deprecate
    vim.deprecate = function() end
    query_class.iter_matches = function(query, ...)
      local iterator, state, value = iter_matches(query, ...)
      return function(iter_state, iter_value)
        local pattern, match, metadata = iterator(iter_state, iter_value)
        if match then
          for capture, nodes in pairs(match) do
            if type(nodes) == "table" then
              match[capture] = nodes[1]
            end
          end
        end
        return pattern, match, metadata
      end,
        state,
        value
    end
    local ok, result = pcall(gtest_discover_positions, path)
    query_class.iter_matches = iter_matches
    vim.deprecate = deprecate
    if not ok then
      error(result)
    end
    return result
  end

  local gtest_executables = require("neotest-gtest.executables")
  local find_gtest_executables = gtest_executables.find_executables
  gtest_executables.find_executables = function(tree)
    local binary = require("core.gtest").binary_for_tree(tree)
    if binary then
      return { [binary] = { tree:data().id } }, nil
    end
    return find_gtest_executables(tree)
  end

  local gtest_build_spec = gtest_adapter.build_spec
  gtest_adapter.build_spec = function(args)
    -- neotest-gtest still calls the deprecated vim.tbl_flatten, whose warning
    -- cannot be emitted from Neotest's fast-event context on Neovim 0.12.
    local tbl_flatten = vim.tbl_flatten
    vim.tbl_flatten = function(values)
      return vim.iter(values):flatten(math.huge):totable()
    end
    local ok, result = pcall(gtest_build_spec, args)
    vim.tbl_flatten = tbl_flatten
    if not ok then
      error(result)
    end
    return result
  end
end

local adapters = {
  require("neotest-java")({}),
  require("neotest-python")({
    runner = "pytest",
    python = python_command,
  }),
  require("neotest-rust"),
  require("neotest-go")({
    args = { "-count=1" },
    recursive_run = true,
  }),
  bun_adapter,
  vitest_adapter,
  require("neotest-busted")({
    busted_command = "busted",
    no_nvim = true,
  }),
}
if gtest_adapter then
  table.insert(adapters, gtest_adapter)
end

neotest.setup({ adapters = adapters })

vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("detect_gtest_executable", { clear = true }),
  pattern = { "*.cc", "*.cpp", "*.cxx", "*.c++" },
  callback = function(event)
    require("core.gtest").detect(event.file)
  end,
})

return neotest
