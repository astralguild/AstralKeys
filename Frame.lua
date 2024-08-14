local _, addon = ...
local L = addon.L

-- MixIns
AstralKeysCharacterMixin = {}
AstralKeysListMixin = {}
-- Red color code
-- #C72329

-- Background
-- Left #000000 ALPHA 0.8
-- Right #212121 ALPHA 0.8
local COLOR_GRAY = 'ff9d9d9d'
local COLOR_BLUE_BNET = 'ff82c5ff'

-- Scroll bar texture alpha settings
local SCROLL_TEXTURE_ALPHA_MIN = 0.25
local SCROLL_TEXTURE_ALPHA_MAX = 0.6

local FRAME_WIDTH_MINIMIZED = 575
local CHARACTER_INFO_FRAME_SIZE = 275
local FRAME_WIDTH_EXPANDED = FRAME_WIDTH_MINIMIZED + CHARACTER_INFO_FRAME_SIZE

local FILTER_FIELDS = {}
FILTER_FIELDS['key_level'] = ''
FILTER_FIELDS['mapID'] = ''
FILTER_FIELDS['character_name'] = ''

local BACKDROPBUTTON = {
bgFile = nil,
edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16, edgeSize = 1,
insets = {left = 0, right = 0, top = 0, bottom = 0}
}
-- Used for filtering, sorting, and displaying units on lists
local sortTable = {}
sortTable.num_shown = 0

local selectedUnits = {}

local CreateNewTab, UpdateTabs, RemoveTab, tabFrame

local function ClearSelectedUnits()
	wipe(selectedUnits)
end

function AstralKeysCharacterMixin:UpdateUnit(characterID)
	local unit = addon.CharacterName(characterID)
	local realm = addon.CharacterRealm(characterID)
	local unitClass = addon.GetCharacterClass(characterID)

	local bestKey = addon.GetCharacterBestLevel(characterID)
	local currentMapID = addon.GetCharacterMapID(unit .. '-' .. realm)
	local currentKeyLevel = addon.GetCharacterKeyLevel(unit .. '-' .. realm)

	if addon.CharacterRealm(characterID) ~= addon.PlayerRealm() then
		unit = unit .. ' (*)'
	end
	self.nameString:SetText(WrapTextInColorCode(unit, select(4, GetClassColor(unitClass))))

	if bestKey ~= 0 then
		self.weeklyStringValue:SetText(bestKey)
	else
		self.weeklyStringValue:SetText(WrapTextInColorCode(L['CHARACTER_DUNGEON_NOT_RAN'], COLOR_GRAY))
	end

	if currentMapID then
		self.keyStringValue:SetFormattedText('%d %s', currentKeyLevel, addon.GetMapName(currentMapID, true))
	else
		self.keyStringValue:SetFormattedText('|c%s%s|r', COLOR_GRAY, L['CHARACTER_KEY_NOT_FOUND'])
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

function AstralKeysCharacterMixin:OnLoad()
	self.weeklyString:SetText(L['WEEKLY_BEST'])
	self.keyString:SetText(L['CURRENT_KEY'])
end

function AstralKeysListMixin:SetUnit(unit, class, mapID, keyLevel, weekly_best, faction, btag)
	self.unitID = addon.UnitID(unit)
	self.levelString:SetText(keyLevel)
	self.dungeonString:SetText(addon.GetMapName(mapID))
	self.dungeonString:SetWidth(200)
	if weekly_best and weekly_best > 1 then
		local color_code = addon.GetDifficultyColour(weekly_best)
		self.bestString:SetText(WrapTextInColorCode(weekly_best, color_code))
		self.bestString:SetWidth(self.bestString:GetUnboundedStringWidth() + 15)
	else
		self.bestString:SetText(nil)
	end

	if addon.FrameListShown() == 'GUILD' then
		self.nameString:SetText(WrapTextInColorCode(Ambiguate(unit, 'GUILD'), select(4, GetClassColor(class))))
	else
		if btag then
			if tonumber(faction) == addon.FACTION then
				self.nameString:SetText( string.format('%s (%s)', WrapTextInColorCode(btag:sub(1, btag:find('#') - 1), COLOR_BLUE_BNET), WrapTextInColorCode(unit:sub(1, unit:find('-') - 1), select(4, GetClassColor(class)))))
			else
				self.nameString:SetText( string.format('%s (%s)', WrapTextInColorCode(btag:sub(1, btag:find('#') - 1), COLOR_BLUE_BNET), WrapTextInColorCode(unit:sub(1, unit:find('-') - 1), 'ff9d9d9d')))
			end
		else
			self.nameString:SetText(WrapTextInColorCode(unit:sub(1, unit:find('-') - 1), select(4, GetClassColor(class))))
		end
	end
	
	if addon.IsUnitOnline(unit) then
		self:SetAlpha(1)
	else
		self:SetAlpha(0.4)
	end
end

function AstralKeysListMixin:OnClick(button)
	if not IsModifierKeyDown() and button == 'RightButton' then
		wipe(selectedUnits)
		if AstralMenuFrameUnit1.unit == self.unitID then
			ToggleFrame(AstralMenuFrameUnit1)
		else
			AstralMenuFrameReport1:Hide()
			AstralMenuFrameTabs1:Hide()
			AstralMenuFrameUnit1:ClearAllPoints()
			local uiScale = UIParent:GetScale()

			local cursorX, cursorY = GetCursorPosition()
			cursorX = cursorX/uiScale
			cursorY =  cursorY/uiScale
			xOffset, yOffset = 20, 0

			xOffset = cursorX + xOffset
			yOffset = cursorY + yOffset

			AstralMenuFrameUnit1:SetUnit(self.unitID)
			AstralMenuFrameUnit1:SetTitle(WrapTextInColorCode(addon.UnitName(self.unitID), select(4, GetClassColor(addon.UnitClass(self.unitID)))))
			AstralMenuFrameUnit1:SetPoint('TOPLEFT', UIParent, 'BOTTOMLEFT', xOffset, yOffset)
			AstralMenuFrameUnit1:Show()
			selectedUnits[addon.Unit(self.unitID)] = true
		end
	elseif IsModifierKeyDown() then
		self.Highlight:SetShown(not self.Highlight:IsShown())

		if self.Highlight:IsShown() then
			selectedUnits[addon.Unit(self.unitID)] = true
		else
			selectedUnits[addon.Unit(self.unitID)] = nil
		end
	end
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
local unitPopup = addon.CreateDropDownFrame('Unit', 1, UIParent)
local subUnitPopup = addon.CreateDropDownFrame('Unit', 2, UIParent)
subUnitPopup:SetTitle(L['LIST'])

unitPopup:SetScript('OnHide', function(self)
	wipe(selectedUnits)
	self:SetUnit(nil)
	local buttons = AstralKeyFrameListContainer.buttons
	for _, button in pairs(buttons) do
		button.Highlight:Hide()
	end
end)

local function Whisper_OnShow(self)
	if not addon.IsUnitOnline(addon.Unit(AstralMenuFrameUnit1.unit)) then
		self:SetText(WrapTextInColorCode(self:GetText(), 'ff9d9d9d'))
	else
		self:SetText(L['Whisper'])
	end
end

local function SendWhisper()
	if not addon.IsUnitOnline(addon.Unit(AstralMenuFrameUnit1.unit)) then return end
	if addon.UnitBTag(AstralMenuFrameUnit1.unit) then
		ChatFrame_SendBNetTell(addon.FriendPresName(addon.Unit(AstralMenuFrameUnit1.unit)))
	else
		ChatFrame_SendTell(addon.Unit(AstralMenuFrameUnit1.unit))
	end
end
unitPopup:AddButton(L['Whisper'], SendWhisper, Whisper_OnShow)

local function Invite_OnShow(self)
	local inviteType = GetDisplayedInviteType(addon.UnitGUID(addon.Unit(AstralMenuFrameUnit1.unit)))

	self:SetText(L[inviteType])
	self:GetParent():AdjustWidth()
	if not addon.IsUnitOnline(addon.Unit(AstralMenuFrameUnit1.unit)) then
		self:SetText(WrapTextInColorCode(self:GetText(), 'ff9d9d9d'))
	end

	self.inviteType = inviteType
end

local function InviteUnit(self)
	if not addon.IsUnitOnline(addon.Unit(AstralMenuFrameUnit1.unit)) then return end
	
	if addon.UnitBTag(AstralMenuFrameUnit1.unit) then
		if self.inviteType == 'INVITE' then
			BNInviteFriend(addon.GetFriendGaID(addon.Unit(AstralMenuFrameUnit1.unit)))
		elseif self.inviteType == 'REQUEST_INVITE' then
			BNRequestInviteFriend(addon.GetFriendGaID(addon.Unit(AstralMenuFrameUnit1.unit)))
		elseif self.inviteType == 'SUGGEST_INVITE' then
			BNInviteFriend(addon.GetFriendGaID(addon.Unit(AstralMenuFrameUnit1.unit)))
		end
	else
		if self.inviteType == 'INVITE' then
			InviteToGroup(addon.Unit(AstralMenuFrameUnit1.unit))
		elseif self.inviteType == 'REQUEST_INVITE' then
			RequestInviteFromUnit(addon.Unit(AstralMenuFrameUnit1.unit))
		elseif self.inviteType == 'SUGGEST_INVITE' then
			InviteToGroup(addon.Unit(AstralMenuFrameUnit1.unit))
		end
	end
end
unitPopup:AddButton(L['INVITE'],InviteUnit, Invite_OnShow)

local function CreateList_OnEnter(self)
	local text = self:GetText()

	if text == '' then return end

	local list = addon.CreateNewList(text)

	CreateNewTab(text, tabFrame)
	UpdateTabs()

	if list then
		for unit in pairs(selectedUnits) do
			addon.AddUnitToList(unit, text)
		end
	end

	self:Hide()
	self.buttonParent:Show()
	unitPopup:Hide()
	subUnitPopup:Hide()
	AstralMenuFrameTabs1:Hide()
end

local AstralKeyFrame = CreateFrame('FRAME', 'AstralKeyFrame', UIParent)
AstralKeyFrame:SetFrameStrata('DIALOG')
AstralKeyFrame:SetWidth(FRAME_WIDTH_EXPANDED)
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
AstralKeyFrame.background = AstralKeyFrame:CreateTexture(nil, 'BACKGROUND')
AstralKeyFrame.background:SetAllPoints(AstralKeyFrame)
AstralKeyFrame.background:SetColorTexture(0, 0, 0, 0.8)

local createListEditBox = CreateFrame('EditBox', nil, UIParent, "BackdropTemplate")
createListEditBox:SetFrameStrata('TOOLTIP')
createListEditBox:SetFrameLevel(25)
createListEditBox:Hide()
createListEditBox:SetSize(150, 20)
createListEditBox:SetFontObject(InterUIRegular_Normal)
createListEditBox:SetAutoFocus(true)
createListEditBox:SetMaxLetters(50)
createListEditBox:SetBackdrop(BACKDROPBUTTON)
createListEditBox:SetBackdropBorderColor(33/255, 33/255, 33/255, 0.8)

createListEditBox.description = createListEditBox:CreateFontString(nil, 'OVERLAY', 'InterUIMedium_Normal')
createListEditBox.description:SetHeight(20)
createListEditBox.description:SetJustifyH('LEFT')
createListEditBox.description:SetText(L['NEW_LIST_DESCRIPTION'])
createListEditBox.description:SetTextColor(99/255, 99/255, 99/255, 1)
createListEditBox.description:SetPoint('LEFT', createListEditBox, 'LEFT', 3, 0)
createListEditBox.description:Hide()

local createListOkayButton = CreateFrame('BUTTON', nil, createListEditBox, "BackdropTemplate")
createListOkayButton:SetNormalFontObject(InterUIMedium_Normal)
createListOkayButton:SetBackdrop(BACKDROPBUTTON)
createListOkayButton:SetBackdropBorderColor(33/255, 33/255, 33/255, 0.8)
createListOkayButton:SetHeight(20)
createListOkayButton:SetText(L['OKAY'])
createListOkayButton:GetFontString():SetTextColor(198/255, 198/255, 198/255, 1)
createListOkayButton:SetWidth(createListOkayButton:GetFontString():GetUnboundedStringWidth() + 5)
createListOkayButton:SetPoint('LEFT', createListEditBox, 'RIGHT', 5, 0)

createListOkayButton:SetScript('OnClick', function()
	CreateList_OnEnter(createListEditBox)
end)

createListEditBox:SetScript('OnTextChanged', function(self)
	if not self:GetText() or self:GetText() ~= '' then
		self.description:Hide()
	else
		self.description:Show()
	end
end)

createListEditBox:SetScript('OnShow', function(self)
	self:SetText('')
	self.description:Show()
	self.description:SetWidth(self.description:GetUnboundedStringWidth())
	self:SetWidth(self.description:GetUnboundedStringWidth() + 5)
end)

createListEditBox:SetScript('OnEscapePressed', function(self)
	self:Hide()
	self.buttonParent:Show()
	self.buttonParent:GetParent():AdjustWidth()
end)

local listHelperText = AstralKeyFrame:CreateFontString('$parentListHelperText', 'OVERLAY', 'InterUIBlack_ExtraLarge')
listHelperText:SetWidth(300)
listHelperText:SetJustifyH('CENTER')
listHelperText:SetPoint('TOP', AstralKeyFrameListContainer, 'TOP', 20, 100)
listHelperText:SetText(L['LIST_ADD_HELPER_TEXT'])
listHelperText:SetTextColor(1, 1, 1, 0.5)
listHelperText:Hide()

createListEditBox:SetScript('OnEnterPressed', CreateList_OnEnter)

local function CreateList(self)
	createListEditBox:Hide()
	createListEditBox.buttonParent = self
	createListEditBox:ClearAllPoints()
	createListEditBox:SetPoint('LEFT', self, 'LEFT')
	createListEditBox:Show()
	self:GetParent():AdjustWidth(math.max(createListEditBox:GetWidth(), createListEditBox.description:GetUnboundedStringWidth()) + createListOkayButton:GetWidth())
	self:Hide()
end

local function BuildLists(frame)
	frame:ClearButtons()
	for i = 1, #AstralLists do
		if AstralLists[i].name ~= 'GUILD' and AstralLists[i].name ~= 'FRIENDS' then
			frame:AddButton(AstralLists[i].name, function(self)
				for unit in pairs(selectedUnits) do
					local unit = unit
					local btag addon.UnitBTag(addon.UnitID(unit))
					local list = self:GetText()
					addon.AddUnitToList(unit, list, btag)
				end
			end, nil, nil, nil)
		end
	end
	local newListButton = frame:AddButton(L['CREATE_NEW_LIST'], CreateList)
	newListButton:SetScript('OnClick', function(self)
		CreateList(self)
	end)
end

unitPopup:AddButton(L['ADD_TO_LIST'], nil, nil, function() BuildLists(subUnitPopup) end, true, subUnitPopup)

local function RemoveUnitsFromList()
	if addon.FrameListShown() == 'GUILD' or addon.FrameListShown() == 'FRIENDS' then return end
	local list = addon.FrameListShown()
	for unit in pairs(selectedUnits) do
		addon.RemoveUnitFromList(unit, list)
	end
	addon.UpdateSortTable()
	addon.UpdateFrames()
end

local function RemoveUnit_OnShow(self)
	if addon.FrameListShown() == 'GUILD' or addon.FrameListShown() == 'FRIENDS' then
		self:SetText(WrapTextInColorCode(self:GetText(), 'ff9d9d9d'))
	else
		self:SetText(L['REMOVE_UNIT_FROM_LIST'])
	end
end

unitPopup:AddButton(L['REMOVE_UNIT_FROM_LIST'], RemoveUnitsFromList, RemoveUnit_OnShow)
unitPopup:AddButton(L['CANCEL'])

local AstralKeyToolTip = CreateFrame( "GameTooltip", "AstralKeyToolTip", AAFrame, "BackdropTemplate,GameTooltipTemplate" )
AstralKeyToolTip:SetOwner(AstralKeyFrame, "ANCHOR_CURSOR")
AstralKeyToolTip:SetScript('OnShow', function(self)
	self:SetBackdrop({
					bgFile = "Interface/Tooltips/UI-Tooltip-Background",
					edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16, edgeSize = 1,
					insets = {left = 0, right = 0, top = 0, bottom = 0}
					})
	self:SetBackdropColor(0, 0, 0, 1)
	self:SetBackdropBorderColor(0, 0, 0)
end)

-- Skin the tooltip.
for i = 1, 2 do
	_G['AstralKeyToolTipTextRight' .. i]:SetFontObject(InterUIBold_Tiny)
	_G['AstralKeyToolTipTextLeft' .. i]:SetFontObject(InterUIBold_Tiny)
end

local offLineButton = addon.CreateCheckBox(AstralKeyFrame, SHOW_OFFLINE_MEMBERS, 150)
offLineButton:SetNormalFontObject(InterUIRegular_Small)
offLineButton:SetPoint('BOTTOMRIGHT', AstralKeyFrame, 'BOTTOMRIGHT', -15, 10)
offLineButton:SetAlpha(0.5)
offLineButton:SetScript('OnClick', function(self)
	AstralKeysSettings.frame.show_offline.isEnabled = self:GetChecked()
	HybridScrollFrame_SetOffset(AstralKeyFrameListContainer, 0)
	addon.UpdateFrames()
end)

local menuBar = CreateFrame('FRAME', '$parentMenuBar', AstralKeyFrame)
menuBar:SetSize(50, 490)
menuBar:SetPoint('TOPLEFT', AstralKeyFrame, 'TOPLEFT')
menuBar.texture = menuBar:CreateTexture(nil, 'BACKGROUND')
menuBar.texture:SetAllPoints(menuBar)
menuBar.texture:SetColorTexture(33/255, 33/255, 33/255, 0.8)

local logo_Key = menuBar:CreateTexture(nil, 'ARTWORK')
logo_Key:SetSize(32, 32)
logo_Key:SetTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\key-white@2x')
logo_Key:SetVertexColor(0.8, 0.8, 0.8, 0.8)
logo_Key:SetPoint('TOPLEFT', menuBar, 'TOPLEFT', 10, -10)

local divider = menuBar:CreateTexture(nil, 'ARTWORK')
divider:SetSize(20, 1)
divider:SetColorTexture(.6, .6, .6, .8)
divider:SetPoint('TOP', logo_Key, 'BOTTOM', 0, -20)

-- Report Key(s) to party/guild popup menu
local reportFrame = addon.CreateDropDownFrame('Report', 1, UIParent)
reportFrame:SetTitle(L['REPORT_TO'])
reportFrame:AddButton(L['PARTY'], function() addon.AnnounceCharacterKeys('PARTY') end)
reportFrame:AddButton(L['GUILD'], function() addon.AnnounceCharacterKeys('GUILD') end)
reportFrame:AddButton(L['CANCEL'])

local reportButton = CreateFrame('BUTTON', '$parentReportButton', menuBar)
reportButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\baseline-volume_up-24px@2x')
reportButton:SetSize(20, 20)
reportButton:GetNormalTexture():SetVertexColor(.8, .8, .8, 0.8)
reportButton:SetPoint('TOP', divider, 'BOTTOM', 0, -20)
reportButton:SetScript('OnEnter', function(self)
	self:GetNormalTexture():SetVertexColor(126/255, 126/255, 126/255, 0.8)
	AstralKeyToolTip:SetOwner(self, 'ANCHOR_BOTTOMLEFT', 7, -2)
	AstralKeyToolTip:AddLine('Report', 1, 1, 1)
	AstralKeyToolTip:Show()
end)
reportButton:SetScript('OnLeave', function(self)
	self:GetNormalTexture():SetVertexColor(0.8, 0.8, 0.8, 0.8)
	AstralKeyToolTip:Hide()
end)
reportButton:SetScript('OnClick', function(self)
	AstralMenuFrameUnit1:Hide()
	AstralMenuFrameTabs1:Hide()
	AstralMenuFrameReport1:SetPoint('TOPLEFT', self, 'TOPRIGHT', 10, -3)
	AstralMenuFrameReport1:SetShown( not AstralMenuFrameReport1:IsShown())
	end)


local settingsButton = CreateFrame('BUTTON', '$parentSettingsButton', menuBar)
settingsButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\baseline-settings-20px@2x')
settingsButton:SetSize(24, 24)
settingsButton:GetNormalTexture():SetVertexColor(.8, .8, .8, 0.8)
settingsButton:SetPoint('TOP', reportButton, 'BOTTOM', 0, -20)
settingsButton:SetScript('OnEnter', function(self)
	self:GetNormalTexture():SetVertexColor(126/255, 126/255, 126/255, 0.8)
	AstralKeyToolTip:SetOwner(self, 'ANCHOR_BOTTOMLEFT', 7, -2)
	AstralKeyToolTip:AddLine('Settings', 1, 1, 1)
	AstralKeyToolTip:Show()
end)
settingsButton:SetScript('OnLeave', function(self)
	self:GetNormalTexture():SetVertexColor(0.8, 0.8, 0.8, 0.8)
	AstralKeyToolTip:Hide()
end)
settingsButton:SetScript('OnClick', function()
	AstralMenuFrameUnit1:Hide()
	AstralOptionsFrame:SetShown( not AstralOptionsFrame:IsShown())
	end)

C_AddOns.LoadAddOn("Blizzard_WeeklyRewards")
local greatVaultButton = CreateFrame('BUTTON', '$parentGreatVaultButton', menuBar)
greatVaultButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\great-vault@2x')
greatVaultButton:SetSize(24, 24)
greatVaultButton:GetNormalTexture():SetVertexColor(.8, .8, .8, 0.8)
greatVaultButton:SetPoint('TOP', settingsButton, 'BOTTOM', 0, -20)
greatVaultButton:SetScript('OnEnter', function(self)
	self:GetNormalTexture():SetVertexColor(126/255, 126/255, 126/255, 0.8)
	AstralKeyToolTip:SetOwner(self, 'ANCHOR_BOTTOMLEFT', 7, -2)
	AstralKeyToolTip:AddLine('Vault', 1, 1, 1)
	AstralKeyToolTip:Show()
end)
greatVaultButton:SetScript('OnLeave', function(self)
	self:GetNormalTexture():SetVertexColor(0.8, 0.8, 0.8, 0.8)
	AstralKeyToolTip:Hide()
end)
greatVaultButton:SetScript('OnClick', function()
	ToggleGreatVault()
end)
WeeklyRewardExpirationWarningDialog:Hide()

function ToggleGreatVault()
	if WeeklyRewardsFrame:IsShown() then
		WeeklyRewardsFrame:Hide()
	else WeeklyRewardsFrame:Show()
	end
end

local refreshButton = CreateFrame('BUTTON', '$parentRefreshButton', menuBar)
refreshButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\sync')
refreshButton:SetSize(24, 24)
refreshButton:GetNormalTexture():SetVertexColor(.6, .6, .6, .8)
refreshButton:SetPoint('TOP', greatVaultButton, 'BOTTOM', 0, -20)
refreshButton:SetScript('OnEnter', function(self)
	self:GetNormalTexture():SetVertexColor(126/255, 126/255, 126/255, 0.8)
	AstralKeyToolTip:SetOwner(self, 'ANCHOR_BOTTOMLEFT', 7, -2)
	AstralKeyToolTip:AddLine('Refresh', 1, 1, 1)
	AstralKeyToolTip:Show()
end)
refreshButton:SetScript('OnLeave', function(self)
	self:GetNormalTexture():SetVertexColor(.6, .6, .6, .8)
	AstralKeyToolTip:Hide()
end)
refreshButton:SetScript('OnClick', function()
	StaticPopup_Show('ASTRAL_KEYS_REFRESH_CONFIRM_DIALOG')
end)

local logo_Astral = CreateFrame('BUTTON', nil, menuBar)
logo_Astral:SetSize(32, 32)
logo_Astral:SetPoint('BOTTOMLEFT', menuBar, 'BOTTOMLEFT', 10, 10)
logo_Astral:SetAlpha(0.8)
logo_Astral:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\Logo@2x')

logo_Astral:SetScript('OnClick', function()
	astralGuildInfo:SetShown(not astralGuildInfo:IsShown())
	end)

logo_Astral:SetScript('OnEnter', function(self)
	self:SetAlpha(1)
	end)

logo_Astral:SetScript('OnLeave', function(self)
	self:SetAlpha(0.8)
	end)

local collapseButton = CreateFrame('BUTTON', '$parentCollapseButton', menuBar)
collapseButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\baseline-last_page-24px@2x')
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
local closeButton = CreateFrame('BUTTON', '$parentCloseButton', AstralKeyFrame)
closeButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\baseline-close-24px@2x')
closeButton:SetSize(12, 12)
closeButton:GetNormalTexture():SetVertexColor(.8, .8, .8, 0.8)
closeButton:SetScript('OnClick', function()
	AstralKeyFrame:Hide()
end)
closeButton:SetPoint('TOPRIGHT', AstralKeyFrame, 'TOPRIGHT', -10, -10)
closeButton:SetScript('OnEnter', function(self)
	self:GetNormalTexture():SetVertexColor(126/255, 126/255, 126/255, 0.8)
end)
closeButton:SetScript('OnLeave', function(self)
	self:GetNormalTexture():SetVertexColor(0.8, 0.8, 0.8, 0.8)
end)

-- Tab bar at the top, only show 5 and then start scrolling

-- MenuBar 50px
-- CENTER Frame CHARACTER_INFO_FRAME_SIZEpx
tabFrame = CreateFrame('FRAME', '$parentTabFrame', AstralKeyFrame)
tabFrame.offSet = 0
tabFrame:SetSize(460, 45)
tabFrame:SetPoint('TOPRIGHT', AstralKeyFrame, 'TOPRIGHT', -60, 10)
tabFrame.buttons = {}

local newTabButton = CreateFrame('BUTTON', '$parentNewListButton', tabFrame)
newTabButton:SetSize(17, 17)
newTabButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\baseline_add_white_18dp')
newTabButton:GetNormalTexture():SetVertexColor(0.8, 0.8, 0.8, 0.8)
newTabButton:SetPoint('RIGHT', tabFrame, 'RIGHT')

newTabButton:SetScript('OnClick', function(self)
	AstralMenuFrameUnit1:Hide()
	AstralMenuFrameReport1:Hide()
	AstralMenuFrameTabs1:SetPoint('TOPLEFT', self, 'TOPRIGHT', 10, -3)
	AstralMenuFrameTabs1:SetShown(not AstralMenuFrameTabs1:IsShown())
end)

-- Use arrows to display lists are on either side of curent offset
local tabFrameLeftButton = CreateFrame('BUTTON', '$parentLeftButton', tabFrame)
tabFrameLeftButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\baseline_keyboard_arrow_left_white_18dp')
tabFrameLeftButton:SetSize(12, 12)
tabFrameLeftButton:SetPoint('LEFT', tabFrame, 'LEFT', 10, -2)
tabFrameLeftButton:GetNormalTexture():SetVertexColor(0.8, 0.8, 0.8, 0.8)
tabFrameLeftButton:SetScript('OnClick', function(self)
	if self:GetParent().offSet < 1 then
		return
	else
		self:GetParent().offSet = self:GetParent().offSet - 1
		UpdateTabs()
	end
end)

local tabFrameRightButton = CreateFrame('BUTTON', '$parentLeftButton', tabFrame)
tabFrameRightButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\baseline_keyboard_arrow_right_white_24dp')
tabFrameRightButton:SetSize(12, 12)
tabFrameRightButton:SetPoint('RIGHT', tabFrame, 'RIGHT', 3, -2)
tabFrameRightButton:GetNormalTexture():SetVertexColor(0.8, 0.8, 0.8, 0.8)
tabFrameRightButton:SetScript('OnClick', function(self)
	if self:GetParent().buttons[#self:GetParent().buttons]:IsShown() then
	--if self:GetParent().offSet >= #self:GetParent().buttons then
		return
	else
		self:GetParent().offSet = self:GetParent().offSet + 1
		UpdateTabs()
	end
end)

function UpdateTabs()
	local buttons = AstralKeyFrameTabFrame.buttons
	local offSet = AstralKeyFrameTabFrame.offSet

	local maxPossibleWidth = 450 - 15 - 20 -- Tab frame, close button, new tab button width
	local usedWidth = 0 -- initialize at 10 for padding on the left
	local buttonsUsed = 0

	for i = 1, #buttons do
		buttons[i]:ClearAllPoints()
		buttons[i]:Hide()
	end

	for i = 1 + offSet, #buttons do
		if addon.FrameListShown() == buttons[i].listName then
			buttons[i].underline:Show()
			buttons[i]:SetAlpha(1)
		else
			buttons[i].underline:Hide()
			buttons[i]:SetAlpha(0.5)
		end
		if i == 1 + offSet then
			usedWidth = usedWidth + buttons[i]:GetWidth() + 10 -- Padding between buttons
			buttons[i]:SetPoint('TOPLEFT', AstralKeyFrameTabFrame, 'TOPLEFT', 25, -17)
			buttons[i]:Show()
		else
			usedWidth = usedWidth + buttons[i]:GetWidth() + 10 -- Padding between buttons
			if usedWidth <= maxPossibleWidth then
				buttons[i]:SetPoint('LEFT', buttons[i-1], 'RIGHT', 10, 0)
				buttons[i]:Show()
				buttonsUsed = i
			end
		end
	end
	newTabButton:ClearAllPoints()
	newTabButton:SetPoint('LEFT', buttons[buttonsUsed], 'RIGHT', 5, 0)
end

local function Tab_OnClick(self, button)
	local next = next
	if button == 'LeftButton' then
		C_FriendList.ShowFriends()
	    if addon.FrameListShown() ~= self.listName then
	    	ClearSelectedUnits()
				addon.SetFrameListShown(self.listName)
				HybridScrollFrame_SetOffset(AstralKeyFrameListContainer, 0)
				UpdateTabs()
				addon.UpdateSortTable()
				addon.UpdateFrames()
				AstralKeyFrameListContainer.scrollBar:SetValue(0)
				-- enable if GetListCount is fixed
				--[[ if (self.listName ~= "GUILD" and self.listName ~= "FRIENDS") and addon.GetListCount(self.listName) == 0 then
					listHelperText:Show()
				else
					listHelperText:Hide()
				end ]]
	    end
	end
end

function CreateNewTab(name, parent, ...)
	if not name or type(name) ~= 'string' then
		error('CreateNewTab(name, parent, ...) name: string expected, received ' .. type(name))
	end
	local buttons = parent.buttons
	local tab = CreateFrame('BUTTON', '$parentTab' .. name, parent)
	tab:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
	tab.listName = name
	tab:SetNormalFontObject(InterUIBlack_Small)
	tab:SetText(L[name])
	tab:GetFontString():SetJustifyH('CENTER')
	tab:SetWidth(50)
	tab:SetHeight(15)
	tab:SetScript('OnClick', function(self, button) Tab_OnClick(self, button) end)

	local textWidth = tab:GetFontString():GetUnboundedStringWidth()
	tab:SetWidth(textWidth + 10)
	tab.underline = tab:CreateTexture(nil, 'ARTWORK')
	tab.underline:SetSize(textWidth, 2)
	tab.underline:SetColorTexture(214/255, 38/255, 38/255)
	tab.underline:SetPoint('BOTTOM', tab, 'BOTTOM', 0, -1)

	tab.underline:Hide()

	table.insert(buttons, tab)
end

function RemoveTab(name)
	if not name or type(name) ~= 'string' then
		error('RemoveTab(name) name: string expected, received ' .. type(name))
	end
	local buttons = AstralKeyFrameTabFrame.buttons

	local targetName = 'AstralKeyFrameTabFrameTab' .. name

	for i = 1, #buttons do
		if buttons[i]:GetName() == targetName then
			local btn = table.remove(buttons, i)
			btn:Hide()
			btn:SetParent(nil)
			break
		end
	end
end

local tabPopup = addon.CreateDropDownFrame('Tabs', 1, UIParent)
tabPopup:SetTitle(L['ADD_REMOVE_LIST'])
local subTabPopup = addon.CreateDropDownFrame('Tabs', 2, UIParent)
subTabPopup:SetTitle(L['DELETE_LIST'])
local tabFrameNewListButton = tabPopup:AddButton(L['CREATE_NEW_LIST'], CreateList)

tabFrameNewListButton:SetScript('OnClick', CreateList)

local function RemoveList(frame)
	frame:ClearButtons()
	for i = 1, #AstralLists do
		if AstralLists[i].name ~= 'GUILD' and AstralLists[i].name ~= 'FRIENDS' then
			frame:AddButton(AstralLists[i].name, function(self)
				addon.DeleteList(self:GetText())
				RemoveTab(self:GetText(), tabFrame)
				UpdateTabs()
			end)
		end
	end
end
tabPopup:AddButton(L['DELETE_LIST'], nil, nil, function () RemoveList(subTabPopup) end, true, subTabPopup)

-- CENTER panel construction, Affixe info, character info, guild/version string
local characterFrame = CreateFrame('FRAME', '$parentCharacterFrame', AstralKeyFrame)
characterFrame:SetSize(CHARACTER_INFO_FRAME_SIZE, 490)
characterFrame:SetPoint('TOPLEFT', AstralKeyFrame, 'TOPLEFT', 51, 0)

characterFrame.collapse = characterFrame:CreateAnimationGroup()
local characterCollapse = characterFrame.collapse:CreateAnimation('Alpha')
characterCollapse:SetFromAlpha(1)
characterCollapse:SetToAlpha(0)
characterCollapse:SetDuration(.12)
characterCollapse:SetSmoothing('IN_OUT')

characterCollapse:SetScript('OnFinished', function(self)
	self:GetRegionParent():Hide()
	end)

characterCollapse:SetScript('OnUpdate', function(self)
	self:GetRegionParent():SetAlpha(self:GetSmoothProgress()/2)
	local left, bottom, width = AstralKeyFrame:GetRect()
	local newWidth = FRAME_WIDTH_EXPANDED - (self:GetProgress() * CHARACTER_INFO_FRAME_SIZE) -- CHARACTER_INFO_FRAME_SIZE:: Character Frame Width
	AstralKeyFrame:ClearAllPoints()
	AstralKeyFrame:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOMLEFT', left + width - newWidth, bottom)
	AstralKeyFrame:SetWidth(newWidth)
	end)

characterFrame.expand = characterFrame:CreateAnimationGroup()
local characterExpand = characterFrame.expand:CreateAnimation('Alpha')

characterExpand:SetFromAlpha(0)
characterExpand:SetToAlpha(1)
characterExpand:SetDuration(.12)
characterExpand:SetSmoothing('IN_OUT')

characterExpand:SetScript('OnPlay', function(self)
	self:GetRegionParent():Show()
	end)

characterExpand:SetScript('OnUpdate', function(self)
		local left, bottom, width = AstralKeyFrame:GetRect()
		local newWidth = FRAME_WIDTH_MINIMIZED + (self:GetProgress() * CHARACTER_INFO_FRAME_SIZE) -- CHARACTER_INFO_FRAME_SIZE:: Character Frame Width
		AstralKeyFrame:ClearAllPoints()
		AstralKeyFrame:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOMLEFT', left + width - newWidth, bottom)
		AstralKeyFrame:SetWidth(newWidth)
	end)

collapseButton:SetScript('OnClick', function(self)
	if not AstralKeysSettings.frame.isCollapsed.isEnabled then
		if AstralKeyFrameCharacterFrame.expand:IsPlaying() then
			AstralKeyFrameCharacterFrame.expand:Stop()
		end
		AstralKeyFrameCharacterFrame.collapse:Play()
		AstralKeysSettings.frame.isCollapsed.isEnabled = true
		self:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\baseline-first_page-24px@2x')
	else
		if AstralKeyFrameCharacterFrame.collapse:IsPlaying() then
			AstralKeyFrameCharacterFrame.collapse:Stop()
		end
		AstralKeyFrameCharacterFrame.expand:Play()
		AstralKeysSettings.frame.isCollapsed.isEnabled = false
		self:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\baseline-last_page-24px@2x')
	end
	end)

local affixTitle = characterFrame:CreateFontString('$parentAffixTitle', 'OVERLAY', 'InterUIBlack_Small')
affixTitle:SetPoint('TOPLEFT', characterFrame, 'TOPLEFT', 20, -20)
affixTitle:SetText(L['AFFIXES'])

-- Affix Frames
-----------------------------------------------------

do
	for i = 1, 4 do
		local frame = CreateFrame('FRAME', '$parentAffix' .. i, characterFrame)
		frame.id = i

		frame.affixID = 0
		frame:SetSize(32, 32)
		frame.icon = frame:CreateTexture(nil, 'ARTWORK')


		if i == 1 then
			frame:SetPoint('TOPLEFT', affixTitle, 'BOTTOMLEFT', 0, -15)
		else
			frame:SetPoint('LEFT', '$parentAffix' .. (i -1), 'RIGHT', 15, 0)
		end
		frame.icon:SetAllPoints(frame)

		function frame:UpdateInfo(affixID)
			if affixID and affixID ~= 0 then
				self.affixID = affixID
				local _, _, texture = C_ChallengeMode.GetAffixInfo(affixID)
				self.icon:SetTexture(texture)
			end
		end

		frame:SetScript('OnEnter', function(self)
			if not self.affixID then return end
			AstralKeyToolTip:SetOwner(self, 'ANCHOR_BOTTOMLEFT', 7, -2)
			AstralKeyToolTip:AddLine(addon.AffixName(self.affixID), 1, 1, 1)
			if AstralKeysSettings.general.expanded_tooltip.isEnabled then
				AstralKeyToolTip:AddLine(addon.AffixDescription(self.affixID), 1, 1, 1, true)
			end
			AstralKeyToolTip:Show()
			end)
		frame:SetScript('OnLeave', function()
			AstralKeyToolTip:Hide()
		end)
	end
end


-- Affix frame for coming week's affixes
----------------------------------------------------
AstralKeyFrame.affixesExpanded = false
local affixFrame = CreateFrame('FRAME', '$parentAffixFrame', AstralKeyFrameCharacterFrame)
affixFrame:SetSize(185, 15)
affixFrame:SetPoint('TOPLEFT', AstralKeyFrameCharacterFrameAffix1, 'BOTTOMLEFT', 0 , -10)

local affixExpandButton = CreateFrame('BUTTON', '$parentAffixExpandButton', characterFrame)
affixExpandButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\baseline_keyboard_arrow_down_white_18dp')
affixExpandButton:SetSize(24, 14)
affixExpandButton:GetNormalTexture():SetVertexColor(0.8, 0.8, 0.8, 0.8)
affixExpandButton:SetPoint('BOTTOM', affixFrame, 'BOTTOM', 0, 0)

do
	for i = 1, 8 do
		local frame = CreateFrame('FRAME', '$parentAffix' .. i, affixFrame)
		frame.id = (i % 4) == 0 and 4 or i % 4
		if i < 5 then
			frame.weekOffset = 1
		else
			frame.weekOffset = 2
		end

		frame.affixID = 0
		frame:SetSize(32, 32)
		frame.texture = frame:CreateTexture(nil, 'ARTWORK')
		
		if i == 1 then
			frame:SetPoint('TOPLEFT', affixFrame, 'TOPLEFT', 0, 0)
		elseif i == 5 then
			frame:SetPoint('TOPLEFT', '$parentAffix1', 'BOTTOMLEFT', 0, -15)
		else
			frame:SetPoint('LEFT', '$parentAffix' .. (i -1), 'RIGHT', 15, 0)
		end
		frame.texture:SetPoint('TOPLEFT', frame, 'TOPLEFT')
		frame.texture:SetAllPoints(frame)

		function frame:UpdateInfo()
			self.affixID = addon.GetAffixID(self.id, self.weekOffset)
			if self.affixID and self.affixID ~= 0 then
				local _, _, texture = C_ChallengeMode.GetAffixInfo(self.affixID)
				self.texture:SetTexture(texture)
			end
		end

		frame:SetScript('OnEnter', function(self)
			if not self.affixID then return end
			AstralKeyToolTip:SetOwner(self, 'ANCHOR_BOTTOMLEFT', 7, -2)			
			AstralKeyToolTip:AddLine(addon.AffixName(self.affixID), 1, 1, 1)
			if AstralKeysSettings.general.expanded_tooltip.isEnabled then
				AstralKeyToolTip:AddLine(addon.AffixDescription(self.affixID), 1, 1, 1, true)
			end
			AstralKeyToolTip:Show()
			end)
		frame:SetScript('OnLeave', function()
			AstralKeyToolTip:Hide()
		end)

		frame:Hide()
	end
end

affixFrame.expand = affixFrame:CreateAnimationGroup()

local affixExpand = affixFrame.expand:CreateAnimation('Alpha')
affixExpand:SetFromAlpha(0)
affixExpand:SetToAlpha(1)
affixExpand:SetDuration(.12)
affixExpand:SetSmoothing('IN_OUT')

affixExpand:SetScript('OnPlay', function()
	affixExpandButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\baseline_keyboard_arrow_up_white_18dp')
	affixExpandButton:GetNormalTexture():SetVertexColor(0.8, 0.8, 0.8, 0.8)
	AstralKeyFrame.affixesExpanded = true
	end)

affixExpand:SetScript('OnUpdate', function(self)
	local progress = self:GetProgress()

	AstralKeyFrameCharacterFrameAffixFrame:SetHeight((progress * 85) + 15)
	AstralKeyFrameCharacterFrameCharacterContainer:SetHeight(((1-progress) * 85) + 230)
	AstralKeyFrameCharacterFrameCharacterTitle:SetPoint('TOPLEFT', affixFrame, 'BOTTOMLEFT', 0, -10)
	affixExpandButton:SetPoint('BOTTOM', affixFrame, 'BOTTOM', 0, 0)
	end)

local affixIconsExpand = affixFrame.expand:CreateAnimation('Alpha')
affixIconsExpand:SetDuration(0.08)
affixIconsExpand:SetFromAlpha(0)
affixIconsExpand:SetToAlpha(1)
affixIconsExpand:SetSmoothing('IN_OUT')
affixIconsExpand:SetStartDelay(0.1)

affixIconsExpand:SetScript('OnPlay', function()
	for i = 1, 8 do
		_G['AstralKeyFrameCharacterFrameAffixFrameAffix' .. i]:Show()
	end
	end)

affixIconsExpand:SetScript('OnUpdate', function(self)
	local alpha = self:GetSmoothProgress()
	for i = 1, 8 do
		_G['AstralKeyFrameCharacterFrameAffixFrameAffix' .. i]:SetAlpha(alpha)
	end
	end)

affixIconsExpand:SetScript('OnFinished', function()
	end)

affixFrame.collapse = affixFrame:CreateAnimationGroup()

local affixIconsCollapse = affixFrame.collapse:CreateAnimation('Alpha')
affixIconsCollapse:SetDuration(0.08)
affixIconsCollapse:SetFromAlpha(1)
affixIconsCollapse:SetToAlpha(0)
affixIconsCollapse:SetSmoothing('IN_OUT')
affixIconsCollapse:SetStartDelay(0.1)

affixIconsCollapse:SetScript('OnFinished', function()
	for i = 1, 8 do
		_G['AstralKeyFrameCharacterFrameAffixFrameAffix' .. i]:Hide()
	end
	end)

affixIconsCollapse:SetScript('OnUpdate', function(self)
	local alpha = self:GetSmoothProgress()
	for i = 1, 8 do
		_G['AstralKeyFrameCharacterFrameAffixFrameAffix' .. i]:SetAlpha(alpha)
	end
	end)

local affixCollapse = affixFrame.collapse:CreateAnimation('Alpha')
affixCollapse:SetFromAlpha(1)
affixCollapse:SetToAlpha(0)
affixCollapse:SetDuration(.12)
affixCollapse:SetSmoothing('IN_OUT')

affixCollapse:SetScript('OnPlay', function()
	affixExpandButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\baseline_keyboard_arrow_down_white_18dp')
	affixExpandButton:GetNormalTexture():SetVertexColor(0.8, 0.8, 0.8, 0.8)
	AstralKeyFrame.affixesExpanded = false
	end)

affixCollapse:SetScript('OnUpdate', function(self)
	local progress = self:GetSmoothProgress()

	AstralKeyFrameCharacterFrameAffixFrame:SetHeight(((1-progress) * 85) + 15)
	AstralKeyFrameCharacterFrameCharacterContainer:SetHeight((progress * 85) + 230)
	AstralKeyFrameCharacterFrameCharacterTitle:SetPoint('TOPLEFT', affixFrame, 'BOTTOMLEFT', 0, -10)
	affixExpandButton:SetPoint('BOTTOM', affixFrame, 'BOTTOM', 0, 0)
	end)

affixExpandButton:SetScript('OnClick', function()
	if AstralKeyFrame.affixesExpanded then
		affixFrame.collapse:Play()		
	else
		affixFrame.expand:Play()
	end
	end)

-- Character Frames
----------------------------------------------------------------
local characterTitle = characterFrame:CreateFontString('$parentCharacterTitle', 'OVERLAY', 'InterUIBlack_Small')
characterTitle:SetPoint('TOPLEFT', affixFrame, 'BOTTOMLEFT', 0, -10)
characterTitle:SetText(L['CHARACTERS'])

local guildVersionString = CreateFrame('BUTTON', nil, characterFrame)
guildVersionString:SetNormalFontObject(InterUIRegular_Small)
guildVersionString:SetSize(110, 20)
guildVersionString:SetPoint('BOTTOM', characterFrame, 'BOTTOM', 0, 10)
guildVersionString:SetAlpha(0.2)

guildVersionString:SetScript('OnEnter', function(self)
	self:SetAlpha(.8)
	end)
guildVersionString:SetScript('OnLeave', function(self)
	self:SetAlpha(0.2)
	end)

guildVersionString:SetScript('OnClick', function()
	astralGuildInfo:SetShown(not astralGuildInfo:IsShown())
end)

local astralGuildInfo = CreateFrame('FRAME', 'astralGuildInfo', AstralKeyFrame, "BackdropTemplate")
astralGuildInfo:Hide()
astralGuildInfo:SetFrameLevel(8)
astralGuildInfo:SetSize(200, 100)
astralGuildInfo:SetBackdrop(BACKDROPBUTTON)
astralGuildInfo:EnableKeyboard(true)
astralGuildInfo:SetBackdropBorderColor(.2, .2, .2, 1)
astralGuildInfo:SetPoint('BOTTOM', UIParent, 'TOP', 0, -300)

astralGuildInfo.text = astralGuildInfo:CreateFontString(nil, 'OVERLAY', 'InterUIRegular_Normal')
astralGuildInfo.text:SetPoint('TOP', astralGuildInfo,'TOP', 0, -10)
astralGuildInfo.text:SetText('Visit Astral at')

astralGuildInfo.editBox = CreateFrame('EditBox', nil, astralGuildInfo, "BackdropTemplate")
astralGuildInfo.editBox:SetSize(180, 20)
astralGuildInfo.editBox:SetPoint('TOP', astralGuildInfo.text, 'BOTTOM', 0, -10)

astralGuildInfo.tex = astralGuildInfo:CreateTexture('ARTWORK')
astralGuildInfo.tex:SetSize(198, 98)
astralGuildInfo.tex:SetPoint('TOPLEFT', astralGuildInfo, 'TOPLEFT', 1, -1)
astralGuildInfo.tex:SetColorTexture(0, 0, 0)

astralGuildInfo.editBox:SetBackdrop(BACKDROPBUTTON)
astralGuildInfo.editBox:SetBackdropBorderColor(.2, .2, .2, 1)
astralGuildInfo.editBox:SetFontObject(InterUIRegular_Normal)
astralGuildInfo.editBox:SetText('www.astralguild.com')
astralGuildInfo.editBox:HighlightText()
astralGuildInfo.editBox:SetScript('OnChar', function(self)
	self:SetText('www.astralguild.com')
	self:HighlightText()
end)
astralGuildInfo.editBox:SetScript("OnEscapePressed", function()
	astralGuildInfo:Hide()
end)
astralGuildInfo.editBox:SetScript('OnEditFocusLost', function(self)
	self:SetText('www.astralguild.com')
	self:HighlightText()
	end)
local button = CreateFrame('BUTTON', nil, astralGuildInfo, "BackdropTemplate")
button:SetSize(40, 20)
button:SetNormalFontObject(InterUIRegular_Normal)
button:SetText('Close')
button:SetBackdrop(BACKDROPBUTTON)
button:SetBackdropBorderColor(.2, .2, .2, 1)
button:SetPoint('BOTTOM', astralGuildInfo, 'BOTTOM', 0, 10)

button:SetScript('OnClick', function()
	astralGuildInfo:Hide() end)

addon.AddEscHandler(astralGuildInfo)

characterFrame.background = characterFrame:CreateTexture(nil, 'BACKGROUND')
characterFrame.background:SetColorTexture(33/255, 33/255, 33/255, 0.8)
characterFrame.background:SetAllPoints(characterFrame)

function CharacterScrollFrame_Update()
	local scrollFrame = AstralKeyFrameCharacterFrameCharacterContainer
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local buttons = scrollFrame.buttons
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
characterScrollFrame:SetSize(CHARACTER_INFO_FRAME_SIZE - 40, 315)
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
scrollButton:SetWidth(8)
scrollButton:SetColorTexture(204/255, 204/255, 204/255, SCROLL_TEXTURE_ALPHA_MAX)

characterScrollFrame.buttonHeight = 45
characterScrollFrame.update = CharacterScrollFrame_Update

-- Key List Frames
----------------------------------------------------------------
-- self, unit, unitClass, mapID, keyLevel, cache, faction, btag
function ListScrollFrame_Update()
	local scrollFrame = AstralKeyFrameListContainer
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local buttons = scrollFrame.buttons
	
	local height = scrollFrame.buttonHeight
	local usedHeight = 0
	local lastIndex = 1

	local selectCount = 0
	for _ in pairs(selectedUnits) do
		selectCount = selectCount + 1
	end

	for i = 1, math.min(sortTable.num_shown, #buttons) do
		for j = lastIndex, #sortTable do
			if sortTable[j+offset] and sortTable[j+offset].isShown then
				usedHeight = usedHeight + height
				lastIndex = j + 1
				buttons[i]:SetUnit(sortTable[j+offset].character_name, sortTable[j+offset].character_class, sortTable[j+offset].dungeon_id, sortTable[j+offset].key_level, sortTable[j+offset].weekly_best, sortTable[j+offset]['faction'], sortTable[j+offset]['btag'])
				buttons[i]:Show()
				if selectCount > 1 and selectedUnits[sortTable[j+offset].character_name] then
					buttons[i].Highlight:Show()
				else
					buttons[i].Highlight:Hide()
				end
				break
			end
		end
	end

	for i = math.min(sortTable.num_shown, #buttons) + 1, #buttons do
		buttons[i]:Hide()
	end
	AstralKeyFrameListContainer.stepSize = (sortTable.num_shown / #buttons) * height
	HybridScrollFrame_Update(AstralKeyFrameListContainer, height * sortTable.num_shown, usedHeight)
end

local function ListScrollFrame_OnEnter()
	AstralKeyFrameListContainerScrollBarThumbTexture:SetAlpha(SCROLL_TEXTURE_ALPHA_MAX)
end

local function ListScrollFrame_OnLeave()
	AstralKeyFrameListContainerScrollBarThumbTexture:SetAlpha(SCROLL_TEXTURE_ALPHA_MIN)
end

local listScrollFrame = CreateFrame('ScrollFrame', '$parentListContainer', AstralKeyFrame, 'HybridScrollFrameTemplate')
listScrollFrame:SetSize(485, 375)
listScrollFrame:SetPoint('TOPLEFT', tabFrame, 'BOTTOMLEFT', 10, -35)
listScrollFrame.update = ListScrollFrame_Update
listScrollFrame:SetScript('OnEnter',  ListScrollFrame_OnEnter)
listScrollFrame:SetScript('OnLeave', ListScrollFrame_OnLeave)

local listScrollBar = CreateFrame('Slider', '$parentScrollBar', listScrollFrame, 'HybridScrollBarTemplate')
listScrollBar:SetWidth(10)
listScrollBar:SetPoint('TOPLEFT', listScrollFrame, 'TOPRIGHT')
listScrollBar:SetPoint('BOTTOMLEFT', listScrollFrame, 'BOTTOMRIGHT', -10, 0)
listScrollBar:SetScript('OnEnter', ListScrollFrame_OnEnter)
listScrollBar:SetScript('OnLeave', ListScrollFrame_OnLeave)

listScrollBar.ScrollBarTop:Hide()
listScrollBar.ScrollBarMiddle:Hide()
listScrollBar.ScrollBarBottom:Hide()
_G[listScrollBar:GetName() .. 'ScrollDownButton']:Hide()
_G[listScrollBar:GetName() .. 'ScrollUpButton']:Hide()

local listScrollButton = _G[listScrollBar:GetName() .. 'ThumbTexture']
listScrollButton:SetHeight(50)
listScrollButton:SetWidth(8)
listScrollButton:SetColorTexture(204/255, 204/255, 204/255, SCROLL_TEXTURE_ALPHA_MIN)
listScrollButton:SetAlpha(SCROLL_TEXTURE_ALPHA_MIN)
listScrollFrame.buttonHeight = 15

local contentFrame = CreateFrame('FRAME', 'AstralContentFrame', AstralKeyFrame)
contentFrame:SetSize(485, 390)
contentFrame:SetPoint('TOPLEFT', tabFrame, 'BOTTOMLEFT', 0, -30)

local function ListButton_OnClick(self)
	HybridScrollFrame_SetOffset(AstralKeyFrameListContainer, 0)
	AstralKeyFrameListContainer.scrollBar:SetValue(0)

	if self.sortMethod == AstralKeysSettings.frame.sorth_method then
		AstralKeysSettings.frame.orientation = 1 - AstralKeysSettings.frame.orientation
	else
		AstralKeysSettings.frame.orientation = 0
	end
	AstralKeysSettings.frame.sorth_method = self.sortMethod
	addon.SortTable(sortTable, AstralKeysSettings.frame.sorth_method)
	addon.UpdateFrames()
end

local keyLevelButton = CreateFrame('BUTTON', '$parentKeyLevelButton', contentFrame)
keyLevelButton.sortMethod = 'key_level'
keyLevelButton:SetSize(40, 20)
keyLevelButton:SetNormalFontObject(InterUIBlack_Small)
keyLevelButton:GetNormalFontObject():SetJustifyH('CENTER')
keyLevelButton:SetText(L['LEVEL'])
keyLevelButton:SetAlpha(0.5)
keyLevelButton:SetPoint('TOPLEFT', tabFrame, 'BOTTOMLEFT', 16, -5)
keyLevelButton:SetScript('OnClick', function(self) ListButton_OnClick(self) end)

local keyLevelSearchButton = CreateFrame('BUTTON', '$parentKeyLevelSearch', contentFrame)
keyLevelSearchButton:SetSize(14, 14)
keyLevelSearchButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\baseline_search_white_18dp')
keyLevelSearchButton:SetPoint('LEFT', keyLevelButton, 'RIGHT', -5, 0)
keyLevelSearchButton:SetAlpha(0)
keyLevelSearchButton:SetFrameLevel(keyLevelButton:GetFrameLevel() + 1)

local keyLevelSearchCloseButton = CreateFrame('BUTTON', '$parentKeyLevelSearchCloseButton', contentFrame)
keyLevelSearchCloseButton.filterMethod = 'key_level'
keyLevelSearchCloseButton:SetSize(8, 8)
keyLevelSearchCloseButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\baseline-close-24px@2x')
keyLevelSearchCloseButton:GetNormalTexture():SetVertexColor(0.8, 0.8, 0.8, 0.8)
keyLevelSearchCloseButton:SetPoint('LEFT', keyLevelButton, 'RIGHT', -5, 1)
keyLevelSearchCloseButton:SetFrameLevel(keyLevelButton:GetFrameLevel() + 1)
keyLevelSearchCloseButton:Hide()

local keyLevelSearchTextString = contentFrame:CreateFontString(nil, 'OVERLAY', 'InterUIBlack_Small')
keyLevelSearchTextString:SetJustifyH('LEFT')
keyLevelSearchTextString:SetPoint('LEFT', keyLevelButton, 'LEFT')
keyLevelSearchTextString:SetTextColor(1, 1, 1, 0.5)
keyLevelSearchTextString:Hide()

local keyLevelSearchTextInput = CreateFrame('EditBox', '%parentKeyLevelSearchInput', contentFrame)
keyLevelSearchTextInput.filterMethod = 'key_level'
keyLevelSearchTextInput:SetSize(30, 20)
keyLevelSearchTextInput:SetPoint('RIGHT', keyLevelSearchButton, 'LEFT')
keyLevelSearchTextInput:SetFontObject(InterUIBlack_Small)
keyLevelSearchTextInput:SetJustifyH('LEFT')
keyLevelSearchTextInput:SetTextColor(1, 1, 1, 0.5)
keyLevelSearchTextInput:SetAutoFocus(false)
keyLevelSearchTextInput:EnableKeyboard(true)
keyLevelSearchTextInput:Hide()

keyLevelSearchTextInput:SetScript('OnEscapePressed', function(self)
	FILTER_FIELDS[self.filterMethod] = ''
	addon.UpdateFrames()
	self:ClearFocus()
	keyLevelSearchTextString:Hide()
	keyLevelSearchTextInput:Hide()
	keyLevelButton:Show()
	keyLevelSearchCloseButton:Hide()
	keyLevelSearchButton:Show()
	end)

-- Avaiable search patterns:
--	x		Looks for key level equating x
--	x-		Looks for key levels equal to or less than x
--	x+		Looks for key levels equal to or greater than x
--
-- Spaces will be removed from input text on search, space characters will not effect search results.
-- 

keyLevelSearchTextInput:SetScript('OnEnterPressed', function(self)
	self:ClearFocus()
	FILTER_FIELDS[self.filterMethod] = self:GetText():gsub('%s', '')
	addon.UpdateFrames()
	if self:GetText() == '' then
		keyLevelSearchTextString:Hide()
		keyLevelSearchTextInput:Hide()
		keyLevelButton:Show()
		keyLevelSearchCloseButton:Hide()
		keyLevelSearchButton:Show()
	end
	end)

keyLevelSearchTextInput:SetScript('OnTextChanged', function(self)
	if not self:GetText() or self:GetText() ~= '' then
		keyLevelSearchTextString:Hide()
	else
		keyLevelSearchTextString:Show()
	end
	FILTER_FIELDS[self.filterMethod] = self:GetText()
	addon.UpdateFrames()
	end)

keyLevelSearchButton:SetScript('OnClick', function(self)
	keyLevelSearchTextString:Show()
	self:Hide()
	keyLevelSearchCloseButton:Show()
	keyLevelButton:Hide()
	keyLevelSearchTextInput:Show()
	keyLevelSearchTextInput:SetFocus(true)
	keyLevelSearchTextInput:SetText('')
	end)

keyLevelSearchButton:SetScript('OnEnter', function(self)
	self:SetAlpha(0.8)
	end)
keyLevelSearchButton:SetScript('OnLeave', function(self)
	self:SetAlpha(0)
	end)

keyLevelButton:SetScript('OnEnter', function()
	keyLevelSearchButton:GetNormalTexture():SetVertexColor(0.8, 0.8, 0.8, 0.8)
	keyLevelSearchButton:SetAlpha(0.8)
	end)

keyLevelButton:SetScript('OnLeave', function()
	keyLevelSearchButton:SetAlpha(0)
	end)

keyLevelSearchCloseButton:SetScript('OnClick', function(self)
	FILTER_FIELDS[self.filterMethod] = ''
	keyLevelSearchCloseButton:Hide()
	keyLevelSearchButton:Show()
	keyLevelSearchTextInput:Hide()
	keyLevelSearchTextString:Hide()
	keyLevelButton:Show()
	addon.UpdateFrames()
	end)

local dungeonButton = CreateFrame('BUTTON', '$parentDungeonButton', contentFrame)
dungeonButton.sortMethod = 'dungeon_name'
dungeonButton:SetSize(200, 20)
dungeonButton:SetNormalFontObject(InterUIBlack_Small)
dungeonButton:GetNormalFontObject():SetJustifyH('LEFT')
dungeonButton:SetText(L['DUNGEON'])
dungeonButton:SetAlpha(0.5)
dungeonButton:SetPoint('LEFT', keyLevelButton, 'RIGHT', 10, 0)
dungeonButton:SetScript('OnClick', function(self) ListButton_OnClick(self) end)

local dungeonSearchButton = CreateFrame('BUTTON', '$parentDungeonSearch', contentFrame)
dungeonSearchButton:SetSize(14, 14)
dungeonSearchButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\baseline_search_white_18dp')
dungeonSearchButton:SetPoint('RIGHT', dungeonButton, 'RIGHT', -5, 0)
dungeonSearchButton:SetAlpha(0)
dungeonSearchButton:SetFrameLevel(dungeonButton:GetFrameLevel() + 1)

local dungeonSearchCloseButton = CreateFrame('BUTTON', '$parentDungeonSearchCloseButton', contentFrame)
dungeonSearchCloseButton.filterMethod = 'dungeon_name'
dungeonSearchCloseButton:SetSize(8, 8)
dungeonSearchCloseButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\baseline-close-24px@2x')
dungeonSearchCloseButton:GetNormalTexture():SetVertexColor(0.8, 0.8, 0.8, 0.8)
dungeonSearchCloseButton:SetPoint('RIGHT', dungeonButton, 'RIGHT', -8, 1)
dungeonSearchCloseButton:SetFrameLevel(dungeonButton:GetFrameLevel() + 1)
dungeonSearchCloseButton:Hide()

local dungeonSearchTextString = contentFrame:CreateFontString(nil, 'OVERLAY', 'InterUIBlack_Small')
dungeonSearchTextString:SetJustifyH('LEFT')
dungeonSearchTextString:SetPoint('LEFT', dungeonButton, 'LEFT')
dungeonSearchTextString:SetTextColor(1, 1, 1, 0.5)
dungeonSearchTextString:SetText(L['FILTER_TEXT_DUNGEON'])
dungeonSearchTextString:Hide()

local dungeonSearchTextInput = CreateFrame('EditBox', '%parentDungeonSearchInput', contentFrame)
dungeonSearchTextInput.filterMethod = 'dungeon_name'
dungeonSearchTextInput:SetSize(135, 20)
dungeonSearchTextInput:SetPoint('RIGHT', dungeonSearchButton, 'LEFT')
dungeonSearchTextInput:SetFontObject(InterUIBlack_Small)
dungeonSearchTextInput:SetJustifyH('LEFT')
dungeonSearchTextInput:SetTextColor(1, 1, 1, 0.5)
dungeonSearchTextInput:SetAutoFocus(false)
dungeonSearchTextInput:EnableKeyboard(true)
dungeonSearchTextInput:Hide()

dungeonSearchTextInput:SetScript('OnEscapePressed', function(self)
	FILTER_FIELDS[self.filterMethod] = ''
	addon.UpdateFrames()
	self:ClearFocus()
	dungeonSearchTextString:Hide()
	dungeonSearchTextInput:Hide()
	dungeonButton:Show()
	dungeonSearchCloseButton:Hide()
	dungeonSearchButton:Show()
	end)

dungeonSearchTextInput:SetScript('OnEnterPressed', function(self)
	self:ClearFocus()
	FILTER_FIELDS[self.filterMethod] = self:GetText()
	addon.UpdateFrames()
	if self:GetText() == '' then
		dungeonSearchCloseButton:Hide()
		dungeonSearchButton:Show()
		dungeonSearchTextInput:Hide()
		dungeonSearchTextString:Hide()
		dungeonButton:Show()
	end
	end)

dungeonSearchTextInput:SetScript('OnTextChanged', function(self)
	if not self:GetText() or self:GetText() ~= '' then
		dungeonSearchTextString:Hide()
	else
		dungeonSearchTextString:Show()
	end
	FILTER_FIELDS[self.filterMethod] = self:GetText()
	addon.UpdateFrames()
	end)

dungeonSearchButton:SetScript('OnClick', function(self)
	dungeonSearchTextString:Show()
	self:Hide()
	dungeonSearchCloseButton:Show()
	dungeonButton:Hide()
	dungeonSearchTextInput:Show()
	dungeonSearchTextInput:SetFocus(true)
	dungeonSearchTextInput:SetText('')
	end)

dungeonSearchButton:SetScript('OnEnter', function(self)
	self:SetAlpha(0.8)
	end)
dungeonSearchButton:SetScript('OnLeave', function(self)
	self:SetAlpha(0)
	end)

dungeonButton:SetScript('OnEnter', function()
	dungeonSearchButton:GetNormalTexture():SetVertexColor(0.8, 0.8, 0.8, 0.8)
	dungeonSearchButton:SetAlpha(0.8)
	end)

dungeonButton:SetScript('OnLeave', function()
	dungeonSearchButton:SetAlpha(0)
	end)

dungeonSearchCloseButton:SetScript('OnClick', function(self)
	FILTER_FIELDS[self.filterMethod] = ''
	dungeonSearchCloseButton:Hide()
	dungeonSearchButton:Show()
	dungeonSearchTextInput:Hide()
	dungeonSearchTextString:Hide()
	dungeonButton:Show()
	addon.UpdateFrames()
	end)

local characterButton = CreateFrame('BUTTON', '$parentCharacterButton', contentFrame)
characterButton.sortMethod = 'character_name'
characterButton:SetSize(153, 20)
characterButton:SetNormalFontObject(InterUIBlack_Small)
characterButton:GetNormalFontObject():SetJustifyH('LEFT')
characterButton:SetText(L['CHARACTER'])
characterButton:SetAlpha(0.5)
characterButton:SetPoint('LEFT', dungeonButton, 'RIGHT')
characterButton:SetScript('OnClick', function(self) ListButton_OnClick(self) end)


local characterSearchButton = CreateFrame('BUTTON', '$parentCharacterSearch', contentFrame)
characterSearchButton:SetSize(14, 14)
characterSearchButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\baseline_search_white_18dp')
characterSearchButton:SetPoint('RIGHT', characterButton, 'RIGHT', -10, 0)
characterSearchButton:SetAlpha(0)
characterSearchButton:SetFrameLevel(characterButton:GetFrameLevel() + 1)

local characterSearchCloseButton = CreateFrame('BUTTON', '$parentCharacterSearchCloseButton', contentFrame)
characterSearchCloseButton.filterMethod = 'character_name'
characterSearchCloseButton:SetSize(8, 8)
characterSearchCloseButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\baseline-close-24px@2x')
characterSearchCloseButton:GetNormalTexture():SetVertexColor(0.8, 0.8, 0.8, 0.8)
characterSearchCloseButton:SetPoint('RIGHT', characterButton, 'RIGHT', -13, 1)
characterSearchCloseButton:SetFrameLevel(characterButton:GetFrameLevel() + 1)
characterSearchCloseButton:Hide()

local characterSearchTextString = contentFrame:CreateFontString(nil, 'OVERLAY', 'InterUIBlack_Small')
characterSearchTextString:SetJustifyH('LEFT')
characterSearchTextString:SetPoint('LEFT', characterButton, 'LEFT')
characterSearchTextString:SetTextColor(1, 1, 1, 0.5)
characterSearchTextString:SetText(L['FILTER_TEXT_CHARACTER'])
characterSearchTextString:Hide()

local characterSearchTextInput = CreateFrame('EditBox', '%parentCharacterSearchInput', contentFrame)
characterSearchTextInput.filterMethod = 'character_name'
characterSearchTextInput:SetSize(133, 20)
characterSearchTextInput:SetPoint('RIGHT', characterSearchButton, 'LEFT')
characterSearchTextInput:SetFontObject(InterUIBlack_Small)
characterSearchTextInput:SetJustifyH('LEFT')
characterSearchTextInput:SetTextColor(1, 1, 1, 0.5)
characterSearchTextInput:SetAutoFocus(false)
characterSearchTextInput:EnableKeyboard(true)
characterSearchTextInput:Hide()

characterSearchTextInput:SetScript('OnEscapePressed', function(self)
	FILTER_FIELDS[self.filterMethod] = ''
	addon.UpdateFrames()
	self:ClearFocus()
	characterSearchTextString:Hide()
	characterSearchTextInput:Hide()
	characterButton:Show()
	characterSearchCloseButton:Hide()
	characterSearchButton:Show()
	end)

characterSearchTextInput:SetScript('OnEnterPressed', function(self)
	self:ClearFocus()
	FILTER_FIELDS[self.filterMethod] = self:GetText()
	addon.UpdateFrames()
	if self:GetText() == '' then
		characterSearchCloseButton:Hide()
		characterSearchButton:Show()
		characterSearchTextInput:Hide()
		characterSearchTextString:Hide()
		characterButton:Show()
	end
	end)

characterSearchTextInput:SetScript('OnTextChanged', function(self)
	if not self:GetText() or self:GetText() ~= '' then
		characterSearchTextString:Hide()
	else
		characterSearchTextString:Show()
	end
	FILTER_FIELDS[self.filterMethod] = self:GetText()
	addon.UpdateFrames()
	end)

characterSearchButton:SetScript('OnClick', function(self)
	characterSearchTextString:Show()
	self:Hide()
	characterSearchCloseButton:Show()
	characterButton:Hide()
	characterSearchTextInput:Show()
	characterSearchTextInput:SetFocus(true)
	characterSearchTextInput:SetText('')
	end)

characterSearchButton:SetScript('OnEnter', function(self)
	self:SetAlpha(0.8)
	end)
characterSearchButton:SetScript('OnLeave', function(self)
	self:SetAlpha(0)
	end)

characterButton:SetScript('OnEnter', function()
	characterSearchButton:GetNormalTexture():SetVertexColor(0.8, 0.8, 0.8, 0.8)
	characterSearchButton:SetAlpha(0.8)
	end)

characterButton:SetScript('OnLeave', function()
	characterSearchButton:SetAlpha(0)
	end)

characterSearchCloseButton:SetScript('OnClick', function(self)
	FILTER_FIELDS[self.filterMethod] = ''
	characterSearchCloseButton:Hide()
	characterSearchButton:Show()
	characterSearchTextInput:Hide()
	characterSearchTextString:Hide()
	characterButton:Show()
	addon.UpdateFrames()
	end)

local weeklyBestButton = CreateFrame('BUTTON', '$parentWeeklyBestButton', contentFrame)
weeklyBestButton.sortMethod = 'weekly_best'
weeklyBestButton:SetSize(70, 20)
weeklyBestButton:SetNormalFontObject(InterUIBlack_Small)
characterButton:GetNormalFontObject():SetJustifyH('CENTER')
weeklyBestButton:SetText(L['WEEKLY_BEST'])
weeklyBestButton:SetAlpha(0.5)
weeklyBestButton:SetPoint('LEFT', characterButton, 'RIGHT')
weeklyBestButton:SetScript('OnClick', function(self) ListButton_OnClick(self) end)

function AstralKeyFrame:OnUpdate(elapsed)
	self.updateDelay = self.updateDelay + elapsed

	if self.updateDelay < 0.75 then
		return
	end
	self:SetScript('OnUpdate', nil)
	self.updateDelay = 0
	addon.UpdateFrames()
end

function AstralKeyFrame:ToggleLists()
	if AstralKeysSettings.friendOptions.friend_sync.isEnabled then
		AstralKeyFrameTabFrameTabFRIENDS:Show()
	else
		AstralKeyFrameTabFrameTabFRIENDS:Hide()
		if addon.FrameListShown() == 'FRIENDS' then
			addon.SetFrameListShown('GUILD')
			UpdateTabs()
			addon.UpdateFrames()
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
	offLineButton:SetChecked(AstralKeysSettings.frame.show_offline.isEnabled)
	addon.UpdateFrames()
	addon.UpdateCharacterFrames()
	self:SetPropagateKeyboardInput(true)
	end)

AstralKeyFrame:SetScript('OnDragStart', function(self)
	self:StartMoving()
	unitPopup:Hide()
	subUnitPopup:Hide()
	--tabPopup:Hide()
	AstralMenuFrameReport1:Hide()
	end)

AstralKeyFrame:SetScript('OnDragStop', function(self)
	self:StopMovingOrSizing()
	end)

AstralKeyFrame:SetScript('OnHide', function()
	wipe(selectedUnits)
	AstralMenuFrameUnit1:Hide()
	AstralMenuFrameReport1:Hide()
	end)

local init = false
local function InitializeFrame()
	init = true

	for i = 1, #AstralLists do
		CreateNewTab(AstralLists[i].name, tabFrame)
	end
	UpdateTabs()

	guildVersionString:SetFormattedText('Astral - Area 52 (US) %s', addon.CLIENT_VERSION)

	if AstralKeysSettings.frame.isCollapsed.isEnabled then
		collapseButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\baseline-first_page-24px@2x')
		AstralKeyFrame:SetWidth(FRAME_WIDTH_MINIMIZED)
		AstralKeyFrameCharacterFrame:Hide()
	else
		collapseButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\baseline-last_page-24px@2x')
	end

	if not AstralKeysSettings.friendOptions.friend_sync.isEnabled then
		AstralKeyFrameTabFrameTabFRIENDS:Hide()
	end

	offLineButton:SetChecked(AstralKeysSettings.frame.show_offline.isEnabled)
	HybridScrollFrame_CreateButtons(AstralKeyFrameCharacterFrameCharacterContainer, 'AstralCharacterFrameTemplate', 0, 0, 'TOPLEFT', 'TOPLEFT', 0, -10)
	HybridScrollFrame_CreateButtons(AstralKeyFrameListContainer, 'AstralListFrameTemplate', 0, 0, 'TOPLEFT', 'TOPLEFT', 0, -10)

	addon.UpdateAffixes()

	addon.UpdateFrames()
	UpdateTabs()
end

function addon.UpdateAffixes()
	AstralKeyFrameCharacterFrameAffix1:UpdateInfo(addon.AffixOne())
	AstralKeyFrameCharacterFrameAffix2:UpdateInfo(addon.AffixTwo())
	AstralKeyFrameCharacterFrameAffix3:UpdateInfo(addon.AffixThree())
	AstralKeyFrameCharacterFrameAffix4:UpdateInfo(addon.AffixFour())

	for i = 1, 8 do
		_G['AstralKeyFrameCharacterFrameAffixFrameAffix' .. i]:UpdateInfo()
	end
end

function addon.WipeFrames()
	wipe(sortedTable)
end

function addon.UpdateLines()
	if not init then return end
	local list = addon.FrameListShown()
	if addon.GetListCount(list) == 0 or list ~= 'GUILD' or list ~= 'FRIENDS' then -- There haven't been any units added to the list, show the helper text
		--AstralKeyFrameListHelperText:Show()
	else
		--AstralKeyFrameListHelperText:Hide()
	end
	ListScrollFrame_Update()
end

function addon.UpdateFrames()
	if not init or not AstralKeyFrame:IsShown() then return end

	addon.UpdateTable(sortTable, FILTER_FIELDS)
	addon.SortTable(sortTable, AstralKeysSettings.frame.sorth_method)
	addon.UpdateLines()
end

function addon.UpdateCharacterFrames()
	if not init then return end
	
	local id = addon.GetCharacterID(addon.Player())
	if id then
		local player = table.remove(AstralCharacters, id)
		table.sort(AstralCharacters, function(a,b) return a.unit < b.unit end)
		table.insert(AstralCharacters, 1, player)
		addon.UpdateCharacterIDs()
	end
	CharacterScrollFrame_Update()
end

-- To be used when switching lists maybe?
function addon.UpdateSortTable()
	local currentList = addon.FrameListShown()

	wipe(sortTable)

	for i = 1, #AstralLists do
		if AstralLists[i].name == currentList then
			for unit, bt in pairs(AstralLists[i].units) do
				local unitID = addon.UnitID(unit)

				if unitID then
					local btag
					if type(bt) == 'string' then
						btag = bt
					end

					local addToList = false

					if currentList == 'GUILD' then
						if addon.UnitInGuild(unit) then
							addToList = true
						end
					else
						addToList = true
					end

					if addToList then
						table.insert(sortTable, {
							character_name = AstralKeys[unitID].unit,
							character_class = AstralKeys[unitID].class,
							dungeon_id =AstralKeys[unitID].dungeon_id,
							key_level = AstralKeys[unitID].key_level,
							weekly_best = AstralKeys[unitID].weekly_best,
							faction = AstralKeys[unitID].faction,
							btag = btag or AstralKeys[unitID].btag,
							source = AstralKeys[unitID].source
						})
					end
				end
			end
		end
	end
end

function addon.AddUnitToSortTable(unit, btag, class, faction, mapID, level, weekly_best, source)
	if not addon.DoesUnitBelongToList(unit, addon.FrameListShown()) then return end

	if addon.FrameListShown() == 'GUILD' then
		if not addon.UnitInGuild(unit) then
			return
		end
	end

	local found = false
	for i = 1, #sortTable do
		if sortTable[i].character_name == unit then
			sortTable[i].dungeon_id = mapID
			sortTable[i].key_level = level
			sortTable[i].weekly_best = weekly_best
			found = true
			break
		end
	end

	if not found then
		table.insert(sortTable, {
				character_name = unit,
				btag = btag,
				character_class = class,
				faction = faction,
				dungeon_id =mapID,
				key_level = level,
				weekly_best = weekly_best,
				source = source,
			})
	end
end

		
-- Old function.
function addon.AddUnitToTable(unit, class, faction, listType, mapID, level, weekly_best, btag)
	if not sortedTable[listType] then
		sortedTable[listType] = {}
	end
	local found = false
	for i = 1, #sortedTable[listType] do
		if sortedTable[listType][i].character_name == unit then
			sortedTable[listType][i].mapID = mapID
			sortedTable[listType][i].key_level = level
			sortedTable[listType][i].weekly_best = weekly_best
			found = true
			break
		end
	end

	if not found then
		sortedTable[listType][#sortedTable[listType] + 1] = {character_name = unit, character_class = class, mapID = mapID, key_level = level, weekly_best = weekly_best, faction = faction, btag = btag}
	end
end

function addon.Console(msg)
	print(string.format('%s %s', WrapTextInColorCode('[AK]', '008888FF'), msg))
end

function addon.AstralMain(arg)
	if arg and (arg == 'sync' or arg == 'refresh') then
		addon.Console('Refreshing key data.')
		local refresh = addon.RefreshData()
		if refresh then
			addon.Console('Done.')
		else
			addon.Console('You need to wait more than 30 seconds before refreshing again.')
		end
		return
	end
	addon.AstralToggle()
end

function addon.AstralToggle()
	if not init then InitializeFrame() end
	AstralKeyFrame:SetShown(not AstralKeyFrame:IsShown())
end

function OpenAstralKeysWindow()
	addon.AstralToggle()
end

SLASH_ASTRALKEYS1 = '/astralkeys'
SLASH_ASTRALKEYS2 = '/ak'
SLASH_ASTRALKEYSV1 = '/akv'

SlashCmdList['ASTRALKEYS'] = addon.AstralMain;
SlashCmdList['ASTRALKEYSV'] = addon.CheckGuildVersion
