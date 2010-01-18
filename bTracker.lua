local myname, ns = ...
bTrackerDB = {}
local list = {}
local GetNumTrackingTypes = GetNumTrackingTypes
local SetTracking = SetTracking
local GetTrackingInfo = GetTrackingInfo
local GetSpellCooldown = GetSpellCooldown
local GetSpellInfo = GetSpellInfo
local print = print
local tostring = tostring
local tonumber = tonumber
local spell
local spells = { 
	2383,	-- Find Herbs
	2481,	-- Find Treasure
	2580,	-- Find Minerals
	5503,	-- Sense Undead
	43308,	-- Find Fish
}
local myfullname = GetAddOnMetadata(myname, "Title")
local function Print(...) print("|cFF33FF99".. myfullname.. "|r -", ...) end

local frame = CreateFrame("Frame", "bTracker", UIParent)
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnEvent", function(self, event, ...) 
	if self[event] then 
		return self[event](self, event, ...) 
	end 
end)

function frame:PLAYER_ENTERING_WORLD()
	self:makeTrackList()

	self:RegisterEvent("MINIMAP_UPDATE_TRACKING")

	if not bTrackerDB.custom then
		for k,v in pairs(spells) do
			local name = GetSpellInfo(v)
			if GetSpellCooldown(name) then
				spell = name
				break
			end
			spell = false
		end
	else
		spell = bTrackerDB.custom
	end

	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function frame:MINIMAP_UPDATE_TRACKING()
	self:makeTrackList()
end

function frame:makeTrackList()
	for i=1, GetNumTrackingTypes() do
		local name,_,active,_ = GetTrackingInfo(i)
		list[i] = { name=name, active=active }
	end
end

function frame:printTracks()
	local listName = ""
	for i=1, #list do
		if list[i].active then
			listName = listName .. "|cffffff00" .. i .. ". " .. list[i].name .. "|r"
		else
			listName = listName .. i .. ". " .. list[i].name
		end
		if i ~= #list then
			listName = listName .. ", "
		end
	end
	Print(listName)
end

function frame:clearTracking()
	self:trackHandler(nil,nil)
end

function frame:swapTracking() 
	if spell and GetSpellCooldown(spell) == 0 then
		if bTrackerDB.cur and bTrackerDB.pre then
			self:trackHandler(bTrackerDB.pre, true, true)
		else
			Print("Swap list not set, do one track cycle first")
		end
	elseif spell == false then
		Print("No spells where found to check for global cooldown, swap track has been disabled\n If you have a spell that you would like to check instead of the built in list,\nAdd it with /btracker spellID")
	end
end

function frame:trackHandler(toTrack, swapTrack, silentTrack)
	local trackID = self:checkTracking(toTrack)
	trackID = tonumber(trackID)
	local trackThis
	if trackID and swapTrack then
		if bTrackerDB.cur ~= trackID then
			bTrackerDB.pre = bTrackerDB.cur
			bTrackerDB.cur = trackID
			trackThis = bTrackerDB.cur
		end
	elseif trackID and trackID <= #list then
		if bTrackerDB.cur ~= trackID then
			bTrackerDB.pre = bTrackerDB.cur
			bTrackerDB.cur = trackID
			trackThis = trackID
		end
	end
	if trackThis and trackThis ~= 0 then
		if not silentTrack then Print(string.format("Tracking for: |cff33ff99%s . %s", trackThis, list[trackThis].name)) end
		SetTracking(trackThis)
	else
		Print("Cleared tracking")
		bTrackerDB.cur = nil
		SetTracking(nil)
	end
end

function frame:checkTracking(toTrack)
	local track = tostring(toTrack)
	local trackID = tonumber(toTrack)
	for i=1, GetNumTrackingTypes() do 
		if track:lower() == list[i].name:lower() then
			track = i
			break
		elseif i == trackID then
			track = i
			break
		end
	end
	return track and track
end

SlashCmdList["BTRACKERC"] = function(arg1)
	local trackID = tonumber(arg1)
	if arg1 == "clear" then
		local dbSpell = select(2,GetSpellLink(bTrackerDB.custom))
		Print(string.format("%s %s", "Going back to predefined spell list for GCD checking, removed spell", dbSpell and dbSpell or ""))
		bTrackerDB.custom = nil
		return frame:PLAYER_ENTERING_WORLD()
	elseif trackID then
		spellCheck = GetSpellInfo(trackID)
		if spellCheck then
			bTrackerDB.custom = spellCheck
			spell = spellCheck
			Print(string.format("%s %s", "Custom spell to check for GCD is:", spellCheck))
		else
			bTrackerDB.custom = nil
			spell = false
			Print(string.format("%s, %d", "Unable to get spellinfo on spellID:", trackID))
		end
	else
		Print(string.format("Invalid input: %s is not a number", arg1))
	end
end

SlashCmdList["BTRACKER"] = function(arg1)
	if arg1 == "" then
		frame:printTracks()
	else
		frame:trackHandler(arg1, false, false)
	end
end
SLASH_BTRACKERC1 = "/btracker"
SLASH_BTRACKER1 = "/track"
SLASH_BTRACKER2 = "/tr"
