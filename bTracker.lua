bTrackerDB = {}
local list = {}
local GetNumTrackingTypes = GetNumTrackingTypes
local SetTracking = SetTracking
local GetTrackingInfo = GetTrackingInfo
local GetSpellCooldown = GetSpellCooldown
local print = print
local tostring = tostring
local tonumber = tonumber
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

	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self.PLAYER_ENTERING_WORLD = nil
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
	print(listName)
end

function frame:clearTracking()
	self:trackHandler(nil,nil)
end
function frame:swapTracking()
	if (GetSpellCooldown("Find Herbs") or GetSpellCooldown("Find Minerals") or GetSpellCooldown("Find Fish")) == 0 then 
		if bTrackerDB.cur and bTrackerDB.pre then
			self:trackHandler(bTrackerDB.pre, true, true)
		else
			print("Swap list not set, do one track cycle first")
		end
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
		if not silentTrack then print("Tracking for: |cff33ff99" .. trackThis .. " . " .. list[trackThis].name) end
		SetTracking(trackThis)
	else
		print("Cleared tracking")
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

SlashCmdList["BTRACKER"] = function(arg1)
	if arg1 == "" then
		frame:printTracks()
	else
		frame:trackHandler(arg1, false, false)
	end
end
SLASH_BTRACKER1 = "/track"
SLASH_BTRACKER2 = "/tr"
