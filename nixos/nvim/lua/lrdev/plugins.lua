local fn = vim.fn

-- Automatically run :PackerCompile whenever plugins.lua is updated
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

local packer = require('packer')
local use = packer.use

packer.startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Colorscheme
  use 'morhetz/gruvbox'

  -- LSP Config
  use 'neovim/nvim-lspconfig'

  -- Treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }

  -- Telescope
  use {
    'nvim-telescope/telescope.nvim',
    requires = {'nvim-lua/plenary.nvim'}
  }

  use {
	'nvim-tree/nvim-tree.lua',
  	requires = { 'nvim-tree/nvim-web-devicons' }, -- optional, for icons
  	config = function()
     	require("nvim-tree").setup {}
  	end
  }
  
  use {
  "hrsh7th/nvim-cmp",
  requires = {
    "hrsh7th/cmp-nvim-lsp",    -- LSP completion
    "hrsh7th/cmp-buffer",      -- words from buffer
    "hrsh7th/cmp-path",        -- file paths
    "L3MON4D3/LuaSnip",        -- snippet engine
    "saadparwaiz1/cmp_luasnip" -- snippet completions
  }}

  -- Debug Adapter Protocol
  use 'mfussenegger/nvim-dap'

  -- Inline images in Kitty/WezTerm
  use {
    'edluffy/hologram.nvim',
    config = function()
      require('lrdev.hologram')
    end
  }

  -- GLSL syntax highlighting
  use 'tikhomirov/vim-glsl'

  -- Git integration
  use 'tpope/vim-fugitive'

  if packer_bootstrap then
    packer.sync()
  end
end)
