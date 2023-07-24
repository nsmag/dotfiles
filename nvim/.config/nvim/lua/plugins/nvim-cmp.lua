return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      { "onsails/lspkind.nvim" },
      { "js-everts/cmp-tailwind-colors" },
    },
    opts = function()
      local cmp = require("cmp")
      local lspkind = require("lspkind")
      local cmp_tailwind_colors = require("cmp-tailwind-colors")

      return {
        completion = {
          completeopt = "menu,menuone,noinsert,noselect",
        },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = {
          ["<c-j>"] = cmp.mapping.select_next_item(),
          ["<c-k>"] = cmp.mapping.select_prev_item(),
          ["<c-u>"] = cmp.mapping.scroll_docs(-4),
          ["<c-d>"] = cmp.mapping.scroll_docs(4),
          ["<c-space>"] = cmp.mapping.complete(),
          ["<c-c>"] = cmp.mapping.abort(),
          ["<cr>"] = cmp.mapping.confirm({ select = false }),
          ["<c-cr>"] = cmp.mapping.confirm({ select = false }),
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol_text",
            before = cmp_tailwind_colors.format,
          }),
        },
      }
    end,
  },
}
