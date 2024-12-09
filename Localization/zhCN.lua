local L = select(2, ...).L('zhCN')

-- Default string for keystone
L['KEYSTONE'] = '钥石:'

-- Default tab names
L['Report'] = '通报'
L['REPORT_TO'] = '通报到'
L['GUILD'] = GUILD    -- 使用系统代码，无需本地化翻译
L['FRIENDS'] = FRIENDS
L['PARTY'] = PARTY
L['RAID'] = RAID

-- Column Headers
L['LEVEL'] = LEVEL
L['DUNGEON'] = DUNGEONS
L['CHARACTER'] = CHARACTER

-- Subsection Headers
L['CHARACTERS'] = '角色'
L['AFFIXES'] = '词缀'

-- Character Labels
L['CURRENT_KEY'] = '当前钥石'
L['WEEKLY_BEST'] = '本周最佳'

L['CHARACTER_DUNGEON_NOT_RAN'] = '尚未进行大秘境'
L['CHARACTER_KEY_NOT_FOUND'] = '未发现钥石'


-- Dropdown menu selections
L['Whisper'] = WHISPER   -- 使用系统代码，无需本地化翻译
L['INVITE'] = INVITE
L['SUGGEST_INVITE'] = SUGGEST_INVITE
L['REQUEST_INVITE'] = REQUEST_INVITE
L['CANCEL'] = CANCEL

-- Announce messages
L['ANNOUNCE_NEW_KEY'] = 'Astral Keys: 新的钥石是 %s'
L['NO_KEY'] = '没有钥石'
L['KEYS_RESPOND_ON_NO_KEY'] = '即使无钥石也响应'
L['KEYS_RESPOND_WITH_ALL_CHARACTERS'] = '响应所有角色的钥石信息'

-- Search field texts
L['FILTER_TEXT_DUNGEON'] = '根据地下城过滤'
L['FILTER_TEXT_CHARACTER'] = '根据角色名称过滤'

-- Options
L['Settings'] = '设置'
L['!KEYS_DESC'] = '在以下频道回应 !keys 指令'
L['EXPANDED_TOOLTIP'] = '在鼠标提示中显示词缀描述'
L['GENERAL OPTIONS'] = '一般选项'
L['Show offline players'] = '显示离线角色'
L['Show Minimap button'] = '显示小地图图标'
L['Show current key in tooltip'] = '在鼠标提示中显示钥石信息'
L['Show enemy forces in tooltip'] = '在鼠标提示中显示敌方部队'
L['Display offline below online'] = '在线角色下面显示离线角色'
L['Announce new keys to party'] = '在队伍频道通报钥石'
L['Announce new keys to guild'] = '在公会频道通报钥石'
L['!keys chat command'] = '!keys 指令'
L['SYNC OPTIONS'] = '同步选项'
L['Sync with friends'] = '和好友同步'
L['Show other faction'] = '显示其他阵营'
L['Rank Filter'] = '会阶过滤'
L['Include these ranks in the guild listing'] = '在公会列表中包含以下会阶'
L['Vault'] = '宝库'
L['Refresh'] = '刷新'
L['Refreshing key data.'] = '刷新钥石数据'
L['Done.'] = '完成。'
L['You need to wait more than 30 seconds before refreshing again.'] = '您需要等待 30 秒以上才能再次刷新。'

-- Dialog
L["Are you sure you want to refresh all key data?"] = "您确定要刷新所有钥石数据吗？"
L["Yes"] = "是"
L["No"] = "否"
L["Refreshed key data."] = "刷新钥石数据"
L["You need to wait more than 30 seconds before refreshing again."] = "您需要等待 30 秒以上才能再次刷新。"

-- MinimapButton
L['Left click to toggle main window'] = "左键点击打开窗口"
L['Right Click to toggle options'] = "右键点击打开设置"

-- Lists/Friends
L['Current Keystone'] = '当前钥石'

-- Dungeon Name
-- Cataclysm
L["Grim Batol"] = "格瑞姆巴托"
L["The Vortex Pinnacle"] = "旋云之巅"
L["Throne of the Tides"] = "潮汐王座"

-- Mists of Pandaria
L["Temple of the Jade Serpent"] = "青龙寺"

-- Warlords of Draenor
L["Grimrail Depot"] = "恐轨车站"
L["Iron Docks"] = "钢铁码头"
L["Shadowmoon Burial Grounds"] = "影月墓地"
L["The Everbloom"] = "永茂林地"

-- Legion
L["Black Rook Hold"] = "黑鸦堡垒"
L["Court of Stars"] = "群星庭院"
L["Darkheart Thicket"] = "黑心林地"
L["Halls of Valor"] = "英灵殿"
L["Lower Karazhan"] = "卡拉赞：下层"  -- 重返卡拉赞：下层
L["Neltharion's Lair"] = "奈萨里奥的巢穴"
L["Return to Karazhan: Lower"] = "卡拉赞：下层"  -- 重返卡拉赞：下层
L["Return to Karazhan: Upper"] = "卡拉赞：上层"  -- 重返卡拉赞：上层
L["Upper Karazhan"] = "卡拉赞：上层"  -- 重返卡拉赞：上层

-- Battle for Azeroth
L["Atal'Dazar"] = "阿塔达萨"
L["Freehold"] = "自由镇"
L["Mechagon Junkyard"] = "麦卡贡-废料场"  -- 麦卡贡行动-废料场
L["Mechagon Workshop"] = "麦卡贡-车间"  -- 麦卡贡行动-车间
L["Operation: Mechagon - Junkyard"] = "麦卡贡-废料场"  -- 麦卡贡行动-废料场
L["Operation: Mechagon - Workshop"] = "麦卡贡-车间"  -- 麦卡贡行动-车间
L["Siege of Boralus"] = "围攻伯拉勒斯"
L["The Underrot"] = "地渊孢林"
L["Waycrest Manor"] = "维克雷斯庄园"

-- Shadowlands
L["Mists of Tirna Scithe"] = "塞兹仙林的迷雾"
L["So'leah's Gambit"] = "索·莉亚的宏图"  -- 塔扎维什：索·莉亚的宏图
L["Streets of Wonder"] = "琳彩天街"  -- 塔扎维什：琳彩天街
L["Tazavesh: So'leah's Gambit"] = "索·莉亚的宏图"  -- 塔扎维什：索·莉亚的宏图
L["Tazavesh: Streets of Wonder"] = "琳彩天街"  -- 塔扎维什：琳彩天街
L["The Necrotic Wake"] = "通灵战潮"

-- Dragonflight
L["Algeth'ar Academy"] = "艾杰斯亚学院"
L["Brackenhide Hollow"] = "蕨皮山谷"
L["Dawn of the Infinite: Galakrond's Fall"] = "迦拉克隆的陨落"  -- 永恒黎明：迦拉克隆的陨落
L["Dawn of the Infinite: Murozond's Rise"] = "姆诺兹多的崛起"  -- 永恒黎明：姆诺兹多的崛起
L["DotI: Galakrond's Fall"] = "迦拉克隆的陨落"  -- 永恒黎明：迦拉克隆的陨落
L["DotI: Murozond's Rise"] = "姆诺兹多的崛起"  -- 永恒黎明：姆诺兹多的崛起
L["Halls of Infusion"] = "注能大厅"
L["Neltharus"] = "奈萨鲁斯"
L["Ruby Life Pools"] = "红玉新生法池"
L["The Azure Vault"] = "碧蓝魔馆"
L["The Nokhud Offensive"] = "诺库德阻击战"
L["Uldaman: Legacy of Tyr"] = "奥达曼：提尔"  -- 奥达曼：提尔的遗产

-- The War Within Dungeons
L["Ara-Kara, City of Echoes"] = "回响之城"  -- 艾拉-卡拉，回响之城
L["Cinderbrew Meadery"] = "燧酿酒庄"
L["City of Threads"] = "千丝之城"
L["Darkflame Cleft"] = "暗焰裂口"
L["The Dawnbreaker"] = "破晨号"
L["The Rookery"] = "驭雷栖巢"
L["The Stonevault"] = "矶石宝库"
