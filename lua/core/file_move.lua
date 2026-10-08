-- :MoveFile <path> moves the current file through LSP workspace/willRenameFiles,
-- so servers such as kotlin-lsp can update `package` declarations and imports.
local function move_file(new_path)
  local old_path = vim.fs.normalize(vim.api.nvim_buf_get_name(0))
  new_path = vim.fs.normalize(vim.fn.fnamemodify(new_path, ":p"))

  if old_path == "" or vim.fn.filereadable(old_path) == 0 then
    vim.notify("Current buffer is not a saved file", vim.log.levels.ERROR)
    return
  end
  if vim.uv.fs_stat(new_path) then
    vim.notify("Already exists: " .. new_path, vim.log.levels.ERROR)
    return
  end
  vim.cmd("silent update")

  local params = {
    files = { { oldUri = vim.uri_from_fname(old_path), newUri = vim.uri_from_fname(new_path) } },
  }
  local clients = vim.lsp.get_clients({ method = "workspace/willRenameFiles" })

  -- kotlin-lsp resolves the target package from the directory, so it must exist first.
  local new_dir = vim.fs.dirname(new_path)
  if vim.fn.isdirectory(new_dir) == 0 then
    vim.fn.mkdir(new_dir, "p")
    -- Give the server time to notice the new directory through its file watcher.
    vim.wait(3000)
  end

  -- Ask the servers for edits before touching the file on disk.
  for _, client in ipairs(clients) do
    local response = client:request_sync("workspace/willRenameFiles", params, 30000)
    if response and response.result then
      vim.lsp.util.apply_workspace_edit(response.result, client.offset_encoding)
    end
  end
  vim.cmd("silent wall")

  if vim.fn.rename(old_path, new_path) ~= 0 then
    vim.notify("Failed to move " .. old_path, vim.log.levels.ERROR)
    return
  end

  local old_buf = vim.api.nvim_get_current_buf()
  vim.cmd("edit " .. vim.fn.fnameescape(new_path))
  pcall(vim.api.nvim_buf_delete, old_buf, { force = true })

  for _, client in ipairs(vim.lsp.get_clients({ method = "workspace/didRenameFiles" })) do
    client:notify("workspace/didRenameFiles", params)
  end
end

vim.api.nvim_create_user_command("MoveFile", function(opts)
  move_file(opts.args)
end, { nargs = 1, complete = "file", desc = "Move file via LSP willRenameFiles" })
