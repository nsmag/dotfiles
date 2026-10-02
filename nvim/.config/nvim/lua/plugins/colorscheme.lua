return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    opts = {
      styles = {
        transparency = true,
      },
      highlight_groups = {
        SnacksIndent = { fg = "overlay" },
        SnacksIndentScope = { fg = "muted" },
      },
    },
  },
  { "folke/tokyonight.nvim", enabled = false },
  { "catppuccin/nvim", enabled = false },
  {
    "akinsho/bufferline.nvim",
    optional = true,
    opts = function(_, opts)
      if (vim.g.colors_name or ""):find("printemps") then
        opts.highlights = require("printemps.bufferline").get()
      end
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "printemps" },
  },
}
