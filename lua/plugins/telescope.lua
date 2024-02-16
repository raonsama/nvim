local telescopeConfig = require("telescope.config")
local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

return {
  {
    "nvim-telescope/telescope.nvim",
    event = "VeryLazy",
    opts = {
      defaults = {
        layout_strategy = "vertical",
        vimgrep_arguments = vimgrep_arguments,
      },
      pickers = {
        find_files = {
          find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
        },
      },
    },
  },
}
