local _, e = ...

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

local offset, shownOffset = 0, 0
local characterOffset = 0

local name, keyLevel, mapID, class, realm, indexEnd

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
FONT_OBJECT_HIGHLIGHT:SetTextColor(126/255, 126/255, 126/255)

local sortedTable = {}
sortedTable.numShown = 0
sortedTable['guild'] = {}
sortedTable['friend'] = {}
local numShown = 0
local characters = {}
local characterTable = {}

local function MixIn(D, T)	
	for k,v in pairs(T) do
		if (type(v) == "function") and (force or (D[k] == nil)) then
			D[k] = v;
		end
	end
end

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
	button:SetMovable(true)

	function button:SetW(width)
		self:SetWidth(width)
		self.t:SetWidth(width - 10)
	end

	return button
end

local function CreateCharacterFrame(parent, frameName, unitName, bestKey, createDivider)

	local frame = CreateFrame('FRAME', frameName, parent)
	frame:SetSize(210, 31)
	frame:SetFrameLevel(5)

	frame.unit = unitName
	frame.bestKey = ''
	frame.currentKey = ''
	frame.unitClass = ''
	frame.bestMap = ''
	frame.weeklyAP = 0
	frame.realm = ''

	frame.name = frame:CreateFontString('ARTWORK')
	frame.name:SetJustifyH('LEFT')
	frame.name:SetSize(175, 15)
	frame.name:SetFont(FONT_CONTENT, FONT_SIZE)
	frame.name:SetPoint('TOPLEFT', frame, 'TOPLEFT')

	frame.keystone = frame:CreateFontString('ARTWORK')
	frame.keystone:SetJustifyH('LEFT')
	frame.keystone:SetSize(200, 15)
	frame.keystone:SetFont(FONT_CONTENT, FONT_SIZE)
	frame.keystone:SetPoint('BOTTOMLEFT', frame, 'BOTTOMLEFT', 10, 0)

	if createDivider then

		frame.divider = frame:CreateTexture('BACKGROUND')
		frame.divider:SetSize(125, 1)
		frame.divider:SetPoint('BOTTOMLEFT', frame, 'BOTTOMLEFT', 25)
		frame.divider:SetColorTexture(.3, .3, .3)

	end

	function frame:UpdateBestDungeon(characterID)
		if not characterID then return end
		self.bestKey = e.GetCharacterBestMap(characterID)
		self.bestMap = e.GetCharacterBestMap(characterID)

		self.name:SetText(WrapTextInColorCode(self.unit, select(4, GetClassColor(self.unitClass))) .. ' - ' .. self.bestKey)
	end

	function frame:UpdateInformation(characterID)
		if characterID then 
			self.cid = characterID
			self.unit = e.CharacterName(characterID)
			self.realm = e.CharacterRealm(characterID)
			self.unitClass = e.GetCharacterClass(characterID)
			self.bestKey = e.GetCharacterBestLevel(characterID)
			self.bestMap = e.GetCharacterBestMap(characterID)
			self.weeklyAP = e.GetWeeklyAP(self.bestKey)

			self.keystone:SetText(e.GetCharacterKey(self.unit .. '-' .. self.realm))

			if self.realm ~= e.PlayerRealm() then
				self.unit = self.unit .. ' (*)'
			end

			if self.bestKey ~= 0 then
				self.name:SetText(WrapTextInColorCode(self.unit, select(4, GetClassColor(self.unitClass))) .. ' - ' .. self.bestKey)
			else
				self.name:SetText(WrapTextInColorCode(self.unit, select(4, GetClassColor(self.unitClass))))
			end
		else
			self.name:SetText('')
			self.keystone:SetText('')
			self.cid = -1
		end
	end

	frame:SetScript('OnEnter', function(self)

		if self.weeklyAP > 0 then
			astralMouseOver:SetText(e.GetMapName(self.bestMap) .. '\n- ' .. e.ConvertToSI(self.weeklyAP * e.GetAKBonus()) .. ' AP in cache')
		else
			astralMouseOver:SetText('No mythic+ ran this week.')
		end

		astralMouseOver:AdjustSize()
		astralMouseOver:ClearAllPoints()
		astralMouseOver:SetPoint('TOPLEFT', frame, 'BOTTOMRIGHT', - 105, 20)
		astralMouseOver:Show()
		AstralCharacterContent.slider:SetAlpha(1)
		end)

	frame:SetScript('OnLeave', function()
		astralMouseOver:Hide()
		AstralCharacterContent.slider:SetAlpha(.2)
		end)

	return frame

end

local unit_frames = {}

local UnitFrame = {}
UnitFrame.__index = UnitFrame

function UnitFrame:NewFrame(parent)

	local self = CreateFrame('FRAME', nil, parent)
	self.unitID = 0

	self:EnableMouse(true)
	self:SetSize(400, 15)

	self.levelString = self:CreateFontString('ARTWORK')
	self.levelString:SetFont(FONT_CONTENT, FONT_SIZE)
	self.levelString:SetJustifyH('LEFT')
	self.levelString:SetSize(35, 15)
	self.levelString:SetPoint('TOPLEFT', self, 'TOPLEFT', 5, 0)

	self.dungeonString = self:CreateFontString('ARTWORK')
	self.dungeonString:SetFont(FONT_CONTENT, FONT_SIZE)
	self.dungeonString:SetJustifyH('LEFT')
	self.dungeonString:SetSize(175, 15)
	self.dungeonString:SetPoint('LEFT', self.levelString, 'RIGHT')

	self.nameString = self:CreateFontString('ARTWORK')
	self.nameString:SetFont(FONT_CONTENT, FONT_SIZE)
	self.nameString:SetJustifyH('LEFT')
	self.nameString:SetSize(165, 15)
	self.nameString:SetPoint('LEFT', self.dungeonString, 'RIGHT')

	self.weeklyTexture = self:CreateTexture('BACKGROUND')
	self.weeklyTexture:SetSize(15, 15)

	self.weeklyTexture:SetPoint('LEFT', self.nameString, 'RIGHT')
	self.weeklyTexture:SetTexture('Interface\\AddOns\\AstralKeys\\Media\\check.tga')
	self.weeklyTexture:Hide()

	self.unit = CreateFrame('FRAME', nil, self)
	self.unit:SetSize(170, 15)
	self.unit:SetPoint('RIGHT', self, 'RIGHT')
	self.unit:SetFrameLevel(10)
	self.unit:EnableMouse(true)

	self.unit:SetScript('OnMouseDown', function(self, button)
		if button == 'RightButton' then
			if AstralMenuFrame:IsShown() then
				AstralMenuFrame:Hide()
				return
			end

			if self:GetParent().unitID == 0 then return end

			AstralMenuFrame:ClearAllPoints()
			AstralMenuFrame:SetPoint('TOPLEFT', self, 'CENTER', 5, -5)
			AstralMenuFrame:SetUnit(self:GetParent().unitID)
			AstralMenuFrame:Show()
		end
	end)

	self.unit:SetScript('OnEnter', function(self)
		AstralContentFrame.slider:SetAlpha(1)
		end)

	self.unit:SetScript('OnLeave', function(self)
		astralMouseOver:Hide()
		AstralContentFrame.slider:SetAlpha(.2)
	end)

	self:SetScript('OnEnter', function(self)
		if UnitLevel('player') == 110 then
			if self.mapID ~= 0 then
				astralMouseOver:ClearAllPoints()
				astralMouseOver:SetPoint('TOPLEFT', self, 'CENTER', -85, 0)
				astralMouseOver:SetText(e.MapApText(self.mapID, self.keyLevel))
				astralMouseOver:AdjustSize()
				astralMouseOver:Show()
				AstralContentFrame.slider:SetAlpha(1)
			end
		end
	end)

	self:SetScript('OnLeave', function(self)
		astralMouseOver:Hide()
		AstralContentFrame.slider:SetAlpha(.2)
	end)

	return self
end

-- ff82c5ff BNet 'blue'

local UNIT_FUNCTION = {}

function e.AddUnitFunction(list, f)
	if type(list) ~= 'string' and list == '' then return end
	if type(f) ~= 'function' then return end

	if UNIT_FUNCTION[list] then
		error('Function already associated with the list ' .. list)
		return
	end
	UNIT_FUNCTION[list] = f
end

local function GuildUnitFunction(self, unit, class, mapID, keyLevel, cache, faction, btag)
	self.mapID = mapID
	self.keyLevel = keyLevel
	self.levelString:SetText(keyLevel)
	self.dungeonString:SetText(e.GetMapName(mapID))
	self.unitID = e.UnitID(unit)
	self.nameString:SetText(WrapTextInColorCode(Ambiguate(unit, 'GUILD') , select(4, GetClassColor(class))))
	self.weeklyTexture:SetShown(cache == 1)
end
e.AddUnitFunction('guild', GuildUnitFunction)

UNIT_FUNCTION['friend'] = function(self, unit, class, mapID, keyLevel, cache, faction, btag)
	self.mapID = mapID
	self.keyLevel = keyLevel
	self.levelString:SetText(keyLevel)
	self.dungeonString:SetText(e.GetMapName(mapID))
	self.weeklyTexture:SetShown(cache == 1)
	self.unitID = e.FriendID(unit)
	if btag then
		if tonumber(faction) == e.FACTION then
			self.nameString:SetText( string.format('%s (%s)', WrapTextInColorCode(btag:sub(1, btag:find('#') - 1), 'ff82c5ff'), WrapTextInColorCode(unit:sub(1, unit:find('-') - 1), select(4, GetClassColor(class)))))
		else
			self.nameString:SetText( string.format('%s (%s)', WrapTextInColorCode(btag:sub(1, btag:find('#') - 1), 'ff82c5ff'), WrapTextInColorCode(unit:sub(1, unit:find('-') - 1), 'ff9d9d9d')))
		end
	else
		self.nameString:SetText(WrapTextInColorCode(unit:sub(1, unit:find('-') - 1), select(4, GetClassColor(class))))
	end
end

function UnitFrame:SetUnit(...)
	UNIT_FUNCTION[e.FrameListShown()](self, ...)

	--[[
	self.mapID = mapID
	self.keyLevel = keyLevel
	self.levelString:SetText(keyLevel)
	self.dungeonString:SetText(e.GetMapName(mapID))
	if e.FrameListShown() == 'guild' then
		self.unitID = e.UnitID(unit)
		self.nameString:SetWidth(135)
		self.nameString:SetText(WrapTextInColorCode(Ambiguate(unit, 'GUILD') , select(4, GetClassColor(class))))
		self.weeklyTexture:SetShown(cache == 1)
	end
	if e.FrameListShown() == 'friend' then
		self.unitID = e.FriendID(unit)
		self.nameString:SetWidth(165)		
		if btag then
			if tonumber(faction) == e.FACTION then
				self.nameString:SetText( string.format('%s (%s)', WrapTextInColorCode(btag:sub(1, btag:find('#') - 1), 'ff82c5ff'), WrapTextInColorCode(unit:sub(1, unit:find('-') - 1), select(4, GetClassColor(class)))))
			else
				self.nameString:SetText( string.format('%s (%s)', WrapTextInColorCode(btag:sub(1, btag:find('#') - 1), 'ff82c5ff'), WrapTextInColorCode(unit:sub(1, unit:find('-') - 1), 'ff9d9d9d')))
			end
		else
			self.nameString:SetText(WrapTextInColorCode(unit:sub(1, unit:find('-') - 1), select(4, GetClassColor(class))))
		end
		self.weeklyTexture:Hide()
	end]]
end

function UnitFrame:ClearUnit()
	self.unitID = 0
	self.mapID = 0
	self.keyLevel = 0
	self.levelString:SetText('')
	self.dungeonString:SetText('')
	self.nameString:SetText('')
	self.weeklyTexture:Hide()
end

local function Whisper_OnShow(self)
	local isConnected = true
	if e.FrameListShown() == 'guild' then
		--inviteType = GetDisplayedInviteType(e.GuildMemberGuid(e.Unit(AstralMenuFrame.unit)))
		isConnected = e.GuildMemberOnline(e.Unit(AstralMenuFrame.unit))
	end
	if e.FrameListShown() == 'friend' then
		isConnected = e.IsFriendOnline(e.Friend(AstralMenuFrame.unit))
		--[[

		--inviteType = GetDisplayedInviteType(e.FriendGUID(e.Friend(AstralMenuFrame.unit)))
		if AstralFriends[AstralMenuFrame.unit][2] then
			local gaID = e.GetFriendGaID(AstralFriends[AstralMenuFrame.unit][2])
			if gaID then
				local _, _, client, _, _, faction = BNGetGameAccountInfo(gaID)

				if client == BNET_CLIENT_WOW then					
					local name = select(4, BNGetGameAccountInfo(gaID))
					if not name then
						isConnected = false
					end
				else
					isConnected = false
				end
			end
		else
			isConnected = e.IsFriendOnline(e.Friend(AstralMenuFrame.unit))
		end]]
	end
	self.isConnected = isConnected

	if not self.isConnected then
		self:SetText(WrapTextInColorCode(self:GetText(), 'ff9d9d9d'))
	else
		self:SetText('Whisper')
	end
end

local function SendWhisper(self)
	if not self.isConnected then return end

	if AstralKeysSettings.frameOptions.list == 'guild' then
		ChatFrame_SendTell(e.Unit(AstralMenuFrame.unit))
	else
		if AstralFriends[AstralMenuFrame.unit][2] then
			ChatFrame_SendSmartTell(e.FriendPresName(e.Friend(AstralMenuFrame.unit)))
		else
			ChatFrame_SendTell(e.Friend(AstralMenuFrame.unit))
		end
	end
end
AstralMenuFrame:AddSelection('Whisper', SendWhisper, Whisper_OnShow)

local function Invite_OnShow(self)
	local inviteType
	local isConnected = true
	if e.FrameListShown() == 'guild' then
		inviteType = GetDisplayedInviteType(e.GuildMemberGuid(e.Unit(AstralMenuFrame.unit)))
		isConnected = e.GuildMemberOnline(e.Unit(AstralMenuFrame.unit))
	end
	if e.FrameListShown() == 'friend' then
		isConnected = e.IsFriendOnline(e.Friend(AstralMenuFrame.unit))
		inviteType = GetDisplayedInviteType(e.FriendGUID(e.Friend(AstralMenuFrame.unit)))
		--[[		
		if AstralFriends[AstralMenuFrame.unit][2] then
			local gaID = e.GetFriendGaID(AstralFriends[AstralMenuFrame.unit][2])
			if gaID then
				local name = select(4, BNGetGameAccountInfo(gaID))
				if not name then
					isConnected = false
				end
			else
				isConnected = false
			end
		else
			isConnected = e.IsFriendOnline(e.Friend(AstralMenuFrame.unit))
		end]]
	end

	if inviteType == 'INVITE' then
		self:SetText('Invite')
	elseif inviteType == 'SUGGEST_INVITE' then
		self:SetText('Suggest Invite')
	elseif inviteType == 'REQUEST_INVITE' then
		self:SetText('Request Invite')
	end
	if not isConnected then
		self:SetText(WrapTextInColorCode(self:GetText(), 'ff9d9d9d'))
	end

	self.isConnected = isConnected
	self.inviteType = inviteType
end

local function InviteUnit(self)
	if not self.isConnected then return end
	
	if e.FrameListShown() == 'guild' then
		if self.inviteType == 'INVITE' then
			InviteToGroup(e.Unit(AstralMenuFrame.unit))
		elseif self.inviteType == 'REQUEST_INVITE' then
			RequestInviteFromUnit(e.Unit(AstralMenuFrame.unit))
		elseif self.inviteType == 'SUGGEST_INVITE' then
			InviteToGroup(e.Unit(AstralMenuFrame.unit))
		end
	end
	if e.FrameListShown() == 'friend' then
		if AstralFriends[AstralMenuFrame.unit][2] then -- bnet friend
			if self.inviteType == 'INVITE' then
				BNInviteFriend(e.FriendGAID(e.Friend(AstralMenuFrame.unit)))
			elseif self.inviteType == 'REQUEST_INVITE' then
				BNRequestInviteFriend(e.GetFriendGaID(AstralFriends[AstralMenuFrame.unit][2]))
			elseif self.inviteType == 'SUGGEST_INVITE' then
				BNInviteFriend(e.GetFriendGaID(AstralFriends[AstralMenuFrame.unit][2]))
			end			
		else
			if self.inviteType == 'INVITE' then
				BNInviteFriend(e.FriendGUID(e.Friend(AstralMenuFrame.unit)))
			elseif self.inviteType == 'REQUEST_INVITE' then
				BNRequestInviteFriend(e.FriendGUID(e.Friend(AstralMenuFrame.unit)))
			elseif self.inviteType == 'SUGGEST_INVITE' then
				BNInviteFriend(e.FriendGUID(e.Friend(AstralMenuFrame.unit)))
			end			
		end
	end
	-- GetDisplayedInviteType(guid)
	-- InviteToGroup(fullname)
	-- BNInviteFriend(gaID)
	-- RequestInviteFromUnit(fullname)
	-- BNRequestInviteFriend(gaID)
end
AstralMenuFrame:AddSelection('Invite', InviteUnit, Invite_OnShow)

AstralMenuFrame:AddSelection('Cancel', function() return AstralMenuFrame:Hide() end)

local AstralKeyFrame = CreateFrame('FRAME', 'AstralKeyFrame', UIParent)
AstralKeyFrame:SetFrameStrata('DIALOG')
AstralKeyFrame:SetWidth(675)
AstralKeyFrame:SetHeight(505)
AstralKeyFrame:SetPoint('CENTER', UIParent, 'CENTER')
AstralKeyFrame:EnableMouse(true)
AstralKeyFrame:SetBackdrop(BACKDROP)
AstralKeyFrame:SetBackdropColor(0, 0, 0, 1)
AstralKeyFrame:SetMovable(true)
AstralKeyFrame:RegisterForDrag('LeftButton')
AstralKeyFrame:EnableKeyboard(true)
AstralKeyFrame:SetPropagateKeyboardInput(true)
AstralKeyFrame:SetClampedToScreen(true)
AstralKeyFrame:Hide()
AstralKeyFrame.updateDelay = 0

local guildInfo = CreateFrame('FRAME', nil, AstralKeyFrame)
guildInfo:SetSize(125, 13)
guildInfo:SetPoint('BOTTOMRIGHT', AstralKeyFrame, 'BOTTOMRIGHT', -5, 5)
guildInfo:EnableMouse(true)
guildInfo:SetScript('OnMouseDown', function(self) 
	if not astralGuildInfo then
		local astralGuildInfo = CreateFrame('FRAME', 'astralGuildInfo', UIParent)
		astralGuildInfo:SetFrameLevel(8)
		astralGuildInfo:SetSize(200, 100)
		astralGuildInfo:SetBackdrop(BACKDROPBUTTON)
		astralGuildInfo:SetBackdropBorderColor(.2, .2, .2, 1)
		astralGuildInfo:SetPoint('BOTTOM', UIParent, 'TOP', 0, -300)

		astralGuildInfo.text = astralGuildInfo:CreateFontString('ARTWORK')
		astralGuildInfo.text:SetFont(FONT_CONTENT, FONT_SIZE)
		astralGuildInfo.text:SetPoint('TOP', astralGuildInfo,'TOP', 0, -10)
		astralGuildInfo.text:SetText('Visit Astral at')

		astralGuildInfo.editBox = CreateFrame('EditBox', nil, astralGuildInfo)
		astralGuildInfo.editBox:SetSize(180, 20)
		astralGuildInfo.editBox:SetPoint('TOP', astralGuildInfo.text, 'BOTTOM', 0, -10)

		astralGuildInfo.tex = astralGuildInfo:CreateTexture('ARTWORK')
		astralGuildInfo.tex:SetSize(198, 98)
		astralGuildInfo.tex:SetPoint('TOPLEFT', astralGuildInfo, 'TOPLEFT', 1, -1)
		astralGuildInfo.tex:SetColorTexture(0, 0, 0)

		astralGuildInfo.editBox:SetBackdrop(BACKDROPBUTTON)
		astralGuildInfo.editBox:SetBackdropBorderColor(.2, .2, .2, 1)
		astralGuildInfo.editBox:SetFontObject(FONT_OBJECT_CENTRE)
		astralGuildInfo.editBox:SetText('www.astralguild.com')
		astralGuildInfo.editBox:HighlightText()
		astralGuildInfo.editBox:SetScript('OnChar', function(self, char)
			self:SetText('www.astralguild.com')
			self:HighlightText()

		astralGuildInfo.editBox:SetScript("OnEscapePressed", function(self)
			astralGuildInfo:Hide()
		end)

			end)
		astralGuildInfo.editBox:SetScript('OnEditFocusLost', function(self)
			self:SetText('www.astralguild.com')
			self:HighlightText()
			end)

		astralGuildInfo.button = CreateButton(astralGuildInfo, nil, 40, 20, 'OK', FONT_OBJECT_CENTRE, FONT_OBJECT_HIGHLIGHT)
		astralGuildInfo.button:SetBackdrop(BACKDROPBUTTON)
		astralGuildInfo.button:SetBackdropBorderColor(.2, .2, .2, 1)
		astralGuildInfo.button:SetPoint('BOTTOM', astralGuildInfo, 'BOTTOM', 0, 10)
		astralGuildInfo.button.t:ClearAllPoints()
		astralGuildInfo.button.t = nil
		astralGuildInfo.button:SetScript('OnClick', function(self)
			astralGuildInfo:Hide() end)
	else
		astralGuildInfo:Show()
	end
 end)

guildInfo.string = guildInfo:CreateFontString('ARTWORK')
guildInfo.string:SetFont(FONT_CONTENT, FONT_SIZE - 2)
guildInfo.string:SetText('Astral - Turalyon (US)')
guildInfo.string:SetJustifyH('RIGHT')
guildInfo.string:SetPoint('BOTTOMRIGHT', guildInfo, 'BOTTOMRIGHT')

AstralKeyFrame.version = AstralKeyFrame:CreateFontString('ARTWORK')
AstralKeyFrame.version:SetFont(FONT_CONTENT, FONT_SIZE - 3)
AstralKeyFrame.version:SetPoint('BOTTOMRIGHT', guildInfo, 'TOPRIGHT')
AstralKeyFrame.version:SetText('v'.. GetAddOnMetadata('AstralKeys', 'version'))
AstralKeyFrame.version:SetJustifyH('RIGHT')

local logo = AstralKeyFrame:CreateTexture('ARTWORK')
logo:SetSize(64, 64)
logo:SetTexture('Interface\\AddOns\\AstralKeys\\Media\\Astral.tga')
logo:SetPoint('TOPLEFT', AstralKeyFrame, 'TOPLEFT', 10, -10)

local title = e.CreateHeader(AstralKeyFrame, 'title', 220, 20, 'Astral Keys', 26)
title:SetPoint('LEFT', logo, 'RIGHT', 10, 7) 

-----------------------------------
---- Guild/Friend List buttons

local guildButton = e.CreateOptionButton(AstralKeyFrame, 75)
guildButton:SetHeight(15)
guildButton:SetNormalFontObject(FONT_OBJECT_CENTRE)
guildButton:SetPoint('TOPLEFT', title, 'BOTTOMLEFT', 0, -3)
guildButton:SetText('Guild list')

local friendButton = e.CreateOptionButton(AstralKeyFrame, 75)
friendButton:SetHeight(15)
friendButton:SetPoint('LEFT', guildButton, 'RIGHT')
friendButton:SetNormalFontObject(FONT_OBJECT_CENTRE)
friendButton:SetText(WrapTextInColorCode('Friend list', 'ff9d9d9d'))

AstralKeyFrame.centreDivider = AstralKeyFrame:CreateTexture('BACKGROUND')
AstralKeyFrame.centreDivider:SetSize(1, 325)
AstralKeyFrame.centreDivider:SetPoint('TOPLEFT', AstralKeyFrame, 'TOPLEFT', 250, -125)
AstralKeyFrame.centreDivider:SetColorTexture(0.2, 0.2, 0.2)

local closeButton = CreateFrame('BUTTON', nil, AstralKeyFrame)
closeButton:SetSize(15, 15)
closeButton:SetNormalFontObject(FONT_OBJECT_CENTRE)
closeButton:SetHighlightFontObject(FONT_OBJECT_HIGHLIGHT)
closeButton:SetText('X')
closeButton:SetScript('OnClick', function()
	AstralKeyFrame:Hide()
end)
closeButton:SetPoint('TOPRIGHT', AstralKeyFrame, 'TOPRIGHT', -10, -10)

local toggleButton = CreateFrame('BUTTON', nil, AstralKeyFrame)
toggleButton:SetSize(16, 16)
toggleButton:SetPoint('TOPRIGHT', closeButton, 'TOPLEFT', - 5, 0)
toggleButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\minimize.tga')
toggleButton:SetScript('OnEnter', function(self)
	self:GetNormalTexture():SetVertexColor(126/255, 126/255, 126/255)
	end)
toggleButton:SetScript('OnLeave', function(self)
	self:GetNormalTexture():SetVertexColor(1, 1, 1)
	end)

toggleButton:SetScript('OnClick', function(self)
	local left, bottom, width = AstralKeyFrame:GetRect()
	if AstralKeysSettings.frameOptions.viewMode == 0 then
		AstralKeysSettings.frameOptions.viewMode = 1
		self:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\menu.tga')
		AstralKeyFrame:SetWidth(425)
		AstralKeyFrame:ClearAllPoints()
		AstralKeyFrame:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOMLEFT', left + width - 425, bottom)
		affixFrame:Hide()
		astralCharacterFrame:Hide()
		AstralKeyFrame.centreDivider:Hide()
		AstralContentFrame:ClearAllPoints()
		AstralContentFrame:SetPoint('TOPLEFT', AstralKeyFrame, 'TOPLEFT', 5, -95)
	else
		AstralKeysSettings.frameOptions.viewMode = 0
		self:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\minimize.tga')
		AstralKeyFrame:SetWidth(675)
		AstralKeyFrame:ClearAllPoints()
		AstralKeyFrame:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOMLEFT', left + width - 675, bottom)
		affixFrame:Show()
		astralCharacterFrame:Show()
		AstralKeyFrame.centreDivider:Show()
		AstralContentFrame:ClearAllPoints()
		AstralContentFrame:SetPoint('TOPLEFT', AstralKeyFrame, 'TOPLEFT', 255, -95)
	end
	end)

local optionsButton = CreateFrame('BUTTON', nil, AstralKeyFrame)
optionsButton:SetSize(16, 16)
optionsButton:SetPoint('TOPRIGHT', toggleButton, 'TOPLEFT', -5, 0)
optionsButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\menu3.tga')
optionsButton:SetScript('OnEnter', function(self)
	self:GetNormalTexture():SetVertexColor(126/255, 126/255, 126/255)
	end)
optionsButton:SetScript('OnLeave', function(self)
	self:GetNormalTexture():SetVertexColor(1, 1, 1)
	end)

optionsButton:SetScript('OnClick', function()
	AstralOptionsFrame:SetShown( not AstralOptionsFrame:IsShown())
	end)


-- Announce Buttons
-----------------------------------------------------

local announceFrame = CreateFrame('FRAME', nil, AstralKeyFrame)
announceFrame:SetSize(60, 20)
announceFrame:SetPoint('TOPRIGHT', closeButton, 'BOTTOMRIGHT', 0, -5)
announceFrame.announce = CreateFrame('BUTTON', nil, announceFrame)
announceFrame.announce:SetSize(16, 16)
announceFrame.announce:SetPoint('LEFT', announceFrame, 'LEFT')

function e.ToggleAnnounce()
	if AstralKeysSettings.options.announceKey then
		announceFrame.announce:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\speaker2.tga')
	else
		announceFrame.announce:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\speaker.tga')
	end
	AstralKeysSettings.options.announceKey = not AstralKeysSettings.options.announceKey
end


announceFrame.announce:SetScript('OnClick', function(self)
	e.ToggleAnnounce()
	end)

announceFrame.string = announceFrame:CreateFontString('ARTWORK')
announceFrame.string:SetFont(FONT_CONTENT, FONT_SIZE)
announceFrame.string:SetPoint('TOPLEFT', announceFrame, 'TOPLEFT')

local partyAnnounce = CreateFrame('BUTTON', nil, announceFrame)
partyAnnounce:SetSize(15, 15)
partyAnnounce:SetNormalFontObject(FONT_OBJECT_CENTRE)
partyAnnounce:SetHighlightFontObject(FONT_OBJECT_HIGHLIGHT)
partyAnnounce:SetText('P')
partyAnnounce:GetFontString():SetTextColor(76/255, 144/255, 255/255, 1)

partyAnnounce:SetPoint('LEFT', announceFrame.announce, 'RIGHT', 5, 0)

partyAnnounce:SetScript('OnClick', function()
	e.AnnounceCharacterKeys('PARTY')
	end)

local guildAnnounce = CreateFrame('BUTTON', nil, announceFrame)
guildAnnounce:SetSize(15, 15)
guildAnnounce:SetNormalFontObject(FONT_OBJECT_CENTRE)
guildAnnounce:SetHighlightFontObject(FONT_OBJECT_HIGHLIGHT)
guildAnnounce:SetText('G')
guildAnnounce:GetFontString():SetTextColor(38/255, 214/255, 25/255, 1)

guildAnnounce:SetPoint('LEFT', partyAnnounce, 'RIGHT')

guildAnnounce:SetScript('OnClick', function()
	e.AnnounceCharacterKeys('GUILD')
	end)


-- Tooltip AstralKeyFrame
-----------------------------------------------------

local mouseOverFrame = CreateFrame('FRAME', 'astralMouseOver', UIParent)
mouseOverFrame:SetSize(156, 200)
mouseOverFrame:SetFrameStrata('TOOLTIP')

mouseOverFrame.tex = mouseOverFrame:CreateTexture('ARTWORK')
mouseOverFrame.tex:SetAllPoints()
mouseOverFrame.tex:SetColorTexture(0, 0, 0)

mouseOverFrame.text = mouseOverFrame:CreateFontString('ARTWORK')
mouseOverFrame.text:SetFont(FONT_CONTENT, 14)
mouseOverFrame.text:SetPoint('TOPLEFT', mouseOverFrame, 'TOPLEFT', 8, -8)
mouseOverFrame.text:SetWordWrap(true)
mouseOverFrame.text:SetWidth(150)
mouseOverFrame.text:SetJustifyH('LEFT')

mouseOverFrame:Hide()

function mouseOverFrame:SetText(text)
	mouseOverFrame.text:SetText(text)
end

function mouseOverFrame:AdjustHeight()
	self:SetWidth(150)
	self:SetHeight(self.text:GetStringHeight() + 14)
	self.tex:ClearAllPoints()
	self.tex:SetAllPoints()
end

function mouseOverFrame:AdjustSize(width)
	self.text:SetWidth(width or self.text:GetStringWidth())
	self:SetHeight(self.text:GetStringHeight() + 14)
	self:SetWidth((width or self.text:GetStringWidth()) + 14)
	self.tex:ClearAllPoints()
	self.tex:SetAllPoints()
end

-- Affix Frames
-----------------------------------------------------

local affixFrame = CreateFrame('FRAME', 'affixFrame', AstralKeyFrame)
affixFrame:SetSize(200, 70)
affixFrame:SetHitRectInsets(0, 100, 0, 50)
affixFrame:SetPoint('TOPLEFT', logo, 'BOTTOMLEFT', 5, -10)

affixFrame:SetScript('OnEnter', function(self)
	mouseOverFrame:ClearAllPoints()
	mouseOverFrame:SetPoint('TOPLEFT', self, 'TOPLEFT', 5, -20)
	mouseOverFrame:SetText('Next week\'s affixes\n -' .. C_ChallengeMode.GetAffixInfo(e.AffixOne(1)) .. '\n -' .. C_ChallengeMode.GetAffixInfo(e.AffixTwo(1)) .. '\n -' .. C_ChallengeMode.GetAffixInfo(e.AffixThree(1)))
	mouseOverFrame:AdjustSize()
	mouseOverFrame:Show()
	end)

affixFrame:SetScript('OnLeave', function(self)
	mouseOverFrame:Hide()
	end)

local affixHeader = e.CreateHeader(affixFrame, 'affixHeader', 175, 20, 'Affixes', 12)
affixHeader:SetPoint('TOPLEFT', affixFrame, 'TOPLEFT')

local affixOne = CreateFrame('FRAME', 'AstralAffixOne', affixFrame)
--affixOne.aid = e.GetAffix(1)

affixOne:SetSize(100, 20)
affixOne:SetPoint('TOPLEFT', affixHeader, 'BOTTOMLEFT', 10, -5)
affixOne.string = affixOne:CreateFontString('ARTWORK')
affixOne.string:SetFont(FONT_CONTENT, FONT_SIZE + 2)
affixOne.string:SetPoint('LEFT', affixOne, 'LEFT', 25, 0)

affixOne.texture = affixOne:CreateTexture('ARTWORK')
affixOne.texture:SetSize(20, 20)
affixOne.texture:SetPoint('LEFT', affixOne, 'LEFT')
affixOne.texture:SetTexture(nil)

function affixOne:UpdateInfo()
	self.aid = e.AffixOne()
	self.string:SetText(C_ChallengeMode.GetAffixInfo(self.aid))
	self.texture:SetTexture(select(3, C_ChallengeMode.GetAffixInfo(self.aid)))
end

affixOne:SetScript('OnEnter', function(self)
	if tonumber(self.aid) == 0 or not self.aid then return end

	astralMouseOver:SetText(select(2, C_ChallengeMode.GetAffixInfo(self.aid)))
	astralMouseOver:AdjustSize(150)
	astralMouseOver:SetPoint('TOPLEFT', self, 'BOTTOMRIGHT', -15, 10)
	astralMouseOver:Show()

	end)

affixOne:SetScript('OnLeave', function()
	astralMouseOver:Hide()
	end)

local affixTwo = CreateFrame('FRAME', 'AstralAffixTwo', affixFrame)
--affixTwo.aid = e.GetAffix(2)

affixTwo:SetSize(100, 20)
affixTwo:SetPoint('TOPLEFT', affixOne, 'BOTTOMLEFT', 0, -5)
affixTwo.string = affixTwo:CreateFontString('ARTWORK')
affixTwo.string:SetFont(FONT_CONTENT, FONT_SIZE + 2)
affixTwo.string:SetPoint('LEFT', affixTwo, 'LEFT', 25, 0)

affixTwo.texture = affixTwo:CreateTexture('ARTWORK')
affixTwo.texture:SetSize(20, 20)
affixTwo.texture:SetPoint('LEFT', affixTwo, 'LEFT')
affixTwo.texture:SetTexture(nil)

function affixTwo:UpdateInfo()
	self.aid = e.AffixTwo()
	self.string:SetText(C_ChallengeMode.GetAffixInfo(self.aid))
	self.texture:SetTexture(select(3, C_ChallengeMode.GetAffixInfo(self.aid)))
end

affixTwo:SetScript('OnEnter', function(self)
	if tonumber(self.aid) == 0 or not self.aid then return end

	astralMouseOver:SetText(select(2, C_ChallengeMode.GetAffixInfo(self.aid)))
	astralMouseOver:AdjustSize(150)
	astralMouseOver:SetPoint('TOPLEFT', self, 'BOTTOMRIGHT', -15, 10)
	astralMouseOver:Show()

	end)

affixTwo:SetScript('OnLeave', function()
	astralMouseOver:Hide()
	end)

local affixThree = CreateFrame('FRAME', 'AstralAffixThree', affixFrame)
--affixThree.aid = e.GetAffix(3)

affixThree:SetSize(100, 20)
affixThree:SetPoint('TOPLEFT', affixOne, 'TOPRIGHT', 10, 0)
affixThree.string = affixThree:CreateFontString('ARTWORK')
affixThree.string:SetFont(FONT_CONTENT, FONT_SIZE + 2)
affixThree.string:SetPoint('LEFT', affixThree, 'LEFT', 25, 0)

affixThree.texture = affixThree:CreateTexture('ARTWORK')
affixThree.texture:SetSize(20, 20)
affixThree.texture:SetPoint('LEFT', affixThree, 'LEFT')
affixThree.texture:SetTexture(nil)

function affixThree:UpdateInfo()
	self.aid = e.AffixThree()
	self.string:SetText(C_ChallengeMode.GetAffixInfo(self.aid))
	self.texture:SetTexture(select(3, C_ChallengeMode.GetAffixInfo(self.aid)))
end

affixThree:SetScript('OnEnter', function(self) 
	if tonumber(self.aid) == 0 or not self.aid then return end

	astralMouseOver:SetText(select(2, C_ChallengeMode.GetAffixInfo(self.aid)))
	astralMouseOver:AdjustSize(150)
	astralMouseOver:SetPoint('TOPLEFT', self, 'BOTTOMRIGHT', -15, 10)
	astralMouseOver:Show()

	end)

affixThree:SetScript('OnLeave', function()
	astralMouseOver:Hide()
	end)

-- Character Frames
----------------------------------------------------------------
local characterFrame = CreateFrame('FRAME', 'astralCharacterFrame', AstralKeyFrame)
characterFrame:SetSize(215, 320)
characterFrame:SetPoint('TOPLEFT', affixFrame, 'BOTTOMLEFT', 0, -10)

local characterHeader = e.CreateHeader(characterFrame, 'affixHeader', 175, 20, 'Characters', 10)
characterHeader:SetPoint('TOPLEFT', characterFrame, 'TOPLEFT')

local characterContent = CreateFrame('FRAME', 'AstralCharacterContent', characterFrame)

characterContent.slider = characterContent:CreateTexture('BACKGROUND')
characterContent.slider:SetSize(8, 8)
characterContent.slider:SetColorTexture(0.2, 0.2, 0.2)
characterContent.slider:SetAlpha(.2)

characterContent:SetScript('OnEnter', function()
	AstralCharacterContent.slider:SetAlpha(1)
	end)

characterContent:SetScript('OnLeave', function()
	AstralCharacterContent.slider:SetAlpha(.2)
	end)

-- Key Frames
----------------------------------------------------------------

local contentFrame = CreateFrame('FRAME', 'AstralContentFrame', AstralKeyFrame)
contentFrame:SetSize(410, 390)
contentFrame:SetPoint('TOPLEFT', AstralKeyFrame, 'TOPLEFT', 255, -95)
contentFrame:EnableMouseWheel(true)

contentFrame.slider = contentFrame:CreateTexture('BACKGROUND')
contentFrame.slider:SetColorTexture(0.2, 0.2, 0.2)
contentFrame.slider:SetSize(8, 8)
contentFrame.slider:SetPoint('TOPLEFT', contentFrame, 'TOPRIGHT')
contentFrame.slider:SetAlpha(0.2)


function contentFrame:ResetSlider()
	offset = 0
	self.slider:SetPoint('TOPLEFT', self, 'TOPRIGHT')
end
local newOffset = 0

contentFrame:SetScript('OnMouseWheel', function(self, delta)
	if sortedTable.numShown < 26 then return end

	offset = offset - (delta * math.ceil(sortedTable.numShown/25))
	
	offset = math.max(0, offset)
	offset = math.min(offset, sortedTable.numShown - 25)
	
	e.UpdateLines()

	contentFrame.slider:ClearAllPoints()
	contentFrame.slider:SetPoint('TOPLEFT', contentFrame, 'TOPRIGHT', 0, -offset/(sortedTable.numShown - 25) * 365)

	end)

contentFrame:SetScript('OnEnter', function()
	contentFrame.slider:SetAlpha(1)
	end)

contentFrame:SetScript('OnLeave', function()
	contentFrame.slider:SetAlpha(0.2)
	end)

--[[ Sort methuds
	1: Unit Name
	2: 
	3: Map Name
	4: Key Level
	5: Weekly
]]

local keyButton = CreateButton(contentFrame, 'keyButton', 45, 20, 'Level', FONT_OBJECT_CENTRE, FONT_OBJECT_HIGHLIGHT) --75
keyButton:SetPoint('BOTTOMLEFT', contentFrame, 'TOPLEFT')
keyButton:SetScript('OnClick', function()
	if AstralMenuFrame:IsShown() then
		AstralMenuFrame:Hide()
	end

	contentFrame:ResetSlider()
	if AstralKeysSettings.frameOptions.sortMethod ~= 4 then
		AstralKeysSettings.frameOptions.orientation = 0
	else
		AstralKeysSettings.frameOptions.orientation = 1 - AstralKeysSettings.frameOptions.orientation
	end
	AstralKeysSettings.frameOptions.sortMethod = 4
	e.SortTable(sortedTable[e.FrameListShown()], AstralKeysSettings.frameOptions.sortMethod)
	e.UpdateLines()

	end)

local mapButton = CreateButton(contentFrame, 'mapButton', 170, 20, 'Dungeon', FONT_OBJECT_CENTRE, FONT_OBJECT_HIGHLIGHT)
mapButton:SetPoint('LEFT', keyButton, 'RIGHT')
mapButton:SetScript('OnClick', function()
	if AstralMenuFrame:IsShown() then
		AstralMenuFrame:Hide()
	end
	contentFrame:ResetSlider()
	if AstralKeysSettings.frameOptions.sortMethod ~= 3 then
		AstralKeysSettings.frameOptions.orientation = 0
	else
		AstralKeysSettings.frameOptions.orientation = 1 - AstralKeysSettings.frameOptions.orientation
	end
	AstralKeysSettings.frameOptions.sortMethod = 3
	e.SortTable(sortedTable[e.FrameListShown()], AstralKeysSettings.frameOptions.sortMethod)
	e.UpdateLines()

	end)

local nameButton = CreateButton(contentFrame, 'nameButton', 165, 20, 'Player', FONT_OBJECT_CENTRE, FONT_OBJECT_HIGHLIGHT)
nameButton:SetPoint('LEFT', mapButton, 'RIGHT')
nameButton:SetScript('OnClick', function()
	if AstralMenuFrame:IsShown() then
		AstralMenuFrame:Hide()
	end
	contentFrame:ResetSlider()
	if AstralKeysSettings.frameOptions.sortMethod ~= 1 then
		AstralKeysSettings.frameOptions.orientation = 0
	else
		AstralKeysSettings.frameOptions.orientation = 1 - AstralKeysSettings.frameOptions.orientation
	end
	AstralKeysSettings.frameOptions.sortMethod = 1
	e.SortTable(sortedTable[e.FrameListShown()], AstralKeysSettings.frameOptions.sortMethod)
	e.UpdateLines()

	end)

local completeButton = CreateButton(contentFrame, 'completeButton', 30, 20, e.CACHE_LEVEL .. '+', FONT_OBJECT_CENTRE, FONT_OBJECT_HIGHLIGHT)
completeButton:SetPoint('LEFT', nameButton, 'RIGHT')
completeButton:SetScript('OnClick', function()
	if AstralMenuFrame:IsShown() then
		AstralMenuFrame:Hide()
	end
	contentFrame:ResetSlider()
	if AstralKeysSettings.frameOptions.sortMethod ~= 5 then
		AstralKeysSettings.frameOptions.orientation = 0
	else
		AstralKeysSettings.frameOptions.orientation = 1 - AstralKeysSettings.frameOptions.orientation
	end
	AstralKeysSettings.frameOptions.sortMethod = 5
	e.SortTable(sortedTable[e.FrameListShown()], AstralKeysSettings.frameOptions.sortMethod)
	e.UpdateLines()

	end)

function AstralKeyFrame:OnUpdate(elapsed)
	self.updateDelay = self.updateDelay + elapsed

	if self.updateDelay < 0.75 then
		return
	end
	self:SetScript('OnUpdate', nil)
	self.updateDelay = 0
	e.UpdateFrames()
end

guildButton:SetScript('OnClick', function()
	if AstralMenuFrame:IsShown() then
		AstralMenuFrame:Hide()
	end
	if e.FrameListShown() == 'friend' then
		AstralContentFrame:ResetSlider()
		friendButton:SetNormalTexture(nil)
		friendButton:SetText(WrapTextInColorCode('Friend list', 'ff9d9d9d'))
		
		guildButton:SetNormalTexture(guildButton:GetHighlightTexture())
		guildButton:SetText('Guild list')
		e.SetFrameListShown('guild')
		e.UpdateFrames()
	end
	end)

friendButton:SetScript('OnClick', function()
	if AstralMenuFrame:IsShown() then
		AstralMenuFrame:Hide()
	end
	if e.FrameListShown() == 'guild' then
		e.SetFrameListShown('friend')

		AstralContentFrame:ResetSlider()
		guildButton:SetText(WrapTextInColorCode('Guild list', 'ff9d9d9d'))
		guildButton:SetNormalTexture(nil)

		friendButton:SetNormalTexture(friendButton:GetHighlightTexture())		
		friendButton:SetText('Friend list')
		e.UpdateFrames()
	end
	end)

function AstralKeyFrame:ToggleLists()
	if AstralKeysSettings.options.friendSync then
		guildButton:Show()
		friendButton:Show()
	else
		guildButton:Hide()
		friendButton:Hide()
		if e.FrameListShown() == 'friend' then
			friendButton:SetNormalTexture(nil)	
			friendButton:SetText(WrapTextInColorCode('Friend list', 'ff9d9d9d'))
			
			guildButton:SetNormalTexture(guildButton:GetHighlightTexture())
			guildButton:SetText('Guild list')
			e.SetFrameListShown('guild')
			e.UpdateFrames()
		end
	end
end

AstralKeyFrame:SetScript('OnKeyDown', function(self, key)
	if key == 'ESCAPE' then
		self:SetPropagateKeyboardInput(false)
		AstralKeyFrame:Hide()
	end
	end)

AstralKeyFrame:SetScript('OnShow', function(self)
	e.UpdateFrames()
	self:SetPropagateKeyboardInput(true)
	end)

AstralKeyFrame:SetScript('OnDragStart', function(self)
	self:StartMoving()
	end)

AstralKeyFrame:SetScript('OnDragStop', function(self)
	self:StopMovingOrSizing()
	end)

for i = 1, 25 do
	unit_frames[i] = UnitFrame:NewFrame(AstralContentFrame)
	unit_frames[i]:SetPoint('TOPLEFT', keyButton, 'BOTTOMLEFT', 5, (i-1) * -15 - 3)
	MixIn(unit_frames[i], UnitFrame)
end

local init = false
local function InitializeFrame()
	init = true

	if e.FrameListShown() == 'guild' then
		guildButton:SetNormalTexture(guildButton:GetHighlightTexture())
	else
		guildButton:SetText(WrapTextInColorCode('Guild list', 'ff9d9d9d'))
		guildButton:SetNormalTexture(nil)
		friendButton:SetNormalTexture(friendButton:GetHighlightTexture())
		friendButton:SetText('Friend list')
	end

	if not AstralKeysSettings.options.friendSync then
		guildButton:Hide()
		friendButton:Hide()
	end

	AstralAffixOne:UpdateInfo()
	AstralAffixTwo:UpdateInfo()
	AstralAffixThree:UpdateInfo()

	characterTable = e.DeepCopy(AstralCharacters)

	if AstralKeysSettings.options.announceKey then
		announceFrame.announce:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\speaker.tga')
	else
		announceFrame.announce:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\speaker2.tga')
	end

	if AstralKeysSettings.frameOptions.viewMode == 1 then
		AstralKeyFrame:SetWidth(425)
		affixFrame:Hide()
		astralCharacterFrame:Hide()
		AstralKeyFrame.centreDivider:Hide()
		AstralContentFrame:ClearAllPoints()
		AstralContentFrame:SetPoint('TOPLEFT', AstralKeyFrame, 'TOPLEFT', 5, -95)
		toggleButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\menu.tga')
	end

	local id = e.GetCharacterID(e.Player())

	-- Only create 9 character frames in total, first is reserved for current logged in character if 
	if id then -- We are logged into a character that has a key
		characters[1] = CreateCharacterFrame(characterFrame, nil, characterTable[id].unit, nil, false)
		characters[1]:SetPoint('TOPLEFT', characterHeader, 'BOTTOMLEFT', 0, -5)

		characterContent:SetSize(215, 260)
		characterContent:SetPoint('TOPLEFT', characterHeader, 'BOTTOMLEFT', 0, -39)

		table.remove(characterTable, id)

		for i = 1, math.min(#characterTable, 8) do -- Only 8 left character slots to make
			characters[i+1] = CreateCharacterFrame(characterFrame, nil, characterTable[i].unit, nil, false)
			characters[i+1]:SetPoint('TOPLEFT', characterContent, 'TOPLEFT', 0, -34*(i - 1) - 4)
		end
	else -- No key on said character, make 9 slots for characters
		characterContent:SetSize(215, 290)
		characterContent:SetPoint('TOPLEFT', characterHeader, 'BOTTOMLEFT', 0, -5)

		for i = 1, math.min(#characterTable, 9) do
			characters[i] = CreateCharacterFrame(characterFrame, nil, characterTable[i].unit, nil, false)
			characters[i]:SetPoint('TOPLEFT', characterContent, 'TOPLEFT', 0, -34*(i-1) - 4)
		end
	end

	characterContent.slider:SetPoint('TOPLEFT', characterContent, 'TOPRIGHT', 0, -10)

	if #characterTable > 8 then
		characterContent.slider:Show()
	else
		characterContent.slider:Hide()
	end

	characterContent:SetScript('OnMouseWheel', function(self, delta)
		if #characterTable < 9 then return end -- There aren't more characters than frames, no need to scroll

		local numSlots = 9

		if e.GetCharacterID(e.Player()) then
			numSlots = 8
		end

		characterOffset = characterOffset - delta
		characterOffset = math.max(0, characterOffset)
		characterOffset = math.min(characterOffset, #characterTable - numSlots)

		e.UpdateCharacterFrames()

		characterContent.slider:ClearAllPoints()
		characterContent.slider:SetPoint('TOPLEFT', characterContent, 'TOPRIGHT', 0, characterContent:GetHeight() * -characterOffset/(#characterTable - numSlots))
		end)

	e.UpdateFrames()
	e.UpdateCharacterFrames()

end

function e.UpdateAffixes()
	if not init then return end
	AstralAffixOne:UpdateInfo()
	AstralAffixTwo:UpdateInfo()
	AstralAffixThree:UpdateInfo()
end

function e.WipeFrames()
	wipe(AstralCharacters)
	wipe(AstralKeys)
	wipe(sortedTable)
	wipe(characterTable)
	e.GetBestClear()

	offset = 0
	characterOffset = 0
end

function e.UpdateLines()
	if not init then return end
	local list = e.FrameListShown()
	local lastIndex = 1

	for i = 1, math.min(sortedTable.numShown, 25) do
		for j = lastIndex, #sortedTable[list] do
			if sortedTable[list][j].isShown then
				lastIndex = j + 1
				unit_frames[i]:SetUnit(unpack(sortedTable[list][j + offset], 1, 7))
				break
			end
		end
	end

	for i = sortedTable.numShown + 1, 25 do
		unit_frames[i]:ClearUnit()
	end
end

function e.UpdateFrames()
	if not init or not AstralKeyFrame:IsShown() then return end

	e.UpdateTable(sortedTable)
	e.SortTable(sortedTable[e.FrameListShown()], AstralKeysSettings.frameOptions.sortMethod)

	if 25 + offset > sortedTable.numShown then
		offset = sortedTable.numShown - 26
	end
	offset = math.max(offset, 0)
	
	if sortedTable.numShown > 25 then
		AstralContentFrame.slider:Show()
	else
		AstralContentFrame.slider:Hide()
	end

	e.UpdateLines()
end

function e.UpdateCharacterFrames()
	if not init then return end
	characterTable = e.DeepCopy(AstralCharacters)

	if e.GetCharacterID(e.Player()) then
		characters[1]:UpdateInformation(e.GetCharacterID(e.Player()))
		table.remove(characterTable, e.GetCharacterID(e.Player()))
		for i = 2, #characters do
			if characterTable[i-1] then
				characters[i]:UpdateInformation(e.GetCharacterID(characterTable[i + characterOffset - 1].unit))
			else
				characters[i]:UpdateInformation('')
			end	
		end
	else
		for i = 1, #characters do
			if characterTable[i] then
				characters[i]:UpdateInformation(e.GetCharacterID(characterTable[i + characterOffset].unit))
			else
				characters[i]:UpdateInformation('')
			end
		end
	end
end

function e.AddUnitToTable(unit, class, faction, listType, mapID, level, weekly, btag)
	if not sortedTable[listType] then
		sortedTable[listType] = {}
	end
	local found = false
	for i = 1, #sortedTable[listType] do
		if sortedTable[listType][i][1] == unit then
			sortedTable[listType][i][3] = mapID
			sortedTable[listType][i][4] = level
			sortedTable[listType][i][5] = weekly or 0
			found = true
			break
		end
	end

	if not found then
		sortedTable[listType][#sortedTable[listType] + 1] = {unit, class, mapID, level, weekly or 0, faction, btag}
	end
end

function e.AstralToggle()
	if not init then InitializeFrame() end
	AstralKeyFrame:SetShown(not AstralKeyFrame:IsShown())
end

SLASH_ASTRALKEYS1 = '/astralkeys'
SLASH_ASTRALKEYS2 = '/ak'
SLASH_ASTRALKEYSV1 = '/akv'

local function handler(msg)
	e.AstralToggle()
end

SlashCmdList['ASTRALKEYS'] = handler;
SlashCmdList['ASTRALKEYSV'] = function(msg) e.VersionCheck() end