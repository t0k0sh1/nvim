local conform = require("conform")

local function measure(timings, name, callback)
  local started = vim.uv.hrtime()
  callback()
  table.insert(timings, {
    name = name,
    duration_ms = (vim.uv.hrtime() - started) / 1e6,
  })
end

local function format_profile(profile)
  local steps = vim.tbl_map(function(step)
    return string.format("%s %.1fms", step.name, step.duration_ms)
  end, profile.steps)
  return string.format("Save %.1fms (%s)", profile.total_ms, table.concat(steps, ", "))
end

local function apply_code_actions(bufnr, client_name, kind)
  local clients = vim.lsp.get_clients({
    bufnr = bufnr,
    name = client_name,
    method = "textDocument/codeAction",
  })

  for _, client in ipairs(clients) do
    local params = vim.lsp.util.make_range_params(nil, client.offset_encoding)
    params.context = {
      diagnostics = {},
      only = { kind },
    }

    local response = client:request_sync("textDocument/codeAction", params, 1000, bufnr)
    for _, action in ipairs((response and response.result) or {}) do
      if action.edit then
        vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
      end
      if action.command then
        local command = type(action.command) == "table" and action.command
          or {
            command = action.command,
            arguments = action.arguments,
          }
        client:request_sync("workspace/executeCommand", command, 1000, bufnr)
      end
    end
  end
end

local function execute_command(bufnr, client_name, command, arguments)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = client_name })) do
    client:request_sync("workspace/executeCommand", {
      command = command,
      arguments = arguments,
    }, 1000, bufnr)
  end
end

local function has_biome_config(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  return vim.fs.find({ "biome.json", "biome.jsonc", ".biome.json", ".biome.jsonc" }, {
    path = vim.fs.dirname(filename),
    upward = true,
  })[1] ~= nil
end

local function organize_imports(bufnr, timings)
  local filetype = vim.bo[bufnr].filetype

  if vim.tbl_contains({ "javascript", "javascriptreact", "typescript", "typescriptreact" }, filetype) then
    if has_biome_config(bufnr) then
      return
    end

    local uri = vim.uri_from_bufnr(bufnr)
    measure(timings, "oxlint", function()
      execute_command(bufnr, "oxlint", "oxc.fixAll", { { uri = uri } })
    end)
    measure(timings, "eslint", function()
      execute_command(bufnr, "eslint", "eslint.applyAllFixes", {
        {
          uri = uri,
          version = vim.lsp.util.buf_versions[bufnr],
        },
      })
    end)
    measure(timings, "ts_ls imports", function()
      apply_code_actions(bufnr, "ts_ls", "source.organizeImports")
    end)
  elseif filetype == "rust" then
    measure(timings, "rust imports", function()
      apply_code_actions(bufnr, "rust_analyzer", "source.organizeImports")
    end)
  end
end

vim.api.nvim_create_user_command("SaveProfile", function()
  local profile = vim.b.save_profile
  if not profile then
    vim.notify("No save profile is available for this buffer", vim.log.levels.INFO)
    return
  end
  vim.notify(format_profile(profile), vim.log.levels.INFO)
end, {
  desc = "Show the most recent save performance profile",
})

local function record_save_profile(bufnr, started, timings)
  local profile = {
    total_ms = (vim.uv.hrtime() - started) / 1e6,
    steps = timings,
  }
  vim.b[bufnr].save_profile = profile

  if profile.total_ms >= 500 then
    vim.notify(format_profile(profile), vim.log.levels.WARN, {
      title = "Slow save",
    })
  end
end

-- Define layout and settings for code formatting
conform.setup({
  formatters_by_ft = {
    c = { "clang_format" },
    cpp = { "clang_format" },
    javascript = { "biome-check", "prettierd", "prettier", stop_after_first = true },
    typescript = { "biome-check", "prettierd", "prettier", stop_after_first = true },
    javascriptreact = { "biome-check", "prettierd", "prettier", stop_after_first = true },
    typescriptreact = { "biome-check", "prettierd", "prettier", stop_after_first = true },
    html = { "biome-check", "prettierd", "prettier", stop_after_first = true },
    css = { "biome-check", "prettierd", "prettier", stop_after_first = true },
    json = { "biome-check", "prettierd", "prettier", stop_after_first = true },
    jsonc = { "biome-check", "prettierd", "prettier", stop_after_first = true },
    yaml = { "prettierd", "prettier", stop_after_first = true },
    toml = { "tombi" },
    bash = { "shfmt" },
    sh = { "shfmt" },
    python = { "ruff_organize_imports", "ruff_format" },
    lua = { "stylua" },
    rust = { "rustfmt" },
    java = { "google-java-format" },
  },
  formatters = {
    ["biome-check"] = {
      condition = function(_, ctx)
        return vim.fs.find({ "biome.json", "biome.jsonc", ".biome.json", ".biome.jsonc" }, {
          path = ctx.dirname,
          upward = true,
        })[1] ~= nil
      end,
    },
  },
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("OrganizeImportsAndFormat", { clear = true }),
  callback = function(args)
    local started = vim.uv.hrtime()
    local timings = {}

    organize_imports(args.buf, timings)
    measure(timings, "format", function()
      conform.format({
        bufnr = args.buf,
        timeout_ms = 1000,
        lsp_format = vim.bo[args.buf].filetype == "java" and "never" or "fallback",
      })
    end)
    record_save_profile(args.buf, started, timings)
  end,
})
