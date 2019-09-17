local L = LibStub("AceLocale-3.0"):GetLocale("Carbonite")

Nx.GuideData [L["Flight Master"]] = {
	["Mode"] = 30
}

local FLIGHT_DATA = {
	["1,1444,30.2,43.2"] = L["Fyldren Moonfeather, Feralas"],
	["1,1437,9.4,59.6"] = L["Shellei Brondir, Wetlands"],
	["1,1455,55.6,48"] = L["Gryth Thurden, Ironforge"],
	["1,1439,36.4,45.6"] = L["Caylais Moonfeather, Darkshore"],
	["2,1441,45,49.2"] = L["Nyse, Thousand Needles"],
	["2,1435,46,54.6"] = L["Breyk, Swamp of Sorrows"],
	["1,1431,77.4,44.4"] = L["Felicia Maline, Duskwood"],
	["2,1450,32.2,66.4"] = L["Faustron, Moonglade"],
	["1,1427,37.8,30.6"] = L["Lanie Reed, Searing Gorge"],
	["1,1425,11,46"] = L["Guthrum Thunderfist, The Hinterlands"],
	["2,1456,46.8,50"] = L["Tal, Thunder Bluff"],
	["0,1449,45.2,5.8"] = L["Gryfe, Un'Goro Crater"],
	["2,1423,80.2,57"] = L["Georgia, Eastern Plaguelands"],
	["2,1440,12.2,33.8"] = L["Andruk, Ashenvale"],
	["1,1423,81.6,59.2"] = L["Khaelyn Steelwing, Eastern Plaguelands"],
	["1,1450,44.2,45.2"] = L["Silva Fil'naveth, Moonglade"],
	["1,1434,27.4,77.6"] = L["Gyll, Stranglethorn Vale"],
	["1,1453,66.2,62.4"] = L["Dungar Longdrink, Stormwind City"],
	["1,1428,84.4,68.2"] = L["Borgus Stoutarm, Burning Steppes"],
	["1,1448,62.4,24.2"] = L["Mishellena, Felwood"],
	["2,1424,60.2,18.6"] = L["Zarise, Hillsbrad Foothills"],
	["1,1442,36.4,7.2"] = L["Teloren, Stonetalon Mountains"],
	["2,1427,34.8,30.6"] = L["Grisha, Searing Gorge"],
	["1,1450,48,67.2"] = L["Sindrayl, Moonglade"],
	["2,1417,73,32.6"] = L["Urda, Arathi Highlands"],
	["1,1424,49.4,52.4"] = L["Darla Harris, Hillsbrad Foothills"],
	["1,1447,11.8,77.4"] = L["Jarrodenus, Azshara"],
	["2,1444,75.4,44.2"] = L["Shyn, Feralas"],
	["2,1446,51.6,25.4"] = L["Bulkrek Ragefist, Tanaris"],
	["1,1445,67.4,51.2"] = L["Baldruc, Dustwallow Marsh"],
	["1,1436,56.4,52.6"] = L["Thor, Westfall"],
	["1,1440,34.4,48"] = L["Daelyshia, Ashenvale"],
	["2,1418,4,44.8"] = L["Gorrik, Badlands"],
	["1,1443,64.6,10.4"] = L["Baritanas Skyriver, Desolace"],
	["2,1413,51.5,30.34"] = L["Devrak, The Barrens"],
	["2,1428,65.6,24.2"] = L["Vahgruk, Burning Steppes"],
	["2,1450,44.4,45.4"] = L["Bunthen Plainswind, Moonglade"],
	["2,1413,44.4,59"] = L["Omusa Thunderhorn, The Barrens"],
	["2,1434,26.8,77"] = L["Gringer, Stranglethorn Vale"],
	["1,1446,51,29.2"] = L["Bera Stonehammer, Tanaris"],
	["1,1452,62.2,36.6"] = L["Maethrya, Winterspring"],
	["2,1442,45.2,59.8"] = L["Tharm, Stonetalon Mountains"],
	["1,1419,65.4,24.4"] = L["Alexandra Constantine, Blasted Lands"],
	["0,1413,63,37"] = L["Bragok, The Barrens"],
	["1,1438,58.4,94"] = L["Vesprystus, Teldrassil"],
	["2,1451,48.8,36.6"] = L["Runk Windtamer, Silithus"],
	["1,1432,33.8,50.8"] = L["Thorgrum Borrelson, Loch Modan"],
	["1,1444,89.4,45.8"] = L["Thyssiana, Feralas"],
	["2,1447,22,49.6"] = L["Kroum, Azshara"],
	["1,1422,43,85"] = L["Bibilfaz Featherwhistle, Western Plaguelands"],
	["1,1433,30.6,59.2"] = L["Ariena Stormfeather, Redridge Mountains"],
	["2,1454,45.2,63.8"] = L["Doras, Orgrimmar"],
	["2,1425,81.6,81.8"] = L["Gorkas, The Hinterlands"],
	["2,1458,63.4,48.6"] = L["Michael Garrett, Undercity"],
	["2,1448,34.4,53.8"] = L["Brakkar, Felwood"],
	["2,1421,45.6,42.4"] = L["Karos Razok, Silverpine Forest"],
	["2,1440,73.2,61.6"] = L["Vhulgra, Ashenvale"],
	["2,1434,32.4,29.2"] = L["Thysta, Stranglethorn Vale"],
	["2,1452,60.4,36.4"] = L["Yugrek, Winterspring"],
	["2,1445,35.6,31.8"] = L["Shardi, Dustwallow Marsh"],
	["1,1417,45.8,46.2"] = L["Cedrik Prose, Arathi Highlands"],
	["1,1451,50.6,34.4"] = L["Cloud Skydancer, Silithus"],
	["2,1443,21.6,74"] = L["Thalon, Desolace"],
}
local NX_FLIGHT_LOC = { ["1"] = L["Alliance Flight"], ["2"] = L["Horde Flight"], ["0"] = L["Neutral Flight"], }
Nx.NPCData={}
for k, v in pairs(FLIGHT_DATA) do
	local side, zon, x, y, level = Nx.Split(",", k)
	if not level then level = 0 end
	local name = v
	name = NX_FLIGHT_LOC[side].."|"..name
	x,y,zon=tonumber(x),tonumber(y),tonumber(zon)
	table.insert(Nx.NPCData, format("%s|%s|%s|%s|%s|%s",side,name,zon,x,y,level))
	local i = #Nx.NPCData
	if not Nx.GuideData[L["Flight Master"]][zon] then
		Nx.GuideData[L["Flight Master"]][zon] = format("%s,%s,%s,%s,%s",side,x,y,level,i)
	else
		Nx.GuideData[L["Flight Master"]][zon]=Nx.GuideData[L["Flight Master"]][zon] .. format("|%s,%s,%s,%s,%s",side,x,y,level,i)
	end
end
FLIGHT_DATA = nil
NX_FLIGHT_LOC=nil
Nx.FlightConnection=""
