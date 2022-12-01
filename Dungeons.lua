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

DUNGEON_TABLE[399] = L["Ruby Life Pools"]
DUNGEON_TABLE[400] = L["The Nokhud Offensive"]
DUNGEON_TABLE[401] = L["The Azure Vault"]
DUNGEON_TABLE[402] = L["Algeth'ar Academy"]
DUNGEON_TABLE[210] = L["Court of Stars"]
DUNGEON_TABLE[200] = L["Halls of Valor"]
DUNGEON_TABLE[165] = L["Shadowmoon Burial Grounds"]
DUNGEON_TABLE[2] =   L["Temple of the Jade Serpent"]

DUNGEON_TABLE["400F"] = L["Nokhud Offensive"]
DUNGEON_TABLE["401F"] = L["Azure Vault"]
DUNGEON_TABLE["165F"] = L["Shadowmoon"]
DUNGEON_TABLE["2F"] =   L["Temple"]

function addon.GetMapName(mapID, full)
	return (full and DUNGEON_TABLE[mapID .. "F"]) or DUNGEON_TABLE[mapID]
end
