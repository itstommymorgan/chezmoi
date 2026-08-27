-- Home Assistant notifications for the meeting watcher.
--
-- Webhooks rather than the REST API: the automations already exist on the HASS
-- side, and a webhook needs no long-lived token. The IDs are still capability
-- credentials, so they live in 1Password and are rendered into
-- hass_config.lua at apply time rather than committed.
--
-- Everything here is best-effort. A meeting must never fail to start because a
-- light did not turn on.

ext.hass = {}

local config = nil
do
  local ok, loaded = pcall(require, "hass_config")
  if ok then
    config = loaded
  else
    ext.log:w("hass: hass_config.lua missing; HASS notifications disabled")
  end
end

-- These webhooks only exist on the home LAN, so firing them from a coffee shop is
-- at best a hung connection and at worst a POST at whatever else lives on that
-- address. Matching an interface against the HASS host's /24 covers wired and
-- wireless alike; hs.wifi.currentNetwork() would not, since it returns nil on
-- ethernet and needs a Location Services grant on macOS 14+ even on wifi.
local function subnet(address)
  return address:match("^(%d+%.%d+%.%d+)%.%d+$")
end

function ext.hass.atHome()
  if not config then
    return false
  end

  local home = subnet(config.host)
  if not home then
    ext.log:w("hass: host '" .. tostring(config.host) .. "' is not an IPv4 address")
    return false
  end

  return hs.fnutils.some(hs.host.addresses(), function(address)
    return subnet(address) == home
  end)
end

-- state is "ON" or "OFF"; each maps to its own webhook.
function ext.hass.notify(state)
  if not config then
    return
  end

  local id = config.webhooks[state]
  if not id then
    ext.log:w("hass: no webhook configured for state " .. tostring(state))
    return
  end

  if not ext.hass.atHome() then
    ext.log:i("hass: not on the home network, skipping " .. state)
    return
  end

  local url = ("http://%s:%d/api/webhook/%s"):format(config.host, config.port or 8123, id)

  -- The first request after a reload has been observed failing with status -1
  -- while every subsequent one succeeds -- a cold connection, not a rejection.
  -- Losing it silently would leave the on-air light off for a whole call, so
  -- transport failures get one retry. HTTP statuses are answers, not failures to
  -- deliver, so those are reported rather than repeated.
  local function send(attempt)
    hs.http.asyncPost(url, nil, nil, function(status)
      if status <= 0 then
        if attempt == 1 then
          ext.log:i(("hass: %s webhook did not connect, retrying"):format(state))
          hs.timer.doAfter(1, function()
            send(2)
          end)
        else
          ext.log:w(("hass: %s webhook unreachable after retry"):format(state))
        end
      elseif status < 200 or status >= 300 then
        ext.log:w(("hass: %s webhook returned %d"):format(state, status))
      else
        ext.log:i(("hass: %s webhook ok"):format(state))
      end
    end)
  end

  send(1)
end
