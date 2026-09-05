local group = vim.api.nvim_create_augroup("HtmlCssLsp", { clear = true })
local html_css_utils = require("html-css.utils")
local original_file_exists = html_css_utils.file_exists
local original_exrc = vim.o.exrc
local project_config = vim.fs.joinpath(assert(vim.uv.cwd()), ".nvim.lua")

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.name == "html-css-lsp" then
      -- Keep CSS class completion and definition navigation without adding CSS hover results.
      client.server_capabilities.hoverProvider = false
    end
  end,
})

-- nvim-html-css loads a project-local .nvim.lua with dofile(). Do not allow CSS
-- support to bypass Neovim's trust mechanism for local configuration files.
html_css_utils.file_exists = function(path)
  if vim.fs.normalize(path) == vim.fs.normalize(project_config) then
    return false
  end
  return original_file_exists(path)
end

local ok, err = xpcall(function()
  require("html-css").setup({
    enable_on = { "html", "jsx", "tsx" },
    handlers = {
      definition = { bind = "gd" },
    },
    peek = {
      enabled = false,
    },
  })
end, debug.traceback)

html_css_utils.file_exists = original_file_exists
vim.o.exrc = original_exrc

if not ok then
  error(err)
end
