local parsers = {
  "c",
  "cpp",
  "rust",
  "go",
  "python",
  "javascript",
  "typescript",
  "tsx",
  "html",
  "css",
  "json",
  "yaml",
  "toml",
  "lua",
  "java",
  "markdown",
  "markdown_inline",
}

vim.api.nvim_create_user_command("TreeSitterInstallConfigured", function()
  require("nvim-treesitter").install(parsers, { summary = true })
end, {
  desc = "Install the configured Tree-sitter parsers",
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("TreeSitterHighlight", { clear = true }),
  pattern = {
    "c",
    "cpp",
    "rust",
    "go",
    "python",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "html",
    "css",
    "json",
    "jsonc",
    "yaml",
    "toml",
    "lua",
    "java",
    "markdown",
  },
  callback = function(args)
    -- Missing parsers should not interrupt editing. Install them explicitly
    -- with :TreeSitterInstallConfigured and inspect them with :checkhealth.
    pcall(vim.treesitter.start, args.buf)
  end,
})
