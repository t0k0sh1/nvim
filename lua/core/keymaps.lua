local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- do not deleted a character to the buffer
keymap.set("n", "x", '"_x')

-- increment/decrement
keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")

-- select all
keymap.set("n", "<C-a>", "gg<S-v>G")

-- indent and unindent
keymap.set("v", "<", "<gv", opts)
keymap.set("v", ">", ">gv", opts)

-- save file and quit
keymap.set("n", "<Leader>w", ":update<Return>", opts)
keymap.set("n", "<Leader>q", ":quit<Return>", opts)
keymap.set("n", "<Leader>Q", ":qa!<Return>", opts)

-- move buffer
keymap.set("n", "<S-h>", ":bprevious<CR>", opts)
keymap.set("n", "<S-l>", ":bnext<CR>", opts)

-- 1. Close current buffer (<leader> + bd)
keymap.set('n', '<leader>bd', ':bnext | bdelete #<CR>', { silent = true })

-- 2. Close other buffers (<leader> + bo)
keymap.set('n', '<leader>bo', ':%bd | e# | bd#<CR>', { silent = true })

-- 3. Close all buffers without quitting NeoVim (<leader> + ba)
keymap.set('n', '<leader>ba', ':%bd | enew<CR>', { silent = true })

-- center cursor after search
keymap.set("n", "n", "nzz", opts)
keymap.set("n", "N", "Nzz", opts)

-- cancel search highlighting with ESC
keymap.set("n", "<ESC>", ":nohlsearch<Bar>:echo<CR>", opts)

-- code actions
vim.keymap.set('n', 'gra', vim.lsp.buf.code_action, { desc = "LSP Code Action" })

-- switch between an implementation and its test, creating the pair when needed
vim.keymap.set("n", "<leader>tp", require("core.testing_pair").switch, { desc = "Switch Testing Pair" })

-- smoka7/hop.nvim
local status, _ = pcall(require, "hop")
if status then
  vim.keymap.set("n", "<leader><leader>", "<cmd>HopWord<CR>", opts)
end

-- nvim-telescope/telescope.nvim
local telescope = require('telescope')
local builtin = require('telescope.builtin')

telescope.setup({
  defaults = {
    file_ignore_patterns = {
      "node_modules/",
      "%.git/",
      "pack/",
      "__pycache__/",
      "build/",
      "target/"
    },
  },
})

-- find files
vim.keymap.set('n', '<leader>ff', function()
  builtin.find_files({
    find_command = {
      "sh",
      "-c",
      "fd --type f --color never --strip-cwd-prefix --exclude __init__.py | sort",
    },
  })
end, { desc = "Find Files" })
-- live grep
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Live Grep" })
-- search buffer
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = "Find Buffers" })

-- terminal plugin
local terminal = require("plugins.terminal")

-- toggle terminal
vim.keymap.set('n', '<F12>', terminal.toggle_terminal, opts)
vim.keymap.set('t', '<F12>', terminal.toggle_terminal, opts)
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], opts)

-- 1. Create File
vim.keymap.set("n", "<leader>nf", function()
  vim.api.nvim_feedkeys(":e ", "n", false)
end, { desc = "Prepare :e command" })

-- 2. Create Directory
vim.keymap.set("n", "<leader>nd", function()
  vim.api.nvim_feedkeys(":!mkdir -p ", "n", false)
end, { desc = "Prepare :!mkdir command" })

-- 3. Rename/Move Current File or Directory
vim.keymap.set("n", "<leader>rn", function()
  vim.api.nvim_feedkeys(":!mv ", "n", false)
end, { desc = "Prepare :!mv command" })

-- 4. Delete Current File
vim.keymap.set("n", "<leader>rm", function()
  vim.api.nvim_feedkeys(":!rm ", "n", false)
end, { desc = "Prepare :!rm command" })
