local ADDON, e = ...

local BACKDROP = {
bgFile = "Interface/Tooltips/UI-Tooltip-Background",
edgeFile = nil, tile = true, tileSize = 16, edgeSize = 16,
insets = {left = 0, right = 0, top = 0, bottom = 0}
}

local BACKDROP2 = {
bgFile = "Interface/Tooltips/UI-Tooltip-Background",
edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16, edgeSize = 1,
insets = {left = 0, right = 0, top = 0, bottom = 0}
}

local POSITIONS = {
	[1] = 'LEFT',
	[2] = 'CENTER',
	[3] = 'RIGHT',
}

local BACKDROPBUTTON = {
bgFile = nil,
edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16, edgeSize = 1,
insets = {left = 0, right = 0, top = 0, bottom = 0}
}

local FONT_HEADER = "Interface\\AddOns\\AstralKeys\\Media\\big_noodle_titling.TTF"
local FONT_CONTENT = "Interface\\AddOns\\AstralKeys\\Media\\Lato-Regular.TTF"
local FONT_SIZE = 13

local FONT_OBJECT_LEFT = CreateFont("FONT_OBJECT_LEFT")
FONT_OBJECT_LEFT:SetFont(FONT_CONTENT, FONT_SIZE)
FONT_OBJECT_LEFT:SetJustifyH('LEFT')
FONT_OBJECT_LEFT:SetTextColor(1, 1, 1)

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

local function CreateButton(parent, btnID, width, height, text, fontobject, highlightfont)
	local button = CreateFrame('BUTTON', btnID, parent)
	button.ID = btnID
	button.sort = 0
	button:SetSize(width, height)

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

	return button
end


local frame = CreateFrame('FRAME', 'AstralOptionsFrame', UIParent)
frame:SetFrameStrata('DIALOG')
frame:SetFrameLevel(5)
frame:SetHeight(600)
frame:SetWidth(800)
frame:SetPoint('CENTER', UIParent, 'CENTER')
frame:SetBackdrop(BACKDROP)
frame:SetBackdropColor(0, 0, 0, 1)
frame:SetMovable(true)
frame:EnableKeyboard(true)
frame:SetPropagateKeyboardInput(true)
frame:SetClampedToScreen(true)
frame:Hide()

local logo = frame:CreateTexture('ARTWORK')
logo:SetSize(64, 64)
logo:SetTexture('Interface\\AddOns\\AstralKeys\\Media\\Astral.tga')
logo:SetPoint('TOPLEFT', frame, 'TOPLEFT', 10, -10)

frame.centreDivider = frame:CreateTexture('BACKGROUND')
frame.centreDivider:SetSize(1, 475)
frame.centreDivider:SetPoint('TOPLEFT', logo, 'BOTTOMLEFT', 140, -10)
frame.centreDivider:SetColorTexture(0.2, 0.2, 0.2)

local title = e.CreateHeader(frame, 'title', 260, 20, 'Astral Keys Options', 26)
title:SetPoint('LEFT', logo, 'RIGHT', 10, -10)

local closeButton = CreateFrame('BUTTON', nil, frame)
closeButton:SetSize(15, 15)
closeButton:SetNormalFontObject(FONT_OBJECT_CENTRE)
closeButton:SetHighlightFontObject(FONT_OBJECT_HIGHLIGHT)
closeButton:SetText('X')
closeButton:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', -10, -10)

closeButton:SetScript('OnClick', function()
	AstralOptionsFrame:Hide()
end)

local function CreateOptionButton()

	local button = CreateFrame('BUTTON', nil, frame)
	button:SetSize(140, 20)
	button:SetNormalFontObject(FONT_OBJECT_LEFT)
	button:SetBackdropBorderColor(0, 0, 0)
	button:SetBackdropColor(85/255, 85/255, 85/255, .6)

	local texture = button:CreateTexture()
	texture:SetColorTexture(1, 1, 1, .1)
	texture:SetPoint('TOPLEFT', 1, -1)
	texture:SetPoint('BOTTOMRIGHT', -1, 1)
	button:SetHighlightTexture(texture)

	return button
end

local generalButton = CreateOptionButton()
generalButton:SetText('General Options')
generalButton:SetPoint('TOPLEFT', logo, 'BOTTOMLEFT', 0, -10)

local reportButton = CreateOptionButton()
reportButton:SetText('Report options')
reportButton:SetPoint('TOPLEFT', generalButton, 'BOTTOMLEFT')


local mapButton = CreateOptionButton()
mapButton:SetText('Map Names')
mapButton:SetPoint('TOPLEFT', reportButton, 'BOTTOMLEFT', 0, 0)