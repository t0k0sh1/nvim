# TypeScript 7 development with Neovim

This project exercises the TypeScript development features in this Neovim configuration:

- TypeScript 7 native-LSP diagnostics, completion, and imports
- ESLint and oxlint diagnostics
- Prettier formatting on save
- Neotest with Vitest
- V8 coverage rendered as line backgrounds

Install dependencies with `pnpm install`, open `src/greeting.ts`, then use:

The `@typescript/native` alias supplies the TypeScript 7 compiler and native
LSP, while the `typescript` alias supplies the TypeScript 6 API currently
required by `typescript-eslint`.

- `<leader>tn`: run the nearest test
- `<leader>tf`: run tests in the current file
- `<leader>ta`: run all tests
- `<leader>tc`: run all tests with coverage and display the result
- `<leader>tC`: toggle coverage highlighting
- `<leader>tS`: show the coverage summary

The empty-name branch and `farewell` function are intentionally untested so
covered, uncovered, and partially covered lines are visible.
