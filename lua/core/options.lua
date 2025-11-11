-- Display
vim.wo.number = true
vim.o.relativenumber = true
vim.o.numberwidth = 1
vim.o.cursorline = true
vim.o.signcolumn = "yes"
vim.opt.termguicolors = true
vim.g.have_nerd_font = true

-- UI
vim.o.showtabline = 2
vim.o.cmdheight = 1
vim.o.pumheight = 10
vim.o.hlsearch = true
vim.opt.laststatus = 3
vim.opt.background = "dark"

-- Indentation
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.expandtab = true
vim.o.breakindent = true

-- Line wrapping
vim.o.wrap = false
vim.o.linebreak = true

-- Search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Mouse & Clipboard
vim.o.mouse = "a"
vim.o.clipboard = "unnamedplus"

-- Scrolling
vim.o.scrolloff = 4
vim.o.sidescrolloff = 8

-- Window splits
vim.o.splitbelow = true
vim.o.splitright = true

-- Editing behavior
vim.o.whichwrap = "bs<>[]hl"
vim.o.backspace = "indent,eol,start"

-- Timing
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Files
vim.o.swapfile = false
vim.o.backup = false
vim.o.writebackup = false
vim.o.undofile = true
vim.o.fileencoding = "utf-8"
vim.o.autoread = true

-- Auto-reload files on external changes
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
	pattern = "*",
	command = "checktime",
})

-- Completion
vim.o.completeopt = "menuone,noselect"
vim.o.conceallevel = 0

-- Misc
vim.opt.shortmess:append("c")
vim.opt.iskeyword:append("-")
vim.opt.formatoptions:remove({ "c", "r", "o" })
vim.opt.runtimepath:remove("/usr/share/vim/vimfiles")

-- LSP & Treesitter
vim.highlight.priorities.semantic_tokens = 95

-- Diagnostics
vim.diagnostic.config({
	virtual_text = {
		spacing = 4,
		source = "if_many",
		prefix = "●",
	},
	underline = false,
	update_in_insert = true,
	float = {
		source = true,
		border = "rounded",
	},
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "",
			[vim.diagnostic.severity.INFO] = " ",
			[vim.diagnostic.severity.HINT] = "",
		},
	},
})

-- Set diagnostic sign highlight to match background
vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	callback = function()
		-- Get SignColumn background
		local sign_column_bg = vim.fn.synIDattr(vim.fn.hlID("SignColumn"), "bg")

		-- Set diagnostic signs background to match SignColumn
		vim.api.nvim_set_hl(0, "DiagnosticSignError", { fg = "#e06c75", bg = sign_column_bg })
		vim.api.nvim_set_hl(0, "DiagnosticSignWarn", { fg = "#e5c07b", bg = sign_column_bg })
		vim.api.nvim_set_hl(0, "DiagnosticSignInfo", { fg = "#61afef", bg = sign_column_bg })
		vim.api.nvim_set_hl(0, "DiagnosticSignHint", { fg = "#56b6c2", bg = sign_column_bg })
	end,
})

-- Trigger immediately for current colorscheme
vim.schedule(function()
	local sign_column_bg = vim.fn.synIDattr(vim.fn.hlID("SignColumn"), "bg")
	vim.api.nvim_set_hl(0, "DiagnosticSignError", { fg = "#e06c75", bg = sign_column_bg })
	vim.api.nvim_set_hl(0, "DiagnosticSignWarn", { fg = "#e5c07b", bg = sign_column_bg })
	vim.api.nvim_set_hl(0, "DiagnosticSignInfo", { fg = "#61afef", bg = sign_column_bg })
	vim.api.nvim_set_hl(0, "DiagnosticSignHint", { fg = "#56b6c2", bg = sign_column_bg })
end)

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
	pattern = "*",
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Folding (Treesitter)
vim.opt.foldexpr = "nvim_treesitter#foldexper()"
