return {
  {
    "mfussenegger/nvim-dap",
    lazy = true,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = {
      handlers = {},
      automatic_installation = {
        exclude = {
          "delve",
          "python",
        }
      },
      ensure_installed = {
        "python",
      },
    },
    dependencies = {
      "mfussenegger/nvim-dap",
      "williamboman/mason.nvim",
    }
  },
  {
    "mfussenegger/nvim-dap-python",
    lazy = true,
    config = function()
      if vim.fn.filereadable("./pyproject.toml") == 1 then
        local venv = vim.fn.system("poetry env info -p"):gsub("\n", "") .. "/bin/python"
        require("dap-python").setup(venv)
      elseif vim.fn.filereadable(".venv/bin/python") == 1 then
        local venv = vim.fn.expand(".venv/bin/python")
        require("dap-python").setup(venv)
      elseif vim.fn.filereadable("venv/bin/python") == 1 then
        local venv = vim.fn.expand("venv/bin/python")
        require("dap-python").setup(venv)
      else
        -- Fallback to the default debugpy installation
        local venv = vim.fn.expand("~/.local/share/nvim/mason/packages/debugpy/venv/bin/python")
        require("dap-python").setup(venv)
      end
    end,
    dependencies = {
      "mfussenegger/nvim-dap",
    }
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    config = true,
    dependencies = {
      "mfussenegger/nvim-dap",
    }
  },
  {
    "rcarriga/nvim-dap-ui",
    config = true,
    keys = {
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
    },
    dependencies = {
      "jay-babu/mason-nvim-dap.nvim",
      "mfussenegger/nvim-dap-python",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
    }
  },
}
