local _, e = ...

local unitList = {}

function e.SetUnitID(unit, unitID)
	unitList[unit] = unitID
end

function e.GetUnitID(unit)
	return unitList[unit]
end

function e.UnitRealm(unit)
	for i = 1, #AstralKeys do
		if AstralKeys[i].name == unit then
			return AstralKeys[i].realm
		end
	end
end

function e.UnitID(unit)
	for i = 1, #AstralKeys do
		if AstralKeys[i].name == unit then
			return i
		end
	end
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

