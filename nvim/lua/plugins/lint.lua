return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      -- Use pylint for python
      lint.linters_by_ft = {
        python = { "pylint" },
      }

      -- Force pylint to run inside the project venv
      local pylint = lint.linters.pylint
      pylint.cmd = vim.fn.getcwd() .. "/.venv/bin/python"
      pylint.args = {
        "-m",
        "pylint",
        "--from-stdin",
        function()
          return vim.api.nvim_buf_get_name(0)
        end,
      }

      -- Run lint automatically
      local aug = vim.api.nvim_create_augroup("Lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = aug,
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}

