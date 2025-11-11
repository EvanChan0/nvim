-- Indentation guides (shows all indent lines)
return {
	-- https://github.com/lukas-reineke/indent-blankline.nvim
	"lukas-reineke/indent-blankline.nvim",
	event = "VeryLazy",
	main = "ibl",
	config = function()
		-- 先设置颜色 - 非高亮区域用很暗的灰白色
		vim.api.nvim_set_hl(0, "IblIndent", { fg = "#2a2a2a" })

		require("ibl").setup({
			enabled = true,
			indent = {
				char = "|",
				highlight = { "IblIndent" },
			},
			scope = {
				enabled = false, -- 禁用作用域高亮，这个会导致下划线
			},
		})

		-- 在主题加载后也重新设置颜色
		vim.api.nvim_create_autocmd("ColorScheme", {
			pattern = "*",
			callback = function()
				vim.api.nvim_set_hl(0, "IblIndent", { fg = "#2a2a2a" })
			end,
		})
	end,
}
