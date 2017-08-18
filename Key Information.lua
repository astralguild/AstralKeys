local ADDON, e = ...
local strformat = string.format

local GRAY = 'ff9d9d9d'
local PURPLE = 'ffa335ee'

local WEEKLY_LEVEL = 15

local function Weekly()
	e.GetBestClear()
	if AstralCharacters[e.CharacterID()].level >= WEEKLY_LEVEL then
		SendAddonMessage('AstralKeys', 'updateWeekly 1', 'GUILD')
	end
	e.UpdateCharacterFrames()
end

local function InitData()
	if UnitLevel('player') ~= 110 then return end
	e.GetBestClear()
	e.SetCharacterID()
	e.FindKeyStone(true, false)
	e.BuildMapTable()
	SendAddonMessage('AstralKeys', 'request', 'GUILD')

	AstralEvents:Unregister('CHALLENGE_MODE_MAPS_UPDATE', 'initData')
	AstralEvents:Register('CHALLENGE_MODE_MAPS_UPDATE', Weekly, 'weeklyCheck')
end
AstralEvents:Register('CHALLENGE_MODE_MAPS_UPDATE', InitData, 'initData')


function e.CreateKeyLink(index)
	local s = strformat('|cffa335ee|Hkeystone:%d:%d:%d:%d:%d|h[Keystone: %s]|h|r', AstralKeys[index][3], AstralKeys[index][4], e.AffixOne(), e.AffixTwo(), e.AffixThree(), e.GetMapName(AstralKeys[index][3]))
	s = s:gsub('\124\124', '\124')

	return s, AstralKeys[index][4]
end

AstralEvents:Register('CHALLENGE_MODE_COMPLETED', function()
	C_Timer.After(3, function() e.FindKeyStone(true, true) end)
end, 'dungeonCompleted')

local function CompletedWeekly()
	if not e.CharacterID() then return 0 end
	if AstralCharacters[e.CharacterID()]['level'] and AstralCharacters[e.CharacterID()].level >= WEEKLY_LEVEL then
		return 1
	else
		return 0
	end
end

function e.GetKeyInfo()
	local mapID, keyLevel, a1, a2, a3, s, itemID, delink, link

	for bag = 0, NUM_BAG_SLOTS + 1 do
		for slot = 1, GetContainerNumSlots(bag) do
			itemID = GetContainerItemID(bag, slot)
			if (itemID and itemID == 138019) then
				link = GetContainerItemLink(bag, slot)
				mapID, keyLevel, a1, a2, a3 = e.ParseLink(link)				
			end
		end
	end

	return mapID, keyLevel, a1, a2, a3

end

function e.FindKeyStone(sendUpdate, anounceKey)
	local mapID, keyLevel, a1, a2, a3, s, itemID, delink, link
	local s = ''

	for bag = 0, NUM_BAG_SLOTS + 1 do
		for slot = 1, GetContainerNumSlots(bag) do
			itemID = GetContainerItemID(bag, slot)
			if (itemID and itemID == 138019) then
				link = GetContainerItemLink(bag, slot)
				mapID, keyLevel, a1, a2, a3 = e.ParseLink(link)
				s = string.format('%s %s-%s:%s:%d:%d:%d:%d', e.UPDATE_VERSION, e.PlayerName(), e.PlayerRealm(), e.PlayerClass(), mapID, keyLevel, CompletedWeekly(), e.Week)
			end
		end
	end

	if not link then
		if not AstralEvents:IsRegistered('CHAT_MSG_LOOT', 'keyLoot') then
			AstralEvents:Register('CHAT_MSG_LOOT', function(...)
				local msg = ...
				local unit = select(5, ...)
				if not unit == e.PlayerName() then return end

				if string.lower(msg):find('keystone') then
					AstralEvents:Register('BAG_UPDATE', function()
						e.FindKeyStone(true, true)
						AstralEvents:Unregister('BAG_UPDATE', 'bagUpdate')
						AstralEvents:Unregister('CHAT_MSG_LOOT', 'keyLoot')
						end, 'bagUpdate')
				end
			end, 'keyLoot')
		end
	end

	local oldMap, oldLevel = e.GetUnitKeyByID(e.PlayerID())

	if link and AstralEvents:IsRegistered('BAG_UPDATE', 'bagUpdate') then
		AstralEvents:Unregister('BAG_UPDATE', 'bagUpdate')
	end

	if sendUpdate  and s ~= '' then
		if IsInGuild() then
			SendAddonMessage('AstralKeys', s, 'GUILD')
		else
			local id = e.UnitID(string.format('%s-%s', e.PlayerName(), e.PlayerRealm()))

			if id then
				AstralKeys[id][3] = tonumber(mapID)
				AstralKeys[id][4] = tonumber(keyLevel)
				AstralKeys[id][6] = e.Week
				AstralKeys[id][7] = e.WeekTime()
			else
				AstralKeys[#AstralKeys + 1] = {string.format('%s-%s', e.PlayerName(), e.PlayerRealm()), e.PlayerClass(), tonumber(mapID), tonumber(keyLevel), e.Week, e.WeekTime()}
				e.SetUnitID(string.format('%s-%s', e.PlayerName(), e.PlayerRealm()), #AstralKeys)
			end
		end
	end

	if tonumber(oldMap) == tonumber(mapID) and tonumber(oldLevel) == tonumber(keyLevel) then return end

	if anounceKey then
		e.AnnounceNewKey(link, keyLevel)
	end
end

local function CreateKeyText(mapID, level)
		return level .. ' ' .. C_ChallengeMode.GetMapInfo(mapID)
end

-- Parses item link to get mapID, key level, affix1, affix2, affix3
-- @param link Item Link for keystone
-- return mapID, keyLevel, affix1, affix2, affix3 Integer values

function e.ParseLink(link)
	if not link:find('keystone') then return end -- Not a keystone link, don't do anything
	local delink = link:gsub('\124', '\124\124')
	local mapID, keyLevel, affix1, affix2, affix3 = delink:match(':(%d+):(%d+):(%d+):(%d+):(%d+)')
	return mapID, keyLevel, affix1, affix2, affix3
end

function e.GetUnitKeyByID(id)
	if not id or (id < 1 ) then return end

	return AstralKeys[id][3], AstralKeys[id][4]
end

function e.GetCharacterKey(unit)
	if not unit then return '' end

	for i = 1, #AstralKeys do
		if AstralKeys[i][1] == unit then
			return CreateKeyText(AstralKeys[i][3], AstralKeys[i][4])
		end
	end

	return WrapTextInColorCode('No key found.', 'ff9d9d9d')

end

function e.GetBestKey(id)
	return AstralCharacters[id].level
end

function e.GetBestMap(unit)

	for i = 1, #AstralCharacters do
		if AstralCharacters[i].name == unit then
			if AstralCharacters[i].map ~= 0 then
				return e.GetMapName(AstralCharacters[i].map)
			end
		end
	end
	
	return 'No mythic+ ran this week.'
end

--Returns map ID and keystone level run for current week

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

	if #AstralCharacters == 0 then
		table.insert(AstralCharacters, {name = e.PlayerName(), class = e.PlayerClass(), realm = e.PlayerRealm(), map = bestMap, level = bestLevel, knowledge = e.GetAKBonus(e.ParseAKLevel())})
	end

	local index = -1
	for i = 1, #AstralCharacters do
		if AstralCharacters[i]['name'] == e.PlayerName() and AstralCharacters[i].realm == e.PlayerRealm() then
			AstralCharacters[i].map = bestMap
			AstralCharacters[i].level = bestLevel
			index = i
		end
	end

	if index == -1 then
		table.insert(AstralCharacters, {name = e.PlayerName(), class = e.PlayerClass(), realm = e.PlayerRealm(), map = bestMap, level = bestLevel, knowledge = e.GetAKBonus(e.ParseAKLevel())})
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