local _, e = ...

local version
version = GetAddOnMetadata('AstralKeys', 'version')
version = version:gsub('[%a%p]', '')

if version == '' then version = 1118 end

function e.DataInitTime()
	local d = date('*t')
	return d.sec + d.min * 60 + d.hour * 60 + d.wday * 24*60*60
end


if not AstralKeysSettings then 
	AstralKeysSettings = {
		['initTime'] = e.DataInitTime(),
		['frameOptions'] = {
			['orientation'] = 0,
			['sortMethod'] = 'level',
			['quickOptions'] = {
				['showOffline'] = 0,
				['minKeyLevel'] = 1,
				},
			['viewMode'] = 0,
			},
		}
end

--[[
local frame = CreateFrame('FRAME')
frame:RegisterEvent('ADDON_LOADED')
frame:SetScript('OnEvent', function(self, event, ...)
	local addon = ...
	if addon == 'AstralKeys' then
		print(GetAddOnMetadata('AstralKeys', 'version'))
		--if tonumber(version) == 1118 then wipe(AstralKeys) end
		if (tonumber(version) >= 1118) and (AstralKeysSettings['resetSettings']) then
			AstralKeysSettings = {}
			AstralKeysSettings = {
			['initTime'] = GetServerTime(),
			['resetSettings'] = false,
			['frameOptions'] = {
				['orientation'] = 0,
				['sortMethod'] = 'level',
				['quickOptions'] = {
					['showOffline'] = 0,
					['minKeyLevel'] = 1,
				},
				['viewMode'] = 0,
				},
			}
		end
	end
	end)
]]

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