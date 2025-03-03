return {
  "neovim/nvim-lspconfig",
  opts = {
    setup = {
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
