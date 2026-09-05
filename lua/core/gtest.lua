local M = {}

local detected = {}

local function normalize(path)
  return vim.fs.normalize(vim.fs.abspath(path))
end

local function project_root(path)
  return vim.fs.root(vim.fs.dirname(path), { "CMakeLists.txt", "CMakePresets.json", ".git" })
end

local function build_directories(root)
  local candidates = {
    vim.fs.joinpath(root, "build", "coverage"),
    vim.fs.joinpath(root, "build"),
    vim.fs.joinpath(root, "cmake-build-debug"),
    vim.fs.joinpath(root, "cmake-build-release"),
  }
  local build_root = vim.fs.joinpath(root, "build")
  local scanner = vim.uv.fs_scandir(build_root)
  while scanner do
    local name, kind = vim.uv.fs_scandir_next(scanner)
    if not name then
      break
    end
    if kind == "directory" then
      table.insert(candidates, vim.fs.joinpath(build_root, name))
    end
  end

  local result = {}
  local seen = {}
  for _, candidate in ipairs(candidates) do
    candidate = normalize(candidate)
    if not seen[candidate] and vim.uv.fs_stat(vim.fs.joinpath(candidate, "CTestTestfile.cmake")) then
      seen[candidate] = true
      table.insert(result, candidate)
    end
  end
  return result
end

local function binaries_from_ctest(output)
  local ok, decoded = pcall(vim.json.decode, output)
  if not ok then
    return {}
  end

  local binaries = {}
  local seen = {}
  for _, test in ipairs(decoded.tests or {}) do
    local binary = test.command and test.command[1]
    if binary and not seen[binary] then
      seen[binary] = true
      table.insert(binaries, normalize(binary))
    end
  end
  return binaries
end

function M.assign(root, binaries)
  root = normalize(root)
  if #binaries ~= 1 then
    return false
  end

  local binary = normalize(binaries[1])
  detected[root] = binary
  return true
end

function M.binary_for_tree(tree)
  local root = normalize(tree:root():data().path)
  local binary = detected[root]
  if not binary then
    for _, directory in ipairs(build_directories(root)) do
      local result = vim.system({ "ctest", "--test-dir", directory, "--show-only=json-v1" }, { text = true }):wait()
      local binaries = result.code == 0 and binaries_from_ctest(result.stdout) or {}
      if #binaries == 1 then
        binary = binaries[1]
        detected[root] = binary
        break
      end
    end
  end
  if not binary then
    return nil
  end
  return binary
end

function M.detect(path)
  if vim.fn.executable("ctest") ~= 1 then
    return
  end

  local root = project_root(path)
  if not root then
    return
  end
  root = normalize(root)
  if detected[root] then
    return
  end

  local directories = build_directories(root)
  local function inspect(index)
    local directory = directories[index]
    if not directory then
      return
    end
    vim.system({ "ctest", "--test-dir", directory, "--show-only=json-v1" }, { text = true }, function(result)
      local binaries = result.code == 0 and binaries_from_ctest(result.stdout) or {}
      if not M.assign(root, binaries) then
        inspect(index + 1)
      end
    end)
  end
  inspect(1)
end

return M
