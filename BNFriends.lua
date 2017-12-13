local ADDON, e = ...

local SYNC_VERSION = 'sync1'
local UPDATE_VERSION = 'update1'

local strformat, find = string.format, string.find
local tremove = table.remove

local NonBNFriend_List = {}
local BNFriendList = {}

----------------------------------------------------
----------------------------------------------------
-- BNet Friend's list API
-- Collect and store pressence, game pressence IDs

local BNGetFriendInfo = BNGetFriendInfo
local BNGetGameAccountInfo = BNGetGameAccountInfo

-- BNGetNumFOF(BNetID) -- Seems to take first return value from BNGetFriendInfo

local isConnected = BNConnected() -- Determine if connected to BNet, if not disable all comms, check for BN_CONNECTED to re-enable communications, BN_DISCONNECTED disable communications on this event

-- Retrieves Battle.Net BattleTag
-- @param gaID int Game pressence ID
-- @return string BattleTag corresponding to the game pressnce ID ex. Phrike#1141
function e.GetBNTag(gaID)
	if not BNFriendList[gaID] then return nil end
	return BNFriendList[gaID].battleTag
end

-- Retrieves current client stored for said player
-- @param gaID int Game pressence ID
-- @return string Client string for BattleTag or blank for no client, ex. WoW
function e.BNClient(gaID)
	if not BNFriendList[gaID] then return nil end
	return BNFriendList[gaID].client
end

-- Retrieves pressense ID for game pressence ID
-- @param gaID int Game pressence ID
-- @return int Pressence ID
function e.GetBNPresID(gaID)
	if not BNFriendList[gaID] then return nil end
	return BNFriendList[gaID].presID
end

function e.IsFriendUsingAK(gaID)
	if not BNFriendList[gaID] then return false end
	return BNFriendList[gaID].usingAK
end

-- Updates BNFriendList for friend update
-- @paremt index int Friend's list index that was updated
function e.BNFriendUpdate(index)
	if not index then return end -- No tag, event fired from player
	local presID, _, battleTag, _, toonName, gaID, client = BNGetFriendInfo(index) -- Let's get some fresh info, client != 'WoW' when on character list it seems

	if not gaID then return end -- No game pressence ID, can't talk to them then

	if client == 'WoW' and toonName then
		local fullName = toonName .. '-' .. select(4, BNGetGameAccountInfo(gaID))			
		if NonBNFriend_List[fullName] then
			NonBNFriend_List[fullName].isBtag = true
		end
	end

	if not BNFriendList[gaID] then		
		BNFriendList[gaID] = {toonName = toonName, presID = presID, client = client, battleTag = battleTag, usingAK = false}
	else
		BNFriendList[gaID].client = client --Update client, did they log off WoW?
		BNFriendList[gaID].presID = presID or 0 -- If they have a presID force an update, else set to 0. Used for all API needing a pressence ID
		BNFriendList[gaID].battleTag = battleTag -- Might as well keep it up to date
	end	
end
AstralEvents:Register('BN_FRIEND_INFO_CHANGED', e.BNFriendUpdate, 'update_BNFriend')

----------------------------------------------------
----------------------------------------------------
-- Friend Indexing

local FRIEND_LIST = {}

function e.SetFriendID(unit, id)
	FRIEND_LIST[unit] = id
end

function e.FriendID(unit)
	return FRIEND_LIST[unit]
end

function e.WipeFriendList()
	wipe(FRIEND_LIST)
end

function e.FriendUnit(id)
	return AstralFriends[id]
end

function e.FriendRealm(id)
	return AstralFriends[id][1]:sub(AstralFriends[id][1]:find('-') + 1)
end

function e.FriendName(id)
	return AstralFriends[id][1]:sub(1, AstralFriends[id][1]:find('-') - 1)
end

function e.FriendClass(id)
	return AstralFriends[id][3]
end

function e.FriendBattleTag(id)
	return AstralFriends[id][2]
end

function e.FriendMapID(id)
	return AstralFriends[id][4]
end

function e.FriendKeyLevel(id)
	return AstralFriends[id][5]
end

----------------------------------------------------
----------------------------------------------------
---- Non BNet Friend stuff



function e.IsFriendOnline(friend)
	return NonBNFriend_List[friend]
end

local function UpdateNonBNetFriendList()
	wipe(NonBNFriend_List)

	for i = 1, select(2, GetNumFriends()) do -- Only parse over online friends
		local name = strformat('%s-%s', GetFriendInfo(i), e.PlayerRealm())
		NonBNFriend_List[name] = {isBtag = false}
	end
end
AstralEvents:Register('FRIENDLIST_UPDATE', UpdateNonBNetFriendList, 'update_non_bnet_list')

local function RecieveKey(msg, sender)
	local btag
	if type(sender) == 'number' then
		btag = e.GetBNTag(sender)
	end

	local timeStamp = e.WeekTime()
	local unit = msg:sub(0, msg:find(':') - 1)
	local class, dungeonID, keyLevel, _, week = msg:match('(%a+):(%d+):(%d+):(%d+):(%d+)', msg:find(':')) -- Screw getting class from API, just send it, we have the bandwidth.

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
		AstralFriends[#AstralFriends + 1] = {unit, btag, class, dungeonID, keyLevel, week, timeStamp}
		e.SetFriendID(unit, #AstralFriends)
	end

	if e.FrameListShown() == 'friends' then e.UpdateFrames() end
end
AstralComs:RegisterPrefix('BNET', UPDATE_VERSION, RecieveKey)
AstralComs:RegisterPrefix('WHISPER', UPDATE_VERSION, RecieveKey)

local function SyncFriendUpdate(entry, sender)
	local btag
	if type(sender) == 'number' then
		btag = e.GetBNTag(sender)
	end
	--if not btag then return end -- I like checks and balances

	if AstralKeyFrame:IsShown() then
		AstralKeyFrame:SetScript('OnUpdate', AstralKeyFrame.OnUpdate)
		AstralKeyFrame.updateDelay = 0
	end

	local unit, class, dungeonID, keyLevel, week, timeStamp

	local _pos = 0
	while find(entry, '_', _pos) do

		class, dungeonID, keyLevel, week, timeStamp = entry:match(':(%a+):(%d+):(%d+):(%d+):(%d+)', entry:find(':', _pos))
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
				AstralFriends[#AstralFriends + 1] = {unit, btag, class, dungeonID, keyLevel, week, timeStamp}
				e.SetFriendID(unit, #AstralFriends)
			end
		end
	end
	if e.FrameListShown() == 'friends' then e.UpdateFrames() end
end
AstralComs:RegisterPrefix('BNET', SYNC_VERSION, SyncFriendUpdate)
AstralComs:RegisterPrefix('WHISPER', SYNC_VERSION, SyncFriendUpdate)

local messageStack = {}
local messageQueue = {}

local function PushKeysToFriends(target)
	if not AstralKeysSettings.options.friendSync then return end
	wipe(messageStack)
	wipe(messageQueue)

	for i = 1, #AstralCharacters do
		local id = e.UnitID(AstralCharacters[i].unit)
		if id then -- We have a key for this character, let's get the message and queue it up
			local map, level = e.UnitMapID(id), e.UnitKeyLevel(id)
			if level >= e.GetMinFriendSyncLevel() then
				messageStack[#messageStack + 1] = strformat('%s_', strformat('%s:%s:%d:%d:%d:%d', AstralCharacters[i].unit, e.UnitClass(id), map, level, e.Week, AstralKeys[id][7])) -- name-server:class:mapID:keyLevel:week#:weekTime
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
		for gaID, tbl in pairs(BNFriendList) do
			if tbl.client == 'WoW' and tbl.usingAk then -- Only send if they are in WoW
				if type(data) == 'table' then
					for i = 1, #data do
						AstralComs:NewMessage('AstralKeys', strformat('%s %s', SYNC_VERSION, data[i]), 'BNET', gaID)
					end
				else
					AstralComs:NewMessage('AstralKeys', strformat('%s %s', UPDATE_VERSION, data), 'BNET', gaID)
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

	for i = 1, select(2, GetNumFriends()) do -- Only parse over online friends
		local name = strformat('%s-%s', GetFriendInfo(i), e.PlayerRealm())
		NonBNFriend_List[name] = {isBtag = false}
	end

	for i = 1, BNGetNumFriends() do
		local presID, _, battleTag, _, toonName, gaID, client = BNGetFriendInfo(i)
		if gaID then
			BNFriendList[gaID] = {tonnName = toonName, presID = presID, client = client, battleTag = battleTag, usingAK = false}
			if client == 'WoW' then
				local fullName = toonName .. '-' .. select(4, BNGetGameAccountInfo(gaID))			
				if NonBNFriend_List[fullName] then
					NonBNFriend_List[fullName].isBtag = true
				end
			end
		end
	end	

	for gaID, player in pairs(BNFriendList) do
		if player.client == 'WoW' then
			AstralComs:NewMessage('AstralKeys', 'BNet_query ping', 'BNET', gaID)
		end
	end

	for player in pairs(NonBNFriend_List) do
		if not player.isBtag then
			AstralComs:NewMessage('AstralKeys', 'BNet_query ping', 'WHISPER', player)
		end
	end

	AstralEvents:Unregister('FRIENDLIST_UPDATE', 'pingFriends')
end
AstralEvents:Register('FRIENDLIST_UPDATE', PingFriendsForAstralKeys, 'pingFriends')

local function PingResponse(msg, sender)
	if BNFriendList[sender] then
		BNFriendList[sender].usingAK = true
	end

	if NonBNFriend_List[sender] then
		NonBNFriend_List[sender].usingAK = true
	end

	if msg:find('ping') then
		AstralComs:NewMessage('AstralKeys', 'BNet_query response', type(sender) == 'number' and 'BNET' or 'WHISPER', sender) -- Need to double check if we get the gaID or pressenceID from the event
	end
	PushKeysToFriends(sender)
end
AstralComs:RegisterPrefix('WHISPER', 'BNet_query', PingResponse)
AstralComs:RegisterPrefix('BNET', 'BNet_query', PingResponse)