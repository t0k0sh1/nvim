local M = {}

function M.is_enabled()
  return vim.g.copilot_enabled ~= 0
end

function M.toggle()
  vim.g.copilot_enabled = M.is_enabled() and 0 or 1
  if not M.is_enabled() then
    pcall(vim.fn["copilot#Dismiss"])
  end

  local ok, lualine = pcall(require, "lualine")
  if ok then
    lualine.refresh({ place = { "statusline" } })
  end
end

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

vim.keymap.set({ "n", "i" }, "<F12>", M.toggle, {
  desc = "Toggle Copilot",
  silent = true,
})

return M
