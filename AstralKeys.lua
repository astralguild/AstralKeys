local e, L = unpack(select(2, ...))
e.Week = 0
e.EXPANSION_LEVEL = 60

if not AstralKeys then AstralKeys = {} end
if not AstralCharacters then AstralCharacters = {} end

local initializeTime = {} 
initializeTime[1] = 1500390000 -- US Tuesday at reset
initializeTime[2] = 1500447600 -- EU Wednesday at reset
initializeTime[3] = 1500505200 -- CN Thursday at reset
initializeTime[4] = 0

function e.WeekTime()
	local region = GetCurrentRegion()

	if region ~= 3 then
		return GetServerTime() - initializeTime[1] - 604800 * e.Week
	else
		return GetServerTime() - initializeTime[2] - 604800 * e.Week
	end
end

AstralEvents:Register('PLAYER_LOGIN', function()

	local major, minor = string.match(GetAddOnMetadata('AstralKeys', 'version'), '(%d+).(%d+)')

	if tonumber(major) == 3 and tonumber(minor) > 25 and not AstralKeysSettings.wipedOldTables then -- Changed to single table in 3.26
		wipe(AstralKeys)
		AstralFriends = nil
		AstralKeysSettings.wipedOldTables = true
	end

	if IsInGuild() then
		C_GuildInfo.GuildRoster()
	end

	if UnitFactionGroup('player') == 'Alliance' then
		e.FACTION = 0
	else
		e.FACTION = 1
	end
	
	local region = GetCurrentRegion()
	local currentTime = GetServerTime()
	local d = date('*t', currentTime)
	local hourOffset, minOffset = math.modf(difftime(currentTime, time(date('!*t', currentTime))))/3600

	if region ~= 3 then -- Non EU
		e.Week = math.floor((GetServerTime() - initializeTime[1]) / 604800)
	else
		e.Week = math.floor((GetServerTime() - initializeTime[2]) / 604800)
	end

	e.SetPlayerNameRealm()
	e.SetPlayerClass()

	if currentTime > AstralKeysSettings.general.init_time then
		wipe(AstralCharacters)
		wipe(AstralKeys)
		AstralKeysSettings.general.init_time = e.DataResetTime()
	end

	if d.wday == 3 and d.hour < (16 + hourOffset + (d.isdst and 1 or 0)) and region ~= 3 then
		local frame = CreateFrame('FRAME')
		frame.elapsed = 0
		frame.first = true
		frame.interval = 60 - d.sec

		frame:SetScript('OnUpdate', function(self, elapsed)
			self.elapsed = self.elapsed + elapsed
			if self.elapsed > self.interval then
				if self.first then
					self.interval = 60
					self.first = false
				end

				if time(date('*t', GetServerTime())) > AstralKeysSettings.general.init_time then					
					e.WipeCharacterList()
					e.WipeUnitList()
					e.WipeFriendList()
					C_MythicPlus.RequestRewards()
					AstralCharacters = {}
					AstralKeys = {}
					AstralKeysSettings.general.init_time = e.DataResetTime()
					e.Week = math.floor((GetServerTime() - initializeTime[1]) / 604800)
					e.FindKeyStone(true, false)
					e.UpdateAffixes()
					self:SetScript('OnUpdate', nil)
					self = nil
					return nil
				end
				self.elapsed = 0
			end
			end)
	elseif d.wday == 4 and d.hour < (7 + hourOffset + (d.isdst and 1 or 0)) and region == 3 then
		local frame = CreateFrame('FRAME')
		frame.elapsed = 0
		frame.first = true
		frame.interval = 60 - d.sec

		frame:SetScript('OnUpdate', function(self, elapsed)
			self.elapsed = self.elapsed + elapsed
			if self.elapsed > self.interval then
				if self.first then
					self.interval = 60
					self.first = false
				end

				if time(date('*t', GetServerTime())) > AstralKeysSettings.general.init_time then
					e.WipeCharacterList()
					e.WipeUnitList()
					e.WipeFriendList()
					C_MythicPlus.RequestRewards()
					AstralCharacters = {}
					AstralKeys = {}
					AstralKeysSettings.general.init_time = e.DataResetTime()
					e.FindKeyStone(true, false)
					e.Week = math.floor((GetServerTime() - initializeTime[2]) / 604800)
					e.UpdateAffixes()
					self:SetScript('OnUpdate', nil)
					self = nil
					return nil
				end
				self.elapsed = 0
			end
			end)
	end

	-- Check over saved variables, remove any entries that are incorrect
	-- if any of these fields, remove it
	-- unit, class, dungeon_id, key_level, faction
	for i = #AstralKeys, 1, -1 do
		if not (AstralKeys[i].unit and AstralKeys[i].class and AstralKeys[i].dungeon_id and AstralKeys[i].key_level) then -- Missing information from an entry, remove the entry
			table.remove(AstralKeys, i)
		end
	end

	-- Clean up any bad information for personal characters
	for i = #AstralCharacters, 1, -1 do
		if not (AstralCharacters[i].unit) then
			table.remove(AstralCharacters, i)
		end
	end

	for i = 1, #AstralKeys do -- index guild units
		if AstralKeys[i] and AstralKeys[i].unit then
			e.SetUnitID(AstralKeys[i].unit, i)
			e.AddUnitToSortTable(AstralKeys[i].unit, AstralKeys[i].btag, AstralKeys[i].class, AstralKeys[i].faction, AstralKeys[i].dungeon_id, AstralKeys[i].key_level, AstralKeys[i].weekly_best)
			--e.AddUnitToTable(AstralKeys[i].unit, AstralKeys[i].class, AstralKeys[i].faction, 'GUILD', AstralKeys[i].dungeon_id, AstralKeys[i].key_level, AstralKeys[i].weekly_best)
		end
	end

	for i = 1, #AstralCharacters do -- index player's characters
		if AstralCharacters[i] and AstralCharacters[i].unit then
			e.SetCharacterID(AstralCharacters[i].unit, i)
		end
	end	
	
	if AstralAffixes.season_start_week == 0 then -- Addon has just initialized for the fisrt time or saved variables have been lost. 
		AstralAffixes.season_start_week = e.Week
	end
	C_MythicPlus.RequestMapInfo() -- Gets info on affixes and current season...
	C_MythicPlus.RequestCurrentAffixes() -- Who knows what this actually does...

end, 'login')
