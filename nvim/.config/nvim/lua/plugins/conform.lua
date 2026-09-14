local function has_prettier_config(formatter, ctx)
  if ctx.filename == "" then
    return false
  end

  local command = formatter.command
  if type(command) == "function" then
    command = command(formatter, ctx)
  end
  if type(command) ~= "string" or vim.fn.executable(command) == 0 then
    return false
  end

  vim.fn.system({ command, "--find-config-path", ctx.filename })
  return vim.v.shell_error == 0
end

return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.formatters = opts.formatters or {}

      -- Keep Prettier unavailable unless the project has its own config.
      local prettier = opts.formatters.prettier or {}
      prettier.condition = function(formatter, ctx)
        return has_prettier_config(formatter, ctx)
      end
      opts.formatters.prettier = prettier

      -- Do not fall back to an LSP formatter when Prettier is the only
      -- formatter configured for a filetype without a Prettier config.
      for _, formatters in pairs(opts.formatters_by_ft or {}) do
        if type(formatters) == "table" and vim.tbl_contains(formatters, "prettier") then
          formatters.lsp_format = "never"
        end
      end
    end,
  },
}
