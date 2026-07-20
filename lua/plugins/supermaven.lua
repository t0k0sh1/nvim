require("supermaven-nvim").setup({
  keymaps = {
    accept_suggestion = "<Tab>",
    clear_suggestion = "<C-]>",
    accept_word = "<C-j>",
  },
  ignore_filetypes = { "markdown", "text", "env" },
  color = {
    suggestion_color = "#656565",
    cterm = 244,
  },
  log_level = "warn",
  disable_inline_completion = false,
  disable_keymaps = false,
})
