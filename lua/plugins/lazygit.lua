-- ~/.config/nvim/lua/plugins/lazygit.lua
-- Note: LazyGit keymaps (gg, gG) are now handled by snacks.nvim
-- This plugin provides the LazyGit command integration
return {
	"kdheepak/lazygit.nvim",
	cmd = {
		"LazyGit",
		"LazyGitConfig",
		"LazyGitCurrentFile",
		"LazyGitFilter",
		"LazyGitFilterCurrentFile",
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
}
