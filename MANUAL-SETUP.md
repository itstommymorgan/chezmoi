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
- [ ] **Raycast** — see section 8; it needs more than a sign-in.
- [ ] **Notion Calendar** — sign in, then reconnect each calendar account by hand. It's an
      Electron app (`com.cron.electron`) with no preferences plist and no config file: its
      entire state is the Electron user-data directory, which is session and cache data.
      Nothing here is chezmoi-manageable.
- [ ] **Mimestream** — sign in with Google. Gmail-API based, so labels, filters, and
      search behave as they do in Gmail proper; nothing about it is dotfile-manageable.
- [ ] Obsidian — open the vault from Dropbox once it has synced
- [ ] **Wispr Flow** — launch and configure; it ships no config until first run, and none of it
      is dotfile-manageable.

## 8. Raycast

None of this is chezmoi-manageable: Raycast's state is an encrypted SQLite database with
no CLI, so extensions, AI keys, and settings are re-done by hand on every machine (Pro's
Cloud Sync is the only thing that carries them). The Profile text below is the part worth
copying carefully — it is the whole reason answers come back terse instead of padded.

- [ ] Sign in. **Verify the version is 2.x** — the AI Profile lives in v2 only, and the
      Homebrew cask tracks it (`brew upgrade --cask raycast`).
- [ ] Install extensions: 1Password, Brew, GitHub, Messages, Notion, Spotify, Todoist, Zen.
- [ ] **Enable the AI extension explicitly.** Quick AI ships *disabled* in v2 — it won't
      appear in root search or fire as a fallback until you toggle it on in the AI
      extension's own settings, which looks exactly like AI being broken.
- [ ] Set up AI access. Claude models need either the $8/mo Advanced AI add-on or BYOK;
      BYOK is far cheaper at this usage (roughly 0.1–0.5¢ per question against a prepaid
      Console balance). Paste an Anthropic API key at Settings → AI → API Keys.
      **API credits are billed separately from a Claude subscription** — the subscription
      does not fund them.
- [ ] Set the AI Profile at Settings → AI → Personalization → Profile:

      ```
      Answer in at most 3 sentences of plain prose. No preamble, no headers, no bullet
      lists, no restating the question, no caveats, no offers to elaborate. If the answer
      is a single fact, give just that fact.

      Be direct. Skip flattery and hedging — if something is a bad idea, say so plainly.
      Don't describe what you're about to do; just answer.

      I'm a senior software engineer on macOS (Apple Silicon) — zsh, Neovim, Ghostty,
      Homebrew, mise, git, chezmoi-managed dotfiles. On software and systems questions,
      assume expert fluency and skip the fundamentals. On anything else, treat me as a
      curious generalist and keep the concrete specifics in.
      ```

      The scoping in the last block is deliberate. An unscoped "assume technical fluency
      and skip the basics" gets applied to *every* domain: asked why bacteria develop
      antibiotic resistance, it dropped the concrete mechanisms and returned abstractions.
      Scoping it restored them.
- [ ] Leave **Memory** off (same Personalization screen). It builds a running summary of
      your conversations — useful in general, but it reintroduces exactly the accumulation
      that made Claude's workspace chats feel cluttered. Profile is the deliberate,
      hand-written half; keep that and skip the automatic one.
- [ ] Optionally set Quick AI as a fallback command (Settings → General → Fallback
      Commands) so non-matching input routes to AI, restoring the v1 muscle memory.
      `Cmd+J` promotes a Quick AI answer into a full AI Chat with its history.

**A major-version upgrade does not preserve the API key.** Going 1.x → 2.x dropped the
BYOK key and left every AI surface silently inert. Re-paste it after any big upgrade
before assuming something else broke.

