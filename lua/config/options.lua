-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- LSP Server to use for Python.
-- Set to "basedpyright" to use basedpyright instead of pyright.
vim.g.lazyvim_python_lsp = "pyright"
-- Set to "ruff_lsp" to use the old LSP implementation version.
vim.g.lazyvim_python_ruff = "ruff"

vim.api.nvim_create_autocmd({ "InsertEnter" }, {
  pattern = "*",
  callback = function()
    vim.opt.relativenumber = false
  end,
})

vim.api.nvim_create_autocmd({ "InsertLeave" }, {
  pattern = "*",
  callback = function()
    vim.opt.relativenumber = true
  end,
})
