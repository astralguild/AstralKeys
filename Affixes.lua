local _, addon = ...

if not AstralAffixes then
	AstralAffixes = {}
	AstralAffixes.rotation = {}
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

local AFFIX_ROTATION = {
	{10, 11, 3}, -- Fortified, Bursting, Volcanic
	{9, 7, 124}, -- Tyrannical, Bolstering, Storming
	{10, 123, 12}, -- Fortified, Spiteful, Grievous
	{9, 122, 4}, -- Tyrannical, Inspiring, Necrotic
	{10, 8, 14}, -- Fortified, Sanguine, Quaking
	{9, 6, 13}, -- Tyrannical, Raging, Explosive
	{10, 123, 3}, -- Fortified, Spiteful, Volcanic
	{9, 7, 4}, -- Tyrannical, Bolstering, Necrotic
	{10, 122, 124}, -- Fortified, Inspiring, Storming
	{9, 11, 13}, -- Tyrannical, Bursting, Explosive
	{10, 8, 12}, -- Fortified, Sanguine, Grievous
	{9, 6, 14}, -- Tyrannical, Raging, Quaking
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
		AstralAffixes.rotation = {} -- Wipe the table
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