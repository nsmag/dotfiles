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
    "LazyVim/LazyVim",
    opts = { colorscheme = "rose-pine" },
  },
}
