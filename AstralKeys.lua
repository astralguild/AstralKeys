local a, e = ...
local REGION_RESET_US = 288000
if not AstralKeys then AstralKeys = {} end
if not AstralCharacters then AstralCharacters = {} end

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
	local index = 0

	while amount > 1000 do
		index = index + 1
		amount = amount /1000
	end

	if amount < 10 then
		return string.format('%.2f', amount) .. ' ' .. SI[index]
	else
		return math.floor(amount) .. ' ' .. SI[index]
	end
end

e.RegisterEvent('PLAYER_LOGIN', function()
	local d = date('*t')
	local currentTime = time(d)
	local hourOffset, minOffset = math.modf(difftime(time(), time(date('!*t'))))/3600
	e.SetPlayerName()
	e.SetPlayerClass()
	e.SetPlayerRealm()

	local region = GetCurrentRegion()

	if currentTime > AstralKeysSettings.initTime then
		wipe(AstralCharacters)
		wipe(AstralKeys)
		AstralAffixes = {}
		AstralAffixes[1] = 0
		AstralAffixes[2] = 0
		AstralAffixes[3] = 0
		AstralKeysSettings.initTime = e.DataResetTime()
		e.FindKeyStone(true, false)
	end

	if d.wday == 3 and d.hour < (16 + hourOffset) and region ~= 3 then
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

				if time(date('*t')) > AstralKeysSettings.initTime then
					AstralCharacters = {}
					AstralKeys = {}
					AstralAffixes = {}
					AstralAffixes[1] = 0
					AstralAffixes[2] = 0
					AstralAffixes[3] = 0
					AstralKeysSettings.initTime = e.DataResetTime()
					e.FindKeyStone(true, false)
					self:SetScript('OnUpdate', nil)
					self = nil
				end
				self.elapsed = 0
			end
			end)
	elseif d.wday == 4 and d.hour < (7 + hourOffset) and region == 3 then
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

				if time(date('*t')) > AstralKeysSettings.initTime then
					AstralCharacters = {}
					AstralKeys = {}
					AstralAffixes = {}
					AstralAffixes[1] = 0
					AstralAffixes[2] = 0
					AstralAffixes[3] = 0
					AstralKeysSettings.initTime = e.DataResetTime()
					e.FindKeyStone(true, false)
					self:SetScript('OnUpdate', nil)
					self = nil
				end
				self.elapsed = 0
			end
			end)
	end

	RegisterAddonMessagePrefix('AstralKeys')

	for i = 1, #AstralKeys do
		e.SetUnitID(AstralKeys[i].name .. '-' ..  AstralKeys[i].realm, i)
	end
	e.SetPlayerID()

	e.RegisterEvent('CURRENCY_DISPLAY_UPDATE', function(...)
	for i = 1, #AstralCharacters do
		if AstralCharacters[i].name == e.PlayerName() then
			AstralCharacters[i].knowledge = e.GetAKBonus(e.ParseAKLevel())
		end
	end
	end)

	C_ChallengeMode.RequestMapInfo()

end)
