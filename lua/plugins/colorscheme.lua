return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000,
  opts = {
    flavour = "mocha",
    background = {
      dark = "mocha",
      light = "latte",
    },
    transparent_background = false,
    show_end_of_buffer = false,
    term_colors = false,
    dim_inactive = {
      enabled = true,
      shade = "dark",
      percentage = 0.15,
    },
    default_integrations = true,
    integrations = {
      cmp = true,
      gitsigns = true,
      treesitter = true,
      notify = true,
      neotree = true,
      telescope = true,
      native_lsp = {
        enabled = true,
        virtual_text = {
          errors = { "italic" },
          hints = { "italic" },
          warnings = { "italic" },
          information = { "italic" },
          ok = { "italic" },
        },
        underlines = {
          errors = { "underline" },
          hints = { "underline" },
          warnings = { "underline" },
          information = { "underline" },
          ok = { "underline" },
        },
        inlay_hints = {
          background = true,
        },
      },
      overseer = true,
      copilot_vim = true,
      neotest = true,
      mini = {
        enabled = true,
        indentscope_color = ""
      }
    },
  },
  config = function(_, opts)
    require("catppuccin").setup(opts)
    vim.cmd.colorscheme("catppuccin")
    vim.api.nvim_set_hl(0, "CursorLineNr", { bold = true })
  end,
}
