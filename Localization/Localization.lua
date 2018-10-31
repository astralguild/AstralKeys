local L = select(2, ...)[2]

local localizations = {}
local locale = GetLocale()
if(locale == 'enGB') then
	locale = 'enUS'
end

setmetatable(L, {
	__call = function(_, newLocale)
		localizations[newLocale] = {}
		return localizations[newLocale]
	end,
	__index = function(_, key)
		local localeTable = localizations[locale]
		return localeTable and localeTable[key] or tostring(key)
	end
})