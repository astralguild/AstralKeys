local e, L = unpack(select(2, ...))

local UNIT_LIST = {}

-- Sets a number to a unit for quicker access to table
-- @param unit  Unit name and server
-- @param unitID integer value
function e.SetUnitID(unit, unitID)
	UNIT_LIST[unit] = unitID
end

-- Retrieves ID number for associated unit
-- @param unit Unit name and server
function e.UnitID(unit)
	return UNIT_LIST[unit] or nil
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

function e.UnitBestKey(id)
	if not id then return nil end
	return AstralKeys[id][9]
end