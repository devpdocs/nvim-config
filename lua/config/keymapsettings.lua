vim.keymap.set('n', '<leader>bd', ':bd!<cr>', { desc = 'Close the current buffer' })
vim.keymap.set('n', '<leader>rr', ':source %<cr>', { desc = 'Source the current file' })
vim.keymap.set('v', '>', '>gv', { desc = "after tab in re-select the same" })
vim.keymap.set('v', '<', '<gv', { desc = "after tab out re-select the same" })
vim.keymap.set('n', '|', ':vsplit<cr>', {desc = "Trigger vertical vsplit"})
vim.keymap.set('n', '<leader>|', ':split<cr>', {desc = "Trigger vertical split"})
vim.keymap.set('n', '<leader>j', '<C-w>j')
vim.keymap.set('n', '<leader>h', '<C-w>h')
vim.keymap.set('n', '<leader>k', '<C-w>k')
vim.keymap.set('n', '<leader>l', '<C-w>l')
vim.keymap.set('n', 'n', 'nzzzv', { desc = "Goes to the next result on the seach and put the cursor in the middle" })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = "Goes to the prev result on the seach and put the cursor in the middle" })
vim.keymap.set('n', '<C-fs>', ':%! jq<cr>', {desc = 'it Formats all the current json file way extatnal'})
vim.keymap.set('x', '<C-so>', ':.,$!sort<cr>', {desc = 'Sorts all elements selected'})
vim.keymap.set('n', '<Tab>,', '"+p', {desc = "Page external data to nvim"})



