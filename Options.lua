local ADDON, e = ...

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

