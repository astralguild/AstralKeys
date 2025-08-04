local _, addon = ...
local L = addon.L

LibStub("AceAddon-3.0"):NewAddon(addon, "AstralKeys", "AceConsole-3.0")

local astralkeysLDB = LibStub("LibDataBroker-1.1"):NewDataObject("AstralKeys", {
	type = "data source",
	text = "AstralKeys",
	icon = "Interface\\AddOns\\AstralKeys\\Media\\Texture\\Logo@2x",
	OnClick = function(_, button)
		if button == 'LeftButton' then 
			addon.AstralToggle()
		elseif button == 'RightButton' then
			AstralOptionsFrame:SetShown( not AstralOptionsFrame:IsShown())
		end  
	end,
	OnTooltipShow = function(tooltip)
		tooltip:AddLine("Astral Keys")
		tooltip:AddLine(L['Left click to toggle main window'])
		tooltip:AddLine(L['Right Click to toggle options'])
	end,
})

addon.icon = LibStub("LibDBIcon-1.0")

function addon:OnInitialize()
	local hideMinimap = false

	if AstralKeysSettings.general then
		hideMinimap = not AstralKeysSettings.general.show_minimap_button.isEnabled
	end

	self.db = LibStub("AceDB-3.0"):New("AstralMinimap", {
		profile = {
			minimap = {
				hide = hideMinimap,
			},
		},
	})
	addon.icon:Register("AstralKeys", astralkeysLDB, self.db.profile.minimap)

	addon.Debug = false
end
