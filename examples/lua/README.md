# Lua example

This project exercises Busted tests and LuaCov line coverage.

```sh
nix develop
nvim src/greeting.lua
```

Inside Neovim, use `<leader>tn` or `<leader>tf` to run tests and `<leader>tc`
to run the complete suite with coverage. The intentionally untested
`audience` function makes uncovered lines visible.
