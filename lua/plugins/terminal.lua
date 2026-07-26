local M = {}

local state = {
  floating_win = -1,
  floating_buf = -1,
}

local function get_shell_command()
  if not vim.o.shell:match("zsh$") then
    return vim.o.shell
  end

  local zdotdir = vim.fn.stdpath("cache") .. "/nvim-terminal-zsh"
  local zshrc = zdotdir .. "/.zshrc"

  vim.fn.mkdir(zdotdir, "p")

  local file = io.open(zshrc, "w")
  if file then
    file:write([[
export TMUX=nvim-terminal-skip-autostart
source "$HOME/.zshrc"
unset TMUX
]])
    file:close()
  end

  return { vim.o.shell, "-i" }, { ZDOTDIR = zdotdir }
end

function M.toggle_terminal()
  if vim.api.nvim_win_is_valid(state.floating_win) then
    vim.api.nvim_win_close(state.floating_win, true)
    return
  end

  if not vim.api.nvim_buf_is_valid(state.floating_buf) then
    state.floating_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[state.floating_buf].bufhidden = "wipe"
  end

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
  }

  state.floating_win = vim.api.nvim_open_win(state.floating_buf, true, win_opts)

  if vim.bo[state.floating_buf].buftype ~= "terminal" then
    local command, env = get_shell_command()
    vim.fn.termopen(command, { env = env })
  end

  vim.bo[state.floating_buf].buflisted = false

  vim.cmd("startinsert")
end

return M
