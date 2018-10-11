local _, e = ...

local BACKDROP = {
bgFile = "Interface/Tooltips/UI-Tooltip-Background",
edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16, edgeSize = 1,
insets = {left = 0, right = 0, top = 0, bottom = 0}
}

-- MixIns
AstralKeysCharacterMixin = {}
AstralKeysListMixin = {}
-- Red color code
-- #C72329

-- Background
-- Left #000000 ALPHA 0.8
-- Right #212121 ALPHA 0.8

local CHARACTER_DUNGEON_NOT_RAN = 'No mythic dungeon ran'
local CHARACTER_KEY_NOT_FOUND = 'No key found'

local COLOR_GRAY = 'ff9d9d9d'

-- Scroll bar texture alpha settings
local SCROLL_TEXTURE_ALPHA_MIN = 0.2
local SCROLL_TEXTURE_ALPHA_MAX = 0.6

local FRAME_WIDTH_EXPANDED = 765
local FRAME_WIDTH_MINIMIZED = 550

-- Used for filtering, sorting, and displaying units on lists
local sortedTable = {}
sortedTable.numShown = 0
sortedTable['GUILD'] = {}
sortedTable['FRIENDS'] = {}

function AstralKeysCharacterMixin:UpdateUnit(characterID)
	local unit = e.CharacterName(characterID)
	local realm = e.CharacterRealm(characterID)
	local unitClass = e.GetCharacterClass(characterID)

	local bestKey = e.GetCharacterBestLevel(characterID)
	local currentMapID = e.GetCharacterMapID(unit .. '-' .. realm)
	local currentKeyLevel = e.GetCharacterKeyLevel(unit .. '-' .. realm)

	if e.CharacterRealm(characterID) ~= e.PlayerRealm() then
		unit = unit .. ' (*)'
	end
	self.nameString:SetText(WrapTextInColorCode(unit, select(4, GetClassColor(unitClass))))

	if bestKey ~= 0 then
		self.weeklyStringValue:SetText(bestKey)
	end

	if unit:find('Neko') then
		self.weeklyStringValue:SetText(10)
	end

	if currentMapID then
		self.keyStringValue:SetFormattedText('%d %s', currentKeyLevel, e.GetMapName(currentMapID))
	else
		self.keyStringValue:SetFormattedText('|c%s%s|r', COLOR_GRAY, CHARACTER_KEY_NOT_FOUND)
	end
end

function AstralKeysCharacterMixin:OnEnter()
	local scrollBar = self:GetParent():GetParent().scrollBar
	local scrollButton = _G[scrollBar:GetName() .. 'ThumbTexture']
	scrollButton:SetAlpha(SCROLL_TEXTURE_ALPHA_MAX)
end

function AstralKeysCharacterMixin:OnLeave()
	local scrollBar = self:GetParent():GetParent().scrollBar
	local scrollButton = _G[scrollBar:GetName() .. 'ThumbTexture']
	scrollButton:SetAlpha(SCROLL_TEXTURE_ALPHA_MIN)
end

function AstralKeysListMixin:SetUnit(...)
	e.GetListFunction(e.FrameListShown())(self, ...)
end

function AstralKeysListMixin:OnClick()
	AstralMenuFrame:ClearAllPoints()
	local uiScale = UIParent:GetScale();

	local cursorX, cursorY = GetCursorPosition();
	cursorX = cursorX/uiScale;
	cursorY =  cursorY/uiScale;
	xOffset, yOffset = 15, 0

	xOffset = cursorX + xOffset
	yOffset = cursorY + yOffset

	AstralMenuFrame:SetUnit(self.unitID)
	AstralMenuFrame:SetPoint('TOPLEFT', UIParent, 'BOTTOMLEFT', xOffset, yOffset)
	ToggleFrame(AstralMenuFrame)
end

function AstralKeysListMixin:OnEnter()
	local scrollBar = self:GetParent():GetParent().scrollBar
	local scrollButton = _G[scrollBar:GetName() .. 'ThumbTexture']
	scrollButton:SetAlpha(SCROLL_TEXTURE_ALPHA_MAX)
end

function AstralKeysListMixin:OnLeave()
	local scrollBar = self:GetParent():GetParent().scrollBar
	local scrollButton = _G[scrollBar:GetName() .. 'ThumbTexture']
	scrollButton:SetAlpha(SCROLL_TEXTURE_ALPHA_MIN)
end

-- Unit dropdown mneu items, whisper and invite
local function Whisper_OnShow(self)
	local isConnected = true
	if e.FrameListShown() == 'GUILD' then
		isConnected = e.GuildMemberOnline(e.Unit(AstralMenuFrame.unit))
	end
	if e.FrameListShown() == 'FRIENDS' then
		isConnected = e.IsFriendOnline(e.Friend(AstralMenuFrame.unit))
	end
	self.isConnected = isConnected

	if not self.isConnected then
		self:SetText(WrapTextInColorCode(self:GetText(), 'ff9d9d9d'))
	else
		self:SetText('Whisper')
	end
end

local function SendWhisper(self)
	if not self.isConnected then return end

	if AstralKeysSettings.frameOptions.list == 'GUILD' then
		ChatFrame_SendTell(e.Unit(AstralMenuFrame.unit))
	else
		if AstralFriends[AstralMenuFrame.unit][2] then
			ChatFrame_SendSmartTell(e.FriendPresName(e.Friend(AstralMenuFrame.unit)))
		else
			ChatFrame_SendTell(e.Friend(AstralMenuFrame.unit))
		end
	end
end
AstralMenuFrame:AddSelection('Whisper', SendWhisper, Whisper_OnShow)

local function Invite_OnShow(self)
	local inviteType
	local isConnected = true
	if e.FrameListShown() == 'GUILD' then
		inviteType = GetDisplayedInviteType(e.GuildMemberGuid(e.Unit(AstralMenuFrame.unit)))
		isConnected = e.GuildMemberOnline(e.Unit(AstralMenuFrame.unit))
	end
	if e.FrameListShown() == 'FRIENDS' then
		isConnected = e.IsFriendOnline(e.Friend(AstralMenuFrame.unit))
		inviteType = GetDisplayedInviteType(e.FriendGUID(e.Friend(AstralMenuFrame.unit)))
	end

	if inviteType == 'INVITE' then
		self:SetText('Invite')
	elseif inviteType == 'SUGGEST_INVITE' then
		self:SetText('Suggest Invite')
	elseif inviteType == 'REQUEST_INVITE' then
		self:SetText('Request Invite')
	end
	if not isConnected then
		self:SetText(WrapTextInColorCode(self:GetText(), 'ff9d9d9d'))
	end

	self.isConnected = isConnected
	self.inviteType = inviteType
end

local function InviteUnit(self)
	if not self.isConnected then return end
	
	if e.FrameListShown() == 'GUILD' then
		if self.inviteType == 'INVITE' then
			InviteToGroup(e.Unit(AstralMenuFrame.unit))
		elseif self.inviteType == 'REQUEST_INVITE' then
			RequestInviteFromUnit(e.Unit(AstralMenuFrame.unit))
		elseif self.inviteType == 'SUGGEST_INVITE' then
			InviteToGroup(e.Unit(AstralMenuFrame.unit))
		end
	end
	if e.FrameListShown() == 'FRIENDS' then
		if AstralFriends[AstralMenuFrame.unit][2] then -- bnet friend
			if self.inviteType == 'INVITE' then
				BNInviteFriend(e.FriendGAID(e.Friend(AstralMenuFrame.unit)))
			elseif self.inviteType == 'REQUEST_INVITE' then
				BNRequestInviteFriend(e.GetFriendGaID(AstralFriends[AstralMenuFrame.unit][2]))
			elseif self.inviteType == 'SUGGEST_INVITE' then
				BNInviteFriend(e.GetFriendGaID(AstralFriends[AstralMenuFrame.unit][2]))
			end			
		else
			if self.inviteType == 'INVITE' then
				BNInviteFriend(e.FriendGUID(e.Friend(AstralMenuFrame.unit)))
			elseif self.inviteType == 'REQUEST_INVITE' then
				BNRequestInviteFriend(e.FriendGUID(e.Friend(AstralMenuFrame.unit)))
			elseif self.inviteType == 'SUGGEST_INVITE' then
				BNInviteFriend(e.FriendGUID(e.Friend(AstralMenuFrame.unit)))
			end			
		end
	end
end
AstralMenuFrame:AddSelection('Invite', InviteUnit, Invite_OnShow)
AstralMenuFrame:AddSelection('Cancel', function() return AstralMenuFrame:Hide() end)

local AstralKeyFrame = CreateFrame('FRAME', 'AstralKeyFrame', UIParent)
AstralKeyFrame:SetFrameStrata('DIALOG')
AstralKeyFrame:SetWidth(765)
AstralKeyFrame:SetHeight(490)
AstralKeyFrame:SetPoint('CENTER', UIParent, 'CENTER')
AstralKeyFrame:EnableMouse(true)
AstralKeyFrame:SetMovable(true)
AstralKeyFrame:RegisterForDrag('LeftButton')
AstralKeyFrame:EnableKeyboard(true)
AstralKeyFrame:SetPropagateKeyboardInput(true)
AstralKeyFrame:SetClampedToScreen(true)
AstralKeyFrame:Hide()
AstralKeyFrame.updateDelay = 0
AstralKeyFrame.texture = AstralKeyFrame:CreateTexture(nil, 'BACKGROUND')
AstralKeyFrame.texture:SetAllPoints(AstralKeyFrame)
AstralKeyFrame.texture:SetColorTexture(0, 0, 0, 0.8)

local AstralKeyToolTip = CreateFrame( "GameTooltip", "AstralKeyToolTip", AAFrame, "GameTooltipTemplate" )
AstralKeyToolTip:SetOwner(AstralKeyFrame, "ANCHOR_CURSOR")
AstralKeyToolTip:SetScript('OnShow', function(self)
	self:SetBackdrop(BACKDROP)
	self:SetBackdropColor(0, 0, 0, .8)
	self:SetBackdropBorderColor(0, 0, 0)
end)

-- Skin the tooltip.

for i = 1, 8 do
	_G['AstralKeyToolTipTextRight' .. i]:SetFontObject(InterUIBold_Tiny)
	_G['AstralKeyToolTipTextLeft' .. i]:SetFontObject(InterUIBold_Tiny)
end

local offLineButton = e.CreateCheckBox(AstralKeyFrame, SHOW_OFFLINE_MEMBERS, 150)
offLineButton:SetNormalFontObject(InterUIRegular_Small)
offLineButton:SetPoint('BOTTOMRIGHT', AstralKeyFrame, 'BOTTOMRIGHT', -15, 10)
offLineButton:SetAlpha(0.5)
offLineButton:SetScript('OnClick', function(self)
	AstralKeysSettings.options.showOffline = self:GetChecked()
	HybridScrollFrame_SetOffset(AstralKeyFrameListContainer, 0)
	e.UpdateFrames()
end)

local menuBar = CreateFrame('FRAME', '$parentMenuBar', AstralKeyFrame)
menuBar:SetSize(50, 490)
menuBar:SetPoint('TOPLEFT', AstralKeyFrame, 'TOPLEFT')
menuBar.texture = menuBar:CreateTexture(nil, 'BACKGROUND')
menuBar.texture:SetAllPoints(menuBar)
menuBar.texture:SetColorTexture(33/255, 33/255, 33/255, 0.8)

local logo_Key = menuBar:CreateTexture(nil, 'ARTWORK')
logo_Key:SetSize(32, 32)
logo_Key:SetTexture('Interface\\AddOns\\AstralKeys\\Media\\topnep.tga')
logo_Key:SetPoint('TOPLEFT', menuBar, 'TOPLEFT', 10, -10)

local divider = menuBar:CreateTexture(nil, 'ARTWORK')
divider:SetSize(20, 1)
divider:SetColorTexture(.6, .6, .6, .8)
divider:SetPoint('TOP', logo_Key, 'BOTTOM', 0, -20)

local reportButton = CreateFrame('BUTTON', '$parentReportButton', menuBar)
reportButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\speaker.tga')
reportButton:SetSize(20, 20)
reportButton:GetNormalTexture():SetVertexColor(.8, .8, .8, 0.8)
reportButton:SetPoint('TOP', divider, 'BOTTOM', 0, -20)
reportButton:SetScript('OnEnter', function(self)
	self:GetNormalTexture():SetVertexColor(126/255, 126/255, 126/255, 0.8)
end)
reportButton:SetScript('OnLeave', function(self)
	self:GetNormalTexture():SetVertexColor(0.8, 0.8, 0.8, 0.8)
end)
reportButton:SetScript('OnClick', function()
	AstralOptionsFrame:SetShown( not AstralOptionsFrame:IsShown())
	end)

local settingsButton = CreateFrame('BUTTON', '$parentSettingsButton', menuBar)
settingsButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\cog2.tga')
settingsButton:SetSize(20, 20)
settingsButton:GetNormalTexture():SetVertexColor(.8, .8, .8, 0.8)
settingsButton:SetPoint('TOP', reportButton, 'BOTTOM', 0, -20)
settingsButton:SetScript('OnEnter', function(self)
	self:GetNormalTexture():SetVertexColor(126/255, 126/255, 126/255, 0.8)
end)
settingsButton:SetScript('OnLeave', function(self)
	self:GetNormalTexture():SetVertexColor(0.8, 0.8, 0.8, 0.8)
end)
settingsButton:SetScript('OnClick', function()
	AstralOptionsFrame:SetShown( not AstralOptionsFrame:IsShown())
	end)

local logo_Astral = menuBar:CreateTexture(nil, 'ARTWORK')
logo_Astral:SetSize(32, 32)
logo_Astral:SetTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\Astral.tga')
logo_Astral:SetPoint('BOTTOMLEFT', menuBar, 'BOTTOMLEFT', 10, 10)

local collapseButton = CreateFrame('BUTTON', '$parentCollapseButton', menuBar)
collapseButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\collapse.tga')
collapseButton:SetSize(20, 20)
collapseButton:GetNormalTexture():SetVertexColor(.8, .8, .8, 0.8)
collapseButton:SetPoint('BOTTOM', logo_Astral, 'TOP', 0, 20)
collapseButton:SetScript('OnEnter', function(self)
	self:GetNormalTexture():SetVertexColor(126/255, 126/255, 126/255, 0.8)
end)
collapseButton:SetScript('OnLeave', function(self)
	self:GetNormalTexture():SetVertexColor(0.8, 0.8, 0.8, 0.8)
end)

---- List Buttons
-----------------------------------
local closeButton = CreateFrame('BUTTON', nil, AstralKeyFrame)
closeButton:SetSize(15, 15)
closeButton:SetNormalFontObject(FONT_OBJECT_CENTRE)
closeButton:SetHighlightFontObject(FONT_OBJECT_HIGHLIGHT)
closeButton:SetText('X')
closeButton:SetScript('OnClick', function()
	AstralKeyFrame:Hide()
end)
closeButton:SetPoint('TOPRIGHT', AstralKeyFrame, 'TOPRIGHT', -10, -10)

-- Tab bar at the top, only show 5 and then start scrolling

-- MenuBar 50px
-- Middle Frame 215px
local tabFrame = CreateFrame('FRAME', '$parentTabFrame', AstralKeyFrame)
tabFrame:SetSize(500, 40)
tabFrame:SetPoint('TOPRIGHT', AstralKeyFrame, 'TOPRIGHT', 0, 0)
tabFrame.t = tabFrame:CreateTexture(nil, 'ARTWORK')
tabFrame.t:SetAllPoints(tabFrame)
--tabFrame.t:SetColorTexture(0, .5, 1)
tabFrame.buttons = {}

local MIN_BUTTON_WIDTH = 50
local MAX_BUTTON_WIDTH = 100

local function UpdateTabs()
	local buttons = AstralKeyFrameTabFrame.buttons

	for i = 1, #buttons do
		if e.FrameListShown() == buttons[i].listName then
			buttons[i].underline:Show()
			buttons[i]:SetAlpha(1)
		else
			buttons[i].underline:Hide()
			buttons[i]:SetAlpha(0.5)
		end
		if i == 1 then
			buttons[i]:SetPoint('LEFT', AstralKeyFrameTabFrame, 'LEFT', 10, 0)
		else
			buttons[i]:SetPoint('LEFT', buttons[i-1], 'RIGHT', 10, 0)
		end
	end
end

local function Tab_OnClick(self)	
    if e.FrameListShown() ~= self.listName then
        e.SetFrameListShown(self.listName)
        UpdateTabs()
        e.UpdateFrames()
        HybridScrollFrame_SetOffset(AstralKeyFrameListContainer, 0)
        AstralKeyFrameListContainer.scrollBar:SetValue(0)
    end
end

local function CreateNewTab(name, parent, ...)
	if not name or type(name) ~= 'string' then
		error('CreateNewTab(name, parent, ...) name: string expected, received ' .. type(name))
	end
	local buttons = parent.buttons
	local self = CreateFrame('BUTTON', '$parentTab' .. name, parent)
	self.listName = name
	self:SetNormalFontObject(InterUIBlack_Small)
	self:SetText(name)
	self:SetWidth(50)
	self:SetHeight(15)
	self:SetScript('OnClick', function(self) Tab_OnClick(self) end)

	local textWidth = self:GetFontString():GetStringWidth()
	self.underline = self:CreateTexture(nil, 'ARTWORK')
	self.underline:SetSize(textWidth, 2)
	self.underline:SetColorTexture(214/255, 38/255, 38/255)
	self.underline:SetPoint('BOTTOM', self, 'BOTTOM', 0, -1)

	self.underline:Hide()

	table.insert(buttons, self)
end

CreateNewTab('GUILD', tabFrame)
CreateNewTab('FRIENDS', tabFrame)
UpdateTabs()

-- Middle panel construction, Affixe info, character info, guild/version string
local characterFrame = CreateFrame('FRAME', '$parentCharacterFrame', AstralKeyFrame)
characterFrame:SetSize(215, 490)
characterFrame:SetPoint('TOPLEFT', AstralKeyFrame, 'TOPLEFT', 51, 0)

characterFrame.collapse = characterFrame:CreateAnimationGroup()
local characterCollapse = characterFrame.collapse:CreateAnimation('Alpha')
characterCollapse:SetFromAlpha(1)
characterCollapse:SetToAlpha(0)
characterCollapse:SetDuration(.15)
characterCollapse:SetSmoothing('IN_OUT')

characterCollapse:SetScript('OnFinished', function(self)
	self:GetParent():GetParent():Hide()
	end)

characterCollapse:SetScript('OnUpdate', function(self)
	if self:GetProgress() > 0.6 then self:GetRegionParent():SetAlpha(self:GetProgress()/2) end
	local left, bottom, width = AstralKeyFrame:GetRect()
	local newWidth = FRAME_WIDTH_EXPANDED - (self:GetProgress() * 215)
	AstralKeyFrame:ClearAllPoints()
	AstralKeyFrame:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOMLEFT', left + width - newWidth, bottom)
	AstralKeyFrame:SetWidth(newWidth)
	end)

characterFrame.expand = characterFrame:CreateAnimationGroup()
local characterExpand = characterFrame.expand:CreateAnimation('Alpha')
characterExpand:SetFromAlpha(0)
characterExpand:SetToAlpha(1)
characterExpand:SetDuration(.15)
characterExpand:SetSmoothing('IN_OUT')

characterExpand:SetScript('OnPlay', function(self)
	self:GetParent():GetParent():Show()
	end)

characterExpand:SetScript('OnUpdate', function(self, elapsed)
		if self:GetProgress() < 0.6 then self:GetRegionParent():SetAlpha(0) end
		local left, bottom, width = AstralKeyFrame:GetRect()
		local newWidth = FRAME_WIDTH_MINIMIZED + (self:GetProgress() * 215)
		AstralKeyFrame:ClearAllPoints()
		AstralKeyFrame:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOMLEFT', left + width - newWidth, bottom)
		AstralKeyFrame:SetWidth(newWidth)
	end)


collapseButton:SetScript('OnClick', function(self)
	if AstralKeysSettings.frameOptions.viewMode == 0 then
		if AstralKeyFrameCharacterFrame.expand:IsPlaying() then
			AstralKeyFrameCharacterFrame.expand:Stop()
		end
		AstralKeyFrameCharacterFrame.collapse:Play()
		AstralKeysSettings.frameOptions.viewMode = 1
		self:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\collapse.tga')
	else
		if AstralKeyFrameCharacterFrame.collapse:IsPlaying() then
			AstralKeyFrameCharacterFrame.collapse:Stop()
		end
		AstralKeyFrameCharacterFrame.expand:Play()
		AstralKeysSettings.frameOptions.viewMode = 0
		self:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\expand.tga')
	end
	end)


local characterTitle = characterFrame:CreateFontString(nil, 'OVERLAY', 'InterUIBlack_Small')
characterTitle:SetPoint('TOPLEFT', characterFrame, 'TOPLEFT', 20, -100)
characterTitle:SetText('CHARACTERS')

local guildVersionString = characterFrame:CreateFontString(nil, 'OVERLAY', 'InterUIRegular_Small')
guildVersionString:SetFormattedText('Astral Turalyon (US) %s', 'v3')
guildVersionString:SetJustifyH('CENTER')
guildVersionString:SetPoint('BOTTOM', characterFrame, 'BOTTOM', 0, 20)
guildVersionString:SetAlpha(0.2)

characterFrame.texture = characterFrame:CreateTexture(nil, 'BACKGROUND')
characterFrame.texture:SetColorTexture(33/255, 33/255, 33/255, 0.8)
characterFrame.texture:SetAllPoints(characterFrame)

local affixTitle = characterFrame:CreateFontString(nil, 'OVERLAY', 'InterUIBlack_Small')
affixTitle:SetPoint('TOPLEFT', characterFrame, 'TOPLEFT', 20, -20)
affixTitle:SetText('AFFIXES')

-- Affix Frames
-----------------------------------------------------

do
	for i = 1, 4 do
		local frame = CreateFrame('FRAME', '$parentAffix' .. i, characterFrame)
		frame.id = i

		local mask = frame:CreateMaskTexture()
		mask:SetTexture("Interface\\MINIMAP\\UI-Minimap-Background", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		mask:SetSize(32, 32)
		mask:SetPoint("CENTER")

		frame.affixID = 0
		frame:SetSize(32, 32)
		frame.texture = frame:CreateTexture(nil, 'ARTWORK')
				
		frame.texture:AddMaskTexture(mask)

		if i == 1 then
			frame:SetPoint('TOPLEFT', affixTitle, 'BOTTOMLEFT', 0, -15)
		else
			frame:SetPoint('LEFT', '$parentAffix' .. (i -1), 'RIGHT', 15, 0)
		end
		frame.texture:SetAllPoints(frame)

		function frame:UpdateInfo(affixID)
			self.affixID = affixID
			self.texture:SetTexture(select(3, C_ChallengeMode.GetAffixInfo(affixID)))
		end

		frame:SetScript('OnEnter', function(self)
			AstralKeyToolTip:SetOwner(self, 'ANCHOR_BOTTOMLEFT')
			AstralKeyToolTip:AddLine(e.AffixName(self.id), 1, 1, 1)
			--GameTooltip:AddLine("|T"..itemTexture..":0|t ")  USE THIS TO ADD WEEKS TO COME AFFIXES 2-3?
			AstralKeyToolTip:Show()
			end)
		frame:SetScript('OnLeave', function(self)
			AstralKeyToolTip:Hide()
		end)
	end
end

-- Character Frames
----------------------------------------------------------------
function CharacterScrollFrame_Update()
	local scrollFrame = AstralKeyFrameCharacterFrameCharacterContainer
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local buttons = scrollFrame.buttons
	local numButtons = #buttons
	local button, index
	local height = scrollFrame.buttonHeight
	local usedHeight = #buttons * height

	for i = 1, #buttons do
		if AstralCharacters[i+offset] then
			buttons[i]:UpdateUnit(i+offset)
			buttons[i]:Show()
		else
			buttons[i]:Hide()
		end
	end

	HybridScrollFrame_Update(AstralKeyFrameCharacterFrameCharacterContainer, height * #AstralCharacters, usedHeight)
end

local function CharacterScrollFrame_OnEnter()
	AstralKeyFrameCharacterFrameCharacterContainerScrollBarThumbTexture:SetAlpha(SCROLL_TEXTURE_ALPHA_MAX)
end

local function CharacterScrollFrame_OnLeave()
	AstralKeyFrameCharacterFrameCharacterContainerScrollBarThumbTexture:SetAlpha(SCROLL_TEXTURE_ALPHA_MIN)
end

local characterScrollFrame = CreateFrame('ScrollFrame', '$parentCharacterContainer', AstralKeyFrameCharacterFrame, 'HybridScrollFrameTemplate')
characterScrollFrame:SetSize(180, 320)
characterScrollFrame:SetPoint('TOPLEFT', characterTitle, 'TOPLEFT', 0, -25)
characterScrollFrame:SetScript('OnEnter',  CharacterScrollFrame_OnEnter)
characterScrollFrame:SetScript('OnLeave', CharacterScrollFrame_OnLeave)

local characterScrollBar = CreateFrame('Slider', '$parentScrollBar', characterScrollFrame, 'HybridScrollBarTemplate')
characterScrollBar:SetWidth(10)
characterScrollBar:SetPoint('TOPLEFT', characterScrollFrame, 'TOPRIGHT')
characterScrollBar:SetPoint('BOTTOMLEFT', characterScrollFrame, 'BOTTOMRIGHT', 1, 0)
characterScrollBar:SetScript('OnEnter', CharacterScrollFrame_OnEnter)
characterScrollBar:SetScript('OnLeave', CharacterScrollFrame_OnLeave)

-- Re-skin the scroll Bar
characterScrollBar.ScrollBarTop:Hide()
characterScrollBar.ScrollBarMiddle:Hide()
characterScrollBar.ScrollBarBottom:Hide()
_G[characterScrollBar:GetName() .. 'ScrollDownButton']:Hide()
_G[characterScrollBar:GetName() .. 'ScrollUpButton']:Hide()

local scrollButton = _G[characterScrollBar:GetName() .. 'ThumbTexture']
scrollButton:SetHeight(50)
scrollButton:SetWidth(5)
scrollButton:SetVertexColor(1, 1, 1, SCROLL_TEXTURE_ALPHA_MIN)

characterScrollFrame.buttonHeight = 45
characterScrollFrame.update = CharacterScrollFrame_Update


-- Key List Frames
----------------------------------------------------------------
-- self, unit, unitClass, mapID, keyLevel, cache, faction, btag
function ListScrollFrame_Update()
	local scrollFrame = AstralKeyFrameListContainer
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local buttons = scrollFrame.buttons
	
	local button, index
	local height = scrollFrame.buttonHeight
	local usedHeight = 0
	local list = e.FrameListShown()
	local lastIndex = 1

	for i = 1, math.min(sortedTable.numShown, #buttons) do
		for j = lastIndex, #sortedTable[list] do
			if sortedTable[list][j+offset] and sortedTable[list][j+offset].isShown then
				usedHeight = usedHeight + height
				lastIndex = j + 1
				buttons[i]:SetUnit(sortedTable[list][j+offset].character_name, sortedTable[list][j+offset].character_class, sortedTable[list][j+offset].mapID, sortedTable[list][j+offset].key_level, sortedTable[list][j+offset].weekly_cache, sortedTable[list][j+offset]['faction'], sortedTable[list][j+offset]['btag'])
				buttons[i]:Show()
				break
			end
		end
	end

	for i = sortedTable.numShown + 1, #buttons do
		buttons[i]:Hide()
	end
	AstralKeyFrameListContainer.stepSize = (sortedTable.numShown / #buttons) * height
	HybridScrollFrame_Update(AstralKeyFrameListContainer, height * sortedTable.numShown, usedHeight)
end

local function ListScrollFrame_OnEnter()
	AstralKeyFrameListContainerScrollBarThumbTexture:SetAlpha(SCROLL_TEXTURE_ALPHA_MAX)
end

local function ListScrollFrame_OnLeave()
	AstralKeyFrameListContainerScrollBarThumbTexture:SetAlpha(SCROLL_TEXTURE_ALPHA_MIN)
end

local listScrollFrame = CreateFrame('ScrollFrame', '$parentListContainer', AstralKeyFrame, 'HybridScrollFrameTemplate')
listScrollFrame:SetSize(455, 390)
listScrollFrame:SetPoint('TOPLEFT', tabFrame, 'BOTTOMLEFT', 10, -35)
listScrollFrame.update = ListScrollFrame_Update
listScrollFrame:SetScript('OnEnter',  ListScrollFrame_OnEnter)
listScrollFrame:SetScript('OnLeave', ListScrollFrame_OnLeave)

local listScrollBar = CreateFrame('Slider', '$parentScrollBar', listScrollFrame, 'HybridScrollBarTemplate')
listScrollBar:SetWidth(10)
listScrollBar:SetPoint('TOPLEFT', listScrollFrame, 'TOPRIGHT')
listScrollBar:SetPoint('BOTTOMLEFT', listScrollFrame, 'BOTTOMRIGHT', 1, 0)
listScrollBar:SetScript('OnEnter', ListScrollFrame_OnEnter)
listScrollBar:SetScript('OnLeave', ListScrollFrame_OnLeave)

listScrollBar.ScrollBarTop:Hide()
listScrollBar.ScrollBarMiddle:Hide()
listScrollBar.ScrollBarBottom:Hide()
_G[listScrollBar:GetName() .. 'ScrollDownButton']:Hide()
_G[listScrollBar:GetName() .. 'ScrollUpButton']:Hide()

local scrollButton = _G[listScrollBar:GetName() .. 'ThumbTexture']
scrollButton:SetHeight(50)
scrollButton:SetWidth(5)
scrollButton:SetVertexColor(1, 1, 1, SCROLL_TEXTURE_ALPHA_MIN)
listScrollFrame.buttonHeight = 15

local contentFrame = CreateFrame('FRAME', 'AstralContentFrame', AstralKeyFrame)
contentFrame:SetSize(450, 390)
contentFrame:SetPoint('TOPLEFT', tabFrame, 'BOTTOMLEFT', 0, -30)

local function ListButton_OnClick(self)
	HybridScrollFrame_SetOffset(AstralKeyFrameListContainer, 0)
	AstralKeyFrameListContainer.scrollBar:SetValue(0)

	if self.sortMethod == AstralKeysSettings.frameOptions.sortMethod then
		AstralKeysSettings.frameOptions.orientation = 1 - AstralKeysSettings.frameOptions.orientation
	else
		AstralKeysSettings.frameOptions.orientation = 0
	end
	AstralKeysSettings.frameOptions.sortMethod = self.sortMethod
	e.SortTable(sortedTable[e.FrameListShown()], AstralKeysSettings.frameOptions.sortMethod)
	e.UpdateFrames()
end

local keyLevelButton = CreateFrame('BUTTON', '$parentKeyLevelButton', contentFrame)
keyLevelButton.sortMethod = 'key_level'
keyLevelButton:SetSize(40, 20)
keyLevelButton:SetNormalFontObject(InterUIBlack_Small)
keyLevelButton:GetNormalFontObject():SetJustifyH('CENTER')
keyLevelButton:SetText('LEVEL')
keyLevelButton:SetAlpha(0.5)
keyLevelButton:SetPoint('TOPLEFT', tabFrame, 'BOTTOMLEFT', 16, -5)
keyLevelButton:SetScript('OnClick', function(self) ListButton_OnClick(self) end)

local dungeonButton = CreateFrame('BUTTON', '$parentDungeonButton', contentFrame)
dungeonButton.sortMethod = 'dungeon_name'
dungeonButton:SetSize(155, 20)
dungeonButton:SetNormalFontObject(InterUIBlack_Small)
dungeonButton:GetNormalFontObject():SetJustifyH('LEFT')
dungeonButton:SetText('DUNGEON')
dungeonButton:SetAlpha(0.5)
dungeonButton:SetPoint('LEFT', keyLevelButton, 'RIGHT', 10, 0)
dungeonButton:SetScript('OnClick', function(self) ListButton_OnClick(self) end)

local characterButton = CreateFrame('BUTTON', '$parentCharacterButton', contentFrame)
characterButton.sortMethod = 'character_name'
characterButton:SetSize(153, 20)
characterButton:SetNormalFontObject(InterUIBlack_Small)
characterButton:GetNormalFontObject():SetJustifyH('LEFT')
characterButton:SetText('CHARACTER')
characterButton:SetAlpha(0.5)
characterButton:SetPoint('LEFT', dungeonButton, 'RIGHT')
characterButton:SetScript('OnClick', function(self) ListButton_OnClick(self) end)

local weeklyBestButton = CreateFrame('BUTTON', '$parentWeeklyBestButton', contentFrame)
weeklyBestButton.sortMethod = 'weekly_best_level'
weeklyBestButton:SetSize(50, 20)
weeklyBestButton:SetNormalFontObject(InterUIBlack_Small)
characterButton:GetNormalFontObject():SetJustifyH('CENTER')
weeklyBestButton:SetText('WKLY BEST')
weeklyBestButton:SetAlpha(0.5)
weeklyBestButton:SetPoint('LEFT', characterButton, 'RIGHT')
weeklyBestButton:SetScript('OnClick', function(self) ListButton_OnClick(self) end)

local weeklyButton = CreateFrame('BUTTON', '$parentWeeklyButton', contentFrame)
weeklyButton.sortMethod = 'weekly_cache'
weeklyButton:SetSize(30, 20)
weeklyButton:SetNormalFontObject(InterUIBlack_Small)
weeklyButton:SetText('10+')
weeklyButton:SetAlpha(0.5)
weeklyButton:SetPoint('LEFT', weeklyBestButton, 'RIGHT', 10, 0)
weeklyButton:SetScript('OnClick', function(self) ListButton_OnClick(self) end)

function AstralKeyFrame:OnUpdate(elapsed)
	self.updateDelay = self.updateDelay + elapsed

	if self.updateDelay < 0.75 then
		return
	end
	self:SetScript('OnUpdate', nil)
	self.updateDelay = 0
	e.UpdateFrames()
end

function AstralKeyFrame:ToggleLists()
	if AstralKeysSettings.options.friendSync then

	else
		if e.FrameListShown() == 'FRIENDS' then
			e.SetFrameListShown('GUILD')
			e.UpdateFrames()
			HybridScrollFrame_SetOffset(AstralKeyFrameListContainer, 0)
			AstralKeyFrameListContainer.scrollBar:SetValue(0)

		end
	end
end

AstralKeyFrame:SetScript('OnKeyDown', function(self, key)
	if key == 'ESCAPE' then
		self:SetPropagateKeyboardInput(false)
		AstralKeyFrame:Hide()
	end
	end)

AstralKeyFrame:SetScript('OnShow', function(self)
	offLineButton:SetChecked(AstralKeysSettings.options.showOffline)
	e.UpdateFrames()
	e.UpdateCharacterFrames()
	self:SetPropagateKeyboardInput(true)
	end)

AstralKeyFrame:SetScript('OnDragStart', function(self)
	self:StartMoving()
	end)

AstralKeyFrame:SetScript('OnDragStop', function(self)
	self:StopMovingOrSizing()
	end)

local init = false
local function InitializeFrame()
	init = true

	if AstralKeysSettings.frameOptions.viewMode == 1 then
		collapseButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\collapse.tga')
		AstralKeyFrame:SetWidth(FRAME_WIDTH_MINIMIZED)
		AstralKeyFrameCharacterFrame:Hide()
	else
		collapseButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\expand.tga')
	end

	offLineButton:SetChecked(AstralKeysSettings.options.showOffline)
	HybridScrollFrame_CreateButtons(AstralKeyFrameCharacterFrameCharacterContainer, 'AstralCharacterFrameTemplate', 0, 0, 'TOPLEFT', 'TOPLEFT', 0, -10)
	HybridScrollFrame_CreateButtons(AstralKeyFrameListContainer, 'AstralListFrameTemplate', 0, 0, 'TOPLEFT', 'TOPLEFT', 0, -10)

	e.UpdateAffixes()

	e.UpdateFrames()
	UpdateTabs()
end

function e.UpdateAffixes()
	if not init then return end
	AstralKeyFrameCharacterFrameAffix1:UpdateInfo(e.AffixOne())
	AstralKeyFrameCharacterFrameAffix2:UpdateInfo(e.AffixTwo())
	AstralKeyFrameCharacterFrameAffix3:UpdateInfo(e.AffixThree())
	AstralKeyFrameCharacterFrameAffix4:UpdateInfo(e.AffixFour())
end

function e.WipeFrames()
	wipe(sortedTable)
end

function e.UpdateLines()
	if not init then return end
	ListScrollFrame_Update()
end

function e.UpdateFrames()
	if not init or not AstralKeyFrame:IsShown() then return end

	e.UpdateTable(sortedTable)
	e.SortTable(sortedTable[e.FrameListShown()], AstralKeysSettings.frameOptions.sortMethod)

	e.UpdateLines()
end

function e.UpdateCharacterFrames()
	if not init then return end
	
	local id = e.GetCharacterID(e.Player())
	if id then
		local player = table.remove(AstralCharacters, id)
		table.sort(AstralCharacters, function(a,b) return a.unit < b.unit end)
		table.insert(AstralCharacters, 1, player)
		e.UpdateCharacterIDs()
	end
	CharacterScrollFrame_Update()
end

function e.AddUnitToTable(unit, class, faction, listType, mapID, level, weekly, btag)
	if not sortedTable[listType] then
		sortedTable[listType] = {}
	end
	local found = false
	for i = 1, #sortedTable[listType] do
		if sortedTable[listType][i].character_name == unit then
			sortedTable[listType][i].mapID = mapID
			sortedTable[listType][i].key_level = level
			sortedTable[listType][i].weekly_cache = weekly or 0
			found = true
			break
		end
	end

	if not found then
		sortedTable[listType][#sortedTable[listType] + 1] = {character_name = unit, character_class = class, mapID = mapID, key_level = level, weekly_cache = weekly or 0, faction = faction, btag = btag}
	end
end

function e.AstralToggle()
	if not init then InitializeFrame() end
	AstralKeyFrame:SetShown(not AstralKeyFrame:IsShown())
end

SLASH_ASTRALKEYS1 = '/astralkeys'
SLASH_ASTRALKEYS2 = '/ak'
SLASH_ASTRALKEYSV1 = '/akv'

local function handler(msg)
	e.AstralToggle()
end

SlashCmdList['ASTRALKEYS'] = handler;
SlashCmdList['ASTRALKEYSV'] = function(msg) e.CheckGuildVersion() end