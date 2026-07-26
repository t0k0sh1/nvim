-- Define layout and settings for code formatting
require("conform").setup({
  formatters_by_ft = {
    javascript = { "prettierd", "prettier", stop_after_first = true },
    typescript = { "prettierd", "prettier", stop_after_first = true },
    javascriptreact = { "prettierd", "prettier", stop_after_first = true },
    typescriptreact = { "prettierd", "prettier", stop_after_first = true },
    html = { "prettierd", "prettier", stop_after_first = true },
    css = { "prettierd", "prettier", stop_after_first = true },
    json = { "prettierd", "prettier", stop_after_first = true },
    jsonc = { "prettierd", "prettier", stop_after_first = true },
    yaml = { "prettierd", "prettier", stop_after_first = true },
    toml = { "tombi" },
    python = { "ruff_organize_imports", "ruff_format" },
    lua = { "stylua" },
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
