return {
  {
    "neovim/nvim-lspconfig",
    event = "LazyFile",
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        lua_ls = {
          mason = false,
        },
      },
    },
  },
}
