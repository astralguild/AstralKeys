local _, addon = ...

function addon.CreateCheckBox(parent, label, width)
	local checkbox = CreateFrame('CheckButton', nil, parent, "BackdropTemplate")
	checkbox:SetSize(width or 200, 20)
	checkbox:SetBackdrop(nil)
	checkbox:SetBackdropBorderColor(85/255, 85/255, 85/255)
	checkbox:SetNormalFontObject(InterUIRegular_Normal)
	checkbox:SetText(label)

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

local function AcquireButtonFromPool(parent)
	local button
	button = table.remove(parent.pool, 1)

	return button
end

local function CreateButton(parent)
	local button = AcquireButtonFromPool(parent)

	if not button then
		button = CreateFrame('BUTTON', nil, parent)
		button:SetSize(140, 20)	

		button:SetNormalFontObject(InterUIMedium_Normal)
		local texture = button:CreateTexture()
		texture:SetColorTexture(0.5, 0.5, 0.5, 1)
		texture:SetBlendMode('BLEND')
		texture:SetPoint('TOPLEFT', 1, -1)
		texture:SetPoint('BOTTOMRIGHT', -1, 1)
		texture:SetGradient('HORIZONTAL', CreateColor(.5, .5, .5, .8), CreateColor(.5, .5, .5, 0))
		button:SetHighlightTexture(texture)

		button.menuTexture = button:CreateTexture(nil, 'ARTWORK')
		button.menuTexture:SetSize(16, 16)
		button.menuTexture:SetTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\baseline_keyboard_arrow_right_white_24dp')
		button.menuTexture:SetVertexColor(0.8, 0.8, 0.8, 0.8)
		button.menuTexture:SetPoint('RIGHT', button, 'RIGHT', -5, 0)

		function button:Recycle()
			button:SetText(nil)
			button:SetScript('OnClick', nil)
			button:SetScript('OnShow', nil)
		end
	end

	return button
end

local function CloseSubMenu(frame)
	if not frame then return end

	local nextTierFrame, tier = frame:GetName():match('([%a]+)(%d)')
	nextTierFrame = nextTierFrame .. (tier + 1)
	if _G[nextTierFrame] then _G[nextTierFrame]:Hide() end
end

local function CloseDropDownMenu(frame)
	if not frame then return end

	local baseFrame, tier = frame:GetName():match('([%a]+)(%d)')
	for i = 1, tier do
		if _G[baseFrame .. i] then _G[baseFrame .. i]:Hide() end
	end
end

function addon.CreateDropDownFrame(name, level, parent)
	local frame = CreateFrame('FRAME', 'AstralMenuFrame' .. name .. level, parent, "BackdropTemplate")
	frame:Hide()
	frame.tier = level
	frame.buttons = {}
	frame.pool = {}
	frame.unit = ''
	frame.units = {}

	frame:SetFrameStrata('TOOLTIP')
	frame:SetWidth(10)
	frame:SetHeight(40)
	frame:SetFrameLevel(level * 5)

	frame:SetBackdrop(BACKDROP2)
	frame:SetBackdropBorderColor(33/255, 33/255, 33/255, 0.8)
	frame:SetBackdropColor(0, 0, 0)

	frame.background = frame:CreateTexture(nil, 'BACKGROUND')
	frame.background:SetAllPoints(frame)
	frame.background:SetColorTexture(0, 0, 0, 1)
	frame:EnableKeyboard(true)
	frame:SetPropagateKeyboardInput(true)

	frame:SetScript('OnKeyDown', function(self, key)
		if key == 'ESCAPE' then
			if self.tier == 1 then
				self:SetPropagateKeyboardInput(false)
			end
			self:Hide()
		end
	end)

	frame:SetScript('OnShow', function(self)
		self:SetPropagateKeyboardInput(true)
	end)

	frame.title = frame:CreateFontString(nil, 'ARTWORK', 'InterUIBlack_Normal')
	frame.title:SetNonSpaceWrap(false)
	frame.title:SetJustifyH('LEFT')
	frame.title:SetSize(150, 15)
	frame.title:SetPoint('TOPLEFT', frame, 'TOPLEFT', 5, -5)

	function frame:SetTitle(text)
		self.title:SetText(text)

		local stringLength = self.title:GetUnboundedStringWidth()
		self.title:SetWidth(stringLength + 10)
		self:AdjustWidth(stringLength)

	end

	function frame:AddUnit(unit)
		self.units[unit] = true
	end

	function frame:RemoveUnit(unit)
		self.units[unit] = nil
	end

	function frame:WipeUnits()
		wipe(self.units)
	end

	function frame:GetUnits()
		return self.units
	end

	function frame:SetUnit(unit)
		self.unit = unit
	end

	function frame:AdjustWidth(overrideWidth)
		local longestStringLength = 0
		if not overrideWidth then
			for i = 1, #self.buttons do
				local btnStringLength = self.buttons[i]:GetFontString():GetUnboundedStringWidth() + (self.buttons[i].menuTexture:IsShown() and 20 or 0)
				longestStringLength = math.max(longestStringLength, btnStringLength)
			end
			longestStringLength = math.max(longestStringLength, self.title:GetUnboundedStringWidth())
		else
			longestStringLength = overrideWidth
		end

		self:SetWidth(longestStringLength + 20)
		for i = 1, #self.buttons do
			self.buttons[i]:SetWidth(longestStringLength)
		end
	end

	frame:SetScript('OnShow', function(self)
		self:AdjustWidth()
	end)

	function frame:AddButton(name1, onClick, onShow, onEnter, subMenu, subFrame)
		local button = CreateButton(self)
		button:SetWidth(self:GetWidth() - 20)
		button:SetPoint('TOPLEFT', self.title, 'BOTTOMLEFT', 5, -20*(#self.buttons))
		button:SetText(name1)

		local stringLength = button:GetFontString():GetUnboundedStringWidth()	

		if not subMenu then
			button.menuTexture:Hide()
			button:SetScript('OnClick', function(self)
				if onClick then onClick(self) end
				CloseDropDownMenu(self:GetParent())
			end)
			button:SetScript('OnEnter', function(self)
				CloseSubMenu(self:GetParent())
			end)			
		else
			button:SetWidth(self:GetWidth() + 15)
			stringLength = stringLength + 40 -- to account for sub menu texture and padding on both sides of it
			button.menuTexture:Show()
			button:SetScript('OnEnter', function(self)
				subFrame:SetPoint('TOPLEFT', self, 'TOPRIGHT', -5, 0)
				subFrame:SetShown(true)
			end)
			-- Show an arrow texture to indicate a menu
			button:SetScript('OnClick', function(self)
				if onClick then onClick(self) end
				--subFrame:SetPoint('TOPLEFT', self, 'TOPRIGHT', -5, 0)
				--subFrame:SetShown(not subFrame:IsShown())
			end)
		end

		if onEnter then
			button:HookScript('OnEnter', onEnter)
		end

		button:SetScript('OnShow', onShow)
		table.insert(self.buttons, button)
		self:SetHeight(#self.buttons * 20 + 30)

		self:AdjustWidth()

		return button
	end

	frame:SetScript('OnHide', function(self)
		self:WipeUnits()
	end)

	function frame:ClearButtons()
		for i = #self.buttons, 1, -1 do
			self.buttons[i]:Recycle()
			table.insert(self.pool, table.remove(self.buttons, i))
		end
	end

	return frame
end

function addon.AddEscHandler(frame)
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