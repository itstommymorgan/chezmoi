-- This file contains plugin configuration for two different (but related) types
-- of plugins:
-- 1) Plugins that create "text objects," which provide targets for various
--    operators
-- 2) Plugins that add or modify operators, which perform operations against
--    text objects/selections
return {
	-- allows for splitting and joining multiline statements
	-- (treesitter-based; replaces splitjoin.vim). Default keymaps collide
	-- with existing binds (<Leader>m is harpoon, j/s are window-nav/split),
	-- so they're remapped under a dedicated <Leader>J prefix instead.
	{
		"Wansmer/treesj",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		keys = {
			{ "<Leader>J", nil, desc = "Split/Join" },
			{
				"<Leader>Jm",
				function()
					require("treesj").toggle()
				end,
				desc = "Toggle split/join",
			},
			{
				"<Leader>Jj",
				function()
					require("treesj").join()
				end,
				desc = "Join",
			},
			{
				"<Leader>Js",
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

	-- provide text objects for comments
	{
		"glts/vim-textobj-comment",
		dependencies = { "kana/vim-textobj-user" },
	},

	-- provide text objects for indents
	{
		"kana/vim-textobj-indent",
		dependencies = { "kana/vim-textobj-user" },
	},

	-- provide text objects for lines
	{
		"kana/vim-textobj-line",
		dependencies = { "kana/vim-textobj-user" },
	},

	-- sets `commentstring` based on treesitter injections at the cursor,
	-- so e.g. JS inside an HTML <script> tag or a Vue SFC's <template>
	-- block gets the right comment syntax. Wired into Comment.nvim below
	-- via pre_hook rather than its default CursorHold autocmd.
	{
		"JoosepAlviste/nvim-ts-context-commentstring",
		opts = { enable_autocmd = false },
	},

	-- Provide operators for commenting code (gcc line toggle, gc{motion}/
	-- visual gc operator - same defaults as tpope/vim-commentary, which
	-- this replaces)
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

	-- Enables operators for manipulating surrounding punctuations (ys/ds/cs,
	-- S/gS in visual mode, <C-g>s in insert mode - same defaults as
	-- tpope/vim-surround, which this replaces)
	{
		"kylechui/nvim-surround",
		event = { "BufReadPost", "BufNewFile" },
		opts = {},
	},

	-- allow for a broader range of text objects
	"wellle/targets.vim",
}
