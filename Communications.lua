local ADDON, e = ...

local find, sub, strformat = string.find, string.sub, string.format
local BNSendGameData, SendAddonMessage, SendChatMessage = BNSendGameData, C_ChatInfo.SendAddonMessage, SendChatMessage

-- Variables for syncing information
-- Will only accept information from other clients with same version settings
local SYNC_VERSION = 'sync5'
e.UPDATE_VERSION = 'updateV8'

local versionList = {}
local highestVersion = 0

local messageStack = {}

local PrintVersion, CheckInstanceType

-- New key announce message
-- TODO: add option to change message to something else
local ANNOUNCE_MESSAGE = 'Astral Keys: New key %s + %d'

-- Interval times for syncing keys between clients
-- Two different time settings for in a raid or otherwise
-- Creates a random variance between +- [.001, .100] to help prevent
-- disconnects from too many addon messages
local SEND_VARIANCE = ((-1)^math.random(1,2)) * math.random(1, 100)/ 10^3 -- random number to space out messages being sent between clients
local SEND_INTERVAL = {}
SEND_INTERVAL[1] = 0.2 + SEND_VARIANCE -- Normal operations
SEND_INTERVAL[2] = 1 + SEND_VARIANCE -- Used when in a raiding environment
SEND_INTERVAL[3] = 2 -- Used for version checks

-- Current setting to be used
-- Changes when player enters a raid instance or not
local SEND_INTERVAL_SETTING = 1 -- What intervel to use for sending key information

AstralComs = CreateFrame('FRAME', 'AstralComs')

function AstralComs:RegisterPrefix(channel, prefix, f)
	local channel = channel or 'GUILD' -- Defaults to guild channel

	if self:IsPrefixRegistered(channel, prefix) then return end -- Did we register something to the same channel with the same name?

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
			objs[id] = nil
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

function AstralComs:OnEvent(event, prefix, msg, channel, sender)
	if not (prefix == 'AstralKeys') then return end

	if event == 'BN_CHAT_MSG_ADDON' then channel = 'BNET' end -- To handle BNET addon messages, they are actually WHISPER but I like to keep them seperate

	local objs = AstralComs.dtbl[channel]
	if not objs then return end

	local arg, content = msg:match("^(%S*)%s*(.-)$")

	for _, obj in pairs(objs) do
		if obj.prefix == arg then
			obj.method(content, sender, msg)
		end
	end
end

local msgs = setmetatable({}, {__mode='k'})

local function newMsg()
	local msg = next(msgs)
	if msg then
		msgs[msg] = nil
		return msg
	end
	return {}
end

local function delMsg(msg)
	msg[1] = nil
	msgs[msg] = true
end


function AstralComs:NewMessage(prefix, text, channel, target)
	local msg = newMsg()

	if channel == 'BNET' then
		msg.method = BNSendGameData
		msg[1] = target
		msg[2] = prefix
		msg[3] = text
	else
		msg.method = SendAddonMessage
		msg[1] = prefix
		msg[2] = text
		msg[3] = channel
		msg[4] = channel == 'WHISPER' and target or ''
	end

	--Let's add it to queue
	self.queue[#self.queue + 1] = msg

	if not self:IsShown() then
		self:Show()
	end
end

function AstralComs:SendMessage()
	local msg = table.remove(self.queue, 1)
	if msg[3] == 'BNET' then
		if select(3, BNGetGameAccountInfo(msg[4])) == 'WoW' and BNConnected() then -- Are they logged into WoW and are we connected to BNET?
			msg.method(unpack(msg, 1, #msg))
		end
	elseif msg[3] == 'WHISPER' then
		if e.IsFriendOnline(msg[4]) then -- Are they still logged into that toon
			msg.method(unpack(msg, 1, #msg))
		end
	else -- Guild/raid message, just send it
		msg.method(unpack(msg, 1, #msg))
		delMsg(msg)
	end
end

function AstralComs:OnUpdate(elapsed)
	self.delay = self.delay + elapsed

	if self.delay < SEND_INTERVAL[SEND_INTERVAL_SETTING] + self.loadDelay then
		return
	end

	self.loadDelay = 0

	if self.versionPrint then
		CheckInstanceType()
		self.versionPrint = false
		PrintVersion()
	end

	self.delay = 0

	if #self.queue < 1 then -- Don't have any messages to send
		self:Hide()
		return
	end

	self:SendMessage()
end

function AstralComs:Init()
	self:RegisterEvent('CHAT_MSG_ADDON')
	self:RegisterEvent('BN_CHAT_MSG_ADDON')

	self:SetScript('OnEvent', self.OnEvent)
	self:SetScript('OnUpdate', self.OnUpdate)

	self.dtbl = {}
	self.queue = {}

	self:Hide()
	self.delay = 0
	self.loadDelay = 0
	self.versionPrint = false
end
AstralComs:Init()

-- IN GUILD.LUA

local function UpdateUnitKey(msg)
	local timeStamp = e.WeekTime() -- part of the week we got this key update, used to determine if a key got de-leveled or not

	local unit, class, dungeonID, keyLevel, weekly, week = strsplit(':', msg)
	
	dungeonID = tonumber(dungeonID)
	keyLevel = tonumber(keyLevel)
	weekly = tonumber(weekly)
	week = tonumber(week)

	local id = e.UnitID(unit) -- Is this unit in the db already?

	if id then -- Yep, just change the values then
		AstralKeys[id][3] = dungeonID
		AstralKeys[id][4] = keyLevel
		AstralKeys[id][5] = weekly
		AstralKeys[id][6] = week
		AstralKeys[id][7] = timeStamp
	else -- Nope, let's add them to the DB and index their position
		AstralKeys[#AstralKeys + 1] = {unit, class, dungeonID, keyLevel, weekly, week, timeStamp}
		e.SetUnitID(unit, #AstralKeys)
	end

	e.UpdateFrames()
	e.AddUnitToTable(unit, class, faction, 'guild', dungeonID, keyLevel, weekly)
	
	-- Update character frames if we received our own key
	if unit == e.Player() then
		e.UpdateCharacterFrames()
	end
end
AstralComs:RegisterPrefix('GUILD', e.UPDATE_VERSION, UpdateUnitKey)

local function SyncReceive(entry, sender)
	if sender == e.Player() then return end
	local unit, class, dungeonID, keyLevel, weekly, week, timeStamp
	if AstralKeyFrame:IsShown() then
		AstralKeyFrame:SetScript('OnUpdate', AstralKeyFrame.OnUpdate)
		AstralKeyFrame.updateDelay = 0
	end

	local _pos = 0
	while find(entry, '_', _pos) do
		
		--unit, class, dungeonID, keyLevel, weekly, week, timeStamp = string.split(':', entry:sub(_pos, entry:find('_', _pos) - 1))

		class, dungeonID, keyLevel, weekly, week, timeStamp = entry:match(':(%a+):(%d+):(%d+):(%d+):(%d+):(%d)', entry:find(':', _pos))
		unit = entry:sub(_pos, entry:find(':', _pos) - 1)
		
		_pos = find(entry, '_', _pos) + 1

		dungeonID = tonumber(dungeonID)
		keyLevel = tonumber(keyLevel)
		weekly = tonumber(weekly)
		week = tonumber(week)
		timeStamp = tonumber(timeStamp)

		if week >= e.Week and e.UnitInGuild(unit) then 

			local id = e.UnitID(unit)
			if id then
				if AstralKeys[id][7] < timeStamp then
					if weekly == 1 then AstralKeys[id][5] = 1 end

					AstralKeys[id][3] = dungeonID
					AstralKeys[id][4] = keyLevel
					AstralKeys[id][6] = week
					AstralKeys[id][7] = timeStamp
				end
			else
				AstralKeys[#AstralKeys + 1] = {unit, class, dungeonID, keyLevel, weekly, week, timeStamp}
				e.SetUnitID(unit, #AstralKeys)
			end
			e.AddUnitToTable(unit, class, faction, 'guild', dungeonID, keyLevel, weekly)
		end
	end
	unit, class, dungeonID, keyLevel, weekly, week, timeStamp = nil, nil, nil, nil, nil, nil, nil
end
AstralComs:RegisterPrefix('GUILD', SYNC_VERSION, SyncReceive)

local function UpdateWeekly(weekly, sender)
	local id = e.UnitID(sender)
	if id then
		AstralKeys[id][5] = tonumber(weekly)
		AstralKeys[id][7] = e.WeekTime()
		e.UpdateFrames()
	end
end
AstralComs:RegisterPrefix('GUILD', 'updateWeekly', UpdateWeekly)

local function PushKeyList(msg, sender)
	if sender == e.Player() then return end

	wipe(messageStack)
	for i = 1, #AstralKeys do
		if e.UnitInGuild(AstralKeys[i][1]) then -- Only send current guild keys, who wants keys from a different guild?
			--messageStack[#messageStack + 1] = strformat('%s_', strformat('%s:%s:%d:%d:%d:%d:%d', AstralKeys[i][1], AstralKeys[i][2], AstralKeys[i][3], AstralKeys[i][4], AstralKeys[i][5], AstralKeys[i][6], AstralKeys[i][7]))
			messageStack[#messageStack + 1] = strformat('%s_', table.concat(AstralKeys[i], ':'))
		end
	end
 
	local msg = ''
	while messageStack[1] do
		msg = strformat('%s%s', msg, messageStack[1])
		if msg:len() < 235 then -- Keep the message length less than 255 or player will disconnect
			table.remove(messageStack, 1)
		else
			AstralComs:NewMessage('AstralKeys', strformat('%s %s', SYNC_VERSION, msg), 'GUILD')
			msg = ''
		end
	end
	if msg ~= '' then
		AstralComs:NewMessage('AstralKeys', strformat('%s %s', SYNC_VERSION, msg), 'GUILD')
	end
end
AstralComs:RegisterPrefix('GUILD', 'request', PushKeyList)

-- END OF GUILD.LUA

local function VersionRequest()
	local version = GetAddOnMetadata('AstralKeys', 'version')
	version = version:gsub('[%a%p]', '')
	SendAddonMessage('AstralKeys', 'versionPush ' .. version .. ':' .. e.PlayerClass(), 'GUILD') -- Bypass the queue, shouldn't cause any issues, very little data is being pushed
end
AstralComs:RegisterPrefix('GUILD', 'versionRequest', VersionRequest)

local function VersionPush(msg, sender)
	local version, class = msg:match('(%d+):(%a+)')
	if tonumber(version) > highestVersion then
		highestVersion = tonumber(version)
	end
	versionList[sender] = {version = version, class = class}
end
AstralComs:RegisterPrefix('GUILD', 'versionPush', VersionPush)

PrintVersion = function()
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

function e.VersionCheck()
	if not IsInGuild() then return end

	highestVersion = 0
	wipe(versionList)
	SendAddonMessage('AstralKeys', 'versionRequest', 'GUILD') -- Bypass the queue, very little data is being pushed, shouldn't cause any issues.
	AstralComs.versionPrint = true
	SEND_INTERVAL_SETTING = 3
	AstralComs.delay = 0
	AstralComs:Show()
end

-- Let's just disable sending information if we are doing a boss fight
-- but keep updating individual keys if we receive them
-- keep the addon channel overhead low
AstralEvents:Register('ENCOUNTER_START', function()
	AstralComs:UnregisterPrefix('GUILD', 'request')
	end, 'encStart')

if not C_ChatInfo then
	AstralEvents:Register('ENCOUNTER_STOP', function()
		AstralComs:RegisterPrefix('GUID', 'request', PushKeyList)
		end, 'encStop')
else
	AstralEvents:Register('ENCOUNTER_END', function()
		AstralComs:RegisterPrefix('GUID', 'request', PushKeyList)
		end, 'encStop')
end


-- Checks to see if we zone into a raid instance,
-- Let's increase the send interval if we are raiding, client sync can wait, dc's can't
CheckInstanceType = function()
	AstralComs.loadDelay = 3
	local inInstance, instanceType = IsInInstance()
	if inInstance and instanceType == 'raid' then
		SEND_INTERVAL_SETTING = 2
	else
		SEND_INTERVAL_SETTING = 1
	end
end
AstralEvents:Register('PLAYER_ENTERING_WORLD', CheckInstanceType, 'entering_world')

function e.AnnounceCharacterKeys(channel)
	for i = 1, #AstralCharacters do
		local id = e.UnitID(strformat('%s-%s', e.CharacterName(i), e.CharacterRealm(i)))

		if id then
			local link = e.CreateKeyLink(e.UnitMapID(id), e.UnitKeyLevel(id))
			if channel == 'PARTY' and not IsInGroup() then return end
			SendChatMessage(strformat('%s %s +%d',e.CharacterName(i), link, e.UnitKeyLevel(id)), channel)
		end
	end
end

function e.AnnounceNewKey(keyLink, level)
	if not IsInGroup() then return end
	if not AstralKeysSettings.options.announceKey then return end
	SendChatMessage(strformat(ANNOUNCE_MESSAGE, keyLink, level), 'PARTY')
end
