-- extensions, available in hammerspoon console
ext = {
  frame = {},
  win = {},
  app = {},
  utils = {},
  cache = {},
  log = hs.logger.new("myconfig", "info"),
  -- Karabiner maps right_command to this combo when held, and to hyper+space
  -- (the MicMute binding below) when tapped alone.
  hyper = { "cmd", "alt", "ctrl", "shift" },
  watchers = {},
}

-- hs.settings is macOS defaults storage, so it needs no file to exist up front and
-- no tilde expansion. Change these from the Hammerspoon console with
-- hs.settings.set("meeting_checks", true), then reload.
local defaults = {
  meeting_checks = false,
  always_center_mouse = false,
}

ext.config = {}
for key, fallback in pairs(defaults) do
  local stored = hs.settings.get(key)
  if stored == nil then
    stored = fallback
  end
  ext.config[key] = stored
end

-- The `hs` command line tool talks to Hammerspoon over a Mach port that only
-- exists while this module is loaded, so requiring it here is what makes
-- `hs -c '...'` work from a shell.
require("hs.ipc")

-- The tool itself is a symlink into the app bundle rather than anything Homebrew
-- installs, so it has to be created per machine. cliStatus makes this a no-op
-- after the first run, which keeps a new Mac from needing a manual step.
local brewPrefix = hs.fs.attributes("/opt/homebrew/bin") and "/opt/homebrew" or "/usr/local"
if not hs.ipc.cliStatus(brewPrefix, true) then
  if hs.ipc.cliInstall(brewPrefix, true) then
    ext.log:i("installed the hs command line tool into " .. brewPrefix)
  else
    ext.log:w("could not install the hs command line tool into " .. brewPrefix .. "/bin")
  end
end

-- Generates lua_ls annotations for the whole hs API and every installed Spoon, into
-- Spoons/EmmyLua.spoon/annotations. Only rewrites them when the docs are newer.
--
-- Must load *before* ReloadConfiguration: that spoon pathwatches all of
-- hs.configdir and calls hs.reload on any change whatsoever, so ~140 annotation
-- files appearing underneath it would reload in a loop. Generation happens during
-- init, so getting in first is what keeps that from firing.
hs.loadSpoon("EmmyLua")

-- Reload config automatically
hs.loadSpoon("ReloadConfiguration"):start()

-- toggle microphone mute
hs.loadSpoon("MicMute"):bindHotkeys({ toggle = { ext.hyper, "space" } })

-- caffeinate
require("amphetamine")

-- force *hold* of Cmd-Q to close apps
require("slowq")

-- Use a "Shade" to toggle screen brightness
hs.loadSpoon("Shade")

-- my custom function for launching/focusing a specific app
require("launch_or_focus")

-- Do Not Disturb, via the Shortcuts in MANUAL-SETUP.md
require("focus")

-- dismiss notifications through the accessibility tree
require("notifications")

-- Home Assistant webhooks for the meeting watcher
require("hass")

-- Route URLs to apps rather than always to the browser
require("url_routing")

-- Window halves, thirds, corners, center and undo. Replaces the old my_grid.lua,
-- which only did halves and quarters and had no undo.
hs.loadSpoon("WindowHalfsAndThirds")

-- my_grid used to set this globally as a side effect of being required. Window
-- moves -- including windowpaner's -- animate without it.
hs.window.animationDuration = 0

if ext.config.meeting_checks then
  require("meeting_checks")
end

-- screen is a name pattern (see windowpaner.lua); an integer index still works but
-- shifts around when displays are rearranged.
local LAPTOP = "built%-in"
local DESK = "dell"

ext.utils.windowpaner_config = {
  { app = "Mimestream", screen = LAPTOP, fullScreen = true },
  { app = "Obsidian", screen = DESK, fullScreen = false },
  { app = "Slack", screen = LAPTOP, fullScreen = true },
  { app = "Spotify", screen = LAPTOP, fullScreen = true },
  { app = "Todoist", screen = LAPTOP, fullScreen = true },
}
require("windowpaner")

require("keybinder")

local function moveToScreen(index)
  return function()
    local screen = hs.screen.allScreens()[index]
    local win = hs.window.focusedWindow()
    if screen and win then
      win:moveToScreen(screen, false, true)
    end
  end
end

-- Dot-called, not colon: these are hs.fnutils.partial bindings over
-- resizeCurrentWindow(how, use_frame_correctness), and undo/center/toggleMaximized
-- take a window. A colon call would pass the spoon table into that first argument.
local function windowAction(method)
  return function()
    spoon.WindowHalfsAndThirds[method]()
  end
end

ext.utils.keybinder({
  {
    key = "g",
    comment = "Go...",
    map = {
      { key = "b", comment = "Browser", app = "Zen" },
      { key = "c", comment = "Calendar", app = "Notion Calendar" },
      { key = "d", comment = "ToDoist", app = "Todoist" },
      {
        key = "i",
        comment = "IM-ish",
        map = {
          { key = "b", comment = "Beeper", toggle = "Beeper Desktop" },
          { key = "m", comment = "Messages", toggle = "Messages" },
        },
      },
      { key = "m", comment = "Mail", app = "Mimestream" },
      { key = "o", comment = "Obsidian", toggle = "Obsidian" },
      { key = "s", comment = "Slack", app = "Slack" },
      { key = "u", comment = "mUsic", toggle = "Spotify" },
      { key = "t", comment = "Terminal", app = "Ghostty" },
      {
        key = "v",
        comment = "Video call",
        fun = function()
          if ext.utils.meetings then
            ext.utils.meetings.jump_to_meeting()
          else
            ext.log:i("video call shortcut called but meeting_checks is disabled")
          end
        end,
      },
    },
  },
  {
    key = "h",
    comment = "Hammerspoon",
    map = {
      {
        key = "c",
        comment = "Console",
        fun = function()
          hs.toggleConsole()
        end,
      },
      {
        key = "e",
        comment = "Edit config",
        fun = function()
          hs.open(hs.configdir .. "/init.lua")
        end,
      },
    },
  },
  { key = "m", comment = "Center Mouse", fun = ext.app.centerMouseOnActiveWindow },
  {
    key = "t",
    comment = "Toggle...",
    map = {
      {
        key = "c",
        comment = "Caffeinate",
        fun = function()
          caffeineClicked()
        end,
      },
      { key = "d", comment = "Do Not Disturb", fun = ext.focus.toggle },
      { key = "n", comment = "close Notifications", fun = ext.notifications.dismissAll },
      {
        key = "s",
        comment = "Shade",
        fun = function()
          spoon.Shade:toggleShade()
        end,
      },
    },
  },
  {
    key = "w",
    comment = "Window...",
    map = {
      { key = "1", comment = "Move to Screen 1", fun = moveToScreen(1) },
      { key = "2", comment = "Move to Screen 2", fun = moveToScreen(2) },
      { key = "3", comment = "Move to Screen 3", fun = moveToScreen(3) },
      { key = "h", comment = "Left half", fun = windowAction("leftHalf") },
      { key = "j", comment = "Bottom half", fun = windowAction("bottomHalf") },
      { key = "k", comment = "Top half", fun = windowAction("topHalf") },
      { key = "l", comment = "Right half", fun = windowAction("rightHalf") },
      {
        key = "t",
        comment = "Thirds...",
        map = {
          { key = "h", comment = "Left third", fun = windowAction("leftThird") },
          { key = "j", comment = "Bottom third", fun = windowAction("bottomThird") },
          { key = "k", comment = "Top third", fun = windowAction("topThird") },
          { key = "l", comment = "Right third", fun = windowAction("rightThird") },
        },
      },
      { key = "c", comment = "Center", fun = windowAction("center") },
      { key = "f", comment = "Full screen", fun = windowAction("toggleMaximized") },
      { key = "u", comment = "Undo", fun = windowAction("undo") },
    },
  },
})
