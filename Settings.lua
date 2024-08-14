local ADDON_NAME, addon = ...

-- Reset time 15:00 UTC AMERICAS
-- 07:00 UTC EU

function addon.DataResetTime()
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
	AstralKeysSettings = {}
end

function addon:AddDefaultSettings(category, name, data)
	if not category or type(category) ~= 'string' then
		error('AddDefaultSettings(category, name, data) category: string expected, received ' .. type(category))
	end
	if data == nil then
		error('AddDefaultSettings(data, name, data) data expected, received ' .. type(data))
	end

	if not AstralKeysSettings[category] then
		AstralKeysSettings[category] = {}
	end

	if AstralKeysSettings[category][name] == nil then
		AstralKeysSettings[category][name] = data
	else
		if type(data) == 'table' then
			for newKey, newValue in pairs(data) do
				local found = false
				for oldKey in pairs(AstralKeysSettings[category][name]) do
					if oldKey == newKey then
						found = true
						break
					end
				end

				if not found then
					AstralKeysSettings[category][name][newKey] = newValue
				end
			end
		end
	end
end

local function LoadDefaultSettings(addonName)
	if addonName ~= ADDON_NAME then return end
	if not AstralKeysSettings.new_settings_config then
		wipe(AstralKeysSettings)
		AstralKeysSettings.new_settings_config = true
	end

	addon.CLIENT_VERSION = C_AddOns.GetAddOnMetadata('AstralKeys', 'Version')
	addon:SetUIScale()
	_G['AstralEngine'] = addon

	-- General options
	addon:AddDefaultSettings('general', 'init_time', addon.DataResetTime())
	addon:AddDefaultSettings('general', 'show_minimap_button',
	{
		isEnabled = true,
	})
	addon:AddDefaultSettings('general', 'show_tooltip_key', {
		isEnabled = true,
	})
	addon:AddDefaultSettings('general', 'show_tooltip_forces', {
		isEnabled = false,
	})
	addon:AddDefaultSettings('general', 'announce_party', {
		isEnabled = true,
	})
	addon:AddDefaultSettings('general', 'announce_guild', {
		isEnabled = false,
	})
	addon:AddDefaultSettings('general', 'report_on_message',
	{
		['party'] = true,
		['raid'] = false,
		['guild'] = false,
		['no_key'] = false,
		['all_characters'] = false,
	})
	addon:AddDefaultSettings('general', 'expanded_tooltip', {
		isEnabled = true,
	})

	--Frame settings, collapsed, saved sorting, etc
	addon:AddDefaultSettings('frame', 'orientation', 1)
	addon:AddDefaultSettings('frame', 'sorth_method', 'character_name')
	addon:AddDefaultSettings('frame', 'isCollapsed', {
		isEnabled = false,
	})
	addon:AddDefaultSettings('frame', 'current_list', 'GUILD')
	addon:AddDefaultSettings('frame', 'show_offline', {
		isEnabled = true,
	})
	addon:AddDefaultSettings('frame', 'mingle_offline', {
		isEnabled = false,
	})
	addon:AddDefaultSettings('frame', 'rank_filter',
	{
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
	})

	-- Friend syncing options
	addon:AddDefaultSettings('friendOptions', 'friend_sync', {
		isEnabled = true,
	})
	addon:AddDefaultSettings('friendOptions', 'show_other_faction', {
		isEnabled = true,
	})
	AstralEvents:Unregister('ADDON_LOADED', 'LoadDefaultSettings')
end

AstralEvents:Register('ADDON_LOADED', LoadDefaultSettings, 'LoadDefaultSettings')

function addon.FrameListShown()
	return AstralKeysSettings.frame.current_list
end

function addon.SetFrameListShown(listName)
	AstralKeysSettings.frame.current_list = listName
end