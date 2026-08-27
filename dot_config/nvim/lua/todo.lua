-- Project todo lists.
--
-- The list is a plain-markdown `.todo.md` found by walking up from the current
-- buffer and stopping at the git root, so a subdirectory can hold its own list
-- without every subdirectory needing one. `.todo.md` is gitignored globally
-- (see `dot_config/git/ignore`), which keeps these personal in repos that
-- aren't ours. Claude Code reads the same file; the format contract it follows
-- lives in `dot_claude/CLAUDE.md`.

local M = {}

local FILENAME = ".todo.md"
local SECTION = "## Now"

local TEMPLATE = {
  "# Todo",
  "",
  "## Now",
  "",
  "## Next",
  "",
  "## Deferred",
  "",
  "## Blocked",
  "",
  "## Done",
  "",
}

-- where to resolve from: the current file's directory, or cwd for scratch and
-- terminal buffers that have no path of their own
local function origin()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" or vim.bo.buftype ~= "" then
    return vim.uv.cwd()
  end
  return vim.fs.dirname(file)
end

local function project_root(from)
  -- matches `.git` as a file too, so worktrees resolve like ordinary checkouts
  local git = vim.fs.find(".git", { upward = true, path = from, limit = 1 })[1]
  return git and vim.fs.dirname(git) or vim.uv.cwd()
end

-- nearest existing `.todo.md` at or above the origin, else the path one would
-- take at the project root
---@return string path
---@return string root
local function resolve()
  local from = origin()
  local root = project_root(from)
  local found = vim.fs.find(FILENAME, {
    upward = true,
    type = "file",
    path = from,
    -- `stop` is exclusive, so stop above the root to leave the root searchable
    stop = vim.fs.dirname(root),
    limit = 1,
  })[1]
  return found or vim.fs.joinpath(root, FILENAME), root
end

local function ensure(path)
  if vim.uv.fs_stat(path) then
    return
  end
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  vim.fn.writefile(TEMPLATE, path)
end

-- index that puts a new item directly under SECTION's heading, so items stay
-- newest-first and the blank line separating sections isn't consumed
local function insert_index(lines)
  for i, line in ipairs(lines) do
    if line == SECTION then
      return i + 1
    end
  end
end

function M.open()
  local path = resolve()
  ensure(path)
  vim.cmd.edit(vim.fn.fnameescape(path))
end

-- append to `## Now` without leaving the current buffer, tagging the item with
-- a `file:line` back-reference relative to the todo file
function M.capture()
  local path = resolve()
  local file = vim.api.nvim_buf_get_name(0)
  local ref
  if file ~= "" and vim.bo.buftype == "" and file ~= path then
    local rel = vim.fs.relpath(vim.fs.dirname(path), file) or file
    ref = ("%s:%d"):format(rel, vim.fn.line("."))
  end

  vim.ui.input({ prompt = "Todo: " }, function(text)
    if not text or vim.trim(text) == "" then
      return
    end
    ensure(path)

    local item = "- [ ] " .. vim.trim(text)
    if ref then
      item = ("%s (%s)"):format(item, ref)
    end

    local lines = vim.fn.readfile(path)
    local at = insert_index(lines)
    if at then
      table.insert(lines, at, item)
    else
      vim.list_extend(lines, { "", SECTION, "", item })
    end
    vim.fn.writefile(lines, path)

    -- the list is often open in another window
    vim.cmd.checktime()
    vim.notify("Added to " .. vim.fn.fnamemodify(path, ":~:."), vim.log.levels.INFO)
  end)
end

-- unchecked items across every `.todo.md` in the project. `.todo.md` is both a
-- dotfile and globally gitignored, so ripgrep has to be told twice to read it.
function M.pick()
  local _, root = resolve()
  Snacks.picker.grep({
    cwd = root,
    glob = { "**/" .. FILENAME },
    search = "^- \\[ \\]",
    regex = true,
    live = false,
    hidden = true,
    ignored = true,
    title = "Open todos",
  })
end

return M
