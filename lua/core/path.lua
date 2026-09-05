local priority_paths = {
  "/opt/homebrew/opt/llvm@22/bin",
  "/usr/local/opt/llvm@22/bin",
  "/opt/homebrew/opt/openjdk@25/bin",
  "/usr/local/opt/openjdk@25/bin",
}

local fallback_paths = {
  vim.fn.expand("~/.local/bin"),
  vim.fn.expand("~/.cargo/bin"),
  vim.fn.expand("~/.bun/bin"),
  vim.fn.expand("~/.luarocks/bin"),
  vim.fn.expand("~/.local/opt/go/bin"),
}

local current = vim.split(vim.env.PATH or "", ":", { plain = true })
local seen = {}
for _, path in ipairs(current) do
  seen[path] = true
end

for index = #priority_paths, 1, -1 do
  local path = priority_paths[index]
  if vim.fn.isdirectory(path) == 1 and not seen[path] then
    table.insert(current, 1, path)
    seen[path] = true
  end
end

for _, path in ipairs(fallback_paths) do
  if vim.fn.isdirectory(path) == 1 and not seen[path] then
    table.insert(current, path)
    seen[path] = true
  end
end

vim.env.PATH = table.concat(current, ":")

for _, java_home in ipairs({
  "/opt/homebrew/opt/openjdk@25/libexec/openjdk.jdk/Contents/Home",
  "/usr/local/opt/openjdk@25/libexec/openjdk.jdk/Contents/Home",
}) do
  if vim.fn.isdirectory(java_home) == 1 then
    vim.env.JAVA_HOME = java_home
    break
  end
end
