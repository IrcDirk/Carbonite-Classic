if ( GetLocale() ~= "zhCN" ) then
	return
end

local L = LibStub("AceLocale-3.0"):NewLocale("Carbonite", "zhCN")
if not L then return end

-- Main Guide
L["All"] = "全部"
L["Quest Givers"] = "任务给予人"
L["Stable Master"] = "兽栏管理员"
L["Flight Master"] = "飞行管理员"
L["Common Place"] = "常用地点"
L["Auctioneer"] = "拍卖师"
L["Banker"] = "银行管理员"
L["Innkeeper"] = "旅店老板"
L["Void Storage"] = "虚空仓库管理员"
L["Transmogrifier"] = "物品幻化师"
L["Battle Pet Trainer"] = "战斗宠物训练师"
L["Barber"] = "理发店"
L["Mailbox"] = "邮箱"
L["Anvil"] = "铁砧"
L["Forge"] = "熔炉"
L["Class Trainer"] = "职业训练师"
L["Death Knight Trainer"] = "死亡骑士训练师"
L["Druid Trainer"] = "德鲁伊训练师"
L["Hunter Trainer"] = "猎人训练师"
L["Mage Trainer"] = "法师训练师"
L["Paladin Trainer"] = "圣骑士训练师"
L["Priest Trainer"] = "牧师训练师"
L["Rogue Trainer"] = "潜行者训练师"
L["Shaman Trainer"] = "萨满训练师"
L["Warlock Trainer"] = "术士训练师"
L["Warrior Trainer"] = "战士训练师"
L["Monk Trainer"] = "武僧训练师"
L["Trainer"] = "训练师"
L["Alchemy"] = "炼金"
L["Archaeology"] = "考古"
L["Blacksmithing"] = "锻造"
L["Cooking"] = "烹饪"
L["Enchanting"] = "附魔"
L["Engineering"] = "工程学"
L["First Aid"] = "急救"
L["Fishing"] = "钓鱼"
L["Flying"] = "飞行"
L["Herbalism"] = "草药学"
L["Inscription"] = "铭文"
L["Jewelcrafting"] = "珠宝加工"
L["Leatherworking"] = "制皮"
L["Mining"] = "采矿"
L["Riding"] = "骑术"
L["Skinning"] = "剥皮"
L["Tailoring"] = "裁缝"
L["Travel"] = "旅行"
L["Visited Vendor"] = "已访问的商人"
L["All Items"] = "所有物品"
L["Gather"] = "采集"
L["Herb"] = "草点"
L["Ore"] = "矿点"
L["Artifacts"] = "考古点"
L["Everfrost"] = "永冻薄片"
L["Gas"] = "气体"
L["Instances"] = "副本"
L["Zone"] = "区域"
L["Trade Skill"] = "商业技能"
L["Alchemy Lab"] = "炼金实验室"
L["Altar Of Shadows"] = "黑暗祭坛"
L["Lightforged Beacon"] = "光铸道标"
L["Mana Loom"] = "魔法织布机"
L["Moonwell"] = "月亮井"
L["Back "] = true

-- Menus
L["Delete"] = "删除"
L["Add Goto Quest"] = "添加任务并前往"
L["Show On All Continents"] = "在所有大陆显示"
L["Show Completed Quest Givers"] = "显示已完成的任务给予人"
L["Show Horde"] = "显示部落方标记"
L["Show Alliance"] = "显示联盟方标记"
L["Clear Selection"] = "清除选择"
L["Options..."] = "选项..."
L["Skill"] = "技能"
L["Connection to"] = "连接到："
L["Portal to"] = "传送门："
L["Boat to"] = "渡船："
L["Zeppelin to"] = "飞艇："
L["Tram to"] = "地铁："

-- Instance types
L["Dungeon"] = true
L["Raid"] = true
L["Scenario"] = true
L["Solo"] = true
L["Mythic Dungeon"] = true
