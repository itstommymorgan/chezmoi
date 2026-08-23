-- This file contains configuration for plugins that provide any kind of
-- interface/display specific to coding (or working in source control).

return {
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate'
  },

  -- git signs in the gutter
  {
    'lewis6991/gitsigns.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim'
    },
    config = true,
    opts = {},
  },

  -- Floating terminal windows
  'numToStr/FTerm.nvim',

  -- Git plugin
  {
    'tpope/vim-fugitive',
    dependencies = { 'shumphrey/fugitive-gitlab.vim' },
  },

  -- Enables :GBrowse, autocomplete, etc. to pull from GitHub.
  'tpope/vim-rhubarb',

  -- automatically show pairs
  {
    'windwp/nvim-autopairs',
    after = {'nvim-treesitter', 'nvim-cmp'},
    config = function()
      require('nvim-autopairs').setup({})
    end,
  },

  -- show indentation guidelines
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {},
    ---@module "ibl"
    ---@type ibl.config
    config = function()
      require("ibl").setup()
    end,
  },

  -- pretty list
  {
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = true,
  },

  -- Allow you to edit files directly from the quickfix results
  'stefandtw/quickfix-reflector.vim',

}
