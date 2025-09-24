Config = {}

-- General display behaviour
Config.HideWhenPaused = true
Config.SafeZoneAware  = true
Config.UseKmh         = true
Config.ShowStreet     = true
Config.ShowClock      = true

-- Update intervals in milliseconds
Config.Ticks = {
  fast = 150,   -- vehicle data, voice levels
  med  = 400,   -- health/armor/seatbelt/fuel
  slow = 1000   -- clock, street, direction
}

-- ESX status integration
Config.UseESXStatus = true           -- requires esx_status resource
Config.CustomStressStatus = 'stress' -- optional custom status name

-- Voice configuration
Config.UsePmaVoice = true            -- enable pma-voice integration

-- Opacity
Config.BaseOpacity      = 1.0
Config.CinematicOpacity = 0.35

-- Commands
Config.Commands = {
  toggle    = 'hud',
  cinematic = 'cinematic',
  settings  = 'hudsettings'
}

-- Optional key mappings (RegisterKeyMapping support)
Config.KeyMappings = {
  { command = 'hud',        label = 'HUD anzeigen/verstecken',     defaultKey = 'F7' },
  { command = 'cinematic',  label = 'HUD Cinematic-Modus',         defaultKey = 'F8' },
  { command = 'hudsettings',label = 'HUD Einstellungen öffnen',    defaultKey = 'F9' }
}
