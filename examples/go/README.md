# Go development with Neovim

This project exercises the Go development features in this Neovim configuration:

- gopls diagnostics, completion, and imports
- gofmt through LSP formatting on save
- Neotest with `go test`
- line-based coverage using the Go coverprofile format

Open `greeting.go`, then use these mappings:

- `<leader>tn`: run the nearest test
- `<leader>tf`: run tests in the current file
- `<leader>ta`: run all tests
- `<leader>tc`: run all tests with coverage and display the result
- `<leader>tC`: toggle coverage highlighting
- `<leader>tS`: show the coverage summary

`Farewell` is intentionally untested so both covered and uncovered lines are visible.
