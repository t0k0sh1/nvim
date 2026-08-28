local ollama_endpoint = vim.env.MINUET_OLLAMA_ENDPOINT
    or "http://localhost:11434/v1/completions"

require("minuet").setup({
  provider = "openai_fim_compatible",
  n_completions = 1,
  context_window = 8192,
  -- Avoid starting a local LLM inference during short pauses while typing.
  debounce = 1200,
  throttle = 2000,
  virtualtext = {
    auto_trigger_ft = { "*" },
    auto_trigger_ignore_ft = { "markdown", "text", "env" },
    keymap = {
      accept = "<C-l>",
      accept_line = "<C-j>",
      dismiss = "<C-]>",
    },
  },
  provider_options = {
    openai_fim_compatible = {
      api_key = "TERM",
      name = "Ollama",
      end_point = ollama_endpoint,
      model = "qwen2.5-coder:14b",
      optional = {
        max_tokens = 56,
        top_p = 0.9,
      },
    },
  },
})

local virtualtext = require("minuet.virtualtext")

vim.keymap.set("i", "<Tab>", function()
  if virtualtext.action.is_visible() then
    virtualtext.action.accept()
    return
  end

  if vim.snippet.active({ direction = 1 }) then
    vim.snippet.jump(1)
    return
  end

  vim.api.nvim_feedkeys(vim.keycode("<Tab>"), "n", false)
end, {
  silent = true,
  desc = "Accept Minuet suggestion, jump snippet, or insert Tab",
})
