local _, L = unpack(select(2, ...))
if GetLocale() ~= 'enUS' then return end

-- Default tab names
L['GUILD'] = 'GUILD'
L['FRIENDS'] = 'FRIENDS'

-- Column Headers
L['LEVEL'] = 'LEVEL'
L['DUNGEON'] = 'DUNGEON'
L['CHARACTER'] = 'CHARACTER'
L['WEEKLY_BEST'] = 'WKLY BEST'

-- Subsection Headers
L['CHARACTERS'] = 'CHARACTERS'
L['AFFIXES'] = 'AFFIXES'

-- Misc
L['CURRENT_KEY'] = 'CURRENT'
L['CHARACTER_DUNGEON_NOT_RAN'] = 'No mythic+ ran'