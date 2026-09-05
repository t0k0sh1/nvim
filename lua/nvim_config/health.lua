local M = {}

local groups = {
  {
    name = "Core tools",
    tools = {
      { "git", "plugin installation and project operations" },
      { "make", "building telescope-fzf-native" },
      { "fd", "file search" },
      { "rg", "live grep" },
    },
  },
  {
    name = "Language servers",
    tools = {
      { "bash-language-server", "Shell" },
      { "biome", "Biome projects" },
      { "clangd", "C/C++" },
      { "docker-language-server", "Docker" },
      { "gopls", "Go" },
      { "jdtls", "Java" },
      { "lua-language-server", "Lua" },
      { "marksman", "Markdown" },
      { "oxlint", "JavaScript/TypeScript projects without Biome" },
      { "pyrefly", "Python type checking" },
      { "ruff", "Python linting" },
      { "rust-analyzer", "Rust" },
      { "tombi", "TOML" },
      { "typescript-language-server", "JavaScript/TypeScript" },
      { "vscode-css-language-server", "CSS" },
      { "vscode-eslint-language-server", "ESLint projects" },
      { "vscode-html-language-server", "HTML" },
      { "vscode-json-language-server", "JSON" },
      { "yaml-language-server", "YAML" },
    },
  },
  {
    name = "Language runtimes and build tools",
    tools = {
      { "bun", "Bun projects" },
      { "cargo", "Rust toolchain" },
      { "clang++", "C++ compiler" },
      { "cmake", "C++ project configuration" },
      { "go", "Go toolchain" },
      { "java", "Java runtime" },
      { "javac", "Java compiler" },
      { "lombok", "Java Lombok support", true },
      { "lua", "Lua runtime" },
      { "ninja", "C++ builds" },
      { "node", "JavaScript language servers" },
      { "python3", "Python and JDTLS launchers" },
      { "tsc", "TypeScript compiler" },
      { "uv", "Python projects" },
    },
  },
  {
    name = "Formatters and linters",
    tools = {
      { "clang-format", "C/C++ formatting" },
      { "google-java-format", "Java formatting" },
      { "htmlhint", "HTML linting" },
      { "prettier", "web format fallback" },
      { "prettierd", "fast web formatting" },
      { "ruff", "Python formatting and imports" },
      { "rustfmt", "Rust formatting" },
      { "shfmt", "Shell formatting" },
      { "shellcheck", "Shell linting" },
      { "stylua", "Lua formatting" },
      { "tombi", "TOML formatting and linting" },
    },
  },
  {
    name = "Test and coverage tools",
    optional = true,
    tools = {
      { "busted", "Lua tests" },
      { "cargo-llvm-cov", "Rust coverage" },
      { "cargo-nextest", "Rust test runner" },
      { "ctest", "C++ test discovery and execution" },
      { "llvm-cov", "C++ coverage" },
      { "llvm-profdata", "C++ coverage profiles" },
      { "luacov", "Lua coverage" },
      { "tree-sitter", "Tree-sitter parser builds" },
    },
  },
}

local function check_executable(command, purpose, optional)
  local executable = vim.fn.exepath(command)
  if executable ~= "" then
    vim.health.ok(string.format("%s (%s): %s", command, purpose, executable))
  elseif optional then
    vim.health.warn(string.format("%s is not installed (%s)", command, purpose))
  else
    vim.health.error(string.format("%s is not installed (%s)", command, purpose))
  end
end

local function project_executable(root, relative)
  local path = vim.fs.joinpath(root, "node_modules", ".bin", relative)
  return vim.fn.executable(path) == 1 and path or nil
end

local function check_project_or_global(root, command, purpose, optional)
  local executable = project_executable(root, command) or vim.fn.exepath(command)
  if executable ~= "" and executable then
    vim.health.ok(string.format("%s (%s): %s", command, purpose, executable))
  elseif optional then
    vim.health.warn(string.format("%s is not installed (%s)", command, purpose))
  else
    vim.health.error(string.format("%s is not installed (%s)", command, purpose))
  end
end

local function check_current_project()
  local buffer = vim.api.nvim_buf_get_name(0)
  local start = buffer ~= "" and vim.fs.dirname(buffer) or vim.uv.cwd()
  local root = vim.fs.root(start, { ".git", "package.json", "pyproject.toml", "Cargo.toml", "go.mod", "build.gradle" })
    or start

  vim.health.info("Project root: " .. root)

  local package_json = vim.fs.find("package.json", { path = start, upward = true })[1]
  if package_json then
    local js_root = vim.fs.dirname(package_json)
    local runner = require("core.javascript_test_runner").detect(js_root)
    if not runner then
      vim.health.warn("JavaScript test runner is not configured (expected Bun or Vitest)")
    elseif runner == "bun" then
      check_executable("bun", "detected JavaScript test runner", false)
    else
      local vitest = project_executable(js_root, "vitest")
      if vitest then
        vim.health.ok("vitest: " .. vitest)
      else
        vim.health.error("Vitest is configured but node_modules/.bin/vitest is missing; install project dependencies")
      end
    end

    local biome_config = vim.fs.find({ "biome.json", "biome.jsonc", ".biome.json", ".biome.jsonc" }, {
      path = js_root,
      upward = true,
      stop = vim.fs.dirname(js_root),
    })[1]
    if biome_config then
      check_project_or_global(js_root, "biome", "detected project linter", false)
    else
      check_project_or_global(js_root, "oxlint", "JavaScript lint acceleration", false)
      check_project_or_global(js_root, "eslint", "project-specific JavaScript lint rules", false)
    end
  end

  local pyproject = vim.fs.find("pyproject.toml", { path = start, upward = true })[1]
  if pyproject then
    check_executable("uv", "detected Python project", false)
    local python_root = vim.fs.dirname(pyproject)
    local pytest = vim.fs.joinpath(python_root, ".venv", "bin", "pytest")
    if vim.fn.executable(pytest) == 1 then
      vim.health.ok("pytest: " .. pytest)
    else
      vim.health.warn("pytest is not installed in the project environment; run `uv add --dev pytest pytest-cov`")
    end
  end

  local gradlew = vim.fs.find("gradlew", { path = start, upward = true })[1]
  if gradlew then
    if vim.fn.executable(gradlew) == 1 then
      vim.health.ok("Gradle wrapper: " .. gradlew)
    else
      vim.health.error("Gradle wrapper is not executable: " .. gradlew)
    end
  end
end

function M.check()
  vim.health.start("External tooling")
  vim.health.info("PATH used by Neovim: " .. (vim.env.PATH or ""))

  for _, group in ipairs(groups) do
    vim.health.start(group.name)
    for _, tool in ipairs(group.tools) do
      check_executable(tool[1], tool[2], group.optional == true or tool[3] == true)
    end
  end

  vim.health.start("Current project")
  check_current_project()
end

return M
