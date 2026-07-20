local function build_fzf(path)
  local result = vim.system({ "make" }, { cwd = path }):wait()
  if result.code ~= 0 then
    vim.notify(
      "Failed to build telescope-fzf-native:\n" .. (result.stderr or ""),
      vim.log.levels.ERROR
    )
  end
end

local specs = {
  { src = "https://github.com/t0k0sh1/karasuma.nvim", name = "karasuma" },
  { src = "https://github.com/smoka7/hop.nvim", name = "hop" },
  { src = "https://github.com/stevearc/conform.nvim", name = "conform" },
  { src = "https://github.com/neovim/nvim-lspconfig", name = "lspconfig" },
  { src = "https://github.com/nvim-lualine/lualine.nvim", name = "lualine" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons", name = "nvim-web-devicons" },
  { src = "https://github.com/nvim-lua/plenary.nvim", name = "plenary" },
  { src = "https://github.com/nvim-telescope/telescope.nvim", name = "telescope" },
  {
    src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
    name = "telescope-fzf-native",
  },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", name = "treesitter" },
  { src = "https://github.com/milanglacier/minuet-ai.nvim", name = "minuet" },
  { src = "https://github.com/rachartier/tiny-cmdline.nvim", name = "tiny-cmdline" },
}

vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(event)
    local data = event.data
    if data.spec.name ~= "telescope-fzf-native" then
      return
    end
    if data.kind ~= "install" and data.kind ~= "update" then
      return
    end

    build_fzf(data.path)
  end,
})

vim.pack.add(specs, { confirm = false, load = true })

local fzf = vim.pack.get({ "telescope-fzf-native" })[1]
if fzf and vim.fn.empty(vim.fn.glob(fzf.path .. "/build/libfzf.*")) == 1 then
  build_fzf(fzf.path)
end

vim.api.nvim_create_user_command("PackUpdate", function(opts)
  local names = #opts.fargs > 0 and opts.fargs or nil
  vim.pack.update(names, { force = opts.bang })
end, {
  nargs = "*",
  bang = true,
  desc = "Update plugins managed by vim.pack",
})

vim.cmd([[
  cnoreabbrev <expr> packupdate getcmdtype() ==# ':' && getcmdline() ==# 'packupdate' ? 'PackUpdate' : 'packupdate'
]])
