return {
  {
    "jose-elias-alvarez/null-ls.nvim",
    opts = function()
      local nls = require("null-ls")
      return {
        sources = {
          nls.builtins.formatting.gofumpt,
          nls.builtins.formatting.jq,
          nls.builtins.formatting.prettierd,
          nls.builtins.formatting.stylua,
          nls.builtins.formatting.taplo,
          nls.builtins.formatting.yamlfmt,
        },
      }
    end,
  },
}
