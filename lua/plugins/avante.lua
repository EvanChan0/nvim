return {
	"yetone/avante.nvim",
	event = "VeryLazy",
	lazy = false,
	version = false, -- use latest commit
	build = "make",
	opts = {
		-- Provider configuration
		provider = "claude",
		auto_suggestions_provider = "claude",
		providers = {
			claude = {
				endpoint = "https://co.yes.vg",
				model = "claude-sonnet-4-5-20250929",
				api_key_name = "AVANTE_ANTHROPIC_API_KEY",
				timeout = 30000,
				extra_request_body = {
					temperature = 0,
					max_tokens = 8192,
				},
			},
		},
		-- Use dressing.nvim for better input UI
		input = {
			provider = "dressing",
			provider_opts = {},
		},
		-- Behavior configuration
		behaviour = {
			auto_suggestions = false, -- 关闭 Avante 自动补全，使用 Copilot
			auto_set_highlight_group = true,
			auto_set_keymaps = true,
			auto_apply_diff_after_generation = false,
			support_paste_from_clipboard = false,
		},
		-- Mappings
		mappings = {
			--- @class AvanteConflictMappings
			diff = {
				ours = "co",
				theirs = "ct",
				all_theirs = "ca",
				both = "cb",
				cursor = "cc",
				next = "]x",
				prev = "[x",
			},
			suggestion = {
				accept = "<M-l>",
				next = "<M-]>",
				prev = "<M-[>",
				dismiss = "<C-]>",
			},
			jump = {
				next = "]]",
				prev = "[[",
			},
			submit = {
				normal = "<CR>",
				insert = "<C-s>",
			},
			sidebar = {
				apply_all = "A",
				apply_cursor = "a",
				switch_windows = "<Tab>",
				reverse_switch_windows = "<S-Tab>",
			},
		},
		-- Hints
		hints = { enabled = true },
		-- Windows configuration
		windows = {
			---@type "right" | "left" | "top" | "bottom"
			position = "right",
			wrap = true,
			width = 30, -- 30% width
			sidebar_header = {
				align = "center",
				rounded = true,
			},
		},
		highlights = {
			---@type AvanteConflictHighlights
			diff = {
				current = "DiffText",
				incoming = "DiffAdd",
			},
		},
		--- @class AvanteConflictUserConfig
		diff = {
			autojump = true,
			---@type string | fun(): any
			list_opener = "copen",
		},
	},
	-- Dependencies
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		{
			"stevearc/dressing.nvim",
			opts = {
				input = {
					enabled = true,
				},
			},
		},
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		--- Optional dependencies
		"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
		"zbirenbaum/copilot.lua", -- for providers='copilot'
		{
			-- support for image pasting
			"HakonHarnes/img-clip.nvim",
			event = "VeryLazy",
			opts = {
				-- recommended settings
				default = {
					embed_image_as_base64 = false,
					prompt_for_file_name = false,
					drag_and_drop = {
						insert_mode = true,
					},
					-- required for Windows users
					use_absolute_path = true,
				},
			},
		},
		{
			-- Make sure to set this up properly if you have lazy=true
			"MeanderingProgrammer/render-markdown.nvim",
			opts = {
				file_types = { "markdown", "Avante" },
			},
			ft = { "markdown", "Avante" },
		},
	},
}
