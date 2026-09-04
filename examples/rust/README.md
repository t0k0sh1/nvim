# Rust development with Neovim

This project exercises the Rust development features in this Neovim configuration:

- rust-analyzer diagnostics, completion, and imports
- rustfmt formatting on save
- Clippy checks
- Neotest with cargo-nextest
- line-based coverage with cargo-llvm-cov and cargo-nextest

Open `src/lib.rs`, then use these mappings:

- `<leader>tn`: run the nearest test
- `<leader>tf`: run tests in the current file
- `<leader>ta`: run all tests
- `<leader>tc`: run all tests with coverage and display the result
- `<leader>tC`: toggle coverage highlighting
- `<leader>tS`: show the coverage summary

The empty-name branch and `farewell` function are intentionally untested so
covered and uncovered lines are both visible.
