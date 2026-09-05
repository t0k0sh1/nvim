local M = {}

local neotest = require("neotest")

local function run_after_build(callback)
  if vim.bo.filetype ~= "c" and vim.bo.filetype ~= "cpp" then
    callback()
    return
  end

  vim.cmd("silent update")
  require("core.gtest").build(vim.api.nvim_buf_get_name(0), callback)
end

function M.run(target)
  run_after_build(function()
    neotest.run.run(target)
  end)
end

function M.run_last()
  run_after_build(neotest.run.run_last)
end

return M
