local ADDON, e = ...

local versionList = {}
local messageStack = {}
local messageQueue = {}
local messageContents = {}
local highestVersion = 0
local find, sub = string.find, string.sub

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
	SendChatMessage('Astral Keys: New key ' .. keyLink .. ' +' .. level, 'PARTY')
end

local function AddonMessage(index)	
	return AstralKeys[index].name .. ":" .. AstralKeys[index].class .. ':' .. AstralKeys[index].realm .. ':' .. AstralKeys[index].map .. ':' .. AstralKeys[index].level .. ':' .. AstralKeys[index].a1 .. ':' .. AstralKeys[index].a2 .. ':' .. AstralKeys[index].a3 .. ':' .. AstralKeys[index].weeklyCache
end

function e.ParseMessage(message)
	local entry = message
	wipe(messageContents)
	local _pos
	while find(entry, ':') do
		_pos = find(entry, ':')
		messageContents[#messageContents + 1] = sub(entry, 1, _pos - 1)
		entry = sub(entry, _pos + 1, entry:len())
	end
	messageContents[#messageContents + 1 ] = entry

	return unpack(messageContents)
end

local function UpdateKeyList(entry, ...)
	local messageReceived = {}
	local unit, unitClass, unitRealm, dungeonID, keyLevel, affixOne, affixTwo, affixThree
	if find(entry, '_') then -- Character to seperate multiple entries
		while find(entry, '_') do
			local _pos = find(entry, '_')
			messageReceived[#messageReceived + 1] = sub(entry, 1, _pos - 1)
			entry = sub(entry, _pos + 1, entry:len())
		end
		for i = 1, #messageReceived do

			unit, unitClass, unitRealm, dungeonID, keyLevel, affixOne, affixTwo, affixThree, weekly10 = e.ParseMessage(messageReceived[i])
			dungeonID = tonumber(dungeonID)
			keyLevel = tonumber(keyLevel)
			affixOne = tonumber(affixOne)
			affixTwo = tonumber(affixTwo)
			affixThree = tonumber(affixThree)
			weekly10 = tonumber(weekly10)

			if not e.UnitInGuild(unit .. '-' .. unitRealm) then return end

			if affixOne ~= 0 then
				e.SetAffix(1, affixOne)
			end

			if affixTwo ~= 0 then
				e.SetAffix(2, affixTwo)
			end

			if affixThree ~= 0 then
				e.SetAffix(3, affixThree)
			end

			local id = e.GetUnitID(unit .. '-' .. unitRealm)

			if id then
				if weekly10 == 1 then AstralKeys[id].weeklyCache = weekly10 end

				if AstralKeys[id].level < keyLevel then
					AstralKeys[id].map = dungeonID
					AstralKeys[id].level = keyLevel
					e.UpdateFrames()
				end
			else
				table.insert(AstralKeys, {name = unit, class = unitClass, realm = unitRealm, map = dungeonID, level = keyLevel, a1 = affixOne, a2 = affixTwo, a3 = affixThree, weeklyCache = weekly10})
				e.SetUnitID(unit .. '-' .. unitRealm, #AstralKeys)
				if unit == e.PlayerName() and unitRealm == e.PlayerRealm() then
					e.SetPlayerID()
				end
				e.UpdateFrames()
			end

			if unit == e.PlayerName() and unitRealm == e.PlayerRealm() then
				e.UpdateCharacterFrames()
			end
		end
	else
		unit, unitClass, unitRealm, dungeonID, keyLevel, affixOne, affixTwo, affixThree, weekly10 = e.ParseMessage(entry)

		dungeonID = tonumber(dungeonID)
		keyLevel = tonumber(keyLevel)
		affixOne = tonumber(affixOne)
		affixTwo = tonumber(affixTwo)
		affixThree = tonumber(affixThree)
		weekly10 = tonumber(weekly10)

		if not e.UnitInGuild(unit .. '-' .. unitRealm) then return end

		if affixOne ~= 0 then
			e.SetAffix(1, affixOne)
		end

		if affixTwo ~= 0 then
			e.SetAffix(2, affixTwo)
		end

		if affixThree ~= 0 then
			e.SetAffix(3, affixThree)
		end

		local id = e.GetUnitID(unit .. '-' .. unitRealm)

		if id then
			if weekly10 == 1 then AstralKeys[id].weeklyCache = weekly10 end

			if AstralKeys[id].level < keyLevel then
				AstralKeys[id].map = dungeonID
				AstralKeys[id].level = keyLevel
				e.UpdateFrames()
			end
		else
			table.insert(AstralKeys, {name = unit, class = unitClass, realm = unitRealm, map = dungeonID, level = keyLevel, a1 = affixOne, a2 = affixTwo, a3 = affixThree, weeklyCache = weekly10})
			e.SetUnitID(unit .. '-' .. unitRealm, #AstralKeys)
			e.UpdateFrames()
			if unit == e.PlayerName() and unitRealm == e.PlayerRealm() then
				e.SetPlayerID()
			end
		end

		if unit == e.PlayerName() and unitRealm == e.PlayerRealm() then
			e.UpdateCharacterFrames()
		end
	end
	e.UpdateAffixes()
end
--AstralComs:RegisterPrefix('GUILD', 'updateV4', UpdateKeyList)

local function UpdateUnitKey(msg)
	Console:AddLine(ADDON, msg)
	local unit, unitClass, unitRealm, dungeonID, keyLevel, affixOne, affixTwo, affixThree, weekly10 = e.ParseMessage(msg)

	dungeonID = tonumber(dungeonID)
	keyLevel = tonumber(keyLevel)
	affixOne = tonumber(affixOne)
	affixTwo = tonumber(affixTwo)
	affixThree = tonumber(affixThree)
	weekly10 = tonumber(weekly10)

	if not e.UnitInGuild(unit .. '-' .. unitRealm) then return end

	if affixOne ~= 0 then
		e.SetAffix(1, affixOne)
	end

	if affixTwo ~= 0 then
		e.SetAffix(2, affixTwo)
	end

	if affixThree ~= 0 then
		e.SetAffix(3, affixThree)
	end

	local id = e.GetUnitID(unit .. '-' .. unitRealm)

	if id then
		if weekly10 == 1 then AstralKeys[id].weeklyCache = weekly10 end

		AstralKeys[id].map = dungeonID
		AstralKeys[id].level = keyLevel
		e.UpdateFrames()
	else
		table.insert(AstralKeys, {name = unit, class = unitClass, realm = unitRealm, map = dungeonID, level = keyLevel, a1 = affixOne, a2 = affixTwo, a3 = affixThree, weeklyCache = weekly10})
		e.SetUnitID(unit .. '-' .. unitRealm, #AstralKeys)
		e.UpdateFrames()
		if unit == e.PlayerName() and unitRealm == e.PlayerRealm() then
			e.SetPlayerID()
		end
	end

	if unit == e.PlayerName() and unitRealm == e.PlayerRealm() then
		e.UpdateCharacterFrames()
	end
end
AstralComs:RegisterPrefix('GUILD', 'updateV5', UpdateUnitKey)

local function SyncReceive(entry)
	local messageReceived = {}
	local unit, unitClass, unitRealm, dungeonID, keyLevel, affixOne, affixTwo, affixThree

	while find(entry, '_') do
			local _pos = find(entry, '_')
			messageReceived[#messageReceived + 1] = sub(entry, 1, _pos - 1)
			entry = sub(entry, _pos + 1, entry:len())
	end

	for i = 1, #messageReceived do

		unit, unitClass, unitRealm, dungeonID, keyLevel, affixOne, affixTwo, affixThree, weekly10 = e.ParseMessage(messageReceived[i])
		dungeonID = tonumber(dungeonID)
		keyLevel = tonumber(keyLevel)
		affixOne = tonumber(affixOne)
		affixTwo = tonumber(affixTwo)
		affixThree = tonumber(affixThree)
		weekly10 = tonumber(weekly10)

		if not e.UnitInGuild(unit .. '-' .. unitRealm) then return end

		if affixOne ~= 0 then
			e.SetAffix(1, affixOne)
		end

		if affixTwo ~= 0 then
			e.SetAffix(2, affixTwo)
		end

		if affixThree ~= 0 then
			e.SetAffix(3, affixThree)
		end

		local id = e.GetUnitID(unit .. '-' .. unitRealm)

		if id then
			if weekly10 == 1 then AstralKeys[id].weeklyCache = weekly10 end

			if AstralKeys[id].level < keyLevel then
				AstralKeys[id].map = dungeonID
				AstralKeys[id].level = keyLevel
				e.UpdateFrames()
			end
		else
			table.insert(AstralKeys, {name = unit, class = unitClass, realm = unitRealm, map = dungeonID, level = keyLevel, a1 = affixOne, a2 = affixTwo, a3 = affixThree, weeklyCache = weekly10})
			e.SetUnitID(unit .. '-' .. unitRealm, #AstralKeys)
			if unit == e.PlayerName() and unitRealm == e.PlayerRealm() then
				e.SetPlayerID()
			end
			e.UpdateFrames()
		end

		if unit == e.PlayerName() and unitRealm == e.PlayerRealm() then
			e.UpdateCharacterFrames()
		end
	end
end
AstralComs:RegisterPrefix('GUILD', 'sync1', SyncReceive)

local function UpdateWeekly10(...)
	local weekly = ...
	local sender = select(5, ...)

	local id = e.GetUnitID(sender)
	if id then
		AstralKeys[id].weeklyCache = tonumber(weekly)
		e.UpdateFrames()
	end
end
AstralComs:RegisterPrefix('GUILD', 'updateWeekly', UpdateWeekly10)

local ticker = {}
local function PushKeyList(...)
	if ticker['_remainingIterations'] and ticker['_remainingIterations'] > 0 then ticker:Cancel() end
	local sender = select(5, ...)
	if sender == e.PlayerName() .. '-' .. e.PlayerRealm() then return end
	wipe(messageStack)
	wipe(messageQueue)
	for i = 1, #AstralKeys do
		if e.UnitInGuild(AstralKeys[i].name .. '-' .. AstralKeys[i].realm) then
			messageStack[#messageStack + 1] = AddonMessage(i) .. '_'
		end
	end

	-- Keep 10 characters for prefix length, extra incase version goes into double digits
	local index = 1
	messageQueue[index] = ''
	while messageStack[1] do		
		local nextMessage = messageQueue[index] .. messageStack[1]
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
				SendAddonMessage('AstralKeys', 'sync1 ' .. messageQueue[1], 'GUILD')
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
	AstralAffixes[1] = 0
	AstralAffixes[2] = 0
	AstralAffixes[3] = 0
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
--[[SendAddonMessage('AstralKeys', 'updateV4 Jpeg:DEMONHUNTER:Turalyon:200:22:1:13:13:10:1', 'GUILD')
]]
function e.AnounceCharacterKeys(channel)
	for i = 1, #AstralCharacters do
		local id = e.GetUnitID(e.CharacterName(i) .. '-' .. e.CharacterRealm(i))

		if id then
			local link, keyLevel = e.CreateKeyLink(id)
			if keyLevel >= e.GetMinKeyLevel() then
				if channel == 'PARTY' and not IsInGroup() then return end
				SendChatMessage(e.CharacterName(i) .. ' ' .. link .. ' +' .. keyLevel, channel)
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