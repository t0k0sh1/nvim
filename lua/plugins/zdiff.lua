require("zdiff").setup()

vim.keymap.set("n", "<leader>zd", function()
  require("zdiff").open()
end, { desc = "Zdiff (uncommitted)" })

vim.keymap.set("n", "<leader>zD", function()
  require("zdiff").open("main")
end, { desc = "Zdiff (vs main)" })
