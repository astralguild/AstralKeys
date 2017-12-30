local _, e = ...
local RESET_VERSION = 21000
-- Reset time 15:00 UTC AMERICAS
-- 07:00 UTC EU

function e.DataResetTime()
	local region = GetCurrentRegion()
	local serverTime = GetServerTime()
	local d = date('*t', serverTime)
	local hourOffset, minOffset = math.modf(difftime(serverTime, time(date('!*t', serverTime))))/3600
	minOffset = minOffset or 0
	local hours
	local days

	if region ~= 3 then -- Not EU
		hours = 15 + (d.isdst and 1 or 0) + hourOffset
		if d.wday > 2 then
			if d.wday == 3 then
				days = (d.hour < hours and 0 or 7)
			else
				days = 10 - d.wday
			end
		else
			days = 3 - d.wday
		end
	else -- EU
		hours = 7 + (d.isdst and 1 or 0) + hourOffset
		if d.wday > 3 then
			if d.wday == 4 then
				days = (d.hour < hours and 0 or 7)				
			else
				days = 11 - d.wday
			end
		else
			days = 4 - d.wday
		end
	end

	local time = (((days * 24 + hours) * 60 + minOffset) * 60) + serverTime - d.hour*3600 - d.min*60 - d.sec

	-- TODO
	-- ADD DST Check for time before returning!!!
	return time
end

if not AstralKeysSettings then
	AstralKeysSettings = {
		['resetVersion'] = RESET_VERSION,
		['initTime'] = e.DataResetTime(),
		['frameOptions'] = {
			['orientation'] = 0,
			['sortMethod'] = 1,
			['viewMode'] = 0,
			['list'] = 'guild',
			},
		['options'] = {
			['announceKey'] = true,
			['showOffline'] = true,
			['whisperClick'] = false,
			['showMiniMapButton'] = true,
			['friendSync'] = true,
			['minFriendSync'] = 2,
			['showOtherFaction'] = false,
			['rankFilters'] = {
				[1] = true,
				[2] = true,
				[3] = true,
				[4] = true,
				[5] = true,
				[6] = true,
				[7] = true,
				[8] = true,
				[9] = true,
				[10] = true,
				},
			},
		}
end

--return AstralKeysSettings.options.friends.GetMinFriendSyncLevel
local frame = CreateFrame('FRAME')
frame:RegisterEvent('ADDON_LOADED')
frame:SetScript('OnEvent', function(self, event, ...)
	local addon = ...
	if addon == 'AstralKeys' then
		_G['AstralEngine'] = e
		if not AstralKeysSettings['resetVersion'] or AstralKeysSettings['resetVersion'] ~= RESET_VERSION then
			wipe(AstralKeys)
			wipe(AstralCharacters)
			wipe(AstralFriends)
			AstralKeysSettings = {
				['resetVersion'] = RESET_VERSION,
				['initTime'] = e.DataResetTime(),
				['frameOptions'] = {
					['orientation'] = 0,
					['sortMethod'] = 1,
					['viewMode'] = 0,
					['list'] = 'guild',
					},
				['options'] = {
					['announceKey'] = true,
					['showOffline'] = true,
					['whisperClick'] = false,
					['showMiniMapButton'] = true,
					['friendSync'] = true,
					['minFriendSync'] = 2,
					['showOtherFaction'] = false,
					['rankFilters'] = {
						[1] = true,
						[2] = true,
						[3] = true,
						[4] = true,
						[5] = true,
						[6] = true,
						[7] = true,
						[8] = true,
						[9] = true,
						[10] = true,
						},
					},
				}
		end
		end
		frame:UnregisterEvent('ADDON_LOADED')
	end)

function e.FrameListShown()
	return AstralKeysSettings.frameOptions.list
end

function e.SetFrameListShown(data)
	AstralKeysSettings.frameOptions.list = data
end