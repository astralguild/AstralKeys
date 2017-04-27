local a, e = ...
local REGION_RESET = 288000

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
	e.SetPlayerName()
	e.SetPlayerClass()
	e.SetPlayerRealm()

	if GetServerTime() > AstralKeysSettings.initTime then
		wipe(AstralCharacters)
		wipe(AstralKeys)
		AstralAffixes = {}
		AstralAffixes[1] = 0
		AstralAffixes[2] = 0
		AstralAffixes[3] = 0
		AstralKeysSettings.initTime = e.DataResetTime()
		e.FindKeyStone(true, false)
	end

	if d.wday == 3 and d.hour < 8 then
		local frame = CreateFrame('FRAME')
		frame.interval = 0
		frame:SetScript('OnUpdate', function(self, elapsed)
			frame.interval = frame.interval + elapsed
			if frame.interval > 30 then
				if GetServerTime() > AstralKeysSettings.initTime then
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
				frame.interval = 0
			end
			end)
	end

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
