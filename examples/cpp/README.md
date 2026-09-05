# C++ example

This project exercises GoogleTest through Neotest and LLVM source coverage.

```sh
nix develop
nvim src/greeting.cpp
```

Use `<leader>tc` to configure with CMake, build with Ninja, run CTest, and show
coverage. The intentionally untested `audience` function remains uncovered.

For individual Neotest runs, first open the test summary with `<leader>ts`, mark
the project directory with `m`, press `C`, and enter
`build/coverage/greeting_test`. This executable assignment is persisted; after
that, `<leader>tn`, `<leader>tf`, and the other common test mappings work normally.
