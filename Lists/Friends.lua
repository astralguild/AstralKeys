local e, L = unpack(select(2, ...))
local MAX_LEVEL = 120

local SYNC_VERSION = 'sync4'
local UPDATE_VERSION = 'update4'

local COLOR_BLUE_BNET = 'ff82c5ff'

local strformat, find = string.format, string.find
local tremove = table.remove

local NonBNFriend_List = {}
local BNFriendList = {}
local FRIEND_LIST = {}

----------------------------------------------------
----------------------------------------------------
-- BNet Friend's list API
-- Collect and store pressence, game pressence IDs

local BNGetFriendInfo = BNGetFriendInfo

-- BNGetNumFOF(BNetID) -- Seems to take first return value from BNGetFriendInfo

local isConnected = BNConnected() -- Determine if connected to BNet, if not disable all comms, check for BN_CONNECTED to re-enable communications, BN_DISCONNECTED disable communications on this event

function e.GetFriendGaID(characterName)
	for gaID, target in pairs(BNFriendList) do
		if target == characterName then
			return gaID
		end
	end
	return nil
end

-- Updates BNFriendList for friend update
-- @paremt index int Friend's list index that was updated
function e.BNFriendUpdate(index)
	if not index then return end -- No index, event fired from player

	for gameIndex = 1, C_BattleNet.GetFriendNumGameAccounts(index) do
		local gameAccountInfo = C_BattleNet.GetFriendGameAccountInfo(index, gameIndex)
		if BNFriendList[gameAccountInfo.gameAccountID] and gameAccountInfo.clientProgram ~= BNET_CLIENT_WOW and gameAccountInfo.wowProjectID ~= 1 then -- They are logged into the client, but they are not logged into retail WoW
			BNFriendList[gameAccountInfo.gameAccountID] = nil
		end
		if gameAccountInfo and gameAccountInfo.clientProgram == BNET_CLIENT_WOW and gameAccountInfo.wowProjectID == 1 then
			local realmName
			if gameAccountInfo.realmName then
				realmName = gameAccountInfo.realmName
			elseif gameAccountInfo.realmDisplayName then
				realmName = gameAccountInfo.realmDisplayName:gsub('%s+', '')
			elseif gameAccountInfo.richPresence and gameAccountInfo.richPresence:find('-') then
				realmName = gameAccountInfo.richPresence:sub(gameAccountInfo.richPresence:find('-') + 1, -1):gsub('%s+', '') -- Character - Realm Name stripped down to RealmName
			else
				return
			end

			local fullName = gameAccountInfo.characterName .. '-' .. realmName
			BNFriendList[gameAccountInfo.gameAccountID] = fullName
			if FRIEND_LIST[fullName] then
				local accountInfo = C_BattleNet.GetFriendAccountInfo(index)
				FRIEND_LIST[fullName].accountName = accountInfo.accountName
				FRIEND_LIST[fullName].guid = gameAccountInfo.playerGuid
				FRIEND_LIST[fullName].isConnected = true
			end
			if NonBNFriend_List[fullName] then
				NonBNFriend_List[fullName] = nil
			end
		end
	end
end
AstralEvents:Register('BN_FRIEND_INFO_CHANGED', e.BNFriendUpdate, 'update_BNFriend')

----------------------------------------------------
----------------------------------------------------
-- Friend Indexing

function e.SetFriendID(unit, id)
	FRIEND_LIST[unit] = {id = id, isConnected = false}
end

function e.FriendID(unit)
	if FRIEND_LIST[unit] then
		return FRIEND_LIST[unit].id
	else
		return nil
	end
end

function e.Friend(id)
	return AstralFriends[id][1]
end

function e.FriendName(id)
	return AstralFriends[id][1]:sub(1, AstralFriends[id][1]:find('-') - 1)
end

function e.FriendGUID(unit)
	return FRIEND_LIST[unit].guid
end

function e.FriendPresName(unit)
	return FRIEND_LIST[unit].accountName
end

function e.WipeFriendList()
	wipe(FRIEND_LIST)
end

function e.IsFriendOnline(unit)
	if not FRIEND_LIST[unit] then
		return false
	else
		return FRIEND_LIST[unit].isConnected
	end
end
----------------------------------------------------
----------------------------------------------------
---- Non BNet Friend stuff

local function UpdateNonBNetFriendList()
	wipe(NonBNFriend_List)

	for k,v in pairs(FRIEND_LIST) do
		v.isConnected = false
	end

	for i = 1, select(2, GetNumFriends()) do -- Only parse over online friends
		local name, _, _, _, isConnected, _, _, _, guid = GetFriendInfo(i)
		name = strformat('%s-%s', GetFriendInfo(i), e.PlayerRealm())

		if FRIEND_LIST[name] then
			FRIEND_LIST[name].isConnected = true
			FRIEND_LIST[name].guid = guid
		end
	end

	for index = 1, BNGetNumFriends() do
		for gameIndex = 1, C_BattleNet.GetFriendNumGameAccounts(index) do
			local gameAccountInfo = C_BattleNet.GetFriendGameAccountInfo(index, gameIndex)
			if BNFriendList[gameAccountInfo.gameAccountID] and gameAccountInfo.clientProgram ~= BNET_CLIENT_WOW and gameAccountInfo.wowProjectID ~= 1 then -- They are logged into the client, but they are not logged into retail WoW
				BNFriendList[gameAccountInfo.gameAccountID] = nil
			end
			if gameAccountInfo and gameAccountInfo.clientProgram == BNET_CLIENT_WOW and gameAccountInfo.wowProjectID == 1 then
				local realmName
				if gameAccountInfo.realmName then
					realmName = gameAccountInfo.realmName
				elseif gameAccountInfo.realmDisplayName then
					realmName = gameAccountInfo.realmDisplayName:gsub('%s+', '')
				elseif gameAccountInfo.richPresence and gameAccountInfo.richPresence:find('-') then
					realmName = gameAccountInfo.richPresence:sub(gameAccountInfo.richPresence:find('-') + 1, -1):gsub('%s+', '') -- Character - Realm Name stripped down to RealmName
				else
					return
				end
				local fullName = gameAccountInfo.characterName .. '-' .. realmName
				BNFriendList[gameAccountInfo.gameAccountID] = fullName
				if FRIEND_LIST[fullName] then
					local accountInfo = C_BattleNet.GetFriendAccountInfo(index)
					FRIEND_LIST[fullName].accountName = accountInfo.accountName
					FRIEND_LIST[fullName].guid = gameAccountInfo.playerGuid
					FRIEND_LIST[fullName].isConnected = true
				end
				if NonBNFriend_List[fullName] then
					NonBNFriend_List[fullName] = nil
				end
			end
		end
	end
end
AstralEvents:Register('FRIENDLIST_UPDATE', UpdateNonBNetFriendList, 'update_non_bnet_list')

----------------------------------------------------
----------------------------------------------------
-- Friend Syncing

local function RecieveKey(msg, sender)
	if not AstralKeysSettings.friendOptions.friend_sync.isEnabled then return end
	local btag
	if type(sender) == 'number' then
		local gameAccountInfo = C_BattleNet.GetGameAccountInfoByID(sender)
		local accountInfo = C_BattleNet.GetAccountInfoByGUID(gameAccountInfo.playerGuid)
		btag = accountInfo.battleTag
	end

	local timeStamp = e.WeekTime()
	local unit, class, dungeonID, keyLevel, weekly_best, week, faction = strsplit(':', msg)

	dungeonID = tonumber(dungeonID)
	keyLevel = tonumber(keyLevel)
	week = tonumber(week)
	weekly_best = tonumber(weekly_best)

	local id = e.FriendID(unit)

	if id then
		AstralFriends[id][4] = dungeonID
		AstralFriends[id][5] = keyLevel
		AstralFriends[id][6] = week
		AstralFriends[id][7] = timeStamp
		AstralFriends[id][9] = weekly_best
	else
		AstralFriends[#AstralFriends + 1] = {unit, btag, class, dungeonID, keyLevel, week, timeStamp, faction, weekly_best}
		e.SetFriendID(unit, #AstralFriends)
		ShowFriends()
	end

	e.AddUnitToTable(unit, class, faction, 'FRIENDS', dungeonID, keyLevel, weekly_best, btag)

	if e.FrameListShown() == 'FRIENDS' then 
		e.UpdateFrames()
	end
end
AstralComs:RegisterPrefix('BNET', UPDATE_VERSION, RecieveKey)
AstralComs:RegisterPrefix('WHISPER', UPDATE_VERSION, RecieveKey)

local function SyncFriendUpdate(entry, sender)
	if not AstralKeysSettings.friendOptions.friend_sync.isEnabled then return end

	if AstralKeyFrame:IsShown() then
		AstralKeyFrame:SetScript('OnUpdate', AstralKeyFrame.OnUpdate)
		AstralKeyFrame.updateDelay = 0
	end

	local btag
	if type(sender) == 'number' then
		local gameAccountInfo = C_BattleNet.GetGameAccountInfoByID(sender)
		local accountInfo = C_BattleNet.GetAccountInfoByGUID(gameAccountInfo.playerGuid)
		btag = accountInfo.battleTag
	end

	if AstralKeyFrame:IsShown() then
		AstralKeyFrame:SetScript('OnUpdate', AstralKeyFrame.OnUpdate)
		AstralKeyFrame.updateDelay = 0
	end

	local unit, class, dungeonID, keyLevel, week, timeStamp

	local _pos = 0
	while find(entry, '_', _pos) do

		class, dungeonID, keyLevel, week, timeStamp, faction, weekly_best = entry:match(':(%a+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+)', entry:find(':', _pos))
		unit = entry:sub(_pos, entry:find(':', _pos) - 1)
		_pos = find(entry, '_', _pos) + 1

		dungeonID = tonumber(dungeonID)
		keyLevel = tonumber(keyLevel)
		week = tonumber(week)
		timeStamp = tonumber(timeStamp)
		weekly_best = tonumber(weekly_best)

		if week >= e.Week then
			local id = e.FriendID(unit)
			if id then
				AstralFriends[id][4] = dungeonID
				AstralFriends[id][5] = keyLevel
				AstralFriends[id][6] = week
				AstralFriends[id][7] = timeStamp
				AstralFriends[id][9] = weekly_best
			else
				AstralFriends[#AstralFriends + 1] = {unit, btag, class, dungeonID, keyLevel, week, timeStamp, faction, weekly_best}
				e.SetFriendID(unit, #AstralFriends)
				ShowFriends()
			end
			e.AddUnitToTable(unit, class, faction, 'FRIENDS', dungeonID, keyLevel, weekly_best, btag)
		end
	end
end
AstralComs:RegisterPrefix('BNET', SYNC_VERSION, SyncFriendUpdate)
AstralComs:RegisterPrefix('WHISPER', SYNC_VERSION, SyncFriendUpdate)

local function UpdateWeekly(msg)
	local unit, weekly_best = strsplit(':', msg)

	local id = e.FriendID(unit)
	if id then
		AstralFriends[id][9] = tonumber(weekly_best)
		AstralFriends[id][7] = e.WeekTime()
	end
end
AstralComs:RegisterPrefix('BNET', 'friendWeekly', UpdateWeekly)
AstralComs:RegisterPrefix('WHISPER', 'friendWeekly', UpdateWeekly)

local messageStack = {}
local messageQueue = {}

local function PushKeysToFriends(target)
	if not AstralKeysSettings.friendOptions.friend_sync.isEnabled then return end
	wipe(messageStack)
	wipe(messageQueue)

	for i = 1, #AstralCharacters do
		local id = e.UnitID(AstralCharacters[i].unit)
		if id then -- We have a key for this character, let's get the message and queue it up
			local map, level = e.UnitMapID(id), e.UnitKeyLevel(id)			
			messageStack[#messageStack + 1] = strformat('%s_', strformat('%s:%s:%d:%d:%d:%d:%d:%d', AstralCharacters[i].unit, e.UnitClass(id), map, level, e.Week, AstralKeys[id][7], AstralCharacters[i].faction, AstralCharacters[i].weekly_best)) -- name-server:class:mapID:keyLevel:week#:weekTime:faction:weekly
		end
	end

	local index = 1
	messageQueue[index] = ''
	while(messageStack[1]) do
		local nextMessage = strformat('%s%s', messageQueue[index], messageStack[1])
		if nextMessage:len() < 2000 then
			messageQueue[index] = nextMessage
			table.remove(messageStack, 1)
		else
			index = index + 1
			messageQueue[index] = ''
		end
	end

	e.PushKeyDataToFriends(messageQueue, target)
end

-- Sends data to BNeT friends and Non-BNet friends
-- @param data table Sync data that includes all keys for all of person's characters
-- @param data string Update string including only logged in person's characters
function e.PushKeyDataToFriends(data, target)
	if not target then
		for gaID in pairs(BNFriendList) do
			if type(data) == 'table' then
				for i = 1, #data do
					AstralComs:NewMessage('AstralKeys', strformat('%s %s', SYNC_VERSION, data[i]), 'BNET', gaID)
				end
			else
				AstralComs:NewMessage('AstralKeys', strformat('%s %s', UPDATE_VERSION, data), 'BNET', gaID)
			end
		end
		for player in pairs(NonBNFriend_List) do
			if type(data) == 'table' then
				for i = 1, #data do
					AstralComs:NewMessage('AstralKeys', strformat('%s %s', SYNC_VERSION, data[i]), 'WHISPER', player)
				end
			else
				AstralComs:NewMessage('AstralKeys', strformat('%s %s', UPDATE_VERSION, data), 'WHISPER', player)
			end
		end
	else
		if type(data) == 'table' then
			for i = 1, #data do
				AstralComs:NewMessage('AstralKeys', strformat('%s %s', SYNC_VERSION, data[i]), tonumber(target) and 'BNET' or 'WHISPER', target)
			end
		else
			AstralComs:NewMessage('AstralKeys',  strformat('%s %s', UPDATE_VERSION, data), tonumber(target) and 'BNET' or 'WHISPER', target)
		end
	end
end


-- Let's find out which friends are using Astral Keys, no need to spam every friend, just the ones using Astral keys
local function PingFriendsForAstralKeys()
	if not AstralKeysSettings.friendOptions.friend_sync.isEnabled then return end
	for i = 1, select(2, GetNumFriends()) do -- Only parse over online friends
		local name, _, _, _, isConnected, _, _, _, guid = GetFriendInfo(i)
		name = strformat('%s-%s', GetFriendInfo(i), e.PlayerRealm())

		NonBNFriend_List[name] = {isConnected = isConnected}
	end

	for index = 1, BNGetNumFriends() do
		for gameIndex = 1, C_BattleNet.GetFriendNumGameAccounts(index) do
			local gameAccountInfo = C_BattleNet.GetFriendGameAccountInfo(index, gameIndex)
			if BNFriendList[gameAccountInfo.gameAccountID] and gameAccountInfo.clientProgram ~= BNET_CLIENT_WOW and gameAccountInfo.wowProjectID ~= 1 then -- They are logged into the client, but they are not logged into retail WoW
				BNFriendList[gameAccountInfo.gameAccountID] = nil
			end
			if gameAccountInfo and gameAccountInfo.clientProgram == BNET_CLIENT_WOW and gameAccountInfo.wowProjectID == 1 then
				if not gameAccountInfo.realmName then
					gameAccountInfo = C_BattleNet.GetFriendGameAccountInfo(index, gameIndex)
				end
				local fullName = gameAccountInfo.characterName .. '-' .. gameAccountInfo.realmName
				BNFriendList[gameAccountInfo.gameAccountID] = fullName
				if FRIEND_LIST[fullName] then
					local accountInfo = C_BattleNet.GetFriendAccountInfo(index)
					FRIEND_LIST[fullName].accountName = accountInfo.accountName
					FRIEND_LIST[fullName].guid = gameAccountInfo.playerGuid
					FRIEND_LIST[fullName].isConnected = true
				end
				if NonBNFriend_List[fullName] then
					NonBNFriend_List[fullName] = nil
				end
			end
		end
	end

	for gaID in pairs(BNFriendList) do
		AstralComs:NewMessage('AstralKeys', 'BNet_query ping', 'BNET', gaID)
	end

	for player in pairs(NonBNFriend_List) do
		AstralComs:NewMessage('AstralKeys', 'BNet_query ping', 'WHISPER', player)
	end

	AstralEvents:Unregister('FRIENDLIST_UPDATE', 'pingFriends')
end

-- Figures out who is using AK on friends list, sends them a response and key data
local function PingResponse(msg, sender)
	local btag
	if type(sender) == 'number' then
		local gameAccountInfo = C_BattleNet.GetGameAccountInfoByID(sender)
		local accountInfo = C_BattleNet.GetAccountInfoByGUID(gameAccountInfo.playerGuid)
		btag = accountInfo.battleTag
	end

	if BNFriendList[btag] then
		BNFriendList[btag].usingAK = true
	end

	if NonBNFriend_List[sender] then
		NonBNFriend_List[sender].usingAK = true
	end

	if msg:find('ping') then
		AstralComs:NewMessage('AstralKeys', 'BNet_query response', type(sender) == 'number' and 'BNET' or 'WHISPER', sender)
	end
	PushKeysToFriends(sender)
end
AstralComs:RegisterPrefix('WHISPER', 'BNet_query', PingResponse)
AstralComs:RegisterPrefix('BNET', 'BNet_query', PingResponse)

local function Init()
	ShowFriends()
	AstralEvents:Unregister('PLAYER_ENTERING_WORLD', 'InitFriends')
end
AstralEvents:Register('FRIENDLIST_UPDATE', PingFriendsForAstralKeys, 'pingFriends')
AstralEvents:Register('PLAYER_ENTERING_WORLD', Init, 'InitFriends')


function e.ToggleFriendSync()
	if AstralKeysSettings.friendOptions.friend_sync.isEnabled then
		AstralComs:RegisterPrefix('WHISPER', 'BNet_query', PingResponse)
		AstralComs:RegisterPrefix('BNET', 'BNet_query', PingResponse)
		AstralComs:RegisterPrefix('BNET', SYNC_VERSION, SyncFriendUpdate)
		AstralComs:RegisterPrefix('WHISPER', SYNC_VERSION, SyncFriendUpdate)
		AstralComs:RegisterPrefix('BNET', UPDATE_VERSION, RecieveKey)
		AstralComs:RegisterPrefix('WHISPER', UPDATE_VERSION, RecieveKey)
		AstralEvents:Register('FRIENDLIST_UPDATE', UpdateNonBNetFriendList, 'update_non_bnet_list')
		AstralEvents:Register('BN_FRIEND_INFO_CHANGED', e.BNFriendUpdate, 'update_BNFriend')
		PingFriendsForAstralKeys()
	else
		AstralComs:UnregisterPrefix('WHISPER', 'BNet_query', PingResponse)
		AstralComs:UnregisterPrefix('BNET', 'BNet_query', PingResponse)
		AstralComs:UnregisterPrefix('BNET', SYNC_VERSION, SyncFriendUpdate)
		AstralComs:UnregisterPrefix('WHISPER', SYNC_VERSION, SyncFriendUpdate)
		AstralComs:UnregisterPrefix('BNET', UPDATE_VERSION, RecieveKey)
		AstralComs:UnregisterPrefix('WHISPER', UPDATE_VERSION, RecieveKey)
		AstralEvents:Unregister('FRIENDLIST_UPDATE', UpdateNonBNetFriendList, 'update_non_bnet_list')
		AstralEvents:Unregister('BN_FRIEND_INFO_CHANGED', e.BNFriendUpdate, 'update_BNFriend')
	end
end

----------------------------------------------------
----------------------------------------------------
-- Friend Filtering and sorting
-- Needs non-generic filering for names as well!
local function FriendFilter(A, filters)
	if not type(A) == 'table' then return end
	
	local keyLevelLowerBound, keyLevelUpperBound = 2, 999 -- Lowest key possible, some high enough number

	if filters['key_level'] ~= '' and filters['key_level'] ~= '1' then
		local keyFilterText = filters['key_level']
		if tonumber(keyFilterText) then -- only input a single key level
			keyLevelLowerBound = tonumber(keyFilterText)
			keyLevelUpperBound = tonumber(keyFilterText)
		elseif string.match(keyFilterText, '%d+%+') then -- Text input is <number>+, looking for any key at least <number>
			keyLevelLowerBound = tonumber(string.match(keyFilterText, '%d+'))
		elseif string.match(keyFilterText, '%d+%-') then -- Text input is <number>-, looking for a key no higher than <number>
			keyLevelUpperBound = tonumber(string.match(keyFilterText, '%d+'))
		end
	end

	for i = 1, #A.FRIENDS do
		if AstralKeysSettings.frame.show_offline.isEnabled then
			A.FRIENDS[i].isShown = true
		else
			A.FRIENDS[i].isShown = e.IsFriendOnline(A.FRIENDS[i].character_name)
		end

		if not AstralKeysSettings.friendOptions.show_other_faction.isEnabled then
			A.FRIENDS[i].isShown = A.FRIENDS[i].isShown and tonumber(A.FRIENDS[i].faction) == e.FACTION
		end

		local isShownInFilter = true -- Assume there is no filter taking place
		
		for field, filterText in pairs(filters) do
				if filterText ~= '' then
					isShownInFilter = false -- There is a filter, now assume this unit is not to be shown
					if field == 'dungeon_name' then
						local mapName = e.GetMapName(A.FRIENDS[i]['mapID'])
						if strfind(strlower(mapName), strlower(filterText)) then
							isShownInFilter = true
						end
					elseif field == 'key_level' then
						if A.FRIENDS[i][field] >= keyLevelLowerBound and A.FRIENDS[i][field] <= keyLevelUpperBound then
							isShownInFilter = true
						end
					else
						if strfind(strlower(A.FRIENDS[i][field]):sub(1, A.FRIENDS[i][field]:find('-') - 1), strlower(filterText)) or strfind(strlower(A.FRIENDS[i].btag), strlower(filterText)) then
							isShownInFilter = true
						end
					end
				end
				A.FRIENDS[i].isShown = A.FRIENDS[i].isShown and isShownInFilter
			end

		if A.FRIENDS[i].isShown then
			A.numShown = A.numShown + 1
		end
	end
end
e.AddListFilter('FRIENDS', FriendFilter)

local function CompareFriendNames(a, b)
	local s = string.lower(a.btag) or '|'
	local t = string.lower(b.btag) or '|'
	if AstralKeysSettings.frame.orientation == 0 then
		if s > t then
			return true
		elseif
			s < t then
			return false
		else
			return string.lower(a.character_name) > string.lower(b.character_name)
		end
	else
		if s < t then
			return true
		elseif
			s > t then
			return false
		else
			return string.lower(a.character_name) < string.lower(b.character_name)
		end
	end
end

local function FriendSort(A, v)
	if v == 'dungeon_name' then
		table.sort(A, function(a, b)
			local aOnline = e.IsFriendOnline(a.character_name) and 1 or 0
			local bOnline = e.IsFriendOnline(b.character_name) and 1 or 0
			if not AstralKeysSettings.frame.mingle_offline.isEnabled then
				aOnline = true
				bOnline = true
			end
			if aOnline == bOnline then
				if AstralKeysSettings.frame.orientation == 0 then
					if e.GetMapName(a.mapID) > e.GetMapName(b.mapID) then
						return true
					elseif e.GetMapName(b.mapID) > e.GetMapName(a.mapID) then
						return false
					else
						return a.character_name < b.character_name
					end
				else
					if e.GetMapName(a.mapID) > e.GetMapName(b.mapID) then
						return false
					elseif e.GetMapName(b.mapID) > e.GetMapName(a.mapID) then
						return true
					else
						return CompareFriendNames(a, b)
					end
				end
			else
				return aOnline > bOnline
			end
		end)
	else
		if v == 'character_name' then
			table.sort(A, function(a, b)
				local aOnline = e.IsFriendOnline(a.character_name) and 1 or 0
				local bOnline = e.IsFriendOnline(b.character_name) and 1 or 0
				if not AstralKeysSettings.frame.mingle_offline.isEnabled then
					aOnline = true
					bOnline = true
				end
				if aOnline == bOnline then
					return CompareFriendNames(a, b)
				else
					return aOnline > bOnline
				end
			end)
		else
			table.sort(A, function(a, b) 
				local aOnline = e.IsFriendOnline(a.character_name) and 1 or 0
				local bOnline = e.IsFriendOnline(b.character_name) and 1 or 0
				if not AstralKeysSettings.frame.mingle_offline.isEnabled then
					aOnline = true
					bOnline = true
				end
				if aOnline == bOnline then
					if AstralKeysSettings.frame.orientation == 0 then
						if a[v] > b[v] then
							return true
						elseif
							a[v] < b[v]  then
							return false
						else
							return CompareFriendNames(a, b)
						end
					else
						if a[v] < b[v] then
							return true
						elseif
							a[v] > b[v]  then
							return false
						else
							return CompareFriendNames(a, b)
						end
					end
				else
					return aOnline > bOnline
				end
			end)
		end
	end
end

e.AddListSort('FRIENDS', FriendSort)

-- Friend's list Hooking
do
	for i = 1, 5 do
		local string = FriendsTooltip:CreateFontString('FriendsTooltipAstralKeysInfo' .. i, 'ARTWORK', 'FriendsFont_Small')
		string:SetJustifyH('LEFT')
		string:SetSize(168, 0)
		string:SetTextColor(0.486, 0.518, 0.541)
	end

	local OnEnter, OnHide
	function OnEnter(self)
		if not self.id then return end -- Friend Groups adds fake units with no ide for group heeaders
		if not AstralKeysSettings.general.show_tooltip_key.isEnabled then return end

		local left = FRIENDS_TOOLTIP_MAX_WIDTH - FRIENDS_TOOLTIP_MARGIN_WIDTH - FriendsTooltipAstralKeysInfo1:GetWidth()
		local stringShown = false

		for gameIndex = 1, C_BattleNet.GetFriendNumGameAccounts(self.id) do
			local gameAccountInfo = C_BattleNet.GetFriendGameAccountInfo(self.id, gameIndex)

			if (not gameAccountInfo) or (gameAccountInfo.clientProgram ~= BNET_CLIENT_WOW) or (gameAccountInfo.wowProjectID ~= 1) then return end -- They aren't using retail wow

			if not FriendsTooltip.maxWidth then return end -- Why? Who knows

			local characterNameString = _G['FriendsTooltipGameAccount' .. gameIndex .. 'Name']
			local gameInfoString = _G['FriendsTooltipGameAccount' .. gameIndex .. 'Info']
			local astralKeyString = _G['FriendsTooltipAstralKeysInfo' .. gameIndex]

			if gameAccountInfo.gameAccountID then
				if not gameAccountInfo.realmName then
					gameAccountInfo = C_BattleNet.GetFriendGameAccountInfo(index, gameIndex)
				end
				local fullName = gameAccountInfo.characterName .. '-' .. gameAccountInfo.realmName
				local id = e.FriendID(fullName)

				if id then
					local keyLevel, dungeonID = AstralFriends[id][5], AstralFriends[id][4]
					astralKeyString:SetWordWrap(false)
					astralKeyString:SetFormattedText("|cffffd200Current Keystone|r\n%d - %s", keyLevel, e.GetMapName(dungeonID))
					astralKeyString:SetWordWrap(true)
					astralKeyString:SetPoint('TOP', characterNameString, 'BOTTOM', 3, -4)
					gameInfoString:SetPoint('TOP', astralKeyString, 'BOTTOM', 0, 0)
					astralKeyString:Show()
					stringShown = true
					FriendsTooltip.height = FriendsTooltip:GetHeight() + astralKeyString:GetStringHeight()
					FriendsTooltip.maxWidth = max(FriendsTooltip.maxWidth, astralKeyString:GetStringWidth() + left)
				else
					astralKeyString:SetText('')
					astralKeyString:Hide()
					gameInfoString:SetPoint('TOP', characterNameString, 'BOTTOM', 0, -4)
				end
			end
		end
		
		FriendsTooltip:SetWidth(min(FRIENDS_TOOLTIP_MAX_WIDTH, FriendsTooltip.maxWidth + FRIENDS_TOOLTIP_MARGIN_WIDTH));
		FriendsTooltip:SetHeight(FriendsTooltip.height + (stringShown and 0 or FRIENDS_TOOLTIP_MARGIN_WIDTH))
	end

	function OnHide()
		FriendsTooltipAstralKeysInfo1:SetText('')
		FriendsTooltipAstralKeysInfo1:Hide()
	end

	local buttons = FriendsListFrameScrollFrame.buttons
	for i = 1, #buttons do
		local button = buttons[i]
		button:HookScript("OnEnter", OnEnter)
	end

	FriendsTooltip:HookScript('OnHide', OnHide)
	FriendsTooltip:HookScript('OnShow', OnEnter)
	--hooksecurefunc('FriendsFrameTooltip_Show', OnEnter)
end

local function TooltipHook(self)
    if not AstralKeysSettings.general.show_tooltip_key.isEnabled then return end

    local _, uid = self:GetUnit()
    if not UnitIsPlayer(uid) then return end

    local unitName, unitRealm = UnitFullName(uid)
    unitRealm = ((unitRealm ~= '' and unitRealm) or GetRealmName()):gsub('%s+', '')
    local unit = string.format('%s-%s', unitName, (unitRealm or GetRealmName()):gsub('%s+', ''))

    local id = e.UnitID(unit)
    if id then
    	GameTooltip:AddLine(' ')
        GameTooltip:AddLine('Current Keystone')
        GameTooltip:AddDoubleLine(e.GetMapName(e.UnitMapID(id)), e.UnitKeyLevel(id), 1, 1, 1, 1, 1, 1)
        return
    end

    local id = e.FriendID(unit)
    if id then
    	GameTooltip:AddLine(' ')
        GameTooltip:AddLine('Current Keystone')
        GameTooltip:AddDoubleLine(e.GetMapName(AstralFriends[id][4]), AstralFriends[id][5], 1, 1, 1, 1, 1, 1)
        return
    end
end

GameTooltip:HookScript('OnTooltipSetUnit', TooltipHook)

local function FriendUnitFunction(self, unit, class, mapID, keyLevel, weekly_best, faction, btag)
	self.unitID = e.FriendID(unit)
	self.levelString:SetText(keyLevel)
	self.dungeonString:SetText(e.GetMapName(mapID))
	if weekly_best and weekly_best > 1 then
		local color_code = e.GetDifficultyColour(weekly_best)
		self.bestString:SetText(WrapTextInColorCode(weekly_best, color_code))
	else
		self.bestString:SetText(nil)
	end
	--self.weeklyTexture:SetShown(cache == 1)
	if btag then
		if tonumber(faction) == e.FACTION then
			self.nameString:SetText( string.format('%s (%s)', WrapTextInColorCode(btag:sub(1, btag:find('#') - 1), COLOR_BLUE_BNET), WrapTextInColorCode(unit:sub(1, unit:find('-') - 1), select(4, GetClassColor(class)))))
		else
			self.nameString:SetText( string.format('%s (%s)', WrapTextInColorCode(btag:sub(1, btag:find('#') - 1), COLOR_BLUE_BNET), WrapTextInColorCode(unit:sub(1, unit:find('-') - 1), 'ff9d9d9d')))
		end
	else
		self.nameString:SetText(WrapTextInColorCode(unit:sub(1, unit:find('-') - 1), select(4, GetClassColor(class))))
	end
	if e.IsFriendOnline(unit) then
		self:SetAlpha(1)
	else
		self:SetAlpha(0.4)
	end
end

e.AddUnitFunction('FRIENDS', FriendUnitFunction)