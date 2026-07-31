local gallery = {}
local Settings = require("Settings")

local GUI_WIDTH = 240
local GUI_HEIGHT = 250

-- Main gallery surfaces.
local toggleGUI = nil
local onClose = nil

-- Component handles retained by the demo.
local globalToggle = nil

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
        minWidth = 240,
        minHeight = 250,
        onClose = function()
            if onClose then onClose() end
        end,
    })
end

-- Demo sections appear here in the same order as they appear in the UI.
local function createWindow(window)
    window:AddTitle("Global Toggle")
    globalToggle = window:AddCheckboxButton({
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

    toggleGUI:AddDivider({
        marginTop = 1,
        marginBottom = 1
    })

    toggleGUI:AddText({ text = "Created by Rcm37", colour = 0xAFA27FFF, marginTop = 1, marginBottom = 2 })
    toggleGUI:AddText({ text = "Using PrettyUI 0.5.0", colour = 0xAFA27FFF, marginTop = 1, marginBottom = 2 })

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
