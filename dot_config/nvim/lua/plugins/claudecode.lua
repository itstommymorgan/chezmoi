-- claudecode.nvim - Claude Code IDE integration (same protocol as the VS Code extension)

-- Two console layouts; <leader>aw flips between them. The float is the default;
-- the right-hand split keeps a file visible while typing at the prompt.
local layouts = {
  float = { position = "float", relative = "editor", width = 0.85, height = 0.85, border = "rounded" },
  split = { position = "right", relative = "editor", width = 0.4, height = 0, border = "none" },
}
local layout = "float"

-- claudecode rebuilds its effective config from `terminal.defaults` on every open,
-- so swapping snacks_win_opts there covers any future terminal. A live one also
-- needs its window torn down and the Snacks instance re-pointed: `_cc.kind` is the
-- provider's hide-time float/split marker (it re-shows the recorded kind, ignoring
-- config), and `term.opts` is what Snacks itself re-creates a float from.
local function toggle_dock()
  layout = layout == "float" and "split" or "float"
  local ct = require("claudecode.terminal")
  local win_opts = layouts[layout]
  ct.defaults.snacks_win_opts = win_opts

  local bufnr = ct.get_active_terminal_bufnr()
  if not bufnr then
    return
  end

  local ok, term = pcall(ct._get_managed_terminal_for_test)
  if ok and term then
    -- hide() first so the float's backdrop is dealt with, then drop the backdrop
    -- outright: Snacks re-creates it on the next show().
    pcall(function()
      term:hide()
    end)
    if term.backdrop then
      pcall(function()
        term.backdrop:close()
      end)
      term.backdrop = nil
    end
  end
  -- A config-hidden float survives hide(); close it so the reopen re-creates.
  for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
    pcall(vim.api.nvim_win_close, win, false)
  end
  if ok and term then
    term.win = nil
    term.closed = true
    term.opts = vim.tbl_deep_extend("force", term.opts or {}, win_opts)
    if term._cc then
      term._cc.kind = nil
      if type(term._cc.config) == "table" then
        term._cc.config.snacks_win_opts = win_opts
      end
    end
  end
  ct.open()
end

return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  opts = {
    terminal = {
      snacks_win_opts = layouts.float,
    },
  },
  -- `cmd` lets lazy.nvim create command stubs that load the plugin on first use,
  -- so `:ClaudeCode` and friends work on a fresh start.
  cmd = {
    "ClaudeCode",
    "ClaudeCodeFocus",
    "ClaudeCodeSelectModel",
    "ClaudeCodeAdd",
    "ClaudeCodeSend",
    "ClaudeCodeTreeAdd",
    "ClaudeCodeStatus",
    "ClaudeCodeStart",
    "ClaudeCodeStop",
    "ClaudeCodeOpen",
    "ClaudeCodeClose",
    "ClaudeCodeDiffAccept",
    "ClaudeCodeDiffDeny",
    "ClaudeCodeCloseAllDiffs",
  },
  keys = {
    { "<leader>a", nil, desc = "AI/Claude Code" },
    { "<leader>ac", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    -- ar/aC force-close any live terminal first: ClaudeCode's toggle only reads
    -- its args (--resume/none) when spawning a *new* process, so reusing an
    -- already-running terminal would otherwise silently ignore the flag and
    -- just show/hide whatever's already running.
    {
      "<leader>ar",
      function()
        require("claudecode.terminal").close()
        vim.cmd("ClaudeCode --resume")
      end,
      desc = "Resume Claude (picker)",
    },
    {
      "<leader>aC",
      function()
        require("claudecode.terminal").close()
        vim.cmd("ClaudeCode")
      end,
      desc = "New Claude session",
    },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
    { "<leader>aw", toggle_dock, desc = "Toggle Claude float/split" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
    {
      "<leader>as",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Add file",
      ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw", "snacks_picker_list" },
    },
    -- Diff management
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
  },
}
