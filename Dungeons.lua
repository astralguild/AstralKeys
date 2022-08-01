local _, addon = ...
local L = addon.L

local DUNGEON_TABLE = {}

local function SetDungeonTable()
	local dungeonTable = C_ChallengeMode.GetMapTable()

	if not dungeonTable then
		C_MythicPlus.RequestMapInfo()
	end

	for _, mapID in pairs(dungeonTable) do
		local name = C_ChallengeMode.GetMapUIInfo(mapID)
		if not name then 
			C_MythicPlus.RequestMapInfo()
			break
		end
		local colon = string.find(name, ":")
		if (colon) then
			DUNGEON_TABLE[mapID .. "F"] = L[name]
			name = string.sub(name, colon + 2)
		end
		DUNGEON_TABLE[mapID] = L[name]
	end
	AstralEvents:Unregister('CHALLENGE_MODE_MAPS_UPDATE', 'SetDungeonTable')
end

AstralEvents:Register('CHALLENGE_MODE_MAPS_UPDATE', SetDungeonTable, 'SetDungeonTable')

-- Shadowlands Dungeons

DUNGEON_TABLE[169] = L["Iron Docks"]
DUNGEON_TABLE[166] = L["Grimrail Depot"]
DUNGEON_TABLE[227] = L["Lower Karazhan"]
DUNGEON_TABLE[234] = L["Upper Karazhan"]
DUNGEON_TABLE[370] = L["Mechagon Workshop"]
DUNGEON_TABLE[369] = L["Mechagon Junkyard"]
DUNGEON_TABLE[391] = L["Streets of Wonder"]
DUNGEON_TABLE[392] = L["So'leah's Gambit"]


DUNGEON_TABLE["227F"] = L["Return to Karazhan: Lower"]
DUNGEON_TABLE["234F"] = L["Return to Karazhan: Upper"]
DUNGEON_TABLE["370F"] = L["Operation: Mechagon - Workshop"]
DUNGEON_TABLE["369F"] = L["Operation: Mechagon - Junkyard"]
DUNGEON_TABLE["391F"] = L["Tazavesh: Streets of Wonder"]
DUNGEON_TABLE["392F"] = L["Tazavesh: So'leah's Gambit"]

function addon.GetMapName(mapID, full)
	return (full and DUNGEON_TABLE[mapID .. "F"]) or DUNGEON_TABLE[mapID]
end
