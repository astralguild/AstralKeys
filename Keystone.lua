local _, addon = ...
local L = addon.L
local strformat = string.format

local QUALITIES = {}
QUALITIES.Poor = 'ff9d9d9d'
QUALITIES.Common = 'ffffffff'
QUALITIES.Uncommon = 'ff1eff00'
QUALITIES.Rare = 'ff0070dd'
QUALITIES.Epic = 'ffa335ee'
QUALITIES.Legendary = 'ffff8000'
QUALITIES.Artifact = 'ffe6cc80'

addon.keystone = {}
addon.inKey = false

addon.MYTHICKEY_ITEMID = 180653
addon.TIMEWALKINGKEY_ITEMID = 187786
addon.MYTHICKEY_REROLL_NPCID = 197915
addon.MYTHICKEY_CITY_NPCID = 197711

local function UpdateWeekly()
	addon.UpdateCharacterBest()

	local characterID = addon.GetCharacterID(addon.Player())
	local characterWeeklyBest = addon.GetCharacterBestLevel(characterID)
	local characterScore = addon.GetCharacterMplusScore(characterID)

	if IsInGuild() then
		AstralComs:NewMessage('AstralKeys', 'updateWeekly ' .. characterWeeklyBest, 'GUILD')
	else
		local id = addon.UnitID(addon.Player())
		if id then
			AstralKeys[id].weekly_best = characterWeeklyBest
			AstralKeys[id].mplus_score = characterScore
			addon.PrintDebug('Keystone/UpdateWeekly', addon.DebugTableToString(AstralKeys[id]))
			addon.UpdateFrames()
		end
	end
	addon.UpdateCharacterFrames()
end

function addon.GetCurrentKeystone()
	return C_MythicPlus.GetOwnedKeystoneChallengeMapID(), C_MythicPlus.GetOwnedKeystoneLevel()
end

function addon.CheckKeystone()
	local id, l = addon.GetCurrentKeystone()
	if (not addon.keystone.id) or (id == addon.keystone.id and l < addon.keystone.level) then
		addon.PushKeystone(false, id, l)
	elseif id ~= addon.keystone.id or l ~= addon.keystone.level then
    addon.PushKeystone(true, id, l)
  else
    addon.keystone = {level = l, id = id}
  end
end

--|cffa335ee|Hkeystone:158923:251:12:10:5:13:117|h[Keystone: The Underrot (12)]|h|r
function addon.CreateKeyLink(mapID, keyLevel)
	local mapName
	if mapID == 369 or mapID == 370 then
		mapName = C_ChallengeMode.GetMapUIInfo(mapID)
	else
		mapName = addon.GetMapName(mapID, true)
	end
	keyLevel = keyLevel or C_MythicPlus.GetOwnedKeystoneLevel()
	if not mapName or not keyLevel then return end
	local a1, a2, a3
	if keyLevel > 3 then
		a1 = addon.AffixOne()
	end 
	if keyLevel > 6 then
		a2 = addon.AffixTwo()
	end
	if keyLevel > 9 then
		a3 = addon.AffixThree()
	end

	-- For 12+ keys, the first Xalatath's affix gets dropped and everything shifts forward,
	-- then the fourth affix becomes Xalatath's Guile
	if keyLevel > 11 then
		a1 = a2
		a2 = a3
		a3 = addon.AffixFour()
	end
	-- /script SendChatMessage("\124cffa335ee\124Hkeystone:180653:375:20:148:9:152:10\124h[Keystone: Mists of Tirna Scithe (20)]\124h\124r", 'SAY')
	return strformat('|c' .. QUALITIES.Epic .. '|Hkeystone:%d:%d:%d:%d:%d:%d:%d:%d|h[%s %s (%d)]|h|r', addon.MYTHICKEY_ITEMID, mapID, keyLevel, a1, a2, a3, 0, 0, L['KEYSTONE'] or 'Keystone:', mapName, keyLevel):gsub('\124\124', '\124')
end

-- Prints out the same link as the CreateKeyLink but only if the Timewalking Key is found. Otherwise nothing is done.
function addon.CreateTimewalkingKeyLink(mapID, keyLevel)
	local mapName = addon.GetMapName(mapID, true)
	local a1, a2, a3, a4
	if keyLevel > 1 then
	 a1 = addon.TimewalkingAffixOne()
	end
	if keyLevel > 3 then
	 a2 = addon.TimewalkingAffixTwo()
	end
	if keyLevel > 6 then
	 a3 = addon.TimewalkingAffixThree()
	end
	if keyLevel > 8 then
	 a4 = addon.TimewalkingAffixFour()
	end
	return strformat('|c' .. QUALITIES.Epic .. '|Hkeystone:%d:%d:%d:%d:%d:%d:%d|h[%s %s (%d)]|h|r', addon.TIMEWALKINGKEY_ITEMID, mapID, keyLevel, a1, a2, a3, a4, L['KEYSTONE'] or 'Keystone:', mapName, keyLevel):gsub('\124\124', '\124')
end

function addon.PushKeystone(announceKey, mapID, keyLevel)
	if UnitLevel('player') < addon.EXPANSION_LEVEL then return end

	if not mapID or not keyLevel then
		mapID, keyLevel = addon.GetCurrentKeystone()
	end

	local weeklyBest = 0
	local mplusSummary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary('player')
	local mplusScore = mplusSummary.currentSeasonScore
	local runHistory = C_MythicPlus.GetRunHistory(false, true)

	addon.keystone = {level = keyLevel, id = mapID}

	for i = 1, #runHistory do
		if runHistory[i].thisWeek then
			if runHistory[i].level > weeklyBest then
				weeklyBest = runHistory[i].level
			end
		end
	end

	local msg = ''
	if mapID then
		msg = string.format('%s:%s:%d:%d:%d:%d:%s', addon.Player(), addon.PlayerClass(), mapID, keyLevel, weeklyBest, addon.Week, mplusScore, addon.FACTION)
	end
	if msg ~= '' then
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

	if announceKey then
		addon.AnnounceKey()
	end
end

-- Finds best map clear for the week for logged on character. If character already is in database
-- updates the information, else creates new entry for character
function addon.UpdateCharacterBest()
	if UnitLevel('player') < addon.EXPANSION_LEVEL then return end

	local weeklyBest = 0
	local mplusSummary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary('player')
	local mplusScore = mplusSummary.currentSeasonScore
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
			AstralCharacters[i].mplus_score = mplusScore
			addon.PrintDebug('UpdateCharacterBest', addon.DebugTableToString(AstralCharacters[i]), 'Found: ', found)
			break
		end
	end

	if not found then
		local character = { unit = addon.Player(), class = addon.PlayerClass(), weekly_best = weeklyBest, mplus_score = mplusScore, faction = addon.FACTION }
		table.insert(AstralCharacters, character)
		addon.PrintDebug('UpdateCharacterBest', addon.DebugTableToString(character), 'Found: ', found)
		addon.SetCharacterID(addon.Player(), #AstralCharacters)
	end

end

function addon.GetDifficultyColour(keyLevel)
	if type(keyLevel) ~= 'number' or keyLevel < 2 then return QUALITIES.Common end
	local colour = C_ChallengeMode.GetKeystoneLevelRarityColor(keyLevel)
	return colour:GenerateHexColor()
end

function addon.GetScoreColour(mplusScore)
	local colour = C_ChallengeMode.GetDungeonScoreRarityColor(mplusScore)
	return colour:GenerateHexColor()
end

function addon.GetDungeonTimerForChests(time, level, tier)
	if tier == 3 then
		time = time * 0.6
	elseif tier == 2 then
		time = time * 0.8
	end

	local seasonID = AstralAffixes.season_id or 0
	if seasonID == 13 and level >= 7 then
		time = time + 90 -- wut?
	end

	return time
end

function InitKeystoneData()
	AstralEvents:Unregister('PLAYER_ENTERING_WORLD', 'initData')

	C_MythicPlus.RequestRewards()
	C_ChatInfo.RegisterAddonMessagePrefix('AstralKeys')
	addon.PushKeystone(false)
	addon.UpdateCharacterBest()

	if IsInGuild() then
		AstralComs:NewMessage('AstralKeys', 'request', 'GUILD')
	end

	if UnitLevel('player') < addon.EXPANSION_LEVEL then return end
	AstralEvents:Register('CHALLENGE_MODE_MAPS_UPDATE', UpdateWeekly, 'weeklyCheck')
	AstralEvents:Register('PLAYER_ENTERING_WORLD', addon.CheckKeystone, 'keystoneCheck')
end

AstralEvents:Register('PLAYER_ENTERING_WORLD', InitKeystoneData, 'initData')
AstralEvents:Register('CHALLENGE_MODE_RESET', function()
	addon.CheckKeystone()
	addon.inKey = false
end, 'dungeonReset')
AstralEvents:Register('CHALLENGE_MODE_START', function()
	addon.CheckKeystone()
	addon.inKey = true
end, 'dungeonStart')
AstralEvents:Register('CHALLENGE_MODE_COMPLETED', function()
	C_Timer.After(3, function()
		C_MythicPlus.RequestRewards()
		addon.CheckKeystone()
	end)
	addon.inKey = false
end, 'dungeonCompleted')
AstralEvents:Register('ITEM_CHANGED', function()
	C_Timer.After(3, function()
		C_MythicPlus.RequestRewards()
		addon.CheckKeystone()
	end)
end, 'keystoneMaybeChanged')
AstralEvents:Register('GOSSIP_CLOSED', function()
	local guid = UnitGUID('target')
	if guid ~= nil then
		local npc_id = select(6, strsplit('-', guid))
		if tonumber(npc_id) == addon.MYTHICKEY_CITY_NPCID then
			C_Timer.After(3, function()
				C_MythicPlus.RequestRewards()
				addon.CheckKeystone()
			end)
		end
	end
end, 'keystoneObtainedOrDepleted')