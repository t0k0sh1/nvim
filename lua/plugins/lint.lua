local lint = require("lint")

local markuplint_config_names = {
  ".markuplintrc",
  ".markuplintrc.json",
  ".markuplintrc.yaml",
  ".markuplintrc.yml",
  ".markuplintrc.js",
  ".markuplintrc.cjs",
  ".markuplintrc.ts",
  "markuplint.config.js",
  "markuplint.config.cjs",
  "markuplint.config.ts",
}

local function has_project_markuplint_config(directory)
  if vim.fs.find(markuplint_config_names, { path = directory, upward = true })[1] then
    return true
  end

  local package_json = vim.fs.find("package.json", { path = directory, upward = true })[1]
  if not package_json then
    return false
  end
  local contents = table.concat(vim.fn.readfile(package_json), "\n")
  local ok, package = pcall(vim.json.decode, contents)
  return ok and package.markuplint ~= nil
end

local base_markuplint = require("lint.linters.markuplint")
lint.linters.markuplint = function()
  local linter = vim.deepcopy(base_markuplint)
  if not has_project_markuplint_config(vim.fn.expand("%:p:h")) then
    vim.list_extend(linter.args, {
      "--config",
      vim.fs.joinpath(vim.fn.stdpath("config"), "config", "markuplint.json"),
    })
  end
  return linter
end

lint.linters_by_ft = {
  html = { "markuplint" },
  javascriptreact = { "markuplint" },
  typescriptreact = { "markuplint" },
  markdown = { "markdownlint-cli2" },
}

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
  group = vim.api.nvim_create_augroup("Lint", { clear = true }),
  pattern = { "*.html", "*.jsx", "*.tsx", "*.md", "*.markdown" },
  callback = function()
    lint.try_lint()
  end,
  desc = "Lint markup and Markdown after opening and saving a file",
})
