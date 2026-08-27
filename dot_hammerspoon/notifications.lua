-- Dismiss every visible notification.
--
-- Matches on AXSubrole rather than walking a fixed index path. The old
-- "button 1 of every window of process Notification Center" AppleScript encoded the
-- Big Sur hierarchy and has broken on most releases since; the subroles below have
-- stayed put, so this survives the layout churn. Also keeps the whole thing inside
-- Hammerspoon's existing Accessibility grant instead of adding an Automation prompt
-- for System Events.

ext.notifications = {}

local ALERT_SUBROLES = { "AXNotificationCenterAlert", "AXNotificationCenterAlertStack" }

-- A stack collapses many notifications behind one element, so clear it wholesale;
-- a lone alert only offers Close. Neither is a standard AX action name.
local CLOSE_ACTIONS = { "Clear All", "Close" }

-- These elements report actions as a record rather than a bare name, e.g.
-- "Name:Close\nTarget:0x0\nSelector:(null)". performAction still wants the whole
-- string, so match on the Name: field and hand back the original.
local function actionLabel(action)
  return action:match("^Name:([^\n]+)") or action
end

-- Dismissing mutates the tree the search just walked, so go one element at a time and
-- re-search after each. Bounded because a notification that refuses to close would
-- otherwise spin forever.
local MAX_PASSES = 50

local function closeAction(element)
  local actions = element:actionNames() or {}
  for _, wanted in ipairs(CLOSE_ACTIONS) do
    for _, action in ipairs(actions) do
      if actionLabel(action) == wanted then
        return action
      end
    end
  end
  return nil
end

local function dismissPass(pass)
  if pass > MAX_PASSES then
    ext.log:w("notifications: gave up after " .. MAX_PASSES .. " passes")
    return
  end

  -- By bundle ID: the process name has moved around across releases.
  local app = hs.application.get("com.apple.notificationcenterui")
  if not app then
    return
  end

  hs.axuielement.applicationElement(app):elementSearch(
    function(_, results)
      local dismissed = false

      for _, element in ipairs(results) do
        local action = closeAction(element)
        if action then
          element:performAction(action)
          dismissed = true
          break
        end
      end

      if dismissed then
        -- Let the dismissal animation retire the element before re-reading the tree.
        hs.timer.doAfter(0.1, function()
          dismissPass(pass + 1)
        end)
      end
    end,
    hs.axuielement.searchCriteriaFunction({
      attribute = "AXSubrole",
      value = ALERT_SUBROLES,
    }),
    { count = 1 }
  )
end

function ext.notifications.dismissAll()
  dismissPass(1)
end
