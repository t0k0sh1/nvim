local ollama_endpoint = vim.env.MINUET_OLLAMA_ENDPOINT
  or "http://localhost:11434/v1/completions"

require("minuet").setup({
  provider = "openai_fim_compatible",
  n_completions = 1,
  context_window = 512,
  virtualtext = {
    auto_trigger_ft = { "*" },
    auto_trigger_ignore_ft = { "markdown", "text", "env" },
    keymap = {
      accept = "<Tab>",
      accept_line = "<C-j>",
      dismiss = "<C-]>",
    },
  },
  provider_options = {
    openai_fim_compatible = {
      api_key = "TERM",
      name = "Ollama",
      end_point = ollama_endpoint,
      model = "qwen2.5-coder:1.5b",
      optional = {
        max_tokens = 56,
        top_p = 0.9,
      },
    },
  },
})
