local ADDON, e = ...

local find, sub, strformat = string.find, string.sub, string.format

-- Variables for syncing information
-- Will only accept information from other clients with same version settings
local SYNC_VERSION = 'sync5'
e.UPDATE_VERSION = 'updateV8'

local versionList = {}
local highestVersion = 0

local messageStack = {}

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
end

AstralComs:RegisterPrefix('GUILD', 'request', PushKeyList)