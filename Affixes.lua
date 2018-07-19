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
	return AFFIXES[2].id
end

function e.AffixTwo(weekOffSet)
	return AFFIXES[3].id
end

function e.AffixThree(weekOffSet)
	return AFFIXES[1].id
end

function e.AffixFour()
	return 0 -- AFFIXES[4].id
end