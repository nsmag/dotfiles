return {
  "akinsho/flutter-tools.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "stevearc/dressing.nvim",
  },
  config = true,
  opts = {
    dev_tools = {
      autostart = true,
    },
    lsp = {
      color = {
        enabled = true,
        background = true,
        virtual_text = false,
      },
    },
  },
}
