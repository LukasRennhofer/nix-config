local on_attach = function(client, bufnr)
  local opts = { noremap=true, silent=true, buffer=bufnr }

  -- Keymaps (buffer-local)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format { async = true } end, opts)
end

-- Configure clangd
vim.lsp.config("clangd", {
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150,
  },
})

-- Enable clangd
vim.lsp.enable("clangd")

local cmp = require'cmp'

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- for snippets
    end,
  },
  mapping = {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<CR>']  = cmp.mapping.confirm({ select = true }),
    ['<C-Space>'] = cmp.mapping.complete(),
  },
  sources = {
    { name = 'nvim_lsp' },   -- completion from LSP
    { name = 'buffer' },     -- words in current buffer
    { name = 'path' },       -- file paths
    { name = 'luasnip' },    -- snippet completions
  },
})

