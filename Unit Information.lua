local _, e = ...

local UNIT_LIST = {}
local GUILD_LIST = {}

-- Puts all guild member's into a table for checking if unit in same guild, stores value as rankIndex for filtering by rank
local function UpdateGuildList()
	wipe(GUILD_LIST)

	for i = 1, GetNumGuildMembers() do
		local name, _, rankIndex, _, _, _, _, _, connected = GetGuildRosterInfo(i)
		local guid = select(17, GetGuildRosterInfo(i))
		if not name then return end
		GUILD_LIST[name] = {rank = rankIndex + 1, isConnected = connected, guid = guid}
	end
end
AstralEvents:Register('GUILD_ROSTER_UPDATE', UpdateGuildList, 'guildUpdate')

-- Checks to see if a unit is in the player's guild
-- @param unit Unit name and server
function e.UnitInGuild(unit)
	return GUILD_LIST[unit] or false
end

function e.GuildMemberOnline(unit)
	if not GUILD_LIST[unit] then return false
	else
		return GUILD_LIST[unit].isConnected
	end
end

function e.GuildMemberRank(unit)
	if not GUILD_LIST[unit] then return false
	else
		return GUILD_LIST[unit].rank
	end
end

function e.GuildMemberGuid(unit)
	if not GUILD_LIST[unit] then return nil
	else
		return GUILD_LIST[unit].guid
	end
end

-- Sets a number to a unit for quicker access to table
-- @param unit  Unit name and server
-- @param unitID integer value
function e.SetUnitID(unit, unitID)
	UNIT_LIST[unit] = unitID
end

-- Retrieves ID number for associated unit
-- @param unit Unit name and server
function e.UnitID(unit)
	return UNIT_LIST[unit] or false
end

function e.UnitName(id)
	return AstralKeys[id][1]:sub(1, AstralKeys[id][1]:find('-') - 1)
end

function e.Unit(id)
	return AstralKeys[id][1]
end

-- Clears unit list
function e.WipeUnitList()
	wipe(UNIT_LIST)
end

--Gets unit class from saved variables
-- @param id int ID number for the unit
function e.UnitClass(id)
	if not id then return nil end
	return AstralKeys[id][2]
end

function e.UnitKeyLevel(id)
	if not id then return nil end
	return AstralKeys[id][4]
end

function e.UnitMapID(id)
	if not id then return nil end
	return AstralKeys[id][3]
end