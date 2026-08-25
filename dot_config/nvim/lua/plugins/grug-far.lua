-- find-and-replace across files, backed by ripgrep, with a diff preview
-- before applying. Internal buffer-local actions (Replace, Sync Line,
-- etc.) use <LocalLeader> by default - see :h grug-far-opts.
return {
	"MagicDuck/grug-far.nvim",
	keys = {
		{ "<Leader>fr", "<cmd>GrugFar<cr>", desc = "Find and replace" },
		{ "<Leader>fr", "<cmd>GrugFarWithin<cr>", mode = "x", desc = "Find and replace (in selection)" },
	},
	opts = {},
}
