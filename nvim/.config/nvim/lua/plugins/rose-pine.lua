return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    opts = {
      highlight_groups = {
        SnacksIndent = { fg = "overlay" },
        SnacksIndentScope = { fg = "muted" },
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "rose-pine" },
  },
}
