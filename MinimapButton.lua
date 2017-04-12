local _, e = ...

local addon = LibStub("AceAddon-3.0"):NewAddon("AstralKeys", "AceConsole-3.0")

local astralkeysLDB = LibStub("LibDataBroker-1.1"):NewDataObject("AstralKeys", {
	type = "data source",
	text = "AstralKeys",
	icon = "Interface\\AddOns\\AstralKeys\\Media\\Astral_minimap.tga",
	OnClick = function() e.AstralToggle() end,
})
local icon = LibStub("LibDBIcon-1.0")

function addon:OnInitialize()
	-- Obviously you'll need a ## SavedVariables: BunniesDB line in your TOC, duh!
	self.db = LibStub("AceDB-3.0"):New("AstralKeysSettings", {
		profile = {
			minimap = {
				hide = false,
			},
		},
	})
	icon:Register("astralkeys", astralkeysLDB, self.db.profile.minimap)
	self:RegisterChatCommand("astralkeys", "CommandTheBunnies")
end

function addon:CommandTheBunnies()
	self.db.profile.minimap.hide = not self.db.profile.minimap.hide
	if self.db.profile.minimap.hide then
		icon:Hide("AstralKeys")
	else
		icon:Show("AstralKeys")
	end
end