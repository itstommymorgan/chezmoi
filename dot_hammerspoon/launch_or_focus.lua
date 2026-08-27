local originalApp = nil
local toggledApp = nil

function ext.app.centerMouseOnActiveWindow()
  local win = hs.window.focusedWindow()
  if not win then
    return
  end
  hs.mouse.absolutePosition(win:frame().center)
end

-- Given an appName, try to bring focus to it if it's running - if it's not
-- running, then launch it.
function ext.app.forceLaunchOrFocus(appName)
  -- first focus with hammerspoon
  hs.application.launchOrFocus(appName)

  -- clear timer if exists
  if ext.cache.launchTimer then
    ext.cache.launchTimer:stop()
  end

  -- wait 500ms for window to appear and try hard to show the window
  ext.cache.launchTimer = hs.timer.doAfter(0.5, function()
    local frontmostApp = hs.application.frontmostApplication()
    local frontmostWindows = hs.fnutils.filter(frontmostApp:allWindows(), function(win)
      return win:isStandard()
    end)

    -- launchOrFocus is fire-and-forget, so the app may still be starting, or the
    -- user may have moved on. Either way the window recovery below would act on the
    -- wrong app. Case-insensitive because bindings name apps informally.
    if frontmostApp:title():lower() ~= appName:lower() then
      ext.log:i("expected " .. appName .. " in front, got " .. frontmostApp:title())
      return
    end

    if #frontmostWindows == 0 then
      -- check if there's app name in window menu (Calendar, Messages, etc...)
      if frontmostApp:findMenuItem({ "Window", appName }) then
        -- select it, usually moves to space with this window
        frontmostApp:selectMenuItem({ "Window", appName })
      else
        -- otherwise send cmd-n to create new window
        hs.eventtap.keyStroke({ "cmd" }, "n")
      end
    end

    if ext.config.always_center_mouse then
      ext.app.centerMouseOnActiveWindow()
    end
  end)
end

function ext.app.toggleLaunchOrFocus(appName)
  if toggledApp ~= nil and toggledApp ~= appName then
    -- we're toggling a different app, so don't change the original application
    toggledApp = appName
    ext.app.forceLaunchOrFocus(appName)
  else
    if originalApp == nil then
      originalApp = hs.application.frontmostApplication():name()
      ext.app.forceLaunchOrFocus(appName)
      toggledApp = appName
    else
      ext.app.forceLaunchOrFocus(originalApp)
      originalApp = nil
      toggledApp = nil
    end
  end
end

ext.app.appwatcher = hs.application.watcher
  .new(function(appName, event_type, app)
    -- reset the toggled state if the application loses focus for some other
    -- reason than the toggle function
    if event_type == hs.application.watcher.deactivated and appName == toggledApp then
      toggledApp = nil
      originalApp = nil
    end
  end)
  :start()
