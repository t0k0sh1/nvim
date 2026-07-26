local status, telescope = pcall(require, "telescope")
if not status then return end

telescope.setup({
  defaults = {
    file_ignore_patterns = {
      "^node_modules/",
      "/node_modules/",
      "^pack/",
      "/pack/",
      "^__pycache__/",
      "/__pycache__/",
      "^build/",
      "/build/",
      "^target/",
      "/target/",
      "^bin/",
      "/bin/",
      "^dist/",
      "/dist/",
      "^out/",
      "/out/",
      "^coverage/",
      "/coverage/",
      "^venv/",
      "/venv/",
      "^htmlcov/",
      "/htmlcov/",
      "^CMakeFiles/",
      "/CMakeFiles/",
      "%.class$",
      "%.jar$",
      "%.py[co]$",
      "%.egg%-info/",
      "%.o$",
      "%.a$",
      "%.so$",
      "%.dylib$",
      "gradlew",
      "^gradle/",
      "/gradle/",
    },
  },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
  },
})

telescope.load_extension("fzf")
