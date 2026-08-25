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

	-- indentation (ii/ai) and current-line-characterwise (i_/a_) text
	-- objects - replaces kana/vim-textobj-indent and kana/vim-textobj-line.
	-- vim-textobj-line's old il/al keys aren't reused here: mini.ai above
	-- claims il/al itself for its "inside/around last" next/last-match
	-- modifiers (e.g. `dil)` = delete inside last paren), and that's worth
	-- keeping intact rather than overriding for this comparatively minor
	-- object.
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

	-- extends a/i text objects with seek-forward and expand-outward
	-- behavior for brackets/quotes/tag/argument/function-call, plus
	-- explicit an/in/al/il next-/last-match modifiers (e.g. `di al)` =
	-- delete around the previous paren) - replaces wellle/targets.vim
	-- (and the kana/vim-textobj-user framework it and the others sat on).
	{
		"nvim-mini/mini.ai",
		event = { "BufReadPost", "BufNewFile" },
		opts = {},
	},
}
