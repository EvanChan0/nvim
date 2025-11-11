-- snacks.nvim - Collection of QoL plugins for Neovim (LazyVim style)
-- Using Snacks as the primary picker
return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		-- Core modules (LazyVim defaults)
		bigfile = { enabled = true },
		gitbrowse = { enabled = true },
		lazygit = { enabled = true },
		notifier = { enabled = false },
		quickfile = { enabled = true },
		statuscolumn = { enabled = false }, -- using other plugin
		words = { enabled = true },
		indent = {
			enabled = true,
			scope = { enabled = false }, -- 使用 mini-indentscope 代替
		},
		input = { enabled = true },
		scope = { enabled = false }, -- 使用 mini-indentscope 代替
		scroll = { enabled = false },

		-- Picker configuration (for projects and more)
		picker = {
			enabled = true,
			sources = {
				git_log = {},
				git_log_line = {},
				git_log_file = {},
			},
			-- 使用默认的圆角边框
			layout = {
				preset = "default",
			},
			win = {
				input = {
					keys = {
						["<Esc>"] = { "close", mode = { "n", "i" } },
					},
				},
			},
		},

		-- Projects configuration (LazyVim style)
		picker_projects = {
			dev = { "~/dev", "~/Documents", "~/Desktop", "~/.config" },
			patterns = { ".git" },
			max_depth = 3,
		},
	},
	keys = function()
		local pick = require("util.pick")

		return {
			-- Quick access
			{
				"<leader>,",
				function()
					Snacks.picker.buffers()
				end,
				desc = "Switch Buffer",
			},
			{ "<leader>/", pick.wrap("grep", { root = true }), desc = "Grep (Root Dir)" },
			{
				"<leader>:",
				function()
					Snacks.picker.command_history()
				end,
				desc = "Command History",
			},
			{ "<leader><space>", pick.wrap("files", { root = true }), desc = "Find Files (Root Dir)" },

			-- Find (f prefix)
			{
				"<leader>fb",
				function()
					Snacks.picker.buffers()
				end,
				desc = "Buffers",
			},
			{
				"<leader>fB",
				function()
					Snacks.picker.buffers({ hidden = true, nofile = true })
				end,
				desc = "Buffers (all)",
			},
			{ "<leader>fc", pick.config_files(), desc = "Find Config File" },
			{ "<leader>ff", pick.wrap("files", { root = true }), desc = "Find Files (Root Dir)" },
			{ "<leader>fF", pick.wrap("files", { root = false }), desc = "Find Files (cwd)" },
			{
				"<leader>fg",
				function()
					Snacks.picker.git_files()
				end,
				desc = "Find Files (git-files)",
			},
			{ "<leader>fG", pick.smart_files, desc = "Find Files (smart git/files)" },
			{ "<leader>fr", pick.wrap("recent", { root = true }), desc = "Recent" },
			{
				"<leader>fR",
				function()
					Snacks.picker.recent({ filter = { cwd = true } })
				end,
				desc = "Recent (cwd)",
			},

			-- Projects
			{
				"<leader>fp",
				function()
					Snacks.picker.projects()
				end,
				desc = "Projects",
			},

			-- Git
			{
				"<leader>gg",
				function()
					Snacks.lazygit({ cwd = vim.fn.getcwd() })
				end,
				desc = "Lazygit",
			},
			{
				"<leader>gb",
				function()
					Snacks.picker.git_log_line()
				end,
				desc = "Git Blame Line",
			},
			{
				"<leader>gf",
				function()
					Snacks.picker.git_log_file()
				end,
				desc = "Git File History",
			},
			{
				"<leader>gc",
				function()
					Snacks.picker.git_log()
				end,
				desc = "Git Commits",
			},
			{
				"<leader>gd",
				function()
					Snacks.picker.git_diff()
				end,
				desc = "Git Diff (hunks)",
			},
			{
				"<leader>gD",
				function()
					Snacks.picker.git_diff({ base = "origin", group = true })
				end,
				desc = "Git Diff (origin)",
			},
			{
				"<leader>gs",
				function()
					Snacks.picker.git_status()
				end,
				desc = "Git Status",
			},
			{
				"<leader>gS",
				function()
					Snacks.picker.git_stash()
				end,
				desc = "Git Stash",
			},

			-- Git Browse: Open/Copy GitHub URLs
			{
				"<leader>gB",
				function()
					Snacks.gitbrowse()
				end,
				desc = "Git Browse (open)",
				mode = { "n", "x" },
			},
			{
				"<leader>gY",
				function()
					Snacks.gitbrowse({
						open = function(url)
							vim.fn.setreg("+", url)
						end,
						notify = false,
					})
				end,
				desc = "Git Browse (copy URL)",
				mode = { "n", "x" },
			},

			-- Search (s prefix)
			{
				'<leader>s"',
				function()
					Snacks.picker.registers()
				end,
				desc = "Registers",
			},
			{
				"<leader>sa",
				function()
					Snacks.picker.autocmds()
				end,
				desc = "Auto Commands",
			},
			{
				"<leader>sb",
				function()
					Snacks.picker.lines()
				end,
				desc = "Buffer Lines",
			},
			{
				"<leader>sB",
				function()
					Snacks.picker.grep_buffers()
				end,
				desc = "Grep Open Buffers",
			},
			{
				"<leader>sc",
				function()
					Snacks.picker.command_history()
				end,
				desc = "Command History",
			},
			{
				"<leader>sC",
				function()
					Snacks.picker.commands()
				end,
				desc = "Commands",
			},
			{
				"<leader>sd",
				function()
					Snacks.picker.diagnostics()
				end,
				desc = "Document Diagnostics",
			},
			{
				"<leader>sD",
				function()
					Snacks.picker.diagnostics_buffer()
				end,
				desc = "Buffer Diagnostics",
			},
			{ "<leader>sg", pick.wrap("grep", { root = true }), desc = "Grep (Root Dir)" },
			{ "<leader>sG", pick.wrap("grep", { root = false }), desc = "Grep (cwd)" },
			{
				"<leader>sh",
				function()
					Snacks.picker.help()
				end,
				desc = "Help Pages",
			},
			{
				"<leader>sH",
				function()
					Snacks.picker.highlights()
				end,
				desc = "Search Highlight Groups",
			},
			{
				"<leader>si",
				function()
					Snacks.picker.icons()
				end,
				desc = "Icons",
			},
			{
				"<leader>sj",
				function()
					Snacks.picker.jumps()
				end,
				desc = "Jumplist",
			},
			{
				"<leader>sk",
				function()
					Snacks.picker.keymaps()
				end,
				desc = "Key Maps",
			},
			{
				"<leader>sl",
				function()
					Snacks.picker.loclist()
				end,
				desc = "Location List",
			},
			{
				"<leader>sM",
				function()
					Snacks.picker.man()
				end,
				desc = "Man Pages",
			},
			{
				"<leader>sm",
				function()
					Snacks.picker.marks()
				end,
				desc = "Jump to Mark",
			},
			{
				"<leader>so",
				function()
					Snacks.picker.vim_options()
				end,
				desc = "Options",
			},
			{
				"<leader>sp",
				function()
					Snacks.picker.lazy()
				end,
				desc = "Search for Plugin Spec",
			},
			{
				"<leader>sq",
				function()
					Snacks.picker.qflist()
				end,
				desc = "Quickfix List",
			},
			{
				"<leader>sR",
				function()
					Snacks.picker.resume()
				end,
				desc = "Resume",
			},
			{
				"<leader>su",
				function()
					Snacks.picker.undo()
				end,
				desc = "Undotree",
			},
			{ "<leader>sw", pick.wrap("grep_word", { root = true }), desc = "Word (Root Dir)" },
			{ "<leader>sW", pick.wrap("grep_word", { root = false }), desc = "Word (cwd)" },
			{
				"<leader>sw",
				pick.wrap("grep_word", { root = true }),
				mode = "x",
				desc = "Selection (Root Dir)",
			},
			{
				"<leader>sW",
				pick.wrap("grep_word", { root = false }),
				mode = "x",
				desc = "Selection (cwd)",
			},
			{
				"<leader>ss",
				function()
					Snacks.picker.lsp_symbols()
				end,
				desc = "Goto Symbol",
			},
			{
				"<leader>sS",
				function()
					Snacks.picker.lsp_workspace_symbols()
				end,
				desc = "Goto Symbol (Workspace)",
			},

			-- UI
			{
				"<leader>uC",
				function()
					Snacks.picker.colorschemes()
				end,
				desc = "Colorscheme with Preview",
			},

			-- Notification History
			{
				"<leader>n",
				function()
					Snacks.notifier.show_history()
				end,
				desc = "Notification History",
			},
			{
				"<leader>un",
				function()
					Snacks.notifier.hide()
				end,
				desc = "Dismiss All Notifications",
			},
		}
	end,
	config = function(_, opts)
		-- Setup root detection first
		require("util.root").setup()

		-- Setup snacks
		require("snacks").setup(opts)
	end,
}
