-- Load core configuration
require("core.options")
require("core.keymaps")

-- Set up Lazy plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Set up plugins
require("lazy").setup({
	spec = {
		{ import = "plugins" },
	},
	defaults = {
		lazy = false,
		version = false,
	},
	checker = {
		enabled = true,
		notify = false,
	},
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})

-- Set up Neovim server for lazygit integration
-- This allows external tools to open files in the current Neovim instance
local server_pipe = "/tmp/nvim-server.pipe"

-- Check if this instance already has the server running
local servers = vim.fn.serverlist()
local has_server = false

-- serverlist() returns a list (table) of server addresses
if type(servers) == "table" then
	for _, addr in ipairs(servers) do
		if addr == server_pipe then
			has_server = true
			break
		end
	end
end

-- Only start server if not already running in this instance
if not has_server then
	-- Try to start server, but don't fail if address is in use (another nvim instance)
	local ok, _ = pcall(vim.fn.serverstart, server_pipe)
	if not ok then
		-- If failed, likely another instance is using it, which is fine
		-- Or use a unique pipe for this instance
		vim.fn.serverstart()
	end
end
