local e, L = unpack(select(2, ...))
local strformat = string.format

local COLOUR = {}
COLOUR[1] = 'ffffffff' -- Common
COLOUR[2] = 'ff0070dd' -- Rare
COLOUR[3] = 'ffa335ee' -- Epic
COLOUR[4] = 'ffff8000' -- Legendary
COLOUR[5] = 'ffe6cc80' -- Artifact

function e.UpdateWeeklyCharacter()
    C_MythicPlus.RequestMapInfo()
    local found = false
    local fetchedActivites = C_WeeklyRewards.GetActivities()
    for i = 1, #AstralCharacters do
        if AstralCharacters[i].unit == e.Player() then
            found = true
            if AstralCharacters[i].vault == nil then
                AstralCharacters[i].vault = {progress={}}
            end
            wipe(AstralCharacters[i].vault)
            AstralCharacters[i].vault = {progress={}}
            for j = 1, #fetchedActivites do
                table.insert(AstralCharacters[i].vault.progress,{threshold = fetchedActivites[j].threshold, type = fetchedActivites[j].type, index = fetchedActivites[j].index, progress = fetchedActivites[j].progress, level = fetchedActivites[j].level, rewards = fetchedActivites[j].rewards, id = fetchedActivites[j].id, itemLevel = 0})
            end
        end
    end

    if not found then
        table.insert(AstralCharacters, {unit = e.Player(), class = e.PlayerClass(), weekly_best = 0, faction = e.FACTION, vault={progress={}}})
        e.SetCharacterID(e.Player(), #AstralCharacters)
        local characterID = e.GetCharacterID(e.Player())
        for i = 1, #fetchedActivites do
            table.insert(AstralCharacters[characterID].vault.progress,{threshold = fetchedActivites[i].threshold, type = fetchedActivites[i].type, index = fetchedActivites[i].index, progress = fetchedActivites[i].progress, level = fetchedActivites[i].level, rewards = fetchedActivites[i].rewards, id = fetchedActivites[i].id, itemLevel = 0})
        end
    end
end

-- Retrieves Great Vault progress for character
-- @param id int ID for the character
-- @return table Progress by id per tier
function e.GetWeeklyProgress(id)
    if AstralCharacters[id] and AstralCharacters[id].vault then
        if AstralCharacters[id] and AstralCharacters[id].vault.progress then
            return AstralCharacters[id].vault.progress
        else
            return nil
        end
    else
        return nil
    end
end

-- Sets actual item level for each type and tier
-- @param charid int ID for the character
-- @param progressid int ID for the progress table
-- @param itemLVL int itemLVL
function e.SetWeeklyItemLevel(charid, progressid, itemLVL)
    if AstralCharacters[charid] and AstralCharacters[charid].vault.progress then
        if AstralCharacters[charid].vault.progress[progressid] then
            AstralCharacters[charid].vault.progress[progressid].itemLevel = itemLVL
            print("Wrote item level",itemLVL,"to CharID",charid,"and progressid",progressid)
        end
    end
end

function e.WipeWeeklyCharacter()
    for i = 1, #AstralCharacters do
        wipe(AstralCharacters[i].vault)
    end
end