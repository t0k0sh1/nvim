return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-neotest/nvim-nio",
        "nvim-neotest/neotest-python",
    },
    config = function()
        require("neotest").setup({
            adapters = {
                require("neotest-python")({
                    dap = { justMyCode = false },
                    args = { "--maxfail=1", "--disable-warnings" },
                    runner = "pytest",
                    python = function()
                        if vim.fn.filereadable("./pyproject.toml") == 1 then
                            return vim.fn.system("poetry env info -p"):gsub("\n", "") .. "/bin/python"
                        elseif vim.fn.filereadable(".venv/bin/python") == 1 then
                            return vim.fn.expand(".venv/bin/python")
                        elseif vim.fn.filereadable("venv/bin/python") == 1 then
                            return vim.fn.expand("venv/bin/python")
                        else
                            -- Fallback to the default debugpy installation
                            return vim.fn.expand("~/.local/share/nvim/mason/packages/debugpy/venv/bin/python")
                        end
                    end,
                }),
            }
        })
    end,
}