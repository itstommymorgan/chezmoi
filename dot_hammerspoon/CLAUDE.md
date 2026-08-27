# CLAUDE.md

macOS automation via Lua. `README.md` is the maintained source of truth for what each piece does (Spoons vs. custom scripts) — read it rather than inferring from filenames.

Two things that aren't guessable from the files:

- **The hyper key comes from Karabiner.** Every binding hangs off `ext.hyper` (`cmd+alt+ctrl+shift`); `dot_config/karabiner/private_karabiner.json` maps `right_command` to that combo when held and to `hyper+space` — the MicMute binding — when tapped alone. Changing either side breaks the other, and neither file's tests will tell you.
- **Scope is deliberately the remainder.** Raycast covers launching and search, Karabiner covers remapping, AltTab covers window switching. Before adding something here, check it isn't already one of those. Conversely `ControlEscape.spoon` was removed precisely because Karabiner's `caps_lock` rule had taken it over and the two double-fired escape.

Highlights: `keybinder.lua` wraps `RecursiveBinder.spoon` for all keybinding declarations, which are then invoked from `init.lua`; `meeting_checks.lua` detects an active Zoom call and drives Spotify + DnD side effects (Home Assistant is stubbed, pending an HTTP rewrite); `focus.lua` drives Do Not Disturb through hand-made Shortcuts because macOS 26 exposes no scriptable path.

Settings live in `hs.settings`, not a config file — `hs.settings.set("meeting_checks", true)` then reload.

`stylua` stops its config search at the git root, so `~/.stylua.toml` is invisible from inside this repo and stylua silently falls back to tabs. Format with `--config-path ~/.stylua.toml` to match what the applied files in `~/.hammerspoon` get.
