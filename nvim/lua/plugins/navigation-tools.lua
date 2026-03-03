-- Navigation & Editing Tools
return {
  -- Surround text objects (add/change/delete surroundings)
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup()
      -- Usage examples:
      -- ys{motion}{char} - Add surround (e.g., ysiw" surrounds word with quotes)
      -- ds{char} - Delete surround (e.g., ds" removes quotes)
      -- cs{old}{new} - Change surround (e.g., cs"' changes quotes to single quotes)
    end,
  },

  -- Hop - lightning fast navigation
  {
    "smoka7/hop.nvim",
    event = "VeryLazy",
    config = function()
      require("hop").setup()

      vim.keymap.set("", "s", function()
        require("hop").hint_char1()
      end, { desc = "Hop to character" })

      vim.keymap.set("", "S", function()
        require("hop").hint_char2()
      end, { desc = "Hop to 2 characters" })

      vim.keymap.set("n", "<leader>hw", function()
        require("hop").hint_words()
      end, { desc = "Hop to word" })
    end,
  },

  -- Session management
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    config = function()
      require("persistence").setup()

      vim.keymap.set("n", "<leader>qs", function()
        require("persistence").load()
      end, { desc = "Restore session" })

      vim.keymap.set("n", "<leader>ql", function()
        require("persistence").load({ last = true })
      end, { desc = "Restore last session" })
    end,
  },

  -- Project management
  {
    "ahmedkhalf/project.nvim",
    event = "VeryLazy",
    config = function()
      require("project_nvim").setup({
        detection_methods = { "pattern" },
        patterns = { ".git", "Makefile", "package.json", "CMakeLists.txt" },
      })

      require("telescope").load_extension("projects")
      vim.keymap.set("n", "<leader>fp", ":Telescope projects<CR>", { desc = "Find projects" })
    end,
  },

  -- Better notifications
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function()
      require("notify").setup({
        timeout = 3000,
        max_height = function()
          return math.floor(vim.o.lines * 0.75)
        end,
        max_width = function()
          return math.floor(vim.o.columns * 0.75)
        end,
      })
      vim.notify = require("notify")
    end,
  },
}
