# Neovim configuration

## Setup

The setup scripts install the runtimes, language servers, formatters, linters,
and test tools used by this configuration.

### macOS

Install Homebrew first, then run:

```sh
./scripts/install-macos.sh
```

Most tools previously installed through Nix are installed with Homebrew. Rust
uses rustup so projects can select their toolchain. Lombok is downloaded from
its official distribution because it does not have a Homebrew formula, and
LuaCov is installed through LuaRocks.

### Ubuntu

Run:

```sh
./scripts/install-ubuntu.sh
```

The script uses `apt-get` for system packages. Tools unavailable or too old in
Ubuntu's repositories are installed from their official distribution channels
into the user account. Add `~/.local/bin` to the shell `PATH` after setup.

### Verify the environment

Open Neovim in the project you want to inspect and run:

```vim
:checkhealth nvim_config
```

The report separates common editor tools, language servers, formatters and
linters, optional test and coverage tools, and dependencies detected for the
current project.

Some test dependencies intentionally remain project-local so their versions
match the project. Examples include `pytest` and `pytest-cov` in a uv project,
Vitest and its coverage provider in a JavaScript project, GoogleTest in a CMake
project, and JaCoCo configured through a project's Gradle wrapper.

## Keymaps

`<leader>` is the Space key. Leader mappings can also be discovered through
which-key by pressing Space and waiting for the menu.

### General

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>w` | Normal | Save the current file if it has changed |
| `<leader>q` | Normal | Quit the current window |
| `<leader>Q` | Normal | Quit Neovim without saving |
| `<leader><leader>` | Normal | Jump to a visible word |

### Buffers

| Key | Mode | Action |
| --- | --- | --- |
| `<S-h>` | Normal | Go to the previous buffer |
| `<S-l>` | Normal | Go to the next buffer |
| `<leader>bc` | Normal | Close the current buffer |
| `<leader>bo` | Normal | Close all buffers except the current one |
| `<leader>ba` | Normal | Close all buffers without quitting Neovim |

### Find

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>ff` | Normal | Find project files |
| `<leader>fF` | Normal | Find files including hidden and ignored files |
| `<leader>fg` | Normal | Search text in project files |
| `<leader>fb` | Normal | Find an open buffer |
| `<leader>fd` | Normal | Show diagnostics in the current buffer |
| `<leader>fD` | Normal | Show diagnostics in the workspace |

### LSP and code actions

These mappings are available when an LSP server is attached to the buffer.

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>ls` | Normal | Find symbols in the current file |
| `<leader>lS` | Normal | Find symbols in the workspace |
| `<leader>ld` | Normal | Show the diagnostic at the cursor |
| `<leader>lh` | Normal | Toggle inlay hints when supported by the LSP server |
| `<leader>ca` | Normal, Visual | Show available code actions |
| `<leader>cf` | Normal | Apply a Quick Fix |
| `<leader>ci` | Normal | Organize imports |
| `<leader>cr` | Normal | Rename the symbol under the cursor |

### Tests and coverage

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>tp` | Normal | Switch between implementation and test files |
| `<leader>tn` | Normal | Run the nearest test |
| `<leader>tf` | Normal | Run tests in the current file |
| `<leader>ta` | Normal | Run all tests |
| `<leader>tl` | Normal | Run the previous test again |
| `<leader>to` | Normal | Show output for the nearest test |
| `<leader>tO` | Normal | Toggle the test output panel |
| `<leader>ts` | Normal | Toggle the test summary |
| `<leader>tc` | Normal | Run tests and load coverage |
| `<leader>tC` | Normal | Toggle coverage highlighting |
| `<leader>tS` | Normal | Show the coverage summary |

### Markdown

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>mp` | Normal | Toggle the browser preview for the current Markdown file |

### Git hunks

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>hp` | Normal | Preview the hunk at the cursor |
| `<leader>hs` | Normal, Visual | Stage the current or selected hunk |
| `<leader>hu` | Normal | Undo staging the current hunk |
| `<leader>hr` | Normal, Visual | Reset the current or selected hunk |
| `<leader>hb` | Normal | Show blame information for the current line |

### LSP navigation

These mappings are available when an LSP server is attached to the buffer.

| Key | Mode | Action |
| --- | --- | --- |
| `gd` | Normal | Go to definition, including CSS classes used in HTML/JSX/TSX |
| `gD` | Normal | Go to declaration |
| `gi` | Normal | Go to implementation |
| `gr` | Normal | Show references |
| `K` | Normal | Show documentation for the symbol under the cursor |
| `<C-k>` | Insert | Show signature help |

### Jump history

Definition jumps made with `gd` are recorded in Neovim's jump list. These keys
work like Back and Forward in a browser.

| Key | Mode | Action |
| --- | --- | --- |
| `<C-o>` | Normal | Go back to an older cursor position |
| `<C-i>` | Normal | Go forward to a newer cursor position |

Depending on the terminal, `<C-i>` and `<Tab>` may be treated as the same key.

### Diagnostics and Git changes

| Key | Mode | Action |
| --- | --- | --- |
| `[d` | Normal | Go to the previous diagnostic and show its message |
| `]d` | Normal | Go to the next diagnostic and show its message |
| `[h` | Normal | Go to the previous Git hunk |
| `]h` | Normal | Go to the next Git hunk |

### Search

| Key | Mode | Action |
| --- | --- | --- |
| `n` | Normal | Go to the next search match and center it |
| `N` | Normal | Go to the previous search match and center it |
| `<Esc>` | Normal | Clear search highlighting |

### Comments

The `gc` operator uses the comment syntax for the current file type. Repeating
the same operation removes the comment.

| Key | Mode | Action |
| --- | --- | --- |
| `gcc` | Normal | Toggle the comment on the current line |
| `gc{motion}` | Normal | Toggle comments over a motion, for example `gcap` for a paragraph |
| `gc` | Visual | Toggle comments on the selection |

### Editing

| Key | Mode | Action |
| --- | --- | --- |
| `x` | Normal | Delete a character without copying it |
| `+` | Normal | Increment the number under the cursor |
| `-` | Normal | Decrement the number under the cursor |
| `<C-a>` | Normal | Select the entire buffer |
| `<` | Visual | Unindent and keep the selection |
| `>` | Visual | Indent and keep the selection |
| `<Esc>` | Terminal | Leave Terminal mode |

### Completion

| Key | Mode | Action |
| --- | --- | --- |
| `<Tab>` | Insert | Accept a Copilot suggestion, jump to the next snippet field, or insert a tab |
| `<C-l>` | Insert | Accept the next word of a Copilot suggestion |
| `<C-j>` | Insert | Accept the next line of a Copilot suggestion |
