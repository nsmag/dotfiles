return {
  {
    "goolord/alpha-nvim",
    opts = function()
      local dashboard = require("alpha.themes.dashboard")
      local logo = [[
      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣴⣶⣶⣿⣿⣿⣿⣿⣿⣿⣷⣶⣶⣦⣤⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣾⣿⡿⠿⠛⠋⠉⠁⠀⠀⠀⠀⠀⠀⠈⠉⠙⠛⠿⢿⣿⣷⣦⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⣿⠟⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠻⢿⣿⣦⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣾⡿⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⢿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⡿⠋⠀⣠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⣿⠟⠀⠀⠀⣿⠀⠀⠀⢀⡄⠀⠀⠀⠀⠀⠀⠀⣠⣾⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
      ⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⠏⠀⠀⠀⠀⣿⣄⠀⣠⣾⣇⠀⠀⠀⣀⣤⣶⡿⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀
      ⠀⠀⣀⠀⠀⠀⠀⣼⣿⠃⠀⠀⠀⠀⢰⠟⣿⠿⠋⠘⠿⣿⣿⣿⡟⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀
      ⣼⡿⠿⢿⣷⣶⣴⣿⠏⠀⠀⠀⠀⠀⣿⣿⡿⠀⠀⠀⠀⣿⣼⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣷⠀⠀⠀⠀⠀⠀⠀
      ⣿⣇⠀⠀⠈⢛⣿⡟⠀⠀⠀⠀⠀⠀⠘⠟⠁⠀⠀⠀⠀⢻⣿⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⠀⠀⠀⢸⣿⣇⠀⠀⠀⠀⠀⠀
      ⢹⣿⠀⠀⠀⣼⣿⠃⠀⠀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴⣶⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣴⣾⠿⠟⠛⠛⠻⣿⣆⠀⠀⢿⣿⠀⠀⠀⠀⠀⠀
      ⠘⣿⡇⠀⠀⣿⣿⠀⠀⢸⣷⡀⠀⠀⠀⠀⠀⠀⠀⣀⣠⣤⣶⡿⠟⠛⢩⣿⣿⠀⠀⠀⠀⠀⠀⠀⢀⣴⣾⠿⠛⠉⠀⠀⠀⠀⠀⢀⣿⡇⠀⠀⢸⣿⡇⠀⠀⠀⠀⠀
      ⠀⢹⣿⡄⢰⣿⡇⠀⠀⠀⣿⣿⣶⣶⣶⣶⣶⣾⡿⠟⢻⣿⠁⠀⠀⠀⣸⣿⣿⡇⠀⠀⠀⠀⠀⠀⠿⠛⠁⠀⠀⠀⠀⠀⠀⠀⢀⣼⡿⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀
      ⠀⠀⢻⣿⣼⣿⡇⠀⠀⠀⢸⡇⠈⠉⢹⣇⠀⣸⣧⠀⣼⣿⡆⠀⠀⢠⣿⣧⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣿⠟⠀⠀⠀⠀⠀⣿⣿⠀⠀⠀⠀⠀
      ⠀⠀⠀⠹⣿⣿⡇⠀⠀⠀⢸⣿⠀⠀⢸⣿⣄⣿⣿⣷⣿⠿⣿⡄⠀⣼⡿⢸⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⡿⠋⠀⠀⠀⠀⠀⠀⣿⣿⠀⠀⠀⠀⠀
      ⠀⠀⠀⠀⢸⣿⡇⠀⠀⠀⠸⣿⡆⠀⣿⣿⣿⡟⠋⠙⠁⠀⠙⢿⣶⣿⠃⢸⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠀⠀⠀⠀⠀
      ⠀⠀⠀⠀⢸⣿⡇⠀⠀⠀⠀⣿⣿⣾⣿⣿⡟⠀⠀⠀⠀⠀⠀⠈⠙⠁⠀⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡟⠀⠀⠀⠀⠀
      ⠀⠀⠀⠀⠈⣿⣇⠀⠀⠀⠀⢿⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀
      ⠀⠀⠀⠀⠀⢿⣿⠀⠀⠀⠀⠸⣿⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣷⣶⣶⣶⣤⣀
      ⠀⠀⠀⠀⠀⠸⣿⡇⠀⠀⠀⠀⢹⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⠟⠁⠀⠀⠈⣹⣿
      ⠀⠀⠀⠀⠀⠀⢻⣿⡄⠀⠀⠀⠀⢿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣿⠏
      ⠀⠀⠀⠀⠀⠀⠈⢿⣷⡀⠀⠀⠀⠈⢿⣧⡀⠀⠀⠀⠀⠀⠀⢀⣼⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣾⠟⠁⠀
      ⠀⠀⠀⠀⠀⠀⠀⠀⢻⣿⣄⠀⠀⠀⠀⠹⣿⣦⣀⠀⠀⢀⣠⣾⡟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⠟⠁⠀⠀⠀
      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣿⣦⡀⠀⠀⠀⠈⠛⠿⣿⣿⡿⠿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣴⣾⡿⠟⠁⠀⠀⠀⠀⠀
      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣿⣦⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴⣿⠿⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀
      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⢿⣷⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣤⣶⣾⡿⠟⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⢿⣿⣶⣦⣤⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣤⣴⣶⣿⡿⠟⠛⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠿⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠿⠛⠋⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
      ]]

      dashboard.section.header.val = vim.split(logo, "\n")

      dashboard.section.buttons.val = {}
      dashboard.section.footer.opts.hl = "Type"
      dashboard.section.header.opts.hl = "AlphaHeader"
      dashboard.section.buttons.opts.hl = "AlphaButtons"
      dashboard.opts.layout[1].val = 8

      return dashboard
    end,
  },
}
