return {
  "olimorris/onedarkpro.nvim",
  priority = 1000, -- Ensure it loads first

  config = function()
    require("onedarkpro").setup({
      options = {
        transparency = true
      },
      -- styles = {
      --   comments = "italic",
      --   keywords = "italic",
      --   functions = "italic",
      -- }
    })
    vim.cmd("colorscheme onedark")
  end,
}
