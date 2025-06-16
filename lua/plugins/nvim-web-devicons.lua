return {
  "nvim-tree/nvim-web-devicons",
  config = function()
    require 'nvim-web-devicons'.set_icon {
      astro = {
        icon = "",
        color = "#EF8547",
        name = "astro"
      },
      css = {
        icon = "",
        color = "#563d7c",
        cterm_color = "60",
        name = "Css3"
      },
    }
  end
}
