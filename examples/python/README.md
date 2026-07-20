# Python development with Neovim and uv

This example runs Neovim, Python, uv, Pyrefly, Ruff, and pytest inside a Linux
development container. The Neovim configuration from this repository is
mounted into the container.

## Prerequisites

- Docker Desktop (or another Docker-compatible runtime)
- Dev Container CLI 0.82.0 or newer
- This repository checked out at `~/.config/nvim`

Install the CLI with pnpm if needed:

```sh
pnpm add --global @devcontainers/cli@0.82.0
```

## Start the container

From the repository root:

```sh
devcontainer up --workspace-folder examples/python
```

## Open the project in Neovim

```sh
devcontainer exec --workspace-folder examples/python nvim .
```

## Run the checks

```sh
devcontainer exec --workspace-folder examples/python uv run pytest
devcontainer exec --workspace-folder examples/python uv run ruff check .
```

The project environment is stored in a Docker named volume mounted at
`/home/vscode/.venv`, so a Linux virtual environment is not written into the
macOS workspace. Neovim plugins and the Supermaven binary are also stored in
named volumes and survive container recreation.
