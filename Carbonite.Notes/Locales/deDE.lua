if ( GetLocale() ~= "deDE" ) then
	return;
end

local L = LibStub("AceLocale-3.0"):NewLocale("Carbonite.Notes", "deDE")
if not L then return end

L["Note Options"] = "Notiz-Einstellungen"
L["Show Notes On Map"] = "Notizen auf der Karte zeigen"
L["Shows your notes on the carbonite map"] = "Notizen auf der Carbonite-Karte zeigen"
L["Show Notes"] = "Notizen zeigen"
L["-Notes-"] = "-Notizen-"
L["Add Note"] = "Notiz hinzuf\195\188gen"
L["Notes Module"] = "Notiz-Modul"
L["Toggle Notes"] = "Notizen an/aus"
L["Record"] = "Notiz"
L["Up"] = "Hoch"
L["Down"] = "Runter"
L["Delete Item"] = "l\195\182schen"
L["Name"] = "Name"
L["Type"] = "Typ"
L["Value"] = "Wert"
L["Location"] = "Position"
L["Select a favorite before recording"] = "Favorit vor der Aufzeichnung aussuchen"
L["Add Folder"] = "Ordner hinzuf\195\188gen"
L["Add Favorite"] = "Favorit hinzuf\195\188gen"
L["Rename"] = "Umbenennen"
L["Cut"] = "Ausschneiden"
L["Copy"] = "Kopieren"
L["Paste"] = "Einf\195\188gen"
L["Options"] = "Einstellungen"
L["Add Comment"] = "Kommentar hinzuf\195\188gen"
L["Set Icon"] = "Symbol ausw\195\164hlen"
L["Name"] = "Name"
L["Nothing to paste"] = "Nichts einzuf\195\188gen"
L["Can't paste that on the left side"] = "Dieser Inhalt kann nicht auf der linken Seite eingef\195\188gt werden."
L["Can't paste that on the right side"] = "Dieser Inhalt kann nicht auf der rechten Seite eingef\195\188gt werden."
L["Note"] = "Notiz"
L["Notes"] = "Notizen"
L["Note Addons"] = "Notiz-Addons"
L["My Notes"] = "Meine Notizen"

L["Reset old notes data"] = "Alte Notizdaten zur\195\188cksetzen"
L["Display Handynotes On Map"] = "HandyNotes auf der Karte anzeigen"
L["If you have HandyNotes installed, allows them on the Carbonite map"] = "Falls das Addon HandyNotes installiert ist, werden sie Auf der Carbonite Karte angezeigt"
L["Handnotes Icon Size"] = "HandyNotes Symbolgr\195\182\195\159e"
-- Keybinds
L["Carbonite Notes"] = "Carbonite Notizen"
L["NxTOGGLEFAV"] = "Notizen ein/ausblenden"
