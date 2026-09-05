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
      { "markuplint", "HTML and JSX/TSX linting" },
      { "markdownlint-cli2", "Markdown linting" },
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

local function read_file(path)
  local file = io.open(path, "r")
  if not file then
    return ""
  end
  local contents = file:read("*a")
  file:close()
  return contents
end

local function check_node_package(root, package, purpose, install_command)
  local path = vim.fs.joinpath(root, "node_modules", package)
  if vim.fn.isdirectory(path) == 1 then
    vim.health.ok(string.format("%s (%s): %s", package, purpose, path))
  else
    vim.health.warn(string.format("%s is missing (%s); run `%s`", package, purpose, install_command))
  end
end

local function has_any_file(root, names)
  for _, name in ipairs(names) do
    if vim.fn.filereadable(vim.fs.joinpath(root, name)) == 1 then
      return true
    end
  end
  return false
end

local function js_install_command(root, packages)
  if has_any_file(root, { "bun.lock", "bun.lockb" }) then
    return "bun add --dev " .. packages
  elseif vim.fn.filereadable(vim.fs.joinpath(root, "pnpm-lock.yaml")) == 1 then
    return "pnpm add --save-dev " .. packages
  elseif vim.fn.filereadable(vim.fs.joinpath(root, "yarn.lock")) == 1 then
    return "yarn add --dev " .. packages
  end
  return "npm install --save-dev " .. packages
end

local function python_importable(python, module)
  if vim.fn.executable(python) ~= 1 then
    return false
  end
  return vim.system({ python, "-c", "import " .. module }, { text = true }):wait().code == 0
end

local function check_current_project()
  -- :checkhealth runs in its own report buffer. Prefer the source buffer it
  -- replaced, then fall back to the working directory.
  local alternate = vim.fn.bufnr("#")
  local alternate_name = alternate >= 0 and vim.api.nvim_buf_get_name(alternate) or ""
  local start = alternate_name ~= "" and vim.fs.dirname(alternate_name) or vim.uv.cwd()
  local root = vim.fs.root(start, {
    "package.json",
    "pyproject.toml",
    "Cargo.toml",
    "go.mod",
    "build.gradle",
    "build.gradle.kts",
    "CMakeLists.txt",
    ".git",
  }) or start

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
      check_node_package(
        js_root,
        "@vitest/coverage-v8",
        "Vitest V8 coverage",
        js_install_command(js_root, "@vitest/coverage-v8")
      )
    end

    local decoded, package =
      pcall(vim.json.decode, read_file(package_json), { luanil = { object = true, array = true } })
    package = decoded and package or {}
    local dependencies = vim.tbl_extend("force", package.dependencies or {}, package.devDependencies or {})
    local is_typescript = dependencies.typescript ~= nil
      or dependencies["@typescript/native"] ~= nil
      or vim.fn.filereadable(vim.fs.joinpath(js_root, "tsconfig.json")) == 1
    if is_typescript then
      check_node_package(js_root, "typescript", "TypeScript project service", js_install_command(js_root, "typescript"))
      local backend, version = require("core.typescript").backend(js_root)
      if version then
        local description = backend == "native" and "native tsc LSP" or "typescript-language-server"
        vim.health.ok(string.format("TypeScript %s editor backend: %s", version, description))
      else
        vim.health.warn("TypeScript editor backend cannot be selected until project dependencies are installed")
      end
    end

    local biome_config = vim.fs.find({ "biome.json", "biome.jsonc", ".biome.json", ".biome.jsonc" }, {
      path = js_root,
      upward = true,
      stop = vim.fs.dirname(js_root),
    })[1]
    if biome_config then
      check_project_or_global(js_root, "biome", "detected project linter", false)
      check_node_package(
        js_root,
        "@biomejs/biome",
        "project-pinned Biome",
        js_install_command(js_root, "@biomejs/biome")
      )
    else
      check_project_or_global(js_root, "oxlint", "JavaScript lint acceleration", false)
      check_project_or_global(js_root, "eslint", "project-specific JavaScript lint rules", false)
      local has_eslint_config = has_any_file(js_root, {
        "eslint.config.js",
        "eslint.config.mjs",
        "eslint.config.cjs",
        "eslint.config.ts",
        ".eslintrc",
        ".eslintrc.json",
        ".eslintrc.js",
        ".eslintrc.cjs",
      })
      if has_eslint_config or dependencies.eslint then
        check_node_package(js_root, "eslint", "project-specific lint rules", js_install_command(js_root, "eslint"))
        check_node_package(js_root, "oxlint", "ESLint lint acceleration", js_install_command(js_root, "oxlint"))
        if dependencies["@eslint/js"] then
          check_node_package(
            js_root,
            "@eslint/js",
            "ESLint JavaScript rules",
            js_install_command(js_root, "@eslint/js")
          )
        end
        if is_typescript then
          check_node_package(
            js_root,
            "typescript-eslint",
            "TypeScript ESLint rules",
            js_install_command(js_root, "typescript-eslint")
          )
          local backend = require("core.typescript").backend(js_root)
          local typescript_spec = tostring(dependencies.typescript or "")
          if backend == "native" and not typescript_spec:find("@typescript/typescript6", 1, true) then
            vim.health.warn(
              "TypeScript 7 has no programmatic API for typescript-eslint; keep @typescript/typescript6 as the typescript alias"
            )
          end
        end
      else
        vim.health.warn(
          "ESLint is not configured in this project; add an eslint.config file to enable project lint rules"
        )
      end
    end
  end

  local pyproject = vim.fs.find("pyproject.toml", { path = start, upward = true })[1]
  if pyproject then
    check_executable("uv", "detected Python project", false)
    local python_root = vim.fs.dirname(pyproject)
    local pytest = vim.fs.joinpath(python_root, ".venv", "bin", "pytest")
    local python = vim.fs.joinpath(python_root, ".venv", "bin", "python")
    if python_importable(python, "pytest") then
      vim.health.ok("pytest: " .. pytest)
    else
      vim.health.warn("pytest is not installed in the project environment; run `uv add --dev pytest pytest-cov`")
    end
    if python_importable(python, "pytest_cov") then
      vim.health.ok("pytest-cov: available in the project environment")
    else
      vim.health.warn("pytest-cov is not installed in the project environment; run `uv add --dev pytest-cov`")
    end
  end

  local gradlew = vim.fs.find("gradlew", { path = start, upward = true })[1]
  if gradlew then
    if vim.fn.executable(gradlew) == 1 then
      vim.health.ok("Gradle wrapper: " .. gradlew)
    else
      vim.health.error("Gradle wrapper is not executable: " .. gradlew)
    end

    local java_root = vim.fs.dirname(gradlew)
    local build_file = vim.fs.find({ "build.gradle.kts", "build.gradle" }, { path = start, upward = true })[1]
    local build = build_file and read_file(build_file) or ""
    if build:lower():find("junit", 1, true) then
      vim.health.ok("JUnit: configured in " .. build_file)
    else
      vim.health.warn("JUnit is not configured; add a JUnit testImplementation dependency")
    end
    if build:find("jacoco", 1, true) then
      vim.health.ok("JaCoCo: configured in " .. build_file)
    else
      vim.health.warn("JaCoCo is not configured; add the `jacoco` Gradle plugin for coverage")
    end
    if not build_file then
      vim.health.warn("No build.gradle or build.gradle.kts was found under " .. java_root)
    end
  end

  local cmake_file = vim.fs.find("CMakeLists.txt", { path = start, upward = true })[1]
  if cmake_file then
    local cmake = read_file(cmake_file):lower()
    if cmake:find("gtest", 1, true) or cmake:find("googletest", 1, true) then
      vim.health.ok("GoogleTest: configured in " .. cmake_file)
    else
      vim.health.warn("GoogleTest is not configured; add GTest::gtest_main and gtest_discover_tests to CMake")
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
