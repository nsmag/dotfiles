return {
  "hrsh7th/nvim-cmp",
  opts = function(_, opts)
    local cmp = require("cmp")
    opts.mapping = vim.tbl_deep_extend("force", opts.mapping, {
      -- Remap item select
      ["<C-n>"] = nil,
      ["<C-p>"] = nil,
      ["<C-j>"] = cmp.mapping.select_next_item(),
      ["<C-k>"] = cmp.mapping.select_prev_item(),
      -- Remap doc scroll
      ["<C-b>"] = nil,
      ["<C-f>"] = nil,
      ["<C-u>"] = cmp.mapping.scroll_docs(-4),
      ["<C-d>"] = cmp.mapping.scroll_docs(4),
      -- Remap abort
      ["<C-e>"] = nil,
      ["<C-c>"] = cmp.mapping.abort(),
    })
  end,
}
