local _, addon = ...
local L = addon.L

local DUNGEON_TABLE = {}

-- Shadowlands Dungeons

DUNGEON_TABLE[169] = L["Iron Docks"]
DUNGEON_TABLE[166] = L["Grimrail Depot"]
DUNGEON_TABLE[227] = L["Lower Karazhan"]
DUNGEON_TABLE[234] = L["Upper Karazhan"]
DUNGEON_TABLE[370] = L["Mechagon Workshop"]
DUNGEON_TABLE[369] = L["Mechagon Junkyard"]
DUNGEON_TABLE[391] = L["Streets of Wonder"]
DUNGEON_TABLE[392] = L["So'leah's Gambit"]


DUNGEON_TABLE["227F"] = L["Return to Karazhan: Lower"]
DUNGEON_TABLE["234F"] = L["Return to Karazhan: Upper"]
DUNGEON_TABLE["370F"] = L["Operation: Mechagon - Workshop"]
DUNGEON_TABLE["369F"] = L["Operation: Mechagon - Junkyard"]
DUNGEON_TABLE["391F"] = L["Tazavesh: Streets of Wonder"]
DUNGEON_TABLE["392F"] = L["Tazavesh: So'leah's Gambit"]

-- Dragonflight Dungeons

DUNGEON_TABLE[399] = L["Ruby Life Pools"]
DUNGEON_TABLE[400] = L["The Nokhud Offensive"]
DUNGEON_TABLE[401] = L["The Azure Vault"]
DUNGEON_TABLE[402] = L["Algeth'ar Academy"]
DUNGEON_TABLE[210] = L["Court of Stars"]
DUNGEON_TABLE[200] = L["Halls of Valor"]
DUNGEON_TABLE[165] = L["Shadowmoon Burial Grounds"]
DUNGEON_TABLE[2] =   L["Temple of the Jade Serpent"]

DUNGEON_TABLE["400F"] = L["The Nokhud Offensive"]
DUNGEON_TABLE["401F"] = L["The Azure Vault"]
DUNGEON_TABLE["165F"] = L["Shadowmoon Burial Grounds"]
DUNGEON_TABLE["2F"] =   L["Temple of the Jade Serpent"]

DUNGEON_TABLE[403] = L["Uldaman: Legacy of Tyr"]
DUNGEON_TABLE[404] = L["Neltharus"]
DUNGEON_TABLE[405] = L["Brackenhide Hollow"]
DUNGEON_TABLE[406] = L["Halls of Infusion"]
DUNGEON_TABLE[438] = L["The Vortex Pinnacle"]
DUNGEON_TABLE[206] = L["Neltharion's Lair"]
DUNGEON_TABLE[245] = L["Freehold"]
DUNGEON_TABLE[251] = L["The Underrot"]

DUNGEON_TABLE["463F"] = L["Dawn of the Infinite: Galakrond's Fall"]
DUNGEON_TABLE[463] = L["DotI: Galakrond's Fall"]
DUNGEON_TABLE["464F"] = L["Dawn of the Infinite: Murozond's Rise"]
DUNGEON_TABLE[464] = L["DotI: Murozond's Rise"]
DUNGEON_TABLE[244] = L["Atal'Dazar"]
DUNGEON_TABLE[248] = L["Waycrest Manor"]
DUNGEON_TABLE[198] = L["Darkheart Thicket"]
DUNGEON_TABLE[199] = L["Black Rook Hold"]
DUNGEON_TABLE[168] = L["The Everbloom"]
DUNGEON_TABLE[456] = L["Throne of the Tides"]

function addon.GetMapName(mapID, full)
	if not mapID then return nil end
	return (full and DUNGEON_TABLE[mapID .. "F"]) or DUNGEON_TABLE[mapID]
end