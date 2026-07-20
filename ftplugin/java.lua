-- Command to start the Java language server
local cmd = { "jdtls" }

-- Detect the root directory of the Java project
-- It looks for build files like pom.xml, build.gradle, or a .git folder
local root_dir = vim.fs.root(0, { "pom.xml", "build.gradle", ".git", "mvnw", "gradlew" })

-- If a root directory is found, start and attach the LSP client
if root_dir then
  vim.lsp.start({
    name = "jdtls",
    cmd = cmd,
    root_dir = root_dir,
    -- You can add extra settings or keymaps here
  })
else
  vim.notify("Could not find project root (pom.xml, build.gradle, etc.)", vim.log.levels.WARN)
end
