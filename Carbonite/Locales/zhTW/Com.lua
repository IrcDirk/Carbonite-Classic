if ( GetLocale() ~= "zhTW" ) then
	return;
end

local L = LibStub("AceLocale-3.0"):NewLocale("Carbonite", "zhTW")
if not L then return end

L["reached level"] = "已達到等級"
L["Monitor Error: All 10 chat channels are in use"] = "監視錯誤：所有10個聊天頻道均已被佔用"
L["This will disable some communication features"] = "這會使部分插件交流功能失效"
L["You may free channels using the chat tab"] = "你需要在聊天界面中退出一些頻道"
L["chat channel(s)!"] = "聊天頻道！"
L["Need"] = "需求"
L["Monitored:"] = "已監視："
L["Druid"] = "德魯伊"
L["Hunter"] = "獵人"
L["Mage"] = "法師"
L["Paladin"] = "聖騎士"
L["Priest"] = "牧師"
L["Rogue"] = "潛行者"
L["Shaman"] = "薩滿祭司"
L["Warlock"] = "術士"
L["Warrior"] = "戰士"
L["Deathknight"] = "死亡騎士"
L["Monk"] = "武僧"

L["Com options reset (%f, %f)"] = true
L["ComTest"] = true
L["Disabling com functions!"] = true
L["JoinChan Err %s"] = true
L["SendSecG Error: %s"] = true
L[" %s (pending)"] = true
L["Com %d Bytes sec %d"] = true
