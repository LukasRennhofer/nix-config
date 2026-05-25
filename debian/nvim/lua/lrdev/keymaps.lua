local opts = { noremap = true, silent = true }

-- Toggle NvimTree
vim.keymap.set('n', '<leader>e', function()
    require("nvim-tree.api").tree.toggle()
end, opts)

-- Clear search highlights
vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>', opts)

-- Quit
vim.keymap.set('n', '<leader>q', ':q<CR>', opts)

