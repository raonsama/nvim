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
      ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
      setup = {},
    },
  },
}
