vim.o.background = "dark"
vim.cmd("silent! colorscheme dracula")

-- dracula levels floats with Normal and sinks the tree sidebar below it, so popups
-- read as holes instead of raised panels. Lift floats a step above the buffer and
-- give them an edge; level the sidebar. Re-applied on ColorScheme so it survives
-- the dashboard's scheme picker.
local function fix_surface_contrast()
  local ok, dracula = pcall(require, "dracula")
  if not ok then
    return
  end
  local c = dracula.colors()
  vim.api.nvim_set_hl(0, "NeoTreeNormal", { link = "Normal" })
  vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { link = "Normal" })
  vim.api.nvim_set_hl(0, "NormalFloat", { fg = c.fg, bg = c.visual })
  vim.api.nvim_set_hl(0, "FloatBorder", { fg = c.purple, bg = c.visual })
end
vim.api.nvim_create_autocmd("ColorScheme", { callback = fix_surface_contrast })
fix_surface_contrast()

-- show matching brackets/etc
vim.o.showmatch = true
-- show filename in title string
vim.o.title = true

-- tmux fix (don't ask me, ask stack overflow)
vim.cmd([[
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
]])

-- always show at least 7 lines around the cursor
vim.o.scrolloff = 7

-- show whitespace by default
vim.o.list = true
local whitespacechars = "tab:▸ ,trail:•,precedes:«,extends:»"
vim.o.listchars = whitespacechars
