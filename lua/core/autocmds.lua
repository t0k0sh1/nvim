-- Auto save on insert leave
local autosave_group = vim.api.nvim_create_augroup("AutoSaveGroup", { clear = true })

vim.api.nvim_create_autocmd({ "InsertLeave", "BufLeave" }, {
  group = autosave_group,
  pattern = "*",
  callback = function()
    if vim.bo.modified and vim.bo.buftype == "" then
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

    -- Feature 3: Rename (Refactoring)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

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
