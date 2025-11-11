# LazyVim Pick - 快速参考卡片

## 核心 API

### Root Detection

```lua
local root = require("util.root")

-- 获取项目根目录
local project_root = root.get()
local project_root = root.get({ buf = bufnr })

-- 获取 git 根目录
local git_root = root.git()

-- 显示根目录信息（:LazyRoot）
root.info()

-- 自定义检测规则
vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }

-- 忽略 LSP 服务器
vim.g.root_lsp_ignore = { "copilot" }
```

### Picker

```lua
local pick = require("util.pick")

-- 基本用法
pick.open("find_files", { root = true })   -- 在根目录
pick.open("find_files", { root = false })  -- 在 cwd
pick.open("find_files", { cwd = "/path" }) -- 指定目录

-- 创建可重用函数
local find_root = pick.wrap("find_files", { root = true })
find_root()

-- 便捷方法
pick.config_files()   -- 配置文件
pick.smart_files()    -- 智能 git/files
pick.files_root()     -- 根目录文件
pick.files_cwd()      -- cwd 文件
pick.grep_root()      -- 根目录 grep
pick.grep_cwd()       -- cwd grep
```

## 快捷键速查表

### 文件操作

| Key | Action | Root | Desc |
|-----|--------|------|------|
| `SPC SPC` | find_files | ✓ | Find Files (Root) |
| `SPC f f` | find_files | ✓ | Find Files (Root) |
| `SPC f F` | find_files | ✗ | Find Files (cwd) |
| `SPC f g` | git_files | - | Git Files |
| `SPC f G` | smart_files | ✓ | Smart Git/Files |
| `SPC f c` | config | - | Config Files |

### 文本搜索

| Key | Action | Root | Desc |
|-----|--------|------|------|
| `SPC /` | live_grep | ✓ | Grep (Root) |
| `SPC s g` | live_grep | ✓ | Grep (Root) |
| `SPC s G` | live_grep | ✗ | Grep (cwd) |
| `SPC s w` | grep_string | ✓ | Word (Root) |
| `SPC s W` | grep_string | ✗ | Word (cwd) |

### Telescope 内置映射

| Key | Action | Desc |
|-----|--------|------|
| `Alt-i` | no_ignore | Show ignored files |
| `Alt-h` | hidden | Show hidden files |
| `C-j/k` | move | Move selection |
| `C-f/b` | scroll | Scroll preview |

## Root Detection 优先级

```
1. LSP Workspace Folders
   ↓
2. LSP Root Directory
   ↓
3. Pattern Match (.git, lua, etc.)
   ↓
4. Current Working Directory
```

## 常见用例

### 1. 查找配置文件

```lua
-- 方法 1：使用内置函数
vim.keymap.set("n", "<leader>fc", pick.config_files())

-- 方法 2：手动指定路径
vim.keymap.set("n", "<leader>fp", function()
  pick.open("find_files", { cwd = vim.fn.stdpath("config") .. "/lua/plugins" })
end)
```

### 2. 自定义项目查找

```lua
vim.keymap.set("n", "<leader>fP", function()
  pick.open("find_files", { cwd = "~/projects" })
end, { desc = "Find in Projects" })
```

### 3. 智能根目录切换

```lua
-- 切换到 git 根目录
vim.keymap.set("n", "<leader>cd", function()
  local root = require("util.root")
  vim.cmd("cd " .. root.git())
end, { desc = "CD to Git Root" })

-- 切换到项目根目录
vim.keymap.set("n", "<leader>cD", function()
  local root = require("util.root")
  vim.cmd("cd " .. root.get())
end, { desc = "CD to Project Root" })
```

## 故障排除速查

### 问题：根目录不对

```vim
:LazyRoot  " 查看检测信息
```

```lua
-- 调整检测规则
vim.g.root_spec = { "lsp", { ".git", "package.json" }, "cwd" }
```

### 问题：LSP 根目录错误

```lua
-- 忽略特定 LSP
vim.g.root_lsp_ignore = { "null-ls", "copilot" }
```

### 问题：缓存过期

```lua
-- 手动清除缓存
require("util.root").cache = {}
```

## 对比表格

### LazyVim vs 自定义实现

| LazyVim | Custom | Notes |
|---------|--------|-------|
| `LazyVim.pick("files")` | `pick.open("find_files")` | 默认 root=true |
| `LazyVim.root()` | `root.get()` | 获取根目录 |
| `LazyVim.root.info()` | `root.info()` | 显示信息 |
| `LazyVim.pick.config_files()` | `pick.config_files()` | 配置文件 |

## 文件结构

```
~/.config/nvim/
├── lua/
│   ├── util/
│   │   ├── root.lua      # 根目录检测
│   │   └── pick.lua      # Picker 包装器
│   └── plugins/
│       └── telescope.lua # Telescope 配置
└── docs/
    ├── lazyvim-pick-implementation.md  # 完整文档
    └── pick-quick-reference.md         # 本文件
```

## 最小配置示例

```lua
-- 在 lua/plugins/telescope.lua
return {
  {
    "nvim-telescope/telescope.nvim",
    keys = function()
      local pick = require("util.pick")
      return {
        { "<leader><space>", pick.wrap("find_files", { root = true }) },
        { "<leader>ff", pick.wrap("find_files", { root = true }) },
        { "<leader>fF", pick.wrap("find_files", { root = false }) },
        { "<leader>/", pick.wrap("live_grep", { root = true }) },
      }
    end,
    config = function(_, opts)
      require("util.root").setup()  -- 初始化根目录检测
      require("telescope").setup(opts)
    end,
  }
}
```

## 性能优化

### 缓存系统

- 每个 buffer 的根目录会被缓存
- 自动清除时机：
  - `LspAttach` - LSP 附加
  - `BufWritePost` - 文件保存
  - `DirChanged` - 目录改变
  - `BufEnter` - 进入 buffer

### Find Command 优化

优先级：`rg` > `fd` > `fdfind` > `find` > `where`

```lua
-- 在 telescope opts 中配置
pickers = {
  find_files = {
    find_command = { "rg", "--files", "--color", "never", "-g", "!.git" }
  }
}
```

## 扩展阅读

- 完整文档：`docs/lazyvim-pick-implementation.md`
- LazyVim 源码：https://github.com/LazyVim/LazyVim
- Telescope 文档：`:help telescope`
