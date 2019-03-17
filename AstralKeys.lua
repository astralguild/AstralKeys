local e, L = unpack(select(2, ...))
e.Week = 0

if not AstralKeys then AstralKeys = {} end
if not AstralCharacters then AstralCharacters = {} end
if not AstralFriends then AstralFriends = {} end

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
	if IsInGuild() then
		GuildRoster()
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
		wipe(AstralFriends)
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
					wipe(AstralFriends)
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
					wipe(AstralFriends)
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

	for i = 1, #AstralKeys do -- index guild units
		e.SetUnitID(AstralKeys[i][1], i)
		e.AddUnitToTable(AstralKeys[i][1], AstralKeys[i][2], nil, 'GUILD', AstralKeys[i][3], AstralKeys[i][4], AstralKeys[i][5])
	end

	for i = 1, #AstralCharacters do -- index player's characters
		e.SetCharacterID(AstralCharacters[i].unit, i)
	end	

	for i = 1, #AstralFriends do
		e.SetFriendID(AstralFriends[i][1], i)
		e.AddUnitToTable(AstralFriends[i][1], AstralFriends[i][3], AstralFriends[i][8], 'FRIENDS',  AstralFriends[i][4], AstralFriends[i][5], AstralFriends[i][9], AstralFriends[i][2])
	end

	C_MythicPlus.RequestMapInfo() -- Gets info on affixes and current season...
	C_MythicPlus.RequestCurrentAffixes() -- Who knows what this actually does...

end, 'login')
