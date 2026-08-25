# CLAUDE.md

macOS automation via Lua. `README.md` is the maintained source of truth for what each piece does (Spoons vs. custom scripts) — read it rather than inferring from filenames. Highlights: `meeting_checks.lua` detects active Zoom/Meet calls and drives Home Assistant + DnD side effects; `keybinder.lua` wraps `RecursiveBinder.spoon` for all keybinding declarations, which are then invoked from `init.lua`.
