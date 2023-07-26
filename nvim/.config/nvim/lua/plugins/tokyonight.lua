return {
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    opts = {
      style = "night",
      on_highlights = function(hl, c)
        hl.TelescopeBorder = {
          bg = c.bg_dark,
          fg = c.magenta,
        }
      end,
    },
  },
}
