-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

if vim.fn.executable("nvr") == 1 then
  vim.env.EDITOR = 'nvr -cc split -c "set bufhidden=delete" --remote-wait'
end
