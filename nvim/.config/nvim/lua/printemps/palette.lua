-- Printemps · after Claude Monet, Spring Flowers (1864)
-- Source palette: themes/printemps/preview.html

---@class printemps.Palette
return {
  -- base tones, background → foreground
  base = "#140e09", -- umber backdrop
  surface = "#1e1711", -- cursorline, panels
  overlay = "#2b231b", -- ANSI black, status bar
  hl_med = "#3c3128", -- selection
  hl_high = "#52453a", -- borders, search match
  muted = "#7a6c60", -- ANSI bright black, comments
  subtle = "#a7988d", -- secondary text
  text = "#e1d4d0", -- foreground, cursor

  -- accents
  geranium = "#d86e67", -- ANSI red
  tulip = "#ed9280", -- ANSI bright red
  wallflower = "#db9657", -- orange (truecolor only)
  ochre = "#deb870", -- ANSI yellow
  pollen = "#ead297", -- ANSI bright yellow
  leaf = "#a2b477", -- ANSI green
  viburnum = "#cbd3a7", -- ANSI bright green
  sage = "#83b7af", -- ANSI cyan
  mist = "#b1d7d3", -- ANSI bright cyan
  forgetmenot = "#70a4d0", -- ANSI blue
  sky = "#a1c6e6", -- ANSI bright blue
  lilac = "#b299c6", -- ANSI magenta
  hydrangea = "#e8b9c0", -- ANSI bright magenta
  peony = "#cec1bc", -- ANSI white
  petal = "#f3e9e5", -- ANSI bright white
}
