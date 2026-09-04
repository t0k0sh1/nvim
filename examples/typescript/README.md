# TypeScript development with Neovim

This project exercises the TypeScript development features in this Neovim configuration:

- ts_ls diagnostics, completion, and imports
- ESLint and oxlint diagnostics
- Prettier formatting on save
- Neotest with Vitest
- V8 coverage rendered as line backgrounds

Install dependencies with `pnpm install`, open `src/greeting.ts`, then use:

- `<leader>tn`: run the nearest test
- `<leader>tf`: run tests in the current file
- `<leader>ta`: run all tests
- `<leader>tc`: run all tests with coverage and display the result
- `<leader>tC`: toggle coverage highlighting
- `<leader>tS`: show the coverage summary

The empty-name branch and `farewell` function are intentionally untested so
covered, uncovered, and partially covered lines are visible.
