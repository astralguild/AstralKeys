local _, addon = ...

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
		if mapID == 369 then
			DUNGEON_TABLE[mapID] = 'Junkyard'
		elseif mapID == 370 then
			DUNGEON_TABLE[mapID] = 'Workshop'
		else
			DUNGEON_TABLE[mapID] = name
		end

	end
	AstralEvents:Unregister('CHALLENGE_MODE_MAPS_UPDATE', 'SetDungeonTable')
end

AstralEvents:Register('CHALLENGE_MODE_MAPS_UPDATE', SetDungeonTable, 'SetDungeonTable')

-- Shadowlands Dungeons
DUNGEON_TABLE[375] = {}
DUNGEON_TABLE[375]['name'] = 'Mists of Tirna Scithe'
DUNGEON_TABLE[376] = {}
DUNGEON_TABLE[376]['name'] = 'The Necrotic Wake'
DUNGEON_TABLE[377] = {}
DUNGEON_TABLE[377]['name'] = 'De Other Side'
DUNGEON_TABLE[378] = {}
DUNGEON_TABLE[378]['name'] = 'Halls of Atonement'
DUNGEON_TABLE[379] = {}
DUNGEON_TABLE[379]['name'] = 'Plaguefall'
DUNGEON_TABLE[380] = {}
DUNGEON_TABLE[380]['name'] = 'Sanguine Depths'
DUNGEON_TABLE[381] = {}
DUNGEON_TABLE[381]['name'] = 'Spires of Ascension'
DUNGEON_TABLE[382] = {}
DUNGEON_TABLE[382]['name'] = 'Theater of Pain'

function addon.GetMapName(mapID)
	if type(DUNGEON_TABLE[mapID]) == 'table' then
		return DUNGEON_TABLE[mapID].name
	else
		return DUNGEON_TABLE[mapID]
	end
end