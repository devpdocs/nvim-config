local ls = require "luasnip"
local types = require "luasnip.util.types"

local M = {}

function M.setup()
  ls.config.set_config {
    history = true,
    updateevents = "TextChanged,TextChangedI",
    enable_autosnippets = true,
    ext_opts = {
      [types.choiceNode] = {
        active = {
          virt_text = { { "<- Choice", "Error" } },
        },
      },
    },
  }

  vim.keymap.set({ "i", "s" }, "<c-k>", function()
    if ls.expand_or_jumpable() then
      ls.expand_or_jump()
    end
  end, { silent = true })

  vim.keymap.set({ "i", "s" }, "<c-j>", function()
    if ls.jumpable(-1) then
      ls.jump(-1)
    end
  end, { silent = true })

  vim.keymap.set("i", "<c-l>", function()
    if ls.choice_active() then
      ls.change_choice(1)
    end
  end)

  -- Carga snippets de VSCode (friendly-snippets, etc.)
  require("luasnip.loaders.from_vscode").lazy_load()

  -- vim-react-snippets ya no expone lazy_load() directamente.
  -- Se carga mediante el loader de LuaSnip apuntando a su runtimepath.
  require("luasnip.loaders.from_vscode").lazy_load({
    paths = { vim.fn.stdpath("data") .. "/lazy/vim-react-snippets" },
  })
end

return M

