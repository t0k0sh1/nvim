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
vim.keymap.set("n", "<leader>tp", require("core.testing_pair").switch, {
  desc = "Switch Testing Pair",
})

-- run Java tests and inspect their persistent results
local neotest = require("neotest")
vim.keymap.set("n", "<leader>tn", function()
  neotest.run.run()
end, { desc = "Test Nearest" })
vim.keymap.set("n", "<leader>tf", function()
  neotest.run.run(vim.fn.expand("%"))
end, { desc = "Test File" })
vim.keymap.set("n", "<leader>ta", function()
  neotest.run.run(vim.uv.cwd())
end, { desc = "Test All" })
vim.keymap.set("n", "<leader>tl", neotest.run.run_last, { desc = "Test Last" })
vim.keymap.set("n", "<leader>to", function()
  neotest.output.open({ enter = true })
end, { desc = "Test Output" })
vim.keymap.set("n", "<leader>tO", neotest.output_panel.toggle, { desc = "Test Output Panel" })
vim.keymap.set("n", "<leader>ts", neotest.summary.toggle, { desc = "Test Summary" })

-- run and inspect Python coverage
local coverage = require("plugins.coverage")
vim.keymap.set("n", "<leader>tc", coverage.run, { desc = "Test Coverage" })
vim.keymap.set("n", "<leader>tC", coverage.toggle, { desc = "Toggle Coverage" })
vim.keymap.set("n", "<leader>tS", coverage.summary, { desc = "Coverage Summary" })

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
      "fd --type f --color never --strip-cwd-prefix --exclude __init__.py",
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
-- diagnostics in the current buffer
vim.keymap.set("n", "<leader>fd", function()
  builtin.diagnostics({ bufnr = 0 })
end, { desc = "Buffer Diagnostics" })
-- diagnostics in the workspace
vim.keymap.set("n", "<leader>fD", builtin.diagnostics, { desc = "Workspace Diagnostics" })

vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts)
