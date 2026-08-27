-- Park each configured app's windows on a fixed screen as they appear.
--
-- Be sure to define ext.utils.windowpaner_config in your init file before
-- requiring this file!!
--
-- hs.layout only applies on demand and hs.window.layout is flagged experimental
-- upstream, so this stays hand-rolled.

local filters = {}
local screenWatcher = nil

function ext.utils.clear_windowpaner_filters()
  hs.fnutils.each(filters, function(wf)
    wf:unsubscribeAll()
  end)
  filters = {}
end

-- A name (matched as a lowercased pattern) or, as a fallback, an index into
-- allScreens(). Prefer the name: allScreens() is ordered by screen geometry, so
-- rearranging displays in System Settings silently reassigns every index.
local function resolveScreen(target)
  if type(target) == "number" then
    return hs.screen.allScreens()[target]
  end
  return hs.screen.find(target)
end

function ext.utils.windowpaner_relocate(window, target, fullScreen)
  local screen = resolveScreen(target)
  if not screen then
    ext.log:w("windowpaner: no screen " .. tostring(target) .. ", leaving " .. window:application():name() .. " alone")
    return
  end

  window:moveToScreen(screen, false, true)
  if fullScreen then
    window:setFullScreen(true)
  end
end

function ext.utils.build_windowpaner_filters()
  hs.fnutils.each(ext.utils.windowpaner_config, function(entry)
    local wf = hs.window.filter.new({ entry.app })
    wf:subscribe(hs.window.filter.windowCreated, function(window)
      ext.utils.windowpaner_relocate(window, entry.screen, entry.fullScreen)
    end)
    table.insert(filters, wf)

    -- Catch windows that already existed when this loaded. Unlike the filter above,
    -- allWindows() is unfiltered, and apps carry hidden helper windows (Todoist has a
    -- title-less one) that must not be dragged around or full-screened.
    local app = hs.application.get(entry.app)
    if app then
      hs.fnutils.each(app:allWindows(), function(window)
        if window:isStandard() then
          ext.utils.windowpaner_relocate(window, entry.screen, entry.fullScreen)
        end
      end)
    end
  end)
end

-- On a single screen there is nowhere to move anything, so tear the filters down
-- rather than leave them firing no-ops.
function ext.utils.windowpaner_poll()
  ext.utils.clear_windowpaner_filters()

  if #hs.screen.allScreens() >= 2 then
    ext.utils.build_windowpaner_filters()
  end
end

ext.utils.windowpaner_poll()

-- Retained in ext.watchers because a watcher that only exists as a local is
-- collected out from under you and silently stops firing.
screenWatcher = hs.screen.watcher.new(function()
  ext.utils.windowpaner_poll()
end)
screenWatcher:start()
ext.watchers.screen = screenWatcher
