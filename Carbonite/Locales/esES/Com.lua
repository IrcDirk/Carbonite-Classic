if ( GetLocale() ~= "esES" ) then
	return;
end

local L = LibStub("AceLocale-3.0"):NewLocale("Carbonite", "esES")
if not L then return end

L["reached level"] = true
L["Monitor Error: All 10 chat channels are in use"] = true
L["This will disable some communication features"] = true
L["You may free channels using the chat tab"] = true
L["chat channel(s)!"] = true
L["Need"] = true
L["Monitored:"] = true
L["Druid"] = true
L["Hunter"] = true
L["Mage"] = true
L["Paladin"] = true
L["Priest"] = true
L["Rogue"] = true
L["Shaman"] = true
L["Warlock"] = true
L["Warrior"] = true
L["Deathknight"] = true
L["Monk"] = true

L["Com options reset (%f, %f)"] = true
L["ComTest"] = true
L["Disabling com functions!"] = true
L["JoinChan Err %s"] = true
L["SendSecG Error: %s"] = true
L[" %s (pending)"] = true
L["Com %d Bytes sec %d"] = true
