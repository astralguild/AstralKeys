local _, e = ...

local BACKDROP = {
bgFile = "Interface/Tooltips/UI-Tooltip-Background",
edgeFile = nil, tile = true, tileSize = 16, edgeSize = 16,
insets = {left = 0, right = 0, top = 0, bottom = 0}
}

local BACKDROPBUTTON = {
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

local FONT_OBJECT_EDITBOX = CreateFont("FONTOBJECT_EDITBOX")
FONTOBJECT_EDITBOX:SetFont(FONT_CONTENT, FONT_SIZE - 1)
FONTOBJECT_EDITBOX:SetJustifyH('RIGHT')
FONTOBJECT_EDITBOX:SetTextColor(1, 1, 1)

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


function e.CreateLabel(parent, text, pos)
	local label = parent:CreateFontString('ARTWORK')
	label:SetFont(FONT_CONTENT, FONT_SIZE)
	if pos == 'left' then
		label:SetPoint('RIGHT', parent, 'LEFT', -5, 0)
	elseif pos == 'right' then
		label:SetPoint('LEFT', parent, 'RIGHT', 5, 0)
	end
	label:SetText(text)

	return label

end

function e.CreateEditBox(parent, name, width, label, minValue, maxValue)
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
		editBox.label = e.CreateLabel(editBox, label, 'left')
	end

	function editBox:SetValue(value)
		self:SetNumber(value)
	end

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

function e.CreateHeader(self, parent, name, width, height, text, fontAdjust)
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