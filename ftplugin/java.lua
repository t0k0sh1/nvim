local lombok_bin = vim.fn.resolve(vim.fn.exepath("lombok"))
local lombok_jar = ""

if lombok_bin ~= "" and vim.fn.filereadable(lombok_bin) == 1 then
  local lines = vim.fn.readfile(lombok_bin)
  for _, line in ipairs(lines) do
    -- クラスパス (-cp) や行内から lombok.jar を含むパスを抽出
    local match = line:match("(%S+lombok%.jar)")
    if match then
      -- コロン区切り (:) で複数のJARが結合されている場合、lombok.jar の要素のみを取り出す
      for path in string.gmatch(match, "[^:]+") do
        if path:match("lombok%.jar$") and vim.fn.filereadable(path) == 1 then
          lombok_jar = path
          break
        end
      end
    end
    if lombok_jar ~= "" then
      break
    end
  end
end

-- プロジェクトルートの検出
local root_dir = vim.fs.root(0, { "pom.xml", "build.gradle", ".git", "mvnw", "gradlew" })

if root_dir then
  root_dir = vim.fs.normalize(root_dir)
  local project_name = vim.fs.basename(root_dir)
  local project_hash = vim.fn.sha256(root_dir):sub(1, 12)
  local workspace_dir = vim.fs.joinpath(
    vim.fn.stdpath("cache"),
    "jdtls-workspace",
    project_name .. "-" .. project_hash
  )

  local cmd = {
    "jdtls",
    "-data", workspace_dir,
  }

  if lombok_jar ~= "" then
    -- Homebrew版jdtlsでは、JVMオプションを --jvm-arg 経由で渡す必要がある
    table.insert(cmd, "--jvm-arg=-javaagent:" .. lombok_jar)
  else
    vim.notify("Lombok Jar path could not be extracted from " .. lombok_bin, vim.log.levels.WARN)
  end

  local capabilities = require("core.lsp").client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  }

  local client_id = vim.lsp.start({
    name = "jdtls",
    cmd = cmd,
    root_dir = root_dir,
    capabilities = capabilities,
    settings = {
      java = {
        signatureHelp = { enabled = true },
        saveActions = {
          organizeImports = true,
        },
        completion = {
          importOrder = {
            "java",
            "javax",
            "org",
            "com",
          },
        },
        sources = {
          organizeImports = {
            starThreshold = 99,
            staticStarThreshold = 99,
          },
        },
      },
    },
  })

  if client_id then
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = vim.api.nvim_get_current_buf(),
      callback = function()
        vim.lsp.buf.code_action({
          apply = true,
          context = {
            only = { "source.organizeImports" },
            diagnostics = {},
          },
        })
      end,
    })
  end
else
  vim.notify("Could not find project root (pom.xml, build.gradle, etc.)", vim.log.levels.WARN)
end
