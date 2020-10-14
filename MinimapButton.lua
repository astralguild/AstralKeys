local e, L = unpack(select(2, ...))

local addon = LibStub("AceAddon-3.0"):NewAddon("AstralKeys", "AceConsole-3.0")

local astralkeysLDB = LibStub("LibDataBroker-1.1"):NewDataObject("AstralKeys", {
	type = "data source",
	text = "AstralKeys",
	icon = "Interface\\AddOns\\AstralKeys\\Media\\Texture\\Logo@2x",
	OnClick = function(self, button)
		if button == 'LeftButton' then 
			e.AstralToggle()
		elseif button == 'RightButton' then
			AstralOptionsFrame:SetShown( not AstralOptionsFrame:IsShown())
		end  
	end,
	OnTooltipShow = function(tooltip)
		tooltip:AddLine("Astral Keys")
		tooltip:AddLine('Left click to toggle main window')
		tooltip:AddLine('Right Click to toggle options')
	end,
})

e.icon = LibStub("LibDBIcon-1.0")

function addon:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("AstralMinimap", {
		profile = {
			minimap = {
				hide = not AstralKeysSettings.general.show_minimap_button.isEnabled,
			},
		},
	})
	e.icon:Register("AstralKeys", astralkeysLDB, self.db.profile.minimap)
end