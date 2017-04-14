local _, e = ...

if not AstralKeysSettings then 
	AstralKeysSettings = {
		['frameOptions'] = {
			['orientation'] = 0,
			['sortMethod'] = 'level',
			['quickOptions'] = {
				['showOffline'] = true,
				['minKeyLevel'] = 1,
				},
			['viewMode'] = 0,
			},
		}
end


function e.GetOrientation()
	return AstralKeysSettings.frameOptions.orientation
end

function e.SetOrientation(value)
	AstralKeysSettings.frameOptions.orientation = value
end

function e.GetSortMethod()
	return AstralKeysSettings.frameOptions.sortMethod
end

function e.SetSortMethod(method)
	AstralKeysSettings.frameOptions.sortMethod = method
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

function e.SetMinKeyLevel(value)
	AstralKeysSettings.frameOptions.quickOptions.minKeyLevel = value
end

function e.GetViewMode()
	return AstralKeysSettings.frameOptions.viewMode
end

function e.SetViewMode(value)
	AstralKeysSettings.frameOptions.viewMode = value
end