return {
  {
    "akinsho/flutter-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    ft = "dart",
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
  },
}
