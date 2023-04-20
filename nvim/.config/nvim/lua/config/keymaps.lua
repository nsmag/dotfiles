-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local function map(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  -- do not create the keymap if a lazy keys handler exists
  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

-- Unmap some default keys
map("n", "<leader>gg", "<nop>")
map("n", "<leader>gG", "<nop>")
map("n", "<leader>ft", "<nop>")
map("n", "<leader>fT", "<nop>")

-- Easy exit insert mode
map("i", "jk", "<esc>")

-- Move in insert mode
map("i", "<c-h>", "<left>")
map("i", "<c-j>", "<down>")
map("i", "<c-k>", "<up>")
map("i", "<c-l>", "<right>")

-- nvim-tmux-navigation
map("n", "<c-h>", "<cmd>NvimTmuxNavigateLeft<cr>")
map("n", "<c-j>", "<cmd>NvimTmuxNavigateDown<cr>")
map("n", "<c-k>", "<cmd>NvimTmuxNavigateUp<cr>")
map("n", "<c-l>", "<cmd>NvimTmuxNavigateRight<cr>")
map("n", "<c-\\>", "<cmd>NvimTmuxNavigateLastActive<cr>")
map("n", "<c-space>", "<cmd>NvimTmuxNavigateNext<cr>")
