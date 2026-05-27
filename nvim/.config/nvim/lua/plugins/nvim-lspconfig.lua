return {
  "neovim/nvim-lspconfig",
  opts = {
    setup = {
      marksman = function(_, opts)
        opts.handlers = {
          ['textDocument/publishDiagnostics'] = function(err, result, ctx, config)
            if result and result.diagnostics then
              result.diagnostics = vim.tbl_filter(function(d)
                return not (d.message:find('Ambiguous link', 1, true)
                         or d.message:find('Duplicate definition', 1, true))
              end, result.diagnostics)
            end
            vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, config)
          end,
        }
      end,
      tailwindcss = function(_, opts)
        opts.settings = {
          tailwindCSS = {
            experimental = {
              classRegex = {
                {
                  "clsx\\(([^)]*)\\)",
                  "(?:'|\"|`)([^']*)(?:'|\"|`)",
                },
                {
                  "cva(?:\\<[^(]*)?\\(([^)]*)\\)",
                  "(?:'|\"|`)([^']*)(?:'|\"|`)",
                },
              },
            },
          },
        }
      end,
    },
  },
}
