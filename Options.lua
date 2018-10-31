local e, L = unpack(select(2, ...))

local AstralOptionsFrame = CreateFrame('FRAME', 'AstralOptionsFrame', UIParent)
AstralOptionsFrame:SetFrameStrata('DIALOG')
AstralOptionsFrame:SetFrameLevel(5)
AstralOptionsFrame:SetHeight(385)
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
menuBar:SetHeight(385)
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
--[[
local logo = AstralOptionsFrame:CreateTexture(nil, 'ARTWORK')
logo:SetSize(64, 64)
logo:SetTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\Astral.tga')
logo:SetPoint('TOPLEFT', AstralOptionsFrame, 'TOPLEFT', 10, -10)
]]
local logo_Key = menuBar:CreateTexture(nil, 'ARTWORK')
logo_Key:SetSize(32, 32)
logo_Key:SetTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\key-white@2x2.tga')
logo_Key:SetPoint('TOPLEFT', menuBar, 'TOPLEFT', 10, -10)

local divider = menuBar:CreateTexture(nil, 'ARTWORK')
divider:SetSize(20, 1)
divider:SetColorTexture(.6, .6, .6, .8)
divider:SetPoint('TOP', logo_Key, 'BOTTOM', 0, -20)

local logo_Astral = menuBar:CreateTexture(nil, 'ARTWORK')
logo_Astral:SetAlpha(0.8)
logo_Astral:SetSize(32, 32)
logo_Astral:SetTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\Logo@2x2.tga')
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
contentFrame:SetSize(550, 335)

contentFrame.t = contentFrame:CreateTexture(nil, 'ARTWORK')
contentFrame.t:SetAllPoints(contentFrame)
--contentFrame.t:SetColorTexture(0, .5, 1)

local generalHeader = contentFrame:CreateFontString(nil, 'OVERLAY', 'InterUIBold_Normal')
generalHeader:SetText(L['GENERAL OPTIONS'])
generalHeader:SetPoint('TOPLEFT', contentFrame, 'TOPLEFT')

local showOffLine = e.CreateCheckBox(contentFrame, 'Show offline players')
showOffLine:SetPoint('TOPLEFT', generalHeader, 'BOTTOMLEFT', 10, -10)
showOffLine:SetScript('OnClick', function(self)
	AstralKeysSettings.options.showOffline = self:GetChecked()
	e.UpdateFrames()
	HybridScrollFrame_SetOffset(AstralKeyFrameListContainer, 0)
	end)

local showMinimap = e.CreateCheckBox(contentFrame, 'Show Minimap button')
showMinimap:SetPoint('LEFT', showOffLine, 'RIGHT', 10, 0)
showMinimap:SetScript('OnClick', function(self)
	AstralKeysSettings.options.showMiniMapButton = self:GetChecked()
	if AstralKeysSettings.options.showMiniMapButton then
		e.icon:Show('AstralKeys')
	else
		e.icon:Hide('AstralKeys')
	end
	if IsAddOnLoaded('ElvUI_Enhanced') then -- Update the layout for the minimap buttons
		ElvUI[1]:GetModule('MinimapButtons'):UpdateLayout()
	end
	end)

local showTooltip = e.CreateCheckBox(contentFrame, 'Show current key in tooltip')
showTooltip:SetPoint('TOPLEFT', showOffLine, 'BOTTOMLEFT', 0, -5)
showTooltip:SetScript('OnClick', function(self)
	AstralKeysSettings.options.showTooltip = self:GetChecked()
	end)

local announceParty = e.CreateCheckBox(contentFrame, L['Announce new keys to party'])
announceParty:SetPoint('TOPLEFT', showTooltip, 'BOTTOMLEFT', 0, -5)
announceParty:SetScript('OnClick', function(self)
	e.ToggleAnnounce('PARTY')
	end)

local announceGuild = e.CreateCheckBox(contentFrame, L['Announce new keys to guild'])
announceGuild:SetPoint('LEFT', announceParty, 'RIGHT', 10, 0)
announceGuild:SetScript('OnClick', function(self)
	e.ToggleAnnounce('GUILD')
	end)

local syncHeader = contentFrame:CreateFontString(nil, 'OVERLAY', 'InterUIBold_Normal')
syncHeader:SetText(L['SYNC OPTIONS'])
syncHeader:SetPoint('TOPLEFT', announceParty, 'BOTTOMLEFT', -10, -20)

local syncFriends = e.CreateCheckBox(contentFrame, 'Sync with friends')
syncFriends:SetPoint('TOPLEFT', syncHeader, 'BOTTOMLEFT', 10, -10)
syncFriends:SetScript('OnClick', function(self)
	AstralKeysSettings.options.friendSync= self:GetChecked()
	AstralKeyFrame:ToggleLists()
	e.ToggleFriendSync()
	end)

local otherFaction = e.CreateCheckBox(contentFrame, 'Show other faction')
otherFaction:SetPoint('LEFT', syncFriends, 'RIGHT', 10, 0)
otherFaction:SetScript('OnClick', function(self)
	AstralKeysSettings.options.showOtherFaction = self:GetChecked()
	e.UpdateFrames()
	end)

local rankFilterHeader = contentFrame:CreateFontString(nil, 'OVERLAY', 'InterUIBold_Normal')
rankFilterHeader:SetText(L['Rank Filter'])
rankFilterHeader:SetPoint('TOPLEFT', syncFriends, 'BOTTOMLEFT', -10, -20)

local filter_descript = contentFrame:CreateFontString(nil, 'OVERLAY', 'InterUIRegular_Small')
filter_descript:SetText(L['Include these ranks in the guild listing'])
filter_descript:SetPoint('TOPLEFT', rankFilterHeader, 'BOTTOMLEFT', 5, -5)

local _ranks = {}
for i = 1, 10 do
	_ranks[i] = e.CreateCheckBox(contentFrame, ' ')
	_ranks[i].id = i
end

function InitData()
	otherFaction:SetChecked(AstralKeysSettings.options.showOtherFaction)
	showOffLine:SetChecked(AstralKeysSettings.options.showOffline)
	showMinimap:SetChecked(AstralKeysSettings.options.showMiniMapButton)
	announceParty:SetChecked(AstralKeysSettings.options.announceKey)
	showTooltip:SetChecked(AstralKeysSettings.options.showTooltip)
	syncFriends:SetChecked(AstralKeysSettings.options.friendSync)

	for i = 1, GuildControlGetNumRanks() do
		_ranks[i]:SetText(GuildControlGetRankName(i))

		for i = GuildControlGetNumRanks() + 1, 10 do
			_ranks[i]:Hide()
		end

		if i == 1 then
			_ranks[i]:SetPoint('TOPLEFT', filter_descript, 'BOTTOMLEFT', 5, -10)
		elseif (i % 3 == 1) then
			_ranks[i]:SetPoint('TOPLEFT', _ranks[i-3], 'BOTTOMLEFT', 0, -5)
		else
			_ranks[i]:SetPoint('LEFT', _ranks[i-1], 'RIGHT', 10, 0)
		end

		_ranks[i]:SetChecked(AstralKeysSettings.options.rankFilters[i])

		_ranks[i]:SetScript('OnClick', function(self)
			AstralKeysSettings.options.rankFilters[self.id] = self:GetChecked()
			if AstralKeysSettings.frameOptions.list == 'GUILD' then
				e.UpdateFrames()
			end
			end)
	end
end
AstralEvents:Register('PLAYER_LOGIN', InitData, 'initOptions')

AstralOptionsFrame:SetScript('OnKeyDown', function(self, key)
	if key == 'ESCAPE' then
		self:SetPropagateKeyboardInput(false)
		AstralOptionsFrame:Hide()
	end
	end)

AstralOptionsFrame:SetScript('OnShow', function(self)
	self:SetPropagateKeyboardInput(true)
	otherFaction:SetChecked(AstralKeysSettings.options.showOtherFaction)
	showOffLine:SetChecked(AstralKeysSettings.options.showOffline)
	showMinimap:SetChecked(AstralKeysSettings.options.showMiniMapButton)
	announceParty:SetChecked(AstralKeysSettings.options.announceKey)
	showTooltip:SetChecked(AstralKeysSettings.options.showTooltip)
	syncFriends:SetChecked(AstralKeysSettings.options.friendSync)
	end)