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

-- window grid
local my_grid = require("my_grid")

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

local function moveToGridPosition(position)
  return function()
    my_grid.moveWindowToPosition(my_grid.screenPositions[position])
  end
end

ext.utils.keybinder({
  {
    key = "g",
    comment = "Go...",
    map = {
      { key = "b", comment = "Browser", app = "Zen" },
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
      { key = "h", comment = "Left", fun = moveToGridPosition("left") },
      { key = "j", comment = "Bottom", fun = moveToGridPosition("bottom") },
      { key = "k", comment = "Top", fun = moveToGridPosition("top") },
      { key = "l", comment = "Right", fun = moveToGridPosition("right") },
    },
  },
})
