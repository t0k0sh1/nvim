-- Define layout and settings for code formatting
require("conform").setup({
  formatters_by_ft = {
    javascript = { "prettierd", "prettier", stop_after_first = true },
    typescript = { "prettierd", "prettier", stop_after_first = true },
    javascriptreact = { "prettierd", "prettier", stop_after_first = true },
    typescriptreact = { "prettierd", "prettier", stop_after_first = true },
    rust = { "rustfmt" },
    java = { "google-java-format" },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_format = "fallback", -- Use LSP formatting if no configured formatter is available
  },
})

-- Define user command to view formatter status
vim.api.nvim_create_user_command("ConformInfo", function()
  require("conform").info()
end, {})
