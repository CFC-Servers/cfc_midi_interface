CreateConVar( "sv_midi_sf_notes_quota", 30, FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_PROTECTED )
AddCSLuaFile( "cfc_midi_interface/base.lua" )
AddCSLuaFile( "cfc_midi_interface/key_lookup.lua" )
AddCSLuaFile( "cfc_midi_interface/console.lua" )