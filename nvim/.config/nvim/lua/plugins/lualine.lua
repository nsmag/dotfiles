return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    opts.options.component_separators = {
      left = "",
      right = "",
    }
    opts.options.section_separators = {
      left = "",
      right = "",
    }
    opts.sections.lualine_b = { {
      "branch",
      icon = "",
    } }
    -- LazyVim's defaults without the profiler and lazy.nvim update count
    opts.sections.lualine_x = {
      -- stylua: ignore
      {
        function() return require("noice").api.status.command.get() end,
        cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
        color = function() return { fg = Snacks.util.color("Statement") } end,
      },
      -- stylua: ignore
      {
        function() return require("noice").api.status.mode.get() end,
        cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
        color = function() return { fg = Snacks.util.color("Constant") } end,
      },
      -- stylua: ignore
      {
        function() return "  " .. require("dap").status() end,
        cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
        color = function() return { fg = Snacks.util.color("Debug") } end,
      },
      {
        "diff",
        symbols = LazyVim.config.icons.git,
        source = function()
          local gitsigns = vim.b.gitsigns_status_dict
          if gitsigns then
            return {
              added = gitsigns.added,
              modified = gitsigns.changed,
              removed = gitsigns.removed,
            }
          end
        end,
      },
    }
    opts.sections.lualine_y = { "progress" }
    opts.sections.lualine_z = { "location" }
  end,
}
