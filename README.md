# cfc_midi_interface
This addon allows users with MIDI devices to play the [Playable Piano](https://steamcommunity.com/sharedfiles/filedetails/?id=104548572) addon with said device.  
It also integrates Starfall hooks and functions for the MIDI devices and Playable Piano.  

## Requirements
Clients are required to have [gmcl_midi.dll](https://github.com/FPtje/gmcl_midi/releases) in `garrysmod/lua/bin` for MIDI devices to be used.

Just click the link and download the appropriate version of `gmcl_midi` from the latest release.

If you're running default Garry's Mod, download `gmcl_midi_win32.dll`.

If you're running Garry's Mod on the 64-bit / Chromium branch, download `gmcl_midi_win64.dll`.

## Console Commands
- `midi_devices` - This allows you to select the MIDI device you wish to use.
- `midi_debug [0|1]` - This boolean ConVar enables/disables debug prints in console, which show information about midi events as they occur.
- `midi_reload` - This simply reloads the addon, and searches for `gmcl_midi.dll` again, allowing users to add the file without relog.
- `sv_midi_sf_note_quota` - This is a server-side quota for starfall playNote calls (per second) (def 30).

## Starfall
- The `MIDI` hook is now available on client-side, using the following syntax:  
`nil GM:MIDI( float time, int command, int note, int velocity )`  
or more often:  
`hook.add("MIDI", "my_unique_identifier", function(time, command, note, velocity) end)`
- Entities now have the `boolean Entity:IsInstrument()` and `boolean Entity:playNote(int note)` functions.  
`Entity:playNote` takes a note index from `1-61` and returns a success boolean.  
**NOTE:** `Entity:playNote` is limited by the `sv_midi_sf_note_quota` ConVar.  
**NOTE2:** `Entity:playNote` also requires the calling player have PhysGun access to the instrument entity.

