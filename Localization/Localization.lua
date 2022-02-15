local _, addon = ...
addon.L = { }

local localizations = addon.L

local locale = GetLocale()
if(locale == 'enGB') then
	locale = 'enUS'
end

setmetatable(addon.L, {
	__call = function(_, newLocale)
		localizations[newLocale] = {}
		return localizations[newLocale]
	end,
	__index = function(_, key)
		local localeTable = localizations[locale]
		return localeTable and localeTable[key] or tostring(key)
	end
})
