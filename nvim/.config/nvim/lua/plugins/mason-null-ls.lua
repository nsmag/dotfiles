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
        "prettier",
        "prettierd",
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
    opts = function()
      local null_ls = require("null-ls")

      return {
        sources = {
          null_ls.builtins.formatting.prettier.with({
            extra_filetypes = { "mdx" },
            prefer_local = "node_modules/.bin",
          }),
          -- null_ls.builtins.formatting.prettierd.with({
          --   env = {
          --     PRETTIERD_LOCAL_PRETTIER_ONLY = true,
          --   },
          -- }),
        },
      }
    end,
  },
}
