local M = {}

local version_cache = {}

local function declares_typescript(root)
  local package_json = vim.fs.joinpath(root, "package.json")
  if vim.fn.filereadable(package_json) ~= 1 then
    return false
  end

  local ok, package = pcall(vim.json.decode, table.concat(vim.fn.readfile(package_json), "\n"))
  if not ok then
    return false
  end
  local dependencies = vim.tbl_extend("force", package.dependencies or {}, package.devDependencies or {})
  return dependencies.typescript ~= nil or dependencies["@typescript/native"] ~= nil
end

local function compiler(root)
  local local_tsc = vim.fs.joinpath(root, "node_modules", ".bin", "tsc")
  if vim.fn.executable(local_tsc) == 1 then
    return local_tsc
  end
  if declares_typescript(root) then
    return nil
  end

  local global_tsc = vim.fn.exepath("tsc")
  return global_tsc ~= "" and global_tsc or nil
end

function M.root_dir(bufnr)
  local lockfiles = { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock" }
  local markers = vim.fn.has("nvim-0.11.3") == 1 and { lockfiles, { ".git" } } or vim.list_extend(lockfiles, { ".git" })
  local project_root = vim.fs.root(bufnr, markers)
  local deno_root = vim.fs.root(bufnr, { "deno.json", "deno.jsonc" })
  local deno_lock_root = vim.fs.root(bufnr, { "deno.lock" })

  if deno_lock_root and (not project_root or #deno_lock_root > #project_root) then
    return nil
  end
  if deno_root and (not project_root or #deno_root >= #project_root) then
    return nil
  end

  return project_root or vim.fn.getcwd()
end

function M.compiler(root)
  return compiler(root)
end

function M.version(root)
  local executable = compiler(root)
  if not executable then
    return nil
  end
  if version_cache[executable] ~= nil then
    return version_cache[executable] or nil
  end

  local result = vim.system({ executable, "--version" }, { text = true }):wait(2000)
  local version = result.code == 0 and (result.stdout or ""):match("(%d+%.%d+%.%d+)") or nil
  version_cache[executable] = version or false
  return version
end

function M.backend(root)
  local version = M.version(root)
  local major = version and tonumber(version:match("^(%d+)")) or nil
  return major and major >= 7 and "native" or "legacy", version
end

function M.root_for(backend)
  return function(bufnr, on_dir)
    local root = M.root_dir(bufnr)
    if root and M.backend(root) == backend then
      on_dir(root)
    end
  end
end

return M
