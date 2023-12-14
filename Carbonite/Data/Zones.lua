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
	
	[213] = L["Ragefire Chasm"] .. "|20|60|3|5|85|51.9|58.4|5",
	[219] = L["Zul'Farrak"] .. "|20|60|3|5|71|39.2|21.4|5",
	[220] = L["The Temple of Atal'Hakkar"] .. "|20|60|3|5|51|69.83|54.14|5",
	[225] = L["The Stockade"] .. "|20|60|3|5|84|51.4|68.3|5",
	[226] = L["Gnomeregan"] .. "|20|60|3|5|27|24.38|39.8|5",
	[221] = L["Blackfathom Deeps"] .. "|20|60|3|5|63|14.15|13.9|5",
	[230] = L["Uldaman"] .. "|20|60|3|5|15|44.44|12.19|5",
	[234] = L["Dire Maul"] .. "|20|60|3|5|69|59.1|45.4|5",
	[242] = L["Blackrock Depths"] .. "|20|60|3|5|36|15.70|28.33|5",
	[250] = L["Blackrock Spire"] .. "|20|60|3|5|36|15.70|33.33|10",
	[280] = L["Maraudon"] .. "|20|60|3|5|66|29.48|62.53|5",
	[291] = L["The Deadmines"] .. "|20|60|3|5|52|42.56|71.72|5",
	[279] = L["Wailing Caverns"] .. "|20|60|3|5|10|39|69.4|5",
	[300] = L["Razorfen Downs"] .. "|33|47|3|5|1413|45.43|89.48|5",
	[301] = L["Razorfen Kraul"] .. "|24|40|3|5|1413|43.59|90.16|5",
	[306] = L["Scholomance"] .. "|20|60|3|5|22|69.77|73.51|5",
	[310] = L["Shadowfang Keep"] .. "|20|60|3|5|21|44.86|67.86|5",
	[317] = L["Stratholme"] .. "|20|60|3|5|23|27.09|12.6|5",
	[435] = L["Scarlet Monastery"] .. "|20|60|3|5|18|85.57|36.04|5",
	
	[162] = L["Naxxramas"] .. "|80|90|3|5|115|87.3|50.98|1025",
	[232] = L["Molten Core"] .. "|60|80|3|5|36|20.70|33.33|40",
	[247] = L["Ruins of Ahn'Qiraj"] .. "|60|80|3|5|327|59.1|14|20",
	[248] = L["Onyxia's Lair"] .. "|80|90|3|5|70|52.41|76.39|1025",
	[287] = L["Blackwing Lair"] .. "|60|80|3|5|36|20.70|35.33|40",
	[319] = L["Temple of Ahn'Qiraj"] .. "|60|80|3|5|327|47|7.8|40",
	[337] = L["Zul'Gurub"] .. "|80|90|3|5|50|67.2|32.8|5",
}


Nx.SubNames = {}
