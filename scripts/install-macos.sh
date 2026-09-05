#!/usr/bin/env bash

set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This script supports macOS only." >&2
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required: https://brew.sh" >&2
  exit 1
fi

packages=(
  bash-language-server
  biome
  bun
  busted
  cargo-llvm-cov
  cargo-nextest
  cmake
  docker-language-server
  fd
  git
  go
  google-java-format
  gopls
  htmlhint
  jdtls
  lua
  lua-language-server
  luarocks
  llvm@22
  marksman
  neovim
  neovim-remote
  ninja
  node
  openjdk@25
  oxlint
  prettier
  prettierd
  pyrefly
  python
  ripgrep
  ruff
  shellcheck
  shfmt
  stylua
  tombi
  typescript-language-server
  uv
  vscode-langservers-extracted
  yaml-language-server
)

brew install "${packages[@]}"

# Rustup supports project-specific toolchains through rust-toolchain.toml.
if ! command -v rustup >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 --fail --silent --show-error https://sh.rustup.rs \
    | sh -s -- -y --profile default
fi
"${HOME}/.cargo/bin/rustup" toolchain install stable
"${HOME}/.cargo/bin/rustup" default stable
"${HOME}/.cargo/bin/rustup" component add rust-analyzer rustfmt

# LuaCov is not available as a Homebrew formula.
luarocks install --local luacov

# ESLint rules belong to each project, but a global fallback keeps its LSP usable.
npm install --global eslint

# Lombok is the only Nix-installed editor dependency without a Homebrew formula.
local_bin="${HOME}/.local/bin"
lombok_dir="${HOME}/.local/share/lombok"
mkdir -p "$local_bin" "$lombok_dir"
curl --fail --location --silent --show-error \
  https://projectlombok.org/downloads/lombok.jar \
  --output "${lombok_dir}/lombok.jar"
printf '#!/usr/bin/env bash\n# %s\nexec java -jar "%s" "$@"\n' \
  "${lombok_dir}/lombok.jar" "${lombok_dir}/lombok.jar" > "${local_bin}/lombok"
chmod +x "${local_bin}/lombok"

echo
echo "Installation complete. Restart Neovim, then run :checkhealth nvim_config."
