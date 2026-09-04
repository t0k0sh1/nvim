require("gitsigns").setup({
  current_line_blame = false,
  on_attach = function(bufnr)
    local gitsigns = require("gitsigns")
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, {
        buffer = bufnr,
        desc = desc,
      })
    end

    map("n", "]h", function()
      if vim.wo.diff then
        vim.cmd.normal({ "]c", bang = true })
      else
        gitsigns.nav_hunk("next")
      end
    end, "Next Git Hunk")
    map("n", "[h", function()
      if vim.wo.diff then
        vim.cmd.normal({ "[c", bang = true })
      else
        gitsigns.nav_hunk("prev")
      end
    end, "Previous Git Hunk")
    map("n", "<leader>hp", gitsigns.preview_hunk, "Preview Git Hunk")
    map("n", "<leader>hs", gitsigns.stage_hunk, "Stage Git Hunk")
    map("x", "<leader>hs", function()
      gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, "Stage Git Hunk")
    map("n", "<leader>hu", gitsigns.undo_stage_hunk, "Undo Stage Git Hunk")
    map("n", "<leader>hr", gitsigns.reset_hunk, "Reset Git Hunk")
    map("x", "<leader>hr", function()
      gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, "Reset Git Hunk")
    map("n", "<leader>hb", function()
      gitsigns.blame_line({ full = true })
    end, "Blame Git Line")
  end,
})
