local e, L = unpack(select(2, ...))
local strformat = string.format

local COLOUR = {}
COLOUR[1] = 'ffffffff' -- Common
COLOUR[2] = 'ff0070dd' -- Rare
COLOUR[3] = 'ffa335ee' -- Epic
COLOUR[4] = 'ffff8000' -- Legendary
COLOUR[5] = 'ffe6cc80' -- Artifact

e.MYTHICKEY_ITEMID = 180653

local MapIds = {}

local function UpdateWeekly()
	e.UpdateCharacterBest()
	local characterID = e.GetCharacterID(e.Player())
	local characterWeeklyBest = e.GetCharacterBestLevel(characterID)
	if IsInGuild() then
		AstralComs:NewMessage('AstralKeys', 'updateWeekly ' .. characterWeeklyBest, 'GUILD')
	else
		local id = e.UnitID(e.Player())
		if id then
			AstralKeys[id].weekly_best = characterWeeklyBest
			e.UpdateFrames()
		end
	end
	e.UpdateCharacterFrames()
end

local dataInitialized
local function InitData()
	MapIds = C_ChallengeMode.GetMapTable()
	C_MythicPlus.RequestRewards()
	AstralEvents:Unregister('PLAYER_ENTERING_WORLD', 'initData')
	C_ChatInfo.RegisterAddonMessagePrefix('AstralKeys')
	e.FindKeyStone(true, false)
	e.UpdateCharacterBest()
	if IsInGuild() then
		AstralComs:NewMessage('AstralKeys', 'request', 'GUILD')
	end

	if UnitLevel('player') < e.EXPANSION_LEVEL then return end
	AstralEvents:Register('CHALLENGE_MODE_MAPS_UPDATE', UpdateWeekly, 'weeklyCheck')
	dataInitialized = true
end
AstralEvents:Register('PLAYER_ENTERING_WORLD', InitData, 'initData')


--|cffa335ee|Hkeystone:158923:251:12:10:5:13:117|h[Keystone: The Underrot (12)]|h|r
-- COLOUR[3] returns epic color hex code
function e.CreateKeyLink(mapID, keyLevel)
	local mapName
	if mapID == 369 or mapID == 370 then
		mapName = C_ChallengeMode.GetMapUIInfo(mapID)		
	else
		mapName = e.GetMapName(mapID)
	end
	local thisAff1, thisAff2, thisAff3, thisAff4 = 0
	if keyLevel > 1 then
	 thisAff1 = e.AffixOne()
	end
	if keyLevel > 3 then
	 thisAff2 = e.AffixTwo()
	end
	if keyLevel > 6 then
	 thisAff3 = e.AffixThree()
	end
	if keyLevel > 8 then
	 thisAff4 = e.AffixFour()
	end
	local covenantID = C_Covenants.GetActiveCovenantID()
	local covenantData = C_Covenants.GetCovenantData(covenantID)
	if (covenantData) then
		return strformat('|c' .. COLOUR[3] .. '|Hkeystone:%d:%d:%d:%d:%d:%d:%d|h[%s %s (%d)]|h|r (%s)', e.MYTHICKEY_ITEMID, mapID, keyLevel, thisAff1, thisAff2, thisAff3, thisAff4, L['KEYSTONE'], mapName, keyLevel, covenantData.name):gsub('\124\124', '\124')
	else
		return strformat('|c' .. COLOUR[3] .. '|Hkeystone:%d:%d:%d:%d:%d:%d:%d|h[%s %s (%d)]|h|r', e.MYTHICKEY_ITEMID, mapID, keyLevel, thisAff1, thisAff2, thisAff3, thisAff4, L['KEYSTONE'], mapName, keyLevel):gsub('\124\124', '\124')
	end
end

AstralEvents:Register('CHALLENGE_MODE_COMPLETED', function()
	C_Timer.After(3, function()
		C_MythicPlus.RequestRewards()
		e.FindKeyStone(true, true)
	end)
end, 'dungeonCompleted')

function e.FindKeyStone(sendUpdate, anounceKey)
	if UnitLevel('player') < e.EXPANSION_LEVEL then return end

	local mapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID()
	local keyLevel = C_MythicPlus.GetOwnedKeystoneLevel()
	local weeklyBest = 0
	local isChestAvailable = C_MythicPlus.IsWeeklyRewardAvailable()
	

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
		msg = string.format('%s:%s:%d:%d:%d:%d:%s', e.Player(), e.PlayerClass(), mapID, keyLevel, weeklyBest, e.Week, e.FACTION)
	end

	local oldMap, oldLevel = e.UnitMapID(e.UnitID(e.Player())), e.UnitKeyLevel(e.UnitID(e.Player()))

	if sendUpdate and msg ~= '' then
		e.PushKeyDataToFriends(msg)
		if IsInGuild() then
			AstralComs:NewMessage('AstralKeys', strformat('%s %s', e.UPDATE_VERSION, msg), 'GUILD')
		else -- Not in a guild, who are you people? Whatever, gotta make it work for them as well
			local id = e.UnitID(e.Player())
			if id then -- Are we in the DB already?
				AstralKeys[id].dungeon_id = tonumber(mapID)
				AstralKeys[id].key_level = tonumber(keyLevel)
				AstralKeys[id].week = e.Week
				AstralKeys[id].time_stamp = e.WeekTime()
			else -- Nope, ok, let's add them to the DB manually.
				AstralKeys[#AstralKeys + 1] = {
					unit = e.Player(),
					class = e.PlayerClass(),
					dungeon_id = tonumber(mapID),
					key_level = tonumber(keyLevel),
					week = e.Week,
					time_stamp = e.WeekTime(),
				}
				e.SetUnitID(e.Player(), #AstralKeys)
			end
		end
	end
	msg = nil

	-- Ok, time to check if we need to announce a new key or not
	if tonumber(oldMap) == tonumber(mapID) and tonumber(oldLevel) == tonumber(keyLevel) then return end

	if anounceKey then
		e.AnnounceNewKey(e.CreateKeyLink(mapID, keyLevel))
	end
end

-- Finds best map clear fothe week for logged on character. If character already is in database
-- updates the information, else creates new entry for character
function e.UpdateCharacterBest()
	if UnitLevel('player') < e.EXPANSION_LEVEL then return end

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
		if AstralCharacters[i].unit == e.Player() then
			found = true
			AstralCharacters[i].weekly_best = weeklyBest
			break
		end
	end

	if not found then
		table.insert(AstralCharacters, {unit = e.Player(), class = e.PlayerClass(), weekly_best = weeklyBest, faction = e.FACTION})
		e.SetCharacterID(e.Player(), #AstralCharacters)
	end
end

local function MythicPlusStart()
	e.FindKeyStone(true, false)
end

AstralEvents:Register('CHALLENGE_MODE_START', MythicPlusStart, 'PlayerEnteredMythic')

function e.GetDifficultyColour(keyLevel)
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
			if (e.MYTHICKEY_ITEMID == itemID) then
				local itemLink = GetContainerItemLink(bagId, slot)
				if (dataInitialized) then
					if (itemLink ~= lastKey) then
						e.FindKeyStone(true, false)
					end
				end
				lastKey = itemLink
			end
		end
	end
end, 'bagUpdateKeyScan')
