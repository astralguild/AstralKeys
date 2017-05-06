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

local d = {}
local updateCounter = 0
local function checkTime()
	updateCounter = updateCounter + 1
	d = date('!*t')
	if updateCounter > 60 then
		updateCounter = 0
		collectgarbage('collect')
	end
	return d
end

e.RegisterEvent('PLAYER_LOGIN', function()
	local d = date('!*t')
	local resetTime = time(d)
	e.SetPlayerName()
	e.SetPlayerClass()
	e.SetPlayerRealm()

	local region = GetCurrentRegion()

	if resetTime > AstralKeysSettings.initTime then
		wipe(AstralCharacters)
		wipe(AstralKeys)
		AstralAffixes = {}
		AstralAffixes[1] = 0
		AstralAffixes[2] = 0
		AstralAffixes[3] = 0
		AstralKeysSettings.initTime = e.DataResetTime()
		e.FindKeyStone(true, false)
	end

	if d.wday == 3 and d.hour < 15 and region ~= 3 then
		local frame = CreateFrame('FRAME')
		frame.d = {}
		frame.firstPass = true
		frame.interval = 0
		frame.resetInterval = 1
		frame.sec = 0
		frame.min = 0
		frame.cTime = 0

		frame:SetScript('OnUpdate', function(self, elapsed)
			self.interval = self.interval + elapsed
			if self.interval > self.resetInterval then
				--self.sec = tonumber(self.d.sec)
				
				--self.min = tonumber(self.d.min)
				--[[if sec > 54 or (sec > 0 and sec < 5) then 
					self.resetInterval = 1
				else
					self.resetInterval = 27
				end
				if self.firstPass then 
					self.resetInterval = 1
				end]]
				self.cTime = time(checkTime())

				if self.cTime > AstralKeysSettings.initTime then
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
				self.interval = 0
			end
			end)
	elseif d.wday == 4 and d.hour < 7 and region == 3 then
		local frame = CreateFrame('FRAME')
		frame.d = {}
		frame.interval = 0
		frame.resetInterval = 1

		frame:SetScript('OnUpdate', function(self, elapsed)
			self.interval = self.interval + elapsed
			if self.interval > self.resetInterval then 
				local sec = tonumber(date('%S'))
				local min = tonumber(date('%M'))
				if sec > 55 or (sec > 0 and sec < 5) then 
					self.resetInterval = 1
				else
					self.resetInterval = 55
				end
				self.d = date('!*t')
				local cTime = time(self.d)

				if cTime > AstralKeysSettings.initTime then
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
				self.interval = 0
			end
			end)

	end

	RegisterAddonMessagePrefix('AstralKeys')
	e.SetPlayerID()

	for i = 1, #AstralKeys do
		e.SetUnitID(AstralKeys[i].name .. '-' ..  AstralKeys[i].realm, i)
	end

	e.RegisterEvent('CURRENCY_DISPLAY_UPDATE', function(...)
	for i = 1, #AstralCharacters do
		if AstralCharacters[i].name == e.PlayerName() then
			AstralCharacters[i].knowledge = e.GetAKBonus(e.ParseAKLevel())
		end
	end
	end)

	C_ChallengeMode.RequestMapInfo()

end)
