if vim.lsp.config then
  -- Explicitly enable and setup servers installed on your system using Neovim 0.11+ API

  vim.lsp.config("*", {
    capabilities = require("core.lsp").client_capabilities(),
  })

  -- Lua
  vim.lsp.config("lua_ls", {
    settings = {
      Lua = {
        diagnostics = {
          -- Fix: 'undefined global vim'
          globals = { "vim" },
        },
      },
    },
  })

  -- Define configuration for pyrefly
  vim.lsp.config("pyrefly", {
    cmd = { "pyrefly", "lsp" },
    root_markers = {
      "pyrefly.toml",
      "pyproject.toml",
      "setup.py",
      "setup.cfg",
      "requirements.txt",
      ".git",
    },
    -- If you don't need custom options, you can leave settings empty
    settings = {},
  })

  -- JavaScript / TypeScript
  vim.lsp.config("ts_ls", {
    settings = {
      typescript = {
        suggest = {
          -- Enable auto-imports in the completion list
          autoImports = true,
        },
      },
      javascript = {
        suggest = {
          autoImports = true,
        },
      },
    },
  })

  -- HTML / CSS
  vim.lsp.config("html", {})
  vim.lsp.config("cssls", {})

  -- JSON / YAML / TOML
  vim.lsp.config("jsonls", {
    settings = {
      json = {
        schemas = require("schemastore").json.schemas(),
        validate = { enable = true },
      },
    },
  })
  vim.lsp.config("yamlls", {
    settings = {
      yaml = {
        schemaStore = {
          enable = false,
          url = "",
        },
        schemas = require("schemastore").yaml.schemas(),
      },
    },
  })
  vim.lsp.config("tombi", {})

  -- Shell Script
  vim.lsp.config("bashls", {})

  -- Markdown
  vim.lsp.config("marksman", {})

  -- Dockerfile / Docker Compose / Docker Bake
  vim.lsp.config("docker_language_server", {})

  -- Rust
  vim.lsp.config("rust_analyzer", {
    settings = {
      ["rust-analyzer"] = {
        -- Options for code completion and imports
        completion = {
          autoimport = {
            -- Enable auto-import suggestions in completions/actions
            enable = true,
          },
        },
        imports = {
          granularity = {
            -- Keep imports from the same crate in a single use statement
            group = "crate",
            enforce = true,
          },
          -- Separate standard library, external crate, and local imports
          group = {
            enable = true,
          },
        },
        -- Optional: Run `cargo check` on save to get live diagnostics
        checkOnSave = true,
        check = {
          command = "check",
        },
      },
    },
  })

  -- Go
  vim.lsp.config("gopls", {
    settings = {
      gopls = {
        -- Enable auto-import suggestions for unimported packages
        completeUnimported = true,

        -- Optional: Shows parameter names in function signatures (Inlay Hints)
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          functionTypeParameters = true,
        },
      },
    },
  })

  -- C / C++
  vim.lsp.config("clangd", {})

  -- Prefer Biome over ESLint when the project has a Biome configuration.
  vim.lsp.config("biome", {})

  local oxlint_root_dir = vim.lsp.config.oxlint.root_dir
  vim.lsp.config("oxlint", {
    root_dir = function(bufnr, on_dir)
      if vim.fs.root(bufnr, { "biome.json", "biome.jsonc" }) then
        return
      end
      return oxlint_root_dir(bufnr, on_dir)
    end,
  })

  local eslint_root_dir = vim.lsp.config.eslint.root_dir
  vim.lsp.config("eslint", {
    root_dir = function(bufnr, on_dir)
      if vim.fs.root(bufnr, { "biome.json", "biome.jsonc" }) then
        return
      end
      return eslint_root_dir(bufnr, on_dir)
    end,
  })

  -- Ruff provides Python lint diagnostics; Pyrefly remains the type checker.
  vim.lsp.config("ruff", {
    on_attach = function(client)
      client.server_capabilities.hoverProvider = false
    end,
  })

  -- Automatically enable all defined servers
  -- This will start the LSP when you open a matching file
  local servers = {
    "lua_ls",
    "pyrefly",
    "ts_ls",
    "html",
    "cssls",
    "jsonls",
    "yamlls",
    "tombi",
    "bashls",
    "marksman",
    "docker_language_server",
    "rust_analyzer",
    "gopls",
    "clangd",
    "biome",
    "oxlint",
    "eslint",
    "ruff",
  }
  for _, server in ipairs(servers) do
    vim.lsp.enable(server)
  end
else
  vim.notify("vim.lsp.config is not available or nvim-lspconfig failed to load", vim.log.levels.WARN)
end
