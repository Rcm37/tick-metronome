local gallery = {}
local Settings = require("Settings")

local GUI_WIDTH = 200
local GUI_HEIGHT = 140

-- Main gallery surfaces.
local toggleGUI = nil
local onClose = nil

-- Build our primary window
local function createDemoWindow(gameArea)
    return prettyui.Window.new(gameArea, {
        title = "Tick Metronome",
        x = 20,
        y = 20,
        xAnchor = 0,
        yAnchor = 0,
        width = GUI_WIDTH,
        height = GUI_HEIGHT,
        minWidth = 200,
        minHeight = 140,
        onClose = function()
            if onClose then onClose() end
        end,
    })
end

local function createWindow(window)
    window:AddTitle("Global Toggle")
    window:AddCheckboxButton({
        { text = "Enable Plugin", value = "enabled", selected = Settings.get("enabled") },
    }, {
        onChange = function(_, _, changedValue, selected)
            updateSettings(changedValue, selected)
        end,
    })
end

function gallery.Build(onCloseHandler)
    onClose = onCloseHandler
    if toggleGUI ~= nil then return true end

    local gameArea = ui.Interfaces:GetComponent(id.Component.TOPLEVEL_V2__GAME_AREA)
    if gameArea == nil then return false end

    toggleGUI = createDemoWindow(gameArea)

    createWindow(toggleGUI)

    return true
end

function updateSettings(settingsKey, value)
    Settings.update(settingsKey, value)
end

function gallery.Show()
    if toggleGUI then toggleGUI:Show() end
end

function gallery.Close()
    if toggleGUI then toggleGUI:Close() end
end

function gallery.Destroy()
    -- Destroy the roots we own; child components are destroyed with them.
    if toggleGUI then toggleGUI:Destroy() end

    -- Release retained component handles.
    onClose = nil
    toggleGUI = nil
end

return gallery
