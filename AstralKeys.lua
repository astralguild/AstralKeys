local _, addon = ...
addon.Week = 0
addon.EXPANSION_LEVEL = 70

if not AstralKeys then AstralKeys = {} end
if not AstralCharacters then AstralCharacters = {} end

local initializeTime = {}
initializeTime[1] = 1500390000 -- US Tuesday at reset
initializeTime[2] = 1500447600 -- EU Wednesday at reset
initializeTime[3] = 1500505200 -- TW Thursday at reset
initializeTime[4] = 0

function addon.WeekTime()
	local region = GetCurrentRegion()

	if region == 3 then  -- EU
		return GetServerTime() - initializeTime[2] - 604800 * addon.Week
	elseif region == 4 then -- TW
		return GetServerTime() - initializeTime[3] - 604800 * addon.Week
	else                 -- default to US
		return GetServerTime() - initializeTime[1] - 604800 * addon.Week
	end
end

function addon.GetWeek()
	local region = GetCurrentRegion()
	if region == 3 then  -- EU
		return math.floor((GetServerTime() - initializeTime[2]) / 604800)
	elseif region == 4 then -- TW
		return math.floor((GetServerTime() - initializeTime[3]) / 604800)
	else                 -- default to US
		return math.floor((GetServerTime() - initializeTime[1]) / 604800)
	end
end

function addon.RefreshData()
	local elapsed = time() - addon.refreshTime

	if addon.refreshTime == 0 or (elapsed >= ASTRAL_KEYS_REFRESH_INTERVAL) then
		addon.WipeCharacterList()
		addon.WipeUnitList()
		addon.WipeFriendList()
		C_MythicPlus.RequestRewards()
		AstralCharacters = {}
		AstralKeys = {}
		AstralKeysSettings.general.init_time = addon.DataResetTime()
		addon.PushKeystone(false)
		addon.UpdateAffixes()
		if IsInGuild() then
			C_GuildInfo.GuildRoster()
		end
		addon.SetPlayerNameRealm()
		addon.SetPlayerClass()
		InitKeystoneData()

		addon.refreshTime = time()
		return true
	end
	return false
end

function addon.handleRegionReset(d, regionInitializeTime)
	-- Create a frame
	local frame = CreateFrame('FRAME')
	frame.elapsed = 0
	frame.first = true
	frame.interval = 60 - d.sec

	-- Set the frame's OnUpdate event handler
	frame:SetScript('OnUpdate', function(self, elapsed)
		self.elapsed = self.elapsed + elapsed
		if self.elapsed > self.interval then
			if self.first then
				self.interval = 60
				self.first = false
			end

			-- Check if the time is after the initialization time
			if time(date('*t', GetServerTime())) > AstralKeysSettings.general.init_time then
				addon.RefreshData()
				addon.Week = math.floor((GetServerTime() - regionInitializeTime) / 604800)
				self:SetScript('OnUpdate', nil)
				self = nil
				return nil
			end
			self.elapsed = 0
		end
	end)
end

AstralEvents:Register('PLAYER_LOGIN', function()
	local major, minor = string.match(C_AddOns.GetAddOnMetadata('AstralKeys', 'version'), '(%d+).(%d+)')

	if tonumber(major) == 3 and tonumber(minor) > 25 and not AstralKeysSettings.wipedOldTables then -- Changed to single table in 3.26
		wipe(AstralKeys)
		AstralFriends = nil
		AstralKeysSettings.wipedOldTables = true
	end

	if IsInGuild() then
		C_GuildInfo.GuildRoster()
	end

	if UnitFactionGroup('player') == 'Alliance' then
		addon.FACTION = 0
	else
		addon.FACTION = 1
	end

	local region = GetCurrentRegion()
	local currentTime = GetServerTime()
	local d = date('*t', currentTime)
	local hourOffset = math.modf(difftime(currentTime, time(date('!*t', currentTime)))) / 3600

	addon.Week = addon.GetWeek()

	addon.SetPlayerNameRealm()
	addon.SetPlayerClass()

	if currentTime > AstralKeysSettings.general.init_time then
		wipe(AstralCharacters)
		wipe(AstralKeys)
		AstralKeysSettings.general.init_time = addon.DataResetTime()
	end


	if d.wday == 4 and d.hour < (7 + hourOffset + (d.isdst and 1 or 0)) and region == 3 then  --  EU Reset
		addon.handleRegionReset(d, initializeTime[2])
	elseif d.wday == 4 and d.hour < (7 + hourOffset + (d.isdst and 1 or 0)) and region == 4 then --  TW Reset
		addon.handleRegionReset(d, initializeTime[3])
		-- Handle non EU nor TW (US and other regions)
	elseif d.wday == 3 and d.hour < (16 + hourOffset + (d.isdst and 1 or 0)) then -- US Reset (default)
		addon.handleRegionReset(d, initializeTime[1])
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
			addon.SetUnitID(AstralKeys[i].unit, i)
			addon.AddUnitToSortTable(AstralKeys[i].unit, AstralKeys[i].btag, AstralKeys[i].class, AstralKeys[i].faction,
				AstralKeys[i].dungeon_id, AstralKeys[i].key_level, AstralKeys[i].weekly_best)
			--e.AddUnitToTable(AstralKeys[i].unit, AstralKeys[i].class, AstralKeys[i].faction, 'GUILD', AstralKeys[i].dungeon_id, AstralKeys[i].key_level, AstralKeys[i].weekly_best)
		end
	end

	for i = 1, #AstralCharacters do -- index player's characters
		if AstralCharacters[i] and AstralCharacters[i].unit then
			addon.SetCharacterID(AstralCharacters[i].unit, i)
		end
	end

	if AstralAffixes.season_start_week == 0 then -- Addon has just initialized for the fisrt time or saved variables have been lost.
		AstralAffixes.season_start_week = addon.Week
	end
	C_MythicPlus.RequestMapInfo()     -- Gets info on affixes and current season...
	C_MythicPlus.RequestCurrentAffixes() -- Who knows what this actually does...
end, 'login')
