# Java development with Neovim

This project exercises the Java development features in this Neovim configuration:

- Eclipse JDT Language Server diagnostics, completion, and imports
- google-java-format formatting on save
- Neotest with JUnit and the Gradle Wrapper
- JaCoCo line and branch coverage rendered as line backgrounds

Open `src/main/java/example/Greeting.java`, then use:

- `<leader>tn`: run the nearest test
- `<leader>tf`: run tests in the current file
- `<leader>ta`: run all tests
- `<leader>tc`: run all tests with coverage and display the result
- `<leader>tC`: toggle coverage highlighting
- `<leader>tS`: show the coverage summary

The empty-name branch and `farewell` method are intentionally untested so
covered, uncovered, and partially covered lines are visible.
