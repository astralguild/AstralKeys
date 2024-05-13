local _, addon = ...

if not AstralAffixes then
	AstralAffixes = {}
	AstralAffixes.season_start_week = 0
	AstralAffixes.season_affix = 0
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

local AFFIX_ROTATION = {
	{ TYRANNICAL, STORMING, RAGING },
	{ FORTIFIED, ENTANGLING, BOLSTERING },
	{ TYRANNICAL, INCORPOREAL, SPITEFUL },
	{ FORTIFIED, AFFLICTED, RAGING },
	{ TYRANNICAL, VOLCANIC, SANGUINE },
	{ FORTIFIED, STORMING, BURSTING },
	{ TYRANNICAL, AFFLICTED, BOLSTERING },
	{ FORTIFIED, INCORPOREAL, SANGUINE },
	{ TYRANNICAL, ENTANGLING, BOLSTERING },
	{ FORTIFIED, VOLCANIC, SPITEFUL },
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
local AffixOneID, AffixTwoID, AffixThreeID, AffixSeasonID = 0, 0, 0, 0 -- Used to always show the current week's affixes irregardless if the rotation is known or not

-- Finds the index of the current week's affixes in the table
-- @param affixOne Integers id for corresponding affix
-- @param affixTwo Integers id for corresponding affix
-- @param affixThree Integers id for corresponding affix
-- @return returnIndex integer defaults to 0 if the affixes are not found in the table, else returns the index the rotation is found
local function GetRotationPosition(affixOne, affixTwo, affixThree)
	local returnIndex = 0

	for i = 1, #AFFIX_ROTATION do
		if AFFIX_ROTATION[i][1] == affixOne and AFFIX_ROTATION[i][2] == affixTwo and AFFIX_ROTATION[i][3] == affixThree then
			return i
		end
	end

	return returnIndex
end

local function UpdateMythicPlusAffixes()
	local affixes = C_MythicPlus.GetCurrentAffixes()
	if not affixes or not C_ChallengeMode.GetAffixInfo(1) then -- affixes have not loaded, re-request the info
		C_MythicPlus.RequestMapInfo()
		C_MythicPlus.RequestCurrentAffixes()
		return
	end

	AffixOneID = affixes[1].id
	AffixTwoID = affixes[2].id
	AffixThreeID = affixes[3].id
	if #affixes > 3 then
		AffixSeasonID = affixes[4].id
	end

	ROTATION_WEEK_POSITION = GetRotationPosition(affixes[1].id, affixes[2].id, affixes[3].id)

	if AffixSeasonID ~= AstralAffixes.season_affix then -- Season has changed
		AstralAffixes.season_affix = AffixSeasonID -- Change the season affix
		AstralAffixes.season_start_week = addon.Week -- Set the starting week
	end

	-- Store the affix info for all the affixes, name, description
	for affixId = 1, 300 do
		local name, desc = C_ChallengeMode.GetAffixInfo(affixId)
		AFFIX_INFO[affixId] = {name = name, description = desc}
	end

	-- Store the season affix info
	if AffixSeasonID > 0 then
		local name, desc = C_ChallengeMode.GetAffixInfo(AffixSeasonID)
		AFFIX_INFO[AffixSeasonID] = {name = name, description = desc}
	end

	AstralEvents:Unregister('CHALLENGE_MODE_MAPS_UPDATE', 'updateAffixes')
	AstralEvents:Unregister('MYTHIC_PLUS_CURRENT_AFFIX_UPDATE', 'updateAffixes')
end

AstralEvents:Register('CHALLENGE_MODE_MAPS_UPDATE', UpdateMythicPlusAffixes, 'updateAffixes')
AstralEvents:Register('MYTHIC_PLUS_CURRENT_AFFIX_UPDATE', UpdateMythicPlusAffixes, 'UpdateAffixes')

function addon.AffixOne(weekOffSet)
	local offSet = weekOffSet or 0

	if offSet == 0 then
		return AffixOneID
	end

	local week = (ROTATION_WEEK_POSITION + weekOffSet) % 12
	--local week = (e.Week + offSet) % 12
	if week == 0 then week = AFFIX_ROTATION_WEEKS end
	return AFFIX_ROTATION[week][1]
end

function addon.AffixTwo(weekOffSet)
	local offSet = weekOffSet or 0

	if offSet == 0 then
		return AffixTwoID
	end
	local week = (ROTATION_WEEK_POSITION + weekOffSet) % AFFIX_ROTATION_WEEKS
--	local week = (e.Week + offSet) % 12
	if week == 0 then week = AFFIX_ROTATION_WEEKS end
	return AFFIX_ROTATION[week][2]
end

function addon.AffixThree(weekOffSet)
	local offSet = weekOffSet or 0

	if offSet == 0 then
		return AffixThreeID
	end

	local week = (ROTATION_WEEK_POSITION + weekOffSet) % AFFIX_ROTATION_WEEKS	
--	local week = (e.Week + offSet) % 12
	if week == 0 then week = AFFIX_ROTATION_WEEKS end
	return AFFIX_ROTATION[week][3]

end

-- This is always the season affix, this doesn't get changed in a rotation
function addon.AffixFour()
	return AffixSeasonID
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
		if id == 4 then
			return AffixSeasonID
		end
		local affixes = C_MythicPlus.GetCurrentAffixes()
		return affixes[id].ID or AffixSeasonID
	end
	return AFFIX_ROTATION[week][id] or AffixSeasonID
end