return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      renderer = {
        indent_markers = {
          enable = true,
        },
        icons = {
          git_placement = "after",
          glyphs = {
            git = {
              unstaged = "!",
              staged = "+",
              unmerged = "=",
              renamed = "»",
              untracked = "?",
              deleted = "✗",
            },
          },
        },
      },
    },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Explorer (root dir)", remap = true },
    },
  },
}
