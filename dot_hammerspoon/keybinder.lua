-- We're gonna go recursive at some point
hs.loadSpoon("RecursiveBinder")
local singleKey = spoon.RecursiveBinder.singleKey

function ext.utils.app_function(appName)
  return function()
    ext.app.forceLaunchOrFocus(appName)
  end
end

function ext.utils.toggle_function(appName)
  return function()
    ext.app.toggleLaunchOrFocus(appName)
  end
end

-- Resolve one entry to the function RecursiveBinder should call. Returns nil for an
-- entry that declares no action, which the callers report rather than bind.
local function entry_function(entry)
  if entry.app ~= nil then
    return ext.utils.app_function(entry.app)
  elseif entry.toggle ~= nil then
    return ext.utils.toggle_function(entry.toggle)
  elseif entry.fun ~= nil then
    return entry.fun
  elseif entry.map ~= nil then
    return ext.utils.build_map(entry.map)
  end
  return nil
end

function ext.utils.build_map(map)
  local binding = {}
  hs.fnutils.each(map, function(entry)
    binding[singleKey(entry.key, entry.comment)] = entry_function(entry)
  end)
  return binding
end

-- given a map of keybindings, bind all of them to <hyper>-key
-- supports switching to apps and also custom functions and recursive bindings.
function ext.utils.keybinder(keybindings)
  ext.utils.keybindings = keybindings
  hs.fnutils.each(keybindings, function(keybinding)
    local binding_fun
    if keybinding.map ~= nil then
      binding_fun = spoon.RecursiveBinder.recursiveBind(ext.utils.build_map(keybinding.map))
    else
      binding_fun = entry_function(keybinding)
    end

    if binding_fun == nil then
      ext.log:w("no valid binding found for key " .. keybinding.key)
    else
      hs.hotkey.bind(ext.hyper, keybinding.key, keybinding.comment, binding_fun)
    end
  end)
end
