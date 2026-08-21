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
      vim.g.gutentags_cache_dir = '~/.tags-cache'
    end,
  },

  -- Automatically add 'end' statements as appropriate
  'tpope/vim-endwise',

}
