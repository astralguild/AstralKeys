local _, e = ...

local BROADCAST = true
local versionList = {}
local highestVersion

local akComms = CreateFrame('FRAME')
akComms:RegisterEvent('CHAT_MSG_ADDON')
RegisterAddonMessagePrefix('AstralKeys')

local function AddonMessage(index)	
	return 'updateV3 ' ..  AstralKeys[index].name .. ":" .. AstralKeys[index].class .. ':' .. AstralKeys[index].realm .. ':' .. AstralKeys[index].map .. ':' .. AstralKeys[index].level .. ':' .. AstralKeys[index].usable .. ':' .. AstralKeys[index].a1 .. ':' .. AstralKeys[index].a2 .. ':' .. AstralKeys[index].a3 .. ':' .. AstralKeys[index].weeklyCache
end

function e.AnnounceNewKey(keyLink, level)
	if not BROADCAST and not IsInGroup() then return end
	SendChatMessage('Astral Keys: New key ' .. keyLink .. ' +' .. level, 'PARTY')
end

akComms:SetScript('OnEvent', function(self, event, ...)
	local prefix, msg, _, sender = ...
	if not (prefix == 'AstralKeys') then return end

	local arg, content = msg:match("^(%S*)%s*(.-)$")

	if arg == 'updateWeekly' then
		local id e.GetUnitID(sender)
		if id then
			AstralKeys[id].weeklyCache = tonumber(content)
		end
	end

	if arg == 'updateV3' then
		local unit, unitClass, unitRealm = content:match('(%a+):(%a+):([%a%s-\']+)')
		local dungeonID, keyLevel, isUsable, affixOne, affixTwo, affixThree, weekly10 = content:match(':(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+)')
		dungeonID = tonumber(dungeonID)
		keyLevel = tonumber(keyLevel)
		isUsable = tonumber(isUsable)
		affixOne = tonumber(affixOne)
		affixTwo = tonumber(affixTwo)
		affixThree = tonumber(affixThree)
		weekly10 = tonumber(weekly10)

		if not e.UnitInGuild(unit) then return end

		if affixOne ~= 0 then
			e.SetAffix(1, affixOne)
		end

		if affixTwo ~= 0 then
			e.SetAffix(2, affixTwo)
		end

		if affixThree ~= 0 then
			e.SetAffix(3, affixThree)
		end

		local id = e.GetUnitID(unit..unitRealm)

		if id then
			if AstralKeys[id].weeklyCache ~= weekly10 then AstralKeys[id].weeklyCache = weekly10 end

			if AstralKeys[id].level < keyLevel or AstralKeys[id].usable ~= isUsable then
				AstralKeys[id].map = dungeonID
				AstralKeys[id].level = keyLevel
				AstralKeys[id].usable = isUsable
				e.UpdateFrames()
			end
		else
			table.insert(AstralKeys, {name = unit, class = unitClass, realm = unitRealm, map = dungeonID, level = keyLevel, usable = isUsable, a1 = affixOne, a2 = affixTwo, a3 = affixThree, weeklyCache = weekly10})
			e.SetUnitID(unit .. unitRealm, #AstralKeys)
			if unit == e.PlayerName() and unitRealm == e.PlayerRealm() then
				e.SetPlayerID()
			end
			e.UpdateFrames()
		end

		if sender == e.PlayerName() and unitRealm == e.PlayerRealm() then
			e.UpdateCharacterFrames()
		end
		
		e.UpdateAffixes()
	end
	if arg == 'request' then
		if sender == e.PlayerName() .. '-' .. e.PlayerRealm() then return end
		for i = 1, #AstralKeys do
			if e.UnitInGuild(AstralKeys[i].name) then
				SendAddonMessage('AstralKeys', AddonMessage(i), 'GUILD')
			end
		end
	end
	if arg =='versionRequest' then
		local version = GetAddOnMetadata('AstralKeys', 'version')
		version = version:gsub('[%a%p]', '')
		SendAddonMessage('AstralKeys', 'versionPush ' .. version .. ':' .. e.PlayerClass(), 'GUILD')
	end
	if arg == 'versionPush' then
		local version, class = content:match('(%d+):(%a+)')
		if tonumber(version) > highestVersion then
			highestVersion = tonumber(content)
		end
		sender = Ambiguate(sender, 'GUILD')
		versionList[sender] = {version = version, class = class}
	end
	--[[
	SendAddonMessage('AstralKeys', 'updateV3 Jpeg:DEMONHUNTER:Turalyon:200:22:1:13:13:10:1', 'GUILD')
	SendAddonMessage('AstralKeys', 'updateV3 Unsu:SHAMAN:Turalyon:227:22:1:13:13:10:1', 'GUILD')
	SendAddonMessage('AstralKeys', 'updateV3 Phrike:MAGE:Turalyon:200:22:1:13:13:10:0', 'GUILD')
	SendAddonMessage('AstralKeys', 'updateV3 Ripmalv:SHAMN:Turalyon:234:22:1:13:13:10:0', 'GUILD')
	]]
	--SendAddonMessage('AstralKeys', 'resetAK', 'GUILD')
	if arg == 'resetAK' then
		AstralKeysSettings['reset'] = false
		e.WipeUnitList()
		AstralKeys = {}
		AstralCharacters = {}
		AstralAffixes[1] = 0
		AstralAffixes[2] = 0
		AstralAffixes[3] = 0
		e.GetBestClear()
		e.SetPlayerID()
		e.FindKeyStone(true)
		C_Timer.After(.75, function()
			e.SetCharacterID()
			e.UpdateCharacterFrames()
			e.UpdateFrames()
		end)
	end
	end)

function e.AnounceCharacterKeys(channel)
	for i = 1, #AstralCharacters do
		local id = e.UnitID(e.CharacterName(i))

		if id then
			local link, keyLevel = e.CreateKeyLink(id)
			if keyLevel >= e.GetMinKeyLevel() then
				if channel == 'PARTY' and not IsInGroup() then return end
				SendChatMessage(e.CharacterName(i) .. ' ' .. link .. ' +' .. keyLevel, channel)
			end
		end
	end
end


local function PrintVersion()
	local s = 'Astral Keys players out of date: '
	highestVersion = 22222
	local i = 1
	for k,v in pairs(versionList) do
		if tonumber(v.version) < highestVersion then
			s = s .. WrapTextInColorCode(k, select(4, GetClassColor(v.class))) .. ' (' .. v.version .. ')'
			if i > 1 then s = s .. ', ' end
			i = i + 1
		end
	end
	ChatFrame1:AddMessage(s)
end

local timer
function e.VersionCheck()
	if not IsInGuild() then return end
	highestVersion = 0
	wipe(versionList)
	SendAddonMessage('AstralKeys', 'versionRequest', 'GUILD')
	if timer then timer:Cancel() end
	timer =  C_Timer.NewTicker(3, PrintVersion, 1)
end
