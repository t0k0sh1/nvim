vim.keymap.set("i", "<Tab>", function()
  local suggestion = vim.fn["copilot#Accept"]("")
  if suggestion ~= "" then
    return suggestion
  end

  if vim.snippet.active({ direction = 1 }) then
    vim.snippet.jump(1)
    return ""
  end

  return vim.keycode("<Tab>")
end, {
  expr = true,
  replace_keycodes = false,
  silent = true,
  desc = "Accept Copilot suggestion, jump snippet, or insert Tab",
})

vim.keymap.set("i", "<C-l>", "<Plug>(copilot-accept-word)", {
  desc = "Accept Copilot Word",
})
vim.keymap.set("i", "<C-j>", "<Plug>(copilot-accept-line)", {
  desc = "Accept Copilot Line",
})
