-- C++ Development Enhancements
return {
  -- Clangd extensions for better C++ experience
  {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp", "objc", "objcpp" },
    config = function()
      require("clangd_extensions").setup({
        inlay_hints = {
          inline = false,
          only_current_line = false,
          show_parameter_hints = true,
          parameter_hints_prefix = "<- ",
          other_hints_prefix = "=> ",
        },
        ast = {
          role_icons = {
            type = "",
            declaration = "",
            expression = "",
            statement = "",
            specifier = "",
            ["template argument"] = "",
          },
        },
      })
    end,
  },

  -- CMake integration
  {
    "Civitasv/cmake-tools.nvim",
    ft = { "c", "cpp", "cmake" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("cmake-tools").setup({
        cmake_build_directory = "build",
        cmake_soft_link_compile_commands = true,
      })

      -- CMake keymaps
      vim.keymap.set("n", "<leader>cg", ":CMakeGenerate<CR>", { desc = "CMake Generate" })
      vim.keymap.set("n", "<leader>cb", ":CMakeBuild<CR>", { desc = "CMake Build" })
      vim.keymap.set("n", "<leader>cr", ":CMakeRun<CR>", { desc = "CMake Run" })
      vim.keymap.set("n", "<leader>cd", ":CMakeDebug<CR>", { desc = "CMake Debug" })
      vim.keymap.set("n", "<leader>ct", ":CMakeSelectBuildTarget<CR>", { desc = "Select Build Target" })
    end,
  },

  -- Switch between header and source files
  {
    "rgroli/other.nvim",
    ft = { "c", "cpp" },
    config = function()
      require("other-nvim").setup({
        mappings = {
          {
            pattern = "/(.*)%.cpp$",
            target = "/%1.h",
          },
          {
            pattern = "/(.*)%.c$",
            target = "/%1.h",
          },
          {
            pattern = "/(.*)%.h$",
            target = {
              { target = "/%1.cpp" },
              { target = "/%1.c" },
            },
          },
        },
      })

      vim.keymap.set("n", "<leader>oh", "<cmd>:Other<CR>", { desc = "Switch header/source" })
      vim.keymap.set("n", "<leader>ov", "<cmd>:OtherVSplit<CR>", { desc = "Switch header/source (vsplit)" })
    end,
  },
}
