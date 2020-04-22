cfc_midi = {}

include( "cfc_midi_interface/key_lookup.lua" )
include( "cfc_midi_interface/console.lua" )

local table = table

function cfc_midi.sendNote( instrument, note )
    if not instrument.OnRegisteredKeyPlayed then
        error( "Invalid instrument entity." )
    end

    if not cfc_midi.MIDIKeys[note] then
        error( "Note out of range. ( 1-" .. #cfc_midi.MIDIKeys .. " )" )
    end

    instrument:OnRegisteredKeyPlayed( cfc_midi.MIDIKeys[note] )
    net.Start( "InstrumentNetwork" )
        net.WriteEntity( instrument )
        net.WriteInt( INSTNET_PLAY, 3 )
        net.WriteString( cfc_midi.MIDIKeys[note] )
    net.SendToServer()
end

-- To string everything and add tabs, as normal print would
local function printPre( addNewl, ... )
    local d = {...}
    local last = #d
    local out = {}

    for k, v in ipairs( d ) do
        table.insert( out, tostring( v ) )

        if k ~= last then
            table.insert( out, "\t" )
        end
    end

    if addNewl then
        table.insert( out, "\n" )
    end

    return unpack( out )
end

-- Print functions that prefix "MIDI" with colour
function cfc_midi.print( ... )
    MsgC( Color( 0, 255, 255 ), "MIDI: ", Color( 220, 220, 220 ), printPre( true, ... ) )
end

function cfc_midi.printChat( ... )
    chat.AddText( Color( 0, 255, 255 ), "MIDI: ", Color( 220, 220, 220 ), printPre( false, ... ) )
end

function cfc_midi.load()
    -- If file exists ( windows or linux )
    if file.Exists( "lua/bin/gmcl_midi_win64.dll", "MOD" ) or
       file.Exists( "lua/bin/gmcl_midi_win32.dll", "MOD" ) or
       file.Exists( "lua/bin/gmcl_midi_linux.dll", "MOD" ) then

        cfc_midi.print( "GMCL-Module detected!" )
        require( "midi" ) -- Import the library

        if not midi then -- Check it succeeded
            print( "GMCL-Module failed to initialize." )
            return
        end
        cfc_midi.printChat( "GMCL-Module initialised. Use console commands midi_devices and midi_debug [0|1] to use." )

        -- Connect to first device if it exists for convenience
        local ports = midi.GetPorts()
        local portsCount = table.Count( ports )
        if portsCount > 0 then
            midi.Open( 0 )
            cfc_midi.print( "Connected to device " .. ports[0] )
        end

        hook.Add( "MIDI", "midiPlayablePiano", function( time, command, note, velocity, ... )
            if not command then return end

            local code = midi.GetCommandCode( command )
            local name = midi.GetCommandName( command )
            if name == "NOTE_ON" and velocity == 0 then
                name = "NOTE_OFF"
            end

            -- Do debug print if enabled
            local cVar = GetConVar( "midi_debug" )
            if cVar and cVar:GetBool() then
                -- The code is a byte ( number between 0 and 254 ).
                cfc_midi.print( " = == EVENT = = =" )
                cfc_midi.print( "Time:\t", time )
                cfc_midi.print( "Code:\t", code )
                cfc_midi.print( "Channel:\t", midi.GetCommandChannel( command ) )
                cfc_midi.print( "Name:\t", name )
                cfc_midi.print( "Parameters", note, velocity, ... )
            end

            -- Get instrument entity
            local instrument = LocalPlayer().Instrument
            if not IsValid( instrument ) then return end

            -- Increase max keys ( previously 4 ) so you can play something good
            instrument.MaxKeys = 10

            -- Zero velocity NOTE_ON substitutes NOTE_OFF
            if not midi or name ~= "NOTE_ON" then return end
            if velocity == 0 or not cfc_midi.MIDIKeys or not cfc_midi.MIDIKeys[note - 35] then return end

            cfc_midi.sendNote( instrument, note - 35 )
        end )

        -- Tell others it worked
        hook.Run( "cfc_midi_init", midi )
    end
end

cfc_midi.load()