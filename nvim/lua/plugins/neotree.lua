return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		require("neo-tree").setup({
      filesystem = {
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = true,
        }
      },
    })
vim.keymap.set("n", "<C-b>", function()
  vim.cmd("Neotree toggle left filesystem reveal")
end, { desc = "Neo-tree toggle (left)" })
    
	end,
}
