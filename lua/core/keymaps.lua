-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opts = { noremap = true, silent = true }

vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- File operations
vim.keymap.set("n", "<C-s>", "<cmd>w<CR>", opts)
vim.keymap.set("n", "<leader>sn", "<cmd>noautocmd w<CR>", opts)

-- Navigation
vim.keymap.set("n", "<C-d>", "<C-d>zz", opts)
vim.keymap.set("n", "<C-u>", "<C-u>zz", opts)

-- Clear search highlight
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Disable command history window (use <leader>: for command history instead)
vim.keymap.set("n", "q:", "<Nop>", { desc = "Disabled (use <leader>:)" })
vim.keymap.set("n", "q/", "<Nop>", { desc = "Disabled" })
vim.keymap.set("n", "q?", "<Nop>", { desc = "Disabled" })

-- Exit insert mode
vim.keymap.set("i", "jk", "<Esc>")

-- Indentation (keep visual selection)
vim.keymap.set("v", ">", ">gv", { desc = "Indent and reselect" })
vim.keymap.set("v", "<", "<gv", { desc = "Unindent and reselect" })

-- Window navigation (由 smart-splits.nvim 接管)
-- 以下快捷键在 smart-splits.nvim 中配置：
-- <C-h/j/k/l> - 移动焦点（支持 Neovim + tmux）
-- <M-h/j/k/l> - 调整大小（智能 resize）
-- <leader>wh/j/k/l - 交换窗口位置

-- Window movement (使用原生vim命令)
vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window left" })
vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window right" })
vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window down" })
vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window up" })

-- Window splits (LazyVim style)
vim.keymap.set("n", "<leader>-", "<C-w>s", { desc = "Split Window Below" })
vim.keymap.set("n", "<leader>|", "<C-w>v", { desc = "Split Window Right" })

-- Terminal
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Diagnostics
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Quickfix list" })

-- Buffer operations
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
vim.keymap.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to other buffer" })
vim.keymap.set("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to other buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>Bdelete<cr>", { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>bD", "<cmd>bd<cr>", { desc = "Delete buffer and window" })

-- Server info
vim.keymap.set("n", "<leader>si", function()
	local servers = vim.fn.serverlist()
	if #servers == 0 then
		vim.notify("No server running in this instance", vim.log.levels.WARN)
	else
		local msg = "Server addresses:\n" .. table.concat(servers, "\n")
		vim.notify(msg, vim.log.levels.INFO)
	end
end, { desc = "Show server info" })

-- Debug (DAP)
local dap = function(method) return function() require("dap")[method]() end end
local dapui = function(method) return function() require("dapui")[method]() end end

vim.keymap.set("n", "<leader>db", dap("toggle_breakpoint"), { desc = "Toggle breakpoint" })
vim.keymap.set("n", "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, { desc = "Conditional breakpoint" })
vim.keymap.set("n", "<leader>dc", dap("continue"), { desc = "Continue/Start" })
vim.keymap.set("n", "<leader>dC", dap("run_to_cursor"), { desc = "Run to cursor" })
vim.keymap.set("n", "<leader>di", dap("step_into"), { desc = "Step into" })
vim.keymap.set("n", "<leader>do", dap("step_out"), { desc = "Step out" })
vim.keymap.set("n", "<leader>dO", dap("step_over"), { desc = "Step over" })
vim.keymap.set("n", "<leader>dp", dap("pause"), { desc = "Pause" })
vim.keymap.set("n", "<leader>dr", dap("repl.toggle"), { desc = "Toggle REPL" })
vim.keymap.set("n", "<leader>dt", dap("terminate"), { desc = "Terminate" })
vim.keymap.set("n", "<leader>du", function() require("dapui").toggle({}) end, { desc = "Toggle DAP UI" })
vim.keymap.set({ "n", "v" }, "<leader>de", function() require("dapui").eval() end, { desc = "Eval" })
