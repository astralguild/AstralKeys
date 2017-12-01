local ADDON, e = ...
Console:AddLine(ADDON, 'BN friends loaded')

local BNGetFriendInfo = BNGetFriendInfo
local BNGetGameAccountInfo = BNGetGameAccountInfo

-- /script end  for i =1, select(2, BNGetNumFriends()) do local charName, bnetID = select(5, BNGetFriendInfo(i)) if charName == 'Ripmalv' then BNSendGameData(bnetID, 'akTest', 'Testing') break end end

local FRIEND_LIST = {}
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

local numFriendsOnline = select(2, GetNumFriends()) -- NON BNet friends.

-- Updates BNFriendList for friend update
-- @paremt index int Friend's list index that was updated
function e.BNFriendUpdate(index)
	if not index then return end -- No tag, event fired from player
	local presID, _, battleTag, _, _, gaID, client = BNGetFriendInfo(index) -- Let's get some fresh info, client != 'WoW' when on character list it seems

	if not gaID then return end -- No game pressence ID, can't talk to them then
	if not BNFriendList[gaID] then
		--ADD new? friend to DB
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

local function RecieveKey(msg, ...)
	local sender = select(4, ...)

	local btag = e.GetBNTag(sender)
	if not btag then return end -- How the hell did this happen? Will have to do some testing...

	local timeStamp = e.WeekTime()
	local name, _, realm _, _, faction, _, class= select(2, BNGetGameAccountInfo(sender))
	local unit = format('%s-%s', name, realm)
	local class, dungeonID, keyLevel, week = msg:match('(%a+):(%d+):(%d+):(%d+)') -- Screw getting class from API, just send it, we have the bandwidth.


	dungeonID = tonumber(dungeonID)
	keyLevel = tonumber(keyLevel)
	week = tonumber(week)

	local id = e.UnitID(unit, 'BNET')

	if id and week >= e.Week then
		e.UpdateUnitKey('BNET', btag, id, dungeonID, keyLevel, nil, week, timeStamp)
	else
		--e.AddUnitKey('BNET', unit, class, dungeonID, keyLevel, nil, week, timeStamp, faction)
		--AddUnitKey('BNET', 'Phrike-test', 'mage', 215, 15, nil, 16, 28373, 'Alliance')
	end
	--[[
	if AstralKeys.friends.bnet[btag] then
		UpdateBNFriendKeyInfo(btag, name, realm, mapID, keyLevel) --Update key for battleTag
		AstralKeys.friends.bnet[btag][1] = 'character name'
		AstralKeys.friends.bnet[btag][2] = 'character class'
		AstralKeys.friends.bnet[btag][3] = 'faction 0-1'
		AstralKeys.friends.bnet[btag][4] = 'mapID'
		AstralKeys.friends.bnet[btag][5] = 'keyLevel'
	end
	]]
	-- Code to recieve key informatino here
end

AstralComs:RegisterPrefix('BNET', 'updateKey', RecieveKey)















------------------------------------------------------
------- TESTNG STUFF
------------------------------------------------------


AstralEvents:Register('BN_NEW_PRESENCE', function(index, name) Console:AddLine(ADDON, 'event:: BN_NEW_PRESENCE index:: ' .. index .. ' name:: ' .. name) end, 'new_pres')

AstralEvents:Register('BN_FRIEND_ACCOUNT_ONLINE', function(id) Console:AddLine(ADDON, 'event:: BN_FRIEND_ACCOUNT_ONLINE id::' .. id) end, 'bn_online')

AstralEvents:Register('BN_FRIEND_TOON_ONLINE', function(...) print('toonline::', ...) end, 'toon_online')

AstralEvents:Register('BN_TOON_NAME_UPDATED', function(...) print('BN_TOON_NAME_UPDATED', ...) end, 'toon_update')

-- FIRES ON:: STATUS CHANGES, TEXT UPDATE, CHARACTER LOGIN/LOGOUT, ZONE CHANGES, FIRES A SHIT TON
-- IF FRIEND INFO CHANGED RETURNS INT
-- INT CORREPSONDS TO INDEX OF FRIEND?
--AstralEvents:Register('BN_FRIEND_INFO_CHANGED', function(...) local id = ... or 0 Console:AddLine('AK', 'BN_FRIEND_INFO_CHANGED ' .. id) end, 'info_changed')
