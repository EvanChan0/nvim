-- Active indent guide (highlights current scope with animation)
return {
	-- https://github.com/echasnovski/mini.indentscope
	"echasnovski/mini.indentscope",
	event = "VeryLazy",
	opts = {
		symbol = "|",
		options = { try_as_border = true },
		draw = {
			animation = function()
				return 0
			end,
		},
	},
	init = function()
		-- Set color after colorscheme loads
		vim.api.nvim_create_autocmd("ColorScheme", {
			pattern = "*",
			callback = function()
				-- 设置高亮缩进线颜色为稍亮的灰色
				vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { fg = "#5a5a5a" })
			end,
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = {
				"help",
				"alpha",
				"dashboard",
				"neo-tree",
				"Trouble",
				"trouble",
				"lazy",
				"mason",
				"notify",
				"toggleterm",
				"lazyterm",
			},
			callback = function()
				vim.b.miniindentscope_disable = true
			end,
		})
	end,
}
