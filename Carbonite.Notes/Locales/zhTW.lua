if ( GetLocale() ~= "zhTW" ) then
	return;
end

local L = LibStub("AceLocale-3.0"):NewLocale("Carbonite.Notes", "zhTW")
if not L then return end

L["Note Options"] = true
L["Show Notes On Map"] = true
L["Shows your notes on the carbonite map"] = true
L["Show Notes"] = true
L["-Notes-"] = true
L["Add Note"] = true
L["Notes Module"] = true
L["Toggle Notes"] = true
L["Record"] = true
L["Up"] = true
L["Down"] = true
L["Delete Item"] = true
L["Name"] = true
L["Type"] = true
L["Value"] = true
L["Location"] = true
L["Select a favorite before recording"] = true
L["Add Folder"] = true
L["Add Favorite"] = true
L["Rename"] = true
L["Cut"] = true
L["Copy"] = true
L["Paste"] = true
L["Options"] = true
L["Add Comment"] = true
L["Set Icon"] = true
L["Name"] = true
L["Nothing to paste"] = true
L["Can't paste that on the left side"] = true
L["Can't paste that on the right side"] = true
L["Note"] = true
L["Notes"] = true
L["Note Addons"] = true
L["My Notes"] = true

L["Reset old notes data"] = true
L["Display Handynotes On Map"] = true
L["If you have HandyNotes installed, allows them on the Carbonite map"] = true
L["Handnotes Icon Size"] = true

-- Keybinds
L["Carbonite Notes"] = "Carbonite Notes"
L["NxTOGGLEFAV"] = "show/hide Notes"
