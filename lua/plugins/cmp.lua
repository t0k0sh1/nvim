return {
  "hrsh7th/nvim-cmp",
  enabled = true,
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/cmp-emoji",
    "zbirenbaum/copilot-cmp",
  },
  opts = function()
    local cmp = require("cmp")
    mapping = cmp.mapping.preset.insert({
      ["<Tab>"] = cmp.mapping.select_next_item(),
      ["S-Tab"] = cmp.mapping.select_prev_item(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
    })
    sources = cmp.config.sources({
      { name = "nvim_lsp", keyword_length = 1 },
      { name = "buffer", keyword_length = 3 },
      { name = "path" },
      { name = "emoji" },
    })
  end,
}