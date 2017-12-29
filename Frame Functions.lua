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

e.FONT = {}
e.FONT.HEADER = "Interface\\AddOns\\AstralKeys\\Media\\big_noodle_titling.TTF"
e.FONT.CONTENT = "Interface\\AddOns\\AstralKeys\\Media\\Lato-Regular.TTF"
e.FONT.SIZE = 13
e.FONT.OBJECT = {}

local FONT_HEADER = e.FONT.HEADER
local FONT_CONTENT = e.FONT.CONTENT
local FONT_SIZE = e.FONT.SIZE
local BACKDROP = e.BACKDROP
local BACKDROPBUTTON = e.BACKDROPBUTTON

local FONT_OBJECT_EDITBOX = CreateFont("FONTOBJECT_EDITBOX")
FONTOBJECT_EDITBOX:SetFont(FONT_CONTENT, FONT_SIZE - 1)
FONTOBJECT_EDITBOX:SetJustifyH('RIGHT')
FONTOBJECT_EDITBOX:SetTextColor(1, 1, 1)
e.FONT.OBJECT.EDITBOX = FONT_OBJECT_EDITBOX

local FONT_OBJECT_RIGHT = CreateFont("FONT_OBJECT_RIGHT")
FONT_OBJECT_RIGHT:SetFont(FONT_CONTENT, FONT_SIZE)
FONT_OBJECT_RIGHT:SetJustifyH('RIGHT')
FONT_OBJECT_RIGHT:SetTextColor(1, 1, 1)
e.FONT.OBJECT.RIGHT = FONT_OBJECT_RIGHT

local FONT_OBJECT_LEFT = CreateFont("FONT_OBJECT_LEFT")
FONT_OBJECT_LEFT:SetFont(FONT_CONTENT, FONT_SIZE)
FONT_OBJECT_LEFT:SetJustifyH('LEFT')
FONT_OBJECT_LEFT:SetTextColor(1, 1, 1)
e.FONT.OBJECT.LEFT = FONT_OBJECT_LEFT

local FONT_OBJECT_CENTRE = CreateFont("FONT_OBJECT_CENTRE")
FONT_OBJECT_CENTRE:SetFont(FONT_CONTENT, FONT_SIZE)
FONT_OBJECT_CENTRE:SetJustifyH('CENTER')
FONT_OBJECT_CENTRE:SetTextColor(1, 1, 1)
e.FONT.OBJECT.CENTRE = FONT_OBJECT_CENTRE

local FONT_OBJECT_HIGHLIGHT = CreateFont("FONT_OBJECT_HIGHLIGHT")
FONT_OBJECT_HIGHLIGHT:SetFont(FONT_CONTENT, FONT_SIZE)
FONT_OBJECT_HIGHLIGHT:SetJustifyH('CENTER')
FONT_OBJECT_HIGHLIGHT:SetTextColor(192/255, 192/255, 192/255)
e.FONT.OBJECT.HIGHLIGHT = FONT_OBJECT_HIGHLIGHT

local FONT_OBJECT_DISABLED = CreateFont("FONT_OBJECT_DISABLED")
FONT_OBJECT_DISABLED:SetFont(FONT_CONTENT, FONT_SIZE)
FONT_OBJECT_DISABLED:SetJustifyH('CENTER')
FONT_OBJECT_DISABLED:SetTextColor(122/255, 122/255, 122/255)
e.FONT.OBJECT.DISABLED = FONT_OBJECT_DISABLED

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

function e.CreateEditBox(parent, width, label, minValue, maxValue, labelPos)
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
		if self:GetNumber() < self.minValue then
			self:SetNumber(self.minValue)
		end
		if self:GetNumber() > self.maxValue then
			self:SetNumber(self.maxValue)
		end
		end)

	return editBox

end

function e.CreateHeader(parent, name, width, height, text, fontAdjust)
	local self = parent:CreateFontString('BACKGROUND')
	self:SetWidth(width)
	self:SetFont(FONT_HEADER, FONT_SIZE + fontAdjust)
	self:SetText(text)
	self:SetJustifyH('LEFT')

	self.t = parent:CreateTexture('BACKGROUND')
	self.t:SetPoint('BOTTOMLEFT', self, 'BOTTOMLEFT')
	self.t:SetSize(width, 1)
	self.t:SetColorTexture(1, 1, 1)
	self.t:SetGradientAlpha('HORIZONTAL', 1, 1, 1, 0.8, 0, 0 , 0, 0)

	return self
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
	tex:SetPoint('LEFT', checkbox, 'LEFT', -2, 0)
	tex:SetTexture('Interface\\AddOns\\AstralKeys\\Media\\box2.tga')
	tex:SetVertexColor(0.3, 0.3, 0.3)

	checkbox.t = checkbox:CreateTexture('PUSHEDTEXTURE', 'BACKGROUND')
	checkbox.t:SetSize(8, 8)
	checkbox.t:SetPoint('CENTER', tex, 'CENTER', 0, 0)
	checkbox.t:SetColorTexture(.9, .9, .9)
	checkbox:SetCheckedTexture(checkbox.t)

	checkbox:SetDisabledFontObject(FONT_OBJECT_DISABLED)

	checkbox:GetFontString():SetPoint('LEFT', tex, 'RIGHT', 5, 0)

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

local BACKDROP2 = {
bgFile = "Interface/Tooltips/UI-Tooltip-Background",
edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16, edgeSize = 1,
insets = {left = 0, right = 0, top = 0, bottom = 0}
}

local menuFrame = CreateFrame('FRAME', 'AstralMenuFrame', UIParent)
menuFrame:Hide()
menuFrame.dtbl = {}

menuFrame:SetFrameStrata('TOOLTIP')
menuFrame:SetWidth(150)
menuFrame:SetHeight(40)
menuFrame:SetBackdrop(BACKDROP2)
menuFrame:SetBackdropBorderColor(0, 0, 0)
menuFrame:SetBackdropColor(35/255, 35/255, 35/255)
menuFrame:EnableKeyboard(true)
--menuFrame:SetPropagateKeyboardInput(true)

menuFrame:SetScript('OnKeyDown', function(self, key)
	if key == 'ESCAPE' then
		AstralMenuFrame:Hide()
	end
	end)

menuFrame:SetScript('OnShow', function(self)
	--AstralKeyFrame:SetPropagateKeyboardInput(false)
	self:SetPropagateKeyboardInput(true)
	end)

menuFrame:SetScript('OnHide', function(self)
	AstralKeyFrame:SetPropagateKeyboardInput(true)
	end)

menuFrame.title = menuFrame:CreateFontString('ARTWORK')
menuFrame.title:SetFont(FONT_CONTENT, FONT_SIZE - 1)
menuFrame.title:SetJustifyH('LEFT')
menuFrame.title:SetSize(120, 15)
menuFrame.title:SetPoint('TOPLEFT', menuFrame, 'TOPLEFT', 10, -5)

local function HideMenu()
	menuFrame:Hide()
end

function menuFrame:SetUnit(unitID)
	self.unit = unitID
	self.title:SetText(e.UnitName(unitID))
end

function menuFrame:NewObject(name, func, onShow)
	local btn = CreateFrame('BUTTON', nil, menuFrame)
	btn:SetSize(140, 20)
	btn:SetBackdrop(BACKDROP2)
	btn:SetBackdropBorderColor(0, 0, 0, 0)
	btn:SetBackdropColor(25/255, 25/255, 25/255)
	btn:SetNormalFontObject(FONT_OBJECT_CENTRE)

	local texture = btn:CreateTexture()
	texture:SetColorTexture(1, 1, 1, .2)
	texture:SetPoint('TOPLEFT', 1, -1)
	texture:SetPoint('BOTTOMRIGHT', -1, 1)
	btn:SetHighlightTexture(texture)

	btn:SetText(name)

	btn:SetScript('OnClick', func)

	if onShow and type(onShow) == 'function' then
		btn:SetScript('OnShow', function(self) onShow(self) end)
	end

	return btn
end

function menuFrame:AddSelection(name, onClick, onShow)
	local dtbl = self.dtbl
	dtbl[#dtbl + 1] = self:NewObject(name, onClick, onShow)
	self:SetHeight(#dtbl * 20 + 30)

	if onClick then
		dtbl[#dtbl]:HookScript('OnClick', HideMenu)
	end

	dtbl[#dtbl]:SetPoint('TOPLEFT', self, 'TOPLEFT', 5, -20*(#dtbl) -5)	
end