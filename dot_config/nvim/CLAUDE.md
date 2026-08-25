# CLAUDE.md

Plugin-managed via `lazy.nvim` (bootstrapped in `lua/plugin_manager.lua`, which clones lazy.nvim if absent and calls `require('lazy').setup('plugins')` — so every file under `lua/plugins/*.lua` returning a lazy.nvim plugin spec is auto-loaded; no manual registration needed). Core (non-plugin) config is split by concern and required in order from `init.lua`: `display`, `line_numbers`, `editing`, `filetypes`, `keybindings`.

Notable non-obvious pieces:
- `lua/filetypes.lua` teaches Neovim to detect filetypes for chezmoi's `dot_*` naming convention (e.g. a buffer at `.../dot_zshrc` is filetype-detected as if it were `.zshrc`).
- `lua/plugins/claudecode.lua` wires up `coder/claudecode.nvim` (depends on `folke/snacks.nvim`) for driving Claude Code from inside Neovim; it runs the `claude` CLI (installed via the `claude-code` Homebrew cask) in an embedded terminal over the same WebSocket protocol as the official VS Code extension, bound under `<Leader>a*`.
- `lua/keybindings.lua` is the entry point for keymaps; per-plugin keybindings live in `lua/keybindings/{dashboard,fterm,fugitive,telescope,trouble}.lua`.
- `.chezmoiignore` excludes `lazy-lock.json` from chezmoi management (see repo-root `CLAUDE.md` for the general `.chezmoiignore` mechanism).
