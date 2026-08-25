-- This file contains plugin configuration for two different (but related) types
-- of plugins:
-- 1) Plugins that create "text objects," which provide targets for various
--    operators
-- 2) Plugins that add or modify operators, which perform operations against
--    text objects/selections
return {
  -- treesitter-based split/join of multiline statements. Under <Leader>x
  -- since j/J/s/S/m are all already claimed by window-nav/split/harpoon.
  {
    "Wansmer/treesj",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    keys = {
      { "<Leader>x", nil, desc = "Split/Join" },
      {
        "<Leader>xm",
        function()
          require("treesj").toggle()
        end,
        desc = "Toggle split/join",
      },
      {
        "<Leader>xj",
        function()
          require("treesj").join()
        end,
        desc = "Join",
      },
      {
        "<Leader>xs",
        function()
          require("treesj").split()
        end,
        desc = "Split",
      },
    },
    opts = { use_default_keymaps = false },
  },

  -- provide a shortcut for sorting text in a motion/textobj
  "christoomey/vim-sort-motion",

  -- comment text objects (ic/ac), treesitter-based. @comment.inner isn't
  -- defined for every language's query file, but fails silently.
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    keys = {
      {
        "ic",
        function()
          require("nvim-treesitter-textobjects.select").select_textobject("@comment.inner", "textobjects")
        end,
        mode = { "x", "o" },
        desc = "Inner comment",
      },
      {
        "ac",
        function()
          require("nvim-treesitter-textobjects.select").select_textobject("@comment.outer", "textobjects")
        end,
        mode = { "x", "o" },
        desc = "Around comment",
      },
    },
    opts = {},
  },

  -- indentation (ii/ai) and current-line-characterwise (i_/a_) text
  -- objects. Line uses i_/a_ rather than il/al since mini.ai below
  -- claims those for its next/last-match modifiers.
  {
    "chrisgrieser/nvim-various-textobjs",
    keys = {
      {
        "ii",
        '<cmd>lua require("various-textobjs").indentation("inner", "inner")<CR>',
        mode = { "x", "o" },
        desc = "Inner indentation",
      },
      {
        "ai",
        '<cmd>lua require("various-textobjs").indentation("outer", "inner")<CR>',
        mode = { "x", "o" },
        desc = "Around indentation",
      },
      {
        "i_",
        '<cmd>lua require("various-textobjs").lineCharacterwise("inner")<CR>',
        mode = { "x", "o" },
        desc = "Inner line",
      },
      {
        "a_",
        '<cmd>lua require("various-textobjs").lineCharacterwise("outer")<CR>',
        mode = { "x", "o" },
        desc = "Around line",
      },
    },
    opts = {},
  },

  -- sets `commentstring` based on treesitter injections at the cursor
  -- (e.g. JS inside an HTML <script> tag gets `//`, not `<!-- -->`)
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    opts = { enable_autocmd = false },
  },

  -- comment/uncomment operators: gcc line toggle, gc{motion}/visual gc
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    opts = function()
      return {
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      }
    end,
  },

  -- Allow custom commands to be repeated
  "tpope/vim-repeat",

  -- surround operators: ys/ds/cs, S/gS in visual mode, <C-g>s in insert
  {
    "kylechui/nvim-surround",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- extends a/i text objects with seek-forward/expand-outward behavior
  -- and an/in/al/il next-/last-match modifiers (e.g. `di al)` = delete
  -- around the previous paren)
  {
    "nvim-mini/mini.ai",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },
}
