return {
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    opts = {
      style = "night",
      on_highlights = function(hl, c)
        -- noice
        hl.NoiceCmdlineIcon = {
          fg = c.magenta,
        }
        -- telescope
        hl.TelescopeBorder = {
          bg = c.bg_dark,
          fg = c.magenta,
        }
        hl.TelescopePromptBorder = {
          bg = c.bg_dark,
          fg = c.magenta,
        }
        hl.TelescopePromptTitle = {
          bg = c.bg_dark,
          fg = c.magenta,
        }
      end,
    },
  },
}
