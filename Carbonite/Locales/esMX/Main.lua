if ( GetLocale() ~= "esMX" ) then
	return;
end

local L = LibStub("AceLocale-3.0"):NewLocale("Carbonite", "esMX")
if not L then return end

NXClassLocToCap = {		-- Convert localized class name to generic caps
	["Caballero de la muerte"] = "DEATHKNIGHT",
	["Druida"] = "DRUID",
	["Cazador"] = "HUNTER",
	["Cazadora"] = "HUNTER",
	["Mago"] = "MAGE",
	["Maga"] = "MAGE",
--	["??"] = "MONK",
	["Palad\195\173n"] = "PALADIN",
	["Sacerdote"] = "PRIEST",
	["Sacerdotisa"] = "PRIEST",
	["P\195\173caro"] = "ROGUE",
	["P\195\173cara"] = "ROGUE",
	["Cham\195\161n"] = "SHAMAN",
	["Brujo"] = "WARLOCK",
	["Bruja"] = "WARLOCK",
	["Guerrero"] = "WARRIOR",
	["Guerrera"] = "WARRIOR",
}

-- Main Carbonite
L["Carbonite"] = true
L["CARBONITE"] = true
L["Loading"] = true
L["Loading Done"] = true
L["None"] = true
L["Goto"] = true
L["Show Player Zone"] = true
L["Menu"] = true
L["Show Selected Zone"] = true
L["Add Note"] = true
L["TopRight"] = true
L["Help"] = true
L["Options"] = true
L["Toggle Map"] = true
L["Toggle Combat Graph"] = true
L["Toggle Events"] = true
L["Left-Click to Toggle Map"] = true
L["Shift Left-Click to Toggle Minimize"] = true
L["Middle-Click to Toggle Guide"] = true
L["Right-Click for Menu"] = true
L["Carbonite requires v5.0 or higher"] = true
L["GUID player"] = true
L["GUID NPC"] = true
L["GUID pet"] = true
L["Unit map error"] = true
L["Gather"] = true
L["Entered"] = true
L["Level"] = "Nivel"
L["Deaths"] = true
L["Bonus"] = true
L["Reset old data"] = true
L["Reset old global options"] = true
L["Options have been reset for the new version."] = true
L["Privacy or other settings may have changed."] = true
L["Cleaned"] = true
L["items"] = true
L["Reset old HUD options"] = true
L["Reset old travel data"] = true
L["Reset old gather data"] = true
L["Missing character data!"] = true
L["Deathknight"] = true
L["Death Knight"] = true
L["Version"] = true
L["Maintained by"] = true
L["crit"] = true
L["hit"] = true
L["Killed"] = true
L["honor"] = true
L["Hit"] = true
L["Peak"] = true
L["Best"] = true
L["Total"] = true
L["Time"] = true
L["Event"] = true
L["Events"] = true
L["Position"] = true
L["Died"] = true
L["Picked"] = true
L["Mined"] = true
L["Fished"] = true
L["Unknown herb"] = true
L["Unknown ore"] = true
L["Gathermate2_Data_Carbonite addon is not loaded!"] = true
L["Imported"] = true
L["nodes from GatherMate2_Data"] = true
L["Delete visited vendor data?"] = true
L["This will stop the attempted retrieval of items on login."] = true
L["Delete"] = true
L["Cancel"] = true
L["items retrieved"] = true
L["Item retrieval from server complete"] = true
L["Show Map"] = true
L["Show Combat Graph"] = true
L["Show Events"] = true
L["Show Auction Buyout Per Item"] = true
L["Show Com Window"] = true
L["Toggle Profiling"] = true
L["Left click toggle Map"] = true
L["Shift left click toggle minimize"] = true
L["Alt left click toggle Watch List"] = true
L["Middle click toggle Guide"] = true
L["Right click for Menu"] = true
L["Shift drag to move"] = true
L["Hide In Combat"] = true
L["Lock"] = true
L["Fade In"] = true
L["Fade Out"] = true
L["Layer"] = true
L["Scale"] = true
L["Transparency"] = true
L["Reset Layout"] = true

-- UI Tooltips
L["Close/Menu"] = true
L["Close/Unlock"] = true
L["Pick Color"] = true
L["Unlock"] = true
L["Maximize"] = true
L["Restore"] = true
L["Minimize"] = true
L["Auto Scale"] = true

-- Stuff from old localization
L["Searching for Artifacts"] = "B\195\186squeda de artefactos"		-- NXlARTIFACTS
L["Extract Gas"] = "Extraer gas"					-- NXlEXTRACTGAS
L["Herb Gathering"] = "Recolectar hierbas"				-- NXlHERBGATHERING
L["In Conflict"] = "En conflicto"					-- NXlINCONFLICT
L["Opening"] = "Apertura"						-- NXlOpening
L["Opening - No Text"] = "Apertura - Sin texto"				-- NXlOpeningNoText
L["Everfrost Chip"] = "Esquirla de siemprescarcha"			-- NXlEverfrost

L["yds"] = true
L["secs"] = true
L["mins"] = true

-- NxUI.lua
L[" Frame: %s Shown%d Vis%d P>%s"] = true
L[" EScale %f, Lvl %f"] = true
L[" LR %f, %f"] = true
L[" BT %f, %f"] = true
L["%s#%d %s ID%s (%s) show%d l%d x%d y%d"] = true
L["%.1f days"] = true
L["%.1f hours"] = true
L["%d mins"] = true
L["Reset old layout data"] = true
L["Window version mismatch!"] = true
L["XY missing (%s)"] = true
L["Window not found (%s)"] = true
L["Detach %s"] = true
L["Detach found %s"] = true
L["Search: [click]"] = true
L["Search: %[click%]"] = true
L["Reset old list data"] = true
L["!BUT %s"] = true
L["Key %s transfered to Watch List Item"] = true
L["CLICK (.+):"] = true
L["Key %s %s #%s %s"] = true
L["shift left/right click to change size"] = true
L["Reset old tool bar data"] = true

-- NxTravel.lua
L["Connection: %s to %s"] = true
L["Fly: %s to %s"] = true
