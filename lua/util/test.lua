-- Test script for root detection and picker utilities
-- Run with: :luafile ~/.config/nvim/lua/util/test.lua

local M = {}

-- ANSI color codes
local colors = {
	reset = "\27[0m",
	red = "\27[31m",
	green = "\27[32m",
	yellow = "\27[33m",
	blue = "\27[34m",
	cyan = "\27[36m",
}

local function print_header(text)
	print(string.format("\n%s=== %s ===%s", colors.cyan, text, colors.reset))
end

local function print_success(text)
	print(string.format("%s✓ %s%s", colors.green, text, colors.reset))
end

local function print_error(text)
	print(string.format("%s✗ %s%s", colors.red, text, colors.reset))
end

local function print_info(text)
	print(string.format("%s  %s%s", colors.blue, text, colors.reset))
end

local function print_warning(text)
	print(string.format("%s⚠ %s%s", colors.yellow, text, colors.reset))
end

-- Test root detection
function M.test_root_detection()
	print_header("Testing Root Detection")

	local ok, root = pcall(require, "util.root")
	if not ok then
		print_error("Failed to load util.root: " .. root)
		return false
	end

	print_success("Loaded util.root module")

	-- Test get()
	local root_dir = root.get()
	if root_dir then
		print_success("root.get() returned: " .. root_dir)
	else
		print_error("root.get() returned nil")
		return false
	end

	-- Test git()
	local git_root = root.git()
	if git_root then
		print_success("root.git() returned: " .. git_root)
	else
		print_warning("root.git() returned nil (may not be in a git repo)")
	end

	-- Test detect()
	local roots = root.detect({ all = true })
	print_info(string.format("Found %d root candidates:", #roots))
	for i, r in ipairs(roots) do
		local spec_str = type(r.spec) == "table" and table.concat(r.spec, ", ") or tostring(r.spec)
		for _, path in ipairs(r.paths) do
			print_info(string.format("  [%d] %s (%s)", i, path, spec_str))
		end
	end

	-- Test cache
	local buf = vim.api.nvim_get_current_buf()
	local cached = root.cache[buf]
	if cached then
		print_success("Cache working: " .. cached)
	else
		print_warning("No cache entry (will be created on first call)")
	end

	return true
end

-- Test picker
function M.test_picker()
	print_header("Testing Picker")

	local ok, pick = pcall(require, "util.pick")
	if not ok then
		print_error("Failed to load util.pick: " .. pick)
		return false
	end

	print_success("Loaded util.pick module")

	-- Test wrap()
	local wrapped = pick.wrap("find_files", { root = true })
	if type(wrapped) == "function" then
		print_success("pick.wrap() returned a function")
	else
		print_error("pick.wrap() did not return a function")
		return false
	end

	-- Test helper functions exist
	local functions = {
		"open",
		"wrap",
		"smart_files",
		"config_files",
		"files_root",
		"files_cwd",
		"grep_root",
		"grep_cwd",
	}

	for _, func in ipairs(functions) do
		if type(pick[func]) == "function" then
			print_success(string.format("pick.%s() exists", func))
		else
			print_error(string.format("pick.%s() does not exist", func))
			return false
		end
	end

	return true
end

-- Test telescope integration
function M.test_telescope()
	print_header("Testing Telescope Integration")

	local ok, telescope = pcall(require, "telescope")
	if not ok then
		print_error("Failed to load telescope: " .. telescope)
		return false
	end

	print_success("Loaded telescope module")

	-- Check if builtin exists
	ok, _ = pcall(require, "telescope.builtin")
	if ok then
		print_success("telescope.builtin loaded")
	else
		print_error("telescope.builtin failed to load")
		return false
	end

	return true
end

-- Test configuration
function M.test_config()
	print_header("Testing Configuration")

	-- Check root_spec
	local root_spec = vim.g.root_spec
	if root_spec then
		print_success("Custom root_spec found:")
		print_info("  " .. vim.inspect(root_spec))
	else
		print_info("Using default root_spec: { 'lsp', { '.git', 'lua' }, 'cwd' }")
	end

	-- Check root_lsp_ignore
	local root_lsp_ignore = vim.g.root_lsp_ignore
	if root_lsp_ignore then
		print_success("LSP ignore list found:")
		print_info("  " .. vim.inspect(root_lsp_ignore))
	else
		print_info("No LSP servers ignored")
	end

	-- Check for LazyRoot command
	local commands = vim.api.nvim_get_commands({})
	if commands.LazyRoot then
		print_success(":LazyRoot command registered")
	else
		print_warning(":LazyRoot command not found (run require('util.root').setup())")
	end

	return true
end

-- Test LSP integration
function M.test_lsp()
	print_header("Testing LSP Integration")

	local buf = vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_clients({ bufnr = buf })

	if #clients == 0 then
		print_warning("No LSP clients attached to current buffer")
		return true
	end

	print_success(string.format("Found %d LSP client(s):", #clients))

	for _, client in ipairs(clients) do
		print_info(string.format("  - %s", client.name))
		if client.root_dir then
			print_info(string.format("    Root: %s", client.root_dir))
		end
		if client.config.workspace_folders then
			print_info(string.format("    Workspace folders: %d", #client.config.workspace_folders))
		end
	end

	return true
end

-- Test keymaps
function M.test_keymaps()
	print_header("Testing Keymaps")

	local keymaps = {
		{ mode = "n", lhs = "<leader><space>", desc = "Find Files (Root)" },
		{ mode = "n", lhs = "<leader>ff", desc = "Find Files (Root)" },
		{ mode = "n", lhs = "<leader>fF", desc = "Find Files (cwd)" },
		{ mode = "n", lhs = "<leader>/", desc = "Grep (Root)" },
	}

	for _, km in ipairs(keymaps) do
		local maps = vim.api.nvim_get_keymap(km.mode)
		local found = false
		for _, map in ipairs(maps) do
			if map.lhs == km.lhs then
				found = true
				print_success(string.format("%s %s mapped", km.mode, km.lhs))
				break
			end
		end
		if not found then
			print_warning(string.format("%s %s not mapped", km.mode, km.lhs))
		end
	end

	return true
end

-- Run all tests
function M.run_all()
	print_header("Running All Tests")
	print("")

	local results = {
		{ name = "Root Detection", func = M.test_root_detection },
		{ name = "Picker", func = M.test_picker },
		{ name = "Telescope", func = M.test_telescope },
		{ name = "Configuration", func = M.test_config },
		{ name = "LSP Integration", func = M.test_lsp },
		{ name = "Keymaps", func = M.test_keymaps },
	}

	local passed = 0
	local failed = 0

	for _, test in ipairs(results) do
		local ok, result = pcall(test.func)
		if ok and result ~= false then
			passed = passed + 1
		else
			failed = failed + 1
			if not ok then
				print_error("Test crashed: " .. result)
			end
		end
	end

	print_header("Test Summary")
	print(string.format("%s%d tests passed%s", colors.green, passed, colors.reset))
	if failed > 0 then
		print(string.format("%s%d tests failed%s", colors.red, failed, colors.reset))
	end

	return failed == 0
end

-- Auto-run on load
M.run_all()

return M
