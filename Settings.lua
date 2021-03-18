local ADDON_NAME = ...
local e, L = unpack(select(2, ...))

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
	AstralKeysSettings = {}
end

function e:AddDefaultSettings(category, name, data)
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

local function LoadDefaultSettings(addon)
	if addon ~= ADDON_NAME then return end
	if not AstralKeysSettings.new_settings_config then
		wipe(AstralKeysSettings)
		AstralKeysSettings.new_settings_config = true
	end

	e.CLIENT_VERSION = GetAddOnMetadata('AstralKeys', 'Version')
	e:SetUIScale()
	_G['AstralEngine'] = e

	-- General options
	e:AddDefaultSettings('general', 'init_time', e.DataResetTime())
	e:AddDefaultSettings('general', 'show_minimap_button', 
	{
		isEnabled = true,
	})
	e:AddDefaultSettings('general', 'show_tooltip_key', {
		isEnabled = true,
	})
	e:AddDefaultSettings('general', 'announce_party', {
		isEnabled = true,
	})
	e:AddDefaultSettings('general', 'announce_guild', {
		isEnabled = false,
	})
	e:AddDefaultSettings('general', 'report_on_message', 
	{
		['party'] = true,
		['raid'] = false,
		['guild'] = false,
		['no_key'] = false,
	})
	e:AddDefaultSettings('general', 'expanded_tooltip', {
		isEnabled = true,
	})

	--Frame settings, collapsed, saved sorting, etc
	e:AddDefaultSettings('frame', 'orientation', 1)
	e:AddDefaultSettings('frame', 'sorth_method', 'character_name')
	e:AddDefaultSettings('frame', 'isCollapsed', {
		isEnabled = false,
	})
	e:AddDefaultSettings('frame', 'current_list', 'GUILD')
	e:AddDefaultSettings('frame', 'show_offline', {
		isEnabled = true,
	})
	e:AddDefaultSettings('frame', 'mingle_offline', {
		isEnabled = false,
	})
	e:AddDefaultSettings('frame', 'rank_filter', 
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
	e:AddDefaultSettings('friendOptions', 'friend_sync', {
		isEnabled = true,
	})
	e:AddDefaultSettings('friendOptions', 'show_other_faction', {
		isEnabled = true,
	})
	e:AddDefaultSettings('vault', 'current_list', 'MYTHIC')
	e:AddDefaultSettings('vault', 'only_incomplete', 'false')
	AstralEvents:Unregister('ADDON_LOADED', 'LoadDefaultSettings')
end

AstralEvents:Register('ADDON_LOADED', LoadDefaultSettings, 'LoadDefaultSettings')

function e.FrameListShown()
	return AstralKeysSettings.frame.current_list
end

function e.SetFrameListShown(listName)
	AstralKeysSettings.frame.current_list = listName
end

function e.VaultListShown()
	return AstralKeysSettings.vault.current_list
end

function e.SetVaultListShown(listName)
	AstralKeysSettings.vault.current_list = listName
end