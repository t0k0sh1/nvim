local greeting = require("greeting")

describe("greeting", function()
  it("greets a named person", function()
    assert.are.equal("Hello, Lua!", greeting.message("Lua"))
  end)

  it("greets without a name", function()
    assert.are.equal("Hello!", greeting.message(""))
  end)
end)
