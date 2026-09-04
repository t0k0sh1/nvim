vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"
if vim.fn.executable("nvr") == 1 then
  vim.env.EDITOR = 'nvr -cc split -c "set bufhidden=delete" --remote-wait'
end

-- general settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.title = true
vim.opt.wrap = false
vim.opt.scrolloff = 10
vim.opt.signcolumn = "yes"
vim.opt.completeopt = { "menuone", "noselect", "popup" }

-- indentation settings
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.breakindent = true

-- search settings
vim.opt.ignorecase = true
vim.opt.inccommand = "split"

-- split settings
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.splitkeep = "cursor"
vim.opt.backup = false

-- UI settings
vim.opt.cmdheight = 0
vim.opt.laststatus = 3
vim.opt.mouse = ""

-- file searching settings
vim.opt.path:append({ "**" })
vim.opt.wildignore:append({ "*/node_modules/*" })

-- format options
vim.opt.formatoptions:append({ "r" })

vim.opt.cursorline = true
vim.opt.cursorlineopt = "both"
