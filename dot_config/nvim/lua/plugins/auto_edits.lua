-- This file contains configuration information for plugins that perform
-- automatic edits (or other operations like ctags generation) based on context. Programmer's little helpers.
return {
  -- keep HTML tags in sync
  'AndrewRadev/tagalong.vim',

  -- autogenerate tagfiles
  {
    'ludovicchabant/vim-gutentags',
    config = function()
      -- use a temp folder for storing tags
      local tags_cache_dir = vim.fn.stdpath('cache') .. '/tags'
      vim.fn.mkdir(tags_cache_dir, 'p')
      vim.g.gutentags_cache_dir = tags_cache_dir
    end,
  },

  -- Automatically add 'end' statements as appropriate
  'tpope/vim-endwise',

}
