-- Adds SF hook call, and ability to send key events to an instrument
hook.Add("Initialize", "MIDI_SF", function()
	if not SF then return end
	SF.hookAdd("MIDI")
	local ent_methods = SF.Entities.Methods

	function ent_methods:isInstrument()
		SF.CheckType(self, SF.Entities.Metatable)
		local e = SF.Entities.Unwrap(self)
		return e.OnRegisteredKeyPlayed and true or false
	end

	-- We want to limit playNote calls as it directly calls net.Send, and could be used to lag the server.
	local limitCVar = GetConVar("sv_midi_sf_notes_quota")
	local limit = limitCVar:GetInt()
	cvars.AddChangeCallback("sv_midi_sf_notes_quota", function(_, newLimit)
		limit = newLimit
	end )

	local noteCount = 0
	local timerActive = false
	local function createTimer()
		if not timerActive then
			timerActive = true
			timer.Create("cfc_mi_sfnotelimit", 1, 0, function()
				if noteCount == 0 then
					timer.Remove("cfc_mi_sfnotelimit")
					timerActive = false
				end
				noteCount = 0
			end )
		end
	end

	-- boolean Entity:playNote( number noteIdx )
	-- Takes note index from 1 to 61
	-- Returns if successful or not
	-- Limited by sv_midi_sf_notes_quota as a maximum number of notes per second
	function ent_methods:playNote(noteIdx)
		SF.CheckType(self, SF.Entities.Metatable)
		SF.CheckLuaType(noteIdx, TYPE_NUMBER)
		local ent = SF.Entities.Unwrap(self)
		if not ent.OnRegisteredKeyPlayed then
			error("Entity is not an instrument.")
		end
		if FPP then
			-- This is extracted as Jenkins complains about the double if.
			-- However, joining them into one condition will give unwanted behaviour
			-- Silly Jenkins 
			local canTouch = FPP.canTouchEnt(ent, "Physgun")
			if not canTouch then
				error("You do not have permission to send notes to this instrument")
			end
		else
			local o = ent:GetOwner()
			if IsValid(o) then
				if o ~= LocalPlayer() then
					error("You do not have permission to send notes to this instrument")
				end
			end
		end

		createTimer()
		noteCount = noteCount + 1
		if noteCount > limit then
			return false -- Called too many times
		end

		cfc_midi.sendNote(ent, noteIdx)
		return true
	end
end)