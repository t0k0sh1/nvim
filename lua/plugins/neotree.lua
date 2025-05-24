return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    version = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    },
    opts = {
      filesystem = {
        window = {
          position = "right",
          mappings = {
            ["\\"] = "close_window",
          },
        },
      },
      event_handlers = {
        {
          event = "file_opened",
          handler = function(_)
            require("neo-tree.command").execute({ action = "close" })
          end,
        },
      },
    },
  },
}
