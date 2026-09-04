local function organize_go_imports(bufnr)
  local clients = vim.lsp.get_clients({
    bufnr = bufnr,
    name = "gopls",
    method = "textDocument/codeAction",
  })

  for _, client in ipairs(clients) do
    local params = {
      textDocument = vim.lsp.util.make_text_document_params(bufnr),
      range = {
        start = { line = 0, character = 0 },
        ["end"] = { line = vim.api.nvim_buf_line_count(bufnr), character = 0 },
      },
      context = {
        diagnostics = {},
        only = { "source.organizeImports" },
      },
    }
    local response = client:request_sync("textDocument/codeAction", params, 1000, bufnr)

    for _, action in ipairs((response and response.result) or {}) do
      if action.edit then
        vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
      end
      if action.command then
        local command = type(action.command) == "table" and action.command or {
          command = action.command,
          arguments = action.arguments,
        }
        client:request_sync("workspace/executeCommand", command, 1000, bufnr)
      end
    end

    break
  end
end

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("GoOrganizeImports", { clear = true }),
  pattern = "*.go",
  callback = function(args)
    organize_go_imports(args.buf)
  end,
})

-- Auto save after leaving Insert mode or immediately when leaving a buffer
local autosave_group = vim.api.nvim_create_augroup("AutoSaveGroup", { clear = true })
local autosave_generation = {}

local function save_buffer(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr)
    or not vim.bo[bufnr].modified
    or vim.bo[bufnr].buftype ~= ""
    or vim.api.nvim_buf_get_name(bufnr) == ""
  then
    return
  end

  local ok, error_message = pcall(vim.api.nvim_buf_call, bufnr, function()
    vim.cmd("update")
  end)
  if not ok then
    vim.notify("Auto-save failed: " .. tostring(error_message), vim.log.levels.ERROR)
  end
end

local function cancel_pending_save(bufnr)
  autosave_generation[bufnr] = (autosave_generation[bufnr] or 0) + 1
end

vim.api.nvim_create_autocmd("InsertLeave", {
  group = autosave_group,
  pattern = "*",
  callback = function(args)
    cancel_pending_save(args.buf)
    local generation = autosave_generation[args.buf]

    vim.defer_fn(function()
      if autosave_generation[args.buf] ~= generation then
        return
      end
      save_buffer(args.buf)
    end, 500)
  end,
})

vim.api.nvim_create_autocmd("InsertEnter", {
  group = autosave_group,
  pattern = "*",
  callback = function(args)
    cancel_pending_save(args.buf)
  end,
})

vim.api.nvim_create_autocmd("BufLeave", {
  group = autosave_group,
  pattern = "*",
  callback = function(args)
    vim.cmd("stopinsert")
    cancel_pending_save(args.buf)
    save_buffer(args.buf)
  end,
})

vim.api.nvim_create_autocmd("BufWipeout", {
  group = autosave_group,
  pattern = "*",
  callback = function(args)
    autosave_generation[args.buf] = nil
  end,
})

local indentation = {
  c = { expandtab = true, shiftwidth = 2, tabstop = 2 },
  cpp = { expandtab = true, shiftwidth = 2, tabstop = 2 },
  rust = { expandtab = true, shiftwidth = 4, tabstop = 4 },
  go = { expandtab = false, shiftwidth = 0, tabstop = 8 },
  python = { expandtab = true, shiftwidth = 4, tabstop = 4 },
  javascript = { expandtab = true, shiftwidth = 2, tabstop = 2 },
  javascriptreact = { expandtab = true, shiftwidth = 2, tabstop = 2 },
  typescript = { expandtab = true, shiftwidth = 2, tabstop = 2 },
  typescriptreact = { expandtab = true, shiftwidth = 2, tabstop = 2 },
  html = { expandtab = true, shiftwidth = 2, tabstop = 2 },
  css = { expandtab = true, shiftwidth = 2, tabstop = 2 },
  json = { expandtab = true, shiftwidth = 2, tabstop = 2 },
  jsonc = { expandtab = true, shiftwidth = 2, tabstop = 2 },
  yaml = { expandtab = true, shiftwidth = 2, tabstop = 2 },
  toml = { expandtab = true, shiftwidth = 2, tabstop = 2 },
  lua = { expandtab = true, shiftwidth = 2, tabstop = 2 },
}

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("LanguageIndentation", { clear = true }),
  pattern = vim.tbl_keys(indentation),
  callback = function(args)
    local options = indentation[vim.bo[args.buf].filetype]
    for name, value in pairs(options) do
      vim.bo[args.buf][name] = value
    end
  end,
})

-- Keymaps after LSP attaches to a buffer
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))

    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end

    if client:supports_method("textDocument/inlayHint") then
      vim.keymap.set("n", "<leader>th", function()
        local filter = { bufnr = ev.buf }
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(filter), filter)
      end, {
        buffer = ev.buf,
        desc = "Toggle Inlay Hints",
      })
    end

    -- LSP navigation and information
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {
      buffer = ev.buf,
      desc = "Rename Symbol",
    })
    vim.keymap.set("n", "<leader>ls", function()
      require("telescope.builtin").lsp_document_symbols()
    end, {
      buffer = ev.buf,
      desc = "Document Symbols",
    })
    vim.keymap.set("n", "<leader>lS", function()
      require("telescope.builtin").lsp_dynamic_workspace_symbols()
    end, {
      buffer = ev.buf,
      desc = "Workspace Symbols",
    })

    -- Code Actions
    vim.keymap.set({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, {
      buffer = ev.buf,
      desc = "Code Action",
    })
    vim.keymap.set("n", "<leader>qf", function()
      vim.lsp.buf.code_action({
        apply = true,
        context = {
          only = { "quickfix" },
          diagnostics = vim.diagnostic.get(ev.buf, {
            lnum = vim.api.nvim_win_get_cursor(0)[1] - 1,
          }),
        },
      })
    end, {
      buffer = ev.buf,
      desc = "Quick Fix",
    })
    vim.keymap.set("n", "<leader>oi", function()
      vim.lsp.buf.code_action({
        apply = true,
        context = {
          only = { "source.organizeImports" },
          diagnostics = {},
        },
      })
    end, {
      buffer = ev.buf,
      desc = "Organize Imports",
    })

    -- Diagnostic Navigation
    vim.keymap.set("n", "[d", function()
      vim.diagnostic.jump({ count = -1, float = true })
    end, opts)
    vim.keymap.set("n", "]d", function()
      vim.diagnostic.jump({ count = 1, float = true })
    end, opts)
    vim.keymap.set("n", "<leader>do", vim.diagnostic.open_float, {
      buffer = ev.buf,
      desc = "Open Diagnostic",
    })
  end,
})

-- Automatically create parent directories if they do not exist when saving a file
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("Mkdir", { clear = true }),
  pattern = "*",
  callback = function(ctx)
    -- Skip special buffers like help or neotree
    if vim.bo[ctx.buf].buftype ~= "" then
      return
    end

    -- Get the parent directory of the current file
    local dir = vim.fn.fnamemodify(ctx.file, ":h")

    -- Create the directory if it does not exist
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end,
})
