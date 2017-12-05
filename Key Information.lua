local ADDON, e = ...
local strformat = string.format

local GRAY = 'ff9d9d9d'
local PURPLE = 'ffa335ee'

e.CACHE_LEVEL = 15 -- Weekly M+ requirement for class hall cache

local function Weekly()
	e.GetBestClear()
	if AstralCharacters[e.GetCharacterID(e.Player())].level >= e.CACHE_LEVEL then
		AstralComs:NewMessage('AstralKeys', 'updateWeekly 1', 'GUILD')
		--SendAddonMessage('AstralKeys', 'updateWeekly 1', 'GUILD')
	end
	e.UpdateCharacterFrames()
end

local function InitData()
	if UnitLevel('player') ~= 110 then return end -- Character isn't max level, anything from them is useless
	e.GetBestClear()
	e.FindKeyStone(true, false)
	e.BuildMapTable()
	AstralComs:NewMessage('AstralKeys', 'request', 'GUILD')
	--SendAddonMessage('AstralKeys', 'request', 'GUILD')

	AstralEvents:Unregister('CHALLENGE_MODE_MAPS_UPDATE', 'initData')
	AstralEvents:Register('CHALLENGE_MODE_MAPS_UPDATE', Weekly, 'weeklyCheck')
end
AstralEvents:Register('CHALLENGE_MODE_MAPS_UPDATE', InitData, 'initData')


function e.CreateKeyLink(index)
	local s = strformat('|cffa335ee|Hkeystone:%d:%d:%d:%d:%d|h[Keystone: %s]|h|r', AstralKeys[index][3], AstralKeys[index][4], e.AffixOne(), e.AffixTwo(), e.AffixThree(), e.GetMapName(AstralKeys[index][3])):gsub('\124\124', '\124')

	return s, AstralKeys[index][4]
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

function e.GetKeyInfo()
	local mapID, keyLevel, a1, a2, a3, s, itemID, link

	for bag = 0, NUM_BAG_SLOTS + 1 do
		for slot = 1, GetContainerNumSlots(bag) do
			itemID = GetContainerItemID(bag, slot)
			if (itemID and itemID == 138019) then -- Found the key
				return e.ParseLink(GetContainerItemLink(bag, slot)) -- return the mapID, keyLevel, and affixes from the link
			end
		end
	end

	return nil -- No key found, just return nil
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
	local mapID, keyLevel, affix1, affix2, affix3 = e.GetKeyInfo()
	local msg = ''

	if mapID then -- Won't have a mapID without having a
		msg = string.format('%s %s:%s:%d:%d:%d:%d', e.UPDATE_VERSION, e.Player(), e.PlayerClass(), mapID, keyLevel, CompletedWeekly(), e.Week)
	end

	if not mapID and not AstralEvents:IsRegistered('CHAT_MSG_LOOT', 'loot_msg_parse') then -- No key found or event registered, let's look for those keys
		AstralEvents:Register('CHAT_MSG_LOOT', ParseLootMsgForKey, 'loot_msg_parse')
	end

	-- Get the current key information the db to check for new key announcement
	local oldMap, oldLevel = e.GetUnitKeyByID(e.UnitID(e.Player()))

	-- Key found, unregister function, no longer needed
	if link and AstralEvents:IsRegistered('BAG_UPDATE', 'bagUpdate') then
		AstralEvents:Unregister('BAG_UPDATE', 'bagUpdate')
	end

	if sendUpdate  and msg ~= '' then
		if IsInGuild() then
			AstralComs:NewMessage('AstralKeys', msg, 'GUILD')
			e.PushKeyDataToFriends(msg)
			--SendAddonMessage('AstralKeys', msg, 'GUILD')
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
		e.AnnounceNewKey(link, keyLevel)
	end
end

-- Parses item link to get mapID, key level, affix1, affix2, affix3
-- @param link Item Link for keystone
-- return int ID's for mapID, keyLevel, affix1, affix2, affix3 
-- return ex. 239 12 4 5 10
function e.ParseLink(link)
	if not link:find('keystone') then return end -- Not a keystone link, don't do anything, also something went wrong shouldn't be here if not keystone link
	return link:gsub('\124', '\124\124'):match(':(%d+):(%d+):(%d+):(%d+):(%d+)')
end

function e.GetUnitKeyByID(id)
	if not id or (id < 1 ) then return end -- Id out of ranged, or not supplied, who does this?

	return AstralKeys[id][3], AstralKeys[id][4] -- mapID, key level
end

function e.UnitKeyLevel(id)
	return AstralKeys[id][4]
end

function e.UnitMapID(id)
	return AstralKeys[id][3]
end

function e.UnitCompletedWeekly(id)
	if AstralKeys[id][5] == 1 then
		return true
	else
		return false
	end
end

function e.GetCharacterKey(unit)
	if not unit then return '' end

	local id = e.UnitID(unit)
	
	if id then 
		return AstralKeys[id][4] .. ' ' .. C_ChallengeMode.GetMapInfo(AstralKeys[id][3]) -- 4:: key level 3:: mapID
	else
		return WrapTextInColorCode('No key found.', 'ff9d9d9d')
	end
end

-- Finds best map clear fothe week for logged on character. If character already is in database
-- updates the information, else creates new entry for character
function e.GetBestClear()
	if UnitLevel('player') ~= 110 then return end
	local bestLevel = 0
	local bestMap = 0
	for _, v in pairs(C_ChallengeMode.GetMapTable()) do
		local _, _, weeklyBestLevel = C_ChallengeMode.GetMapPlayerStats(v)
		if weeklyBestLevel then
			if weeklyBestLevel > bestLevel then
				bestLevel = weeklyBestLevel
				bestMap = v
			end
		end
	end

	local id = e.GetCharacterID(e.Player())
	if id then
		AstralCharacters[id].map = bestMap
		AstralCharacters[id].level = bestLevel
	else
		table.insert(AstralCharacters, {unit = e.Player(), class = e.PlayerClass(), map = bestMap, level = bestLevel, faction = UnitFactionGroup('player')})
		e.SetCharacterID(e.Player(), #AstralCharacters)
	end
end

-- Deprecated
--[[
if not AstralAffixes then 
	AstralAffixes = {}
	AstralAffixes[1] = 0
	AstralAffixes[2] = 0
	AstralAffixes[3] = 0
end

function e.SetAffix(affixNumber, affixID)
	AstralAffixes[affixNumber] = affixID
end

function e.GetAffix(affixNumber)
	return AstralAffixes[affixNumber]
end
]]