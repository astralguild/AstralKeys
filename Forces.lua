local _, addon = ...

function addon.DisplayForcesCountInTooltip(tooltip, data)
  if not tooltip or tooltip ~= GameTooltip or not data or not data.guid then return end
  if not addon.inKey then return end
  if not MDT or not AstralKeysSettings.general.show_tooltip_forces.isEnabled then return end

  local npcID = select(6, strsplit("-", data.guid))
  local count, max = MDT:GetEnemyForces(tonumber(npcID))

  if count and max and count ~= 0 and max ~= 0 then
    local percentText = ("%.2f"):format(count / max * 100)
    local countText = ("%d"):format(count)
    local result = "+:count: / :percent:"

    result = gsub(result, ":percent:", percentText .. "%%")
    result = gsub(result, ":count:", countText)
    GameTooltip:AddLine("Count: |cFFFFFFFF" .. result .. "|r")
    GameTooltip:Show()
  end
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, addon.DisplayForcesCountInTooltip)