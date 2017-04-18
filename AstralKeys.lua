local a, e = ...
if not AstralKeys then AstralKeys = {} end
if not AstralCharacters then AstralCharacters = {} end
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
	local secs = d.sec + d.min * 60 + d.hour * 60* 60 + d.wday * 24*60*60
	--print(secs, REGION_RESET, AstralKeysSettings.initTime)
	if secs >= REGION_RESET and AstralKeysSettings.initTime < secs then
		wipe(AstralCharacters)
		wipe(AstralKeys)
		wipe(AstralAffixes)
		AstralKeysSettings.initTime = e.DataInitTime()
	end

	if d.wday == 3 and d.hour < 8 then
		local time = 0
		local frame = CreateFrame('FRAME')
		frame:SetScript('OnUpdate', function(self, elapsed)
			time = 0 + elapsed
			end)
	end

	for i = 1, #AstralKeys do
		e.SetUnitID(AstralKeys[i].name .. AstralKeys[i].realm, i)
	end

	
	C_ChallengeMode.RequestMapInfo()
	e.SetPlayerName()
	e.SetPlayerClass()
	e.SetPlayerID()
	e.SetCharacterID()
	e.SetPlayerRealm()


end)