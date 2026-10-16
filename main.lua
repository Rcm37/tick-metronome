local Metronome = require("metronome")
local ContentPane = require("interface/content")

Metronome.Start()
ContentPane.Start()

function PluginShutdown()
    ContentPane.Shutdown()
    Metronome.Shutdown()
end
