local M = {}

function M.root(path)
  local stat = vim.uv.fs_stat(path)
  local start = stat and stat.type == "directory" and path or vim.fs.dirname(path)
  return vim.fs.root(start, "package.json")
end

local function has_file(root, names)
  for _, name in ipairs(names) do
    if vim.uv.fs_stat(vim.fs.joinpath(root, name)) then
      return true
    end
  end
  return false
end

function M.detect(path)
  local root = M.root(path)
  if not root then
    return nil
  end

  local package_file = vim.fs.joinpath(root, "package.json")
  local file = io.open(package_file, "r")
  local contents = file and file:read("*a") or ""
  if file then
    file:close()
  end
  local ok, package = pcall(vim.json.decode, contents)
  package = ok and package or {}
  local dependencies = vim.tbl_extend("force", package.dependencies or {}, package.devDependencies or {})
  local test_script = (package.scripts or {}).test or ""

  local vitest_configs = {}
  for _, extension in ipairs({ "js", "mjs", "cjs", "ts", "mts", "cts" }) do
    table.insert(vitest_configs, "vitest.config." .. extension)
  end

  if has_file(root, vitest_configs) or dependencies.vitest or test_script:match("%f[%w]vitest%f[%W]") then
    return "vitest"
  end
  if
    has_file(root, { "bun.lock", "bun.lockb", "bunfig.toml" })
    or (package.packageManager or ""):match("^bun@")
    or test_script:match("%f[%w]bun%s+test%f[%W]")
  then
    return "bun"
  end
end

function M.is_test_file(path, runner)
  return path:match("%.test%.[jt]sx?$") ~= nil and M.detect(path) == runner
end

return M
