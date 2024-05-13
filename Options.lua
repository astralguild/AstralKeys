local _, addon = ...
L = addon.L

local AstralOptionsFrame = CreateFrame('FRAME', 'AstralOptionsFrame', UIParent)
AstralOptionsFrame:SetFrameStrata('DIALOG')
AstralOptionsFrame:SetFrameLevel(5)
AstralOptionsFrame:SetHeight(455)
AstralOptionsFrame:SetWidth(650)
AstralOptionsFrame:SetPoint('CENTER', UIParent, 'CENTER')
AstralOptionsFrame:SetMovable(true)
AstralOptionsFrame:EnableMouse(true)
AstralOptionsFrame:RegisterForDrag('LeftButton')
AstralOptionsFrame:EnableKeyboard(true)
AstralOptionsFrame:SetPropagateKeyboardInput(true)
AstralOptionsFrame:SetClampedToScreen(true)
AstralOptionsFrame.background = AstralOptionsFrame:CreateTexture(nil, 'BACKGROUND')
AstralOptionsFrame.background:SetAllPoints(AstralOptionsFrame)
AstralOptionsFrame.background:SetColorTexture(0, 0, 0, 0.8)
AstralOptionsFrame:Hide()

local menuBar = CreateFrame('FRAME', '$parentMenuBar', AstralOptionsFrame)
menuBar:SetWidth(50)
menuBar:SetHeight(455)
menuBar:SetPoint('TOPLEFT', AstralOptionsFrame, 'TOPLEFT')
menuBar.texture = menuBar:CreateTexture(nil, 'BACKGROUND')
menuBar.texture:SetAllPoints(menuBar)
menuBar.texture:SetColorTexture(33/255, 33/255, 33/255, 0.8)

AstralOptionsFrame:SetScript('OnDragStart', function(self)
	self:StartMoving()
	end)

AstralOptionsFrame:SetScript('OnDragStop', function(self)
	self:StopMovingOrSizing()
	end)

local logo_Key = menuBar:CreateTexture(nil, 'ARTWORK')
logo_Key:SetSize(32, 32)
logo_Key:SetTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\key-white@2x')
logo_Key:SetVertexColor(0.8, 0.8, 0.8, 0.8)
logo_Key:SetPoint('TOPLEFT', menuBar, 'TOPLEFT', 10, -10)

local divider = menuBar:CreateTexture(nil, 'ARTWORK')
divider:SetSize(20, 1)
divider:SetColorTexture(.6, .6, .6, .8)
divider:SetPoint('TOP', logo_Key, 'BOTTOM', 0, -20)

local logo_Astral = menuBar:CreateTexture(nil, 'ARTWORK')
logo_Astral:SetAlpha(0.8)
logo_Astral:SetSize(32, 32)
logo_Astral:SetTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\Logo@2x')
logo_Astral:SetPoint('BOTTOMLEFT', menuBar, 'BOTTOMLEFT', 10, 10)

local closeButton = CreateFrame('BUTTON', '$parentCloseButton', AstralOptionsFrame)
closeButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\baseline-close-24px@2x.tga')
closeButton:SetSize(12, 12)
closeButton:GetNormalTexture():SetVertexColor(.8, .8, .8, 0.8)
closeButton:SetScript('OnClick', function()
	AstralOptionsFrame:Hide()
end)
closeButton:SetPoint('TOPRIGHT', AstralOptionsFrame, 'TOPRIGHT', -14, -14)
closeButton:SetScript('OnEnter', function(self)
	self:GetNormalTexture():SetVertexColor(126/255, 126/255, 126/255, 0.8)
end)
closeButton:SetScript('OnLeave', function(self)
	self:GetNormalTexture():SetVertexColor(0.8, 0.8, 0.8, 0.8)
end)

-- Content frame to anchor all option panels
-- 
local contentFrame = CreateFrame('FRAME', 'AstralFrame_OptionContent', AstralOptionsFrame)
contentFrame:SetPoint('TOPLEFT', menuBar, 'TOPRIGHT', 15, -15)
contentFrame:SetSize(550, 360)

local generalHeader = contentFrame:CreateFontString(nil, 'OVERLAY', 'InterUIBold_Normal')
generalHeader:SetText(L['GENERAL OPTIONS'])
generalHeader:SetPoint('TOPLEFT', contentFrame, 'TOPLEFT')

local showOffLine = addon.CreateCheckBox(contentFrame, L['Show offline players'])
showOffLine:SetPoint('TOPLEFT', generalHeader, 'BOTTOMLEFT', 10, -10)
showOffLine:SetScript('OnClick', function(self)
	AstralKeysSettings.frame.show_offline.isEnabled = self:GetChecked()
	addon.UpdateFrames()
	HybridScrollFrame_SetOffset(AstralKeyFrameListContainer, 0)
	end)

local showMinimap = addon.CreateCheckBox(contentFrame, L['Show Minimap button'])
showMinimap:SetPoint('LEFT', showOffLine, 'RIGHT', 10, 0)
showMinimap:SetScript('OnClick', function(self)
	AstralKeysSettings.general.show_minimap_button.isEnabled = self:GetChecked()
	if AstralKeysSettings.general.show_minimap_button.isEnabled then
		addon.icon:Show('AstralKeys')
	else
		addon.icon:Hide('AstralKeys')
	end
	if IsAddOnLoaded('ElvUI_Enhanced') then -- Update the layout for the minimap buttons
		ElvUI[1]:GetModule('MinimapButtons'):UpdateLayout()
	end
	end)

local showTooltip = addon.CreateCheckBox(contentFrame, L['Show current key in tooltip'])
showTooltip:SetPoint('TOPLEFT', showOffLine, 'BOTTOMLEFT', 0, -5)
showTooltip:SetScript('OnClick', function(self)
	AstralKeysSettings.general.show_tooltip_key.isEnabled = self:GetChecked()
	end)

local mingleOffline = addon.CreateCheckBox(contentFrame, L['Display offline below online'])
mingleOffline:SetPoint('LEFT', showTooltip, 'RIGHT', 10, 0)
mingleOffline:SetScript('OnClick', function()
	AstralKeysSettings.frame.mingle_offline.isEnabled = not AstralKeysSettings.frame.mingle_offline.isEnabled
	addon.UpdateFrames()
	end)

local announceParty = addon.CreateCheckBox(contentFrame, L['Announce new keys to party'])
announceParty:SetPoint('TOPLEFT', showTooltip, 'BOTTOMLEFT', 0, -5)
announceParty:SetScript('OnClick', function()
	AstralKeysSettings.general.announce_party.isEnabled = not AstralKeysSettings.general.announce_party.isEnabled
	end)

local announceGuild = addon.CreateCheckBox(contentFrame, L['Announce new keys to guild'])
announceGuild:SetPoint('LEFT', announceParty, 'RIGHT', 10, 0)
announceGuild:SetScript('OnClick', function()
	AstralKeysSettings.general.announce_guild.isEnabled = not AstralKeysSettings.general.announce_guild.isEnabled
	end)

local expandedTooltip = addon.CreateCheckBox(contentFrame, L['EXPANDED_TOOLTIP'])
expandedTooltip:SetPoint('TOPLEFT', announceParty, 'BOTTOMLEFT', 0, -5)
expandedTooltip:SetScript('OnClick', function ()
	AstralKeysSettings.general.expanded_tooltip.isEnabled = not AstralKeysSettings.general.expanded_tooltip.isEnabled
end)

local showForces = addon.CreateCheckBox(contentFrame, L['Show enemy forces in tooltip'])
showForces:SetPoint('LEFT', expandedTooltip, 'RIGHT', 10, 0)
showForces:SetScript('OnClick', function(self)
	AstralKeysSettings.general.show_tooltip_forces.isEnabled = self:GetChecked()
	end)

local chatHeader = contentFrame:CreateFontString(nil, 'OVERLAY', 'InterUIBold_Normal')
chatHeader:SetText(L['!keys chat command'])
chatHeader:SetPoint('TOPLEFT', expandedTooltip, 'BOTTOMLEFT', -10, -20)

local chatDesc = contentFrame:CreateFontString(nil, 'OVERLAY', 'InterUIRegular_Small')
chatDesc:SetText(L['!KEYS_DESC'])
chatDesc:SetPoint('TOPLEFT', chatHeader, 'BOTTOMLEFT', 5, -5)

local commandRespondParty = addon.CreateCheckBox(contentFrame, L['PARTY'])
commandRespondParty:SetPoint('TOPLEFT', chatDesc, 'BOTTOMLEFT', 5, -10)
commandRespondParty:SetScript('OnClick', function ()
	AstralKeysSettings.general.report_on_message['party'] = not AstralKeysSettings.general.report_on_message['party']
end)

local commandRespondGuild = addon.CreateCheckBox(contentFrame, L['GUILD'])
commandRespondGuild:SetPoint('LEFT', commandRespondParty, 'RIGHT', 10, 0)
commandRespondGuild:SetScript('OnClick', function ()
	AstralKeysSettings.general.report_on_message['guild'] = not AstralKeysSettings.general.report_on_message['guild']
end)

local commandRespondRaid = addon.CreateCheckBox(contentFrame, L['RAID'])
commandRespondRaid:SetPoint('LEFT', commandRespondGuild, 'RIGHT', 10, 0)
commandRespondRaid:SetScript('OnClick', function ()
	AstralKeysSettings.general.report_on_message['raid'] = not AstralKeysSettings.general.report_on_message['raid']
end)

local commandRespondNoKey = addon.CreateCheckBox(contentFrame, L['KEYS_RESPOND_ON_NO_KEY'])
commandRespondNoKey:SetPoint('TOPLEFT', commandRespondParty, 'BOTTOMLEFT', 0, -5)
commandRespondNoKey:SetScript('OnClick', function ()
	AstralKeysSettings.general.report_on_message['no_key'] = not AstralKeysSettings.general.report_on_message['no_key']
end)

local commandRespondAllCharacters = addon.CreateCheckBox(contentFrame, L['KEYS_RESPOND_WITH_ALL_CHARACTERS'])
commandRespondAllCharacters:SetPoint('LEFT', commandRespondNoKey, 'RIGHT', 10, 0)
commandRespondAllCharacters:SetScript('OnClick', function ()
	AstralKeysSettings.general.report_on_message['all_characters'] = not AstralKeysSettings.general.report_on_message['all_characters']
end)

local syncHeader = contentFrame:CreateFontString(nil, 'OVERLAY', 'InterUIBold_Normal')
syncHeader:SetText(L['SYNC OPTIONS'])
syncHeader:SetPoint('TOPLEFT', commandRespondNoKey, 'BOTTOMLEFT', -10, -20)

local syncFriends = addon.CreateCheckBox(contentFrame, L['Sync with friends'])
syncFriends:SetPoint('TOPLEFT', syncHeader, 'BOTTOMLEFT', 10, -10)
syncFriends:SetScript('OnClick', function(self)
	AstralKeysSettings.friendOptions.friend_sync.isEnabled = self:GetChecked()
	AstralKeyFrame:ToggleLists()
	addon.ToggleFriendSync()
	end)

local otherFaction = addon.CreateCheckBox(contentFrame, L['Show other faction'])
otherFaction:SetPoint('LEFT', syncFriends, 'RIGHT', 10, 0)
otherFaction:SetScript('OnClick', function(self)
	AstralKeysSettings.friendOptions.show_other_faction.isEnabled = self:GetChecked()
	addon.UpdateFrames()
	end)

local rankFilterHeader = contentFrame:CreateFontString(nil, 'OVERLAY', 'InterUIBold_Normal')
rankFilterHeader:SetText(L['Rank Filter'])
rankFilterHeader:SetPoint('TOPLEFT', syncFriends, 'BOTTOMLEFT', -10, -20)

local filter_descript = contentFrame:CreateFontString(nil, 'OVERLAY', 'InterUIRegular_Small')
filter_descript:SetText(L['Include these ranks in the guild listing'])
filter_descript:SetPoint('TOPLEFT', rankFilterHeader, 'BOTTOMLEFT', 5, -5)

local _ranks = {}
for i = 1, 10 do
	_ranks[i] = addon.CreateCheckBox(contentFrame, ' ')
	_ranks[i].id = i
end

function InitializeOptionSettings()
	showMinimap:SetChecked(AstralKeysSettings.general.show_minimap_button.isEnabled)
	showTooltip:SetChecked(AstralKeysSettings.general.show_tooltip_key.isEnabled)
	showForces:SetChecked(AstralKeysSettings.general.show_tooltip_forces.isEnabled)
	announceParty:SetChecked(AstralKeysSettings.general.announce_party.isEnabled)
	announceGuild:SetChecked(AstralKeysSettings.general.announce_guild.isEnabled)
	expandedTooltip:SetChecked(AstralKeysSettings.general.expanded_tooltip.isEnabled)
	commandRespondParty:SetChecked(AstralKeysSettings.general.report_on_message['party'])
	commandRespondGuild:SetChecked(AstralKeysSettings.general.report_on_message['guild'])
	commandRespondRaid:SetChecked(AstralKeysSettings.general.report_on_message['raid'])
	commandRespondNoKey:SetChecked(AstralKeysSettings.general.report_on_message['no_key'])
	commandRespondAllCharacters:SetChecked(AstralKeysSettings.general.report_on_message['all_characters'])

	showOffLine:SetChecked(AstralKeysSettings.frame.show_offline.isEnabled)
	mingleOffline:SetChecked(AstralKeysSettings.frame.mingle_offline.isEnabled)

	syncFriends:SetChecked(AstralKeysSettings.friendOptions.friend_sync.isEnabled)
	otherFaction:SetChecked(AstralKeysSettings.friendOptions.show_other_faction.isEnabled)

	for i = 1, GuildControlGetNumRanks() do
		_ranks[i]:SetText(GuildControlGetRankName(i))

		for i2 = GuildControlGetNumRanks() + 1, 10 do
			_ranks[i2]:Hide()
		end

		if i == 1 then
			_ranks[i]:SetPoint('TOPLEFT', filter_descript, 'BOTTOMLEFT', 5, -10)
		elseif (i % 3 == 1) then
			_ranks[i]:SetPoint('TOPLEFT', _ranks[i-3], 'BOTTOMLEFT', 0, -5)
		else
			_ranks[i]:SetPoint('LEFT', _ranks[i-1], 'RIGHT', 10, 0)
		end

		_ranks[i]:SetChecked(AstralKeysSettings.frame.rank_filter[i])

		_ranks[i]:SetScript('OnClick', function(self)
			AstralKeysSettings.frame.rank_filter[self.id] = self:GetChecked()
			if AstralKeysSettings.frame.list_shown == 'GUILD' then
				addon.UpdateFrames()
			end
			end)
	end
end
AstralEvents:Register('PLAYER_LOGIN', InitializeOptionSettings, 'initOptions')

AstralOptionsFrame:SetScript('OnKeyDown', function(self, key)
	if key == 'ESCAPE' then
		self:SetPropagateKeyboardInput(false)
		AstralOptionsFrame:Hide()
	end
	end)

AstralOptionsFrame:SetScript('OnShow', function(self)
	self:SetPropagateKeyboardInput(true)

	showMinimap:SetChecked(AstralKeysSettings.general.show_minimap_button.isEnabled)
	showTooltip:SetChecked(AstralKeysSettings.general.show_tooltip_key.isEnabled)
	showForces:SetChecked(AstralKeysSettings.general.show_tooltip_forces.isEnabled)
	announceParty:SetChecked(AstralKeysSettings.general.announce_party.isEnabled)
	announceGuild:SetChecked(AstralKeysSettings.general.announce_guild.isEnabled)
	expandedTooltip:SetChecked(AstralKeysSettings.general.expanded_tooltip.isEnabled)
	commandRespondParty:SetChecked(AstralKeysSettings.general.report_on_message['party'])
	commandRespondGuild:SetChecked(AstralKeysSettings.general.report_on_message['guild'])
	commandRespondRaid:SetChecked(AstralKeysSettings.general.report_on_message['raid'])
	commandRespondNoKey:SetChecked(AstralKeysSettings.general.report_on_message['no_key'])
	commandRespondAllCharacters:SetChecked(AstralKeysSettings.general.report_on_message['all_characters'])

	showOffLine:SetChecked(AstralKeysSettings.frame.show_offline.isEnabled)
	mingleOffline:SetChecked(AstralKeysSettings.frame.mingle_offline.isEnabled)

	syncFriends:SetChecked(AstralKeysSettings.friendOptions.friend_sync.isEnabled)
	otherFaction:SetChecked(AstralKeysSettings.friendOptions.show_other_faction.isEnabled)
	end)