local _, e = ...

e.BACKDROP = {
bgFile = "Interface/Tooltips/UI-Tooltip-Background",
edgeFile = nil, tile = true, tileSize = 16, edgeSize = 16,
insets = {left = 0, right = 0, top = 0, bottom = 0}
}

e.BACKDROPBUTTON = {
bgFile = nil,
edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16, edgeSize = 1,
insets = {left = 0, right = 0, top = 0, bottom = 0}
}

e.FONT_HEADER = "Interface\\AddOns\\AstralKeys\\Media\\big_noodle_titling.TTF"
e.FONT_CONTENT = "Interface\\AddOns\\AstralKeys\\Media\\Lato-Regular.TTF"
e.FONT_SIZE = 13

local FONT_HEADER = e.FONT_HEADER
local FONT_CONTENT = e.FONT_CONTENT
local FONT_SIZE = e.FONT_SIZE
local BACKDROP = e.BACKDROP
local BACKDROPBUTTON = e.BACKDROPBUTTON

local FONT_OBJECT_EDITBOX = CreateFont("FONTOBJECT_EDITBOX")
FONTOBJECT_EDITBOX:SetFont(FONT_CONTENT, FONT_SIZE - 1)
FONTOBJECT_EDITBOX:SetJustifyH('RIGHT')
FONTOBJECT_EDITBOX:SetTextColor(1, 1, 1)

local FONT_OBJECT_RIGHT = CreateFont("FONT_OBJECT_RIGHT")
FONT_OBJECT_RIGHT:SetFont(FONT_CONTENT, FONT_SIZE)
FONT_OBJECT_RIGHT:SetJustifyH('RIGHT')
FONT_OBJECT_RIGHT:SetTextColor(1, 1, 1)

local FONT_OBJECT_LEFT = CreateFont("FONT_OBJECT_LEFT")
FONT_OBJECT_LEFT:SetFont(FONT_CONTENT, FONT_SIZE)
FONT_OBJECT_LEFT:SetJustifyH('LEFT')
FONT_OBJECT_LEFT:SetTextColor(1, 1, 1)

local FONT_OBJECT_CENTRE = CreateFont("FONT_OBJECT_CENTRE")
FONT_OBJECT_CENTRE:SetFont(FONT_CONTENT, FONT_SIZE)
FONT_OBJECT_CENTRE:SetJustifyH('CENTER')
FONT_OBJECT_CENTRE:SetTextColor(1, 1, 1)

local FONT_OBJECT_HIGHLIGHT = CreateFont("FONT_OBJECT_HIGHLIGHT")
FONT_OBJECT_HIGHLIGHT:SetFont(FONT_CONTENT, FONT_SIZE)
FONT_OBJECT_HIGHLIGHT:SetJustifyH('CENTER')
FONT_OBJECT_HIGHLIGHT:SetTextColor(192/255, 192/255, 192/255)

local FONT_OBJECT_DISABLED = CreateFont("FONT_OBJECT_DISABLED")
FONT_OBJECT_DISABLED:SetFont(FONT_CONTENT, FONT_SIZE)
FONT_OBJECT_DISABLED:SetJustifyH('CENTER')
FONT_OBJECT_DISABLED:SetTextColor(122/255, 122/255, 122/255)

function e.CreateButton(name, parent, width, height, text, texture)
	local button = CreateFrame('BUTTON', name, parent)
	button:SetSize(width, height)
	button:SetNormalFontObject(FONT_OBJECT_CENTRE)
	button:SetHighlightFontObject(FONT_OBJECT_HIGHLIGHT)

	if text then
		button:SetText(text)
	end

	if texture then
		button:SetNormalTexture(texture)
	end

	return button
end

function e.CreateLabel(parent, text, pos)
	local label = parent:CreateFontString('ARTWORK')
	label:SetFont(FONT_CONTENT, FONT_SIZE)
	if pos == 'LEFT' then
		label:SetPoint('RIGHT', parent, 'LEFT', -5, 0)
	elseif pos == 'RIGHT' then
		label:SetPoint('LEFT', parent, 'RIGHT', 5, 0)
	end
	label:SetText(text)

	return label

end

function e.CreateEditBox(parent, type, width, label, minValue, maxValue, labelPos)
	local editBox = CreateFrame('EditBox', nil, parent)
	editBox.maxValue = maxValue
	editBox.minValue = minValue
	editBox:SetSize(width, 18)
	editBox:SetBackdrop(BACKDROPBUTTON)
	editBox:SetBackdropBorderColor(85/255, 85/255, 85/255)
	editBox:SetFontObject(FONT_OBJECT_EDITBOX)
	editBox:SetTextInsets(2, 2, 0, 0)
	editBox:SetAutoFocus(false)
	editBox:SetNumeric(true)
	editBox:SetScript("OnEnterPressed", function(self)
		self:ClearFocus()
		end)
	editBox:SetScript("OnEscapePressed", function(self)
		self:ClearFocus()
		end)

	if label then
		editBox.label = e.CreateLabel(editBox, label, labelPos)
	end

	function editBox:SetValue(value)
		self:SetNumber(value)
	end

	editBox:SetScript('OnDisable', function(self)
		self.label:SetTextColor(122/255, 122/255, 122/255)
		end)

	editBox:SetScript('OnEnable', function(self)
		self.label:SetTextColor(1, 1, 1)
		end)


	editBox:SetScript("OnEditFocusLost", function(self)
		if self:GetNumber() < minValue then
			self:SetNumber(self.minValue)
		end
		if self:GetNumber() > maxValue then
			self:SetNumber(self.maxValue)
		end
		end)

	return editBox

end

function e.CreateHeader(parent, name, width, height, text, fontAdjust)
	local frame = CreateFrame('FRAME', 'header_' .. name, parent)
	frame:SetSize(width, height)

	frame.s = frame:CreateFontString('BACKGROUND')
	frame.s:SetFont(FONT_HEADER, FONT_SIZE + fontAdjust)
	frame.s:SetPoint('BOTTOMLEFT', frame, 'BOTTOMLEFT')
	frame.s:SetText(text)

	frame.t = frame:CreateTexture('BACKGROUND')
	frame.t:SetPoint('BOTTOMLEFT', frame, 'BOTTOMLEFT')
	frame.t:SetSize(width, 1)
	frame.t:SetColorTexture(1, 1, 1)
	frame.t:SetGradientAlpha('HORIZONTAL', 1, 1, 1, 0.8, 0, 0 , 0, 0)

	function frame:SetText(text)
		self.s:SetText(text)
	end

	return frame

end

function e.CreateCheckButton(parent, text)
	local self = CreateFrame('BUTTON', nil, parent)
	self:SetSize(140, 20)
	self:SetNormalFontObject(FONT_OBJECT_LEFT)
	self:SetBackdropBorderColor(0, 0, 0)
	self:SetBackdropColor(85/255, 85/255, 85/255, .6)
	self:SetText(text)

	self.checkbox = CreateFrame('CheckButton', nil, parent)
	self.checkbox:SetSize(12, 12)
	self:SetBackdrop(BACKDROPBUTTON)
	self:SetBackdropBorderColor(85/255, 85/255, 85/255)
	--self:SetText(label)
	self.checkbox:SetNormalTexture(nil)
	self.checkbox:SetBackdropColor(0, 0, 0)



	return self
end
--[[
function e.CreateCheckBox(parent, label, textPos)
	local checkbox = CreateFrame('CheckButton', nil, parent)
	checkbox:SetSize(12, 12)
	checkbox:SetBackdrop(BACKDROPBUTTON)
	checkbox:SetBackdropBorderColor(85/255, 85/255, 85/255)
	checkbox:SetText(label)

	checkbox:SetNormalTexture(nil)
	checkbox:SetBackdropColor(0, 0, 0)
	if textPos == 'LEFT' then
		checkbox:SetNormalFontObject(FONT_OBJECT_RIGHT)
		checkbox:GetFontString():SetPoint('RIGHT', checkbox, 'LEFT', -5, 0)
	else
		checkbox:SetNormalFontObject(FONT_OBJECT_LEFT)
		checkbox:GetFontString():SetPoint('LEFT', checkbox, 'RIGHT', 5, 0)
	end

	checkbox:SetPushedTextOffset(0,0)

	checkbox.t = checkbox:CreateTexture('PUSHEDTEXTURE', 'BACKGROUND')
	checkbox.t:SetSize(6, 6)
	checkbox.t:SetPoint('TOPLEFT', checkbox, 'TOPLEFT', 3, -3)
	checkbox.t:SetColorTexture(.9, .9, .9)
	checkbox:SetCheckedTexture(checkbox.t)

	checkbox:SetDisabledFontObject(FONT_OBJECT_DISABLED)

	return checkbox
end]]


function e.CreateCheckBox(parent, label, width)
	local checkbox = CreateFrame('CheckButton', nil, parent)
	checkbox:SetSize(width or 200, 20)
	checkbox:SetBackdrop(nil)
	checkbox:SetBackdropBorderColor(85/255, 85/255, 85/255)
	checkbox:SetNormalFontObject(FONT_OBJECT_LEFT)
	checkbox:SetText(label)

	checkbox:SetNormalTexture(nil)
	checkbox:SetBackdropColor(0, 0, 0)

	checkbox:SetPushedTextOffset(1,-1)

	local tex = checkbox:CreateTexture('PUSHED_TEXTURE_BOX', 'BACKGROUND')
	tex:SetSize(14, 14)
	tex:SetPoint('RIGHT', checkbox, 'RIGHT', -2, 0)
	tex:SetTexture('Interface\\AddOns\\AstralKeys\\Media\\box2.tga')
	tex:SetVertexColor(0.3, 0.3, 0.3)

	checkbox.t = checkbox:CreateTexture('PUSHEDTEXTURE', 'BACKGROUND')
	checkbox.t:SetSize(8, 8)
	checkbox.t:SetPoint('CENTER', tex, 'CENTER', 0, 0)
	checkbox.t:SetColorTexture(.9, .9, .9)
	checkbox:SetCheckedTexture(checkbox.t)

	checkbox:SetDisabledFontObject(FONT_OBJECT_DISABLED)

	return checkbox
end

-- Creates a skinned button for Astral Keys options
-- Backdrop highlight: yes
-- Font highlight: no
-- Border: no
function e.CreateOptionButton(parent, width)
	local self = CreateFrame('BUTTON', nil, parent)
	self:SetSize(width or 140, 20)
	self:SetNormalFontObject(FONT_OBJECT_LEFT)
	self:SetBackdropBorderColor(0, 0, 0)
	self:SetBackdropColor(85/255, 85/255, 85/255, .6)

	local texture = self:CreateTexture()
	texture:SetColorTexture(1, 1, 1, .1)
	texture:SetPoint('TOPLEFT')
	texture:SetPoint('BOTTOMRIGHT')
	self:SetHighlightTexture(texture)

	return self
end