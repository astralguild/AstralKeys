local e, L = unpack(select(2, ...))

local RESET_VERSION = 20200
e.CLIENT_VERSION = '2.0'
-- Reset time 15:00 UTC AMERICAS
-- 07:00 UTC EU


local uiScale, mult

function e:SetUIScale()
	local screenHeight = UIParent:GetHeight()
	local scale = string.match( GetCVar( "gxWindowedResolution" ), "%d+x(%d+)" )
	uiScale = UIParent:GetScale()
	mult = 768/scale/uiScale
end

function e:Scale(x)
	return mult * floor(x/mult+.5)
end

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
			['sortMethod'] = 4,
			['viewMode'] = 0,
			['list'] = 'GUILD',
			},
		['options'] = {
			['announceKey'] = true,
			['showOffline'] = true,
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


--return AstralKeysSettings.options.friends.GetMinFriendSyncLevel
local frame = CreateFrame('FRAME')
frame:RegisterEvent('ADDON_LOADED')
frame:SetScript('OnEvent', function(self, event, addon)
	if addon == 'AstralKeys' then
		e:SetUIScale()
		_G['AstralEngine'] = e

		MixInSetting('options', 'showTooltip', true)

		if not AstralKeysSettings['resetVersion'] or AstralKeysSettings['resetVersion'] ~= RESET_VERSION then
			wipe(AstralKeys)
			wipe(AstralCharacters)
			wipe(AstralFriends)
			AstralKeysSettings = {
				['resetVersion'] = RESET_VERSION,
				['initTime'] = e.DataResetTime(),
				['frameOptions'] = {
					['orientation'] = 1,
					['sortMethod'] = 4,
					['viewMode'] = 0,
					['list'] = 'GUILD',
					},
				['options'] = {
					['announceKey'] = true,
					['showOffline'] = true,
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
	return AstralKeysSettings.frameOptions.list
end

function e.SetFrameListShown(data)
	AstralKeysSettings.frameOptions.list = data
end