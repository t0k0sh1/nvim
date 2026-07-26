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

-- close buffer(s)
-- close current buffer
keymap.set("n", "<leader>bd", ":bnext | bdelete #<CR>", opts)
-- close other buffers
keymap.set("n", "<leader>bo", ":%bd | e# | bd#<CR>", opts)
-- close all buffers without quitting NeoVim
keymap.set("n", "<leader>ba", ":%bd | enew<CR>", opts)

-- center cursor after search
keymap.set("n", "n", "nzz", opts)
keymap.set("n", "N", "Nzz", opts)

-- cancel search highlighting with ESC
keymap.set("n", "<ESC>", ":nohlsearch<Bar>:echo<CR>", opts)

-- switch between an implementation and its test, creating the pair when needed
vim.keymap.set("n", "<leader>tp", require("core.testing_pair").switch, opts)

-- smoka7/hop.nvim
local status, _ = pcall(require, "hop")
if status then
  vim.keymap.set("n", "<leader><leader>", "<cmd>HopWord<CR>", opts)
end

-- nvim-telescope/telescope.nvim
local builtin = require("telescope.builtin")

-- find files
vim.keymap.set("n", "<leader>ff", function()
  builtin.find_files({
    find_command = {
      "sh",
      "-c",
      "fd --type f --color never --strip-cwd-prefix --exclude __init__.py | sort",
    },
  })
end, { desc = "Find Files" })
-- find hidden and ignored files, while limiting .git to editable hooks
vim.keymap.set("n", "<leader>fF", function()
  builtin.find_files({
    prompt_title = "Find All Files",
    find_command = {
      "sh",
      "-c",
      "(fd --type f --hidden --no-ignore --color never --exclude .git "
        .. "--exclude .project --exclude .settings --exclude .gradle "
        .. "--exclude .factorypath --exclude .classpath; "
        .. "if [ -d .git/hooks ]; then fd --type f --hidden --no-ignore --color never . .git/hooks; fi) | sort -u",
    },
  })
end, { desc = "Find All Files" })
-- live grep
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })
-- search buffer
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find Buffers" })

-- terminal plugin
local terminal = require("plugins.terminal")

-- toggle terminal
vim.keymap.set("n", "<F12>", terminal.toggle_terminal, opts)
vim.keymap.set("t", "<F12>", terminal.toggle_terminal, opts)
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts)

-- Rename/Move Current File or Directory
vim.keymap.set("n", "<leader>rn", require("core.files").rename_current_file, {
  desc = "Rename Current File",
})

-- Delete Current File
vim.keymap.set("n", "<leader>rm", require("core.files").delete_current_file, {
  desc = "Delete Current File",
})
