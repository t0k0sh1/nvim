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
  { src = "https://github.com/lewis6991/gitsigns.nvim", name = "gitsigns" },
  { src = "https://github.com/smoka7/hop.nvim", name = "hop" },
  { src = "https://github.com/stevearc/conform.nvim", name = "conform" },
  { src = "https://github.com/neovim/nvim-lspconfig", name = "lspconfig" },
  { src = "https://github.com/nvim-lualine/lualine.nvim", name = "lualine" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons", name = "nvim-web-devicons" },
  { src = "https://github.com/b0o/schemastore.nvim", name = "schemastore" },
  { src = "https://github.com/nvim-lua/plenary.nvim", name = "plenary" },
  { src = "https://github.com/andythigpen/nvim-coverage", name = "coverage" },
  { src = "https://github.com/nvim-neotest/nvim-nio", name = "nvim-nio" },
  { src = "https://github.com/nvim-neotest/neotest", name = "neotest" },
  { src = "https://github.com/rcasia/neotest-java", name = "neotest-java" },
  { src = "https://github.com/nvim-neotest/neotest-python", name = "neotest-python" },
  { src = "https://github.com/rouge8/neotest-rust", name = "neotest-rust" },
  { src = "https://github.com/nvim-neotest/neotest-go", name = "neotest-go" },
  { src = "https://github.com/Arthur944/neotest-bun", name = "neotest-bun" },
  { src = "https://github.com/marilari88/neotest-vitest", name = "neotest-vitest" },
  { src = "https://github.com/MisanthropicBit/neotest-busted", name = "neotest-busted" },
  { src = "https://github.com/mfussenegger/nvim-jdtls", name = "nvim-jdtls" },
  { src = "https://github.com/nvim-telescope/telescope.nvim", name = "telescope" },
  {
    src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
    name = "telescope-fzf-native",
  },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", name = "treesitter" },
  { src = "https://github.com/github/copilot.vim", name = "copilot" },
  { src = "https://github.com/rachartier/tiny-cmdline.nvim", name = "tiny-cmdline" },
  { src = "https://github.com/folke/which-key.nvim", name = "which-key" },
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

vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(event)
    local data = event.data
    if data.spec.name ~= "treesitter" then
      return
    end
    if data.kind ~= "install" and data.kind ~= "update" then
      return
    end

    vim.schedule(function()
      require("nvim-treesitter").update()
    end)
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
