local _, addon = ...
local L = addon.L
local strformat = string.format

local COLOUR = {}
COLOUR[1] = 'ffffffff' -- Common
COLOUR[2] = 'ff0070dd' -- Rare
COLOUR[3] = 'ffa335ee' -- Epic
COLOUR[4] = 'ffff8000' -- Legendary
COLOUR[5] = 'ffe6cc80' -- Artifact

addon.MYTHICKEY_ITEMID = 180653
addon.TIMEWALKINGKEY_ITEMID = 187786

local MapIds = {}

local function UpdateWeekly()
	addon.UpdateCharacterBest()
	local characterID = addon.GetCharacterID(addon.Player())
	local characterWeeklyBest = addon.GetCharacterBestLevel(characterID)
	if IsInGuild() then
		AstralComs:NewMessage('AstralKeys', 'updateWeekly ' .. characterWeeklyBest, 'GUILD')
	else
		local id = addon.UnitID(addon.Player())
		if id then
			AstralKeys[id].weekly_best = characterWeeklyBest
			addon.UpdateFrames()
		end
	end
	addon.UpdateCharacterFrames()
end

local dataInitialized
local function InitData()
	MapIds = C_ChallengeMode.GetMapTable()
	C_MythicPlus.RequestRewards()
	AstralEvents:Unregister('PLAYER_ENTERING_WORLD', 'initData')
	C_ChatInfo.RegisterAddonMessagePrefix('AstralKeys')
	addon.FindKeyStone(true, false)
	addon.UpdateCharacterBest()
	if IsInGuild() then
		AstralComs:NewMessage('AstralKeys', 'request', 'GUILD')
	end

	if UnitLevel('player') < addon.EXPANSION_LEVEL then return end
	AstralEvents:Register('CHALLENGE_MODE_MAPS_UPDATE', UpdateWeekly, 'weeklyCheck')
	dataInitialized = true
end
AstralEvents:Register('PLAYER_ENTERING_WORLD', InitData, 'initData')


--|cffa335ee|Hkeystone:158923:251:12:10:5:13:117|h[Keystone: The Underrot (12)]|h|r
-- COLOUR[3] returns epic color hex code
function addon.CreateKeyLink(mapID, keyLevel)
	local mapName
	if mapID == 369 or mapID == 370 then
		mapName = C_ChallengeMode.GetMapUIInfo(mapID)		
	else
		mapName = addon.GetMapName(mapID, true)
	end
	local thisAff1, thisAff2, thisAff3, thisAff4 = 0
	if keyLevel > 1 then
	 thisAff1 = addon.AffixOne()
	end
	if keyLevel > 3 then
	 thisAff2 = addon.AffixTwo()
	end
	if keyLevel > 6 then
	 thisAff3 = addon.AffixThree()
	end
	if keyLevel > 8 then
	 thisAff4 = addon.AffixFour()
	end
	local covenantID = C_Covenants.GetActiveCovenantID()
	local covenantData = C_Covenants.GetCovenantData(covenantID)
	if (covenantData) then
		return strformat('|c' .. COLOUR[3] .. '|Hkeystone:%d:%d:%d:%d:%d:%d:%d|h[%s %s (%d)]|h|r (%s)', addon.MYTHICKEY_ITEMID, mapID, keyLevel, thisAff1, thisAff2, thisAff3, thisAff4, L['KEYSTONE'], mapName, keyLevel, covenantData.name):gsub('\124\124', '\124')
	else
		return strformat('|c' .. COLOUR[3] .. '|Hkeystone:%d:%d:%d:%d:%d:%d:%d|h[%s %s (%d)]|h|r', addon.MYTHICKEY_ITEMID, mapID, keyLevel, thisAff1, thisAff2, thisAff3, thisAff4, L['KEYSTONE'], mapName, keyLevel):gsub('\124\124', '\124')
	end
end

-- Prints out the same link as the CreateKeyLink but only if the Timewalking Key is found. Otherwise nothing is done.
function addon.CreateTimewalkingKeyLink(mapID, keyLevel)
   local mapName = addon.GetMapName(mapID, true)
   local thisAff1, thisAff2, thisAff3, thisAff4 = 0
	if keyLevel > 1 then
	 thisAff1 = addon.TimewalkingAffixOne()
	end
	if keyLevel > 3 then
	 thisAff2 = addon.TimewalkingAffixTwo()
	end
	if keyLevel > 6 then
	 thisAff3 = addon.TimewalkingAffixThree()
	end
	if keyLevel > 8 then
	 thisAff4 = addon.TimewalkingAffixFour()
	end
	return strformat('|c' .. COLOUR[3] .. '|Hkeystone:%d:%d:%d:%d:%d:%d:%d|h[%s %s (%d)]|h|r', addon.TIMEWALKINGKEY_ITEMID, mapID, keyLevel, thisAff1, thisAff2, thisAff3, thisAff4, L['KEYSTONE'], mapName, keyLevel):gsub('\124\124', '\124')
end


AstralEvents:Register('CHALLENGE_MODE_COMPLETED', function()
	C_Timer.After(3, function()
		C_MythicPlus.RequestRewards()
		addon.FindKeyStone(true, true)
	end)
end, 'dungeonCompleted')

function addon.FindKeyStone(sendUpdate, anounceKey)
	if UnitLevel('player') < addon.EXPANSION_LEVEL then return end

	local mapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID()
	local keyLevel = C_MythicPlus.GetOwnedKeystoneLevel()
	local weeklyBest = 0
	local runHistory = C_MythicPlus.GetRunHistory(false, true)

	for i = 1, #runHistory do
		if runHistory[i].thisWeek then
			if runHistory[i].level > weeklyBest then
				weeklyBest = runHistory[i].level
			end
		end
	end

	local msg = ''

	if mapID then 
		msg = string.format('%s:%s:%d:%d:%d:%d:%s', addon.Player(), addon.PlayerClass(), mapID, keyLevel, weeklyBest, addon.Week, addon.FACTION)
	end

	local oldMap, oldLevel = addon.UnitMapID(addon.UnitID(addon.Player())), addon.UnitKeyLevel(addon.UnitID(addon.Player()))

	if sendUpdate and msg ~= '' then
		addon.PushKeyDataToFriends(msg)
		if IsInGuild() then
			AstralComs:NewMessage('AstralKeys', strformat('%s %s', addon.UPDATE_VERSION, msg), 'GUILD')
		else -- Not in a guild, who are you people? Whatever, gotta make it work for them as well
			local id = addon.UnitID(addon.Player())
			if id then -- Are we in the DB already?
				AstralKeys[id].dungeon_id = tonumber(mapID)
				AstralKeys[id].key_level = tonumber(keyLevel)
				AstralKeys[id].week = addon.Week
				AstralKeys[id].time_stamp = addon.WeekTime()
			else -- Nope, ok, let's add them to the DB manually.
				AstralKeys[#AstralKeys + 1] = {
					unit = addon.Player(),
					class = addon.PlayerClass(),
					dungeon_id = tonumber(mapID),
					key_level = tonumber(keyLevel),
					week = addon.Week,
					time_stamp = addon.WeekTime(),
				}
				addon.SetUnitID(addon.Player(), #AstralKeys)
			end
		end
	end
	msg = nil

	-- Ok, time to check if we need to announce a new key or not
	if tonumber(oldMap) == tonumber(mapID) and tonumber(oldLevel) == tonumber(keyLevel) then return end

	if anounceKey then
		addon.AnnounceNewKey(addon.CreateKeyLink(mapID, keyLevel))
	end
end

-- Finds best map clear fothe week for logged on character. If character already is in database
-- updates the information, else creates new entry for character
function addon.UpdateCharacterBest()
	if UnitLevel('player') < addon.EXPANSION_LEVEL then return end

	local weeklyBest = 0
	local runHistory = C_MythicPlus.GetRunHistory(false, true)


	for i = 1, #runHistory do
		if runHistory[i].thisWeek then
			if runHistory[i].level > weeklyBest then
				weeklyBest = runHistory[i].level
			end
		end
	end

	local found = false

	for i = 1, #AstralCharacters do
		if AstralCharacters[i].unit == addon.Player() then
			found = true
			AstralCharacters[i].weekly_best = weeklyBest
			break
		end
	end

	if not found then
		table.insert(AstralCharacters, { unit = addon.Player(), class = addon.PlayerClass(), weekly_best = weeklyBest, faction = addon.FACTION})
		addon.SetCharacterID(addon.Player(), #AstralCharacters)
	end
end

local function MythicPlusStart()
	addon.FindKeyStone(true, false)
end

AstralEvents:Register('CHALLENGE_MODE_START', MythicPlusStart, 'PlayerEnteredMythic')

function addon.GetDifficultyColour(keyLevel)
	if type(keyLevel) ~= 'number' then return COLOUR[1] end -- return white for any strings or non-number values
	if keyLevel <= 4 then
		return COLOUR[1]
	elseif keyLevel <= 9 then
		return COLOUR[2]
	elseif keyLevel <= 14 then
		return COLOUR[3]
	elseif keyLevel <= 19 then
		return COLOUR[4]
	else
		return COLOUR[5]
	end
end

local lastKey
AstralEvents:Register('BAG_UPDATE', function()
	for bagId = 0, 4 do
		for slot = 1, GetContainerNumSlots(bagId) do
			local itemID = GetContainerItemID(bagId, slot)
			if (addon.MYTHICKEY_ITEMID == itemID) then
				local itemLink = GetContainerItemLink(bagId, slot)
				if (dataInitialized) then
					if (itemLink ~= lastKey) then
						addon.FindKeyStone(true, false)
					end
				end
				lastKey = itemLink
			end
		end
	end
end, 'bagUpdateKeyScan')
