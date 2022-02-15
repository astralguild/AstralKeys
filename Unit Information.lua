local _, addon = ...

local UNIT_LIST = {}

-- Sets a number to a unit for quicker access to table
-- @param unit  Unit name and server
-- @param unitID integer value
function addon.SetUnitID(unit, unitID)
	UNIT_LIST[unit] = unitID
end

-- Retrieves ID number for associated unit
-- @param unit Unit name and server
function addon.UnitID(unit)
	return UNIT_LIST[unit] or nil
end

function addon.UnitName(id)
	return AstralKeys[id].unit:sub(1, AstralKeys[id].unit:find('-') - 1)
end

function addon.Unit(id)
	return AstralKeys[id].unit
end

function addon.UnitBTag(id)
	return AstralKeys[id].btag
end

function addon.UnitGUID(unit)
	return addon.GuildMemberGuid(unit) or addon.FriendGUID(unit)
end

function addon.IsUnitOnline(unit)
	return addon.GuildMemberOnline(unit) or addon.IsFriendOnline(unit)
end

-- Clears unit list
function addon.WipeUnitList()
	wipe(UNIT_LIST)
end

--Gets unit class from saved variables
-- @param id int ID number for the unit
function addon.UnitClass(id)
	if not id then return nil end
	return AstralKeys[id].class
end

function addon.UnitKeyLevel(id)
	if not id then return nil end
	return AstralKeys[id].key_level
end

function addon.UnitMapID(id)
	if not id then return nil end
	return AstralKeys[id].dungeon_id
end

function addon.UnitWeeklyBest(id)
	if not id then return nil end
	return AstralKeys[id].weekly_best
end