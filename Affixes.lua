local ADDON, e = ...

local AFFIXES = {}

if C_MythicPlus then
	local function UpdateMythicPlusAffixes()
		AFFIXES = C_MythicPlus.GetCurrentAffixes()
		for i = 1, #AFFIXES do
			local id = AFFIXES[i]
			local name, desc = C_ChallengeMode.GetAffixInfo(id)
			AFFIXES[i] = {}
			AFFIXES[i]['id'] = id
			AFFIXES[i]['name'] = name
			AFFIXES[i]['desc'] = desc
		end
	end
	AstralEvents:Register('MYTHIC_PLUS_CURRENT_AFFIX_UPDATE', UpdateMythicPlusAffixes, 'updateAffixes')

else
--[[
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
16]]

AFFIXES[1] = {} -- Teeming, Quaking, Fortified
AFFIXES[1][1] = 5
AFFIXES[1][2] = 14
AFFIXES[1][3] = 10

AFFIXES[2] = {} -- Volcanic, Necrotic, Tyrannical
AFFIXES[2][1] = 6
AFFIXES[2][2] = 4
AFFIXES[2][3] = 9

AFFIXES[3] = {} -- Bolstering, Skittish, Fortified
AFFIXES[3][1] = 7
AFFIXES[3][2] = 2
AFFIXES[3][3] = 10

AFFIXES[4] = {} -- Teeming, Vocanic, Tyrannical
AFFIXES[4][1] = 5
AFFIXES[4][2] = 3
AFFIXES[4][3] = 9

AFFIXES[5] = {} -- Sanguine, Grievous, Fortified
AFFIXES[5][1] = 8
AFFIXES[5][2] = 12
AFFIXES[5][3] = 10

AFFIXES[6] = {} -- Bolstering, Explosive, Tyrannical
AFFIXES[6][1] = 7
AFFIXES[6][2] = 13
AFFIXES[6][3] = 9

AFFIXES[7] = {} -- Bursting, Quaking, Fortified
AFFIXES[7][1] = 11
AFFIXES[7][2] = 14
AFFIXES[7][3] = 10

AFFIXES[8] = {} -- Raging, Volcanic, Tyrannical
AFFIXES[8][1] = 6
AFFIXES[8][2] = 3
AFFIXES[8][3] = 9

AFFIXES[9] = {} -- Teeming, Explosive, Fortified
AFFIXES[9][1] = 5
AFFIXES[9][2] = 13
AFFIXES[9][3] = 10

AFFIXES[10] = {} -- Bolstering, Grievous, Tyrannical
AFFIXES[10][1] = 7
AFFIXES[10][2] = 12
AFFIXES[10][3] = 9

AFFIXES[11] = {} -- Sanguine, Volcanic, Fortified
AFFIXES[11][1] = 8
AFFIXES[11][2] = 4
AFFIXES[11][3] = 10

AFFIXES[12] = {} -- Bursting, Skittish, Tyrannical
AFFIXES[12][1] = 11
AFFIXES[12][2] = 2
AFFIXES[12][3] = 9
end

function e.AffixOne(weekOffSet)
	if C_MythicPlus then
		return AFFIXES[2].id
	else
		local offSet = weekOffSet or 0
		local week = (e.Week + offSet) % 12
		if week == 0 then week = 12 end
		return AFFIXES[week][1]
	end
end

function e.AffixTwo(weekOffSet)
	if C_MythicPlus then
		return AFFIXES[3].id
	else
		local offSet = weekOffSet or 0
		local week = (e.Week + offSet) % 12
		if week == 0 then week = 12 end
		return AFFIXES[week][2]
	end
end

function e.AffixThree(weekOffSet)
	if C_MythicPlus then
		return AFFIXES[1].id
	else
		local offSet = weekOffSet or 0
		local week = (e.Week + offSet) % 12
		if week == 0 then week = 12 end
		return AFFIXES[week][3]
	end
end

function e.AffixFour()
	return AFFIXES[4].id
end