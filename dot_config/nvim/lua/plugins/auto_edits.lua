-- This file contains configuration information for plugins that perform
-- automatic edits (or other operations like ctags generation) based on context. Programmer's little helpers.
return {
  -- keep HTML/JSX/etc tags in sync
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    opts = {},
  },

  -- automatically create matching pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    dependencies = { "nvim-treesitter" },
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },

  -- automatically add 'end' statements. Needs `ft` (not `event`) since it
  -- activates via a FileType autocmd - `event` would miss the buffer
  -- that triggered the load, since FileType fires first.
  {
    "RRethy/nvim-treesitter-endwise",
    ft = { "ruby", "lua", "vim", "bash", "sh", "fish", "elixir", "julia" },
  },
}
