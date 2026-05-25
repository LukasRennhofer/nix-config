-- main init.lua for nvim-config-lrdev

-- 1. Tell Lua where to find the nvim-treesitter module
local home = os.getenv("HOME")
package.path = package.path .. ";" .. home .. "/.local/share/nvim/site/pack/packer/start/nvim-treesitter/lua/?.lua"
package.path = package.path .. ";" .. home .. "/.local/share/nvim/site/pack/packer/start/nvim-treesitter/lua/?/init.lua"

-- 2. Add the plugin to the runtime path so Neovim can find its compiled parsers
vim.opt.runtimepath:append(home .. "/.local/share/nvim/site/pack/packer/start/nvim-treesitter")
-- Set the Leader key to comma
vim.g.mapleader = ","

-- Set Absolute numbers for editor
vim.opt.number = true

-- For Vantor Projects
vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
  pattern = { "*/Vantor/**/*.cpp", "*/Vantor/**/*.hpp" },
  callback = function(args)
    -- only insert if file is empty
    if vim.api.nvim_buf_line_count(0) == 1
      and vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == "" then

      local header = {
        "/****************************************************************************",
        " * Vantor Engine™ - Source Code (2025)",
        " *",
        " * Author    : Lukas Rennhofer (@LukasRennhofer), Vantor Studios™",
        " * Copyright : © 2025 Lukas Rennhofer, Vantor Studios™",
        " * License   : GNU General Public License v3.0",
        " *             See LICENSE file for full details.",
        " ****************************************************************************/",
        "",
      }

      -- insert header
      vim.api.nvim_buf_set_lines(0, 0, -1, false, header)

      -- check filetype by extension
      local fname = args.file
      if fname:match("%.hpp$") then
        vim.api.nvim_buf_set_lines(0, -1, -1, false, { "#pragma once", "" })
      end
    end
  end,
})


-- Bootstrap packer if not installed
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 
      'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

require('lrdev.plugins')

if packer_bootstrap then
  require('packer').sync()
  -- If we just bootstrapped packer, sync will install plugins asynchronously.
  -- Exit early so the rest of the config (which may `require` plugin modules)
  -- doesn't run before plugins are available.
  return
end

require('lrdev.colorscheme')
require('lrdev.lsp')
require('lrdev.treesitter')
require('lrdev.telescope')
require('lrdev.dap')
require('lrdev.keymaps')

-- Safe mappings and commands for hologram (calls the module only if available)
vim.api.nvim_set_keymap('n', '<leader>i', ":lua (function() local ok,m = pcall(require,'lrdev.hologram'); if ok and m and m.toggle_image then m.toggle_image() end end)()<CR>", { noremap = true, silent = true })

vim.api.nvim_create_user_command('HologramShow', function()
  local ok, m = pcall(require, 'lrdev.hologram')
  if ok and m and m.show_current_image then pcall(m.show_current_image) end
end, {})

vim.api.nvim_create_user_command('HologramHide', function()
  local ok, m = pcall(require, 'lrdev.hologram')
  if ok and m and m.hide_current_image then pcall(m.hide_current_image) end
end, {})

vim.api.nvim_create_user_command('HologramToggle', function()
  local ok, m = pcall(require, 'lrdev.hologram')
  if ok and m and m.toggle_image then pcall(m.toggle_image) end
end, {})

-- Simple fallback command: show current file with Kitty's icat
vim.api.nvim_create_user_command('IcatCurrent', function()
  local path = vim.fn.expand('%:p')
  if path == nil or path == '' then
    print('No file to show')
    return
  end
  -- If running inside tmux, warn the user (kitty protocol may not work)
  if vim.env.TMUX and vim.env.TMUX ~= '' then
    vim.notify('You are running inside tmux — kitty graphics may not be available', vim.log.levels.WARN)
  end

  -- Simple: run kitty icat synchronously (blocks until image viewed/closed)
  local ok, err = pcall(vim.fn.system, { 'kitty', '+kitten', 'icat', path })
  if not ok then
    print('Error: ' .. tostring(err))
  else
    print('Image command returned: ' .. tostring(err))
  end
end, {})

-- Mapping: <leader>K to show current file with kitty icat
vim.api.nvim_set_keymap('n', '<leader>K', ':IcatCurrent<CR>', { noremap = true, silent = true })
