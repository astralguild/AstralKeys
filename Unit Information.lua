local _, e = ...

local unitList = {}
local guildList = {}

-- Puts all guild member's into a table for checking if unit in guild

local function UpdateGuildList()
	wipe(guildList)
	local name
	for i = 1, GetNumGuildMembers() do
		name = GetGuildRosterInfo(i)
		if not name then return end
		guildList[name] = true
	end
end

-- Checks to see if a unit is in the player's guild
-- @param unit Unit name and server
function e.UnitInGuild(unit)
	return guildList[unit] or false
end

-- Sets a number to a unit for quicker access to table
-- @param unit  Unit name and server
-- @param unitID integer value
function e.SetUnitID(unit, unitID)
	unitList[unit] = unitID
end

-- Retrieves ID number for associated unit
-- @param unit Unit name and server
function e.UnitID(unit)
	return unitList[unit]
end

-- Clears unit list
function e.WipeUnitList()
	wipe(unitList)
end

-- Retrieves unit's realm
-- @param unit id
function e.UnitRealm(id)
	return AstralKeys[id][1]:sub(AstralKeys[id][1]:find('-') + 1)
end

function e.UnitName(index)
	return Ambiguate(AstralKeys[index][1], 'GUILD')
end

--Gets unit class from saved variables
function e.UnitClass(id)
	return AstralKeys[id][2]
end

AstralEvents:Register('GUILD_ROSTER_UPDATE', UpdateGuildList, 'guildUpdate')