local _, e = ...

local keyTable = {}
local sortedTable = {}
local characterTable = {}
if not AstralAffixes then 
	AstralAffixes = {} 
	AstralAffixes[1] = 0
	AstralAffixes[2] = 0
	AstralAffixes[3] = 0
end

local GRAY = 'ff9d9d9d'
local PURPLE = 'ffa335ee'

local currentKey = ''
local mapID, keyLevel, usable, a1, a2, a3, s, itemID, delink, link

local init = false

e.RegisterEvent('CHALLENGE_MODE_MAPS_UPDATE', function()
	if UnitLevel('player') ~= 110 then return end
	e.GetBestClear()
 	if not init then
 		e.FindKeyStone(true)
 		e.BuildMapTable()
 		SendAddonMessage('AstralKeys', 'request', 'GUILD')
 		init = true
 	end
 end)

e.RegisterEvent('CHALLENGE_MODE_COMPLETED', function()
	e.FindKeyStone(true, true)
	end)

function e.ParseAffixes()
	for i=1, #AstralKeys do
		if AstralKeys[i].a1 ~= 0 then
			AstralAffixes[1] = AstralKeys[i].a1
		end
		if AstralKeys[i].a2 ~= 0 then
			AstralAffixes[2] = AstralKeys[i].a2
		end
		if AstralKeys[i].a3 ~= 0 then
			AstralAffixes[3] = AstralKeys[i].a3
		end
	end
end

function e.CreateKeyLink(index)
	s = '|c'
	mapID, keyLevel, usable, a1, a2, a3 = AstralKeys[index].map, AstralKeys[index].level, AstralKeys[index].usable, AstralKeys[index].a1, AstralKeys[index].a2, AstralKeys[index].a3

	if tonumber(usable) == 1 then
		s = s .. PURPLE
	else
		s = s .. GRAY
	end

	s = s .. '|Hkeystone:' .. mapID .. ':' .. keyLevel .. ':' .. usable .. ':' .. a1 .. ':' .. a2 .. ':' .. a3 .. '|h[Keystone: ' .. e.GetMapName(mapID) .. ']|h|r'
	s = s:gsub('\124\124', '\124')

	return s, keyLevel
end

e.RegisterEvent('CHALLENGE_MODE_NEW_RECORD', function()
	e.GetBestClear()
	e.UpdateCharacterFrames()
	end)

e.RegisterEvent('CHAT_MSG_LOOT', function(...)
	local msg = ...
	if not msg:find('You') then return end

	if msg:find('Keystone') then
		e.FindKeyStone(true, true)
	end

	end)

function e.SetAffix(affixNumber, affixID)
	AstralAffixes[affixNumber] = affixID
end

function e.GetAffix(affixNumber)
	return AstralAffixes[affixNumber]
end

function e.FindKeyStone(sendUpdate, anounceKey)
	s = ''

	for bag = 0, NUM_BAG_SLOTS + 1 do
		for slot = 1, GetContainerNumSlots(bag) do
			itemID = GetContainerItemID(bag, slot)
			if (itemID and itemID == 138019) then
				link = GetContainerItemLink(bag, slot)
				delink = link:gsub('\124', '\124\124')
				mapID, keyLevel, usable, a1, a2, a3 = delink:match(':(%d+):(%d+):(%d+):(%d+):(%d+):(%d+)')
				s = 'updateV1 ' .. e.PlayerName() .. ':' .. e.PlayerClass() .. ':' .. e.PlayerRealm() ..':' .. mapID .. ':' .. keyLevel .. ':' .. usable .. ':' .. a1 .. ':' .. a2 .. ':' .. a3
			end
		end
	end

	local oldMap, oldLevel, oldUsable = e.GetCharacterKey(e.PlayerName())

	e.CheckForWeeklyClear(a1)

	if tonumber(oldMap) == tonumber(mapID) and tonumber(oldLevel) == tonumber(keyLevel) and tonumber(oldUsable) == tonumber(usable) then return end

	if sendUpdate  and s ~= '' then
		SendAddonMessage('AstralKeys', s, 'GUILD')
	end

	if anounceKey then
		e.AnnounceNewKey(link, keyLevel)
	end

end

function e.GetKeyLevelByIndex(index)
	return AstralKeys[index].keyLevel
end

local function CreateKeyText(mapID, level, isDepleted)
	if not isDepleted then
		return level .. ' ' .. C_ChallengeMode.GetMapInfo(mapID)
	else
		if tonumber(isDepleted) == 0 then
			return WrapTextInColorCode(level .. ' ' .. C_ChallengeMode.GetMapInfo(mapID), 'ff9d9d9d')
		else
			return level .. ' ' .. C_ChallengeMode.GetMapInfo(mapID)
		end
	end
end

function e.GetUnitKey(id)
	if not id then return '' end

	return AstralKeys[id].map
end

function e.GetCharacterKey(unit)
	if not unit then return '' end

	for i = 1, #AstralKeys do
		if AstralKeys[i].name == unit then
			return CreateKeyText(AstralKeys[i].map, AstralKeys[i].level, AstralKeys[i].usable)
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
local bestLevel, bestMap, weeklyBestLevel
function e.GetBestClear()
	if UnitLevel('player') ~= 110 then return end
	bestLevel = 0
	bestMap = 0
	for _, v in pairs(C_ChallengeMode.GetMapTable()) do
		_, _, weeklyBestLevel = C_ChallengeMode.GetMapPlayerStats(v)
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