return {
  'devpdocs/floatterminal_nvim',
  dir = '~/.config/nvim/lua/my-plugins/lua/mbt-floaterminal',
  config = function()
    require('my-plugins/lua/mbt-floaterminal').floaterminal()
    require('my-plugins/lua/mbt-floaterminal').setup{killterm = true}
  end,
  event = 'VeryLazy'
}
