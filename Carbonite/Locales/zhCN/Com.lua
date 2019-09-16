if ( GetLocale() ~= "zhCN" ) then
	return
end

local L = LibStub("AceLocale-3.0"):NewLocale("Carbonite", "zhCN")
if not L then return end

L["reached level"] = "已达到等级"
L["Monitor Error: All 10 chat channels are in use"] = "监视错误：所有10个聊天频道均已被占用"
L["This will disable some communication features"] = "这会使部分插件交流功能失效"
L["You may free channels using the chat tab"] = "你需要在聊天界面中退出一些频道"
L["chat channel(s)!"] = "聊天频道！"
L["Need"] = "需求"
L["Monitored:"] = "已监视："
L["Druid"] = "德鲁伊"
L["Hunter"] = "猎人"
L["Mage"] = "法师"
L["Paladin"] = "圣骑士"
L["Priest"] = "牧师"
L["Rogue"] = "潜行者"
L["Shaman"] = "萨满祭司"
L["Warlock"] = "术士"
L["Warrior"] = "战士"
L["Deathknight"] = "死亡骑士"
L["Monk"] = "武僧"

L["Com options reset (%f, %f)"] = "通讯设置重置 (%f, %f)"
L["ComTest"] = "通讯测试"
L["Disabling com functions!"] = "禁用通讯功能！"
L["JoinChan Err %s"] = "无法加入频道 %s "
L["SendSecG Error: %s"] = "全局频道安全信息发送失败：%s"
L[" %s (pending)"] = " %s (待定)"
L["Com %d Bytes sec %d"] = "通讯 %d 字节每秒 %d"
