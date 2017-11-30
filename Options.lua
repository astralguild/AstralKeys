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
edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 0, edgeSize = 1,
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

-- Re-write old CreateHeader to use this one instead!!!
local function CreateHeader(parent, name, width, height, text, fontAdjust)
	local fontString = parent:CreateFontString('BACKGROUND')
	fontString:SetFont(FONT_HEADER, FONT_SIZE + fontAdjust)
	fontString:SetText(text)

	local t = parent:CreateTexture('BACKGROUND')
	t:SetPoint('BOTTOMLEFT', fontString, 'BOTTOMLEFT')
	t:SetSize(width, 1)
	t:SetColorTexture(1, 1, 1)
	t:SetGradientAlpha('HORIZONTAL', 1, 1, 1, 0.8, 0, 0 , 0, 0)

	return fontString

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
frame:EnableMouse(true)
frame:RegisterForDrag('LeftButton')
frame:EnableKeyboard(true)
frame:SetPropagateKeyboardInput(true)
frame:SetClampedToScreen(true)
--frame:Hide()

frame:SetScript('OnDragStart', function(self)
	self:StartMoving()
	end)

frame:SetScript('OnDragStop', function(self)
	self:StopMovingOrSizing()
	end)

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

local generalButton = e.CreateOptionButton(AstralOptionsFrame)
generalButton:SetText('General Options')
generalButton:SetPoint('TOPLEFT', logo, 'BOTTOMLEFT', 0, -10)

local reportButton = e.CreateOptionButton(AstralOptionsFrame)
reportButton:SetText('Report options')
reportButton:SetPoint('TOPLEFT', generalButton, 'BOTTOMLEFT', 0, -1)


local mapButton = e.CreateOptionButton(AstralOptionsFrame)
mapButton:SetText('Map Names')
mapButton:SetPoint('TOPLEFT', reportButton, 'BOTTOMLEFT', 0, -1)


-- Content frame to anchor all option panels
-- 
local contentFrame = CreateFrame('FRAME', 'AstralFrame_OptionContent', frame)
contentFrame:SetPoint('TOPLEFT', frame.centreDivider, 'TOPLEFT', 5, 0)
contentFrame:SetBackdrop(BACKDROP)
contentFrame:SetBackdropColor(1, 0, 1)
contentFrame:SetSize(630, 500)

-- Content frame header, tells user what options they are looking at
-- 
contentFrame.header = CreateHeader(contentFrame, 'content_header', 150, 20, 'General Options', 10)
contentFrame.header:SetPoint('TOPLEFT', contentFrame, 'TOPLEFT', 5, 0)

local cf3 =CreateFrame('FRAME', nil, frame)
cf3:SetPoint('TOPLEFT', frame.centreDivider, 'TOPLEFT', 5, 0)
cf3:SetBackdrop(BACKDROP)
cf3:SetBackdropColor(1, 1, 0)
cf3:SetSize(210, 500)

local cf4 =CreateFrame('FRAME', nil, frame)
cf4:SetPoint('TOPLEFT', cf3, 'TOPRIGHT', 0, 0)
cf4:SetBackdrop(BACKDROP)
cf4:SetBackdropColor(0, 1, 0)
cf4:SetSize(210, 500)

local cf2 =CreateFrame('FRAME', nil, frame)
cf2:SetPoint('TOPLEFT', frame.centreDivider, 'TOPLEFT', 5, 0)
cf2:SetBackdrop(BACKDROP)
cf2:SetBackdropColor(0, 1, 1)
cf2:SetSize(315, 500)

local showOffLine = e.CreateCheckBox(contentFrame, 'Show offline guild members')
showOffLine:SetPoint('TOPLEFT', contentFrame.header, 'BOTTOMLEFT', 0, -10)

local test1 = e.CreateCheckBox(contentFrame, 'Show minimap button')
test1:SetPoint('LEFT', showOffLine, 'RIGHT', 10, 0)

local test2 = e.CreateCheckBox(contentFrame, '')
test2:SetPoint('TOPLEFT', contentFrame.header, 'BOTTOMLEFT', 420, -10)
