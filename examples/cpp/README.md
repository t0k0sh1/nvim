# C++ example

This project exercises GoogleTest through Neotest and LLVM source coverage.

```sh
nix develop
nvim src/greeting.cpp
```

Use `<leader>tc` to configure with CMake, build with Ninja, run CTest, and show
coverage. The intentionally untested `audience` function remains uncovered.

When CTest reports one GoogleTest executable, it is assigned to Neotest
automatically. `<leader>tn`, `<leader>tf`, and the other common test mappings can
then run it directly. Projects with multiple test executables remain ambiguous;
for those, open `<leader>ts`, mark a group with `m`, and press `C` to select its
executable manually.
