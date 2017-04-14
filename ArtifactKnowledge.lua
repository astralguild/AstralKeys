local _, e = ...

local AK_BONUS = {}

AK_BONUS[0] = 1
AK_BONUS[1] = 1.25
AK_BONUS[2] = 1.5
AK_BONUS[3] = 1.9
AK_BONUS[4] = 2.4
AK_BONUS[5] = 3
AK_BONUS[6] = 3.75
AK_BONUS[7] = 4.75
AK_BONUS[8] = 6
AK_BONUS[9] = 7.5
AK_BONUS[10] = 9.5
AK_BONUS[11] = 12
AK_BONUS[12] = 15
AK_BONUS[13] = 18.75
AK_BONUS[14] = 23.5
AK_BONUS[15] = 29.5
AK_BONUS[16] = 37
AK_BONUS[17] = 46.5
AK_BONUS[18] = 58
AK_BONUS[19] = 73
AK_BONUS[20] = 91
AK_BONUS[21] = 114
AK_BONUS[22] = 143
AK_BONUS[23] = 179
AK_BONUS[24] = 224
AK_BONUS[25] = 250
AK_BONUS[26] = 1001
AK_BONUS[27] = 1301
AK_BONUS[28] = 1701
AK_BONUS[29] = 2201
AK_BONUS[30] = 2901
AK_BONUS[31] = 3801
AK_BONUS[32] = 4901
AK_BONUS[33] = 6401
AK_BONUS[34] = 8301
AK_BONUS[35] = 10801
AK_BONUS[36] = 14001
AK_BONUS[37] = 18201
AK_BONUS[38] = 23701
AK_BONUS[39] = 30801
AK_BONUS[40] = 40001
AK_BONUS[41] = 52001
AK_BONUS[42] = 67601
AK_BONUS[43] = 87901
AK_BONUS[44] = 114301
AK_BONUS[45] = 148601
AK_BONUS[46] = 193201
AK_BONUS[47] = 251201
AK_BONUS[48] = 326601
AK_BONUS[49] = 424601
AK_BONUS[50] = 552001

function e.GetAKBonus(akLevel)
	return AK_BONUS[tonumber(akLevel)]
end

function e.ParseAKLevel()
	local amount = select(2, GetCurrencyInfo(1171))
	return amount
end

-- FIRED FOR LEARNING AK
e.RegisterEvent('CURRENCY_DISPLAY_UPDATE', function(...)
	for i = 1, #AstralCharacters do
		if AstralCharacters[i].name == e.PlayerName() then
			AstralCharacters[i].knowledge = e.GetAKBonus(e.ParseAKLevel())
		end
	end
	end)