local M = {}

---@class printemps.Config
M.config = {
  -- leave the editor background to the terminal (Ghostty draws it translucent)
  transparent = true,
}

---@param opts? printemps.Config
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

function M.load()
  if vim.g.colors_name then
    vim.cmd("hi clear")
  end
  vim.o.termguicolors = true
  vim.o.background = "dark"
  vim.g.colors_name = "printemps"

  local p = require("printemps.palette")
  for group, hl in pairs(require("printemps.groups").get(p, M.config)) do
    vim.api.nvim_set_hl(0, group, hl)
  end

  local ansi = {
    p.overlay,
    p.geranium,
    p.leaf,
    p.ochre,
    p.forgetmenot,
    p.lilac,
    p.sage,
    p.peony,
    p.muted,
    p.tulip,
    p.viburnum,
    p.pollen,
    p.sky,
    p.hydrangea,
    p.mist,
    p.petal,
  }
  for i, color in ipairs(ansi) do
    vim.g["terminal_color_" .. (i - 1)] = color
  end
end

return M
