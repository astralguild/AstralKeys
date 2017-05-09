local _, e = ...

local playerClass, playerName, numArtifacts, akBonus, characterID, playerID, playerRealm

function e.CharacterID()
	return characterID
end

function e.SetCharacterID()
	characterID = e.GetCharacterID(e.PlayerName())
end

function e.SetPlayerID()
	playerID = e.GetUnitID(e.PlayerName() .. '-' .. e.PlayerRealm())
end

function e.CharacterAK(id)
	return AstralCharacters[id].knowledge
end

function e.CharacterRealm(id)
	return AstralCharacters[id].realm
end

function e.CharacterName(id)
	return AstralCharacters[id].name
end

function e.GetCharacterID(unit)
	for i = 1, #AstralCharacters do
		if AstralCharacters[i].name == unit then
			return i
		end
	end
end

function e.CharacterClass(id)
	return AstralCharacters[id].class
end

function e.PlayerID()
	return playerID
end

function e.SetPlayerName()
	playerName = UnitName('player')
end

function e.PlayerRealm()
	return playerRealm
end

function e.SetPlayerRealm()
	playerRealm = GetRealmName()
end

function e.SetPlayerClass()
	playerClass = select(2, UnitClass('player'))
end

function e.PlayerClass()
	return playerClass
end

function e.PlayerName()
	return playerName
end
