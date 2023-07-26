return {
  {
    "williamboman/mason.nvim",
  },
  {
    "jay-babu/mason-null-ls.nvim",
    opts = {
      ensure_installed = {
        "css-lsp",
        "gofumpt",
        "gopls",
        "hadolint",
        "html-lsp",
        "jq",
        "json-lsp",
        "lua-language-server",
        "prisma-language-server",
        "stylua",
        "tailwindcss-language-server",
        "taplo",
        "typescript-language-server",
        "xmlformatter",
        "yamlfmt",
      },
      automatic_installation = true,
      automatic_setup = true,
    },
    config = function(_, opts)
      require("mason-null-ls").setup(opts)
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
  },
}
