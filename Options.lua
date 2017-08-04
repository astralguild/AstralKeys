local ADDON, e = ...

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
frame:SetHeight(400)
frame:SetWidth(500)
frame:SetPoint('CENTER', UIParent, 'CENTER')
frame:SetBackdropColor(0, 0, 0, 1)
frame:SetMoveable(true)
frame:EnableKeyboard(true)
frame:SetPropegateKeyboardInput(true)
frame:SetClampedToScreen(true)
frame:Hide()

local logo = frame:CreateTexture('ARTWORK')
logo:SetSize(64, 64)
logo:SetTexture('Interface\\AddOns\\AstralKeys\\Media\\Astral.tga')
logo:SetPoint('TOPLEFT', frame, 'TOPLEFT', 10, -10)

local title = e.CreateHeader(frame, 'title', 220, 20, 'Astral Keys Options', 26)
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

local generalButton = CreateButton(frame, 'akGeneral', 125, 20, 'General Options', FONT_OBJECT_CENTRE, FONT_OBJECT_HIGHLIGHT)
generalButton:SetPoint('TOPLEFT', logo, 'BOTTOMLEFT', 0, -10)

local mapButton = CreateButton(frame, 'akmapButton', 200, 20, 'Map Names', FONT_OBJECT_CENTRE, FONT_OBJECT_HIGHLIGHT)
mapButton:SetPoint('LEFT', generalButton, 'RIGHT', 10, 0)