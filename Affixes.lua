local e, L = unpack(select(2, ...))

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
]]

local AFFIX_ROTATION = {
	{10, 5, 14},
	{9, 6, 4},
	{10, 7, 2},
	{9, 5, 4},
	{10, 8, 12},
	{9, 7, 13},
	{10, 11, 14},
	{9, 6, 3},
	{10, 5, 13},
	{9, 7, 12},
	{10, 8, 3},
	{9, 2, 9},
}

local AFFIX_INFO = {}
local SEASON_AFFIX

local function UpdateMythicPlusAffixes()
	local affixes = C_MythicPlus.GetCurrentAffixes()
	if not affixes then return end
	
	SEASON_AFFIX = affixes[4].id

	local affixId = 1
	while (C_ChallengeMode.GetAffixInfo(affixId)) do
		local name, desc = C_ChallengeMode.GetAffixInfo(affixId)
		AFFIX_INFO[affixId] = {name = name, description = desc}
		affixId = affixId + 1
	end
	AstralEvents:Unregister('CHALLENGE_MODE_MAPS_UPDATE', 'updateAffixes')
end
AstralEvents:Register('CHALLENGE_MODE_MAPS_UPDATE', UpdateMythicPlusAffixes, 'updateAffixes')

function e.AffixOne(weekOffSet)
	local offSet = weekOffSet or 0
	local week = (e.Week + offSet) % 12
	if week == 0 then week = 12 end
	return AFFIX_ROTATION[week][1]
end

function e.AffixTwo(weekOffSet)
	local offSet = weekOffSet or 0
	local week = (e.Week + offSet) % 12
	if week == 0 then week = 12 end
	return AFFIX_ROTATION[week][2]
end

function e.AffixThree(weekOffSet)
	local offSet = weekOffSet or 0
	local week = (e.Week + offSet) % 12
	if week == 0 then week = 12 end
	return AFFIX_ROTATION[week][3]

end

-- This is always the season affix, this doesn't get changed in a rotation
function e.AffixFour()
	return SEASON_AFFIX
end

function e.AffixName(id)
	if id ~= -1 then
		return AFFIX_INFO[id].name
	else
		return nil
	end
end

function e.AffixDescription(id)
	if id ~= -1 then
		return AFFIX_INFO[id].description
	else
		return nil
	end
end

function e.GetAffixID(id, weekOffSet)
	local offSet = weekOffSet or 0
	local week = (e.Week + offSet) % 12
	if week == 0 then week = 12 end
	return AFFIX_ROTATION[week][id] or SEASON_AFFIX
end