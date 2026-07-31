local Settings = require("settings")

local gallery = require("interface/gallery")

local BUILD_EVENT = "tick_metronome_build"
local ribbonButton = nil

local function buildGallery()
    return gallery.Build(function()
        if ribbonButton then ribbonButton:SetActive(false) end
    end)
end
ribbonButton = prettyui.RibbonBar.Register({
    id = "TickMetronome",
    icon = id.Sprite.RS3_ICON_TIMER_INSTANCE_0,
    tooltip = "Tick Metronome",
    onClick = function(handle, active)
        if active then
            if buildGallery() then
                gallery.Show()
            else
                handle:SetActive(false)
            end
        else
            gallery.Close()
        end
    end,
})
-- The game area may not exist during the first plugin tick.
if not buildGallery() then
    Event.Logic.Subscribe(BUILD_EVENT, function()
        if buildGallery() then
            ribbonButton:SetActive(true)
            Event.Logic.Unsubscribe(BUILD_EVENT)
        end
    end)
else
    ribbonButton:SetActive(true)
end

function PluginShutdown()
    Event.Logic.Unsubscribe(BUILD_EVENT)
    gallery.Destroy()

    if ribbonButton then
        ribbonButton:Destroy()
        ribbonButton = nil
    end
end

Event.ServerLogic.Subscribe("myEvent", function(serverLogicEvent)
    if Settings.get("enabled") then
        local playMetronome = audio.Play(Plugin.resources.metro)
    end
end)
