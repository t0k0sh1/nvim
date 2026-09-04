local M = {}

local languages = {}

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "Testing pair" })
end

local function normalize(path)
  return vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))
end

local function java_contents(target)
  local package_parts = vim.split(target.relative_dir, "/", { plain = true, trimempty = true })
  local lines = {}

  if #package_parts > 0 then
    table.insert(lines, "package " .. table.concat(package_parts, ".") .. ";")
    table.insert(lines, "")
  end

  local declaration = target.kind == "source" and "public class " or "class "
  table.insert(lines, declaration .. target.class_name .. " {")
  table.insert(lines, "}")
  return lines
end

local function java_resolve(path)
  local source_marker = "/src/main/java/"
  local test_marker = "/src/test/java/"
  local marker, replacement, kind

  if path:find(source_marker, 1, true) then
    marker = source_marker
    replacement = test_marker
    kind = "test"
  elseif path:find(test_marker, 1, true) then
    marker = test_marker
    replacement = source_marker
    kind = "source"
  else
    return nil, "Java file is not under src/main/java or src/test/java"
  end

  local before, relative = path:match("^(.-)" .. vim.pesc(marker) .. "(.+)$")
  local relative_dir = vim.fs.dirname(relative)
  if relative_dir == "." then
    relative_dir = ""
  end

  local filename = vim.fs.basename(relative)
  local class_name = filename:match("^(.+)%.java$")
  if not class_name then
    return nil, "Current file is not a Java source file"
  end

  if kind == "test" then
    class_name = class_name .. "Test"
  else
    class_name = class_name:match("^(.+)Test$")
    if not class_name then
      return nil, "Test class name must end with Test"
    end
  end

  local target_relative = relative_dir == "" and (class_name .. ".java")
    or (relative_dir .. "/" .. class_name .. ".java")

  return {
    path = before .. replacement .. target_relative,
    kind = kind,
    class_name = class_name,
    relative_dir = relative_dir,
  }
end

local function python_root(path)
  return vim.fs.root(vim.fs.dirname(path), {
    "pyproject.toml",
    "uv.lock",
    "setup.py",
    "setup.cfg",
    ".git",
  })
end

local function python_resolve(path)
  if not path:match("%.py$") then
    return nil, "Current file is not a Python source file"
  end

  local root = python_root(path)
  if not root then
    return nil, "Could not find the Python project root"
  end

  root = normalize(root)
  local relative = path:sub(#root + 2)
  local test_relative = relative:match("^tests/(.+)$")

  if test_relative then
    local directory = vim.fs.dirname(test_relative)
    local filename = vim.fs.basename(test_relative)
    local source_name = filename:match("^test_(.+%.py)$")
    if not source_name then
      local source_stem = filename:match("^(.+)_test%.py$")
      source_name = source_stem and (source_stem .. ".py") or nil
    end
    if not source_name then
      return nil, "Python test filename must start with test_ or end with _test.py"
    end

    local source_relative = directory == "." and source_name or vim.fs.joinpath(directory, source_name)
    local candidates = {
      vim.fs.joinpath(root, "src", source_relative),
      vim.fs.joinpath(root, source_relative),
    }

    for _, candidate in ipairs(candidates) do
      if vim.fn.filereadable(candidate) == 1 then
        return { path = candidate, kind = "source" }
      end
    end

    local source_root = vim.fn.isdirectory(vim.fs.joinpath(root, "src")) == 1 and vim.fs.joinpath(root, "src") or root
    return {
      path = vim.fs.joinpath(source_root, source_relative),
      kind = "source",
    }
  end

  local source_relative = relative:match("^src/(.+)$") or relative
  local directory = vim.fs.dirname(source_relative)
  local filename = vim.fs.basename(source_relative)
  local test_name = "test_" .. filename
  local target_relative = directory == "." and test_name or vim.fs.joinpath(directory, test_name)

  return {
    path = vim.fs.joinpath(root, "tests", target_relative),
    kind = "test",
  }
end

function M.register(filetype, definition)
  vim.validate({
    filetype = { filetype, "string" },
    definition = { definition, "table" },
    resolve = { definition.resolve, "function" },
    contents = { definition.contents, "function", true },
  })
  languages[filetype] = definition
end

function M.ignore(filetype)
  vim.validate({ filetype = { filetype, "string" } })
  languages[filetype] = { ignored = true }
end

function M.switch()
  local definition = languages[vim.bo.filetype]
  if not definition then
    notify("No testing-pair rule for filetype: " .. vim.bo.filetype, vim.log.levels.WARN)
    return
  end
  if definition.ignored then
    return
  end

  local current = vim.api.nvim_buf_get_name(0)
  if current == "" then
    notify("The current buffer has no file", vim.log.levels.WARN)
    return
  end

  local target, err = definition.resolve(normalize(current))
  if not target then
    notify(err, vim.log.levels.WARN)
    return
  end

  if vim.fn.filereadable(target.path) == 0 then
    vim.fn.mkdir(vim.fs.dirname(target.path), "p")
    local contents = definition.contents and definition.contents(target) or {}
    local ok, result = pcall(vim.fn.writefile, contents, target.path)
    if not ok or result ~= 0 then
      notify("Could not create pair: " .. tostring(result), vim.log.levels.ERROR)
      return
    end
    notify("Created " .. vim.fn.fnamemodify(target.path, ":~:."))
  end

  vim.cmd.edit(vim.fn.fnameescape(target.path))
end

M.register("java", {
  resolve = java_resolve,
  contents = java_contents,
})

M.register("python", {
  resolve = python_resolve,
})

M.ignore("rust")

return M
