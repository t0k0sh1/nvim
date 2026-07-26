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

-- Auto save on insert leave
local autosave_group = vim.api.nvim_create_augroup("AutoSaveGroup", { clear = true })

vim.api.nvim_create_autocmd({ "InsertLeave", "BufLeave" }, {
  group = autosave_group,
  pattern = "*",
  callback = function()
    if vim.bo.modified and vim.bo.buftype == "" then
      if vim.bo.filetype == "go" then
        organize_go_imports(0)
      end

      -- Use the same formatter configuration as regular saves
      require("conform").format({
        bufnr = 0,
        timeout_ms = 1000,
        lsp_format = vim.bo.filetype == "java" and "never" or "fallback",
      })

      -- Save without triggering other autocmds to prevent infinite loops
      vim.cmd("noautocmd silent! write")
    end
  end,
})

-- Spell check configuration for markdown and text files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = { "en_us" } -- Check English typos only, ignoring Japanese text
  end,
})

-- Enable Tree-sitter highlight for Java
vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function(args)
    -- args.buf handles the current buffer, and "java" specifies the parser
    vim.treesitter.start(args.buf, "java")
  end,
})

-- Keymaps after LSP attaches to a buffer
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
  callback = function(ev)
    local opts = { buffer = ev.buf }

    -- Feature 2: Code Jump (Definition & References)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)

    -- Code Actions
    vim.keymap.set({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, {
      buffer = ev.buf,
      desc = "Code Action",
    })

    -- Feature 4: Diagnostic Navigation
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', '<leader>do', vim.diagnostic.open_float)

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
