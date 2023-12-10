local L = LibStub("AceLocale-3.0"):GetLocale("Carbonite")

Nx.BuggedSubZones = {
	[0] = "null",
	[1] = "Caverns of Time",
	[2] = "Cleft of Shadow",
	[3] = "Temple of Earth",
	[4] = "Terrace of Light"
}

Nx.BuggedAreas = {
	[0] = "null",
	[1] = 125,
	[2] = 126,
	[3] = 103,
	[4] = 87,
	[5] = 90,
}


	-- Can anyone expand/corect this (from dratr https://github.com/dratr/Carbonite/commits/map-zonesdocs)
	-- Fields: name, minLvl, maxLvl, faction, cont, entryId, ex, ey, ??
	-- entryId, ex, ey only for instances.
	-- entryId is map id of zone that has dungeon entrance; ex, ey is loc in zone
	-- Faction:
	-- 0 Alliance
	-- 1 Horde
	-- 2 Contested
	-- 3 Instance
	-- 4 Unknown
Nx.Zones = {
    [0] = L["Unknown Zone"] .. "|0|0|4|0||",
    [1411] = L["Durotar"] .. "|1|10|1|1||",
    [1412] = L["Mulgore"] .. "|1|10|1|1||",
    [1413] = L["Northern Barrens"] .. "|20|60|1|1||",
    [12] = L["Kalimdor"] .. "|1|60|2|1||",
    [13] = L["Eastern Kingdoms"] .. "|1|60|2|2||",
	[1416] = L["Alterac Mountains"] .. "|30|40|2|2||",
    [1417] = L["Arathi Highlands"] .. "|30|40|2|2||",
    [1418] = L["Badlands"] .. "|35|45|2|2||",
    [1419] = L["Blasted Lands"] .. "|45|55|2|2||",
    [1420] = L["Tirisfal Glades"] .. "|1|10|1|2||",
    [1421] = L["Silverpine Forest"] .. "|10|20|1|2||",
    [1422] = L["Western Plaguelands"] .. "|51|58|2|2||",
    [1423] = L["Eastern Plaguelands"] .. "|53|60|2|2||",
    [1424] = L["Hillsbrad Foothills"] .. "|20|30|2|2||",
    [1425] = L["The Hinterlands"] .. "|40|50|2|2||",
    [1426] = L["Dun Morogh"] .. "|1|10|0|2||",
    [1427] = L["Searing Gorge"] .. "|43|50|2|2||",
    [1428] = L["Burning Steppes"] .. "|50|58|2|2||",
    [1429] = L["Elwynn Forest"] .. "|1|10|0|2||",
    [1430] = L["Deadwind Pass"] .. "|55|60|2|2||",
    [1431] = L["Duskwood"] .. "|18|30|2|2||",
    [1432] = L["Loch Modan"] .. "|10|20|0|2||",
    [1433] = L["Redridge Mountains"] .. "|15|25|2|2||",
    [1434] = L["Stranglethorn Vale"] .. "|30|45|2|2||",
    [1435] = L["Swamp of Sorrows"] .. "|35|45|2|2||",
    [1436] = L["Westfall"] .. "|10|20|0|2||",
    [1437] = L["Wetlands"] .. "|20|30|2|2||",
    [1438] = L["Teldrassil"] .. "|1|10|0|1||",
    [1439] = L["Darkshore"] .. "|10|20|0|1||",
    [1440] = L["Ashenvale"] .. "|18|30|2|1||",
    [1441] = L["Thousand Needles"] .. "|25|35|2|1||",
    [1442] = L["Stonetalon Mountains"] .. "|15|27|2|1||",
    [1443] = L["Desolace"] .. "|30|40|2|1||",
    [1444] = L["Feralas"] .. "|40|50|2|1||",
    [1445] = L["Dustwallow Marsh"] .. "|35|45|2|1||",
    [1446] = L["Tanaris"] .. "|40|50|2|1||",
    [1447] = L["Azshara"] .. "|45|55|1|1||",
    [1448] = L["Felwood"] .. "|48|55|2|1||",
    [1449] = L["Un'Goro Crater"] .. "|48|55|2|1||",
    [1450] = L["Moonglade"] .. "|0|0|2|1||",
    [1451] = L["Silithus"] .. "|55|60|2|1||",
    [1452] = L["Winterspring"] .. "|55|60|2|1||",
    [1453] = L["Stormwind City"] .. "|0|0|0|2||",
    [1454] = L["Orgrimmar"] .. "|0|0|1|1||",
	--[86] = L["Orgrimmar"] .. "|0|0|1|1||",
    [1455] = L["Ironforge"] .. "|0|0|0|2||",
    [1456] = L["Thunder Bluff"] .. "|0|0|1|1||",
    [1457] = L["Darnassus"] .. "|0|0|0|1||",
    [1458] = L["Undercity"] .. "|0|0|1|2||",
    [1459] = L["Alterac Valley"] .. "|0|0|3|4||",
    [1460] = L["Warsong Gulch"] .. "|0|0|3|4||",
    [1461] = L["Arathi Basin"] .. "|0|0|3|4||",
}


Nx.SubNames = {}
