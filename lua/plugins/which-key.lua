local which_key = require("which-key")

which_key.setup({
  preset = "modern",
  delay = 300,
})

which_key.add({
  { "<leader>b", group = "buffer" },
  { "<leader>f", group = "find" },
  { "<leader>h", group = "git hunk" },
  { "<leader>l", group = "lsp" },
  { "<leader>t", group = "toggle/test" },
})
