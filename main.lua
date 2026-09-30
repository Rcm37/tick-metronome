local Settings = require("settings")
local contentView = require("interface/content")

function PluginShutdown()
    Event.ContentLayerReady.Unsubscribe("my-plugin-content")
    if contentView then
        contentView:Destroy()
        contentView = nil
    end
end

Event.ServerLogic.Subscribe("myEvent", function(serverLogicEvent)
    if Settings.get("enabled") then
        local playMetronome = audio.Play(Plugin.resources.metro)
    end
end)
