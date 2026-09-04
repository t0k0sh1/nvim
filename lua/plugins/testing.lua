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

neotest.setup({
  adapters = {
    require("neotest-java")({}),
    require("neotest-python")({
      runner = "pytest",
      python = python_command,
    }),
    require("neotest-rust"),
  },
})

return neotest
