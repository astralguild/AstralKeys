local _, e = ...

local DUNGEON_TABLE = {}

--[[
RUSSIAN
Upper Kara   Верхний Каражан
Lowre Kara   Нижний Каражан
]]

-- Legion Dungeons
DUNGEON_TABLE[197] = {}
DUNGEON_TABLE[197]['name'] = 'Eye of Azshara'
DUNGEON_TABLE[198] = {}
DUNGEON_TABLE[198]['name'] = 'Darkheart Thicket'
DUNGEON_TABLE[199] = {}
DUNGEON_TABLE[199]['name'] = 'Black Rook Hold'
DUNGEON_TABLE[200] = {}
DUNGEON_TABLE[200]['name'] = 'Halls of Valor'
DUNGEON_TABLE[206] = {}
DUNGEON_TABLE[206]['name'] = 'Neltharion\'s Lair'
DUNGEON_TABLE[207] = {}
DUNGEON_TABLE[207]['name'] = 'Vault of the Wardens'
DUNGEON_TABLE[208] = {}
DUNGEON_TABLE[208]['name'] = 'Maw of Souls'
DUNGEON_TABLE[209] = {}
DUNGEON_TABLE[209]['name'] = 'The Arcway'
DUNGEON_TABLE[210] = {}
DUNGEON_TABLE[210]['name'] = 'Court of Stars'
DUNGEON_TABLE[227] = {}
DUNGEON_TABLE[227]['name'] = 'Karazhan: Lower'
DUNGEON_TABLE[233] = {}
DUNGEON_TABLE[233]['name'] = 'Cathedral'
DUNGEON_TABLE[234] = {}
DUNGEON_TABLE[234]['name'] = 'Karazhan: Upper'
DUNGEON_TABLE[239] = {}
DUNGEON_TABLE[239]['name'] = 'Seat, Triumvirate'

-- BfA Dungeons
DUNGEON_TABLE[244] = {}
DUNGEON_TABLE[244]['name'] = 'Atal\'dazar'
DUNGEON_TABLE[245] = {}
DUNGEON_TABLE[245]['name'] = 'Freehold'
DUNGEON_TABLE[246] = {}
DUNGEON_TABLE[246]['name'] = 'Tol Dagor'
DUNGEON_TABLE[247] = {}
DUNGEON_TABLE[247]['name'] = 'The Motherlode'
DUNGEON_TABLE[248] = {}
DUNGEON_TABLE[248]['name'] = 'Waycrest Manor'
DUNGEON_TABLE[249] = {}
DUNGEON_TABLE[249]['name'] = 'King\'s Rest'
DUNGEON_TABLE[250] = {}
DUNGEON_TABLE[250]['name'] = 'Temple of Sethraliss'
DUNGEON_TABLE[251] = {}
DUNGEON_TABLE[251]['name'] = 'The Underrot'
DUNGEON_TABLE[252] = {}
DUNGEON_TABLE[252]['name'] = 'Shrine of the Storm'
DUNGEON_TABLE[253] = {}
DUNGEON_TABLE[244]['name'] = 'Siege of Boralus'

function e.GetMapName(mapID)
	return DUNGEON_TABLE[tonumber(mapID)]['name']
end