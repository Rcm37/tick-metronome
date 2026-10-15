local contentView
local Settings = require("settings")
local UIUtils = require("interface/ui_utils")
Event.ContentLayerReady.Subscribe("tick-metronome-content-pane", function(event)
    if contentView then contentView:Destroy() end

    local parent = event.component
    contentView = prettyui.SimpleView.new(parent, {
        width = parent.width,
        height = parent.height,
    })
    contentView:AddTitle("Global Toggle")
    contentView:AddCheckboxButton({
        { text = "Enable Plugin", value = "enabled", selected = Settings.get("enabled") },
    }, {
        onChange = function(_, _, changedValue, selected)
            UIUtils.updateSettings(changedValue, selected)
        end,
    })

end)