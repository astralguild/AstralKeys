 local _, e = ...

local BACKDROP = {
bgFile = "Interface/Tooltips/UI-Tooltip-Background",
edgeFile = nil, tile = true, tileSize = 16, edgeSize = 16,
insets = {left = 0, right = 0, top = 0, bottom = 0}
}

local POSITIONS = {
	[1] = 'LEFT',
	[2] = 'CENTER',
	[3] = 'RIGHT',
}

local offset = 0
local characterOffset = 0

local name, keyLevel, mapID, class, usable, realm, indexEnd

local currentSort = {}
currentSort['section'] = 'key'
currentSort['orientation'] = 0

local BACKDROPBUTTON = {
bgFile = nil,
edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16, edgeSize = 1,
insets = {left = 0, right = 0, top = 0, bottom = 0}
}

local FONT_HEADER = "Interface\\AddOns\\AstralKeys\\Media\\big_noodle_titling.TTF"
local FONT_CONTENT = "Interface\\AddOns\\AstralKeys\\Media\\Lato-Regular.TTF"
local FONT_SIZE = 13

local FONT_OBJECT_RIGHT = CreateFont("FONT_OBJECT_RIGHT")
FONT_OBJECT_RIGHT:SetFont(FONT_CONTENT, FONT_SIZE)
FONT_OBJECT_RIGHT:SetJustifyH('RIGHT')
FONT_OBJECT_RIGHT:SetTextColor(1, 1, 1)

local FONT_OBJECT_CENTRE = CreateFont("FONT_OBJECT_CENTRE")
FONT_OBJECT_CENTRE:SetFont(FONT_CONTENT, FONT_SIZE)
FONT_OBJECT_CENTRE:SetJustifyH('CENTER')
FONT_OBJECT_CENTRE:SetTextColor(1, 1, 1)

local FONT_OBJECT_HIGHLIGHT = CreateFont("FONT_OBJECT_HIGHLIGHT")
FONT_OBJECT_HIGHLIGHT:SetFont(FONT_CONTENT, FONT_SIZE)
FONT_OBJECT_HIGHLIGHT:SetJustifyH('CENTER')
FONT_OBJECT_HIGHLIGHT:SetTextColor(192/255, 192/255, 192/255)

local sortedTable = {}
local characters = {}
local characterTable = {}

local function CreateHeader(self, parent, name, width, height, text, fontAdjust)
	self = CreateFrame('FRAME', 'header_' .. name, parent)
	self:SetSize(width, height)

	self.s = self:CreateFontString('BACKGROUND')
	self.s:SetFont(FONT_HEADER, FONT_SIZE + fontAdjust)
	self.s:SetPoint('BOTTOMLEFT', self, 'BOTTOMLEFT')
	self.s:SetText(text)

	self.t = self:CreateTexture('BACKGROUND')
	self.t:SetPoint('BOTTOMLEFT', self, 'BOTTOMLEFT')
	self.t:SetSize(width, 1)
	self.t:SetColorTexture(1, 1, 1)
	self.t:SetGradientAlpha('HORIZONTAL', 1, 1, 1, 0.8, 0, 0 , 0, 0)

	function self:SetText(text)
		self.s:SetText(text)
	end

	return self

end

local function CreateButton(parent, btnID, width, height, text, fontobject, highlightfont)
	local button = CreateFrame('BUTTON', btnID, parent)
	button.ID = btnID
	button.sort = 0
	button:SetSize(width, height)
	--button:SetMovable(true)
	--button:RegisterForDrag('LeftButton')

	button.t = button:CreateTexture('BACKGROUND')
	button.t:SetPoint('BOTTOMLEFT', button, 'BOTTOMLEFT', 5, 0)
	button.t:SetSize(width - 10, 1)
	button.t:SetColorTexture(.3, .3, .3)

	if fontobject then
		button:SetNormalFontObject(fontobject)
		button:SetHighlightFontObject(highlightfont)
		button:SetText(text)
	end

	button:EnableMouse(true)
	button:SetMovable(true)

	button:SetScript('OnDragStart', function(self)
		self:StartMoving()
		end)

	button:SetScript('OnDragStop', function(self)
		self:StopMovingOrSizing()
		end)

	return button
end

local function CreateCheckBox(parent, cbID, label)
	local checkbox = CreateFrame('CheckButton', nil, parent)
	checkbox:SetSize(12, 12)
	checkbox:SetBackdrop(BACKDROPBUTTON)
	checkbox:SetBackdropBorderColor(85/255, 85/255, 85/255)
	checkbox:SetNormalFontObject(FONT_OBJECT_RIGHT)
	checkbox:SetText(label)

	checkbox:SetNormalTexture(nil)
	checkbox:SetBackdropColor(0, 0, 0)
	checkbox:GetFontString():SetPoint('RIGHT', checkbox, 'LEFT', -5, 0)

	checkbox.t = checkbox:CreateTexture('PUSHEDTEXTURE', 'BACKGROUND')
	checkbox.t:SetSize(6, 6)
	checkbox.t:SetPoint('TOPLEFT', checkbox, 'TOPLEFT', 3, -3)
	checkbox.t:SetColorTexture(.9, .9, .9)
	checkbox:SetCheckedTexture(checkbox.t)

	return checkbox
end

local function CreateCharacterFrame(parent, frameName, unitName, bestKey, createDivider)

	local frame = CreateFrame('FRAME', frameName, parent)
	frame:SetSize(210, 31)
	frame:SetFrameLevel(5)

	frame.tid = ''
	frame.unit = unitName
	frame.bestKey = ''
	frame.currentKey = ''
	frame.unitClass = ''
	frame.bestMap = ''
	frame.weeklyAP = 0
	frame.realm = ''


	frame.name = CreateFrame('FRAME', nil, frame)
	frame.name:SetSize(175, 15)
	frame.name:SetPoint('TOPLEFT', frame, 'TOPLEFT')

	frame.name.string = frame.name:CreateFontString('ARTWORK')
	frame.name.string:SetFont(FONT_CONTENT, FONT_SIZE)
	frame.name.string:SetPoint('TOPLEFT', frame.name, 'TOPLEFT')

	frame.keystone = CreateFrame('FRAME', nil, frame)
	frame.keystone:SetSize(200, 15)
	frame.keystone:SetPoint('BOTTOMLEFT', frame, 'BOTTOMLEFT', 10, 0)

	frame.keystone.string = frame.keystone:CreateFontString('ARTWORK')
	frame.keystone.string:SetFont(FONT_CONTENT, FONT_SIZE)
	frame.keystone.string:SetPoint('BOTTOMLEFT', frame.keystone, 'BOTTOMLEFT')

	if createDivider then

		frame.divider = frame:CreateTexture('BACKGROUND')
		frame.divider:SetSize(125, 1)
		frame.divider:SetPoint('BOTTOMLEFT', frame, 'BOTTOMLEFT', 25)
		frame.divider:SetColorTexture(.3, .3, .3)

	end

	function frame:UpdateInformation(unit)
		if unit ~= '' and unit then
			self.unit = unit
			self.tid = e.GetCharacterID(self.unit)
			self.unitClass = e.CharacterClass(self.tid)
			self.bestKey = e.GetBestKey(self.tid)
			self.bestMap = e.GetBestMap(self.unit)
			self.weeklyAP = e.GetWeeklyAP(self.bestKey)
			self.realm = e.CharacterRealm(self.tid)

			local name = self.unit

			if self.realm ~= e.PlayerRealm() then
				name = name .. '(*)'
			end

			if self.bestKey ~= 0 then
				self.name.string:SetText(WrapTextInColorCode(name, select(4, GetClassColor(self.unitClass))) .. ' - ' .. self.bestKey)
			else
				self.name.string:SetText(WrapTextInColorCode(name, select(4, GetClassColor(self.unitClass))))
			end
			self.keystone.string:SetText(e.GetCharacterKey(self.unit))
		else
			self.name.string:SetText('')
			self.keystone.string:SetText('')
			self.tid = nil
		end

	end

	frame:SetScript('OnEnter', function(self)
		if not self.tid then return end

		if self.weeklyAP then
			astralMouseOver:SetText(self.bestMap .. '\n- ' .. e.ConvertToSI(self.weeklyAP * e.CharacterAK(self.tid)) .. ' AP')
		else
			astralMouseOver:SetText(self.bestMap)
		end

		astralMouseOver:AdjustSize()
		astralMouseOver:ClearAllPoints()
		astralMouseOver:SetPoint('TOPLEFT', frame, 'BOTTOMRIGHT', - 105, 20)
		astralMouseOver:Show()
		AstralCharacterContent.slider:SetAlpha(1)
		end)

	frame:SetScript('OnLeave', function()
		astralMouseOver:Hide()
		AstralCharacterContent.slider:SetAlpha(.2)
		end)

	return frame

end

local nameFrames = {}
local keyFrames = {}
local mapFrames = {}
local completedFrames = {}

local function CreateNameFrame(parent, unitName, unitClass, unitRealm)
	local frame = CreateFrame('FRAME', nil, parent)
	frame:SetSize(100, 15)
	frame.name = unitName
	frame.class = unitClass
	frame.realm = unitRealm

	frame.string = frame:CreateFontString('ARTWORK')
	frame.string:SetFont(FONT_CONTENT, FONT_SIZE)
	frame.string:SetPoint('TOPLEFT', frame, 'TOPLEFT')
	frame.string:SetWidth(100)
	frame.string:SetJustifyH('LEFT')
	frame.string:SetJustifyV('TOP')
	if frame.realm == e.PlayerRealm() then
		frame.string:SetText(WrapTextInColorCode(frame.name, select(4, GetClassColor(frame.class))))
	else
		frame.string:SetText(WrapTextInColorCode(frame.name .. '(*)', select(4, GetClassColor(frame.class))))
	end

	function frame.SetNameInfo(self, unitName, unitClass, unitRealm)
		if unitName ~= '' then
			self.name = unitName
			self.class = unitClass
			self.realm = unitRealm
			if self.realm == e.PlayerRealm() then
				self.string:SetText(WrapTextInColorCode(self.name, select(4, GetClassColor(self.class))))
			else
				self.string:SetText(WrapTextInColorCode(self.name .. '(*)', select(4, GetClassColor(self.class))))
			end
		else
			self.string:SetText('')
		end

	end

	return frame

end

local function CreateMapFrame(parent, mapID, isUsable, keyLevel)
	local frame = CreateFrame('FRAME', nil, parent)
	frame:SetSize(170, 15)
	frame.map = tonumber(mapID)
	frame.usable = tonumber(isUsable)
	frame.level = tonumber(keyLevel)

	frame.string = frame:CreateFontString('ARTWORK')
	frame.string:SetFont(FONT_CONTENT, FONT_SIZE)
	frame.string:SetPoint('TOPLEFT', frame, 'TOPLEFT')

	if tonumber(frame.usable) ~= 1 then 
		frame.string:SetText(WrapTextInColorCode(e.GetMapName(frame.map), 'ff9d9d9d'))
	else
		frame.string:SetText(e.GetMapName(frame.map))
	end

	function frame.SetMapInfo(self, mapID, isUsable, keyLevel)
		if mapID ~= -1 then
			self.map = tonumber(mapID)
			self.usable = tonumber(isUsable)
			self.level = tonumber(keyLevel)

			if tonumber(self.usable) ~= 1 then 
				self.string:SetText(WrapTextInColorCode(e.GetMapName(self.map), 'ff9d9d9d'))
			else
				self.string:SetText(e.GetMapName(self.map))
			end
		else
			self.map = -1
			self.string:SetText('')
		end
	end

	frame:SetScript('OnEnter', function(self)
		if UnitLevel('player') == 110 then
			if self.map ~= -1 then
				astralMouseOver:ClearAllPoints()
				astralMouseOver:SetPoint('TOPLEFT', self, 'CENTER', 35, 0)
				astralMouseOver:SetText(e.MapApText(frame.map, frame.level, frame.usable))
				astralMouseOver:AdjustSize()
				astralMouseOver:Show()
				AstralContentFrame.slider:SetAlpha(1)
			end
		end
		end)

 	frame:SetScript('Onleave', function(self)
 		astralMouseOver:Hide()
		AstralContentFrame.slider:SetAlpha(.2)
 		end)

	return frame

end

local function CreateKeyFrame(parent, keyLevel)
	local frame = CreateFrame('FRAME', nil, parent)
	frame:SetSize(45, 15)
	frame.key = tonumber(keyLevel)

	frame.string = frame:CreateFontString('ARTWORK')
	frame.string:SetFont(FONT_CONTENT, FONT_SIZE)
	frame.string:SetPoint('TOPLEFT', frame, 'TOPLEFT')
	frame.string:SetText(keyLevel)

	function frame.SetKeyInfo(self, keyLevel)
		if keyLevel ~= -1 then
			self.key = keyLevel
			self.string:SetText(self.key)
		else
			self.string:SetText('')
		end
	end

	return frame

end

local function CreateCompleteFrame(parent, completed)
	local frame = CreateFrame('FRAME', nil, parent)
	frame:SetSize(15, 15)
	frame.isCompleted = completed

	frame.tex = frame:CreateTexture('BACKGROUND')
	frame.tex:SetSize(15, 15)
	frame.tex:SetPoint('TOPLEFT', frame, 'TOPLEFT')
	frame.tex:SetTexture('Interface\\AddOns\\AstralKeys\\Media\\check.tga')

	if frame.isCompleted == 1 then
		frame:Show()
	else
		frame:Hide()
	end

	function frame:SetCompletedInfo(completed)
		if not completed then self.isCompleted = 0 end
		self.isCompleted = completed
		if self.isCompleted == 1 then
			self:Show()
		else
			self:Hide()
		end
	end

	return frame
end

local AstralKeyFrame = CreateFrame('FRAME', 'AstralKeyFrame', UIParent)
AstralKeyFrame:SetFrameStrata('DIALOG')
AstralKeyFrame:SetWidth(655)
AstralKeyFrame:SetHeight(505)
AstralKeyFrame:SetPoint('CENTER', UIParent, 'CENTER')
AstralKeyFrame:EnableMouse(true)
AstralKeyFrame:SetBackdrop(BACKDROP)
AstralKeyFrame:SetBackdropColor(0, 0, 0, 1)
AstralKeyFrame:SetMovable(true)
AstralKeyFrame:RegisterForDrag('LeftButton')
AstralKeyFrame:EnableKeyboard(true)
AstralKeyFrame:SetPropagateKeyboardInput(true)
AstralKeyFrame:SetClampedToScreen(true)
AstralKeyFrame:Hide()

local guildInfo = CreateFrame('FRAME', nil, AstralKeyFrame)
guildInfo:SetSize(125, 13)
guildInfo:SetPoint('BOTTOMRIGHT', AstralKeyFrame, 'BOTTOMRIGHT', -5, 5)
guildInfo:EnableMouse(true)
guildInfo:SetScript('OnMouseDown', function(self) 
	if not astralGuildInfo then
		local astralGuildInfo = CreateFrame('FRAME', 'astralGuildInfo', UIParent)
		astralGuildInfo:SetFrameLevel(8)
		astralGuildInfo:SetSize(200, 100)
		astralGuildInfo:SetBackdrop(BACKDROPBUTTON)
		astralGuildInfo:SetBackdropBorderColor(.2, .2, .2, 1)
		astralGuildInfo:SetPoint('BOTTOM', UIParent, 'TOP', 0, -300)

		astralGuildInfo.text = astralGuildInfo:CreateFontString('ARTWORK')
		astralGuildInfo.text:SetFont(FONT_CONTENT, FONT_SIZE)
		astralGuildInfo.text:SetPoint('TOP', astralGuildInfo,'TOP', 0, -10)
		astralGuildInfo.text:SetText('Visit Astral at')

		astralGuildInfo.editBox = CreateFrame('EditBox', nil, astralGuildInfo)
		astralGuildInfo.editBox:SetSize(180, 20)
		astralGuildInfo.editBox:SetPoint('TOP', astralGuildInfo.text, 'BOTTOM', 0, -10)

		astralGuildInfo.tex = astralGuildInfo:CreateTexture('ARTWORK')
		astralGuildInfo.tex:SetSize(198, 98)
		astralGuildInfo.tex:SetPoint('TOPLEFT', astralGuildInfo, 'TOPLEFT', 1, -1)
		astralGuildInfo.tex:SetColorTexture(0, 0, 0)

		astralGuildInfo.editBox:SetBackdrop(BACKDROPBUTTON)
		astralGuildInfo.editBox:SetBackdropBorderColor(.2, .2, .2, 1)
		astralGuildInfo.editBox:SetFontObject(FONT_OBJECT_CENTRE)
		astralGuildInfo.editBox:SetText('www.astralguild.com')
		astralGuildInfo.editBox:HighlightText()
		astralGuildInfo.editBox:SetScript('OnChar', function(self, char)
			self:SetText('www.astralguild.com')
			self:HighlightText()

		astralGuildInfo.editBox:SetScript("OnEscapePressed", function(self)
			astralGuildInfo:Hide()
		end)

			end)
		astralGuildInfo.editBox:SetScript('OnEditFocusLost', function(self)
			self:SetText('www.astralguild.com')
			self:HighlightText()
			end)

		astralGuildInfo.button = CreateButton(astralGuildInfo, nil, 40, 20, 'OK', FONT_OBJECT_CENTRE, FONT_OBJECT_HIGHLIGHT)
		astralGuildInfo.button:SetBackdrop(BACKDROPBUTTON)
		astralGuildInfo.button:SetBackdropBorderColor(.2, .2, .2, 1)
		astralGuildInfo.button:SetPoint('BOTTOM', astralGuildInfo, 'BOTTOM', 0, 10)
		astralGuildInfo.button.t:ClearAllPoints()
		astralGuildInfo.button.t = nil
		astralGuildInfo.button:SetScript('OnClick', function(self)
			astralGuildInfo:Hide() end)
	else
		astralGuildInfo:Show()
	end
 end)



guildInfo.string = guildInfo:CreateFontString('ARTWORK')
guildInfo.string:SetFont(FONT_CONTENT, FONT_SIZE - 2)
guildInfo.string:SetText('Astral - Turalyon (US)')
guildInfo.string:SetJustifyH('RIGHT')
guildInfo.string:SetPoint('BOTTOMRIGHT', guildInfo, 'BOTTOMRIGHT')

AstralKeyFrame.version = AstralKeyFrame:CreateFontString('ARTWORK')
AstralKeyFrame.version:SetFont(FONT_CONTENT, FONT_SIZE - 3)
AstralKeyFrame.version:SetPoint('BOTTOMRIGHT', guildInfo, 'TOPRIGHT')
AstralKeyFrame.version:SetText('v'.. GetAddOnMetadata('AstralKeys', 'version'))
AstralKeyFrame.version:SetJustifyH('RIGHT')

local logo = AstralKeyFrame:CreateTexture('ARTWORK')
logo:SetSize(64, 64)
logo:SetTexture('Interface\\AddOns\\AstralKeys\\Media\\Astral.tga')
logo:SetPoint('TOPLEFT', AstralKeyFrame, 'TOPLEFT', 10, -10)

local title = CreateHeader(self, AstralKeyFrame, 'title', 220, 20, 'Astral Keys', 26)
title:SetPoint('LEFT', logo, 'RIGHT', 10, -10)

AstralKeyFrame.centreDivider = AstralKeyFrame:CreateTexture('BACKGROUND')
AstralKeyFrame.centreDivider:SetSize(1, 325)
AstralKeyFrame.centreDivider:SetPoint('TOPLEFT', AstralKeyFrame, 'TOPLEFT', 250, -125)
AstralKeyFrame.centreDivider:SetColorTexture(0.2, 0.2, 0.2)

local closeButton = CreateFrame('BUTTON', nil, AstralKeyFrame)
closeButton:SetSize(15, 15)
closeButton:SetNormalFontObject(FONT_OBJECT_CENTRE)
closeButton:SetHighlightFontObject(FONT_OBJECT_HIGHLIGHT)
closeButton:SetText('X')

local toggleButton = CreateFrame('BUTTON', nil, AstralKeyFrame)
toggleButton.mode = 0
toggleButton:SetSize(16, 16)
toggleButton:SetPoint('TOPRIGHT', closeButton, 'TOPLEFT', - 5, 0)
toggleButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\minimize.tga')
toggleButton:SetHighlightTexture('Interface\\AddOns\\AstralKeys\\Media\\minimize_highlight.tga', 'BLEND')

toggleButton:SetScript('OnClick', function(self)
	local left, bottom, width = AstralKeyFrame:GetRect()
	if e.GetViewMode() == 0 then
		e.SetViewMode(1)
		self:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\menu.tga')
		self:SetHighlightTexture('Interface\\AddOns\\AstralKeys\\Media\\menu_highlight.tga', 'BLEND')
		AstralKeyFrame:SetWidth(405)
		AstralKeyFrame:ClearAllPoints()
		AstralKeyFrame:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOMLEFT', left + width - 405, bottom)
		affixFrame:Hide()
		astralCharacterFrame:Hide()
		AstralKeyFrame.centreDivider:Hide()
		AstralContentFrame:ClearAllPoints()
		AstralContentFrame:SetPoint('TOPLEFT', AstralKeyFrame, 'TOPLEFT', 5, -95)
	else
		e.SetViewMode(0)
		self:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\minimize.tga')
		self:SetHighlightTexture('Interface\\AddOns\\AstralKeys\\Media\\minimize_highlight.tga', 'BLEND')
		AstralKeyFrame:SetWidth(655)
		AstralKeyFrame:ClearAllPoints()
		AstralKeyFrame:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOMLEFT', left + width - 655, bottom)
		affixFrame:Show()
		astralCharacterFrame:Show()
		AstralKeyFrame.centreDivider:Show()
		AstralContentFrame:ClearAllPoints()
		AstralContentFrame:SetPoint('TOPLEFT', AstralKeyFrame, 'TOPLEFT', 255, -95)
	end
	end)

closeButton:SetScript('OnClick', function()
	AstralKeyFrame:Hide()
end)

closeButton:SetPoint('TOPRIGHT', AstralKeyFrame, 'TOPRIGHT', -10, -10)

local quickOptionsFrame = CreateFrame('FRAME', 'quickOptionsFrame', AstralKeyFrame)
quickOptionsFrame:SetSize(150, 45)
quickOptionsFrame:SetBackdrop(BACKDROP)
quickOptionsFrame:SetBackdropColor(0, 0, 0, 1)
quickOptionsFrame:SetFrameLevel(10)
quickOptionsFrame:SetPoint('TOPRIGHT', AstralKeyFrame, 'TOPRIGHT', -10, - 28)
quickOptionsFrame:Hide()

local showOffline = CreateCheckBox(quickOptionsFrame, 'showOffline', 'Show offline')
showOffline:SetPoint('TOPRIGHT', quickOptionsFrame, 'TOPRIGHT', -5, -5)

showOffline:SetScript('OnClick', function (self)
	e.SetShowOffline(self:GetChecked())
	offset = 0
	e.UpdateFrames()
end)

local minKeyLevel = e.CreateEditBox(quickOptionsFrame, 'minKeyLevel', 25, 'Min announce level', 1, 100)
minKeyLevel:SetPoint('TOPRIGHT', showOffline, 'BOTTOMRIGHT', 0, -5)
minKeyLevel:SetScript('OnEditFocusLost', function(self)
	e.SetMinKeyLevel(self:GetNumber())
		end)
minKeyLevel:EnableMouseWheel(true)
minKeyLevel:SetScript('OnMouseWheel', function(self, delta)
	if self:GetNumber() + delta < self.minValue or self:GetNumber() + delta > self.maxValue then
		return
	else
		self:SetNumber(self:GetNumber() + delta)
		e.SetMinKeyLevel(self:GetNumber())
	end
	end)

local quickOptions = CreateFrame('BUTTON', nil, AstralKeyFrame)
quickOptions:SetSize(16, 16)
quickOptions:SetPoint('TOPRIGHT', toggleButton, 'TOPLEFT', -5, 0)
quickOptions:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\folder.tga')
quickOptions:SetHighlightTexture('Interface\\AddOns\\AstralKeys\\Media\\folder_highlight.tga', 'BLEND')
quickOptions:SetScript('OnClick', function ()
	quickOptionsFrame:SetShown(not quickOptionsFrame:IsShown())
end)

-- Announce Buttons
-----------------------------------------------------

local announceFrame = CreateFrame('FRAME', nil, AstralKeyFrame)
announceFrame:SetSize(60, 20)
announceFrame:SetPoint('TOPRIGHT', closeButton, 'BOTTOMRIGHT', 0, -5)
announceFrame.texture = announceFrame:CreateTexture('BACKGROUND')
announceFrame.texture:SetSize(16, 16)
announceFrame.texture:SetTexture('Interface\\AddOns\\AstralKeys\\Media\\speaker.tga')
announceFrame.texture:SetPoint('LEFT', announceFrame, 'LEFT')


announceFrame.string = announceFrame:CreateFontString('ARTWORK')
announceFrame.string:SetFont(FONT_CONTENT, FONT_SIZE)
announceFrame.string:SetPoint('TOPLEFT', announceFrame, 'TOPLEFT')
--announceFrame.string:SetText('Report to')

local partyAnnounce = CreateFrame('BUTTON', nil, announceFrame)
partyAnnounce:SetSize(15, 15)
partyAnnounce:SetNormalFontObject(FONT_OBJECT_CENTRE)
partyAnnounce:SetHighlightFontObject(FONT_OBJECT_HIGHLIGHT)
partyAnnounce:SetText('P')
partyAnnounce:GetFontString():SetTextColor(76/255, 144/255, 255/255, 1)

partyAnnounce:SetPoint('LEFT', announceFrame.texture, 'RIGHT', 5, 0)

partyAnnounce:SetScript('OnClick', function()
	e.AnounceCharacterKeys('PARTY')
	end)

local guildAnnounce = CreateFrame('BUTTON', nil, announceFrame)
guildAnnounce:SetSize(15, 15)
guildAnnounce:SetNormalFontObject(FONT_OBJECT_CENTRE)
guildAnnounce:SetHighlightFontObject(FONT_OBJECT_HIGHLIGHT)
guildAnnounce:SetText('G')
guildAnnounce:GetFontString():SetTextColor(38/255, 214/255, 25/255, 1)

guildAnnounce:SetPoint('LEFT', partyAnnounce, 'RIGHT')

guildAnnounce:SetScript('OnClick', function()
	e.AnounceCharacterKeys('GUILD')
	end)

quickOptionsFrame:SetScript('OnShow', function(self)
	partyAnnounce:Disable()
	guildAnnounce:Disable()
	end)

quickOptionsFrame:SetScript('OnHide', function(self)
	partyAnnounce:Enable()
	guildAnnounce:Enable()
	end)

-- Tooltip AstralKeyFrame
-----------------------------------------------------

local mouseOverFrame = CreateFrame('FRAME', 'astralMouseOver', AstralKeyFrame)
mouseOverFrame:SetSize(156, 200)
mouseOverFrame:SetFrameStrata('TOOLTIP')

mouseOverFrame.tex = mouseOverFrame:CreateTexture('ARTWORK')
mouseOverFrame.tex:SetAllPoints()
mouseOverFrame.tex:SetColorTexture(0, 0, 0)

mouseOverFrame.text = mouseOverFrame:CreateFontString('ARTWORK')
mouseOverFrame.text:SetFont(FONT_CONTENT, 14)
mouseOverFrame.text:SetPoint('TOPLEFT', mouseOverFrame, 'TOPLEFT', 8, -8)
mouseOverFrame.text:SetWordWrap(true)
mouseOverFrame.text:SetWidth(150)
mouseOverFrame.text:SetJustifyH('LEFT')

mouseOverFrame:Hide()

function mouseOverFrame:SetText(text)
	mouseOverFrame.text:SetText(text)
end

function mouseOverFrame:AdjustHeight()
	self:SetWidth(150)
	self:SetHeight(self.text:GetStringHeight() + 14)
	self.tex:ClearAllPoints()
	self.tex:SetAllPoints()
end

function mouseOverFrame:AdjustSize(width)
	self.text:SetWidth(width or self.text:GetStringWidth())
	self:SetHeight(self.text:GetStringHeight() + 14)
	self:SetWidth((width or self.text:GetStringWidth()) + 14)
	self.tex:ClearAllPoints()
	self.tex:SetAllPoints()
end

-- Affix Frames
-----------------------------------------------------

local affixFrame = CreateFrame('FRAME', 'affixFrame', AstralKeyFrame)
affixFrame:SetSize(200, 70)
affixFrame:SetPoint('TOPLEFT', logo, 'BOTTOMLEFT', 5, -10)

local affixHeader = CreateHeader(self, affixFrame, 'affixHeader', 175, 20, 'Affixes:', 12)
affixHeader:SetPoint('TOPLEFT', affixFrame, 'TOPLEFT')

local affixOne = CreateFrame('FRAME', 'AstralAffixOne', affixFrame)
affixOne.aid = e.GetAffix(1)

affixOne:SetSize(100, 20)
affixOne:SetPoint('TOPLEFT', affixHeader, 'BOTTOMLEFT', 10, -5)
affixOne.string = affixOne:CreateFontString('ARTWORK')
affixOne.string:SetFont(FONT_CONTENT, FONT_SIZE + 2)
affixOne.string:SetPoint('LEFT', affixOne, 'LEFT', 25, 0)

affixOne.texture = affixOne:CreateTexture('ARTWORK')
affixOne.texture:SetSize(20, 20)
affixOne.texture:SetPoint('LEFT', affixOne, 'LEFT')
affixOne.texture:SetTexture(nil)

function affixOne:UpdateInfo()
	self.aid = e.GetAffix(1)
	if self.aid ~= 0 and self.aid then
		self.string:SetText(C_ChallengeMode.GetAffixInfo(self.aid))
		self.texture:SetTexture(select(3, C_ChallengeMode.GetAffixInfo(self.aid)))
	else
		self.string:SetText('')
		self.texture:SetTexture('')
	end
end

affixOne:SetScript('OnEnter', function(self)
	if tonumber(self.aid) == 0 or not self.aid then return end

	astralMouseOver:SetText(select(2, C_ChallengeMode.GetAffixInfo(self.aid)))
	astralMouseOver:AdjustSize(150)
	astralMouseOver:SetPoint('TOPLEFT', self, 'BOTTOMRIGHT', -15, 10)
	astralMouseOver:Show()

	end)

affixOne:SetScript('OnLeave', function()
	astralMouseOver:Hide()
	end)

local affixTwo = CreateFrame('FRAME', 'AstralAffixTwo', affixFrame)
affixTwo.aid = e.GetAffix(2)

affixTwo:SetSize(100, 20)
affixTwo:SetPoint('TOPLEFT', affixOne, 'BOTTOMLEFT', 0, -5)
affixTwo.string = affixTwo:CreateFontString('ARTWORK')
affixTwo.string:SetFont(FONT_CONTENT, FONT_SIZE + 2)
affixTwo.string:SetPoint('LEFT', affixTwo, 'LEFT', 25, 0)

affixTwo.texture = affixTwo:CreateTexture('ARTWORK')
affixTwo.texture:SetSize(20, 20)
affixTwo.texture:SetPoint('LEFT', affixTwo, 'LEFT')
affixTwo.texture:SetTexture(nil)

function affixTwo:UpdateInfo()
	self.aid = e.GetAffix(2)
	if self.aid ~= 0 and self.aid then
		self.string:SetText(C_ChallengeMode.GetAffixInfo(self.aid))
		self.texture:SetTexture(select(3, C_ChallengeMode.GetAffixInfo(self.aid)))
	else
		self.string:SetText('')
		self.texture:SetTexture('')
	end
end

affixTwo:SetScript('OnEnter', function(self)
	if tonumber(self.aid) == 0 or not self.aid then return end

	astralMouseOver:SetText(select(2, C_ChallengeMode.GetAffixInfo(self.aid)))
	astralMouseOver:AdjustSize(150)
	astralMouseOver:SetPoint('TOPLEFT', self, 'BOTTOMRIGHT', -15, 10)
	astralMouseOver:Show()

	end)

affixTwo:SetScript('OnLeave', function()
	astralMouseOver:Hide()
	end)

local affixThree = CreateFrame('FRAME', 'AstralAffixThree', affixFrame)
affixThree.aid = e.GetAffix(3)

affixThree:SetSize(100, 20)
affixThree:SetPoint('TOPLEFT', affixOne, 'TOPRIGHT', 10, 0)
affixThree.string = affixThree:CreateFontString('ARTWORK')
affixThree.string:SetFont(FONT_CONTENT, FONT_SIZE + 2)
affixThree.string:SetPoint('LEFT', affixThree, 'LEFT', 25, 0)

affixThree.texture = affixThree:CreateTexture('ARTWORK')
affixThree.texture:SetSize(20, 20)
affixThree.texture:SetPoint('LEFT', affixThree, 'LEFT')
affixThree.texture:SetTexture(nil)

function affixThree:UpdateInfo()
	self.aid = e.GetAffix(3)
	if self.aid ~= 0 and self.aid then
		self.string:SetText(C_ChallengeMode.GetAffixInfo(self.aid))
		self.texture:SetTexture(select(3, C_ChallengeMode.GetAffixInfo(self.aid)))
	else
		self.string:SetText('')
		self.texture:SetTexture('')
	end
end

affixThree:SetScript('OnEnter', function(self) 
	if tonumber(self.aid) == 0 or not self.aid then return end

	astralMouseOver:SetText(select(2, C_ChallengeMode.GetAffixInfo(self.aid)))
	astralMouseOver:AdjustSize(150)
	astralMouseOver:SetPoint('TOPLEFT', self, 'BOTTOMRIGHT', -15, 10)
	astralMouseOver:Show()

	end)

affixThree:SetScript('OnLeave', function()
	astralMouseOver:Hide()
	end)

-- Character Frames
----------------------------------------------------------------
local characterFrame = CreateFrame('FRAME', 'astralCharacterFrame', AstralKeyFrame)
characterFrame:SetSize(215, 320)
characterFrame:SetPoint('TOPLEFT', affixFrame, 'BOTTOMLEFT', 0, -10)

local characterHeader = CreateHeader(self, characterFrame, 'affixHeader', 175, 20, 'Characters', 10)
characterHeader:SetPoint('TOPLEFT', characterFrame, 'TOPLEFT')

local characterContent = CreateFrame('FRAME', 'AstralCharacterContent', characterFrame)

characterContent.slider = characterContent:CreateTexture('BACKGROUND')
characterContent.slider:SetSize(8, 8)
characterContent.slider:SetColorTexture(0.2, 0.2, 0.2)
characterContent.slider:SetAlpha(.2)

characterContent:SetScript('OnEnter', function()
	AstralCharacterContent.slider:SetAlpha(1)
	end)

characterContent:SetScript('OnLeave', function()
	AstralCharacterContent.slider:SetAlpha(.2)
	end)

-- Key Frames
----------------------------------------------------------------

local contentFrame = CreateFrame('FRAME', 'AstralContentFrame', AstralKeyFrame)
contentFrame:SetSize(375, 390)
contentFrame:SetPoint('TOPLEFT', AstralKeyFrame, 'TOPLEFT', 255, -95)
contentFrame:EnableMouseWheel(true)

contentFrame.slider = contentFrame:CreateTexture('BACKGROUND')
contentFrame.slider:SetColorTexture(0.2, 0.2, 0.2)
contentFrame.slider:SetSize(8, 8)
contentFrame.slider:SetPoint('TOPLEFT', contentFrame, 'TOPRIGHT')
contentFrame.slider:SetAlpha(0.2)


function contentFrame:ResetSlider()
	offset = 0
	contentFrame.slider:SetPoint('TOPLEFT', contentFrame, 'TOPRIGHT')
end

contentFrame:SetScript('OnMouseWheel', function(self, delta)
	if #sortedTable < 26 then return end

	if delta < 0 then -- Scroll down
		if (#sortedTable - offset) > 25 then
			offset = offset - delta
			e.UpdateFrames()
		end			
	else
		if offset > 0 then -- Scroll up
			offset = offset - delta
			e.UpdateFrames()
		end
	end  

	contentFrame.slider:ClearAllPoints()
	contentFrame.slider:SetPoint('TOPLEFT', contentFrame, 'TOPRIGHT', 0, -offset/(#sortedTable - 25) * 365)

	end)

contentFrame:SetScript('OnEnter', function()
	contentFrame.slider:SetAlpha(1)
	end)

contentFrame:SetScript('OnLeave', function()
	contentFrame.slider:SetAlpha(0.2)
	end)

local keyButton = CreateButton(contentFrame, 'keyButton', 75, 20, 'Level', FONT_OBJECT_CENTRE, FONT_OBJECT_HIGHLIGHT)
keyButton:SetPoint('BOTTOMLEFT', contentFrame, 'TOPLEFT')
keyButton:SetScript('OnClick', function()
	contentFrame:ResetSlider()
	if e.GetSortMethod() ~= 'level' then
		e.SetOrientation(0)
	else
		e.SetOrientation(1 - e.GetOrientation())
	end
	e.SetSortMethod('level')
	e.UpdateFrames()

	end)

local mapButton = CreateButton(contentFrame, 'mapButton', 190, 20, 'Dungeon', FONT_OBJECT_CENTRE, FONT_OBJECT_HIGHLIGHT)
mapButton:SetPoint('LEFT', keyButton, 'RIGHT')
mapButton:SetScript('OnClick', function()
	contentFrame:ResetSlider()
	if e.GetSortMethod() ~= 'map' then
		e.SetOrientation(0)
	else
		e.SetOrientation(1 - e.GetOrientation())
	end
	e.SetSortMethod('map')
	e.UpdateFrames()

	end)

local nameButton = CreateButton(contentFrame, 'nameButton', 100, 20, 'Player', FONT_OBJECT_CENTRE, FONT_OBJECT_HIGHLIGHT)
nameButton:SetPoint('LEFT', mapButton, 'RIGHT')
nameButton:SetScript('OnClick', function()
	contentFrame:ResetSlider()
	if e.GetSortMethod() ~= 'name' then
		e.SetOrientation(0)
	else
		e.SetOrientation(1 - e.GetOrientation())
	end
	e.SetSortMethod('name')
	e.UpdateFrames()

	end)

local completeButton = CreateButton(contentFrame, 'completeButton', 30, 20, '10+', FONT_OBJECT_CENTRE, FONT_OBJECT_HIGHLIGHT)
completeButton:SetPoint('LEFT', nameButton, 'RIGHT')
completeButton:SetScript('OnClick', function()
	contentFrame:ResetSlider()
	if e.GetSortMethod() ~= 'weeklyCache' then
		e.SetOrientation(0)
	else
		e.SetOrientation(1 - e.GetOrientation())
	end
	e.SetSortMethod('weeklyCache')
	e.UpdateFrames()

	end)

AstralKeyFrame:SetScript('OnKeyDown', function(self, key)
	if key == 'ESCAPE' then
		self:SetPropagateKeyboardInput(false)
		self:Hide()
	end
	end)

AstralKeyFrame:SetScript('OnShow', function(self)
	self:SetPropagateKeyboardInput(true)
	affixOne:UpdateInfo()
	affixTwo:UpdateInfo()
	affixThree:UpdateInfo()
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

	showOffline:SetChecked(e.GetShowOffline())
	minKeyLevel:SetValue(e.GetMinKeyLevel())

	characterTable = e.DeepCopy(AstralCharacters)
	sortedTable = e.DeepCopy(AstralKeys)

	e.UpdateTables(sortedTable)
	e.SortTable(sortedTable, e.GetSortMethod())

	if #sortedTable > 26 then
		contentFrame.slider:Show()
	else
		contentFrame.slider:Hide()
	end

	if e.GetViewMode() == 1 then
		AstralKeyFrame:SetWidth(405)
		affixFrame:Hide()
		astralCharacterFrame:Hide()
		AstralKeyFrame.centreDivider:Hide()
		AstralContentFrame:ClearAllPoints()
		AstralContentFrame:SetPoint('TOPLEFT', AstralKeyFrame, 'TOPLEFT', 5, -95)
		toggleButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\menu.tga')
		toggleButton:SetHighlightTexture('Interface\\AddOns\\AstralKeys\\Media\\menu_highlight.tga', 'BLEND')
	end

	local id = e.CharacterID()
	local endIndex

	if id then

		characters[1] = CreateCharacterFrame(characterFrame, nil, characterTable[id].name, nil, false)
		characters[1]:SetPoint('TOPLEFT', characterHeader, 'BOTTOMLEFT', 0, -5)

		characterContent:SetSize(215, 260)
		characterContent:SetPoint('TOPLEFT', characterHeader, 'BOTTOMLEFT', 0, -39)

		table.remove(characterTable, id)

		if #characterTable < 9 then
			endIndex = #characterTable
		else
			endIndex = 8
		end

		for i = 1, endIndex do
			characters[i+1] = CreateCharacterFrame(characterFrame, nil, characterTable[i].name, nil, false)
			characters[i+1]:SetPoint('TOPLEFT', characterContent, 'TOPLEFT', 0, -34*(i - 1) - 4)
		end
	else
		characterContent:SetSize(215, 290)
		characterContent:SetPoint('TOPLEFT', characterHeader, 'BOTTOMLEFT', 0, -5)

		if #characterTable < 10 then
			endIndex = #characterTable
		else
			endIndex = 9
		end

		for i = 1, endIndex do
			characters[i] = CreateCharacterFrame(characterFrame, nil, characterTable[i].name, nil, false)
			characters[i]:SetPoint('TOPLEFT', characterContent, 'TOPLEFT', 0, -34*(i-1) - 4)
		end
	end

	characterContent.slider:SetPoint('TOPLEFT', characterContent, 'TOPRIGHT', 0, -10)

	if #characterTable > 8 then
		characterContent.slider:Show()
	else
		characterContent.slider:Hide()
	end

	characterContent:SetScript('OnMouseWheel', function(self, delta)
		if #characterTable < 9 then return end

		if delta < 0 then -- Scroll down
			if (#characterTable - characterOffset) > 8 then
				characterOffset = characterOffset - delta
				e.UpdateCharacterFrames()
			end
			
		else
			if characterOffset > 0 then -- Scroll up
				characterOffset = characterOffset - delta
				e.UpdateCharacterFrames()
			end
		end

		characterContent.slider:ClearAllPoints()
		characterContent.slider:SetPoint('TOPLEFT', characterContent, 'TOPRIGHT', 0, characterContent:GetHeight() * -characterOffset/(#characterTable - #characters))

		end)

	-- MAX 25
	if #sortedTable < 26 then
		indexEnd = #sortedTable
	else
		indexEnd = 25
	end

	for i = 1, indexEnd do
		name, keyLevel, mapID, class, usable, realm, completed = sortedTable[i].name, sortedTable[i].level, sortedTable[i].map, sortedTable[i].class, sortedTable[i].usable, sortedTable[i].realm, sortedTable[i].weeklyCache

		nameFrames[i] = CreateNameFrame(contentFrame, name, class, realm)		
		keyFrames[i] = CreateKeyFrame(contentFrame, keyLevel)
		mapFrames[i] = CreateMapFrame(contentFrame, mapID, usable, keyLevel)
		completedFrames[i] = CreateCompleteFrame(contentFrame, completed)


		keyFrames[i]:SetPoint('TOPLEFT', keyButton, 'BOTTOMLEFT', 5, (i-1) * -15 - 3)
		mapFrames[i]:SetPoint('TOPLEFT', mapButton, 'BOTTOMLEFT', 5, (i-1) * -15 - 3)
		nameFrames[i]:SetPoint('TOPLEFT', nameButton, 'BOTTOMLEFT', 5, (i-1) * -15 - 3)
		completedFrames[i]:SetPoint('TOPLEFT', completeButton, 'BOTTOMLEFT', 5, (i-1) * -15, -3)
	end

	e.UpdateFrames()
	e.UpdateCharacterFrames()

end

function e.UpdateAffixes()
	if not init then return end
	AstralAffixOne:UpdateInfo()
	AstralAffixTwo:UpdateInfo()
	AstralAffixThree:UpdateInfo()
end

function e.WipeFrames()
	wipe(AstralCharacters)
	wipe(characterTable)
	e.GetBestClear()

	if init then
		AstralContentFrame.slider:Hide()
		AstralCharacterContent.slider:Hide()
		characterTable = e.DeepCopy(AstralCharacters)
		if playerCharacter then
			playerCharacter:UpdateInformation(e.PlayerName())
			table.remove(characterTable, e.CharacterID())
		end
		for i = 1, #characters do
			characters[i]:UpdateInformation('')
		end
		for i = 1, #characterTable do
			characters[i]:UpdateInformation(characterTable[i].name)
		end
	end

	wipe(AstralKeys)
	wipe(sortedTable)

	for i = 1, #nameFrames do
		nameFrames[i]:SetNameInfo('')
		keyFrames[i]:SetKeyInfo(-1)
		mapFrames[i]:SetMapInfo(-1)
		completedFrames[i]:SetCompletedInfo(0)
	end
	--e.FindKeyStone(true)
end

function e.UpdateFrames()
	if not init then return end

	local name, keyLevel, mapID, class, usable, realm, index

	--sortedTable = e.DeepCopy(AstralKeys)

	sortedTable = e.UpdateTables(sortedTable)

	e.SortTable(sortedTable, e.GetSortMethod())

	if #sortedTable > 25 then
		AstralContentFrame.slider:Show()
	else
		AstralContentFrame.slider:Hide()
	end

	if #sortedTable < 26 then
		indexEnd = #sortedTable
	else
		indexEnd = 25
	end

	if #sortedTable < #nameFrames then
		for i = 1, indexEnd do
			index = i + offset
			local name, keyLevel, mapID, class, usable, realm, completed = sortedTable[index].name, sortedTable[index].level, sortedTable[index].map, sortedTable[index].class, sortedTable[index].usable, sortedTable[index].realm, sortedTable[index].weeklyCache
			nameFrames[i]:SetNameInfo(name, class, realm)
			keyFrames[i]:SetKeyInfo(keyLevel)
			mapFrames[i]:SetMapInfo(mapID, usable, keyLevel)
			completedFrames[i]:SetCompletedInfo(completed)
		end
		for i = indexEnd + 1, #nameFrames do
			nameFrames[i]:SetNameInfo('', nil, nil)
			keyFrames[i]:SetKeyInfo(-1)
			mapFrames[i]:SetMapInfo(-1, nil, nil)
			completedFrames[i]:SetCompletedInfo(0)
		end
	else
		for i = 1, indexEnd do
			index = i + offset
			local name, keyLevel, mapID, class, usable, realm, completed = sortedTable[index].name, sortedTable[index].level, sortedTable[index].map, sortedTable[index].class, sortedTable[index].usable, sortedTable[index].realm, sortedTable[index].weeklyCache
			if nameFrames[i] then
				nameFrames[i]:SetNameInfo(name, class, realm)
				keyFrames[i]:SetKeyInfo(keyLevel)
				mapFrames[i]:SetMapInfo(mapID, usable, keyLevel)
				completedFrames[i]:SetCompletedInfo(completed)
			else
				nameFrames[i] = CreateNameFrame(AstralContentFrame, name, class, realm)
				keyFrames[i] = CreateKeyFrame(AstralContentFrame, keyLevel)
				mapFrames[i] = CreateMapFrame(AstralContentFrame, mapID, usable, keyLevel)
				completedFrames[i] = CreateCompleteFrame(contentFrame, completed)

				keyFrames[i]:SetPoint('TOPLEFT', keyButton, 'BOTTOMLEFT', 5, (i-1) * -15 - 3)
				mapFrames[i]:SetPoint('TOPLEFT', mapButton, 'BOTTOMLEFT', 5, (i-1) * -15 - 3)
				nameFrames[i]:SetPoint('TOPLEFT', nameButton, 'BOTTOMLEFT', 5, (i-1) * -15 - 3)
				completedFrames[i]:SetPoint('TOPLEFT', completeButton, 'BOTTOMLEFT', 5, (i-1) * -15 - 3)
			end
		end
	end

end

function e.UpdateCharacterFrames()
	if not init then return end
	characterTable = e.DeepCopy(AstralCharacters)

	if e.CharacterID() then
		characters[1]:UpdateInformation(e.PlayerName())
		table.remove(characterTable, e.CharacterID())
		for i = 2, #characters do
			if characterTable[i-1] then
				characters[i]:UpdateInformation(characterTable[i + characterOffset - 1]['name'])
			else
				characters[i]:UpdateInformation('')
			end	
		end
	else
		for i = 1, #characters do
			if characterTable[i] then
				characters[i]:UpdateInformation(characterTable[i + characterOffset]['name'])
			else
				characters[i]:UpdateInformation('')
			end
		end
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
SlashCmdList['ASTRALKEYSV'] = function(msg) e.VersionCheck() end
--SlashCmdList['AK'] = handler;