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
DUNGEON_TABLE[375] = L["Mists of Tirna Scithe"]
DUNGEON_TABLE[376] = L["The Necrotic Wake"]
DUNGEON_TABLE[377] = L["De Other Side"]
DUNGEON_TABLE[378] = L["Halls of Atonement"]
DUNGEON_TABLE[379] = L["Plaguefall"]
DUNGEON_TABLE[380] = L["Sanguine Depths"]
DUNGEON_TABLE[381] = L["Spires of Ascension"]
DUNGEON_TABLE[382] = L["Theater of Pain"]
DUNGEON_TABLE[391] = L["Streets of Wonder"]
DUNGEON_TABLE[392] = L["So'leah's Gambit"]

DUNGEON_TABLE["391F"] = L["Tazavesh: Streets of Wonder"]
DUNGEON_TABLE["392F"] = L["Tazavesh: So'leah's Gambit"]

function addon.GetMapName(mapID, full)
	return (full and DUNGEON_TABLE[mapID .. "F"]) or DUNGEON_TABLE[mapID]
end
