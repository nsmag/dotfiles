return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      tailwindcss = {
        filetypes_exclude = { "markdown" },
        settings = {
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
        },
      },
    },
  },
}
