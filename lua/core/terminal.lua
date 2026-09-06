local M = {}

local state = {
  buffer = nil,
  window = nil,
  return_window = nil,
}

local root_markers = {
  ".git",
  "package.json",
  "pyproject.toml",
  "Cargo.toml",
  "go.mod",
  "CMakeLists.txt",
  "settings.gradle",
  "settings.gradle.kts",
  "build.gradle",
  "build.gradle.kts",
}

local function valid_buffer(buffer)
  return buffer and vim.api.nvim_buf_is_valid(buffer)
end

local function valid_window(window)
  return window and vim.api.nvim_win_is_valid(window)
end

local function terminal_is_visible()
  return valid_window(state.window)
    and valid_buffer(state.buffer)
    and vim.api.nvim_win_get_buf(state.window) == state.buffer
end

local function project_root()
  local buffer_name = vim.api.nvim_buf_get_name(0)
  if buffer_name ~= "" and vim.bo.buftype == "" then
    return vim.fs.root(buffer_name, root_markers) or vim.fs.dirname(buffer_name)
  end
  return vim.fn.getcwd()
end

local function terminal_height()
  local available = math.max(1, vim.o.lines - vim.o.cmdheight - 2)
  return math.min(available, math.max(8, math.floor(available * 0.3)))
end

local function clear_state(buffer)
  if state.buffer == buffer then
    state.buffer = nil
    state.window = nil
    state.return_window = nil
  end
end

local function create_terminal(cwd)
  local buffer = vim.api.nvim_get_current_buf()
  state.buffer = buffer

  vim.bo[buffer].buflisted = false
  vim.bo[buffer].bufhidden = "hide"
  vim.bo[buffer].swapfile = false

  local job = vim.fn.jobstart({ vim.o.shell }, {
    cwd = cwd,
    term = true,
    on_exit = function()
      vim.schedule(function()
        clear_state(buffer)
        if vim.api.nvim_buf_is_valid(buffer) then
          vim.api.nvim_buf_delete(buffer, { force = true })
        end
      end)
    end,
  })

  if job <= 0 then
    clear_state(buffer)
    error("Failed to start terminal shell")
  end
end

local function show()
  local cwd = project_root()
  state.return_window = vim.api.nvim_get_current_win()
  vim.cmd(("botright %dsplit"):format(terminal_height()))
  state.window = vim.api.nvim_get_current_win()

  if valid_buffer(state.buffer) then
    vim.api.nvim_win_set_buf(state.window, state.buffer)
  else
    vim.cmd("enew")
    create_terminal(cwd)
  end

  vim.wo[state.window].number = false
  vim.wo[state.window].relativenumber = false
  vim.wo[state.window].signcolumn = "no"
  vim.cmd("startinsert")
end

local function hide()
  local terminal_window = state.window
  local return_window = state.return_window

  if #vim.api.nvim_tabpage_list_wins(0) == 1 then
    vim.cmd("aboveleft new")
    return_window = vim.api.nvim_get_current_win()
  end

  vim.api.nvim_win_hide(terminal_window)
  state.window = nil

  if valid_window(return_window) then
    vim.api.nvim_set_current_win(return_window)
  end
end

function M.toggle()
  if terminal_is_visible() then
    hide()
  else
    state.window = nil
    show()
  end
end

vim.api.nvim_create_user_command("TerminalToggle", M.toggle, {
  desc = "Toggle the persistent bottom terminal",
})

return M
