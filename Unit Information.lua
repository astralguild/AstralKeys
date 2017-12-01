local _, e = ...

local UNIT_LIST = {}
local guildList = {}

-- Puts all guild member's into a table for checking if unit in same guild, stores value as rankIndex for filtering by rank
local function UpdateGuildList()
	wipe(guildList)
	local name, rankIndex
	for i = 1, GetNumGuildMembers() do
		name, _, rankIndex = GetGuildRosterInfo(i)
		if not name then return end
		guildList[name] = rankIndex
	end
end
AstralEvents:Register('GUILD_ROSTER_UPDATE', UpdateGuildList, 'guildUpdate')

-- Checks to see if a unit is in the player's guild
-- @param unit Unit name and server
function e.UnitInGuild(unit)
	return guildList[unit] or false
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

-- Clears unit list
function e.WipeUnitList()
	wipe(UNIT_LIST)
	UNIT_LIST['GUILD'] = {}
	UNIT_LIST['BNET'] = {}
	UNIT_LIST['FRIEND'] = {}
end

-- Retrieves unit from database
-- @param id int ID for said unit
-- @return str Unit name and realm, ex  'Phrike-Turalyon'
function e.Unit(id)
	return AstralKeys[id][1]
end

-- Retrieves unit's realm from unit string
-- @param id int for unit
function e.UnitRealm(id)
	return AstralKeys[id][1]:sub(AstralKeys[id][1]:find('-') + 1)
end

-- Returns Character name with server name removed
-- @param id int ID number for unit
-- @return Unit name with server name removed
function e.UnitName(index)
	return Ambiguate(AstralKeys[index][1], 'GUILD')
end

--Gets unit class from saved variables
-- @param id int ID number for the unit
function e.UnitClass(id)
	return AstralKeys[id][2]
end

-- TEST LATER
function e.AddUnitKey(...)
	if not AstralKeys[list] then AstralKeys[list] = {} end
	table.insert(AstralKeys[list], {...})
end

function e.UpdateUnitKey(list, btag, id, dungeonID, keyLevel, weekly, week, timeStamp)
	if week >= e.Week then -- Does the key belong to this week or last's?
		if AstralKeys[list][id][7] < timeStamp then
			AstralKeys[list][id][3] = dungeonID
			AstralKeys[list][id][4] = keyLevel
			AstralKeys[list][id][6] = week
			AstralKeys[list][id][7] = timeStamp
		end
	else
		AstralKeys[list][id] = nil
	end
end