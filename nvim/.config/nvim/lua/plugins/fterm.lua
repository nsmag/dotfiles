return {
  {
    "numToStr/FTerm.nvim",
    opts = {
      border = "rounded",
      dimensions = {
        width = 0.9,
        height = 0.9,
      },
    },
    keys = {
      {
        "<leader>t",
        function()
          require("FTerm").toggle()
        end,
        desc = "Terminal",
      },
      {
        "<esc>",
        function()
          require("FTerm").toggle()
        end,
        mode = "t",
      },
    },
  },
}
