return {
  "norcalli/nvim-colorizer.lua",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("colorizer").setup({
      "*",
    }, {
      names = true, -- CSS color names like "red"
      RGB = true, -- #RGB hex codes
      RRGGBB = true, -- #RRGGBB hex codes
      RRGGBBAA = true, -- #RRGGBBAA hex codes
      rgb_fn = true, -- rgb() and rgba()
      hsl_fn = true, -- hsl() and hsla()
      css = true, -- Enable all CSS features
      css_fn = true, -- Enable functions like linear-gradient()
    })
  end,
}
