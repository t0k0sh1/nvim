return {
  "nvim-telescope/telescope.nvim",
  cmd = { "Telescope" },
  tag = "0.1.8",
  branch = "0.1.x",
  dependencies = {
    { "nvim-lua/plenary.nvim", lazy = true },
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond = function()
        return vim.fn.executable("make") == 1
      end,
      lazy = true,
    },
    {
      "nvim-telescope/telescope-ui-select.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
      config = function()
        require("telescope").load_extension("ui-select")
      end,
      lazy = true,
    },
    -- {
    --   "nvim-telescope/nvim-web-devicons",
    --   enabled = vim.g.have_nerd_font,
    --   lazy = true,
    -- },
  },
  require("telescope").setup({
    extensions = {
      ["ui-select"] = {
        require("telescope.themes").get_dropdown(),
      },
    },
  }),
}
