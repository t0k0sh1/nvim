ARG PYTHON_VERSION=3.13
ARG UV_VERSION=0.11.29

FROM ghcr.io/astral-sh/uv:${UV_VERSION} AS uv
FROM python:${PYTHON_VERSION}-slim-bookworm

ARG NVIM_VERSION=v0.12.4
ARG TARGETARCH

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        build-essential \
        curl \
        git \
        ripgrep \
        sudo \
    && rm -rf /var/lib/apt/lists/*

COPY --from=uv /uv /uvx /usr/local/bin/

RUN case "${TARGETARCH}" in \
      amd64) nvim_arch="x86_64"; nvim_sha256="012bf3fcac5ade43914df3f174668bf64d05e049a4f032a388c027b1ebd78628" ;; \
      arm64) nvim_arch="arm64"; nvim_sha256="ceb7e88c6b681f0515d135dcdfad54f5eb4373b25ce6172197cd9a69c758063f" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac \
    && curl -fsSLo /tmp/nvim.tar.gz \
      "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-${nvim_arch}.tar.gz" \
    && echo "${nvim_sha256}  /tmp/nvim.tar.gz" | sha256sum --check --strict \
    && tar -xzf /tmp/nvim.tar.gz -C /opt \
    && mv "/opt/nvim-linux-${nvim_arch}" /opt/nvim \
    && ln -s /opt/nvim/bin/nvim /usr/local/bin/nvim \
    && rm /tmp/nvim.tar.gz

RUN useradd --create-home --shell /bin/bash vscode \
    && echo "vscode ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/vscode \
    && chmod 0440 /etc/sudoers.d/vscode

ENV UV_PROJECT_ENVIRONMENT=/home/vscode/.venv
ENV PATH="/home/vscode/.venv/bin:${PATH}"

USER vscode
WORKDIR /workspace

CMD ["sleep", "infinity"]
