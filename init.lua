-- set <space> as the leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- disable providers we don't use to speed up startup time
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Make tools installed by the platform setup scripts available to Neovim.
require("core.path")

-- Keep Tab available for our Copilot/snippet fallback mapping.
vim.g.copilot_no_tab_map = true
vim.g.copilot_filetypes = {
  markdown = false,
  text = false,
  env = false,
}

vim.g.mkdp_filetypes = { "markdown" }
vim.g.mkdp_auto_start = 0
vim.g.mkdp_auto_close = 1
vim.g.mkdp_open_to_the_world = 0

-- install and load plugins
require("core.packages")

-- load colorscheme
vim.cmd([[colorscheme karasuma]])
vim.api.nvim_set_hl(0, "tsxIntrinsicTagName", { link = "Tag" })

-- load core settings, keymaps and autocommands
require("core.options")
require("plugins.testing")
require("core.keymaps")
require("core.autocmds")

-- load core plugins
require("plugins.telescope")
require("plugins.lualine")
require("plugins.tiny-cmdline")
require("plugins.hop")
require("plugins.treesitter")
require("plugins.gitsigns")
require("plugins.which-key")

-- load coding plugins
require("plugins.copilot")
require("plugins.lsp")
require("plugins.conform")
require("plugins.lint")
require("plugins.html-css")

-- add filetype for .gotmpl files
vim.filetype.add({
  extension = {
    gotmpl = "gotmpl",
  },
})
