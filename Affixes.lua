local ADDON, e = ...

local AFFIXES = {}

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