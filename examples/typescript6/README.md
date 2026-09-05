# TypeScript 6 development with Neovim

This project verifies the legacy TypeScript editor path in this Neovim configuration:

- `ts_ls` diagnostics, completion, and imports
- ESLint and Oxlint diagnostics
- Prettier formatting on save
- Neotest with Vitest
- V8 coverage rendered as line backgrounds

Install dependencies with `pnpm install`, open `src/greeting.ts`, then run
`:checkhealth nvim_config`. The health report should select
`typescript-language-server` for TypeScript 6.

The test and coverage mappings are the same as the TypeScript 7 example in
`../typescript`.
