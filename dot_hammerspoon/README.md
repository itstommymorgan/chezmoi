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

Three signals, OR'd:

- **Camera in use.** App-agnostic, so it covers Google Meet in Zen, Discord, Slack
  huddles and FaceTime with no per-browser tab scraping. This is what replaced the
  old Chrome/JXA hunt for a `meet.google.com` tab.
- **A Zoom meeting window**, because a camera-off Zoom call never touches the camera.
- **An audio call** in `Phone.app` (the macOS 26 iPhone bridge) or `FaceTime.app`.

Audio calls needed their own signal because they touch no camera and open no window
— during a call neither app shows one or changes its title, so there is nothing for
a windowfilter to match. What does change is that **`Video > Mute` is only enabled
while a call exists**. Measured on a real bridge call: Phone launched with Mute
already enabled while still ringing, the mic followed two seconds later, Mute went
false as the call ended and the app quit a second after that.

That check is deliberately mic-independent. The mic would catch every audio call,
but Wispr Flow holds it for dictation — and since dictating into Slack is normal and
Slack is always open, "mic plus a call app is running" would false-positive
constantly. The menu state has no such problem, and it goes true *before* the mic.

Sampling is needed because Mute flips inside the app's lifetime rather than at
launch or quit, and no notification exists for a menu item changing state. The poll
only runs while one of those apps is up, which outside a call is never — they launch
for the call and quit when it ends.

**OBS inverts the camera signal.** OBS grabs a real camera the moment it launches,
long before any call, so while it's running "a real camera is in use" means nothing.
What does mean something is a *consumer on OBS Virtual Camera* — that only happens
when a meeting app is pulling the OBS feed. So the signal flips: OBS down → watch the
real cameras; OBS up → watch the virtual one. All four states are verified.

The gap: OBS running *and* a call using a webcam directly rather than through OBS.
Zoom is still covered by its window filter; a browser call in that state is missed.

The mic would catch every camera-off call, but Wispr Flow grabs it for dictation, so
it's a false-positive generator and is deliberately unused.

Controlled by the `hs.settings` key `meeting_checks`.

### Home Assistant

`hass.lua` fires the on-air light through two Home Assistant webhooks, one for on
and one for off. Webhooks rather than the REST API because the automations already
exist on the HASS side and a webhook needs no long-lived token. It replaces the old
MQTT path to `mosquitto.morgan.house`.

The webhook IDs are capability credentials — anyone holding one can fire the
automation — so they live in 1Password and are rendered into
`~/.hammerspoon/hass_config.lua` (mode 0600) at apply time by
`private_hass_config.lua.tmpl`. Nothing secret enters the repo. The host is a LAN
address, meaningless elsewhere, so it stays readable in the template.

**It only fires at home.** The webhooks exist on one LAN, so `atHome()` requires a
local interface on the same `/24` as the HASS host. That covers wired and wireless
alike — `hs.wifi.currentNetwork()` would not, since it returns nil on ethernet and
needs a Location Services grant on macOS 14+ even on wifi.

Everything is best-effort: a missing config, a foreign network, a non-IPv4 host or
an HTTP failure all log and return. A meeting never fails to start because a light
did not. The first request after a reload has been seen failing with status -1 on a
cold connection, so transport failures get one retry — losing that silently would
leave the light off for an entire call. HTTP statuses are answers rather than
delivery failures, so those are reported, not repeated.

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

### Window management

`WindowHalfsAndThirds.spoon`, replacing the old hand-rolled `my_grid.lua` which did
halves and quarters only and had no undo. Bound under `hyper w`: `h/j/k/l` for halves,
`w t` for the thirds submap, plus center, full-screen toggle and undo.

Its methods must be **dot**-called, not colon-called — the halves and thirds are
`hs.fnutils.partial` bindings over `resizeCurrentWindow(how, use_frame_correctness)`,
and `undo`/`center`/`toggleMaximized` take a window, so a colon call quietly passes
the spoon table into that first argument instead of erroring.

`init.lua` also sets `hs.window.animationDuration = 0` explicitly. `my_grid` used to
do that as a side effect of being required; without it every window move animates,
windowpaner's included.

### Screenshots

`hyper s` runs `screencapture -i -c`: crosshair, drag, image on the clipboard. Same
thing `Cmd+Ctrl+Shift+4` does natively — bound here so it lives with the rest of the
hyper key rather than being a separate thing to remember. (The resizable box people
end up fighting is `Cmd+Shift+5`/Screenshot.app, a different mechanism.)

It needs no Screen Recording grant: interactive capture is done by the system's own
selection UI, so Hammerspoon's existing permissions suffice. Only the programmatic
forms (`-R` and friends) require it, and they fail with "could not create image from
rect" without it.

Run via `hs.task`, not `hs.execute` — `screencapture -i` doesn't return until the
selection finishes, which would freeze Hammerspoon's runloop while the crosshair is up.

Two `com.apple.screencapture` defaults matter here and are set by
`.chezmoiscripts/before/run_once_before_98-screenshot-defaults.sh`: `target` is
`clipboard`, and `show-thumbnail` is **off**. That second one is what makes stock
macOS screenshots feel broken — the floating thumbnail holds the capture for ~5
seconds, so pasting immediately after a screenshot gets nothing.

### URL routing

`url_routing.lua` makes Hammerspoon the system `http`/`https` handler and dispatches
by pattern via `URLDispatcher.spoon`: Zoom, Spotify, Notion and Todoist go to their
apps, everything else to Zen. Zoom is the one that earns its keep — `zoom.us/j/`
links exist only to bounce you through a browser page into the app.

Two things guard against hijacking a URL that only *mentions* a routed app.
URLDispatcher matches patterns against the whole URL, so a bare `notion%.so` also
matches an OAuth `redirect_uri` pointing at Notion — which broke logging into Notion
Calendar, sending the Google sign-in page to the Notion app. Patterns are therefore
anchored at the scheme so they can only match the authority section, in two variants
per domain (the domain itself, and any subdomain — the literal dot in the subdomain
form is what stops `fakenotion.so` matching). Separately, a first rule sends anything
that looks like a sign-in flow to the browser, since handing one to an app drops the
session mid-establishment. That rule is deliberately loose: a false positive only
means "opened in the browser", which is the default anyway.

Tracking parameters (`utm_*`, `fbclid`, `gclid`, …) are stripped before dispatch, so
a URL copied from the address bar afterwards is already clean. Slack's
`slack-redir.net` wrapping is undone by the spoon itself.

Owning the default browser is less fragile than it sounds: `setRestoreHandler` hands
`http` back to Zen whenever Hammerspoon exits *or reloads its config*, so a config
that fails to load leaves links opening in Zen rather than disappearing.

Routing into a specific Zen **workspace** is not wired up. Zen has no scheme or flag
for workspaces and external links land in the last-active one; the only documented
path is via containers, and whether `ext+container:` resolves when the OS hands it to
Zen is untested. `ext.urls.openInZenContainer` is there for when it's tried — see
`MANUAL-SETUP.md`.

## Bindings

All prefixed with the hyper key (a held `right_command`).

| Key | Action |
| --- | --- |
| `space` | Toggle microphone mute |
| `m` | Center the mouse on the active window |
| `s` | Screenshot: crosshair, drag, straight to the clipboard |
| `g b` / `g t` | Zen / Ghostty |
| `g c` / `g d` / `g m` / `g o` / `g s` / `g u` | Notion Calendar / Todoist / Mimestream / Obsidian / Slack / Spotify |
| `g i b` / `g i m` | Beeper / Messages |
| `g v` | Jump to the in-progress video call |
| `h c` / `h e` | Hammerspoon console / edit `init.lua` |
| `t c` / `t d` / `t n` / `t s` | Caffeinate / Do Not Disturb / dismiss notifications / Shade |
| `w 1` / `w 2` / `w 3` | Move the focused window to screen N |
| `w h` / `w j` / `w k` / `w l` | Focused window to the left / bottom / top / right half |
| `w t` then `h/j/k/l` | …to the left / bottom / top / right third |
| `w c` / `w f` / `w u` | Center / full-screen toggle / undo the last resize |
