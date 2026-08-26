# Manual setup checklist

Everything `chezmoi apply` **can't** do on a new machine. Most of it is macOS TCC permission
grants (Apple deliberately blocks scripting these) or account logins.

Work top to bottom — 1Password first, since most of the rest needs credentials from it.

## 1. Credentials

- [ ] Sign in to **1Password**, then enable **Settings → Developer → Use the SSH agent**.
      (`run_once_before_20-use-1password-for-ssh.sh` walks through this and blocks until confirmed.)
- [ ] Sign in to **1Password CLI** (`op signin`) and enable Settings → Developer → Integrate
      with 1Password CLI.
- [ ] `gh auth login` — normally handled by `run_once_after_01-auth-gh.sh`; re-run if skipped.

## 2. macOS permissions (System Settings → Privacy & Security)

None of these can be granted from a script. Each app must be launched at least once first.

- [ ] **Accessibility**: Hammerspoon, Karabiner-Elements, AltTab, Raycast, Wispr Flow
- [ ] **Input Monitoring**: Karabiner-Elements
- [ ] **Screen Recording**: OBS, AltTab (window previews), Claude
- [ ] **Microphone**: Wispr Flow, Zoom, OBS
- [ ] **Karabiner driver approval**: System Settings → Privacy & Security → *"System software
      from Fumihiko Takayama was blocked"* → Allow. Karabiner silently does nothing until this
      is approved, and the prompt is easy to miss.
- [ ] Confirm login items registered (`run_once_after_99-loginitems.sh` handles this).

## 3. Claude

- [ ] `claude` — log in to Claude Code (CLI). Not scripted.
- [ ] **Claude Desktop**: sign in, then set **quick entry shortcut to `Alt+Space`**.
- [ ] **Claude Desktop → Customize**: skills, connectors, and plugins for the **Chat** and
      **Cowork** tabs sync through your claude.ai account, *not* from `~/.claude`. Nothing in
      this repo can configure them — set them up in-app.
- [ ] **Cowork**: grant trusted folders for any directory you want it working in.
- [ ] Confirm the Code tab picked up local config: theme should be Dracula, prompt should be in
      vim mode. Both come from `~/.claude/settings.json` via `dot_claude/modify_settings.json`.

Personal instructions for Chat/Cowork live in your claude.ai account settings; the CLI/Code
equivalent is `dot_claude/CLAUDE.md`. They are deliberately separate — see `CLAUDE.md`.

## 4. Terminal and editor

- [ ] Launch **Ghostty** once and make it the default terminal.
- [ ] Open **Neovim** and let `lazy.nvim` finish syncing (`run_after_91-update-nvim-lazy.sh`
      does a headless sync, but a first interactive launch surfaces anything that failed).
- [ ] Run `:checkhealth` in Neovim and resolve anything red.
- [ ] Install Mason tooling for the languages you actually use — the LSP/linter/formatter set
      is not installed automatically.

## 5. App sign-ins

- [ ] Dropbox (start sync early — it takes a while)
- [ ] Slack, Notion, Notion Calendar, Todoist, Beeper, Spotify, Zoom
- [ ] Obsidian — open the vault from Dropbox once it has synced
- [ ] **Wispr Flow** — launch and configure; it ships no config until first run, and none of it
      is dotfile-manageable.

## 6. Verify

- [ ] `chezmoi diff` is empty
- [ ] `exec zsh` — prompt, plugins, and `mise` all load without errors
- [ ] `mise ls` shows the expected runtimes (ruby, node)
- [ ] Claude Code statusline renders (needs `jq`, which is in the `Brewfile`)
