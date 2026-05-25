local ok, hologram = pcall(require, 'hologram')

-- We'll provide a fallback that calls `kitty +kitten icat` if the plugin
-- isn't available or fails. That helps when the plugin hasn't been installed
-- or when Neovim can't access the kitty protocol (e.g. running in tmux).

local use_hologram = ok

if use_hologram then
  hologram.setup({ auto_display = true })
end

-- Helper state
local displayed = false

local function is_image(path)
  if not path or path == '' then return false end
  local ext = path:match('%.([^%.]+)$')
  if not ext then return false end
  ext = ext:lower()
  local img_exts = { png=true, jpg=true, jpeg=true, gif=true, webp=true }
  return img_exts[ext]
end

local function kitty_show(path)
  if not path or path == '' then return false end
  -- Use jobstart so Neovim doesn't block; detach so the image remains
  -- displayed by Kitty. Log the result so we can debug failures.
  local ok, jid = pcall(vim.fn.jobstart, { 'kitty', '+kitten', 'icat', path }, {detach = true})
  if not ok then
    vim.notify('kitty icat jobstart failed: ' .. tostring(jid), vim.log.levels.WARN)
    return false
  end
  if jid and jid > 0 then
    vim.notify('kitty icat started, job id: ' .. tostring(jid), vim.log.levels.DEBUG)
    return true
  end
  vim.notify('kitty icat jobstart returned: ' .. tostring(jid), vim.log.levels.WARN)
  return false
end

local function show_current_image()
  local path = vim.fn.expand('%:p')
  if not is_image(path) then
    print('Not an image')
    return
  end

  if use_hologram and hologram and hologram.display then
    local ok, err = pcall(hologram.display, path)
    if not ok then
      vim.notify('hologram.display failed: ' .. tostring(err), vim.log.levels.WARN)
    else
      vim.notify('hologram.display succeeded', vim.log.levels.DEBUG)
      displayed = true
      return
    end
  end

  -- fallback to kitty icat
  if kitty_show(path) then
    displayed = true
    return
  end

  print('No image display available (hologram missing and kitty icat failed)')
end

local function hide_current_image()
  if use_hologram and hologram and hologram.hide then
    pcall(hologram.hide)
  else
    -- kitty icat images can't be programmatically hidden from Neovim easily;
    -- the user can redraw the terminal or open another buffer. We'll just
    -- notify the user.
    -- If Kitty supports clearing, user can run: printf '\033_Ga=d,;\033\\'
    -- but it's not portable here.
    -- So we simply inform the user.
    if displayed then
      print('Image displayed via kitty; to clear, redraw the terminal or switch buffer')
    end
  end
  displayed = false
end

local function toggle_image()
  if displayed then
    hide_current_image()
  else
    show_current_image()
  end
end

vim.api.nvim_set_keymap('n', '<leader>i', ":lua require('lrdev.hologram').toggle_image()<CR>", { noremap = true, silent = true })

vim.api.nvim_create_user_command('HologramShow', show_current_image, {})
vim.api.nvim_create_user_command('HologramHide', hide_current_image, {})
vim.api.nvim_create_user_command('HologramToggle', toggle_image, {})

-- Auto-display images when opening image files (works when opening from file explorer)
vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
  pattern = { '*.png', '*.jpg', '*.jpeg', '*.gif', '*.webp' },
  callback = function()
    -- don't error if module isn't loaded
    pcall(show_current_image)
  end,
})

return {
  show_current_image = show_current_image,
  hide_current_image = hide_current_image,
  toggle_image = toggle_image,
}
