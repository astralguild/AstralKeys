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
]]

local BURSTING = 11
local TYRANNICAL = 9
local EXPLOSIVE = 13
local RAGING = 6
local SANGUINE = 8
local VOLCANIC = 3
local SPITEFUL = 123
local QUAKING = 14
local NECROTIC = 4
local INSPIRING = 122
local BOLSTERING = 7
local STORMING = 124
local GRIEVOUS = 12
local FORTIFIED = 10

local AFFIX_ROTATION = {
	{ FORTIFIED, BURSTING, STORMING },
	{ TYRANNICAL, RAGING, VOLCANIC },
	{ FORTIFIED, INSPIRING, GRIEVOUS },
	{ TYRANNICAL, SPITEFUL, NECROTIC },
	{ FORTIFIED, BOLSTERING, QUAKING },
	{ TYRANNICAL, SANGUINE, STORMING },
	{ FORTIFIED, RAGING, EXPLOSIVE },
	{ TYRANNICAL, BURSTING, VOLCANIC },
	{ FORTIFIED, SPITEFUL, GRIEVOUS },
	{ TYRANNICAL, INSPIRING, QUAKING },
	{ FORTIFIED, SANGUINE, GRIEVOUS },
	{ TYRANNICAL, BOLSTERING, EXPLOSIVE },
}

-- Timewalking Affixes
local INFERNAL = 129

local LEGION_AFFIX_ROTATION = {
	{ TYRANNICAL, BURSTING, VOLCANIC, INFERNAL },
	{ FORTIFIED, SANGUINE, QUAKING, INFERNAL }
}

local AFFIX_INFO = {}
local SEASON_AFFIX = 0
local ROTATION_WEEK_POSITION = 0
local AffixOneID, AffixTwoID, AffixThreeID = 0, 0, 0 -- Used to always show the current week's affixes irregardless if the rotation is known or not

-- Finds the index of the current week's affixes in the table
-- @param affixOne Integers id for corresponding affix
-- @param affixTwo Integers id for corresponding affix
-- @param affixThree Integers id for corresponding affix
-- @return returnIndex integer defaults to 0 if the affixes are not found in the table, else returns the index the rotation is found
local function GetRotationPosition(affixOne, affixTwo, affixThree)
	local returnIndex = 0

	for i = 1, #AFFIX_ROTATION do
		if AFFIX_ROTATION[i][1] == affixOne and AFFIX_ROTATION[i][2] == affixTwo and AFFIX_ROTATION[i][3] == affixThree then
			returnIndex = i
			break
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
	
	SEASON_AFFIX = affixes[4].id -- Set the season affix id
	AffixOneID = affixes[1].id
	AffixTwoID = affixes[2].id
	AffixThreeID = affixes[3].id

	ROTATION_WEEK_POSITION = GetRotationPosition(affixes[1].id, affixes[2].id, affixes[3].id)

	if SEASON_AFFIX ~= AstralAffixes.season_affix then -- Season has changed
		AstralAffixes.season_affix = SEASON_AFFIX -- Change the season affix
		AstralAffixes.season_start_week = addon.Week -- Set the starting week
	end

	-- Store the affix info for all the affixes, name, description
	for affixId = 1, 300 do
		local name, desc = C_ChallengeMode.GetAffixInfo(affixId)
		AFFIX_INFO[affixId] = {name = name, description = desc}
	end

	-- Store the season affix info
	local name, desc = C_ChallengeMode.GetAffixInfo(SEASON_AFFIX)
	AFFIX_INFO[SEASON_AFFIX] = {name = name, description = desc}
	
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
	if week == 0 then week = 12 end
	return AFFIX_ROTATION[week][1]
end

function addon.AffixTwo(weekOffSet)
	local offSet = weekOffSet or 0

	if offSet == 0 then
		return AffixTwoID
	end
	local week = (ROTATION_WEEK_POSITION + weekOffSet) % 12
--	local week = (e.Week + offSet) % 12
	if week == 0 then week = 12 end
	return AFFIX_ROTATION[week][2]
end

function addon.AffixThree(weekOffSet)
	local offSet = weekOffSet or 0

	if offSet == 0 then
		return AffixThreeID
	end

	local week = (ROTATION_WEEK_POSITION + weekOffSet) % 12	
--	local week = (e.Week + offSet) % 12
	if week == 0 then week = 12 end
	return AFFIX_ROTATION[week][3]

end

-- This is always the season affix, this doesn't get changed in a rotation
function addon.AffixFour()
	return SEASON_AFFIX
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
	local week = (ROTATION_WEEK_POSITION + weekOffSet) % 12
	if week == 0 then week = 12 end
	return AFFIX_ROTATION[week][id] or SEASON_AFFIX
end