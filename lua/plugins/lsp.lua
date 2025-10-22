return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'williamboman/mason.nvim',
    'folke/neodev.nvim',
  },
  config = function()
    vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
    vim.keymap.set('n', '[d', function()
      vim.diagnostic.jump({ count = -1, float = true })
    end, { desc = 'Anterior diagnóstico + float' })

    vim.keymap.set('n', ']d', function()
      vim.diagnostic.jump({ count = 1, float = true })
    end, { desc = 'Siguiente diagnóstico + float' })
    vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)
    local on_attach = function(client, bufnr)
      --- auto_complete ctr-x + ctrl-o
      print("LSP attached: " .. client.name)
      vim.keymap.set('n', '.', vim.lsp.buf.hover, { buffer = bufnr })
      vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
      local opts = { buffer = bufnr }
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
      vim.keymap.set('n', '<C-K>', vim.lsp.buf.signature_help, opts)
      vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
      vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
      vim.keymap.set('n', '<leader>wl', function()
        print(vim.inspect(vim.lps.buf.list_workspace_folders()))
      end, opts)
      vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
      vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
      vim.keymap.set('n', '<leader>f', function()
        vim.lsp.buf.format { async = true }
      end, opts)
      if client.name == "rust_analyzer" then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      end
      if client.name == "clangd" then
        client.server_capabilities.signatureHelpProvider = false
      end
    end

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    require('neodev').setup()

    vim.lsp.config("lua_ls", {
      on_attach = on_attach,
      settings = {
        Lua = {
          telemetry = { enable = false },
          workspace = { checkThirdParty = false },
        },
      },
    })

    vim.lsp.enable("lua_ls")
    vim.lsp.config('pyright',{
      on_attach = on_attach,
      settings = {
        python = {
          telemetry = { enable = false },
          workspace = { checkThirdparty = false },
        },
      },

    })
    vim.lsp.config('ts_ls', {
      on_attach = on_attach,
      filetypes = {
        'javascript',
        'typescript',
        'typescriptreact'
      },
    })
    vim.lsp.config('astro', {
      on_attach = on_attach,
      capabilities = capabilities,
      init_options = {
        typescript = {
          tdsk = "/node_modules/typescript/lib"
        }
      },
    })
    vim.lsp.config('html', {
      capabilities = capabilities,
      on_attach = on_attach
    })
    vim.lsp.config('cssls', {
      on_attach = on_attach,
      capabilities = capabilities
    })
    vim.lsp.config('jsonls', {
      on_attach = on_attach,
      capabilities = capabilities
    })
    vim.lsp.config('rust_analyzer', {
      on_attach = on_attach,
      capabilities = capabilities
    })
    vim.lsp.config('clangd', {
    })
    vim.lsp.config('markdown_oxide', {
      on_attach = on_attach,
      capabilities = capabilities
    })
  end
}
