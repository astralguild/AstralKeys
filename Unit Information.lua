local _, e = ...

local unitList = {}
local guildList = {}

-- Puts all guild member's into a table for checking if unit in guild

function e.UpdateGuildList()
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

function e.UnitInGuild(unit, realm)
	return guildList[string.format('%s-%s', unit, realm)]
end

-- Sets a number to a unit for quicker access to table
-- @param unit  Unit name and server
-- @param unitID integer value

function e.SetUnitID(unit, realm, unitID)
	Console:AddLine('AK', unit .. realm)
	local string = string.format('%s-%s', unit, realm)
	unitList[string] = unitID
end

-- Retrieves ID number for associated unit
-- @param unit Unit name and server

function e.GetUnitID(unit, realm)
	if realm then
		return unitList[string.format('%s-%s', unit, realm)]
	else
		return unitList[unit]
	end
end

-- Clears unit list

function e.WipeUnitList()
	wipe(unitList)
end

-- Retrieves unit's realm
-- @param unit id

function e.UnitRealm(id)
	return AstralKeys[id].realm
end

function e.UnitName(index)
	return AstralKeys[index].name
end

--Gets unit class from saved variables
function e.UnitClass(id)
	return AstralCharacters[id].class
end

function e.GetColoredClassText(index)
	return WrapTextInColor(AstralKeys[index].name , GetClassColor(AstralKeys[index].class))
end

e.RegisterEvent('GUILD_ROSTER_UPDATE', function() e.UpdateGuildList() end)