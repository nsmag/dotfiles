return {
  {
    "akinsho/flutter-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    ft = "dart",
    config = function()
      require("flutter-tools").setup({})
    end,
  },
}
