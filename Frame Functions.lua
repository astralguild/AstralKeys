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
menuFrame.background = menuFrame:CreateTexture(nil, 'BACKGROUND')
menuFrame.background:SetAllPoints(menuFrame)
menuFrame.background:SetColorTexture(0, 0, 0, 1)
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
	btn:SetBackdropColor(33/255, 33/255, 33/255)
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

	dtbl[#dtbl]:SetPoint('TOPLEFT', self, 'TOPLEFT', 12, -20*(#dtbl) -5)
end

local reportFrame = CreateFrame('FRAME', 'AstralReportFrame', UIParent)
reportFrame:Hide()

reportFrame:SetFrameStrata('TOOLTIP')
reportFrame:SetWidth(100)
reportFrame:SetHeight(70)
reportFrame.background = reportFrame:CreateTexture(nil, 'BACKGROUND')
reportFrame.background:SetAllPoints(reportFrame)
reportFrame.background:SetColorTexture(0, 0, 0, 1)
reportFrame:EnableKeyboard(true)

local partyButton = CreateFrame('BUTTON', nil, reportFrame)
partyButton:SetSize(90, 20)
partyButton:SetBackdrop(BACKDROP2)
partyButton:SetBackdropBorderColor(0, 0, 0, 0)
partyButton:SetBackdropColor(25/255, 25/255, 25/255)
partyButton:SetNormalFontObject(InterUIBlack_Normal)

local partyHighlightTexture = partyButton:CreateTexture()
partyHighlightTexture:SetColorTexture(0.5, 0.5, 0.5, .2)
partyHighlightTexture:SetPoint('TOPLEFT', 1, -1)
partyHighlightTexture:SetPoint('BOTTOMRIGHT', -1, 1)
partyButton:SetHighlightTexture(partyHighlightTexture)

partyButton:SetPoint('TOPLEFT', reportFrame, 'TOPLEFT', 5, -5)

partyButton:SetText(L['PARTY'])
partyButton:SetScript('OnClick', function()
	e.AnnounceCharacterKeys('PARTY')
	reportFrame:Hide()
	end)

local guildButton = CreateFrame('BUTTON', nil, reportFrame)
guildButton:SetSize(90, 20)
guildButton:SetBackdrop(BACKDROP2)
guildButton:SetBackdropBorderColor(0, 0, 0, 0)
guildButton:SetBackdropColor(25/255, 25/255, 25/255)
guildButton:SetNormalFontObject(InterUIBlack_Normal)

local guildHighlightTexture = guildButton:CreateTexture()
guildHighlightTexture:SetColorTexture(0.5, 0.5, 0.5, .2)
guildHighlightTexture:SetPoint('TOPLEFT', 1, -1)
guildHighlightTexture:SetPoint('BOTTOMRIGHT', -1, 1)
guildButton:SetHighlightTexture(guildHighlightTexture)

guildButton:SetPoint('TOPLEFT', partyButton, 'BOTTOMLEFT', 0, -1)

guildButton:SetText(L['GUILD'])
guildButton:SetScript('OnClick', function()
	e.AnnounceCharacterKeys('GUILD')
	reportFrame:Hide()
	end)

local cancelButton = CreateFrame('BUTTON', nil, reportFrame)
cancelButton:SetSize(90, 20)
cancelButton:SetBackdrop(BACKDROP2)
cancelButton:SetBackdropBorderColor(0, 0, 0, 0)
cancelButton:SetBackdropColor(25/255, 25/255, 25/255)
cancelButton:SetNormalFontObject(InterUIBlack_Normal)

local cancelHighlightTexture = cancelButton:CreateTexture()
cancelHighlightTexture:SetColorTexture(0.5, 0.5, 0.5, .2)
cancelHighlightTexture:SetPoint('TOPLEFT', 1, -1)
cancelHighlightTexture:SetPoint('BOTTOMRIGHT', -1, 1)
cancelButton:SetHighlightTexture(cancelHighlightTexture)

cancelButton:SetPoint('TOPLEFT', guildButton, 'BOTTOMLEFT', 0, -1)

cancelButton:SetText(L['CANCEL'])
cancelButton:SetScript('OnClick', function()
	reportFrame:Hide()
	end)


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