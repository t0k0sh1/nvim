-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local opts = { noremap = true, silent = true }

-- Normal mode

vim.keymap.set("n", "<leader>qq", "<cmd>qa!<CR>", { desc = "Quit all" })

-- Don't yank on x
vim.keymap.set("n", "x", '"_x', opts)

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move focus to the right window" })

-- Hop
vim.keymap.set("n", "<leader>r", "<cmd>HopWord<CR>", { desc = "Hop Word" })

-- Telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })
vim.keymap.set("n", "<leader>gs", builtin.git_status, {})
vim.keymap.set("n", "<leader>gl", builtin.git_bcommits, {})
vim.keymap.set("n", "<leader>/", function()
  -- You can pass additional configuration to Telescope to change the theme, layout, etc.
  builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
    winblend = 10,
    previewer = false,
  }))
end, { desc = "[/] Fuzzily search in current buffer" })
vim.keymap.set("n", "<leader>s/", function()
  builtin.live_grep({
    grep_open_files = true,
    prompt_title = "Live Grep in Open Files",
  })
end, { desc = "[S]earch [/] in Open Files" })
vim.keymap.set("n", "<leader>sn", function()
  builtin.find_files({ cwd = vim.fn.stdpath("config") })
end, { desc = "[S]earch [N]eovim files" })

-- todo-comments
local todo_comments = require("todo-comments")
vim.keymap.set("n", "[t", todo_comments.jump_prev, opts)
vim.keymap.set("n", "]t", todo_comments.jump_next, opts)

-- gitsigns
local gitsigns = require("gitsigns")
vim.keymap.set("n", "[c", function()
  if vim.wo.diff then
    vim.cmd.nomal({ "[c", bang = true })
  else
    gitsigns.nav_hunk("prev")
  end
end, { desc = "jump to previous git [c]hange", noremap = true, silent = true })
vim.keymap.set("n", "]c", function()
  if vim.wo.diff then
    vim.cmd.nomal({ "]c", bang = true })
  else
    gitsigns.nav_hunk("next")
  end
end, { desc = "jump to next git [c]hange", noremap = true, silent = true })
vim.keymap.set("n", "<leader>hs", gitsigns.stage_hunk, { desc = "git [s]tage hunk", noremap = true, silent = true })
vim.keymap.set("n", "<leader>hr", gitsigns.reset_hunk, { desc = "git [r]eset hunk", noremap = true, silent = true })
vim.keymap.set("n", "<leader>hS", gitsigns.stage_buffer, { desc = "git [S]tage buffer", noremap = true, silent = true })
vim.keymap.set(
  "n",
  "<leader>hu",
  gitsigns.stage_buffer,
  { desc = "git [u]nstage buffer", noremap = true, silent = true }
)
vim.keymap.set("n", "<leader>hR", gitsigns.reset_buffer, { desc = "git [R]eset buffer", noremap = true, silent = true })
vim.keymap.set("n", "<leader>hp", gitsigns.preview_hunk, { desc = "git [p]review hunk", noremap = true, silent = true })
vim.keymap.set("n", "<leader>hb", gitsigns.blame_line, { desc = "git [b]lame line", noremap = true, silent = true })
vim.keymap.set(
  "n",
  "<leader>tb",
  gitsigns.toggle_current_line_blame,
  { desc = "[T]oggle git show [b]lame line", noremap = true, silent = true }
)
vim.keymap.set(
  "n",
  "<leader>tD",
  gitsigns.preview_hunk_inline,
  { desc = "[T]oggle git show [D]eleted", noremap = true, silent = true }
)

-- diffview
vim.keymap.set("n", "<leader>hh", "<cmd>DiffviewOpen HEAD~1<CR>", { desc = "Show diff to previous commit" })
vim.keymap.set("n", "<leader>hf", "<cmd>DiffviewFileHistory %<CR>", { desc = "Show change histories" })
vim.keymap.set("n", "<leader>hc", "<cmd>DiffviewClose<CR>", { desc = "Diffview close" })
vim.keymap.set("n", "<leader>hd", "<cmd>DiffView<CR>", { desc = "Show conflict view" })

vim.keymap.set("n", "<leader>tr", vim.lsp.buf.rename, opts)

-- Overseer
-- vim.keymap.set("n", "<leader>r", "<cmd>OverseerRun<CR>", { desc = "Run task" })
-- vim.keymap.set("n", "<leader>R", "<cmd>OverseerToggle<CR>", { desc = "Toggle task list" })

-- DAP
vim.keymap.set("n", "<F5>", function()
  require("dap").continue()
end, { desc = "Continue" })
vim.keymap.set("n", "<F9>", function()
  require("dap").toggle_breakpoint()
end, { desc = "Toggle Breakpoint" })
vim.keymap.set("n", "<F10>", function()
  require("dap").step_over()
end, { desc = "Step Over" })
vim.keymap.set("n", "<F11>", function()
  require("dap").step_into()
end, { desc = "Step Into" })
vim.keymap.set("n", "<S-F11>", function()
  require("dap").step_out()
end, { desc = "Step Out" })

-- Testing
-- vim.keymap.set("n", "<leader>tt", function()
--   local filepath = vim.fn.expand("%:p")
--   local filename = vim.fn.fnamemodify(filepath, ":t:r")

--   local target_path
--   if filepath:match("/src/") then
--     target_path = filepath:gsub("/src/", "/tests/"):gsub("/([%w_%-]+)%.py$", "/test_%1.py")
--   elseif filepath:match("/tests/") then
--     target_path = filepath:gsub("/tests/", "/src/"):gsub("/test_([%w_%-]+)%.py$", "/%1.py")
--   else
--     vim.notify("Not in src/ or tests/", vim.log.levels.WARN)
--     return
--   end

--   for _, win in ipairs(vim.api.nvim_list_wins()) do
--     local buf = vim.api.nvim_win_get_buf(win)
--     local name = vim.api.nvim_buf_get_name(buf)
--     if name == target_path then
--       vim.api.nvim_set_current_win(win)
--       return
--     end
--   end

--   if vim.fn.filereadable(target_path) == 0 then
--     vim.fn.mkdir(vim.fn.fnamemodify(target_path, ":h"), "p")
--     vim.fn.writefile({}, target_path)
--     vim.notify("Created: " .. target_path)
--   end

--   vim.cmd("vsplit " .. target_path)
-- end)

vim.keymap.set("n", "<leader>tt", function()
  local filepath = vim.fn.expand("%:p")
  if not filepath:match("%.py$") then
    vim.notify("Not a Python file", vim.log.levels.WARN)
    return
  end

  local target_path

  if filepath:match("/src/") then
    -- src → tests へ変換
    target_path = filepath:gsub("/src/", "/tests/"):gsub("([/\\])([%w_%-]+)%.py$", "%1test_%2.py")
  else
    -- 同じディレクトリに test_*.py を作成
    local dir = vim.fn.fnamemodify(filepath, ":h")
    local base = vim.fn.fnamemodify(filepath, ":t:r")
    target_path = dir .. "/test_" .. base .. ".py"
  end

  -- すでにバッファで開かれている場合はフォーカスを移す
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf)
    if name == target_path then
      vim.api.nvim_set_current_win(win)
      return
    end
  end

  -- ファイルが存在しなければ作成
  if vim.fn.filereadable(target_path) == 0 then
    vim.fn.mkdir(vim.fn.fnamemodify(target_path, ":h"), "p")
    vim.fn.writefile({}, target_path)
    vim.notify("Created: " .. target_path)
  end

  -- 開く
  vim.cmd("vsplit " .. vim.fn.fnameescape(target_path))
end)

vim.keymap.set("n", "<leader>tr", function()
  require("neotest").run.run()
end, { desc = "Run nearest test" })

vim.keymap.set("n", "<leader>td", function()
  require("neotest").run.run({ strategy = "dap" })
end, { desc = "Debug nearest test" })

vim.keymap.set("n", "<leader>tf", function()
  require("neotest").run.run(vim.fn.expand("%"))
end, { desc = "Run test file" })

vim.keymap.set("n", "<leader>to", function()
  require("neotest").output.open({ enter = true, auto_close = true })
end, { desc = "Show test output" })

-- Insert mode
vim.keymap.set("i", ",", ",<Space>", opts)

-- Visual mode
vim.keymap.set("v", "v", "$h", opts)
