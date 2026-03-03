return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        transparent_background = true,
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  { "projekt0n/github-nvim-theme", lazy = true },
  { "olimorris/onedarkpro.nvim", lazy = true },
  { "notken12/base46-colors", lazy = true },
}

