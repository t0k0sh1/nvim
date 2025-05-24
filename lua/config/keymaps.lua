-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

keymap.set("n", "x", '"_x')

-- Increment/decrement
keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G")

-- Indent and unindent
keymap.set("v", "<", "<gv", opts)
keymap.set("v", ">", ">gv", opts)

-- Save file and quit
keymap.set("n", "<Leader>w", ":update<Return>", opts)
keymap.set("n", "<Leader>q", ":quit<Return>", opts)
keymap.set("n", "<Leader>Q", ":qa!<Return>", opts)

-- Split windows
keymap.set("n", "ss", ":split<Return>", opts)
keymap.set("n", "sv", ":vsplit<Return>", opts)

-- Move window
keymap.set("n", "<C-h>", "<C-w>h", opts)
keymap.set("n", "<C-k>", "<C-w>k", opts)
keymap.set("n", "<C-j>", "<C-w>j", opts)
keymap.set("n", "<C-l>", "<C-w>l", opts)

-- Move buffer
keymap.set("n", "<S-h>", ":bprevious<CR>", opts)
keymap.set("n", "<S-l>", ":bnext<CR>", opts)

-- Center cursor after search
keymap.set("n", "n", "nzz", opts)
keymap.set("n", "N", "Nzz", opts)

-- Cancel search highlighting with ESC
keymap.set("n", "<ESC>", ":nohlsearch<Bar>:echo<CR>", opts)

-- Telescope
-- Lists files in your current working directory, respects .gitignore
keymap.set("n", ";f", function()
  local builtin = require("telescope.builtin")
  builtin.find_files({
    no_ignore = false,
    hidden = true,
    cwd = vim.fn.getcwd(),
  })
end, opts)
-- Search for a string in your current working directory and get results live as you type, respects .gitignore
keymap.set("n", ";r", function()
  local builtin = require("telescope.builtin")
  -- builtin.live_grep()
  builtin.current_buffer_fuzzy_find()
end, opts)
-- Lists Diagnostics for all open buffers or a specific buffer
keymap.set("n", ";e", function()
  local builtin = require("telescope.builtin")
  builtin.diagnostics()
end, opts)
-- Lists Function names, variables, from Treesitter
keymap.set("n", ";s", function()
  local builtin = require("telescope.builtin")
  builtin.treesitter()
end, opts)
keymap.set("n", ";;", function()
  local builtin = require("telescope.builtin")
  builtin.resume()
end, opts)

-- NeoTree
keymap.set("n", "<leader>t", ":Neotree reveal<CR>", opts)

-- hop
keymap.set("n", "<leader>h", "<cmd>HopWord<CR>", opts)

-- TodoComments
keymap.set("n", "<leader>]t", function()
  require("todo-comments").jump_next()
end, opts)
keymap.set("n", "<leader>[t", function()
  require("todo-comments").jump_prev()
end, opts)

-- Refactoring
keymap.set("n", "<leader>rn", function()
  return ":IncRename " .. vim.fn.expand("<cword>")
end, { noremap = true, expr = true, silent = true })
keymap.set("v", "<leader>r", function()
  require("refactoring").select_refactor({
    show_success_message = true,
  })
end, { noremap = true, expr = true, silent = true })

-- Neotest
-- Run File
keymap.set("n", ";tt", function()
  require("neotest").run.run(vim.fn.expand("%"))
end, opts)
-- Run Nearest
keymap.set("n", ";tr", function()
  require("neotest").run.run()
end, opts)
-- Run All Test Files
keymap.set("n", ";tT", function()
  require("neotest").run.run(vim.loop.cwd())
end, opts)
-- Run Last
keymap.set("n", ";tl", function()
  require("neotest").run.run_last()
end, opts)
-- Toggle Summary
keymap.set("n", ";ts", function()
  require("neotest").summary.toggle()
end, opts)
-- Show Output
keymap.set("n", ";to", function()
  require("neotest").output.open({ enter = true, auto_close = true })
end, opts)
-- Toggle Output Panel
keymap.set("n", ";tO", function()
  require("neotest").output_panel.toggle()
end, opts)
-- Stop
keymap.set("n", ";tS", function()
  require("neotest").run.stop()
end, opts)
