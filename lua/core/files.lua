local M = {}

local function move_to_trash(path)
  local trash = vim.fn.exepath("trash")
  if trash == "" then
    return false, "trash command is not available"
  end

  local result = vim.system({ trash, path }, { text = true }):wait()
  if result.code ~= 0 then
    local message = vim.trim(result.stderr or "")
    return false, message ~= "" and message or "trash command failed"
  end

  return true
end

local function directory_is_empty(path)
  local scanner = vim.uv.fs_scandir(path)
  return scanner ~= nil and vim.uv.fs_scandir_next(scanner) == nil
end

local function offer_to_trash_empty_directory(path)
  if not directory_is_empty(path) then
    return
  end

  local confirmed = vim.fn.confirm(
    "The directory is now empty. Move it to Trash?\n" .. path,
    "&Delete directory\n&Keep directory",
    2
  ) == 1

  if not confirmed then
    return
  end

  local cwd = vim.fs.normalize(vim.fn.getcwd())
  if cwd == path then
    vim.api.nvim_set_current_dir(vim.fs.dirname(path))
  end

  local deleted, error_message = move_to_trash(path)
  if not deleted then
    vim.notify("Failed to delete directory: " .. error_message, vim.log.levels.ERROR)
  end
end

function M.rename_current_file()
  local bufnr = vim.api.nvim_get_current_buf()
  local path = vim.api.nvim_buf_get_name(bufnr)

  if path == "" or vim.bo[bufnr].buftype ~= "" then
    vim.notify("The current buffer is not a file", vim.log.levels.WARN)
    return
  end

  path = vim.fs.normalize(path)
  if vim.uv.fs_stat(path) == nil then
    vim.notify("File does not exist: " .. path, vim.log.levels.WARN)
    return
  end

  vim.ui.input({
    prompt = "Rename file: ",
    default = vim.fn.fnamemodify(path, ":."),
    completion = "file",
    scope = "buffer",
  }, function(input)
    if input == nil or input == "" or not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end

    local target = vim.fs.normalize(vim.fn.fnamemodify(vim.fn.expand(input), ":p"))
    if target == path then
      return
    end

    if vim.uv.fs_stat(target) ~= nil or vim.fn.bufnr(target) ~= -1 then
      vim.notify("Destination already exists: " .. target, vim.log.levels.ERROR)
      return
    end

    local target_parent = vim.fs.dirname(target)
    if vim.fn.isdirectory(target_parent) == 0 then
      vim.fn.mkdir(target_parent, "p")
      if vim.fn.isdirectory(target_parent) == 0 then
        vim.notify("Could not create destination directory: " .. target_parent, vim.log.levels.ERROR)
        return
      end
    end

    local saved, save_error = pcall(vim.api.nvim_buf_call, bufnr, function()
      vim.cmd("silent update")
    end)
    if not saved then
      vim.notify("Could not save file: " .. tostring(save_error), vim.log.levels.ERROR)
      return
    end

    local mv = vim.fn.exepath("mv")
    local result = vim.system({ mv, path, target }, { text = true }):wait()
    if result.code ~= 0 then
      local message = vim.trim(result.stderr or "")
      vim.notify("Failed to rename file: " .. message, vim.log.levels.ERROR)
      return
    end

    vim.api.nvim_buf_set_name(bufnr, target)
    offer_to_trash_empty_directory(vim.fs.dirname(path))
    vim.notify("Renamed file to: " .. target)
  end)
end

function M.delete_current_file()
  local bufnr = vim.api.nvim_get_current_buf()
  local path = vim.api.nvim_buf_get_name(bufnr)

  if path == "" or vim.bo[bufnr].buftype ~= "" then
    vim.notify("The current buffer is not a file", vim.log.levels.WARN)
    return
  end

  path = vim.fs.normalize(path)
  if vim.uv.fs_stat(path) == nil then
    vim.notify("File does not exist: " .. path, vim.log.levels.WARN)
    return
  end

  local prompt = "Move this file to Trash?\n" .. path
  if vim.bo[bufnr].modified then
    prompt = prompt .. "\n\nUnsaved changes will be discarded."
  end

  if vim.fn.confirm(prompt, "&Delete\n&Cancel", 2) ~= 1 then
    return
  end

  local deleted, error_message = move_to_trash(path)
  if not deleted then
    vim.notify("Failed to delete file: " .. error_message, vim.log.levels.ERROR)
    return
  end

  -- Prevent the BufLeave autosave from recreating the deleted file.
  vim.bo[bufnr].modified = false

  offer_to_trash_empty_directory(vim.fs.dirname(path))

  vim.api.nvim_buf_delete(bufnr, { force = true })
  vim.notify("Moved to Trash: " .. path)
end

return M
