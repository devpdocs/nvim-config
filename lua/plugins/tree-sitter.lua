return {
  'nvim-treesitter/nvim-treesitter',
  dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
  build = ':TSUpdate',
  branch = 'main',
  lazy = false, -- la rama main NO soporta lazy-loading
  -- ELIMINADO: main = 'nvim-treesitter.configs' (módulo ya no existe en la rama main)
  config = function()
    require('nvim-treesitter').setup({
      install_dir = vim.fn.stdpath('data') .. '/treesitter',
    })

    -- Instalar parsers (reemplaza ensure_installed del API viejo)
    local ensure_installed = {
      'c',
      'javascript',
      'lua',
      'luadoc',
      'markdown',
      'markdown_inline',
      'python',
      'php',
      'rust',
      'typescript',
      'tsx',
      'html',
      'css',
      'scss',
      'cpp',
      'c_sharp',
      'json',
      -- 'jsonc',
      'astro',
      'go',
    }

    local installed = require('nvim-treesitter.config').get_installed()
    local to_install = vim.tbl_filter(function(p)
      return not vim.tbl_contains(installed, p)
    end, ensure_installed)

    if #to_install > 0 then
      require('nvim-treesitter').install(to_install)
    end

    -- Highlight e indent ahora los activa Neovim directamente via autocmd
    vim.api.nvim_create_autocmd('FileType', {
      callback = function()
        pcall(vim.treesitter.start)
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}

-- NOTA: nvim-treesitter-textobjects también requiere su rama main.
-- Agrega en su spec: branch = 'main'
-- Los keymaps de textobjects se configuran en el spec de nvim-treesitter-textobjects,
-- no dentro de nvim-treesitter.configs (que ya no existe).
