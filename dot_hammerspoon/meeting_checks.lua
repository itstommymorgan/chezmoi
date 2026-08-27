-- Detect whether I'm on a call -- video or audio -- and drive the side effects:
-- pause music, turn Do Not Disturb on, and light the on-air lamp via hass.lua.
--
-- Three independent signals, OR'd together:
--
--   camera  -- any real camera reporting in-use. App-agnostic, so it covers Google
--             Meet in Zen, Discord, Slack huddles and FaceTime without any
--             per-browser tab scraping. This is what replaced the old Chrome/JXA
--             hunt for a meet.google.com tab.
--   zoom    -- a Zoom meeting window. Kept because a camera-off Zoom call never
--             touches the camera and would otherwise go undetected.
--   call    -- an audio call in Phone.app (the macOS 26 iPhone bridge) or
--             FaceTime.app. Neither shows a window or changes its title during a
--             call, but "Video > Mute" is only enabled while one is in progress.
--
-- The mic would catch every camera-off call, but Wispr Flow grabs it for dictation,
-- so it is a false-positive generator here and is deliberately not used. The menu
-- check above is why it is not needed: it is mic-independent, and it goes true
-- while the call is still ringing, a couple of seconds before the mic opens.

ext.utils.meetings = {}
ext.utils.meetings.in_zoom_meeting = false

-- OBS grabs a real camera the moment it launches, well before any call, so while it
-- is running "a real camera is in use" means nothing. What does mean something is
-- something *consuming* OBS's virtual camera -- that only happens when a meeting app
-- is pulling the OBS feed. So the signal flips depending on whether OBS is up.
--
-- Verified on this machine: OBS launched with no call put Anker PowerConf C200 in
-- use and left OBS Virtual Camera idle.
--
-- The gap this leaves is OBS running *and* a call using a webcam directly rather
-- than through OBS. Zoom is still covered by the window filter below; a browser
-- call in that state would be missed.
local VIRTUAL_CAMERA_PATTERNS = { "virtual", "obs" }

local signals = { camera = false, zoom = false, call = false }
local active = false

-- Drives the on-air light. See hass.lua: no-ops off the home network, and never
-- raises -- the meeting side effects below must not depend on a light responding.
function ext.utils.meetings.notify(state)
  ext.log:i("meeting state: " .. state)
  ext.hass.notify(state)
end

function ext.utils.meetings.in_meeting()
  ext.utils.meetings.notify("ON")
  if hs.spotify.isRunning() then
    hs.spotify.pause()
  end
  ext.focus.on()
end

function ext.utils.meetings.out_of_meeting()
  ext.utils.meetings.notify("OFF")
  ext.focus.off()
end

-- Only fire on a transition. Any one signal is enough to be on a call, and all of
-- them have to clear before it is over.
local function recompute(reason)
  local nowActive = signals.camera or signals.zoom or signals.call
  if nowActive == active then
    return
  end

  active = nowActive
  ext.log:i(
    ("meeting %s (%s; camera=%s zoom=%s call=%s)"):format(
      active and "started" or "ended",
      reason,
      tostring(signals.camera),
      tostring(signals.zoom),
      tostring(signals.call)
    )
  )

  if active then
    ext.utils.meetings.in_meeting()
  else
    ext.utils.meetings.out_of_meeting()
  end
end

function ext.utils.meetings.jump_to_meeting()
  if ext.utils.meetings.in_zoom_meeting then
    ext.app.forceLaunchOrFocus("zoom.us")
  else
    ext.log:i("video call shortcut called but no call in progress")
  end
end

local function isVirtual(camera)
  local name = (camera:name() or ""):lower()
  return hs.fnutils.some(VIRTUAL_CAMERA_PATTERNS, function(pattern)
    return name:find(pattern, 1, true) ~= nil
  end)
end

local function anyCameraInUse()
  local obsRunning = hs.application.get("OBS") ~= nil

  return hs.fnutils.some(hs.camera.allCameras(), function(camera)
    if isVirtual(camera) then
      return obsRunning and camera:isInUse()
    end
    return not obsRunning and camera:isInUse()
  end)
end

-- Phone.app is the macOS 26 iPhone bridge; FaceTime handles its own calls. Neither
-- opens a window or changes its title for a call, so there is nothing for a
-- windowfilter to match -- but "Video > Mute" is disabled until a call exists.
--
-- Measured on a real bridge call: Phone launched with Mute already enabled while
-- still ringing, the mic followed two seconds later, Mute went false as the call
-- ended and the app quit a second after that.
local CALL_APPS = { "Phone", "FaceTime" }

local function anyCallInProgress()
  return hs.fnutils.some(CALL_APPS, function(name)
    local app = hs.application.get(name)
    if not app then
      return false
    end
    local mute = app:findMenuItem({ "Video", "Mute" })
    return mute ~= nil and mute.enabled
  end)
end

local function anyCallAppRunning()
  return hs.fnutils.some(CALL_APPS, function(name)
    return hs.application.get(name) ~= nil
  end)
end

-- Mute flips within the app's lifetime rather than at launch or quit, and there is
-- no notification for a menu item changing state, so it has to be sampled. Only
-- while one of these apps is up, which outside a call is never -- they launch for
-- the call and quit when it ends.
local callPoll = hs.timer.new(2, function()
  local now = anyCallInProgress()
  if now ~= signals.call then
    signals.call = now
    recompute("call")
  end
end)

local function syncCallPolling()
  if anyCallAppRunning() then
    if not callPoll:running() then
      callPoll:start()
    end
  else
    callPoll:stop()
    if signals.call then
      signals.call = false
      recompute("call app quit")
    end
  end
end

ext.watchers.call_apps = hs.application.watcher
  .new(function(name, event)
    if hs.fnutils.contains(CALL_APPS, name) then
      if event == hs.application.watcher.launched or event == hs.application.watcher.terminated then
        syncCallPolling()
      end
    end
  end)
  :start()

syncCallPolling()

-- Cameras have to be retained or their property watchers are collected and silently
-- stop firing, the same way an unretained hs.screen.watcher does.
-- Every camera, virtual included: with OBS running the virtual camera is the signal,
-- so it needs a watcher of its own.
local function watchCameras()
  ext.watchers.cameras = hs.camera.allCameras()
  hs.fnutils.each(ext.watchers.cameras, function(camera)
    camera:setPropertyWatcherCallback(function()
      signals.camera = anyCameraInUse()
      recompute("camera")
    end)
    camera:startPropertyWatcher()
  end)
end

watchCameras()

-- Continuity Camera and USB webcams come and go; re-arm on every device change so a
-- camera plugged in mid-session is still watched.
hs.camera.setWatcherCallback(function()
  watchCameras()
  signals.camera = anyCameraInUse()
  recompute("camera device change")
end)
hs.camera.startWatcher()

-- Start from a reject-everything filter so only the meeting window matches. The
-- previous `new("Zoom")` also allowed an app named "Zoom", which doesn't exist --
-- Zoom's hs.application:name() is "zoom.us".
local wf_zoom_meeting = hs.window.filter.new(false)
wf_zoom_meeting:setAppFilter("zoom.us", { allowTitles = "Zoom Meeting" })

wf_zoom_meeting:subscribe(hs.window.filter.hasWindow, function()
  ext.utils.meetings.in_zoom_meeting = true
  signals.zoom = true
  recompute("zoom window")
end)

wf_zoom_meeting:subscribe(hs.window.filter.hasNoWindows, function()
  ext.utils.meetings.in_zoom_meeting = false
  signals.zoom = false
  recompute("zoom window")
end)

ext.watchers.zoom_meeting = wf_zoom_meeting

-- Pick up a call that was already running when this loaded.
signals.camera = anyCameraInUse()
recompute("startup")
