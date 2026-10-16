local Settings = require("settings")
local Metronome = {}
local EVENT_ID = "tick-metronome-server-logic"

local function onServerLogic()
    if Settings.get("enabled") then
        audio.Play(Plugin.resources.metro)
    end
end

local active = false

local function setEnabled(enabled)
    if active == enabled then return end
    if enabled then
        Event.ServerLogic.Subscribe(EVENT_ID, onServerLogic)
    else
        Event.ServerLogic.Unsubscribe(EVENT_ID)
    end
    active = enabled
end

local function onSettingChanged(name, value)
    if name == "enabled" then setEnabled(value) end
end

function Metronome.Start()
    Settings.Subscribe(EVENT_ID, onSettingChanged)
    setEnabled(Settings.get("enabled"))
end

function Metronome.Shutdown()
    Settings.Unsubscribe(EVENT_ID)
    setEnabled(false)
end

return Metronome
