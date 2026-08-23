local function is_excluded()
  return vim.tbl_contains(vim.g.tm_special_buffers, vim.bo.filetype)
end

-- Create an autocommand group for native line number toggling
local number_toggle = vim.api.nvim_create_augroup("NumberToggle", { clear = true })

-- Function to safely apply line numbers based on current state
local function apply_numbers()
  if is_excluded() then
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
  else
    vim.opt_local.number = true
    if vim.api.nvim_get_mode().mode ~= "i" then
      vim.opt_local.relativenumber = true
    else
      vim.opt_local.relativenumber = false
    end
  end
end

-- Switch to absolute numbers when entering insert mode or losing focus
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
  group = number_toggle,
  callback = function()
    if is_excluded() then return end
    vim.opt_local.relativenumber = false
  end,
})

-- Switch to hybrid numbers when entering normal mode or gaining focus
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
  group = number_toggle,
  callback = function()
    if is_excluded() then return end
    if vim.api.nvim_get_mode().mode ~= "i" then
      vim.opt_local.relativenumber = true
    end
  end,
})

-- Handle excluded windows immediately when their filetype is set
vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
  group = number_toggle,
  callback = function()
    if is_excluded() then
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
      vim.opt_local.signcolumn = "no"
    end
  end,
})

-- FIX: Catch when an empty startup buffer gets recycled or filled with a file
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = number_toggle,
  callback = function()
    apply_numbers()
  end,
})

vim.opt.number = true
vim.opt.relativenumber = true
