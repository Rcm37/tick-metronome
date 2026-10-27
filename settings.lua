local Settings = {}
local listeners = {}

function Settings.Subscribe(key, callback)
    listeners[key] = callback
end

function Settings.Unsubscribe(key)
    listeners[key] = nil
end

local PLUGIN_DB_PREFIX = "tick_metronome_"

local CachedSettings = {}

-- Settings toggles and their default values
local ValidSettings = {
    enabled = true
}

local function assertValidSetting(settingName)
    if ValidSettings[settingName] == nil then
        error("Unknown setting: " .. tostring(settingName))
    end
end

local function makeKey(settingName)
    return PLUGIN_DB_PREFIX .. settingName
end

function Settings.update(settingName, value)
    assertValidSetting(settingName)

    if type(value) ~= "boolean" then
        error("Expected boolean for setting: " .. tostring(settingName))
    end

    PersistentDB:SetBool(makeKey(settingName), value)
    CachedSettings[settingName] = value
    for _, callback in pairs(listeners) do callback(settingName, value) end
end

function Settings.get(settingName)
    assertValidSetting(settingName)

    if CachedSettings[settingName] ~= nil then
        return CachedSettings[settingName]
    end

    local value = PersistentDB:GetBool(makeKey(settingName))

    if value == nil then
        value = ValidSettings[settingName]
        PersistentDB:SetBool(makeKey(settingName), value)
    end

    CachedSettings[settingName] = value
    return value
end

return Settings
