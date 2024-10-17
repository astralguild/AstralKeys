local _, addon = ...

if not AstralAffixes then
	AstralAffixes = {}
	AstralAffixes.season_start_week = 0
	AstralAffixes.season_id = 0
end

-- Migration to season_id instead of season_affix
if not AstralAffixes.season_id then
	AstralAffixes.season_id = 0
end

--[[
Affix names corresponding to ID
1 OVERFLOWING
2 SKITTISH
3 VOLCANIC
4 NECROTIC
5 TEEMING
6 RAGING
7 BOLSTERING
8 SANGUINE
9 TYRANNICAL
10 FORTIFIED
11 BURSTING
12 GRiEVOUS WOUNDS
13 EXPLOSIVE
14 QUAKING
15 RELENTLESS
16 Infested
...
121 Prideful
122 Inspiring
123 Spiteful
124 Storming
125 Tormented
...
130 Encrypted
...
134 Entangling
135 Afflicted
136 Incorporeal
]]

local BURSTING = 11
local TYRANNICAL = 9
local EXPLOSIVE = 13
local RAGING = 6
local SANGUINE = 8
local VOLCANIC = 3
local SPITEFUL = 123
local QUAKING = 14
local BOLSTERING = 7
local STORMING = 124
local GRIEVOUS = 12
local FORTIFIED = 10
local ENTANGLING = 134
local AFFLICTED = 135
local INCORPOREAL = 136
local XALATATHS_BARGAIN_ASCENDANT = 148
local XALATATHS_GUILE = 147
local CHALLENGERS_PERIL = 152
local XALATATHS_BARGAIN_VOIDBOUND = 158
local XALATATHS_BARGAIN_OBLIVION = 159
local XALATATHS_BARGAIN_DEVOUR = 160

local AFFIX_ROTATION = {
	{ XALATATHS_BARGAIN_ASCENDANT, TYRANNICAL, CHALLENGERS_PERIL, FORTIFIED, XALATATHS_GUILE },
	{ XALATATHS_BARGAIN_OBLIVION, FORTIFIED, CHALLENGERS_PERIL, TYRANNICAL, XALATATHS_GUILE  },
	{ XALATATHS_BARGAIN_VOIDBOUND, TYRANNICAL, CHALLENGERS_PERIL, FORTIFIED, XALATATHS_GUILE },
	{ XALATATHS_BARGAIN_DEVOUR, FORTIFIED, CHALLENGERS_PERIL, TYRANNICAL, XALATATHS_GUILE },
	{ XALATATHS_BARGAIN_OBLIVION, TYRANNICAL, CHALLENGERS_PERIL, FORTIFIED, XALATATHS_GUILE },
	{ XALATATHS_BARGAIN_ASCENDANT, XALATATHS_GUILE, XALATATHS_GUILE, XALATATHS_GUILE, XALATATHS_GUILE }, -- Rest of rotation TBD
	{ XALATATHS_BARGAIN_ASCENDANT, XALATATHS_GUILE, XALATATHS_GUILE, XALATATHS_GUILE, XALATATHS_GUILE },
	{ XALATATHS_BARGAIN_ASCENDANT, XALATATHS_GUILE, XALATATHS_GUILE, XALATATHS_GUILE, XALATATHS_GUILE },
	{ XALATATHS_BARGAIN_ASCENDANT, XALATATHS_GUILE, XALATATHS_GUILE, XALATATHS_GUILE, XALATATHS_GUILE },
	{ XALATATHS_BARGAIN_ASCENDANT, XALATATHS_GUILE, XALATATHS_GUILE, XALATATHS_GUILE, XALATATHS_GUILE },
	{ XALATATHS_BARGAIN_ASCENDANT, XALATATHS_GUILE, XALATATHS_GUILE, XALATATHS_GUILE, XALATATHS_GUILE },
}

local AFFIX_ROTATION_WEEKS = 10

-- Timewalking Affixes
local INFERNAL = 129

local LEGION_AFFIX_ROTATION = {
	{ TYRANNICAL, BURSTING, VOLCANIC, INFERNAL },
	{ FORTIFIED, SANGUINE, QUAKING, INFERNAL }
}

local AFFIX_INFO = {}
local ROTATION_WEEK_POSITION = 0
local AffixIDs = {}
local AffixOneID, AffixTwoID, AffixThreeID, AffixSeasonID = 0, 0, 0, 0 -- Used to always show the current week's affixes irregardless if the rotation is known or not

-- Finds the index of the current week's affixes in the table
-- @param affixIds Array of integers for the corresponding affix
-- @return returnIndex integer defaults to 0 if the affixes are not found in the table, else returns the index the rotation is found
local function GetRotationPosition(affixIds)
	for i = 1, #AFFIX_ROTATION do
		local matches = true
		for j = 1, #affixIds do
			if AFFIX_ROTATION[i][j] ~= affixIds[j] then
				matches = false
				break
			end
		end
		if matches then
			return i
		end
	end
	return 0
end

local function UpdateMythicPlusAffixes()
	local affixes = C_MythicPlus.GetCurrentAffixes()
	if not affixes or not C_ChallengeMode.GetAffixInfo(1) then -- affixes have not loaded, re-request the info
		C_MythicPlus.RequestMapInfo()
		C_MythicPlus.RequestCurrentAffixes()
		return
	end
	
	if #affixes == 0 then -- Affixes can be empty at start of expac?
		return
	end
	
	for i = 1, #affixes do
	  AffixIDs[i] = affixes[i].id
	end

	ROTATION_WEEK_POSITION = GetRotationPosition(AffixIDs)

	if C_MythicPlus.GetCurrentSeason() ~= AstralAffixes.season_id then -- Season has changed
		AstralAffixes.season_id = C_MythicPlus.GetCurrentSeason() -- Change the season id
		AstralAffixes.season_start_week = addon.Week -- Set the starting week
	end

	-- Store the affix info for all the affixes, name, description
	-- TODO: what on earth is this
	for affixId = 1, 300 do
		local name, desc = C_ChallengeMode.GetAffixInfo(affixId)
		AFFIX_INFO[affixId] = {name = name, description = desc}
	end

	AstralEvents:Unregister('CHALLENGE_MODE_MAPS_UPDATE', 'updateAffixes')
	AstralEvents:Unregister('MYTHIC_PLUS_CURRENT_AFFIX_UPDATE', 'updateAffixes')
end

AstralEvents:Register('CHALLENGE_MODE_MAPS_UPDATE', UpdateMythicPlusAffixes, 'updateAffixes')
AstralEvents:Register('MYTHIC_PLUS_CURRENT_AFFIX_UPDATE', UpdateMythicPlusAffixes, 'UpdateAffixes')

-- TODO: This is yikes now that there are 5 affixes. plsfix when have time
function addon.AffixOne(weekOffSet)
	local offSet = weekOffSet or 0

	if offSet == 0 then
		return AffixIDs[1]
	end

	local week = (ROTATION_WEEK_POSITION + weekOffSet) % 12
	--local week = (e.Week + offSet) % 12
	if week == 0 then week = AFFIX_ROTATION_WEEKS end
	return AFFIX_ROTATION[week][1]
end

function addon.AffixTwo(weekOffSet)
	local offSet = weekOffSet or 0

	if offSet == 0 then
		return AffixIDs[2]
	end
	local week = (ROTATION_WEEK_POSITION + weekOffSet) % AFFIX_ROTATION_WEEKS
--	local week = (e.Week + offSet) % 12
	if week == 0 then week = AFFIX_ROTATION_WEEKS end
	return AFFIX_ROTATION[week][2]
end

function addon.AffixThree(weekOffSet)
	local offSet = weekOffSet or 0

	if offSet == 0 then
		return AffixIDs[3]
	end

	local week = (ROTATION_WEEK_POSITION + weekOffSet) % AFFIX_ROTATION_WEEKS	
--	local week = (e.Week + offSet) % 12
	if week == 0 then week = AFFIX_ROTATION_WEEKS end
	return AFFIX_ROTATION[week][3]
end

function addon.AffixFour()
	local offSet = weekOffSet or 0

	if offSet == 0 then
		return AffixIDs[4]
	end

	local week = (ROTATION_WEEK_POSITION + weekOffSet) % AFFIX_ROTATION_WEEKS	
--	local week = (e.Week + offSet) % 12
	if week == 0 then week = AFFIX_ROTATION_WEEKS end
	return AFFIX_ROTATION[week][4]
end

function addon.AffixFive()
	local offSet = weekOffSet or 0

	if offSet == 0 then
		return AffixIDs[5]
	end

	local week = (ROTATION_WEEK_POSITION + weekOffSet) % AFFIX_ROTATION_WEEKS	
--	local week = (e.Week + offSet) % 12
	if week == 0 then week = AFFIX_ROTATION_WEEKS end
	return AFFIX_ROTATION[week][5]
end

-- These are hardcoded and should be updated once we get back into the Timewalking event
function addon.TimewalkingAffixOne() 
	return LEGION_AFFIX_ROTATION[0][1]
end

function addon.TimewalkingAffixTwo()
	return LEGION_AFFIX_ROTATION[0][2]
end

function addon.TimewaklingAffixThree()
	return LEGION_AFFIX_ROTATION[0][3]
end

function addon.TimewalkingAffixFour()
	return LEGION_AFFIX_ROTATION[0][4]
end

function addon.AffixName(id)
	if id ~= 0 then
		return AFFIX_INFO[id] and AFFIX_INFO[id].name
	else
		return nil
	end
end

function addon.AffixDescription(id)
	if id ~= -1 then
		return AFFIX_INFO[id] and AFFIX_INFO[id].description
	else
		return nil
	end
end

function addon.GetAffixID(id, weekOffSet)
	local week = (ROTATION_WEEK_POSITION + weekOffSet) % AFFIX_ROTATION_WEEKS
	if week == 0 then week = AFFIX_ROTATION_WEEKS end
	if week > #AFFIX_ROTATION-1 then
		local affixes = C_MythicPlus.GetCurrentAffixes()
		return affixes[id].id or 0
	end
	return AFFIX_ROTATION[week][id] or 0
end