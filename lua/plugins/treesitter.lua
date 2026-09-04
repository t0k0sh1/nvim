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
}

require("nvim-treesitter").install(parsers)

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
  },
  callback = function(args)
    vim.treesitter.start(args.buf)
  end,
})
