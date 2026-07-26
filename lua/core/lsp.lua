local M = {}

function M.client_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.workspace.fileOperations = {
    dynamicRegistration = false,
    didCreate = true,
    willCreate = true,
    didRename = true,
    willRename = true,
    didDelete = true,
    willDelete = true,
  }
  return capabilities
end

return M
