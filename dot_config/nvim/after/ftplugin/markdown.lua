-- render-markdown.nvim manages conceallevel/concealcursor itself (forces
-- them every render pass) - only spellcheck belongs here
vim.opt_local.spell = true
vim.opt_local.spelllang = "en_us"

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

vim.keymap.set("n", "<LocalLeader>t", "<cmd>TableModeToggle<CR>", { buffer = true, desc = "Toggle table mode" })
