# What Does My Hammerspoon Do?

[Hammerspoon](https://www.hammerspoon.org/) is an automation tool for macOS. It
provides APIs and libraries to interact with the operating system in interesting
ways through the Lua scripting language.

Most of what lives here is the stuff nothing else in the stack covers. Raycast
handles launching and search, Karabiner handles key remapping, AltTab handles
window switching — so this config is deliberately the remainder: a global mic mute,
a hold-to-quit guard, a screen dimmer, a hyper-key command tree, and automatic
window placement.

## The hyper key

Every binding here hangs off `ext.hyper` (`cmd+alt+ctrl+shift`), which nothing sane
presses directly. Karabiner supplies it: **`right_command` held emits the full hyper
combo, and `right_command` tapped alone emits `hyper+space`** — which is the MicMute
binding below. That coupling is the load-bearing link between the two configs; see
`dot_config/karabiner/private_karabiner.json`.

## Configuration

Two settings live in `hs.settings` (macOS defaults storage), read at load in
`init.lua`:

| Key | Default | Effect |
| --- | --- | --- |
| `meeting_checks` | `false` | Load `meeting_checks.lua` |
| `always_center_mouse` | `false` | Warp the pointer to the middle of a window after focusing it |

Change one from the Hammerspoon console and reload:

```lua
hs.settings.set("meeting_checks", true)
```

## Spoons and other borrowed code

Spoons are kind of like plugins for Hammerspoon - libraries that can easily be
imported.

### MicMute.spoon

Toggles the system input device's mute state, bound to `hyper+space` — i.e. a tap
of `right_command`. Works regardless of which app has focus, which is the whole
point; Zoom's own mute only applies while Zoom is frontmost.

### RecursiveBinder.spoon

This spoon allows for creating recursive keybindings quickly and easily, and
drives most of my keybinding setup.

### ReloadConfiguration.spoon

This spoon automatically reloads the Hammerspoon configuration when it changes,
which is handy when I'm doing edits.

### Shade.spoon

This spoon creates a transparent "shade" across the screen that artificially
lowers the brightness. Nice when I need to check my computer at night or in any
other dark environment.

### amphetamine.lua

While this isn't a spoon, it is a library that I stole from somewhere on the
internet. This creates a "caffeine" icon in the menubar that allows me to
disable the computer from sleeping.

### slowq.lua

Another borrowed library, this forces `Cmd-Q` to delay for a while before
closing the current application. With `Q` being right next to `W`, I often
accidentally hit `Q` when I really just wanted to close a tab or window - this
saves me from killing the whole application unless I really intend to.

## Customizations

### Meeting watchers

`meeting_checks.lua` pauses Spotify and turns on Do Not Disturb when a call starts,
reversing both when it ends. It also tracks whether a Zoom call is in progress so
`hyper g v` can jump to it.

Two signals, OR'd:

- **Camera in use.** App-agnostic, so it covers Google Meet in Zen, Discord, Slack
  huddles and FaceTime with no per-browser tab scraping. This is what replaced the
  old Chrome/JXA hunt for a `meet.google.com` tab.
- **A Zoom meeting window**, because a camera-off Zoom call never touches the camera.

**OBS inverts the camera signal.** OBS grabs a real camera the moment it launches,
long before any call, so while it's running "a real camera is in use" means nothing.
What does mean something is a *consumer on OBS Virtual Camera* — that only happens
when a meeting app is pulling the OBS feed. So the signal flips: OBS down → watch the
real cameras; OBS up → watch the virtual one. All four states are verified.

The gap: OBS running *and* a call using a webcam directly rather than through OBS.
Zoom is still covered by its window filter; a browser call in that state is missed.

The mic would catch every camera-off call, but Wispr Flow grabs it for dictation, so
it's a false-positive generator and is deliberately unused.

Off by default (`hs.settings` key `meeting_checks`). The Home Assistant side — the
on-air light in the hallway and the desk lamp — used to run over MQTT to
`mosquitto.morgan.house` and is currently a stub in `ext.utils.meetings.notify`,
pending a rewrite against Home Assistant's HTTP API.

### Do Not Disturb

`focus.lua`. macOS 26 offers no supported way to set a Focus mode from a script:
`~/Library/DoNotDisturb/DB` is TCC-protected and `dndmoded` caches over direct
writes anyway, and driving Control Center through the accessibility tree breaks
every release. So this shells out to three hand-made Shortcuts (listed in
`MANUAL-SETUP.md`) via `hs.shortcuts`. Their names are checked at load, and a
missing one is logged rather than silently doing nothing.

### Notifications

`notifications.lua` dismisses everything on screen. It searches the accessibility
tree for elements whose `AXSubrole` is `AXNotificationCenterAlert` or
`AXNotificationCenterAlertStack` and performs their `Clear All` / `Close` action.
The subroles have been stable; the fixed index path that the old AppleScript
version walked was not.

### 'Launch or focus' applications

See `launch_or_focus.lua` for details. While I originally lifted a lot of this
code from someone else, I've adapted it a fair bit to make it work for my
use-cases. Basically this enables me to call an application by name and have it
either focus (if it's currently running) or launch (if it's not). I also support
"toggling" applications in a smart way, this is used in keyboard shortcuts so
that I can use a single keyboard command to switch to an application and then
switch back from it.

### Keybinder

A wrapper around `hs.hotkey.bind` and `RecursiveBinder.spoon` that lets bindings
be declared as data — an entry names a `key`, a `comment`, and one of `app`
(launch or focus), `toggle` (launch, focus, or switch back), `fun` (call this), or
`map` (recurse). The code is in `keybinder.lua`; the bindings themselves are the
big table at the bottom of `init.lua`.

### Windowpaner

`windowpaner.lua` parks each app in `ext.utils.windowpaner_config` on a fixed
screen as its windows appear, and full-screens it if asked. Rebuilt on every
screen-configuration change, and torn down entirely when only one display is
attached. `hs.layout` only applies on demand rather than reacting to new windows,
and `hs.window.layout` is marked experimental upstream, so this stays hand-rolled.

Each rule's `screen` is a **name** pattern (`"dell"`, `"built%-in"`), not an index.
`hs.screen.allScreens()` is ordered by screen geometry, so an index quietly points
somewhere else the moment displays get rearranged in System Settings. An integer
still works as a fallback. A rule naming a screen that isn't attached logs and
leaves the window alone.

### My grid

See `my_grid.lua`. This is again _largely_ stolen, but it sets up a 4x4 window
grid whose halves are bound under `hyper w`. Not a big part of my workflow, but
it's there when I need it.

## Bindings

All prefixed with the hyper key (a held `right_command`).

| Key | Action |
| --- | --- |
| `space` | Toggle microphone mute |
| `m` | Center the mouse on the active window |
| `g b` / `g t` | Zen / Ghostty |
| `g d` / `g m` / `g o` / `g s` / `g u` | Todoist / Mimestream / Obsidian / Slack / Spotify |
| `g i b` / `g i m` | Beeper / Messages |
| `g v` | Jump to the in-progress video call |
| `h c` / `h e` | Hammerspoon console / edit `init.lua` |
| `t c` / `t d` / `t n` / `t s` | Caffeinate / Do Not Disturb / dismiss notifications / Shade |
| `w 1` / `w 2` / `w 3` | Move the focused window to screen N |
| `w h` / `w j` / `w k` / `w l` | Move the focused window to the left / bottom / top / right half |
