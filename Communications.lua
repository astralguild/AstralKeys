local ADDON, e = ...

local SYNC_VERSION = 'sync4'
e.UPDATE_VERSION = 'updateV7'

local versionList = {}
local messageStack = {}
local messageQueue = {}
local messageContents = {}
local highestVersion = 0
local find, sub, strformat = string.find, string.sub, string.format
local ANNOUNCE_MESSAGE = 'Astral Keys: New key %s + %d'

AstralComs = CreateFrame('FRAME')
AstralComs:RegisterEvent('CHAT_MSG_ADDON')
AstralComs.dtbl = {}

function AstralComs:RegisterPrefix(channel, prefix, f)
	if not channel then channel = 'GUILD' end
	if self:IsPrefixRegistered(channel, prefix) then return end

	if not self.dtbl[channel] then self.dtbl[channel] = {} end
	
	local obj = {}
	obj.method = f
	obj.prefix = prefix

	table.insert(self.dtbl[channel], obj)
end

function AstralComs:UnregisterPrefix(channel, prefix)
	local objs = self.dtbl[channel]
	if not objs then return end
	for id, obj in pairs(objs) do
		if obj.prefix == prefix then
			table.remove(objs, id)
			--objs[id] = nil
			break
		end
	end
end

function AstralComs:IsPrefixRegistered(channel, prefix)
	local objs = self.dtbl[channel]
	if not objs then return false end
	for _, obj in pairs(objs) do
		if obj.prefix == prefix then
			return true
		end
	end
	return false
end

function AstralComs:OnEvent(event, ...)
	local prefix, msg, channel = ...
	if not (prefix == 'AstralKeys') then return end

	local objs = self.dtbl[channel]
	if not objs then return end

	local arg, content = msg:match("^(%S*)%s*(.-)$")

	for _, obj in pairs(objs) do
		if obj.prefix == arg then
			obj.method(content, ...)
		end
	end
end
AstralComs:SetScript('OnEvent', AstralComs.OnEvent)

function e.AnnounceNewKey(keyLink, level)
	if not IsInGroup() then return end
	if not e.AnnounceKey() then return end
	SendChatMessage(strformat(ANNOUNCE_MESSAGE, keyLink, level), 'PARTY')
end

local function UpdateUnitKey(msg)
	local timeStamp = e.WeekTime()
	local unit = msg:sub(0, msg:find(':') - 1)
	local class, dungeonID, keyLevel, weekly, week = msg:match('(%a+):(%d+):(%d+):(%d+):(%d+)', msg:find(':'))
	
	dungeonID = tonumber(dungeonID)
	keyLevel = tonumber(keyLevel)
	weekly = tonumber(weekly)
	week = tonumber(week)

	local id = e.UnitID(unit)

	if id then
		if weekly == 1 then AstralKeys[id][5] = weekly end

		AstralKeys[id][3] = dungeonID
		AstralKeys[id][4] = keyLevel
		AstralKeys[id][6] = week
		AstralKeys[id][7] = timeStamp
	else
		AstralKeys[#AstralKeys + 1] = {unit, class, dungeonID, keyLevel, weekly, week, timeStamp}
		e.SetUnitID(unit, #AstralKeys)
	end

	e.UpdateFrames()
	
	if unit == strformat('%s-%s', e.PlayerName(), e.PlayerRealm()) then
		e.SetPlayerID()
		e.UpdateCharacterFrames()
	end
end
AstralComs:RegisterPrefix('GUILD', e.UPDATE_VERSION, UpdateUnitKey)

local updateTicker = {}
local function SyncReceive(entry)
	local unit, class, dungeonID, keyLevel, weekly, week, timeStamp
	if updateTicker['_remainingIterations'] and updateTicker['_remainingIterations'] > 0 then updateTicker:Cancel() end
	updateTicker = C_Timer.NewTicker(.75, e.UpdateFrames, 1)

	local _pos = 0
	while find(entry, '_', _pos) do
		
		class, dungeonID, keyLevel, weekly, week, timeStamp = entry:match(':(%a+):(%d+):(%d+):(%d+):(%d+):(%d)', entry:find(':', _pos))
		unit = entry:sub(_pos, entry:find(':', _pos) - 1)
		
		_pos = find(entry, '_', _pos) + 1

		dungeonID = tonumber(dungeonID)
		keyLevel = tonumber(keyLevel)
		weekly = tonumber(weekly)
		week = tonumber(week)
		timeStamp = tonumber(timeStamp)

		if not e.UnitInGuild(unit) then return end

		local id = e.UnitID(unit)

		if id then
			if weekly == 1 then AstralKeys[id][5] = weekly end

			if AstralKeys[id][7] < timeStamp then
				AstralKeys[id][3] = dungeonID
				AstralKeys[id][4] = keyLevel
				AstralKeys[id][6] = week
				AstralKeys[id][7] = timeStamp
			end
		else
			AstralKeys[#AstralKeys + 1] = {unit, class, dungeonID, keyLevel, weekly, week, timeStamp}
			e.SetUnitID(unit, #AstralKeys)
			if unit == strformat('%s-%s', e.PlayerName(), e.PlayerRealm()) then
				e.SetPlayerID()
			end
		end
	end
end
AstralComs:RegisterPrefix('GUILD', SYNC_VERSION, SyncReceive)

local function UpdateWeekly10(...)
	local weekly = ...
	local sender = select(5, ...)

	local id = e.UnitID(sender)
	if id then
		AstralKeys[id][5] = tonumber(weekly)
		e.UpdateFrames()
	end
end
AstralComs:RegisterPrefix('GUILD', 'updateWeekly', UpdateWeekly10)

local ticker = {}
local function PushKeyList(...)
	if ticker['_remainingIterations'] and ticker['_remainingIterations'] > 0 then ticker:Cancel() end
	local sender = select(5, ...)
	if sender == string.format('%s-%s', e.PlayerName(), e.PlayerRealm()) then return end
	wipe(messageStack)
	wipe(messageQueue)
	for i = 1, #AstralKeys do
		if e.UnitInGuild(AstralKeys[i][1]) then
			messageStack[#messageStack + 1] = strformat('%s_', strformat('%s:%s:%d:%d:%d:%d:%d', AstralKeys[i][1], AstralKeys[i][2], AstralKeys[i][3], AstralKeys[i][4], AstralKeys[i][5], AstralKeys[i][6], AstralKeys[i][7]))
		end
	end
 
	-- Keep 10 characters for prefix length, extra incase version goes into double digits
	local index = 1
	messageQueue[index] = ''
	while messageStack[1] do		
		local nextMessage = strformat('%s%s', messageQueue[index], messageStack[1])
		if nextMessage:len() < 245 then
			messageQueue[index] = nextMessage
			table.remove(messageStack, 1)
		else
			index = index + 1
			messageQueue[index] = ''
		end
	end

	local function SendEntries()
		for i = 1, 5 do
			if messageQueue[1] and messageQueue[1] ~= '' then
				SendAddonMessage('AstralKeys', strformat('%s %s', SYNC_VERSION, messageQueue[1]), 'GUILD')
				table.remove(messageQueue, 1)
			else
				break
			end
		end
	end

	local tickerIterations = math.ceil(#messageQueue/5)
	ticker = C_Timer.NewTicker(1, SendEntries, tickerIterations)
end

AstralComs:RegisterPrefix('GUILD', 'request', PushKeyList)

local function VersionRequest()
	local version = GetAddOnMetadata('AstralKeys', 'version')
	version = version:gsub('[%a%p]', '')
	SendAddonMessage('AstralKeys', 'versionPush ' .. version .. ':' .. e.PlayerClass(), 'GUILD')
end
AstralComs:RegisterPrefix('GUILD', 'versionRequest', VersionRequest)

local function VersionPush(msg, ...)
	local sender = select(4, ...)
	local version, class = msg:match('(%d+):(%a+)')
	if tonumber(version) > highestVersion then
		highestVersion = tonumber(version)
	end
	versionList[sender] = {version = version, class = class}
end

local function ResetAK()
	AstralKeysSettings['reset'] = false
	e.WipeUnitList()
	e.WipeFrames()
	e.SetPlayerID()
	e.FindKeyStone(true)
	e.SetCharacterID()
	e.UpdateAffixes()
	C_Timer.After(.75, function()
		e.UpdateCharacterFrames()
		e.UpdateFrames()
	end)
end
AstralComs:RegisterPrefix('GUILD', 'resetAK', ResetAK)
--SendAddonMessage('AstralKeys', 'resetAK', 'GUILD')

function e.AnnounceCharacterKeys(channel)
	for i = 1, #AstralCharacters do
		local id = e.UnitID(strformat('%s-%s', e.CharacterName(i), e.CharacterRealm(i)))

		if id then
			local link, keyLevel = e.CreateKeyLink(id)
			if keyLevel >= e.GetMinKeyLevel() then
				if channel == 'PARTY' and not IsInGroup() then return end
				SendChatMessage(strformat('%s %s +%d',e.CharacterName(i), link, keyLevel), channel)
			end
		end
	end
end

local function PrintVersion()
	local outOfDate = 'Out of date: '
	local upToDate = 'Up to date: '
	local notInstalled = 'Not installed: '

	local i = 1
	for k,v in pairs(versionList) do
		if tonumber(v.version) < highestVersion then
			outOfDate = outOfDate .. WrapTextInColorCode(Ambiguate(k, 'GUILD'), select(4, GetClassColor(v.class))) .. '(' .. v.version .. ') '
		else
			upToDate = upToDate .. WrapTextInColorCode(Ambiguate(k, 'GUILD'), select(4, GetClassColor(v.class))) .. '(' .. v.version .. ') '
		end
	end
	for i = 1, select(2, GetNumGuildMembers()) do
		local unit = GetGuildRosterInfo(i)
		local class = select(11, GetGuildRosterInfo(i))
		if not versionList[unit] then
			notInstalled = notInstalled .. WrapTextInColorCode(Ambiguate(unit, 'GUILD'), select(4, GetClassColor(class))) .. ' '
		end
	end
	ChatFrame1:AddMessage(upToDate)
	ChatFrame1:AddMessage(outOfDate)
	ChatFrame1:AddMessage(notInstalled)
end

local timer
function e.VersionCheck()
	if not IsInGuild() then return end
	if not AstralComs:IsPrefixRegistered('GUILD', 'versionPush') then
		AstralComs:RegisterPrefix('GUILD', 'versionPush', VersionPush)
	end

	highestVersion = 0
	wipe(versionList)
	SendAddonMessage('AstralKeys', 'versionRequest', 'GUILD')
	if timer then timer:Cancel() end
	timer =  C_Timer.NewTicker(3, function() PrintVersion() AstralComs:UnregisterPrefix('GUILD', 'versionPush') end, 1)
end