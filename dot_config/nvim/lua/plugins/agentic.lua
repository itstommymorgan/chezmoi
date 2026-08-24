-- agentic - work with AI agents inside nvim
return {
	"carlos-algms/agentic.nvim",
	opts = {
		provider = "claude-agent-acp", -- use for claude code
	},
	keys = {
		{
			"<Leader>at",
			function()
				require("agentic").toggle()
			end,
			mode = { "n", "v" },
			desc = "Toggle Agentic chat",
		},
		{
			"<Leader>ac",
			function()
				require("agentic").add_context()
			end,
			mode = { "n", "v" },
			desc = "Add selection/file to context",
		},
		{
			"<Leader>an",
			function()
				require("agentic").new_session()
			end,
			mode = { "n", "v" },
			desc = "New Agentic session",
		},
	},
}
