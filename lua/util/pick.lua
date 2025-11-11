-- Picker utility wrapper for Snacks and Telescope
-- Based on LazyVim's pick.lua implementation
-- Supports both Snacks.picker and Telescope

---@class util.pick
---@overload fun(command:string, opts?:util.pick.Opts): fun()
local M = setmetatable({}, {
	__call = function(m, ...)
		return m.wrap(...)
	end,
})

---@class util.pick.Opts: table<string, any>
---@field root? boolean
---@field cwd? string
---@field buf? number
---@field show_untracked? boolean
---@field picker? "snacks"|"telescope"  -- which picker to use

-- Default picker ("snacks" or "telescope")
M.picker = "snacks"

-- Open picker with smart root detection
---@param command string
---@param opts? util.pick.Opts
function M.open(command, opts)
	opts = opts or {}
	local picker = opts.picker or M.picker

	-- Deep copy to avoid modifying original opts
	opts = vim.deepcopy(opts)

	-- Validate cwd option
	if type(opts.cwd) == "boolean" then
		vim.notify("pick: opts.cwd should be a string or nil", vim.log.levels.WARN)
		opts.cwd = nil
	end

	-- Smart root detection: if root is not explicitly false, use root directory
	if not opts.cwd and opts.root ~= false then
		local root = require("util.root")
		opts.cwd = root.get({ buf = opts.buf })
	end

	-- Remove our custom options before passing to picker
	opts.root = nil
	opts.buf = nil
	opts.picker = nil

	if picker == "snacks" then
		M.open_snacks(command, opts)
	else
		M.open_telescope(command, opts)
	end
end

-- Open Snacks picker
---@param command string
---@param opts? table
function M.open_snacks(command, opts)
	opts = opts or {}

	-- Map command aliases to snacks picker sources
	local command_map = {
		files = "files",
		git_files = "git_files",
		grep = "grep",
		live_grep = "grep",
		grep_word = "grep_word",
		grep_string = "grep_word",
		oldfiles = "recent",
		recent = "recent",
		buffers = "buffers",
		colorscheme = "colorschemes",
	}

	local snacks_command = command_map[command] or command

	-- Special handling for files: auto-detect git_files vs files
	if snacks_command == "files" and not opts.cwd then
		if vim.fn.isdirectory(".git") == 1 then
			snacks_command = "git_files"
		end
	end

	-- Call Snacks picker
	if Snacks and Snacks.picker then
		Snacks.picker[snacks_command](opts)
	else
		vim.notify("Snacks picker not available", vim.log.levels.ERROR)
	end
end

-- Open Telescope picker (fallback)
---@param command string
---@param opts? table
function M.open_telescope(command, opts)
	opts = opts or {}

	-- Map command aliases to actual telescope commands
	local command_map = {
		files = "find_files",
		git_files = "git_files",
		grep = "live_grep",
		live_grep = "live_grep",
		grep_word = "grep_string",
		grep_string = "grep_string",
		oldfiles = "oldfiles",
		recent = "oldfiles",
		buffers = "buffers",
		colorscheme = "colorscheme",
	}

	local telescope_command = command_map[command] or command

	-- Special handling for files: auto-detect git_files vs find_files
	if telescope_command == "find_files" and not opts.cwd then
		if vim.fn.isdirectory(".git") == 1 then
			telescope_command = "git_files"
		end
	end

	-- Call Telescope
	local ok, builtin = pcall(require, "telescope.builtin")
	if ok then
		builtin[telescope_command](opts)
	else
		vim.notify("Telescope not available", vim.log.levels.ERROR)
	end
end

-- Create a reusable picker function
---@param command string
---@param opts? util.pick.Opts
---@return function
function M.wrap(command, opts)
	opts = opts or {}
	return function()
		M.open(command, opts)
	end
end

-- Config files picker
function M.config_files()
	return function()
		M.open("files", { cwd = vim.fn.stdpath("config") })
	end
end

-- Smart files: auto-detect git_files vs find_files
M.smart_files = M.wrap("files", { root = true })

return M
