local lint = require("lint")

lint.linters_by_ft = {
  html = { "htmlhint" },
}

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
  group = vim.api.nvim_create_augroup("Lint", { clear = true }),
  pattern = "*.html",
  callback = function()
    lint.try_lint()
  end,
  desc = "Lint HTML after opening and saving a file",
})
