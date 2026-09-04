local lombok_bin = vim.fn.resolve(vim.fn.exepath("lombok"))
local lombok_jar = ""

if lombok_bin ~= "" and vim.fn.filereadable(lombok_bin) == 1 then
  local lines = vim.fn.readfile(lombok_bin)
  for _, line in ipairs(lines) do
    -- Extract the path containing lombok.jar from the classpath or line.
    local match = line:match("(%S+lombok%.jar)")
    if match then
      -- When multiple JARs are colon-separated, keep only the lombok.jar entry.
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

-- Prefer repository-level markers so one JDTLS instance covers every module.
local root_dir = vim.fs.root(0, { ".git", "mvnw", "gradlew" })
  or vim.fs.root(0, { "pom.xml", "build.gradle", "build.gradle.kts" })

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
    -- Homebrew jdtls requires JVM options to be passed through --jvm-arg.
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

  require("jdtls").start_or_attach({
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
else
  vim.notify("Could not find project root (pom.xml, build.gradle, etc.)", vim.log.levels.WARN)
end
