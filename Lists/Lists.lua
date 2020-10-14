local e, L = unpack(select(2, ...))

if not AstralLists then
	AstralLists = {}
end

-- Names saved that can't be used for another list
local SAVED_NAMES = {}
SAVED_NAMES[L['GUILD']] = true
SAVED_NAMES[L['FRIENDS']] = true

local function DoesListExist(listName)
	if not listName then return end

	for i = 1, #AstralLists do
		if AstralLists[i].name == listName then
			return true, i
		end
	end

	return false
end


-- Creates a new list
-- @param listName string The name of the list to be created
-- @return boolean Returns true if the list was created, false otherwise
function e.CreateNewList(listName)
	if not listName then
		error('Astral Keys: CreateNewList(listName) listName expected, received ' .. type(listName))
	end

	if DoesListExist(listName) then
		return false
	end

	local tbl = {}
	tbl['name'] = listName
	tbl['units'] = {}

	table.insert(AstralLists, tbl)

	return true
end

function e.DeleteList(targetListName)
	if not targetListName or type(targetListName) ~= 'string' then
		error('AstralKeys DeleteList(targetListName) targetListName expected, received ' .. type(targetListName))
	end

	for i = 1, #AstralLists do
		if AstralLists[i].name == targetListName then
			table.remove(AstralLists, i)
			break
		end
	end
end

function e.DoesListExist(list)
	if not list or type(list) ~= 'string' then
		error('AstralKeys DoesListExist(list) String expected, recieved ' .. type(list))
	end

	for i = 1, #AstralLists do
		if AstralLists[i].name == list then
			return true
		end
	end

	return false
end

function e.GetListCount(list)
	if not list or type(list) ~= 'string' then
		error('AstralKeys GetListCount(list) String expected, received ' .. type(list))
	end

	local count = 0

	if e.DoesListExist(list) then
		for i = 1, #AstralLists do
			if AstralLists[i].name == list then
				for unit in pairs(AstralLists[i].units) do
					count = count + 1
				end
			end
		end
	end

	return count
end

function e.AddUnitToList(unit, listName, btag)
	if not listName then
		error('Astral Keys: AddUnitToList(unit, btag, listName) listName expected, received ' .. type(listName))
	end
	if not unit then
		error('Astral Keys: AddUnitToList(unit, btag, listName) unit expected, received ' .. type(unit))
	end

	local unitID = e.UnitID(unit)

	btag = e.UnitBTag(unitID)

	for i = 1, #AstralLists do
		if AstralLists[i].name == listName then
			AstralLists[i].units[unit] = btag or true
			return true
		end
	end

	return false
end

function e.RemoveUnitFromList(unit, listName)
	if not listName then
		error('Astral Keys: RemoveUnitFromList(unit, btag, listName) listName expected, received ' .. type(listName))
	end
	if not unit then
		error('Astral Keys: RemoveUnitFromList(unit, btag, unit) unit expected, received ' .. type(unit))
	end

	for i = 1, #AstralLists do
		if AstralLists[i].name == listName then
			AstralLists[i].units[unit] = nil
			break
		end
	end
end

local function GetListUnits(listName)
	if not listName then return end

	for i = 1, #AstralLists do
		if AstralLists[i].name == listName then
			return AstralLists[i].units
		end
	end
end

function e.DoesUnitBelongToList(unitName, listName)
	if not unitName then
		error('AstralKeys: DoesUnitBelongToList(unitName, listName) unitName expected, received ' .. type(unitName))
	end
	if not listName then
		error('AstralKeys: DoesUnitBelongToList(unitName, listName) listName expected, received ' .. type(listName))
	end

	if not DoesListExist(listName) then
		return false
	end

	for list = 1, #AstralLists do
		if AstralLists[list].name == listName then
			if AstralLists[list].units[unitName] then
				return true
			end
		end
	end

	return false

end

local function GetLists()
	local tbl = {}

	for i = 1, AstralLists do
		table.insert(tbl, AstralLists[i].name)
	end

	return tbl
end

e.CreateNewList('GUILD')
e.CreateNewList('FRIENDS')