-- render-markdown.nvim manages conceallevel/concealcursor itself (forces
-- conceallevel=3 on every render pass, reveals the cursor's line via its own
-- extmark-based anti-conceal rather than concealcursor) - setting them here
-- would just get silently overwritten. Spellcheck is the only thing to add.
vim.opt_local.spell = true
vim.opt_local.spelllang = "en_us"

-- toggle a `- [ ]`/`- [x]` checkbox on the current line
vim.keymap.set("n", "<LocalLeader>x", function()
	local line = vim.api.nvim_get_current_line()
	local new_line
	if line:find("%[ %]") then
		new_line = line:gsub("%[ %]", "[x]", 1)
	elseif line:find("%[x%]") then
		new_line = line:gsub("%[x%]", "[ ]", 1)
	end
	if new_line then
		vim.api.nvim_set_current_line(new_line)
	end
end, { buffer = true, desc = "Toggle checkbox" })

-- vim-table-mode's own default mappings are disabled (they live on
-- <Leader>t*, which collides with the terminal-toggle prefix); this is the
-- only entry point, kept local to markdown buffers.
vim.keymap.set("n", "<LocalLeader>t", "<cmd>TableModeToggle<CR>", { buffer = true, desc = "Toggle table mode" })
