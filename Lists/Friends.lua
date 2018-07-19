local ADDON, e = ...
local MAX_LEVEL = 110

local SYNC_VERSION = 'sync4'
local UPDATE_VERSION = 'update4'

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
local BNGetGameAccountInfo = BNGetGameAccountInfo

-- BNGetNumFOF(BNetID) -- Seems to take first return value from BNGetFriendInfo

local isConnected = BNConnected() -- Determine if connected to BNet, if not disable all comms, check for BN_CONNECTED to re-enable communications, BN_DISCONNECTED disable communications on this event

function e.GetFriendGaID(battleTag)
	if not BNFriendList[battleTag] then return nil end
	return BNFriendList[battleTag].gaID
end

function e.FriendBattleTag(id)
	return AstralFriends[id][2]:sub(1, AstralFriends[id][2]:find('#') - 1)
end

-- Updates BNFriendList for friend update
-- @paremt index int Friend's list index that was updated
function e.BNFriendUpdate(index)
	if not index then return end -- No index, event fired from player
	local presID, pName, battleTag, _, toonName, gaID, client = BNGetFriendInfo(index) -- Let's get some fresh info, client != 'WoW' when on character list it seems

	if not gaID then return end -- No game pressence ID, can't talk to them then

	local guid = select(20, BNGetGameAccountInfo(gaID))

	if client == BNET_CLIENT_WOW and toonName then
		local fullName = toonName .. '-' .. select(4, BNGetGameAccountInfo(gaID))
		if FRIEND_LIST[fullName] then
			FRIEND_LIST[fullName].guid = guid
			FRIEND_LIST[fullName].pName = pName
			FRIEND_LIST[fullName].isConnected = true
		end
		if NonBNFriend_List[fullName] then
			NonBNFriend_List[fullName].isBtag = true
		end
	end

	if not BNFriendList[battleTag] then		
		BNFriendList[battleTag] = {toonName = toonName, client = client, gaID = gaID, usingAK = false}
	else
		BNFriendList[battleTag].client = client --Update client, did they log off WoW?
		BNFriendList[battleTag].presID = presID or 0 -- If they have a presID force an update, else set to 0. Used for all API needing a pressence ID
		BNFriendList[battleTag].gaID = gaID -- Might as well keep it up to date
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

function e.FriendGAID(unit)
	return FRIEND_LIST[unit].gaID
end

function e.FriendPresName(unit)
	return FRIEND_LIST[unit].pName
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
		local name = strformat('%s-%s', GetFriendInfo(i), e.PlayerRealm())
		local guid = select(9, GetFriendInfo(i))
		NonBNFriend_List[name] = {isBtag = false}
		if FRIEND_LIST[name] then
			FRIEND_LIST[name].isConnected = true
			FRIEND_LIST[name].guid = guid
		end
	end

	for i = 1, BNGetNumFriends() do
		local presID, pName, battleTag, _, toonName, gaID, client = BNGetFriendInfo(i)
		if gaID and toonName then
		local guid = select(20, BNGetGameAccountInfo(gaID))
			BNFriendList[battleTag] = {toonName = toonName, client = client, gaID = gaID, usingAK = false}
			if client == BNET_CLIENT_WOW then
				local fullName = toonName .. '-' .. select(4, BNGetGameAccountInfo(gaID))	
				if NonBNFriend_List[fullName] then
					NonBNFriend_List[fullName].isBtag = true -- don't need to send people on WoW friend and bnet friend the same data.
				end
				if FRIEND_LIST[fullName] then
					FRIEND_LIST[fullName].isConnected = true
					FRIEND_LIST[fullName].guid = guid
					FRIEND_LIST[fullName].pName = pName
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
	if not AstralKeysSettings.options.friendSync then return end
	local btag
	if type(sender) == 'number' then
		local bnetID = select(17, BNGetGameAccountInfo(sender))
		btag = select(3, BNGetFriendInfo(BNGetFriendIndex(bnetID)))
	end

	local timeStamp = e.WeekTime()
	local unit, class, dungeonID, keyLevel, weekly, week, faction = strsplit(':', msg)

	dungeonID = tonumber(dungeonID)
	keyLevel = tonumber(keyLevel)
	week = tonumber(week)
	weekly = tonumber(weekly)

	local id = e.FriendID(unit)

	if id then
		AstralFriends[id][4] = dungeonID
		AstralFriends[id][5] = keyLevel
		AstralFriends[id][6] = week
		AstralFriends[id][7] = timeStamp
		AstralFriends[id][9] = weekly
	else
		AstralFriends[#AstralFriends + 1] = {unit, btag, class, dungeonID, keyLevel, week, timeStamp, faction, weekly}
		e.SetFriendID(unit, #AstralFriends)
		ShowFriends()
	end

	e.AddUnitToTable(unit, class, faction, 'friend', dungeonID, keyLevel, weekly, btag)

	if e.FrameListShown() == 'friends' then 
		e.UpdateFrames()
	end
end
AstralComs:RegisterPrefix('BNET', UPDATE_VERSION, RecieveKey)
AstralComs:RegisterPrefix('WHISPER', UPDATE_VERSION, RecieveKey)

local function SyncFriendUpdate(entry, sender)
	if not AstralKeysSettings.options.friendSync then return end

	if AstralKeyFrame:IsShown() then
		AstralKeyFrame:SetScript('OnUpdate', AstralKeyFrame.OnUpdate)
		AstralKeyFrame.updateDelay = 0
	end

	local btag
	if type(sender) == 'number' then	
		local bnetID = select(17, BNGetGameAccountInfo(sender))
		btag = select(3, BNGetFriendInfo(BNGetFriendIndex(bnetID)))
	end

	if AstralKeyFrame:IsShown() then
		AstralKeyFrame:SetScript('OnUpdate', AstralKeyFrame.OnUpdate)
		AstralKeyFrame.updateDelay = 0
	end

	local unit, class, dungeonID, keyLevel, week, timeStamp

	local _pos = 0
	while find(entry, '_', _pos) do

		class, dungeonID, keyLevel, week, timeStamp, faction, weekly = entry:match(':(%a+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+)', entry:find(':', _pos))
		unit = entry:sub(_pos, entry:find(':', _pos) - 1)

		_pos = find(entry, '_', _pos) + 1

		dungeonID = tonumber(dungeonID)
		keyLevel = tonumber(keyLevel)
		week = tonumber(week)
		timeStamp = tonumber(timeStamp)
		weekly = tonumber(weekly)

		if week >= e.Week then 

			local id = e.FriendID(unit)
			if id then
				if weekly == 1 then
					AstralFriends[id][9] = 1
				end
				if AstralFriends[id][7] < timeStamp then
					AstralFriends[id][4] = dungeonID
					AstralFriends[id][5] = keyLevel
					AstralFriends[id][6] = week
					AstralFriends[id][7] = timeStamp
				end
			else
				AstralFriends[#AstralFriends + 1] = {unit, btag, class, dungeonID, keyLevel, week, timeStamp, faction}
				e.SetFriendID(unit, #AstralFriends)
				ShowFriends()
			end
			e.AddUnitToTable(unit, class, faction, 'friend', dungeonID, keyLevel, weekly, btag)
		end
	end
end
AstralComs:RegisterPrefix('BNET', SYNC_VERSION, SyncFriendUpdate)
AstralComs:RegisterPrefix('WHISPER', SYNC_VERSION, SyncFriendUpdate)

local function UpdateWeekly(msg)
	local unit, weekly = strsplit(':', msg)

	local id = e.FriendID(unit)
	if id then
		AstralFriends[id][9] = weekly
		AstralFriends[id][7] = e.WeekTime()
	end
end
AstralComs:RegisterPrefix('BNET', 'friendWeekly', UpdateWeekly)
AstralComs:RegisterPrefix('WHISPER', 'friendWeekly', UpdateWeekly)

local messageStack = {}
local messageQueue = {}

local function PushKeysToFriends(target)
	if not AstralKeysSettings.options.friendSync then return end
	wipe(messageStack)
	wipe(messageQueue)

	local minKeyLevel = AstralKeysSettings.options.minFriendSync or 2
	for i = 1, #AstralCharacters do
		local id = e.UnitID(AstralCharacters[i].unit)
		if id then -- We have a key for this character, let's get the message and queue it up
			local map, level = e.UnitMapID(id), e.UnitKeyLevel(id)
			local weekly = AstralCharacters[i].level >= e.CACHE_LEVEL and 1 or 0
			if level >= minKeyLevel then
				messageStack[#messageStack + 1] = strformat('%s_', strformat('%s:%s:%d:%d:%d:%d:%d:%d', AstralCharacters[i].unit, e.UnitClass(id), map, level, e.Week, AstralKeys[id][7], AstralCharacters[i].faction, weekly)) -- name-server:class:mapID:keyLevel:week#:weekTime:faction:weekly
			end
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
		for _, unit in pairs(BNFriendList) do
			if unit.client == BNET_CLIENT_WOW then --and unit.usingAk then -- Only send if they are in WoW
				if type(data) == 'table' then
					for i = 1, #data do
						AstralComs:NewMessage('AstralKeys', strformat('%s %s', SYNC_VERSION, data[i]), 'BNET', unit.gaID)
					end
				else
					AstralComs:NewMessage('AstralKeys', strformat('%s %s', UPDATE_VERSION, data), 'BNET', unit.gaID)
				end
			end
		end
		for player in pairs(NonBNFriend_List) do
			if not player.isBtag then
				if type(data) == 'table' then
					for i = 1, #data do
						AstralComs:NewMessage('AstralKeys', strformat('%s %s', SYNC_VERSION, data[i]), 'WHISPER', player)
					end
				else
					AstralComs:NewMessage('AstralKeys', strformat('%s %s', UPDATE_VERSION, data), 'WHISPER', player)
				end
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
	if not AstralKeysSettings.options.friendSync then return end
	for i = 1, select(2, GetNumFriends()) do -- Only parse over online friends
		local name = strformat('%s-%s', GetFriendInfo(i), e.PlayerRealm())
		NonBNFriend_List[name] = {isBtag = false}
	end

	for i = 1, BNGetNumFriends() do
		local presID, pName, battleTag, _, toonName, gaID, client = BNGetFriendInfo(i)

		if gaID then
			local guid = select(20, BNGetGameAccountInfo(gaID))
			BNFriendList[battleTag] = {toonName = toonName, client = client, gaID = gaID, usingAK = false}
			if client == BNET_CLIENT_WOW then
				local fullName = toonName .. '-' .. select(4, BNGetGameAccountInfo(gaID))
				if NonBNFriend_List[fullName] then
					NonBNFriend_List[fullName].isBtag = true -- don't need to send people on WoW friend and bnet friend the same data.
				end
				if FRIEND_LIST[fullName] then
					FRIEND_LIST[fullName].isConnected = true
					FRIEND_LIST[fullName].guid = guid
					FRIEND_LIST[fullName].pName = pName
				end
			end
		end
	end

	for _, player in pairs(BNFriendList) do
		if player.client == BNET_CLIENT_WOW then
			AstralComs:NewMessage('AstralKeys', 'BNet_query ping', 'BNET', player.gaID)
		end
	end

	for player in pairs(NonBNFriend_List) do
		if not player.isBtag then
			AstralComs:NewMessage('AstralKeys', 'BNet_query ping', 'WHISPER', player)
		end
	end

	AstralEvents:Unregister('FRIENDLIST_UPDATE', 'pingFriends')
end

-- Figures out who is using AK on friends list, sends them a response and key data
local function PingResponse(msg, sender)
	local btag
	if type(sender) == 'number' then
		local bnetID = select(17, BNGetGameAccountInfo(sender))
		btag = select(3, BNGetFriendInfoByID(BNGetFriendIndex(bnetID)))
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
AstralEvents:Register('PLAYER_ENTERING_WORLD', Init, 'InitFriends')

AstralEvents:Register('FRIENDLIST_UPDATE', PingFriendsForAstralKeys, 'pingFriends')

function e.ToggleFriendSync()
	if AstralKeysSettings.options.friendSync then
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

local function FriendFilter(tbl)
	if not type(tbl) == 'table' then return end

	for i = 1, #tbl.friend do
		if AstralKeysSettings.options.showOffline then
			tbl.friend[i].isShown = true
		else
			tbl.friend[i].isShown = e.IsFriendOnline(tbl.friend[i][1])
		end

		if not AstralKeysSettings.options.showOtherFaction then
			tbl.friend[i].isShown = tbl.friend[i].isShown and tonumber(tbl.friend[i][6]) == e.FACTION
		end

		if tbl.friend[i].isShown then
			tbl.numShown = tbl.numShown + 1
		end
	end
end
e.AddListFilter('friend', FriendFilter)

local function FriendSort(A, v)
	if v == 3 then -- Dungeon Name
		table.sort(A, function(a, b) 
			if AstralKeysSettings.frameOptions.orientation == 0 then
				return e.GetMapName(a[v]) > e.GetMapName(b[v])
			else
				return e.GetMapName(b[v]) > e.GetMapName(a[v])
			end
			end)
	else
		if v == 1 then -- BNet Name
			table.sort(A, function(a, b)
				local s = string.lower(a[7]) or '|'
				local t = string.lower(b[7]) or '|'
				if AstralKeysSettings.frameOptions.orientation == 0 then
					if s > t then
						return true
					elseif
						s < t then
						return false
					else
						return string.lower(a[1]) > string.lower(b[1])
					end
				else
					if s < t then
						return true
					elseif
						s > t then
						return false
					else
						return a[1] < b[1]
					end
				end
			end)
		else
			table.sort(A, function(a, b) 
				if AstralKeysSettings.frameOptions.orientation == 0 then
					return a[v] > b[v]
				else
					return a[v] < b[v]
				end
			end)
		end
	end
end

e.AddListSort('friend', FriendSort)

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
		if not AstralKeysSettings.options.showTooltip then return end

		local left = FRIENDS_TOOLTIP_MAX_WIDTH - FRIENDS_TOOLTIP_MARGIN_WIDTH - FriendsTooltipAstralKeysInfo1:GetWidth()
		local stringShown = false

		local bnetIDAccount, accountName, isBattleTag, characterName, bnetIDGameAccount, client, lastOnline, isAFK, isDND, broadcastText, noteText, isFriend, broadcastTime = BNGetFriendInfo(self.id);
		-- Call BNGetFriendInfo twice, first time doesn't seem to actually get the info?
		bnetIDAccount, accountName, battleTag, isBattleTag, characterName, bnetIDGameAccount, client, isOnline, lastOnline, isAFK, isDND, broadcastText, noteText, isFriend, broadcastTime = BNGetFriendInfo(self.id);

		if not bnetIDAccount then return end -- Double check to make sure index is actually a game account and not a Friend Groups group header.
		if not FriendsTooltip.maxWidth then return end

		local numGameAccounts = 0 

		if bnetIDGameAccount then
			local hasFocus, characterName, client, realmName, realmID, faction, race, class, _, zoneName, level, gameText = BNGetGameAccountInfo(bnetIDGameAccount)

			if client == BNET_CLIENT_WOW then
				local characterName = characterName .. '-' .. realmName:gsub('%s+', '')
				local id = e.FriendID(characterName)

				if id then
					local keyLevel, dungeonID = AstralFriends[id][5], AstralFriends[id][4]					
					FriendsTooltipAstralKeysInfo1:SetFormattedText("|cffffd200Current Keystone|r\n%d - %s", keyLevel, e.GetMapName(dungeonID))				

					FriendsTooltipAstralKeysInfo1:SetPoint('TOP', FriendsTooltipGameAccount1Name, 'BOTTOM', 3, -4)
					FriendsTooltipGameAccount1Info:SetPoint('TOP', FriendsTooltipAstralKeysInfo1, 'BOTTOM', 0, 0)
					FriendsTooltipAstralKeysInfo1:Show()
					stringShown = true
					FriendsTooltip.height = FriendsTooltip:GetHeight() + FriendsTooltipAstralKeysInfo1:GetHeight()
					FriendsTooltip.maxWidth = max(FriendsTooltip.maxWidth, FriendsTooltipAstralKeysInfo1:GetStringWidth() + left)
				else
					FriendsTooltipAstralKeysInfo1:SetText('')
					FriendsTooltipAstralKeysInfo1:Hide()
					FriendsTooltipGameAccount1Info:SetPoint('TOP', FriendsTooltipGameAccount1Name, 'BOTTOM', 0, -4)
				end
			else
				FriendsTooltipAstralKeysInfo1:SetText('')
				FriendsTooltipAstralKeysInfo1:Hide()
				FriendsTooltipGameAccount1Info:SetPoint('TOP', FriendsTooltipGameAccount1Name, 'BOTTOM', 0, -4)
			end
		end

		if isOnline then
			numGameAccounts = BNGetNumFriendGameAccounts(self.id)
		end

		local characterNameString, gameInfoString, astralKeyString
		if numGameAccounts > 1 then
			for i = 1, numGameAccounts do
				local hasFocus, characterName, client, realmName, realmID, faction, race, class, _, zoneName, level, gameText = BNGetFriendGameAccountInfo(self.id, i);
				characterNameString = _G['FriendsTooltipGameAccount' .. i .. 'Name']
				gameInfoString = _G['FriendsTooltipGameAccount' .. i .. 'Info']
				astralKeyString = _G['FriendsTooltipAstralKeysInfo' .. i]
				if client == BNET_CLIENT_WOW then
					local characterName = characterName .. '-' .. realmName:gsub('%s+', '')
					local id = e.FriendID(characterName)
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

	local buttons = FriendsFrameFriendsScrollFrame.buttons
	for i = 1, #buttons do
		local button = buttons[i]
		button:HookScript("OnEnter", OnEnter)
	end

	FriendsTooltip:HookScript('OnHide', OnHide)
	hooksecurefunc('FriendsFrameTooltip_Show', OnEnter)
end

local function TooltipHook(self)
    if not AstralKeysSettings.options.showTooltip then return end

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