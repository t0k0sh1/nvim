local neotest = require("neotest")

neotest.setup({
  adapters = {
    require("neotest-java")({}),
  },
})

return neotest
