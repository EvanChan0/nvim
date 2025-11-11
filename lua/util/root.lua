-- Root directory detection utility
-- Based on LazyVim's root.lua implementation

---@class util.root
---@overload fun(): string
local M = setmetatable({}, {
	__call = function(m, ...)
		return m.get(...)
	end,
})

---@class LazyRoot
---@field paths string[]
---@field spec LazyRootSpec

---@alias LazyRootFn fun(buf: number): (string|string[])
---@alias LazyRootSpec string|string[]|LazyRootFn

-- Default root detection spec
-- Priority: LSP -> patterns (.git, lua) -> cwd
---@type LazyRootSpec[]
M.spec = { "lsp", { ".git", "lua" }, "cwd" }

M.detectors = {}

-- Detector: current working directory
function M.detectors.cwd()
	return { vim.uv.cwd() }
end

-- Detector: LSP workspace folders and root_dir
---@param buf number
function M.detectors.lsp(buf)
	local bufpath = M.bufpath(buf)
	if not bufpath then
		return {}
	end

	local roots = {} ---@type string[]
	local clients = vim.lsp.get_clients({ bufnr = buf })

	-- Filter out ignored LSP clients
	clients = vim.tbl_filter(function(client)
		return not vim.tbl_contains(vim.g.root_lsp_ignore or {}, client.name)
	end, clients)

	-- Collect workspace folders and root_dir from each client
	for _, client in pairs(clients) do
		local workspace = client.config.workspace_folders
		for _, ws in pairs(workspace or {}) do
			roots[#roots + 1] = vim.uri_to_fname(ws.uri)
		end
		if client.root_dir then
			roots[#roots + 1] = client.root_dir
		end
	end

	-- Filter roots that contain the buffer path
	return vim.tbl_filter(function(path)
		path = M.norm(path)
		return path and bufpath:find(path, 1, true) == 1
	end, roots)
end

-- Detector: pattern matching (search for files/directories)
---@param buf number
---@param patterns string[]|string
function M.detectors.pattern(buf, patterns)
	patterns = type(patterns) == "string" and { patterns } or patterns
	local path = M.bufpath(buf) or vim.uv.cwd()

	-- Search upward for matching patterns
	local pattern = vim.fs.find(function(name)
		for _, p in ipairs(patterns) do
			if name == p then
				return true
			end
			-- Support wildcard patterns like "*.txt"
			if p:sub(1, 1) == "*" and name:find(vim.pesc(p:sub(2)) .. "$") then
				return true
			end
		end
		return false
	end, { path = path, upward = true })[1]

	return pattern and { vim.fs.dirname(pattern) } or {}
end

-- Get buffer path
---@param buf number
function M.bufpath(buf)
	return M.realpath(vim.api.nvim_buf_get_name(assert(buf)))
end

-- Get current working directory
function M.cwd()
	return M.realpath(vim.uv.cwd()) or ""
end

-- Normalize and resolve path
---@param path string
function M.realpath(path)
	if path == "" or path == nil then
		return nil
	end
	-- On non-Windows, resolve symlinks
	path = vim.fn.has("win32") == 0 and vim.uv.fs_realpath(path) or path
	return M.norm(path)
end

-- Normalize path separators
---@param path string
function M.norm(path)
	if path:sub(1, 1) == "~" then
		local home = vim.uv.os_homedir()
		if home:sub(-1) == "\\" or home:sub(-1) == "/" then
			home = home:sub(1, -2)
		end
		path = home .. path:sub(2)
	end
	path = path:gsub("\\", "/"):gsub("/+", "/")
	return path:sub(-1) == "/" and path:sub(1, -2) or path
end

-- Resolve a spec into a detector function
---@param spec LazyRootSpec
---@return LazyRootFn
function M.resolve(spec)
	if M.detectors[spec] then
		return M.detectors[spec]
	elseif type(spec) == "function" then
		return spec
	end
	-- Default to pattern detector
	return function(buf)
		return M.detectors.pattern(buf, spec)
	end
end

-- Detect all roots for the given buffer
---@param opts? { buf?: number, spec?: LazyRootSpec[], all?: boolean }
---@return LazyRoot[]
function M.detect(opts)
	opts = opts or {}
	opts.spec = opts.spec or type(vim.g.root_spec) == "table" and vim.g.root_spec or M.spec
	opts.buf = (opts.buf == nil or opts.buf == 0) and vim.api.nvim_get_current_buf() or opts.buf

	local ret = {} ---@type LazyRoot[]

	-- Iterate through all specs
	for _, spec in ipairs(opts.spec) do
		local paths = M.resolve(spec)(opts.buf)
		paths = paths or {}
		paths = type(paths) == "table" and paths or { paths }

		-- Collect and deduplicate paths
		local roots = {} ---@type string[]
		for _, p in ipairs(paths) do
			local pp = M.realpath(p)
			if pp and not vim.tbl_contains(roots, pp) then
				roots[#roots + 1] = pp
			end
		end

		-- Sort by length (longest first - most specific)
		table.sort(roots, function(a, b)
			return #a > #b
		end)

		if #roots > 0 then
			ret[#ret + 1] = { spec = spec, paths = roots }
			-- If not all=true, stop at first match
			if opts.all == false then
				break
			end
		end
	end

	return ret
end

-- Cache for root directories per buffer
---@type table<number, string>
M.cache = {}

-- Setup autocmds to clear cache
function M.setup()
	vim.api.nvim_create_user_command("LazyRoot", function()
		M.info()
	end, { desc = "Show root directory info for the current buffer" })

	-- Clear cache on certain events
	vim.api.nvim_create_autocmd({ "LspAttach", "BufWritePost", "DirChanged", "BufEnter" }, {
		group = vim.api.nvim_create_augroup("util_root_cache", { clear = true }),
		callback = function(event)
			M.cache[event.buf] = nil
		end,
	})
end

-- Get the root directory for the current buffer
-- Returns the first detected root, or cwd as fallback
---@param opts? { normalize?: boolean, buf?: number }
---@return string
function M.get(opts)
	opts = opts or {}
	local buf = opts.buf or vim.api.nvim_get_current_buf()

	-- Check cache first
	local ret = M.cache[buf]
	if not ret then
		-- Detect roots (only need first one)
		local roots = M.detect({ all = false, buf = buf })
		ret = roots[1] and roots[1].paths[1] or vim.uv.cwd()
		M.cache[buf] = ret
	end

	-- Normalize path separators for Windows
	if opts and opts.normalize then
		return ret
	end
	return vim.fn.has("win32") == 1 and ret:gsub("/", "\\") or ret
end

-- Get git root directory
function M.git()
	local root = M.get()
	local git_root = vim.fs.find(".git", { path = root, upward = true })[1]
	local ret = git_root and vim.fn.fnamemodify(git_root, ":h") or root
	return ret
end

-- Show root info for current buffer
function M.info()
	local spec = type(vim.g.root_spec) == "table" and vim.g.root_spec or M.spec
	local roots = M.detect({ all = true })
	local lines = {} ---@type string[]
	local first = true

	lines[#lines + 1] = "# Root Detection for Current Buffer"
	lines[#lines + 1] = ""

	for _, root in ipairs(roots) do
		for _, path in ipairs(root.paths) do
			lines[#lines + 1] = string.format(
				"  %s %s (%s)",
				first and "[x]" or "[ ]",
				path,
				type(root.spec) == "table" and table.concat(root.spec, ", ") or root.spec
			)
			first = false
		end
	end

	lines[#lines + 1] = ""
	lines[#lines + 1] = "Root spec:"
	lines[#lines + 1] = "```lua"
	lines[#lines + 1] = "vim.g.root_spec = " .. vim.inspect(spec)
	lines[#lines + 1] = "```"

	vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "Root Detection" })
	return roots[1] and roots[1].paths[1] or vim.uv.cwd()
end

return M
