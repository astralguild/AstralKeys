local _, e = ...
local BACKDROPBUTTON = {
bgFile = nil,
edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16, edgeSize = 1,
insets = {left = 0, right = 0, top = 0, bottom = 0}
}

local FONT_HEADER = "Interface\\AddOns\\AstralKeys\\Media\\big_noodle_titling.TTF"
local FONT_CONTENT = "Interface\\AddOns\\AstralKeys\\Media\\Lato-Regular.TTF"
local FONT_SIZE = 12

local FONTOBJECT_EDITBOX = CreateFont("FONTOBJECT_EDITBOX")
FONTOBJECT_EDITBOX:SetFont(FONT_CONTENT, FONT_SIZE - 1)
FONTOBJECT_EDITBOX:SetJustifyH('RIGHT')
FONTOBJECT_EDITBOX:SetTextColor(1, 1, 1)


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
	editBox:SetFontObject(FONTOBJECT_EDITBOX)
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