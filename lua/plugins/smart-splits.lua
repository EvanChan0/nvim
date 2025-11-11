-- Smart, seamless, directional navigation and resizing of Neovim + tmux splits
return {
	"mrjones2014/smart-splits.nvim",
	lazy = false, -- 不要lazy load，确保tmux集成正常工作
	opts = {
		-- 忽略的文件类型（不会resize的窗口）
		ignored_filetypes = {
			"nofile",
			"quickfix",
			"qf",
			"prompt",
		},
		ignored_buftypes = { "nofile" },
		-- 默认调整大小的步长
		default_amount = 3,
		-- 在边缘窗口的行为
		at_edge = "wrap", -- 或 'stop'
		-- 移动光标时保持相对位置
		move_cursor_same_row = false,
		-- 光标跟随聚焦窗口
		cursor_follows_swapped_bufs = false,
		-- resize模式设置
		resize_mode = {
			-- 退出resize模式的按键
			quit_key = "<ESC>",
			-- resize模式是否静默
			silent = false,
			-- resize模式的钩子
			hooks = {
				on_enter = nil,
				on_leave = nil,
			},
		},
		-- 忽略的事件
		ignored_events = {
			"BufEnter",
			"WinEnter",
		},
		-- multiplexer集成（tmux）
		multiplexer_integration = "tmux",
		-- 禁用multiplexer导航的文件类型
		disable_multiplexer_nav_when_zoomed = true,
	},
	config = function(_, opts)
		require("smart-splits").setup(opts)

		-- Keymaps
		local map = vim.keymap.set

		-- 移动焦点（Neovim + tmux无缝切换）
		map("n", "<C-h>", require("smart-splits").move_cursor_left, { desc = "Move to left split" })
		map("n", "<C-j>", require("smart-splits").move_cursor_down, { desc = "Move to below split" })
		map("n", "<C-k>", require("smart-splits").move_cursor_up, { desc = "Move to above split" })
		map("n", "<C-l>", require("smart-splits").move_cursor_right, { desc = "Move to right split" })
		map("n", "<C-\\>", require("smart-splits").move_cursor_previous, { desc = "Move to previous split" })

		-- 调整窗口大小（智能resize）
		map("n", "<M-h>", require("smart-splits").resize_left, { desc = "Resize split left" })
		map("n", "<M-j>", require("smart-splits").resize_down, { desc = "Resize split down" })
		map("n", "<M-k>", require("smart-splits").resize_up, { desc = "Resize split up" })
		map("n", "<M-l>", require("smart-splits").resize_right, { desc = "Resize split right" })

		-- 交换窗口位置
		map("n", "<leader>wh", require("smart-splits").swap_buf_left, { desc = "Swap buffer left" })
		map("n", "<leader>wj", require("smart-splits").swap_buf_down, { desc = "Swap buffer down" })
		map("n", "<leader>wk", require("smart-splits").swap_buf_up, { desc = "Swap buffer up" })
		map("n", "<leader>wl", require("smart-splits").swap_buf_right, { desc = "Swap buffer right" })
	end,
}
