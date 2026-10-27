# Tick Metronome

A RuneScape plugin that plays an audible click on each server-logic event, providing a rhythm cue for game ticks.

## Setup

Requires **PrettyUI** (dependency ID `6398181`). Load the `tick-metronome` directory as a development plugin with PrettyUI available. Keep its bundled `resources/metro.ogg` sound file with the plugin. The plugin requests no additional permissions.

## Usage

Open **Tick Metronome** from the plugin ribbon and toggle **Enable Plugin** to start or stop the clicks. It is enabled by default, and the setting persists between sessions. All configuration is in the ribbon panel; this plugin has no separate Plugin Hub settings pane.

Clicks follow the client's server-logic callbacks, so their timing follows incoming server updates. Disabling the plugin stops listening for those events.
