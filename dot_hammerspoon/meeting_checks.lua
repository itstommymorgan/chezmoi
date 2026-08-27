-- Detect whether I'm in a video call and drive the side effects: pause music, turn
-- Do Not Disturb on, and (once the Home Assistant hook below is wired back up) the
-- on-air light and desk lamp.
--
-- Two independent signals, OR'd together:
--
--   camera  -- any real camera reporting in-use. App-agnostic, so it covers Google
--             Meet in Zen, Discord, Slack huddles and FaceTime without any
--             per-browser tab scraping. This is what replaced the old Chrome/JXA
--             hunt for a meet.google.com tab.
--   zoom    -- a Zoom meeting window. Kept because a camera-off Zoom call never
--             touches the camera and would otherwise go undetected.
--
-- The mic would catch every camera-off call, but Wispr Flow grabs it for dictation,
-- so it is a false-positive generator here and is deliberately not used.

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

local signals = { camera = false, zoom = false }
local active = false

-- Placeholder. The old implementation shelled out to mosquitto_pub against
-- mosquitto.morgan.house; replace with an HTTP call to Home Assistant.
function ext.utils.meetings.notify(state)
  ext.log:i("meeting state: " .. state)
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

-- Only fire on a transition. Either signal alone is enough to be in a call, and both
-- have to clear before it is over.
local function recompute(reason)
  local nowActive = signals.camera or signals.zoom
  if nowActive == active then
    return
  end

  active = nowActive
  ext.log:i(
    ("meeting %s (%s; camera=%s zoom=%s)"):format(
      active and "started" or "ended",
      reason,
      tostring(signals.camera),
      tostring(signals.zoom)
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
