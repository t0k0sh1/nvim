#!/usr/bin/env bash

set -euo pipefail

if [[ "$(uname -s)" != "Linux" ]] || ! command -v apt-get >/dev/null 2>&1; then
  echo "This script supports Ubuntu and other apt-based Linux distributions only." >&2
  exit 1
fi

case "$(uname -m)" in
  x86_64)
    nvim_arch="x86_64"
    luals_arch="x64"
    marksman_arch="x64"
    go_arch="amd64"
    rust_target="x86_64-unknown-linux-gnu"
    ;;
  aarch64 | arm64)
    nvim_arch="arm64"
    luals_arch="arm64"
    marksman_arch="arm64"
    go_arch="arm64"
    rust_target="aarch64-unknown-linux-gnu"
    ;;
  *)
    echo "Unsupported architecture: $(uname -m)" >&2
    exit 1
    ;;
esac

sudo apt-get update
sudo apt-get install --yes \
  build-essential \
  ca-certificates \
  clang \
  clang-format \
  clangd \
  cmake \
  curl \
  default-jdk \
  fd-find \
  git \
  jq \
  lua-busted \
  lua5.4 \
  liblua5.4-dev \
  luarocks \
  llvm \
  ninja-build \
  python3 \
  python3-venv \
  ripgrep \
  shellcheck \
  shfmt \
  tar \
  unzip

# LuaCov is not packaged by every supported Ubuntu release.
luarocks --lua-version 5.4 install --local luacov

local_bin="${HOME}/.local/bin"
local_opt="${HOME}/.local/opt"
mkdir -p "$local_bin" "$local_opt"
ln -sfn "$(command -v fdfind)" "${local_bin}/fd"

temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

github_asset_url() {
  local repository="$1"
  local pattern="$2"
  curl --fail --location --retry 3 --silent --show-error \
    "https://api.github.com/repos/${repository}/releases/latest" \
    | jq --exit-status --raw-output --arg pattern "$pattern" \
      'first(.assets[] | select(.name | test($pattern)) | .browser_download_url)'
}

# Neovim's Ubuntu package is too old for vim.pack on some supported releases.
nvim_archive="${temp_dir}/nvim.tar.gz"
curl --fail --location --silent --show-error \
  "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${nvim_arch}.tar.gz" \
  --output "$nvim_archive"
rm -rf "${local_opt}/neovim"
mkdir -p "${local_opt}/neovim"
tar -xzf "$nvim_archive" --strip-components=1 -C "${local_opt}/neovim"
ln -sfn "${local_opt}/neovim/bin/nvim" "${local_bin}/nvim"

# Install a current Go toolchain independently of the Ubuntu release cadence.
go_version="$(curl --fail --location --silent --show-error 'https://go.dev/VERSION?m=text' | head -n 1)"
go_archive="${temp_dir}/go.tar.gz"
curl --fail --location --silent --show-error \
  "https://go.dev/dl/${go_version}.linux-${go_arch}.tar.gz" \
  --output "$go_archive"
rm -rf "${local_opt}/go"
mkdir -p "${local_opt}/go"
tar -xzf "$go_archive" --strip-components=1 -C "${local_opt}/go"
export PATH="${local_opt}/go/bin:${local_bin}:${PATH}"
GOBIN="$local_bin" go install golang.org/x/tools/gopls@latest
GOBIN="$local_bin" go install github.com/docker/docker-language-server/cmd/docker-language-server@latest

# Rust tools, formatters, and coverage runners.
if ! command -v rustup >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 --fail --silent --show-error https://sh.rustup.rs \
    | sh -s -- -y --profile default
fi
export PATH="${HOME}/.cargo/bin:${PATH}"
rustup component add rust-analyzer rustfmt
cargo install --locked cargo-llvm-cov stylua
nextest_url="$(github_asset_url nextest-rs/nextest "cargo-nextest-[0-9.]+-${rust_target}\\.tar\\.gz$")"
nextest_archive="${temp_dir}/cargo-nextest.tar.gz"
curl --fail --location --silent --show-error "$nextest_url" --output "$nextest_archive"
tar -xzf "$nextest_archive" -C "$local_bin"

# uv provides isolated installs for Python editor tooling.
if ! command -v uv >/dev/null 2>&1; then
  curl --fail --location --silent --show-error https://astral.sh/uv/install.sh | sh
fi
export PATH="${HOME}/.local/bin:${PATH}"
uv tool install --upgrade pyrefly
uv tool install --upgrade ruff
uv tool install --upgrade neovim-remote

# Use NodeSource so JavaScript language servers do not depend on Ubuntu's Node version.
curl --fail --location --silent --show-error https://deb.nodesource.com/setup_22.x \
  --output "${temp_dir}/nodesource.sh"
sudo -E bash "${temp_dir}/nodesource.sh"
sudo apt-get install --yes nodejs
npm config set prefix "${HOME}/.local"
npm install --global \
  @biomejs/biome \
  bash-language-server \
  eslint \
  htmlhint \
  markdownlint-cli2 \
  oxlint \
  prettier \
  @fsouza/prettierd \
  tombi \
  tree-sitter-cli \
  typescript \
  typescript-language-server \
  vscode-langservers-extracted \
  yaml-language-server

# Bun is needed only for projects that select Bun as their runtime.
if ! command -v bun >/dev/null 2>&1; then
  curl --fail --location --silent --show-error https://bun.sh/install | bash
fi

# Lua Language Server release archive.
luals_url="$(github_asset_url LuaLS/lua-language-server "linux-${luals_arch}\\.tar\\.gz$")"
luals_archive="${temp_dir}/lua-language-server.tar.gz"
curl --fail --location --silent --show-error "$luals_url" --output "$luals_archive"
rm -rf "${local_opt}/lua-language-server"
mkdir -p "${local_opt}/lua-language-server"
tar -xzf "$luals_archive" -C "${local_opt}/lua-language-server"
ln -sfn "${local_opt}/lua-language-server/bin/lua-language-server" "${local_bin}/lua-language-server"

# Marksman ships as a single release binary.
marksman_url="$(github_asset_url artempyanykh/marksman "marksman-linux-${marksman_arch}$")"
curl --fail --location --silent --show-error "$marksman_url" --output "${local_bin}/marksman"
chmod +x "${local_bin}/marksman"

# Eclipse JDT.LS includes its launcher script in the release archive.
jdtls_archive="${temp_dir}/jdtls.tar.gz"
curl --fail --location --silent --show-error \
  https://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz \
  --output "$jdtls_archive"
rm -rf "${local_opt}/jdtls"
mkdir -p "${local_opt}/jdtls"
tar -xzf "$jdtls_archive" -C "${local_opt}/jdtls"
ln -sfn "${local_opt}/jdtls/bin/jdtls" "${local_bin}/jdtls"

# Java formatter and Lombok are distributed as executable jars.
google_java_format_url="$(github_asset_url google/google-java-format 'google-java-format-[0-9.]+-all-deps\.jar$')"
java_tools="${HOME}/.local/share/java-tools"
lombok_dir="${HOME}/.local/share/lombok"
mkdir -p "$java_tools" "$lombok_dir"
curl --fail --location --silent --show-error "$google_java_format_url" \
  --output "${java_tools}/google-java-format.jar"
curl --fail --location --silent --show-error https://projectlombok.org/downloads/lombok.jar \
  --output "${lombok_dir}/lombok.jar"
printf '#!/usr/bin/env bash\nexec java -jar "%s" "$@"\n' \
  "${java_tools}/google-java-format.jar" > "${local_bin}/google-java-format"
printf '#!/usr/bin/env bash\n# %s\nexec java -jar "%s" "$@"\n' \
  "${lombok_dir}/lombok.jar" "${lombok_dir}/lombok.jar" > "${local_bin}/lombok"
chmod +x "${local_bin}/google-java-format" "${local_bin}/lombok"

echo
echo "Installation complete. Add ${local_bin} to your shell PATH, restart Neovim,"
echo "then run :checkhealth nvim_config."
