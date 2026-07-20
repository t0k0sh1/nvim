if vim.lsp.config then
  -- Explicitly enable and setup servers installed on your system using Neovim 0.11+ API

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
        -- Optional: Run `cargo check` on save to get live diagnostics
        checkOnSave = {
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

  -- Java
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits", -- Required for auto-imports during completion
    },
  }
  vim.lsp.config("jdtls", {
    -- If 'jdtls' is not in your system $PATH, specify the absolute path here:
    capabilities = capabilities,
    settings = {
      java = {
        signatureHelp = { enabled = true },
        -- Enable clean-ups on save (Optional but highly recommended for imports)
        saveActions = {
          organizeImports = true,
        },
      },
    },
  })

  -- Automatically enable all defined servers
  -- This will start the LSP when you open a matching file
  local servers = { "lua_ls", "pyrefly", "ts_ls", "rust_analyzer", "gopls", "clangd", "jdtls" }
  for _, server in ipairs(servers) do
    vim.lsp.enable(server)
  end
else
  vim.notify("vim.lsp.config is not available or nvim-lspconfig failed to load", vim.log.levels.WARN)
end
