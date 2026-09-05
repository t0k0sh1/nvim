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

neotest.setup({
  adapters = {
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
  },
})

return neotest
