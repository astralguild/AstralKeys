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
	SEASON_AFFIX = select(4, unpack(C_MythicPlus.GetCurrentAffixes())) -- 4 entry in the table is the season affix.
	local affixId = 1
	while (C_ChallengeMode.GetAffixInfo(affixId)) do
		local name, desc = C_ChallengeMode.GetAffixInfo(affixId)
		AFFIX_INFO[affixId] = {name = name, description = desc}
		affixId = affixId + 1
	end
end
AstralEvents:Register('MYTHIC_PLUS_CURRENT_AFFIX_UPDATE', UpdateMythicPlusAffixes, 'updateAffixes')

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
	return AFFIX_INFO[id].name
end

function e.AffixDescription(id)
	return AFFIX_INFO[id].description
end

function e.GetAffixID(id, weekOffSet)
	local offSet = weekOffSet or 0
	local week = (e.Week + offSet) % 12
	if week == 0 then week = 12 end
	return AFFIX_ROTATION[week][id] or SEASON_AFFIX
end