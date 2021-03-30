local e, L = unpack(select(2, ...))

local addon = LibStub("AceAddon-3.0"):NewAddon("AstralKeys", "AceConsole-3.0")

local astralkeysLDB = LibStub("LibDataBroker-1.1"):NewDataObject("AstralKeys", {
	type = "data source",
	text = "AstralKeys",
	icon = "Interface\\AddOns\\AstralKeys\\Media\\Texture\\Logo@2x",
	OnClick = function(self, button)
		local alt_key = IsAltKeyDown()
		local shift_key = IsShiftKeyDown()
		local control_key = IsControlKeyDown()
		if button == 'LeftButton' then
			if shift_key then
				e.AstralKeysVaultToggle()
			else
				e.AstralToggle()
			end
		elseif button == 'RightButton' then
			AstralOptionsFrame:SetShown(not AstralOptionsFrame:IsShown())
		end
	end,
	OnTooltipShow = function(tooltip)
		tooltip:AddLine('AstralKeys')
		tooltip:AddLine(L['AKTT_LCLK'], 0.8, 0.8, 0.8)
		tooltip:AddLine(L['AKTT_SLCLK'], 0.8, 0.8, 0.8)
		tooltip:AddLine(L['AKTT_RCLK'], 0.8, 0.8, 0.8)
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