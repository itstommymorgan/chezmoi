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

## 3. Claude

- [ ] `claude` — log in to Claude Code (CLI). Not scripted.
- [ ] **Claude Desktop**: sign in.
- [ ] **Claude Desktop → Customize**: skills, connectors, and plugins for the **Chat** and
      **Cowork** tabs sync through your claude.ai account, *not* from `~/.claude`. Nothing in
      this repo can configure them — set them up in-app.
- [ ] **Cowork**: grant trusted folders for any directory you want it working in.

Personal instructions for Chat/Cowork live in your claude.ai account settings; the CLI/Code
equivalent is `dot_claude/CLAUDE.md`. They are deliberately separate — see `CLAUDE.md`.

## 4. Keyboard shortcuts

App-level shortcuts, none of them scriptable. Do these in order — the first two collide, and
Todoist grabs the binding by default.

- [ ] **Todoist** → quick entry to **`Ctrl+Option+Space`**. Its default is `Option+Space`,
      which is the binding Claude wants below. Move Todoist first.
- [ ] **Claude Desktop** → quick entry to **`Option+Space`**.
- [ ] **Raycast** → **`Cmd+Space`**. (`run_once_before_99-disable-spotlight-shortcut.sh`
      already frees this from Spotlight.)
- [ ] **AltTab** → **`Cmd+Tab`**.

## 5. Terminal

- [ ] Launch **Ghostty** once and make it the default terminal.
- [ ] Switch the login shell to the Homebrew zsh. Apple's `/bin/zsh` is frozen at 5.9 and
      gets no upstream fixes; the Brewfile already installs the current one. Needs `sudo`
      and a password prompt, which is why it isn't a `run_` script:

      ```sh
      echo "$(brew --prefix)/bin/zsh" | sudo tee -a /etc/shells
      chsh -s "$(brew --prefix)/bin/zsh"
      ```

      Open a new terminal and confirm with `echo $SHELL`.

## 6. Browser (Zen)

The cask installs Zen, but nothing about the profile is chezmoi-managed. Zen names its profile
directory with a random prefix (`Profiles/<random>.Default (release)`), so there is no stable
path to target, and renaming it afterwards breaks the profile — `pkcs11.txt` and
`extensions.json` store the absolute path. Set it up by hand and leave the directory name alone.

- [ ] Launch **Zen** once to create the profile.
- [ ] Sign in to a **Mozilla account** (Settings → Sync). This carries bookmarks, history,
      passwords, extensions, changed prefs, and Zen's own workspaces / Essentials / enabled mods
      — most of what you'd otherwise hand-manage.
- [ ] Set Zen as the default browser: System Settings → Desktop & Dock → Default web browser.
- [ ] Install extensions (sync restores them if this machine has synced before).
- [ ] Only if you want `userChrome.css`: `about:config` →
      `toolkit.legacyUserProfileCustomizations.stylesheets` → `true`. Zen ignores the file
      entirely without it.

## 7. App sign-ins

- [ ] Dropbox (start sync early — it takes a while)
- [ ] Slack, Notion, Notion Calendar, Todoist, Beeper, Spotify, Zoom
- [ ] **Notion Calendar** — sign in, then reconnect each calendar account by hand. It's an
      Electron app (`com.cron.electron`) with no preferences plist and no config file: its
      entire state is the Electron user-data directory, which is session and cache data.
      Nothing here is chezmoi-manageable.
- [ ] Obsidian — open the vault from Dropbox once it has synced
- [ ] **Wispr Flow** — launch and configure; it ships no config until first run, and none of it
      is dotfile-manageable.
