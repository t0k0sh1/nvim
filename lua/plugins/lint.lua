local lint = require("lint")

lint.linters_by_ft = {
  html = { "htmlhint" },
  markdown = { "markdownlint-cli2" },
}

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
  group = vim.api.nvim_create_augroup("Lint", { clear = true }),
  pattern = { "*.html", "*.md", "*.markdown" },
  callback = function(args)
    lint.try_lint()
  end,
  desc = "Lint HTML and Markdown after opening and saving a file",
})
