local _, e = ...


	-- Reset time 15:00 UTC AMERICAS
	-- 07:00 UTC EU

function e.DataResetTime()
	local serverTime = GetServerTime()
	local d = date('*t', serverTime)
	local secs = 60 - d.sec
	local mins = math.floor(59 - d.min + d.sec/100)
	local hours = math.floor(23 - d.hour + d.min/100)
	local days
	local hourOffset, minOffset = math.modf(difftime(time(), time(date('!*t'))))/3600
	minOffset = minOffset or 0
	if d.wday > 3 then 
		days = math.floor(7 - d.wday + d.hour/100) + 2
	else
		days = math.floor(2 - d.wday + d.hour/100)
	end

	local region = GetCurrentRegion()

	if region == 3 then 
		hourOffset = hourOffset + 7 + 24
	else
		hourOffset = hourOffset + 16
	end

	local time = (((days * 24 + hours + hourOffset) * 60 + mins + minOffset) * 60 + secs) + serverTime

	return time
end

if not AstralKeysSettings then
	AstralKeysSettings = {
		['resetVersion'] = 1143,
		['reset'] = true,
		['initTime'] = e.DataResetTime(),
		['frameOptions'] = {
			['orientation'] = 0,
			['sortMethod'] = 'level',
			['quickOptions'] = {
				['showOffline'] = 0,
				['minKeyLevel'] = 1,
				},
			['viewMode'] = 0,
			},
		['options'] = {
			['announceKey'] = true,
			},
		}
end

local frame = CreateFrame('FRAME')
frame:RegisterEvent('ADDON_LOADED')
frame:SetScript('OnEvent', function(self, event, ...)
	local addon = ...
	if addon == 'AstralKeys' then
		_G['AstralEngine'] = e
		if not AstralKeysSettings['reset'] or not AstralKeysSettings['resetVersion'] or AstralKeysSettings['resetVersion'] ~= 1143 then
			wipe(AstralKeys)
			wipe(AstralCharacters)
			AstralAffixes[1] = 0
			AstralAffixes[2] = 0
			AstralAffixes[3] = 0
			AstralKeysSettings = {
				['resetVersion'] = 1143,
				['reset'] = true,
				['initTime'] = e.DataResetTime(),
				['frameOptions'] = {
					['orientation'] = 0,
					['sortMethod'] = 'level',
					['quickOptions'] = {
						['showOffline'] = 0,
						['minKeyLevel'] = 1,
						},
					['viewMode'] = 0,
					},
				['options'] = {
					['announceKey'] = true,
					},
				}
		end
		end
	end)

function e.GetOrientation()
	return AstralKeysSettings.frameOptions.orientation
end

function e.SetOrientation(int)
	AstralKeysSettings.frameOptions.orientation = int
end

function e.GetSortMethod()
	return AstralKeysSettings.frameOptions.sortMethod
end

function e.SetSortMethod(string)
	AstralKeysSettings.frameOptions.sortMethod = string
end

function e.GetShowOffline()
	return AstralKeysSettings.frameOptions.quickOptions.showOffline
end

function e.SetShowOffline(value)
	AstralKeysSettings.frameOptions.quickOptions.showOffline = value
end

function e.GetMinKeyLevel()
	return AstralKeysSettings.frameOptions.quickOptions.minKeyLevel
end

function e.SetMinKeyLevel(int)
	AstralKeysSettings.frameOptions.quickOptions.minKeyLevel = int
end

function e.GetViewMode()
	return AstralKeysSettings.frameOptions.viewMode
end

function e.SetViewMode(int)
	AstralKeysSettings.frameOptions.viewMode = int
end

function e.ToggleAnnounce()
	AstralKeysSettings.options.announceKey = not AstralKeysSettings.options.announceKey
end

function e.AnnounceKey()
	return AstralKeysSettings.options.announceKey
end