-- set <space> as the leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- disable providers we don't use to speed up startup time
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Make globally installed Bun tools available to Neovim
vim.env.PATH = vim.fn.expand("~/.bun/bin") .. ":" .. vim.env.PATH

-- install and load plugins
require("core.packages")

-- load colorscheme
vim.cmd([[colorscheme karasuma]])
vim.api.nvim_set_hl(0, "tsxIntrinsicTagName", { link = "Tag" })

-- load core settings, keymaps and autocommands
require("core.options")
require("core.keymaps")
require("core.autocmds")

-- load core plugins
require("plugins.telescope")
require("plugins.lualine")
require("plugins.tiny-cmdline")
require("plugins.hop")
require("plugins.treesitter")
require("plugins.gitsigns")

-- load coding plugins
require("plugins.minuet")
require("plugins.lsp")
require("plugins.conform")

-- add filetype for .gotmpl files
vim.filetype.add({
  extension = {
    gotmpl = "gotmpl",
  },
})
