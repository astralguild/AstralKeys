local e, L = unpack(select(2, ...))

local find, sub, strformat = string.find, string.sub, string.format

local GUILD_LIST = {}

-- Puts all guild member's into a table for checking if unit in same guild, stores value as rankIndex for filtering by rank
local function UpdateGuildList()
	wipe(GUILD_LIST)

	for i = 1, GetNumGuildMembers() do
		local name, _, rankIndex, _, _, _, _, _, connected = GetGuildRosterInfo(i)
		local guid = select(17, GetGuildRosterInfo(i))
		if not name then return end
		GUILD_LIST[name] = {rank = rankIndex + 1, isConnected = connected, guid = guid}
	end
	e.UpdateFrames()
end
AstralEvents:Register('GUILD_ROSTER_UPDATE', UpdateGuildList, 'guildUpdate')

-- Checks to see if a unit is in the player's guild
-- @param unit Unit name and server
function e.UnitInGuild(unit)
	return GUILD_LIST[unit] or false
end

function e.GuildMemberOnline(unit)
	if not GUILD_LIST[unit] then return false
	else
		return GUILD_LIST[unit].isConnected
	end
end

function e.GuildMemberRank(unit)
	if not GUILD_LIST[unit] then return false
	else
		return GUILD_LIST[unit].rank
	end
end

function e.GuildMemberGuid(unit)
	if not GUILD_LIST[unit] then return nil
	else
		return GUILD_LIST[unit].guid
	end
end

-- Variables for syncing information
-- Will only accept information from other clients with same version settings
local SYNC_VERSION = 'sync5'
e.UPDATE_VERSION = 'updateV8'

local versionList = {}
local highestVersion = 0

local messageStack = {}

local function UpdateUnitKey(msg)
	local timeStamp = e.WeekTime() -- part of the week we got this key update, used to determine if a key got de-leveled or not

	local unit, class, dungeonID, keyLevel, weekly_best, week = strsplit(':', msg)
	
	dungeonID = tonumber(dungeonID)
	keyLevel = tonumber(keyLevel)
	weekly_best = tonumber(weekly_best)
	week = tonumber(week)

	local id = e.UnitID(unit) -- Is this unit in the db already?

	if id then -- Yep, just change the values then
		AstralKeys[id][3] = dungeonID
		AstralKeys[id][4] = keyLevel
		AstralKeys[id][5] = weekly_best
		AstralKeys[id][6] = week
		AstralKeys[id][7] = timeStamp
	else -- Nope, let's add them to the DB and index their position
		AstralKeys[#AstralKeys + 1] = {unit, class, dungeonID, keyLevel, weekly_best, week, timeStamp}
		e.SetUnitID(unit, #AstralKeys)
	end

	e.UpdateFrames()
	e.AddUnitToTable(unit, class, faction, 'GUILD', dungeonID, keyLevel, weekly_best)
	
	-- Update character frames if we received our own key
	if unit == e.Player() then
		e.UpdateCharacterFrames()
	end
end
AstralComs:RegisterPrefix('GUILD', e.UPDATE_VERSION, UpdateUnitKey)

local function SyncReceive(entry, sender)
	local unit, class, dungeonID, keyLevel, weekly_best, week, timeStamp
	if AstralKeyFrame:IsShown() then
		AstralKeyFrame:SetScript('OnUpdate', AstralKeyFrame.OnUpdate)
		AstralKeyFrame.updateDelay = 0
	end

	local _pos = 0
	while find(entry, '_', _pos) do
		
		--unit, class, dungeonID, keyLevel, weekly_best, week, timeStamp = string.split(':', entry:sub(_pos, entry:find('_', _pos) - 1))

		class, dungeonID, keyLevel, weekly_best, week, timeStamp = entry:match(':(%a+):(%d+):(%d+):(%d+):(%d+):(%d)', entry:find(':', _pos))
		unit = entry:sub(_pos, entry:find(':', _pos) - 1)
		
		_pos = find(entry, '_', _pos) + 1

		dungeonID = tonumber(dungeonID)
		keyLevel = tonumber(keyLevel)
		weekly_best = tonumber(weekly_best)
		week = tonumber(week)
		timeStamp = tonumber(timeStamp)

		if week >= e.Week and e.UnitInGuild(unit) then 

			local id = e.UnitID(unit)
			if id then
				if weekly_best > AstralKeys[id][5] then
					AstralKeys[id][5] = weekly_best
				end
				if AstralKeys[id][7] < timeStamp then
					AstralKeys[id][3] = dungeonID
					AstralKeys[id][4] = keyLevel
					AstralKeys[id][6] = week
					AstralKeys[id][7] = timeStamp
				end
			else
				AstralKeys[#AstralKeys + 1] = {unit, class, dungeonID, keyLevel, weekly_best, week, timeStamp}
				e.SetUnitID(unit, #AstralKeys)
			end
			e.AddUnitToTable(unit, class, faction, 'GUILD', dungeonID, keyLevel, weekly_best)
		end
	end
	unit, class, dungeonID, keyLevel, weekly_best, week, timeStamp = nil, nil, nil, nil, nil, nil, nil
end
AstralComs:RegisterPrefix('GUILD', SYNC_VERSION, SyncReceive)

local function UpdateWeekly(weekly_best, sender)
	local id = e.UnitID(sender)
	if id then
		AstralKeys[id][5] = tonumber(weekly_best)
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


-- Guild sorting/Filtering
local function GuildListSort(A, v)	
	if v == 'dungeon_name' then
		table.sort(A, function(a, b)
			local aOnline = e.GuildMemberOnline(a.character_name) and 1 or 0
			local bOnline = e.GuildMemberOnline(b.character_name) and 1 or 0
			if aOnline == bOnline then
				if AstralKeysSettings.frameOptions.orientation == 0 then
					if e.GetMapName(a.mapID) > e.GetMapName(b.mapID) then
						if bOnline then
							return true
						else
							return false
						end
					elseif e.GetMapName(a.mapID) < e.GetMapName(b.mapID) then
						if aOnline then
							return false
						else
							return true
						end
					else
						return a.character_name < b.character_name
					end
				else
					if e.GetMapName(a.mapID) < e.GetMapName(b.mapID) then
						if aOnline then
							return true
						else
							return false
						end
					elseif e.GetMapName(a.mapID) > e.GetMapName(b.mapID) then
						if bOnline then
							return false
						else
							return true
						end
					else
						return a.character_name < b.character_name
					end
				end
			else
				return aOnline > bOnline
			end
		end)
	else
		table.sort(A, function(a, b)
			local aOnline = e.GuildMemberOnline(a.character_name) and 1 or 0
			local bOnline = e.GuildMemberOnline(b.character_name) and 1 or 0
			if aOnline == bOnline then
				if AstralKeysSettings.frameOptions.orientation == 0 then
					if a[v] > b[v] then
						return true
					elseif a[v] < b[v] then
						return false
					else
						return a.character_name < b.character_name
					end
				else
					if a[v] < b[v] then
						return true
					elseif a[v] > b[v] then
						return false
					else
						return a.character_name < b.character_name
					end
				end
			else
				return aOnline > bOnline
			end
		end)
	end
end
e.AddListSort('GUILD', GuildListSort)

local function GuildListFilter(A)
	if not type(A) == 'table' then return end

	for i = 1, #A.GUILD do
		if e.UnitInGuild(A.GUILD[i].character_name) then
			if AstralKeysSettings.options.showOffline then
				A.GUILD[i].isShown = true
			else
				A.GUILD[i].isShown = e.GuildMemberOnline(A.GUILD[i].character_name)
			end

			A.GUILD[i].isShown = A.GUILD[i].isShown and AstralKeysSettings.options.rankFilters[e.GuildMemberRank(A.GUILD[i].character_name)]

			if A.GUILD[i].isShown then
				A.numShown = A.numShown + 1
			end
		else
			A.GUILD[i].isShown = false
		end
	end
end
e.AddListFilter('GUILD', GuildListFilter)

-- Guild list function for displaying character information
local function GuildUnitFunction(self, unit, unitClass, mapID, keyLevel, weekly_best, faction, btag)
	self.unitID = e.UnitID(unit)
	self.levelString:SetText(keyLevel)
	self.dungeonString:SetText(e.GetMapName(mapID))
	self.nameString:SetText(WrapTextInColorCode(Ambiguate(unit, 'GUILD') , select(4, GetClassColor(unitClass))))
	if weekly_best and weekly_best > 1 then
		local color_code = e.GetDifficultyColour(weekly_best)
		self.bestString:SetText(WrapTextInColorCode(weekly_best, color_code))
	else
		self.bestString:SetText(nil)
	end
	
	if e.GuildMemberOnline(unit) then
		self:SetAlpha(1)
	else
		self:SetAlpha(0.4)
	end
end
e.AddUnitFunction('GUILD', GuildUnitFunction)