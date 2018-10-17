local _, L = unpack(select(2, ...))

L['enUS'] = {}
L['enGB'] = {}
L['deDE'] = {}
L['esES'] = {}
L['esMX'] = {}
L['frFR'] = {}
L['koKR'] = {}
L['ruRU'] = {}
L['zhCN'] = {}
L['zhTW'] = {}

local locale = GetLocale()
Console:AddLine('locale', locale)

L = L[locale]


function printL()
	tprint(L)
end