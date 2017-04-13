local _, e = ...

local DUNGEON_TABLE = {}
local WEEKLY_AP = {}

local temp_dungeon = {}
temp_dungeon[197] = 'Eye of Azshara'
temp_dungeon[198] = 'Darkheart Thicket'
temp_dungeon[199] = 'Black Rook Hold'
temp_dungeon[200] = 'Halls of Valor'
temp_dungeon[206] = 'Neltharion\'s Lair'
temp_dungeon[207] = 'Vault of the Wardens'
temp_dungeon[208] = 'Maw of Souls'
temp_dungeon[209] = 'The Arcway'
temp_dungeon[210] = 'Court of Stars'
temp_dungeon[227] = 'Return to Karazhan: Lower'
temp_dungeon[233] = 'Cathedral of Eternal Night'
temp_dungeon[234] = 'Return to Karazhan: Upper'



--[[ 
Times
	-1440
	> 1440
	< 2700
	>2700
 Tier 1 Lvl 2 -3
 	-Maw 175
 	-Other 300
 	-HoV, Arc 375

 Tier 2 Lvl 4-6
 	- 290
 	- 475
 	- 600

 Tier 3 Lvl 7-9
 	-325
 	-540
 	-675

 Tier 4 10-14
 	-465
 	-775
 	-1000

 Tier 5 lvl 15+
 	-725
 	-1200
 	-1500


]]

local name, mapID, runTime, a, b, c
local dungeon = {}


local function ParseMaps()
	for _, map in pairs(C_ChallengeMode.GetMapTable()) do
		name, mapID, runTime = C_ChallengeMode.GetMapInfo(map)
		wipe(dungeon)
		a, b, c = runTime, runTime * .8, runTime * .6
		dungeon.name = name
		dungeon['chestTimes'] = {}
		dungeon.chestTimes[1] = a
		dungeon.chestTimes[2] = b
		dungeon.chestTimes[3] = c
		dungeon['apTier'] = {}
		if runTime == 1400 then
			dungeon.apTier[1] = 175
			dungeon.apTier[2] = 290
			dungeon.apTier[3] = 325
			dungeon.apTier[4] = 465
			dungeon.apTier[5] = 725
		elseif runTime > 1440 and runTime < 2700 then
			dungeon.apTier[1] = 300
			dungeon.apTier[2] = 475
			dungeon.apTier[3] = 540
			dungeon.apTier[4] = 775
			dungeon.apTier[5] = 1000
		elseif runTime == 2700 then
			dungeon.apTier[1] = 375
			dungeon.apTier[2] = 600
			dungeon.apTier[3] = 675
			dungeon.apTier[4] = 1000
			dungeon.apTier[5] = 1500
		end
		DUNGEON_TABLE[map] = e.DeepCopy(dungeon)
	end

	return DUNGEON_TABLE
end

function e.BuildMapTable()
	DUNGEON_TABLE = ParseMaps()
end

function e.GetMapName(mapID)
	--return temp_dungeon[tonumber(mapID)]
	return DUNGEON_TABLE[tonumber(mapID)]['name'] or temp_dungeon[mapID]
end

local function GetMapTime(mapID, chestCount)
	return DUNGEON_TABLE[mapID].chestTimes[chestCount]
end

local function GetKeyTier(keyLevel)
	if keyLevel < 4 then return 1 end
	if keyLevel > 3 then
		if keyLevel < 7 then
			return 2
		elseif keyLevel < 10 then
			return 3
		elseif keyLevel < 15 then
			return 4
		else
			return 5
		end
	end
end


function e.GetMapAP(mapID, keyLevel)
	return DUNGEON_TABLE[tonumber(mapID)]['apTier'][GetKeyTier(tonumber(keyLevel))]
end

WEEKLY_AP[2] = 0
WEEKLY_AP[3] = 1250
WEEKLY_AP[4] = 0
WEEKLY_AP[5] = 1925
WEEKLY_AP[6] = 1925
WEEKLY_AP[7] = 2150
WEEKLY_AP[8] = 2150
WEEKLY_AP[9] = 0
WEEKLY_AP[10] = 3125
WEEKLY_AP[11] = 3525
WEEKLY_AP[12] = 3925
WEEKLY_AP[13] = 4325
WEEKLY_AP[14] = 4725
WEEKLY_AP[15] = 5000
WEEKLY_AP[16] = 5400
WEEKLY_AP[17] = 5800
WEEKLY_AP[18] = 6200
WEEKLY_AP[19] = 6600
WEEKLY_AP[20] = 7000

function e.GetWeeklyAP(keyLevel)
	if WEEKLY_AP[keyLevel] ~= 0 then
		return WEEKLY_AP[keyLevel]
	end

	return 0
end

local amount, s, chest1, chest2, chest3

function e.MapApText(mapID, keyLevel, isDepleted)
	if isDepleted == 0 then return 'Depleted key.' end

	amount = e.GetMapAP(mapID, keyLevel) * e.GetAKBonus(e.ParseAKLevel())
	s = ''
	chest1 = e.ConvertToSI(amount/math.floor(GetMapTime(mapID, 1)/60))
	chest2 = e.ConvertToSI(amount/math.floor(GetMapTime(mapID, 2)/60))
	chest3 = e.ConvertToSI(amount/math.floor(GetMapTime(mapID, 3)/60))
	s = e.ConvertToSI(amount) .. ' AP\n' .. '+1 ' .. chest1 .. '/m \n+2 ' .. chest2 .. '/m  \n+3 ' .. chest3 .. '/m'
	return s

end
--string.format('%.2f', test)
	
		