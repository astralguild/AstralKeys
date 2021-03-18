local e, L = unpack(select(2, ...))
local strformat = string.format

local COLOUR = {}
COLOUR[1] = 'ffffffff' -- Common
COLOUR[2] = 'ff0070dd' -- Rare
COLOUR[3] = 'ffa335ee' -- Epic
COLOUR[4] = 'ffff8000' -- Legendary
COLOUR[5] = 'ffe6cc80' -- Artifact

function e.UpdateWeeklyCharacter()
    local found = false
    local characterID = e.GetCharacterID(e.Player())
    for i = 1, #AstralCharacters do
        if AstralCharacters[i].unit == e.Player() then
            found = true
            if AstralCharacters[i].vault == nil then
                AstralCharacters[i].vault = {progress={}}
            end
            AstralCharacters[i].vault.progress = C_WeeklyRewards.GetActivities()
            break
        end
    end

    if not found then
        table.insert(AstralCharacters, {unit = e.Player(), class = e.PlayerClass(), weekly_best = 0, faction = e.FACTION, vault={progress={C_WeeklyRewards.GetActivities()}}})
        e.SetCharacterID(e.Player(), #AstralCharacters)
    end
end