local ADDON, e = ...

local SYNC_VERSION = 'sync2'
local UPDATE_VERSION = 'update2'

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
	local presID, _, battleTag, _, toonName, gaID, client = BNGetFriendInfo(index) -- Let's get some fresh info, client != 'WoW' when on character list it seems

	if not gaID then return end -- No game pressence ID, can't talk to them then

	local guid = select(20, BNGetGameAccountInfo(gaID))

	if client == 'WoW' and toonName then
		local fullName = toonName .. '-' .. select(4, BNGetGameAccountInfo(gaID))
		if FRIEND_LIST[fullName] then
			FRIEND_LIST[fullName].guid = guid
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

function e.WipeFriendList()
	wipe(FRIEND_LIST)
end

----------------------------------------------------
----------------------------------------------------
---- Non BNet Friend stuff

function e.IsFriendOnline(unit)
	if not FRIEND_LIST[unit] then
		return false
	else
		return FRIEND_LIST[unit].isConnected
	end
end

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
		local presID, _, battleTag, _, toonName, gaID, client = BNGetFriendInfo(i)
		if gaID then
		local guid = select(20, BNGetGameAccountInfo(gaID))
			BNFriendList[battleTag] = {toonName = toonName, client = client, gaID = gaID, usingAK = false}
			if client == 'WoW' then
				local fullName = toonName .. '-' .. select(4, BNGetGameAccountInfo(gaID))	
				if NonBNFriend_List[fullName] then
					NonBNFriend_List[fullName].isBtag = true -- don't need to send people on WoW friend and bnet friend the same data.
				end
				if FRIEND_LIST[fullName] then
					FRIEND_LIST[fullName].isConnected = true
					FRIEND_LIST[fullName].guid = guid
				end
			end
		end
	end
end
AstralEvents:Register('FRIENDLIST_UPDATE', UpdateNonBNetFriendList, 'update_non_bnet_list')

local function RecieveKey(msg, sender)
	if not AstralKeysSettings.options.friendSync then return end
	local btag
	if type(sender) == 'number' then
		btag = select(3, BNGetFriendInfo(sender))
	end

	local timeStamp = e.WeekTime()
	local unit, class, dungeonID, keyLevel, _, week, faction = strsplit(':', msg)

	dungeonID = tonumber(dungeonID)
	keyLevel = tonumber(keyLevel)
	week = tonumber(week)

	local id = e.FriendID(unit)

	if id then
		AstralFriends[id][4] = dungeonID
		AstralFriends[id][5] = keyLevel
		AstralFriends[id][6] = week
		AstralFriends[id][7] = timeStamp
	else
		AstralFriends[#AstralFriends + 1] = {unit, btag, class, dungeonID, keyLevel, week, timeStamp, faction}
		e.SetFriendID(unit, #AstralFriends)
		ShowFriends()
	end

	e.AddUnitToTable(unit, class, faction, 'friend', dungeonID, keyLevel, nil, btag)

	if e.FrameListShown() == 'friends' then 
		e.UpdateFrames()
	end
end
AstralComs:RegisterPrefix('BNET', UPDATE_VERSION, RecieveKey)
AstralComs:RegisterPrefix('WHISPER', UPDATE_VERSION, RecieveKey)

local function SyncFriendUpdate(entry, sender)
	if not AstralKeysSettings.options.friendSync then return end
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

		class, dungeonID, keyLevel, week, timeStamp, faction = entry:match(':(%a+):(%d+):(%d+):(%d+):(%d+):(%d+)', entry:find(':', _pos))
		unit = entry:sub(_pos, entry:find(':', _pos) - 1)

		_pos = find(entry, '_', _pos) + 1

		dungeonID = tonumber(dungeonID)
		keyLevel = tonumber(keyLevel)
		week = tonumber(week)
		timeStamp = tonumber(timeStamp)

		if week >= e.Week then 

			local id = e.FriendID(unit)
			if id then
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
			e.AddUnitToTable(unit, class, faction, 'friend', dungeonID, keyLevel, nil, btag)
		end
	end
	if e.FrameListShown() == 'friends' then 
		e.UpdateFrames() 
	end
end
AstralComs:RegisterPrefix('BNET', SYNC_VERSION, SyncFriendUpdate)
AstralComs:RegisterPrefix('WHISPER', SYNC_VERSION, SyncFriendUpdate)

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
			if level >= minKeyLevel then
				messageStack[#messageStack + 1] = strformat('%s_', strformat('%s:%s:%d:%d:%d:%d:%s', AstralCharacters[i].unit, e.UnitClass(id), map, level, e.Week, AstralKeys[id][7], AstralCharacters[i].faction)) -- name-server:class:mapID:keyLevel:week#:weekTime:faction
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
			if unit.client == 'WoW' and unit.usingAk then -- Only send if they are in WoW
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
		local presID, _, battleTag, _, toonName, gaID, client = BNGetFriendInfo(i)
		if gaID then
		local guid = select(20, BNGetGameAccountInfo(gaID))
			BNFriendList[battleTag] = {toonName = toonName, client = client, gaID = gaID, usingAK = false}
			if client == 'WoW' then
				local fullName = toonName .. '-' .. select(4, BNGetGameAccountInfo(gaID))	
				if NonBNFriend_List[fullName] then
					NonBNFriend_List[fullName].isBtag = true -- don't need to send people on WoW friend and bnet friend the same data.
				end
				if FRIEND_LIST[fullName] then
					FRIEND_LIST[fullName].isConnected = true
					FRIEND_LIST[fullName].guid = guid
				end
			end
		end
	end	

	for _, player in pairs(BNFriendList) do
		if player.client == 'WoW' then
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
		btag = select(3, BNGetFriendInfo(BNGetFriendIndex(bnetID)))
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
	if v == 3 then
		table.sort(A, function(a, b) 
			if AstralKeysSettings.frameOptions.orientation == 0 then
				return e.GetMapName(a[v]) > e.GetMapName(b[v])
			else
				return e.GetMapName(b[v]) > e.GetMapName(a[v])
			end
			end)
	else
		if v == 1 then
			table.sort(A, function(a, b)
				local s = a[7] or '|'
				local t = b[7] or '|'
				if AstralKeysSettings.frameOptions.orientation == 0 then
					return s > t
				else
					return s < t
				end
			end)
		else
			table.sort(A, function(a, b) 
				if AstralKeysSettings.frameOptions.orientation == 0 then
					return b[v] > a[v]
				else
					return b[v] < a[v]
				end
			end)
		end
	end
end

e.AddListSort('friend', FriendSort)