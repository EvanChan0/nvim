return {
  "NMAC427/guess-indent.nvim",
  event = "BufReadPre",
  config = function()
    require('guess-indent').setup({
      auto_cmd = true,
      override_editorconfig = false,
      filetype_exclude = {
        "netrw", "tutor",
      },
      buftype_exclude = {
        "help", "nofile", "terminal", "prompt",
      },
    })
  end,
}
