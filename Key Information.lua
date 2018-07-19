local ADDON, e = ...
local strformat = string.format

local GRAY = 'ff9d9d9d'
local PURPLE = 'ffa335ee'

e.CACHE_LEVEL = 15 -- Weekly M+ requirement for class hall cache

local function Weekly()
	e.GetBestClear()
	if AstralCharacters[e.GetCharacterID(e.Player())].level >= e.CACHE_LEVEL then
		if IsInGuild() then
			AstralComs:NewMessage('AstralKeys', 'updateWeekly 1', 'GUILD')
		else
			local id = e.UnitID(e.Player())
			if id then
				AstralKeys[id][5] = 1
				e.UpdateFrames()
			end
		end
	end
	e.UpdateCharacterFrames()
end

local function InitData()
	AstralEvents:Unregister('CHALLENGE_MODE_MAPS_UPDATE', 'initData')
	C_ChatInfo.RegisterAddonMessagePrefix('AstralKeys')
	e.FindKeyStone(true, false)
	e.GetBestClear()

	AstralComs:NewMessage('AstralKeys', 'request', 'GUILD')	

	if UnitLevel('player') < 110 then return end
	AstralEvents:Register('CHALLENGE_MODE_MAPS_UPDATE', Weekly, 'weeklyCheck')
end
AstralEvents:Register('CHALLENGE_MODE_MAPS_UPDATE', InitData, 'initData')

--|cffa335ee|Hkeystone:138019:206:13:5:3:9:0|h[Keystone: Neltharion's Lair (13)]|h|r 5 
function e.CreateKeyLink(mapID, keyLevel)
	return strformat('\124cffa335ee\124Hkeystone:138019:%d:%d:%d:%d:%d:%d|h[Keystone: %s]\124h\124r', mapID, keyLevel, e.AffixOne(), e.AffixTwo(), e.AffixThree(), e.AffixFour(), e.GetMapName(mapID))--:gsub('\124\124', '\124')
end

AstralEvents:Register('CHALLENGE_MODE_COMPLETED', function()
	C_Timer.After(3, function() e.FindKeyStone(true, true) end)
end, 'dungeonCompleted')

local function CompletedWeekly()
	local id = e.GetCharacterID(e.Player())
	if not id then return 0 end
	if AstralCharacters[id]['level'] and AstralCharacters[id].level >= e.CACHE_LEVEL then
		return 1
	else
		return 0
	end
end

local function ParseLootMsgForKey(...)
	local msg = ...
	local unit = select(5, ...)
	if not unit == e.PlayerName() then return end

	if string.lower(msg):find('keystone') then -- Looked a key, let's bind a function to bag_update event to find that key
		AstralEvents:Register('BAG_UPDATE', function()
			e.FindKeyStone(true, true)
			AstralEvents:Unregister('BAG_UPDATE', 'bagUpdate')
			AstralEvents:Unregister('CHAT_MSG_LOOT', 'lootCheck')
			end, 'bagUpdate')
	end
end

function e.FindKeyStone(sendUpdate, anounceKey)
	if UnitLevel('player') < 110 then return end

	local mapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID()
	local keyLevel = C_MythicPlus.GetOwnedKeystoneLevel()

	local msg = ''

	if mapID then 
		msg = string.format('%s:%s:%d:%d:%d:%d:%s', e.Player(), e.PlayerClass(), mapID, keyLevel, CompletedWeekly(), e.Week, e.FACTION)
	end

	if not mapID and not AstralEvents:IsRegistered('CHAT_MSG_LOOT', 'loot_msg_parse') then
		AstralEvents:Register('CHAT_MSG_LOOT', ParseLootMsgForKey, 'loot_msg_parse')
	end

	local oldMap, oldLevel = e.UnitMapID(e.UnitID(e.Player())), e.UnitKeyLevel(e.UnitID(e.Player()))

	-- Key found, unregister function, no longer needed
	if mapID and AstralEvents:IsRegistered('BAG_UPDATE', 'bagUpdate') then
		AstralEvents:Unregister('BAG_UPDATE', 'bagUpdate')
	end

	if sendUpdate and msg ~= '' then
		e.PushKeyDataToFriends(msg)
		if IsInGuild() then
			AstralComs:NewMessage('AstralKeys', strformat('%s %s', e.UPDATE_VERSION, msg), 'GUILD')
		else -- Not in a guild, who are you people? Whatever, gotta make it work for them aswell
			local id = e.UnitID(e.Player()) -- Are we in the DB already?
			if id then -- Yep, ok just update those values
				AstralKeys[id][3] = tonumber(mapID)
				AstralKeys[id][4] = tonumber(keyLevel)
				AstralKeys[id][6] = e.Week
				AstralKeys[id][7] = e.WeekTime()
			else -- Nope, ok, let's add them to the DB manually.
				AstralKeys[#AstralKeys + 1] = {e.Player(), e.PlayerClass(), tonumber(mapID), tonumber(keyLevel), e.Week, e.WeekTime()}
				e.SetUnitID(e.Player(), #AstralKeys)
			end
		end
	end
	msg = nil

	-- Ok, time to check if we need to announce a new key or not
	if tonumber(oldMap) == tonumber(mapID) and tonumber(oldLevel) == tonumber(keyLevel) then return end

	if anounceKey then
		e.AnnounceNewKey(e.CreateKeyLink(mapID, keyLevel), keyLevel)
	end
end

-- Finds best map clear fothe week for logged on character. If character already is in database
-- updates the information, else creates new entry for character
function e.GetBestClear()
	if UnitLevel('player') < 110 then return end
	local bestLevel = C_MythicPlus.GetWeeklyChestRewardLevel()
	--[[
	local bestLevel = 0
	local bestMap = 0
	for _, v in pairs(C_ChallengeMode.GetMapTable()) do
		local _, weeklyBestLevel = C_MythicPlus.GetWeeklyBestForMap(v)
		Console:AddLine(v, weeklyBestLevel)
		if weeklyBestLevel then
			if weeklyBestLevel > bestLevel then
				bestLevel = weeklyBestLevel
				bestMap = v
			end
		end
	end
]]
	local id = e.GetCharacterID(e.Player())
	if id then
		AstralCharacters[id].map = bestMap
		AstralCharacters[id].level = bestLevel
	else
		table.insert(AstralCharacters, {unit = e.Player(), class = e.PlayerClass(), map = bestMap, level = bestLevel, faction = e.FACTION})
		e.SetCharacterID(e.Player(), #AstralCharacters)
	end
end