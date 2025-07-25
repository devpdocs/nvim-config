return {
  'nvim-treesitter/nvim-treesitter',
  dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
  build = ":TSUpdate",
  event = 'VeryLazy',
  main = 'nvim-treesitter.configs',
  opts = {
    ensure_installed = {
      'c',
      'php';
      'javascript',
      'lua',
      'luadoc',
      'markdown',
      'markdown_inline',
      'python',
      'php',
      'rust',
      'typescript',
      'html',
      'css',
      'scss',
      'cpp',
      'c_sharp',
      'json',
      'jsonc',
      'astro',
    },
    highlight = {
      enable = true,
    },
    indent = {
      enable = true,
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@conditional.outer",
          ["ic"] = "@conditional.inner",
          ["al"] = "@loop.outer",
          ["il"] = "@loop.inner",

        },
      },
    },
  },
}
