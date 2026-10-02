local p = require("printemps.palette")

local function mode(color)
  return {
    a = { fg = p.base, bg = color, gui = "bold" },
    b = { fg = p.text, bg = p.overlay },
    c = { fg = p.subtle, bg = p.surface },
  }
end

return {
  normal = mode(p.forgetmenot),
  insert = mode(p.leaf),
  visual = mode(p.lilac),
  replace = mode(p.geranium),
  command = mode(p.ochre),
  terminal = mode(p.sage),
  inactive = {
    a = { fg = p.muted, bg = p.surface, gui = "bold" },
    b = { fg = p.muted, bg = p.surface },
    c = { fg = p.muted, bg = p.surface },
  },
}
