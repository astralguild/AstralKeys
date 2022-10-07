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

function addon.GetMapName(mapID, full)
	return (full and DUNGEON_TABLE[mapID .. "F"]) or DUNGEON_TABLE[mapID]
end
