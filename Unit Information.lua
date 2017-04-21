local _, e = ...

local unitList = {}
local guildList = {}

function e.UpdateGuildList()
	wipe(guildList)
	local name
	for i = 1, GetNumGuildMembers() do
		name = GetGuildRosterInfo(i)
		if not name then return end
		name = Ambiguate(name, 'guild')
		guildList[name] = true
	end
end

function e.UnitInGuild(unit)
	return guildList[unit]
end

function e.SetUnitID(unit, unitID)
	unitList[unit] = unitID
end

function e.GetUnitID(unit)
	return unitList[unit]
end

function e.WipeUnitList()
	wipe(unitList)
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

e.RegisterEvent('GUILD_ROSTER_UPDATE', function() e.UpdateGuildList() end)