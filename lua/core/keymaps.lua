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

-- show or hide a persistent terminal without listing it as an editing buffer
local terminal = require("core.terminal")
keymap.set({ "n", "t" }, "<C-\\>", terminal.toggle, {
  noremap = true,
  silent = true,
  desc = "Toggle Terminal",
})

local window_directions = {
  h = 8,
  j = 10,
  k = 11,
  l = 12,
}

local function move_from_editor(direction)
  vim.cmd("wincmd " .. direction)
  if vim.bo.buftype == "terminal" then
    vim.cmd("startinsert")
  end
end

local function move_from_terminal(direction, control_code)
  local previous_window = vim.api.nvim_get_current_win()
  local terminal_job = vim.b.terminal_job_id
  vim.cmd("stopinsert")
  vim.cmd("wincmd " .. direction)

  if vim.api.nvim_get_current_win() == previous_window then
    vim.cmd("startinsert")
    if terminal_job then
      vim.api.nvim_chan_send(terminal_job, string.char(control_code))
    end
  end
end

for direction, control_code in pairs(window_directions) do
  local lhs = "<C-" .. direction .. ">"
  keymap.set("n", lhs, function()
    move_from_editor(direction)
  end, { silent = true, desc = "Move to " .. direction .. " Window" })
  keymap.set("t", lhs, function()
    move_from_terminal(direction, control_code)
  end, { silent = true, desc = "Move to " .. direction .. " Window" })
end

-- move buffer
keymap.set("n", "<S-h>", ":bprevious<CR>", opts)
keymap.set("n", "<S-l>", ":bnext<CR>", opts)

-- close buffer(s)
-- close current buffer
keymap.set("n", "<leader>bc", ":bnext | bdelete #<CR>", opts)
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

-- run tests and inspect their persistent results
local neotest = require("neotest")
local test_runner = require("core.test_runner")
vim.keymap.set("n", "<leader>tn", function()
  test_runner.run()
end, { desc = "Test Nearest" })
vim.keymap.set("n", "<leader>tf", function()
  test_runner.run(vim.fn.expand("%"))
end, { desc = "Test File" })
vim.keymap.set("n", "<leader>ta", function()
  test_runner.run(vim.uv.cwd())
end, { desc = "Test All" })
vim.keymap.set("n", "<leader>tl", test_runner.run_last, { desc = "Test Last" })
vim.keymap.set("n", "<leader>to", function()
  neotest.output.open({ enter = true })
end, { desc = "Test Output" })
vim.keymap.set("n", "<leader>tO", neotest.output_panel.toggle, { desc = "Test Output Panel" })
vim.keymap.set("n", "<leader>ts", neotest.summary.toggle, { desc = "Test Summary" })

-- run and inspect coverage
local coverage = require("plugins.coverage")
vim.keymap.set("n", "<leader>tc", coverage.run, { desc = "Test Coverage" })
vim.keymap.set("n", "<leader>tC", coverage.toggle, { desc = "Toggle Coverage" })
vim.keymap.set("n", "<leader>tS", coverage.summary, { desc = "Coverage Summary" })

vim.keymap.set("n", "<leader>mp", function()
  if vim.bo.filetype ~= "markdown" then
    vim.notify("Markdown preview is available only in Markdown buffers", vim.log.levels.WARN)
    return
  end
  vim.cmd("MarkdownPreviewToggle")
end, { desc = "Markdown Preview" })

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
