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
  format_on_save = function(bufnr)
    return {
      timeout_ms = 1000,
      lsp_format = vim.bo[bufnr].filetype == "java" and "never" or "fallback",
    }
  end,
})

-- Define user command to view formatter status
vim.api.nvim_create_user_command("ConformInfo", function()
  require("conform").info()
end, {})
