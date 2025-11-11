# LazyVim Pick 功能 - 安装和使用说明

## 已创建的文件

以下文件已经为您创建：

### 核心模块
1. `/Users/chan/.config/nvim/lua/util/root.lua` - 根目录检测模块
2. `/Users/chan/.config/nvim/lua/util/pick.lua` - Picker 包装器模块

### 配置文件
3. `/Users/chan/.config/nvim/lua/plugins/telescope-updated.lua` - 更新后的 Telescope 配置

### 文档
4. `/Users/chan/.config/nvim/docs/lazyvim-pick-implementation.md` - 完整实现文档
5. `/Users/chan/.config/nvim/docs/pick-quick-reference.md` - 快速参考指南
6. `/Users/chan/.config/nvim/docs/INSTALLATION.md` - 本文件

### 任务文件
7. `/Users/chan/.config/nvim/tasks/todo.md` - 研究笔记和任务列表

## 安装步骤

### 选项 1：替换现有配置（推荐）

如果您想使用新的智能根目录检测功能：

```bash
# 备份原配置
cd ~/.config/nvim/lua/plugins
cp telescope.lua telescope.lua.backup

# 使用新配置
mv telescope-updated.lua telescope.lua

# 重启 Neovim
```

### 选项 2：手动集成

如果您想保留现有配置并手动集成：

1. **保留两个工具模块**：
   - `lua/util/root.lua`
   - `lua/util/pick.lua`

2. **在您的 telescope.lua 中添加初始化代码**：

```lua
-- 在 config 函数中添加
config = function(_, opts)
  -- 初始化根目录检测
  require("util.root").setup()

  require("telescope").setup(opts)
  -- ... 其他代码
end
```

3. **更新需要的快捷键**：

```lua
-- 示例：只更新 <leader>ff 和 <leader>fF
local pick = require("util.pick")

keys = {
  -- 使用智能根目录检测
  { "<leader>ff", pick.wrap("find_files", { root = true }), desc = "Find Files (Root Dir)" },
  { "<leader>fF", pick.wrap("find_files", { root = false }), desc = "Find Files (cwd)" },
  -- ... 其他保持不变
}
```

### 选项 3：仅使用工具函数

如果您只想在需要时手动使用这些工具：

```lua
-- 在任何 Lua 文件中
local root = require("util.root")
local pick = require("util.pick")

-- 获取根目录
local project_root = root.get()

-- 手动调用 picker
pick.open("find_files", { root = true })
```

## 验证安装

### 1. 测试根目录检测

启动 Neovim 并执行：

```vim
:lua vim.print(require("util.root").get())
```

应该输出当前项目的根目录。

### 2. 测试 LazyRoot 命令

```vim
:LazyRoot
```

应该显示当前 buffer 的根目录检测信息。

### 3. 测试 Picker

按下 `<leader>ff`（或 `<space>ff`），应该：
- 打开 Telescope find_files
- 在项目根目录查找文件
- 显示正确的 cwd

按下 `<leader>fF`，应该：
- 在当前工作目录查找文件
- 不使用根目录检测

## 配置自定义

### 自定义根目录检测规则

在 `init.lua` 或任何配置文件中添加：

```lua
-- 默认规则
vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }

-- 示例：添加更多模式
vim.g.root_spec = {
  "lsp",
  { ".git", "package.json", "Cargo.toml", "pyproject.toml" },
  "cwd"
}

-- 示例：只使用 git 和 cwd
vim.g.root_spec = { { ".git" }, "cwd" }

-- 示例：不使用 LSP
vim.g.root_spec = { { ".git", "package.json" }, "cwd" }
```

### 忽略特定 LSP 服务器

某些 LSP 可能提供不正确的根目录：

```lua
vim.g.root_lsp_ignore = { "copilot", "null-ls" }
```

### 添加状态栏指示器

如果您使用 lualine，可以在状态栏显示根目录：

```lua
-- 在 lualine 配置的 sections 中添加
{
  function()
    local root = require("util.root")
    return vim.fn.fnamemodify(root.get(), ":~")
  end,
  icon = "󱉭",
  color = { fg = "#8aadf4" }
}
```

## 常见快捷键

安装后，您将拥有以下快捷键（假设 leader 是 Space）：

### 文件查找
- `<Space><Space>` - 在根目录查找文件
- `<Space>ff` - 在根目录查找文件
- `<Space>fF` - 在当前目录查找文件
- `<Space>fc` - 在配置目录查找文件
- `<Space>fg` - 查找 git 文件
- `<Space>fG` - 智能查找（优先 git_files）

### 文本搜索
- `<Space>/` - 在根目录 grep
- `<Space>sg` - 在根目录 grep
- `<Space>sG` - 在当前目录 grep
- `<Space>sw` - 在根目录搜索单词
- `<Space>sW` - 在当前目录搜索单词

### Telescope 内部
- `<Alt-i>` - 显示被忽略的文件
- `<Alt-h>` - 显示隐藏文件
- `<Ctrl-j/k>` - 上下移动
- `<Ctrl-f/b>` - 预览窗口滚动

## 故障排除

### 问题：找不到模块

如果出现 "module 'util.root' not found" 错误：

1. 确认文件存在：
```bash
ls ~/.config/nvim/lua/util/root.lua
ls ~/.config/nvim/lua/util/pick.lua
```

2. 确认路径正确：
```vim
:lua vim.print(vim.fn.stdpath("config"))
```

3. 重启 Neovim

### 问题：根目录检测不正确

1. 检查当前检测结果：
```vim
:LazyRoot
```

2. 查看所有候选根目录：
```vim
:lua vim.print(require("util.root").detect({ all = true }))
```

3. 自定义检测规则（见上面的配置部分）

### 问题：快捷键不工作

1. 确认 telescope 已加载：
```vim
:Telescope
```

2. 检查快捷键映射：
```vim
:nmap <leader>ff
```

3. 如果使用旧配置，确保已添加初始化代码：
```lua
require("util.root").setup()
```

### 问题：性能问题

1. 检查 find_command 配置：
```vim
:lua vim.print(require("telescope.config").values.find_command)
```

2. 确保安装了 ripgrep 或 fd：
```bash
which rg
which fd
```

3. 如果项目很大，考虑增加 ignore 模式

## 回滚

如果遇到问题想要回滚：

```bash
cd ~/.config/nvim/lua/plugins

# 如果有备份
mv telescope.lua.backup telescope.lua

# 或删除新文件
rm telescope-updated.lua

# 可选：删除工具模块
rm -rf ~/.config/nvim/lua/util
```

然后重启 Neovim。

## 下一步

1. **阅读完整文档**：查看 `docs/lazyvim-pick-implementation.md` 了解详细信息
2. **快速参考**：使用 `docs/pick-quick-reference.md` 作为速查手册
3. **自定义配置**：根据您的需求调整 `vim.g.root_spec`
4. **探索功能**：尝试不同的快捷键和选项

## 获取帮助

如果您有问题或建议：

1. 查看文档：
   - `docs/lazyvim-pick-implementation.md` - 完整文档
   - `docs/pick-quick-reference.md` - 快速参考

2. 查看源代码：
   - `lua/util/root.lua` - 根目录检测实现
   - `lua/util/pick.lua` - Picker 包装器实现

3. 参考 LazyVim 源代码：
   - https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/util/pick.lua
   - https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/util/root.lua

## 总结

您现在拥有了与 LazyVim 完全相同的智能文件查找功能！

**核心功能**：
- ✅ 自动项目根目录检测
- ✅ 智能 LSP/Git/Pattern 检测
- ✅ 缓存机制提升性能
- ✅ 与 LazyVim 一致的快捷键
- ✅ 完全可配置

**两个核心模块**：
- `util.root` - 根目录检测
- `util.pick` - Picker 包装器

**使用方式**：
```lua
local root = require("util.root")
local pick = require("util.pick")

-- 获取根目录
local project_root = root.get()

-- 使用 picker
pick.open("find_files", { root = true })
```

祝您使用愉快！
