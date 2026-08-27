-- Route URLs to apps instead of always landing in the browser.
--
-- Hammerspoon registers as the system http/https handler and URLDispatcher matches
-- each URL against the patterns below, falling back to Zen. Patterns are Lua
-- patterns, not regexes, so dots need escaping.
--
-- The failure mode is contained: hs.urlevent.setRestoreHandler puts Zen back as the
-- default handler whenever Hammerspoon exits *or reloads its config*. So a config
-- error means URLDispatcher never re-claims the handler and links keep opening in
-- Zen, rather than vanishing into a Hammerspoon that failed to load.

ext.urls = {}

hs.loadSpoon("URLDispatcher")

local BROWSER = "app.zen-browser.zen"

-- Query parameters that exist only to track. Stripped before dispatch, so anything
-- copied out of the address bar afterwards is already clean.
local TRACKING_PARAMS = {
  "utm_[%w_]+",
  "fbclid",
  "gclid",
  "dclid",
  "msclkid",
  "igshid",
  "ttclid",
  "mc_[ce]id",
  "_hs[%w_]*",
  "vero_[%w_]+",
}

local function stripTracking(_, _, _, url)
  local cleaned = url

  for _, param in ipairs(TRACKING_PARAMS) do
    -- Keep the leading "?" when it is the first parameter being removed, otherwise
    -- the next parameter along loses its separator entirely.
    cleaned = cleaned:gsub("[?&]" .. param .. "=[^&#]*", function(match)
      return match:sub(1, 1) == "?" and "?" or ""
    end)
  end

  -- Tidy what removal leaves behind: "?&foo" -> "?foo", and a "?" with nothing
  -- after it, whether at the end or in front of a fragment.
  cleaned = cleaned:gsub("%?&", "?"):gsub("%?#", "#"):gsub("[?&]$", "")
  return cleaned
end

spoon.URLDispatcher.default_handler = BROWSER

-- Slack wraps outbound links in slack-redir.net; the spoon unwraps those itself via
-- decode_slack_redir_urls, which defaults to true.
spoon.URLDispatcher.url_redir_decoders = {
  { "strip tracking params", stripTracking, nil, true },
}

spoon.URLDispatcher.url_patterns = {
  -- Zoom's web links exist only to bounce you into the app through an interstitial.
  { { "zoom%.us/j/", "zoom%.us/s/", "zoom%.us/my/", "zoom%.us/w/" }, "us.zoom.xos" },
  { "open%.spotify%.com", "com.spotify.client" },
  { "notion%.so", "notion.id" },
  { "todoist%.com", "com.todoist.mac.Todoist" },
}

-- Put Zen back when Hammerspoon exits or reloads. This is the safety net described
-- at the top -- register it before claiming the handler.
hs.urlevent.setRestoreHandler("http", BROWSER)

spoon.URLDispatcher:start()

--- Open a URL in a named Firefox container, which is the only lever that reaches a
--- Zen workspace from outside the browser.
---
--- UNVERIFIED -- nothing below is wired to a rule yet. Zen exposes no URL scheme or
--- command-line flag for workspaces, and external links currently land in whichever
--- workspace was last active (zen-browser/desktop#6515). The documented path is
--- indirect: a workspace can be bound to a container, and Zen has a setting,
--- "Switch to workspace where container is set as default when opening container
--- tabs", which makes opening a container tab pull its workspace forward.
---
--- Reaching a container from outside needs the Multi-Account Containers extension,
--- which registers the ext+container: scheme. Whether that scheme resolves when
--- handed to Zen by the OS rather than typed inside it is the untested part.
---
--- To try it: install the extension, bind a container to a workspace, enable that
--- setting, then add a rule such as
---   { "github%.com", function(url) ext.urls.openInZenContainer("Work", url) end },
function ext.urls.openInZenContainer(container, url)
  local target = ("ext+container:name=%s&url=%s"):format(hs.http.encodeForQuery(container), hs.http.encodeForQuery(url))
  hs.urlevent.openURLWithBundle(target, BROWSER)
end
