local _, addon = ...

local playerClass
local playerNameRealm = UnitName('player') .. '-' .. GetRealmName():gsub("%s+", "")
local characterList = {}

function addon.SetCharacterID(unit, unitID)
	characterList[unit] = unitID
end

function addon.UpdateCharacterIDs()
	wipe(characterList)
	for i = 1, #AstralCharacters do
		characterList[AstralCharacters[i].unit] = i
	end
end

-- Retrieves character's realm
-- @return string Realm name for character
function addon.CharacterRealm(id)
	return AstralCharacters[id].unit:sub(AstralCharacters[id].unit:find('-') + 1)
end

-- Retrieves character's name
-- @return string Character's name
function addon.CharacterName(id)
	return AstralCharacters[id].unit:sub(1, AstralCharacters[id].unit:find('-') - 1)
end

-- Retrieves character ID
-- unit string Character name
-- @return int Returns id number or false if character isn't indexed
function addon.GetCharacterID(unit)
	return characterList[unit] or false
end

-- Retrieves character class
-- id int ID for character
-- @return string Non-localized class name, used for text colouring
function addon.GetCharacterClass(id)
	return AstralCharacters[id].class
end

-- Retrieves character's highest run Mythic+
-- @param id int ID for character
-- @return int Highest mythic+ ran for the week
-- @return int 0 implies no key run for the week
function addon.GetCharacterBestLevel(id)
	if AstralCharacters[id] and AstralCharacters[id].weekly_best then
		return AstralCharacters[id].weekly_best
	else
		return nil
	end
end

-- Retrieves character's mapID for highest ran mythic+ for the week
-- @param id int ID for the character
-- @return int mapID for the highest ran mythic+ for the week
-- @return int 0 implies no key run for the week
function addon.GetCharacterBestMap(id)
	if AstralCharacters[id] and AstralCharacters[id].map then
		return AstralCharacters[id].map
	else
		return nil
	end
end

-- Retrieves faction for character
-- @param id int ID for the character
-- @return string Non-localized faction name
function addon.GetCharacterFaction(id)
	return AstralCharacters[id].faction
end

-- Clears character IDs
function addon.WipeCharacterList()
	wipe(characterList)
end

-- Sets player name-realm
function addon.SetPlayerNameRealm()
	playerNameRealm = UnitName('player') .. '-' .. GetRealmName():gsub("%s+", "")
end

-- Retrieves player's realm
-- @return string Realm name for player
function addon.PlayerRealm()
	return playerNameRealm:sub(playerNameRealm:find('-') + 1)
end

-- Sets player realm variable
function addon.SetPlayerRealm()
	playerRealm = GetRealmName():gsub("%s+", "")
end

-- Player's name
-- @return string Player's current logged in character's name without guild attached
function addon.PlayerName()
	return Ambiguate(playerNameRealm, 'GUILD')
end

-- Sets player class variable
function addon.SetPlayerClass()
	playerClass = select(2, UnitClass('player'))
end

-- Retrieves player's class
-- @return string Non-localized class name, used for text colouring
function addon.PlayerClass()
	return playerClass
end

-- Retrieves player's name for logged in character
-- @return string Name of player with realm attached
function addon.Player()
	return playerNameRealm
end

function addon.GetCharacterMapID(unit)
	if not unit then return nil end

	local id = addon.UnitID(unit)
	
	if id then 
		return AstralKeys[id].dungeon_id
	else
		return nil
	end
end

function addon.GetCharacterKeyLevel(unit)
	if not unit then return nil end

	local id = addon.UnitID(unit)

	if id then 
		return AstralKeys[id].key_level
	else
		return nil
	end
end