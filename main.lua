Event.Logic.Subscribe("myEvent", function(logicEvent)

    -- supposed to be every 0.6s for tick rate but this is just client timing based on when the client kicks off the plugin
    -- not guaranteed to be in-time with actual server ticks
    if logicEvent.logicTick % 30 == 0 then
        local playMetronome = audio.Play(Plugin.resources.metro)
    end

end)
