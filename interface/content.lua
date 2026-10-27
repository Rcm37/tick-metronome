local Settings = require("settings")
local ContentPane = {}
local EVENT_ID = "tick-metronome-content-pane"
local view

local function closeView()
    if view then view:Destroy() end
    view = nil
end

local function onLayerReady(event)
    closeView()

    local parent = event.component
    view = prettyui.SimpleView.new(parent, {
        width = parent.width,
        height = parent.height,
    })
    view:AddTitle("Global Toggle")
    view:AddCheckboxButton({
        { text = "Enable Plugin", value = "enabled", selected = Settings.get("enabled") },
    }, {
        onChange = function(_, _, changedValue, selected)
            Settings.update(changedValue, selected)
        end,
    })

end

function ContentPane.Start()
    Event.ContentLayerReady.Subscribe(EVENT_ID, onLayerReady)
end

function ContentPane.Shutdown()
    Event.ContentLayerReady.Unsubscribe(EVENT_ID)
    closeView()
end

return ContentPane
