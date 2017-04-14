local _, e = ...

--local version = GetAddonMetaData('AstralKeys', 'version')
--version = version:gsub('%.', '')
local version = 1116
if not AstralKeysSettings then 
	AstralKeysSettings = {
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

local frame = CreateFrame('FRAME')
frame:RegisterEvent('ADDON_LOADED')
frame:SetScript('OnEvent', function(self, event, ...)
	local addon = ...
	if addon == 'AstralKeys' then
		if tonumber(version) >= 1116 and AstralKeysSettings['resetSettings'] then
			AstralKeysSettings = {}
			AstralKeysSettings = {
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