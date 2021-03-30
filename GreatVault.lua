local e, L = unpack(select(2, ...))

-- MixIns
AstralKeysVaultMixin = {}

-- Color Definitions
local COLOR_YELLOW = 'ffffffc0'
local COLOR_GRAY = 'ff9d9d9d'
local COLOR_RED = 'ffff0000'
local COLOR_GREEN = 'ff00ff00'

-- Scroll bar texture alpha settings
local SCROLL_TEXTURE_ALPHA_MIN = 0.25
local SCROLL_TEXTURE_ALPHA_MAX = 0.6

local BACKDROPBUTTON = {
    bgFile = nil,
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16, edgeSize = 1,
    insets = {left = 0, right = 0, top = 0, bottom = 0}
}

-- Used for filtering, sorting, and displaying units on lists
local vaultTable = {}
vaultTable.num_shown = 0

local selectedUnits = {}

local CreateVaultTab, UpdateVaultTabs, vaultTabFrame

local function ClearSelectedUnits()
    wipe(selectedUnits)
end

function AstralKeysVaultMixin:UpdateUnit(characterID)
    local thisName = self:GetName()
    C_MythicPlus.RequestMapInfo()
    local unit = e.CharacterName(characterID)
    local realm = e.CharacterRealm(characterID)
    local unitClass = e.GetCharacterClass(characterID)
    local progress = e.GetWeeklyProgress(characterID)
    local tierstring = {}
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
            local tierfault = false
            _G[thisName.."Tier"..i.."String"]:Show()
            _G[thisName.."Tier"..i.."Level"]:Show()
            _G[thisName.."Tier"..i.."Item"]:Show()
            tierstring[i] = ''
            for j = 1, #progress do
                if progress[j].index == i and progress[j].type == Types[e.VaultListShown()] then
                    if progress[j].progress >= progress[j].threshold then
                        local tierlevel, tieritem
                        local itemLevel
                        local itemLink, upgradeitemLink = C_WeeklyRewards.GetExampleRewardItemHyperlinks(progress[j].id)
                        if GetDetailedItemLevelInfo(itemLink) then
                            if progress[j].itemLevel > 0 then
                                if GetDetailedItemLevelInfo(itemLink) ~= progress[j].itemLevel and GetDetailedItemLevelInfo(itemLink) > 0 and characterID == e.GetCharacterID(e.Player()) then
                                    itemLevel = GetDetailedItemLevelInfo(itemLink)
                                    e.SetWeeklyItemLevel(characterID, j, itemLevel)
                                    print("updated:", itemLevel, "and wrote to database:", progress[j].itemLevel) --debug function
                                else
                                    itemLevel = progress[j].itemLevel
                                    print("used database:",itemLevel) --debug function
                                end
                            elseif characterID == e.GetCharacterID(e.Player()) then
                                itemLevel = GetDetailedItemLevelInfo(itemLink)
                                e.SetWeeklyItemLevel(characterID, j, itemLevel)
                                print(itemLink)
                                print("used fresh:", itemLevel, "and wrote to database instead of old:", progress[j].itemLevel) --debug function
                            end
                        else
                            if progress[j].itemLevel > 0 then
                                itemLevel = progress[j].itemLevel
                                print("used database as failsafe:",itemLevel) --debug function
                            else
                                tierfault = true
                                print(e.VaultListShown(),"(",e.GetCharacterID(e.Player())," ): error retrieving itemLink for tier",i,"on characterID",characterID,"with progress",j,"and progressID",progress[j].id) --debug function
                            end
                        end

                        if Types[e.VaultListShown()] == Enum.WeeklyRewardChestThresholdType.MythicPlus then
                            local rewardstring = string.format(WEEKLY_REWARDS_ITEM_LEVEL_MYTHIC, itemLevel, progress[j].level)
                            local lzditem, lzdlevel = strsplit("-", rewardstring)
                            tierlevel = string.format('%s%s',COLOR_GREEN, strtrim(lzdlevel))
                            tieritem = string.format('%s%s',COLOR_YELLOW, strtrim(lzditem))
                        elseif Types[e.VaultListShown()] == Enum.WeeklyRewardChestThresholdType.Raid then
                            local lzditem = string.format(ITEM_LEVEL, itemLevel)
                            tierlevel = string.format('%s%s',COLOR_GREEN, DifficultyUtil.GetDifficultyName(progress[j].level))
                            tieritem = string.format('%s%s',COLOR_YELLOW, lzditem)
                        elseif Types[e.VaultListShown()] == Enum.WeeklyRewardChestThresholdType.RankedPvP then
                            local tierName = PVPUtil.GetTierName(progress[j].level)
                            local rewardstring = string.format(WEEKLY_REWARDS_ITEM_LEVEL_PVP, itemLevel, tierName)
                            local lzditem, lzdlevel = strsplit("-", rewardstring)
                            tierlevel = string.format('%s%s',COLOR_GREEN, strtrim(lzdlevel))
                            tieritem = string.format('%s%s',COLOR_YELLOW, strtrim(lzditem))
                            --else
                            --	print("error:", Types[e.VaultListShown()], "==", Enum.WeeklyRewardChestThresholdType.MythicPlus, Enum.WeeklyRewardChestThresholdType.Raid, Enum.WeeklyRewardChestThresholdType.RankedPvP)
                            --	tierlevel = string.format('%s%s',COLOR_RED, "ERROR")
                            --	tieritem = string.format('%s%s',COLOR_RED, "ERROR")
                        else
                            tierfault = true
                        end
                        if not tierfault then
                            _G[thisName.."Tier"..i.."String"]:Hide()
                            _G[thisName.."Tier"..i.."Level"]:SetFormattedText('|c%s|r', tierlevel)
                            _G[thisName.."Tier"..i.."Item"]:SetFormattedText('|c%s|r', tieritem)
                        end
                    else
                        tierstring[i] = string.format('%s(%d / %d)',COLOR_RED, progress[j].progress, progress[j].threshold)
                        _G[thisName.."Tier"..i.."Level"]:Hide()
                        _G[thisName.."Tier"..i.."Item"]:Hide()
                        _G[thisName.."Tier"..i.."String"]:SetFormattedText('|c%s|r', tierstring[i])
                    end
                end
            end
            if tierfault then
                _G[thisName.."Tier"..i.."Level"]:Hide()
                _G[thisName.."Tier"..i.."Item"]:Hide()
                _G[thisName.."Tier"..i.."String"]:SetFormattedText('|c%s%s|r', COLOR_GRAY, L['NO_VAULT_DATA'])
            end
        end
    else
        for i = 1, 3 do
            _G[thisName.."Tier"..i.."Level"]:Hide()
            _G[thisName.."Tier"..i.."Item"]:Hide()
            _G[thisName.."Tier"..i.."String"]:SetFormattedText('|c%s%s|r', COLOR_GRAY, L['NO_VAULT_DATA'])
        end
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
AstralKeysVaultFrame:SetWidth(525)
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

-- Window 525
-- MenuBar 50px
-- Middle Frame 475px
-- Padding Left/Right 10
-- -- TabFrame = MiddleFrame 275 - Padding 10 - Close Button 20 = 445
vaultTabFrame = CreateFrame('FRAME', '$parentTabFrame', AstralKeysVaultFrame)
vaultTabFrame.offSet = 0
vaultTabFrame:SetSize(445, 45)
vaultTabFrame:SetPoint('TOPRIGHT', AstralKeysVaultFrame, 'TOPRIGHT', -20, 0)
vaultTabFrame.buttons = {}

function UpdateVaultTabs()
    local buttons = AstralKeysVaultFrameTabFrame.buttons
    local offSet = AstralKeysVaultFrameTabFrame.offSet

    local maxPossibleWidth = 445 -- Tab frame, close button, new tab button width
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
characterFrame:SetSize(445, 280)
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
vaultScrollFrame:SetSize(445, 260)
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
    --e.UpdateVaultFrames()
end

AstralKeysVaultFrame:SetScript('OnKeyDown', function(self, key)
    if key == 'ESCAPE' then
        self:SetPropagateKeyboardInput(false)
        AstralKeysVaultFrame:Hide()
    end
end)

AstralKeysVaultFrame:SetScript('OnShow', function(self)
    e.UpdateCharacterFrames()
    e.UpdateVaultFrames()
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
    C_MythicPlus.RequestMapInfo()
    --creates Tabs: AstralKeysVaultFrameTabFrameTab*name*
    local Tabs = {'MYTHIC','RAID','PVP'}
    for i = 1, 3 do
        CreateVaultTab(Tabs[i], vaultTabFrame)
    end
    UpdateVaultTabs()
    --TODO: INITIALIZE CHECKBOX HERE
    e.UpdateWeeklyCharacter()
    HybridScrollFrame_CreateButtons(AstralKeysVaultFrameCharacterFrameCharacterContainer, 'AstralKeysVaultFrameTemplate', 0, 0, 'TOPLEFT', 'TOPLEFT', 0, -10)
    --e.UpdateVaultFrames()
    if not e.VaultListShown() then
        AstralKeysSettings.vault.current_list = 'MYTHIC'
    end
    UpdateVaultTabs()
end

function e.UpdateVaultFrames()
    if not init then return end

    local id = e.GetCharacterID(e.Player())
    if id then
        local player = table.remove(AstralCharacters, id)
        table.sort(AstralCharacters, function(a,b) return a.unit < b.unit end)
        table.insert(AstralCharacters, 1, player)
        e.UpdateCharacterIDs()
    end
    VaultScrollFrame_Update()
end

function e.AstralKeysVaultToggle()
    if not init then InitializeFrame() end
    AstralKeysVaultFrame:SetShown(not AstralKeysVaultFrame:IsShown())
end