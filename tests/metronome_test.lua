-- Run from tick-metronome: lua tests/metronome_test.lua
local checks = 0
local function expect(actual, expected, label)
    assert(actual == expected, label .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
    checks = checks + 1
end
local subscriptions = {}
local subscribeCalls = {}
local function event(name)
    subscriptions[name] = {}
    return {
        Subscribe = function(key, callback)
            subscribeCalls[name] = (subscribeCalls[name] or 0) + 1
            subscriptions[name][key] = callback
        end,
        Unsubscribe = function(key) subscriptions[name][key] = nil end,
    }
end
Event = { ServerLogic = event("ServerLogic"), ContentLayerReady = event("ContentLayerReady") }
local function emit(name, payload)
    for _, callback in pairs(subscriptions[name]) do callback(payload) end
end
local saved, reads, writes, failWrites = {}, 0, 0, false
PersistentDB = {
    GetBool = function(_, key) reads = reads + 1; return saved[key] end,
    SetBool = function(_, key, value)
        if failWrites then error("simulated database failure") end
        writes = writes + 1
        saved[key] = value
    end,
}
local sounds = {}
Plugin = { resources = { metro = "metronome sound" } }
audio = { Play = function(resource) sounds[#sounds + 1] = resource end }
local views = {}
prettyui = { SimpleView = { new = function()
    local view = {}
    function view:AddTitle() end
    function view:AddCheckboxButton(items, options)
        self.selected = items[1].selected
        self.toggle = options.onChange
    end
    function view:Destroy() self.destroyed = true end
    views[#views + 1] = view
    return view
end } }

local Settings = require("settings")
local Metronome = require("metronome")
local ContentPane = require("interface/content")
for name, callbacks in pairs(subscriptions) do
    expect(next(callbacks), nil, "requiring modules does not subscribe to " .. name)
end
expect(Settings.get("enabled"), true, "default enabled")
expect(Settings.get("enabled"), true, "repeat default read")
expect(reads, 1, "default cached")
expect(writes, 1, "default persisted once")
local ok = pcall(Settings.update, "enabled", "false")
expect(ok, false, "reject wrong type")
expect(Settings.get("enabled"), true, "invalid value does not poison cache")
expect(writes, 1, "invalid value does not write")
expect(pcall(Settings.update, "unknown", true), false, "reject unknown setting")
failWrites = true
expect(pcall(Settings.update, "enabled", false), false, "failed write propagates")
expect(Settings.get("enabled"), true, "failed write leaves cache intact")
failWrites = false
Settings.update("enabled", false)
local reloaded = dofile("settings.lua")
expect(reloaded.get("enabled"), false, "load saved false")
local previousReads = reads
expect(reloaded.get("enabled"), false, "repeat loaded false")
expect(reads, previousReads, "saved false cached")
dofile("main.lua")
expect(next(subscriptions.ServerLogic), nil, "saved disabled state skips server logic subscription")
expect(next(subscriptions.ContentLayerReady) ~= nil, true, "disabled startup retains content UI")
Settings.update("enabled", true)
emit("ServerLogic")
expect(#sounds, 1, "one sound per server tick")
expect(sounds[1], Plugin.resources.metro, "correct audio resource")
local parent = { component = { width = 400, height = 600 } }
emit("ContentLayerReady", parent)
local first = views[#views]
expect(first.selected, true, "pane reflects setting")
first.toggle(nil, nil, "enabled", false)
expect(next(subscriptions.ServerLogic), nil, "disable removes server logic subscription")
expect(next(subscriptions.ContentLayerReady) ~= nil, true, "disable retains content UI")
emit("ServerLogic")
expect(#sounds, 1, "disabled metronome silent")
expect(saved.tick_metronome_enabled, false, "toggle persisted")
emit("ContentLayerReady", parent)
local second = views[#views]
expect(first.destroyed, true, "old view destroyed on reopen")
expect(second.selected, false, "reopen reflects disabled setting")
second.toggle(nil, nil, "enabled", true)
expect(next(subscriptions.ServerLogic) ~= nil, true, "reenable restores server logic subscription")
local previousSubscriptions = subscribeCalls.ServerLogic
Settings.update("enabled", true)
expect(subscribeCalls.ServerLogic, previousSubscriptions, "repeated enable does not resubscribe")
failWrites = true
expect(pcall(Settings.update, "enabled", false), false, "failed toggle write propagates")
expect(next(subscriptions.ServerLogic) ~= nil, true, "failed toggle retains active subscription")
failWrites = false
emit("ServerLogic")
expect(#sounds, 2, "reenabled metronome plays")
PluginShutdown()
expect(second.destroyed, true, "shutdown destroys view")
Settings.update("enabled", false)
Settings.update("enabled", true)
for name, callbacks in pairs(subscriptions) do
    expect(next(callbacks), nil, name .. " unsubscribed")
end
emit("ServerLogic")
expect(#sounds, 2, "no sound after shutdown")
PluginShutdown()
Metronome.Start()
ContentPane.Start()
emit("ServerLogic")
expect(#sounds, 3, "restart resumes ticking")
PluginShutdown() -- Safe when no content pane was opened.
for name, callbacks in pairs(subscriptions) do
    expect(next(callbacks), nil, name .. " cleaned up without pane")
end
print("Tick Metronome: " .. checks .. " checks passed")
