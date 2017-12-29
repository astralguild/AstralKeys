local _, e = ...

local addon = LibStub("AceAddon-3.0"):NewAddon("AstralKeys", "AceConsole-3.0")

local astralkeysLDB = LibStub("LibDataBroker-1.1"):NewDataObject("AstralKeys", {
	type = "data source",
	text = "AstralKeys",
	icon = "Interface\\AddOns\\AstralKeys\\Media\\Astral_minimap.tga",
	OnClick = function() e.AstralToggle() end,
})

e.icon = LibStub("LibDBIcon-1.0")

function addon:OnInitialize()
	local shown
	if not AstralKeysSettings.options.showMinimapButton then
		shown = true
	else
		shown = AstralKeysSettings.options.showMinimapButton
	end
	self.db = LibStub("AceDB-3.0"):New("AstralMinimap", {
		profile = {
			minimap = {
				hide = not shown,
			},
		},
	})
	e.icon:Register("AstralKeys", astralkeysLDB, self.db.profile.minimap)
	if AstralKeysSettings.options.showMinimapButton then
		e.icon:Show('AstralKeys')
	else
		e.icon:Hide('AstralKeys')
	end
end