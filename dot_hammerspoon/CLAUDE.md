# CLAUDE.md

macOS automation via Lua. `README.md` is the maintained source of truth for what each piece does (Spoons vs. custom scripts) — read it rather than inferring from filenames.

Two things that aren't guessable from the files:

- **The hyper key comes from Karabiner.** Every binding hangs off `ext.hyper` (`cmd+alt+ctrl+shift`); `dot_config/karabiner/private_karabiner.json` maps `right_command` to that combo when held and to `hyper+space` — the MicMute binding — when tapped alone. Changing either side breaks the other, and neither file's tests will tell you.
- **Scope is deliberately the remainder.** Raycast covers launching and search, Karabiner covers remapping, AltTab covers window switching. Before adding something here, check it isn't already one of those. Conversely `ControlEscape.spoon` was removed precisely because Karabiner's `caps_lock` rule had taken it over and the two double-fired escape.

Highlights: `keybinder.lua` wraps `RecursiveBinder.spoon` for all keybinding declarations, which are then invoked from `init.lua`; `meeting_checks.lua` detects an active Zoom call and drives Spotify + DnD side effects (Home Assistant is stubbed, pending an HTTP rewrite); `focus.lua` drives Do Not Disturb through hand-made Shortcuts because macOS 26 exposes no scriptable path.

Settings live in `hs.settings`, not a config file — `hs.settings.set("meeting_checks", true)` then reload.

`hs -c '...'` drives the running Hammerspoon from a shell -- far easier than the alternative, which is temporarily enabling `hs.allowAppleScript`. **Close stdin (`hs -c '...' </dev/null`)** or it waits on it and appears to hang. `init.lua` both requires `hs.ipc` (the Mach port the CLI talks to) and re-creates the CLI symlink when missing, so a new machine needs no manual step.

`EmmyLua.spoon` generates lua_ls annotations for the whole `hs` API into `Spoons/EmmyLua.spoon/annotations`, wired up via `workspace.library` in `.luarc.json`. Two things about it: it **must** load before `ReloadConfiguration`, which pathwatches all of `hs.configdir` and reloads on any change -- 146 annotation files landing after that starts is a reload loop. And there are two `.luarc.json` copies to keep in sync: the `dot_` one applied to `~/.hammerspoon`, and a literal `.luarc.json` that lua_ls uses when editing the source here. lua_ls does expand `~` in library paths (verified), so both can share one portable path. `diagnostics.globals` stays as a fallback for a fresh machine, where the annotations do not exist until Hammerspoon has run once.

`stylua` stops its config search at the git root, so `~/.stylua.toml` is invisible from inside this repo and stylua silently falls back to tabs. Format with `--config-path ~/.stylua.toml` to match what the applied files in `~/.hammerspoon` get.
