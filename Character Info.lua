local e, L = unpack(select(2, ...))

local playerClass, characterID
local playerNameRealm = UnitName('player') .. '-' .. GetRealmName():gsub("%s+", "")
local characterList = {}

function e.SetCharacterID(unit, unitID)
	characterList[unit] = unitID
end

function e.GetMinimumItemLevel()
	local minitemlvl = 9999
	for i = 1, 18 do
		local itemLink = GetInventoryItemLink("player", i)
		local effectiveILvl, isPreview, baseILvl = GetDetailedItemLevelInfo(itemLink or "")

		if effectiveILvl then
			if minitemlvl > effectiveILvl then
				minitemlvl = effectiveILvl
			end
		end
	end
	if minitemlvl < 9999 then
		return minitemlvl
	else
		return 0
	end
end

function e.UpdateAstralGear(maxLevel)
	wipe(AstralGear)
	for i = 1, maxLevel do
		local rewardWeekly, rewardDaily = C_MythicPlus.GetRewardLevelForDifficultyLevel(i)
		table.insert(AstralGear, {weekly = rewardWeekly, daily = rewardDaily})
	end
end

function e.SetLowestGear()
	e.lowestGear = e.GetMinimumItemLevel()
end

function e.UpdateCharacterIDs()
	wipe(characterList)
	for i = 1, #AstralCharacters do
		characterList[AstralCharacters[i].unit] = i
	end
end

-- Retrieves character's realm
-- @return string Realm name for character
function e.CharacterRealm(id)
	return AstralCharacters[id].unit:sub(AstralCharacters[id].unit:find('-') + 1)
end

-- Retrieves character's name
-- @return string Character's name
function e.CharacterName(id)
	return AstralCharacters[id].unit:sub(1, AstralCharacters[id].unit:find('-') - 1)
end

-- Retrieves character ID
-- unit string Character name
-- @return int Returns id number or false if character isn't indexed
function e.GetCharacterID(unit)
	return characterList[unit] or false
end

-- Retrieves character class
-- id int ID for character
-- @return string Non-localized class name, used for text colouring
function e.GetCharacterClass(id)
	return AstralCharacters[id].class
end

-- Retrieves character's highest run Mythic+
-- @param id int ID for character
-- @return int Highest mythic+ ran for the week
-- @return int 0 implies no key run for the week
function e.GetCharacterBestLevel(id)
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
function e.GetCharacterBestMap(id)
	if AstralCharacters[id] and AstralCharacters[id].map then
		return AstralCharacters[id].map
	else
		return nil
	end
end

-- Retrieves faction for character
-- @param id int ID for the character
-- @return string Non-localized faction name
function e.GetCharacterFaction(id)
	return AstralCharacters[id].faction
end

-- Clears character IDs
function e.WipeCharacterList()
	wipe(characterList)
end

-- Sets player name-realm
function e.SetPlayerNameRealm()
	playerNameRealm = UnitName('player') .. '-' .. GetRealmName():gsub("%s+", "")
end

-- Retrieves player's realm
-- @return string Realm name for player
function e.PlayerRealm()
	return playerNameRealm:sub(playerNameRealm:find('-') + 1)
end

-- Sets player realm variable
function e.SetPlayerRealm()
	playerRealm = GetRealmName():gsub("%s+", "")
end

-- Player's name
-- @return string Player's current logged in character's name without guild attached
function e.PlayerName()
	return Ambiguate(playerNameRealm, 'GUILD')
end

-- Sets player class variable
function e.SetPlayerClass()
	playerClass = select(2, UnitClass('player'))
end

-- Retrieves player's class
-- @return string Non-localized class name, used for text colouring
function e.PlayerClass()
	return playerClass
end

-- Retrieves player's name for logged in character
-- @return string Name of player with realm attached
function e.Player()
	return playerNameRealm
end

function e.GetCharacterMapID(unit)
	if not unit then return nil end

	local id = e.UnitID(unit)

	if id then
		return AstralKeys[id].dungeon_id
	else
		return nil
	end
end

function e.GetCharacterKeyLevel(unit)
	if not unit then return nil end

	local id = e.UnitID(unit)

	if id then
		return AstralKeys[id].key_level
	else
		return nil
	end
end