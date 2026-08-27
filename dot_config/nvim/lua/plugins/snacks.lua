-- snacks.nvim - collection of QoL plugins

-- feeds the harpoon2 list into the dashboard's "Bookmarks" picker below
local function harpoon_items()
  local harpoon = require("harpoon")
  local list = harpoon:list()
  local items = {}
  for i = 1, list:length() do
    local item = list.items[i]
    if item then
      items[#items + 1] = {
        text = i .. " " .. item.value,
        file = item.value,
        pos = { (item.context and item.context.row) or 1, (item.context and item.context.col) or 0 },
      }
    end
  end
  return items
end

-- permalink to the last visual selection in the current buffer, built the
-- same way Snacks.gitbrowse builds its own permalinks
local function selection_permalink()
  local file = vim.api.nvim_buf_get_name(0)
  local cwd = vim.fn.fnamemodify(file, ":h")
  local rel_file = vim.trim(vim.fn.system({ "git", "-C", cwd, "ls-files", "--full-name", file }))
  local commit = vim.trim(vim.fn.system({ "git", "-C", cwd, "log", "-n", "1", "--pretty=format:%H", "--", file }))
  local remote = vim.trim(vim.fn.system({ "git", "-C", cwd, "remote", "get-url", "origin" }))
  local repo = Snacks.gitbrowse.get_repo(remote)

  local line_start, line_end = vim.fn.line("'<"), vim.fn.line("'>")
  if line_start > line_end then
    line_start, line_end = line_end, line_start
  end

  return Snacks.gitbrowse.get_url(repo, {
    file = rel_file,
    commit = commit,
    line_start = line_start,
    line_end = line_end,
  }, { what = "permalink" })
end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  keys = {
    {
      "<Leader>t",
      function()
        Snacks.terminal.toggle()
      end,
      desc = "Toggle terminal",
    },
    {
      "<Leader>z",
      function()
        Snacks.scratch()
      end,
      desc = "Toggle scratch buffer",
    },
    -- extends the gr* convention rather than a bracket motion
    {
      "grw",
      function()
        Snacks.words.jump(1, true)
      end,
      desc = "Next reference (words)",
    },
    {
      "grW",
      function()
        Snacks.words.jump(-1, true)
      end,
      desc = "Prev reference (words)",
    },
    -- <Leader>g* terminal helpers: the plain Git commands (b/d/l/s)
    -- live on the vim-fugitive spec instead.
    {
      "<Leader>go",
      function()
        Snacks.gitbrowse()
      end,
      desc = "Git browse",
    },
    {
      "<Leader>gp",
      -- Runs through an interactive shell (-ic) so aliases like `gp`
      -- resolve. A second, distinct Snacks terminal (count = 2) keeps
      -- this separate from the plain <Leader>t shell - terminal
      -- identity is based on cmd/cwd/env/count, see docs/terminal.md.
      function()
        Snacks.terminal({ vim.o.shell, "-ic", "gp" }, { count = 2, auto_close = false })
      end,
      desc = "Git push (gp alias)",
    },
    {
      "<Leader>gt",
      function()
        Snacks.terminal.toggle(nil, { count = 2 })
      end,
      desc = "Git terminal",
    },
    {
      "<Leader>gu",
      function()
        Snacks.terminal({ vim.o.shell, "-ic", "git-smart-sync" }, { count = 2, auto_close = false })
      end,
      desc = "git-smart-sync",
    },
    -- PRs use gr/gR (not gp/gP) since gp is already git push above
    {
      "<Leader>gi",
      function()
        Snacks.picker.gh_issue()
      end,
      desc = "Browse open issues",
    },
    {
      "<Leader>gI",
      function()
        Snacks.picker.gh_issue({ state = "all" })
      end,
      desc = "Browse all issues",
    },
    {
      "<Leader>gr",
      function()
        Snacks.picker.gh_pr()
      end,
      desc = "Browse open PRs",
    },
    {
      "<Leader>gR",
      function()
        Snacks.picker.gh_pr({ state = "all" })
      end,
      desc = "Browse all PRs",
    },
    {
      "<Leader>gn",
      function()
        Snacks.terminal({ "gh", "pr", "create" }, { count = 2, auto_close = false })
      end,
      desc = "New PR",
    },
    {
      "<Leader>gN",
      function()
        Snacks.terminal({ "gh", "issue", "create" }, { count = 2, auto_close = false })
      end,
      desc = "New issue",
    },
    {
      "<Leader>gN",
      function()
        Snacks.terminal({ "gh", "issue", "create", "--body", selection_permalink() }, { count = 2, auto_close = false })
      end,
      mode = "x",
      desc = "New issue (linking selection)",
    },
  },
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    quickfile = { enabled = true },
    scroll = { enabled = true },
    indent = { enabled = true },
    words = { enabled = true },
    notifier = { enabled = true },
    -- Ghostty speaks the kitty graphics protocol, so markdown images render
    -- inline. Needs `magick` for anything but PNG (Brewfile), and `gs` for PDFs.
    image = { enabled = true },
    gh = {},
    terminal = {
      win = {
        position = "float",
        width = 0.8,
        height = 0.8,
        border = "rounded",
      },
    },
    gitbrowse = {},
    dashboard = {
      enabled = true,
      preset = {
        keys = {
          {
            icon = " ",
            key = "f",
            desc = "Find File",
            action = function()
              Snacks.dashboard.pick("files")
            end,
          },
          {
            icon = " ",
            key = "h",
            desc = "Find History",
            action = function()
              Snacks.dashboard.pick("oldfiles")
            end,
          },
          {
            icon = " ",
            key = "w",
            desc = "Find Word",
            action = function()
              Snacks.dashboard.pick("live_grep")
            end,
          },
          {
            icon = " ",
            key = "b",
            desc = "Bookmarks",
            action = function()
              Snacks.picker.pick({
                title = "Harpoon",
                finder = harpoon_items,
                format = "file",
              })
            end,
          },
          {
            icon = " ",
            key = "c",
            desc = "Change Colorscheme",
            action = function()
              Snacks.dashboard.pick("colorscheme")
            end,
          },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
        },
      },
    },
  },
}
