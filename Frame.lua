local _, e = ...

-- MixIns
AstralKeysCharacterMixin = {}
AstralKeysListMixin = {}
-- Red color code
-- #C72329

-- Background
-- Left #000000 ALPHA 0.8
-- Right #212121 ALPHA 0.8


local CHARACTER_CURRENT_KEY = 'Current Key:'
local CHARACTER_WEEKLY_BEST = 'Weekly Best:'
local CHARACTER_DUNGEON_NOT_RAN = 'No mythic dungeon ran'
local CHARACTER_KEY_NOT_FOUND = 'No key found'

local COLOR_BLUE_BNET = 'ff82c5ff'

local SCROLL_TEXTURE_ALPHA_MIN = 0.2
local SCROLL_TEXTURE_ALPHA_MAX = 0.6


local sortedTable = {}
sortedTable.numShown = 0
sortedTable['guild'] = {}
sortedTable['friend'] = {}

function AstralKeysCharacterMixin:UpdateUnit(characterID)
	local unit = e.CharacterName(characterID)
	local realm = e.CharacterRealm(characterID)
	local unitClass = e.GetCharacterClass(characterID)

	local bestKey = e.GetCharacterBestLevel(characterID)
	local currentMapID = e.GetCharacterMapID(unit .. '-' .. realm)
	local currentKeyLevel = e.GetCharacterKeyLevel(unit .. '-' .. realm)

	if e.CharacterRealm(characterID) ~= e.PlayerRealm() then
		unit = unit .. ' (*)'
	end
	self.nameString:SetText(WrapTextInColorCode(unit, select(4, GetClassColor(unitClass))))

	if bestKey ~= 0 then
		self.weeklyStringValue:SetText(bestKey)
	end

	if unit:find('Neko') then
		self.weeklyStringValue:SetText(10)
	end

	if currentMapID then
		self.keyStringValue:SetFormattedText('%d %s', currentKeyLevel, e.GetMapName(currentMapID))
	else
		self.keyStringValue:SetFormattedText('|c%s%s|r', COLOR_GRAY, CHARACTER_KEY_NOT_FOUND)
	end
end

function AstralKeysCharacterMixin:OnEnter()
	local scrollBar = self:GetParent():GetParent().scrollBar
	local scrollButton = _G[scrollBar:GetName() .. 'ThumbTexture']
	scrollButton:SetAlpha(0.6)
end

function AstralKeysCharacterMixin:OnLeave()
	local scrollBar = self:GetParent():GetParent().scrollBar
	local scrollButton = _G[scrollBar:GetName() .. 'ThumbTexture']
	scrollButton:SetAlpha(0.3)
end

function AstralKeysListMixin:SetUnit(id)
	local unit = e.UnitName(id)
	local unitClass = e.UnitClass(id)
	local bestKey = 0 --e.UnitBestKey()


	self.levelString:SetText(e.UnitKeyLevel(id))
	self.dungeonString:SetText(e.GetMapName(e.UnitMapID(id)))

	self.nameString:SetText(WrapTextInColorCode(Ambiguate(unit, 'GUILD') , select(4, GetClassColor(unitClass))))

	self.bestString:SetText(bestKey)
	self.weeklyTexture:SetShown(true or bestKey >= e.CACHE_LEVEL)
end


local UnitFrame = {}

function AstralKeysList_OnClick()
	print('testing')
end

function UnitFrame:NewFrame(parent)

	local self = CreateFrame('FRAME', nil, parent)
	self.unitID = 0

	self:EnableMouse(true)
	self:SetSize(400, 15)

	self.levelString = self:CreateFontString(nil, 'OVERLAY', 'InterUIBlack_Normal')
	self.levelString:SetPoint('TOPRIGHT', self, 'TOPLEFT', 20, 0)
	self.levelString:SetSize(20, 15)
	self.levelString:SetJustifyH('RIGHT')

	self.dungeonString = self:CreateFontString(nil, 'OVERLAY', 'InterUIBlack_Normal')
	self.dungeonString:SetSize(160, 15)
	self.dungeonString:SetPoint('LEFT', self.levelString, 'RIGHT', 25, 0)

	self.nameString = self:CreateFontString(nil, 'OVERLAY', 'InterUIMedium_Normal')
	self.nameString:SetSize(150, 15)
	self.nameString:SetPoint('LEFT', self.dungeonString, 'RIGHT')

	self.weeklyTexture = self:CreateTexture(nil, 'BACKGROUND')
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

	return self
end

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
			self.nameString:SetText( string.format('%s (%s)', WrapTextInColorCode(btag:sub(1, btag:find('#') - 1), COLOR_BLUE_BNET), WrapTextInColorCode(unit:sub(1, unit:find('-') - 1), select(4, GetClassColor(class)))))
		else
			self.nameString:SetText( string.format('%s (%s)', WrapTextInColorCode(btag:sub(1, btag:find('#') - 1), COLOR_BLUE_BNET), WrapTextInColorCode(unit:sub(1, unit:find('-') - 1), 'ff9d9d9d')))
		end
	else
		self.nameString:SetText(WrapTextInColorCode(unit:sub(1, unit:find('-') - 1), select(4, GetClassColor(class))))
	end
end

function UnitFrame:SetUnit(...)
	UNIT_FUNCTION[e.FrameListShown()](self, ...)
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
		isConnected = e.GuildMemberOnline(e.Unit(AstralMenuFrame.unit))
	end
	if e.FrameListShown() == 'friend' then
		isConnected = e.IsFriendOnline(e.Friend(AstralMenuFrame.unit))
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
AstralKeyFrame:SetWidth(740)
AstralKeyFrame:SetHeight(490)
AstralKeyFrame:SetPoint('CENTER', UIParent, 'CENTER')
AstralKeyFrame:EnableMouse(true)
AstralKeyFrame:SetMovable(true)
AstralKeyFrame:RegisterForDrag('LeftButton')
AstralKeyFrame:EnableKeyboard(true)
AstralKeyFrame:SetPropagateKeyboardInput(true)
AstralKeyFrame:SetClampedToScreen(true)
AstralKeyFrame:Hide()
AstralKeyFrame.updateDelay = 0
AstralKeyFrame.texture = AstralKeyFrame:CreateTexture(nil, 'BACKGROUND')
AstralKeyFrame.texture:SetAllPoints(AstralKeyFrame)
AstralKeyFrame.texture:SetColorTexture(0, 0, 0, 0.8)

local menuBar = CreateFrame('FRAME', '%parentMenuBar', AstralKeyFrame)
menuBar:SetSize(50, 490)
menuBar:SetPoint('TOPLEFT', AstralKeyFrame, 'TOPLEFT')
menuBar.texture = menuBar:CreateTexture(nil, 'BACKGROUND')
menuBar.texture:SetAllPoints(menuBar)
menuBar.texture:SetColorTexture(33/255, 33/255, 33/255, 0.8)

local logo_Key = menuBar:CreateTexture(nil, 'ARTWORK')
logo_Key:SetSize(32, 32)
logo_Key:SetTexture('Interface\\AddOns\\AstralKeys\\Media\\topnep.tga')
logo_Key:SetPoint('TOPLEFT', menuBar, 'TOPLEFT', 10, -10)

local divider = menuBar:CreateTexture(nil, 'ARTWORK')
divider:SetSize(20, 1)
divider:SetColorTexture(.6, .6, .6, .8)
divider:SetPoint('TOP', logo_Key, 'BOTTOM', 0, -20)

local settingsButton = CreateFrame('BUTTON', '$parentSettingsButton', menuBar)
settingsButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\settings_cog.tga')
settingsButton:SetSize(20, 20)
settingsButton:GetNormalTexture():SetVertexColor(.8, .8, .8)
settingsButton:SetPoint('TOP', divider, 'BOTTOM', 0, -20)
settingsButton:SetScript('OnEnter', function(self)
	self:GetNormalTexture():SetVertexColor(126/255, 126/255, 126/255)
end)
settingsButton:SetScript('OnLeave', function(self)
	self:GetNormalTexture():SetVertexColor(1, 1, 1)
end)

local logo_Astral = menuBar:CreateTexture(nil, 'ARTWORK')
logo_Astral:SetSize(32, 32)
logo_Astral:SetTexture('Interface\\AddOns\\AstralKeys\\Media\\Astral.tga')
logo_Astral:SetPoint('BOTTOMLEFT', menuBar, 'BOTTOMLEFT', 10, 10)

---- List Buttons
-----------------------------------
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

toggleButton:SetScript('OnClick', function(self)
	local left, bottom, width = AstralKeyFrame:GetRect()
	if AstralKeysSettings.frameOptions.viewMode == 0 then
		AstralKeysSettings.frameOptions.viewMode = 1
		self:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\menu.tga')
		AstralKeyFrame:SetWidth(425)
		AstralKeyFrame:ClearAllPoints()
		AstralKeyFrame:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOMLEFT', left + width - 425, bottom)
		AstralContentFrame:ClearAllPoints()
		AstralContentFrame:SetPoint('TOPLEFT', AstralKeyFrame, 'TOPLEFT', 5, -95)
	else
		AstralKeysSettings.frameOptions.viewMode = 0
		self:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\minimize.tga')
		AstralKeyFrame:SetWidth(675)
		AstralKeyFrame:ClearAllPoints()
		AstralKeyFrame:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOMLEFT', left + width - 675, bottom)
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

local tabFrame = CreateFrame('FRAME', '$parentTabFrame', AstralKeyFrame)
tabFrame:SetSize(420, 30)
tabFrame:SetPoint('TOPRIGHT', AstralKeyFrame, 'TOPRIGHT', -30, -10)
tabFrame.t = tabFrame:CreateTexture(nil, 'ARTWORK')
tabFrame.t:SetAllPoints(tabFrame)
--tabFrame.t:SetColorTexture(0, .5, 1)
tabFrame.buttons = {}

local MIN_BUTTON_WIDTH = 50
local MAX_BUTTON_WIDTH = 100

local function CreateNewTab(name, parent, ...)
	if not name or type(name) ~= 'string' then
		error('CreateNewTab(name, parent, ...) name: string expected, received ' .. type(name))
	end
	local buttons = parent.buttons
	local self = CreateFrame('BUTTON', '$parentTab' .. name, parent)
	self:SetNormalFontObject(InterUIBlack_Small)
	self:SetText(name)
	self:SetWidth(50)
	self:SetHeight(15)

	local textWidth = self:GetFontString():GetStringWidth()
	self.underline = self:CreateTexture(nil, 'ARTWORK')
	self.underline:SetSize(textWidth, 2)
	self.underline:SetColorTexture(214/255, 38/255, 38/255)
	self.underline:SetPoint('BOTTOM', self, 'BOTTOM', 0, -1)

	table.insert(buttons, self)
end

-- Max 5 with current text
local function UpdateTabs()
	local frame = AstralKeyFrameTabFrame
	local buttons = frame.buttons

	for i = 1, #buttons do
		if i == 1 then
			buttons[i]:SetPoint('LEFT', frame, 'LEFT')
		else
			buttons[i]:SetPoint('LEFT', buttons[i-1], 'RIGHT', 10, 0)
		end
	end
end

CreateNewTab('GUILD', tabFrame)
CreateNewTab('FRIENDS', tabFrame)
CreateNewTab('FRIENDS', tabFrame)
CreateNewTab('FRIENDS', tabFrame)
CreateNewTab('FRIENDS', tabFrame)
CreateNewTab('FRIENDS', tabFrame)
UpdateTabs()

local characterFrame = CreateFrame('FRAME', '$parentCharacterFrame', AstralKeyFrame)
characterFrame:SetSize(225, 490)
characterFrame:SetPoint('TOPLEFT', menuBar, 'TOPRIGHT', 1, 0)

local characterTitle = characterFrame:CreateFontString(nil, 'OVERLAY', 'InterUIBlack_Small')
characterTitle:SetPoint('TOPLEFT', characterFrame, 'TOPLEFT', 20, -100)
characterTitle:SetText('CHARACTERS')

local guildVersionString = characterFrame:CreateFontString(nil, 'OVERLAY', 'InterUIRegular_Small')
guildVersionString:SetFormattedText('Astral Turalyon (US) %s', 'v3')
guildVersionString:SetJustifyH('CENTER')
guildVersionString:SetPoint('BOTTOM', characterFrame, 'BOTTOM', 0, 20)
guildVersionString:SetAlpha(0.2)

characterFrame.texture = characterFrame:CreateTexture(nil, 'BACKGROUND')
characterFrame.texture:SetColorTexture(33/255, 33/255, 33/255, 0.8)
characterFrame.texture:SetAllPoints(characterFrame)

local affixTitle = characterFrame:CreateFontString(nil, 'OVERLAY', 'InterUIBlack_Small')
affixTitle:SetPoint('TOPLEFT', characterFrame, 'TOPLEFT', 20, -20)
affixTitle:SetText('AFFIXES')

-- Affix Frames
-----------------------------------------------------
do
	for i = 1, 4 do
		local frame = CreateFrame('FRAME', '$parentAffix' .. i, characterFrame)

		local mask = frame:CreateMaskTexture()
		mask:SetTexture("Interface\\MINIMAP\\UI-Minimap-Background", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		mask:SetSize(32, 32)
		mask:SetPoint("CENTER")

		frame.affixID = 0
		frame:SetSize(32, 32)
		frame.texture = frame:CreateTexture(nil, 'ARTWORK')
				
		frame.texture:AddMaskTexture(mask)

		if i == 1 then
			frame:SetPoint('TOPLEFT', affixTitle, 'BOTTOMLEFT', 0, -15)
		else
			frame:SetPoint('LEFT', '$parentAffix' .. (i -1), 'RIGHT', 15, 0)
		end
		frame.texture:SetAllPoints(frame)

		function frame:UpdateInfo(affixID)
			self.affixID = affixID
			self.texture:SetTexture(select(3, C_ChallengeMode.GetAffixInfo(affixID)))
		end
	end
end

-- Character Frames
----------------------------------------------------------------
function CharacterScrollFrame_Update()
	local scrollFrame = AstralKeyFrameCharacterContainer
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local buttons = scrollFrame.buttons
	local numButtons = #buttons
	local button, index
	local height = scrollFrame.buttonHeight
	local usedHeight = #buttons * height

	for i = 1, #buttons do
		if AstralCharacters[i+offset] then
			buttons[i]:UpdateUnit(i+offset)
			buttons[i]:Show()
		else
			buttons[i]:Hide()
		end
	end

	HybridScrollFrame_Update(AstralKeyFrameCharacterContainer, height * #AstralCharacters, usedHeight)
end

local function CharacterScrollFrame_OnEnter()
	AstralKeyFrameCharacterContainerScrollBarThumbTexture:SetAlpha(SCROLL_TEXTURE_ALPHA_MAX)
end

local function CharacterScrollFrame_OnLeave()
	AstralKeyFrameCharacterContainerScrollBarThumbTexture:SetAlpha(SCROLL_TEXTURE_ALPHA_MIN)
end

local characterScrollFrame = CreateFrame('ScrollFrame', '$parentCharacterContainer', AstralKeyFrame, 'HybridScrollFrameTemplate')
characterScrollFrame:SetSize(190, 320)
characterScrollFrame:SetPoint('TOPLEFT', characterTitle, 'TOPLEFT', 0, -25)
characterScrollFrame:SetScript('OnEnter',  CharacterScrollFrame_OnEnter)
characterScrollFrame:SetScript('OnLeave', CharacterScrollFrame_OnLeave)

local characterScrollBar = CreateFrame('Slider', '$parentScrollBar', characterScrollFrame, 'HybridScrollBarTemplate')
characterScrollBar:SetWidth(10)
characterScrollBar:SetPoint('TOPLEFT', characterScrollFrame, 'TOPRIGHT')
characterScrollBar:SetPoint('BOTTOMLEFT', characterScrollFrame, 'BOTTOMRIGHT', 1, 0)
characterScrollBar:SetScript('OnEnter', CharacterScrollFrame_OnEnter)
characterScrollBar:SetScript('OnLeave', CharacterScrollFrame_OnLeave)

-- Re-skin the scroll Bar
characterScrollBar.ScrollBarTop:Hide()
characterScrollBar.ScrollBarMiddle:Hide()
characterScrollBar.ScrollBarBottom:Hide()
_G[characterScrollBar:GetName() .. 'ScrollDownButton']:Hide()
_G[characterScrollBar:GetName() .. 'ScrollUpButton']:Hide()

local scrollButton = _G[characterScrollBar:GetName() .. 'ThumbTexture']
scrollButton:SetHeight(50)
scrollButton:SetWidth(5)
scrollButton:SetVertexColor(1, 1, 1, SCROLL_TEXTURE_ALPHA_MIN)

characterScrollFrame.buttonHeight = 45
characterScrollFrame.update = CharacterScrollFrame_Update


-- Key List Frames
----------------------------------------------------------------
function ListScrollFrame_Update()
	local scrollFrame = AstralKeyFrameListContainer
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local buttons = scrollFrame.buttons
	local numButtons = #buttons
	local button, index
	local height = scrollFrame.buttonHeight
	local usedHeight = 0

	local list = e.FrameListShown()
	local lastIndex = 1

	for i = 1, math.min(sortedTable.numShown, 25) do
		for j = lastIndex, #sortedTable[list] do
			if sortedTable[list][j].isShown then
				usedHeight = usedHeight + height
				lastIndex = j + 1
				buttons[i]:SetUnit(j+offset)
				buttons[i]:Show()
				break
			end
		end
	end

	for i = sortedTable.numShown + 1, #buttons do
		buttons[i]:Hide()
	end

	HybridScrollFrame_Update(AstralKeyFrameListContainer, height * #AstralKeys, usedHeight)
end

local listScrollFrame = CreateFrame('ScrollFrame', '$parentListContainer', AstralKeyFrame, 'HybridScrollFrameTemplate')
listScrollFrame:SetSize(420, 390)
listScrollFrame:SetPoint('TOPLEFT', tabFrame, 'BOTTOMLEFT', 0, -40)
listScrollFrame.update = ListScrollFrame_Update

local listScrollBar = CreateFrame('Slider', '$parentScrollBar', listScrollFrame, 'HybridScrollBarTemplate')
listScrollBar:SetWidth(10)
listScrollBar:SetPoint('TOPLEFT', listScrollFrame, 'TOPRIGHT')
listScrollBar:SetPoint('BOTTOMLEFT', listScrollFrame, 'BOTTOMRIGHT', 1, 0)

listScrollBar.ScrollBarTop:Hide()
listScrollBar.ScrollBarMiddle:Hide()
listScrollBar.ScrollBarBottom:Hide()
_G[listScrollBar:GetName() .. 'ScrollDownButton']:Hide()
_G[listScrollBar:GetName() .. 'ScrollUpButton']:Hide()

local scrollButton = _G[listScrollBar:GetName() .. 'ThumbTexture']
scrollButton:SetHeight(50)
scrollButton:SetWidth(5)
scrollButton:SetVertexColor(1, 1, 1, SCROLL_TEXTURE_ALPHA_MIN)
listScrollFrame.buttonHeight = 15

local contentFrame = CreateFrame('FRAME', 'AstralContentFrame', AstralKeyFrame)
contentFrame:SetSize(450, 390)
contentFrame:SetPoint('TOPLEFT', tabFrame, 'BOTTOMLEFT', 0, -30)

--[[ Sort methuds
	1: Unit Name
	2: 
	3: Map Name
	4: Key Level
	5: Weekly
]]

local keyLevelButton = CreateFrame('BUTTON', '%parentKeyLevelButton', contentFrame)
keyLevelButton:SetSize(40, 20)
keyLevelButton:SetNormalFontObject(InterUIBlack_Small)
keyLevelButton:GetNormalFontObject():SetJustifyH('CENTER')
keyLevelButton:SetText('LEVEL')
keyLevelButton:SetAlpha(0.5)
keyLevelButton:SetPoint('TOPLEFT', tabFrame, 'BOTTOMLEFT', 6, -10)

local dungeonButton = CreateFrame('BUTTON', '%DungeonButton', contentFrame)
dungeonButton:SetSize(160, 20)
dungeonButton:SetNormalFontObject(InterUIBlack_Small)
dungeonButton:GetNormalFontObject():SetJustifyH('LEFT')
dungeonButton:SetText('DUNGEON')
dungeonButton:SetAlpha(0.5)
dungeonButton:SetPoint('LEFT', keyLevelButton, 'RIGHT', 10, 0)

local characterButton = CreateFrame('BUTTON', '%parentCharacterButton', contentFrame)
characterButton:SetSize(105, 20)
characterButton:SetNormalFontObject(InterUIBlack_Small)
characterButton:GetNormalFontObject():SetJustifyH('LEFT')
characterButton:SetText('CHARACTER')
characterButton:SetAlpha(0.5)
characterButton:SetPoint('LEFT', dungeonButton, 'RIGHT')

local weeklyBestButton = CreateFrame('BUTTON', '%parentWeeklyBestButton', contentFrame)
weeklyBestButton:SetSize(50, 20)
weeklyBestButton:SetNormalFontObject(InterUIBlack_Small)
characterButton:GetNormalFontObject():SetJustifyH('CENTER')
weeklyBestButton:SetText('WKLY BEST')
weeklyBestButton:SetAlpha(0.5)
weeklyBestButton:SetPoint('LEFT', characterButton, 'RIGHT')

local weeklyButton = CreateFrame('BUTTON', '%parentWeeklyButton', contentFrame)
weeklyButton:SetSize(30, 20)
weeklyButton:SetNormalFontObject(InterUIBlack_Small)
weeklyButton:SetText('10+')
weeklyButton:SetAlpha(0.5)
weeklyButton:SetPoint('LEFT', weeklyBestButton, 'RIGHT', 10, 0)

--[[
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
]]
function AstralKeyFrame:OnUpdate(elapsed)
	self.updateDelay = self.updateDelay + elapsed

	if self.updateDelay < 0.75 then
		return
	end
	self:SetScript('OnUpdate', nil)
	self.updateDelay = 0
	e.UpdateFrames()
end

function AstralKeyFrame:ToggleLists()
	if AstralKeysSettings.options.friendSync then		
		
	else
		if e.FrameListShown() == 'friend' then
			
			
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
	e.UpdateCharacterFrames()
	self:SetPropagateKeyboardInput(true)
	end)

AstralKeyFrame:SetScript('OnDragStart', function(self)
	self:StartMoving()
	end)

AstralKeyFrame:SetScript('OnDragStop', function(self)
	self:StopMovingOrSizing()
	end)

local init = false
local function InitializeFrame()
	init = true

	HybridScrollFrame_CreateButtons(AstralKeyFrameCharacterContainer, 'AstralCharacterFrameTemplate', 0, 0, 'TOPLEFT', 'TOPLEFT', 0, -10)
	HybridScrollFrame_CreateButtons(AstralKeyFrameListContainer, 'AstralListFrameTemplate', 0, 0, 'TOPLEFT', 'TOPLEFT', 0, -15)

	local MAX_CHARACTER_FRAMES

	if e.FrameListShown() == 'guild' then
	else
	end

	if not AstralKeysSettings.options.friendSync then
	
	end

	e.UpdateAffixes()

	if AstralKeysSettings.frameOptions.viewMode == 1 then
		AstralKeyFrame:SetWidth(425)
		AstralContentFrame:ClearAllPoints()
		AstralContentFrame:SetPoint('TOPLEFT', AstralKeyFrame, 'TOPLEFT', 5, -95)
		toggleButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\menu.tga')
	end

	e.UpdateFrames()
end

function e.UpdateAffixes()
	if not init then return end
	AstralKeyFrameCharacterFrameAffix1:UpdateInfo(e.AffixOne())
	AstralKeyFrameCharacterFrameAffix2:UpdateInfo(e.AffixTwo())
	AstralKeyFrameCharacterFrameAffix3:UpdateInfo(e.AffixThree())
	AstralKeyFrameCharacterFrameAffix4:UpdateInfo(e.AffixFour())
end

function e.WipeFrames()
	wipe(sortedTable)
end

function e.UpdateLines()
	if not init then return end
	ListScrollFrame_Update()
end

function e.UpdateFrames()
	if not init or not AstralKeyFrame:IsShown() then return end

	e.UpdateTable(sortedTable)
	e.SortTable(sortedTable[e.FrameListShown()], AstralKeysSettings.frameOptions.sortMethod)

	e.UpdateLines()
end

function e.UpdateCharacterFrames()
	if not init then return end
	
	local id = e.GetCharacterID(e.Player())
	if id then
		local player = table.remove(AstralCharacters, id)
		table.sort(AstralCharacters, function(a,b) return a.unit < b.unit end)
		table.insert(AstralCharacters, 1, player)
		e.UpdateCharacterIDs()
	end
	CharacterScrollFrame_Update()
end

function e.AddUnitToTable(unit, class, faction, listType, mapID, level, weekly, weeklyBest, btag)
	if not sortedTable[listType] then
		sortedTable[listType] = {}
	end
	local found = false
	for i = 1, #sortedTable[listType] do
		if sortedTable[listType][i][1] == unit then
			sortedTable[listType][i][3] = mapID
			sortedTable[listType][i][4] = level
			sortedTable[listType][i][5] = weekly or 0
			sortedTable[listType][i][6] = weeklyBest
			found = true
			break
		end
	end

	if not found then
		sortedTable[listType][#sortedTable[listType] + 1] = {unit, class, mapID, level, weekly or 0, weeklyBest, faction, btag}
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