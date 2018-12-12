local e, L = unpack(select(2, ...))

local RESET_VERSION = 20200
e.CLIENT_VERSION = '3.0'
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
			['orientation'] = 1,
			['sorth_method'] = 'character_name',
			['viewMode'] = 0,
			['list'] = 'GUILD',
			},
		['options'] = {
			['announce_party'] = true,
			['announce_guild'] = false,
			['showOffline'] = true,
			['mingle_offline'] = false,
			['showTooltip'] = true,
			['whisperClick'] = false,
			['showMiniMapButton'] = true,
			['friendSync'] = true,
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

local function MixInSetting(section, name, value)
	if AstralKeysSettings[section][name] == nil then
		AstralKeysSettings[section][name] = value
	end
end

local frame = CreateFrame('FRAME')
frame:RegisterEvent('ADDON_LOADED')
frame:SetScript('OnEvent', function(self, event, addon)
	if addon == 'AstralKeys' then
		e:SetUIScale()
		_G['AstralEngine'] = e

		MixInSetting('options', 'showTooltip', true)
		MixInSetting('frameOptions', 'frame_list', 'GUILD')
		MixInSetting('frameOptions', 'sorth_method', 'character_name')
		MixInSetting('options', 'mingle_offline', false)

		if not AstralKeysSettings['resetVersion'] or AstralKeysSettings['resetVersion'] ~= RESET_VERSION then
			wipe(AstralKeys)
			wipe(AstralCharacters)
			wipe(AstralFriends)
			AstralKeysSettings = {
				['resetVersion'] = RESET_VERSION,
				['initTime'] = e.DataResetTime(),
				['frameOptions'] = {
					['orientation'] = 1,
					['sorth_method'] = 'character_name',
					['viewMode'] = 0,
					['frame_list'] = 'GUILD',
					},
				['options'] = {
					['announce_party'] = true,
					['announce_guild'] = false,
					['showOffline'] = true,
					['mingle_offline'] = false,
					['whisperClick'] = false,
					['showTooltip'] = true,
					['showMiniMapButton'] = true,
					['friendSync'] = true,
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
	return AstralKeysSettings.frameOptions.frame_list
end

function e.SetFrameListShown(data)
	AstralKeysSettings.frameOptions.frame_list = data
end