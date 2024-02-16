return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      table.insert(opts.routes, {
        filter = {
          event = "notify",
          find = "Spawning language server",
        },

        opts = { skip = true },
      })
    end
  },
}
