# CLAUDE.md

Plugin-managed via `lazy.nvim` (bootstrapped in `lua/plugin_manager.lua`, which clones lazy.nvim if absent and calls `require('lazy').setup('plugins')` — so every file under `lua/plugins/*.lua` returning a lazy.nvim plugin spec is auto-loaded; no manual registration needed). Core (non-plugin) config is split by concern and required in order from `init.lua`: `display`, `line_numbers`, `editing`, `filetypes`, `keybindings`.

Notable non-obvious pieces:
- `lua/filetypes.lua` teaches Neovim to detect filetypes for chezmoi's `dot_*` naming convention (e.g. a buffer at `.../dot_zshrc` is filetype-detected as if it were `.zshrc`).
- `lua/plugins/claudecode.lua` wires up `coder/claudecode.nvim` (depends on `folke/snacks.nvim`) for driving Claude Code from inside Neovim; it runs the `claude` CLI (installed via the `claude-code` Homebrew cask) in an embedded terminal over the same WebSocket protocol as the official VS Code extension, bound under `<Leader>a*`.
- `lua/keymaps.lua` holds the editor-wide keymaps. Per-plugin ones live on the plugin's own spec under `lua/plugins/` (lazy.nvim `keys =`, which also gives lazy-loading), and buffer-local ones in `after/ftplugin/<ft>.lua`.
- `.chezmoiignore` excludes `lazy-lock.json` from chezmoi management (see repo-root `CLAUDE.md` for the general `.chezmoiignore` mechanism).
- `.claude/skills/nvim-filetype-support/` is a directory-scoped Claude Code skill (see repo-root `CLAUDE.md`) for adding per-filetype LSP/lint/format/DAP/treesitter support here.
