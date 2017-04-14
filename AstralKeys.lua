local a, e = ...
if not AstralKeys then AstralKeys = {} end
if not AstralCharacters then AstralCharacters = {} end

e.version = @file-abbreviated-hash@

function e.CheckForWeeklyClear(a1)
	local affix = tonumber(a1)

	local currentAffix = e.GetAffix(1)
	if tonumber(currentAffix) == 0 then return end

	if currentAffix == affix then return end

	AstralAffixes[1] = 0
	AstralAffixes[2] = 0
	AstralAffixes[3] = 0
	--e.WipeFrames()
end

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

local amount, index

function e.ConvertToSI(quantity)
	amount = quantity
	index = 0

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
	local isOlddata = false
	for i = 1, #AstralCharacters do
		if not AstralCharacters[i].realm then
			isOlddata = true
			break
		end
	end

	--if isOlddata then wipe(AstralCharacters) end

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