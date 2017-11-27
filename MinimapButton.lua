local _, e = ...

local addon = LibStub("AceAddon-3.0"):NewAddon("AstralKeys", "AceConsole-3.0")

local astralkeysLDB = LibStub("LibDataBroker-1.1"):NewDataObject("AstralKeys", {
	type = "data source",
	text = "AstralKeys",
	icon = "Interface\\AddOns\\AstralKeys\\Media\\Astral_minimap.tga",
	OnClick = function() e.AstralToggle() end,
})
--local icon = LibStub("LibDBIcon-1.0")

e.icon = LibStub("LibDBIcon-1.0")

function addon:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("AstralMinimap", {
		profile = {
			minimap = {
				hide = not e.ShowMinimapButton(),
			},
		},
	})
	e.icon:Register("AstralKeys", astralkeysLDB, self.db.profile.minimap)
	if e.ShowMinimapButton() then
		e.icon:Show('AstralKeys')
	else
		e.icon:Hide('AstralKeys')
	end
end