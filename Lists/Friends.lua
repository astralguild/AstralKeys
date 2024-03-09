local _, addon = ...

local SYNC_VERSION = 'sync4'
local UPDATE_VERSION = 'update4'

local COLOR_BLUE_BNET = 'ff82c5ff'

local strformat, find = string.format, string.find

local NonBNFriend_List = {}
local BNFriendList = {}
local FRIEND_LIST = {}
local BNET_GAID_TO_BATTLETAG = {}

----------------------------------------------------
----------------------------------------------------
-- Returns a player's game account ID
-- @param characterName string Full character name of the player being looked up
-- Only used for inviting people through the AK interface. Not worth the resources to invert the table for a quicker look up time since it would need to be inverted each time the friends list is upodated
function addon.GetFriendGaID(characterName)
	for gaID, target in pairs(BNFriendList) do
		if target == characterName then
			return gaID
		end
	end
	return nil
end

-- Updates BNFriendList for friend update
-- @param index int Friend's list index that was updated
function addon.BNFriendUpdate(index)
	if not index then return end -- No index, event fired from player

	local accountInfo = C_BattleNet.GetFriendAccountInfo(index)

	for gameIndex = 1, C_BattleNet.GetFriendNumGameAccounts(index) do		
		local gameAccountInfo = C_BattleNet.GetFriendGameAccountInfo(index, gameIndex)		
		if BNFriendList[gameAccountInfo.gameAccountID] and gameAccountInfo.clientProgram ~= BNET_CLIENT_WOW and gameAccountInfo.wowProjectID ~= 1 then -- They are logged into the client, but they are not logged into retail WoW
			BNFriendList[gameAccountInfo.gameAccountID] = nil
		end
		if gameAccountInfo and gameAccountInfo.clientProgram == BNET_CLIENT_WOW and gameAccountInfo.wowProjectID == 1 then --1 is used for retail
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
				FRIEND_LIST[fullName].account_name = accountInfo.accountName
				FRIEND_LIST[fullName].battle_tag = accountInfo.battleTag
				FRIEND_LIST[fullName].isConnected = true
			else
				FRIEND_LIST[fullName] = {}
				FRIEND_LIST[fullName].account_name = accountInfo.accountName
				FRIEND_LIST[fullName].battle_tag = accountInfo.battleTag
				FRIEND_LIST[fullName].isConnected = true
			end
			if NonBNFriend_List[fullName] then
				NonBNFriend_List[fullName] = nil
			end
		end
		if gameAccountInfo.gameAccountID then
			BNET_GAID_TO_BATTLETAG[gameAccountInfo.gameAccountID] = accountInfo.battleTag
		end
	end
end
AstralEvents:Register('BN_FRIEND_INFO_CHANGED', addon.BNFriendUpdate, 'update_BNFriend')

----------------------------------------------------
----------------------------------------------------
function addon.FriendGUID(unit)
	if not FRIEND_LIST[unit] then return nil end
	return FRIEND_LIST[unit].guid
end

function addon.FriendPresName(unit)
	if not FRIEND_LIST[unit] then return nil end
	return FRIEND_LIST[unit].account_name
end

function addon.WipeFriendList()
	wipe(FRIEND_LIST)
end

function addon.IsFriendOnline(unit)
	return (FRIEND_LIST[unit] and FRIEND_LIST[unit].isConnected) or (NonBNFriend_List[unit] and NonBNFriend_List[unit].isConnected)
end
----------------------------------------------------
----------------------------------------------------
---- Non BNet Friend stuff

local function UpdateNonBNetFriendList()
	wipe(NonBNFriend_List)

	for _,v in pairs(FRIEND_LIST) do
		v.isConnected = false
	end

	for i = 1, C_FriendList.GetNumOnlineFriends() do
		local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
		local name = strformat('%s-%s', friendInfo.name, addon.PlayerRealm())
		NonBNFriend_List[name] = {isConnected = friendInfo.connected}
		if FRIEND_LIST[name] then
			FRIEND_LIST[name].isConnected = true
			FRIEND_LIST[name].guid = guid
		end
	end

	for index = 1, BNGetNumFriends() do
		addon.BNFriendUpdate(index)
	end
end
AstralEvents:Register('FRIENDLIST_UPDATE', UpdateNonBNetFriendList, 'update_non_bnet_list')

----------------------------------------------------
----------------------------------------------------
-- Friend Syncing

local function RecieveKey(msg, sender)
	if not AstralKeysSettings.friendOptions.friend_sync.isEnabled then return end
	
	local timeStamp = addon.WeekTime()
	local unit, class, dungeonID, keyLevel, weekly_best, week, faction = strsplit(':', msg)

	local btag

	if type(sender) == 'number' then
		btag = BNET_GAID_TO_BATTLETAG[sender]
	end

	dungeonID = tonumber(dungeonID)
	keyLevel = tonumber(keyLevel)
	week = tonumber(week)
	weekly_best = tonumber(weekly_best)

	local id = addon.UnitID(unit)

	if id then
		AstralKeys[id].dungeon_id = dungeonID
		AstralKeys[id].key_level = keyLevel
		AstralKeys[id].week = week
		AstralKeys[id].time_stamp = timeStamp
		AstralKeys[id].weekly_best = weekly_best
		AstralKeys[id].btag = btag
	else
		table.insert(AstralKeys, {
			unit = unit,
			btag = btag,
			class = class,
			dungeon_id = dungeonID,
			key_level = keyLevel,
			week = week,
			time_stamp = timeStamp,
			faction = faction,
			weekly_best = weekly_best,
			source = 'friend',
		})
		addon.SetUnitID(unit, #AstralKeys)
		C_FriendList.ShowFriends()
	end
	addon.AddUnitToSortTable(unit, btag, class, faction, dungeonID, keyLevel, weekly_best, 'FRIENDS')
	addon.AddUnitToList(unit, 'FRIENDS', btag)

	msg = nil
	if addon.FrameListShown() == 'FRIENDS' then
		addon.UpdateFrames()
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
		btag = BNET_GAID_TO_BATTLETAG[sender]
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

		if week >= addon.Week then
			local id = addon.UnitID(unit)
			if id then
				AstralKeys[id].dungeon_id = dungeonID
				AstralKeys[id].key_level = keyLevel
				AstralKeys[id].week = week
				AstralKeys[id].time_stamp = timeStamp
				AstralKeys[id].weekly_best = weekly_best
				AstralKeys[id].btag = btag
			else
				table.insert(AstralKeys, {
					unit = unit,
					btag = btag,
					class = class,
					dungeon_id = dungeonID,
					key_level = keyLevel,
					week = week,
					time_stamp = timeStamp,
					faction = faction,
					weekly_best = weekly_best,
					source = 'friend'
				})
				addon.SetUnitID(unit, #AstralKeys)
				C_FriendList.ShowFriends()
			end
			addon.AddUnitToList(unit, 'FRIENDS', btag)
			addon.AddUnitToSortTable(unit, btag, class, faction, dungeonID, keyLevel, weekly_best, 'FRIENDS')
			--e.AddUnitToTable(unit, class, faction, 'FRIENDS', dungeonID, keyLevel, weekly_best, btag)
		end
	end
	entry = nil
end
AstralComs:RegisterPrefix('BNET', SYNC_VERSION, SyncFriendUpdate)
AstralComs:RegisterPrefix('WHISPER', SYNC_VERSION, SyncFriendUpdate)

local function UpdateWeekly(msg)
	local unit, weekly_best = strsplit(':', msg)

	local id = addon.UnitID(unit)
	if id then
		AstralKeys[id].weekly_best = tonumber(weekly_best)
		AstralKeys[id].time_stamp = addon.WeekTime()
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
		local id = addon.UnitID(AstralCharacters[i].unit)
		if id then -- We have a key for this character, let's get the message and queue it up
			local map, level = addon.UnitMapID(id), addon.UnitKeyLevel(id)
			messageStack[#messageStack + 1] = strformat('%s_', strformat('%s:%s:%d:%d:%d:%d:%d:%d', AstralCharacters[i].unit, addon.UnitClass(id), map, level, addon.Week, AstralKeys[id][7], AstralCharacters[i].faction, AstralCharacters[i].weekly_best)) -- name-server:class:mapID:keyLevel:week#:weekTime:faction:weekly
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

	addon.PushKeyDataToFriends(messageQueue, target)
end

-- Sends data to BNeT friends and Non-BNet friends
-- @param data table Sync data that includes all keys for all of person's characters
-- @param data string Update string including only logged in person's characters
function addon.PushKeyDataToFriends(data, target)
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
	for i = 1, C_FriendList.GetNumOnlineFriends() do -- Only parse over online friends
		local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
		local name = strformat('%s-%s', friendInfo.name, addon.PlayerRealm())

		NonBNFriend_List[name] = {isConnected = friendInfo.connected}
	end

	for index = 1, BNGetNumFriends() do
		addon.BNFriendUpdate(index)
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
	if msg:find('ping') then
		AstralComs:NewMessage('AstralKeys', 'BNet_query response', type(sender) == 'number' and 'BNET' or 'WHISPER', sender)
	end
	PushKeysToFriends(sender)
end
AstralComs:RegisterPrefix('WHISPER', 'BNet_query', PingResponse)
AstralComs:RegisterPrefix('BNET', 'BNet_query', PingResponse)

local function Init()
	C_FriendList.ShowFriends()
	AstralEvents:Unregister('PLAYER_ENTERING_WORLD', 'InitFriends')
end
AstralEvents:Register('FRIENDLIST_UPDATE', PingFriendsForAstralKeys, 'pingFriends')
AstralEvents:Register('PLAYER_ENTERING_WORLD', Init, 'InitFriends')


function addon.ToggleFriendSync()
	if AstralKeysSettings.friendOptions.friend_sync.isEnabled then
		AstralComs:RegisterPrefix('WHISPER', 'BNet_query', PingResponse)
		AstralComs:RegisterPrefix('BNET', 'BNet_query', PingResponse)
		AstralComs:RegisterPrefix('BNET', SYNC_VERSION, SyncFriendUpdate)
		AstralComs:RegisterPrefix('WHISPER', SYNC_VERSION, SyncFriendUpdate)
		AstralComs:RegisterPrefix('BNET', UPDATE_VERSION, RecieveKey)
		AstralComs:RegisterPrefix('WHISPER', UPDATE_VERSION, RecieveKey)
		AstralEvents:Register('FRIENDLIST_UPDATE', UpdateNonBNetFriendList, 'update_non_bnet_list')
		AstralEvents:Register('BN_FRIEND_INFO_CHANGED', addon.BNFriendUpdate, 'update_BNFriend')
		PingFriendsForAstralKeys()
	else
		AstralComs:UnregisterPrefix('WHISPER', 'BNet_query', PingResponse)
		AstralComs:UnregisterPrefix('BNET', 'BNet_query', PingResponse)
		AstralComs:UnregisterPrefix('BNET', SYNC_VERSION, SyncFriendUpdate)
		AstralComs:UnregisterPrefix('WHISPER', SYNC_VERSION, SyncFriendUpdate)
		AstralComs:UnregisterPrefix('BNET', UPDATE_VERSION, RecieveKey)
		AstralComs:UnregisterPrefix('WHISPER', UPDATE_VERSION, RecieveKey)
		AstralEvents:Unregister('FRIENDLIST_UPDATE', UpdateNonBNetFriendList, 'update_non_bnet_list')
		AstralEvents:Unregister('BN_FRIEND_INFO_CHANGED', addon.BNFriendUpdate, 'update_BNFriend')
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

	for i = 1, #A do
		if AstralKeysSettings.frame.show_offline.isEnabled then
			A[i].isShown = true
		else
			A[i].isShown = addon.IsFriendOnline(A[i].character_name)
		end

		if not AstralKeysSettings.friendOptions.show_other_faction.isEnabled then
			A[i].isShown = A[i].isShown and tonumber(A[i].faction) == addon.FACTION
		end

		local isShownInFilter = true -- Assume there is no filter taking place
		
		for field, filterText in pairs(filters) do
				if filterText ~= '' then
					isShownInFilter = false -- There is a filter, now assume this unit is not to be shown
					if field == 'dungeon_name' then
						local mapName = addon.GetMapName(A[i]['mapID'])
						if strfind(strlower(mapName), strlower(filterText)) then
							isShownInFilter = true
						end
					elseif field == 'key_level' then
						if A[i][field] >= keyLevelLowerBound and A[i][field] <= keyLevelUpperBound then
							isShownInFilter = true
						end
					else
						if strfind(strlower(A[i][field]):sub(1, A[i][field]:find('-') - 1), strlower(filterText)) or strfind(strlower(A[i].btag), strlower(filterText)) then
							isShownInFilter = true
						end
					end
				end
				A[i].isShown = A[i].isShown and isShownInFilter
			end

		if A[i].isShown then
			A.num_shown = A.num_shown + 1
		end
	end
end
addon.AddListFilter('FRIENDS', FriendFilter)

local function CompareFriendNames(a, b)
	local s = string.lower(a.btag or '|')
	local t = string.lower(b.btag or '|')
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
			local aOnline = addon.IsFriendOnline(a.character_name) and 1 or 0
			local bOnline = addon.IsFriendOnline(b.character_name) and 1 or 0
			if not AstralKeysSettings.frame.mingle_offline.isEnabled then
				aOnline = true
				bOnline = true
			end
			if aOnline == bOnline then
				if AstralKeysSettings.frame.orientation == 0 then
					if addon.GetMapName(a.mapID) > addon.GetMapName(b.mapID) then
						return true
					elseif addon.GetMapName(b.mapID) > addon.GetMapName(a.mapID) then
						return false
					else
						return a.character_name < b.character_name
					end
				else
					if addon.GetMapName(a.mapID) > addon.GetMapName(b.mapID) then
						return false
					elseif addon.GetMapName(b.mapID) > addon.GetMapName(a.mapID) then
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
				local aOnline = addon.IsFriendOnline(a.character_name) and 1 or 0
				local bOnline = addon.IsFriendOnline(b.character_name) and 1 or 0
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
				local aOnline = addon.IsFriendOnline(a.character_name) and 1 or 0
				local bOnline = addon.IsFriendOnline(b.character_name) and 1 or 0
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

addon.AddListSort('FRIENDS', FriendSort)

-- Friend's list Hooking
do
	for i = 1, 5 do
		local textString = FriendsTooltip:CreateFontString('FriendsTooltipAstralKeysInfo' .. i, 'ARTWORK', 'FriendsFont_Small')
		textString:SetJustifyH('LEFT')
		textString:SetSize(168, 0)
		textString:SetTextColor(0.486, 0.518, 0.541)
	end

	local OnEnter, OnHide
	function OnEnter(self)
		if not self.id then return end -- Friend Groups adds fake units with no ide for group heeaders
		if not AstralKeysSettings.general.show_tooltip_key.isEnabled then return end
		if not FriendsTooltip.maxWidth then return end -- Why? Who knows

		local left = FRIENDS_TOOLTIP_MAX_WIDTH - FRIENDS_TOOLTIP_MARGIN_WIDTH - FriendsTooltipAstralKeysInfo1:GetWidth()
		local stringShown = false

		for gameIndex = 1, C_BattleNet.GetFriendNumGameAccounts(self.id) do
			if gameIndex > FRIENDS_TOOLTIP_MAX_GAME_ACCOUNTS then break end -- Blizzard only wrote lines for 5 game indices
			local gameAccountInfo = C_BattleNet.GetFriendGameAccountInfo(self.id, gameIndex)
			local characterNameString = _G['FriendsTooltipGameAccount' .. gameIndex .. 'Name']
			local gameInfoString = _G['FriendsTooltipGameAccount' .. gameIndex .. 'Info']
			local astralKeyString = _G['FriendsTooltipAstralKeysInfo' .. gameIndex]

			if (gameAccountInfo) and (gameAccountInfo.clientProgram == BNET_CLIENT_WOW) and (gameAccountInfo.wowProjectID == 1) then -- They are playing retail WoW

				if gameAccountInfo.gameAccountID then
					local realmName
					if gameAccountInfo.realmName then
						realmName = gameAccountInfo.realmName
					elseif gameAccountInfo.realmDisplayName then
						realmName = gameAccountInfo.realmDisplayName:gsub('%s+', '')
					elseif gameAccountInfo.richPresence and gameAccountInfo.richPresence:find('-') then
						realmName = gameAccountInfo.richPresence:sub(gameAccountInfo.richPresence:find('-') + 1, -1):gsub('%s+', '') -- Character - Realm Name stripped down to RealmName
					else
						-- I really don't know what is going on with their API....
					end
					if realmName then
						local fullName = gameAccountInfo.characterName .. '-' .. realmName
						local id = addon.UnitID(fullName)
						if id then
							local keyLevel, dungeonID = AstralKeys[id].key_level, AstralKeys[id].dungeon_id
							astralKeyString:SetWordWrap(false)
							astralKeyString:SetFormattedText("|cffffd200Current Keystone|r\n%d - %s", keyLevel, addon.GetMapName(dungeonID))
							astralKeyString:SetWordWrap(true)
							astralKeyString:SetPoint('TOP', characterNameString, 'BOTTOM', 3, -4)
							gameInfoString:SetPoint('TOP', astralKeyString, 'BOTTOM', 0, 0)
							astralKeyString:Show()
							stringShown = true
							FriendsTooltip.height = FriendsTooltip:GetHeight() + astralKeyString:GetStringHeight() + 8
							FriendsTooltip.maxWidth = max(FriendsTooltip.maxWidth, astralKeyString:GetStringWidth() + left)
						else
							astralKeyString:SetText('')
							astralKeyString:Hide()
							gameInfoString:SetPoint('TOP', characterNameString, 'BOTTOM', 0, -4)
						end
					end
				end
			else
				astralKeyString:SetText('')
				astralKeyString:Hide()
			end
		end
		
		FriendsTooltip:SetWidth(min(FRIENDS_TOOLTIP_MAX_WIDTH, FriendsTooltip.maxWidth + FRIENDS_TOOLTIP_MARGIN_WIDTH));
		FriendsTooltip:SetHeight(FriendsTooltip.height + (stringShown and 0 or (FRIENDS_TOOLTIP_MARGIN_WIDTH + 8)))
	end

	function OnHide()
		FriendsTooltipAstralKeysInfo1:SetText('')
		FriendsTooltipAstralKeysInfo1:Hide()
	end

	local buttons = FriendsListFrame.ScrollBox
	for i = 1, #buttons do
		local button = buttons[i]
		local oldOnEnter = button.OnEnter
		function button:OnEnter()
			oldOnEnter(self)
			OnEnter(self)
		end
		button:HookScript("OnEnter", OnEnter)
	end

	FriendsTooltip:HookScript('OnHide', OnHide)
	FriendsTooltip:HookScript('OnEnter', OnEnter)
end

local function TooltipHook(self)
	if not AstralKeysSettings.general.show_tooltip_key.isEnabled then return end

	if self.GetUnit~=nil then 
    local _, uid = self:GetUnit()
    if not UnitIsPlayer(uid) then return end

    local unitName, unitRealm = UnitFullName(uid)
    unitRealm = ((unitRealm ~= '' and unitRealm) or GetRealmName()):gsub('%s+', '')
    local unit = string.format('%s-%s', unitName, (unitRealm or GetRealmName()):gsub('%s+', ''))

    local id = addon.UnitID(unit)
    if id then
    	GameTooltip:AddLine(' ')
        GameTooltip:AddLine('Current Keystone')
        GameTooltip:AddDoubleLine(addon.GetMapName(addon.UnitMapID(id)), addon.UnitKeyLevel(id), 1, 1, 1, 1, 1, 1)
        return
    end
	end
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, TooltipHook)

local function FriendUnitFunction(self, unit, class, mapID, keyLevel, weekly_best, faction, btag)
	self.unitID = addon.UnitID(unit)
	self.levelString:SetText(keyLevel)
	self.dungeonString:SetText(addon.GetMapName(mapID))
	if weekly_best and weekly_best > 1 then
		local color_code = addon.GetDifficultyColour(weekly_best)
		self.bestString:SetText(WrapTextInColorCode(weekly_best, color_code))
	else
		self.bestString:SetText(nil)
	end
	--self.weeklyTexture:SetShown(cache == 1)
	if btag then
		if tonumber(faction) == addon.FACTION then
			self.nameString:SetText( string.format('%s (%s)', WrapTextInColorCode(btag:sub(1, btag:find('#') - 1), COLOR_BLUE_BNET), WrapTextInColorCode(unit:sub(1, unit:find('-') - 1), select(4, GetClassColor(class)))))
		else
			self.nameString:SetText( string.format('%s (%s)', WrapTextInColorCode(btag:sub(1, btag:find('#') - 1), COLOR_BLUE_BNET), WrapTextInColorCode(unit:sub(1, unit:find('-') - 1), 'ff9d9d9d')))
		end
	else
		self.nameString:SetText(WrapTextInColorCode(unit:sub(1, unit:find('-') - 1), select(4, GetClassColor(class))))
	end
	if addon.IsUnitOnline(unit) then
		self:SetAlpha(1)
	else
		self:SetAlpha(0.4)
	end
end

addon.AddUnitFunction('FRIENDS', FriendUnitFunction)
