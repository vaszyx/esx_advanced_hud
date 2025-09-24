local Config = Config or {}
local ESX = exports['es_extended']:getSharedObject()

local HUD = {
  visible    = true,
  cinematic  = false,
  uiReady    = false,
  last       = {},
  seatbelt   = false,
  inVeh      = false
}

local function sendUI(data)
  if not data then return end
  SendNUIMessage(data)
end

local function changed(key, val)
  if HUD.last[key] ~= val then
    HUD.last[key] = val
    return true
  end
  return false
end

local function applyVisibility()
  local isVisible = HUD.visible and not (Config.HideWhenPaused and IsPauseMenuActive())
  local opacity = HUD.cinematic and Config.CinematicOpacity or Config.BaseOpacity
  local payload = { action = 'visibility', visible = isVisible }

  local opacityChanged = changed('hudOpacity', opacity)
  if opacityChanged then
    payload.opacity = opacity
  end

  if changed('hudVisibility', isVisible) or opacityChanged then
    sendUI(payload)
  end
end

RegisterNUICallback('ready', function(_, cb)
  HUD.uiReady = true
  cb(1)
  applyVisibility()
  SetNuiFocus(false, false)
end)

RegisterNUICallback('closeSettings', function(_, cb)
  SetNuiFocus(false, false)
  cb(1)
end)

-- Commands
if Config.Commands and Config.Commands.toggle then
  RegisterCommand(Config.Commands.toggle, function()
    HUD.visible = not HUD.visible
    applyVisibility()
  end)
end

if Config.Commands and Config.Commands.cinematic then
  RegisterCommand(Config.Commands.cinematic, function()
    HUD.cinematic = not HUD.cinematic
    sendUI({ action = 'opacity', opacity = HUD.cinematic and Config.CinematicOpacity or Config.BaseOpacity })
    applyVisibility()
  end)
end

if Config.Commands and Config.Commands.settings then
  RegisterCommand(Config.Commands.settings, function()
    sendUI({ action = 'openSettings' })
    SetNuiFocus(true, true)
  end)
end

for _, mapping in ipairs(Config.KeyMappings or {}) do
  if mapping.command then
    RegisterKeyMapping(mapping.command, mapping.label or '', 'keyboard', mapping.defaultKey or '')
  end
end

-- Exports
exports('SetSeatbelt', function(state)
  HUD.seatbelt = state and true or false
  sendUI({ action = 'seatbelt', state = HUD.seatbelt })
end)

local function updateSafeZone()
  if not Config.SafeZoneAware then return end
  local safeZone = GetSafeZoneSize()
  sendUI({ action = 'safezone', size = safeZone })
end

CreateThread(function()
  Wait(500)
  updateSafeZone()
end)

AddEventHandler('onResourceStart', function(resourceName)
  if resourceName ~= GetCurrentResourceName() then return end
  Wait(500)
  updateSafeZone()
end)

-- FAST tick
CreateThread(function()
  while true do
    local sleep = Config.Ticks.fast or 150
    if HUD.uiReady and HUD.visible and not (Config.HideWhenPaused and IsPauseMenuActive()) then
      local ped = PlayerPedId()
      local veh = GetVehiclePedIsIn(ped, false)
      local inVeh = veh ~= 0

      if changed('inVeh', inVeh) then
        HUD.inVeh = inVeh
        sendUI({ action = 'vehicleMode', state = inVeh })
      end

      if Config.UsePmaVoice then
        if exports['pma-voice'] then
          local talking = exports['pma-voice']:getTalkingState()
          if changed('talking', talking) then
            sendUI({ action = 'voiceTalking', talking = talking })
          end

          local mode = exports['pma-voice']:getVoiceRange()
          if mode and changed('voiceMode', mode) then
            sendUI({ action = 'voiceMode', mode = mode })
          end
        end
      end

      if inVeh then
        local speed = GetEntitySpeed(veh) * (Config.UseKmh and 3.6 or 2.236936)
        local rpm   = GetVehicleCurrentRpm(veh)
        local gear  = GetVehicleCurrentGear(veh) or 0
        local fuel  = GetVehicleFuelLevel(veh) or 100.0

        speed = math.floor(speed + 0.5)
        local rpmPct = math.floor((rpm or 0) * 100 + 0.5)

        sendUI({
          action = 'veh',
          speed  = speed,
          unit   = Config.UseKmh and 'KMH' or 'MPH',
          rpm    = rpmPct,
          gear   = gear,
          fuel   = math.floor(fuel)
        })
      end
    end
    Wait(sleep)
  end
end)

-- MED tick
CreateThread(function()
  while true do
    local sleep = Config.Ticks.med or 400
    if HUD.uiReady and HUD.visible and not (Config.HideWhenPaused and IsPauseMenuActive()) then
      local ped = PlayerPedId()
      local hp = GetEntityHealth(ped) - 100
      if hp < 0 then hp = 0 end
      local armor = GetPedArmour(ped)

      sendUI({
        action  = 'stats',
        hp      = hp,
        armor   = armor,
        seatbelt = HUD.seatbelt
      })
    end
    Wait(sleep)
  end
end)

-- SLOW tick
local function headingToCardinal(heading)
  local dirs = { 'N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW', 'N' }
  return dirs[math.floor((heading % 360) / 45) + 1]
end

CreateThread(function()
  while true do
    local sleep = Config.Ticks.slow or 1000
    if HUD.uiReady and HUD.visible and not (Config.HideWhenPaused and IsPauseMenuActive()) then
      if Config.ShowClock then
        local hour = GetClockHours()
        local minute = GetClockMinutes()
        sendUI({ action = 'clock', time = string.format('%02d:%02d', hour, minute) })
      end

      if Config.ShowStreet then
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local s1, s2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
        local street = GetStreetNameFromHashKey(s1)
        local zone = GetNameOfZone(coords.x, coords.y, coords.z)
        local direction = headingToCardinal(GetEntityHeading(ped))
        sendUI({ action = 'street', street = street, zone = zone, dir = direction })
      end
    end
    Wait(sleep)
  end
end)

if Config.UseESXStatus then
  CreateThread(function()
    while true do
      TriggerEvent('esx_status:getStatus', 'hunger', function(status)
        local hunger = status and status.val or 1000000
        TriggerEvent('esx_status:getStatus', 'thirst', function(status2)
          local thirst = status2 and status2.val or 1000000
          if Config.CustomStressStatus then
            TriggerEvent('esx_status:getStatus', Config.CustomStressStatus, function(status3)
              local stress = status3 and status3.val or 0
              sendUI({
                action = 'needs',
                hunger = math.floor(hunger / 10000),
                thirst = math.floor(thirst / 10000),
                stress = math.floor(stress / 10000)
              })
            end)
          else
            sendUI({
              action = 'needs',
              hunger = math.floor(hunger / 10000),
              thirst = math.floor(thirst / 10000)
            })
          end
        end)
      end)
      Wait(1000)
    end
  end)
end

-- Pause handling
CreateThread(function()
  while true do
    if HUD.uiReady then
      applyVisibility()
    end
    Wait(400)
  end
end)

