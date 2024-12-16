return {
  "folke/tokyonight.nvim",
  opts = {
    style = "night",
    on_highlights = function(hl, c)
      -- dashboard
      hl.DashboardFooter = {
        fg = c.yellow,
      }
      hl.DashboardKey = {
        fg = c.magenta,
      }
      -- fzf
      hl.FzfLuaBorder = {
        fg = c.magenta,
        bg = c.bg_float,
      }
      hl.FzfLuaFzfPointer = {
        fg = c.magenta,
      }
      hl.FzfLuaFzfSeparator = {
        fg = c.magenta,
        bg = c.bg_float,
      }
      hl.FzfLuaPreviewTitle = {
        fg = c.magenta,
        bg = c.bg_float,
      }
      hl.FzfLuaTitle = {
        fg = c.magenta,
        bg = c.bg_float,
      }
      -- noice
      hl.NoiceCmdlineIcon = {
        fg = c.magenta,
      }
    end,
  },
}
