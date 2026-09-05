local M = {}

function M.message(name)
  if name == "" then
    return "Hello!"
  end

  return "Hello, " .. name .. "!"
end

function M.audience(count)
  if count == 1 then
    return "person"
  end

  return "people"
end

return M
