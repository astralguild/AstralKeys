local ADDON, e = ...
Console:AddLine(ADDON, 'BN friends loaded')

local strformat = string.format
local find = string.find

----------------------------------------------------
----------------------------------------------------
-- BNet Friend's list API
-- Collect and store pressence, game pressence IDs

local BNGetFriendInfo = BNGetFriendInfo
local BNGetGameAccountInfo = BNGetGameAccountInfo

-- /script for i =1, select(2, BNGetNumFriends()) do charName, bnetID = select(5, BNGetFriendInfo(i)) if charName == 'Oonsu' then print(bnetID) BNSendGameData(bnetID, 'akTest', 'Testing') break end end
local BNFriendList = {}

-- BNGetNumFOF(BNetID) -- Seems to take first return value from BNGetFriendInfo

local isConnected = BNConnected() -- Determine if connected to BNet, if not disable all comms, check for BN_CONNECTED to re-enable communications, BN_DISCONNECTED disable communications on this event

for i = 1, BNGetNumFriends() do
	local presID, _, battleTag, _, toonName, gaID, client = BNGetFriendInfo(i)
	if gaID then
		BNFriendList[gaID] = {tonnName = toonName, presID = presID, client = client, battleTag = battleTag}
	end
end

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
	if not BNFriendList[gaID] then return '' end
	return BNFriendList[gaID].client
end

-- Retrieves pressense ID for game pressence ID
-- @param gaID int Game pressence ID
-- @return int Pressence ID
function e.GetBNPresID(gaID)
	if not BNFriendList[gaID] then return nil end
	return BNFriendList[gaID].presID
end

-- Updates BNFriendList for friend update
-- @paremt index int Friend's list index that was updated
function e.BNFriendUpdate(index)
	if not index then return end -- No tag, event fired from player
	local presID, _, battleTag, _, _, gaID, client = BNGetFriendInfo(index) -- Let's get some fresh info, client != 'WoW' when on character list it seems

	if not gaID then return end -- No game pressence ID, can't talk to them then
	if not BNFriendList[gaID] then
		local presID, _, battleTag, _, toonName, gaID, client = BNGetFriendInfo(index)
		if gaID then
			BNFriendList[gaID] = {tonnName = toonName, presID = presID, client = client, battleTag = battleTag}
		end
	else
		-- Store last client, if the client hasn't changed don't send any information
		local lastClient = BNFriendList[gaID].client

		BNFriendList[gaID].client = client --Update client, did they log off WoW?
		BNFriendList[gaID].presID = presID or 0 -- If they have a presID force an update, else set to 0. Used for all API needing a pressence ID
		BNFriendList[gaID].battleTag = battleTag -- Might as well keep it up to date
	end

	if lastClient ~= client and client == 'WoW' then -- They either switched toons or are logging in for the first time.
		-- Going to be dirty, but let's send them the informatino either way. Maybe they disconnected and lost the data?
		--Let's send them our key information!
		--for gaID in pairs(BNFriendList) do SendCharacterKeys(gaID) end
		--4000 bits seem to be safe, let's limit this shit to 1000 to be on the safe side tho
		--Don't know if aother addons are going to be using this shit or not.
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
	return Ambiguate(AstralFriends[id][1])
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

local NonBNFriend_List = {}

function e.IsFriendOnline(friend)
	return NonBNFriend_List[friend]
end

local function UpdateNonBNetFriendList()
	wipe(NonBNFriend_List)

	for i = 1, select(2, GetNumFriends()) do -- Only parse over online friends
		local name = GetFriendInfo(i)
		NonBNFriend_List[name] = true
	end
end
AstralEvents:Register('FRIENDLIST_UPDATE', UpdateNonBNetFriendList, 'update_non_bnet_list')

local function RecieveKey(msg, ...)
	local sender = select(4, ...)

	local btag = e.GetBNTag(sender)
	if not btag then return end -- How the hell did this happen? Will have to do some testing...

	local timeStamp = e.WeekTime()
	local name, _, realm _, _, faction, _, class = select(2, BNGetGameAccountInfo(sender))
	local unit = format('%s-%s', name, realm)
	local class, dungeonID, keyLevel, week = msg:match('(%a+):(%d+):(%d+):(%d+)') -- Screw getting class from API, just send it, we have the bandwidth.


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

	--e.UpdateFrames()
end
AstralComs:RegisterPrefix('BNET', 'updateKey', RecieveKey)

local function SyncFriendUpdate(entry, ...)
	local sender = select(4, ...)

	print(sender)
	print(entry)

	local btag = e.GetBNTag(sender)
	if not btag then return end -- I like checks and balances
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
				if AstralFriends[7] < timeStamp then
					AstralFriends[4] = dungeonID
					AstralFriends[5] = keyLevel
					AstralFriends[6] = week
					AstralFriends[7] = timeStamp
				end
			else
				AstralFriends[#AstralFriends + 1] = {unit, btag, class, dungeonID, keyLevel, week, timeStamp}
				e.SetFriendID(unit, #AstralFriends)
			end
		end
	end
end
AstralComs:RegisterPrefix('BNET', 'sync1', SyncFriendUpdate)

local messageStack = {}
local messageQueue = {}

function PushKeysToFriends()
	local msg = 'sync1 '
	for i = 1, #AstralCharacters do
		local id = e.UnitID(AstralCharacters[i].unit)
		if id then -- We have a key for this character, let's get the message and queue it up
			local map, level = e.GetUnitKeyByID(id)
			if level >= e.GetMinFriendSyncLevel() then
				msg = strformat('%s:%s:%d:%d:%d:%d', e.Unit(id), e.UnitClass(id), map, level, e.Week, AstralKeys[id][7]) -- name-server:class:mapID:keyLevel:week#:weekTime
				msg = strformat('%s_', msg)
				messageStack[#messageStack + 1] = msg
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

	for gaID, tbl in pairs(BNFriendList) do
		if tbl.client == 'WoW' then -- Only send if they are in WoW
			for i = 1, #messageQueue do
			AstralComs:NewMessage('AstralKeys', messageQueue[i], 'BNET', gaID)
			end
		end
	end
end


------------------------------------------------------
------- TESTNG STUFF
------------------------------------------------------


AstralEvents:Register('BN_NEW_PRESENCE', function(index, name) Console:AddLine(ADDON, 'event:: BN_NEW_PRESENCE index:: ' .. index .. ' name:: ' .. name) end, 'new_pres')

AstralEvents:Register('BN_FRIEND_ACCOUNT_ONLINE', function(id, ...) Console:AddLine(ADDON, 'event:: BN_FRIEND_ACCOUNT_ONLINE id::' .. id) end, 'bn_online')

AstralEvents:Register('BN_FRIEND_TOON_ONLINE', function(...) print('toonline::', ...) end, 'toon_online')

AstralEvents:Register('BN_TOON_NAME_UPDATED', function(...) print('BN_TOON_NAME_UPDATED', ...) end, 'toon_update')

-- FIRES ON:: STATUS CHANGES, TEXT UPDATE, CHARACTER LOGIN/LOGOUT, ZONE CHANGES, FIRES A SHIT TON
-- IF FRIEND INFO CHANGED RETURNS INT
-- INT CORREPSONDS TO INDEX OF FRIEND?
--AstralEvents:Register('BN_FRIEND_INFO_CHANGED', function(...) local id = ... or 0 Console:AddLine('AK', 'BN_FRIEND_INFO_CHANGED ' .. id) end, 'info_changed')
