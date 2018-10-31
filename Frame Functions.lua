local e, L = unpack(select(2, ...))

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

e.FONT = {}
e.FONT.HEADER = "Interface\\AddOns\\AstralKeys\\Media\\big_noodle_titling.TTF"
e.FONT.CONTENT = "Interface\\AddOns\\AstralKeys\\Media\\Lato-Regular.TTF"
e.FONT.SIZE = 13
e.FONT.OBJECT = {}

local FONT_HEADER = e.FONT.HEADER

--local FONT_HEADER = "Interface\\AddOns\\AstralKeys\\Media\\stop.ttf"
local FONT_CONTENT = e.FONT.CONTENT
local FONT_SIZE = e.FONT.SIZE
local BACKDROP = e.BACKDROP

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

function e.CreateLabel(parent, text, pos)
	local label = parent:CreateFontString(nil, 'ARTWORK', 'InterUIRegular_Normal')
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
	editBox:SetBackdrop({
						bgFile = nil,
						edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = e:Scale(16), edgeSize = e:Scale(2),
						insets = {left = e:Scale(2), right = e:Scale(2), top = e:Scale(2), bottom = e:Scale(2)}
						})
	editBox:SetBackdropBorderColor(85/255, 85/255, 85/255)
	--editBox:SetFontObject(FONT_OBJECT_EDITBOX)
	editBox:SetFontObject(InterUIRegular_Normal)
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

function e.CreateCheckBox(parent, label, width)
	local checkbox = CreateFrame('CheckButton', nil, parent)
	checkbox:SetSize(width or 200, 20)
	checkbox:SetBackdrop(nil)
	checkbox:SetBackdropBorderColor(85/255, 85/255, 85/255)
	checkbox:SetNormalFontObject(InterUIRegular_Normal)
	checkbox:SetText(label)

	checkbox:SetNormalTexture(nil)
	checkbox:SetBackdropColor(0, 0, 0)

	checkbox:SetPushedTextOffset(1,-1)

	local tex = checkbox:CreateTexture('PUSHED_TEXTURE_BOX', 'BACKGROUND')
	tex:SetSize(12, 12)
	tex:SetPoint('LEFT', checkbox, 'LEFT', -2, 0)
	tex:SetTexture('Interface\\AddOns\\AstralKeys\\Media\\box2.tga')
	tex:SetVertexColor(0.3, 0.3, 0.3)

	checkbox.t = checkbox:CreateTexture('PUSHEDTEXTURE', 'BACKGROUND')
	checkbox.t:SetSize(12, 12)
	checkbox.t:SetPoint('CENTER', tex, 'CENTER', 0, 0)
	checkbox.t:SetTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\baseline-done-small@2x.tga')
	checkbox:SetCheckedTexture(checkbox.t)

	if label then
		checkbox:GetFontString():SetPoint('LEFT', tex, 'RIGHT', 5, 0)
	end

	return checkbox
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

menuFrame:SetScript('OnKeyDown', function(self, key)
	if key == 'ESCAPE' then
		AstralMenuFrame:Hide()
	end
	end)

menuFrame:SetScript('OnShow', function(self)
	self:SetPropagateKeyboardInput(true)
	end)

menuFrame.title = menuFrame:CreateFontString(nil, 'ARTWORK', 'InterUIMedium_Normal')
--menuFrame.title:SetFont(FONT_CONTENT, FONT_SIZE - 1)
menuFrame.title:SetJustifyH('LEFT')
menuFrame.title:SetSize(120, 15)
menuFrame.title:SetPoint('TOPLEFT', menuFrame, 'TOPLEFT', 10, -5)

local function HideMenu()
	menuFrame:Hide()
end

function menuFrame:SetUnit(unitID)
	self.unit = unitID
	if e.FrameListShown() == 'GUILD' then
		self.title:SetText(e.UnitName(unitID))
	else
		self.title:SetText(e.FriendName(unitID))
	end
end

function menuFrame:NewObject(name, func, onShow)
	local btn = CreateFrame('BUTTON', nil, menuFrame)
	btn:SetSize(135, 20)
	btn:SetBackdrop(BACKDROP2)
	btn:SetBackdropBorderColor(0, 0, 0, 0)
	btn:SetBackdropColor(25/255, 25/255, 25/255)
	btn:SetNormalFontObject(InterUIBlack_Normal)

	local texture = btn:CreateTexture()
	texture:SetColorTexture(0.5, 0.5, 0.5, .2)
	texture:SetPoint('TOPLEFT', 1, -1)
	texture:SetPoint('BOTTOMRIGHT', -1, 1)
	btn:SetHighlightTexture(texture)

	btn:SetText(name)

	btn:SetScript('OnClick', func)

	if onShow and type(onShow) == 'function' then
		btn:SetScript('OnShow', onShow)
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

	dtbl[#dtbl]:SetPoint('TOPLEFT', self, 'TOPLEFT', 15, -20*(#dtbl) -5)
end

function e.AddEscHandler(frame)
	if not frame and type(frame) ~= 'table' then
		error('frame expcted, got '.. type(frame))
	end
	if frame:GetScript('OnKeyDown') then
		frame:HookScript('OnKeyDown', function(self, key)
			if key == 'ESCAPE' then
				self:SetPropagateKeyboardInput(false)
				self:Hide()
			end
		end)
	else
		frame:EnableKeyboard(true)
		frame:SetPropagateKeyboardInput(true)
		frame:SetScript('OnKeyDown', function(self, key)
			if key == 'ESCAPE' then
				self:SetPropagateKeyboardInput(false)
				self:Hide()
			end
		end)
	end
	if frame:GetScript('OnShow') then
		frame:HookScript('OnShow', function(self)
			self:SetPropagateKeyboardInput(true)
		end)
	else
		frame:SetScript('OnShow', function(self)
			self:SetPropagateKeyboardInput(true)
		end)
	end
end