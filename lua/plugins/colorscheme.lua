-- Theme/Colorscheme - Tokyo Night
return {
	-- https://github.com/folke/tokyonight.nvim
	"folke/tokyonight.nvim",
	lazy = false, -- Load immediately when starting Neovim
	priority = 1000, -- Load the colorscheme before other non-lazy-loaded plugins
	opts = {
		-- Replace this with your scheme-specific settings or remove to use the defaults
		style = "night", -- storm, moon, night, or day
		transparent = true,
		terminal_colors = true,
		styles = {
			comments = { italic = true },
			keywords = { italic = true },
			functions = {},
			variables = {},
			sidebars = "transparent",
			floats = "transparent",
		},
		sidebars = { "qf", "help", "terminal", "packer" },
		day_brightness = 0.3,
		hide_inactive_statusline = false,
		dim_inactive = false,
		lualine_bold = false,
		on_colors = function(colors)
			-- Tokyo Night 的注释色默认是 #565f89 (偏蓝的灰色)
			colors.comment = "#5a5a5a" -- 纯灰色注释，明度接近原版
			-- Tokyo Night 默认 bg_highlight 是 #292e42 (偏蓝的深灰色)
			colors.bg_highlight = "#2a2a2a" -- 光标所在行背景
		end,
		on_highlights = function(highlights, colors)
			-- 非高亮行号颜色调整
			-- Tokyo Night 默认 LineNr 是 #3b4261 (深蓝灰色)
			-- 改成相同明度的纯灰色
			highlights.LineNr = { fg = "#404040" }
			highlights.LineNrAbove = { fg = "#404040" }
			highlights.LineNrBelow = { fg = "#404040" }

			-- Tokyo Night 默认 CursorLineNr 是 #7aa2f7 (亮蓝色)
			highlights.CursorLineNr = { fg = "#9d9d9d", bold = true } -- 高亮行号

			-- 变量颜色调整
			-- Tokyo Night 默认 @variable 是 #c0caf5 (偏蓝的白色)
			-- 改成相同明度的纯灰白色
			highlights["@variable"] = { fg = "#c8c8c8" }
			highlights["@variable.builtin"] = { fg = "#c8c8c8" }
			highlights["@variable.member"] = { fg = "#c8c8c8" }

			-- Visual 模式和搜索高亮颜色调整
			-- Tokyo Night 默认 Visual 是 #33467C (深蓝色背景)
			-- 改成相同明度的纯灰色
			highlights.Visual = { bg = "#3a3a3a" }

			-- Tokyo Night 默认 Search 是 #3d59a1 (蓝色背景)
			-- 改成相同明度的纯灰色
			highlights.Search = { bg = "#4a4a4a", fg = "#ffffff" }
			highlights.IncSearch = { bg = "#5a5a5a", fg = "#ffffff" }

			-- LSP 引用高亮（光标放在变量上时）
			-- Tokyo Night 默认是偏蓝的背景色
			-- 改成相同明度的纯灰色
			highlights.LspReferenceText = { bg = "#3a3a3a" }
			highlights.LspReferenceRead = { bg = "#3a3a3a" }
			highlights.LspReferenceWrite = { bg = "#3a3a3a" }

			-- Git 标记颜色（使用 Tokyo Night 原生色彩）
			-- 绿色 #9ece6a, 黄色 #e0af68, 红色 #f7768e
			highlights.GitSignsAdd = { fg = "#9ece6a", bg = "NONE" }
			highlights.GitSignsChange = { fg = "#e0af68", bg = "NONE" }
			highlights.GitSignsDelete = { fg = "#f7768e", bg = "NONE" }

			highlights.SignColumn = { bg = "NONE" }
			highlights.FoldColumn = { bg = "NONE" }

			-- Which-key transparent background
			highlights.WhichKey = { bg = "NONE" }
			highlights.WhichKeyGroup = { bg = "NONE" }
			highlights.WhichKeyDesc = { bg = "NONE" }
			highlights.WhichKeySeparator = { bg = "NONE" }
			highlights.WhichKeyFloat = { bg = "NONE" }
			highlights.WhichKeyBorder = { bg = "NONE" }
			highlights.WhichKeyNormal = { bg = "NONE" }
			highlights.WhichKeyTitle = { bg = "NONE" }
		end,
	},
	config = function(_, opts)
		require("tokyonight").setup(opts)
		vim.cmd("colorscheme tokyonight")

		-- 强制设置非高亮行号颜色
		vim.api.nvim_set_hl(0, "LineNr", { fg = "#404040", bg = "NONE" })
	end,
}
