# CLAUDE.md

Karabiner-Elements complex modifications config. `private_karabiner.json` (the `private_` prefix means chezmoi writes it with `0600` permissions) is the managed config, applied to `~/.config/karabiner/karabiner.json`. `automatic_backups/` is excluded via `.chezmoiignore` since it's local runtime state, not source-controlled config.

`description` belongs on the *rule*, not on the manipulator inside it. Karabiner reads it from the rule level for its Complex Modifications list; one nested a level too deep shows up as a blank entry in the UI and reads as an undocumented rule here.

**The `right_command` rule is shared with Hammerspoon.** Held, it emits `cmd+ctrl+opt+shift` — the `ext.hyper` that every binding in `dot_hammerspoon/init.lua` hangs off. Tapped alone, it emits `hyper+space`, which is MicMute.spoon's toggle. Changing either side silently breaks the other.

The `caps_lock` rule (control held, escape alone) is why `ControlEscape.spoon` was deleted from the Hammerspoon config — both implemented the same behavior at different timeouts, and Hammerspoon saw the bare `left_control` this rule emits before its `to_if_alone` resolved, so a caps tap fired escape twice.
