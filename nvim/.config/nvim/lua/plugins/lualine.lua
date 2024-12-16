return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    opts.options.components_separators = {
      left = "",
      right = "",
    }
    opts.options.section_separators = {
      left = "",
      right = "",
    }
    opts.sections.lualine_y = { "progress" }
    opts.sections.lualine_z = { "location" }
  end,
}
