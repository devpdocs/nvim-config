return {
  'devpdocs/chatcode_nvim',
  dir = '~/.config/nvim/lua/my-plugins/lua/mbt-chatcode',
  config = function()
    require('my-plugins/lua/mbt-chatcode').chatcode()
    require('my-plugins/lua/mbt-chatcode').setup{kill_chat_code = true}
  end,
  event = 'VeryLazy'
}
