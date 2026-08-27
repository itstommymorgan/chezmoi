-- Do Not Disturb control.
--
-- Shortcuts is the only stable route on macOS 26. Writing ~/Library/DoNotDisturb/DB
-- directly needs Full Disk Access and stopped reliably taking effect after Ventura,
-- since dndmoded caches the state it just wrote. Driving Control Center through the
-- accessibility tree rebreaks every release. So: three shortcuts, created by hand once
-- (see MANUAL-SETUP.md), invoked here by name.

ext.focus = {}

ext.focus.shortcuts = {
  on = "Do Not Disturb On",
  off = "Do Not Disturb Off",
  toggle = "Toggle Do Not Disturb",
}

-- hs.shortcuts.run is fire-and-forget: it returns nothing whether the shortcut ran,
-- failed, or does not exist. Checking the name against the library is the only
-- failure signal available, so keep a set of them. hs.shortcuts.list() yields
-- records, not names.
local installed = {}

local function refresh()
  installed = {}
  for _, shortcut in ipairs(hs.shortcuts.list()) do
    installed[shortcut.name] = true
  end
end

local function run(which)
  local name = ext.focus.shortcuts[which]

  -- Refresh before giving up, so a shortcut created since load still works.
  if not installed[name] then
    refresh()
  end

  if not installed[name] then
    ext.log:w("focus: no shortcut named '" .. name .. "' (see MANUAL-SETUP.md)")
    return
  end

  hs.shortcuts.run(name)
end

function ext.focus.on()
  run("on")
end

function ext.focus.off()
  run("off")
end

function ext.focus.toggle()
  run("toggle")
end

refresh()

local missing = {}
for _, name in pairs(ext.focus.shortcuts) do
  if not installed[name] then
    table.insert(missing, name)
  end
end
table.sort(missing)

if #missing > 0 then
  ext.log:w("focus: missing Shortcuts -- " .. table.concat(missing, ", ") .. " (see MANUAL-SETUP.md)")
end
