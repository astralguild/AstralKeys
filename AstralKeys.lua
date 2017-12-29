local a, e = ...

if not AstralKeys then AstralKeys = {} end
if not AstralCharacters then AstralCharacters = {} end
if not AstralFriends then AstralFriends = {} end

local initializeTime = {} 
initializeTime[1]= 1500390000 -- US Tuesday at reset
initializeTime[2]= 1500447600 -- EU Wednesday at reset

local SI = {}
SI[0] = ''
SI[1] = 'k'
SI[2] = 'M'
SI[3] = 'G'
SI[4] = 'T'
SI[5] = 'P'

local IMP = {}
IMP[0] = ''
IMP[1] = 'k'
IMP[2] = 'M'
IMP[3] = 'B'
IMP[4] = 'T'
IMP[5] = 'Q'

function e.ConvertToSI(quantity)
	local amount = quantity
	local power = 0

	while amount > 1000 do
		power = power + 1
		amount = amount /1000
	end

	if amount < 10 then
		return string.format('%.2f', amount) .. ' ' .. IMP[power]
	else
		return math.floor(amount) .. ' ' .. IMP[power]
	end
end

function e.WeekTime()
	local region = GetCurrentRegion()

	if region ~= 3 then
		return GetServerTime() - initializeTime[1] - 604800 * e.Week
	else
		return GetServerTime() - initializeTime[2] - 604800 * e.Week
	end
end

AstralEvents:Register('PLAYER_LOGIN', function()
	GuildRoster()

	if UnitFactionGroup('player') == 'Alliance' then
		e.FACTION = 0
	else
		e.FACTION = 1
	end
	
	local region = GetCurrentRegion()
	local currentTime = GetServerTime()
	local d = date('*t', currentTime)
	local hourOffset, minOffset = math.modf(difftime(currentTime, time(date('!*t', currentTime))))/3600

	if region ~= 3 then
		e.Week = math.floor((GetServerTime() - initializeTime[1]) / 604800)
	else
		e.Week = math.floor((GetServerTime() - initializeTime[2]) / 604800)
	end

	e.SetPlayerNameRealm()
	e.SetPlayerClass()

	if currentTime > AstralKeysSettings.initTime then
		wipe(AstralCharacters)
		wipe(AstralKeys)
		wipe(AstralFriends)
		--AstralAffixes = {}
		--AstralAffixes[1] = 0
		--AstralAffixes[2] = 0
		--AstralAffixes[3] = 0
		AstralKeysSettings.initTime = e.DataResetTime()
		e.FindKeyStone(true, false)
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

				if time(date('*t', GetServerTime())) > AstralKeysSettings.initTime then
					AstralCharacters = {}
					AstralKeys = {}
					AstralAffixes = {}
					AstralAffixes[1] = 0
					AstralAffixes[2] = 0
					AstralAffixes[3] = 0
					AstralKeysSettings.initTime = e.DataResetTime()
					e.Week = math.floor((GetServerTime() - initializeTime[1]) / 604800)
					e.FindKeyStone(true, false)
					self:SetScript('OnUpdate', nil)
					self = nil
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

				if time(date('*t', GetServerTime())) > AstralKeysSettings.initTime then
					AstralCharacters = {}
					AstralKeys = {}
					wipe(AstralFriends)
					AstralAffixes = {}
					AstralAffixes[1] = 0
					AstralAffixes[2] = 0
					AstralAffixes[3] = 0
					AstralKeysSettings.initTime = e.DataResetTime()
					e.FindKeyStone(true, false)
					e.Week = math.floor((GetServerTime() - initializeTime[2]) / 604800)
					self:SetScript('OnUpdate', nil)
					self = nil
				end
				self.elapsed = 0
			end
			end)
	end

	for i = 1, #AstralKeys do -- index guild units
		e.SetUnitID(AstralKeys[i][1], i)
		e.AddUnitToTable(AstralKeys[i][1], AstralKeys[i][2], nil, 'guild', AstralKeys[i][3], AstralKeys[i][4], AstralKeys[i][5])
	end

	for i = 1, #AstralCharacters do -- index player's characters
		e.SetCharacterID(AstralCharacters[i].unit, i)
	end	

	for i = 1, #AstralFriends do
		e.SetFriendID(AstralFriends[i][1], i)
		e.AddUnitToTable(AstralFriends[i][1], AstralFriends[i][3], AstralFriends[i][8], 'friend',  AstralFriends[i][4], AstralFriends[i][5], nil, AstralFriends[i][2])
	end

	RegisterAddonMessagePrefix('AstralKeys')

	C_ChallengeMode.RequestMapInfo()

end, 'login')
