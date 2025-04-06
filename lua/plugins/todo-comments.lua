return {
  "folke/todo-comments.nvim",
  event = "VimEnter",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    signs = false,
    highlight = {
      pattern = [[.*<(KEYWORDS)]],
      after = "",
    },
    search = {
      pattern = [[\b(KEYWORDS)\b]],
    },
  },
}
