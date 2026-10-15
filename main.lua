local Settings = require("settings")
local contentView = require("interface/content")

function PluginShutdown()
    Event.ContentLayerReady.Unsubscribe("tick-metronome-content-pane")
    if contentView then
        contentView:Destroy()
        contentView = nil
    end
end

Event.ServerLogic.Subscribe("tick-metronome-server-logic", function(serverLogicEvent)
    if Settings.get("enabled") then
        local playMetronome = audio.Play(Plugin.resources.metro)
    end
end)
