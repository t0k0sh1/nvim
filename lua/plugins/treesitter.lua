return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- add tsx and treesitter
      vim.list_extend(opts.ensure_installed, {
        "gitignore",
        "regex",
        "json",
        "yaml",
        "toml",
        "html",
        "css",
        "scss",
        "vim",
        "lua",
        "javascript",
        "tsx",
        "typescript",
        "python",
        "go",
        "gomod",
        "gosum",
        "bash",
        "html",
        "query",
        "markdown",
        "markdown_inline",
      })
      -- vim.list_extend(opts.query_linter, {
      --   enable = true,
      --   use_virtual_text = true,
      --   lint_events = { "BufWrite", "CursorHold" },
      -- })
    end,
  },
}
