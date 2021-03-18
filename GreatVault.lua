local e, L = unpack(select(2, ...))

-- MixIns
AstralKeysVaultMixin = {}

local BACKDROPBUTTON = {
    bgFile = nil,
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16, edgeSize = 1,
    insets = {left = 0, right = 0, top = 0, bottom = 0}
}

-- Color Definitions
local COLOR_GRAY = 'ff9d9d9d'
local COLOR_RED = 'ffff0000'
local COLOR_GREEN = 'ff00ff00'

-- Scroll bar texture alpha settings
local SCROLL_TEXTURE_ALPHA_MIN = 0.25
local SCROLL_TEXTURE_ALPHA_MAX = 0.6

-- Used for filtering, sorting, and displaying units on lists
local vaultTable = {}
vaultTable.num_shown = 0

local selectedUnits = {}

local CreateVaultTab, UpdateVaultTabs, vaultTabFrame

local function ClearSelectedUnits()
    wipe(selectedUnits)
end

function AstralKeysVaultMixin:UpdateUnit(characterID)
    local unit = e.CharacterName(characterID)
    local realm = e.CharacterRealm(characterID)
    local unitClass = e.GetCharacterClass(characterID)
    local progress = e.GetWeeklyProgress(characterID)
    local tierprogress = {}
    local tierthreshold = {}
    local tiercolor = {}
    local Types = {['MYTHIC']=Enum.WeeklyRewardChestThresholdType.MythicPlus,['RAID']=Enum.WeeklyRewardChestThresholdType.Raid,['PVP']=Enum.WeeklyRewardChestThresholdType.RankedPvP}
    if realm ~= e.PlayerRealm() then
        unit = unit .. ' (*)'
    end
    self.nameString:SetText(WrapTextInColorCode(unit, select(4, GetClassColor(unitClass))))
    self.tier1:SetFormattedText('|c%s%s|r', COLOR_GRAY, L['TIER1'])
    self.tier2:SetFormattedText('|c%s%s|r', COLOR_GRAY, L['TIER2'])
    self.tier3:SetFormattedText('|c%s%s|r', COLOR_GRAY, L['TIER3'])
    if progress then
        --TODO: INTEGRATE TAB-CHECK for M+, RAID, PVP

        --type defines mythic,raid,pvp enum
        --index defines "tier"
        --threshold = threshold
        --progress = actual number
        for i = 1, 3 do
            for j = 1, #progress do
                if progress[j].index == i and progress[j].type == Types[e.VaultListShown()] then
                    if progress[j].progress >= progress[j].threshold then
                        tiercolor[i] = COLOR_GREEN
                        tierprogress[i] = progress[j].threshold
                    else
                        tiercolor[i] = COLOR_RED
                        tierprogress[i] = progress[j].progress
                    end
                    tierthreshold[i] = progress[j].threshold
                end
            end
        end
        self.tier1String:SetFormattedText('|c%s(%d / %d)|r', tiercolor[1], tierprogress[1], tierthreshold[1])
        self.tier2String:SetFormattedText('|c%s(%d / %d)|r', tiercolor[2], tierprogress[2], tierthreshold[2])
        self.tier3String:SetFormattedText('|c%s(%d / %d)|r', tiercolor[3], tierprogress[3], tierthreshold[3])
    else
        self.tier1String:SetFormattedText('|c%s%s|r', COLOR_GRAY, L['NO_VAULT_DATA'])
        self.tier2String:SetFormattedText('|c%s%s|r', COLOR_GRAY, L['NO_VAULT_DATA'])
        self.tier3String:SetFormattedText('|c%s%s|r', COLOR_GRAY, L['NO_VAULT_DATA'])
    end
end

function AstralKeysVaultMixin:OnEnter()
    local scrollBar = self:GetParent():GetParent().scrollBar
    local scrollButton = _G[scrollBar:GetName() .. 'ThumbTexture']
    scrollButton:SetAlpha(SCROLL_TEXTURE_ALPHA_MAX)
end

function AstralKeysVaultMixin:OnLeave()
    local scrollBar = self:GetParent():GetParent().scrollBar
    local scrollButton = _G[scrollBar:GetName() .. 'ThumbTexture']
    scrollButton:SetAlpha(SCROLL_TEXTURE_ALPHA_MIN)
end

function AstralKeysVaultMixin:OnLoad()
    --TODO: CHECK WHAT TO DO OnLoad
end

local AstralKeysVaultFrame = CreateFrame('FRAME', 'AstralKeysVaultFrame', UIParent)
AstralKeysVaultFrame:SetFrameStrata('DIALOG')
AstralKeysVaultFrame:SetWidth(325)
AstralKeysVaultFrame:SetHeight(325)
AstralKeysVaultFrame:SetPoint('CENTER', UIParent, 'CENTER')
AstralKeysVaultFrame:EnableMouse(true)
AstralKeysVaultFrame:SetMovable(true)
AstralKeysVaultFrame:RegisterForDrag('LeftButton')
AstralKeysVaultFrame:EnableKeyboard(true)
AstralKeysVaultFrame:SetPropagateKeyboardInput(true)
AstralKeysVaultFrame:SetClampedToScreen(true)
AstralKeysVaultFrame:Hide()
AstralKeysVaultFrame.updateDelay = 0
AstralKeysVaultFrame.background = AstralKeysVaultFrame:CreateTexture(nil, 'BACKGROUND')
AstralKeysVaultFrame.background:SetAllPoints(AstralKeysVaultFrame)
AstralKeysVaultFrame.background:SetColorTexture(0, 0, 0, 0.8)

local menuBar = CreateFrame('FRAME', '$parentMenuBar', AstralKeysVaultFrame)
menuBar:SetWidth(50)
menuBar:SetHeight(325)
menuBar:SetPoint('TOPLEFT', AstralKeysVaultFrame, 'TOPLEFT')
menuBar.texture = menuBar:CreateTexture(nil, 'BACKGROUND')
menuBar.texture:SetAllPoints(menuBar)
menuBar.texture:SetColorTexture(33/255, 33/255, 33/255, 0.8)

local logo_Vault = menuBar:CreateTexture(nil, 'ARTWORK')
logo_Vault:SetSize(32, 32)
logo_Vault:SetTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\great-vault@2x')
logo_Vault:SetVertexColor(0.8, 0.8, 0.8, 0.8)
logo_Vault:SetPoint('TOPLEFT', menuBar, 'TOPLEFT', 10, -10)

local divider = menuBar:CreateTexture(nil, 'ARTWORK')
divider:SetSize(20, 1)
divider:SetColorTexture(.6, .6, .6, .8)
divider:SetPoint('TOP', logo_Key, 'BOTTOM', 0, -20)

local logo_Astral = menuBar:CreateTexture(nil, 'ARTWORK')
logo_Astral:SetAlpha(0.8)
logo_Astral:SetSize(32, 32)
logo_Astral:SetTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\Logo@2x')
logo_Astral:SetPoint('BOTTOMLEFT', menuBar, 'BOTTOMLEFT', 10, 10)

local closeButton = CreateFrame('BUTTON', '$parentCloseButton', AstralKeysVaultFrame)
closeButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\baseline-close-24px@2x')
closeButton:SetSize(12, 12)
closeButton:GetNormalTexture():SetVertexColor(.8, .8, .8, 0.8)
closeButton:SetScript('OnClick', function()
    AstralKeysVaultFrame:Hide()
end)
closeButton:SetPoint('TOPRIGHT', AstralKeysVaultFrame, 'TOPRIGHT', -14, -14)
closeButton:SetScript('OnEnter', function(self)
    self:GetNormalTexture():SetVertexColor(126/255, 126/255, 126/255, 0.8)
end)
closeButton:SetScript('OnLeave', function(self)
    self:GetNormalTexture():SetVertexColor(0.8, 0.8, 0.8, 0.8)
end)

--TODO: Create Vault-Character-List (see Character Info.lua)
--TODO: Hook to CHALLENGE_MODE_COMPLETE, etc. to update current progress
--TODO: Create Validation on week-change (see BlizzardWeeklyRewards.lua)
--TODO: Make list interactive to show only characters with unfinished progress

-- Window 325
-- MenuBar 50px
-- Middle Frame 275px
-- Padding Left/Right 10
-- -- TabFrame = MiddleFrame 275 - Padding 10 - Close Button 20 = 245
vaultTabFrame = CreateFrame('FRAME', '$parentTabFrame', AstralKeysVaultFrame)
vaultTabFrame.offSet = 0
vaultTabFrame:SetSize(245, 45)
vaultTabFrame:SetPoint('TOPRIGHT', AstralKeysVaultFrame, 'TOPRIGHT', -20, 0)
vaultTabFrame.buttons = {}

function UpdateVaultTabs()
    local buttons = AstralKeysVaultFrameTabFrame.buttons
    local offSet = AstralKeysVaultFrameTabFrame.offSet

    local maxPossibleWidth = 245 -- Tab frame, close button, new tab button width
    local usedWidth = 0 -- initialize at 10 for padding on the left
    local buttonsUsed = 0

    for i = 1, #buttons do
        buttons[i]:ClearAllPoints()
        buttons[i]:Hide()
    end

    for i = 1 + offSet, #buttons do
        if e.VaultListShown() == buttons[i].listName then
            buttons[i].underline:Show()
            buttons[i]:SetAlpha(1)
        else
            buttons[i].underline:Hide()
            buttons[i]:SetAlpha(0.5)
        end
        if i == 1 + offSet then
            usedWidth = usedWidth + buttons[i]:GetWidth() + 10 -- Padding between buttons
            buttons[i]:SetPoint('TOPLEFT', AstralKeysVaultFrameTabFrame, 'TOPLEFT', 20, -17)
            buttons[i]:Show()
        else
            usedWidth = usedWidth + buttons[i]:GetWidth() + 10 -- Padding between buttons
            if usedWidth <= maxPossibleWidth then
                buttons[i]:SetPoint('LEFT', buttons[i-1], 'RIGHT', 10, 0)
                buttons[i]:Show()
                buttonsUsed = i
            end
        end
    end
end

local function Tab_OnClick(self, button)
    if button == 'LeftButton' then

        if e.VaultListShown() ~= self.listName then
            ClearSelectedUnits()
            e.SetVaultListShown(self.listName)
            HybridScrollFrame_SetOffset(AstralKeysVaultFrameCharacterFrameCharacterContainer, 0)
            UpdateVaultTabs()
            --e.UpdateVaultTable:
            VaultScrollFrame_Update()
            AstralKeysVaultFrameCharacterFrameCharacterContainer.scrollBar:SetValue(0)
        end
    end
end

function CreateVaultTab(name, parent, ...)
    if not name or type(name) ~= 'string' then
        error('CreateNewTab(name, parent, ...) name: string expected, received ' .. type(name))
    end
    local buttons = parent.buttons
    local self = CreateFrame('BUTTON', '$parentTab' .. name, parent)
    self:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
    self.listName = name
    self:SetNormalFontObject(InterUIBlack_Small)
    self:SetText(L[name])
    self:GetFontString():SetJustifyH('CENTER')
    self:SetWidth(50)
    self:SetHeight(15)
    self:SetScript('OnClick', function(self, button) Tab_OnClick(self, button) end)

    local textWidth = self:GetFontString():GetUnboundedStringWidth()
    self:SetWidth(textWidth + 10)
    self.underline = self:CreateTexture(nil, 'ARTWORK')
    self.underline:SetSize(textWidth, 2)
    self.underline:SetColorTexture(214/255, 38/255, 38/255)
    self.underline:SetPoint('BOTTOM', self, 'BOTTOM', -5, -1)

    self.underline:Hide()

    table.insert(buttons, self)
end

-- Middle panel construction, Affixe info, character info, guild/version string
local characterFrame = CreateFrame('FRAME', '$parentCharacterFrame', AstralKeysVaultFrame)
characterFrame:SetSize(245, 280)
characterFrame:SetPoint('TOPLEFT', AstralKeysVaultFrame, 'TOPLEFT', 61, -46)

function VaultScrollFrame_Update()
    local scrollFrame = AstralKeysVaultFrameCharacterFrameCharacterContainer
    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    local buttons = scrollFrame.buttons
    local numButtons = #buttons
    local button, index
    local height = scrollFrame.buttonHeight
    local usedHeight = numButtons * height

    for i = 1, numButtons do
        if AstralCharacters[i+offset] then
            buttons[i]:UpdateUnit(i+offset)
            buttons[i]:Show()
        else
            buttons[i]:Hide()
        end
    end

    HybridScrollFrame_Update(AstralKeysVaultFrameCharacterFrameCharacterContainer, height * #AstralCharacters, usedHeight)
end

local function VaultScrollFrame_OnEnter()
    AstralKeysVaultFrameCharacterFrameCharacterContainerScrollBarThumbTexture:SetAlpha(SCROLL_TEXTURE_ALPHA_MAX)
end

local function VaultScrollFrame_OnLeave()
    AstralKeysVaultFrameCharacterFrameCharacterContainerScrollBarThumbTexture:SetAlpha(SCROLL_TEXTURE_ALPHA_MIN)
end

local vaultScrollFrame = CreateFrame('ScrollFrame', '$parentCharacterContainer', AstralKeysVaultFrameCharacterFrame, 'HybridScrollFrameTemplate')
vaultScrollFrame:SetSize(245, 260)
vaultScrollFrame:SetPoint('TOPLEFT', characterFrame, 'TOPLEFT', 0, -20)
vaultScrollFrame:SetScript('OnEnter',  VaultScrollFrame_OnEnter)
vaultScrollFrame:SetScript('OnLeave', VaultScrollFrame_OnLeave)

local vaultScrollBar = CreateFrame('Slider', '$parentScrollBar', vaultScrollFrame, 'HybridScrollBarTemplate')
vaultScrollBar:SetWidth(10)
vaultScrollBar:SetPoint('TOPLEFT', vaultScrollFrame, 'TOPRIGHT')
vaultScrollBar:SetPoint('BOTTOMLEFT', vaultScrollFrame, 'BOTTOMRIGHT', 1, 0)
vaultScrollBar:SetScript('OnEnter', VaultScrollFrame_OnEnter)
vaultScrollBar:SetScript('OnLeave', VaultScrollFrame_OnLeave)

-- Re-skin the scroll Bar
vaultScrollBar.ScrollBarTop:Hide()
vaultScrollBar.ScrollBarMiddle:Hide()
vaultScrollBar.ScrollBarBottom:Hide()
_G[vaultScrollBar:GetName() .. 'ScrollDownButton']:Hide()
_G[vaultScrollBar:GetName() .. 'ScrollUpButton']:Hide()

local scrollButton = _G[vaultScrollBar:GetName() .. 'ThumbTexture']
scrollButton:SetHeight(50)
scrollButton:SetWidth(4)
scrollButton:SetColorTexture(204/255, 204/255, 204/255, SCROLL_TEXTURE_ALPHA_MAX)

vaultScrollFrame.buttonHeight = 45
vaultScrollFrame.update = VaultScrollFrame_Update

function AstralKeysVaultFrame:OnUpdate(elapsed)
    self.updateDelay = self.updateDelay + elapsed

    if self.updateDelay < 0.75 then
        return
    end
    self:SetScript('OnUpdate', nil)
    self.updateDelay = 0
    VaultScrollFrame_Update()
end

AstralKeysVaultFrame:SetScript('OnKeyDown', function(self, key)
    if key == 'ESCAPE' then
        self:SetPropagateKeyboardInput(false)
        AstralKeysVaultFrame:Hide()
    end
end)

AstralKeysVaultFrame:SetScript('OnShow', function(self)
    VaultScrollFrame_Update()
    self:SetPropagateKeyboardInput(true)
end)

AstralKeysVaultFrame:SetScript('OnDragStart', function(self)
    self:StartMoving()
end)

AstralKeysVaultFrame:SetScript('OnDragStop', function(self)
    self:StopMovingOrSizing()
end)

AstralKeysVaultFrame:SetScript('OnHide', function(self)
    wipe(selectedUnits)
end)

local init = false
local function InitializeFrame()
    init = true
    --creates Tabs: AstralKeysVaultFrameTabFrameTab*name*
    local Tabs = {'MYTHIC','RAID','PVP'}
    for i = 1, 3 do
        CreateVaultTab(Tabs[i], vaultTabFrame)
    end
    UpdateVaultTabs()
    e.UpdateWeeklyCharacter()
    --TODO: INITIALIZE CHECKBOX HERE
    HybridScrollFrame_CreateButtons(AstralKeysVaultFrameCharacterFrameCharacterContainer, 'AstralKeysVaultFrameTemplate', 0, 0, 'TOPLEFT', 'TOPLEFT', 0, -10)
    if not e.VaultListShown() then
        AstralKeysSettings.vault.current_list = 'MYTHIC'
    end
    VaultScrollFrame_Update()
    UpdateVaultTabs()
end

function e.AstralKeysVaultToggle()
    if not init then InitializeFrame() end
    AstralKeysVaultFrame:SetShown(not AstralKeysVaultFrame:IsShown())
    e.UpdateWeeklyCharacter()
end