if not Nx.ModQuests then
	Nx.ModQuests = {}
end

function Nx.ModQuests:Data0()
	local ModQuests={
		[171] = {
			Quest = [[A Warden of the Alliance|1|0|10|0|0]],
		},
		[172] = {
			Quest = [[Children's Week|2|0|10|0|0]],
		},
		[558] = {
			Quest = [[Jaina's Autograph|1|0|10|0|0]],
		},
		[915] = {
			Quest = [[You Scream, I Scream...|0|0|10|0|0]],
		},
		[925] = {
			Quest = [[Cairne's Hoofprint|0|0|10|0|0]],
		},
		[1036] = {
			Quest = [[Avast Ye, Scallywag|0|0|55|4621|0]],
			Start = "938|1434|32|27.40|69.40",
			End = "1|1434|32|30.60|90.20",
		},
		[4621] = {
			Quest = [[Avast Ye, Admiral!|0|0|30|0|0]],
			Start = "1|1434|32|30.60|90.20",
			End = "1|1434|32|30.60|90.20",
			Objectives = {
				[1] = {
					"nil|1434|32|26.72|76.08|9.62|9.62",
				 },
				[2] = {
					"nil|1434|32|26.72|76.08|9.62|9.62",
				 },
			},
		},
		[4822] = {
			Quest = [[You Scream, I Scream...|1|0|10|0|0]],
		},
		[5502] = {
			Quest = [[A Warden of the Horde|2|0|10|0|0]],
		},
		[5656] = {
			Quest = [[Hex of Weakness|0|0|10|0|0]],
		},
		[6961] = {
			Quest = [[Great-father Winter is Here!|2|0|10|0|0]],
		},
		[6962] = {
			Quest = [[Treats for Great-father Winter|2|0|10|0|0]],
			Objectives = {
				[1] = {
					"nil|1413|35|59.52|2.88|28.86|9.62",
					"nil|1413|35|57.60|4.32|67.33|9.62",
					"nil|1413|35|44.16|5.76|19.24|9.62",
					"nil|1413|35|55.68|5.76|96.19|9.62",
					"nil|1413|35|42.24|7.20|48.10|9.62",
					"nil|1413|35|53.76|7.20|125.05|9.62",
					"nil|1413|35|40.32|8.64|76.95|9.62",
					"nil|1413|35|51.84|8.64|153.91|9.62",
					"nil|1413|35|38.40|10.08|105.81|9.62",
					"nil|1413|35|49.92|10.08|182.76|9.62",
					"nil|1413|35|6.72|11.52|9.62|9.62",
					"nil|1413|35|36.48|11.52|327.05|9.62",
					"nil|1413|35|5.76|12.96|28.86|9.62",
					"nil|1413|35|20.16|12.96|9.62|9.62",
					"nil|1413|35|34.56|12.96|355.91|9.62",
					"nil|1413|35|76.80|12.96|19.24|9.62",
					"nil|1413|35|6.72|14.40|19.24|9.62",
					"nil|1413|35|18.24|14.40|48.10|9.62",
					"nil|1413|35|33.60|14.40|375.15|9.62",
					"nil|1413|35|74.88|14.40|57.72|9.62",
					"nil|1413|35|6.72|15.84|28.86|9.62",
					"nil|1413|35|16.32|15.84|86.57|9.62",
					"nil|1413|35|32.64|15.84|490.58|9.62",
					"nil|1413|35|7.68|17.28|19.24|9.62",
					"nil|1413|35|14.40|17.28|125.05|9.62",
					"nil|1413|35|31.68|17.28|490.58|9.62",
					"nil|1413|35|8.64|18.72|721.44|9.62",
					"nil|1413|35|8.64|20.16|711.82|19.24",
					"nil|1413|35|9.60|23.04|615.63|9.62",
					"nil|1413|35|72.00|23.04|67.33|9.62",
					"nil|1413|35|9.60|24.48|606.01|9.62",
					"nil|1413|35|73.92|24.48|48.10|9.62",
					"nil|1413|35|10.56|25.92|48.10|9.62",
					"nil|1413|35|18.24|25.92|509.82|9.62",
					"nil|1413|35|75.84|25.92|9.62|9.62",
					"nil|1413|35|10.56|27.36|48.10|9.62",
					"nil|1413|35|17.28|27.36|509.82|9.62",
					"nil|1413|35|11.52|28.80|548.29|9.62",
					"nil|1413|35|13.44|30.24|490.58|9.62",
					"nil|1413|35|15.36|31.68|461.72|9.62",
					"nil|1413|35|16.32|33.12|442.48|9.62",
					"nil|1413|35|17.28|34.56|432.86|9.62",
					"nil|1413|35|19.20|36.00|413.63|9.62",
					"nil|1413|35|20.16|37.44|57.72|9.62",
					"nil|1413|35|26.88|37.44|38.48|9.62",
					"nil|1413|35|34.56|37.44|278.96|9.62",
					"nil|1413|35|21.12|38.88|86.57|9.62",
					"nil|1413|35|33.60|38.88|307.81|9.62",
					"nil|1413|35|22.08|40.32|442.48|9.62",
					"nil|1413|35|23.04|41.76|432.86|9.62",
					"nil|1413|35|23.04|43.20|442.48|9.62",
					"nil|1413|35|24.00|44.64|432.86|9.62",
					"nil|1413|35|24.00|46.08|442.48|9.62",
					"nil|1413|35|24.00|47.52|442.48|9.62",
					"nil|1413|35|24.00|48.96|452.10|9.62",
					"nil|1413|35|24.00|50.40|153.91|9.62",
					"nil|1413|35|40.32|50.40|288.58|9.62",
					"nil|1413|35|24.00|51.84|461.72|9.62",
					"nil|1413|35|24.96|53.28|452.10|9.62",
					"nil|1413|35|24.96|54.72|471.34|9.62",
					"nil|1413|35|25.92|56.16|480.96|9.62",
					"nil|1413|35|25.92|57.60|500.20|9.62",
					"nil|1413|35|26.88|59.04|500.20|9.62",
					"nil|1413|35|14.40|60.48|19.24|9.62",
					"nil|1413|35|26.88|60.48|500.20|9.62",
					"nil|1413|35|13.44|61.92|48.10|9.62",
					"nil|1413|35|27.84|61.92|490.58|9.62",
					"nil|1413|35|14.40|63.36|48.10|9.62",
					"nil|1413|35|29.76|63.36|471.34|9.62",
					"nil|1413|35|14.40|64.80|38.48|9.62",
					"nil|1413|35|34.56|64.80|423.24|9.62",
					"nil|1413|35|15.36|66.24|9.62|9.62",
					"nil|1413|35|33.60|66.24|432.86|9.62",
					"nil|1413|35|32.64|67.68|442.48|9.62",
					"nil|1413|35|31.68|69.12|192.38|9.62",
					"nil|1413|35|56.64|69.12|202.00|9.62",
					"nil|1413|35|30.72|70.56|202.00|9.62",
					"nil|1413|35|55.68|70.56|211.62|9.62",
					"nil|1413|35|23.04|72.00|9.62|9.62",
					"nil|1413|35|29.76|72.00|211.62|9.62",
					"nil|1413|35|54.72|72.00|115.43|9.62",
					"nil|1413|35|72.96|72.00|38.48|9.62",
					"nil|1413|35|22.08|73.44|38.48|9.62",
					"nil|1413|35|28.80|73.44|221.24|9.62",
					"nil|1413|35|53.76|73.44|115.43|9.62",
					"nil|1413|35|73.92|73.44|38.48|9.62",
					"nil|1413|35|23.04|74.88|259.72|9.62",
					"nil|1413|35|51.84|74.88|125.05|9.62",
					"nil|1413|35|74.88|74.88|38.48|9.62",
					"nil|1413|35|24.00|76.32|192.38|9.62",
					"nil|1413|35|50.88|76.32|134.67|9.62",
					"nil|1413|35|74.88|76.32|48.10|9.62",
					"nil|1413|35|24.96|77.76|182.76|9.62",
					"nil|1413|35|51.84|77.76|115.43|9.62",
					"nil|1413|35|74.88|77.76|57.72|9.62",
					"nil|1413|35|25.92|79.20|173.15|9.62",
					"nil|1413|35|51.84|79.20|96.19|9.62",
					"nil|1413|35|74.88|79.20|67.33|9.62",
					"nil|1413|35|25.92|80.64|182.76|9.62",
					"nil|1413|35|52.80|80.64|9.62|9.62",
					"nil|1413|35|73.92|80.64|96.19|9.62",
					"nil|1413|35|25.92|82.08|192.38|9.62",
					"nil|1413|35|73.92|82.08|115.43|9.62",
					"nil|1413|35|25.92|83.52|202.00|9.62",
					"nil|1413|35|72.96|83.52|134.67|9.62",
					"nil|1413|35|25.92|84.96|202.00|9.62",
					"nil|1413|35|72.96|84.96|134.67|9.62",
					"nil|1413|35|26.88|86.40|202.00|9.62",
					"nil|1413|35|72.00|86.40|134.67|9.62",
					"nil|1413|35|26.88|87.84|192.38|9.62",
					"nil|1413|35|72.00|87.84|134.67|9.62",
					"nil|1413|35|27.84|89.28|163.53|9.62",
					"nil|1413|35|71.04|89.28|125.05|9.62",
					"nil|1413|35|29.76|90.72|125.05|9.62",
					"nil|1413|35|71.04|90.72|115.43|9.62",
					"nil|1413|35|31.68|92.16|86.57|9.62",
					"nil|1413|35|70.08|92.16|105.81|9.62",
					"nil|1413|35|33.60|93.60|48.10|9.62",
					"nil|1413|35|70.08|93.60|86.57|9.62",
					"nil|1413|35|35.52|95.04|9.62|9.62",
					"nil|1413|35|71.04|95.04|57.72|9.62",
					"nil|1413|35|72.00|96.48|28.86|9.62",
				 },
			},
		},
		[6983] = {
			Quest = [[You're a Mean One...|2|0|60|6984|0]],
		},
		[6984] = {
			Quest = [[A Smokywood Pastures Thank You!|2|0|30|0|0]],
		},
		[7021] = {
			Quest = [[Great-father Winter is Here!|2|0|10|0|0]],
		},
		[7024] = {
			Quest = [[Great-father Winter is Here!|2|0|10|0|0]],
		},
		[7043] = {
			Quest = [[You're a Mean One...|1|0|60|7045|0]],
		},
		[7045] = {
			Quest = [[A Smokywood Pastures Thank You!|1|0|30|0|0]],
		},
		[7061] = {
			Quest = [[The Feast of Winter Veil|2|0|10|0|0]],
			Start = "116|1454|32|38.60|36.20",
			End = "117|1456|32|60.00|51.60",
		},
		[7063] = {
			Quest = [[The Feast of Winter Veil|1|0|10|0|0]],
			Start = "115|1455|32|77.20|11.80",
		},
		[7165] = {
			Quest = [[Earned Reverence|2|0|51|0|0]],
			Start = "104|1416|32|62.20|59.00",
			End = "104|1416|32|62.20|59.00",
		},
		[7166] = {
			Quest = [[Legendary Heroes|2|0|51|0|0]],
			Start = "104|1416|32|62.20|59.00",
			End = "104|1416|32|62.20|59.00",
		},
		[7167] = {
			Quest = [[The Eye of Command|2|0|51|0|0]],
			Start = "104|1416|32|62.20|59.00",
			End = "104|1416|32|62.20|59.00",
		},
		[7170] = {
			Quest = [[Earned Reverence|1|0|51|0|0]],
			Start = "103|1416|32|39.60|81.00",
			End = "103|1416|32|39.60|81.00",
		},
		[7171] = {
			Quest = [[Legendary Heroes|1|0|51|0|0]],
			Start = "103|1416|32|39.60|81.00",
			End = "103|1416|32|39.60|81.00",
		},
		[7172] = {
			Quest = [[The Eye of Command|1|0|51|0|0]],
			Start = "103|1416|32|39.60|81.00",
			End = "103|1416|32|39.60|81.00",
		},
		[7463] = {
			Quest = [[Arcane Refreshment|0|0|60|0|0]],
		},
		[7564] = {
			Quest = [[Wildeyes|0|0|60|0|0]],
		},
		[7624] = {
			Quest = [[Ulathek the Traitor|0|0|60|0|0]],
		},
		[7626] = {
			Quest = [[Bell of Dethmoora|0|0|60|0|0]],
		},
		[7627] = {
			Quest = [[Wheel of the Black March|0|0|60|0|0]],
		},
		[7628] = {
			Quest = [[Doomsday Candle|0|0|60|0|0]],
		},
		[7630] = {
			Quest = [[Arcanite|0|0|60|0|0]],
		},
		[7639] = {
			Quest = [[To Show Due Judgment|0|0|60|0|0]],
		},
		[7643] = {
			Quest = [[Ancient Equine Spirit|0|0|60|0|0]],
		},
		[7644] = {
			Quest = [[Blessed Arcanite Barding|0|0|60|0|0]],
		},
		[7645] = {
			Quest = [[Manna-Enriched Horse Feed|0|0|60|0|0]],
		},
		[7646] = {
			Quest = [[The Divination Scryer|0|0|60|0|0]],
			Objectives = {
				[1] = {
					"nil|1447|35|52.80|37.44|19.24|9.62",
					"nil|1447|35|45.12|38.88|9.62|9.62",
					"nil|1447|35|51.84|38.88|48.10|9.62",
					"nil|1447|35|44.16|40.32|28.86|9.62",
					"nil|1447|35|52.80|40.32|57.72|9.62",
					"nil|1447|35|45.12|41.76|9.62|9.62",
					"nil|1447|35|54.72|41.76|48.10|9.62",
					"nil|1447|35|68.16|41.76|38.48|9.62",
					"nil|1447|35|56.64|43.20|19.24|9.62",
					"nil|1447|35|66.24|43.20|76.95|9.62",
					"nil|1447|35|65.28|44.64|105.81|9.62",
					"nil|1447|35|66.24|46.08|105.81|9.62",
					"nil|1447|35|67.20|47.52|86.57|9.62",
					"nil|1447|35|69.12|48.96|57.72|9.62",
					"nil|1447|35|71.04|50.40|19.24|9.62",
					"nil|1447|35|29.76|51.84|9.62|9.62",
					"nil|1447|35|42.24|51.84|9.62|9.62",
					"nil|1447|35|49.92|51.84|9.62|9.62",
					"nil|1447|35|27.84|53.28|38.48|9.62",
					"nil|1447|35|40.32|53.28|38.48|9.62",
					"nil|1447|35|48.96|53.28|28.86|9.62",
					"nil|1447|35|25.92|54.72|48.10|9.62",
					"nil|1447|35|39.36|54.72|48.10|9.62",
					"nil|1447|35|49.92|54.72|9.62|9.62",
					"nil|1447|35|24.96|56.16|57.72|9.62",
					"nil|1447|35|40.32|56.16|28.86|9.62",
					"nil|1447|35|24.00|57.60|57.72|9.62",
					"nil|1447|35|40.32|57.60|28.86|9.62",
					"nil|1447|35|22.08|59.04|76.95|9.62",
					"nil|1447|35|41.28|59.04|9.62|9.62",
					"nil|1447|35|20.16|60.48|86.57|9.62",
					"nil|1447|35|18.24|61.92|105.81|9.62",
					"nil|1447|35|18.24|63.36|86.57|9.62",
					"nil|1447|35|17.28|64.80|76.95|9.62",
					"nil|1447|35|17.28|66.24|48.10|9.62",
					"nil|1447|35|60.48|66.24|9.62|9.62",
					"nil|1447|35|16.32|67.68|48.10|9.62",
					"nil|1447|35|59.52|67.68|28.86|9.62",
					"nil|1447|35|16.32|69.12|38.48|9.62",
					"nil|1447|35|60.48|69.12|9.62|9.62",
					"nil|1447|35|15.36|70.56|38.48|9.62",
					"nil|1447|35|15.36|72.00|28.86|9.62",
					"nil|1447|35|14.40|73.44|28.86|9.62",
					"nil|1447|35|15.36|74.88|9.62|9.62",
					"nil|1447|35|64.32|82.08|9.62|9.62",
					"nil|1447|35|63.36|83.52|28.86|9.62",
					"nil|1447|35|64.32|84.96|9.62|9.62",
				 },
			},
		},
		[7648] = {
			Quest = [[Grimand's Finest Work|0|0|60|0|0]],
		},
		[7666] = {
			Quest = [[Again Into the Great Ossuary|0|0|60|0|0]],
		},
		[7939] = {
			Quest = [[More Dense Grinding Stones|0|0|40|0|0]],
		},
		[7941] = {
			Quest = [[More Armor Kits|0|0|40|0|0]],
		},
		[7942] = {
			Quest = [[More Thorium Widgets|0|0|40|0|0]],
		},
		[7943] = {
			Quest = [[More Bat Eyes|0|0|40|0|0]],
		},
		[8223] = {
			Quest = [[More Glowing Scorpid Blood|0|0|40|0|0]],
		},
		[8228] = {
			Quest = [[Could I get a Fishing Flier?|2|0|35|0|0]],
		},
		[8229] = {
			Quest = [[Could I get a Fishing Flier?|1|0|35|0|0]],
		},
		[8272] = {
			Quest = [[Hero of the Frostwolf|2|0|51|0|0]],
			Start = "41|1416|32|63.60|60.60",
			End = "41|1416|32|63.60|60.60",
		},
		[8278] = {
			Quest = [[Noggle's Last Hope|0|0|40|0|0]],
		},
		[8279] = {
			Quest = [[The Twilight Lexicon|0|0|40|8287|0]],
			Start = "35|1451|32|66.80|69.60",
			End = "35|1451|32|66.80|69.60",
		},
		[8281] = {
			Quest = [[Stepping Up Security|0|0|40|0|0]],
			Objectives = {
				[1] = {
					"nil|1451|35|35.52|36.00|9.62|9.62",
					"nil|1451|35|34.56|37.44|28.86|9.62",
					"nil|1451|35|35.52|38.88|9.62|9.62",
					"nil|1451|35|18.24|43.20|9.62|9.62",
					"nil|1451|35|17.28|44.64|28.86|9.62",
					"nil|1451|35|18.24|46.08|9.62|9.62",
					"nil|1451|35|37.44|51.84|76.95|9.62",
					"nil|1451|35|35.52|53.28|115.43|9.62",
					"nil|1451|35|34.56|54.72|134.67|9.62",
					"nil|1451|35|35.52|56.16|134.67|9.62",
					"nil|1451|35|37.44|57.60|125.05|9.62",
					"nil|1451|35|39.36|59.04|9.62|9.62",
					"nil|1451|35|47.04|59.04|38.48|9.62",
					"nil|1451|35|48.00|60.48|38.48|9.62",
					"nil|1451|35|49.92|61.92|9.62|9.62",
				 },
			},
		},
		[8282] = {
			Quest = [[Noggle's Lost Satchel|0|0|40|0|0]],
			Objectives = {
				[1] = {
					"nil|1451|32|43.52|89.28|9.62|9.62",
				 },
			},
		},
		[8285] = {
			Quest = [[The Deserter|0|0|40|8279|0]],
			End = "35|1451|32|66.80|69.60",
		},
		[8287] = {
			Quest = [[A Terrible Purpose|0|0|40|0|0]],
			Start = "35|1451|32|66.80|69.60",
			End = "39|1451|32|49.20|34.40",
		},
		[8304] = {
			Quest = [[Dearest Natalia|0|0|40|8306|0]],
			Start = "39|1451|32|49.20|34.40",
			End = "39|1451|32|49.20|34.40",
		},
		[8306] = {
			Quest = [[Into The Maw of Madness|0|0|40|0|0]],
			Start = "39|1451|32|49.20|34.40",
			End = "39|1451|32|49.20|34.40",
		},
		[8307] = {
			Quest = [[Desert Recipe|0|0|40|8313|0]],
			Start = "36|1451|32|51.80|39.00",
		},
		[8309] = {
			Quest = [[Glyph Chasing|0|0|40|0|0]],
			Start = "37|1451|32|41.20|88.60",
			End = "37|1451|32|41.20|88.60",
		},
		[8310] = {
			Quest = [[Breaking the Code|0|0|40|0|0]],
			Start = "38|1451|32|40.80|88.80",
			End = "38|1451|32|40.80|88.80",
			Objectives = {
				[1] = {
					"nil|1451|35|55.68|67.68|9.62|9.62",
					"nil|1451|35|54.72|69.12|67.33|9.62",
					"nil|1451|35|54.72|70.56|86.57|9.62",
					"nil|1451|35|53.76|72.00|115.43|9.62",
					"nil|1451|35|53.76|73.44|134.67|9.62",
					"nil|1451|35|53.76|74.88|134.67|9.62",
					"nil|1451|35|53.76|76.32|144.29|19.24",
					"nil|1451|35|51.84|79.20|163.53|9.62",
					"nil|1451|35|49.92|80.64|173.15|9.62",
					"nil|1451|35|48.00|82.08|192.38|9.62",
					"nil|1451|35|47.04|83.52|192.38|9.62",
					"nil|1451|35|47.04|84.96|192.38|9.62",
					"nil|1451|35|47.04|86.40|182.76|19.24",
					"nil|1451|35|48.00|89.28|96.19|9.62",
					"nil|1451|35|58.56|89.28|67.33|9.62",
					"nil|1451|35|48.00|90.72|86.57|9.62",
					"nil|1451|35|59.52|90.72|57.72|9.62",
					"nil|1451|35|48.96|92.16|67.33|9.62",
					"nil|1451|35|60.48|92.16|48.10|9.62",
					"nil|1451|35|48.96|93.60|67.33|9.62",
					"nil|1451|35|61.44|93.60|38.48|9.62",
					"nil|1451|35|49.92|95.04|48.10|9.62",
					"nil|1451|35|61.44|95.04|28.86|9.62",
					"nil|1451|35|50.88|96.48|28.86|9.62",
					"nil|1451|35|62.40|96.48|9.62|9.62",
				 },
			},
		},
		[8313] = {
			Quest = [[Sharing the Knowledge|0|0|40|8317|0]],
			End = "36|1451|32|51.80|39.00",
		},
		[8314] = {
			Quest = [[Unraveling the Mystery|0|0|40|0|0]],
			Start = "37|1451|32|41.20|88.60",
		},
		[8316] = {
			Quest = [[Armaments of War|0|0|40|0|0]],
		},
		[8317] = {
			Quest = [[Kitchen Assistance|0|0|40|0|0]],
			Start = "36|1451|32|51.80|39.00",
			End = "36|1451|32|51.80|39.00",
		},
		[8319] = {
			Quest = [[Encrypted Twilight Texts|0|0|40|0|0]],
		},
		[8321] = {
			Quest = [[Vyral the Vile|0|0|40|0|0]],
		},
		[8323] = {
			Quest = [[True Believers|0|0|40|0|0]],
			Start = "35|1451|32|66.80|69.60",
			End = "35|1451|32|66.80|69.60",
		},
		[8324] = {
			Quest = [[Still Believing|0|0|40|0|0]],
			Start = "35|1451|32|66.80|69.60",
			End = "35|1451|32|66.80|69.60",
		},
		[8353] = {
			Quest = [[Chicken Clucking for a Mint|1|0|10|0|0]],
			Start = "34|1455|32|18.60|51.40",
			End = "34|1455|32|18.60|51.40",
			Objectives = {
				[1] = {
					"nil|1455|35|18.24|50.40|9.62|9.62",
					"nil|1455|35|17.28|51.84|28.86|9.62",
					"nil|1455|35|18.24|53.28|9.62|9.62",
				 },
			},
		},
		[8354] = {
			Quest = [[Chicken Clucking for a Mint|2|0|10|0|0]],
			Start = "33|1458|32|67.60|38.00",
			End = "33|1458|32|67.60|38.00",
			Objectives = {
				[1] = {
					"nil|1458|35|67.20|36.00|9.62|9.62",
					"nil|1458|35|66.24|37.44|28.86|9.62",
					"nil|1458|35|67.20|38.88|9.62|9.62",
				 },
			},
		},
		[8355] = {
			Quest = [[Incoming Gumdrop|1|0|10|0|0]],
			Start = "32|1455|32|36.00|4.00",
			End = "32|1455|32|36.00|4.00",
			Objectives = {
				[1] = {
					"nil|1455|35|36.48|4.32|9.62|9.62",
					"nil|1455|35|35.52|5.76|28.86|9.62",
					"nil|1455|35|36.48|7.20|9.62|9.62",
				 },
			},
		},
		[8356] = {
			Quest = [[Flexing for Nougat|1|0|10|0|0]],
			Start = "31|1453|32|52.80|65.40",
			End = "31|1453|32|52.80|65.40",
			Objectives = {
				[1] = {
					"nil|1453|35|52.80|63.36|9.62|9.62",
					"nil|1453|35|51.84|64.80|28.86|9.62",
					"nil|1453|35|51.84|66.24|28.86|9.62",
					"nil|1453|35|52.80|67.68|9.62|9.62",
				 },
			},
		},
		[8357] = {
			Quest = [[Dancing for Marzipan|1|0|10|0|0]],
			Start = "30|1457|32|67.20|15.60",
			End = "30|1457|32|67.20|15.60",
			Objectives = {
				[1] = {
					"nil|1457|35|67.20|14.40|9.62|9.62",
					"nil|1457|35|66.24|15.84|28.86|9.62",
					"nil|1457|35|67.20|17.28|9.62|9.62",
				 },
			},
		},
		[8358] = {
			Quest = [[Incoming Gumdrop|2|0|10|0|0]],
			Start = "29|1411|32|56.20|74.20",
			End = "29|1411|32|56.20|74.20",
			Objectives = {
				[1] = {
					"nil|1411|32|55.72|73.48|9.62|9.62",
				 },
			},
		},
		[8359] = {
			Quest = [[Flexing for Nougat|2|0|10|0|0]],
			Start = "28|1454|32|54.00|68.60",
			End = "28|1454|32|54.00|68.60",
			Objectives = {
				[1] = {
					"nil|1454|35|53.76|67.68|9.62|9.62",
					"nil|1454|35|52.80|69.12|28.86|9.62",
					"nil|1454|35|53.76|70.56|9.62|9.62",
				 },
			},
		},
		[8360] = {
			Quest = [[Dancing for Marzipan|2|0|10|0|0]],
			Start = "8|1456|32|45.60|64.20",
			End = "8|1456|32|45.60|64.20",
			Objectives = {
				[1] = {
					"nil|1456|35|45.12|61.92|9.62|9.62",
					"nil|1456|35|44.16|63.36|28.86|9.62",
					"nil|1456|35|45.12|64.80|28.86|9.62",
					"nil|1456|35|46.08|66.24|9.62|9.62",
				 },
			},
		},
		[8376] = {
			Quest = [[Armaments of War|0|0|40|0|0]],
		},
		[8377] = {
			Quest = [[Armaments of War|0|0|40|0|0]],
		},
		[8381] = {
			Quest = [[Armaments of War|0|0|40|0|0]],
		},
		[8385] = {
			Quest = [[Concerted Efforts|0|0|61|0|0]],
		},
		[8388] = {
			Quest = [[For Great Honor|0|0|61|0|0]],
		},
		[8481] = {
			Quest = [[The Root of All Evil|0|0|40|0|0]],
			Start = "15|1448|32|65.20|2.60",
			End = "15|1448|32|65.20|2.60",
		},
		[8828] = {
			Quest = [[Winter's Presents|2|0|1|0|0]],
		},
		[8861] = {
			Quest = [[New Year Celebrations!|2|0|1|0|0]],
			End = "8|1456|32|45.60|64.20",
		},
		[8873] = {
			Quest = [[The Lunar Festival|2|0|1|0|0]],
		},
		[8874] = {
			Quest = [[The Lunar Festival|2|0|1|0|0]],
		},
		[8875] = {
			Quest = [[The Lunar Festival|2|0|1|0|0]],
		},
		[8883] = {
			Quest = [[Valadar Starsong|0|0|1|0|0]],
		},
		[9068] = {
			Quest = [[Earthshatter Tunic|0|0|0|0|0]],
		},
		[9069] = {
			Quest = [[Earthshatter Legguards|0|0|0|0|0]],
		},
		[9070] = {
			Quest = [[Earthshatter Headpiece|0|0|0|0|0]],
		},
		[9072] = {
			Quest = [[Earthshatter Boots|0|0|0|0|0]],
		},
		[9073] = {
			Quest = [[Earthshatter Handguards|0|0|0|0|0]],
		},
		[9074] = {
			Quest = [[Earthshatter Girdle|0|0|0|0|0]],
		},
		[9075] = {
			Quest = [[Earthshatter Wristguards|0|0|0|0|0]],
		},
		[9094] = {
			Quest = [[Argent Dawn Gloves|0|0|50|0|0]],
		},
		[9257] = {
			Quest = [[Atiesh, Greatstaff of the Guardian|0|0|0|0|0]],
		},
		[9259] = {
			Quest = [[Traitor to the Bloodsail|0|0|30|0|0]],
			Start = "4|1434|32|31.60|70.80",
			End = "4|1434|32|31.60|70.80",
			Objectives = {
				[1] = {
					"nil|1434|35|24.96|2.88|250.10|9.62",
					"nil|1434|35|23.04|4.32|288.58|9.62",
					"nil|1434|35|21.12|5.76|307.81|9.62",
					"nil|1434|35|19.20|7.20|327.05|9.62",
					"nil|1434|35|18.24|8.64|336.67|9.62",
					"nil|1434|35|18.24|10.08|327.05|9.62",
					"nil|1434|35|17.28|11.52|336.67|9.62",
					"nil|1434|35|17.28|12.96|336.67|9.62",
					"nil|1434|35|17.28|14.40|211.62|9.62",
					"nil|1434|35|39.36|14.40|115.43|9.62",
					"nil|1434|35|17.28|15.84|211.62|9.62",
					"nil|1434|35|39.36|15.84|115.43|9.62",
					"nil|1434|35|17.28|17.28|211.62|9.62",
					"nil|1434|35|39.36|17.28|115.43|9.62",
					"nil|1434|35|17.28|18.72|346.29|9.62",
					"nil|1434|35|18.24|20.16|336.67|9.62",
					"nil|1434|35|18.24|21.60|346.29|9.62",
					"nil|1434|35|19.20|23.04|336.67|9.62",
					"nil|1434|35|19.20|24.48|346.29|9.62",
					"nil|1434|35|20.16|25.92|336.67|9.62",
					"nil|1434|35|30.72|27.36|240.48|9.62",
					"nil|1434|35|31.68|28.80|230.86|9.62",
					"nil|1434|35|32.64|30.24|211.62|9.62",
					"nil|1434|35|33.60|31.68|202.00|9.62",
					"nil|1434|35|34.56|33.12|182.76|19.24",
					"nil|1434|35|35.52|36.00|173.15|9.62",
					"nil|1434|35|35.52|37.44|163.53|19.24",
					"nil|1434|35|35.52|40.32|153.91|19.24",
					"nil|1434|35|35.52|43.20|144.29|9.62",
					"nil|1434|35|34.56|44.64|153.91|9.62",
					"nil|1434|35|33.60|46.08|153.91|9.62",
					"nil|1434|35|25.92|47.52|230.86|9.62",
					"nil|1434|35|24.00|48.96|240.48|9.62",
					"nil|1434|35|22.08|50.40|250.10|9.62",
					"nil|1434|35|21.12|51.84|250.10|9.62",
					"nil|1434|35|21.12|53.28|240.48|9.62",
					"nil|1434|35|21.12|54.72|230.86|9.62",
					"nil|1434|35|21.12|56.16|86.57|9.62",
					"nil|1434|35|30.72|56.16|134.67|9.62",
					"nil|1434|35|21.12|57.60|221.24|19.24",
					"nil|1434|35|22.08|60.48|202.00|9.62",
					"nil|1434|35|22.08|61.92|96.19|9.62",
					"nil|1434|35|33.60|61.92|86.57|9.62",
					"nil|1434|35|23.04|63.36|86.57|9.62",
					"nil|1434|35|33.60|63.36|76.95|9.62",
					"nil|1434|35|23.04|64.80|182.76|9.62",
					"nil|1434|35|24.00|66.24|163.53|19.24",
					"nil|1434|35|24.96|69.12|144.29|19.24",
					"nil|1434|35|24.96|72.00|134.67|9.62",
					"nil|1434|35|24.96|73.44|125.05|9.62",
					"nil|1434|35|24.96|74.88|125.05|19.24",
					"nil|1434|35|24.96|77.76|125.05|19.24",
					"nil|1434|35|24.96|80.64|125.05|9.62",
					"nil|1434|35|24.00|82.08|134.67|9.62",
					"nil|1434|35|24.00|83.52|125.05|9.62",
					"nil|1434|35|24.00|84.96|125.05|9.62",
					"nil|1434|35|24.96|86.40|105.81|19.24",
					"nil|1434|35|25.92|89.28|86.57|9.62",
					"nil|1434|35|27.84|90.72|67.33|9.62",
					"nil|1434|35|29.76|92.16|38.48|9.62",
					"nil|1434|35|31.68|93.60|9.62|9.62",
				 },
			},
		},
		[9266] = {
			Quest = [[Making Amends|0|0|0|0|0]],
		},
		[9267] = {
			Quest = [[Mending Old Wounds|0|0|10|0|0]],
			Start = "3|1413|32|61.20|37.80",
			End = "3|1413|32|61.20|37.80",
			Objectives = {
				[1] = {
					"nil|1413|35|59.52|2.88|38.48|9.62",
					"nil|1413|35|57.60|4.32|76.95|9.62",
					"nil|1413|35|55.68|5.76|96.19|9.62",
					"nil|1413|35|53.76|7.20|125.05|9.62",
					"nil|1413|35|51.84|8.64|144.29|9.62",
					"nil|1413|35|38.40|10.08|19.24|9.62",
					"nil|1413|35|49.92|10.08|173.15|9.62",
					"nil|1413|35|37.44|11.52|298.20|9.62",
					"nil|1413|35|36.48|12.96|307.81|19.24",
					"nil|1413|35|36.48|15.84|307.81|19.24",
					"nil|1413|35|37.44|18.72|298.20|9.62",
					"nil|1413|35|37.44|20.16|298.20|19.24",
					"nil|1413|35|37.44|23.04|298.20|19.24",
					"nil|1413|35|37.44|25.92|298.20|9.62",
					"nil|1413|35|37.44|27.36|298.20|19.24",
					"nil|1413|35|38.40|30.24|288.58|9.62",
					"nil|1413|35|38.40|31.68|288.58|9.62",
					"nil|1413|35|39.36|33.12|278.96|9.62",
					"nil|1413|35|39.36|34.56|288.58|19.24",
					"nil|1413|35|39.36|37.44|288.58|19.24",
					"nil|1413|35|39.36|40.32|288.58|19.24",
					"nil|1413|35|39.36|43.20|278.96|19.24",
					"nil|1413|35|39.36|46.08|278.96|9.62",
					"nil|1413|35|40.32|47.52|269.34|19.24",
					"nil|1413|35|40.32|50.40|269.34|9.62",
					"nil|1413|35|41.28|51.84|250.10|19.24",
					"nil|1413|35|42.24|54.72|230.86|9.62",
					"nil|1413|35|42.24|56.16|230.86|9.62",
					"nil|1413|35|42.24|57.60|221.24|9.62",
					"nil|1413|35|42.24|59.04|144.29|9.62",
					"nil|1413|35|42.24|60.48|134.67|9.62",
					"nil|1413|35|43.20|61.92|115.43|9.62",
					"nil|1413|35|43.20|63.36|105.81|9.62",
					"nil|1413|35|43.20|64.80|96.19|9.62",
					"nil|1413|35|43.20|66.24|86.57|9.62",
					"nil|1413|35|43.20|67.68|76.95|19.24",
					"nil|1413|35|43.20|70.56|76.95|9.62",
					"nil|1413|35|42.24|72.00|86.57|19.24",
					"nil|1413|35|41.28|74.88|96.19|19.24",
					"nil|1413|35|40.32|77.76|105.81|9.62",
					"nil|1413|35|40.32|79.20|115.43|9.62",
					"nil|1413|35|39.36|80.64|125.05|19.24",
					"nil|1413|35|39.36|83.52|125.05|9.62",
					"nil|1413|35|39.36|84.96|115.43|9.62",
					"nil|1413|35|40.32|86.40|105.81|9.62",
					"nil|1413|35|40.32|87.84|96.19|9.62",
					"nil|1413|35|41.28|89.28|67.33|9.62",
					"nil|1413|35|41.28|90.72|48.10|9.62",
					"nil|1413|35|42.24|92.16|19.24|9.62",
				 },
			},
		},
		[9268] = {
			Quest = [[War at Sea|0|0|40|0|0]],
			Start = "2|1446|32|50.40|26.20",
			End = "2|1446|32|50.40|26.20",
			Objectives = {
				[1] = {
					"nil|1446|35|38.40|18.72|38.48|9.62",
					"nil|1446|35|36.48|20.16|76.95|9.62",
					"nil|1446|35|60.48|20.16|9.62|9.62",
					"nil|1446|35|36.48|21.60|86.57|9.62",
					"nil|1446|35|58.56|21.60|48.10|9.62",
					"nil|1446|35|35.52|23.04|96.19|9.62",
					"nil|1446|35|57.60|23.04|76.95|9.62",
					"nil|1446|35|35.52|24.48|96.19|9.62",
					"nil|1446|35|57.60|24.48|96.19|9.62",
					"nil|1446|35|35.52|25.92|86.57|9.62",
					"nil|1446|35|56.64|25.92|115.43|9.62",
					"nil|1446|35|35.52|27.36|86.57|9.62",
					"nil|1446|35|56.64|27.36|115.43|9.62",
					"nil|1446|35|36.48|28.80|67.33|9.62",
					"nil|1446|35|55.68|28.80|134.67|9.62",
					"nil|1446|35|37.44|30.24|57.72|9.62",
					"nil|1446|35|55.68|30.24|134.67|9.62",
					"nil|1446|35|39.36|31.68|28.86|9.62",
					"nil|1446|35|55.68|31.68|144.29|9.62",
					"nil|1446|35|55.68|33.12|144.29|9.62",
					"nil|1446|35|55.68|34.56|153.91|9.62",
					"nil|1446|35|55.68|36.00|163.53|9.62",
					"nil|1446|35|56.64|37.44|163.53|9.62",
					"nil|1446|35|56.64|38.88|173.15|9.62",
					"nil|1446|35|57.60|40.32|182.76|9.62",
					"nil|1446|35|57.60|41.76|192.38|9.62",
					"nil|1446|35|58.56|43.20|192.38|19.24",
					"nil|1446|35|60.48|46.08|182.76|9.62",
					"nil|1446|35|39.36|47.52|19.24|9.62",
					"nil|1446|35|67.20|47.52|105.81|9.62",
					"nil|1446|35|38.40|48.96|48.10|9.62",
					"nil|1446|35|68.16|48.96|96.19|9.62",
					"nil|1446|35|37.44|50.40|67.33|9.62",
					"nil|1446|35|69.12|50.40|76.95|9.62",
					"nil|1446|35|37.44|51.84|67.33|9.62",
					"nil|1446|35|71.04|51.84|38.48|9.62",
					"nil|1446|35|36.48|53.28|86.57|9.62",
					"nil|1446|35|36.48|54.72|96.19|9.62",
					"nil|1446|35|35.52|56.16|115.43|9.62",
					"nil|1446|35|36.48|57.60|115.43|9.62",
					"nil|1446|35|36.48|59.04|125.05|9.62",
					"nil|1446|35|37.44|60.48|115.43|9.62",
					"nil|1446|35|37.44|61.92|125.05|19.24",
					"nil|1446|35|37.44|64.80|134.67|9.62",
					"nil|1446|35|37.44|66.24|134.67|19.24",
					"nil|1446|35|64.32|67.68|9.62|9.62",
					"nil|1446|35|37.44|69.12|125.05|9.62",
					"nil|1446|35|63.36|69.12|28.86|9.62",
					"nil|1446|35|37.44|70.56|105.81|9.62",
					"nil|1446|35|64.32|70.56|9.62|9.62",
					"nil|1446|35|37.44|72.00|96.19|9.62",
					"nil|1446|35|37.44|73.44|86.57|9.62",
					"nil|1446|35|38.40|74.88|67.33|9.62",
					"nil|1446|35|38.40|76.32|48.10|9.62",
					"nil|1446|35|40.32|77.76|9.62|9.62",
					"nil|1446|35|54.72|86.40|48.10|9.62",
					"nil|1446|35|52.80|87.84|76.95|9.62",
					"nil|1446|35|50.88|89.28|86.57|9.62",
					"nil|1446|35|49.92|90.72|96.19|9.62",
					"nil|1446|35|49.92|92.16|86.57|9.62",
					"nil|1446|35|49.92|93.60|86.57|9.62",
					"nil|1446|35|50.88|95.04|67.33|9.62",
					"nil|1446|35|51.84|96.48|48.10|9.62",
					"nil|1446|35|53.76|97.92|9.62|9.62",
				 },
			},
		},
		[9269] = {
			Quest = [[Atiesh, Greatstaff of the Guardian|0|0|0|0|0]],
		},
		[9270] = {
			Quest = [[Atiesh, Greatstaff of the Guardian|0|0|0|0|0]],
		},
		[9271] = {
			Quest = [[Atiesh, Greatstaff of the Guardian|0|0|0|0|0]],
		},
		[9272] = {
			Quest = [[Dressing the Part|0|0|30|0|0]],
			Start = "1|1434|32|30.60|90.20",
			End = "1|1434|32|30.60|90.20",
		},
		[9310] = {
			Quest = [[Faint Necrotic Crystal|0|0|1|0|0]],
		},
		[9330] = {
			Quest = [[Stealing Stormwind's Flame|2|0|1|0|0]],
		},
		[9331] = {
			Quest = [[Stealing Ironforge's Flame|2|0|1|0|0]],
		},
		[9332] = {
			Quest = [[Stealing Darnassus's Flame|2|0|1|0|0]],
		},
		[9333] = {
			Quest = [[Argent Dawn Gloves|0|0|50|0|0]],
		},
		[9339] = {
			Quest = [[A Thief's Reward|2|0|1|0|0]],
		},
		[9365] = {
			Quest = [[A Thief's Reward|1|0|1|0|0]],
		},
		[9386] = {
			Quest = [[A Light in Dark Places|0|0|50|0|0]],
		},
	}
	return ModQuests
end
	
function Nx.ModQuests:Load0()
	local ModQuests = Nx.ModQuests:Data0()
	local count = 0
	for key,val in pairs(ModQuests) do
		Nx.Quests[key] = val
		count = count + 1
	end
	ModQuests = {}
	return count
end

function Nx.ModQuests:Clear0()
	--ModQuests = {}
end