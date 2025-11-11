# LazyVim 文件查找功能完整实现指南

## 概述

本文档详细说明了如何在自定义 Neovim 配置中完全复制 LazyVim 的智能文件查找功能。

## 核心组件

### 1. 根目录检测 (`lua/util/root.lua`)

这个模块负责智能检测项目根目录，检测优先级如下：

1. **LSP Workspace Folders** - 从 LSP 服务器获取工作区文件夹
2. **LSP Root Directory** - LSP 服务器的根目录
3. **Pattern Matching** - 向上查找特定文件/目录（如 `.git`, `lua`）
4. **Current Working Directory** - 最后的 fallback

**关键特性**：
- 缓存机制，提高性能
- 支持自定义检测模式
- 自动处理 Windows/Unix 路径差异

**使用示例**：

```lua
local root = require("util.root")

-- 获取当前 buffer 的项目根目录
local project_root = root.get()

-- 获取 git 根目录
local git_root = root.git()

-- 显示根目录检测信息
vim.cmd("LazyRoot")

-- 自定义根目录检测规则
vim.g.root_spec = { "lsp", { ".git", "package.json", "Cargo.toml" }, "cwd" }
```

### 2. 智能 Picker 包装器 (`lua/util/pick.lua`)

这个模块提供了一个 Telescope 包装器，自动处理根目录检测和 cwd 设置。

**核心功能**：

```lua
local pick = require("util.pick")

-- 基本用法：在根目录查找文件
pick.open("find_files", { root = true })

-- 在当前工作目录查找文件
pick.open("find_files", { root = false })

-- 创建可重用的 picker 函数
local find_files_root = pick.wrap("find_files", { root = true })
find_files_root()

-- 智能文件查找（优先使用 git_files，fallback 到 find_files）
pick.smart_files()
```

**API 对比**：

| LazyVim | 自定义实现 | 说明 |
|---------|-----------|------|
| `LazyVim.pick("files")` | `pick.open("find_files", { root = true })` | 在根目录查找文件 |
| `LazyVim.pick("files", { root = false })` | `pick.open("find_files", { root = false })` | 在 cwd 查找文件 |
| `LazyVim.pick.config_files()` | `pick.config_files()` | 查找配置文件 |

### 3. Telescope 配置 (`lua/plugins/telescope.lua`)

更新后的配置使用新的工具函数，提供与 LazyVim 完全一致的行为。

**关键改动**：

1. **快捷键定义**：使用函数而不是命令字符串
```lua
-- 旧方式
{ "<leader><space>", "<cmd>Telescope find_files<cr>", desc = "Find Files" }

-- 新方式（支持智能根目录检测）
{ "<leader><space>", pick.wrap("find_files", { root = true }), desc = "Find Files (Root Dir)" }
```

2. **初始化根目录检测**：
```lua
config = function(_, opts)
  -- 初始化根目录检测系统
  require("util.root").setup()

  require("telescope").setup(opts)
end
```

## 快捷键参考

### 文件查找

| 快捷键 | 功能 | Root | 说明 |
|--------|------|------|------|
| `<leader><space>` | Find Files | Yes | 在项目根目录查找文件 |
| `<leader>ff` | Find Files | Yes | 在项目根目录查找文件 |
| `<leader>fF` | Find Files | No | 在当前工作目录查找文件 |
| `<leader>fg` | Git Files | - | 查找 git 跟踪的文件 |
| `<leader>fG` | Smart Files | Yes | 智能选择 git_files 或 find_files |
| `<leader>fc` | Config Files | - | 在 Neovim 配置目录查找文件 |

### 文本搜索

| 快捷键 | 功能 | Root | 说明 |
|--------|------|------|------|
| `<leader>/` | Live Grep | Yes | 在项目根目录 grep |
| `<leader>sg` | Live Grep | Yes | 在项目根目录 grep |
| `<leader>sG` | Live Grep | No | 在当前工作目录 grep |
| `<leader>sw` | Grep Word | Yes | 在根目录搜索光标下的单词 |
| `<leader>sW` | Grep Word | No | 在 cwd 搜索光标下的单词 |

### 特殊模式映射

在 Telescope 查找界面中：

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `<Alt-i>` | No Ignore | 包含被忽略的文件（如 .gitignore） |
| `<Alt-h>` | Hidden | 包含隐藏文件 |
| `<C-j>/<C-k>` | Move | 上下移动选择 |
| `<C-f>/<C-b>` | Scroll | 预览窗口滚动 |

## 工作原理详解

### Root Detection Flow

```
用户按下 <leader>ff
    ↓
pick.wrap("find_files", { root = true }) 被调用
    ↓
检查 opts.root 是否为 false
    ↓ (root = true)
调用 root.get() 获取项目根目录
    ↓
root.get() 检查缓存
    ↓ (缓存未命中)
root.detect() 按优先级检测：
    1. 检查 LSP workspace folders
    2. 检查 LSP root_dir
    3. 向上查找 .git 或 lua 目录
    4. Fallback 到 cwd
    ↓
返回第一个匹配的根目录
    ↓
缓存结果到 M.cache[buf]
    ↓
设置 opts.cwd = root_path
    ↓
调用 telescope.builtin.find_files(opts)
```

### Cache Management

缓存在以下事件时自动清除：
- `LspAttach` - LSP 客户端附加到 buffer
- `BufWritePost` - 文件保存后
- `DirChanged` - 目录改变
- `BufEnter` - 进入 buffer

这确保根目录检测始终是最新的，同时避免重复计算。

## 自定义配置

### 1. 修改根目录检测规则

```lua
-- 在 init.lua 或任何配置文件中设置
vim.g.root_spec = {
  "lsp",                    -- 先检查 LSP
  { ".git", "package.json", "Cargo.toml" },  -- 然后查找这些文件
  "cwd"                     -- 最后 fallback 到 cwd
}
```

### 2. 忽略特定 LSP 服务器

某些 LSP 服务器可能提供不准确的根目录，可以忽略它们：

```lua
vim.g.root_lsp_ignore = { "copilot", "null-ls" }
```

### 3. 创建自定义 Picker

```lua
-- 创建一个搜索特定目录的 picker
local pick = require("util.pick")

local function search_docs()
  pick.open("find_files", { cwd = "~/Documents" })
end

-- 绑定到快捷键
vim.keymap.set("n", "<leader>fd", search_docs, { desc = "Find in Documents" })
```

### 4. 添加自定义根目录检测器

```lua
local root = require("util.root")

-- 添加自定义检测器：查找 Makefile
root.detectors.makefile = function(buf)
  return root.detectors.pattern(buf, "Makefile")
end

-- 在 spec 中使用
vim.g.root_spec = { "lsp", "makefile", ".git", "cwd" }
```

## 使用示例

### 场景 1：Monorepo 项目

在一个包含多个子项目的 monorepo 中：

```
monorepo/
├── .git/
├── frontend/
│   ├── package.json
│   └── src/
└── backend/
    ├── Cargo.toml
    └── src/
```

当你在 `frontend/src/main.ts` 中：
- `<leader>ff` 会在 `frontend/` 目录查找（LSP root）
- 如果没有 LSP，会在 `monorepo/` 查找（.git）
- `<leader>fF` 总是在当前目录查找

### 场景 2：配置文件查找

```lua
-- 快速跳转到特定配置文件
vim.keymap.set("n", "<leader>fp", function()
  require("telescope.builtin").find_files({
    cwd = vim.fn.stdpath("config") .. "/lua/plugins",
    prompt_title = "Find Plugin Config"
  })
end, { desc = "Find Plugin Config" })
```

### 场景 3：多项目工作区

如果你同时处理多个项目：

```lua
-- 显示当前 buffer 的根目录信息
vim.keymap.set("n", "<leader>fr", function()
  local root = require("util.root")
  root.info()
end, { desc = "Show Root Info" })
```

## 迁移指南

### 从原始配置迁移

如果你当前使用硬编码的 cwd：

```lua
-- 旧方式
{ "<leader>ff", function()
  require("telescope.builtin").find_files({ cwd = vim.fn.getcwd() })
end }

-- 新方式（自动根目录检测）
{ "<leader>ff", pick.wrap("find_files", { root = true }) }
```

### 从 LazyVim 迁移

如果你从 LazyVim 迁移到自定义配置：

| LazyVim | 自定义实现 |
|---------|-----------|
| `LazyVim.pick("files")` | `pick.open("find_files")` 或 `pick.wrap("find_files")` |
| `LazyVim.root()` | `root.get()` |
| `LazyVim.root.info()` | `root.info()` |
| `vim.g.root_spec` | 完全相同，无需改动 |

## 故障排除

### 问题：找不到正确的根目录

**解决方案**：

1. 检查当前检测到的根目录：
```vim
:LazyRoot
```

2. 查看所有可能的根目录：
```lua
local root = require("util.root")
local roots = root.detect({ all = true })
vim.print(roots)
```

3. 调整根目录检测规则：
```lua
-- 添加更多模式
vim.g.root_spec = { "lsp", { ".git", "package.json", "pyproject.toml" }, "cwd" }
```

### 问题：LSP 根目录不正确

**解决方案**：

忽略该 LSP 服务器：
```lua
vim.g.root_lsp_ignore = { "服务器名称" }
```

或修改 spec 不使用 LSP：
```lua
vim.g.root_spec = { { ".git", "package.json" }, "cwd" }
```

### 问题：性能问题

**解决方案**：

缓存系统应该已经处理了性能问题。如果仍有问题：

1. 检查是否有大量的文件：
```lua
-- 增加 ignore 模式
pickers = {
  find_files = {
    find_command = { "rg", "--files", "--color", "never", "-g", "!node_modules", "-g", "!.git" }
  }
}
```

2. 减少检测频率（不推荐）：
```lua
-- 只在 LspAttach 和 DirChanged 时清除缓存
vim.api.nvim_create_autocmd({ "LspAttach", "DirChanged" }, {
  group = vim.api.nvim_create_augroup("util_root_cache", { clear = true }),
  callback = function(event)
    require("util.root").cache[event.buf] = nil
  end,
})
```

## 高级技巧

### 1. 根目录指示器

在状态栏显示当前根目录：

```lua
-- 在 lualine 配置中
{
  function()
    local root = require("util.root")
    return vim.fn.fnamemodify(root.get(), ":~")
  end,
  icon = "󱉭",
  color = { fg = "#8aadf4" }
}
```

### 2. 项目切换器

结合 telescope 创建项目切换器：

```lua
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values

local function project_picker()
  -- 你的项目列表
  local projects = {
    "~/dev/project1",
    "~/dev/project2",
    "~/dev/project3",
  }

  pickers.new({}, {
    prompt_title = "Projects",
    finder = finders.new_table({
      results = projects,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        vim.cmd("cd " .. selection[1])
        -- 清除缓存以重新检测根目录
        require("util.root").cache = {}
      end)
      return true
    end,
  }):find()
end

vim.keymap.set("n", "<leader>fp", project_picker, { desc = "Switch Project" })
```

### 3. 智能 Git 查找

自动在 git 仓库使用 git_files，否则使用 find_files：

```lua
local pick = require("util.pick")

-- 这个功能已经内置在 pick.smart_files 中
vim.keymap.set("n", "<leader>fG", pick.smart_files, { desc = "Smart Files" })
```

## 参考资料

- LazyVim pick.lua: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/util/pick.lua
- LazyVim root.lua: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/util/root.lua
- Telescope.nvim 文档: https://github.com/nvim-telescope/telescope.nvim

## 总结

通过 `util.root` 和 `util.pick` 两个模块，我们完全复制了 LazyVim 的智能文件查找功能：

1. **自动根目录检测** - 基于 LSP、文件模式或 cwd
2. **缓存机制** - 提高性能，避免重复检测
3. **灵活配置** - 支持自定义检测规则和忽略列表
4. **一致的 API** - 与 LazyVim 相同的使用体验

使用这套系统，你可以在任何项目中快速、准确地查找文件，无论项目结构如何复杂。
