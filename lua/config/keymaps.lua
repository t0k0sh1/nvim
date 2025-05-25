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
keymap.set(
  "n",
  "<leader>,",
  "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",
  { desc = "Switch Buffer", noremap = true }
)
keymap.set("n", "<leader><space>", LazyVim.pick("files"), { desc = "Find Files (Root Dir)", noremap = true })
keymap.set("n", "<leader>/", LazyVim.pick("live_grep"), { desc = "Grep (Root Dir)", noremap = true })
-- find
keymap.set(
  "n",
  "<leader>fb",
  "<cmd>Telescope buffers sort_mru=true sort_lastused=true ignore_current_buffer=true<cr>",
  { desc = "Buffers", noremap = true }
)
keymap.set("n", "<leader>ff", LazyVim.pick("files"), { desc = "Find Files (Root Dir)", noremap = true })
keymap.set("n", "<leader>fF", LazyVim.pick("files", { root = false }), { desc = "Find Files (cwd)", noremap = true })
keymap.set("n", "<leader>fg", "<cmd>Telescope git_files<cr>", { desc = "Find Files (git-files)", noremap = true })
keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Find Recent", noremap = true })
keymap.set(
  "n",
  "<leader>fR",
  LazyVim.pick("oldfiles", { cwd = vim.uv.cwd() }),
  { desc = "Find Recent (cwd)", noremap = true }
)
-- git
keymap.set("n", "<leader>gc", "<cmd>Telescope git_commit<cr>", { desc = "Search Commits", noremap = true })
keymap.set("n", "<leader>gs", "<cmd>Telescope git_status<cr>", { desc = "Search Status", noremap = true })

--search
keymap.set("n", "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find", { desc = "Search Buffer", noremap = true })
keymap.set("n", "<leader>sg", LazyVim.pick("live_grep"), { desc = "Grep (Root Dir)", noremap = true })
keymap.set("n", "<leader>sG", LazyVim.pick("live_grep", { root = false }), { desc = "Grep (cwd)", noremap = true })
keymap.set(
  "n",
  "<leader>sd",
  "<cmd>Telescope diagnostics bufnr=0<cr>",
  { desc = "Document Diagnostics", noremap = true }
)
keymap.set("n", "<leader>sD", "<cmd>Telescope diagnostics<cr>", { desc = "Workspace Diagnostics", noremap = true })
keymap.set("n", "<leader>ss", function()
  local builtin = require("telescope.builtin")
  builtin.treesitter()
end, { desc = "Lists Function names, variables, from Treesitter", noremap = true })
-- Lists files in your current working directory, respects .gitignore
keymap.set("n", ";f", function()
  local builtin = require("telescope.builtin")
  builtin.find_files({
    no_ignore = false,
    hidden = true,
    cwd = vim.fn.getcwd(),
  })
end, opts)
keymap.set("n", "<leader>sR", "<cmd>Telescope resume<cr>", { desc = "Search Resume", noremap = true })

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
