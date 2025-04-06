return {
  "stevearc/conform.nvim",
  event = "VeryLazy",
  opts = {
    formatters_by_ft = {
      python = { "isort", "black" },
      json = { "jq" },
    },
  }
}