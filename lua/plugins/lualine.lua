-- Status line
return {
	-- https://github.com/nvim-lualine/lualine.nvim
	"nvim-lualine/lualine.nvim",
	dependencies = {
		-- https://github.com/nvim-tree/nvim-web-devicons
		"nvim-tree/nvim-web-devicons", -- fancy icons
		-- https://github.com/linrongbin16/lsp-progress.nvim
		"linrongbin16/lsp-progress.nvim", -- LSP loading progress
	},
	config = function()
		require("lualine").setup({
			options = {
				theme = "kanagawa",
				component_separators = { left = "|", right = "|" },
				section_separators = { left = "", right = "" },
			},
			sections = {
				lualine_c = {
					{
						"filename",
						file_status = true,
						newfile_status = false,
						path = 4,
						symbols = {
							modified = "[+]",
							readonly = "[-]",
						},
					},
				},
			},
		})
	end,
}
