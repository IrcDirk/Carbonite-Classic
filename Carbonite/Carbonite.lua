---------------------------------------------------------------------------------------
-- Carbonite - Addon for World of Warcraft(tm)
-- Copyright 2007-2012 Carbon Based Creations, LLC
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
---------------------------------------------------------------------------------------
-- Commit: 2019-08-20 08:10:08 +0200 (436eed1)
---------------------------------------------------------------------------------------
local _G = getfenv(0)

Nx = LibStub("AceAddon-3.0"):NewAddon("Carbonite","AceConsole-3.0", "AceTimer-3.0", "AceEvent-3.0", "AceComm-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Carbonite")

Nx.WebSite = "wowinterface.com"
NXTITLEFULL = L["Carbonite"]

Nx.VERMAJOR			= 113
Nx.VERMINOR			= .0				-- Not 0 is a test version
Nx.BUILD			= "436eed1"
if Nx.BUILD:find("Format:%h", 1, true) then Nx.BUILD = string.sub("@project-revision@", 0, 7) end
if Nx.BUILD:find("project-revision", 1, true) then Nx.BUILD = "0" end

Nx.VERSION			= Nx.VERMAJOR + Nx.VERMINOR / 100

Nx.VERSIONDATA			= .02				-- Main data
Nx.VERSIONCHAR			= .02				-- Character data
Nx.VERSIONCharData		= .4				-- Character specific saved data
Nx.VERSIONGATHER		= .9				-- Gathered data
Nx.VERSIONGOPTS			= .102				-- Global options
Nx.VERSIONHUDOPTS		= .03				-- HUD options
Nx.VERSIONList			= .1				-- List header data
Nx.VERSIONTaxiCap		= .5				-- Taxi capture data
Nx.VERSIONTRAVEL		= .5				-- Travel data
Nx.VERSIONWin			= .31				-- Window layouts
Nx.VERSIONTOOLBAR		= .1				-- Tool Bar data
Nx.VERSIONCAP			= .75				-- Captured data (quest recording)
Nx.VERSIONVENDORV		= .56				-- Visited vendor data
Nx.VERSIONTransferData		= .1				-- Transfer data
Nx.TXTBLUE			= "|cffc0c0ff"

-- Keybindings
BINDING_HEADER_Carbonite	= "|cffc0c0ff" .. L["Carbonite"] .. "|r"
BINDING_NAME_NxMAPTOGORIGINAL	= L["NxMAPTOGORIGINAL"]
BINDING_NAME_NxMAPTOGNORMMAX	= L["NxMAPTOGNORMMAX"]
BINDING_NAME_NxMAPTOGNONEMAX	= L["NxMAPTOGNONEMAX"]
BINDING_NAME_NxMAPTOGNONENORM	= L["NxMAPTOGNONENORM"]
BINDING_NAME_NxMAPSCALERESTORE	= L["NxMAPSCALERESTORE"]
BINDING_NAME_NxMAPTOGMINIFULL	= L["NxMAPTOGMINIFULL"]
BINDING_NAME_NxMAPTOGHERB	= L["NxMAPTOGHERB"]
BINDING_NAME_NxMAPTOGMINE	= L["NxMAPTOGMINE"]
BINDING_NAME_NxTOGGLEGUIDE	= L["NxTOGGLEGUIDE"]
BINDING_NAME_NxMAPSKIPTARGET	= L["NxMAPSKIPTARGET"]
BINDING_NAME_NxMAPTOGTIMBER	= L["NxMAPTOGTIMBER"]

Nx.Tick = 0

Nx.Combat = {
	["KBs"] = 0,
	["Deaths"] = 0,
	["HKs"] = 0,
	["Honor"] = 0,
	["DamDone"] = 0,
	["HealDone"] = 0,
}

Nx.Font = {}
Nx.Skin = {}
Nx.Window = {}
Nx.Menu = {}
Nx.MenuI = {}
Nx.List = {}
Nx.DropDown = {}
Nx.Button = {}
Nx.EditBox = {}
Nx.Graph = {}
Nx.Slider = {}
Nx.TabBar = {}
Nx.ToolBar = {}

Nx.Proc = {}
Nx.Script = {}

Nx.Logo = "Interface\\AddOns\\Carbonite\\Gfx\\Carbonite"

Nx.Opts = {}

Nx.Com = {}
Nx.Com.List = {}

Nx.HUD = {}

Nx.Map = {}
Nx.Map.Dock = {}
Nx.Map.Guide = {}
Nx.Map.Guide.PlayerTargets = {}

Nx.Travel = {}

Nx.Title = {}
Nx.AuctionAssist = {}

Nx.UEvents = {}
Nx.UEvents.List = {}

Nx.DebugOn = false
Nx.NetSendPos = false
Nx.NetPlyrSendTime = GetTime()

Nx.GroupMembers = {}

Nx.Item = {}

Nx.NXMiniMapBut = {}

Nx.db = {}
Nx.dbs = {}

Nx.ModuleUpdateIcon = {"test"}
Nx.RequestTime = false
Nx.FirstTry = true
Nx.Loaded = false
Nx.Initialized = false
Nx.RealTom =  false
Nx.PlayerFnd = false
Nx.ModQAction = ""
Nx.ModPAction = ""
Nx.GlowOn = false

Nx.Whatsnew = {}
Nx.Whatsnew.Categories = {"Maps"}
Nx.Whatsnew.Maps = {
  [1568657164] = {"Sept 16th 2019","","This is Alpha version of Carbonite Classic, all bugs/issues please report to", "GitHub repo: https://github.com/IrcDirk/Carbonite-Classic."}
}
Nx.Whatsnew.WhichCat = 1
Nx.Whatsnew.HasWhatsNew = nil

function Nx.EmulateTomTom()
	if _G.TomTom and Nx.RealTom then
		return
	end
	local tom = {}
	_G.TomTom = tom
	tom["version"] = "v40200"
	tom["AddWaypoint"] = Nx.TTAddWaypoint
	tom["AddZWaypoint"] = Nx.TTAddZWaypoint
	tom["SetCustomWaypoint"] = Nx.TTSetCustomWaypoint
	tom["SetCustomMFWaypoint"] = Nx.TTSetCustomMFWaypoint
	tom["AddMFWaypoint"] = Nx.TTSetCustomMFWaypoint
	tom["RemoveWaypoint"] = Nx.TTRemoveWaypoint
	tom["SetCrazyArrow"] = Nx.TTSetCrazyArrow
	SLASH_WAY1 = '/way'
	SLASH_CBWAY1 = '/cbway'
	SlashCmdList["WAY"] = function (msg, editbox)
		Nx:TTWayCmd(msg)
	end
	SlashCmdList["CBWAY"] = function (msg, editbox)
		Nx:TTWayCmd(msg)
	end
end

local defaults = {
	char = {
		Map = {
			ShowGatherA = false,
			ShowGatherH = false,
			ShowGatherM = false,
			ShowGatherL = false,
			ShowQuestGivers = 1,
			ShowContPois = true,
			ShowMailboxes = true,
			ShowRaidBoss = true,
			ShowWorldQuest = true,
			ShowCustom = true,
			ShowCCity = false,
			ShowCExtra = true,
			ShowCTown = false,
			ShowArchBlobs = true,
			ShowQuestBlobs = true,
		},
	},
	global = {
	   Characters = {},
	},
	profile = {
		Battleground = {
			ShowStats = true
		},
		General = {
			CameraForceMaxDist = false,
			CaptureEnable = false,
			CaptureShare = true,
			ChatMsgFrm = "",
			GryphonsHide = true,
			LoginHideVer = true,
			TitleOff = true,
			TitleSoundOn = false,
		},
		Guide = {
			VendorVMax = 60,
			GatherEnabled = true,
			ShowMines = {
				[1] = true,
				[2] = true,
				[3] = true,
				[4] = true,
				[5] = true,
				[6] = true,
				[7] = true,
				[8] = true,
				[9] = true,
				[10] = true,
				[11] = true,
				[12] = true,
				[13] = true,
				[14] = true,
				[15] = true,
				[16] = true,
				[17] = true,
				[18] = true,
				[19] = true,
				[20] = true,
				[21] = true,
				[22] = true,
				[23] = true,
				[24] = true,
				[25] = true,
				[26] = true,
				[27] = true,
				[28] = true,
				[29] = true,
				[30] = true,
				[31] = true,
				[32] = true,
				[33] = true,
				[34] = true,
				[35] = true,
				[36] = true,
				[37] = true,
				[38] = true,
				[39] = true,
				[40] = true,
				[41] = true,
				[42] = true,
				[43] = true,
				[44] = true,
				[45] = true,
				[46] = true,
				[47] = true,
				[48] = true,
				[49] = true,
				[50] = true,
				[51] = true,
				[52] = true,
				[53] = true,
				[54] = true,
				[55] = true,
				[56] = true,
				[57] = true,
				[58] = true,
				[59] = true,
				[60] = true,
			},
			ShowHerbs = {
				[1] = true,
				[2] = true,
				[3] = true,
				[4] = true,
				[5] = true,
				[6] = true,
				[7] = true,
				[8] = true,
				[9] = true,
				[10] = true,
				[11] = true,
				[12] = true,
				[13] = true,
				[14] = true,
				[15] = true,
				[16] = true,
				[17] = true,
				[18] = true,
				[19] = true,
				[20] = true,
				[21] = true,
				[22] = true,
				[23] = true,
				[24] = true,
				[25] = true,
				[26] = true,
				[27] = true,
				[28] = true,
				[29] = true,
				[30] = true,
				[31] = true,
				[32] = true,
				[33] = true,
				[34] = true,
				[35] = true,
				[36] = true,
				[37] = true,
				[38] = true,
				[39] = true,
				[40] = true,
				[41] = true,
				[42] = true,
				[43] = true,
				[44] = true,
				[45] = true,
				[46] = true,
				[47] = true,
				[48] = true,
				[49] = true,
				[50] = true,
				[51] = true,
				[52] = true,
				[53] = true,
				[54] = true,
				[55] = true,
				[56] = true,
				[57] = true,
				[58] = true,
				[59] = true,
				[60] = true,
				[61] = true,
				[62] = true,
				[63] = true,
				[64] = true,
				[65] = true,
				[66] = true,
				[67] = true,
				[68] = true,
				[69] = true,
				[70] = true,
				[71] = true,
				[72] = true,
				[73] = true,
				[74] = true,
				[75] = true,
				[76] = true,	
				[77] = true,
				[78] = true,
				[79] = true,
				[80] = true,
				[81] = true,
				[82] = true,
				[83] = true,
				[84] = true,
			},
			ShowTimber = {
				[1] = true,
				[2] = true,
				[3] = true,
			},
		},
		Comm = {
			Global = true,
			Zone = true,
			LvlUpShow = true,
			SendToFriends = true,
			SendToGuild = true,
			SendToZone = true,
		},
		Debug = {
		  VerDebug = false,
		  VerT = 0,
		  DebugMap = false,
		  DebugDock = false,
		  DBGather = false,
		  DBMapMax = false,
		  DebugCom = false,
		  DebugUnit = false,
		},
		Font = {
			Small = "Friz",
			SmallSize = 10,
			SmallSpacing = 0,
			Medium = "Friz",
			MediumSize = 12,
			MediumSpacing = 0,
			Map = "Friz",
			MapSize = 10,
			MapSpacing = 0,
			MapLoc = "Friz",
			MapLocSize = 10,
			MapLocSpacing = 0,
			Menu = "Friz",
			MenuSize = 10,
			MenuSpacing = 0,
		},
		Skin = {
		  Name = "",
		  WinBdColor = ".8|.8|1|1",
		  WinFixedBgColor = ".5|.5|.5|.5",
		  WinSizedBgColor = ".121|.121|.121|.88",
		},
		Map = {
			ButLAlt = L["None"],
			ButLCtrl = L["Goto"],
			ButM = L["Show Player Zone"],
			ButMAlt = L["None"],
			ButMCtrl = L["None"],
			ButR = L["Menu"],
			ButRAlt = L["None"],
			ButRCtrl = L["None"],
			But4 = L["Show Selected Zone"],
			But4Alt = L["Add Note"],
			But4Ctrl = L["None"],
			Compatibility = false,			
			DetailSize = 6,
			IconPOIAlpha = 1,
			IconGatherA = 0.7,
			IconGatherAtScale = 0.5,
			LineThick = 1.0,
			LocTipAnchor = "TopRight",
			LocTipAnchorRel = "None",
			MaxCenter = true,
			MaxMouseIgnore = false,
			MaxOverride = true,
			MaxRestoreHide = false,
			MouseIgnore = false,
			PlyrArrowSize = 32,
			RestoreScaleAfterTrack = true,
			RouteUse = true,
			TopTooltip = false,
			IconScaleMin = 1,
			ShowOthersInCities = true,
			ShowOthersInZone = true,
			ShowPalsInCities = true,
			ShowPOI = true,
			ShowTitleName = true,
			ShowTitleXY = true,
			ShowTitleSpeed = true,
			ShowTitle2 = false,
			ShowToolBar = true,
			ShowTrail = true,
			TakeFunctions = false,
			TrailCnt = 100,
			TrailDist = 2,
			TrailTime = 90,
			WOwn = false,
			ZoneDrawCnt = 3,
			InstanceBossSize = 32,
			InstancePlayerSize = 24,
			InstanceGroupSize = 24,
			InstanceScale = 16,
		},
		MiniMap = {
			AboveIcons = false,
			ButColumns = 1,
			ButCorner = "TopRight",
			ButOwn = false,
			ButShowCarb = true,
			ButHide = false,
			ButLock = false,
			ButShowCalendar = true,
			ButShowClock = true,
			ButShowWorldMap = true,
			ButSpacing = 29,
			ButWinMinimize = false,
			DockHigh = "",
			DockAlways = false,
			DockBugged = true,
			DockIndoors = true,
			DockOnMax = false,
			DockSquare = true,
			DockBottom = false,
			DockRight = false,
			DockIScale = 1,
			DockZoom = 0,
			DXO = 0,
			DYO = 0,
			HideOnMax = false,
			InstanceTogFullSize = false,
			IndoorTogFullSize = false,
			BuggedTogFullSize = false,
			IScale = 1,
			MoveCapBars = true,
			NodeGD = 0,
			Own = false,
			ShowOldNameplate = true,
			Square = false,
		},
		Menu = {
			CenterH = false,
			CenterV = false,
		},
		Route = {
			GatherRadius = 60,
			MergeRadius = 20,
			Recycle = false,
		},
		Track = {
			EmuTomTom = true,
			Hide = false,
			HideInBG = false,
			ShowDir = false,
			Lock = false,
			AGfx = "Gloss",
			ASize = 44,
			AXO = 0,
			AYO = 0,
			TBut = true,
			TButColor = "0|0|0|.101",
			TButCombatColor = "1|0|0|.101",
			TSoundOn = true,
			ATBGPal = true,
			ATCorpse = true,
			ATTaxi = true,
		},
		Version = {
			OptionsVersion = 0,
		},
		WinSettings = {
		},
		Whatsnew = {
			lastreadtime = 0,
		},
   },
}

Nx.BrokerMenuTemplate = {
	{ text = "Carbonite", icon = icon, isTitle = true },
	{ text = L["Options"], func = function() Nx.Opts:Open() end },
	{ text = L["Toggle Map"], func = function() Nx.Map:ToggleSize(0) end },
	{ text = L["Toggle Events"], func = function() Nx.UEvents.List:Open() end },
}

local menuFrame = CreateFrame("Frame", "CarboniteMenuFrame", UIParent, "UIDropDownMenuTemplate")

Nx.Broker = LibStub("LibDataBroker-1.1"):NewDataObject("Broker_Carbonite", {
						type = "data source",
						icon = "Interface\\AddOns\\Carbonite\\Gfx\\MMBut",
						label = "Carbonite",
						text = "Carbonite",
						OnTooltipShow = function(tooltip)
											if not tooltip or not tooltip.AddLine then return end
											tooltip:AddLine("Carbonite")
											tooltip:AddLine(L["Left-Click to Toggle Map"])
											if Nx.db.profile.MiniMap.ButOwn then
												tooltip:AddLine(L["Shift Left-Click to Toggle Minimize"])
											end
											tooltip:AddLine(L["Middle-Click to Toggle Guide"])
											tooltip:AddLine(L["Right-Click for Menu"])
										end,
						OnClick = function(frame, msg)
									if msg == "LeftButton" then
										if (IsShiftKeyDown()) then
											Nx.db.profile.MiniMap.ButWinMinimize = not Nx.db.profile.MiniMap.ButWinMinimize
											Nx.Map.Dock:UpdateOptions()
										else
											Nx.Map:ToggleSize(0)
										end
									elseif msg == "MiddleButton" then
										Nx.Map:GetMap(1).Guide:ToggleShow()
									elseif msg == "RightButton" then
										EasyMenu(Nx.BrokerMenuTemplate, menuFrame, "cursor", 0, 0, "MENU")
									end
								end,
						})
function Nx:OnInitialize()
	local ver = GetBuildInfo()
	local v1, v2, v3 = Nx.Split (".", ver)
	v1 = tonumber (v1) or 0
	v2 = tonumber (v2) or 0
	v3 = tonumber (v3) or 0
	ver = v1 * 10000 + v2 * 100 + v3

	Nx.V30 = true

	if ver < 10000 or ver >= 40003 then		-- Patch 4
		Nx.V403 = true
	end

	if ver > 10000 and ver < 50000 then		-- Old?
		--local s = "|cffff2020" .. L["Carbonite requires v5.0 or higher"]
		--DEFAULT_CHAT_FRAME:AddMessage (s)
		--UIErrorsFrame:AddMessage (s)
		Nx.NXVerOld = true
	end
	Nx.TooltipLastDiffNumLines = 0
	Nx.db = LibStub("AceDB-3.0"):New("CarbData", defaults, true)
	tinsert(Nx.dbs,Nx.db)
	Nx.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	Nx.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	Nx.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	Nx.SetupConfig()
	Nx:RegisterComm("carbmodule",Nx.ModChatReceive)
end

function Nx:OnProfileChanged(event, database, newProfileKey)
	if not Nx.db.profile.MapSettings then
		Nx.db:RegisterDefaults(defaults)
		Nx.db.profile.MapSettings = NxMapOptsDefaults
		Nx.db.profile.MapSettings.Maps = NXMapOptsMapsDefault
	end
	Nx.db.profile.Version.OptionsVersion = Nx.VERSIONGOPTS
	Nx.Map:VerifySettings()
	Nx.Opts.NXCmdReload()
end

function Nx:OnEnable()
end

function Nx:OnDisable()
end
---------------------------------------------------------------------

--------
-- Slash command parsing

function Nx.slashCommand (txt)

	local UEvents = Nx.UEvents
	local cmd, a1, a2 = Nx.Split (" ", txt)
	cmd = strlower (cmd)

	a1 = a1 or ""
	a2 = a2 or ""

	if cmd == "" or cmd == "?" or cmd == "help" then

		Nx.prt ("Commands:")
		Nx.prt (" goto [zone] x y  (set map goto)")
		Nx.prt (" gotoadd [zone] x y  (add map goto)")
		Nx.prt (" menu  (open menu)")
		Nx.prt (" note [\"]name[\"] [zone] [x y]  (make map note)")
		Nx.prt (" options  (open options window)")
		Nx.prt (" resetwin  (reset window layouts)")
		Nx.prt (" rl  (reload UI)")
		Nx.prt (" track name  (track the player)")
		Nx.prt (" winpos name x y  (position a window)")
		Nx.prt (" winshow name [0/1]  (toggle or show a window)")
		Nx.prt (" winsize name w h  (size a window)")

	elseif cmd == "goto" then
		local map = Nx.Map:GetMap (1)
		local s = gsub (txt, "goto%s*", "")
		map:SetTargetAtStr (s)

	elseif cmd == "gotoadd" then
		local map = Nx.Map:GetMap (1)
		local s = gsub (txt, "gotoadd %s*", "")
		map:SetTargetAtStr (s, true)

	elseif cmd == "menu" then
		Nx.NXMiniMapBut:OpenMenu()

	elseif cmd == "options" then
		Nx.Opts:Open()

	elseif cmd == "resetwin" then
		Nx.Window:ResetLayouts()

	elseif cmd == "rl" then
		ReloadUI()

	elseif cmd == "track" then
		if a1 then
			local map = Nx.Map:GetMap (1)
			map.TrackPlyrs[a1] = true
		end

	elseif cmd == "winpos" then
		Nx.Window:ConsolePos (gsub (txt, "winpos %s*", ""))

	elseif cmd == "winshow" then
		Nx.Window:ConsoleShow (gsub (txt, "winshow %s*", ""))

	elseif cmd == "winsize" then
		Nx.Window:ConsoleSize (gsub (txt, "winsize %s*", ""))

	elseif cmd == "gatherd" then
		Nx.db.profile.Debug.DBGather = not Nx.db.profile.Debug.DBGather

	elseif cmd == "herb" then
		UEvents:AddHerb (strtrim (a1 .. " " .. a2))

	elseif cmd == "dbmapmax" then
		Nx.db.profile.Debug.DBMapMax = not Nx.db.profile.Debug.DBMapMax

	elseif cmd == "mine" then
		UEvents:AddMine (strtrim (a1 .. " " .. a2))

	elseif cmd == "addopen" then
		UEvents:AddOpen (a1, a2)

	elseif cmd == "cap" then
		Nx.CaptureItems()

	elseif cmd == "crash" then
		assert()

	elseif cmd == "com" then
		Nx.Com.List:Open()

	elseif cmd == "comd" then
		Nx.db.profile.Debug.DebugCom = not Nx.db.profile.Debug.DebugCom
		ReloadUI()

	elseif cmd == "comt" then
		Nx.Com:Test (a1, a2)

	elseif cmd == "comver" then
		if Nx.db.profile.Debug.VerDebug then		-- Stop casual use
			Nx.Com:GetUserVer()
		end

	elseif cmd == "d" then
		Nx.DebugOn = not Nx.DebugOn
		Nx.prt("Carbonite Debug: %s", Nx.DebugOn and "On" or "Off")

	elseif cmd == "dock" then
		Nx.db.profile.Debug.DebugDock = not Nx.db.profile.Debug.DebugDock

	elseif cmd == "events" then
		UEvents.List:Open()

	elseif cmd == "item" then
		local id = format ("Hitem:%s", a1)
		GameTooltip:SetOwner (UIParent, "ANCHOR_LEFT", 0, 0)
		GameTooltip:SetHyperlink (id)
		local name, iLink, iRarity, lvl, minLvl, type, subType, stackCount, equipLoc, tx = GetItemInfo (id)
		Nx.prt ("Item: %s %s", name or "nil", iLink or "")

	elseif cmd == "kill" then
		UEvents:AddKill (a1)

	elseif cmd == "loot" then
		Nx.LootOn = not Nx.LootOn
		Nx.prt ("Loot %s", Nx.LootOn and "On" or "Off")

	elseif cmd == "mapd" then
		Nx.db.profile.Debug.DebugMap = not Nx.db.profile.Debug.DebugMap
		ReloadUI()

	elseif cmd == "questclr" then
		Nx.Quest:ClearCaptured()

	elseif cmd == "unitc" then
		Nx.db.profile.Debug.DebugUnit = true
		Nx:UnitDCapture()

	elseif cmd == "unitd" then
		Nx.db.profile.Debug.DebugUnit = not Nx.db.profile.Debug.DebugUnit

	elseif cmd == "vehpos" then
		Nx.Map:GetMap (1):VehicleDumpPos()

	else
		local s = gsub (txt, "note%s*", "")
		Nx:SendCommMessage("carbmodule","CMD|" .. cmd .. "|" .. s,"WHISPER",UnitName("player"))
	end
end

--------------------------------------------------------------------------------
-- Startup

function Nx:NXOnLoad (frm)

	SlashCmdList["Carbonite"] = Nx.slashCommand
	SLASH_Carbonite1 = "/Carb"

	self.Frm = frm		--V4 this
	self.TimeLast = 0
	self.ClassColorStrs = Nx.Util_coltrgb2colstr (RAID_CLASS_COLORS)

	Nx:RegisterEvent ("ADDON_LOADED")
	Nx:RegisterEvent ("UNIT_NAME_UPDATE")
	Nx:RegisterEvent ("PLAYER_ENTERING_WORLD", "UNIT_NAME_UPDATE")
	Nx.CalendarDate = 0		-- For safety if Map update happens early
end

--------
--
function Nx:SetupEverything()

	if not Nx.FirstTry then
		return
	end
	Nx.FirstTry = false
	local fact = UnitFactionGroup ("player")
	Nx.PlFactionNum = strsub (fact, 1, 1) == "A" and 0 or 1

	Nx.AirshipType = Nx.PlFactionNum == 0 and "Airship Alliance" or "Airship Horde"

	Nx:InitGlobal()

	Nx:prtSetChatFrame()

	if Nx.db.profile.General.LoginHideVer then
		Nx.prt (L["Carbonite"].." |cffffffff"..Nx.VERMAJOR.."."..(Nx.VERMINOR*10).." Build "..Nx.BUILD.." ".. L["Loading"])
	end

	Nx:LocaleInit()

	Nx:InitEvents()

	Nx.Opts:Init()

	Nx:UIInit()
	Nx.Item:Init()
	Nx.Proc:Init()
	Nx.Title:Init()
	Nx.NXMiniMapBut:Init()

	Nx.Com:Init()
	Nx.HUD:Init()
	Nx.Map:Init()

	Nx:GatherInit()		-- Needs map init. May need to do before map open

	Nx.Map:Open()
	Nx.Travel:Init()

	Nx.UEvents:Init()
	Nx.UEvents.List:Open()

	if Nx.db.profile.General.LoginHideVer then
		Nx.prt (L["Loading Done"])
	end
	if Nx.Font.AddonLoaded then
		Nx.Font:AddonLoaded()
	end
	
	ShowUIPanel(WorldMapFrame)
	HideUIPanel(WorldMapFrame)
	
	if Nx.db.profile.Map.MaxOverride then Nx.Map:ToggleSize() end
	
	Nx.Initialized = true
	Nx:OnPlayer_login("PLAYER_LOGIN")
end

function Nx:ADDON_LOADED (event, arg1, ...)
	Nx.Loaded = true
	
	local nodes = {}

	nodes[1446] = {
		[52002960] = {
			name = L["Auctioneer Beardo"],
			category = "auctioneers",
			faction = "Neutral",
		},
		[52202880] = {
			name = L["Gimblethorn"],
			category = "bankers",
			description = L["Banker"],
			faction = "Neutral",
		},
		[52402880] = {
			name = L["Qizzik"],
			category = "bankers",
			description = L["Banker"],
			faction = "Neutral",
		},
		[51002920] = {
			name = L["Bera Stonehammer"],
			category = "flightmasters",
			fpName = L["Gadgetzan, Tanaris"],
			description = L["Gryphon Master"],
			faction = "Alliance",
		},
		[51602540] = {
			name = L["Bulkrek Ragefist"],
			category = "flightmasters",
			fpName = L["Gadgetzan, Tanaris"],
			description = L["Wind Rider Master"],
			faction = "Horde",
		},
		[52402780] = {
			name = L["Innkeeper Fizzgrimble"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Neutral",
		},
		[52302780] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Neutral",
		},
		[51402880] = {
			name = L["Krinkle Goodsteel"],
			category = "repair",
			description = L["Blacksmithing Supplies"],
			faction = "Neutral",
		},
		[50802760] = {
			name = L["Wrinkle Goodsteel"],
			category = "repair",
			description = L["Superior Armor Crafter"],
			faction = "Neutral",
		},
		[50802765] = {
			name = L["Blizrik Buckshot"],
			category = "vendors",
			description = L["Gunsmith"],
			faction = "Neutral",
		},
		[54002880] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[52202800] = {
			name = L["Laziphus"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Neutral",
		},
		[52402720] = {
			name = L["Nixx Sprocketspring"],
			category = "trainers",
			description = L["Master Goblin Engineer"],
			faction = "Neutral",
		},
		[51002800] = {
			name = L["Pikkle"],
			category = "primaryProfession",
			profession = "Mining",
			description = L["Miner"],
			faction = "Neutral",
		},
		[52202760] = {
			name = L["Buzzek Bracketswing"],
			category = "primaryProfession",
			profession = "Engineering",
			description = L["Master Engineer"],
			faction = "Neutral",
		},
		[50802700] = {
			name = L["Alchemist Pestlezugg"],
			category = "vendors",
			description = L["Alchemy Supplies"],
			faction = "Neutral",
		},
		[51002740] = {
			name = L["Vizzklick"],
			category = "vendors",
			description = L["Tailoring Supplies"],
			faction = "Neutral",
		},
		[51802860] = {
			name = L["Marin Noggenfogger"],
			category = "vendors",
			faction = "Neutral",
		},
		[52602800] = {
			name = L["Dirge Quikcleave"],
			category = "vendors",
			description = L["Butcher"],
			faction = "Neutral",
		},
		[66602200] = {
			name = L["Gikkix"],
			category = "secondaryProfession",
			profession = "Fishing",
			description = L["Fisherman"],
			faction = "Neutral",
		},
		[67002200] = {
			name = L["Jabbey"],
			category = "vendors",
			description = L["General Goods"],
			faction = "Neutral",
		},
		[39007360] = {
			name = L["Omgorn the Lost"],
			category = "rares",
			faction = "Neutral",
		},
		[41207300] = {
			name = L["Omgorn the Lost"],
			category = "rares",
			faction = "Neutral",
		},
		[48406520] = {
			name = L["Omgorn the Lost"],
			category = "rares",
			faction = "Neutral",
		},
		[40607240] = {
			name = L["Cyclok the Mad"],
			category = "rares",
			faction = "Neutral",
		},
		[72404680] = {
			name = L["Kregg Keelhaul"],
			category = "rares",
			faction = "Neutral",
		},
		[74804740] = {
			name = L["Kregg Keelhaul"],
			category = "rares",
			faction = "Neutral",
		},
		[75604540] = {
			name = L["Kregg Keelhaul"],
			category = "rares",
			faction = "Neutral",
		},
		[34804320] = {
			name = L["Soriid the Devourer"],
			category = "rares",
			faction = "Neutral",
		},
		[56607200] = {
			name = L["Haarka the Ravenous"],
			category = "rares",
			faction = "Neutral",
		},
		[57006880] = {
			name = L["Haarka the Ravenous"],
			category = "rares",
			faction = "Neutral",
		},
		[42003440] = {
			name = L["Greater Firebird"],
			category = "rares",
			faction = "Neutral",
		},
		[46403300] = {
			name = L["Greater Firebird"],
			category = "rares",
			faction = "Neutral",
		},
		[47003780] = {
			name = L["Greater Firebird"],
			category = "rares",
			faction = "Neutral",
		},
		[47203900] = {
			name = L["Greater Firebird"],
			category = "rares",
			faction = "Neutral",
		},
		[49403480] = {
			name = L["Greater Firebird"],
			category = "rares",
			faction = "Neutral",
		},
		[50403940] = {
			name = L["Greater Firebird"],
			category = "rares",
			faction = "Neutral",
		},
		[54403260] = {
			name = L["Murderous Blisterpaw"],
			category = "rares",
			faction = "Neutral",
		},
		[42202260] = {
			name = L["Jin'Zallah the Sandbringer"],
			category = "rares",
			faction = "Neutral",
		},
		[38805060] = {
			name = L["Omgorn the Lost"],
			category = "rares",
			faction = "Neutral",
		},
		[39205860] = {
			name = L["Omgorn the Lost"],
			category = "rares",
			faction = "Neutral",
		},
		[39405000] = {
			name = L["Omgorn the Lost"],
			category = "rares",
			faction = "Neutral",
		},
		[44806620] = {
			name = L["Omgorn the Lost"],
			category = "rares",
			faction = "Neutral",
		},
		[48406560] = {
			name = L["Omgorn the Lost"],
			category = "rares",
			faction = "Neutral",
		},
		[74404740] = {
			name = L["Kregg Keelhaul"],
			category = "rares",
			faction = "Neutral",
		},
		[74804760] = {
			name = L["Kregg Keelhaul"],
			category = "rares",
			faction = "Neutral",
		},
		[33204320] = {
			name = L["Soriid the Devourer"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1452] = {
		[61403720] = {
			name = L["Auctioneer Grizzlin"],
			category = "auctioneers",
			faction = "Neutral",
		},
		[61403700] = {
			name = L["Izzy Coppergrab"],
			category = "bankers",
			description = L["Banker"],
			faction = "Neutral",
		},
		[62203660] = {
			name = L["Maethrya"],
			category = "flightmasters",
			fpName = L["Everlook, Winterspring"],
			description = L["Hippogryph Master"],
			faction = "Alliance",
		},
		[60403640] = {
			name = L["Yugrek"],
			category = "flightmasters",
			fpName = L["Everlook, Winterspring"],
			description = L["Wind Rider Master"],
			faction = "Horde",
		},
		[61203880] = {
			name = L["Innkeeper Vizzie"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Neutral",
		},
		[61303860] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Neutral",
		},
		[61603800] = {
			name = L["Nixxrak"],
			category = "repair",
			description = L["Heavy Armor Merchant"],
			faction = "Neutral",
		},
		[61603780] = {
			name = L["Blixxrak"],
			category = "repair",
			description = L["Light Armor Merchant"],
			faction = "Neutral",
		},
		[61603805] = {
			name = L["Wixxrak"],
			category = "vendors",
			description = L["Weaponsmith & Gunsmith"],
			faction = "Neutral",
		},
		[61203480] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[60403780] = {
			name = L["Azzleby"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Neutral",
		},
		[51403080] = {
			name = L["Natheril Raincaller"],
			category = "vendors",
			description = L["General Goods"],
			faction = "Alliance",
		},
		[52002920] = {
			name = L["Lyranne Feathersong"],
			category = "vendors",
			description = L["Food & Drink"],
			faction = "Alliance",
		},
		[51602980] = {
			name = L["Syurana"],
			category = "vendors",
			description = L["Trade Goods Supplies"],
			faction = "Alliance",
		},
		[60803860] = {
			name = L["Xizzer Fizzbolt"],
			category = "vendors",
			description = L["Engineering Supplies"],
			faction = "Neutral",
		},
		[61803860] = {
			name = L["Lunnix Sprocketslip"],
			category = "vendors",
			description = L["Mining Supplies"],
			faction = "Neutral",
		},
		[61203900] = {
			name = L["Himmik"],
			category = "vendors",
			description = L["Food & Drink"],
			faction = "Neutral",
		},
		[60803780] = {
			name = L["Evie Whirlbrew"],
			category = "vendors",
			description = L["Alchemy Supplies"],
			faction = "Neutral",
		},
		[61203720] = {
			name = L["Qia"],
			category = "vendors",
			description = L["Trade Goods Supplies"],
			faction = "Neutral",
		},
		[30203780] = {
			name = L["Mezzir the Howler"],
			category = "rares",
			faction = "Neutral",
		},
		[30604660] = {
			name = L["Mezzir the Howler"],
			category = "rares",
			faction = "Neutral",
		},
		[30803740] = {
			name = L["Mezzir the Howler"],
			category = "rares",
			faction = "Neutral",
		},
		[31003800] = {
			name = L["Mezzir the Howler"],
			category = "rares",
			faction = "Neutral",
		},
		[31603740] = {
			name = L["Mezzir the Howler"],
			category = "rares",
			faction = "Neutral",
		},
		[44003720] = {
			name = L["Mezzir the Howler"],
			category = "rares",
			faction = "Neutral",
		},
		[44603720] = {
			name = L["Mezzir the Howler"],
			category = "rares",
			faction = "Neutral",
		},
		[63606980] = {
			name = L["Kashoch the Reaver"],
			category = "rares",
			faction = "Neutral",
		},
		[67003740] = {
			name = L["Grizzle Snowpaw"],
			category = "rares",
			faction = "Neutral",
		},
		[67403760] = {
			name = L["Grizzle Snowpaw"],
			category = "rares",
			faction = "Neutral",
		},
		[67803720] = {
			name = L["Grizzle Snowpaw"],
			category = "rares",
			faction = "Neutral",
		},
		[68003780] = {
			name = L["Grizzle Snowpaw"],
			category = "rares",
			faction = "Neutral",
		},
		[68603800] = {
			name = L["Grizzle Snowpaw"],
			category = "rares",
			faction = "Neutral",
		},
		[49801160] = {
			name = L["Rak'shiri"],
			category = "rares",
			faction = "Neutral",
		},
		[54601260] = {
			name = L["Rak'shiri"],
			category = "rares",
			faction = "Neutral",
		},
		[60403820] = {
			name = L["Azurous"],
			category = "rares",
			faction = "Neutral",
		},
		[30203880] = {
			name = L["Mezzir the Howler"],
			category = "rares",
			faction = "Neutral",
		},
		[30604580] = {
			name = L["Mezzir the Howler"],
			category = "rares",
			faction = "Neutral",
		},
		[40203660] = {
			name = L["Mezzir the Howler"],
			category = "rares",
			faction = "Neutral",
		},
		[66603560] = {
			name = L["Grizzle Snowpaw"],
			category = "rares",
			faction = "Neutral",
		},
		[57803660] = {
			name = L["Azurous"],
			category = "rares",
			faction = "Neutral",
		},
		[57804300] = {
			name = L["Azurous"],
			category = "rares",
			faction = "Neutral",
		},
		[63404240] = {
			name = L["Azurous"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1434] = {
		[27807700] = {
			name = L["Auctioneer Kresky"],
			category = "auctioneers",
			faction = "Neutral",
		},
		[28407580] = {
			name = L["Auctioneer Graves"],
			category = "auctioneers",
			faction = "Neutral",
		},
		[26607640] = {
			name = L["Auctioneer O'reely"],
			category = "auctioneers",
			faction = "Neutral",
		},
		[26607645] = {
			name = L["Rickle Goldgrubber"],
			category = "bankers",
			description = L["Banker"],
			faction = "Neutral",
		},
		[32402920] = {
			name = L["Thysta"],
			category = "flightmasters",
			fpName = L["Grom'gol, Stranglethorn"],
			description = L["Wind Rider Master"],
			faction = "Horde",
		},
		[26807700] = {
			name = L["Gringer"],
			category = "flightmasters",
			fpName = L["Booty Bay, Stranglethorn"],
			description = L["Wind Rider Master"],
			faction = "Horde",
		},
		[27407760] = {
			name = L["Gyll"],
			category = "flightmasters",
			fpName = L["Booty Bay, Stranglethorn"],
			description = L["Gryphon Master"],
			faction = "Alliance",
		},
		[31402960] = {
			name = L["Innkeeper Thulbek"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Horde",
		},
		[27007720] = {
			name = L["Innkeeper Skindle"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Neutral",
		},
		[26707640] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Neutral",
		},
		[32402870] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Horde",
		},
		[32202800] = {
			name = L["Vharr"],
			category = "repair",
			description = L["Superior Weaponsmith"],
			faction = "Horde",
		},
		[31602900] = {
			name = L["Hragran"],
			category = "repair",
			description = L["Cloth & Leather Armor Merchant"],
			faction = "Horde",
		},
		[32402800] = {
			name = L["Krakk"],
			category = "repair",
			description = L["Superior Armorer"],
			faction = "Horde",
		},
		[28407540] = {
			name = L["Zarena Cromwind"],
			category = "repair",
			description = L["Superior Weaponsmith"],
			faction = "Neutral",
		},
		[35601060] = {
			name = L["Jaquilina Dramet"],
			category = "repair",
			description = L["Superior Axecrafter"],
			faction = "Neutral",
		},
		[28207460] = {
			name = L["Haren Kanmae"],
			category = "repair",
			description = L["Superior Bowyer"],
			faction = "Neutral",
		},
		[28207520] = {
			name = L["Kizz Bluntstrike"],
			category = "repair",
			description = L["Macecrafter"],
			faction = "Neutral",
		},
		[27407740] = {
			name = L["Jutak"],
			category = "repair",
			description = L["Blade Trader"],
			faction = "Neutral",
		},
		[29007500] = {
			name = L["Hurklor"],
			category = "repair",
			description = L["Blacksmithing Supplies"],
			faction = "Neutral",
		},
		[29007505] = {
			name = L["Fargon Mortalak"],
			category = "vendors",
			description = L["Superior Armorer"],
			faction = "Neutral",
		},
		[29007540] = {
			name = L["Jansen Underwood"],
			category = "repair",
			description = L["Blacksmithing Supplies"],
			faction = "Neutral",
		},
		[28207740] = {
			name = L["Qixdi Goodstitch"],
			category = "repair",
			description = L["Cloth Armor and Accessories"],
			faction = "Neutral",
		},
		[30007300] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[38400880] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[27207720] = {
			name = L["Grimestack"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Neutral",
		},
		[31802940] = {
			name = L["Durik"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Horde",
		},
		[27607760] = {
			name = L["Flora Silverwind"],
			category = "primaryProfession",
			profession = "Herbalism",
			description = L["Superior Herbalist"],
			faction = "Neutral",
		},
		[31402800] = {
			name = L["Mudduk"],
			category = "secondaryProfession",
			profession = "Cooking",
			description = L["Superior Cook"],
			faction = "Horde",
		},
		[31602880] = {
			name = L["Brawn"],
			category = "primaryProfession",
			profession = "Leatherworking",
			description = L["Expert Leatherworker"],
			faction = "Horde",
		},
		[31202860] = {
			name = L["Kragg"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Hunter Trainer"],
			classes = {
				HUNTER = true,
			},
			faction = "Horde",
		},
		[26807720] = {
			name = L["Ian Strom"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Rogue Trainer"],
			classes = {
				ROGUE = true,
			},
			faction = "Neutral",
		},
		[28607680] = {
			name = L["Grarnik Goodstitch"],
			category = "primaryProfession",
			profession = "Tailoring",
			description = L["Expert Tailor"],
			faction = "Neutral",
		},
		[27407700] = {
			name = L["Myizz Luckycatch"],
			category = "secondaryProfession",
			profession = "Fishing",
			description = L["Superior Fisherman"],
			faction = "Neutral",
		},
		[29007545] = {
			name = L["Brikk Keencraft"],
			category = "primaryProfession",
			profession = "Blacksmith",
			description = L["Master Blacksmith"],
			faction = "Alliance",
		},
		[28007800] = {
			name = L["Jaxin Chong"],
			category = "primaryProfession",
			profession = "Alchemy",
			description = L["Expert Alchemist"],
			faction = "Neutral",
		},
		[32202740] = {
			name = L["Angrun"],
			category = "primaryProfession",
			profession = "Herbalism",
			description = L["Superior Herbalist"],
			faction = "Horde",
		},
		[31202880] = {
			name = L["Zudd"],
			category = "trainers",
			description = L["Pet Trainer"],
			faction = "Horde",
		},
		[28207620] = {
			name = L["Oglethorpe Obnoticus"],
			category = "primaryProfession",
			profession = "Engineering",
			description = L["Master Gnome Engineer"],
			faction = "Neutral",
		},
		[36603420] = {
			name = L["Se'Jib"],
			category = "primaryProfession",
			profession = "Leatherworking",
			description = L["Master Tribal Leatherworker"],
			faction = "Horde",
		},
		[38000300] = {
			name = L["Corporal Bluth"],
			category = "vendors",
			description = L["Camp Trader"],
			faction = "Alliance",
		},
		[32602920] = {
			name = L["Nerrist"],
			category = "vendors",
			description = L["Trade Goods"],
			faction = "Horde",
		},
		[31602800] = {
			name = L["Uthok"],
			category = "vendors",
			description = L["General Supplies"],
			faction = "Horde",
		},
		[28407680] = {
			name = L["Sly Garrett"],
			category = "vendors",
			description = L["Shady Goods"],
			faction = "Neutral",
		},
		[27407705] = {
			name = L["Old Man Heming"],
			category = "secondaryProfession",
			profession = "Fishing",
			description = L["Fisherman"],
			faction = "Neutral",
		},
		[28207440] = {
			name = L["Narkk"],
			category = "vendors",
			description = L["Pirate Supplies"],
			faction = "Neutral",
		},
		[28207445] = {
			name = L["Kelsey Yance"],
			category = "secondaryProfession",
			profession = "Cooking",
			description = L["Cook"],
			faction = "Neutral",
		},
		[28607685] = {
			name = L["Xizk Goodstitch"],
			category = "vendors",
			description = L["Tailoring Supplies"],
			faction = "Neutral",
		},
		[27008240] = {
			name = L["Cowardly Crosby"],
			category = "vendors",
			description = L["Tailoring Supplies"],
			faction = "Neutral",
		},
		[28407500] = {
			name = L["Mazk Snipeshot"],
			category = "vendors",
			description = L["Engineering Supplies"],
			faction = "Neutral",
		},
		[51003520] = {
			name = L["Gnaz Blunderflame"],
			category = "vendors",
			description = L["Engineering Supplies"],
			faction = "Neutral",
		},
		[28407600] = {
			name = L["Rikqiz"],
			category = "vendors",
			description = L["Leatherworking Supplies"],
			faction = "Neutral",
		},
		[27007725] = {
			name = L["Nixxrax Fillamug"],
			category = "vendors",
			description = L["Food and Drink"],
			faction = "Neutral",
		},
		[28207660] = {
			name = L["Crazk Sparks"],
			category = "vendors",
			description = L["Fireworks Merchant"],
			faction = "Neutral",
		},
		[28007680] = {
			name = L["Wigcik"],
			category = "secondaryProfession",
			profession = "Fishing",
			description = L["Superior Fisherman"],
			faction = "Neutral",
		},
		[28207745] = {
			name = L["Blixrez Goodstitch"],
			category = "vendors",
			description = L["Leatherworking Supplies"],
			faction = "Neutral",
		},
		[28007805] = {
			name = L["Glyx Brewright"],
			category = "vendors",
			description = L["Alchemy Supplies"],
			faction = "Neutral",
		},
		[32202920] = {
			name = L["Nargatt"],
			category = "vendors",
			description = L["Food & Drink"],
			faction = "Horde",
		},
		[51003525] = {
			name = L["Knaz Blunderflame"],
			category = "vendors",
			description = L["Engineering Supplies"],
			faction = "Neutral",
		},
		[49003180] = {
			name = L["Mosh'Ogg Butcher"],
			category = "rares",
			faction = "Neutral",
		},
		[49203120] = {
			name = L["Mosh'Ogg Butcher"],
			category = "rares",
			faction = "Neutral",
		},
		[49603120] = {
			name = L["Mosh'Ogg Butcher"],
			category = "rares",
			faction = "Neutral",
		},
		[43004580] = {
			name = L["Scale Belly"],
			category = "rares",
			faction = "Neutral",
		},
		[43004820] = {
			name = L["Scale Belly"],
			category = "rares",
			faction = "Neutral",
		},
		[43204920] = {
			name = L["Scale Belly"],
			category = "rares",
			faction = "Neutral",
		},
		[43404700] = {
			name = L["Scale Belly"],
			category = "rares",
			faction = "Neutral",
		},
		[43604660] = {
			name = L["Scale Belly"],
			category = "rares",
			faction = "Neutral",
		},
		[44004820] = {
			name = L["Scale Belly"],
			category = "rares",
			faction = "Neutral",
		},
		[28206320] = {
			name = L["Lord Sakrasis"],
			category = "rares",
			faction = "Neutral",
		},
		[28406240] = {
			name = L["Lord Sakrasis"],
			category = "rares",
			faction = "Neutral",
		},
		[28606060] = {
			name = L["Lord Sakrasis"],
			category = "rares",
			faction = "Neutral",
		},
		[28606220] = {
			name = L["Lord Sakrasis"],
			category = "rares",
			faction = "Neutral",
		},
		[33402240] = {
			name = L["Gluggle"],
			category = "rares",
			faction = "Neutral",
		},
		[34002180] = {
			name = L["Gluggle"],
			category = "rares",
			faction = "Neutral",
		},
		[34402280] = {
			name = L["Gluggle"],
			category = "rares",
			faction = "Neutral",
		},
		[34602140] = {
			name = L["Gluggle"],
			category = "rares",
			faction = "Neutral",
		},
		[34602280] = {
			name = L["Gluggle"],
			category = "rares",
			faction = "Neutral",
		},
		[34602380] = {
			name = L["Gluggle"],
			category = "rares",
			faction = "Neutral",
		},
		[36802700] = {
			name = L["Roloch"],
			category = "rares",
			faction = "Neutral",
		},
		[37402560] = {
			name = L["Roloch"],
			category = "rares",
			faction = "Neutral",
		},
		[37602600] = {
			name = L["Roloch"],
			category = "rares",
			faction = "Neutral",
		},
		[30408600] = {
			name = L["Rippa"],
			category = "rares",
			faction = "Neutral",
		},
		[32808400] = {
			name = L["Rippa"],
			category = "rares",
			faction = "Neutral",
		},
		[33208460] = {
			name = L["Rippa"],
			category = "rares",
			faction = "Neutral",
		},
		[33006580] = {
			name = L["Kurmokk"],
			category = "rares",
			faction = "Neutral",
		},
		[36605440] = {
			name = L["Verifonix"],
			category = "rares",
			description = L["The Surveyor"],
			faction = "Neutral",
		},
		[36605460] = {
			name = L["Verifonix"],
			category = "rares",
			description = L["The Surveyor"],
			faction = "Neutral",
		},
		[36605660] = {
			name = L["Verifonix"],
			category = "rares",
			description = L["The Surveyor"],
			faction = "Neutral",
		},
		[36805600] = {
			name = L["Verifonix"],
			category = "rares",
			description = L["The Surveyor"],
			faction = "Neutral",
		},
		[50003060] = {
			name = L["Mosh'Ogg Butcher"],
			category = "rares",
			faction = "Neutral",
		},
		[43404580] = {
			name = L["Scale Belly"],
			category = "rares",
			faction = "Neutral",
		},
		[43604860] = {
			name = L["Scale Belly"],
			category = "rares",
			faction = "Neutral",
		},
		[33002100] = {
			name = L["Gluggle"],
			category = "rares",
			faction = "Neutral",
		},
		[34602160] = {
			name = L["Gluggle"],
			category = "rares",
			faction = "Neutral",
		},
		[28208440] = {
			name = L["Rippa"],
			category = "rares",
			faction = "Neutral",
		},
		[28608580] = {
			name = L["Rippa"],
			category = "rares",
			faction = "Neutral",
		},
		[33808360] = {
			name = L["Rippa"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1453] = {
		[53206060] = {
			name = L["Auctioneer Chilton"],
			category = "auctioneers",
			faction = "Alliance",
		},
		[53406040] = {
			name = L["Auctioneer Fitch"],
			category = "auctioneers",
			faction = "Alliance",
		},
		[53405960] = {
			name = L["Auctioneer Jaxon"],
			category = "auctioneers",
			faction = "Alliance",
		},
		[57407240] = {
			name = L["Olivia Burnside"],
			category = "bankers",
			description = L["Banker"],
			faction = "Alliance",
		},
		[57007280] = {
			name = L["Newton Burnside"],
			category = "bankers",
			description = L["Banker"],
			faction = "Alliance",
		},
		[56407320] = {
			name = L["John Burnside"],
			category = "bankers",
			description = L["Banker"],
			faction = "Alliance",
		},
		[66206240] = {
			name = L["Dungar Longdrink"],
			category = "flightmasters",
			fpName = L["Stormwind, Elwynn"],
			description = L["Gryphon Master"],
			faction = "Alliance",
		},
		[57206800] = {
			name = L["Aldwin Laughlin"],
			category = "guildmasters",
			description = L["Guild Master"],
			faction = "Alliance",
		},
		[52806540] = {
			name = L["Innkeeper Allison"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Alliance",
		},
		[40008410] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Alliance",
		},
		[54406640] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Alliance",
		},
		[70704030] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Alliance",
		},
		[57205700] = {
			name = L["Marda Weller"],
			category = "repair",
			description = L["Weapons Merchant"],
			faction = "Alliance",
		},
		[57205720] = {
			name = L["Gunther Weller"],
			category = "repair",
			description = L["Weapons Merchant"],
			faction = "Alliance",
		},
		[55005580] = {
			name = L["Carla Granger"],
			category = "repair",
			description = L["Cloth Armor Merchant"],
			faction = "Alliance",
		},
		[54805520] = {
			name = L["Aldric Moore"],
			category = "repair",
			description = L["Mail Armor Merchant"],
			faction = "Alliance",
		},
		[54805540] = {
			name = L["Lara Moore"],
			category = "repair",
			description = L["Leather Armor Merchant"],
			faction = "Alliance",
		},
		[50405740] = {
			name = L["Lina Stover"],
			category = "repair",
			description = L["Bow & Gun Merchant"],
			faction = "Alliance",
		},
		[50205760] = {
			name = L["Frederick Stover"],
			category = "repair",
			description = L["Bow & Arrow Merchant"],
			faction = "Alliance",
		},
		[49605500] = {
			name = L["Lisbeth Schneider"],
			category = "repair",
			description = L["Clothier"],
			faction = "Alliance",
		},
		[41607660] = {
			name = L["Wynne Larson"],
			category = "repair",
			description = L["Robe Merchant"],
			faction = "Alliance",
		},
		[42407660] = {
			name = L["Evan Larson"],
			category = "repair",
			description = L["Hatter"],
			faction = "Alliance",
		},
		[42806540] = {
			name = L["Ardwyn Cailen"],
			category = "repair",
			description = L["Wand Merchant"],
			faction = "Alliance",
		},
		[43407420] = {
			name = L["Duncan Cullen"],
			category = "repair",
			description = L["Light Armor Merchant"],
			faction = "Alliance",
		},
		[43006540] = {
			name = L["Allan Hafgan"],
			category = "repair",
			description = L["Staves Merchant"],
			faction = "Alliance",
		},
		[64204300] = {
			name = L["Bryan Cross"],
			category = "repair",
			description = L["Shield Merchant"],
			faction = "Alliance",
		},
		[67604880] = {
			name = L["Seoman Griffith"],
			category = "repair",
			description = L["Leather Armor Merchant"],
			faction = "Alliance",
		},
		[74204740] = {
			name = L["Osric Strang"],
			category = "repair",
			description = L["Heavy Armor Merchant"],
			faction = "Alliance",
		},
		[74204280] = {
			name = L["Heinrich Stone"],
			category = "repair",
			description = L["Blade Merchant"],
			faction = "Alliance",
		},
		[69004240] = {
			name = L["Gerik Koen"],
			category = "repair",
			description = L["Two Handed Weapon Merchant"],
			faction = "Alliance",
		},
		[67004320] = {
			name = L["Mayda Thane"],
			category = "repair",
			description = L["Cobbler"],
			faction = "Alliance",
		},
		[74604780] = {
			name = L["Wilhelm Strang"],
			category = "repair",
			description = L["Mail Armor Merchant"],
			faction = "Alliance",
		},
		[37003940] = {
			name = L["Gregory Ardus"],
			category = "repair",
			description = L["Staff & Mace Merchant"],
			faction = "Alliance",
		},
		[43804320] = {
			name = L["Agustus Moulaine"],
			category = "repair",
			description = L["Mail Armor Merchant"],
			faction = "Alliance",
		},
		[43604340] = {
			name = L["Theresa Moulaine"],
			category = "repair",
			description = L["Robe Vendor"],
			faction = "Alliance",
		},
		[51401240] = {
			name = L["Kathrum Axehand"],
			category = "repair",
			description = L["Axe Merchant"],
			faction = "Alliance",
		},
		[54401540] = {
			name = L["Thulman Flintcrag"],
			category = "repair",
			description = L["Guns Vendor"],
			faction = "Alliance",
		},
		[56601700] = {
			name = L["Kaita Deepforge"],
			category = "repair",
			description = L["Blacksmithing Supplies"],
			faction = "Alliance",
		},
		[73805340] = {
			name = L["Officer Areyn"],
			category = "repair",
			description = L["Accessories Quartermaster"],
			faction = "Alliance",
		},
		[29405120] = {
			name = L["Sylista"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Alliance",
		},
		[61201720] = {
			name = L["Jenova Stoneshield"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Alliance",
		},
		[38008160] = {
			name = L["Maginor Dumas"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Master Mage"],
			classes = {
				MAGE = true,
			},
			faction = "Alliance",
		},
		[38802640] = {
			name = L["High Priestess Laurena"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Priest Trainer"],
			classes = {
				PRIEST = true,
			},
			faction = "Alliance",
		},
		[25407820] = {
			name = L["Demisette Cloyce"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warlock Trainer"],
			classes = {
				WARLOCK = true,
			},
			faction = "Alliance",
		},
		[78204720] = {
			name = L["Ander Germaine"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warrior Trainer"],
			classes = {
				WARRIOR = true,
			},
			faction = "Alliance",
		},
		[74405280] = {
			name = L["Osborne the Night Man"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Rogue Trainer"],
			classes = {
				ROGUE = true,
			},
			faction = "Alliance",
		},
		[37203300] = {
			name = L["Lord Grayson Shadowbreaker"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Paladin Trainer"],
			classes = {
				PALADIN = true,
			},
			faction = "Alliance",
		},
		[56801640] = {
			name = L["Dane Lindgren"],
			category = "primaryProfession",
			profession = "Blacksmith",
			description = L["Journeyman Blacksmith"],
			faction = "Alliance",
		},
		[67804900] = {
			name = L["Maris Granger"],
			category = "primaryProfession",
			profession = "Skinning",
			description = L["Skinning Trainer"],
			faction = "Alliance",
		},
		[43607380] = {
			name = L["Lawrence Schneider"],
			category = "primaryProfession",
			profession = "Tailoring",
			description = L["Journeyman Tailor"],
			faction = "Alliance",
		},
		[43006420] = {
			name = L["Lucan Cordell"],
			category = "primaryProfession",
			profession = "Enchanting",
			description = L["Expert Enchanter"],
			faction = "Alliance",
		},
		[43207360] = {
			name = L["Georgio Bolero"],
			category = "primaryProfession",
			profession = "Tailoring",
			description = L["Artisan Tailor"],
			faction = "Alliance",
		},
		[42802640] = {
			name = L["Shaina Fuller"],
			category = "secondaryProfession",
			profession = "First Aid",
			description = L["First Aid Trainer"],
			faction = "Alliance",
		},
		[39407960] = {
			name = L["Larimaine Purdue"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Portal Trainer"],
			classes = {
				MAGE = true,
			},
			faction = "Alliance",
		},
		[61601580] = {
			name = L["Karrina Mekenda"],
			category = "trainers",
			description = L["Pet Trainer"],
			faction = "Alliance",
		},
		[78804560] = {
			name = L["Wu Shen"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warrior Trainer"],
			classes = {
				WARRIOR = true,
			},
			faction = "Alliance",
		},
		[78604560] = {
			name = L["Ilsa Corbin"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warrior Trainer"],
			classes = {
				WARRIOR = true,
			},
			faction = "Alliance",
		},
		[75603700] = {
			name = L["Stephen Ryback"],
			category = "secondaryProfession",
			profession = "Cooking",
			description = L["Cooking Trainer"],
			faction = "Alliance",
		},
		[41002820] = {
			name = L["Brother Benjamin"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Priest Trainer"],
			classes = {
				PRIEST = true,
			},
			faction = "Alliance",
		},
		[38802680] = {
			name = L["Brother Joshua"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Priest Trainer"],
			classes = {
				PRIEST = true,
			},
			faction = "Alliance",
		},
		[38603260] = {
			name = L["Arthur the Faithful"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Paladin Trainer"],
			classes = {
				PALADIN = true,
			},
			faction = "Alliance",
		},
		[37403200] = {
			name = L["Katherine the Pure"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Paladin Trainer"],
			classes = {
				PALADIN = true,
			},
			faction = "Alliance",
		},
		[45805820] = {
			name = L["Arnold Leland"],
			category = "secondaryProfession",
			profession = "Fishing",
			description = L["Fishing Trainer"],
			faction = "Alliance",
		},
		[26207740] = {
			name = L["Ursula Deline"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warlock Trainer"],
			classes = {
				WARLOCK = true,
			},
			faction = "Alliance",
		},
		[25807900] = {
			name = L["Sandahl"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warlock Trainer"],
			classes = {
				WARLOCK = true,
			},
			faction = "Alliance",
		},
		[38607940] = {
			name = L["Jennea Cannon"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Mage Trainer"],
			classes = {
				MAGE = true,
			},
			faction = "Alliance",
		},
		[37008120] = {
			name = L["Elsharin"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Mage Trainer"],
			classes = {
				MAGE = true,
			},
			faction = "Alliance",
		},
		[46407920] = {
			name = L["Lilyssia Nightbreeze"],
			category = "primaryProfession",
			profession = "Alchemy",
			description = L["Expert Alchemist"],
			faction = "Alliance",
		},
		[46407900] = {
			name = L["Tel'Athir"],
			category = "primaryProfession",
			profession = "Alchemy",
			description = L["Journeyman Alchemist"],
			faction = "Alliance",
		},
		[15204980] = {
			name = L["Shylamiir"],
			category = "primaryProfession",
			profession = "Herbalism",
			description = L["Herbalism Trainer"],
			faction = "Alliance",
		},
		[21005540] = {
			name = L["Sheldras Moontree"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Druid Trainer"],
			classes = {
				DRUID = true,
			},
			faction = "Alliance",
		},
		[21405140] = {
			name = L["Theridran"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Druid Trainer"],
			classes = {
				DRUID = true,
			},
			faction = "Alliance",
		},
		[18805360] = {
			name = L["Maldryn"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Druid Trainer"],
			classes = {
				DRUID = true,
			},
			faction = "Alliance",
		},
		[56801645] = {
			name = L["Therum Deepforge"],
			category = "primaryProfession",
			profession = "Blacksmith",
			description = L["Expert Blacksmith"],
			faction = "Alliance",
		},
		[51001720] = {
			name = L["Gelman Stonehand"],
			category = "primaryProfession",
			profession = "Mining",
			description = L["Mining Trainer"],
			faction = "Alliance",
		},
		[61601540] = {
			name = L["Einris Brightspear"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Hunter Trainer"],
			classes = {
				HUNTER = true,
			},
			faction = "Alliance",
		},
		[62001500] = {
			name = L["Ulfir Ironbeard"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Hunter Trainer"],
			classes = {
				HUNTER = true,
			},
			faction = "Alliance",
		},
		[62401480] = {
			name = L["Thorfin Stoneshield"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Hunter Trainer"],
			classes = {
				HUNTER = true,
			},
			faction = "Alliance",
		},
		[54800780] = {
			name = L["Lilliam Sparkspindle"],
			category = "primaryProfession",
			profession = "Engineering",
			description = L["Expert Engineer"],
			faction = "Alliance",
		},
		[67204960] = {
			name = L["Simon Tanner"],
			category = "primaryProfession",
			profession = "Leatherworking",
			description = L["Expert Leatherworker"],
			faction = "Alliance",
		},
		[44807700] = {
			name = L["Tannysa"],
			category = "primaryProfession",
			profession = "Herbalism",
			description = L["Herbalism Trainer"],
			faction = "Alliance",
		},
		[42007620] = {
			name = L["Sellandus"],
			category = "primaryProfession",
			profession = "Tailoring",
			description = L["Expert Tailor"],
			faction = "Alliance",
		},
		[26607760] = {
			name = L["Jalane Ayrole"],
			category = "primaryProfession",
			profession = "Tailoring",
			description = L["Master Shadoweave Tailor"],
			faction = "Alliance",
		},
		[54600800] = {
			name = L["Sprite Jumpsprocket"],
			category = "primaryProfession",
			profession = "Engineering",
			description = L["Journeyman Engineer"],
			faction = "Alliance",
		},
		[43006400] = {
			name = L["Betty Quin"],
			category = "primaryProfession",
			profession = "Enchanting",
			description = L["Journeyman Enchanter"],
			faction = "Alliance",
		},
		[67804940] = {
			name = L["Randal Worth"],
			category = "primaryProfession",
			profession = "Leatherworking",
			description = L["Journeyman Leatherworker"],
			faction = "Alliance",
		},
		[20205080] = {
			name = L["Nara Meideros"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Priest Trainer"],
			classes = {
				PRIEST = true,
			},
			faction = "Alliance",
		},
		[57005760] = {
			name = L["Woo Ping"],
			category = "trainers",
			subcategory = "weaponmaster",
			description = L["Weapon Master"],
			faction = "Alliance",
		},
		[78205720] = {
			name = L["Lord Tony Romano"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Rogue Trainer"],
			classes = {
				ROGUE = true,
			},
			faction = "Alliance",
		},
		[52006780] = {
			name = L["Roberto Pupellyverbos"],
			category = "vendors",
			description = L["Merlot Connoisseur"],
			faction = "Alliance",
		},
		[74603680] = {
			name = L["Kendor Kabonka"],
			category = "vendors",
			description = L["Master of Cooking Recipes"],
			faction = "Alliance",
		},
		[60406340] = {
			name = L["Elaine Trias"],
			category = "vendors",
			description = L["Mistress of Cheese"],
			faction = "Alliance",
		},
		[55806520] = {
			name = L["Keldric Boucher"],
			category = "vendors",
			description = L["Arcane Goods Vendor"],
			faction = "Alliance",
		},
		[56206500] = {
			name = L["Kyra Boucher"],
			category = "vendors",
			subcategory = "reagentvendor",
			description = L["Reagent Vendor"],
			faction = "Alliance",
		},
		[58206140] = {
			name = L["Thurman Mullby"],
			category = "vendors",
			description = L["General Goods Vendor"],
			faction = "Alliance",
		},
		[58006080] = {
			name = L["Edna Mullby"],
			category = "vendors",
			description = L["Trade Supplier"],
			faction = "Alliance",
		},
		[51806840] = {
			name = L["Julia Gallina"],
			category = "vendors",
			description = L["Wine Vendor"],
			faction = "Alliance",
		},
		[64206100] = {
			name = L["Bernard Gump"],
			category = "vendors",
			description = L["Florist"],
			faction = "Alliance",
		},
		[64406060] = {
			name = L["Felicia Gump"],
			category = "vendors",
			description = L["Herbalism Supplier"],
			faction = "Alliance",
		},
		[29606780] = {
			name = L["Darian Singh"],
			category = "vendors",
			description = L["Fireworks Vendor"],
			faction = "Alliance",
		},
		[28607500] = {
			name = L["Jarel Moor"],
			category = "vendors",
			description = L["Bartender"],
			faction = "Alliance",
		},
		[32408000] = {
			name = L["Charys Yserian"],
			category = "vendors",
			description = L["Arcane Trinkets Vendor"],
			faction = "Alliance",
		},
		[36007480] = {
			name = L["Owen Vaughn"],
			category = "vendors",
			subcategory = "reagentvendor",
			description = L["Reagent Vendor"],
			faction = "Alliance",
		},
		[40808980] = {
			name = L["Joachim Brenlow"],
			category = "vendors",
			description = L["Bartender"],
			faction = "Alliance",
		},
		[46607900] = {
			name = L["Maria Lumere"],
			category = "vendors",
			description = L["Alchemy Supplies"],
			faction = "Alliance",
		},
		[41406520] = {
			name = L["Adair Gilroy"],
			category = "vendors",
			description = L["Librarian"],
			faction = "Alliance",
		},
		[43006425] = {
			name = L["Jessara Cordell"],
			category = "vendors",
			description = L["Enchanting Supplies"],
			faction = "Alliance",
		},
		[67404900] = {
			name = L["Alyssa Griffith"],
			category = "vendors",
			description = L["Bag Vendor"],
			faction = "Alliance",
		},
		[78205900] = {
			name = L["Jasper Fel"],
			category = "vendors",
			description = L["Shady Dealer"],
			faction = "Alliance",
		},
		[76406000] = {
			name = L["Sloan McCoy"],
			category = "vendors",
			subcategory = "poisonvendor",
			description = L["Poison Supplier"],
			faction = "Alliance",
		},
		[73803720] = {
			name = L["Elly Langston"],
			category = "vendors",
			description = L["Barmaid"],
			faction = "Alliance",
		},
		[43407400] = {
			name = L["Alexandra Bolero"],
			category = "vendors",
			description = L["Tailoring Supplies"],
			faction = "Alliance",
		},
		[43202680] = {
			name = L["Brother Cassius"],
			category = "vendors",
			subcategory = "reagentvendor",
			description = L["Reagent Vendor"],
			faction = "Alliance",
		},
		[57806300] = {
			name = L["Thomas Miller"],
			category = "vendors",
			description = L["Baker"],
			faction = "Alliance",
		},
		[60406360] = {
			name = L["Ben Trias"],
			category = "vendors",
			description = L["Apprentice of Cheese"],
			faction = "Alliance",
		},
		[57206840] = {
			name = L["Rebecca Laughlin"],
			category = "vendors",
			description = L["Tabard Vendor"],
			faction = "Alliance",
		},
		[76003680] = {
			name = L["Erika Tate"],
			category = "vendors",
			description = L["Cooking Supplier"],
			faction = "Alliance",
		},
		[45805825] = {
			name = L["Catherine Leland"],
			category = "vendors",
			description = L["Fishing Supplier"],
			faction = "Alliance",
		},
		[46607880] = {
			name = L["Eldraeith"],
			category = "vendors",
			description = L["Herbalism Supplier"],
			faction = "Alliance",
		},
		[51201680] = {
			name = L["Brooke Stonebraid"],
			category = "vendors",
			description = L["Mining Supplier"],
			faction = "Alliance",
		},
		[55200740] = {
			name = L["Billibub Cogspinner"],
			category = "vendors",
			description = L["Engineering Supplier"],
			faction = "Alliance",
		},
		[25807760] = {
			name = L["Spackle Thornberry"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Demon Trainer"],
			classes = {
				WARLOCK = true,
			},
			faction = "Alliance",
		},
		[67204940] = {
			name = L["Jillian Tanner"],
			category = "vendors",
			description = L["Leatherworking Supplies"],
			faction = "Alliance",
		},
		[64003800] = {
			name = L["Lil Timmy"],
			category = "vendors",
			description = L["Boy with kittens"],
			faction = "Alliance",
		},
		[30006220] = {
			name = L["Sewer Beast"],
			category = "rares",
			faction = "Neutral",
		},
		[30806320] = {
			name = L["Sewer Beast"],
			category = "rares",
			faction = "Neutral",
		},
		[31206040] = {
			name = L["Sewer Beast"],
			category = "rares",
			faction = "Neutral",
		},
		[31806000] = {
			name = L["Sewer Beast"],
			category = "rares",
			faction = "Neutral",
		},
		[35604320] = {
			name = L["Sewer Beast"],
			category = "rares",
			faction = "Neutral",
		},
		[40206040] = {
			name = L["Sewer Beast"],
			category = "rares",
			faction = "Neutral",
		},
		[41006020] = {
			name = L["Sewer Beast"],
			category = "rares",
			faction = "Neutral",
		},
		[49406260] = {
			name = L["Sewer Beast"],
			category = "rares",
			faction = "Neutral",
		},
		[49406620] = {
			name = L["Sewer Beast"],
			category = "rares",
			faction = "Neutral",
		},
		[49802260] = {
			name = L["Sewer Beast"],
			category = "rares",
			faction = "Neutral",
		},
		[50006220] = {
			name = L["Sewer Beast"],
			category = "rares",
			faction = "Neutral",
		},
		[59003680] = {
			name = L["Sewer Beast"],
			category = "rares",
			faction = "Neutral",
		},
		[60205140] = {
			name = L["Sewer Beast"],
			category = "rares",
			faction = "Neutral",
		},
		[63203600] = {
			name = L["Sewer Beast"],
			category = "rares",
			faction = "Neutral",
		},
		[63604860] = {
			name = L["Sewer Beast"],
			category = "rares",
			faction = "Neutral",
		},
		[63605480] = {
			name = L["Sewer Beast"],
			category = "rares",
			faction = "Neutral",
		},
		[64603420] = {
			name = L["Sewer Beast"],
			category = "rares",
			faction = "Neutral",
		},
		[65603300] = {
			name = L["Sewer Beast"],
			category = "rares",
			faction = "Neutral",
		},
		[66205680] = {
			name = L["Sewer Beast"],
			category = "rares",
			faction = "Neutral",
		},
		[35004520] = {
			name = L["Sewer Beast"],
			category = "rares",
			faction = "Neutral",
		},
		[37604460] = {
			name = L["Sewer Beast"],
			category = "rares",
			faction = "Neutral",
		},
		[38204700] = {
			name = L["Sewer Beast"],
			category = "rares",
			faction = "Neutral",
		},
		[48006380] = {
			name = L["Sewer Beast"],
			category = "rares",
			faction = "Neutral",
		},
		[57605880] = {
			name = L["Sewer Beast"],
			category = "rares",
			faction = "Neutral",
		},
		[62405020] = {
			name = L["Sewer Beast"],
			category = "rares",
			faction = "Neutral",
		},
		[62605400] = {
			name = L["Sewer Beast"],
			category = "rares",
			faction = "Neutral",
		},
		[64203380] = {
			name = L["Sewer Beast"],
			category = "rares",
			faction = "Neutral",
		},
		[64603340] = {
			name = L["Sewer Beast"],
			category = "rares",
			faction = "Neutral",
		},
		[64605440] = {
			name = L["Sewer Beast"],
			category = "rares",
			faction = "Neutral",
		},
		[64805500] = {
			name = L["Sewer Beast"],
			category = "rares",
			faction = "Neutral",
		},
		[66003200] = {
			name = L["Sewer Beast"],
			category = "rares",
			faction = "Neutral",
		},
		[66803120] = {
			name = L["Sewer Beast"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1454] = {
		[55606280] = {
			name = L["Auctioneer Thathung"],
			category = "auctioneers",
			faction = "Horde",
		},
		[55406480] = {
			name = L["Auctioneer Wabang"],
			category = "auctioneers",
			faction = "Horde",
		},
		[55006200] = {
			name = L["Auctioneer Grimful"],
			category = "auctioneers",
			faction = "Horde",
		},
		[49606940] = {
			name = L["Karus"],
			category = "bankers",
			description = L["Banker"],
			faction = "Horde",
		},
		[50006880] = {
			name = L["Koma"],
			category = "bankers",
			description = L["Banker"],
			faction = "Horde",
		},
		[49206960] = {
			name = L["Soran"],
			category = "bankers",
			description = L["Banker"],
			faction = "Horde",
		},
		[45206380] = {
			name = L["Doras"],
			category = "flightmasters",
			fpName = L["Orgrimmar, Durotar"],
			description = L["Wind Rider Master"],
			faction = "Horde",
		},
		[43807460] = {
			name = L["Urtrun Clanbringer"],
			category = "guildmasters",
			description = L["Guild Master"],
			faction = "Horde",
		},
		[54006860] = {
			name = L["Innkeeper Gryshka"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Horde",
		},
		[50807030] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Horde",
		},
		[62104060] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Horde",
		},
		[47406860] = {
			name = L["Urtharo"],
			category = "repair",
			description = L["Weapon Merchant"],
			faction = "Horde",
		},
		[62605040] = {
			name = L["Tor'phan"],
			category = "repair",
			description = L["Cloth & Leather Armor Merchant"],
			faction = "Horde",
		},
		[62804480] = {
			name = L["Handor"],
			category = "repair",
			description = L["Cloth & Leather Armor Merchant"],
			faction = "Horde",
		},
		[56207360] = {
			name = L["Ollanus"],
			category = "repair",
			description = L["Light Armor Merchant"],
			faction = "Horde",
		},
		[55807300] = {
			name = L["Sana"],
			category = "repair",
			description = L["Mail Armor Merchant"],
			faction = "Horde",
		},
		[56007320] = {
			name = L["Morgum"],
			category = "repair",
			description = L["Leather Armor Merchant"],
			faction = "Horde",
		},
		[52206240] = {
			name = L["Kaja"],
			category = "repair",
			description = L["Guns and Ammo Merchant"],
			faction = "Horde",
		},
		[44404840] = {
			name = L["Muragus"],
			category = "repair",
			description = L["Staff Merchant"],
			faction = "Horde",
		},
		[45405580] = {
			name = L["Kareth"],
			category = "repair",
			description = L["Blade Merchant"],
			faction = "Horde",
		},
		[29807400] = {
			name = L["Ukra'nor"],
			category = "repair",
			description = L["Staff Merchant"],
			faction = "Horde",
		},
		[82402380] = {
			name = L["Sumi"],
			category = "repair",
			description = L["Blacksmithing Supplier"],
			faction = "Horde",
		},
		[73004200] = {
			name = L["Kiro"],
			category = "repair",
			description = L["War Harness Maker"],
			faction = "Horde",
		},
		[81601880] = {
			name = L["Koru"],
			category = "repair",
			description = L["Mace & Staves Vendor"],
			faction = "Horde",
		},
		[81401900] = {
			name = L["Shoma"],
			category = "repair",
			description = L["Weapon Vendor"],
			faction = "Horde",
		},
		[81201900] = {
			name = L["Zendo'jian"],
			category = "repair",
			description = L["Weapon Vendor"],
			faction = "Horde",
		},
		[77803840] = {
			name = L["Jin'sora"],
			category = "repair",
			description = L["Bow Merchant"],
			faction = "Horde",
		},
		[82001880] = {
			name = L["Galthuk"],
			category = "repair",
			description = L["Two-Handed Weapons Merchant"],
			faction = "Horde",
		},
		[82402360] = {
			name = L["Tumi"],
			category = "repair",
			description = L["Heavy Armor Merchant"],
			faction = "Horde",
		},
		[44204840] = {
			name = L["Katis"],
			category = "repair",
			description = L["Wand Merchant"],
			faction = "Horde",
		},
		[41406880] = {
			name = L["Sergeant Ba'sha"],
			category = "repair",
			description = L["Accessories Quartermaster"],
			faction = "Horde",
		},
		[70201500] = {
			name = L["Xon'cha"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Horde",
		},
		[79602340] = {
			name = L["Snarl"],
			category = "primaryProfession",
			profession = "Blacksmith",
			description = L["Expert Blacksmith"],
			faction = "Horde",
		},
		[81401940] = {
			name = L["Hanashi"],
			category = "trainers",
			subcategory = "weaponmaster",
			description = L["Weapon Master"],
			faction = "Horde",
		},
		[62804940] = {
			name = L["Snang"],
			category = "primaryProfession",
			profession = "Tailoring",
			description = L["Journeyman Tailor"],
			faction = "Horde",
		},
		[75802440] = {
			name = L["Thund"],
			category = "primaryProfession",
			profession = "Engineering",
			description = L["Journeyman Engineer"],
			faction = "Horde",
		},
		[48004620] = {
			name = L["Grol'dar"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warlock Trainer"],
			classes = {
				WARLOCK = true,
			},
			faction = "Horde",
		},
		[48404700] = {
			name = L["Mirket"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warlock Trainer"],
			classes = {
				WARLOCK = true,
			},
			faction = "Horde",
		},
		[48404560] = {
			name = L["Zevrost"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warlock Trainer"],
			classes = {
				WARLOCK = true,
			},
			faction = "Horde",
		},
		[42805140] = {
			name = L["Gest"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Rogue Trainer"],
			classes = {
				ROGUE = true,
			},
			faction = "Horde",
		},
		[44005440] = {
			name = L["Ormok"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Rogue Trainer"],
			classes = {
				ROGUE = true,
			},
			faction = "Horde",
		},
		[69602920] = {
			name = L["Lumak"],
			category = "secondaryProfession",
			profession = "Fishing",
			description = L["Fishing Trainer"],
			faction = "Horde",
		},
		[38803660] = {
			name = L["Kardris Dreamseeker"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Shaman Trainer"],
			classes = {
				SHAMAN = true,
			},
			faction = "Horde",
		},
		[53803840] = {
			name = L["Godan"],
			category = "primaryProfession",
			profession = "Enchanting",
			description = L["Expert Enchanter"],
			faction = "Horde",
		},
		[56603320] = {
			name = L["Yelmak"],
			category = "primaryProfession",
			profession = "Alchemy",
			description = L["Expert Alchemist"],
			faction = "Horde",
		},
		[66201840] = {
			name = L["Ormak Grimshot"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Hunter Trainer"],
			classes = {
				HUNTER = true,
			},
			faction = "Horde",
		},
		[79603140] = {
			name = L["Grezz Ragefist"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warrior Trainer"],
			classes = {
				WARRIOR = true,
			},
			faction = "Horde",
		},
		[80203240] = {
			name = L["Sorek"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warrior Trainer"],
			classes = {
				WARRIOR = true,
			},
			faction = "Horde",
		},
		[82202300] = {
			name = L["Saru Steelfury"],
			category = "primaryProfession",
			profession = "Blacksmith",
			description = L["Artisan Blacksmith"],
			faction = "Horde",
		},
		[73002640] = {
			name = L["Makaru"],
			category = "primaryProfession",
			profession = "Mining",
			description = L["Mining Trainer"],
			faction = "Horde",
		},
		[63405000] = {
			name = L["Magar"],
			category = "primaryProfession",
			profession = "Tailoring",
			description = L["Expert Tailor"],
			faction = "Horde",
		},
		[62804440] = {
			name = L["Karolek"],
			category = "primaryProfession",
			profession = "Leatherworking",
			description = L["Expert Leatherworker"],
			faction = "Horde",
		},
		[34008440] = {
			name = L["Arnok"],
			category = "secondaryProfession",
			profession = "First Aid",
			description = L["First Aid Trainer"],
			faction = "Horde",
		},
		[57405360] = {
			name = L["Zamja"],
			category = "secondaryProfession",
			profession = "Cooking",
			description = L["Cooking Trainer"],
			faction = "Horde",
		},
		[43005340] = {
			name = L["Shenthul"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Rogue Trainer"],
			classes = {
				ROGUE = true,
			},
			faction = "Horde",
		},
		[37803660] = {
			name = L["Sian'tsu"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Shaman Trainer"],
			classes = {
				SHAMAN = true,
			},
			faction = "Horde",
		},
		[55403960] = {
			name = L["Jandi"],
			category = "primaryProfession",
			profession = "Herbalism",
			description = L["Herbalism Trainer"],
			faction = "Horde",
		},
		[67002000] = {
			name = L["Xor'juul"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Hunter Trainer"],
			classes = {
				HUNTER = true,
			},
			faction = "Horde",
		},
		[67801780] = {
			name = L["Sian'dur"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Hunter Trainer"],
			classes = {
				HUNTER = true,
			},
			faction = "Horde",
		},
		[80202960] = {
			name = L["Zel'mak"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warrior Trainer"],
			classes = {
				WARRIOR = true,
			},
			faction = "Horde",
		},
		[75802520] = {
			name = L["Nogg"],
			category = "primaryProfession",
			profession = "Engineering",
			description = L["Expert Engineer"],
			faction = "Horde",
		},
		[69201300] = {
			name = L["Kildar"],
			category = "trainers",
			description = L["Wolf Riding Instructor"],
			faction = "Horde",
		},
		[63204500] = {
			name = L["Kamari"],
			category = "primaryProfession",
			profession = "Leatherworking",
			description = L["Journeyman Leatherworker"],
			faction = "Horde",
		},
		[38408560] = {
			name = L["Pephredo"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Mage Trainer"],
			classes = {
				MAGE = true,
			},
			faction = "Horde",
		},
		[38808540] = {
			name = L["Enyo"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Mage Trainer"],
			classes = {
				MAGE = true,
			},
			faction = "Horde",
		},
		[38408580] = {
			name = L["Deino"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Mage Trainer"],
			classes = {
				MAGE = true,
			},
			faction = "Horde",
		},
		[38608560] = {
			name = L["Thuul"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Portal Trainer"],
			classes = {
				MAGE = true,
			},
			faction = "Horde",
		},
		[35608720] = {
			name = L["Zayus"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["High Priest"],
			classes = {
				PRIEST = true,
			},
			faction = "Horde",
		},
		[35808740] = {
			name = L["X'yera"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Priest Trainer"],
			classes = {
				PRIEST = true,
			},
			faction = "Horde",
		},
		[35608760] = {
			name = L["Ur'kyo"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Priest Trainer"],
			classes = {
				PRIEST = true,
			},
			faction = "Horde",
		},
		[63204520] = {
			name = L["Thuwd"],
			category = "primaryProfession",
			profession = "Skinning",
			description = L["Skinning Trainer"],
			faction = "Horde",
		},
		[39008600] = {
			name = L["Uthel'nay"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Mage Trainer"],
			classes = {
				MAGE = true,
			},
			faction = "Horde",
		},
		[66401500] = {
			name = L["Xao'tsu"],
			category = "trainers",
			description = L["Pet Trainer"],
			faction = "Horde",
		},
		[80602340] = {
			name = L["Ug'thok"],
			category = "primaryProfession",
			profession = "Blacksmith",
			description = L["Journeyman Blacksmith"],
			faction = "Horde",
		},
		[76002500] = {
			name = L["Roxxik"],
			category = "primaryProfession",
			profession = "Engineering",
			description = L["Artisan Engineer"],
			faction = "Horde",
		},
		[55803320] = {
			name = L["Whuut"],
			category = "primaryProfession",
			profession = "Alchemy",
			description = L["Journeyman Alchemist"],
			faction = "Horde",
		},
		[53603820] = {
			name = L["Jhag"],
			category = "primaryProfession",
			profession = "Enchanting",
			description = L["Journeyman Enchanter"],
			faction = "Horde",
		},
		[81401945] = {
			name = L["Sayoc"],
			category = "trainers",
			subcategory = "weaponmaster",
			description = L["Weapon Master"],
			faction = "Horde",
		},
		[38603620] = {
			name = L["Sagorne Creststrider"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Shaman Trainer"],
			classes = {
				SHAMAN = true,
			},
			faction = "Horde",
		},
		[44806980] = {
			name = L["Olvia"],
			category = "vendors",
			description = L["Meat Vendor"],
			faction = "Horde",
		},
		[48008020] = {
			name = L["Trak'gen"],
			category = "vendors",
			description = L["General Goods Merchant"],
			faction = "Horde",
		},
		[45405680] = {
			name = L["Horthus"],
			category = "vendors",
			subcategory = "reagentvendor",
			description = L["Reagents Vendor"],
			faction = "Horde",
		},
		[49005400] = {
			name = L["Kor'jus"],
			category = "vendors",
			description = L["Mushroom Vendor"],
			faction = "Horde",
		},
		[69802960] = {
			name = L["Shankys"],
			category = "vendors",
			description = L["Fishing Supplies"],
			faction = "Horde",
		},
		[42204960] = {
			name = L["Rekkul"],
			category = "vendors",
			subcategory = "poisonvendor",
			description = L["Poison Vendor"],
			faction = "Horde",
		},
		[46004600] = {
			name = L["Hagrus"],
			category = "vendors",
			subcategory = "reagentvendor",
			description = L["Reagents Vendor"],
			faction = "Horde",
		},
		[37605240] = {
			name = L["Shan'ti"],
			category = "vendors",
			description = L["Fruit Vendor"],
			faction = "Horde",
		},
		[53603800] = {
			name = L["Kithas"],
			category = "vendors",
			description = L["Enchanting Supplies"],
			faction = "Horde",
		},
		[56203420] = {
			name = L["Kor'geld"],
			category = "vendors",
			description = L["Alchemy Supplies"],
			faction = "Horde",
		},
		[46004060] = {
			name = L["Asoran"],
			category = "vendors",
			description = L["General Goods Vendor"],
			faction = "Horde",
		},
		[45804060] = {
			name = L["Magenius"],
			category = "vendors",
			subcategory = "reagentvendor",
			description = L["Reagents Vendor"],
			faction = "Horde",
		},
		[73202660] = {
			name = L["Gorina"],
			category = "vendors",
			description = L["Mining Supplier"],
			faction = "Horde",
		},
		[69401240] = {
			name = L["Ogunaro Wolfrunner"],
			category = "vendors",
			description = L["Kennel Master"],
			faction = "Horde",
		},
		[63005120] = {
			name = L["Borya"],
			category = "vendors",
			description = L["Tailoring Supplies"],
			faction = "Horde",
		},
		[63004520] = {
			name = L["Tamar"],
			category = "vendors",
			description = L["Leatherworking Supplies"],
			faction = "Horde",
		},
		[57405780] = {
			name = L["Felika"],
			category = "vendors",
			description = L["General Trade Goods Merchant"],
			faction = "Horde",
		},
		[57405340] = {
			name = L["Borstan"],
			category = "vendors",
			description = L["Meat Vendor"],
			faction = "Horde",
		},
		[58805300] = {
			name = L["Gotri"],
			category = "vendors",
			description = L["Bag Vendor"],
			faction = "Horde",
		},
		[57405320] = {
			name = L["Xen'to"],
			category = "vendors",
			description = L["Cooking Supplier"],
			faction = "Horde",
		},
		[55003960] = {
			name = L["Zeal'aya"],
			category = "vendors",
			description = L["Herbalism Supplier"],
			faction = "Horde",
		},
		[75602520] = {
			name = L["Sovik"],
			category = "vendors",
			description = L["Engineering Supplies"],
			faction = "Horde",
		},
		[43807440] = {
			name = L["Garyl"],
			category = "vendors",
			description = L["Tabard Vendor"],
			faction = "Horde",
		},
		[54406800] = {
			name = L["Barkeep Morag"],
			category = "vendors",
			faction = "Horde",
		},
		[47604680] = {
			name = L["Kurgul"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Demon Trainer"],
			classes = {
				WARLOCK = true,
			},
			faction = "Horde",
		},
		[48008025] = {
			name = L["Shimra"],
			category = "vendors",
			description = L["General Trade Goods Merchant"],
			faction = "Horde",
		},
		[37807660] = {
			name = L["Xan'tish"],
			category = "vendors",
			description = L["Snake Vendor"],
			faction = "Horde",
		},
	}
	nodes[1455] = {
		[24007200] = {
			name = L["Auctioneer Buckler"],
			category = "auctioneers",
			faction = "Alliance",
		},
		[24207440] = {
			name = L["Auctioneer Redmuse"],
			category = "auctioneers",
			faction = "Alliance",
		},
		[25807500] = {
			name = L["Auctioneer Lympkin"],
			category = "auctioneers",
			faction = "Alliance",
		},
		[34605900] = {
			name = L["Barnum Stonemantle"],
			category = "bankers",
			description = L["Banker"],
			faction = "Alliance",
		},
		[35406060] = {
			name = L["Bailey Stonemantle"],
			category = "bankers",
			description = L["Banker"],
			faction = "Alliance",
		},
		[36406220] = {
			name = L["Soleil Stonemantle"],
			category = "bankers",
			description = L["Banker"],
			faction = "Alliance",
		},
		[55604800] = {
			name = L["Gryth Thurden"],
			category = "flightmasters",
			fpName = L["Ironforge, Dun Morogh"],
			description = L["Gryphon Master"],
			faction = "Alliance",
		},
		[36008520] = {
			name = L["Jondor Steelbrow"],
			category = "guildmasters",
			description = L["Guild Master"],
			faction = "Alliance",
		},
		[18605140] = {
			name = L["Innkeeper Firebrew"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Alliance",
		},
		[21005190] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Alliance",
		},
		[32806500] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Alliance",
		},
		[71007250] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Alliance",
		},
		[72004910] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Alliance",
		},
		[51804240] = {
			name = L["Thurgrum Deepforge"],
			category = "repair",
			description = L["Blacksmithing Supplies"],
			faction = "Alliance",
		},
		[36206600] = {
			name = L["Dolman Steelfury"],
			category = "repair",
			description = L["Weapon Merchant"],
			faction = "Alliance",
		},
		[36406600] = {
			name = L["Grenil Steelfury"],
			category = "repair",
			description = L["Weapon Merchant"],
			faction = "Alliance",
		},
		[31805780] = {
			name = L["Bromiir Ormsen"],
			category = "repair",
			description = L["Heavy Armor Merchant"],
			faction = "Alliance",
		},
		[32005840] = {
			name = L["Mangorn Flinthammer"],
			category = "repair",
			description = L["Heavy Armor Merchant"],
			faction = "Alliance",
		},
		[32405800] = {
			name = L["Raena Flinthammer"],
			category = "repair",
			description = L["Light Armor Merchant"],
			faction = "Alliance",
		},
		[61808860] = {
			name = L["Hegnar Swiftaxe"],
			category = "repair",
			description = L["Axe Merchant"],
			faction = "Alliance",
		},
		[61808865] = {
			name = L["Brenwyn Wintersteel"],
			category = "vendors",
			description = L["Blade Merchant"],
			faction = "Alliance",
		},
		[62008900] = {
			name = L["Kelomir Ironhand"],
			category = "repair",
			description = L["Maces & Staves"],
			faction = "Alliance",
		},
		[71606620] = {
			name = L["Skolmin Goldfury"],
			category = "repair",
			description = L["Bow Merchant"],
			faction = "Alliance",
		},
		[72406600] = {
			name = L["Bretta Goldfury"],
			category = "repair",
			description = L["Gun Merchant"],
			faction = "Alliance",
		},
		[54208820] = {
			name = L["Dolkin Craghelm"],
			category = "repair",
			description = L["Mail Armor Merchant"],
			faction = "Alliance",
		},
		[54408740] = {
			name = L["Olthran Craghelm"],
			category = "repair",
			description = L["Heavy Armor Merchant"],
			faction = "Neutral",
		},
		[54608820] = {
			name = L["Lissyphus Finespindle"],
			category = "repair",
			description = L["Light Armor Merchant"],
			faction = "Alliance",
		},
		[22801660] = {
			name = L["Harick Boulderdrum"],
			category = "repair",
			description = L["Wands Merchant"],
			faction = "Alliance",
		},
		[22601620] = {
			name = L["Bingus"],
			category = "repair",
			description = L["Weapon Merchant"],
			faction = "Alliance",
		},
		[38400560] = {
			name = L["Ingrys Stonebrow"],
			category = "repair",
			description = L["Cloth Armor Merchant"],
			faction = "Alliance",
		},
		[38800560] = {
			name = L["Maeva Snowbraid"],
			category = "repair",
			description = L["Robe Merchant"],
			faction = "Alliance",
		},
		[45400640] = {
			name = L["Hjoldir Stoneblade"],
			category = "repair",
			description = L["Blade Merchant"],
			faction = "Alliance",
		},
		[61208920] = {
			name = L["Thalgus Thunderfist"],
			category = "repair",
			description = L["Weapon Merchant"],
			faction = "Alliance",
		},
		[69408380] = {
			name = L["Ulbrek Firehand"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Alliance",
		},
		[66405520] = {
			name = L["Vosur Brakthel"],
			category = "primaryProfession",
			profession = "Alchemy",
			description = L["Journeyman Alchemist"],
			faction = "Alliance",
		},
		[39003280] = {
			name = L["Gretta Finespindle"],
			category = "primaryProfession",
			profession = "Leatherworking",
			description = L["Journeyman Leatherworker"],
			faction = "Alliance",
		},
		[43602820] = {
			name = L["Uthrar Threx"],
			category = "primaryProfession",
			profession = "Tailoring",
			description = L["Journeyman Tailor"],
			faction = "Alliance",
		},
		[67008960] = {
			name = L["Kelstrum Stonebreaker"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warrior Trainer"],
			classes = {
				WARRIOR = true,
			},
			faction = "Alliance",
		},
		[25600740] = {
			name = L["Milstaff Stormeye"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Portal Trainer"],
			classes = {
				MAGE = true,
			},
			faction = "Alliance",
		},
		[50402600] = {
			name = L["Geofram Bouldertoe"],
			category = "primaryProfession",
			profession = "Mining",
			description = L["Mining Trainer"],
			faction = "Alliance",
		},
		[52004180] = {
			name = L["Bengus Deepforge"],
			category = "primaryProfession",
			profession = "Blacksmith",
			description = L["Artisan Blacksmith"],
			faction = "Alliance",
		},
		[70209060] = {
			name = L["Kelv Sternhammer"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warrior Trainer"],
			classes = {
				WARRIOR = true,
			},
			faction = "Alliance",
		},
		[66208820] = {
			name = L["Bilban Tosslespanner"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warrior Trainer"],
			classes = {
				WARRIOR = true,
			},
			faction = "Alliance",
		},
		[71009000] = {
			name = L["Daera Brightspear"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Hunter Trainer"],
			classes = {
				HUNTER = true,
			},
			faction = "Alliance",
		},
		[70608380] = {
			name = L["Olmin Burningbeard"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Hunter Trainer"],
			classes = {
				HUNTER = true,
			},
			faction = "Alliance",
		},
		[69808320] = {
			name = L["Regnus Thundergranite"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Hunter Trainer"],
			classes = {
				HUNTER = true,
			},
			faction = "Alliance",
		},
		[39803340] = {
			name = L["Fimble Finespindle"],
			category = "primaryProfession",
			profession = "Leatherworking",
			description = L["Expert Leatherworker"],
			faction = "Alliance",
		},
		[55605880] = {
			name = L["Reyna Stonebranch"],
			category = "primaryProfession",
			profession = "Herbalism",
			description = L["Herbalism Trainer"],
			faction = "Alliance",
		},
		[23800900] = {
			name = L["Theodrus Frostbeard"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Priest Trainer"],
			classes = {
				PRIEST = true,
			},
			faction = "Neutral",
		},
		[24600920] = {
			name = L["Braenna Flintcrag"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Priest Trainer"],
			classes = {
				PRIEST = true,
			},
			faction = "Alliance",
		},
		[25201020] = {
			name = L["Toldren Deepiron"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Priest Trainer"],
			classes = {
				PRIEST = true,
			},
			faction = "Alliance",
		},
		[27000820] = {
			name = L["Bink"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Mage Trainer"],
			classes = {
				MAGE = true,
			},
			faction = "Alliance",
		},
		[26200720] = {
			name = L["Juli Stormkettle"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Mage Trainer"],
			classes = {
				MAGE = true,
			},
			faction = "Alliance",
		},
		[25600440] = {
			name = L["Nittlebur Sparkfizzle"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Mage Trainer"],
			classes = {
				MAGE = true,
			},
			faction = "Neutral",
		},
		[23400500] = {
			name = L["Valgar Highforge"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Paladin Trainer"],
			classes = {
				PALADIN = true,
			},
			faction = "Alliance",
		},
		[24600480] = {
			name = L["Beldruk Doombrow"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Paladin Trainer"],
			classes = {
				PALADIN = true,
			},
			faction = "Alliance",
		},
		[23400620] = {
			name = L["Brandur Ironhammer"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Paladin Trainer"],
			classes = {
				PALADIN = true,
			},
			faction = "Alliance",
		},
		[54805860] = {
			name = L["Nissa Firestone"],
			category = "secondaryProfession",
			profession = "First Aid",
			description = L["First Aid Trainer"],
			faction = "Alliance",
		},
		[43202900] = {
			name = L["Jormund Stonebrow"],
			category = "primaryProfession",
			profession = "Tailoring",
			description = L["Expert Tailor"],
			faction = "Alliance",
		},
		[60004520] = {
			name = L["Gimble Thistlefuzz"],
			category = "primaryProfession",
			profession = "Enchanting",
			description = L["Expert Enchanter"],
			faction = "Alliance",
		},
		[60003680] = {
			name = L["Daryl Riknussun"],
			category = "secondaryProfession",
			profession = "Cooking",
			description = L["Cooking Trainer"],
			faction = "Alliance",
		},
		[48200660] = {
			name = L["Grimnur Stonebrand"],
			category = "secondaryProfession",
			profession = "Fishing",
			description = L["Fishing Trainer"],
			faction = "Alliance",
		},
		[51601480] = {
			name = L["Hulfdan Blackbeard"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Rogue Trainer"],
			classes = {
				ROGUE = true,
			},
			faction = "Alliance",
		},
		[52401480] = {
			name = L["Ormyr Flinteye"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Rogue Trainer"],
			classes = {
				ROGUE = true,
			},
			faction = "Alliance",
		},
		[51801500] = {
			name = L["Fenthwick"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Rogue Trainer"],
			classes = {
				ROGUE = true,
			},
			faction = "Alliance",
		},
		[50800660] = {
			name = L["Thistleheart"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warlock Trainer"],
			classes = {
				WARLOCK = true,
			},
			faction = "Alliance",
		},
		[50200600] = {
			name = L["Briarthorn"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warlock Trainer"],
			classes = {
				WARLOCK = true,
			},
			faction = "Alliance",
		},
		[50200700] = {
			name = L["Alexander Calder"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warlock Trainer"],
			classes = {
				WARLOCK = true,
			},
			faction = "Alliance",
		},
		[68204360] = {
			name = L["Springspindle Fizzlegear"],
			category = "primaryProfession",
			profession = "Engineering",
			description = L["Artisan Engineer"],
			faction = "Alliance",
		},
		[66405525] = {
			name = L["Tally Berryfizz"],
			category = "primaryProfession",
			profession = "Alchemy",
			description = L["Expert Alchemist"],
			faction = "Alliance",
		},
		[39603240] = {
			name = L["Balthus Stoneflayer"],
			category = "primaryProfession",
			profession = "Skinning",
			description = L["Skinning Trainer"],
			faction = "Alliance",
		},
		[26800840] = {
			name = L["Dink"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Mage Trainer"],
			classes = {
				MAGE = true,
			},
			faction = "Alliance",
		},
		[69805020] = {
			name = L["Tinkmaster Overspark"],
			category = "primaryProfession",
			profession = "Engineering",
			description = L["Master Gnome Engineer"],
			faction = "Alliance",
		},
		[70808540] = {
			name = L["Belia Thundergranite"],
			category = "trainers",
			description = L["Pet Trainer"],
			faction = "Alliance",
		},
		[52004240] = {
			name = L["Rotgath Stonebeard"],
			category = "primaryProfession",
			profession = "Blacksmith",
			description = L["Expert Blacksmith"],
			faction = "Alliance",
		},
		[51804220] = {
			name = L["Groum Stonebeard"],
			category = "primaryProfession",
			profession = "Blacksmith",
			description = L["Journeyman Blacksmith"],
			faction = "Alliance",
		},
		[67804400] = {
			name = L["Jemma Quikswitch"],
			category = "primaryProfession",
			profession = "Engineering",
			description = L["Journeyman Engineer"],
			faction = "Alliance",
		},
		[67804320] = {
			name = L["Trixie Quikswitch"],
			category = "primaryProfession",
			profession = "Engineering",
			description = L["Expert Engineer"],
			faction = "Alliance",
		},
		[60404480] = {
			name = L["Thonys Pillarstone"],
			category = "primaryProfession",
			profession = "Enchanting",
			description = L["Journeyman Enchanter"],
			faction = "Alliance",
		},
		[26800760] = {
			name = L["High Priest Rohan"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Priest Trainer"],
			classes = {
				PRIEST = true,
			},
			faction = "Alliance",
		},
		[61408920] = {
			name = L["Buliwyf Stonehand"],
			category = "trainers",
			subcategory = "weaponmaster",
			description = L["Weapon Master"],
			faction = "Alliance",
		},
		[62008920] = {
			name = L["Bixi Wobblebonk"],
			category = "trainers",
			subcategory = "weaponmaster",
			description = L["Weapon Master"],
			faction = "Alliance",
		},
		[51002600] = {
			name = L["Golnir Bouldertoe"],
			category = "vendors",
			description = L["Mining Supplier"],
			faction = "Alliance",
		},
		[36008540] = {
			name = L["Lyesa Steelbrow"],
			category = "vendors",
			description = L["Guild Tabard Vendor"],
			faction = "Alliance",
		},
		[38407360] = {
			name = L["Fillius Fizzlespinner"],
			category = "vendors",
			description = L["Trade Supplier"],
			faction = "Alliance",
		},
		[39007380] = {
			name = L["Bryllia Ironbrand"],
			category = "vendors",
			description = L["General Goods Vendor"],
			faction = "Alliance",
		},
		[32607600] = {
			name = L["Myra Tyrngaarde"],
			category = "vendors",
			description = L["Bread Vendor"],
			faction = "Alliance",
		},
		[19405620] = {
			name = L["Barim Jurgenstaad"],
			category = "vendors",
			subcategory = "reagentvendor",
			description = L["Reagent Vendor"],
			faction = "Alliance",
		},
		[18805160] = {
			name = L["Gwenna Firebrew"],
			category = "vendors",
			description = L["Barmaid"],
			faction = "Alliance",
		},
		[64606940] = {
			name = L["Sognar Cliffbeard"],
			category = "vendors",
			description = L["Meat Vendor"],
			faction = "Alliance",
		},
		[39603400] = {
			name = L["Bombus Finespindle"],
			category = "vendors",
			description = L["Leatherworking Supplies"],
			faction = "Alliance",
		},
		[38407420] = {
			name = L["Pithwick"],
			category = "vendors",
			description = L["Bag Vendor"],
			faction = "Alliance",
		},
		[55405900] = {
			name = L["Gwina Stonebranch"],
			category = "vendors",
			description = L["Herbalism Supplier"],
			faction = "Alliance",
		},
		[72207600] = {
			name = L["Edris Barleybeard"],
			category = "vendors",
			description = L["Barmaid"],
			faction = "Alliance",
		},
		[31202740] = {
			name = L["Ginny Longberry"],
			category = "vendors",
			subcategory = "reagentvendor",
			description = L["Reagent Vendor"],
			faction = "Alliance",
		},
		[43202840] = {
			name = L["Poranna Snowbraid"],
			category = "vendors",
			description = L["Tailoring Supplies"],
			faction = "Alliance",
		},
		[60804420] = {
			name = L["Tilli Thistlefuzz"],
			category = "vendors",
			description = L["Enchanting Supplies"],
			faction = "Alliance",
		},
		[59803760] = {
			name = L["Emrul Riknussun"],
			category = "vendors",
			description = L["Cooking Supplier"],
			faction = "Alliance",
		},
		[47800640] = {
			name = L["Tansy Puddlefizz"],
			category = "vendors",
			description = L["Fishing Supplier"],
			faction = "Alliance",
		},
		[46402720] = {
			name = L["Burbik Gearspanner"],
			category = "vendors",
			description = L["Trade Supplier"],
			faction = "Alliance",
		},
		[52801320] = {
			name = L["Tynnus Venomsprout"],
			category = "vendors",
			description = L["Shady Dealer"],
			faction = "Alliance",
		},
		[67804300] = {
			name = L["Gearcutter Cogspinner"],
			category = "vendors",
			description = L["Engineering Supplies"],
			faction = "Alliance",
		},
		[66405460] = {
			name = L["Soolie Berryfizz"],
			category = "vendors",
			description = L["Alchemy Supplies"],
			faction = "Alliance",
		},
		[73205340] = {
			name = L["Fizzlebang Booms"],
			category = "vendors",
			description = L["Fireworks Vendor"],
			faction = "Alliance",
		},
		[72207640] = {
			name = L["Bruuk Barleybeard"],
			category = "vendors",
			description = L["Bartender"],
			faction = "Alliance",
		},
		[53000620] = {
			name = L["Jubahl Corpseseeker"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Demon Trainer"],
			classes = {
				WARLOCK = true,
			},
			faction = "Alliance",
		},
		[36001620] = {
			name = L["Bimble Longberry"],
			category = "vendors",
			description = L["Fruit Vendor"],
			faction = "Alliance",
		},
		[43002920] = {
			name = L["Outfitter Eric"],
			category = "vendors",
			description = L["Speciality Tailoring Supplies"],
			faction = "Alliance",
		},
		[45004700] = {
			name = L["Sraaz"],
			category = "vendors",
			description = L["Pie Vendor"],
			faction = "Alliance",
		},
	}
	nodes[1456] = {
		[40405220] = {
			name = L["Auctioneer Stampi"],
			category = "auctioneers",
			faction = "Horde",
		},
		[38805060] = {
			name = L["Auctioneer Gullem"],
			category = "auctioneers",
			faction = "Horde",
		},
		[47405840] = {
			name = L["Torn"],
			category = "bankers",
			description = L["Banker"],
			faction = "Horde",
		},
		[46805820] = {
			name = L["Chesmu"],
			category = "bankers",
			description = L["Banker"],
			faction = "Horde",
		},
		[47005900] = {
			name = L["Atepa"],
			category = "bankers",
			description = L["Banker"],
			faction = "Horde",
		},
		[46805000] = {
			name = L["Tal"],
			category = "flightmasters",
			fpName = L["Thunder Bluff, Mulgore"],
			description = L["Wind Rider Master"],
			faction = "Horde",
		},
		[37406300] = {
			name = L["Krumn"],
			category = "guildmasters",
			description = L["Guild Master"],
			faction = "Horde",
		},
		[45606420] = {
			name = L["Innkeeper Pala"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Horde",
		},
		[45005920] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Horde",
		},
		[41206200] = {
			name = L["Jyn Stonehoof"],
			category = "repair",
			description = L["Weapons Merchant"],
			faction = "Horde",
		},
		[39805540] = {
			name = L["Taur Stonehoof"],
			category = "repair",
			description = L["Blacksmithing Supplies"],
			faction = "Horde",
		},
		[46804540] = {
			name = L["Kuna Thunderhorn"],
			category = "repair",
			description = L["Bowyer & Fletching Goods"],
			faction = "Horde",
		},
		[55605660] = {
			name = L["Hogor Thunderhoof"],
			category = "repair",
			description = L["Guns Merchant"],
			faction = "Horde",
		},
		[53805720] = {
			name = L["Delgo Ragetotem"],
			category = "repair",
			description = L["Axe Merchant"],
			faction = "Horde",
		},
		[53205780] = {
			name = L["Etu Ragetotem"],
			category = "repair",
			description = L["Mace & Staff Merchant"],
			faction = "Horde",
		},
		[53205680] = {
			name = L["Kard Ragetotem"],
			category = "repair",
			description = L["Sword and Dagger Merchant"],
			faction = "Horde",
		},
		[49604920] = {
			name = L["Sunn Ragetotem"],
			category = "repair",
			description = L["Staff Merchant"],
			faction = "Horde",
		},
		[51805460] = {
			name = L["Sura Wildmane"],
			category = "repair",
			description = L["War Harness Vendor"],
			faction = "Horde",
		},
		[43404400] = {
			name = L["Tagain"],
			category = "repair",
			description = L["Cloth Armor Merchant"],
			faction = "Horde",
		},
		[42804320] = {
			name = L["Grod"],
			category = "repair",
			description = L["Leather Armor Merchant"],
			faction = "Horde",
		},
		[42804440] = {
			name = L["Fela"],
			category = "repair",
			description = L["Heavy Armor Merchant"],
			faction = "Horde",
		},
		[45205640] = {
			name = L["Hewa"],
			category = "repair",
			description = L["Cloth Armor Merchant"],
			faction = "Horde",
		},
		[45405580] = {
			name = L["Ahanu"],
			category = "repair",
			description = L["Leather Armor Merchant"],
			faction = "Horde",
		},
		[45005620] = {
			name = L["Elki"],
			category = "repair",
			description = L["Mail Armor Merchant"],
			faction = "Horde",
		},
		[53205720] = {
			name = L["Ohanko"],
			category = "repair",
			description = L["Two Handed Weapon Merchant"],
			faction = "Horde",
		},
		[57401720] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[45005960] = {
			name = L["Bulrug"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Horde",
		},
		[29402140] = {
			name = L["Pand Stonebinder"],
			category = "secondaryProfession",
			profession = "First Aid",
			description = L["First Aid Trainer"],
			faction = "Horde",
		},
		[39605520] = {
			name = L["Karn Stonehoof"],
			category = "primaryProfession",
			profession = "Blacksmith",
			description = L["Expert Blacksmith"],
			faction = "Horde",
		},
		[34605760] = {
			name = L["Brek Stonehoof"],
			category = "primaryProfession",
			profession = "Mining",
			description = L["Mining Trainer"],
			faction = "Horde",
		},
		[44204500] = {
			name = L["Tepa"],
			category = "primaryProfession",
			profession = "Tailoring",
			description = L["Expert Tailor"],
			faction = "Horde",
		},
		[41804260] = {
			name = L["Una"],
			category = "primaryProfession",
			profession = "Leatherworking",
			description = L["Artisan Leatherworker"],
			faction = "Horde",
		},
		[42204320] = {
			name = L["Mak"],
			category = "primaryProfession",
			profession = "Leatherworking",
			description = L["Journeyman Leatherworker"],
			faction = "Horde",
		},
		[46803360] = {
			name = L["Bena Winterhoof"],
			category = "primaryProfession",
			profession = "Alchemy",
			description = L["Expert Alchemist"],
			faction = "Horde",
		},
		[45003800] = {
			name = L["Teg Dawnstrider"],
			category = "primaryProfession",
			profession = "Enchanting",
			description = L["Expert Enchanter"],
			faction = "Horde",
		},
		[49803980] = {
			name = L["Komin Winterhoof"],
			category = "primaryProfession",
			profession = "Herbalism",
			description = L["Herbalism Trainer"],
			faction = "Horde",
		},
		[51005280] = {
			name = L["Aska Mistrunner"],
			category = "secondaryProfession",
			profession = "Cooking",
			description = L["Cooking Trainer"],
			faction = "Horde",
		},
		[56004680] = {
			name = L["Kah Mistrunner"],
			category = "secondaryProfession",
			profession = "Fishing",
			description = L["Fishing Trainer"],
			faction = "Horde",
		},
		[23002080] = {
			name = L["Siln Skychaser"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Shaman Trainer"],
			classes = {
				SHAMAN = true,
			},
			faction = "Horde",
		},
		[23401920] = {
			name = L["Tigor Skychaser"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Shaman Trainer"],
			classes = {
				SHAMAN = true,
			},
			faction = "Horde",
		},
		[22201900] = {
			name = L["Beram Skychaser"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Shaman Trainer"],
			classes = {
				SHAMAN = true,
			},
			faction = "Horde",
		},
		[76402760] = {
			name = L["Turak Runetotem"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Druid Trainer"],
			classes = {
				DRUID = true,
			},
			faction = "Horde",
		},
		[77002740] = {
			name = L["Sheal Runetotem"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Druid Trainer"],
			classes = {
				DRUID = true,
			},
			faction = "Horde",
		},
		[76802980] = {
			name = L["Kym Wildmane"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Druid Trainer"],
			classes = {
				DRUID = true,
			},
			faction = "Horde",
		},
		[58208780] = {
			name = L["Kary Thunderhorn"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Hunter Trainer"],
			classes = {
				HUNTER = true,
			},
			faction = "Horde",
		},
		[57408940] = {
			name = L["Holt Thunderhorn"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Hunter Trainer"],
			classes = {
				HUNTER = true,
			},
			faction = "Horde",
		},
		[58808660] = {
			name = L["Urek Thunderhorn"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Hunter Trainer"],
			classes = {
				HUNTER = true,
			},
			faction = "Horde",
		},
		[57608720] = {
			name = L["Torm Ragetotem"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warrior Trainer"],
			classes = {
				WARRIOR = true,
			},
			faction = "Horde",
		},
		[57208900] = {
			name = L["Sark Ragetotem"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warrior Trainer"],
			classes = {
				WARRIOR = true,
			},
			faction = "Horde",
		},
		[57808560] = {
			name = L["Ker Ragetotem"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warrior Trainer"],
			classes = {
				WARRIOR = true,
			},
			faction = "Horde",
		},
		[25401500] = {
			name = L["Miles Welsh"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Priest Trainer"],
			classes = {
				PRIEST = true,
			},
			faction = "Horde",
		},
		[24802260] = {
			name = L["Malakai Cross"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Priest Trainer"],
			classes = {
				PRIEST = true,
			},
			faction = "Horde",
		},
		[25402080] = {
			name = L["Father Cobb"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Priest Trainer"],
			classes = {
				PRIEST = true,
			},
			faction = "Horde",
		},
		[22601480] = {
			name = L["Archmage Shymm"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Mage Trainer"],
			classes = {
				MAGE = true,
			},
			faction = "Horde",
		},
		[25401440] = {
			name = L["Ursyn Ghull"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Mage Trainer"],
			classes = {
				MAGE = true,
			},
			faction = "Horde",
		},
		[25402120] = {
			name = L["Thurston Xane"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Mage Trainer"],
			classes = {
				MAGE = true,
			},
			faction = "Horde",
		},
		[22201720] = {
			name = L["Birgitte Cranston"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Portal Trainer"],
			classes = {
				MAGE = true,
			},
			faction = "Horde",
		},
		[44404260] = {
			name = L["Mooranta"],
			category = "primaryProfession",
			profession = "Skinning",
			description = L["Skinning Trainer"],
			faction = "Horde",
		},
		[54208360] = {
			name = L["Hesuwa Thunderhorn"],
			category = "trainers",
			description = L["Pet Trainer"],
			faction = "Horde",
		},
		[39205620] = {
			name = L["Thrag Stonehoof"],
			category = "primaryProfession",
			profession = "Blacksmith",
			description = L["Journeyman Blacksmith"],
			faction = "Horde",
		},
		[46803420] = {
			name = L["Kray"],
			category = "primaryProfession",
			profession = "Alchemy",
			description = L["Journeyman Alchemist"],
			faction = "Horde",
		},
		[44004440] = {
			name = L["Vhan"],
			category = "primaryProfession",
			profession = "Tailoring",
			description = L["Journeyman Tailor"],
			faction = "Horde",
		},
		[44803880] = {
			name = L["Mot Dawnstrider"],
			category = "primaryProfession",
			profession = "Enchanting",
			description = L["Journeyman Enchanter"],
			faction = "Horde",
		},
		[42404300] = {
			name = L["Tarn"],
			category = "primaryProfession",
			profession = "Leatherworking",
			description = L["Expert Leatherworker"],
			faction = "Horde",
		},
		[40806240] = {
			name = L["Ansekhwa"],
			category = "trainers",
			subcategory = "weaponmaster",
			description = L["Weapon Master"],
			faction = "Horde",
		},
		[34405700] = {
			name = L["Kurm Stonehoof"],
			category = "vendors",
			description = L["Mining Supplier"],
			faction = "Horde",
		},
		[41205340] = {
			name = L["Fyr Mistrunner"],
			category = "vendors",
			description = L["Bread Vendor"],
			faction = "Horde",
		},
		[43804460] = {
			name = L["Mahu"],
			category = "vendors",
			description = L["Leatherworking & Tailoring Supplies"],
			faction = "Horde",
		},
		[47203400] = {
			name = L["Mani Winterhoof"],
			category = "vendors",
			description = L["Alchemy Supplies"],
			faction = "Horde",
		},
		[45003880] = {
			name = L["Nata Dawnstrider"],
			category = "vendors",
			description = L["Enchanting Supplies"],
			faction = "Horde",
		},
		[49603940] = {
			name = L["Nida Winterhoof"],
			category = "vendors",
			description = L["Herbalism Supplier"],
			faction = "Horde",
		},
		[49003460] = {
			name = L["Tand"],
			category = "vendors",
			description = L["Basket Weaver"],
			faction = "Horde",
		},
		[47204220] = {
			name = L["Nan Mistrunner"],
			category = "vendors",
			description = L["Fruit Vendor"],
			faction = "Horde",
		},
		[52404820] = {
			name = L["Kaga Mistrunner"],
			category = "vendors",
			description = L["Meat Vendor"],
			faction = "Horde",
		},
		[51005285] = {
			name = L["Naal Mistrunner"],
			category = "vendors",
			description = L["Cooking Supplier"],
			faction = "Horde",
		},
		[56004700] = {
			name = L["Sewa Mistrunner"],
			category = "vendors",
			description = L["Fishing Supplier"],
			faction = "Horde",
		},
		[37406305] = {
			name = L["Thrumn"],
			category = "vendors",
			description = L["Tabard Vendor"],
			faction = "Horde",
		},
		[41605440] = {
			name = L["Chepi"],
			category = "vendors",
			subcategory = "reagentvendor",
			description = L["Reagent Vendor"],
			faction = "Horde",
		},
		[39006420] = {
			name = L["Kuruk"],
			category = "vendors",
			description = L["General Goods Vendor"],
			faction = "Horde",
		},
		[40406360] = {
			name = L["Shadi Mistrunner"],
			category = "vendors",
			description = L["Trade Goods Supplier"],
			faction = "Horde",
		},
		[39206380] = {
			name = L["Pakwa"],
			category = "vendors",
			description = L["Bag Vendor"],
			faction = "Horde",
		},
		[62205860] = {
			name = L["Halpa"],
			category = "vendors",
			description = L["Prairie Dog Vendor"],
			faction = "Neutral",
		},
		[70803380] = {
			name = L["Bashana Runetotem"],
			category = "vendors",
			faction = "Horde",
		},
	}
	nodes[1457] = {
		[56405220] = {
			name = L["Auctioneer Tolon"],
			category = "auctioneers",
			faction = "Alliance",
		},
		[56405380] = {
			name = L["Auctioneer Golothas"],
			category = "auctioneers",
			faction = "Alliance",
		},
		[55405280] = {
			name = L["Auctioneer Cazarez"],
			category = "auctioneers",
			faction = "Alliance",
		},
		[39804240] = {
			name = L["Idriana"],
			category = "bankers",
			description = L["Banker"],
			faction = "Alliance",
		},
		[40004180] = {
			name = L["Lairn"],
			category = "bankers",
			description = L["Banker"],
			faction = "Alliance",
		},
		[40004220] = {
			name = L["Garryeth"],
			category = "bankers",
			description = L["Banker"],
			faction = "Alliance",
		},
		[67201560] = {
			name = L["Innkeeper Saelienne"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Alliance",
		},
		[41404220] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Alliance",
		},
		[59004600] = {
			name = L["Cylania"],
			category = "repair",
			description = L["Night Elf Armorer"],
			faction = "Alliance",
		},
		[65406020] = {
			name = L["Merelyssa"],
			category = "repair",
			description = L["Blade Merchant"],
			faction = "Alliance",
		},
		[55609000] = {
			name = L["Anadyia"],
			category = "repair",
			description = L["Robe Vendor"],
			faction = "Alliance",
		},
		[63206660] = {
			name = L["Landria"],
			category = "repair",
			description = L["Bow Merchant"],
			faction = "Alliance",
		},
		[60007180] = {
			name = L["Vinasia"],
			category = "repair",
			description = L["Cloth Armor Merchant"],
			faction = "Alliance",
		},
		[57207720] = {
			name = L["Melea"],
			category = "repair",
			description = L["Mail Armor Merchant"],
			faction = "Alliance",
		},
		[58604480] = {
			name = L["Ariyell Skyshadow"],
			category = "repair",
			description = L["Weapon Merchant"],
			faction = "Alliance",
		},
		[65206000] = {
			name = L["Kieran"],
			category = "repair",
			description = L["Weapon Merchant"],
			faction = "Alliance",
		},
		[64005900] = {
			name = L["Glorandiir"],
			category = "repair",
			description = L["Axe Merchant"],
			faction = "Alliance",
		},
		[65006040] = {
			name = L["Mythidan"],
			category = "repair",
			description = L["Mace & Staff Merchant"],
			faction = "Alliance",
		},
		[56008900] = {
			name = L["Andrus"],
			category = "repair",
			description = L["Staff Merchant"],
			faction = "Alliance",
		},
		[62406560] = {
			name = L["Turian"],
			category = "repair",
			description = L["Thrown Weapons Merchant"],
			faction = "Alliance",
		},
		[53008000] = {
			name = L["Cyridan"],
			category = "repair",
			description = L["Leather Armor Merchant"],
			faction = "Alliance",
		},
		[56807620] = {
			name = L["Caynrus"],
			category = "repair",
			description = L["Shield Merchant"],
			faction = "Alliance",
		},
		[77002700] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[39400980] = {
			name = L["Alassin"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Alliance",
		},
		[58403520] = {
			name = L["Arias'ta Bladesinger"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warrior Trainer"],
			classes = {
				WARRIOR = true,
			},
			faction = "Alliance",
		},
		[61804180] = {
			name = L["Sildanair"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warrior Trainer"],
			classes = {
				WARRIOR = true,
			},
			faction = "Alliance",
		},
		[38408080] = {
			name = L["Astarii Starseeker"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Priest Trainer"],
			classes = {
				PRIEST = true,
			},
			faction = "Alliance",
		},
		[38008260] = {
			name = L["Jandria"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Priest Trainer"],
			classes = {
				PRIEST = true,
			},
			faction = "Alliance",
		},
		[40008740] = {
			name = L["Lariia"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Priest Trainer"],
			classes = {
				PRIEST = true,
			},
			faction = "Alliance",
		},
		[39600580] = {
			name = L["Jeen'ra Nightrunner"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Hunter Trainer"],
			classes = {
				HUNTER = true,
			},
			faction = "Alliance",
		},
		[40200880] = {
			name = L["Jocaste"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Hunter Trainer"],
			classes = {
				HUNTER = true,
			},
			faction = "Alliance",
		},
		[47605660] = {
			name = L["Astaia"],
			category = "secondaryProfession",
			profession = "Fishing",
			description = L["Fishing Trainer"],
			faction = "Alliance",
		},
		[63402220] = {
			name = L["Me'lynn"],
			category = "primaryProfession",
			profession = "Tailoring",
			description = L["Expert Tailor"],
			faction = "Alliance",
		},
		[55002400] = {
			name = L["Ainethil"],
			category = "primaryProfession",
			profession = "Alchemy",
			description = L["Artisan Alchemist"],
			faction = "Alliance",
		},
		[36802180] = {
			name = L["Syurna"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Rogue Trainer"],
			classes = {
				ROGUE = true,
			},
			faction = "Alliance",
		},
		[40408200] = {
			name = L["Elissa Dumas"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Portal Trainer"],
			classes = {
				MAGE = true,
			},
			faction = "Alliance",
		},
		[48006840] = {
			name = L["Firodren Mooncaller"],
			category = "primaryProfession",
			profession = "Herbalism",
			description = L["Herbalism Trainer"],
			faction = "Alliance",
		},
		[42200760] = {
			name = L["Dorion"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Hunter Trainer"],
			classes = {
				HUNTER = true,
			},
			faction = "Alliance",
		},
		[49002120] = {
			name = L["Alegorn"],
			category = "secondaryProfession",
			profession = "Cooking",
			description = L["Cooking Trainer"],
			faction = "Alliance",
		},
		[51601260] = {
			name = L["Dannelor"],
			category = "secondaryProfession",
			profession = "First Aid",
			description = L["First Aid Trainer"],
			faction = "Alliance",
		},
		[64402120] = {
			name = L["Telonis"],
			category = "primaryProfession",
			profession = "Leatherworking",
			description = L["Artisan Leatherworker"],
			faction = "Alliance",
		},
		[58601320] = {
			name = L["Taladan"],
			category = "primaryProfession",
			profession = "Enchanting",
			description = L["Expert Enchanter"],
			faction = "Alliance",
		},
		[34602560] = {
			name = L["Erion Shadewhisper"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Rogue Trainer"],
			classes = {
				ROGUE = true,
			},
			faction = "Alliance",
		},
		[37802140] = {
			name = L["Anishar"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Rogue Trainer"],
			classes = {
				ROGUE = true,
			},
			faction = "Neutral",
		},
		[35200800] = {
			name = L["Mathrengyl Bearwalker"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Druid Trainer"],
			classes = {
				DRUID = true,
			},
			faction = "Alliance",
		},
		[34800780] = {
			name = L["Denatharion"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Druid Trainer"],
			classes = {
				DRUID = true,
			},
			faction = "Alliance",
		},
		[33600860] = {
			name = L["Fylerian Nightwing"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Druid Trainer"],
			classes = {
				DRUID = true,
			},
			faction = "Alliance",
		},
		[38401580] = {
			name = L["Jartsam"],
			category = "trainers",
			description = L["Nightsaber Riding Instructor"],
			faction = "Alliance",
		},
		[64202180] = {
			name = L["Eladriel"],
			category = "primaryProfession",
			profession = "Skinning",
			description = L["Skinning Trainer"],
			faction = "Alliance",
		},
		[58603520] = {
			name = L["Darnath Bladesinger"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warrior Trainer"],
			classes = {
				WARRIOR = true,
			},
			faction = "Alliance",
		},
		[42200880] = {
			name = L["Silvaria"],
			category = "trainers",
			description = L["Pet Trainer"],
			faction = "Alliance",
		},
		[55402300] = {
			name = L["Milla Fairancora"],
			category = "primaryProfession",
			profession = "Alchemy",
			description = L["Journeyman Alchemist"],
			faction = "Alliance",
		},
		[56202420] = {
			name = L["Sylvanna Forestmoon"],
			category = "primaryProfession",
			profession = "Alchemy",
			description = L["Expert Alchemist"],
			faction = "Alliance",
		},
		[63602140] = {
			name = L["Trianna"],
			category = "primaryProfession",
			profession = "Tailoring",
			description = L["Journeyman Tailor"],
			faction = "Alliance",
		},
		[58801280] = {
			name = L["Lalina Summermoon"],
			category = "primaryProfession",
			profession = "Enchanting",
			description = L["Journeyman Enchanter"],
			faction = "Alliance",
		},
		[64602160] = {
			name = L["Faldron"],
			category = "primaryProfession",
			profession = "Leatherworking",
			description = L["Expert Leatherworker"],
			faction = "Alliance",
		},
		[64402100] = {
			name = L["Darianna"],
			category = "primaryProfession",
			profession = "Leatherworking",
			description = L["Journeyman Leatherworker"],
			faction = "Alliance",
		},
		[39208100] = {
			name = L["Priestess Alathea"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Priest Trainer"],
			classes = {
				PRIEST = true,
			},
			faction = "Alliance",
		},
		[57604640] = {
			name = L["Ilyenia Moonfire"],
			category = "trainers",
			subcategory = "weaponmaster",
			description = L["Weapon Master"],
			faction = "Alliance",
		},
		[32801960] = {
			name = L["Kyrai"],
			category = "vendors",
			subcategory = "poisonvendor",
			description = L["Poison Vendor"],
			faction = "Alliance",
		},
		[38604500] = {
			name = L["Alaindia"],
			category = "vendors",
			subcategory = "reagentvendor",
			description = L["Reagent Vendor"],
			faction = "Alliance",
		},
		[38202020] = {
			name = L["Dendrythis"],
			category = "vendors",
			description = L["Food & Drink Vendor"],
			faction = "Alliance",
		},
		[64402160] = {
			name = L["Elynna"],
			category = "vendors",
			description = L["Tailoring Supplies"],
			faction = "Alliance",
		},
		[62205800] = {
			name = L["Jaeana"],
			category = "vendors",
			description = L["Meat Vendor"],
			faction = "Alliance",
		},
		[64405300] = {
			name = L["Ellandrieth"],
			category = "vendors",
			description = L["General Goods Vendor"],
			faction = "Alliance",
		},
		[60607220] = {
			name = L["Ealyshia Dewwhisper"],
			category = "vendors",
			description = L["Two Handed Weapon Merchant"],
			faction = "Neutral",
		},
		[69404480] = {
			name = L["Fyrenna"],
			category = "vendors",
			description = L["Food & Drink Vendor"],
			faction = "Alliance",
		},
		[48206920] = {
			name = L["Chardryn"],
			category = "vendors",
			description = L["Herbalism Supplier"],
			faction = "Alliance",
		},
		[34000960] = {
			name = L["Cyroen"],
			category = "vendors",
			subcategory = "reagentvendor",
			description = L["Reagent Vendor"],
			faction = "Alliance",
		},
		[47405700] = {
			name = L["Talaelar"],
			category = "vendors",
			description = L["Fish Vendor"],
			faction = "Alliance",
		},
		[47005680] = {
			name = L["Voloren"],
			category = "vendors",
			description = L["Fishing Supplier"],
			faction = "Alliance",
		},
		[48602120] = {
			name = L["Fyldan"],
			category = "vendors",
			description = L["Cooking Supplier"],
			faction = "Alliance",
		},
		[63802200] = {
			name = L["Saenorion"],
			category = "vendors",
			description = L["Leatherworking Supplies"],
			faction = "Alliance",
		},
		[55802440] = {
			name = L["Ulthir"],
			category = "vendors",
			description = L["Alchemy Supplies"],
			faction = "Alliance",
		},
		[58601440] = {
			name = L["Vaean"],
			category = "vendors",
			description = L["Enchanting Supplies"],
			faction = "Alliance",
		},
		[61001800] = {
			name = L["Mythrin'dir"],
			category = "vendors",
			description = L["General Trade Supplier"],
			faction = "Alliance",
		},
		[65405300] = {
			name = L["Yldan"],
			category = "vendors",
			description = L["Bag Merchant"],
			faction = "Alliance",
		},
		[70404520] = {
			name = L["Mydrannul"],
			category = "vendors",
			description = L["General Goods Vendor"],
			faction = "Alliance",
		},
		[38201560] = {
			name = L["Lelanai"],
			category = "vendors",
			description = L["Saber Handler"],
			faction = "Alliance",
		},
		[70402320] = {
			name = L["Shalumon"],
			category = "vendors",
			description = L["Tabard Vendor"],
			faction = "Alliance",
		},
		[69604560] = {
			name = L["Shylenai"],
			category = "vendors",
			description = L["Owl Trainer"],
			faction = "Alliance",
		},
	}
	nodes[1458] = {
		[67805220] = {
			name = L["Auctioneer Leeka"],
			category = "auctioneers",
			faction = "Horde",
		},
		[64205220] = {
			name = L["Auctioneer Epitwee"],
			category = "auctioneers",
			faction = "Horde",
		},
		[71204700] = {
			name = L["Auctioneer Stockton"],
			category = "auctioneers",
			faction = "Horde",
		},
		[71404140] = {
			name = L["Auctioneer Yarly"],
			category = "auctioneers",
			faction = "Horde",
		},
		[67803600] = {
			name = L["Auctioneer Cain"],
			category = "auctioneers",
			faction = "Horde",
		},
		[64003600] = {
			name = L["Auctioneer Naxxremis"],
			category = "auctioneers",
			faction = "Horde",
		},
		[60604120] = {
			name = L["Auctioneer Tricket"],
			category = "auctioneers",
			faction = "Horde",
		},
		[60604680] = {
			name = L["Auctioneer Rhyker"],
			category = "auctioneers",
			faction = "Horde",
		},
		[66004300] = {
			name = L["Randolph Montague"],
			category = "bankers",
			description = L["Banker"],
			faction = "Horde",
		},
		[66604400] = {
			name = L["Mortimer Montague"],
			category = "bankers",
			description = L["Banker"],
			faction = "Horde",
		},
		[66004520] = {
			name = L["William Montague"],
			category = "bankers",
			description = L["Banker"],
			faction = "Horde",
		},
		[65204400] = {
			name = L["Ophelia Montague"],
			category = "bankers",
			description = L["Banker"],
			faction = "Horde",
		},
		[63404860] = {
			name = L["Michael Garrett"],
			category = "flightmasters",
			fpName = L["Undercity, Tirisfal"],
			description = L["Bat Handler"],
			faction = "Horde",
		},
		[69604440] = {
			name = L["Christopher Drakul"],
			category = "guildmasters",
			description = L["Guild Master"],
			faction = "Horde",
		},
		[67603800] = {
			name = L["Innkeeper Norman"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Horde",
		},
		[67903840] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Horde",
		},
		[61604180] = {
			name = L["Gordon Wendham"],
			category = "repair",
			description = L["Weapons Merchant"],
			faction = "Horde",
		},
		[61404120] = {
			name = L["Louis Warren"],
			category = "repair",
			description = L["Weapons Merchant"],
			faction = "Horde",
		},
		[64003800] = {
			name = L["Lauren Newcomb"],
			category = "repair",
			description = L["Light Armor Merchant"],
			faction = "Horde",
		},
		[62803980] = {
			name = L["Timothy Weldon"],
			category = "repair",
			description = L["Heavy Armor Merchant"],
			faction = "Horde",
		},
		[62603900] = {
			name = L["Walter Ellingson"],
			category = "repair",
			description = L["Heavy Armor Merchant"],
			faction = "Horde",
		},
		[77005000] = {
			name = L["Charles Seaton"],
			category = "repair",
			description = L["Blade Merchant"],
			faction = "Horde",
		},
		[69802740] = {
			name = L["Sydney Upton"],
			category = "repair",
			description = L["Staff Merchant"],
			faction = "Horde",
		},
		[71002920] = {
			name = L["Lucille Castleton"],
			category = "repair",
			description = L["Robe Vendor"],
			faction = "Horde",
		},
		[77205020] = {
			name = L["Nathaniel Steenwick"],
			category = "repair",
			description = L["Thrown Weapons Merchant"],
			faction = "Horde",
		},
		[61402940] = {
			name = L["Samuel Van Brunt"],
			category = "repair",
			description = L["Blacksmithing Supplier"],
			faction = "Horde",
		},
		[58403260] = {
			name = L["Geoffrey Hartwell"],
			category = "repair",
			description = L["Weapon Merchant"],
			faction = "Horde",
		},
		[58603240] = {
			name = L["Francis Eliot"],
			category = "repair",
			description = L["Weapon Merchant"],
			faction = "Horde",
		},
		[58403240] = {
			name = L["Benijah Fenner"],
			category = "repair",
			description = L["Weapon Merchant"],
			faction = "Horde",
		},
		[62202700] = {
			name = L["Nicholas Atwood"],
			category = "repair",
			description = L["Gun Merchant"],
			faction = "Horde",
		},
		[54803800] = {
			name = L["Abigail Sawyer"],
			category = "repair",
			description = L["Bow Merchant"],
			faction = "Horde",
		},
		[70002720] = {
			name = L["Zane Bradford"],
			category = "repair",
			description = L["Wand Vendor"],
			faction = "Horde",
		},
		[61402860] = {
			name = L["Mirelle Tremayne"],
			category = "repair",
			description = L["Heavy Armor Merchant"],
			faction = "Horde",
		},
		[70405880] = {
			name = L["Gillian Moore"],
			category = "repair",
			description = L["Leather Armor Merchant"],
			faction = "Horde",
		},
		[70402920] = {
			name = L["Sheldon Von Croy"],
			category = "repair",
			description = L["Cloth Armor Merchant"],
			faction = "Horde",
		},
		[67801440] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[67403800] = {
			name = L["Anya Maulray"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Horde",
		},
		[70605880] = {
			name = L["Dan Golthas"],
			category = "primaryProfession",
			profession = "Leatherworking",
			description = L["Journeyman Leatherworker"],
			faction = "Horde",
		},
		[84201600] = {
			name = L["Lexington Mortaim"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Portal Trainer"],
			classes = {
				MAGE = true,
			},
			faction = "Horde",
		},
		[62204460] = {
			name = L["Eunice Burch"],
			category = "secondaryProfession",
			profession = "Cooking",
			description = L["Cooking Trainer"],
			faction = "Horde",
		},
		[86001560] = {
			name = L["Kaal Soulreaper"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warlock Trainer"],
			classes = {
				WARLOCK = true,
			},
			faction = "Horde",
		},
		[86201520] = {
			name = L["Luther Pickman"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warlock Trainer"],
			classes = {
				WARLOCK = true,
			},
			faction = "Horde",
		},
		[88601600] = {
			name = L["Richard Kerwin"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warlock Trainer"],
			classes = {
				WARLOCK = true,
			},
			faction = "Horde",
		},
		[85201420] = {
			name = L["Kaelystia Hatebringer"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Mage Trainer"],
			classes = {
				MAGE = true,
			},
			faction = "Horde",
		},
		[85401380] = {
			name = L["Pierce Shackleton"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Mage Trainer"],
			classes = {
				MAGE = true,
			},
			faction = "Horde",
		},
		[85001020] = {
			name = L["Anastasia Hartwell"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Mage Trainer"],
			classes = {
				MAGE = true,
			},
			faction = "Horde",
		},
		[80803120] = {
			name = L["Armand Cromwell"],
			category = "secondaryProfession",
			profession = "Fishing",
			description = L["Fishing Trainer"],
			faction = "Horde",
		},
		[70603040] = {
			name = L["Josef Gregorian"],
			category = "primaryProfession",
			profession = "Tailoring",
			description = L["Artisan Tailor"],
			faction = "Horde",
		},
		[86402220] = {
			name = L["Josephine Lister"],
			category = "primaryProfession",
			profession = "Tailoring",
			description = L["Master Shadoweave Tailor"],
			faction = "Horde",
		},
		[83807180] = {
			name = L["Carolyn Ward"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Rogue Trainer"],
			classes = {
				ROGUE = true,
			},
			faction = "Horde",
		},
		[84807160] = {
			name = L["Miles Dexter"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Rogue Trainer"],
			classes = {
				ROGUE = true,
			},
			faction = "Horde",
		},
		[84607320] = {
			name = L["Gregory Charles"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Rogue Trainer"],
			classes = {
				ROGUE = true,
			},
			faction = "Horde",
		},
		[75607320] = {
			name = L["Graham Van Talen"],
			category = "primaryProfession",
			profession = "Engineering",
			description = L["Journeyman Engineer"],
			faction = "Horde",
		},
		[70405780] = {
			name = L["Arthur Moore"],
			category = "primaryProfession",
			profession = "Leatherworking",
			description = L["Expert Leatherworker"],
			faction = "Horde",
		},
		[73405560] = {
			name = L["Mary Edras"],
			category = "secondaryProfession",
			profession = "First Aid",
			description = L["First Aid Trainer"],
			faction = "Horde",
		},
		[47001540] = {
			name = L["Christoph Walker"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warrior Trainer"],
			classes = {
				WARRIOR = true,
			},
			faction = "Horde",
		},
		[48201560] = {
			name = L["Angela Curthas"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warrior Trainer"],
			classes = {
				WARRIOR = true,
			},
			faction = "Horde",
		},
		[47401700] = {
			name = L["Baltus Fowler"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warrior Trainer"],
			classes = {
				WARRIOR = true,
			},
			faction = "Horde",
		},
		[61002980] = {
			name = L["James Van Brunt"],
			category = "primaryProfession",
			profession = "Blacksmith",
			description = L["Expert Blacksmith"],
			faction = "Horde",
		},
		[56003700] = {
			name = L["Brom Killian"],
			category = "primaryProfession",
			profession = "Mining",
			description = L["Mining Trainer"],
			faction = "Horde",
		},
		[60002860] = {
			name = L["Basil Frye"],
			category = "primaryProfession",
			profession = "Blacksmith",
			description = L["Journeyman Blacksmith"],
			faction = "Horde",
		},
		[49201820] = {
			name = L["Aelthalyste"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Priest Trainer"],
			classes = {
				PRIEST = true,
			},
			faction = "Horde",
		},
		[49601560] = {
			name = L["Father Lankester"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Priest Trainer"],
			classes = {
				PRIEST = true,
			},
			faction = "Horde",
		},
		[47401920] = {
			name = L["Father Lazarus"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Priest Trainer"],
			classes = {
				PRIEST = true,
			},
			faction = "Horde",
		},
		[51407420] = {
			name = L["Doctor Marsh"],
			category = "primaryProfession",
			profession = "Alchemy",
			description = L["Expert Alchemist"],
			faction = "Horde",
		},
		[47607300] = {
			name = L["Doctor Herbert Halsey"],
			category = "primaryProfession",
			profession = "Alchemy",
			description = L["Artisan Alchemist"],
			faction = "Horde",
		},
		[54204980] = {
			name = L["Martha Alliestar"],
			category = "primaryProfession",
			profession = "Herbalism",
			description = L["Herbalism Trainer"],
			faction = "Horde",
		},
		[62206160] = {
			name = L["Lavinia Crowe"],
			category = "primaryProfession",
			profession = "Enchanting",
			description = L["Expert Enchanter"],
			faction = "Horde",
		},
		[70405920] = {
			name = L["Killian Hagey"],
			category = "primaryProfession",
			profession = "Skinning",
			description = L["Skinning Trainer"],
			faction = "Horde",
		},
		[75807380] = {
			name = L["Franklin Lloyd"],
			category = "primaryProfession",
			profession = "Engineering",
			description = L["Expert Engineer"],
			faction = "Horde",
		},
		[46607440] = {
			name = L["Doctor Martin Felben"],
			category = "primaryProfession",
			profession = "Alchemy",
			description = L["Journeyman Alchemist Trainer"],
			faction = "Horde",
		},
		[70202960] = {
			name = L["Victor Ward"],
			category = "primaryProfession",
			profession = "Tailoring",
			description = L["Journeyman Tailor"],
			faction = "Horde",
		},
		[70203020] = {
			name = L["Rhiannon Davis"],
			category = "primaryProfession",
			profession = "Tailoring",
			description = L["Expert Tailor"],
			faction = "Horde",
		},
		[62206020] = {
			name = L["Malcomb Wynn"],
			category = "primaryProfession",
			profession = "Enchanting",
			description = L["Journeyman Enchanter"],
			faction = "Horde",
		},
		[57203260] = {
			name = L["Archibald"],
			category = "trainers",
			subcategory = "weaponmaster",
			description = L["Weapon Master"],
			faction = "Horde",
		},
		[62404340] = {
			name = L["Ronald Burch"],
			category = "vendors",
			description = L["Cooking Supplier"],
			faction = "Horde",
		},
		[65804960] = {
			name = L["Tawny Grisette"],
			category = "vendors",
			description = L["Mushroom Vendor"],
			faction = "Horde",
		},
		[69004840] = {
			name = L["Eleanor Rusk"],
			category = "vendors",
			description = L["General Goods Vendor"],
			faction = "Horde",
		},
		[64203780] = {
			name = L["Daniel Bartlett"],
			category = "vendors",
			description = L["General Trade Supplier"],
			faction = "Horde",
		},
		[69403920] = {
			name = L["Thomas Mordan"],
			category = "vendors",
			subcategory = "reagentvendor",
			description = L["Reagent Vendor"],
			faction = "Horde",
		},
		[77003040] = {
			name = L["Morley Bates"],
			category = "vendors",
			description = L["Fungus Vendor"],
			faction = "Horde",
		},
		[81203080] = {
			name = L["Lizbeth Cromwell"],
			category = "vendors",
			description = L["Fishing Supplier"],
			faction = "Horde",
		},
		[82601600] = {
			name = L["Hannah Akeley"],
			category = "vendors",
			description = L["Reagent Supplier"],
			faction = "Horde",
		},
		[70403020] = {
			name = L["Millie Gregorian"],
			category = "vendors",
			description = L["Tailoring Supplies"],
			faction = "Horde",
		},
		[77203860] = {
			name = L["Salazar Bloch"],
			category = "vendors",
			description = L["Book Dealer"],
			faction = "Horde",
		},
		[75405140] = {
			name = L["Ezekiel Graves"],
			category = "vendors",
			subcategory = "poisonvendor",
			description = L["Poison Vendor"],
			faction = "Horde",
		},
		[75807385] = {
			name = L["Elizabeth Van Talen"],
			category = "vendors",
			description = L["Engineering Supplier"],
			faction = "Horde",
		},
		[70405885] = {
			name = L["Joseph Moore"],
			category = "vendors",
			description = L["Leatherworking Supplies"],
			faction = "Horde",
		},
		[69606100] = {
			name = L["Jonathan Chambers"],
			category = "vendors",
			description = L["Bag Vendor"],
			faction = "Horde",
		},
		[56203680] = {
			name = L["Sarah Killian"],
			category = "vendors",
			description = L["Mining Supplier"],
			faction = "Horde",
		},
		[51807440] = {
			name = L["Algernon"],
			category = "vendors",
			description = L["Alchemy Supplies"],
			faction = "Horde",
		},
		[54604940] = {
			name = L["Katrina Alliestar"],
			category = "vendors",
			description = L["Herbalism Supplier"],
			faction = "Horde",
		},
		[62006080] = {
			name = L["Thaddeus Webb"],
			category = "vendors",
			description = L["Enchanting Supplies"],
			faction = "Horde",
		},
		[64205020] = {
			name = L["Felicia Doan"],
			category = "vendors",
			description = L["General Trade Goods Vendor"],
			faction = "Horde",
		},
		[69204440] = {
			name = L["Merill Pleasance"],
			category = "vendors",
			description = L["Tabard Vendor"],
			faction = "Horde",
		},
		[85601580] = {
			name = L["Martha Strain"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Demon Trainer"],
			classes = {
				WARLOCK = true,
			},
			faction = "Horde",
		},
		[58205520] = {
			name = L["Alessandro Luca"],
			category = "vendors",
			description = L["Blue Moon Odds and Ends"],
			faction = "Horde",
		},
		[67404440] = {
			name = L["Jeremiah Payson"],
			category = "vendors",
			description = L["Cockroach Vendor"],
			faction = "Horde",
		},
	}
	nodes[1413] = {
		[62603740] = {
			name = L["Fuzruckle"],
			category = "bankers",
			description = L["Banker"],
			faction = "Neutral",
		},
		[62603745] = {
			name = L["Zikkel"],
			category = "bankers",
			description = L["Banker"],
			faction = "Neutral",
		},
		[44405900] = {
			name = L["Omusa Thunderhorn"],
			category = "flightmasters",
			fpName = L["Camp Taurajo, The Barrens"],
			description = L["Wind Rider Master"],
			faction = "Horde",
		},
		[63003700] = {
			name = L["Bragok"],
			category = "flightmasters",
			fpName = L["Ratchet, The Barrens"],
			description = L["Flight Master"],
			faction = "Neutral",
		},
		[52002980] = {
			name = L["Innkeeper Boorand Plainswind"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Horde",
		},
		[62003940] = {
			name = L["Innkeeper Wiley"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Neutral",
		},
		[45605900] = {
			name = L["Innkeeper Byula"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Horde",
		},
		[45105870] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Horde",
		},
		[52003040] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Horde",
		},
		[62203920] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Neutral",
		},
		[51002900] = {
			name = L["Hraq"],
			category = "repair",
			description = L["Blacksmithing Supplier"],
			faction = "Horde",
		},
		[51202920] = {
			name = L["Nargal Deatheye"],
			category = "repair",
			description = L["Weaponsmith"],
			faction = "Horde",
		},
		[51202900] = {
			name = L["Jahan Hawkwing"],
			category = "repair",
			description = L["Leather & Mail Armor Merchant"],
			faction = "Horde",
		},
		[52203180] = {
			name = L["Halija Whitestrider"],
			category = "repair",
			description = L["Clothier"],
			faction = "Horde",
		},
		[51002905] = {
			name = L["Uthrok"],
			category = "vendors",
			description = L["Bowyer & Gunsmith"],
			faction = "Horde",
		},
		[62203740] = {
			name = L["Ironzar"],
			category = "repair",
			description = L["Weaponsmith"],
			faction = "Neutral",
		},
		[62203840] = {
			name = L["Vexspindle"],
			category = "repair",
			description = L["Cloth & Leather Armor Merchant"],
			faction = "Neutral",
		},
		[62203845] = {
			name = L["Grazlix"],
			category = "vendors",
			description = L["Armorer & Shieldcrafter"],
			faction = "Neutral",
		},
		[52403060] = {
			name = L["Lizzarik"],
			category = "repair",
			description = L["Weapon Dealer"],
			faction = "Neutral",
		},
		[43801220] = {
			name = L["Vrang Wildgore"],
			category = "repair",
			description = L["Weaponsmith & Armorcrafter"],
			faction = "Horde",
		},
		[41803860] = {
			name = L["Kiknikle"],
			category = "repair",
			description = L["Stylish Clothier"],
			faction = "Horde",
		},
		[41803865] = {
			name = L["Pizznukle"],
			category = "vendors",
			description = L["Leather Armor Merchant"],
			faction = "Horde",
		},
		[45005900] = {
			name = L["Sanuye Runetotem"],
			category = "repair",
			description = L["Leather Armor Merchant"],
			faction = "Horde",
		},
		[46600840] = {
			name = L["Kelm Hargunth"],
			category = "repair",
			description = L["Warsong Supply Officer"],
			faction = "Horde",
		},
		[45206100] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[50603260] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[60203980] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[51602960] = {
			name = L["Sikwa"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Horde",
		},
		[45205860] = {
			name = L["Kelsuwa"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Horde",
		},
		[62203925] = {
			name = L["Reggifuz"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Neutral",
		},
		[51202880] = {
			name = L["Traugh"],
			category = "primaryProfession",
			profession = "Blacksmith",
			description = L["Expert Blacksmith"],
			faction = "Horde",
		},
		[52203160] = {
			name = L["Kil'hala"],
			category = "primaryProfession",
			profession = "Tailoring",
			description = L["Journeyman Tailor"],
			faction = "Horde",
		},
		[62603620] = {
			name = L["Tinkerwiz"],
			category = "primaryProfession",
			profession = "Engineering",
			description = L["Journeyman Engineer"],
			faction = "Neutral",
		},
		[44805940] = {
			name = L["Krulmoo Fullmoon"],
			category = "primaryProfession",
			profession = "Leatherworking",
			description = L["Expert Leatherworker"],
			faction = "Horde",
		},
		[44805945] = {
			name = L["Gahroot"],
			category = "vendors",
			description = L["Butcher"],
			faction = "Horde",
		},
		[45005905] = {
			name = L["Dranh"],
			category = "primaryProfession",
			profession = "Skinning",
			description = L["Skinner"],
			faction = "Horde",
		},
		[55203180] = {
			name = L["Duhng"],
			category = "secondaryProfession",
			profession = "Cooking",
			description = L["Cook"],
			faction = "Horde",
		},
		[52203060] = {
			name = L["Moorane Hearthgrain"],
			category = "vendors",
			description = L["Baker"],
			faction = "Horde",
		},
		[51603000] = {
			name = L["Barg"],
			category = "vendors",
			description = L["General Supplies"],
			faction = "Horde",
		},
		[51603005] = {
			name = L["Tari'qa"],
			category = "vendors",
			description = L["Trade Supplies"],
			faction = "Horde",
		},
		[52203165] = {
			name = L["Wrahk"],
			category = "vendors",
			description = L["Tailoring Supplies"],
			faction = "Horde",
		},
		[52203200] = {
			name = L["Kalyimah Stormcloud"],
			category = "vendors",
			description = L["Bags & Sacks"],
			faction = "Horde",
		},
		[52602980] = {
			name = L["Zargh"],
			category = "vendors",
			description = L["Butcher"],
			faction = "Horde",
		},
		[51403020] = {
			name = L["Hula'mahi"],
			category = "vendors",
			description = L["Reagents and Herbs"],
			faction = "Horde",
		},
		[62603625] = {
			name = L["Gagsprocket"],
			category = "vendors",
			description = L["Engineering Goods"],
			faction = "Neutral",
		},
		[62803820] = {
			name = L["Kilxx"],
			category = "secondaryProfession",
			profession = "Fishing",
			description = L["Fisherman"],
			faction = "Neutral",
		},
		[61803880] = {
			name = L["Jazzik"],
			category = "vendors",
			description = L["General Supplies"],
			faction = "Neutral",
		},
		[61803860] = {
			name = L["Ranik"],
			category = "vendors",
			description = L["Trade Supplies"],
			faction = "Neutral",
		},
		[62003900] = {
			name = L["Zizzek"],
			category = "secondaryProfession",
			profession = "Fishing",
			description = L["Fisherman"],
			faction = "Neutral",
		},
		[52002960] = {
			name = L["Larhka"],
			category = "vendors",
			description = L["Beverage Merchant"],
			faction = "Horde",
		},
		[45005920] = {
			name = L["Yonada"],
			category = "vendors",
			description = L["Tailoring & Leatherworking Supplies"],
			faction = "Horde",
		},
		[55003200] = {
			name = L["Tarban Hearthgrain"],
			category = "vendors",
			description = L["Baker"],
			faction = "Horde",
		},
		[46600845] = {
			name = L["Hecht Copperpinch"],
			category = "vendors",
			description = L["Smokywood Pastures"],
			faction = "Horde",
		},
		[44206940] = {
			name = L["Silithid Harvester"],
			category = "rares",
			faction = "Neutral",
		},
		[44406960] = {
			name = L["Silithid Harvester"],
			category = "rares",
			faction = "Neutral",
		},
		[44607200] = {
			name = L["Silithid Harvester"],
			category = "rares",
			faction = "Neutral",
		},
		[44807280] = {
			name = L["Silithid Harvester"],
			category = "rares",
			faction = "Neutral",
		},
		[47607040] = {
			name = L["Silithid Harvester"],
			category = "rares",
			faction = "Neutral",
		},
		[47807100] = {
			name = L["Silithid Harvester"],
			category = "rares",
			faction = "Neutral",
		},
		[56402360] = {
			name = L["Elder Mystic Razorsnout"],
			category = "rares",
			faction = "Neutral",
		},
		[57202360] = {
			name = L["Elder Mystic Razorsnout"],
			category = "rares",
			faction = "Neutral",
		},
		[57602400] = {
			name = L["Elder Mystic Razorsnout"],
			category = "rares",
			faction = "Neutral",
		},
		[58002680] = {
			name = L["Elder Mystic Razorsnout"],
			category = "rares",
			faction = "Neutral",
		},
		[58202620] = {
			name = L["Elder Mystic Razorsnout"],
			category = "rares",
			faction = "Neutral",
		},
		[58402480] = {
			name = L["Elder Mystic Razorsnout"],
			category = "rares",
			faction = "Neutral",
		},
		[58602720] = {
			name = L["Elder Mystic Razorsnout"],
			category = "rares",
			faction = "Neutral",
		},
		[59002440] = {
			name = L["Elder Mystic Razorsnout"],
			category = "rares",
			faction = "Neutral",
		},
		[59002460] = {
			name = L["Elder Mystic Razorsnout"],
			category = "rares",
			faction = "Neutral",
		},
		[59202580] = {
			name = L["Elder Mystic Razorsnout"],
			category = "rares",
			faction = "Neutral",
		},
		[59602500] = {
			name = L["Elder Mystic Razorsnout"],
			category = "rares",
			faction = "Neutral",
		},
		[59602580] = {
			name = L["Elder Mystic Razorsnout"],
			category = "rares",
			faction = "Neutral",
		},
		[56600800] = {
			name = L["Sludge Beast"],
			category = "rares",
			faction = "Neutral",
		},
		[46203960] = {
			name = L["Gesharahan"],
			category = "rares",
			faction = "Neutral",
		},
		[46403820] = {
			name = L["Gesharahan"],
			category = "rares",
			faction = "Neutral",
		},
		[46403920] = {
			name = L["Gesharahan"],
			category = "rares",
			faction = "Neutral",
		},
		[46603900] = {
			name = L["Gesharahan"],
			category = "rares",
			faction = "Neutral",
		},
		[46603980] = {
			name = L["Gesharahan"],
			category = "rares",
			faction = "Neutral",
		},
		[47403840] = {
			name = L["Gesharahan"],
			category = "rares",
			faction = "Neutral",
		},
		[47601920] = {
			name = L["Rathorian"],
			category = "rares",
			faction = "Neutral",
		},
		[45005840] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[45206460] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[45406340] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[45406400] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[45406580] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[45604140] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[45605820] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46004260] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46004840] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46006240] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46006820] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46006920] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46007040] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46007160] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46007460] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46206740] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46207120] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46406280] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46407260] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46604640] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46605820] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46606880] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46607080] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46806600] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[47008080] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[47206180] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[47206540] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[47207520] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[47406260] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[47407400] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[47407620] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[47607400] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[47805920] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[47806100] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[47806420] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[48206340] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[48405040] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[48405160] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[48405720] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[48607720] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[48607960] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[48805240] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[48805740] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[48806240] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[49205320] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[49404780] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[49405520] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[49407820] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[50006100] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[50204300] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[50204680] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[45406380] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[45606540] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[45804080] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[45806640] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[45806680] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[45806780] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[45807160] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46004265] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Alliance",
		},
		[46006245] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46006925] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Alliance",
		},
		[46007020] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46007465] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46207125] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46406260] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46604645] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46607780] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46608040] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46806560] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46806880] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[47004300] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[47006160] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[47008085] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Alliance",
		},
		[47206520] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[47406120] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[47407405] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Alliance",
		},
		[47407625] = {
			name = L["Hannah Bladeleaf"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[47607405] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[48205220] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[48206345] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Alliance",
		},
		[48207620] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[48407840] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[48605180] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[48805700] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[49007920] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[49205325] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[49405525] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[49604320] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[45206540] = {
			name = L["Hannah Bladeleaf"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[45406405] = {
			name = L["Hannah Bladeleaf"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[45804085] = {
			name = L["Hannah Bladeleaf"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[45804820] = {
			name = L["Hannah Bladeleaf"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[45806820] = {
			name = L["Hannah Bladeleaf"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46006220] = {
			name = L["Hannah Bladeleaf"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46007025] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Alliance",
		},
		[46007100] = {
			name = L["Hannah Bladeleaf"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46007440] = {
			name = L["Hannah Bladeleaf"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46206620] = {
			name = L["Hannah Bladeleaf"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46207180] = {
			name = L["Hannah Bladeleaf"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46406680] = {
			name = L["Hannah Bladeleaf"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46407280] = {
			name = L["Hannah Bladeleaf"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46607060] = {
			name = L["Hannah Bladeleaf"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[47206240] = {
			name = L["Hannah Bladeleaf"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[47806105] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Alliance",
		},
		[48006420] = {
			name = L["Hannah Bladeleaf"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[48205225] = {
			name = L["Hannah Bladeleaf"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[48606240] = {
			name = L["Hannah Bladeleaf"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[48607965] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Alliance",
		},
		[48805720] = {
			name = L["Hannah Bladeleaf"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[49405320] = {
			name = L["Hannah Bladeleaf"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[49405500] = {
			name = L["Hannah Bladeleaf"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[50204320] = {
			name = L["Hannah Bladeleaf"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[45204100] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[45206545] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Alliance",
		},
		[46004060] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46006640] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46006825] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Alliance",
		},
		[46007105] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Alliance",
		},
		[46007165] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Alliance",
		},
		[46204880] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46206220] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46404640] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46406300] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46406700] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46407340] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46608020] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[47004305] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Alliance",
		},
		[47006580] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[47607420] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[47806425] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Alliance",
		},
		[48207680] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[48405220] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[49005260] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[49205240] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[49205380] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[49405505] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Alliance",
		},
		[50004640] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[50204280] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[44407500] = {
			name = L["Brontus"],
			category = "rares",
			faction = "Neutral",
		},
		[44407980] = {
			name = L["Brontus"],
			category = "rares",
			faction = "Neutral",
		},
		[44607960] = {
			name = L["Brontus"],
			category = "rares",
			faction = "Neutral",
		},
		[44807360] = {
			name = L["Brontus"],
			category = "rares",
			faction = "Neutral",
		},
		[45007640] = {
			name = L["Brontus"],
			category = "rares",
			faction = "Neutral",
		},
		[45007940] = {
			name = L["Brontus"],
			category = "rares",
			faction = "Neutral",
		},
		[45607920] = {
			name = L["Brontus"],
			category = "rares",
			faction = "Neutral",
		},
		[45807820] = {
			name = L["Brontus"],
			category = "rares",
			faction = "Neutral",
		},
		[46007280] = {
			name = L["Brontus"],
			category = "rares",
			faction = "Neutral",
		},
		[46206980] = {
			name = L["Brontus"],
			category = "rares",
			faction = "Neutral",
		},
		[46207140] = {
			name = L["Brontus"],
			category = "rares",
			faction = "Neutral",
		},
		[46207200] = {
			name = L["Brontus"],
			category = "rares",
			faction = "Neutral",
		},
		[46606920] = {
			name = L["Brontus"],
			category = "rares",
			faction = "Neutral",
		},
		[46607160] = {
			name = L["Brontus"],
			category = "rares",
			faction = "Neutral",
		},
		[47006960] = {
			name = L["Brontus"],
			category = "rares",
			faction = "Neutral",
		},
		[47406540] = {
			name = L["Brontus"],
			category = "rares",
			faction = "Neutral",
		},
		[47406620] = {
			name = L["Brontus"],
			category = "rares",
			faction = "Neutral",
		},
		[47606460] = {
			name = L["Brontus"],
			category = "rares",
			faction = "Neutral",
		},
		[48206440] = {
			name = L["Brontus"],
			category = "rares",
			faction = "Neutral",
		},
		[48406000] = {
			name = L["Brontus"],
			category = "rares",
			faction = "Neutral",
		},
		[48406160] = {
			name = L["Brontus"],
			category = "rares",
			faction = "Neutral",
		},
		[48605720] = {
			name = L["Brontus"],
			category = "rares",
			faction = "Neutral",
		},
		[48606080] = {
			name = L["Brontus"],
			category = "rares",
			faction = "Neutral",
		},
		[48806040] = {
			name = L["Brontus"],
			category = "rares",
			faction = "Neutral",
		},
		[62203380] = {
			name = L["Humar the Pridelord"],
			category = "rares",
			faction = "Neutral",
		},
		[40202320] = {
			name = L["Snort the Heckler"],
			category = "rares",
			faction = "Neutral",
		},
		[40402400] = {
			name = L["Snort the Heckler"],
			category = "rares",
			faction = "Neutral",
		},
		[40602280] = {
			name = L["Snort the Heckler"],
			category = "rares",
			faction = "Neutral",
		},
		[40602420] = {
			name = L["Snort the Heckler"],
			category = "rares",
			faction = "Neutral",
		},
		[40802180] = {
			name = L["Snort the Heckler"],
			category = "rares",
			faction = "Neutral",
		},
		[41002760] = {
			name = L["Snort the Heckler"],
			category = "rares",
			faction = "Neutral",
		},
		[41202120] = {
			name = L["Snort the Heckler"],
			category = "rares",
			faction = "Neutral",
		},
		[41202700] = {
			name = L["Snort the Heckler"],
			category = "rares",
			faction = "Neutral",
		},
		[41602600] = {
			name = L["Snort the Heckler"],
			category = "rares",
			faction = "Neutral",
		},
		[41802160] = {
			name = L["Snort the Heckler"],
			category = "rares",
			faction = "Neutral",
		},
		[41802260] = {
			name = L["Snort the Heckler"],
			category = "rares",
			faction = "Neutral",
		},
		[42402120] = {
			name = L["Snort the Heckler"],
			category = "rares",
			faction = "Neutral",
		},
		[37801560] = {
			name = L["Sister Rathtalon"],
			category = "rares",
			faction = "Neutral",
		},
		[38201500] = {
			name = L["Sister Rathtalon"],
			category = "rares",
			faction = "Neutral",
		},
		[38401660] = {
			name = L["Sister Rathtalon"],
			category = "rares",
			faction = "Neutral",
		},
		[38601460] = {
			name = L["Sister Rathtalon"],
			category = "rares",
			faction = "Neutral",
		},
		[39001620] = {
			name = L["Sister Rathtalon"],
			category = "rares",
			faction = "Neutral",
		},
		[39201380] = {
			name = L["Sister Rathtalon"],
			category = "rares",
			faction = "Neutral",
		},
		[39201680] = {
			name = L["Sister Rathtalon"],
			category = "rares",
			faction = "Neutral",
		},
		[39401220] = {
			name = L["Sister Rathtalon"],
			category = "rares",
			faction = "Neutral",
		},
		[39401320] = {
			name = L["Sister Rathtalon"],
			category = "rares",
			faction = "Neutral",
		},
		[39601260] = {
			name = L["Sister Rathtalon"],
			category = "rares",
			faction = "Neutral",
		},
		[39601380] = {
			name = L["Sister Rathtalon"],
			category = "rares",
			faction = "Neutral",
		},
		[39601720] = {
			name = L["Sister Rathtalon"],
			category = "rares",
			faction = "Neutral",
		},
		[39801640] = {
			name = L["Sister Rathtalon"],
			category = "rares",
			faction = "Neutral",
		},
		[40401520] = {
			name = L["Sister Rathtalon"],
			category = "rares",
			faction = "Neutral",
		},
		[40601660] = {
			name = L["Sister Rathtalon"],
			category = "rares",
			faction = "Neutral",
		},
		[40601780] = {
			name = L["Sister Rathtalon"],
			category = "rares",
			faction = "Neutral",
		},
		[40801560] = {
			name = L["Sister Rathtalon"],
			category = "rares",
			faction = "Neutral",
		},
		[59203260] = {
			name = L["Swiftmane"],
			category = "rares",
			faction = "Neutral",
		},
		[59803120] = {
			name = L["Swiftmane"],
			category = "rares",
			faction = "Neutral",
		},
		[60003280] = {
			name = L["Swiftmane"],
			category = "rares",
			faction = "Neutral",
		},
		[60203020] = {
			name = L["Swiftmane"],
			category = "rares",
			faction = "Neutral",
		},
		[60203180] = {
			name = L["Swiftmane"],
			category = "rares",
			faction = "Neutral",
		},
		[60403420] = {
			name = L["Swiftmane"],
			category = "rares",
			faction = "Neutral",
		},
		[60603180] = {
			name = L["Swiftmane"],
			category = "rares",
			faction = "Neutral",
		},
		[60803300] = {
			name = L["Swiftmane"],
			category = "rares",
			faction = "Neutral",
		},
		[61202960] = {
			name = L["Swiftmane"],
			category = "rares",
			faction = "Neutral",
		},
		[61203080] = {
			name = L["Swiftmane"],
			category = "rares",
			faction = "Neutral",
		},
		[61203460] = {
			name = L["Swiftmane"],
			category = "rares",
			faction = "Neutral",
		},
		[61403380] = {
			name = L["Swiftmane"],
			category = "rares",
			faction = "Neutral",
		},
		[46807780] = {
			name = L["Thunderstomp"],
			category = "rares",
			faction = "Neutral",
		},
		[46807880] = {
			name = L["Thunderstomp"],
			category = "rares",
			faction = "Neutral",
		},
		[47007680] = {
			name = L["Thunderstomp"],
			category = "rares",
			faction = "Neutral",
		},
		[47008020] = {
			name = L["Thunderstomp"],
			category = "rares",
			faction = "Neutral",
		},
		[47208140] = {
			name = L["Thunderstomp"],
			category = "rares",
			faction = "Neutral",
		},
		[47208160] = {
			name = L["Thunderstomp"],
			category = "rares",
			faction = "Neutral",
		},
		[48007940] = {
			name = L["Thunderstomp"],
			category = "rares",
			faction = "Neutral",
		},
		[48008040] = {
			name = L["Thunderstomp"],
			category = "rares",
			faction = "Neutral",
		},
		[48008060] = {
			name = L["Thunderstomp"],
			category = "rares",
			faction = "Neutral",
		},
		[43806260] = {
			name = L["Azzere the Skyblade"],
			category = "rares",
			faction = "Neutral",
		},
		[44006140] = {
			name = L["Azzere the Skyblade"],
			category = "rares",
			faction = "Neutral",
		},
		[44406160] = {
			name = L["Azzere the Skyblade"],
			category = "rares",
			faction = "Neutral",
		},
		[44406360] = {
			name = L["Azzere the Skyblade"],
			category = "rares",
			faction = "Neutral",
		},
		[44806400] = {
			name = L["Azzere the Skyblade"],
			category = "rares",
			faction = "Neutral",
		},
		[45006240] = {
			name = L["Azzere the Skyblade"],
			category = "rares",
			faction = "Neutral",
		},
		[45006260] = {
			name = L["Azzere the Skyblade"],
			category = "rares",
			faction = "Neutral",
		},
		[46006320] = {
			name = L["Azzere the Skyblade"],
			category = "rares",
			faction = "Neutral",
		},
		[46206225] = {
			name = L["Azzere the Skyblade"],
			category = "rares",
			faction = "Neutral",
		},
		[46806280] = {
			name = L["Azzere the Skyblade"],
			category = "rares",
			faction = "Neutral",
		},
		[56400840] = {
			name = L["Foreman Grills"],
			category = "rares",
			faction = "Neutral",
		},
		[56600860] = {
			name = L["Foreman Grills"],
			category = "rares",
			faction = "Neutral",
		},
		[56200860] = {
			name = L["Engineer Whirleygig"],
			category = "rares",
			faction = "Neutral",
		},
		[42002460] = {
			name = L["Stonearm"],
			category = "rares",
			faction = "Neutral",
		},
		[42202440] = {
			name = L["Stonearm"],
			category = "rares",
			faction = "Neutral",
		},
		[42202740] = {
			name = L["Stonearm"],
			category = "rares",
			faction = "Neutral",
		},
		[42602480] = {
			name = L["Stonearm"],
			category = "rares",
			faction = "Neutral",
		},
		[42802380] = {
			name = L["Stonearm"],
			category = "rares",
			faction = "Neutral",
		},
		[46402320] = {
			name = L["Stonearm"],
			category = "rares",
			faction = "Neutral",
		},
		[46602500] = {
			name = L["Stonearm"],
			category = "rares",
			faction = "Neutral",
		},
		[46802320] = {
			name = L["Stonearm"],
			category = "rares",
			faction = "Neutral",
		},
		[52804380] = {
			name = L["Brokespear"],
			category = "rares",
			faction = "Neutral",
		},
		[53004460] = {
			name = L["Brokespear"],
			category = "rares",
			faction = "Neutral",
		},
		[53403980] = {
			name = L["Brokespear"],
			category = "rares",
			faction = "Neutral",
		},
		[54404640] = {
			name = L["Brokespear"],
			category = "rares",
			faction = "Neutral",
		},
		[54604620] = {
			name = L["Brokespear"],
			category = "rares",
			faction = "Neutral",
		},
		[56404360] = {
			name = L["Brokespear"],
			category = "rares",
			faction = "Neutral",
		},
		[56604380] = {
			name = L["Brokespear"],
			category = "rares",
			faction = "Neutral",
		},
		[57004120] = {
			name = L["Brokespear"],
			category = "rares",
			faction = "Neutral",
		},
		[51803720] = {
			name = L["Rocklance"],
			category = "rares",
			faction = "Neutral",
		},
		[52003280] = {
			name = L["Rocklance"],
			category = "rares",
			faction = "Neutral",
		},
		[53203780] = {
			name = L["Rocklance"],
			category = "rares",
			faction = "Neutral",
		},
		[53204200] = {
			name = L["Rocklance"],
			category = "rares",
			faction = "Neutral",
		},
		[53204280] = {
			name = L["Rocklance"],
			category = "rares",
			faction = "Neutral",
		},
		[53204360] = {
			name = L["Rocklance"],
			category = "rares",
			faction = "Neutral",
		},
		[53204560] = {
			name = L["Rocklance"],
			category = "rares",
			faction = "Neutral",
		},
		[53403740] = {
			name = L["Rocklance"],
			category = "rares",
			faction = "Neutral",
		},
		[53404140] = {
			name = L["Rocklance"],
			category = "rares",
			faction = "Neutral",
		},
		[53604100] = {
			name = L["Rocklance"],
			category = "rares",
			faction = "Neutral",
		},
		[53604240] = {
			name = L["Rocklance"],
			category = "rares",
			faction = "Neutral",
		},
		[53604260] = {
			name = L["Rocklance"],
			category = "rares",
			faction = "Neutral",
		},
		[53804020] = {
			name = L["Rocklance"],
			category = "rares",
			faction = "Neutral",
		},
		[54003920] = {
			name = L["Rocklance"],
			category = "rares",
			faction = "Neutral",
		},
		[54203820] = {
			name = L["Rocklance"],
			category = "rares",
			faction = "Neutral",
		},
		[54603820] = {
			name = L["Rocklance"],
			category = "rares",
			faction = "Neutral",
		},
		[55204500] = {
			name = L["Rocklance"],
			category = "rares",
			faction = "Neutral",
		},
		[55404580] = {
			name = L["Rocklance"],
			category = "rares",
			faction = "Neutral",
		},
		[55803820] = {
			name = L["Rocklance"],
			category = "rares",
			faction = "Neutral",
		},
		[56203920] = {
			name = L["Rocklance"],
			category = "rares",
			faction = "Neutral",
		},
		[56204260] = {
			name = L["Rocklance"],
			category = "rares",
			faction = "Neutral",
		},
		[56404140] = {
			name = L["Rocklance"],
			category = "rares",
			faction = "Neutral",
		},
		[56404180] = {
			name = L["Rocklance"],
			category = "rares",
			faction = "Neutral",
		},
		[56604020] = {
			name = L["Rocklance"],
			category = "rares",
			faction = "Neutral",
		},
		[59800800] = {
			name = L["Takk the Leaper"],
			category = "rares",
			faction = "Neutral",
		},
		[46808480] = {
			name = L["Heggin Stonewhisker"],
			category = "rares",
			description = L["Bael'dun Chief Engineer"],
			faction = "Neutral",
		},
		[47208420] = {
			name = L["Heggin Stonewhisker"],
			category = "rares",
			description = L["Bael'dun Chief Engineer"],
			faction = "Neutral",
		},
		[49408440] = {
			name = L["Malgin Barleybrew"],
			category = "rares",
			description = L["Bael'dun Morale Officer"],
			faction = "Neutral",
		},
		[47408540] = {
			name = L["Digger Flameforge"],
			category = "rares",
			description = L["Excavation Specialist"],
			faction = "Neutral",
		},
		[47408560] = {
			name = L["Digger Flameforge"],
			category = "rares",
			description = L["Excavation Specialist"],
			faction = "Neutral",
		},
		[47608500] = {
			name = L["Digger Flameforge"],
			category = "rares",
			description = L["Excavation Specialist"],
			faction = "Neutral",
		},
		[47808560] = {
			name = L["Digger Flameforge"],
			category = "rares",
			description = L["Excavation Specialist"],
			faction = "Neutral",
		},
		[49408380] = {
			name = L["Captain Gerogg Hammertoe"],
			category = "rares",
			description = L["Bael'dun Captain of the Guard"],
			faction = "Neutral",
		},
		[49608360] = {
			name = L["Captain Gerogg Hammertoe"],
			category = "rares",
			description = L["Bael'dun Captain of the Guard"],
			faction = "Neutral",
		},
		[41407900] = {
			name = L["Hagg Taurenbane"],
			category = "rares",
			description = L["Razormane Champion"],
			faction = "Neutral",
		},
		[41807940] = {
			name = L["Hagg Taurenbane"],
			category = "rares",
			description = L["Razormane Champion"],
			faction = "Neutral",
		},
		[42008040] = {
			name = L["Hagg Taurenbane"],
			category = "rares",
			description = L["Razormane Champion"],
			faction = "Neutral",
		},
		[42208140] = {
			name = L["Hagg Taurenbane"],
			category = "rares",
			description = L["Razormane Champion"],
			faction = "Neutral",
		},
		[42208160] = {
			name = L["Hagg Taurenbane"],
			category = "rares",
			description = L["Razormane Champion"],
			faction = "Neutral",
		},
		[42607920] = {
			name = L["Hagg Taurenbane"],
			category = "rares",
			description = L["Razormane Champion"],
			faction = "Neutral",
		},
		[42808200] = {
			name = L["Hagg Taurenbane"],
			category = "rares",
			description = L["Razormane Champion"],
			faction = "Neutral",
		},
		[42808300] = {
			name = L["Hagg Taurenbane"],
			category = "rares",
			description = L["Razormane Champion"],
			faction = "Neutral",
		},
		[43808160] = {
			name = L["Hagg Taurenbane"],
			category = "rares",
			description = L["Razormane Champion"],
			faction = "Neutral",
		},
		[44008400] = {
			name = L["Hagg Taurenbane"],
			category = "rares",
			description = L["Razormane Champion"],
			faction = "Neutral",
		},
		[44208120] = {
			name = L["Hagg Taurenbane"],
			category = "rares",
			description = L["Razormane Champion"],
			faction = "Neutral",
		},
		[44208280] = {
			name = L["Hagg Taurenbane"],
			category = "rares",
			description = L["Razormane Champion"],
			faction = "Neutral",
		},
		[41004520] = {
			name = L["Geopriest Gukk'rok"],
			category = "rares",
			faction = "Neutral",
		},
		[41204560] = {
			name = L["Geopriest Gukk'rok"],
			category = "rares",
			faction = "Neutral",
		},
		[43204860] = {
			name = L["Geopriest Gukk'rok"],
			category = "rares",
			faction = "Neutral",
		},
		[43205140] = {
			name = L["Geopriest Gukk'rok"],
			category = "rares",
			faction = "Neutral",
		},
		[43404820] = {
			name = L["Geopriest Gukk'rok"],
			category = "rares",
			faction = "Neutral",
		},
		[43405160] = {
			name = L["Geopriest Gukk'rok"],
			category = "rares",
			faction = "Neutral",
		},
		[43804840] = {
			name = L["Geopriest Gukk'rok"],
			category = "rares",
			faction = "Neutral",
		},
		[44205220] = {
			name = L["Geopriest Gukk'rok"],
			category = "rares",
			faction = "Neutral",
		},
		[44805180] = {
			name = L["Geopriest Gukk'rok"],
			category = "rares",
			faction = "Neutral",
		},
		[45405100] = {
			name = L["Geopriest Gukk'rok"],
			category = "rares",
			faction = "Neutral",
		},
		[40804540] = {
			name = L["Swinegart Spearhide"],
			category = "rares",
			faction = "Neutral",
		},
		[41804520] = {
			name = L["Swinegart Spearhide"],
			category = "rares",
			faction = "Neutral",
		},
		[42204800] = {
			name = L["Swinegart Spearhide"],
			category = "rares",
			faction = "Neutral",
		},
		[43004780] = {
			name = L["Swinegart Spearhide"],
			category = "rares",
			faction = "Neutral",
		},
		[43004920] = {
			name = L["Swinegart Spearhide"],
			category = "rares",
			faction = "Neutral",
		},
		[43604840] = {
			name = L["Swinegart Spearhide"],
			category = "rares",
			faction = "Neutral",
		},
		[43604920] = {
			name = L["Swinegart Spearhide"],
			category = "rares",
			faction = "Neutral",
		},
		[49201540] = {
			name = L["Dishu"],
			category = "rares",
			faction = "Neutral",
		},
		[49401580] = {
			name = L["Dishu"],
			category = "rares",
			faction = "Neutral",
		},
		[49402700] = {
			name = L["Dishu"],
			category = "rares",
			faction = "Neutral",
		},
		[49601580] = {
			name = L["Dishu"],
			category = "rares",
			faction = "Neutral",
		},
		[49602700] = {
			name = L["Dishu"],
			category = "rares",
			faction = "Neutral",
		},
		[51002020] = {
			name = L["Dishu"],
			category = "rares",
			faction = "Neutral",
		},
		[51202080] = {
			name = L["Dishu"],
			category = "rares",
			faction = "Neutral",
		},
		[51402640] = {
			name = L["Dishu"],
			category = "rares",
			faction = "Neutral",
		},
		[51402720] = {
			name = L["Dishu"],
			category = "rares",
			faction = "Neutral",
		},
		[51602640] = {
			name = L["Dishu"],
			category = "rares",
			faction = "Neutral",
		},
		[51602660] = {
			name = L["Dishu"],
			category = "rares",
			faction = "Neutral",
		},
		[45808780] = {
			name = L["Ambassador Bloodrage"],
			category = "rares",
			faction = "Neutral",
		},
		[47809060] = {
			name = L["Ambassador Bloodrage"],
			category = "rares",
			faction = "Neutral",
		},
		[48609560] = {
			name = L["Ambassador Bloodrage"],
			category = "rares",
			faction = "Neutral",
		},
		[42407060] = {
			name = L["Silithid Harvester"],
			category = "rares",
			faction = "Neutral",
		},
		[47606940] = {
			name = L["Silithid Harvester"],
			category = "rares",
			faction = "Neutral",
		},
		[60002740] = {
			name = L["Elder Mystic Razorsnout"],
			category = "rares",
			faction = "Neutral",
		},
		[46403960] = {
			name = L["Gesharahan"],
			category = "rares",
			faction = "Neutral",
		},
		[46204820] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46806520] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46806840] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[47607660] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[49005440] = {
			name = L["Aean Swiftriver"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46007140] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46007180] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46806440] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46806845] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[47606520] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[48407700] = {
			name = L["Thora Feathermoon"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46007045] = {
			name = L["Hannah Bladeleaf"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[46204825] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Alliance",
		},
		[46806860] = {
			name = L["Hannah Bladeleaf"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[47807640] = {
			name = L["Hannah Bladeleaf"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[49005445] = {
			name = L["Hannah Bladeleaf"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Neutral",
		},
		[45006360] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Alliance",
		},
		[45604145] = {
			name = L["Marcus Bel"],
			category = "rares",
			description = L["Alliance Outrunner"],
			faction = "Alliance",
		},
		[40402460] = {
			name = L["Snort the Heckler"],
			category = "rares",
			faction = "Neutral",
		},
		[40802540] = {
			name = L["Snort the Heckler"],
			category = "rares",
			faction = "Neutral",
		},
		[41202160] = {
			name = L["Snort the Heckler"],
			category = "rares",
			faction = "Neutral",
		},
		[41202760] = {
			name = L["Snort the Heckler"],
			category = "rares",
			faction = "Neutral",
		},
		[39001840] = {
			name = L["Sister Rathtalon"],
			category = "rares",
			faction = "Neutral",
		},
		[39201260] = {
			name = L["Sister Rathtalon"],
			category = "rares",
			faction = "Neutral",
		},
		[60603160] = {
			name = L["Swiftmane"],
			category = "rares",
			faction = "Neutral",
		},
		[48008080] = {
			name = L["Thunderstomp"],
			category = "rares",
			faction = "Neutral",
		},
		[44406300] = {
			name = L["Azzere the Skyblade"],
			category = "rares",
			faction = "Neutral",
		},
		[47202360] = {
			name = L["Stonearm"],
			category = "rares",
			faction = "Neutral",
		},
		[56004380] = {
			name = L["Rocklance"],
			category = "rares",
			faction = "Neutral",
		},
		[56004480] = {
			name = L["Rocklance"],
			category = "rares",
			faction = "Neutral",
		},
		[58000720] = {
			name = L["Takk the Leaper"],
			category = "rares",
			faction = "Neutral",
		},
		[58600680] = {
			name = L["Takk the Leaper"],
			category = "rares",
			faction = "Neutral",
		},
		[60400960] = {
			name = L["Takk the Leaper"],
			category = "rares",
			faction = "Neutral",
		},
		[60600980] = {
			name = L["Takk the Leaper"],
			category = "rares",
			faction = "Neutral",
		},
		[60601360] = {
			name = L["Takk the Leaper"],
			category = "rares",
			faction = "Neutral",
		},
		[60801340] = {
			name = L["Takk the Leaper"],
			category = "rares",
			faction = "Neutral",
		},
		[47608540] = {
			name = L["Digger Flameforge"],
			category = "rares",
			description = L["Excavation Specialist"],
			faction = "Neutral",
		},
		[42208100] = {
			name = L["Hagg Taurenbane"],
			category = "rares",
			description = L["Razormane Champion"],
			faction = "Neutral",
		},
		[43605200] = {
			name = L["Geopriest Gukk'rok"],
			category = "rares",
			faction = "Neutral",
		},
		[45205220] = {
			name = L["Geopriest Gukk'rok"],
			category = "rares",
			faction = "Neutral",
		},
		[40404520] = {
			name = L["Swinegart Spearhide"],
			category = "rares",
			faction = "Neutral",
		},
		[40604520] = {
			name = L["Swinegart Spearhide"],
			category = "rares",
			faction = "Neutral",
		},
		[42004860] = {
			name = L["Swinegart Spearhide"],
			category = "rares",
			faction = "Neutral",
		},
		[51503034] = {
			name = L["Devrak"],
			category = "flightmasters",
			fpName = L["Crossroads, The Barrens"],
			description = L["Wind Rider Master"],
			faction = "Horde",
		},
	}
	nodes[1443] = {
		[64601040] = {
			name = L["Baritanas Skyriver"],
			category = "flightmasters",
			fpName = L["Nijel's Point, Desolace"],
			description = L["Hippogryph Master"],
			faction = "Alliance",
		},
		[21607400] = {
			name = L["Thalon"],
			category = "flightmasters",
			fpName = L["Shadowprey Village, Desolace"],
			description = L["Wind Rider Master"],
			faction = "Horde",
		},
		[66200660] = {
			name = L["Innkeeper Lyshaerya"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Alliance",
		},
		[24206820] = {
			name = L["Innkeeper Sikewa"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Horde",
		},
		[24806880] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Horde",
		},
		[65400690] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Alliance",
		},
		[67800840] = {
			name = L["Maxton Strang"],
			category = "repair",
			description = L["Mail Armor Merchant"],
			faction = "Alliance",
		},
		[55605640] = {
			name = L["Muuran"],
			category = "repair",
			description = L["Superior Macecrafter"],
			faction = "Horde",
		},
		[25807100] = {
			name = L["Hae'Wilani"],
			category = "repair",
			description = L["Axecrafter"],
			faction = "Horde",
		},
		[50206280] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[65400780] = {
			name = L["Shelgrayn"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Alliance",
		},
		[24806885] = {
			name = L["Aboda"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Horde",
		},
		[55205620] = {
			name = L["Narv Hidecrafter"],
			category = "primaryProfession",
			profession = "Leatherworking",
			description = L["Expert Leathercrafter"],
			faction = "Horde",
		},
		[23206980] = {
			name = L["Malux"],
			category = "primaryProfession",
			profession = "Skinning",
			description = L["Skinning Trainer"],
			faction = "Horde",
		},
		[22607240] = {
			name = L["Lui'Mala"],
			category = "secondaryProfession",
			profession = "Fishing",
			description = L["Fisherman"],
			faction = "Horde",
		},
		[66200665] = {
			name = L["Janet Hommers"],
			category = "vendors",
			description = L["Food & Drink"],
			faction = "Alliance",
		},
		[51205320] = {
			name = L["Harnor"],
			category = "vendors",
			description = L["Food & Drink"],
			faction = "Horde",
		},
		[51005340] = {
			name = L["Kireena"],
			category = "vendors",
			description = L["Trade Goods"],
			faction = "Horde",
		},
		[25007180] = {
			name = L["Tukk"],
			category = "vendors",
			description = L["General Goods Vendor"],
			faction = "Horde",
		},
		[23007160] = {
			name = L["Lah'Mawhani"],
			category = "vendors",
			description = L["Trade Supplies"],
			faction = "Horde",
		},
		[22607200] = {
			name = L["Mai'Lahii"],
			category = "vendors",
			description = L["Fishing Supplies"],
			faction = "Horde",
		},
		[26206980] = {
			name = L["Wulan"],
			category = "vendors",
			description = L["Cooking Supplies"],
			faction = "Horde",
		},
		[60203800] = {
			name = L["Vendor-Tron 1000"],
			category = "vendors",
			faction = "Neutral",
		},
		[40407920] = {
			name = L["Super-Seller 680"],
			category = "vendors",
			faction = "Neutral",
		},
		[66600680] = {
			name = L["Christi Galvanis"],
			category = "vendors",
			description = L["General Goods"],
			faction = "Alliance",
		},
		[29806240] = {
			name = L["Cursed Centaur"],
			category = "rares",
			faction = "Neutral",
		},
		[74601200] = {
			name = L["Prince Kellen"],
			category = "rares",
			faction = "Neutral",
		},
		[74601340] = {
			name = L["Prince Kellen"],
			category = "rares",
			faction = "Neutral",
		},
		[77202220] = {
			name = L["Prince Kellen"],
			category = "rares",
			faction = "Neutral",
		},
		[78002320] = {
			name = L["Prince Kellen"],
			category = "rares",
			faction = "Neutral",
		},
		[49007120] = {
			name = L["Kaskk"],
			category = "rares",
			faction = "Neutral",
		},
		[49407260] = {
			name = L["Kaskk"],
			category = "rares",
			faction = "Neutral",
		},
		[55007660] = {
			name = L["Kaskk"],
			category = "rares",
			faction = "Neutral",
		},
		[56407500] = {
			name = L["Kaskk"],
			category = "rares",
			faction = "Neutral",
		},
		[40804720] = {
			name = L["Hissperak"],
			category = "rares",
			faction = "Neutral",
		},
		[43204840] = {
			name = L["Hissperak"],
			category = "rares",
			faction = "Neutral",
		},
		[43404180] = {
			name = L["Hissperak"],
			category = "rares",
			faction = "Neutral",
		},
		[43406120] = {
			name = L["Hissperak"],
			category = "rares",
			faction = "Neutral",
		},
		[43604240] = {
			name = L["Hissperak"],
			category = "rares",
			faction = "Neutral",
		},
		[43806180] = {
			name = L["Hissperak"],
			category = "rares",
			faction = "Neutral",
		},
		[45405240] = {
			name = L["Hissperak"],
			category = "rares",
			faction = "Neutral",
		},
		[45405460] = {
			name = L["Hissperak"],
			category = "rares",
			faction = "Neutral",
		},
		[45805340] = {
			name = L["Hissperak"],
			category = "rares",
			faction = "Neutral",
		},
		[46405400] = {
			name = L["Hissperak"],
			category = "rares",
			faction = "Neutral",
		},
		[57400840] = {
			name = L["Giggler"],
			category = "rares",
			faction = "Neutral",
		},
		[57401000] = {
			name = L["Giggler"],
			category = "rares",
			faction = "Neutral",
		},
		[63003500] = {
			name = L["Giggler"],
			category = "rares",
			faction = "Neutral",
		},
		[65602440] = {
			name = L["Giggler"],
			category = "rares",
			faction = "Neutral",
		},
		[66201720] = {
			name = L["Giggler"],
			category = "rares",
			faction = "Neutral",
		},
		[67202340] = {
			name = L["Giggler"],
			category = "rares",
			faction = "Neutral",
		},
		[28801460] = {
			name = L["Accursed Slitherblade"],
			category = "rares",
			faction = "Neutral",
		},
		[34800500] = {
			name = L["Accursed Slitherblade"],
			category = "rares",
			faction = "Neutral",
		},
		[29606240] = {
			name = L["Cursed Centaur"],
			category = "rares",
			faction = "Neutral",
		},
		[50007200] = {
			name = L["Kaskk"],
			category = "rares",
			faction = "Neutral",
		},
		[50808000] = {
			name = L["Kaskk"],
			category = "rares",
			faction = "Neutral",
		},
		[63403440] = {
			name = L["Giggler"],
			category = "rares",
			faction = "Neutral",
		},
		[63403560] = {
			name = L["Giggler"],
			category = "rares",
			faction = "Neutral",
		},
		[63803480] = {
			name = L["Giggler"],
			category = "rares",
			faction = "Neutral",
		},
		[66401940] = {
			name = L["Giggler"],
			category = "rares",
			faction = "Neutral",
		},
		[66601740] = {
			name = L["Giggler"],
			category = "rares",
			faction = "Neutral",
		},
		[28801420] = {
			name = L["Accursed Slitherblade"],
			category = "rares",
			faction = "Neutral",
		},
		[29401540] = {
			name = L["Accursed Slitherblade"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1440] = {
		[34404800] = {
			name = L["Daelyshia"],
			category = "flightmasters",
			fpName = L["Astranaar, Ashenvale"],
			description = L["Hippogryph Master"],
			faction = "Alliance",
		},
		[12203380] = {
			name = L["Andruk"],
			category = "flightmasters",
			fpName = L["Zoram'gar Outpost, Ashenvale"],
			description = L["Wind Rider Master"],
			faction = "Horde",
		},
		[73206160] = {
			name = L["Vhulgra"],
			category = "flightmasters",
			fpName = L["Splintertree Post, Ashenvale"],
			description = L["Wind Rider Master"],
			faction = "Horde",
		},
		[37004920] = {
			name = L["Innkeeper Kimlya"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Alliance",
		},
		[74006060] = {
			name = L["Innkeeper Kaylisk"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Horde",
		},
		[36405030] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Alliance",
		},
		[73606090] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Horde",
		},
		[50206720] = {
			name = L["Bhaldaran Ravenshade"],
			category = "repair",
			description = L["Bowyer"],
			faction = "Alliance",
		},
		[34404960] = {
			name = L["Aeolynn"],
			category = "repair",
			description = L["Clothier"],
			faction = "Alliance",
		},
		[34604980] = {
			name = L["Tandaan Lightmane"],
			category = "repair",
			description = L["Leather Armor Merchant"],
			faction = "Alliance",
		},
		[73406040] = {
			name = L["Burkrum"],
			category = "repair",
			description = L["Heavy Armor Merchant"],
			faction = "Horde",
		},
		[35805200] = {
			name = L["Xai'ander"],
			category = "repair",
			description = L["Weaponsmith"],
			faction = "Alliance",
		},
		[61408380] = {
			name = L["Illiyana Moonblaze"],
			category = "repair",
			description = L["Silverwing Supply Officer"],
			faction = "Alliance",
		},
		[40205300] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[80605800] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[36405040] = {
			name = L["Maluressian"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Alliance",
		},
		[73406100] = {
			name = L["Qeeju"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Horde",
		},
		[50006780] = {
			name = L["Danlaar Nightstride"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Hunter Trainer"],
			classes = {
				HUNTER = true,
			},
			faction = "Alliance",
		},
		[50806700] = {
			name = L["Kylanna"],
			category = "primaryProfession",
			profession = "Alchemy",
			description = L["Expert Alchemist"],
			faction = "Alliance",
		},
		[50606700] = {
			name = L["Cylania Rootstalker"],
			category = "primaryProfession",
			profession = "Herbalism",
			description = L["Herbalist"],
			faction = "Alliance",
		},
		[35805205] = {
			name = L["Aayndia Floralwind"],
			category = "primaryProfession",
			profession = "Leatherworking",
			description = L["Expert Leatherworker"],
			faction = "Alliance",
		},
		[49806700] = {
			name = L["Caelyb"],
			category = "trainers",
			description = L["Pet Trainer"],
			faction = "Alliance",
		},
		[50006720] = {
			name = L["Jayla"],
			category = "primaryProfession",
			profession = "Skinning",
			description = L["Skinner"],
			faction = "Alliance",
		},
		[18005980] = {
			name = L["Alenndaar Lapidaar"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Hunter Trainer"],
			classes = {
				HUNTER = true,
			},
			faction = "Neutral",
		},
		[10803360] = {
			name = L["Kil'Hiwana"],
			category = "secondaryProfession",
			profession = "Fishing",
			description = L["Fisherman"],
			faction = "Horde",
		},
		[35005200] = {
			name = L["Dalria"],
			category = "vendors",
			description = L["Trade Goods"],
			faction = "Alliance",
		},
		[49606700] = {
			name = L["Shandrina"],
			category = "vendors",
			description = L["Trade Goods"],
			faction = "Alliance",
		},
		[50606705] = {
			name = L["Harklan Moongrove"],
			category = "vendors",
			description = L["Alchemy Supplies"],
			faction = "Alliance",
		},
		[34804980] = {
			name = L["Lardan"],
			category = "vendors",
			description = L["Leatherworking Supplies"],
			faction = "Alliance",
		},
		[37004980] = {
			name = L["Nantar"],
			category = "vendors",
			description = L["Baker"],
			faction = "Alliance",
		},
		[50006660] = {
			name = L["Ulthaan"],
			category = "vendors",
			description = L["Butcher"],
			faction = "Alliance",
		},
		[36604980] = {
			name = L["Maliynn"],
			category = "vendors",
			description = L["Food & Drink Vendor"],
			faction = "Alliance",
		},
		[34805080] = {
			name = L["Haljan Oakheart"],
			category = "vendors",
			description = L["General Goods"],
			faction = "Alliance",
		},
		[36404940] = {
			name = L["Fahran Silentblade"],
			category = "vendors",
			description = L["Tools & Supplies"],
			faction = "Alliance",
		},
		[35004840] = {
			name = L["Llana"],
			category = "vendors",
			description = L["Reagent Supplies"],
			faction = "Alliance",
		},
		[11803400] = {
			name = L["Wik'Tar"],
			category = "vendors",
			description = L["Fish Merchant & Supplies"],
			faction = "Horde",
		},
		[62008280] = {
			name = L["Gapp Jinglepocket"],
			category = "vendors",
			description = L["Smokywood Pastures"],
			faction = "Alliance",
		},
		[33202100] = {
			name = L["Apothecary Falthis"],
			category = "rares",
			faction = "Neutral",
		},
		[33202160] = {
			name = L["Apothecary Falthis"],
			category = "rares",
			faction = "Neutral",
		},
		[25206040] = {
			name = L["Akkrilus"],
			category = "rares",
			faction = "Neutral",
		},
		[28406140] = {
			name = L["Akkrilus"],
			category = "rares",
			faction = "Neutral",
		},
		[50603840] = {
			name = L["Terrowulf Packlord"],
			category = "rares",
			faction = "Neutral",
		},
		[50603880] = {
			name = L["Terrowulf Packlord"],
			category = "rares",
			faction = "Neutral",
		},
		[9601540] = {
			name = L["Lady Vespia"],
			category = "rares",
			faction = "Neutral",
		},
		[11202940] = {
			name = L["Lady Vespia"],
			category = "rares",
			faction = "Neutral",
		},
		[11203000] = {
			name = L["Lady Vespia"],
			category = "rares",
			faction = "Neutral",
		},
		[12401840] = {
			name = L["Lady Vespia"],
			category = "rares",
			faction = "Neutral",
		},
		[12401900] = {
			name = L["Lady Vespia"],
			category = "rares",
			faction = "Neutral",
		},
		[12601900] = {
			name = L["Lady Vespia"],
			category = "rares",
			faction = "Neutral",
		},
		[35403280] = {
			name = L["Rorgish Jowl"],
			category = "rares",
			faction = "Neutral",
		},
		[35603200] = {
			name = L["Rorgish Jowl"],
			category = "rares",
			faction = "Neutral",
		},
		[35603260] = {
			name = L["Rorgish Jowl"],
			category = "rares",
			faction = "Neutral",
		},
		[36603540] = {
			name = L["Rorgish Jowl"],
			category = "rares",
			faction = "Neutral",
		},
		[36603620] = {
			name = L["Rorgish Jowl"],
			category = "rares",
			faction = "Neutral",
		},
		[37003400] = {
			name = L["Rorgish Jowl"],
			category = "rares",
			faction = "Neutral",
		},
		[37203340] = {
			name = L["Rorgish Jowl"],
			category = "rares",
			faction = "Neutral",
		},
		[49806060] = {
			name = L["Oakpaw"],
			category = "rares",
			faction = "Neutral",
		},
		[51006140] = {
			name = L["Oakpaw"],
			category = "rares",
			faction = "Neutral",
		},
		[51006160] = {
			name = L["Oakpaw"],
			category = "rares",
			faction = "Neutral",
		},
		[53606100] = {
			name = L["Oakpaw"],
			category = "rares",
			faction = "Neutral",
		},
		[53806240] = {
			name = L["Oakpaw"],
			category = "rares",
			faction = "Neutral",
		},
		[54406260] = {
			name = L["Oakpaw"],
			category = "rares",
			faction = "Neutral",
		},
		[56206320] = {
			name = L["Oakpaw"],
			category = "rares",
			faction = "Neutral",
		},
		[56406240] = {
			name = L["Oakpaw"],
			category = "rares",
			faction = "Neutral",
		},
		[56606280] = {
			name = L["Oakpaw"],
			category = "rares",
			faction = "Neutral",
		},
		[43804520] = {
			name = L["Branch Snapper"],
			category = "rares",
			faction = "Neutral",
		},
		[44204560] = {
			name = L["Branch Snapper"],
			category = "rares",
			faction = "Neutral",
		},
		[45004600] = {
			name = L["Branch Snapper"],
			category = "rares",
			faction = "Neutral",
		},
		[46604840] = {
			name = L["Branch Snapper"],
			category = "rares",
			faction = "Neutral",
		},
		[45207140] = {
			name = L["Eck'alom"],
			category = "rares",
			faction = "Neutral",
		},
		[45407160] = {
			name = L["Eck'alom"],
			category = "rares",
			faction = "Neutral",
		},
		[48206980] = {
			name = L["Eck'alom"],
			category = "rares",
			faction = "Neutral",
		},
		[52807020] = {
			name = L["Eck'alom"],
			category = "rares",
			faction = "Neutral",
		},
		[17803680] = {
			name = L["Mugglefin"],
			category = "rares",
			faction = "Neutral",
		},
		[18803800] = {
			name = L["Mugglefin"],
			category = "rares",
			faction = "Neutral",
		},
		[19404280] = {
			name = L["Mugglefin"],
			category = "rares",
			faction = "Neutral",
		},
		[19404480] = {
			name = L["Mugglefin"],
			category = "rares",
			faction = "Neutral",
		},
		[19804400] = {
			name = L["Mugglefin"],
			category = "rares",
			faction = "Neutral",
		},
		[20004240] = {
			name = L["Mugglefin"],
			category = "rares",
			faction = "Neutral",
		},
		[20404320] = {
			name = L["Mugglefin"],
			category = "rares",
			faction = "Neutral",
		},
		[19403020] = {
			name = L["Mist Howler"],
			category = "rares",
			faction = "Neutral",
		},
		[21803020] = {
			name = L["Mist Howler"],
			category = "rares",
			faction = "Neutral",
		},
		[26401760] = {
			name = L["Mist Howler"],
			category = "rares",
			faction = "Neutral",
		},
		[26401860] = {
			name = L["Mist Howler"],
			category = "rares",
			faction = "Neutral",
		},
		[26601800] = {
			name = L["Mist Howler"],
			category = "rares",
			faction = "Neutral",
		},
		[77404620] = {
			name = L["Prince Raze"],
			category = "rares",
			faction = "Neutral",
		},
		[78204640] = {
			name = L["Prince Raze"],
			category = "rares",
			faction = "Neutral",
		},
		[78404240] = {
			name = L["Prince Raze"],
			category = "rares",
			faction = "Neutral",
		},
		[78604400] = {
			name = L["Prince Raze"],
			category = "rares",
			faction = "Neutral",
		},
		[78804540] = {
			name = L["Prince Raze"],
			category = "rares",
			faction = "Neutral",
		},
		[78804560] = {
			name = L["Prince Raze"],
			category = "rares",
			faction = "Neutral",
		},
		[79804620] = {
			name = L["Prince Raze"],
			category = "rares",
			faction = "Neutral",
		},
		[82404680] = {
			name = L["Ursol'lok"],
			category = "rares",
			faction = "Neutral",
		},
		[82804740] = {
			name = L["Ursol'lok"],
			category = "rares",
			faction = "Neutral",
		},
		[83004840] = {
			name = L["Ursol'lok"],
			category = "rares",
			faction = "Neutral",
		},
		[28206520] = {
			name = L["Akkrilus"],
			category = "rares",
			faction = "Neutral",
		},
		[50203900] = {
			name = L["Terrowulf Packlord"],
			category = "rares",
			faction = "Neutral",
		},
		[12601820] = {
			name = L["Lady Vespia"],
			category = "rares",
			faction = "Neutral",
		},
		[35203220] = {
			name = L["Rorgish Jowl"],
			category = "rares",
			faction = "Neutral",
		},
		[46604900] = {
			name = L["Branch Snapper"],
			category = "rares",
			faction = "Neutral",
		},
		[47604660] = {
			name = L["Branch Snapper"],
			category = "rares",
			faction = "Neutral",
		},
		[20004260] = {
			name = L["Mugglefin"],
			category = "rares",
			faction = "Neutral",
		},
		[83405620] = {
			name = L["Ursol'lok"],
			category = "rares",
			faction = "Neutral",
		},
		[88606820] = {
			name = L["Ursol'lok"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1442] = {
		[45205980] = {
			name = L["Tharm"],
			category = "flightmasters",
			fpName = L["Sun Rock Retreat, Stonetalon Mountains"],
			description = L["Wind Rider Master"],
			faction = "Horde",
		},
		[36400720] = {
			name = L["Teloren"],
			category = "flightmasters",
			fpName = L["Stonetalon Peak, Stonetalon Mountains"],
			description = L["Hippogryph Master"],
			faction = "Alliance",
		},
		[47406200] = {
			name = L["Innkeeper Jayka"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Horde",
		},
		[35600580] = {
			name = L["Innkeeper Faralia"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Alliance",
		},
		[36000730] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Alliance",
		},
		[48006110] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Horde",
		},
		[62604020] = {
			name = L["Nizzik"],
			category = "repair",
			description = L["Venture Armor Salesman"],
			faction = "Neutral",
		},
		[58205160] = {
			name = L["Veenix"],
			category = "repair",
			description = L["Venture Co. Merchant"],
			faction = "Neutral",
		},
		[35400700] = {
			name = L["Illyanie"],
			category = "repair",
			description = L["Cloth Armor Merchant"],
			faction = "Alliance",
		},
		[45205920] = {
			name = L["Borand"],
			category = "repair",
			description = L["Bowyer"],
			faction = "Horde",
		},
		[57406200] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[47806120] = {
			name = L["Gereck"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Horde",
		},
		[49205720] = {
			name = L["Hgarth"],
			category = "primaryProfession",
			profession = "Enchanting",
			description = L["Artisan Enchanter"],
			faction = "Horde",
		},
		[73409540] = {
			name = L["Denni'ka"],
			category = "vendors",
			description = L["Butcher"],
			faction = "Horde",
		},
		[45805860] = {
			name = L["Grawnal"],
			category = "vendors",
			description = L["General Goods"],
			faction = "Horde",
		},
		[47606160] = {
			name = L["Jeeda"],
			category = "vendors",
			description = L["Apprentice Witch Doctor"],
			faction = "Horde",
		},
		[35600620] = {
			name = L["Chylina"],
			category = "vendors",
			description = L["General Supplies"],
			faction = "Alliance",
		},
		[46205840] = {
			name = L["Krond"],
			category = "vendors",
			description = L["Butcher"],
			faction = "Horde",
		},
		[45405940] = {
			name = L["Kulwia"],
			category = "vendors",
			description = L["Trade Supplies"],
			faction = "Horde",
		},
		[44204000] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[44404120] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[44404680] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[44603980] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[44604460] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[44804360] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[44804560] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[45003920] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[45403840] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[45404140] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[45603860] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[45604540] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[45804040] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[46003760] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[46004780] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[46203720] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[46204120] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[46204180] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[46404320] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[46404640] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[46404700] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[46604200] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[46804460] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[47004340] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[47004660] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[47004760] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[47204560] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[47404360] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[47604400] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[47604800] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[47804520] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[48004340] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[48204640] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[48404680] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[49004580] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[53003700] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[53203620] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[53403540] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[53403800] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[53604060] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[53803540] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[54003580] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[54003920] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[54203800] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[54204000] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[54803800] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[54803900] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[55003700] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[29206860] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[30006620] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[30206860] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[30207080] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[30406440] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[30407320] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[31006600] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[31406320] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[31406460] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[31407300] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[32007200] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[32007280] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[32007380] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[32606000] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[32607300] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[33207080] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[33406300] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[33607160] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[33807260] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[34006000] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[34006220] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[34207080] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[34207360] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[35007440] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[35407460] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[35807240] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[36207300] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[36207360] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[37407240] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[25401140] = {
			name = L["Nal'taszar"],
			category = "rares",
			faction = "Neutral",
		},
		[25401200] = {
			name = L["Nal'taszar"],
			category = "rares",
			faction = "Neutral",
		},
		[25401260] = {
			name = L["Nal'taszar"],
			category = "rares",
			faction = "Neutral",
		},
		[25401360] = {
			name = L["Nal'taszar"],
			category = "rares",
			faction = "Neutral",
		},
		[25801240] = {
			name = L["Nal'taszar"],
			category = "rares",
			faction = "Neutral",
		},
		[25801260] = {
			name = L["Nal'taszar"],
			category = "rares",
			faction = "Neutral",
		},
		[28201280] = {
			name = L["Brother Ravenoak"],
			category = "rares",
			faction = "Neutral",
		},
		[28601400] = {
			name = L["Brother Ravenoak"],
			category = "rares",
			faction = "Neutral",
		},
		[30001420] = {
			name = L["Sentinel Amarassan"],
			category = "rares",
			faction = "Neutral",
		},
		[30201480] = {
			name = L["Sentinel Amarassan"],
			category = "rares",
			faction = "Neutral",
		},
		[30601460] = {
			name = L["Sentinel Amarassan"],
			category = "rares",
			faction = "Neutral",
		},
		[31001440] = {
			name = L["Sentinel Amarassan"],
			category = "rares",
			faction = "Neutral",
		},
		[32401580] = {
			name = L["Sentinel Amarassan"],
			category = "rares",
			faction = "Neutral",
		},
		[32601800] = {
			name = L["Sentinel Amarassan"],
			category = "rares",
			faction = "Neutral",
		},
		[32801680] = {
			name = L["Sentinel Amarassan"],
			category = "rares",
			faction = "Neutral",
		},
		[34201820] = {
			name = L["Sentinel Amarassan"],
			category = "rares",
			faction = "Neutral",
		},
		[36201440] = {
			name = L["Sentinel Amarassan"],
			category = "rares",
			faction = "Neutral",
		},
		[36401580] = {
			name = L["Sentinel Amarassan"],
			category = "rares",
			faction = "Neutral",
		},
		[37401480] = {
			name = L["Sentinel Amarassan"],
			category = "rares",
			faction = "Neutral",
		},
		[46003820] = {
			name = L["Sorrow Wing"],
			category = "rares",
			faction = "Neutral",
		},
		[46203540] = {
			name = L["Sorrow Wing"],
			category = "rares",
			faction = "Neutral",
		},
		[47003400] = {
			name = L["Sorrow Wing"],
			category = "rares",
			faction = "Neutral",
		},
		[47003640] = {
			name = L["Sorrow Wing"],
			category = "rares",
			faction = "Neutral",
		},
		[47203500] = {
			name = L["Sorrow Wing"],
			category = "rares",
			faction = "Neutral",
		},
		[47803640] = {
			name = L["Sorrow Wing"],
			category = "rares",
			faction = "Neutral",
		},
		[48003420] = {
			name = L["Sorrow Wing"],
			category = "rares",
			faction = "Neutral",
		},
		[48603620] = {
			name = L["Sorrow Wing"],
			category = "rares",
			faction = "Neutral",
		},
		[48803380] = {
			name = L["Sorrow Wing"],
			category = "rares",
			faction = "Neutral",
		},
		[48803680] = {
			name = L["Sorrow Wing"],
			category = "rares",
			faction = "Neutral",
		},
		[49203280] = {
			name = L["Sorrow Wing"],
			category = "rares",
			faction = "Neutral",
		},
		[49803700] = {
			name = L["Sorrow Wing"],
			category = "rares",
			faction = "Neutral",
		},
		[50603680] = {
			name = L["Sorrow Wing"],
			category = "rares",
			faction = "Neutral",
		},
		[51203440] = {
			name = L["Sorrow Wing"],
			category = "rares",
			faction = "Neutral",
		},
		[51203500] = {
			name = L["Sorrow Wing"],
			category = "rares",
			faction = "Neutral",
		},
		[27206880] = {
			name = L["Sister Riven"],
			category = "rares",
			faction = "Neutral",
		},
		[27206980] = {
			name = L["Sister Riven"],
			category = "rares",
			faction = "Neutral",
		},
		[27406820] = {
			name = L["Sister Riven"],
			category = "rares",
			faction = "Neutral",
		},
		[27606580] = {
			name = L["Sister Riven"],
			category = "rares",
			faction = "Neutral",
		},
		[27607040] = {
			name = L["Sister Riven"],
			category = "rares",
			faction = "Neutral",
		},
		[28206800] = {
			name = L["Sister Riven"],
			category = "rares",
			faction = "Neutral",
		},
		[28606920] = {
			name = L["Sister Riven"],
			category = "rares",
			faction = "Neutral",
		},
		[29606840] = {
			name = L["Sister Riven"],
			category = "rares",
			faction = "Neutral",
		},
		[29606880] = {
			name = L["Sister Riven"],
			category = "rares",
			faction = "Neutral",
		},
		[29806980] = {
			name = L["Sister Riven"],
			category = "rares",
			faction = "Neutral",
		},
		[35206760] = {
			name = L["Sister Riven"],
			category = "rares",
			faction = "Neutral",
		},
		[36006880] = {
			name = L["Sister Riven"],
			category = "rares",
			faction = "Neutral",
		},
		[36206960] = {
			name = L["Sister Riven"],
			category = "rares",
			faction = "Neutral",
		},
		[36606840] = {
			name = L["Sister Riven"],
			category = "rares",
			faction = "Neutral",
		},
		[37006940] = {
			name = L["Sister Riven"],
			category = "rares",
			faction = "Neutral",
		},
		[37007020] = {
			name = L["Sister Riven"],
			category = "rares",
			faction = "Neutral",
		},
		[37606800] = {
			name = L["Sister Riven"],
			category = "rares",
			faction = "Neutral",
		},
		[38406740] = {
			name = L["Sister Riven"],
			category = "rares",
			faction = "Neutral",
		},
		[63604700] = {
			name = L["Foreman Rigger"],
			category = "rares",
			faction = "Neutral",
		},
		[64805100] = {
			name = L["Foreman Rigger"],
			category = "rares",
			faction = "Neutral",
		},
		[65004800] = {
			name = L["Foreman Rigger"],
			category = "rares",
			faction = "Neutral",
		},
		[65205180] = {
			name = L["Foreman Rigger"],
			category = "rares",
			faction = "Neutral",
		},
		[65404420] = {
			name = L["Foreman Rigger"],
			category = "rares",
			faction = "Neutral",
		},
		[65605120] = {
			name = L["Foreman Rigger"],
			category = "rares",
			faction = "Neutral",
		},
		[66004460] = {
			name = L["Foreman Rigger"],
			category = "rares",
			faction = "Neutral",
		},
		[66005200] = {
			name = L["Foreman Rigger"],
			category = "rares",
			faction = "Neutral",
		},
		[66205380] = {
			name = L["Foreman Rigger"],
			category = "rares",
			faction = "Neutral",
		},
		[66404600] = {
			name = L["Foreman Rigger"],
			category = "rares",
			faction = "Neutral",
		},
		[66404660] = {
			name = L["Foreman Rigger"],
			category = "rares",
			faction = "Neutral",
		},
		[66405260] = {
			name = L["Foreman Rigger"],
			category = "rares",
			faction = "Neutral",
		},
		[66605160] = {
			name = L["Foreman Rigger"],
			category = "rares",
			faction = "Neutral",
		},
		[66605300] = {
			name = L["Foreman Rigger"],
			category = "rares",
			faction = "Neutral",
		},
		[66804680] = {
			name = L["Foreman Rigger"],
			category = "rares",
			faction = "Neutral",
		},
		[67004560] = {
			name = L["Foreman Rigger"],
			category = "rares",
			faction = "Neutral",
		},
		[67204500] = {
			name = L["Foreman Rigger"],
			category = "rares",
			faction = "Neutral",
		},
		[68004500] = {
			name = L["Foreman Rigger"],
			category = "rares",
			faction = "Neutral",
		},
		[68404620] = {
			name = L["Foreman Rigger"],
			category = "rares",
			faction = "Neutral",
		},
		[61405040] = {
			name = L["Taskmaster Whipfang"],
			category = "rares",
			faction = "Neutral",
		},
		[61405120] = {
			name = L["Taskmaster Whipfang"],
			category = "rares",
			faction = "Neutral",
		},
		[61405160] = {
			name = L["Taskmaster Whipfang"],
			category = "rares",
			faction = "Neutral",
		},
		[61805160] = {
			name = L["Taskmaster Whipfang"],
			category = "rares",
			faction = "Neutral",
		},
		[62005100] = {
			name = L["Taskmaster Whipfang"],
			category = "rares",
			faction = "Neutral",
		},
		[62205700] = {
			name = L["Taskmaster Whipfang"],
			category = "rares",
			faction = "Neutral",
		},
		[62405520] = {
			name = L["Taskmaster Whipfang"],
			category = "rares",
			faction = "Neutral",
		},
		[62405640] = {
			name = L["Taskmaster Whipfang"],
			category = "rares",
			faction = "Neutral",
		},
		[62605480] = {
			name = L["Taskmaster Whipfang"],
			category = "rares",
			faction = "Neutral",
		},
		[62605620] = {
			name = L["Taskmaster Whipfang"],
			category = "rares",
			faction = "Neutral",
		},
		[63605540] = {
			name = L["Taskmaster Whipfang"],
			category = "rares",
			faction = "Neutral",
		},
		[64004920] = {
			name = L["Taskmaster Whipfang"],
			category = "rares",
			faction = "Neutral",
		},
		[64405340] = {
			name = L["Taskmaster Whipfang"],
			category = "rares",
			faction = "Neutral",
		},
		[64405400] = {
			name = L["Taskmaster Whipfang"],
			category = "rares",
			faction = "Neutral",
		},
		[64604940] = {
			name = L["Taskmaster Whipfang"],
			category = "rares",
			faction = "Neutral",
		},
		[64605340] = {
			name = L["Taskmaster Whipfang"],
			category = "rares",
			faction = "Neutral",
		},
		[64605400] = {
			name = L["Taskmaster Whipfang"],
			category = "rares",
			faction = "Neutral",
		},
		[64805020] = {
			name = L["Taskmaster Whipfang"],
			category = "rares",
			faction = "Neutral",
		},
		[73805160] = {
			name = L["Taskmaster Whipfang"],
			category = "rares",
			faction = "Neutral",
		},
		[44004060] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[44204380] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[44204500] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[45004280] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[45204240] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[45804000] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[45804580] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[46004140] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[48804660] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[53203580] = {
			name = L["Pridewing Patriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[30807100] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[31606140] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[32206260] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[32806120] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[33806340] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[33807120] = {
			name = L["Vengeful Ancient"],
			category = "rares",
			faction = "Neutral",
		},
		[25401220] = {
			name = L["Nal'taszar"],
			category = "rares",
			faction = "Neutral",
		},
		[26001320] = {
			name = L["Nal'taszar"],
			category = "rares",
			faction = "Neutral",
		},
		[34401800] = {
			name = L["Sentinel Amarassan"],
			category = "rares",
			faction = "Neutral",
		},
		[36601400] = {
			name = L["Sentinel Amarassan"],
			category = "rares",
			faction = "Neutral",
		},
		[36801640] = {
			name = L["Sentinel Amarassan"],
			category = "rares",
			faction = "Neutral",
		},
		[38001840] = {
			name = L["Sentinel Amarassan"],
			category = "rares",
			faction = "Neutral",
		},
		[48003340] = {
			name = L["Sorrow Wing"],
			category = "rares",
			faction = "Neutral",
		},
		[48003380] = {
			name = L["Sorrow Wing"],
			category = "rares",
			faction = "Neutral",
		},
		[48203720] = {
			name = L["Sorrow Wing"],
			category = "rares",
			faction = "Neutral",
		},
		[50803700] = {
			name = L["Sorrow Wing"],
			category = "rares",
			faction = "Neutral",
		},
		[28007080] = {
			name = L["Sister Riven"],
			category = "rares",
			faction = "Neutral",
		},
		[28406880] = {
			name = L["Sister Riven"],
			category = "rares",
			faction = "Neutral",
		},
		[29006840] = {
			name = L["Sister Riven"],
			category = "rares",
			faction = "Neutral",
		},
		[29406680] = {
			name = L["Sister Riven"],
			category = "rares",
			faction = "Neutral",
		},
		[35606800] = {
			name = L["Sister Riven"],
			category = "rares",
			faction = "Neutral",
		},
		[36406740] = {
			name = L["Sister Riven"],
			category = "rares",
			faction = "Neutral",
		},
		[36606820] = {
			name = L["Sister Riven"],
			category = "rares",
			faction = "Neutral",
		},
		[37606780] = {
			name = L["Sister Riven"],
			category = "rares",
			faction = "Neutral",
		},
		[65205080] = {
			name = L["Foreman Rigger"],
			category = "rares",
			faction = "Neutral",
		},
		[65605140] = {
			name = L["Foreman Rigger"],
			category = "rares",
			faction = "Neutral",
		},
		[65605160] = {
			name = L["Foreman Rigger"],
			category = "rares",
			faction = "Neutral",
		},
		[65804940] = {
			name = L["Foreman Rigger"],
			category = "rares",
			faction = "Neutral",
		},
		[66604440] = {
			name = L["Foreman Rigger"],
			category = "rares",
			faction = "Neutral",
		},
		[66605240] = {
			name = L["Foreman Rigger"],
			category = "rares",
			faction = "Neutral",
		},
		[67605320] = {
			name = L["Foreman Rigger"],
			category = "rares",
			faction = "Neutral",
		},
		[68205120] = {
			name = L["Foreman Rigger"],
			category = "rares",
			faction = "Neutral",
		},
		[61405080] = {
			name = L["Taskmaster Whipfang"],
			category = "rares",
			faction = "Neutral",
		},
		[61805040] = {
			name = L["Taskmaster Whipfang"],
			category = "rares",
			faction = "Neutral",
		},
		[62604960] = {
			name = L["Taskmaster Whipfang"],
			category = "rares",
			faction = "Neutral",
		},
		[63205600] = {
			name = L["Taskmaster Whipfang"],
			category = "rares",
			faction = "Neutral",
		},
		[64405040] = {
			name = L["Taskmaster Whipfang"],
			category = "rares",
			faction = "Neutral",
		},
		[64405060] = {
			name = L["Taskmaster Whipfang"],
			category = "rares",
			faction = "Neutral",
		},
		[64405600] = {
			name = L["Taskmaster Whipfang"],
			category = "rares",
			faction = "Neutral",
		},
		[64805080] = {
			name = L["Taskmaster Whipfang"],
			category = "rares",
			faction = "Neutral",
		},
		[65005160] = {
			name = L["Taskmaster Whipfang"],
			category = "rares",
			faction = "Neutral",
		},
		[65005480] = {
			name = L["Taskmaster Whipfang"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1445] = {
		[67405120] = {
			name = L["Baldruc"],
			category = "flightmasters",
			fpName = L["Theramore, Dustwallow Marsh"],
			description = L["Gryphon Master"],
			faction = "Alliance",
		},
		[35603180] = {
			name = L["Shardi"],
			category = "flightmasters",
			fpName = L["Brackenwall Village, Dustwallow Marsh"],
			description = L["Wind Rider Master"],
			faction = "Horde",
		},
		[66404520] = {
			name = L["Innkeeper Janene"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Alliance",
		},
		[65904540] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Alliance",
		},
		[36403080] = {
			name = L["Krak"],
			category = "repair",
			description = L["Armorer"],
			faction = "Horde",
		},
		[36203160] = {
			name = L["Zulrg"],
			category = "repair",
			description = L["Weaponsmith"],
			faction = "Horde",
		},
		[64605040] = {
			name = L["Hans Weston"],
			category = "repair",
			description = L["Armorer & Shieldsmith"],
			faction = "Alliance",
		},
		[64605020] = {
			name = L["Marie Holdston"],
			category = "repair",
			description = L["Weaponsmith"],
			faction = "Alliance",
		},
		[67404800] = {
			name = L["Torq Ironblast"],
			category = "repair",
			description = L["Gunsmith"],
			faction = "Alliance",
		},
		[67404780] = {
			name = L["Piter Verance"],
			category = "repair",
			description = L["Weaponsmith & Armorer"],
			faction = "Alliance",
		},
		[67804980] = {
			name = L["Jensen Farran"],
			category = "repair",
			description = L["Bowyer"],
			faction = "Alliance",
		},
		[35403020] = {
			name = L["Zanara"],
			category = "repair",
			description = L["Bowyer"],
			faction = "Horde",
		},
		[39603080] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[63604300] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[66004540] = {
			name = L["Michael"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Alliance",
		},
		[64004760] = {
			name = L["Brant Jasperbloom"],
			category = "primaryProfession",
			profession = "Herbalism",
			description = L["Herbalist"],
			faction = "Alliance",
		},
		[64004780] = {
			name = L["Alchemist Narett"],
			category = "primaryProfession",
			profession = "Alchemy",
			description = L["Expert Alchemist"],
			faction = "Alliance",
		},
		[67404740] = {
			name = L["Brother Karman"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Paladin Trainer"],
			classes = {
				PALADIN = true,
			},
			faction = "Alliance",
		},
		[67804820] = {
			name = L["Captain Evencane"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warrior Trainer"],
			classes = {
				WARRIOR = true,
			},
			faction = "Alliance",
		},
		[66205160] = {
			name = L["Timothy Worthington"],
			category = "primaryProfession",
			profession = "Tailoring",
			description = L["Master Tailor"],
			faction = "Alliance",
		},
		[36603100] = {
			name = L["Ogg'marr"],
			category = "vendors",
			description = L["Butcher"],
			faction = "Horde",
		},
		[65205140] = {
			name = L["Gregor MacVince"],
			category = "vendors",
			description = L["Horse Breeder"],
			faction = "Alliance",
		},
		[68204740] = {
			name = L["Dwane Wertle"],
			category = "vendors",
			description = L["Chef"],
			faction = "Alliance",
		},
		[66604520] = {
			name = L["Bartender Lillian"],
			category = "vendors",
			description = L["Bartender"],
			faction = "Alliance",
		},
		[66804520] = {
			name = L["Craig Nollward"],
			category = "secondaryProfession",
			profession = "Cooking",
			description = L["Cook"],
			faction = "Alliance",
		},
		[67405160] = {
			name = L["Charity Mipsy"],
			category = "vendors",
			description = L["General Goods"],
			faction = "Alliance",
		},
		[66405140] = {
			name = L["Helenia Olden"],
			category = "vendors",
			description = L["Trade Supplies"],
			faction = "Alliance",
		},
		[64004765] = {
			name = L["Uma Bartulm"],
			category = "vendors",
			description = L["Herbalism & Alchemy Supplies"],
			faction = "Alliance",
		},
		[35203080] = {
			name = L["Ghok'kah"],
			category = "vendors",
			description = L["Tailoring Supplies"],
			faction = "Horde",
		},
		[36403040] = {
			name = L["Balai Lok'Wein"],
			category = "vendors",
			description = L["Potions, Scrolls and Reagents"],
			faction = "Horde",
		},
		[44408100] = {
			name = L["Brimgore"],
			category = "rares",
			faction = "Neutral",
		},
		[30202140] = {
			name = L["Darkmist Widow"],
			category = "rares",
			faction = "Neutral",
		},
		[30802060] = {
			name = L["Darkmist Widow"],
			category = "rares",
			faction = "Neutral",
		},
		[31002040] = {
			name = L["Darkmist Widow"],
			category = "rares",
			faction = "Neutral",
		},
		[56801720] = {
			name = L["Burgle Eye"],
			category = "rares",
			faction = "Neutral",
		},
		[58600800] = {
			name = L["Burgle Eye"],
			category = "rares",
			faction = "Neutral",
		},
		[59401040] = {
			name = L["Burgle Eye"],
			category = "rares",
			faction = "Neutral",
		},
		[61800720] = {
			name = L["Burgle Eye"],
			category = "rares",
			faction = "Neutral",
		},
		[62201900] = {
			name = L["Burgle Eye"],
			category = "rares",
			faction = "Neutral",
		},
		[62400820] = {
			name = L["Burgle Eye"],
			category = "rares",
			faction = "Neutral",
		},
		[62600800] = {
			name = L["Burgle Eye"],
			category = "rares",
			faction = "Neutral",
		},
		[62600920] = {
			name = L["Burgle Eye"],
			category = "rares",
			faction = "Neutral",
		},
		[63602640] = {
			name = L["Burgle Eye"],
			category = "rares",
			faction = "Neutral",
		},
		[63800840] = {
			name = L["Burgle Eye"],
			category = "rares",
			faction = "Neutral",
		},
		[64002720] = {
			name = L["Burgle Eye"],
			category = "rares",
			faction = "Neutral",
		},
		[39201960] = {
			name = L["Drogoth the Roamer"],
			category = "rares",
			faction = "Neutral",
		},
		[40202080] = {
			name = L["Drogoth the Roamer"],
			category = "rares",
			faction = "Neutral",
		},
		[41201900] = {
			name = L["Drogoth the Roamer"],
			category = "rares",
			faction = "Neutral",
		},
		[41202000] = {
			name = L["Drogoth the Roamer"],
			category = "rares",
			faction = "Neutral",
		},
		[42802200] = {
			name = L["Drogoth the Roamer"],
			category = "rares",
			faction = "Neutral",
		},
		[46401860] = {
			name = L["Dart"],
			category = "rares",
			faction = "Neutral",
		},
		[46801740] = {
			name = L["Dart"],
			category = "rares",
			faction = "Neutral",
		},
		[47001760] = {
			name = L["Dart"],
			category = "rares",
			faction = "Neutral",
		},
		[47201880] = {
			name = L["Dart"],
			category = "rares",
			faction = "Neutral",
		},
		[47401540] = {
			name = L["Dart"],
			category = "rares",
			faction = "Neutral",
		},
		[47801880] = {
			name = L["Dart"],
			category = "rares",
			faction = "Neutral",
		},
		[48201760] = {
			name = L["Dart"],
			category = "rares",
			faction = "Neutral",
		},
		[48801800] = {
			name = L["Dart"],
			category = "rares",
			faction = "Neutral",
		},
		[41805540] = {
			name = L["Ripscale"],
			category = "rares",
			faction = "Neutral",
		},
		[43805060] = {
			name = L["Ripscale"],
			category = "rares",
			faction = "Neutral",
		},
		[47605440] = {
			name = L["Ripscale"],
			category = "rares",
			faction = "Neutral",
		},
		[49005720] = {
			name = L["Ripscale"],
			category = "rares",
			faction = "Neutral",
		},
		[49405780] = {
			name = L["Ripscale"],
			category = "rares",
			faction = "Neutral",
		},
		[51406440] = {
			name = L["Hayoc"],
			category = "rares",
			faction = "Neutral",
		},
		[51806140] = {
			name = L["Hayoc"],
			category = "rares",
			faction = "Neutral",
		},
		[52806600] = {
			name = L["Hayoc"],
			category = "rares",
			faction = "Neutral",
		},
		[54006500] = {
			name = L["Hayoc"],
			category = "rares",
			faction = "Neutral",
		},
		[55406780] = {
			name = L["Hayoc"],
			category = "rares",
			faction = "Neutral",
		},
		[50804980] = {
			name = L["The Rot"],
			category = "rares",
			faction = "Neutral",
		},
		[50805800] = {
			name = L["The Rot"],
			category = "rares",
			faction = "Neutral",
		},
		[51805800] = {
			name = L["The Rot"],
			category = "rares",
			faction = "Neutral",
		},
		[52405540] = {
			name = L["The Rot"],
			category = "rares",
			faction = "Neutral",
		},
		[52805340] = {
			name = L["The Rot"],
			category = "rares",
			faction = "Neutral",
		},
		[55206140] = {
			name = L["Lord Angler"],
			category = "rares",
			faction = "Neutral",
		},
		[55206200] = {
			name = L["Lord Angler"],
			category = "rares",
			faction = "Neutral",
		},
		[57006140] = {
			name = L["Lord Angler"],
			category = "rares",
			faction = "Neutral",
		},
		[57206180] = {
			name = L["Lord Angler"],
			category = "rares",
			faction = "Neutral",
		},
		[39206340] = {
			name = L["Oozeworm"],
			category = "rares",
			faction = "Neutral",
		},
		[38802040] = {
			name = L["Drogoth the Roamer"],
			category = "rares",
			faction = "Neutral",
		},
		[48801920] = {
			name = L["Dart"],
			category = "rares",
			faction = "Neutral",
		},
		[49002080] = {
			name = L["Dart"],
			category = "rares",
			faction = "Neutral",
		},
		[49201960] = {
			name = L["Dart"],
			category = "rares",
			faction = "Neutral",
		},
		[44405000] = {
			name = L["Ripscale"],
			category = "rares",
			faction = "Neutral",
		},
		[47605480] = {
			name = L["Ripscale"],
			category = "rares",
			faction = "Neutral",
		},
		[52605960] = {
			name = L["Hayoc"],
			category = "rares",
			faction = "Neutral",
		},
		[52606620] = {
			name = L["Hayoc"],
			category = "rares",
			faction = "Neutral",
		},
		[52605160] = {
			name = L["The Rot"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1441] = {
		[45004920] = {
			name = L["Nyse"],
			category = "flightmasters",
			fpName = L["Freewind Post, Thousand Needles"],
			description = L["Wind Rider Master"],
			faction = "Horde",
		},
		[46005140] = {
			name = L["Innkeeper Abeqwa"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Horde",
		},
		[45805100] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Horde",
		},
		[80407680] = {
			name = L["Synge"],
			category = "repair",
			description = L["Gun Merchant"],
			faction = "Neutral",
		},
		[45005060] = {
			name = L["Starn"],
			category = "repair",
			description = L["Gunsmith & Bowyer"],
			faction = "Horde",
		},
		[30402340] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[45805105] = {
			name = L["Awenasa"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Horde",
		},
		[21003180] = {
			name = L["Laer Stepperunner"],
			category = "vendors",
			description = L["Food & Drink"],
			faction = "Horde",
		},
		[45405100] = {
			name = L["Turhaw"],
			category = "vendors",
			description = L["Butcher"],
			faction = "Horde",
		},
		[46005145] = {
			name = L["Jandia"],
			category = "vendors",
			description = L["Trade Supplies"],
			faction = "Horde",
		},
		[45205080] = {
			name = L["Montarr"],
			category = "vendors",
			description = L["Lorekeeper"],
			faction = "Horde",
		},
		[80007640] = {
			name = L["Riznek"],
			category = "vendors",
			description = L["Drink Vendor"],
			faction = "Neutral",
		},
		[77407700] = {
			name = L["Brivelthwerp"],
			category = "vendors",
			description = L["Ice Cream Vendor"],
			faction = "Neutral",
		},
		[78207580] = {
			name = L["Magus Tirth"],
			category = "vendors",
			faction = "Neutral",
		},
		[77607780] = {
			name = L["Jinky Twizzlefixxit"],
			category = "vendors",
			description = L["Engineering Supplies"],
			faction = "Neutral",
		},
		[64208600] = {
			name = L["Silithid Ravager"],
			category = "rares",
			faction = "Neutral",
		},
		[64808560] = {
			name = L["Silithid Ravager"],
			category = "rares",
			faction = "Neutral",
		},
		[65408520] = {
			name = L["Silithid Ravager"],
			category = "rares",
			faction = "Neutral",
		},
		[65608560] = {
			name = L["Silithid Ravager"],
			category = "rares",
			faction = "Neutral",
		},
		[67408600] = {
			name = L["Silithid Ravager"],
			category = "rares",
			faction = "Neutral",
		},
		[68408260] = {
			name = L["Silithid Ravager"],
			category = "rares",
			faction = "Neutral",
		},
		[69008160] = {
			name = L["Silithid Ravager"],
			category = "rares",
			faction = "Neutral",
		},
		[69208800] = {
			name = L["Silithid Ravager"],
			category = "rares",
			faction = "Neutral",
		},
		[70008560] = {
			name = L["Silithid Ravager"],
			category = "rares",
			faction = "Neutral",
		},
		[70608540] = {
			name = L["Silithid Ravager"],
			category = "rares",
			faction = "Neutral",
		},
		[71208580] = {
			name = L["Silithid Ravager"],
			category = "rares",
			faction = "Neutral",
		},
		[71408660] = {
			name = L["Silithid Ravager"],
			category = "rares",
			faction = "Neutral",
		},
		[18403740] = {
			name = L["Achellios the Banished"],
			category = "rares",
			faction = "Neutral",
		},
		[18803380] = {
			name = L["Achellios the Banished"],
			category = "rares",
			faction = "Neutral",
		},
		[18803880] = {
			name = L["Achellios the Banished"],
			category = "rares",
			faction = "Neutral",
		},
		[19003280] = {
			name = L["Achellios the Banished"],
			category = "rares",
			faction = "Neutral",
		},
		[19203820] = {
			name = L["Achellios the Banished"],
			category = "rares",
			faction = "Neutral",
		},
		[20003940] = {
			name = L["Achellios the Banished"],
			category = "rares",
			faction = "Neutral",
		},
		[20803160] = {
			name = L["Achellios the Banished"],
			category = "rares",
			faction = "Neutral",
		},
		[21003100] = {
			name = L["Achellios the Banished"],
			category = "rares",
			faction = "Neutral",
		},
		[22804320] = {
			name = L["Achellios the Banished"],
			category = "rares",
			faction = "Neutral",
		},
		[23804380] = {
			name = L["Achellios the Banished"],
			category = "rares",
			faction = "Neutral",
		},
		[25003620] = {
			name = L["Achellios the Banished"],
			category = "rares",
			faction = "Neutral",
		},
		[25004260] = {
			name = L["Achellios the Banished"],
			category = "rares",
			faction = "Neutral",
		},
		[25203520] = {
			name = L["Achellios the Banished"],
			category = "rares",
			faction = "Neutral",
		},
		[25203680] = {
			name = L["Achellios the Banished"],
			category = "rares",
			faction = "Neutral",
		},
		[26003960] = {
			name = L["Achellios the Banished"],
			category = "rares",
			faction = "Neutral",
		},
		[15404020] = {
			name = L["Heartrazor"],
			category = "rares",
			faction = "Neutral",
		},
		[15804020] = {
			name = L["Heartrazor"],
			category = "rares",
			faction = "Neutral",
		},
		[16004160] = {
			name = L["Heartrazor"],
			category = "rares",
			faction = "Neutral",
		},
		[16204120] = {
			name = L["Heartrazor"],
			category = "rares",
			faction = "Neutral",
		},
		[16804180] = {
			name = L["Heartrazor"],
			category = "rares",
			faction = "Neutral",
		},
		[17004120] = {
			name = L["Heartrazor"],
			category = "rares",
			faction = "Neutral",
		},
		[17404260] = {
			name = L["Heartrazor"],
			category = "rares",
			faction = "Neutral",
		},
		[17804040] = {
			name = L["Heartrazor"],
			category = "rares",
			faction = "Neutral",
		},
		[17804060] = {
			name = L["Heartrazor"],
			category = "rares",
			faction = "Neutral",
		},
		[80007660] = {
			name = L["Ironeye the Invincible"],
			category = "rares",
			faction = "Neutral",
		},
		[83607220] = {
			name = L["Ironeye the Invincible"],
			category = "rares",
			faction = "Neutral",
		},
		[84807760] = {
			name = L["Ironeye the Invincible"],
			category = "rares",
			faction = "Neutral",
		},
		[85406340] = {
			name = L["Ironeye the Invincible"],
			category = "rares",
			faction = "Neutral",
		},
		[85606860] = {
			name = L["Ironeye the Invincible"],
			category = "rares",
			faction = "Neutral",
		},
		[85806800] = {
			name = L["Ironeye the Invincible"],
			category = "rares",
			faction = "Neutral",
		},
		[85808020] = {
			name = L["Ironeye the Invincible"],
			category = "rares",
			faction = "Neutral",
		},
		[86406980] = {
			name = L["Ironeye the Invincible"],
			category = "rares",
			faction = "Neutral",
		},
		[86607480] = {
			name = L["Ironeye the Invincible"],
			category = "rares",
			faction = "Neutral",
		},
		[86607960] = {
			name = L["Ironeye the Invincible"],
			category = "rares",
			faction = "Neutral",
		},
		[86807060] = {
			name = L["Ironeye the Invincible"],
			category = "rares",
			faction = "Neutral",
		},
		[87007840] = {
			name = L["Ironeye the Invincible"],
			category = "rares",
			faction = "Neutral",
		},
		[87807620] = {
			name = L["Ironeye the Invincible"],
			category = "rares",
			faction = "Neutral",
		},
		[69606560] = {
			name = L["Vile Sting"],
			category = "rares",
			faction = "Neutral",
		},
		[69806460] = {
			name = L["Vile Sting"],
			category = "rares",
			faction = "Neutral",
		},
		[70206320] = {
			name = L["Vile Sting"],
			category = "rares",
			faction = "Neutral",
		},
		[70406880] = {
			name = L["Vile Sting"],
			category = "rares",
			faction = "Neutral",
		},
		[70607140] = {
			name = L["Vile Sting"],
			category = "rares",
			faction = "Neutral",
		},
		[71206880] = {
			name = L["Vile Sting"],
			category = "rares",
			faction = "Neutral",
		},
		[71207240] = {
			name = L["Vile Sting"],
			category = "rares",
			faction = "Neutral",
		},
		[71806940] = {
			name = L["Vile Sting"],
			category = "rares",
			faction = "Neutral",
		},
		[72407080] = {
			name = L["Vile Sting"],
			category = "rares",
			faction = "Neutral",
		},
		[73207200] = {
			name = L["Vile Sting"],
			category = "rares",
			faction = "Neutral",
		},
		[32003080] = {
			name = L["Harb Foulmountain"],
			category = "rares",
			faction = "Neutral",
		},
		[32202900] = {
			name = L["Harb Foulmountain"],
			category = "rares",
			faction = "Neutral",
		},
		[32602740] = {
			name = L["Harb Foulmountain"],
			category = "rares",
			faction = "Neutral",
		},
		[32602800] = {
			name = L["Harb Foulmountain"],
			category = "rares",
			faction = "Neutral",
		},
		[32803560] = {
			name = L["Harb Foulmountain"],
			category = "rares",
			faction = "Neutral",
		},
		[33202860] = {
			name = L["Harb Foulmountain"],
			category = "rares",
			faction = "Neutral",
		},
		[34002980] = {
			name = L["Harb Foulmountain"],
			category = "rares",
			faction = "Neutral",
		},
		[34403060] = {
			name = L["Harb Foulmountain"],
			category = "rares",
			faction = "Neutral",
		},
		[34603080] = {
			name = L["Harb Foulmountain"],
			category = "rares",
			faction = "Neutral",
		},
		[36403140] = {
			name = L["Harb Foulmountain"],
			category = "rares",
			faction = "Neutral",
		},
		[36803180] = {
			name = L["Harb Foulmountain"],
			category = "rares",
			faction = "Neutral",
		},
		[36803260] = {
			name = L["Harb Foulmountain"],
			category = "rares",
			faction = "Neutral",
		},
		[51804360] = {
			name = L["Gibblesnik"],
			category = "rares",
			faction = "Neutral",
		},
		[55805080] = {
			name = L["Gibblesnik"],
			category = "rares",
			faction = "Neutral",
		},
		[60204680] = {
			name = L["Gibblesnik"],
			category = "rares",
			faction = "Neutral",
		},
		[26204100] = {
			name = L["Achellios the Banished"],
			category = "rares",
			faction = "Neutral",
		},
		[86207880] = {
			name = L["Ironeye the Invincible"],
			category = "rares",
			faction = "Neutral",
		},
		[86407560] = {
			name = L["Ironeye the Invincible"],
			category = "rares",
			faction = "Neutral",
		},
		[87407360] = {
			name = L["Ironeye the Invincible"],
			category = "rares",
			faction = "Neutral",
		},
		[87407580] = {
			name = L["Ironeye the Invincible"],
			category = "rares",
			faction = "Neutral",
		},
		[71007400] = {
			name = L["Vile Sting"],
			category = "rares",
			faction = "Neutral",
		},
		[71607280] = {
			name = L["Vile Sting"],
			category = "rares",
			faction = "Neutral",
		},
		[71807500] = {
			name = L["Vile Sting"],
			category = "rares",
			faction = "Neutral",
		},
		[72007420] = {
			name = L["Vile Sting"],
			category = "rares",
			faction = "Neutral",
		},
		[33402880] = {
			name = L["Harb Foulmountain"],
			category = "rares",
			faction = "Neutral",
		},
		[55804880] = {
			name = L["Gibblesnik"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1444] = {
		[89404580] = {
			name = L["Thyssiana"],
			category = "flightmasters",
			fpName = L["Thalanaar, Feralas"],
			description = L["Hippogryph Master"],
			faction = "Alliance",
		},
		[30204320] = {
			name = L["Fyldren Moonfeather"],
			category = "flightmasters",
			fpName = L["Feathermoon, Feralas"],
			description = L["Hippogryph Master"],
			faction = "Alliance",
		},
		[75404420] = {
			name = L["Shyn"],
			category = "flightmasters",
			fpName = L["Camp Mojache, Feralas"],
			description = L["Wind Rider Master"],
			faction = "Horde",
		},
		[31004340] = {
			name = L["Innkeeper Shyria"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Alliance",
		},
		[74804500] = {
			name = L["Innkeeper Greul"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Horde",
		},
		[31204380] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Alliance",
		},
		[74904400] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Horde",
		},
		[89404585] = {
			name = L["Rendow"],
			category = "vendors",
			description = L["Leather Armor Merchant"],
			faction = "Alliance",
		},
		[30604260] = {
			name = L["Pratt McGrubben"],
			category = "repair",
			description = L["Leatherworking Supplies"],
			faction = "Alliance",
		},
		[74604260] = {
			name = L["Worb Strongstitch"],
			category = "repair",
			description = L["Light Armor Merchant"],
			faction = "Horde",
		},
		[74804560] = {
			name = L["Cawind Trueaim"],
			category = "repair",
			description = L["Gunsmith & Bowyer"],
			faction = "Horde",
		},
		[30804320] = {
			name = L["Dulciea Frostmoon"],
			category = "repair",
			description = L["Cloth Armor Merchant"],
			faction = "Alliance",
		},
		[31604800] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[54804760] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[73004480] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[74404320] = {
			name = L["Shyrka Wolfrunner"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Horde",
		},
		[31404320] = {
			name = L["Antarius"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Neutral",
		},
		[32204160] = {
			name = L["Brannock"],
			category = "secondaryProfession",
			profession = "Fishing",
			description = L["Fisherman"],
			faction = "Neutral",
		},
		[32604380] = {
			name = L["Kylanna Windwhisper"],
			category = "primaryProfession",
			profession = "Alchemy",
			description = L["Master Alchemist"],
			faction = "Alliance",
		},
		[31604420] = {
			name = L["Xylinnia Starshine"],
			category = "primaryProfession",
			profession = "Enchanting",
			description = L["Expert Enchanter"],
			faction = "Alliance",
		},
		[76004220] = {
			name = L["Jannos Lighthoof"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Druid Trainer"],
			classes = {
				DRUID = true,
			},
			faction = "Horde",
		},
		[74404300] = {
			name = L["Kulleg Stonehorn"],
			category = "primaryProfession",
			profession = "Skinning",
			description = L["Skinning Trainer"],
			faction = "Horde",
		},
		[76004340] = {
			name = L["Ruw"],
			category = "primaryProfession",
			profession = "Herbalism",
			description = L["Herbalism Trainer"],
			faction = "Horde",
		},
		[74404305] = {
			name = L["Hahrana Ironhide"],
			category = "primaryProfession",
			profession = "Leatherworking",
			description = L["Master Leatherworker"],
			faction = "Horde",
		},
		[74604480] = {
			name = L["Tarhus"],
			category = "vendors",
			subcategory = "reagentvendor",
			description = L["Reagent Vendor"],
			faction = "Horde",
		},
		[30804200] = {
			name = L["Jadenvis Seawatcher"],
			category = "vendors",
			subcategory = "reagentvendor",
			description = L["Reagent Vendor"],
			faction = "Alliance",
		},
		[89004580] = {
			name = L["Brienna Starglow"],
			category = "vendors",
			description = L["Tailoring Supplies"],
			faction = "Alliance",
		},
		[49201980] = {
			name = L["Kalin Windflight"],
			category = "vendors",
			faction = "Alliance",
		},
		[45002540] = {
			name = L["Gregan Brewspewer"],
			category = "vendors",
			faction = "Neutral",
		},
		[74404280] = {
			name = L["Jangdor Swiftstrider"],
			category = "vendors",
			description = L["Leatherworking Supplies"],
			faction = "Horde",
		},
		[32404380] = {
			name = L["Quintis Jonespyre"],
			category = "vendors",
			faction = "Alliance",
		},
		[31004320] = {
			name = L["Mardrack Greenwell"],
			category = "vendors",
			description = L["Food & Drink"],
			faction = "Alliance",
		},
		[30604340] = {
			name = L["Faralorn"],
			category = "vendors",
			description = L["General Supplies"],
			faction = "Alliance",
		},
		[31004620] = {
			name = L["Harklane"],
			category = "vendors",
			description = L["Fish Vendor"],
			faction = "Alliance",
		},
		[31004625] = {
			name = L["Savanne"],
			category = "vendors",
			description = L["Fishing Supplies"],
			faction = "Alliance",
		},
		[31204340] = {
			name = L["Vivianna"],
			category = "vendors",
			description = L["Trade Supplies"],
			faction = "Alliance",
		},
		[75404380] = {
			name = L["Loorana"],
			category = "vendors",
			description = L["Food & Drink"],
			faction = "Horde",
		},
		[74404285] = {
			name = L["Sheendra Tallgrass"],
			category = "vendors",
			description = L["Trade Supplies"],
			faction = "Horde",
		},
		[32604400] = {
			name = L["Logannas"],
			category = "vendors",
			description = L["Alchemy Supplies"],
			faction = "Alliance",
		},
		[76004320] = {
			name = L["Bronk"],
			category = "vendors",
			description = L["Alchemy Supplies"],
			faction = "Horde",
		},
		[44804340] = {
			name = L["Zorbin Fandazzle"],
			category = "vendors",
			faction = "Neutral",
		},
		[24607280] = {
			name = L["Lady Szallah"],
			category = "rares",
			faction = "Neutral",
		},
		[26406560] = {
			name = L["Lady Szallah"],
			category = "rares",
			faction = "Neutral",
		},
		[27206880] = {
			name = L["Lady Szallah"],
			category = "rares",
			faction = "Neutral",
		},
		[28006780] = {
			name = L["Lady Szallah"],
			category = "rares",
			faction = "Neutral",
		},
		[51005980] = {
			name = L["Bloodroar the Stalker"],
			category = "rares",
			faction = "Neutral",
		},
		[52006080] = {
			name = L["Bloodroar the Stalker"],
			category = "rares",
			faction = "Neutral",
		},
		[52206020] = {
			name = L["Bloodroar the Stalker"],
			category = "rares",
			faction = "Neutral",
		},
		[55607480] = {
			name = L["Antilus the Soarer"],
			category = "rares",
			faction = "Neutral",
		},
		[58207360] = {
			name = L["Antilus the Soarer"],
			category = "rares",
			faction = "Neutral",
		},
		[39402300] = {
			name = L["Arash-ethis"],
			category = "rares",
			faction = "Neutral",
		},
		[41202420] = {
			name = L["Arash-ethis"],
			category = "rares",
			faction = "Neutral",
		},
		[41402500] = {
			name = L["Arash-ethis"],
			category = "rares",
			faction = "Neutral",
		},
		[42402340] = {
			name = L["Arash-ethis"],
			category = "rares",
			faction = "Neutral",
		},
		[44602280] = {
			name = L["Arash-ethis"],
			category = "rares",
			faction = "Neutral",
		},
		[46002540] = {
			name = L["Arash-ethis"],
			category = "rares",
			faction = "Neutral",
		},
		[46002620] = {
			name = L["Arash-ethis"],
			category = "rares",
			faction = "Neutral",
		},
		[72006420] = {
			name = L["Qirot"],
			category = "rares",
			faction = "Neutral",
		},
		[74006260] = {
			name = L["Qirot"],
			category = "rares",
			faction = "Neutral",
		},
		[74006460] = {
			name = L["Qirot"],
			category = "rares",
			faction = "Neutral",
		},
		[76606560] = {
			name = L["Qirot"],
			category = "rares",
			faction = "Neutral",
		},
		[77806220] = {
			name = L["Qirot"],
			category = "rares",
			faction = "Neutral",
		},
		[77806360] = {
			name = L["Qirot"],
			category = "rares",
			faction = "Neutral",
		},
		[60405940] = {
			name = L["Old Grizzlegut"],
			category = "rares",
			faction = "Neutral",
		},
		[66204740] = {
			name = L["Old Grizzlegut"],
			category = "rares",
			faction = "Neutral",
		},
		[69204700] = {
			name = L["Old Grizzlegut"],
			category = "rares",
			faction = "Neutral",
		},
		[75403880] = {
			name = L["Snarler"],
			category = "rares",
			faction = "Neutral",
		},
		[76203800] = {
			name = L["Snarler"],
			category = "rares",
			faction = "Neutral",
		},
		[76803900] = {
			name = L["Snarler"],
			category = "rares",
			faction = "Neutral",
		},
		[78003860] = {
			name = L["Snarler"],
			category = "rares",
			faction = "Neutral",
		},
		[81403940] = {
			name = L["Snarler"],
			category = "rares",
			faction = "Neutral",
		},
		[82203980] = {
			name = L["Snarler"],
			category = "rares",
			faction = "Neutral",
		},
		[51805960] = {
			name = L["Bloodroar the Stalker"],
			category = "rares",
			faction = "Neutral",
		},
		[54807420] = {
			name = L["Antilus the Soarer"],
			category = "rares",
			faction = "Neutral",
		},
		[39402200] = {
			name = L["Arash-ethis"],
			category = "rares",
			faction = "Neutral",
		},
		[40402220] = {
			name = L["Arash-ethis"],
			category = "rares",
			faction = "Neutral",
		},
		[40602200] = {
			name = L["Arash-ethis"],
			category = "rares",
			faction = "Neutral",
		},
		[46002340] = {
			name = L["Arash-ethis"],
			category = "rares",
			faction = "Neutral",
		},
		[74206260] = {
			name = L["Qirot"],
			category = "rares",
			faction = "Neutral",
		},
		[74206460] = {
			name = L["Qirot"],
			category = "rares",
			faction = "Neutral",
		},
		[78006400] = {
			name = L["Qirot"],
			category = "rares",
			faction = "Neutral",
		},
		[57805760] = {
			name = L["Old Grizzlegut"],
			category = "rares",
			faction = "Neutral",
		},
		[58005700] = {
			name = L["Old Grizzlegut"],
			category = "rares",
			faction = "Neutral",
		},
		[68604840] = {
			name = L["Old Grizzlegut"],
			category = "rares",
			faction = "Neutral",
		},
		[75203680] = {
			name = L["Snarler"],
			category = "rares",
			faction = "Neutral",
		},
		[76004345] = {
			name = L["Snarler"],
			category = "rares",
			faction = "Neutral",
		},
		[77603820] = {
			name = L["Snarler"],
			category = "rares",
			faction = "Neutral",
		},
		[79203760] = {
			name = L["Snarler"],
			category = "rares",
			faction = "Neutral",
		},
		[79403860] = {
			name = L["Snarler"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1448] = {
		[34405380] = {
			name = L["Brakkar"],
			category = "flightmasters",
			fpName = L["Bloodvenom Post, Felwood"],
			description = L["Wind Rider Master"],
			faction = "Horde",
		},
		[62402420] = {
			name = L["Mishellena"],
			category = "flightmasters",
			fpName = L["Talonbranch Glade, Felwood"],
			description = L["Hippogryph Master"],
			faction = "Alliance",
		},
		[34805300] = {
			name = L["Altsoba Ragetotem"],
			category = "repair",
			description = L["Weapon Merchant"],
			faction = "Horde",
		},
		[62402580] = {
			name = L["Mylini Frostmoon"],
			category = "repair",
			description = L["Weapon Merchant"],
			faction = "Alliance",
		},
		[49603080] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[62202420] = {
			name = L["Nalesette Wildbringer"],
			category = "trainers",
			description = L["Pet Trainer"],
			faction = "Alliance",
		},
		[61802360] = {
			name = L["Kaerbrus"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Hunter Trainer"],
			classes = {
				HUNTER = true,
			},
			faction = "Neutral",
		},
		[62002440] = {
			name = L["Golhine the Hooded"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Druid Trainer"],
			classes = {
				DRUID = true,
			},
			faction = "Alliance",
		},
		[62202560] = {
			name = L["Malygen"],
			category = "vendors",
			description = L["General Goods"],
			faction = "Alliance",
		},
		[34605300] = {
			name = L["Bale"],
			category = "vendors",
			description = L["General Goods"],
			faction = "Horde",
		},
		[58201760] = {
			name = L["Dessecus"],
			category = "rares",
			faction = "Neutral",
		},
		[38803820] = {
			name = L["Immolatus"],
			category = "rares",
			faction = "Neutral",
		},
		[38804220] = {
			name = L["Immolatus"],
			category = "rares",
			faction = "Neutral",
		},
		[39804280] = {
			name = L["Immolatus"],
			category = "rares",
			faction = "Neutral",
		},
		[43004060] = {
			name = L["Immolatus"],
			category = "rares",
			faction = "Neutral",
		},
		[43203920] = {
			name = L["Immolatus"],
			category = "rares",
			faction = "Neutral",
		},
		[44604160] = {
			name = L["Immolatus"],
			category = "rares",
			faction = "Neutral",
		},
		[45804040] = {
			name = L["Immolatus"],
			category = "rares",
			faction = "Neutral",
		},
		[46204060] = {
			name = L["Immolatus"],
			category = "rares",
			faction = "Neutral",
		},
		[47203940] = {
			name = L["Immolatus"],
			category = "rares",
			faction = "Neutral",
		},
		[48407840] = {
			name = L["Death Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[38808160] = {
			name = L["Alshirr Banebreath"],
			category = "rares",
			faction = "Neutral",
		},
		[47609260] = {
			name = L["Ragepaw"],
			category = "rares",
			faction = "Neutral",
		},
		[48409120] = {
			name = L["Ragepaw"],
			category = "rares",
			faction = "Neutral",
		},
		[48409180] = {
			name = L["Ragepaw"],
			category = "rares",
			faction = "Neutral",
		},
		[48608980] = {
			name = L["Ragepaw"],
			category = "rares",
			faction = "Neutral",
		},
		[48609160] = {
			name = L["Ragepaw"],
			category = "rares",
			faction = "Neutral",
		},
		[58201840] = {
			name = L["Olm the Wise"],
			category = "rares",
			faction = "Neutral",
		},
		[40607900] = {
			name = L["Mongress"],
			category = "rares",
			faction = "Neutral",
		},
		[57801960] = {
			name = L["Dessecus"],
			category = "rares",
			faction = "Neutral",
		},
		[58601860] = {
			name = L["Dessecus"],
			category = "rares",
			faction = "Neutral",
		},
		[42204180] = {
			name = L["Immolatus"],
			category = "rares",
			faction = "Neutral",
		},
		[43004020] = {
			name = L["Immolatus"],
			category = "rares",
			faction = "Neutral",
		},
		[43804240] = {
			name = L["Immolatus"],
			category = "rares",
			faction = "Neutral",
		},
		[44603780] = {
			name = L["Immolatus"],
			category = "rares",
			faction = "Neutral",
		},
		[46204220] = {
			name = L["Immolatus"],
			category = "rares",
			faction = "Neutral",
		},
		[46604300] = {
			name = L["Immolatus"],
			category = "rares",
			faction = "Neutral",
		},
		[40208400] = {
			name = L["Alshirr Banebreath"],
			category = "rares",
			faction = "Neutral",
		},
		[40608600] = {
			name = L["Alshirr Banebreath"],
			category = "rares",
			faction = "Neutral",
		},
		[43008540] = {
			name = L["Alshirr Banebreath"],
			category = "rares",
			faction = "Neutral",
		},
		[43008580] = {
			name = L["Alshirr Banebreath"],
			category = "rares",
			faction = "Neutral",
		},
		[48209180] = {
			name = L["Ragepaw"],
			category = "rares",
			faction = "Neutral",
		},
		[48809120] = {
			name = L["Ragepaw"],
			category = "rares",
			faction = "Neutral",
		},
		[48809180] = {
			name = L["Ragepaw"],
			category = "rares",
			faction = "Neutral",
		},
		[54802560] = {
			name = L["Olm the Wise"],
			category = "rares",
			faction = "Neutral",
		},
		[43007680] = {
			name = L["Mongress"],
			category = "rares",
			faction = "Neutral",
		},
		[42804760] = {
			name = L["The Ongar"],
			category = "rares",
			faction = "Neutral",
		},
		[43205040] = {
			name = L["The Ongar"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1447] = {
		[22004960] = {
			name = L["Kroum"],
			category = "flightmasters",
			fpName = L["Valormok, Azshara"],
			description = L["Wind Rider Master"],
			faction = "Horde",
		},
		[11807740] = {
			name = L["Jarrodenus"],
			category = "flightmasters",
			fpName = L["Talrendis Point, Azshara"],
			description = L["Hippogryph Master"],
			faction = "Alliance",
		},
		[22205120] = {
			name = L["Gruul Darkblade"],
			category = "repair",
			description = L["Weaponsmith"],
			faction = "Horde",
		},
		[12007820] = {
			name = L["Brinna Valanaar"],
			category = "repair",
			description = L["Bowyer"],
			faction = "Alliance",
		},
		[70401560] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[21805200] = {
			name = L["Kurll"],
			category = "vendors",
			description = L["Food & Drink"],
			faction = "Horde",
		},
		[13407240] = {
			name = L["Varo'then's Ghost"],
			category = "rares",
			faction = "Neutral",
		},
		[13407480] = {
			name = L["Varo'then's Ghost"],
			category = "rares",
			faction = "Neutral",
		},
		[13607300] = {
			name = L["Varo'then's Ghost"],
			category = "rares",
			faction = "Neutral",
		},
		[14007200] = {
			name = L["Varo'then's Ghost"],
			category = "rares",
			faction = "Neutral",
		},
		[15807080] = {
			name = L["Varo'then's Ghost"],
			category = "rares",
			faction = "Neutral",
		},
		[16207220] = {
			name = L["Varo'then's Ghost"],
			category = "rares",
			faction = "Neutral",
		},
		[16406900] = {
			name = L["Varo'then's Ghost"],
			category = "rares",
			faction = "Neutral",
		},
		[16606960] = {
			name = L["Varo'then's Ghost"],
			category = "rares",
			faction = "Neutral",
		},
		[17006900] = {
			name = L["Varo'then's Ghost"],
			category = "rares",
			faction = "Neutral",
		},
		[17406840] = {
			name = L["Varo'then's Ghost"],
			category = "rares",
			faction = "Neutral",
		},
		[17606920] = {
			name = L["Varo'then's Ghost"],
			category = "rares",
			faction = "Neutral",
		},
		[17806660] = {
			name = L["Varo'then's Ghost"],
			category = "rares",
			faction = "Neutral",
		},
		[59403120] = {
			name = L["Magister Hawkhelm"],
			category = "rares",
			faction = "Neutral",
		},
		[17005460] = {
			name = L["Antilos"],
			category = "rares",
			faction = "Neutral",
		},
		[17606020] = {
			name = L["Antilos"],
			category = "rares",
			faction = "Neutral",
		},
		[48602320] = {
			name = L["Antilos"],
			category = "rares",
			faction = "Neutral",
		},
		[51002960] = {
			name = L["Antilos"],
			category = "rares",
			faction = "Neutral",
		},
		[54802420] = {
			name = L["Antilos"],
			category = "rares",
			faction = "Neutral",
		},
		[55402040] = {
			name = L["Antilos"],
			category = "rares",
			faction = "Neutral",
		},
		[35205680] = {
			name = L["Lady Sesspira"],
			category = "rares",
			faction = "Neutral",
		},
		[36405340] = {
			name = L["Lady Sesspira"],
			category = "rares",
			faction = "Neutral",
		},
		[36405700] = {
			name = L["Lady Sesspira"],
			category = "rares",
			faction = "Neutral",
		},
		[36605380] = {
			name = L["Lady Sesspira"],
			category = "rares",
			faction = "Neutral",
		},
		[36805220] = {
			name = L["Lady Sesspira"],
			category = "rares",
			faction = "Neutral",
		},
		[36805480] = {
			name = L["Lady Sesspira"],
			category = "rares",
			faction = "Neutral",
		},
		[37005720] = {
			name = L["Lady Sesspira"],
			category = "rares",
			faction = "Neutral",
		},
		[39004840] = {
			name = L["Lady Sesspira"],
			category = "rares",
			faction = "Neutral",
		},
		[39604660] = {
			name = L["Lady Sesspira"],
			category = "rares",
			faction = "Neutral",
		},
		[39604840] = {
			name = L["Lady Sesspira"],
			category = "rares",
			faction = "Neutral",
		},
		[39605520] = {
			name = L["Lady Sesspira"],
			category = "rares",
			faction = "Neutral",
		},
		[39804860] = {
			name = L["Lady Sesspira"],
			category = "rares",
			faction = "Neutral",
		},
		[41205420] = {
			name = L["General Fangferror"],
			category = "rares",
			faction = "Neutral",
		},
		[39603360] = {
			name = L["Gatekeeper Rageroar"],
			category = "rares",
			faction = "Neutral",
		},
		[17205340] = {
			name = L["The Evalcharr"],
			category = "rares",
			faction = "Neutral",
		},
		[54004900] = {
			name = L["Scalebeard"],
			category = "rares",
			faction = "Neutral",
		},
		[13407300] = {
			name = L["Varo'then's Ghost"],
			category = "rares",
			faction = "Neutral",
		},
		[14807220] = {
			name = L["Varo'then's Ghost"],
			category = "rares",
			faction = "Neutral",
		},
		[15007300] = {
			name = L["Varo'then's Ghost"],
			category = "rares",
			faction = "Neutral",
		},
		[16007300] = {
			name = L["Varo'then's Ghost"],
			category = "rares",
			faction = "Neutral",
		},
		[16406880] = {
			name = L["Varo'then's Ghost"],
			category = "rares",
			faction = "Neutral",
		},
		[16606760] = {
			name = L["Varo'then's Ghost"],
			category = "rares",
			faction = "Neutral",
		},
		[16806660] = {
			name = L["Varo'then's Ghost"],
			category = "rares",
			faction = "Neutral",
		},
		[17006920] = {
			name = L["Varo'then's Ghost"],
			category = "rares",
			faction = "Neutral",
		},
		[17606940] = {
			name = L["Varo'then's Ghost"],
			category = "rares",
			faction = "Neutral",
		},
		[17607020] = {
			name = L["Varo'then's Ghost"],
			category = "rares",
			faction = "Neutral",
		},
		[56407820] = {
			name = L["Monnos the Elder"],
			category = "rares",
			faction = "Neutral",
		},
		[57002880] = {
			name = L["Magister Hawkhelm"],
			category = "rares",
			faction = "Neutral",
		},
		[50202840] = {
			name = L["Antilos"],
			category = "rares",
			faction = "Neutral",
		},
		[52803060] = {
			name = L["Antilos"],
			category = "rares",
			faction = "Neutral",
		},
		[35805700] = {
			name = L["Lady Sesspira"],
			category = "rares",
			faction = "Neutral",
		},
		[36404800] = {
			name = L["Lady Sesspira"],
			category = "rares",
			faction = "Neutral",
		},
		[36405300] = {
			name = L["Lady Sesspira"],
			category = "rares",
			faction = "Neutral",
		},
		[36804800] = {
			name = L["Lady Sesspira"],
			category = "rares",
			faction = "Neutral",
		},
		[38605580] = {
			name = L["Lady Sesspira"],
			category = "rares",
			faction = "Neutral",
		},
		[39804560] = {
			name = L["Lady Sesspira"],
			category = "rares",
			faction = "Neutral",
		},
		[38203200] = {
			name = L["Gatekeeper Rageroar"],
			category = "rares",
			faction = "Neutral",
		},
		[61802560] = {
			name = L["Master Feardred"],
			category = "rares",
			faction = "Neutral",
		},
		[17806665] = {
			name = L["The Evalcharr"],
			category = "rares",
			faction = "Neutral",
		},
		[18206580] = {
			name = L["The Evalcharr"],
			category = "rares",
			faction = "Neutral",
		},
		[23405500] = {
			name = L["The Evalcharr"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1439] = {
		[36404560] = {
			name = L["Caylais Moonfeather"],
			category = "flightmasters",
			fpName = L["Auberdine, Darkshore"],
			description = L["Hippogryph Master"],
			faction = "Alliance",
		},
		[37004400] = {
			name = L["Innkeeper Shaussiy"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Alliance",
		},
		[37304380] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Alliance",
		},
		[37604040] = {
			name = L["Naram Longclaw"],
			category = "repair",
			description = L["Weaponsmith"],
			faction = "Alliance",
		},
		[38204040] = {
			name = L["Shaldyn"],
			category = "repair",
			description = L["Clothier"],
			faction = "Alliance",
		},
		[37004120] = {
			name = L["Mavralyn"],
			category = "repair",
			description = L["Leather Armor & Leatherworking Supplies"],
			faction = "Alliance",
		},
		[37004125] = {
			name = L["Harlon Thornguard"],
			category = "vendors",
			description = L["Armorer & Shieldsmith"],
			faction = "Alliance",
		},
		[38204120] = {
			name = L["Elisa Steelhand"],
			category = "repair",
			description = L["Blacksmithing Supplies"],
			faction = "Alliance",
		},
		[41803640] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[43409240] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[37404420] = {
			name = L["Jaelysia"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Alliance",
		},
		[38204045] = {
			name = L["Grondal Moonbreeze"],
			category = "primaryProfession",
			profession = "Tailoring",
			description = L["Journeyman Tailor"],
			faction = "Alliance",
		},
		[38204100] = {
			name = L["Kurdram Stonehammer"],
			category = "primaryProfession",
			profession = "Mining",
			description = L["Mining Trainer"],
			faction = "Alliance",
		},
		[38204105] = {
			name = L["Jenna Lemkenilli"],
			category = "primaryProfession",
			profession = "Engineering",
			description = L["Journeyman Engineer"],
			faction = "Alliance",
		},
		[37404040] = {
			name = L["Dalmond"],
			category = "vendors",
			description = L["General Goods"],
			faction = "Alliance",
		},
		[38004060] = {
			name = L["Valdaron"],
			category = "vendors",
			description = L["Tailoring Supplies"],
			faction = "Alliance",
		},
		[36804440] = {
			name = L["Kyndri"],
			category = "vendors",
			description = L["Baker"],
			faction = "Alliance",
		},
		[37004360] = {
			name = L["Allyndia"],
			category = "vendors",
			description = L["Food & Drink Vendor"],
			faction = "Alliance",
		},
		[36804380] = {
			name = L["Taldan"],
			category = "vendors",
			description = L["Drink Vendor"],
			faction = "Alliance",
		},
		[43807640] = {
			name = L["Ullanna"],
			category = "vendors",
			description = L["Trade Supplies"],
			faction = "Alliance",
		},
		[43607660] = {
			name = L["Tiyani"],
			category = "vendors",
			description = L["Food & Drink Vendor"],
			faction = "Alliance",
		},
		[36804420] = {
			name = L["Laird"],
			category = "vendors",
			description = L["Fish Vendor"],
			faction = "Alliance",
		},
		[37005620] = {
			name = L["Heldan Galesong"],
			category = "secondaryProfession",
			profession = "Fishing",
			description = L["Fisherman"],
			faction = "Alliance",
		},
		[38204125] = {
			name = L["Thelgrum Stonehammer"],
			category = "vendors",
			description = L["Mining Supplier"],
			faction = "Alliance",
		},
		[38004120] = {
			name = L["Gorbold Steelhand"],
			category = "vendors",
			description = L["General Trade Supplier"],
			faction = "Alliance",
		},
		[36004480] = {
			name = L["Gubber Blump"],
			category = "vendors",
			faction = "Alliance",
		},
		[34408620] = {
			name = L["Strider Clutchmother"],
			category = "rares",
			faction = "Neutral",
		},
		[34408700] = {
			name = L["Strider Clutchmother"],
			category = "rares",
			faction = "Neutral",
		},
		[34408900] = {
			name = L["Strider Clutchmother"],
			category = "rares",
			faction = "Neutral",
		},
		[34608680] = {
			name = L["Strider Clutchmother"],
			category = "rares",
			faction = "Neutral",
		},
		[34608860] = {
			name = L["Strider Clutchmother"],
			category = "rares",
			faction = "Neutral",
		},
		[34808800] = {
			name = L["Strider Clutchmother"],
			category = "rares",
			faction = "Neutral",
		},
		[35808840] = {
			name = L["Strider Clutchmother"],
			category = "rares",
			faction = "Neutral",
		},
		[36009040] = {
			name = L["Strider Clutchmother"],
			category = "rares",
			faction = "Neutral",
		},
		[36209080] = {
			name = L["Strider Clutchmother"],
			category = "rares",
			faction = "Neutral",
		},
		[36609120] = {
			name = L["Strider Clutchmother"],
			category = "rares",
			faction = "Neutral",
		},
		[36809340] = {
			name = L["Strider Clutchmother"],
			category = "rares",
			faction = "Neutral",
		},
		[37209380] = {
			name = L["Strider Clutchmother"],
			category = "rares",
			faction = "Neutral",
		},
		[37409220] = {
			name = L["Strider Clutchmother"],
			category = "rares",
			faction = "Neutral",
		},
		[37609120] = {
			name = L["Strider Clutchmother"],
			category = "rares",
			faction = "Neutral",
		},
		[37609200] = {
			name = L["Strider Clutchmother"],
			category = "rares",
			faction = "Neutral",
		},
		[37609320] = {
			name = L["Strider Clutchmother"],
			category = "rares",
			faction = "Neutral",
		},
		[38809380] = {
			name = L["Strider Clutchmother"],
			category = "rares",
			faction = "Neutral",
		},
		[39009140] = {
			name = L["Strider Clutchmother"],
			category = "rares",
			faction = "Neutral",
		},
		[39009340] = {
			name = L["Strider Clutchmother"],
			category = "rares",
			faction = "Neutral",
		},
		[39409160] = {
			name = L["Strider Clutchmother"],
			category = "rares",
			faction = "Neutral",
		},
		[39609040] = {
			name = L["Strider Clutchmother"],
			category = "rares",
			faction = "Neutral",
		},
		[39609220] = {
			name = L["Strider Clutchmother"],
			category = "rares",
			faction = "Neutral",
		},
		[39809120] = {
			name = L["Strider Clutchmother"],
			category = "rares",
			faction = "Neutral",
		},
		[40609300] = {
			name = L["Strider Clutchmother"],
			category = "rares",
			faction = "Neutral",
		},
		[38803440] = {
			name = L["Shadowclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[39003600] = {
			name = L["Shadowclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[39203780] = {
			name = L["Shadowclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[39403700] = {
			name = L["Shadowclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[39404020] = {
			name = L["Shadowclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[39804280] = {
			name = L["Shadowclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[40003500] = {
			name = L["Shadowclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[40003800] = {
			name = L["Shadowclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[40203880] = {
			name = L["Shadowclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[40204000] = {
			name = L["Shadowclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[40403560] = {
			name = L["Shadowclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[40404080] = {
			name = L["Shadowclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[40604060] = {
			name = L["Shadowclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[40804020] = {
			name = L["Shadowclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[40804180] = {
			name = L["Shadowclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[41003800] = {
			name = L["Shadowclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[41203680] = {
			name = L["Shadowclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[41606160] = {
			name = L["Lady Moongazer"],
			category = "rares",
			faction = "Neutral",
		},
		[42005880] = {
			name = L["Lady Moongazer"],
			category = "rares",
			faction = "Neutral",
		},
		[43006120] = {
			name = L["Lady Moongazer"],
			category = "rares",
			faction = "Neutral",
		},
		[43205960] = {
			name = L["Lady Moongazer"],
			category = "rares",
			faction = "Neutral",
		},
		[43206240] = {
			name = L["Lady Moongazer"],
			category = "rares",
			faction = "Neutral",
		},
		[43406280] = {
			name = L["Lady Moongazer"],
			category = "rares",
			faction = "Neutral",
		},
		[43605920] = {
			name = L["Lady Moongazer"],
			category = "rares",
			faction = "Neutral",
		},
		[37005020] = {
			name = L["Carnivous the Breaker"],
			category = "rares",
			faction = "Neutral",
		},
		[38005140] = {
			name = L["Carnivous the Breaker"],
			category = "rares",
			faction = "Neutral",
		},
		[38805120] = {
			name = L["Carnivous the Breaker"],
			category = "rares",
			faction = "Neutral",
		},
		[38805360] = {
			name = L["Carnivous the Breaker"],
			category = "rares",
			faction = "Neutral",
		},
		[39005340] = {
			name = L["Carnivous the Breaker"],
			category = "rares",
			faction = "Neutral",
		},
		[39007960] = {
			name = L["Carnivous the Breaker"],
			category = "rares",
			faction = "Neutral",
		},
		[39205220] = {
			name = L["Carnivous the Breaker"],
			category = "rares",
			faction = "Neutral",
		},
		[39207760] = {
			name = L["Carnivous the Breaker"],
			category = "rares",
			faction = "Neutral",
		},
		[39407860] = {
			name = L["Carnivous the Breaker"],
			category = "rares",
			faction = "Neutral",
		},
		[39605260] = {
			name = L["Carnivous the Breaker"],
			category = "rares",
			faction = "Neutral",
		},
		[39605400] = {
			name = L["Carnivous the Breaker"],
			category = "rares",
			faction = "Neutral",
		},
		[39607820] = {
			name = L["Carnivous the Breaker"],
			category = "rares",
			faction = "Neutral",
		},
		[40207740] = {
			name = L["Carnivous the Breaker"],
			category = "rares",
			faction = "Neutral",
		},
		[40207920] = {
			name = L["Carnivous the Breaker"],
			category = "rares",
			faction = "Neutral",
		},
		[40605320] = {
			name = L["Carnivous the Breaker"],
			category = "rares",
			faction = "Neutral",
		},
		[42208440] = {
			name = L["Carnivous the Breaker"],
			category = "rares",
			faction = "Neutral",
		},
		[42808320] = {
			name = L["Carnivous the Breaker"],
			category = "rares",
			faction = "Neutral",
		},
		[43008380] = {
			name = L["Carnivous the Breaker"],
			category = "rares",
			faction = "Neutral",
		},
		[43208480] = {
			name = L["Carnivous the Breaker"],
			category = "rares",
			faction = "Neutral",
		},
		[43608640] = {
			name = L["Carnivous the Breaker"],
			category = "rares",
			faction = "Neutral",
		},
		[44008720] = {
			name = L["Carnivous the Breaker"],
			category = "rares",
			faction = "Neutral",
		},
		[44403660] = {
			name = L["Licillin"],
			category = "rares",
			faction = "Neutral",
		},
		[44803780] = {
			name = L["Licillin"],
			category = "rares",
			faction = "Neutral",
		},
		[45203640] = {
			name = L["Licillin"],
			category = "rares",
			faction = "Neutral",
		},
		[45203660] = {
			name = L["Licillin"],
			category = "rares",
			faction = "Neutral",
		},
		[46003920] = {
			name = L["Licillin"],
			category = "rares",
			faction = "Neutral",
		},
		[46803660] = {
			name = L["Licillin"],
			category = "rares",
			faction = "Neutral",
		},
		[47203780] = {
			name = L["Licillin"],
			category = "rares",
			faction = "Neutral",
		},
		[47603720] = {
			name = L["Licillin"],
			category = "rares",
			faction = "Neutral",
		},
		[38408620] = {
			name = L["Firecaller Radison"],
			category = "rares",
			faction = "Neutral",
		},
		[38408700] = {
			name = L["Firecaller Radison"],
			category = "rares",
			faction = "Neutral",
		},
		[38608760] = {
			name = L["Firecaller Radison"],
			category = "rares",
			faction = "Neutral",
		},
		[39008520] = {
			name = L["Firecaller Radison"],
			category = "rares",
			faction = "Neutral",
		},
		[39008640] = {
			name = L["Firecaller Radison"],
			category = "rares",
			faction = "Neutral",
		},
		[39008660] = {
			name = L["Firecaller Radison"],
			category = "rares",
			faction = "Neutral",
		},
		[35407260] = {
			name = L["Flagglemurk the Cruel"],
			category = "rares",
			faction = "Neutral",
		},
		[35807260] = {
			name = L["Flagglemurk the Cruel"],
			category = "rares",
			faction = "Neutral",
		},
		[36407000] = {
			name = L["Flagglemurk the Cruel"],
			category = "rares",
			faction = "Neutral",
		},
		[36407080] = {
			name = L["Flagglemurk the Cruel"],
			category = "rares",
			faction = "Neutral",
		},
		[36407160] = {
			name = L["Flagglemurk the Cruel"],
			category = "rares",
			faction = "Neutral",
		},
		[36807080] = {
			name = L["Flagglemurk the Cruel"],
			category = "rares",
			faction = "Neutral",
		},
		[37406120] = {
			name = L["Flagglemurk the Cruel"],
			category = "rares",
			faction = "Neutral",
		},
		[37406240] = {
			name = L["Flagglemurk the Cruel"],
			category = "rares",
			faction = "Neutral",
		},
		[37606160] = {
			name = L["Flagglemurk the Cruel"],
			category = "rares",
			faction = "Neutral",
		},
		[38206140] = {
			name = L["Flagglemurk the Cruel"],
			category = "rares",
			faction = "Neutral",
		},
		[42602140] = {
			name = L["Flagglemurk the Cruel"],
			category = "rares",
			faction = "Neutral",
		},
		[43402040] = {
			name = L["Flagglemurk the Cruel"],
			category = "rares",
			faction = "Neutral",
		},
		[44202040] = {
			name = L["Flagglemurk the Cruel"],
			category = "rares",
			faction = "Neutral",
		},
		[44402060] = {
			name = L["Flagglemurk the Cruel"],
			category = "rares",
			faction = "Neutral",
		},
		[57402120] = {
			name = L["Lady Vespira"],
			category = "rares",
			faction = "Neutral",
		},
		[57402260] = {
			name = L["Lady Vespira"],
			category = "rares",
			faction = "Neutral",
		},
		[58001720] = {
			name = L["Lady Vespira"],
			category = "rares",
			faction = "Neutral",
		},
		[58002140] = {
			name = L["Lady Vespira"],
			category = "rares",
			faction = "Neutral",
		},
		[58602400] = {
			name = L["Lady Vespira"],
			category = "rares",
			faction = "Neutral",
		},
		[59201660] = {
			name = L["Lady Vespira"],
			category = "rares",
			faction = "Neutral",
		},
		[59602620] = {
			name = L["Lady Vespira"],
			category = "rares",
			faction = "Neutral",
		},
		[59802340] = {
			name = L["Lady Vespira"],
			category = "rares",
			faction = "Neutral",
		},
		[60602180] = {
			name = L["Lady Vespira"],
			category = "rares",
			faction = "Neutral",
		},
		[61202320] = {
			name = L["Lady Vespira"],
			category = "rares",
			faction = "Neutral",
		},
		[61401860] = {
			name = L["Lady Vespira"],
			category = "rares",
			faction = "Neutral",
		},
		[61801780] = {
			name = L["Lady Vespira"],
			category = "rares",
			faction = "Neutral",
		},
		[55003520] = {
			name = L["Lord Sinslayer"],
			category = "rares",
			faction = "Neutral",
		},
		[56603420] = {
			name = L["Lord Sinslayer"],
			category = "rares",
			faction = "Neutral",
		},
		[34808520] = {
			name = L["Strider Clutchmother"],
			category = "rares",
			faction = "Neutral",
		},
		[34808740] = {
			name = L["Strider Clutchmother"],
			category = "rares",
			faction = "Neutral",
		},
		[39809160] = {
			name = L["Strider Clutchmother"],
			category = "rares",
			faction = "Neutral",
		},
		[40204060] = {
			name = L["Shadowclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[41403680] = {
			name = L["Shadowclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[42203820] = {
			name = L["Shadowclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[43406260] = {
			name = L["Lady Moongazer"],
			category = "rares",
			faction = "Neutral",
		},
		[46803640] = {
			name = L["Licillin"],
			category = "rares",
			faction = "Neutral",
		},
		[47603640] = {
			name = L["Licillin"],
			category = "rares",
			faction = "Neutral",
		},
		[38608740] = {
			name = L["Firecaller Radison"],
			category = "rares",
			faction = "Neutral",
		},
		[43002140] = {
			name = L["Flagglemurk the Cruel"],
			category = "rares",
			faction = "Neutral",
		},
		[54603640] = {
			name = L["Lord Sinslayer"],
			category = "rares",
			faction = "Neutral",
		},
		[54803660] = {
			name = L["Lord Sinslayer"],
			category = "rares",
			faction = "Neutral",
		},
		[56403480] = {
			name = L["Lord Sinslayer"],
			category = "rares",
			faction = "Neutral",
		},
		[56603460] = {
			name = L["Lord Sinslayer"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1449] = {
		[45200580] = {
			name = L["Gryfe"],
			category = "flightmasters",
			fpName = L["Marshal's Refuge, Un'Goro Crater"],
			description = L["Flight Master"],
			faction = "Neutral",
		},
		[44000720] = {
			name = L["Gibbert"],
			category = "repair",
			description = L["Weapon Merchant"],
			faction = "Neutral",
		},
		[80004980] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[43200760] = {
			name = L["Nergal"],
			category = "vendors",
			description = L["General Goods Vendor"],
			faction = "Neutral",
		},
		[62006440] = {
			name = L["Ravasaur Matriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[65006820] = {
			name = L["Ravasaur Matriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[49408320] = {
			name = L["Clutchmother Zavas"],
			category = "rares",
			faction = "Neutral",
		},
		[49408400] = {
			name = L["Clutchmother Zavas"],
			category = "rares",
			faction = "Neutral",
		},
		[30404620] = {
			name = L["King Mosh"],
			category = "rares",
			faction = "Neutral",
		},
		[31203520] = {
			name = L["King Mosh"],
			category = "rares",
			faction = "Neutral",
		},
		[31604800] = {
			name = L["King Mosh"],
			category = "rares",
			faction = "Neutral",
		},
		[31804700] = {
			name = L["King Mosh"],
			category = "rares",
			faction = "Neutral",
		},
		[32003520] = {
			name = L["King Mosh"],
			category = "rares",
			faction = "Neutral",
		},
		[34003560] = {
			name = L["King Mosh"],
			category = "rares",
			faction = "Neutral",
		},
		[36202920] = {
			name = L["King Mosh"],
			category = "rares",
			faction = "Neutral",
		},
		[67001420] = {
			name = L["Uhk'loc"],
			category = "rares",
			faction = "Neutral",
		},
		[68401420] = {
			name = L["Uhk'loc"],
			category = "rares",
			faction = "Neutral",
		},
		[68601420] = {
			name = L["Uhk'loc"],
			category = "rares",
			faction = "Neutral",
		},
		[68801540] = {
			name = L["Uhk'loc"],
			category = "rares",
			faction = "Neutral",
		},
		[69401680] = {
			name = L["Uhk'loc"],
			category = "rares",
			faction = "Neutral",
		},
		[67006260] = {
			name = L["Ravasaur Matriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[44608160] = {
			name = L["Clutchmother Zavas"],
			category = "rares",
			faction = "Neutral",
		},
		[48808500] = {
			name = L["Clutchmother Zavas"],
			category = "rares",
			faction = "Neutral",
		},
		[29003600] = {
			name = L["King Mosh"],
			category = "rares",
			faction = "Neutral",
		},
		[37003120] = {
			name = L["King Mosh"],
			category = "rares",
			faction = "Neutral",
		},
		[68201200] = {
			name = L["Uhk'loc"],
			category = "rares",
			faction = "Neutral",
		},
		[68601220] = {
			name = L["Uhk'loc"],
			category = "rares",
			faction = "Neutral",
		},
		[68601300] = {
			name = L["Uhk'loc"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1450] = {
		[48006720] = {
			name = L["Sindrayl"],
			category = "flightmasters",
			fpName = L["Moonglade"],
			description = L["Hippogryph Master"],
			faction = "Alliance",
		},
		[32206640] = {
			name = L["Faustron"],
			category = "flightmasters",
			fpName = L["Moonglade"],
			description = L["Wind Rider Master"],
			faction = "Horde",
		},
		[51803300] = {
			name = L["Geenia Sunshadow"],
			category = "repair",
			description = L["Speciality Dress Maker"],
			faction = "Neutral",
		},
		[56403000] = {
			name = L["Kharedon"],
			category = "repair",
			description = L["Light Armor Merchant"],
			faction = "Neutral",
		},
		[51204220] = {
			name = L["Meliri"],
			category = "repair",
			description = L["Weaponsmith"],
			faction = "Neutral",
		},
		[53204280] = {
			name = L["Narianna"],
			category = "repair",
			description = L["Bowyer"],
			faction = "Alliance",
		},
		[45604680] = {
			name = L["Malvor"],
			category = "primaryProfession",
			profession = "Herbalism",
			description = L["Herbalist"],
			faction = "Neutral",
		},
		[52404040] = {
			name = L["Loganaar"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Druid Trainer"],
			classes = {
				DRUID = true,
			},
			faction = "Neutral",
		},
		[51603320] = {
			name = L["Darnall"],
			category = "vendors",
			description = L["Tailoring Supplies"],
			faction = "Neutral",
		},
		[48603920] = {
			name = L["Dargon"],
			category = "vendors",
			description = L["Food & Drink Merchant"],
			faction = "Neutral",
		},
		[45203460] = {
			name = L["Daeolyn Summerleaf"],
			category = "vendors",
			description = L["General Goods"],
			faction = "Neutral",
		},
		[48404020] = {
			name = L["Lorelae Wintersong"],
			category = "vendors",
			description = L["Trade Supplies"],
			faction = "Neutral",
		},
		[44403400] = {
			name = L["My'lanna"],
			category = "vendors",
			description = L["Food & Drink Merchant"],
			faction = "Neutral",
		},
		[44404540] = {
			name = L["Bunthen Plainswind"],
			category = "flightmasters",
			fpName = L["Thunder Bluff Flight Master"],
			description = L["Thunder Bluff Flight Master"],
			classes = {
				DRUID = true,
			},
			faction = "Horde",
		},
		[44204520] = {
			name = L["Silva Fil'naveth"],
			category = "flightmasters",
			fpName = L["Darnassus Flight Master"],
			description = L["Darnassus Flight Master"],
			classes = {
				DRUID = true,
			},
			faction = "Alliance",
		},
	}
	nodes[1451] = {
		[50603440] = {
			name = L["Cloud Skydancer"],
			category = "flightmasters",
			fpName = L["Cenarion Hold, Silithus"],
			description = L["Hippogryph Master"],
			faction = "Alliance",
		},
		[48803660] = {
			name = L["Runk Windtamer"],
			category = "flightmasters",
			fpName = L["Cenarion Hold, Silithus"],
			description = L["Wind Rider Master"],
			faction = "Horde",
		},
		[51803900] = {
			name = L["Calandrath"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Neutral",
		},
		[51703780] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Neutral",
		},
		[81801780] = {
			name = L["Zannok Hidepiercer"],
			category = "vendors",
			description = L["Leatherworking Supplies"],
			faction = "Neutral",
		},
		[48803700] = {
			name = L["Khur Hornstriker"],
			category = "vendors",
			subcategory = "reagentvendor",
			description = L["Reagent Vendor"],
			faction = "Neutral",
		},
		[26802640] = {
			name = L["Huricanian"],
			category = "rares",
			faction = "Neutral",
		},
		[19602260] = {
			name = L["Huricanian"],
			category = "rares",
			faction = "Neutral",
		},
		[22202620] = {
			name = L["Huricanian"],
			category = "rares",
			faction = "Neutral",
		},
		[29201880] = {
			name = L["Huricanian"],
			category = "rares",
			faction = "Neutral",
		},
		[29801720] = {
			name = L["Huricanian"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1438] = {
		[58409400] = {
			name = L["Vesprystus"],
			category = "flightmasters",
			fpName = L["Rut'theran Village, Teldrassil"],
			description = L["Hippogryph Master"],
			faction = "Alliance",
		},
		[55605980] = {
			name = L["Innkeeper Keldamyr"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Alliance",
		},
		[56105840] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Alliance",
		},
		[58803960] = {
			name = L["Khardan Proudblade"],
			category = "repair",
			description = L["Weaponsmith"],
			faction = "Alliance",
		},
		[59404120] = {
			name = L["Keina"],
			category = "repair",
			description = L["Bowyer"],
			faction = "Alliance",
		},
		[59404100] = {
			name = L["Janna Brightmoon"],
			category = "repair",
			description = L["Clothier"],
			faction = "Alliance",
		},
		[59003960] = {
			name = L["Freja Nightwing"],
			category = "repair",
			description = L["Leather Armor Merchant"],
			faction = "Alliance",
		},
		[58603980] = {
			name = L["Andiss"],
			category = "repair",
			description = L["Armorer & Shieldcrafter"],
			faction = "Alliance",
		},
		[56205940] = {
			name = L["Shalomon"],
			category = "repair",
			description = L["Weaponsmith"],
			faction = "Alliance",
		},
		[55805920] = {
			name = L["Jeena Featherbow"],
			category = "repair",
			description = L["Bowyer"],
			faction = "Alliance",
		},
		[56206020] = {
			name = L["Brannol Eaglemoon"],
			category = "repair",
			description = L["Clothier"],
			faction = "Alliance",
		},
		[56205960] = {
			name = L["Sinda"],
			category = "repair",
			description = L["Leather Armor Merchant"],
			faction = "Alliance",
		},
		[56205945] = {
			name = L["Meri Ironweave"],
			category = "vendors",
			description = L["Armorer & Shieldcrafter"],
			faction = "Alliance",
		},
		[56206320] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[58604240] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[56605960] = {
			name = L["Seriadne"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Alliance",
		},
		[56805960] = {
			name = L["Keldas"],
			category = "trainers",
			description = L["Pet Trainer"],
			faction = "Alliance",
		},
		[59603840] = {
			name = L["Alyissia"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warrior Trainer"],
			classes = {
				WARRIOR = true,
			},
			faction = "Alliance",
		},
		[59603860] = {
			name = L["Frahun Shadewhisper"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Rogue Trainer"],
			classes = {
				ROGUE = true,
			},
			faction = "Alliance",
		},
		[59204040] = {
			name = L["Shanda"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Priest Trainer"],
			classes = {
				PRIEST = true,
			},
			faction = "Alliance",
		},
		[58604040] = {
			name = L["Ayanna Everstride"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Hunter Trainer"],
			classes = {
				HUNTER = true,
			},
			faction = "Alliance",
		},
		[58604045] = {
			name = L["Mardant Strongoak"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Druid Trainer"],
			classes = {
				DRUID = true,
			},
			faction = "Alliance",
		},
		[56205920] = {
			name = L["Kyra Windblade"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warrior Trainer"],
			classes = {
				WARRIOR = true,
			},
			faction = "Alliance",
		},
		[56206000] = {
			name = L["Jannok Breezesong"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Rogue Trainer"],
			classes = {
				ROGUE = true,
			},
			faction = "Alliance",
		},
		[55605680] = {
			name = L["Laurna Morninglight"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Priest Trainer"],
			classes = {
				PRIEST = true,
			},
			faction = "Alliance",
		},
		[56605940] = {
			name = L["Dazalar"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Hunter Trainer"],
			classes = {
				HUNTER = true,
			},
			faction = "Alliance",
		},
		[56006160] = {
			name = L["Kal"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Druid Trainer"],
			classes = {
				DRUID = true,
			},
			faction = "Alliance",
		},
		[57606060] = {
			name = L["Cyndra Kindwhisper"],
			category = "primaryProfession",
			profession = "Alchemy",
			description = L["Journeyman Alchemist"],
			faction = "Alliance",
		},
		[57606065] = {
			name = L["Malorne Bladeleaf"],
			category = "primaryProfession",
			profession = "Herbalism",
			description = L["Herbalist"],
			faction = "Alliance",
		},
		[41804940] = {
			name = L["Nadyia Maneweaver"],
			category = "primaryProfession",
			profession = "Leatherworking",
			description = L["Journeyman Leatherworker"],
			faction = "Alliance",
		},
		[36603420] = {
			name = L["Alanna Raveneye"],
			category = "primaryProfession",
			profession = "Enchanting",
			description = L["Journeyman Enchanter"],
			faction = "Alliance",
		},
		[55809340] = {
			name = L["Androl Oakhand"],
			category = "secondaryProfession",
			profession = "Fishing",
			description = L["Fisherman"],
			faction = "Alliance",
		},
		[55205680] = {
			name = L["Byancie"],
			category = "secondaryProfession",
			profession = "First Aid",
			description = L["First Aid Trainer"],
			faction = "Alliance",
		},
		[57006120] = {
			name = L["Zarrin"],
			category = "secondaryProfession",
			profession = "Cooking",
			description = L["Cook"],
			faction = "Alliance",
		},
		[42005000] = {
			name = L["Radnaal Maneweaver"],
			category = "primaryProfession",
			profession = "Skinning",
			description = L["Skinner"],
			faction = "Alliance",
		},
		[59404105] = {
			name = L["Lyrai"],
			category = "vendors",
			description = L["General Supplies"],
			faction = "Alliance",
		},
		[55405720] = {
			name = L["Aldia"],
			category = "vendors",
			description = L["General Supplies"],
			faction = "Alliance",
		},
		[55205700] = {
			name = L["Narret Shadowgrove"],
			category = "vendors",
			description = L["Trade Supplies"],
			faction = "Alliance",
		},
		[57206120] = {
			name = L["Nyoma"],
			category = "vendors",
			description = L["Cooking Supplies"],
			faction = "Alliance",
		},
		[55405725] = {
			name = L["Danlyia"],
			category = "vendors",
			description = L["Food & Drink Vendor"],
			faction = "Alliance",
		},
		[59604080] = {
			name = L["Dellylah"],
			category = "vendors",
			description = L["Food & Drink Vendor"],
			faction = "Alliance",
		},
		[56209240] = {
			name = L["Nessa Shadowsong"],
			category = "vendors",
			description = L["Fishing Supplies"],
			faction = "Alliance",
		},
		[41603700] = {
			name = L["Blackmoss the Fetid"],
			category = "rares",
			faction = "Neutral",
		},
		[41802920] = {
			name = L["Blackmoss the Fetid"],
			category = "rares",
			faction = "Neutral",
		},
		[42003800] = {
			name = L["Blackmoss the Fetid"],
			category = "rares",
			faction = "Neutral",
		},
		[42003920] = {
			name = L["Blackmoss the Fetid"],
			category = "rares",
			faction = "Neutral",
		},
		[42202560] = {
			name = L["Blackmoss the Fetid"],
			category = "rares",
			faction = "Neutral",
		},
		[42202840] = {
			name = L["Blackmoss the Fetid"],
			category = "rares",
			faction = "Neutral",
		},
		[42602820] = {
			name = L["Blackmoss the Fetid"],
			category = "rares",
			faction = "Neutral",
		},
		[42802880] = {
			name = L["Blackmoss the Fetid"],
			category = "rares",
			faction = "Neutral",
		},
		[42803740] = {
			name = L["Blackmoss the Fetid"],
			category = "rares",
			faction = "Neutral",
		},
		[43002560] = {
			name = L["Blackmoss the Fetid"],
			category = "rares",
			faction = "Neutral",
		},
		[43002700] = {
			name = L["Blackmoss the Fetid"],
			category = "rares",
			faction = "Neutral",
		},
		[43603000] = {
			name = L["Blackmoss the Fetid"],
			category = "rares",
			faction = "Neutral",
		},
		[43802940] = {
			name = L["Blackmoss the Fetid"],
			category = "rares",
			faction = "Neutral",
		},
		[44202780] = {
			name = L["Blackmoss the Fetid"],
			category = "rares",
			faction = "Neutral",
		},
		[44602740] = {
			name = L["Blackmoss the Fetid"],
			category = "rares",
			faction = "Neutral",
		},
		[65805720] = {
			name = L["Uruson"],
			category = "rares",
			faction = "Neutral",
		},
		[66005800] = {
			name = L["Uruson"],
			category = "rares",
			faction = "Neutral",
		},
		[66205900] = {
			name = L["Uruson"],
			category = "rares",
			faction = "Neutral",
		},
		[66406020] = {
			name = L["Uruson"],
			category = "rares",
			faction = "Neutral",
		},
		[66805800] = {
			name = L["Uruson"],
			category = "rares",
			faction = "Neutral",
		},
		[67005640] = {
			name = L["Uruson"],
			category = "rares",
			faction = "Neutral",
		},
		[67005680] = {
			name = L["Uruson"],
			category = "rares",
			faction = "Neutral",
		},
		[67005880] = {
			name = L["Uruson"],
			category = "rares",
			faction = "Neutral",
		},
		[67005980] = {
			name = L["Uruson"],
			category = "rares",
			faction = "Neutral",
		},
		[67605940] = {
			name = L["Uruson"],
			category = "rares",
			faction = "Neutral",
		},
		[67805840] = {
			name = L["Uruson"],
			category = "rares",
			faction = "Neutral",
		},
		[67805980] = {
			name = L["Uruson"],
			category = "rares",
			faction = "Neutral",
		},
		[67806120] = {
			name = L["Uruson"],
			category = "rares",
			faction = "Neutral",
		},
		[39207940] = {
			name = L["Grimmaw"],
			category = "rares",
			faction = "Neutral",
		},
		[39408020] = {
			name = L["Grimmaw"],
			category = "rares",
			faction = "Neutral",
		},
		[39808060] = {
			name = L["Grimmaw"],
			category = "rares",
			faction = "Neutral",
		},
		[40407940] = {
			name = L["Grimmaw"],
			category = "rares",
			faction = "Neutral",
		},
		[40407960] = {
			name = L["Grimmaw"],
			category = "rares",
			faction = "Neutral",
		},
		[40607960] = {
			name = L["Grimmaw"],
			category = "rares",
			faction = "Neutral",
		},
		[41007880] = {
			name = L["Grimmaw"],
			category = "rares",
			faction = "Neutral",
		},
		[41207840] = {
			name = L["Grimmaw"],
			category = "rares",
			faction = "Neutral",
		},
		[41407460] = {
			name = L["Grimmaw"],
			category = "rares",
			faction = "Neutral",
		},
		[41407680] = {
			name = L["Grimmaw"],
			category = "rares",
			faction = "Neutral",
		},
		[41607800] = {
			name = L["Grimmaw"],
			category = "rares",
			faction = "Neutral",
		},
		[41607860] = {
			name = L["Grimmaw"],
			category = "rares",
			faction = "Neutral",
		},
		[42407960] = {
			name = L["Grimmaw"],
			category = "rares",
			faction = "Neutral",
		},
		[42608000] = {
			name = L["Grimmaw"],
			category = "rares",
			faction = "Neutral",
		},
		[51207700] = {
			name = L["Duskstalker"],
			category = "rares",
			faction = "Neutral",
		},
		[51607760] = {
			name = L["Duskstalker"],
			category = "rares",
			faction = "Neutral",
		},
		[51807720] = {
			name = L["Duskstalker"],
			category = "rares",
			faction = "Neutral",
		},
		[52607740] = {
			name = L["Duskstalker"],
			category = "rares",
			faction = "Neutral",
		},
		[53607620] = {
			name = L["Duskstalker"],
			category = "rares",
			faction = "Neutral",
		},
		[53807680] = {
			name = L["Duskstalker"],
			category = "rares",
			faction = "Neutral",
		},
		[54807740] = {
			name = L["Duskstalker"],
			category = "rares",
			faction = "Neutral",
		},
		[58007500] = {
			name = L["Duskstalker"],
			category = "rares",
			faction = "Neutral",
		},
		[58007580] = {
			name = L["Duskstalker"],
			category = "rares",
			faction = "Neutral",
		},
		[58407680] = {
			name = L["Duskstalker"],
			category = "rares",
			faction = "Neutral",
		},
		[58607620] = {
			name = L["Duskstalker"],
			category = "rares",
			faction = "Neutral",
		},
		[58607660] = {
			name = L["Duskstalker"],
			category = "rares",
			faction = "Neutral",
		},
		[59807520] = {
			name = L["Duskstalker"],
			category = "rares",
			faction = "Neutral",
		},
		[60207600] = {
			name = L["Duskstalker"],
			category = "rares",
			faction = "Neutral",
		},
		[60407380] = {
			name = L["Duskstalker"],
			category = "rares",
			faction = "Neutral",
		},
		[60607420] = {
			name = L["Duskstalker"],
			category = "rares",
			faction = "Neutral",
		},
		[60607540] = {
			name = L["Duskstalker"],
			category = "rares",
			faction = "Neutral",
		},
		[34203440] = {
			name = L["Fury Shelda"],
			category = "rares",
			faction = "Neutral",
		},
		[34403460] = {
			name = L["Fury Shelda"],
			category = "rares",
			faction = "Neutral",
		},
		[35203540] = {
			name = L["Fury Shelda"],
			category = "rares",
			faction = "Neutral",
		},
		[35403580] = {
			name = L["Fury Shelda"],
			category = "rares",
			faction = "Neutral",
		},
		[35403660] = {
			name = L["Fury Shelda"],
			category = "rares",
			faction = "Neutral",
		},
		[35403760] = {
			name = L["Fury Shelda"],
			category = "rares",
			faction = "Neutral",
		},
		[35603540] = {
			name = L["Fury Shelda"],
			category = "rares",
			faction = "Neutral",
		},
		[35603700] = {
			name = L["Fury Shelda"],
			category = "rares",
			faction = "Neutral",
		},
		[35803560] = {
			name = L["Fury Shelda"],
			category = "rares",
			faction = "Neutral",
		},
		[36203800] = {
			name = L["Fury Shelda"],
			category = "rares",
			faction = "Neutral",
		},
		[36403880] = {
			name = L["Fury Shelda"],
			category = "rares",
			faction = "Neutral",
		},
		[36603780] = {
			name = L["Fury Shelda"],
			category = "rares",
			faction = "Neutral",
		},
		[36603920] = {
			name = L["Fury Shelda"],
			category = "rares",
			faction = "Neutral",
		},
		[37003460] = {
			name = L["Fury Shelda"],
			category = "rares",
			faction = "Neutral",
		},
		[37004080] = {
			name = L["Fury Shelda"],
			category = "rares",
			faction = "Neutral",
		},
		[37004160] = {
			name = L["Fury Shelda"],
			category = "rares",
			faction = "Neutral",
		},
		[37404000] = {
			name = L["Fury Shelda"],
			category = "rares",
			faction = "Neutral",
		},
		[37404260] = {
			name = L["Fury Shelda"],
			category = "rares",
			faction = "Neutral",
		},
		[37604040] = {
			name = L["Fury Shelda"],
			category = "rares",
			faction = "Neutral",
		},
		[37604280] = {
			name = L["Fury Shelda"],
			category = "rares",
			faction = "Neutral",
		},
		[37804240] = {
			name = L["Fury Shelda"],
			category = "rares",
			faction = "Neutral",
		},
		[51205040] = {
			name = L["Threggil"],
			category = "rares",
			faction = "Neutral",
		},
		[51205080] = {
			name = L["Threggil"],
			category = "rares",
			faction = "Neutral",
		},
		[51605160] = {
			name = L["Threggil"],
			category = "rares",
			faction = "Neutral",
		},
		[52205040] = {
			name = L["Threggil"],
			category = "rares",
			faction = "Neutral",
		},
		[52205060] = {
			name = L["Threggil"],
			category = "rares",
			faction = "Neutral",
		},
		[52605240] = {
			name = L["Threggil"],
			category = "rares",
			faction = "Neutral",
		},
		[42603780] = {
			name = L["Blackmoss the Fetid"],
			category = "rares",
			faction = "Neutral",
		},
		[44002800] = {
			name = L["Blackmoss the Fetid"],
			category = "rares",
			faction = "Neutral",
		},
		[67405960] = {
			name = L["Uruson"],
			category = "rares",
			faction = "Neutral",
		},
		[40208060] = {
			name = L["Grimmaw"],
			category = "rares",
			faction = "Neutral",
		},
		[41607820] = {
			name = L["Grimmaw"],
			category = "rares",
			faction = "Neutral",
		},
		[53407700] = {
			name = L["Duskstalker"],
			category = "rares",
			faction = "Neutral",
		},
		[58207640] = {
			name = L["Duskstalker"],
			category = "rares",
			faction = "Neutral",
		},
		[60207480] = {
			name = L["Duskstalker"],
			category = "rares",
			faction = "Neutral",
		},
		[60607620] = {
			name = L["Duskstalker"],
			category = "rares",
			faction = "Neutral",
		},
		[35403540] = {
			name = L["Fury Shelda"],
			category = "rares",
			faction = "Neutral",
		},
		[37404160] = {
			name = L["Fury Shelda"],
			category = "rares",
			faction = "Neutral",
		},
		[37604060] = {
			name = L["Fury Shelda"],
			category = "rares",
			faction = "Neutral",
		},
		[51405040] = {
			name = L["Threggil"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1418] = {
		[4004480] = {
			name = L["Gorrik"],
			category = "flightmasters",
			fpName = L["Kargath, Badlands"],
			description = L["Wind Rider Master"],
			faction = "Horde",
		},
		[2804580] = {
			name = L["Innkeeper Shul'kar"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Horde",
		},
		[3904730] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Horde",
		},
		[3004740] = {
			name = L["Sranda"],
			category = "repair",
			description = L["Light Armor & Weapons Merchant"],
			faction = "Horde",
		},
		[42405260] = {
			name = L["Jazzrik"],
			category = "repair",
			description = L["Blacksmithing Supplies"],
			faction = "Neutral",
		},
		[57002460] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[3804760] = {
			name = L["Greth"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Horde",
		},
		[3004600] = {
			name = L["Grawl"],
			category = "vendors",
			description = L["General Goods"],
			faction = "Horde",
		},
		[39602800] = {
			name = L["Shadowforge Commander"],
			category = "rares",
			faction = "Neutral",
		},
		[40402640] = {
			name = L["Shadowforge Commander"],
			category = "rares",
			faction = "Neutral",
		},
		[40402860] = {
			name = L["Shadowforge Commander"],
			category = "rares",
			faction = "Neutral",
		},
		[7006200] = {
			name = L["Siege Golem"],
			category = "rares",
			faction = "Neutral",
		},
		[11806560] = {
			name = L["Siege Golem"],
			category = "rares",
			faction = "Neutral",
		},
		[14606680] = {
			name = L["Siege Golem"],
			category = "rares",
			faction = "Neutral",
		},
		[15006440] = {
			name = L["Siege Golem"],
			category = "rares",
			faction = "Neutral",
		},
		[19406000] = {
			name = L["Siege Golem"],
			category = "rares",
			faction = "Neutral",
		},
		[20405960] = {
			name = L["Siege Golem"],
			category = "rares",
			faction = "Neutral",
		},
		[20605800] = {
			name = L["Siege Golem"],
			category = "rares",
			faction = "Neutral",
		},
		[21406000] = {
			name = L["Siege Golem"],
			category = "rares",
			faction = "Neutral",
		},
		[22404700] = {
			name = L["Siege Golem"],
			category = "rares",
			faction = "Neutral",
		},
		[23405900] = {
			name = L["Siege Golem"],
			category = "rares",
			faction = "Neutral",
		},
		[30204660] = {
			name = L["Siege Golem"],
			category = "rares",
			faction = "Neutral",
		},
		[32005540] = {
			name = L["Siege Golem"],
			category = "rares",
			faction = "Neutral",
		},
		[34204360] = {
			name = L["Siege Golem"],
			category = "rares",
			faction = "Neutral",
		},
		[34604220] = {
			name = L["Siege Golem"],
			category = "rares",
			faction = "Neutral",
		},
		[35604300] = {
			name = L["Siege Golem"],
			category = "rares",
			faction = "Neutral",
		},
		[37004200] = {
			name = L["Siege Golem"],
			category = "rares",
			faction = "Neutral",
		},
		[37804820] = {
			name = L["Siege Golem"],
			category = "rares",
			faction = "Neutral",
		},
		[39404040] = {
			name = L["Siege Golem"],
			category = "rares",
			faction = "Neutral",
		},
		[43003200] = {
			name = L["War Golem"],
			category = "rares",
			faction = "Neutral",
		},
		[44403240] = {
			name = L["War Golem"],
			category = "rares",
			faction = "Neutral",
		},
		[44603580] = {
			name = L["War Golem"],
			category = "rares",
			faction = "Neutral",
		},
		[45203180] = {
			name = L["War Golem"],
			category = "rares",
			faction = "Neutral",
		},
		[47601140] = {
			name = L["War Golem"],
			category = "rares",
			faction = "Neutral",
		},
		[51802760] = {
			name = L["War Golem"],
			category = "rares",
			faction = "Neutral",
		},
		[2207880] = {
			name = L["Rumbler"],
			category = "rares",
			faction = "Neutral",
		},
		[3407880] = {
			name = L["Rumbler"],
			category = "rares",
			faction = "Neutral",
		},
		[3607820] = {
			name = L["Rumbler"],
			category = "rares",
			faction = "Neutral",
		},
		[3607940] = {
			name = L["Rumbler"],
			category = "rares",
			faction = "Neutral",
		},
		[3608120] = {
			name = L["Rumbler"],
			category = "rares",
			faction = "Neutral",
		},
		[4608120] = {
			name = L["Rumbler"],
			category = "rares",
			faction = "Neutral",
		},
		[4608160] = {
			name = L["Rumbler"],
			category = "rares",
			faction = "Neutral",
		},
		[14208980] = {
			name = L["Rumbler"],
			category = "rares",
			faction = "Neutral",
		},
		[14408860] = {
			name = L["Rumbler"],
			category = "rares",
			faction = "Neutral",
		},
		[14409100] = {
			name = L["Rumbler"],
			category = "rares",
			faction = "Neutral",
		},
		[14608760] = {
			name = L["Rumbler"],
			category = "rares",
			faction = "Neutral",
		},
		[16208600] = {
			name = L["Rumbler"],
			category = "rares",
			faction = "Neutral",
		},
		[16808560] = {
			name = L["Rumbler"],
			category = "rares",
			faction = "Neutral",
		},
		[3805040] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[4404540] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[9406520] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[10607400] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[10806380] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[11007500] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[12606720] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[13606460] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[14006600] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[15006540] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[16006860] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[16806980] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[17008140] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[19006080] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[22605420] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[24605180] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[25204920] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[25205020] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[25605260] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[28204540] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[35407240] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[36606960] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[36607100] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[38405520] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[39605640] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[41405440] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[42205280] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[42407280] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[42805300] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[43005420] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[43407260] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[44207300] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[44405280] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[45005340] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[45005380] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[45405120] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[45604900] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[45807300] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[46404680] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[47004980] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[48005080] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[48207320] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[48804760] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[49007360] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[49607200] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[50004600] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[50207400] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[50807060] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[50807460] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[51605080] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[52406980] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[52607380] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[54007000] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[54206640] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[55005420] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[56405580] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[56405940] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[45003600] = {
			name = L["Broken Tooth"],
			category = "rares",
			faction = "Neutral",
		},
		[45403680] = {
			name = L["Broken Tooth"],
			category = "rares",
			faction = "Neutral",
		},
		[45603620] = {
			name = L["Broken Tooth"],
			category = "rares",
			faction = "Neutral",
		},
		[52201540] = {
			name = L["Broken Tooth"],
			category = "rares",
			faction = "Neutral",
		},
		[52601580] = {
			name = L["Broken Tooth"],
			category = "rares",
			faction = "Neutral",
		},
		[53401720] = {
			name = L["Broken Tooth"],
			category = "rares",
			faction = "Neutral",
		},
		[53601680] = {
			name = L["Broken Tooth"],
			category = "rares",
			faction = "Neutral",
		},
		[54001520] = {
			name = L["Broken Tooth"],
			category = "rares",
			faction = "Neutral",
		},
		[54201200] = {
			name = L["Broken Tooth"],
			category = "rares",
			faction = "Neutral",
		},
		[54401560] = {
			name = L["Broken Tooth"],
			category = "rares",
			faction = "Neutral",
		},
		[54601640] = {
			name = L["Broken Tooth"],
			category = "rares",
			faction = "Neutral",
		},
		[55201700] = {
			name = L["Broken Tooth"],
			category = "rares",
			faction = "Neutral",
		},
		[61804300] = {
			name = L["Broken Tooth"],
			category = "rares",
			faction = "Neutral",
		},
		[62003040] = {
			name = L["Broken Tooth"],
			category = "rares",
			faction = "Neutral",
		},
		[62003280] = {
			name = L["Broken Tooth"],
			category = "rares",
			faction = "Neutral",
		},
		[62603100] = {
			name = L["Broken Tooth"],
			category = "rares",
			faction = "Neutral",
		},
		[63203020] = {
			name = L["Broken Tooth"],
			category = "rares",
			faction = "Neutral",
		},
		[22805460] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[28807400] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[31805560] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[31806820] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[32005320] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[32605780] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[32804620] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[33405200] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[33605720] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[33805280] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[33805580] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[33805860] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[33806640] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[34205080] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[34206480] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[34206760] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[34206920] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[34206960] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[34806480] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[35206440] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[35206660] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[35206840] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[35606700] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[35806860] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[36006480] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[36206580] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[36405500] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[36605560] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[36806040] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[36806600] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[36806740] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[36806780] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[36807360] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[37805380] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[38007140] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[38605380] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[38806560] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[39806900] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[40207060] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[41007080] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[41205380] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[41405880] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[53406460] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[53804560] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[53806640] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[54406500] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[55006100] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[56806100] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[56806340] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[57205820] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[57406480] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[57606060] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[58806000] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[40202660] = {
			name = L["Shadowforge Commander"],
			category = "rares",
			faction = "Neutral",
		},
		[41002620] = {
			name = L["Shadowforge Commander"],
			category = "rares",
			faction = "Neutral",
		},
		[45403300] = {
			name = L["War Golem"],
			category = "rares",
			faction = "Neutral",
		},
		[15808840] = {
			name = L["Rumbler"],
			category = "rares",
			faction = "Neutral",
		},
		[11607240] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[12206840] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[12206980] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[12406940] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[12407060] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[13006900] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[13807020] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[14408000] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[15407960] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[37205440] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[44405100] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[48604020] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[52405240] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[52605200] = {
			name = L["Anathemus"],
			category = "rares",
			faction = "Neutral",
		},
		[43603820] = {
			name = L["Broken Tooth"],
			category = "rares",
			faction = "Neutral",
		},
		[44203640] = {
			name = L["Broken Tooth"],
			category = "rares",
			faction = "Neutral",
		},
		[45003940] = {
			name = L["Broken Tooth"],
			category = "rares",
			faction = "Neutral",
		},
		[61203080] = {
			name = L["Broken Tooth"],
			category = "rares",
			faction = "Neutral",
		},
		[61403440] = {
			name = L["Broken Tooth"],
			category = "rares",
			faction = "Neutral",
		},
		[61603180] = {
			name = L["Broken Tooth"],
			category = "rares",
			faction = "Neutral",
		},
		[62003060] = {
			name = L["Broken Tooth"],
			category = "rares",
			faction = "Neutral",
		},
		[32005160] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[32605140] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[33204920] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[33406640] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[34205240] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[35804880] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[35806760] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[36604200] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[37206920] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[38805340] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[39005660] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[39805580] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[52206120] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[52405840] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[54005920] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[55005840] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[55006260] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[55806120] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[56606240] = {
			name = L["Zaricotl"],
			category = "rares",
			faction = "Neutral",
		},
		[19408060] = {
			name = L["7:XT"],
			category = "rares",
			description = L["Long Distance Recovery Unit"],
			faction = "Neutral",
		},
	}
	nodes[1424] = {
		[60201860] = {
			name = L["Zarise"],
			category = "flightmasters",
			fpName = L["Tarren Mill, Hillsbrad"],
			description = L["Bat Handler"],
			faction = "Horde",
		},
		[49405240] = {
			name = L["Darla Harris"],
			category = "flightmasters",
			fpName = L["Southshore, Hillsbrad"],
			description = L["Gryphon Master"],
			faction = "Alliance",
		},
		[51205880] = {
			name = L["Innkeeper Anderson"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Alliance",
		},
		[62601900] = {
			name = L["Innkeeper Shay"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Horde",
		},
		[50405860] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Alliance",
		},
		[62401980] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Horde",
		},
		[80003900] = {
			name = L["Kris Legace"],
			category = "repair",
			description = L["Freewheeling Tradeswoman"],
			faction = "Horde",
		},
		[51004800] = {
			name = L["Zixil"],
			category = "repair",
			description = L["Merchant Supreme"],
			faction = "Neutral",
		},
		[60402600] = {
			name = L["Ott"],
			category = "repair",
			description = L["Weaponsmith"],
			faction = "Horde",
		},
		[51205700] = {
			name = L["Robert Aebischer"],
			category = "repair",
			description = L["Superior Armorsmith"],
			faction = "Alliance",
		},
		[51605240] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[63601960] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[50205880] = {
			name = L["Wesley"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Alliance",
		},
		[62201980] = {
			name = L["Theodore Mont Claire"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Horde",
		},
		[50606100] = {
			name = L["Donald Rabonne"],
			category = "secondaryProfession",
			profession = "Fishing",
			description = L["Fisherman"],
			faction = "Alliance",
		},
		[61601960] = {
			name = L["Aranae Venomblood"],
			category = "primaryProfession",
			profession = "Herbalism",
			description = L["Herbalist"],
			faction = "Horde",
		},
		[61601920] = {
			name = L["Serge Hinott"],
			category = "primaryProfession",
			profession = "Alchemy",
			description = L["Expert Alchemist"],
			faction = "Horde",
		},
		[63602080] = {
			name = L["Daryl Stack"],
			category = "primaryProfession",
			profession = "Tailoring",
			description = L["Master Tailor"],
			faction = "Horde",
		},
		[32004560] = {
			name = L["Hillsbrad Apprentice Blacksmith"],
			category = "vendors",
			faction = "Alliance",
		},
		[52005560] = {
			name = L["Merideth Carlson"],
			category = "vendors",
			description = L["Horse Breeder"],
			faction = "Alliance",
		},
		[51005900] = {
			name = L["Neema"],
			category = "vendors",
			description = L["Waitress"],
			faction = "Alliance",
		},
		[48805720] = {
			name = L["Bront Coldcleave"],
			category = "vendors",
			description = L["Butcher"],
			faction = "Alliance",
		},
		[51405860] = {
			name = L["Barkeep Kelly"],
			category = "vendors",
			description = L["Bartender"],
			faction = "Alliance",
		},
		[50805700] = {
			name = L["Nandar Branson"],
			category = "vendors",
			description = L["Alchemy Supplies"],
			faction = "Alliance",
		},
		[49005520] = {
			name = L["Micha Yance"],
			category = "vendors",
			description = L["Trade Goods"],
			faction = "Alliance",
		},
		[50606105] = {
			name = L["Lindea Rabonne"],
			category = "vendors",
			description = L["Tackle and Bait"],
			faction = "Alliance",
		},
		[62201900] = {
			name = L["Christoph Jeffcoat"],
			category = "vendors",
			description = L["Tradesman"],
			faction = "Horde",
		},
		[62002080] = {
			name = L["Mallen Swain"],
			category = "vendors",
			description = L["Tailoring Supplies"],
			faction = "Horde",
		},
		[63001940] = {
			name = L["Derak Nightfall"],
			category = "secondaryProfession",
			profession = "Cooking",
			description = L["Cook"],
			faction = "Horde",
		},
		[62401985] = {
			name = L["Kayren Soothallow"],
			category = "vendors",
			description = L["General Goods"],
			faction = "Horde",
		},
		[91803820] = {
			name = L["George Candarte"],
			category = "vendors",
			description = L["Leatherworking Supplies"],
			faction = "Neutral",
		},
		[49806220] = {
			name = L["Hal McAllister"],
			category = "vendors",
			description = L["Fish Merchant"],
			faction = "Alliance",
		},
		[49005525] = {
			name = L["Sarah Raycroft"],
			category = "vendors",
			description = L["General Goods"],
			faction = "Alliance",
		},
		[50805900] = {
			name = L["Jaysin Lanyda"],
			category = "vendors",
			description = L["Poisons & Reagents"],
			faction = "Alliance",
		},
		[61402000] = {
			name = L["Jason Lemieux"],
			category = "vendors",
			description = L["Mushroom Seller"],
			faction = "Horde",
		},
		[68207720] = {
			name = L["Tamra Stormpike"],
			category = "rares",
			faction = "Neutral",
		},
		[69407720] = {
			name = L["Tamra Stormpike"],
			category = "rares",
			faction = "Neutral",
		},
		[69607480] = {
			name = L["Tamra Stormpike"],
			category = "rares",
			faction = "Neutral",
		},
		[70607760] = {
			name = L["Tamra Stormpike"],
			category = "rares",
			faction = "Neutral",
		},
		[71807980] = {
			name = L["Tamra Stormpike"],
			category = "rares",
			faction = "Neutral",
		},
		[72007900] = {
			name = L["Tamra Stormpike"],
			category = "rares",
			faction = "Neutral",
		},
		[72008240] = {
			name = L["Tamra Stormpike"],
			category = "rares",
			faction = "Neutral",
		},
		[72208060] = {
			name = L["Tamra Stormpike"],
			category = "rares",
			faction = "Neutral",
		},
		[72808180] = {
			name = L["Tamra Stormpike"],
			category = "rares",
			faction = "Neutral",
		},
		[73408120] = {
			name = L["Tamra Stormpike"],
			category = "rares",
			faction = "Neutral",
		},
		[23406400] = {
			name = L["Scargil"],
			category = "rares",
			faction = "Neutral",
		},
		[23406460] = {
			name = L["Scargil"],
			category = "rares",
			faction = "Neutral",
		},
		[24406680] = {
			name = L["Scargil"],
			category = "rares",
			faction = "Neutral",
		},
		[25006640] = {
			name = L["Scargil"],
			category = "rares",
			faction = "Neutral",
		},
		[25807080] = {
			name = L["Scargil"],
			category = "rares",
			faction = "Neutral",
		},
		[27407120] = {
			name = L["Scargil"],
			category = "rares",
			faction = "Neutral",
		},
		[28407200] = {
			name = L["Scargil"],
			category = "rares",
			faction = "Neutral",
		},
		[29207140] = {
			name = L["Scargil"],
			category = "rares",
			faction = "Neutral",
		},
		[29607280] = {
			name = L["Scargil"],
			category = "rares",
			faction = "Neutral",
		},
		[58007060] = {
			name = L["Lady Zephris"],
			category = "rares",
			faction = "Neutral",
		},
		[58607140] = {
			name = L["Lady Zephris"],
			category = "rares",
			faction = "Neutral",
		},
		[59407360] = {
			name = L["Lady Zephris"],
			category = "rares",
			faction = "Neutral",
		},
		[59807340] = {
			name = L["Lady Zephris"],
			category = "rares",
			faction = "Neutral",
		},
		[60207480] = {
			name = L["Lady Zephris"],
			category = "rares",
			faction = "Neutral",
		},
		[61207600] = {
			name = L["Lady Zephris"],
			category = "rares",
			faction = "Neutral",
		},
		[64207840] = {
			name = L["Lady Zephris"],
			category = "rares",
			faction = "Neutral",
		},
		[64407860] = {
			name = L["Lady Zephris"],
			category = "rares",
			faction = "Neutral",
		},
		[64607960] = {
			name = L["Lady Zephris"],
			category = "rares",
			faction = "Neutral",
		},
		[65007820] = {
			name = L["Lady Zephris"],
			category = "rares",
			faction = "Neutral",
		},
		[65608740] = {
			name = L["Lady Zephris"],
			category = "rares",
			faction = "Neutral",
		},
		[66808320] = {
			name = L["Lady Zephris"],
			category = "rares",
			faction = "Neutral",
		},
		[63805960] = {
			name = L["Ro'Bark"],
			category = "rares",
			faction = "Neutral",
		},
		[63806080] = {
			name = L["Ro'Bark"],
			category = "rares",
			faction = "Neutral",
		},
		[64206180] = {
			name = L["Ro'Bark"],
			category = "rares",
			faction = "Neutral",
		},
		[64805920] = {
			name = L["Ro'Bark"],
			category = "rares",
			faction = "Neutral",
		},
		[65406040] = {
			name = L["Ro'Bark"],
			category = "rares",
			faction = "Neutral",
		},
		[65806160] = {
			name = L["Ro'Bark"],
			category = "rares",
			faction = "Neutral",
		},
		[66006120] = {
			name = L["Ro'Bark"],
			category = "rares",
			faction = "Neutral",
		},
		[34605860] = {
			name = L["Creepthess"],
			category = "rares",
			faction = "Neutral",
		},
		[34606060] = {
			name = L["Creepthess"],
			category = "rares",
			faction = "Neutral",
		},
		[35206040] = {
			name = L["Creepthess"],
			category = "rares",
			faction = "Neutral",
		},
		[35605920] = {
			name = L["Creepthess"],
			category = "rares",
			faction = "Neutral",
		},
		[39405200] = {
			name = L["Creepthess"],
			category = "rares",
			faction = "Neutral",
		},
		[75603080] = {
			name = L["Big Samras"],
			category = "rares",
			faction = "Neutral",
		},
		[84604800] = {
			name = L["Big Samras"],
			category = "rares",
			faction = "Neutral",
		},
		[85603900] = {
			name = L["Big Samras"],
			category = "rares",
			faction = "Neutral",
		},
		[86204780] = {
			name = L["Big Samras"],
			category = "rares",
			faction = "Neutral",
		},
		[69807700] = {
			name = L["Tamra Stormpike"],
			category = "rares",
			faction = "Neutral",
		},
		[29207280] = {
			name = L["Scargil"],
			category = "rares",
			faction = "Neutral",
		},
		[57806920] = {
			name = L["Lady Zephris"],
			category = "rares",
			faction = "Neutral",
		},
		[58407240] = {
			name = L["Lady Zephris"],
			category = "rares",
			faction = "Neutral",
		},
		[58607240] = {
			name = L["Lady Zephris"],
			category = "rares",
			faction = "Neutral",
		},
		[65407840] = {
			name = L["Lady Zephris"],
			category = "rares",
			faction = "Neutral",
		},
		[65408220] = {
			name = L["Lady Zephris"],
			category = "rares",
			faction = "Neutral",
		},
		[65607780] = {
			name = L["Lady Zephris"],
			category = "rares",
			faction = "Neutral",
		},
		[65608160] = {
			name = L["Lady Zephris"],
			category = "rares",
			faction = "Neutral",
		},
		[65808020] = {
			name = L["Lady Zephris"],
			category = "rares",
			faction = "Neutral",
		},
		[62406160] = {
			name = L["Ro'Bark"],
			category = "rares",
			faction = "Neutral",
		},
		[63006100] = {
			name = L["Ro'Bark"],
			category = "rares",
			faction = "Neutral",
		},
		[63006220] = {
			name = L["Ro'Bark"],
			category = "rares",
			faction = "Neutral",
		},
		[63206340] = {
			name = L["Ro'Bark"],
			category = "rares",
			faction = "Neutral",
		},
		[63606140] = {
			name = L["Ro'Bark"],
			category = "rares",
			faction = "Neutral",
		},
		[63806500] = {
			name = L["Ro'Bark"],
			category = "rares",
			faction = "Neutral",
		},
		[64006300] = {
			name = L["Ro'Bark"],
			category = "rares",
			faction = "Neutral",
		},
		[64205820] = {
			name = L["Ro'Bark"],
			category = "rares",
			faction = "Neutral",
		},
		[65005840] = {
			name = L["Ro'Bark"],
			category = "rares",
			faction = "Neutral",
		},
		[65206200] = {
			name = L["Ro'Bark"],
			category = "rares",
			faction = "Neutral",
		},
		[36605900] = {
			name = L["Creepthess"],
			category = "rares",
			faction = "Neutral",
		},
		[75403160] = {
			name = L["Big Samras"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1417] = {
		[45804620] = {
			name = L["Cedrik Prose"],
			category = "flightmasters",
			fpName = L["Refuge Pointe, Arathi"],
			description = L["Gryphon Master"],
			faction = "Alliance",
		},
		[73003260] = {
			name = L["Urda"],
			category = "flightmasters",
			fpName = L["Hammerfall, Arathi"],
			description = L["Wind Rider Master"],
			faction = "Horde",
		},
		[73803260] = {
			name = L["Innkeeper Adegwa"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Horde",
		},
		[73803310] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Horde",
		},
		[46004760] = {
			name = L["Jannos Ironwill"],
			category = "repair",
			description = L["Superior Macecrafter"],
			faction = "Alliance",
		},
		[72603340] = {
			name = L["Mu'uta"],
			category = "repair",
			description = L["Bowyer"],
			faction = "Horde",
		},
		[73402980] = {
			name = L["Rutherford Twing"],
			category = "repair",
			description = L["Defilers Supply Officer"],
			faction = "Horde",
		},
		[46004520] = {
			name = L["Samuel Hawke"],
			category = "repair",
			description = L["League of Arathor Supply Officer"],
			faction = "Alliance",
		},
		[48805540] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[73803320] = {
			name = L["Tharlidun"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Horde",
		},
		[74003380] = {
			name = L["Slagg"],
			category = "secondaryProfession",
			profession = "Cooking",
			description = L["Superior Butcher"],
			faction = "Horde",
		},
		[27205880] = {
			name = L["Deneb Walker"],
			category = "vendors",
			description = L["Scrolls & Potions"],
			faction = "Alliance",
		},
		[46404760] = {
			name = L["Vikki Lonsav"],
			category = "vendors",
			description = L["General Goods"],
			faction = "Alliance",
		},
		[46404740] = {
			name = L["Hammon Karwn"],
			category = "vendors",
			description = L["Superior Tradesman"],
			faction = "Alliance",
		},
		[46204720] = {
			name = L["Drovnar Strongbrew"],
			category = "vendors",
			description = L["Alchemy Supplies"],
			faction = "Alliance",
		},
		[45604760] = {
			name = L["Narj Deepslice"],
			category = "vendors",
			description = L["Butcher"],
			faction = "Alliance",
		},
		[45004680] = {
			name = L["Androd Fadran"],
			category = "vendors",
			description = L["Leatherworking Supplies"],
			faction = "Alliance",
		},
		[74803460] = {
			name = L["Tunkk"],
			category = "vendors",
			description = L["Leatherworking Supplies"],
			faction = "Horde",
		},
		[74003240] = {
			name = L["Graud"],
			category = "vendors",
			description = L["General Goods"],
			faction = "Horde",
		},
		[74003260] = {
			name = L["Keena"],
			category = "vendors",
			description = L["Trade Goods"],
			faction = "Horde",
		},
		[74203380] = {
			name = L["Uttnar"],
			category = "vendors",
			description = L["Butcher"],
			faction = "Horde",
		},
		[72603640] = {
			name = L["Jun'ha"],
			category = "vendors",
			description = L["Tailoring Supplies"],
			faction = "Horde",
		},
		[46404540] = {
			name = L["Targot Jinglepocket"],
			category = "vendors",
			description = L["Smokywood Pastures"],
			faction = "Alliance",
		},
		[74002920] = {
			name = L["Kosco Copperpinch"],
			category = "vendors",
			description = L["Smokywood Pastures"],
			faction = "Horde",
		},
		[27006600] = {
			name = L["Darbel Montrose"],
			category = "rares",
			description = L["Shadow Council Warlock"],
			faction = "Neutral",
		},
		[27406280] = {
			name = L["Darbel Montrose"],
			category = "rares",
			description = L["Shadow Council Warlock"],
			faction = "Neutral",
		},
		[27606360] = {
			name = L["Darbel Montrose"],
			category = "rares",
			description = L["Shadow Council Warlock"],
			faction = "Neutral",
		},
		[27806640] = {
			name = L["Darbel Montrose"],
			category = "rares",
			description = L["Shadow Council Warlock"],
			faction = "Neutral",
		},
		[28006300] = {
			name = L["Darbel Montrose"],
			category = "rares",
			description = L["Shadow Council Warlock"],
			faction = "Neutral",
		},
		[29206100] = {
			name = L["Darbel Montrose"],
			category = "rares",
			description = L["Shadow Council Warlock"],
			faction = "Neutral",
		},
		[31202640] = {
			name = L["Singer"],
			category = "rares",
			faction = "Neutral",
		},
		[32402680] = {
			name = L["Singer"],
			category = "rares",
			faction = "Neutral",
		},
		[32403100] = {
			name = L["Singer"],
			category = "rares",
			faction = "Neutral",
		},
		[32603120] = {
			name = L["Singer"],
			category = "rares",
			faction = "Neutral",
		},
		[33402800] = {
			name = L["Singer"],
			category = "rares",
			faction = "Neutral",
		},
		[33602740] = {
			name = L["Singer"],
			category = "rares",
			faction = "Neutral",
		},
		[20206640] = {
			name = L["Foulbelly"],
			category = "rares",
			faction = "Neutral",
		},
		[21406620] = {
			name = L["Foulbelly"],
			category = "rares",
			faction = "Neutral",
		},
		[21606540] = {
			name = L["Foulbelly"],
			category = "rares",
			faction = "Neutral",
		},
		[18206860] = {
			name = L["Ruul Onestone"],
			category = "rares",
			faction = "Neutral",
		},
		[32004600] = {
			name = L["Kovork"],
			category = "rares",
			faction = "Neutral",
		},
		[32604600] = {
			name = L["Kovork"],
			category = "rares",
			faction = "Neutral",
		},
		[53408000] = {
			name = L["Molok the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[53807960] = {
			name = L["Molok the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[54007920] = {
			name = L["Molok the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[67408120] = {
			name = L["Zalas Witherbark"],
			category = "rares",
			description = L["Warband Leader"],
			faction = "Neutral",
		},
		[68608080] = {
			name = L["Zalas Witherbark"],
			category = "rares",
			description = L["Warband Leader"],
			faction = "Neutral",
		},
		[69607960] = {
			name = L["Zalas Witherbark"],
			category = "rares",
			description = L["Warband Leader"],
			faction = "Neutral",
		},
		[61807300] = {
			name = L["Nimar the Slayer"],
			category = "rares",
			description = L["Warband Leader"],
			faction = "Neutral",
		},
		[64006780] = {
			name = L["Nimar the Slayer"],
			category = "rares",
			description = L["Warband Leader"],
			faction = "Neutral",
		},
		[64206660] = {
			name = L["Nimar the Slayer"],
			category = "rares",
			description = L["Warband Leader"],
			faction = "Neutral",
		},
		[64207440] = {
			name = L["Nimar the Slayer"],
			category = "rares",
			description = L["Warband Leader"],
			faction = "Neutral",
		},
		[65007420] = {
			name = L["Nimar the Slayer"],
			category = "rares",
			description = L["Warband Leader"],
			faction = "Neutral",
		},
		[66206220] = {
			name = L["Nimar the Slayer"],
			category = "rares",
			description = L["Warband Leader"],
			faction = "Neutral",
		},
		[66406260] = {
			name = L["Nimar the Slayer"],
			category = "rares",
			description = L["Warband Leader"],
			faction = "Neutral",
		},
		[70206620] = {
			name = L["Nimar the Slayer"],
			category = "rares",
			description = L["Warband Leader"],
			faction = "Neutral",
		},
		[72006400] = {
			name = L["Nimar the Slayer"],
			category = "rares",
			description = L["Warband Leader"],
			faction = "Neutral",
		},
		[72006580] = {
			name = L["Nimar the Slayer"],
			category = "rares",
			description = L["Warband Leader"],
			faction = "Neutral",
		},
		[72406480] = {
			name = L["Nimar the Slayer"],
			category = "rares",
			description = L["Warband Leader"],
			faction = "Neutral",
		},
		[72806620] = {
			name = L["Nimar the Slayer"],
			category = "rares",
			description = L["Warband Leader"],
			faction = "Neutral",
		},
		[73006480] = {
			name = L["Nimar the Slayer"],
			category = "rares",
			description = L["Warband Leader"],
			faction = "Neutral",
		},
		[22608520] = {
			name = L["Prince Nazjak"],
			category = "rares",
			faction = "Neutral",
		},
		[23408900] = {
			name = L["Prince Nazjak"],
			category = "rares",
			faction = "Neutral",
		},
		[27406640] = {
			name = L["Darbel Montrose"],
			category = "rares",
			description = L["Shadow Council Warlock"],
			faction = "Neutral",
		},
		[27606540] = {
			name = L["Darbel Montrose"],
			category = "rares",
			description = L["Shadow Council Warlock"],
			faction = "Neutral",
		},
		[31202620] = {
			name = L["Singer"],
			category = "rares",
			faction = "Neutral",
		},
		[33202780] = {
			name = L["Singer"],
			category = "rares",
			faction = "Neutral",
		},
		[20006440] = {
			name = L["Foulbelly"],
			category = "rares",
			faction = "Neutral",
		},
		[20006460] = {
			name = L["Foulbelly"],
			category = "rares",
			faction = "Neutral",
		},
		[63006660] = {
			name = L["Nimar the Slayer"],
			category = "rares",
			description = L["Warband Leader"],
			faction = "Neutral",
		},
		[63806620] = {
			name = L["Nimar the Slayer"],
			category = "rares",
			description = L["Warband Leader"],
			faction = "Neutral",
		},
		[21808480] = {
			name = L["Prince Nazjak"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1425] = {
		[81608180] = {
			name = L["Gorkas"],
			category = "flightmasters",
			fpName = L["Revantusk Village, The Hinterlands"],
			description = L["Wind Rider Master"],
			faction = "Horde",
		},
		[11004600] = {
			name = L["Guthrum Thunderfist"],
			category = "flightmasters",
			fpName = L["Aerie Peak, The Hinterlands"],
			description = L["Gryphon Master"],
			faction = "Alliance",
		},
		[13804160] = {
			name = L["Innkeeper Thulfram"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Alliance",
		},
		[78208120] = {
			name = L["Lard"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Horde",
		},
		[14104570] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Alliance",
		},
		[78908040] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Horde",
		},
		[13404380] = {
			name = L["Harggan"],
			category = "repair",
			description = L["Blacksmithing Supplies"],
			faction = "Alliance",
		},
		[77408020] = {
			name = L["Smith Slagtree"],
			category = "repair",
			description = L["Blacksmithing Supplies"],
			faction = "Horde",
		},
		[72606800] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[14204520] = {
			name = L["Killium Bouldertoe"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Alliance",
		},
		[13404340] = {
			name = L["Drakk Stonehand"],
			category = "primaryProfession",
			profession = "Leatherworking",
			description = L["Master Leatherworking Trainer"],
			faction = "Alliance",
		},
		[80208140] = {
			name = L["Katoom the Angler"],
			category = "secondaryProfession",
			profession = "Fishing",
			description = L["Fishing Trainer & Supplies"],
			faction = "Horde",
		},
		[34203780] = {
			name = L["Ruppo Zipcoil"],
			category = "vendors",
			description = L["Engineering Supplies"],
			faction = "Neutral",
		},
		[14404240] = {
			name = L["Truk Wildbeard"],
			category = "vendors",
			description = L["Bartender"],
			faction = "Alliance",
		},
		[13404320] = {
			name = L["Nioma"],
			category = "vendors",
			description = L["Leatherworking Supplies"],
			faction = "Alliance",
		},
		[34403840] = {
			name = L["Gigget Zipcoil"],
			category = "vendors",
			description = L["Trade Supplies"],
			faction = "Neutral",
		},
		[79207900] = {
			name = L["Otho Moji'ko"],
			category = "vendors",
			description = L["Cooking Supplier"],
			faction = "Horde",
		},
		[78807840] = {
			name = L["Mystic Yayo'jin"],
			category = "vendors",
			subcategory = "reagentvendor",
			description = L["Reagent Vendor"],
			faction = "Horde",
		},
		[76808120] = {
			name = L["Renn'az"],
			category = "vendors",
			description = L["Ammunition Vendor"],
			faction = "Horde",
		},
		[36205200] = {
			name = L["Razortalon"],
			category = "rares",
			faction = "Neutral",
		},
		[15605300] = {
			name = L["Old Cliff Jumper"],
			category = "rares",
			faction = "Neutral",
		},
		[19404940] = {
			name = L["Old Cliff Jumper"],
			category = "rares",
			faction = "Neutral",
		},
		[19804960] = {
			name = L["Old Cliff Jumper"],
			category = "rares",
			faction = "Neutral",
		},
		[20404840] = {
			name = L["Old Cliff Jumper"],
			category = "rares",
			faction = "Neutral",
		},
		[21805040] = {
			name = L["Old Cliff Jumper"],
			category = "rares",
			faction = "Neutral",
		},
		[22005060] = {
			name = L["Old Cliff Jumper"],
			category = "rares",
			faction = "Neutral",
		},
		[22605240] = {
			name = L["Old Cliff Jumper"],
			category = "rares",
			faction = "Neutral",
		},
		[74808840] = {
			name = L["Ironback"],
			category = "rares",
			faction = "Neutral",
		},
		[75008660] = {
			name = L["Ironback"],
			category = "rares",
			faction = "Neutral",
		},
		[77406300] = {
			name = L["Ironback"],
			category = "rares",
			faction = "Neutral",
		},
		[78006380] = {
			name = L["Ironback"],
			category = "rares",
			faction = "Neutral",
		},
		[78606320] = {
			name = L["Ironback"],
			category = "rares",
			faction = "Neutral",
		},
		[81604760] = {
			name = L["Ironback"],
			category = "rares",
			faction = "Neutral",
		},
		[81604880] = {
			name = L["Ironback"],
			category = "rares",
			faction = "Neutral",
		},
		[82404600] = {
			name = L["Ironback"],
			category = "rares",
			faction = "Neutral",
		},
		[82604680] = {
			name = L["Ironback"],
			category = "rares",
			faction = "Neutral",
		},
		[28204520] = {
			name = L["Jalinde Summerdrake"],
			category = "rares",
			faction = "Neutral",
		},
		[28404640] = {
			name = L["Jalinde Summerdrake"],
			category = "rares",
			faction = "Neutral",
		},
		[30404820] = {
			name = L["Jalinde Summerdrake"],
			category = "rares",
			faction = "Neutral",
		},
		[30804760] = {
			name = L["Jalinde Summerdrake"],
			category = "rares",
			faction = "Neutral",
		},
		[31004420] = {
			name = L["Jalinde Summerdrake"],
			category = "rares",
			faction = "Neutral",
		},
		[31404300] = {
			name = L["Jalinde Summerdrake"],
			category = "rares",
			faction = "Neutral",
		},
		[45006860] = {
			name = L["Retherokk the Berserker"],
			category = "rares",
			faction = "Neutral",
		},
		[45206780] = {
			name = L["Retherokk the Berserker"],
			category = "rares",
			faction = "Neutral",
		},
		[46406460] = {
			name = L["Retherokk the Berserker"],
			category = "rares",
			faction = "Neutral",
		},
		[46806800] = {
			name = L["Retherokk the Berserker"],
			category = "rares",
			faction = "Neutral",
		},
		[47206540] = {
			name = L["Retherokk the Berserker"],
			category = "rares",
			faction = "Neutral",
		},
		[47606660] = {
			name = L["Retherokk the Berserker"],
			category = "rares",
			faction = "Neutral",
		},
		[51206580] = {
			name = L["Retherokk the Berserker"],
			category = "rares",
			faction = "Neutral",
		},
		[51206660] = {
			name = L["Retherokk the Berserker"],
			category = "rares",
			faction = "Neutral",
		},
		[58207080] = {
			name = L["Mith'rethis the Enchanter"],
			category = "rares",
			faction = "Neutral",
		},
		[59207540] = {
			name = L["Mith'rethis the Enchanter"],
			category = "rares",
			faction = "Neutral",
		},
		[59407560] = {
			name = L["Mith'rethis the Enchanter"],
			category = "rares",
			faction = "Neutral",
		},
		[64208140] = {
			name = L["Mith'rethis the Enchanter"],
			category = "rares",
			faction = "Neutral",
		},
		[65208000] = {
			name = L["Mith'rethis the Enchanter"],
			category = "rares",
			faction = "Neutral",
		},
		[33207000] = {
			name = L["Witherheart the Stalker"],
			category = "rares",
			faction = "Neutral",
		},
		[33607380] = {
			name = L["Witherheart the Stalker"],
			category = "rares",
			faction = "Neutral",
		},
		[34206840] = {
			name = L["Witherheart the Stalker"],
			category = "rares",
			faction = "Neutral",
		},
		[34806980] = {
			name = L["Witherheart the Stalker"],
			category = "rares",
			faction = "Neutral",
		},
		[23205760] = {
			name = L["Zul'arek Hatefowler"],
			category = "rares",
			faction = "Neutral",
		},
		[23405720] = {
			name = L["Zul'arek Hatefowler"],
			category = "rares",
			faction = "Neutral",
		},
		[23605760] = {
			name = L["Zul'arek Hatefowler"],
			category = "rares",
			faction = "Neutral",
		},
		[23805460] = {
			name = L["Zul'arek Hatefowler"],
			category = "rares",
			faction = "Neutral",
		},
		[24605720] = {
			name = L["Zul'arek Hatefowler"],
			category = "rares",
			faction = "Neutral",
		},
		[24805820] = {
			name = L["Zul'arek Hatefowler"],
			category = "rares",
			faction = "Neutral",
		},
		[31805760] = {
			name = L["Zul'arek Hatefowler"],
			category = "rares",
			faction = "Neutral",
		},
		[32405720] = {
			name = L["Zul'arek Hatefowler"],
			category = "rares",
			faction = "Neutral",
		},
		[32605940] = {
			name = L["Zul'arek Hatefowler"],
			category = "rares",
			faction = "Neutral",
		},
		[32805760] = {
			name = L["Zul'arek Hatefowler"],
			category = "rares",
			faction = "Neutral",
		},
		[35805260] = {
			name = L["Razortalon"],
			category = "rares",
			faction = "Neutral",
		},
		[36604500] = {
			name = L["Razortalon"],
			category = "rares",
			faction = "Neutral",
		},
		[17205580] = {
			name = L["Old Cliff Jumper"],
			category = "rares",
			faction = "Neutral",
		},
		[21605180] = {
			name = L["Old Cliff Jumper"],
			category = "rares",
			faction = "Neutral",
		},
		[48604740] = {
			name = L["The Reak"],
			category = "rares",
			faction = "Neutral",
		},
		[76208240] = {
			name = L["Ironback"],
			category = "rares",
			faction = "Neutral",
		},
		[76808100] = {
			name = L["Ironback"],
			category = "rares",
			faction = "Neutral",
		},
		[77806140] = {
			name = L["Ironback"],
			category = "rares",
			faction = "Neutral",
		},
		[77806300] = {
			name = L["Ironback"],
			category = "rares",
			faction = "Neutral",
		},
		[81804360] = {
			name = L["Ironback"],
			category = "rares",
			faction = "Neutral",
		},
		[82204480] = {
			name = L["Ironback"],
			category = "rares",
			faction = "Neutral",
		},
		[82404780] = {
			name = L["Ironback"],
			category = "rares",
			faction = "Neutral",
		},
		[31404880] = {
			name = L["Jalinde Summerdrake"],
			category = "rares",
			faction = "Neutral",
		},
		[31804380] = {
			name = L["Jalinde Summerdrake"],
			category = "rares",
			faction = "Neutral",
		},
		[64605000] = {
			name = L["Grimungous"],
			category = "rares",
			faction = "Neutral",
		},
		[73005640] = {
			name = L["Grimungous"],
			category = "rares",
			faction = "Neutral",
		},
		[46006860] = {
			name = L["Retherokk the Berserker"],
			category = "rares",
			faction = "Neutral",
		},
		[46206440] = {
			name = L["Retherokk the Berserker"],
			category = "rares",
			faction = "Neutral",
		},
		[46807020] = {
			name = L["Retherokk the Berserker"],
			category = "rares",
			faction = "Neutral",
		},
		[47406600] = {
			name = L["Retherokk the Berserker"],
			category = "rares",
			faction = "Neutral",
		},
		[49406340] = {
			name = L["Retherokk the Berserker"],
			category = "rares",
			faction = "Neutral",
		},
		[64208220] = {
			name = L["Mith'rethis the Enchanter"],
			category = "rares",
			faction = "Neutral",
		},
		[34806900] = {
			name = L["Witherheart the Stalker"],
			category = "rares",
			faction = "Neutral",
		},
		[34807220] = {
			name = L["Witherheart the Stalker"],
			category = "rares",
			faction = "Neutral",
		},
		[35007400] = {
			name = L["Witherheart the Stalker"],
			category = "rares",
			faction = "Neutral",
		},
		[23805800] = {
			name = L["Zul'arek Hatefowler"],
			category = "rares",
			faction = "Neutral",
		},
		[24205740] = {
			name = L["Zul'arek Hatefowler"],
			category = "rares",
			faction = "Neutral",
		},
		[32605720] = {
			name = L["Zul'arek Hatefowler"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1431] = {
		[77404440] = {
			name = L["Felicia Maline"],
			category = "flightmasters",
			fpName = L["Darkshire, Duskwood"],
			description = L["Gryphon Master"],
			faction = "Alliance",
		},
		[73804440] = {
			name = L["Innkeeper Trelayne"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Alliance",
		},
		[73804620] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Alliance",
		},
		[73604880] = {
			name = L["Gavin Gnarltree"],
			category = "repair",
			description = L["Weaponsmith"],
			faction = "Alliance",
		},
		[73804860] = {
			name = L["Morg Gnarltree"],
			category = "repair",
			description = L["Armorer"],
			faction = "Alliance",
		},
		[73204480] = {
			name = L["Avette Fellwood"],
			category = "repair",
			description = L["Bowyer"],
			faction = "Alliance",
		},
		[20004940] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[75005900] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[74004620] = {
			name = L["Steven Black"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Alliance",
		},
		[77404860] = {
			name = L["Finbus Geargrind"],
			category = "primaryProfession",
			profession = "Engineering",
			description = L["Expert Engineer"],
			faction = "Alliance",
		},
		[74004840] = {
			name = L["Clarise Gnarltree"],
			category = "primaryProfession",
			profession = "Blacksmith",
			description = L["Expert Blacksmith"],
			faction = "Alliance",
		},
		[74004960] = {
			name = L["Matt Johnson"],
			category = "primaryProfession",
			profession = "Mining",
			description = L["Mining Trainer"],
			faction = "Alliance",
		},
		[74004480] = {
			name = L["Mabel Solaj"],
			category = "vendors",
			description = L["General Goods Vendor"],
			faction = "Alliance",
		},
		[73804420] = {
			name = L["Barkeep Hann"],
			category = "vendors",
			description = L["Bartender"],
			faction = "Alliance",
		},
		[75004640] = {
			name = L["Antonio Perelli"],
			category = "vendors",
			description = L["Traveling Salesman"],
			faction = "Alliance",
		},
		[73804500] = {
			name = L["Gunder Thornbush"],
			category = "vendors",
			description = L["Tradesman"],
			faction = "Alliance",
		},
		[75604460] = {
			name = L["Lohgan Eva"],
			category = "vendors",
			description = L["Tailoring Supplies"],
			faction = "Alliance",
		},
		[76004520] = {
			name = L["Alyssa Eva"],
			category = "vendors",
			subcategory = "reagentvendor",
			description = L["Reagent Vendor"],
			faction = "Alliance",
		},
		[18005440] = {
			name = L["Bliztik"],
			category = "vendors",
			description = L["Alchemy Supplies"],
			faction = "Alliance",
		},
		[75804540] = {
			name = L["Danielle Zipstitch"],
			category = "vendors",
			description = L["Tailoring Supplies"],
			faction = "Alliance",
		},
		[75604540] = {
			name = L["Sheri Zipstitch"],
			category = "vendors",
			description = L["Tailoring Supplies"],
			faction = "Alliance",
		},
		[77804820] = {
			name = L["Herble Baubbletump"],
			category = "vendors",
			description = L["Engineering and Mining Supplies"],
			faction = "Alliance",
		},
		[81801980] = {
			name = L["Kzixx"],
			category = "vendors",
			description = L["Rare Goods"],
			faction = "Alliance",
		},
		[79404440] = {
			name = L["Malissa"],
			category = "vendors",
			subcategory = "poisonvendor",
			description = L["Poison Supplier"],
			faction = "Alliance",
		},
		[75604840] = {
			name = L["Scott Carevin"],
			category = "vendors",
			description = L["Mushroom Seller"],
			faction = "Alliance",
		},
		[25603020] = {
			name = L["Lord Malathrom"],
			category = "rares",
			faction = "Neutral",
		},
		[59402940] = {
			name = L["Fenros"],
			category = "rares",
			faction = "Neutral",
		},
		[59402980] = {
			name = L["Fenros"],
			category = "rares",
			faction = "Neutral",
		},
		[60804060] = {
			name = L["Fenros"],
			category = "rares",
			faction = "Neutral",
		},
		[61203780] = {
			name = L["Fenros"],
			category = "rares",
			faction = "Neutral",
		},
		[61604160] = {
			name = L["Fenros"],
			category = "rares",
			faction = "Neutral",
		},
		[61804320] = {
			name = L["Fenros"],
			category = "rares",
			faction = "Neutral",
		},
		[62003760] = {
			name = L["Fenros"],
			category = "rares",
			faction = "Neutral",
		},
		[62004140] = {
			name = L["Fenros"],
			category = "rares",
			faction = "Neutral",
		},
		[62403700] = {
			name = L["Fenros"],
			category = "rares",
			faction = "Neutral",
		},
		[62604080] = {
			name = L["Fenros"],
			category = "rares",
			faction = "Neutral",
		},
		[62604580] = {
			name = L["Fenros"],
			category = "rares",
			faction = "Neutral",
		},
		[63204020] = {
			name = L["Fenros"],
			category = "rares",
			faction = "Neutral",
		},
		[63204840] = {
			name = L["Fenros"],
			category = "rares",
			faction = "Neutral",
		},
		[63804680] = {
			name = L["Fenros"],
			category = "rares",
			faction = "Neutral",
		},
		[63804780] = {
			name = L["Fenros"],
			category = "rares",
			faction = "Neutral",
		},
		[64005040] = {
			name = L["Fenros"],
			category = "rares",
			faction = "Neutral",
		},
		[64204940] = {
			name = L["Fenros"],
			category = "rares",
			faction = "Neutral",
		},
		[64404100] = {
			name = L["Fenros"],
			category = "rares",
			faction = "Neutral",
		},
		[65205060] = {
			name = L["Fenros"],
			category = "rares",
			faction = "Neutral",
		},
		[21402620] = {
			name = L["Lupos"],
			category = "rares",
			faction = "Neutral",
		},
		[23202720] = {
			name = L["Lupos"],
			category = "rares",
			faction = "Neutral",
		},
		[23402900] = {
			name = L["Lupos"],
			category = "rares",
			faction = "Neutral",
		},
		[24202800] = {
			name = L["Lupos"],
			category = "rares",
			faction = "Neutral",
		},
		[24202920] = {
			name = L["Lupos"],
			category = "rares",
			faction = "Neutral",
		},
		[24602700] = {
			name = L["Lupos"],
			category = "rares",
			faction = "Neutral",
		},
		[29802760] = {
			name = L["Lupos"],
			category = "rares",
			faction = "Neutral",
		},
		[33602880] = {
			name = L["Lupos"],
			category = "rares",
			faction = "Neutral",
		},
		[33802980] = {
			name = L["Lupos"],
			category = "rares",
			faction = "Neutral",
		},
		[37002840] = {
			name = L["Lupos"],
			category = "rares",
			faction = "Neutral",
		},
		[37802840] = {
			name = L["Lupos"],
			category = "rares",
			faction = "Neutral",
		},
		[38402620] = {
			name = L["Lupos"],
			category = "rares",
			faction = "Neutral",
		},
		[60202440] = {
			name = L["Lupos"],
			category = "rares",
			faction = "Neutral",
		},
		[65402680] = {
			name = L["Lupos"],
			category = "rares",
			faction = "Neutral",
		},
		[70002520] = {
			name = L["Lupos"],
			category = "rares",
			faction = "Neutral",
		},
		[70402560] = {
			name = L["Lupos"],
			category = "rares",
			faction = "Neutral",
		},
		[71002400] = {
			name = L["Lupos"],
			category = "rares",
			faction = "Neutral",
		},
		[61408160] = {
			name = L["Nefaru"],
			category = "rares",
			faction = "Neutral",
		},
		[61608140] = {
			name = L["Nefaru"],
			category = "rares",
			faction = "Neutral",
		},
		[62008160] = {
			name = L["Nefaru"],
			category = "rares",
			faction = "Neutral",
		},
		[62608220] = {
			name = L["Nefaru"],
			category = "rares",
			faction = "Neutral",
		},
		[62808280] = {
			name = L["Nefaru"],
			category = "rares",
			faction = "Neutral",
		},
		[71407440] = {
			name = L["Nefaru"],
			category = "rares",
			faction = "Neutral",
		},
		[72207440] = {
			name = L["Nefaru"],
			category = "rares",
			faction = "Neutral",
		},
		[73207620] = {
			name = L["Nefaru"],
			category = "rares",
			faction = "Neutral",
		},
		[73407680] = {
			name = L["Nefaru"],
			category = "rares",
			faction = "Neutral",
		},
		[73807720] = {
			name = L["Nefaru"],
			category = "rares",
			faction = "Neutral",
		},
		[74206820] = {
			name = L["Nefaru"],
			category = "rares",
			faction = "Neutral",
		},
		[74207860] = {
			name = L["Nefaru"],
			category = "rares",
			faction = "Neutral",
		},
		[74407760] = {
			name = L["Nefaru"],
			category = "rares",
			faction = "Neutral",
		},
		[74807480] = {
			name = L["Nefaru"],
			category = "rares",
			faction = "Neutral",
		},
		[76007420] = {
			name = L["Nefaru"],
			category = "rares",
			faction = "Neutral",
		},
		[86404800] = {
			name = L["Naraxis"],
			category = "rares",
			faction = "Neutral",
		},
		[86404860] = {
			name = L["Naraxis"],
			category = "rares",
			faction = "Neutral",
		},
		[86405020] = {
			name = L["Naraxis"],
			category = "rares",
			faction = "Neutral",
		},
		[86405060] = {
			name = L["Naraxis"],
			category = "rares",
			faction = "Neutral",
		},
		[86604940] = {
			name = L["Naraxis"],
			category = "rares",
			faction = "Neutral",
		},
		[86604960] = {
			name = L["Naraxis"],
			category = "rares",
			faction = "Neutral",
		},
		[87005160] = {
			name = L["Naraxis"],
			category = "rares",
			faction = "Neutral",
		},
		[14403340] = {
			name = L["Commander Felstrom"],
			category = "rares",
			faction = "Neutral",
		},
		[15003520] = {
			name = L["Commander Felstrom"],
			category = "rares",
			faction = "Neutral",
		},
		[15203440] = {
			name = L["Commander Felstrom"],
			category = "rares",
			faction = "Neutral",
		},
		[15803440] = {
			name = L["Commander Felstrom"],
			category = "rares",
			faction = "Neutral",
		},
		[15803540] = {
			name = L["Commander Felstrom"],
			category = "rares",
			faction = "Neutral",
		},
		[16003720] = {
			name = L["Commander Felstrom"],
			category = "rares",
			faction = "Neutral",
		},
		[16603780] = {
			name = L["Commander Felstrom"],
			category = "rares",
			faction = "Neutral",
		},
		[16803480] = {
			name = L["Commander Felstrom"],
			category = "rares",
			faction = "Neutral",
		},
		[17403740] = {
			name = L["Commander Felstrom"],
			category = "rares",
			faction = "Neutral",
		},
		[17603520] = {
			name = L["Commander Felstrom"],
			category = "rares",
			faction = "Neutral",
		},
		[17603740] = {
			name = L["Commander Felstrom"],
			category = "rares",
			faction = "Neutral",
		},
		[18003560] = {
			name = L["Commander Felstrom"],
			category = "rares",
			faction = "Neutral",
		},
		[18003800] = {
			name = L["Commander Felstrom"],
			category = "rares",
			faction = "Neutral",
		},
		[18603560] = {
			name = L["Commander Felstrom"],
			category = "rares",
			faction = "Neutral",
		},
		[62003440] = {
			name = L["Fenros"],
			category = "rares",
			faction = "Neutral",
		},
		[62604420] = {
			name = L["Fenros"],
			category = "rares",
			faction = "Neutral",
		},
		[63004300] = {
			name = L["Fenros"],
			category = "rares",
			faction = "Neutral",
		},
		[28002760] = {
			name = L["Lupos"],
			category = "rares",
			faction = "Neutral",
		},
		[29602620] = {
			name = L["Lupos"],
			category = "rares",
			faction = "Neutral",
		},
		[61002320] = {
			name = L["Lupos"],
			category = "rares",
			faction = "Neutral",
		},
		[64802560] = {
			name = L["Lupos"],
			category = "rares",
			faction = "Neutral",
		},
		[70802480] = {
			name = L["Lupos"],
			category = "rares",
			faction = "Neutral",
		},
		[61008120] = {
			name = L["Nefaru"],
			category = "rares",
			faction = "Neutral",
		},
		[61808140] = {
			name = L["Nefaru"],
			category = "rares",
			faction = "Neutral",
		},
		[63008300] = {
			name = L["Nefaru"],
			category = "rares",
			faction = "Neutral",
		},
		[17203520] = {
			name = L["Commander Felstrom"],
			category = "rares",
			faction = "Neutral",
		},
		[17203780] = {
			name = L["Commander Felstrom"],
			category = "rares",
			faction = "Neutral",
		},
		[17603760] = {
			name = L["Commander Felstrom"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1435] = {
		[46005460] = {
			name = L["Breyk"],
			category = "flightmasters",
			fpName = L["Stonard, Swamp of Sorrows"],
			description = L["Wind Rider Master"],
			faction = "Horde",
		},
		[45005660] = {
			name = L["Innkeeper Karakul"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Horde",
		},
		[45405500] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Neutral",
		},
		[45005020] = {
			name = L["Grimnal"],
			category = "repair",
			description = L["Mail & Plate Merchant"],
			faction = "Horde",
		},
		[45605100] = {
			name = L["Hartash"],
			category = "repair",
			description = L["Weapon Merchant"],
			faction = "Horde",
		},
		[45005140] = {
			name = L["Thralosh"],
			category = "repair",
			description = L["Cloth & Leather Armor Merchant"],
			faction = "Horde",
		},
		[45405140] = {
			name = L["Gharash"],
			category = "repair",
			description = L["Blacksmithing Supplies"],
			faction = "Horde",
		},
		[50206220] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[45405505] = {
			name = L["Hekkru"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Horde",
		},
		[44805740] = {
			name = L["Malosh"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warrior Trainer"],
			classes = {
				WARRIOR = true,
			},
			faction = "Horde",
		},
		[48005780] = {
			name = L["Haromm"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Shaman Trainer"],
			classes = {
				SHAMAN = true,
			},
			faction = "Neutral",
		},
		[47205320] = {
			name = L["Ogromm"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Hunter Trainer"],
			classes = {
				HUNTER = true,
			},
			faction = "Neutral",
		},
		[48405540] = {
			name = L["Kartosh"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warlock Trainer"],
			classes = {
				WARLOCK = true,
			},
			faction = "Horde",
		},
		[48405560] = {
			name = L["Rogvar"],
			category = "primaryProfession",
			profession = "Alchemy",
			description = L["Master Alchemist"],
			faction = "Horde",
		},
		[46405420] = {
			name = L["Thultash"],
			category = "vendors",
			description = L["Food & Drink Vendor"],
			faction = "Horde",
		},
		[45805300] = {
			name = L["Thultazor"],
			category = "vendors",
			description = L["Arcane Goods Vendor"],
			faction = "Horde",
		},
		[44605680] = {
			name = L["Banalash"],
			category = "vendors",
			description = L["Trade Goods"],
			faction = "Horde",
		},
		[45405700] = {
			name = L["Rartar"],
			category = "vendors",
			description = L["Alchemy Supplies"],
			faction = "Horde",
		},
		[26403160] = {
			name = L["Masat T'andr"],
			category = "vendors",
			description = L["Superior Leatherworker"],
			faction = "Neutral",
		},
		[48405545] = {
			name = L["Greshka"],
			category = "vendors",
			description = L["Demon Master"],
			faction = "Horde",
		},
		[61002040] = {
			name = L["Lost One Chieftain"],
			category = "rares",
			faction = "Neutral",
		},
		[61202060] = {
			name = L["Lost One Chieftain"],
			category = "rares",
			faction = "Neutral",
		},
		[61802000] = {
			name = L["Lost One Chieftain"],
			category = "rares",
			faction = "Neutral",
		},
		[61802080] = {
			name = L["Lost One Chieftain"],
			category = "rares",
			faction = "Neutral",
		},
		[61802180] = {
			name = L["Lost One Chieftain"],
			category = "rares",
			faction = "Neutral",
		},
		[62602040] = {
			name = L["Lost One Chieftain"],
			category = "rares",
			faction = "Neutral",
		},
		[62602160] = {
			name = L["Lost One Chieftain"],
			category = "rares",
			faction = "Neutral",
		},
		[63002100] = {
			name = L["Lost One Chieftain"],
			category = "rares",
			faction = "Neutral",
		},
		[62202300] = {
			name = L["Lost One Cook"],
			category = "rares",
			faction = "Neutral",
		},
		[62602200] = {
			name = L["Lost One Cook"],
			category = "rares",
			faction = "Neutral",
		},
		[62802360] = {
			name = L["Lost One Cook"],
			category = "rares",
			faction = "Neutral",
		},
		[62802580] = {
			name = L["Lost One Cook"],
			category = "rares",
			faction = "Neutral",
		},
		[65202220] = {
			name = L["Lost One Cook"],
			category = "rares",
			faction = "Neutral",
		},
		[65402080] = {
			name = L["Lost One Cook"],
			category = "rares",
			faction = "Neutral",
		},
		[65402260] = {
			name = L["Lost One Cook"],
			category = "rares",
			faction = "Neutral",
		},
		[65602280] = {
			name = L["Lost One Cook"],
			category = "rares",
			faction = "Neutral",
		},
		[65802440] = {
			name = L["Lost One Cook"],
			category = "rares",
			faction = "Neutral",
		},
		[66202480] = {
			name = L["Lost One Cook"],
			category = "rares",
			faction = "Neutral",
		},
		[66402060] = {
			name = L["Lost One Cook"],
			category = "rares",
			faction = "Neutral",
		},
		[67202000] = {
			name = L["Lost One Cook"],
			category = "rares",
			faction = "Neutral",
		},
		[63603980] = {
			name = L["Lord Captain Wyrmak"],
			category = "rares",
			faction = "Neutral",
		},
		[64003900] = {
			name = L["Lord Captain Wyrmak"],
			category = "rares",
			faction = "Neutral",
		},
		[68803900] = {
			name = L["Lord Captain Wyrmak"],
			category = "rares",
			faction = "Neutral",
		},
		[69203820] = {
			name = L["Lord Captain Wyrmak"],
			category = "rares",
			faction = "Neutral",
		},
		[70603800] = {
			name = L["Lord Captain Wyrmak"],
			category = "rares",
			faction = "Neutral",
		},
		[76604180] = {
			name = L["Lord Captain Wyrmak"],
			category = "rares",
			faction = "Neutral",
		},
		[78204120] = {
			name = L["Lord Captain Wyrmak"],
			category = "rares",
			faction = "Neutral",
		},
		[78604440] = {
			name = L["Lord Captain Wyrmak"],
			category = "rares",
			faction = "Neutral",
		},
		[78605900] = {
			name = L["Lord Captain Wyrmak"],
			category = "rares",
			faction = "Neutral",
		},
		[78606300] = {
			name = L["Lord Captain Wyrmak"],
			category = "rares",
			faction = "Neutral",
		},
		[78606380] = {
			name = L["Lord Captain Wyrmak"],
			category = "rares",
			faction = "Neutral",
		},
		[79004780] = {
			name = L["Lord Captain Wyrmak"],
			category = "rares",
			faction = "Neutral",
		},
		[79404620] = {
			name = L["Lord Captain Wyrmak"],
			category = "rares",
			faction = "Neutral",
		},
		[79404660] = {
			name = L["Lord Captain Wyrmak"],
			category = "rares",
			faction = "Neutral",
		},
		[79805080] = {
			name = L["Lord Captain Wyrmak"],
			category = "rares",
			faction = "Neutral",
		},
		[80004860] = {
			name = L["Lord Captain Wyrmak"],
			category = "rares",
			faction = "Neutral",
		},
		[80605120] = {
			name = L["Lord Captain Wyrmak"],
			category = "rares",
			faction = "Neutral",
		},
		[63008560] = {
			name = L["Fingat"],
			category = "rares",
			faction = "Neutral",
		},
		[63008740] = {
			name = L["Fingat"],
			category = "rares",
			faction = "Neutral",
		},
		[63009020] = {
			name = L["Fingat"],
			category = "rares",
			faction = "Neutral",
		},
		[93605960] = {
			name = L["Gilmorian"],
			category = "rares",
			faction = "Neutral",
		},
		[94205620] = {
			name = L["Gilmorian"],
			category = "rares",
			faction = "Neutral",
		},
		[23604500] = {
			name = L["Molt Thorn"],
			category = "rares",
			faction = "Neutral",
		},
		[24004100] = {
			name = L["Molt Thorn"],
			category = "rares",
			faction = "Neutral",
		},
		[24204560] = {
			name = L["Molt Thorn"],
			category = "rares",
			faction = "Neutral",
		},
		[27003500] = {
			name = L["Molt Thorn"],
			category = "rares",
			faction = "Neutral",
		},
		[27203580] = {
			name = L["Molt Thorn"],
			category = "rares",
			faction = "Neutral",
		},
		[28005140] = {
			name = L["Molt Thorn"],
			category = "rares",
			faction = "Neutral",
		},
		[29404580] = {
			name = L["Molt Thorn"],
			category = "rares",
			faction = "Neutral",
		},
		[29804760] = {
			name = L["Molt Thorn"],
			category = "rares",
			faction = "Neutral",
		},
		[30003300] = {
			name = L["Molt Thorn"],
			category = "rares",
			faction = "Neutral",
		},
		[30204580] = {
			name = L["Molt Thorn"],
			category = "rares",
			faction = "Neutral",
		},
		[31604440] = {
			name = L["Molt Thorn"],
			category = "rares",
			faction = "Neutral",
		},
		[31804260] = {
			name = L["Molt Thorn"],
			category = "rares",
			faction = "Neutral",
		},
		[37003800] = {
			name = L["Molt Thorn"],
			category = "rares",
			faction = "Neutral",
		},
		[42403320] = {
			name = L["Molt Thorn"],
			category = "rares",
			faction = "Neutral",
		},
		[60602040] = {
			name = L["Lost One Chieftain"],
			category = "rares",
			faction = "Neutral",
		},
		[61402420] = {
			name = L["Lost One Cook"],
			category = "rares",
			faction = "Neutral",
		},
		[81605260] = {
			name = L["Lord Captain Wyrmak"],
			category = "rares",
			faction = "Neutral",
		},
		[61008560] = {
			name = L["Fingat"],
			category = "rares",
			faction = "Neutral",
		},
		[62208740] = {
			name = L["Fingat"],
			category = "rares",
			faction = "Neutral",
		},
		[65808120] = {
			name = L["Fingat"],
			category = "rares",
			faction = "Neutral",
		},
		[78000560] = {
			name = L["Gilmorian"],
			category = "rares",
			faction = "Neutral",
		},
		[87807900] = {
			name = L["Gilmorian"],
			category = "rares",
			faction = "Neutral",
		},
		[89407440] = {
			name = L["Gilmorian"],
			category = "rares",
			faction = "Neutral",
		},
		[90007340] = {
			name = L["Gilmorian"],
			category = "rares",
			faction = "Neutral",
		},
		[18804480] = {
			name = L["Molt Thorn"],
			category = "rares",
			faction = "Neutral",
		},
		[21404620] = {
			name = L["Molt Thorn"],
			category = "rares",
			faction = "Neutral",
		},
		[23004700] = {
			name = L["Molt Thorn"],
			category = "rares",
			faction = "Neutral",
		},
		[24404920] = {
			name = L["Molt Thorn"],
			category = "rares",
			faction = "Neutral",
		},
		[27403740] = {
			name = L["Molt Thorn"],
			category = "rares",
			faction = "Neutral",
		},
		[27603380] = {
			name = L["Molt Thorn"],
			category = "rares",
			faction = "Neutral",
		},
		[28003700] = {
			name = L["Molt Thorn"],
			category = "rares",
			faction = "Neutral",
		},
		[29803660] = {
			name = L["Molt Thorn"],
			category = "rares",
			faction = "Neutral",
		},
		[30203540] = {
			name = L["Molt Thorn"],
			category = "rares",
			faction = "Neutral",
		},
		[30603440] = {
			name = L["Molt Thorn"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1437] = {
		[9405960] = {
			name = L["Shellei Brondir"],
			category = "flightmasters",
			fpName = L["Menethil Harbor, Wetlands"],
			description = L["Gryphon Master"],
			faction = "Alliance",
		},
		[10606080] = {
			name = L["Innkeeper Helbrek"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Alliance",
		},
		[10805970] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Alliance",
		},
		[11405940] = {
			name = L["Brak Durnad"],
			category = "repair",
			description = L["Weaponsmith"],
			faction = "Alliance",
		},
		[11405960] = {
			name = L["Brahnmar"],
			category = "repair",
			description = L["Armorer"],
			faction = "Alliance",
		},
		[8205580] = {
			name = L["Jennabink Powerseam"],
			category = "repair",
			description = L["Tailoring Supplies & Specialty Goods"],
			faction = "Alliance",
		},
		[11205840] = {
			name = L["Naela Trance"],
			category = "repair",
			description = L["Bowyer"],
			faction = "Alliance",
		},
		[11405945] = {
			name = L["Murndan Derth"],
			category = "vendors",
			description = L["Gunsmith"],
			faction = "Alliance",
		},
		[11005840] = {
			name = L["Edwina Monzor"],
			category = "repair",
			description = L["Fletcher"],
			faction = "Alliance",
		},
		[25602580] = {
			name = L["Wenna Silkbeard"],
			category = "repair",
			description = L["Special Goods Dealer"],
			faction = "Alliance",
		},
		[11404340] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[49404140] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[10405960] = {
			name = L["Bethaine Flinthammer"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Alliance",
		},
		[8005580] = {
			name = L["Telurinon Moonshadow"],
			category = "primaryProfession",
			profession = "Herbalism",
			description = L["Herbalism Trainer"],
			faction = "Alliance",
		},
		[8205860] = {
			name = L["Harold Riggs"],
			category = "secondaryProfession",
			profession = "Fishing",
			description = L["Fishing Trainer"],
			faction = "Alliance",
		},
		[10806120] = {
			name = L["Fremal Doohickey"],
			category = "secondaryProfession",
			profession = "First Aid",
			description = L["First Aid Trainer"],
			faction = "Alliance",
		},
		[10605680] = {
			name = L["Neal Allen"],
			category = "vendors",
			description = L["Engineering & General Goods Supplier"],
			faction = "Alliance",
		},
		[12005780] = {
			name = L["Gruham Rumdnul"],
			category = "vendors",
			description = L["General Supplies"],
			faction = "Alliance",
		},
		[8005620] = {
			name = L["Dewin Shimmerdawn"],
			category = "vendors",
			description = L["Alchemy Supplies"],
			faction = "Alliance",
		},
		[10406060] = {
			name = L["Kersok Prond"],
			category = "vendors",
			description = L["Tradesman"],
			faction = "Alliance",
		},
		[10406020] = {
			name = L["Samor Festivus"],
			category = "vendors",
			description = L["Shady Dealer"],
			faction = "Alliance",
		},
		[8605440] = {
			name = L["Unger Statforth"],
			category = "vendors",
			description = L["Horse Breeder"],
			faction = "Alliance",
		},
		[8205640] = {
			name = L["Falkan Armonis"],
			category = "vendors",
			subcategory = "reagentvendor",
			description = L["Reagent Vendor"],
			faction = "Alliance",
		},
		[26402580] = {
			name = L["Fradd Swiftgear"],
			category = "vendors",
			description = L["Engineering Supplies"],
			faction = "Alliance",
		},
		[8005820] = {
			name = L["Stuart Fleming"],
			category = "secondaryProfession",
			profession = "Fishing",
			description = L["Fisherman"],
			faction = "Alliance",
		},
		[46601820] = {
			name = L["Dark Iron Entrepreneur"],
			category = "vendors",
			description = L["Speciality Goods"],
			faction = "Alliance",
		},
		[50203780] = {
			name = L["Kixxle"],
			category = "vendors",
			description = L["Potions & Herbs"],
			faction = "Neutral",
		},
		[44204320] = {
			name = L["Dragonmaw Battlemaster"],
			category = "rares",
			faction = "Neutral",
		},
		[44404420] = {
			name = L["Dragonmaw Battlemaster"],
			category = "rares",
			faction = "Neutral",
		},
		[48404740] = {
			name = L["Dragonmaw Battlemaster"],
			category = "rares",
			faction = "Neutral",
		},
		[48804580] = {
			name = L["Dragonmaw Battlemaster"],
			category = "rares",
			faction = "Neutral",
		},
		[48804840] = {
			name = L["Dragonmaw Battlemaster"],
			category = "rares",
			faction = "Neutral",
		},
		[49004520] = {
			name = L["Dragonmaw Battlemaster"],
			category = "rares",
			faction = "Neutral",
		},
		[50004820] = {
			name = L["Dragonmaw Battlemaster"],
			category = "rares",
			faction = "Neutral",
		},
		[52005300] = {
			name = L["Dragonmaw Battlemaster"],
			category = "rares",
			faction = "Neutral",
		},
		[52605280] = {
			name = L["Dragonmaw Battlemaster"],
			category = "rares",
			faction = "Neutral",
		},
		[53005360] = {
			name = L["Dragonmaw Battlemaster"],
			category = "rares",
			faction = "Neutral",
		},
		[45606400] = {
			name = L["Leech Widow"],
			category = "rares",
			faction = "Neutral",
		},
		[46006180] = {
			name = L["Leech Widow"],
			category = "rares",
			faction = "Neutral",
		},
		[46206520] = {
			name = L["Leech Widow"],
			category = "rares",
			faction = "Neutral",
		},
		[46606540] = {
			name = L["Leech Widow"],
			category = "rares",
			faction = "Neutral",
		},
		[46806580] = {
			name = L["Leech Widow"],
			category = "rares",
			faction = "Neutral",
		},
		[47006160] = {
			name = L["Leech Widow"],
			category = "rares",
			faction = "Neutral",
		},
		[69802920] = {
			name = L["Razormaw Matriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[70803080] = {
			name = L["Razormaw Matriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[48007420] = {
			name = L["Ma'ruk Wyrmscale"],
			category = "rares",
			description = L["Dragonmaw Warlord"],
			faction = "Neutral",
		},
		[38404600] = {
			name = L["Garneg Charskull"],
			category = "rares",
			faction = "Neutral",
		},
		[38604620] = {
			name = L["Garneg Charskull"],
			category = "rares",
			faction = "Neutral",
		},
		[39204660] = {
			name = L["Garneg Charskull"],
			category = "rares",
			faction = "Neutral",
		},
		[39804660] = {
			name = L["Garneg Charskull"],
			category = "rares",
			faction = "Neutral",
		},
		[41204600] = {
			name = L["Garneg Charskull"],
			category = "rares",
			faction = "Neutral",
		},
		[46204480] = {
			name = L["Garneg Charskull"],
			category = "rares",
			faction = "Neutral",
		},
		[22403680] = {
			name = L["Mirelow"],
			category = "rares",
			faction = "Neutral",
		},
		[22602380] = {
			name = L["Mirelow"],
			category = "rares",
			faction = "Neutral",
		},
		[23803080] = {
			name = L["Mirelow"],
			category = "rares",
			faction = "Neutral",
		},
		[25203220] = {
			name = L["Mirelow"],
			category = "rares",
			faction = "Neutral",
		},
		[26603000] = {
			name = L["Mirelow"],
			category = "rares",
			faction = "Neutral",
		},
		[27003300] = {
			name = L["Mirelow"],
			category = "rares",
			faction = "Neutral",
		},
		[27003360] = {
			name = L["Mirelow"],
			category = "rares",
			faction = "Neutral",
		},
		[27803280] = {
			name = L["Mirelow"],
			category = "rares",
			faction = "Neutral",
		},
		[30003060] = {
			name = L["Gnawbone"],
			category = "rares",
			faction = "Neutral",
		},
		[32603380] = {
			name = L["Gnawbone"],
			category = "rares",
			faction = "Neutral",
		},
		[35802960] = {
			name = L["Gnawbone"],
			category = "rares",
			faction = "Neutral",
		},
		[38802960] = {
			name = L["Gnawbone"],
			category = "rares",
			faction = "Neutral",
		},
		[12007060] = {
			name = L["Sludginn"],
			category = "rares",
			faction = "Neutral",
		},
		[13806860] = {
			name = L["Sludginn"],
			category = "rares",
			faction = "Neutral",
		},
		[14806720] = {
			name = L["Sludginn"],
			category = "rares",
			faction = "Neutral",
		},
		[45606340] = {
			name = L["Leech Widow"],
			category = "rares",
			faction = "Neutral",
		},
		[46006220] = {
			name = L["Leech Widow"],
			category = "rares",
			faction = "Neutral",
		},
		[67603200] = {
			name = L["Razormaw Matriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[70003180] = {
			name = L["Razormaw Matriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[70803040] = {
			name = L["Razormaw Matriarch"],
			category = "rares",
			faction = "Neutral",
		},
		[43204420] = {
			name = L["Garneg Charskull"],
			category = "rares",
			faction = "Neutral",
		},
		[44404425] = {
			name = L["Garneg Charskull"],
			category = "rares",
			faction = "Neutral",
		},
		[21802220] = {
			name = L["Mirelow"],
			category = "rares",
			faction = "Neutral",
		},
		[22803140] = {
			name = L["Mirelow"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1421] = {
		[45604240] = {
			name = L["Karos Razok"],
			category = "flightmasters",
			fpName = L["The Sepulcher, Silverpine Forest"],
			description = L["Bat Handler"],
			faction = "Horde",
		},
		[43204120] = {
			name = L["Innkeeper Bates"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Horde",
		},
		[43404140] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Horde",
		},
		[46408640] = {
			name = L["Wallace the Blind"],
			category = "repair",
			description = L["Weaponsmith"],
			faction = "Horde",
		},
		[44603920] = {
			name = L["Alexandre Lefevre"],
			category = "repair",
			description = L["Leather Armor Merchant"],
			faction = "Horde",
		},
		[43204125] = {
			name = L["Sebastian Meloche"],
			category = "vendors",
			description = L["Armorer"],
			faction = "Horde",
		},
		[44603925] = {
			name = L["Andrea Boynton"],
			category = "vendors",
			description = L["Clothier"],
			faction = "Horde",
		},
		[45003940] = {
			name = L["Nadia Vernon"],
			category = "repair",
			description = L["Bowyer"],
			faction = "Horde",
		},
		[44204140] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[43404120] = {
			name = L["Sarah Goode"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Horde",
		},
		[43404040] = {
			name = L["Johan Focht"],
			category = "primaryProfession",
			profession = "Mining",
			description = L["Miner"],
			faction = "Horde",
		},
		[43204100] = {
			name = L["Guillaume Sorouy"],
			category = "primaryProfession",
			profession = "Blacksmith",
			description = L["Journeyman Blacksmith"],
			faction = "Horde",
		},
		[44004000] = {
			name = L["Edwin Harly"],
			category = "vendors",
			description = L["General Supplies"],
			faction = "Horde",
		},
		[43004180] = {
			name = L["Patrice Dwyer"],
			category = "vendors",
			subcategory = "poisonvendor",
			description = L["Poison Supplies"],
			faction = "Horde",
		},
		[43204060] = {
			name = L["Andrew Hilbert"],
			category = "vendors",
			description = L["Trade Goods"],
			faction = "Horde",
		},
		[62206420] = {
			name = L["Dalaran Brewmaster"],
			category = "vendors",
			faction = "Alliance",
		},
		[33001780] = {
			name = L["Killian Sanatha"],
			category = "secondaryProfession",
			profession = "Fishing",
			description = L["Fisherman"],
			faction = "Horde",
		},
		[43005080] = {
			name = L["Lilly"],
			category = "vendors",
			description = L["Enchanting Supplies"],
			faction = "Horde",
		},
		[54008220] = {
			name = L["Leo Sarn"],
			category = "vendors",
			description = L["Enchanting Supplies"],
			faction = "Horde",
		},
		[44003980] = {
			name = L["Gwyn Farrow"],
			category = "vendors",
			description = L["Mushroom Merchant"],
			faction = "Horde",
		},
		[60606440] = {
			name = L["Dalaran Spellscribe"],
			category = "rares",
			faction = "Neutral",
		},
		[62206400] = {
			name = L["Dalaran Spellscribe"],
			category = "rares",
			faction = "Neutral",
		},
		[63006220] = {
			name = L["Dalaran Spellscribe"],
			category = "rares",
			faction = "Neutral",
		},
		[63006540] = {
			name = L["Dalaran Spellscribe"],
			category = "rares",
			faction = "Neutral",
		},
		[63406320] = {
			name = L["Dalaran Spellscribe"],
			category = "rares",
			faction = "Neutral",
		},
		[63606540] = {
			name = L["Dalaran Spellscribe"],
			category = "rares",
			faction = "Neutral",
		},
		[63606560] = {
			name = L["Dalaran Spellscribe"],
			category = "rares",
			faction = "Neutral",
		},
		[64202400] = {
			name = L["Rot Hide Bruiser"],
			category = "rares",
			faction = "Neutral",
		},
		[64802200] = {
			name = L["Rot Hide Bruiser"],
			category = "rares",
			faction = "Neutral",
		},
		[64802460] = {
			name = L["Rot Hide Bruiser"],
			category = "rares",
			faction = "Neutral",
		},
		[65002140] = {
			name = L["Rot Hide Bruiser"],
			category = "rares",
			faction = "Neutral",
		},
		[65002300] = {
			name = L["Rot Hide Bruiser"],
			category = "rares",
			faction = "Neutral",
		},
		[65202040] = {
			name = L["Rot Hide Bruiser"],
			category = "rares",
			faction = "Neutral",
		},
		[65602300] = {
			name = L["Rot Hide Bruiser"],
			category = "rares",
			faction = "Neutral",
		},
		[66002700] = {
			name = L["Rot Hide Bruiser"],
			category = "rares",
			faction = "Neutral",
		},
		[66402540] = {
			name = L["Rot Hide Bruiser"],
			category = "rares",
			faction = "Neutral",
		},
		[66602640] = {
			name = L["Rot Hide Bruiser"],
			category = "rares",
			faction = "Neutral",
		},
		[67002400] = {
			name = L["Rot Hide Bruiser"],
			category = "rares",
			faction = "Neutral",
		},
		[67002480] = {
			name = L["Rot Hide Bruiser"],
			category = "rares",
			faction = "Neutral",
		},
		[68002480] = {
			name = L["Rot Hide Bruiser"],
			category = "rares",
			faction = "Neutral",
		},
		[68202560] = {
			name = L["Rot Hide Bruiser"],
			category = "rares",
			faction = "Neutral",
		},
		[65002500] = {
			name = L["Snarlmane"],
			category = "rares",
			faction = "Neutral",
		},
		[65402400] = {
			name = L["Snarlmane"],
			category = "rares",
			faction = "Neutral",
		},
		[65602380] = {
			name = L["Snarlmane"],
			category = "rares",
			faction = "Neutral",
		},
		[65802320] = {
			name = L["Snarlmane"],
			category = "rares",
			faction = "Neutral",
		},
		[66202500] = {
			name = L["Snarlmane"],
			category = "rares",
			faction = "Neutral",
		},
		[57207040] = {
			name = L["Ravenclaw Regent"],
			category = "rares",
			faction = "Neutral",
		},
		[57407100] = {
			name = L["Ravenclaw Regent"],
			category = "rares",
			faction = "Neutral",
		},
		[57606980] = {
			name = L["Ravenclaw Regent"],
			category = "rares",
			faction = "Neutral",
		},
		[57607120] = {
			name = L["Ravenclaw Regent"],
			category = "rares",
			faction = "Neutral",
		},
		[57807160] = {
			name = L["Ravenclaw Regent"],
			category = "rares",
			faction = "Neutral",
		},
		[46201720] = {
			name = L["Gorefang"],
			category = "rares",
			faction = "Neutral",
		},
		[46201800] = {
			name = L["Gorefang"],
			category = "rares",
			faction = "Neutral",
		},
		[46202660] = {
			name = L["Gorefang"],
			category = "rares",
			faction = "Neutral",
		},
		[46402620] = {
			name = L["Gorefang"],
			category = "rares",
			faction = "Neutral",
		},
		[46601760] = {
			name = L["Gorefang"],
			category = "rares",
			faction = "Neutral",
		},
		[46602480] = {
			name = L["Gorefang"],
			category = "rares",
			faction = "Neutral",
		},
		[46602680] = {
			name = L["Gorefang"],
			category = "rares",
			faction = "Neutral",
		},
		[46801900] = {
			name = L["Gorefang"],
			category = "rares",
			faction = "Neutral",
		},
		[46802560] = {
			name = L["Gorefang"],
			category = "rares",
			faction = "Neutral",
		},
		[47201700] = {
			name = L["Gorefang"],
			category = "rares",
			faction = "Neutral",
		},
		[47402440] = {
			name = L["Gorefang"],
			category = "rares",
			faction = "Neutral",
		},
		[48001920] = {
			name = L["Gorefang"],
			category = "rares",
			faction = "Neutral",
		},
		[49401900] = {
			name = L["Gorefang"],
			category = "rares",
			faction = "Neutral",
		},
		[50201820] = {
			name = L["Gorefang"],
			category = "rares",
			faction = "Neutral",
		},
		[50201880] = {
			name = L["Gorefang"],
			category = "rares",
			faction = "Neutral",
		},
		[50601800] = {
			name = L["Gorefang"],
			category = "rares",
			faction = "Neutral",
		},
		[51201940] = {
			name = L["Gorefang"],
			category = "rares",
			faction = "Neutral",
		},
		[59200840] = {
			name = L["Gorefang"],
			category = "rares",
			faction = "Neutral",
		},
		[59200860] = {
			name = L["Gorefang"],
			category = "rares",
			faction = "Neutral",
		},
		[59800800] = {
			name = L["Gorefang"],
			category = "rares",
			faction = "Neutral",
		},
		[59800920] = {
			name = L["Gorefang"],
			category = "rares",
			faction = "Neutral",
		},
		[51406260] = {
			name = L["Old Vicejaw"],
			category = "rares",
			faction = "Neutral",
		},
		[51406380] = {
			name = L["Old Vicejaw"],
			category = "rares",
			faction = "Neutral",
		},
		[51806280] = {
			name = L["Old Vicejaw"],
			category = "rares",
			faction = "Neutral",
		},
		[52206380] = {
			name = L["Old Vicejaw"],
			category = "rares",
			faction = "Neutral",
		},
		[53405220] = {
			name = L["Old Vicejaw"],
			category = "rares",
			faction = "Neutral",
		},
		[54005260] = {
			name = L["Old Vicejaw"],
			category = "rares",
			faction = "Neutral",
		},
		[54405240] = {
			name = L["Old Vicejaw"],
			category = "rares",
			faction = "Neutral",
		},
		[55006060] = {
			name = L["Old Vicejaw"],
			category = "rares",
			faction = "Neutral",
		},
		[55006240] = {
			name = L["Old Vicejaw"],
			category = "rares",
			faction = "Neutral",
		},
		[55204960] = {
			name = L["Old Vicejaw"],
			category = "rares",
			faction = "Neutral",
		},
		[55406260] = {
			name = L["Old Vicejaw"],
			category = "rares",
			faction = "Neutral",
		},
		[55606120] = {
			name = L["Old Vicejaw"],
			category = "rares",
			faction = "Neutral",
		},
		[56005980] = {
			name = L["Old Vicejaw"],
			category = "rares",
			faction = "Neutral",
		},
		[56206240] = {
			name = L["Old Vicejaw"],
			category = "rares",
			faction = "Neutral",
		},
		[56606400] = {
			name = L["Old Vicejaw"],
			category = "rares",
			faction = "Neutral",
		},
		[34200940] = {
			name = L["Krethis Shadowspinner"],
			category = "rares",
			faction = "Neutral",
		},
		[34201580] = {
			name = L["Krethis Shadowspinner"],
			category = "rares",
			faction = "Neutral",
		},
		[34801100] = {
			name = L["Krethis Shadowspinner"],
			category = "rares",
			faction = "Neutral",
		},
		[35000800] = {
			name = L["Krethis Shadowspinner"],
			category = "rares",
			faction = "Neutral",
		},
		[35001000] = {
			name = L["Krethis Shadowspinner"],
			category = "rares",
			faction = "Neutral",
		},
		[35201460] = {
			name = L["Krethis Shadowspinner"],
			category = "rares",
			faction = "Neutral",
		},
		[35400900] = {
			name = L["Krethis Shadowspinner"],
			category = "rares",
			faction = "Neutral",
		},
		[35401220] = {
			name = L["Krethis Shadowspinner"],
			category = "rares",
			faction = "Neutral",
		},
		[35401300] = {
			name = L["Krethis Shadowspinner"],
			category = "rares",
			faction = "Neutral",
		},
		[35401560] = {
			name = L["Krethis Shadowspinner"],
			category = "rares",
			faction = "Neutral",
		},
		[35600800] = {
			name = L["Krethis Shadowspinner"],
			category = "rares",
			faction = "Neutral",
		},
		[35601560] = {
			name = L["Krethis Shadowspinner"],
			category = "rares",
			faction = "Neutral",
		},
		[36201440] = {
			name = L["Krethis Shadowspinner"],
			category = "rares",
			faction = "Neutral",
		},
		[36401340] = {
			name = L["Krethis Shadowspinner"],
			category = "rares",
			faction = "Neutral",
		},
		[36401460] = {
			name = L["Krethis Shadowspinner"],
			category = "rares",
			faction = "Neutral",
		},
		[36601440] = {
			name = L["Krethis Shadowspinner"],
			category = "rares",
			faction = "Neutral",
		},
		[36601460] = {
			name = L["Krethis Shadowspinner"],
			category = "rares",
			faction = "Neutral",
		},
		[36601740] = {
			name = L["Krethis Shadowspinner"],
			category = "rares",
			faction = "Neutral",
		},
		[37201560] = {
			name = L["Krethis Shadowspinner"],
			category = "rares",
			faction = "Neutral",
		},
		[38201300] = {
			name = L["Krethis Shadowspinner"],
			category = "rares",
			faction = "Neutral",
		},
		[62806520] = {
			name = L["Dalaran Spellscribe"],
			category = "rares",
			faction = "Neutral",
		},
		[67202560] = {
			name = L["Rot Hide Bruiser"],
			category = "rares",
			faction = "Neutral",
		},
		[57207020] = {
			name = L["Ravenclaw Regent"],
			category = "rares",
			faction = "Neutral",
		},
		[46401940] = {
			name = L["Gorefang"],
			category = "rares",
			faction = "Neutral",
		},
		[47001760] = {
			name = L["Gorefang"],
			category = "rares",
			faction = "Neutral",
		},
		[50401940] = {
			name = L["Gorefang"],
			category = "rares",
			faction = "Neutral",
		},
		[34401000] = {
			name = L["Krethis Shadowspinner"],
			category = "rares",
			faction = "Neutral",
		},
		[36201560] = {
			name = L["Krethis Shadowspinner"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1422] = {
		[43008500] = {
			name = L["Bibilfaz Featherwhistle"],
			category = "flightmasters",
			fpName = L["Chillwind Camp, Western Plaguelands"],
			description = L["Gryphon Master"],
			faction = "Alliance",
		},
		[42808380] = {
			name = L["Argent Quartermaster Lightspark"],
			category = "repair",
			description = L["The Argent Dawn"],
			faction = "Alliance",
		},
		[43008440] = {
			name = L["Leonard Porter"],
			category = "repair",
			description = L["Leatherworking Supplies"],
			faction = "Alliance",
		},
		[45408560] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[42608380] = {
			name = L["Alchemist Arbington"],
			category = "vendors",
			faction = "Alliance",
		},
		[68007740] = {
			name = L["Magnus Frostwake"],
			category = "vendors",
			faction = "Neutral",
		},
		[42601820] = {
			name = L["Scarlet Judge"],
			category = "rares",
			faction = "Neutral",
		},
		[42601880] = {
			name = L["Scarlet Judge"],
			category = "rares",
			faction = "Neutral",
		},
		[54402400] = {
			name = L["Scarlet High Clerist"],
			category = "rares",
			faction = "Neutral",
		},
		[55002320] = {
			name = L["Scarlet High Clerist"],
			category = "rares",
			faction = "Neutral",
		},
		[45801880] = {
			name = L["Scarlet Executioner"],
			category = "rares",
			faction = "Neutral",
		},
		[45400920] = {
			name = L["Foreman Jerris"],
			category = "rares",
			faction = "Neutral",
		},
		[48403160] = {
			name = L["Foreman Marcrid"],
			category = "rares",
			faction = "Neutral",
		},
		[44205040] = {
			name = L["Foulmane"],
			category = "rares",
			faction = "Neutral",
		},
		[45405220] = {
			name = L["Foulmane"],
			category = "rares",
			faction = "Neutral",
		},
		[45405280] = {
			name = L["Foulmane"],
			category = "rares",
			faction = "Neutral",
		},
		[45605280] = {
			name = L["Foulmane"],
			category = "rares",
			faction = "Neutral",
		},
		[38806820] = {
			name = L["Putridius"],
			category = "rares",
			faction = "Neutral",
		},
		[39606740] = {
			name = L["Putridius"],
			category = "rares",
			faction = "Neutral",
		},
		[40806600] = {
			name = L["Putridius"],
			category = "rares",
			faction = "Neutral",
		},
		[44006640] = {
			name = L["Putridius"],
			category = "rares",
			faction = "Neutral",
		},
		[64203800] = {
			name = L["The Husk"],
			category = "rares",
			faction = "Neutral",
		},
		[42201800] = {
			name = L["Scarlet Judge"],
			category = "rares",
			faction = "Neutral",
		},
		[42401900] = {
			name = L["Scarlet Judge"],
			category = "rares",
			faction = "Neutral",
		},
		[54202460] = {
			name = L["Scarlet High Clerist"],
			category = "rares",
			faction = "Neutral",
		},
		[54402620] = {
			name = L["Scarlet High Clerist"],
			category = "rares",
			faction = "Neutral",
		},
		[54602380] = {
			name = L["Scarlet High Clerist"],
			category = "rares",
			faction = "Neutral",
		},
		[54802340] = {
			name = L["Scarlet High Clerist"],
			category = "rares",
			faction = "Neutral",
		},
		[45801840] = {
			name = L["Scarlet Executioner"],
			category = "rares",
			faction = "Neutral",
		},
		[46401560] = {
			name = L["Foreman Jerris"],
			category = "rares",
			faction = "Neutral",
		},
		[45203740] = {
			name = L["Foreman Marcrid"],
			category = "rares",
			faction = "Neutral",
		},
		[44805060] = {
			name = L["Foulmane"],
			category = "rares",
			faction = "Neutral",
		},
		[46205220] = {
			name = L["Foulmane"],
			category = "rares",
			faction = "Neutral",
		},
		[49407860] = {
			name = L["Lord Maldazzar"],
			category = "rares",
			faction = "Neutral",
		},
		[49607860] = {
			name = L["Lord Maldazzar"],
			category = "rares",
			faction = "Neutral",
		},
		[50408000] = {
			name = L["Lord Maldazzar"],
			category = "rares",
			faction = "Neutral",
		},
		[51207920] = {
			name = L["Lord Maldazzar"],
			category = "rares",
			faction = "Neutral",
		},
		[52208040] = {
			name = L["Lord Maldazzar"],
			category = "rares",
			faction = "Neutral",
		},
		[40606740] = {
			name = L["Putridius"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1427] = {
		[37803060] = {
			name = L["Lanie Reed"],
			category = "flightmasters",
			fpName = L["Thorium Point, Searing Gorge"],
			description = L["Gryphon Master"],
			faction = "Alliance",
		},
		[34803060] = {
			name = L["Grisha"],
			category = "flightmasters",
			fpName = L["Thorium Point, Searing Gorge"],
			description = L["Wind Rider Master"],
			faction = "Horde",
		},
		[41407480] = {
			name = L["Graw Cornerstone"],
			category = "repair",
			description = L["Mail Armor Merchant"],
			faction = "Alliance",
		},
		[38602840] = {
			name = L["Master Smith Burninate"],
			category = "repair",
			description = L["The Thorium Brotherhood"],
			faction = "Neutral",
		},
		[35402300] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[34802620] = {
			name = L["Rekk'tilac"],
			category = "rares",
			faction = "Neutral",
		},
		[61807280] = {
			name = L["Rekk'tilac"],
			category = "rares",
			faction = "Neutral",
		},
		[29206080] = {
			name = L["Smoldar"],
			category = "rares",
			faction = "Neutral",
		},
		[30005080] = {
			name = L["Smoldar"],
			category = "rares",
			faction = "Neutral",
		},
		[33004480] = {
			name = L["Faulty War Golem"],
			category = "rares",
			faction = "Neutral",
		},
		[34004620] = {
			name = L["Faulty War Golem"],
			category = "rares",
			faction = "Neutral",
		},
		[43004280] = {
			name = L["Faulty War Golem"],
			category = "rares",
			faction = "Neutral",
		},
		[47406600] = {
			name = L["Faulty War Golem"],
			category = "rares",
			faction = "Neutral",
		},
		[59605620] = {
			name = L["Faulty War Golem"],
			category = "rares",
			faction = "Neutral",
		},
		[55605880] = {
			name = L["Shleipnarr"],
			category = "rares",
			faction = "Neutral",
		},
		[58405200] = {
			name = L["Shleipnarr"],
			category = "rares",
			faction = "Neutral",
		},
		[65004500] = {
			name = L["Shleipnarr"],
			category = "rares",
			faction = "Neutral",
		},
		[35805600] = {
			name = L["Scald"],
			category = "rares",
			faction = "Neutral",
		},
		[50204880] = {
			name = L["Scald"],
			category = "rares",
			faction = "Neutral",
		},
		[51404540] = {
			name = L["Scald"],
			category = "rares",
			faction = "Neutral",
		},
		[14203760] = {
			name = L["Highlord Mastrogonde"],
			category = "rares",
			faction = "Neutral",
		},
		[14203880] = {
			name = L["Highlord Mastrogonde"],
			category = "rares",
			faction = "Neutral",
		},
		[28402600] = {
			name = L["Highlord Mastrogonde"],
			category = "rares",
			faction = "Neutral",
		},
		[29602700] = {
			name = L["Highlord Mastrogonde"],
			category = "rares",
			faction = "Neutral",
		},
		[29802620] = {
			name = L["Highlord Mastrogonde"],
			category = "rares",
			faction = "Neutral",
		},
		[30602640] = {
			name = L["Highlord Mastrogonde"],
			category = "rares",
			faction = "Neutral",
		},
		[41002500] = {
			name = L["Slave Master Blackheart"],
			category = "rares",
			faction = "Neutral",
		},
		[41004460] = {
			name = L["Slave Master Blackheart"],
			category = "rares",
			faction = "Neutral",
		},
		[41202620] = {
			name = L["Slave Master Blackheart"],
			category = "rares",
			faction = "Neutral",
		},
		[41804380] = {
			name = L["Slave Master Blackheart"],
			category = "rares",
			faction = "Neutral",
		},
		[44403740] = {
			name = L["Slave Master Blackheart"],
			category = "rares",
			faction = "Neutral",
		},
		[45403860] = {
			name = L["Slave Master Blackheart"],
			category = "rares",
			faction = "Neutral",
		},
		[45603880] = {
			name = L["Slave Master Blackheart"],
			category = "rares",
			faction = "Neutral",
		},
		[46202580] = {
			name = L["Slave Master Blackheart"],
			category = "rares",
			faction = "Neutral",
		},
		[30406980] = {
			name = L["Rekk'tilac"],
			category = "rares",
			faction = "Neutral",
		},
		[35802580] = {
			name = L["Rekk'tilac"],
			category = "rares",
			faction = "Neutral",
		},
		[58005900] = {
			name = L["Faulty War Golem"],
			category = "rares",
			faction = "Neutral",
		},
		[59405900] = {
			name = L["Faulty War Golem"],
			category = "rares",
			faction = "Neutral",
		},
		[54805600] = {
			name = L["Shleipnarr"],
			category = "rares",
			faction = "Neutral",
		},
		[37405520] = {
			name = L["Scald"],
			category = "rares",
			faction = "Neutral",
		},
		[50604760] = {
			name = L["Scald"],
			category = "rares",
			faction = "Neutral",
		},
		[29402660] = {
			name = L["Highlord Mastrogonde"],
			category = "rares",
			faction = "Neutral",
		},
		[40803560] = {
			name = L["Slave Master Blackheart"],
			category = "rares",
			faction = "Neutral",
		},
		[41002460] = {
			name = L["Slave Master Blackheart"],
			category = "rares",
			faction = "Neutral",
		},
		[41404460] = {
			name = L["Slave Master Blackheart"],
			category = "rares",
			faction = "Neutral",
		},
		[42603480] = {
			name = L["Slave Master Blackheart"],
			category = "rares",
			faction = "Neutral",
		},
		[42803560] = {
			name = L["Slave Master Blackheart"],
			category = "rares",
			faction = "Neutral",
		},
		[45403840] = {
			name = L["Slave Master Blackheart"],
			category = "rares",
			faction = "Neutral",
		},
		[46002680] = {
			name = L["Slave Master Blackheart"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1419] = {
		[65402440] = {
			name = L["Alexandra Constantine"],
			category = "flightmasters",
			fpName = L["Nethergarde Keep, Blasted Lands"],
			description = L["Gryphon Master"],
			faction = "Alliance",
		},
		[64101930] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Alliance",
		},
		[66001740] = {
			name = L["Strumner Flintheel"],
			category = "repair",
			description = L["Armor Crafter"],
			faction = "Alliance",
		},
		[63401680] = {
			name = L["Bernie Heisten"],
			category = "vendors",
			description = L["Food & Drink"],
			faction = "Alliance",
		},
		[66801840] = {
			name = L["Nina Lightbrew"],
			category = "vendors",
			description = L["Alchemy Supplies"],
			faction = "Alliance",
		},
		[41401180] = {
			name = L["Mojo the Twisted"],
			category = "rares",
			faction = "Neutral",
		},
		[41401260] = {
			name = L["Mojo the Twisted"],
			category = "rares",
			faction = "Neutral",
		},
		[45201600] = {
			name = L["Mojo the Twisted"],
			category = "rares",
			faction = "Neutral",
		},
		[48803760] = {
			name = L["Magronos the Unyielding"],
			category = "rares",
			faction = "Neutral",
		},
		[49004000] = {
			name = L["Magronos the Unyielding"],
			category = "rares",
			faction = "Neutral",
		},
		[44604600] = {
			name = L["Akubar the Seer"],
			category = "rares",
			faction = "Neutral",
		},
		[45404780] = {
			name = L["Akubar the Seer"],
			category = "rares",
			faction = "Neutral",
		},
		[45604620] = {
			name = L["Akubar the Seer"],
			category = "rares",
			faction = "Neutral",
		},
		[45804860] = {
			name = L["Akubar the Seer"],
			category = "rares",
			faction = "Neutral",
		},
		[52005260] = {
			name = L["Akubar the Seer"],
			category = "rares",
			faction = "Neutral",
		},
		[58204580] = {
			name = L["Akubar the Seer"],
			category = "rares",
			faction = "Neutral",
		},
		[58804480] = {
			name = L["Akubar the Seer"],
			category = "rares",
			faction = "Neutral",
		},
		[59604540] = {
			name = L["Akubar the Seer"],
			category = "rares",
			faction = "Neutral",
		},
		[59804640] = {
			name = L["Akubar the Seer"],
			category = "rares",
			faction = "Neutral",
		},
		[57203300] = {
			name = L["Spiteflayer"],
			category = "rares",
			faction = "Neutral",
		},
		[57803280] = {
			name = L["Spiteflayer"],
			category = "rares",
			faction = "Neutral",
		},
		[58404040] = {
			name = L["Spiteflayer"],
			category = "rares",
			faction = "Neutral",
		},
		[58803800] = {
			name = L["Spiteflayer"],
			category = "rares",
			faction = "Neutral",
		},
		[59403860] = {
			name = L["Spiteflayer"],
			category = "rares",
			faction = "Neutral",
		},
		[59403960] = {
			name = L["Spiteflayer"],
			category = "rares",
			faction = "Neutral",
		},
		[59404260] = {
			name = L["Spiteflayer"],
			category = "rares",
			faction = "Neutral",
		},
		[60003860] = {
			name = L["Spiteflayer"],
			category = "rares",
			faction = "Neutral",
		},
		[60203760] = {
			name = L["Spiteflayer"],
			category = "rares",
			faction = "Neutral",
		},
		[47403640] = {
			name = L["Ravage"],
			category = "rares",
			faction = "Neutral",
		},
		[47803420] = {
			name = L["Ravage"],
			category = "rares",
			faction = "Neutral",
		},
		[58203620] = {
			name = L["Ravage"],
			category = "rares",
			faction = "Neutral",
		},
		[58603540] = {
			name = L["Ravage"],
			category = "rares",
			faction = "Neutral",
		},
		[59203620] = {
			name = L["Ravage"],
			category = "rares",
			faction = "Neutral",
		},
		[60203765] = {
			name = L["Ravage"],
			category = "rares",
			faction = "Neutral",
		},
		[45004240] = {
			name = L["Clack the Reaver"],
			category = "rares",
			faction = "Neutral",
		},
		[49603620] = {
			name = L["Clack the Reaver"],
			category = "rares",
			faction = "Neutral",
		},
		[50603680] = {
			name = L["Clack the Reaver"],
			category = "rares",
			faction = "Neutral",
		},
		[51203600] = {
			name = L["Clack the Reaver"],
			category = "rares",
			faction = "Neutral",
		},
		[51803560] = {
			name = L["Clack the Reaver"],
			category = "rares",
			faction = "Neutral",
		},
		[54203320] = {
			name = L["Clack the Reaver"],
			category = "rares",
			faction = "Neutral",
		},
		[55003340] = {
			name = L["Clack the Reaver"],
			category = "rares",
			faction = "Neutral",
		},
		[55003580] = {
			name = L["Clack the Reaver"],
			category = "rares",
			faction = "Neutral",
		},
		[56003440] = {
			name = L["Clack the Reaver"],
			category = "rares",
			faction = "Neutral",
		},
		[56403540] = {
			name = L["Clack the Reaver"],
			category = "rares",
			faction = "Neutral",
		},
		[56803460] = {
			name = L["Clack the Reaver"],
			category = "rares",
			faction = "Neutral",
		},
		[57003560] = {
			name = L["Clack the Reaver"],
			category = "rares",
			faction = "Neutral",
		},
		[57603400] = {
			name = L["Clack the Reaver"],
			category = "rares",
			faction = "Neutral",
		},
		[61003540] = {
			name = L["Clack the Reaver"],
			category = "rares",
			faction = "Neutral",
		},
		[61603480] = {
			name = L["Clack the Reaver"],
			category = "rares",
			faction = "Neutral",
		},
		[43802520] = {
			name = L["Deatheye"],
			category = "rares",
			faction = "Neutral",
		},
		[44802520] = {
			name = L["Deatheye"],
			category = "rares",
			faction = "Neutral",
		},
		[45402640] = {
			name = L["Deatheye"],
			category = "rares",
			faction = "Neutral",
		},
		[46202460] = {
			name = L["Deatheye"],
			category = "rares",
			faction = "Neutral",
		},
		[55202700] = {
			name = L["Grunter"],
			category = "rares",
			faction = "Neutral",
		},
		[61802240] = {
			name = L["Grunter"],
			category = "rares",
			faction = "Neutral",
		},
		[39603620] = {
			name = L["Dreadscorn"],
			category = "rares",
			faction = "Neutral",
		},
		[40003660] = {
			name = L["Dreadscorn"],
			category = "rares",
			faction = "Neutral",
		},
		[41203820] = {
			name = L["Dreadscorn"],
			category = "rares",
			faction = "Neutral",
		},
		[42003900] = {
			name = L["Dreadscorn"],
			category = "rares",
			faction = "Neutral",
		},
		[42404000] = {
			name = L["Dreadscorn"],
			category = "rares",
			faction = "Neutral",
		},
		[42803920] = {
			name = L["Dreadscorn"],
			category = "rares",
			faction = "Neutral",
		},
		[42001160] = {
			name = L["Mojo the Twisted"],
			category = "rares",
			faction = "Neutral",
		},
		[49603980] = {
			name = L["Magronos the Unyielding"],
			category = "rares",
			faction = "Neutral",
		},
		[58804040] = {
			name = L["Spiteflayer"],
			category = "rares",
			faction = "Neutral",
		},
		[59603640] = {
			name = L["Ravage"],
			category = "rares",
			faction = "Neutral",
		},
		[46201760] = {
			name = L["Deatheye"],
			category = "rares",
			faction = "Neutral",
		},
		[47601920] = {
			name = L["Deatheye"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1432] = {
		[33805080] = {
			name = L["Thorgrum Borrelson"],
			category = "flightmasters",
			fpName = L["Thelsamar, Loch Modan"],
			description = L["Gryphon Master"],
			faction = "Alliance",
		},
		[35404840] = {
			name = L["Innkeeper Hearthstove"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Alliance",
		},
		[34804770] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Alliance",
		},
		[34004660] = {
			name = L["Morhan Coppertongue"],
			category = "repair",
			description = L["Metalsmith"],
			faction = "Alliance",
		},
		[42801000] = {
			name = L["Nillen Andemar"],
			category = "repair",
			description = L["Macecrafter"],
			faction = "Alliance",
		},
		[82606400] = {
			name = L["Kat Sampson"],
			category = "repair",
			description = L["Leather Armor Merchant"],
			faction = "Alliance",
		},
		[64806600] = {
			name = L["Aldren Cordon"],
			category = "repair",
			description = L["Clothier"],
			faction = "Alliance",
		},
		[24001800] = {
			name = L["Gothor Brumn"],
			category = "repair",
			description = L["Armorer"],
			faction = "Alliance",
		},
		[35804360] = {
			name = L["Vrok Blunderblast"],
			category = "repair",
			description = L["Gunsmith"],
			faction = "Alliance",
		},
		[83006340] = {
			name = L["Irene Sureshot"],
			category = "repair",
			description = L["Gunsmith"],
			faction = "Alliance",
		},
		[83006300] = {
			name = L["Cliff Hadin"],
			category = "repair",
			description = L["Bowyer"],
			faction = "Alliance",
		},
		[32404680] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[34604800] = {
			name = L["Lina Hearthstove"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Alliance",
		},
		[37004920] = {
			name = L["Ghak Healtouch"],
			category = "primaryProfession",
			profession = "Alchemy",
			description = L["Journeyman Alchemist"],
			faction = "Alliance",
		},
		[36404840] = {
			name = L["Kali Healtouch"],
			category = "primaryProfession",
			profession = "Herbalism",
			description = L["Herbalist"],
			faction = "Alliance",
		},
		[37004780] = {
			name = L["Brock Stoneseeker"],
			category = "primaryProfession",
			profession = "Mining",
			description = L["Mining Trainer"],
			faction = "Alliance",
		},
		[40603960] = {
			name = L["Warg Deepwater"],
			category = "secondaryProfession",
			profession = "Fishing",
			description = L["Fisherman"],
			faction = "Alliance",
		},
		[45801360] = {
			name = L["Deek Fizzlebizz"],
			category = "primaryProfession",
			profession = "Engineering",
			description = L["Journeyman Engineer"],
			faction = "Alliance",
		},
		[82206280] = {
			name = L["Claude Erksine"],
			category = "trainers",
			description = L["Pet Trainer"],
			faction = "Alliance",
		},
		[82206240] = {
			name = L["Dargh Trueaim"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Hunter Trainer"],
			classes = {
				HUNTER = true,
			},
			faction = "Alliance",
		},
		[37004720] = {
			name = L["Karm Ironquill"],
			category = "vendors",
			description = L["Mining Supplies"],
			faction = "Alliance",
		},
		[35604900] = {
			name = L["Drac Roughcut"],
			category = "vendors",
			description = L["Tradesman"],
			faction = "Alliance",
		},
		[36004600] = {
			name = L["Rann Flamespinner"],
			category = "vendors",
			description = L["Tailoring Supplies"],
			faction = "Alliance",
		},
		[34804860] = {
			name = L["Yanni Stoutheart"],
			category = "vendors",
			description = L["General Supplies"],
			faction = "Alliance",
		},
		[40403940] = {
			name = L["Khara Deepwater"],
			category = "vendors",
			description = L["Fishing Supplies"],
			faction = "Alliance",
		},
		[82406340] = {
			name = L["Xandar Goodbeard"],
			category = "vendors",
			description = L["General Supplies"],
			faction = "Alliance",
		},
		[34404720] = {
			name = L["Greishan Ironstove"],
			category = "vendors",
			description = L["Traveling Merchant"],
			faction = "Alliance",
		},
		[35204960] = {
			name = L["Honni Goldenoat"],
			category = "vendors",
			description = L["Baker"],
			faction = "Alliance",
		},
		[62606180] = {
			name = L["Boss Galgosh"],
			category = "rares",
			description = L["Stonesplinter Chieftain"],
			faction = "Neutral",
		},
		[67006320] = {
			name = L["Boss Galgosh"],
			category = "rares",
			description = L["Stonesplinter Chieftain"],
			faction = "Neutral",
		},
		[67006880] = {
			name = L["Boss Galgosh"],
			category = "rares",
			description = L["Stonesplinter Chieftain"],
			faction = "Neutral",
		},
		[67406480] = {
			name = L["Boss Galgosh"],
			category = "rares",
			description = L["Stonesplinter Chieftain"],
			faction = "Neutral",
		},
		[67806880] = {
			name = L["Boss Galgosh"],
			category = "rares",
			description = L["Stonesplinter Chieftain"],
			faction = "Neutral",
		},
		[68406600] = {
			name = L["Boss Galgosh"],
			category = "rares",
			description = L["Stonesplinter Chieftain"],
			faction = "Neutral",
		},
		[68806860] = {
			name = L["Boss Galgosh"],
			category = "rares",
			description = L["Stonesplinter Chieftain"],
			faction = "Neutral",
		},
		[69206600] = {
			name = L["Boss Galgosh"],
			category = "rares",
			description = L["Stonesplinter Chieftain"],
			faction = "Neutral",
		},
		[69206680] = {
			name = L["Boss Galgosh"],
			category = "rares",
			description = L["Stonesplinter Chieftain"],
			faction = "Neutral",
		},
		[69206780] = {
			name = L["Boss Galgosh"],
			category = "rares",
			description = L["Stonesplinter Chieftain"],
			faction = "Neutral",
		},
		[70006520] = {
			name = L["Boss Galgosh"],
			category = "rares",
			description = L["Stonesplinter Chieftain"],
			faction = "Neutral",
		},
		[70006640] = {
			name = L["Boss Galgosh"],
			category = "rares",
			description = L["Stonesplinter Chieftain"],
			faction = "Neutral",
		},
		[70206740] = {
			name = L["Boss Galgosh"],
			category = "rares",
			description = L["Stonesplinter Chieftain"],
			faction = "Neutral",
		},
		[72606900] = {
			name = L["Boss Galgosh"],
			category = "rares",
			description = L["Stonesplinter Chieftain"],
			faction = "Neutral",
		},
		[68406840] = {
			name = L["Magosh"],
			category = "rares",
			description = L["Stonesplinter Tribal Shaman"],
			faction = "Neutral",
		},
		[68606320] = {
			name = L["Magosh"],
			category = "rares",
			description = L["Stonesplinter Tribal Shaman"],
			faction = "Neutral",
		},
		[68606820] = {
			name = L["Magosh"],
			category = "rares",
			description = L["Stonesplinter Tribal Shaman"],
			faction = "Neutral",
		},
		[69206605] = {
			name = L["Magosh"],
			category = "rares",
			description = L["Stonesplinter Tribal Shaman"],
			faction = "Neutral",
		},
		[69806620] = {
			name = L["Magosh"],
			category = "rares",
			description = L["Stonesplinter Tribal Shaman"],
			faction = "Neutral",
		},
		[70006540] = {
			name = L["Magosh"],
			category = "rares",
			description = L["Stonesplinter Tribal Shaman"],
			faction = "Neutral",
		},
		[70406280] = {
			name = L["Magosh"],
			category = "rares",
			description = L["Stonesplinter Tribal Shaman"],
			faction = "Neutral",
		},
		[70406720] = {
			name = L["Magosh"],
			category = "rares",
			description = L["Stonesplinter Tribal Shaman"],
			faction = "Neutral",
		},
		[70406780] = {
			name = L["Magosh"],
			category = "rares",
			description = L["Stonesplinter Tribal Shaman"],
			faction = "Neutral",
		},
		[70806580] = {
			name = L["Magosh"],
			category = "rares",
			description = L["Stonesplinter Tribal Shaman"],
			faction = "Neutral",
		},
		[71206780] = {
			name = L["Magosh"],
			category = "rares",
			description = L["Stonesplinter Tribal Shaman"],
			faction = "Neutral",
		},
		[72806180] = {
			name = L["Magosh"],
			category = "rares",
			description = L["Stonesplinter Tribal Shaman"],
			faction = "Neutral",
		},
		[72806360] = {
			name = L["Magosh"],
			category = "rares",
			description = L["Stonesplinter Tribal Shaman"],
			faction = "Neutral",
		},
		[34202680] = {
			name = L["Grizlak"],
			category = "rares",
			faction = "Neutral",
		},
		[34402640] = {
			name = L["Grizlak"],
			category = "rares",
			faction = "Neutral",
		},
		[34802720] = {
			name = L["Grizlak"],
			category = "rares",
			faction = "Neutral",
		},
		[35002760] = {
			name = L["Grizlak"],
			category = "rares",
			faction = "Neutral",
		},
		[35602200] = {
			name = L["Grizlak"],
			category = "rares",
			faction = "Neutral",
		},
		[35802780] = {
			name = L["Grizlak"],
			category = "rares",
			faction = "Neutral",
		},
		[36002440] = {
			name = L["Grizlak"],
			category = "rares",
			faction = "Neutral",
		},
		[36202680] = {
			name = L["Grizlak"],
			category = "rares",
			faction = "Neutral",
		},
		[36402600] = {
			name = L["Grizlak"],
			category = "rares",
			faction = "Neutral",
		},
		[36602560] = {
			name = L["Grizlak"],
			category = "rares",
			faction = "Neutral",
		},
		[56803020] = {
			name = L["Large Loch Crocolisk"],
			category = "rares",
			faction = "Neutral",
		},
		[57402940] = {
			name = L["Large Loch Crocolisk"],
			category = "rares",
			faction = "Neutral",
		},
		[57803100] = {
			name = L["Large Loch Crocolisk"],
			category = "rares",
			faction = "Neutral",
		},
		[58002920] = {
			name = L["Large Loch Crocolisk"],
			category = "rares",
			faction = "Neutral",
		},
		[58003380] = {
			name = L["Large Loch Crocolisk"],
			category = "rares",
			faction = "Neutral",
		},
		[58203160] = {
			name = L["Large Loch Crocolisk"],
			category = "rares",
			faction = "Neutral",
		},
		[58402800] = {
			name = L["Large Loch Crocolisk"],
			category = "rares",
			faction = "Neutral",
		},
		[58402980] = {
			name = L["Large Loch Crocolisk"],
			category = "rares",
			faction = "Neutral",
		},
		[58403340] = {
			name = L["Large Loch Crocolisk"],
			category = "rares",
			faction = "Neutral",
		},
		[58803260] = {
			name = L["Large Loch Crocolisk"],
			category = "rares",
			faction = "Neutral",
		},
		[58803800] = {
			name = L["Large Loch Crocolisk"],
			category = "rares",
			faction = "Neutral",
		},
		[59003460] = {
			name = L["Large Loch Crocolisk"],
			category = "rares",
			faction = "Neutral",
		},
		[59202220] = {
			name = L["Large Loch Crocolisk"],
			category = "rares",
			faction = "Neutral",
		},
		[59202880] = {
			name = L["Large Loch Crocolisk"],
			category = "rares",
			faction = "Neutral",
		},
		[59203000] = {
			name = L["Large Loch Crocolisk"],
			category = "rares",
			faction = "Neutral",
		},
		[59203240] = {
			name = L["Large Loch Crocolisk"],
			category = "rares",
			faction = "Neutral",
		},
		[59203860] = {
			name = L["Large Loch Crocolisk"],
			category = "rares",
			faction = "Neutral",
		},
		[59603000] = {
			name = L["Large Loch Crocolisk"],
			category = "rares",
			faction = "Neutral",
		},
		[59803180] = {
			name = L["Large Loch Crocolisk"],
			category = "rares",
			faction = "Neutral",
		},
		[59803960] = {
			name = L["Large Loch Crocolisk"],
			category = "rares",
			faction = "Neutral",
		},
		[60003900] = {
			name = L["Large Loch Crocolisk"],
			category = "rares",
			faction = "Neutral",
		},
		[47007640] = {
			name = L["Siege Golem"],
			category = "rares",
			faction = "Neutral",
		},
		[77805220] = {
			name = L["Shanda the Spinner"],
			category = "rares",
			faction = "Neutral",
		},
		[78405300] = {
			name = L["Shanda the Spinner"],
			category = "rares",
			faction = "Neutral",
		},
		[79205160] = {
			name = L["Shanda the Spinner"],
			category = "rares",
			faction = "Neutral",
		},
		[79805200] = {
			name = L["Shanda the Spinner"],
			category = "rares",
			faction = "Neutral",
		},
		[66202100] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[67202160] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[67402300] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[68202180] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[68402300] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[68602920] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[69002300] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[69002580] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[69402140] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[69602160] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[69602520] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[69802000] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[69802420] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[69802660] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[69802760] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[70802020] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[71002100] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[71402240] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[72002420] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[72002500] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[72202320] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[72602560] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[72602760] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[72802440] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[73002140] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[73002160] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[73002700] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[73402540] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[61807800] = {
			name = L["Lord Condar"],
			category = "rares",
			faction = "Neutral",
		},
		[62807820] = {
			name = L["Lord Condar"],
			category = "rares",
			faction = "Neutral",
		},
		[63607740] = {
			name = L["Lord Condar"],
			category = "rares",
			faction = "Neutral",
		},
		[74806780] = {
			name = L["Lord Condar"],
			category = "rares",
			faction = "Neutral",
		},
		[75206660] = {
			name = L["Lord Condar"],
			category = "rares",
			faction = "Neutral",
		},
		[76807380] = {
			name = L["Lord Condar"],
			category = "rares",
			faction = "Neutral",
		},
		[78007320] = {
			name = L["Lord Condar"],
			category = "rares",
			faction = "Neutral",
		},
		[69006600] = {
			name = L["Boss Galgosh"],
			category = "rares",
			description = L["Stonesplinter Chieftain"],
			faction = "Neutral",
		},
		[35802740] = {
			name = L["Grizlak"],
			category = "rares",
			faction = "Neutral",
		},
		[58802820] = {
			name = L["Large Loch Crocolisk"],
			category = "rares",
			faction = "Neutral",
		},
		[59003300] = {
			name = L["Large Loch Crocolisk"],
			category = "rares",
			faction = "Neutral",
		},
		[59203800] = {
			name = L["Large Loch Crocolisk"],
			category = "rares",
			faction = "Neutral",
		},
		[59403120] = {
			name = L["Large Loch Crocolisk"],
			category = "rares",
			faction = "Neutral",
		},
		[60003840] = {
			name = L["Large Loch Crocolisk"],
			category = "rares",
			faction = "Neutral",
		},
		[60203900] = {
			name = L["Large Loch Crocolisk"],
			category = "rares",
			faction = "Neutral",
		},
		[68402120] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[68602220] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[69002480] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[69402580] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[69602560] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[72802620] = {
			name = L["Emogg the Crusher"],
			category = "rares",
			faction = "Neutral",
		},
		[77807460] = {
			name = L["Lord Condar"],
			category = "rares",
			faction = "Neutral",
		},
		[78407440] = {
			name = L["Lord Condar"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1436] = {
		[56405260] = {
			name = L["Thor"],
			category = "flightmasters",
			fpName = L["Sentinel Hill, Westfall"],
			description = L["Gryphon Master"],
			faction = "Alliance",
		},
		[52805360] = {
			name = L["Innkeeper Heather"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Alliance",
		},
		[53105330] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Alliance",
		},
		[57605380] = {
			name = L["William MacGregor"],
			category = "repair",
			description = L["Bowyer"],
			faction = "Alliance",
		},
		[43406680] = {
			name = L["Defias Profiteer"],
			category = "repair",
			description = L["Free Wheeling Merchant"],
			faction = "Alliance",
		},
		[51404960] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[53005300] = {
			name = L["Kirk Maxwell"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Alliance",
		},
		[56003120] = {
			name = L["Farmer Saldean"],
			category = "vendors",
			faction = "Alliance",
		},
		[56804720] = {
			name = L["Quartermaster Lewis"],
			category = "vendors",
			description = L["Quartermaster"],
			faction = "Alliance",
		},
		[57605400] = {
			name = L["Gina MacGregor"],
			category = "vendors",
			description = L["Trade Supplies"],
			faction = "Alliance",
		},
		[57405220] = {
			name = L["Antonio Perelli"],
			category = "vendors",
			description = L["Traveling Salesman"],
			faction = "Alliance",
		},
		[57605360] = {
			name = L["Mike Miller"],
			category = "vendors",
			description = L["Bread Merchant"],
			faction = "Alliance",
		},
		[36209000] = {
			name = L["Kriggon Talsone"],
			category = "secondaryProfession",
			profession = "Fishing",
			description = L["Fisherman"],
			faction = "Alliance",
		},
		[52205280] = {
			name = L["Christopher Hewen"],
			category = "vendors",
			description = L["General Trade Goods Vendor"],
			faction = "Alliance",
		},
		[43406040] = {
			name = L["Vultros"],
			category = "rares",
			faction = "Neutral",
		},
		[44605900] = {
			name = L["Vultros"],
			category = "rares",
			faction = "Neutral",
		},
		[45405820] = {
			name = L["Vultros"],
			category = "rares",
			faction = "Neutral",
		},
		[45605860] = {
			name = L["Vultros"],
			category = "rares",
			faction = "Neutral",
		},
		[45606020] = {
			name = L["Vultros"],
			category = "rares",
			faction = "Neutral",
		},
		[46005640] = {
			name = L["Vultros"],
			category = "rares",
			faction = "Neutral",
		},
		[48404460] = {
			name = L["Vultros"],
			category = "rares",
			faction = "Neutral",
		},
		[63007440] = {
			name = L["Vultros"],
			category = "rares",
			faction = "Neutral",
		},
		[64405520] = {
			name = L["Vultros"],
			category = "rares",
			faction = "Neutral",
		},
		[35203440] = {
			name = L["Sergeant Brashclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[35403260] = {
			name = L["Sergeant Brashclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[36003240] = {
			name = L["Sergeant Brashclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[36203060] = {
			name = L["Sergeant Brashclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[36403300] = {
			name = L["Sergeant Brashclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[36403380] = {
			name = L["Sergeant Brashclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[36602940] = {
			name = L["Sergeant Brashclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[37002760] = {
			name = L["Sergeant Brashclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[37003020] = {
			name = L["Sergeant Brashclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[37003560] = {
			name = L["Sergeant Brashclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[37203100] = {
			name = L["Sergeant Brashclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[37203300] = {
			name = L["Sergeant Brashclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[37403180] = {
			name = L["Sergeant Brashclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[37603340] = {
			name = L["Sergeant Brashclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[37803220] = {
			name = L["Sergeant Brashclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[38203460] = {
			name = L["Sergeant Brashclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[38403360] = {
			name = L["Sergeant Brashclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[38603340] = {
			name = L["Sergeant Brashclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[39603400] = {
			name = L["Sergeant Brashclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[40403320] = {
			name = L["Sergeant Brashclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[26406680] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[27005140] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[27603900] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[27604240] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[27604340] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[28007060] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[28807080] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[29803160] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[30602720] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[30608060] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[30808160] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[32208260] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[32602520] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[33008360] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[33802280] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[33808480] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[34401980] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[35001980] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[35201920] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[36001920] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[36408660] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[36801760] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[37208780] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[39601320] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[40801260] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[43601260] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[44800940] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[46201020] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[47201100] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[47401020] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[49201080] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[49201160] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[50601040] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[51401080] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[51800880] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[53001160] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[53400940] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[53401020] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[53401080] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[54000960] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[54201120] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[54801020] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[55001060] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[55201240] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[55201340] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[55800940] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[25806460] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[26405100] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[26406560] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[26604780] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[26804060] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[26805000] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[26806960] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[27004160] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[27006600] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[27204720] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[27405180] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[27604200] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[27604620] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[28203740] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[28207420] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[28403880] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[28407180] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[28407460] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[28603740] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[29007320] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[29207780] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[29407660] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[30007980] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[30408060] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[30808080] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[31203120] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[31408200] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[31408300] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[31608240] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[32408300] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[33208220] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[33208440] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[33408280] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[34008340] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[34008480] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[34408420] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[34608460] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[36801800] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[36801980] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[37001920] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[39201360] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[42000960] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[42001120] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[45000980] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[45601020] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[45601060] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[47001040] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[48400980] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[48601120] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[49201020] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[49601480] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[51801080] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[52401040] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[52600900] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[52600980] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[54401080] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[54401200] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[55200960] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[55801100] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[41602800] = {
			name = L["Leprithus"],
			category = "rares",
			faction = "Neutral",
		},
		[42202900] = {
			name = L["Leprithus"],
			category = "rares",
			faction = "Neutral",
		},
		[42602900] = {
			name = L["Leprithus"],
			category = "rares",
			faction = "Neutral",
		},
		[43603000] = {
			name = L["Leprithus"],
			category = "rares",
			faction = "Neutral",
		},
		[45602820] = {
			name = L["Leprithus"],
			category = "rares",
			faction = "Neutral",
		},
		[61806840] = {
			name = L["Leprithus"],
			category = "rares",
			faction = "Neutral",
		},
		[61807280] = {
			name = L["Leprithus"],
			category = "rares",
			faction = "Neutral",
		},
		[62606740] = {
			name = L["Leprithus"],
			category = "rares",
			faction = "Neutral",
		},
		[64806460] = {
			name = L["Leprithus"],
			category = "rares",
			faction = "Neutral",
		},
		[37005160] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
		[37605100] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
		[38005180] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
		[38605100] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
		[42003420] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
		[43603580] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
		[44403700] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
		[44603820] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
		[45003580] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
		[45403480] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
		[49006420] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
		[49602320] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
		[49606440] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
		[50002400] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
		[50206500] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
		[50602480] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
		[50802200] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
		[50802380] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
		[50806720] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
		[50806760] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
		[51206880] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
		[51402260] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
		[62206140] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
		[45001860] = {
			name = L["Master Digger"],
			category = "rares",
			faction = "Neutral",
		},
		[45201840] = {
			name = L["Master Digger"],
			category = "rares",
			faction = "Neutral",
		},
		[45801800] = {
			name = L["Master Digger"],
			category = "rares",
			faction = "Neutral",
		},
		[46201860] = {
			name = L["Master Digger"],
			category = "rares",
			faction = "Neutral",
		},
		[46601940] = {
			name = L["Master Digger"],
			category = "rares",
			faction = "Neutral",
		},
		[46601960] = {
			name = L["Master Digger"],
			category = "rares",
			faction = "Neutral",
		},
		[35207000] = {
			name = L["Vultros"],
			category = "rares",
			faction = "Neutral",
		},
		[64805620] = {
			name = L["Vultros"],
			category = "rares",
			faction = "Neutral",
		},
		[34403240] = {
			name = L["Sergeant Brashclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[34803100] = {
			name = L["Sergeant Brashclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[35002940] = {
			name = L["Sergeant Brashclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[36203180] = {
			name = L["Sergeant Brashclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[36803440] = {
			name = L["Sergeant Brashclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[37603140] = {
			name = L["Sergeant Brashclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[37803200] = {
			name = L["Sergeant Brashclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[38003780] = {
			name = L["Sergeant Brashclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[38803380] = {
			name = L["Sergeant Brashclaw"],
			category = "rares",
			faction = "Neutral",
		},
		[26405240] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[26804680] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[27404100] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[27404600] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[27605140] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[28204120] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[33008260] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[33202340] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[34002160] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[34208420] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[34802300] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[45601065] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[51801085] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[53601240] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[55601080] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[55601460] = {
			name = L["Slark"],
			category = "rares",
			faction = "Neutral",
		},
		[26404880] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[27604020] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[51401085] = {
			name = L["Brack"],
			category = "rares",
			faction = "Neutral",
		},
		[41202760] = {
			name = L["Leprithus"],
			category = "rares",
			faction = "Neutral",
		},
		[42002920] = {
			name = L["Leprithus"],
			category = "rares",
			faction = "Neutral",
		},
		[42402980] = {
			name = L["Leprithus"],
			category = "rares",
			faction = "Neutral",
		},
		[42403080] = {
			name = L["Leprithus"],
			category = "rares",
			faction = "Neutral",
		},
		[43002840] = {
			name = L["Leprithus"],
			category = "rares",
			faction = "Neutral",
		},
		[63806720] = {
			name = L["Leprithus"],
			category = "rares",
			faction = "Neutral",
		},
		[38005080] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
		[39004940] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
		[39605200] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
		[45003160] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
		[48802400] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
		[49402480] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
		[50402380] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
		[51002760] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
		[52006860] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
		[62206180] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
		[63405880] = {
			name = L["Foe Reaper 4000"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1433] = {
		[30605920] = {
			name = L["Ariena Stormfeather"],
			category = "flightmasters",
			fpName = L["Lakeshire, Redridge"],
			description = L["Gryphon Master"],
			faction = "Alliance",
		},
		[26804460] = {
			name = L["Innkeeper Brianna"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Alliance",
		},
		[26404670] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Alliance",
		},
		[26804540] = {
			name = L["Kimberly Hiett"],
			category = "repair",
			description = L["Fletcher"],
			faction = "Alliance",
		},
		[30604660] = {
			name = L["Kara Adams"],
			category = "repair",
			description = L["Shield Crafter"],
			faction = "Alliance",
		},
		[30804660] = {
			name = L["Dorin Songblade"],
			category = "repair",
			description = L["Armorer"],
			faction = "Alliance",
		},
		[23804140] = {
			name = L["Henry Chapal"],
			category = "repair",
			description = L["Gunsmith"],
			faction = "Alliance",
		},
		[88407100] = {
			name = L["Bernard Brubaker"],
			category = "repair",
			description = L["Leather Armor Merchant"],
			faction = "Alliance",
		},
		[20805640] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[26804660] = {
			name = L["Penny"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Alliance",
		},
		[21404580] = {
			name = L["Alma Jainrose"],
			category = "primaryProfession",
			profession = "Herbalism",
			description = L["Herbalism Trainer"],
			faction = "Alliance",
		},
		[26605100] = {
			name = L["Matthew Hooper"],
			category = "secondaryProfession",
			profession = "Fishing",
			description = L["Fishing Trainer"],
			faction = "Alliance",
		},
		[22804380] = {
			name = L["Crystal Boughman"],
			category = "secondaryProfession",
			profession = "Cooking",
			description = L["Cooking Trainer"],
			faction = "Alliance",
		},
		[88807100] = {
			name = L["Wilma Ranthal"],
			category = "primaryProfession",
			profession = "Skinning",
			description = L["Skinning Trainer"],
			faction = "Alliance",
		},
		[29004740] = {
			name = L["Amy Davenport"],
			category = "vendors",
			description = L["Tradeswoman"],
			faction = "Alliance",
		},
		[29804740] = {
			name = L["Karen Taylor"],
			category = "vendors",
			description = L["Mining and Smithing Supplies"],
			faction = "Alliance",
		},
		[28804740] = {
			name = L["Lindsay Ashlock"],
			category = "vendors",
			description = L["General Supplies"],
			faction = "Alliance",
		},
		[28804745] = {
			name = L["Antonio Perelli"],
			category = "vendors",
			description = L["Traveling Salesman"],
			faction = "Alliance",
		},
		[21004640] = {
			name = L["Lamar Veisilli"],
			category = "vendors",
			description = L["Fruit Seller"],
			faction = "Alliance",
		},
		[27404760] = {
			name = L["Vernon Hale"],
			category = "vendors",
			description = L["Bait and Tackle Supplier"],
			faction = "Alliance",
		},
		[88807080] = {
			name = L["Clyde Ranthal"],
			category = "vendors",
			description = L["Leatherworking Supplies"],
			faction = "Alliance",
		},
		[26604340] = {
			name = L["Gloria Femmel"],
			category = "vendors",
			description = L["Cooking Supplies"],
			faction = "Alliance",
		},
		[22604420] = {
			name = L["Gretchen Vogel"],
			category = "vendors",
			description = L["Waitress"],
			faction = "Alliance",
		},
		[26804340] = {
			name = L["Sherman Femmel"],
			category = "vendors",
			description = L["Butcher"],
			faction = "Alliance",
		},
		[25004120] = {
			name = L["Gerald Crawley"],
			category = "vendors",
			subcategory = "poisonvendor",
			description = L["Poison Supplier"],
			faction = "Alliance",
		},
		[27204540] = {
			name = L["Franklin Hamar"],
			category = "vendors",
			description = L["Tailoring Supplies"],
			faction = "Alliance",
		},
		[74407920] = {
			name = L["Captured Servant of Azora"],
			category = "vendors",
			description = L["Specialist Tailoring Supplies"],
			faction = "Alliance",
		},
		[26804380] = {
			name = L["Bartender Wental"],
			category = "vendors",
			description = L["Food and Drinks"],
			faction = "Alliance",
		},
		[33000660] = {
			name = L["Kazon"],
			category = "rares",
			faction = "Neutral",
		},
		[34400700] = {
			name = L["Kazon"],
			category = "rares",
			faction = "Neutral",
		},
		[34400820] = {
			name = L["Kazon"],
			category = "rares",
			faction = "Neutral",
		},
		[34600720] = {
			name = L["Kazon"],
			category = "rares",
			faction = "Neutral",
		},
		[34801020] = {
			name = L["Kazon"],
			category = "rares",
			faction = "Neutral",
		},
		[35000760] = {
			name = L["Kazon"],
			category = "rares",
			faction = "Neutral",
		},
		[35001140] = {
			name = L["Kazon"],
			category = "rares",
			faction = "Neutral",
		},
		[35200860] = {
			name = L["Kazon"],
			category = "rares",
			faction = "Neutral",
		},
		[35801200] = {
			name = L["Kazon"],
			category = "rares",
			faction = "Neutral",
		},
		[36001300] = {
			name = L["Kazon"],
			category = "rares",
			faction = "Neutral",
		},
		[36200880] = {
			name = L["Kazon"],
			category = "rares",
			faction = "Neutral",
		},
		[36400960] = {
			name = L["Kazon"],
			category = "rares",
			faction = "Neutral",
		},
		[36600860] = {
			name = L["Kazon"],
			category = "rares",
			faction = "Neutral",
		},
		[36600960] = {
			name = L["Kazon"],
			category = "rares",
			faction = "Neutral",
		},
		[36601120] = {
			name = L["Kazon"],
			category = "rares",
			faction = "Neutral",
		},
		[37001300] = {
			name = L["Kazon"],
			category = "rares",
			faction = "Neutral",
		},
		[37200780] = {
			name = L["Kazon"],
			category = "rares",
			faction = "Neutral",
		},
		[37201160] = {
			name = L["Kazon"],
			category = "rares",
			faction = "Neutral",
		},
		[38001300] = {
			name = L["Kazon"],
			category = "rares",
			faction = "Neutral",
		},
		[39201400] = {
			name = L["Kazon"],
			category = "rares",
			faction = "Neutral",
		},
		[41201560] = {
			name = L["Kazon"],
			category = "rares",
			faction = "Neutral",
		},
		[42001560] = {
			name = L["Kazon"],
			category = "rares",
			faction = "Neutral",
		},
		[50203780] = {
			name = L["Chatter"],
			category = "rares",
			faction = "Neutral",
		},
		[51404340] = {
			name = L["Chatter"],
			category = "rares",
			faction = "Neutral",
		},
		[52004240] = {
			name = L["Chatter"],
			category = "rares",
			faction = "Neutral",
		},
		[52004520] = {
			name = L["Chatter"],
			category = "rares",
			faction = "Neutral",
		},
		[52204560] = {
			name = L["Chatter"],
			category = "rares",
			faction = "Neutral",
		},
		[52403840] = {
			name = L["Chatter"],
			category = "rares",
			faction = "Neutral",
		},
		[52603900] = {
			name = L["Chatter"],
			category = "rares",
			faction = "Neutral",
		},
		[53204040] = {
			name = L["Chatter"],
			category = "rares",
			faction = "Neutral",
		},
		[54404720] = {
			name = L["Chatter"],
			category = "rares",
			faction = "Neutral",
		},
		[54804360] = {
			name = L["Chatter"],
			category = "rares",
			faction = "Neutral",
		},
		[55004340] = {
			name = L["Chatter"],
			category = "rares",
			faction = "Neutral",
		},
		[56004380] = {
			name = L["Chatter"],
			category = "rares",
			faction = "Neutral",
		},
		[57204160] = {
			name = L["Chatter"],
			category = "rares",
			faction = "Neutral",
		},
		[58004040] = {
			name = L["Chatter"],
			category = "rares",
			faction = "Neutral",
		},
		[75403300] = {
			name = L["Rohh the Silent"],
			category = "rares",
			faction = "Neutral",
		},
		[75403960] = {
			name = L["Rohh the Silent"],
			category = "rares",
			faction = "Neutral",
		},
		[75603260] = {
			name = L["Rohh the Silent"],
			category = "rares",
			faction = "Neutral",
		},
		[75803180] = {
			name = L["Rohh the Silent"],
			category = "rares",
			faction = "Neutral",
		},
		[76403600] = {
			name = L["Rohh the Silent"],
			category = "rares",
			faction = "Neutral",
		},
		[77003540] = {
			name = L["Rohh the Silent"],
			category = "rares",
			faction = "Neutral",
		},
		[77203920] = {
			name = L["Rohh the Silent"],
			category = "rares",
			faction = "Neutral",
		},
		[78004040] = {
			name = L["Rohh the Silent"],
			category = "rares",
			faction = "Neutral",
		},
		[81804860] = {
			name = L["Rohh the Silent"],
			category = "rares",
			faction = "Neutral",
		},
		[82004720] = {
			name = L["Rohh the Silent"],
			category = "rares",
			faction = "Neutral",
		},
		[82204780] = {
			name = L["Rohh the Silent"],
			category = "rares",
			faction = "Neutral",
		},
		[82205500] = {
			name = L["Rohh the Silent"],
			category = "rares",
			faction = "Neutral",
		},
		[82404960] = {
			name = L["Rohh the Silent"],
			category = "rares",
			faction = "Neutral",
		},
		[82805400] = {
			name = L["Rohh the Silent"],
			category = "rares",
			faction = "Neutral",
		},
		[83405760] = {
			name = L["Rohh the Silent"],
			category = "rares",
			faction = "Neutral",
		},
		[83605680] = {
			name = L["Rohh the Silent"],
			category = "rares",
			faction = "Neutral",
		},
		[62206120] = {
			name = L["Seeker Aqualon"],
			category = "rares",
			faction = "Neutral",
		},
		[62206180] = {
			name = L["Seeker Aqualon"],
			category = "rares",
			faction = "Neutral",
		},
		[62806220] = {
			name = L["Seeker Aqualon"],
			category = "rares",
			faction = "Neutral",
		},
		[63206260] = {
			name = L["Seeker Aqualon"],
			category = "rares",
			faction = "Neutral",
		},
		[63606260] = {
			name = L["Seeker Aqualon"],
			category = "rares",
			faction = "Neutral",
		},
		[64606600] = {
			name = L["Seeker Aqualon"],
			category = "rares",
			faction = "Neutral",
		},
		[37205020] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[38205680] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[38605940] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[39205440] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[39406420] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[40005360] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[40006440] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[40605180] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[41405080] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[42204920] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[42206440] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[42405160] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[42605420] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[42805140] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[43405160] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[44005120] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[44605220] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[44805140] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[45206420] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[45606500] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[45805260] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[51206860] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[53006620] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[54006220] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[55206400] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[13806280] = {
			name = L["Ribchaser"],
			category = "rares",
			faction = "Neutral",
		},
		[14206620] = {
			name = L["Ribchaser"],
			category = "rares",
			faction = "Neutral",
		},
		[14406180] = {
			name = L["Ribchaser"],
			category = "rares",
			faction = "Neutral",
		},
		[14606740] = {
			name = L["Ribchaser"],
			category = "rares",
			faction = "Neutral",
		},
		[15805840] = {
			name = L["Ribchaser"],
			category = "rares",
			faction = "Neutral",
		},
		[15806000] = {
			name = L["Ribchaser"],
			category = "rares",
			faction = "Neutral",
		},
		[16006720] = {
			name = L["Ribchaser"],
			category = "rares",
			faction = "Neutral",
		},
		[17206640] = {
			name = L["Ribchaser"],
			category = "rares",
			faction = "Neutral",
		},
		[17406280] = {
			name = L["Ribchaser"],
			category = "rares",
			faction = "Neutral",
		},
		[17606500] = {
			name = L["Ribchaser"],
			category = "rares",
			faction = "Neutral",
		},
		[28607440] = {
			name = L["Ribchaser"],
			category = "rares",
			faction = "Neutral",
		},
		[28808280] = {
			name = L["Ribchaser"],
			category = "rares",
			faction = "Neutral",
		},
		[29408120] = {
			name = L["Ribchaser"],
			category = "rares",
			faction = "Neutral",
		},
		[30208000] = {
			name = L["Ribchaser"],
			category = "rares",
			faction = "Neutral",
		},
		[31008320] = {
			name = L["Ribchaser"],
			category = "rares",
			faction = "Neutral",
		},
		[31208200] = {
			name = L["Ribchaser"],
			category = "rares",
			faction = "Neutral",
		},
		[31208400] = {
			name = L["Ribchaser"],
			category = "rares",
			faction = "Neutral",
		},
		[31408460] = {
			name = L["Ribchaser"],
			category = "rares",
			faction = "Neutral",
		},
		[32208240] = {
			name = L["Ribchaser"],
			category = "rares",
			faction = "Neutral",
		},
		[32408340] = {
			name = L["Ribchaser"],
			category = "rares",
			faction = "Neutral",
		},
		[32808400] = {
			name = L["Ribchaser"],
			category = "rares",
			faction = "Neutral",
		},
		[32808480] = {
			name = L["Ribchaser"],
			category = "rares",
			faction = "Neutral",
		},
		[33008200] = {
			name = L["Ribchaser"],
			category = "rares",
			faction = "Neutral",
		},
		[33208300] = {
			name = L["Ribchaser"],
			category = "rares",
			faction = "Neutral",
		},
		[33808140] = {
			name = L["Ribchaser"],
			category = "rares",
			faction = "Neutral",
		},
		[34008320] = {
			name = L["Ribchaser"],
			category = "rares",
			faction = "Neutral",
		},
		[35006600] = {
			name = L["Snarlflare"],
			category = "rares",
			faction = "Neutral",
		},
		[35406680] = {
			name = L["Snarlflare"],
			category = "rares",
			faction = "Neutral",
		},
		[35606660] = {
			name = L["Snarlflare"],
			category = "rares",
			faction = "Neutral",
		},
		[36006620] = {
			name = L["Snarlflare"],
			category = "rares",
			faction = "Neutral",
		},
		[36606660] = {
			name = L["Snarlflare"],
			category = "rares",
			faction = "Neutral",
		},
		[42003260] = {
			name = L["Snarlflare"],
			category = "rares",
			faction = "Neutral",
		},
		[42403120] = {
			name = L["Snarlflare"],
			category = "rares",
			faction = "Neutral",
		},
		[42403160] = {
			name = L["Snarlflare"],
			category = "rares",
			faction = "Neutral",
		},
		[42803140] = {
			name = L["Snarlflare"],
			category = "rares",
			faction = "Neutral",
		},
		[42803240] = {
			name = L["Snarlflare"],
			category = "rares",
			faction = "Neutral",
		},
		[43803100] = {
			name = L["Snarlflare"],
			category = "rares",
			faction = "Neutral",
		},
		[47803460] = {
			name = L["Snarlflare"],
			category = "rares",
			faction = "Neutral",
		},
		[48403440] = {
			name = L["Snarlflare"],
			category = "rares",
			faction = "Neutral",
		},
		[48803420] = {
			name = L["Snarlflare"],
			category = "rares",
			faction = "Neutral",
		},
		[48803520] = {
			name = L["Snarlflare"],
			category = "rares",
			faction = "Neutral",
		},
		[88406360] = {
			name = L["Boulderheart"],
			category = "rares",
			faction = "Neutral",
		},
		[88606480] = {
			name = L["Boulderheart"],
			category = "rares",
			faction = "Neutral",
		},
		[88606560] = {
			name = L["Boulderheart"],
			category = "rares",
			faction = "Neutral",
		},
		[88606760] = {
			name = L["Boulderheart"],
			category = "rares",
			faction = "Neutral",
		},
		[88806700] = {
			name = L["Boulderheart"],
			category = "rares",
			faction = "Neutral",
		},
		[89207020] = {
			name = L["Boulderheart"],
			category = "rares",
			faction = "Neutral",
		},
		[89406860] = {
			name = L["Boulderheart"],
			category = "rares",
			faction = "Neutral",
		},
		[35000800] = {
			name = L["Kazon"],
			category = "rares",
			faction = "Neutral",
		},
		[36000800] = {
			name = L["Kazon"],
			category = "rares",
			faction = "Neutral",
		},
		[51804500] = {
			name = L["Chatter"],
			category = "rares",
			faction = "Neutral",
		},
		[52003780] = {
			name = L["Chatter"],
			category = "rares",
			faction = "Neutral",
		},
		[52803740] = {
			name = L["Chatter"],
			category = "rares",
			faction = "Neutral",
		},
		[57804800] = {
			name = L["Chatter"],
			category = "rares",
			faction = "Neutral",
		},
		[75803160] = {
			name = L["Rohh the Silent"],
			category = "rares",
			faction = "Neutral",
		},
		[83004780] = {
			name = L["Rohh the Silent"],
			category = "rares",
			faction = "Neutral",
		},
		[58205820] = {
			name = L["Seeker Aqualon"],
			category = "rares",
			faction = "Neutral",
		},
		[37405400] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[37805320] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[38005100] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[43606420] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[47605060] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[47606540] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[48606740] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[51205880] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[54606260] = {
			name = L["Squiddic"],
			category = "rares",
			faction = "Neutral",
		},
		[13806460] = {
			name = L["Ribchaser"],
			category = "rares",
			faction = "Neutral",
		},
		[15006020] = {
			name = L["Ribchaser"],
			category = "rares",
			faction = "Neutral",
		},
		[16206060] = {
			name = L["Ribchaser"],
			category = "rares",
			faction = "Neutral",
		},
		[16606040] = {
			name = L["Ribchaser"],
			category = "rares",
			faction = "Neutral",
		},
		[30808320] = {
			name = L["Ribchaser"],
			category = "rares",
			faction = "Neutral",
		},
		[34408280] = {
			name = L["Ribchaser"],
			category = "rares",
			faction = "Neutral",
		},
		[88406500] = {
			name = L["Boulderheart"],
			category = "rares",
			faction = "Neutral",
		},
		[88406580] = {
			name = L["Boulderheart"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1423] = {
		[81605920] = {
			name = L["Khaelyn Steelwing"],
			category = "flightmasters",
			fpName = L["Light's Hope Chapel, Eastern Plaguelands"],
			description = L["Gryphon Master"],
			faction = "Alliance",
		},
		[80205700] = {
			name = L["Georgia"],
			category = "flightmasters",
			fpName = L["Light's Hope Chapel, Eastern Plaguelands"],
			description = L["Bat Handler"],
			faction = "Horde",
		},
		[80905860] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Neutral",
		},
		[47204440] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[79406380] = {
			name = L["Caretaker Alen"],
			category = "vendors",
			description = L["The Argent Dawn"],
			faction = "Neutral",
		},
		[81406000] = {
			name = L["Quartermaster Miranda Breechlock"],
			category = "vendors",
			description = L["The Argent Dawn"],
			faction = "Neutral",
		},
		[14403360] = {
			name = L["Augustus the Touched"],
			category = "vendors",
			faction = "Neutral",
		},
		[80405760] = {
			name = L["Jase Farlane"],
			category = "vendors",
			description = L["Trade Supplies"],
			faction = "Neutral",
		},
		[15007920] = {
			name = L["Duggan Wildhammer"],
			category = "rares",
			faction = "Neutral",
		},
		[19606560] = {
			name = L["Duggan Wildhammer"],
			category = "rares",
			faction = "Neutral",
		},
		[38207520] = {
			name = L["Hed'mush the Rotting"],
			category = "rares",
			faction = "Neutral",
		},
		[65402180] = {
			name = L["Warlord Thresh'jin"],
			category = "rares",
			faction = "Neutral",
		},
		[70001820] = {
			name = L["Zul'Brin Warpbranch"],
			category = "rares",
			faction = "Neutral",
		},
		[72201460] = {
			name = L["Zul'Brin Warpbranch"],
			category = "rares",
			faction = "Neutral",
		},
		[52001620] = {
			name = L["Ranger Lord Hawkspear"],
			category = "rares",
			faction = "Neutral",
		},
		[52801700] = {
			name = L["Ranger Lord Hawkspear"],
			category = "rares",
			faction = "Neutral",
		},
		[53201860] = {
			name = L["Ranger Lord Hawkspear"],
			category = "rares",
			faction = "Neutral",
		},
		[38402480] = {
			name = L["Lord Darkscythe"],
			category = "rares",
			faction = "Neutral",
		},
		[39205360] = {
			name = L["Deathspeaker Selendre"],
			category = "rares",
			description = L["Cult of the Damned"],
			faction = "Neutral",
		},
		[32408340] = {
			name = L["Duggan Wildhammer"],
			category = "rares",
			faction = "Neutral",
		},
		[41406880] = {
			name = L["Duggan Wildhammer"],
			category = "rares",
			faction = "Neutral",
		},
		[83003920] = {
			name = L["Deathspeaker Selendre"],
			category = "rares",
			description = L["Cult of the Damned"],
			faction = "Neutral",
		},
		[85404540] = {
			name = L["Deathspeaker Selendre"],
			category = "rares",
			description = L["Cult of the Damned"],
			faction = "Neutral",
		},
		[85404600] = {
			name = L["Deathspeaker Selendre"],
			category = "rares",
			description = L["Cult of the Damned"],
			faction = "Neutral",
		},
		[80608540] = {
			name = L["High General Abbendis"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1428] = {
		[84406820] = {
			name = L["Borgus Stoutarm"],
			category = "flightmasters",
			fpName = L["Morgan's Vigil, Burning Steppes"],
			description = L["Gryphon Master"],
			faction = "Alliance",
		},
		[65602420] = {
			name = L["Vahgruk"],
			category = "flightmasters",
			fpName = L["Flame Crest, Burning Steppes"],
			description = L["Wind Rider Master"],
			faction = "Horde",
		},
		[85006840] = {
			name = L["Felder Stover"],
			category = "repair",
			description = L["Weaponsmith"],
			faction = "Alliance",
		},
		[66002200] = {
			name = L["Yuka Screwspigot"],
			category = "repair",
			faction = "Neutral",
		},
		[84206780] = {
			name = L["Gabrielle Chase"],
			category = "vendors",
			description = L["Food & Drink"],
			faction = "Alliance",
		},
		[65602400] = {
			name = L["Gruna"],
			category = "vendors",
			description = L["Food & Drink"],
			faction = "Horde",
		},
		[14605620] = {
			name = L["Hematos"],
			category = "rares",
			faction = "Neutral",
		},
		[55803580] = {
			name = L["Thauris Balgarr"],
			category = "rares",
			faction = "Neutral",
		},
		[56603620] = {
			name = L["Thauris Balgarr"],
			category = "rares",
			faction = "Neutral",
		},
		[61003680] = {
			name = L["Thauris Balgarr"],
			category = "rares",
			faction = "Neutral",
		},
		[71203560] = {
			name = L["Thauris Balgarr"],
			category = "rares",
			faction = "Neutral",
		},
		[40403320] = {
			name = L["Gruklash"],
			category = "rares",
			faction = "Neutral",
		},
		[79402980] = {
			name = L["Malfunctioning Reaver"],
			category = "rares",
			faction = "Neutral",
		},
		[84005480] = {
			name = L["Malfunctioning Reaver"],
			category = "rares",
			faction = "Neutral",
		},
		[85205880] = {
			name = L["Malfunctioning Reaver"],
			category = "rares",
			faction = "Neutral",
		},
		[86205740] = {
			name = L["Malfunctioning Reaver"],
			category = "rares",
			faction = "Neutral",
		},
		[86803040] = {
			name = L["Malfunctioning Reaver"],
			category = "rares",
			faction = "Neutral",
		},
		[80004740] = {
			name = L["Hahk'Zor"],
			category = "rares",
			faction = "Neutral",
		},
		[80604860] = {
			name = L["Hahk'Zor"],
			category = "rares",
			faction = "Neutral",
		},
		[80804500] = {
			name = L["Hahk'Zor"],
			category = "rares",
			faction = "Neutral",
		},
		[81404820] = {
			name = L["Hahk'Zor"],
			category = "rares",
			faction = "Neutral",
		},
		[80404640] = {
			name = L["Gorgon'och"],
			category = "rares",
			faction = "Neutral",
		},
		[75403280] = {
			name = L["Deathmaw"],
			category = "rares",
			faction = "Neutral",
		},
		[41804640] = {
			name = L["Terrorspark"],
			category = "rares",
			faction = "Neutral",
		},
		[47004480] = {
			name = L["Terrorspark"],
			category = "rares",
			faction = "Neutral",
		},
		[47604300] = {
			name = L["Terrorspark"],
			category = "rares",
			faction = "Neutral",
		},
		[76002680] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
		[78806100] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
		[81205960] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
		[82806180] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
		[83403040] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
		[83803040] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
		[84002940] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
		[84403080] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
		[84403200] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
		[85803080] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
		[86602760] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
		[88603420] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
		[89005760] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
		[89403500] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
		[90003140] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
		[90203460] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
		[91804040] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
		[18204500] = {
			name = L["Hematos"],
			category = "rares",
			faction = "Neutral",
		},
		[28605200] = {
			name = L["Hematos"],
			category = "rares",
			faction = "Neutral",
		},
		[30005260] = {
			name = L["Hematos"],
			category = "rares",
			faction = "Neutral",
		},
		[52804040] = {
			name = L["Thauris Balgarr"],
			category = "rares",
			faction = "Neutral",
		},
		[54004320] = {
			name = L["Thauris Balgarr"],
			category = "rares",
			faction = "Neutral",
		},
		[54204480] = {
			name = L["Thauris Balgarr"],
			category = "rares",
			faction = "Neutral",
		},
		[54404100] = {
			name = L["Thauris Balgarr"],
			category = "rares",
			faction = "Neutral",
		},
		[15403040] = {
			name = L["Gruklash"],
			category = "rares",
			faction = "Neutral",
		},
		[15403080] = {
			name = L["Gruklash"],
			category = "rares",
			faction = "Neutral",
		},
		[40003460] = {
			name = L["Gruklash"],
			category = "rares",
			faction = "Neutral",
		},
		[43005320] = {
			name = L["Gruklash"],
			category = "rares",
			faction = "Neutral",
		},
		[80203220] = {
			name = L["Malfunctioning Reaver"],
			category = "rares",
			faction = "Neutral",
		},
		[91404520] = {
			name = L["Malfunctioning Reaver"],
			category = "rares",
			faction = "Neutral",
		},
		[92404600] = {
			name = L["Malfunctioning Reaver"],
			category = "rares",
			faction = "Neutral",
		},
		[81804400] = {
			name = L["Hahk'Zor"],
			category = "rares",
			faction = "Neutral",
		},
		[77004320] = {
			name = L["Gorgon'och"],
			category = "rares",
			faction = "Neutral",
		},
		[51004280] = {
			name = L["Terrorspark"],
			category = "rares",
			faction = "Neutral",
		},
		[69004900] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
		[70204880] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
		[70204980] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
		[70804900] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
		[71604500] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
		[71804580] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
		[72004360] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
		[72804680] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
		[73404480] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
		[79406180] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
		[80006020] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
		[80805820] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
		[81605960] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
		[81606240] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
		[82606340] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
		[89205320] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
		[91204200] = {
			name = L["Volchan"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1412] = {
		[46606100] = {
			name = L["Innkeeper Kauth"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Horde",
		},
		[47006030] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Horde",
		},
		[44007740] = {
			name = L["Marjak Keenblade"],
			category = "repair",
			description = L["Weaponsmith"],
			faction = "Horde",
		},
		[44207720] = {
			name = L["Varia Hardhide"],
			category = "repair",
			description = L["Leather Armor Merchant"],
			faction = "Horde",
		},
		[44207740] = {
			name = L["Bronk Steelrage"],
			category = "repair",
			description = L["Armorer and Shieldcrafter"],
			faction = "Horde",
		},
		[45605860] = {
			name = L["Mahnott Roughwound"],
			category = "repair",
			description = L["Weaponsmith"],
			faction = "Horde",
		},
		[45605840] = {
			name = L["Kennah Hawkseye"],
			category = "repair",
			description = L["Gunsmith"],
			faction = "Horde",
		},
		[45805860] = {
			name = L["Varg Windwhisper"],
			category = "repair",
			description = L["Leather Armor Merchant"],
			faction = "Horde",
		},
		[45805865] = {
			name = L["Harant Ironbrace"],
			category = "vendors",
			description = L["Armorer and Shieldcrafter"],
			faction = "Horde",
		},
		[42607800] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[46405540] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[46806020] = {
			name = L["Seikwa"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Horde",
		},
		[44007600] = {
			name = L["Harutt Thunderhorn"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warrior Trainer"],
			classes = {
				WARRIOR = true,
			},
			faction = "Horde",
		},
		[45007600] = {
			name = L["Gart Mistrunner"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Druid Trainer"],
			classes = {
				DRUID = true,
			},
			faction = "Horde",
		},
		[44207580] = {
			name = L["Lanka Farshot"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Hunter Trainer"],
			classes = {
				HUNTER = true,
			},
			faction = "Horde",
		},
		[45007605] = {
			name = L["Meela Dawnstrider"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Shaman Trainer"],
			classes = {
				SHAMAN = true,
			},
			faction = "Horde",
		},
		[49406040] = {
			name = L["Krang Stonehoof"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warrior Trainer"],
			classes = {
				WARRIOR = true,
			},
			faction = "Horde",
		},
		[48405960] = {
			name = L["Gennia Runetotem"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Druid Trainer"],
			classes = {
				DRUID = true,
			},
			faction = "Horde",
		},
		[47805560] = {
			name = L["Yaw Sharpmane"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Hunter Trainer"],
			classes = {
				HUNTER = true,
			},
			faction = "Horde",
		},
		[48405920] = {
			name = L["Narm Skychaser"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Shaman Trainer"],
			classes = {
				SHAMAN = true,
			},
			faction = "Horde",
		},
		[45405800] = {
			name = L["Pyall Silentstride"],
			category = "secondaryProfession",
			profession = "Cooking",
			description = L["Cook"],
			faction = "Horde",
		},
		[45405780] = {
			name = L["Chaw Stronghide"],
			category = "primaryProfession",
			profession = "Leatherworking",
			description = L["Journeyman Leatherworker"],
			faction = "Horde",
		},
		[47605560] = {
			name = L["Reban Freerunner"],
			category = "trainers",
			description = L["Pet Trainer"],
			faction = "Horde",
		},
		[47605840] = {
			name = L["Kar Stormsinger"],
			category = "trainers",
			description = L["Kodo Riding Instructor"],
			faction = "Horde",
		},
		[44406060] = {
			name = L["Uthan Stillwater"],
			category = "secondaryProfession",
			profession = "Fishing",
			description = L["Fisherman"],
			faction = "Horde",
		},
		[46806080] = {
			name = L["Vira Younghoof"],
			category = "secondaryProfession",
			profession = "First Aid",
			description = L["First Aid Trainer"],
			faction = "Horde",
		},
		[45405785] = {
			name = L["Yonn Deepcut"],
			category = "primaryProfession",
			profession = "Skinning",
			description = L["Skinner"],
			faction = "Horde",
		},
		[61803140] = {
			name = L["Twizwick Sprocketgrind"],
			category = "primaryProfession",
			profession = "Engineering",
			description = L["Journeyman Engineer"],
			faction = "Neutral",
		},
		[45207640] = {
			name = L["Kawnie Softbreeze"],
			category = "vendors",
			description = L["General Goods"],
			faction = "Horde",
		},
		[45805760] = {
			name = L["Moorat Longstride"],
			category = "vendors",
			description = L["General Goods"],
			faction = "Horde",
		},
		[46205820] = {
			name = L["Wunna Darkmane"],
			category = "vendors",
			description = L["Trade Goods"],
			faction = "Horde",
		},
		[47405840] = {
			name = L["Harb Clawhoof"],
			category = "vendors",
			description = L["Kodo Mounts"],
			faction = "Horde",
		},
		[44607780] = {
			name = L["Moodan Sungrain"],
			category = "vendors",
			description = L["Baker"],
			faction = "Horde",
		},
		[47606140] = {
			name = L["Jhawna Oatwind"],
			category = "vendors",
			description = L["Baker"],
			faction = "Horde",
		},
		[47405500] = {
			name = L["Harn Longcast"],
			category = "vendors",
			description = L["Fishing Supplies"],
			faction = "Horde",
		},
		[30202660] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[30402460] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[30402640] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[30602700] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[30802640] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[31001980] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[31002280] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[31602040] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[31802160] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[31802600] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[32202800] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[32401940] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[32402860] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[32802800] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[33001900] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[33002580] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[33402860] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[33602720] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[33602840] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[34202600] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[34602720] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[36004120] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[36204200] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[37201720] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[37204160] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[38401420] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[38404180] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[38601340] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[39001240] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[39204140] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[39401100] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[39601380] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[39604100] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[39604200] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[40204260] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[41404160] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[41804080] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[42404240] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[43404060] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[44404160] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[44604140] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[48801420] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[48801540] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[49401560] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[49401700] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[49401800] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[50001620] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[50001720] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[50201760] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[50401280] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[50401360] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[50401860] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[50601800] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[51001380] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[51201320] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[51801420] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[51801620] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[52001340] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[52201460] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[52601620] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[53201460] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[53601380] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[33004200] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[33604100] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[33604160] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[34003980] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[34204380] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[34403920] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[34604200] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[35404120] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[35604180] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[35604460] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[36204100] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[36604140] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[36804180] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[36804300] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[37604280] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[38204380] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[38204460] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[39204280] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[39404420] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[39804320] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[40004400] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[40804340] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[40804380] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[41004220] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[42004340] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[43204300] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[43204380] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[43804280] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[44404220] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[44604240] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[45004320] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[46004220] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[46404300] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[46604220] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[47004280] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[47804460] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[48404340] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[48404400] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[49404320] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[50604220] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[51204280] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[51604260] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[51804200] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[52204500] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[54004360] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[54804100] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[55604100] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[56004260] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[56404180] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[56604300] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[29602280] = {
			name = L["Sister Hatelash"],
			category = "rares",
			faction = "Neutral",
		},
		[30402060] = {
			name = L["Sister Hatelash"],
			category = "rares",
			faction = "Neutral",
		},
		[30402180] = {
			name = L["Sister Hatelash"],
			category = "rares",
			faction = "Neutral",
		},
		[30602160] = {
			name = L["Sister Hatelash"],
			category = "rares",
			faction = "Neutral",
		},
		[31001985] = {
			name = L["Sister Hatelash"],
			category = "rares",
			faction = "Neutral",
		},
		[31002060] = {
			name = L["Sister Hatelash"],
			category = "rares",
			faction = "Neutral",
		},
		[36001000] = {
			name = L["Sister Hatelash"],
			category = "rares",
			faction = "Neutral",
		},
		[36201140] = {
			name = L["Sister Hatelash"],
			category = "rares",
			faction = "Neutral",
		},
		[36601140] = {
			name = L["Sister Hatelash"],
			category = "rares",
			faction = "Neutral",
		},
		[36601200] = {
			name = L["Sister Hatelash"],
			category = "rares",
			faction = "Neutral",
		},
		[54401180] = {
			name = L["Sister Hatelash"],
			category = "rares",
			faction = "Neutral",
		},
		[55001040] = {
			name = L["Sister Hatelash"],
			category = "rares",
			faction = "Neutral",
		},
		[55001140] = {
			name = L["Sister Hatelash"],
			category = "rares",
			faction = "Neutral",
		},
		[55001180] = {
			name = L["Sister Hatelash"],
			category = "rares",
			faction = "Neutral",
		},
		[55601160] = {
			name = L["Sister Hatelash"],
			category = "rares",
			faction = "Neutral",
		},
		[47007000] = {
			name = L["Snagglespear"],
			category = "rares",
			faction = "Neutral",
		},
		[47407120] = {
			name = L["Snagglespear"],
			category = "rares",
			faction = "Neutral",
		},
		[47407180] = {
			name = L["Snagglespear"],
			category = "rares",
			faction = "Neutral",
		},
		[47806860] = {
			name = L["Snagglespear"],
			category = "rares",
			faction = "Neutral",
		},
		[47807340] = {
			name = L["Snagglespear"],
			category = "rares",
			faction = "Neutral",
		},
		[48007040] = {
			name = L["Snagglespear"],
			category = "rares",
			faction = "Neutral",
		},
		[48007140] = {
			name = L["Snagglespear"],
			category = "rares",
			faction = "Neutral",
		},
		[48207160] = {
			name = L["Snagglespear"],
			category = "rares",
			faction = "Neutral",
		},
		[48607000] = {
			name = L["Snagglespear"],
			category = "rares",
			faction = "Neutral",
		},
		[48607260] = {
			name = L["Snagglespear"],
			category = "rares",
			faction = "Neutral",
		},
		[48807140] = {
			name = L["Snagglespear"],
			category = "rares",
			faction = "Neutral",
		},
		[48807240] = {
			name = L["Snagglespear"],
			category = "rares",
			faction = "Neutral",
		},
		[49607040] = {
			name = L["Snagglespear"],
			category = "rares",
			faction = "Neutral",
		},
		[52207040] = {
			name = L["Snagglespear"],
			category = "rares",
			faction = "Neutral",
		},
		[52207080] = {
			name = L["Snagglespear"],
			category = "rares",
			faction = "Neutral",
		},
		[52407200] = {
			name = L["Snagglespear"],
			category = "rares",
			faction = "Neutral",
		},
		[52407320] = {
			name = L["Snagglespear"],
			category = "rares",
			faction = "Neutral",
		},
		[53007400] = {
			name = L["Snagglespear"],
			category = "rares",
			faction = "Neutral",
		},
		[53207140] = {
			name = L["Snagglespear"],
			category = "rares",
			faction = "Neutral",
		},
		[53207220] = {
			name = L["Snagglespear"],
			category = "rares",
			faction = "Neutral",
		},
		[53207260] = {
			name = L["Snagglespear"],
			category = "rares",
			faction = "Neutral",
		},
		[53607140] = {
			name = L["Snagglespear"],
			category = "rares",
			faction = "Neutral",
		},
		[53607300] = {
			name = L["Snagglespear"],
			category = "rares",
			faction = "Neutral",
		},
		[53607400] = {
			name = L["Snagglespear"],
			category = "rares",
			faction = "Neutral",
		},
		[53806980] = {
			name = L["Snagglespear"],
			category = "rares",
			faction = "Neutral",
		},
		[53807220] = {
			name = L["Snagglespear"],
			category = "rares",
			faction = "Neutral",
		},
		[54607100] = {
			name = L["Snagglespear"],
			category = "rares",
			faction = "Neutral",
		},
		[54607360] = {
			name = L["Snagglespear"],
			category = "rares",
			faction = "Neutral",
		},
		[55207220] = {
			name = L["Snagglespear"],
			category = "rares",
			faction = "Neutral",
		},
		[39201600] = {
			name = L["Enforcer Emilgund"],
			category = "rares",
			faction = "Neutral",
		},
		[39601680] = {
			name = L["Enforcer Emilgund"],
			category = "rares",
			faction = "Neutral",
		},
		[40201480] = {
			name = L["Enforcer Emilgund"],
			category = "rares",
			faction = "Neutral",
		},
		[40401560] = {
			name = L["Enforcer Emilgund"],
			category = "rares",
			faction = "Neutral",
		},
		[40601540] = {
			name = L["Enforcer Emilgund"],
			category = "rares",
			faction = "Neutral",
		},
		[40601560] = {
			name = L["Enforcer Emilgund"],
			category = "rares",
			faction = "Neutral",
		},
		[40801700] = {
			name = L["Enforcer Emilgund"],
			category = "rares",
			faction = "Neutral",
		},
		[41001760] = {
			name = L["Enforcer Emilgund"],
			category = "rares",
			faction = "Neutral",
		},
		[48201680] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[48201900] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[48401560] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[48401800] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[48801820] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[49001980] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[49401500] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[49401640] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[49401920] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[49601900] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[49602020] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[49801540] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[49802160] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[50202120] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[50402260] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[50801440] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[50801480] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[50802280] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[51401640] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[51401740] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[51401760] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[51601600] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[51601840] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[51801700] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[52002080] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[52201380] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[52201900] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[52201980] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[52202160] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[52401300] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[52601520] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[52602140] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[52801340] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[52801380] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[52802160] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[53002000] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[53201600] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[53201700] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[54201720] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[54201900] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[54201980] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[54202100] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[54401800] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[54601960] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[54602060] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[54801860] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[31002480] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[31602740] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[32201920] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[34002920] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[37604080] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[38204240] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[38401260] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[41004280] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[46204180] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[46804100] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[48601440] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[49401780] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[50401880] = {
			name = L["Ghost Howl"],
			category = "rares",
			faction = "Neutral",
		},
		[35204300] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[38804460] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[43204460] = {
			name = L["Mazzranache"],
			category = "rares",
			faction = "Neutral",
		},
		[55201060] = {
			name = L["Sister Hatelash"],
			category = "rares",
			faction = "Neutral",
		},
		[48606920] = {
			name = L["Snagglespear"],
			category = "rares",
			faction = "Neutral",
		},
		[48607140] = {
			name = L["Snagglespear"],
			category = "rares",
			faction = "Neutral",
		},
		[39401540] = {
			name = L["Enforcer Emilgund"],
			category = "rares",
			faction = "Neutral",
		},
		[41001680] = {
			name = L["Enforcer Emilgund"],
			category = "rares",
			faction = "Neutral",
		},
		[49602120] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[50402280] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[50601420] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[51201680] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
		[51402360] = {
			name = L["The Rake"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1411] = {
		[51604160] = {
			name = L["Innkeeper Grosk"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Horde",
		},
		[51904210] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Horde",
		},
		[40406800] = {
			name = L["Kzan Thornslash"],
			category = "repair",
			description = L["Weaponsmith"],
			faction = "Horde",
		},
		[40606780] = {
			name = L["Huklah"],
			category = "repair",
			description = L["Cloth & Leather Armor Merchant"],
			faction = "Horde",
		},
		[40406780] = {
			name = L["Rarc"],
			category = "repair",
			description = L["Armorer & Shieldcrafter"],
			faction = "Horde",
		},
		[52004040] = {
			name = L["Uhgar"],
			category = "repair",
			description = L["Weaponsmith"],
			faction = "Horde",
		},
		[53004100] = {
			name = L["Ghrawt"],
			category = "repair",
			description = L["Bowyer"],
			faction = "Horde",
		},
		[53004080] = {
			name = L["Cutac"],
			category = "repair",
			description = L["Cloth & Leather Armor Merchant"],
			faction = "Horde",
		},
		[52004120] = {
			name = L["Wuark"],
			category = "repair",
			description = L["Armorer & Shieldcrafter"],
			faction = "Horde",
		},
		[56407320] = {
			name = L["Trayexir"],
			category = "repair",
			description = L["Weapon Merchant"],
			faction = "Horde",
		},
		[44006920] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[47001740] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[53404440] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[57407320] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[52004180] = {
			name = L["Shoja'my"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Horde",
		},
		[42806940] = {
			name = L["Frang"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warrior Trainer"],
			classes = {
				WARRIOR = true,
			},
			faction = "Horde",
		},
		[42806920] = {
			name = L["Jen'shan"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Hunter Trainer"],
			classes = {
				HUNTER = true,
			},
			faction = "Horde",
		},
		[41206800] = {
			name = L["Rwag"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Rogue Trainer"],
			classes = {
				ROGUE = true,
			},
			faction = "Horde",
		},
		[40606840] = {
			name = L["Nartok"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warlock Trainer"],
			classes = {
				WARLOCK = true,
			},
			faction = "Horde",
		},
		[42406900] = {
			name = L["Shikrik"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Shaman Trainer"],
			classes = {
				SHAMAN = true,
			},
			faction = "Horde",
		},
		[54204240] = {
			name = L["Tarshaw Jaggedscar"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warrior Trainer"],
			classes = {
				WARRIOR = true,
			},
			faction = "Horde",
		},
		[52004360] = {
			name = L["Kaplak"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Rogue Trainer"],
			classes = {
				ROGUE = true,
			},
			faction = "Horde",
		},
		[51804340] = {
			name = L["Thotar"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Hunter Trainer"],
			classes = {
				HUNTER = true,
			},
			faction = "Horde",
		},
		[54204120] = {
			name = L["Dhugru Gorelust"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warlock Trainer"],
			classes = {
				WARLOCK = true,
			},
			faction = "Horde",
		},
		[54404260] = {
			name = L["Swart"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Shaman Trainer"],
			classes = {
				SHAMAN = true,
			},
			faction = "Horde",
		},
		[52004060] = {
			name = L["Dwukk"],
			category = "primaryProfession",
			profession = "Blacksmith",
			description = L["Journeyman Blacksmith"],
			faction = "Horde",
		},
		[51804080] = {
			name = L["Krunn"],
			category = "primaryProfession",
			profession = "Mining",
			description = L["Miner"],
			faction = "Horde",
		},
		[55407400] = {
			name = L["Miao'zan"],
			category = "primaryProfession",
			profession = "Alchemy",
			description = L["Journeyman Alchemist"],
			faction = "Horde",
		},
		[55407500] = {
			name = L["Mishiki"],
			category = "primaryProfession",
			profession = "Herbalism",
			description = L["Herbalist"],
			faction = "Horde",
		},
		[52004340] = {
			name = L["Harruk"],
			category = "trainers",
			description = L["Pet Trainer"],
			faction = "Horde",
		},
		[54204280] = {
			name = L["Tai'jin"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Priest Trainer"],
			classes = {
				PRIEST = true,
			},
			faction = "Horde",
		},
		[42406880] = {
			name = L["Ken'jai"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Priest Trainer"],
			classes = {
				PRIEST = true,
			},
			faction = "Horde",
		},
		[56207500] = {
			name = L["Un'Thuwa"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Mage Trainer"],
			classes = {
				MAGE = true,
			},
			faction = "Horde",
		},
		[42406905] = {
			name = L["Mai'ah"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Mage Trainer"],
			classes = {
				MAGE = true,
			},
			faction = "Horde",
		},
		[53208140] = {
			name = L["Lau'Tiki"],
			category = "secondaryProfession",
			profession = "Fishing",
			description = L["Fisherman"],
			faction = "Horde",
		},
		[54004200] = {
			name = L["Rawrk"],
			category = "secondaryProfession",
			profession = "First Aid",
			description = L["First Aid Trainer"],
			faction = "Horde",
		},
		[55207540] = {
			name = L["Xar'Ti"],
			category = "trainers",
			description = L["Raptor Riding Trainer"],
			faction = "Horde",
		},
		[52204080] = {
			name = L["Mukdrak"],
			category = "primaryProfession",
			profession = "Engineering",
			description = L["Journeyman Engineer"],
			faction = "Horde",
		},
		[42606740] = {
			name = L["Duokna"],
			category = "vendors",
			description = L["General Goods"],
			faction = "Horde",
		},
		[54204220] = {
			name = L["Jark"],
			category = "vendors",
			description = L["General Goods"],
			faction = "Horde",
		},
		[52804200] = {
			name = L["Flakk"],
			category = "vendors",
			description = L["Trade Supplies"],
			faction = "Horde",
		},
		[56207340] = {
			name = L["K'waii"],
			category = "vendors",
			description = L["General Goods"],
			faction = "Horde",
		},
		[56407380] = {
			name = L["Tai'tasi"],
			category = "vendors",
			description = L["Trade Supplies"],
			faction = "Horde",
		},
		[51204260] = {
			name = L["Grimtak"],
			category = "vendors",
			description = L["Butcher"],
			faction = "Horde",
		},
		[42606720] = {
			name = L["Zlagk"],
			category = "vendors",
			description = L["Butcher"],
			faction = "Horde",
		},
		[55607360] = {
			name = L["Hai'zan"],
			category = "vendors",
			description = L["Butcher"],
			faction = "Horde",
		},
		[56007340] = {
			name = L["Zansoa"],
			category = "vendors",
			description = L["Fishing Supplies"],
			faction = "Horde",
		},
		[54604140] = {
			name = L["Kitha"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Demon Trainer"],
			classes = {
				WARLOCK = true,
			},
			faction = "Horde",
		},
		[55207560] = {
			name = L["Zjolnir"],
			category = "vendors",
			description = L["Raptor Handler"],
			faction = "Horde",
		},
		[40606845] = {
			name = L["Hraug"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Demon Trainer"],
			classes = {
				WARLOCK = true,
			},
			faction = "Horde",
		},
		[46001360] = {
			name = L["Javnir Nashak"],
			category = "vendors",
			faction = "Horde",
		},
		[46207940] = {
			name = L["Warlord Kolkanis"],
			category = "rares",
			faction = "Neutral",
		},
		[46407960] = {
			name = L["Warlord Kolkanis"],
			category = "rares",
			faction = "Neutral",
		},
		[46408060] = {
			name = L["Warlord Kolkanis"],
			category = "rares",
			faction = "Neutral",
		},
		[46607940] = {
			name = L["Warlord Kolkanis"],
			category = "rares",
			faction = "Neutral",
		},
		[46607980] = {
			name = L["Warlord Kolkanis"],
			category = "rares",
			faction = "Neutral",
		},
		[47008060] = {
			name = L["Warlord Kolkanis"],
			category = "rares",
			faction = "Neutral",
		},
		[47607740] = {
			name = L["Warlord Kolkanis"],
			category = "rares",
			faction = "Neutral",
		},
		[47607780] = {
			name = L["Warlord Kolkanis"],
			category = "rares",
			faction = "Neutral",
		},
		[48208040] = {
			name = L["Warlord Kolkanis"],
			category = "rares",
			faction = "Neutral",
		},
		[48807900] = {
			name = L["Warlord Kolkanis"],
			category = "rares",
			faction = "Neutral",
		},
		[49407980] = {
			name = L["Warlord Kolkanis"],
			category = "rares",
			faction = "Neutral",
		},
		[49608060] = {
			name = L["Warlord Kolkanis"],
			category = "rares",
			faction = "Neutral",
		},
		[50207980] = {
			name = L["Warlord Kolkanis"],
			category = "rares",
			faction = "Neutral",
		},
		[50407920] = {
			name = L["Warlord Kolkanis"],
			category = "rares",
			faction = "Neutral",
		},
		[50607940] = {
			name = L["Warlord Kolkanis"],
			category = "rares",
			faction = "Neutral",
		},
		[51807980] = {
			name = L["Warlord Kolkanis"],
			category = "rares",
			faction = "Neutral",
		},
		[59405780] = {
			name = L["Watch Commander Zalaphil"],
			category = "rares",
			faction = "Neutral",
		},
		[59405880] = {
			name = L["Watch Commander Zalaphil"],
			category = "rares",
			faction = "Neutral",
		},
		[51400900] = {
			name = L["Felweaver Scornn"],
			category = "rares",
			faction = "Neutral",
		},
		[51401000] = {
			name = L["Felweaver Scornn"],
			category = "rares",
			faction = "Neutral",
		},
		[51600940] = {
			name = L["Felweaver Scornn"],
			category = "rares",
			faction = "Neutral",
		},
		[51600960] = {
			name = L["Felweaver Scornn"],
			category = "rares",
			faction = "Neutral",
		},
		[51800800] = {
			name = L["Felweaver Scornn"],
			category = "rares",
			faction = "Neutral",
		},
		[52600880] = {
			name = L["Felweaver Scornn"],
			category = "rares",
			faction = "Neutral",
		},
		[53000740] = {
			name = L["Felweaver Scornn"],
			category = "rares",
			faction = "Neutral",
		},
		[53400780] = {
			name = L["Felweaver Scornn"],
			category = "rares",
			faction = "Neutral",
		},
		[53800880] = {
			name = L["Felweaver Scornn"],
			category = "rares",
			faction = "Neutral",
		},
		[35004920] = {
			name = L["Death Flayer"],
			category = "rares",
			faction = "Neutral",
		},
		[35205220] = {
			name = L["Death Flayer"],
			category = "rares",
			faction = "Neutral",
		},
		[36204920] = {
			name = L["Death Flayer"],
			category = "rares",
			faction = "Neutral",
		},
		[36204960] = {
			name = L["Death Flayer"],
			category = "rares",
			faction = "Neutral",
		},
		[36205440] = {
			name = L["Death Flayer"],
			category = "rares",
			faction = "Neutral",
		},
		[36205600] = {
			name = L["Death Flayer"],
			category = "rares",
			faction = "Neutral",
		},
		[36405340] = {
			name = L["Death Flayer"],
			category = "rares",
			faction = "Neutral",
		},
		[36405540] = {
			name = L["Death Flayer"],
			category = "rares",
			faction = "Neutral",
		},
		[37004980] = {
			name = L["Death Flayer"],
			category = "rares",
			faction = "Neutral",
		},
		[37005440] = {
			name = L["Death Flayer"],
			category = "rares",
			faction = "Neutral",
		},
		[37205060] = {
			name = L["Death Flayer"],
			category = "rares",
			faction = "Neutral",
		},
		[37205320] = {
			name = L["Death Flayer"],
			category = "rares",
			faction = "Neutral",
		},
		[37605020] = {
			name = L["Death Flayer"],
			category = "rares",
			faction = "Neutral",
		},
		[38204680] = {
			name = L["Death Flayer"],
			category = "rares",
			faction = "Neutral",
		},
		[38804900] = {
			name = L["Death Flayer"],
			category = "rares",
			faction = "Neutral",
		},
		[39205100] = {
			name = L["Death Flayer"],
			category = "rares",
			faction = "Neutral",
		},
		[38205460] = {
			name = L["Captain Flat Tusk"],
			category = "rares",
			description = L["Captain of the Battleguard"],
			faction = "Neutral",
		},
		[38405240] = {
			name = L["Captain Flat Tusk"],
			category = "rares",
			description = L["Captain of the Battleguard"],
			faction = "Neutral",
		},
		[38405320] = {
			name = L["Captain Flat Tusk"],
			category = "rares",
			description = L["Captain of the Battleguard"],
			faction = "Neutral",
		},
		[38405360] = {
			name = L["Captain Flat Tusk"],
			category = "rares",
			description = L["Captain of the Battleguard"],
			faction = "Neutral",
		},
		[38605320] = {
			name = L["Captain Flat Tusk"],
			category = "rares",
			description = L["Captain of the Battleguard"],
			faction = "Neutral",
		},
		[38605480] = {
			name = L["Captain Flat Tusk"],
			category = "rares",
			description = L["Captain of the Battleguard"],
			faction = "Neutral",
		},
		[38805360] = {
			name = L["Captain Flat Tusk"],
			category = "rares",
			description = L["Captain of the Battleguard"],
			faction = "Neutral",
		},
		[38805580] = {
			name = L["Captain Flat Tusk"],
			category = "rares",
			description = L["Captain of the Battleguard"],
			faction = "Neutral",
		},
		[39005240] = {
			name = L["Captain Flat Tusk"],
			category = "rares",
			description = L["Captain of the Battleguard"],
			faction = "Neutral",
		},
		[42004140] = {
			name = L["Captain Flat Tusk"],
			category = "rares",
			description = L["Captain of the Battleguard"],
			faction = "Neutral",
		},
		[42403940] = {
			name = L["Captain Flat Tusk"],
			category = "rares",
			description = L["Captain of the Battleguard"],
			faction = "Neutral",
		},
		[42403960] = {
			name = L["Captain Flat Tusk"],
			category = "rares",
			description = L["Captain of the Battleguard"],
			faction = "Neutral",
		},
		[42603620] = {
			name = L["Captain Flat Tusk"],
			category = "rares",
			description = L["Captain of the Battleguard"],
			faction = "Neutral",
		},
		[42803700] = {
			name = L["Captain Flat Tusk"],
			category = "rares",
			description = L["Captain of the Battleguard"],
			faction = "Neutral",
		},
		[42803900] = {
			name = L["Captain Flat Tusk"],
			category = "rares",
			description = L["Captain of the Battleguard"],
			faction = "Neutral",
		},
		[42804060] = {
			name = L["Captain Flat Tusk"],
			category = "rares",
			description = L["Captain of the Battleguard"],
			faction = "Neutral",
		},
		[43003840] = {
			name = L["Captain Flat Tusk"],
			category = "rares",
			description = L["Captain of the Battleguard"],
			faction = "Neutral",
		},
		[43003960] = {
			name = L["Captain Flat Tusk"],
			category = "rares",
			description = L["Captain of the Battleguard"],
			faction = "Neutral",
		},
		[43604000] = {
			name = L["Captain Flat Tusk"],
			category = "rares",
			description = L["Captain of the Battleguard"],
			faction = "Neutral",
		},
		[43804120] = {
			name = L["Captain Flat Tusk"],
			category = "rares",
			description = L["Captain of the Battleguard"],
			faction = "Neutral",
		},
		[44004920] = {
			name = L["Captain Flat Tusk"],
			category = "rares",
			description = L["Captain of the Battleguard"],
			faction = "Neutral",
		},
		[44404180] = {
			name = L["Captain Flat Tusk"],
			category = "rares",
			description = L["Captain of the Battleguard"],
			faction = "Neutral",
		},
		[44404980] = {
			name = L["Captain Flat Tusk"],
			category = "rares",
			description = L["Captain of the Battleguard"],
			faction = "Neutral",
		},
		[44604920] = {
			name = L["Captain Flat Tusk"],
			category = "rares",
			description = L["Captain of the Battleguard"],
			faction = "Neutral",
		},
		[44604980] = {
			name = L["Captain Flat Tusk"],
			category = "rares",
			description = L["Captain of the Battleguard"],
			faction = "Neutral",
		},
		[44804840] = {
			name = L["Captain Flat Tusk"],
			category = "rares",
			description = L["Captain of the Battleguard"],
			faction = "Neutral",
		},
		[45604920] = {
			name = L["Captain Flat Tusk"],
			category = "rares",
			description = L["Captain of the Battleguard"],
			faction = "Neutral",
		},
		[42004060] = {
			name = L["Geolord Mottle"],
			category = "rares",
			faction = "Neutral",
		},
		[42803760] = {
			name = L["Geolord Mottle"],
			category = "rares",
			faction = "Neutral",
		},
		[43004900] = {
			name = L["Geolord Mottle"],
			category = "rares",
			faction = "Neutral",
		},
		[43204020] = {
			name = L["Geolord Mottle"],
			category = "rares",
			faction = "Neutral",
		},
		[43403920] = {
			name = L["Geolord Mottle"],
			category = "rares",
			faction = "Neutral",
		},
		[43404140] = {
			name = L["Geolord Mottle"],
			category = "rares",
			faction = "Neutral",
		},
		[43404980] = {
			name = L["Geolord Mottle"],
			category = "rares",
			faction = "Neutral",
		},
		[43605080] = {
			name = L["Geolord Mottle"],
			category = "rares",
			faction = "Neutral",
		},
		[43803920] = {
			name = L["Geolord Mottle"],
			category = "rares",
			faction = "Neutral",
		},
		[43804020] = {
			name = L["Geolord Mottle"],
			category = "rares",
			faction = "Neutral",
		},
		[43804080] = {
			name = L["Geolord Mottle"],
			category = "rares",
			faction = "Neutral",
		},
		[43805000] = {
			name = L["Geolord Mottle"],
			category = "rares",
			faction = "Neutral",
		},
		[44004200] = {
			name = L["Geolord Mottle"],
			category = "rares",
			faction = "Neutral",
		},
		[44004740] = {
			name = L["Geolord Mottle"],
			category = "rares",
			faction = "Neutral",
		},
		[44404920] = {
			name = L["Geolord Mottle"],
			category = "rares",
			faction = "Neutral",
		},
		[44604740] = {
			name = L["Geolord Mottle"],
			category = "rares",
			faction = "Neutral",
		},
		[45604720] = {
			name = L["Geolord Mottle"],
			category = "rares",
			faction = "Neutral",
		},
		[45804640] = {
			name = L["Geolord Mottle"],
			category = "rares",
			faction = "Neutral",
		},
		[46204820] = {
			name = L["Geolord Mottle"],
			category = "rares",
			faction = "Neutral",
		},
		[46404920] = {
			name = L["Geolord Mottle"],
			category = "rares",
			faction = "Neutral",
		},
		[46804780] = {
			name = L["Geolord Mottle"],
			category = "rares",
			faction = "Neutral",
		},
		[47204660] = {
			name = L["Geolord Mottle"],
			category = "rares",
			faction = "Neutral",
		},
		[47204960] = {
			name = L["Geolord Mottle"],
			category = "rares",
			faction = "Neutral",
		},
		[47404900] = {
			name = L["Geolord Mottle"],
			category = "rares",
			faction = "Neutral",
		},
		[47604800] = {
			name = L["Geolord Mottle"],
			category = "rares",
			faction = "Neutral",
		},
		[47804920] = {
			name = L["Geolord Mottle"],
			category = "rares",
			faction = "Neutral",
		},
		[48404480] = {
			name = L["Geolord Mottle"],
			category = "rares",
			faction = "Neutral",
		},
		[49004520] = {
			name = L["Geolord Mottle"],
			category = "rares",
			faction = "Neutral",
		},
		[56805820] = {
			name = L["Watch Commander Zalaphil"],
			category = "rares",
			faction = "Neutral",
		},
		[57805800] = {
			name = L["Watch Commander Zalaphil"],
			category = "rares",
			faction = "Neutral",
		},
		[59605820] = {
			name = L["Watch Commander Zalaphil"],
			category = "rares",
			faction = "Neutral",
		},
		[59805880] = {
			name = L["Watch Commander Zalaphil"],
			category = "rares",
			faction = "Neutral",
		},
		[35204820] = {
			name = L["Death Flayer"],
			category = "rares",
			faction = "Neutral",
		},
		[39205020] = {
			name = L["Death Flayer"],
			category = "rares",
			faction = "Neutral",
		},
		[42804200] = {
			name = L["Captain Flat Tusk"],
			category = "rares",
			description = L["Captain of the Battleguard"],
			faction = "Neutral",
		},
		[44004880] = {
			name = L["Captain Flat Tusk"],
			category = "rares",
			description = L["Captain of the Battleguard"],
			faction = "Neutral",
		},
		[42204980] = {
			name = L["Geolord Mottle"],
			category = "rares",
			faction = "Neutral",
		},
		[42405060] = {
			name = L["Geolord Mottle"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1426] = {
		[47405240] = {
			name = L["Innkeeper Belm"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Alliance",
		},
		[47005260] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Alliance",
		},
		[28806640] = {
			name = L["Durnan Furcutter"],
			category = "repair",
			description = L["Cloth & Leather Armor Merchant"],
			faction = "Alliance",
		},
		[28606780] = {
			name = L["Rybrad Coldbank"],
			category = "repair",
			description = L["Weaponsmith"],
			faction = "Alliance",
		},
		[28806780] = {
			name = L["Grundel Harkin"],
			category = "repair",
			description = L["Armorer"],
			faction = "Alliance",
		},
		[45205180] = {
			name = L["Gamili Frosthide"],
			category = "repair",
			description = L["Cloth & Leather Armor Merchant"],
			faction = "Alliance",
		},
		[45205185] = {
			name = L["Boran Ironclink"],
			category = "vendors",
			description = L["Armorer"],
			faction = "Alliance",
		},
		[40606500] = {
			name = L["Hegnar Rumbleshot"],
			category = "repair",
			description = L["Gunsmith"],
			faction = "Alliance",
		},
		[45205200] = {
			name = L["Grawn Thromwyn"],
			category = "repair",
			description = L["Weaponsmith"],
			faction = "Alliance",
		},
		[45205160] = {
			name = L["Thrawn Boltar"],
			category = "repair",
			description = L["Blacksmithing Supplies"],
			faction = "Alliance",
		},
		[68805580] = {
			name = L["Frast Dokner"],
			category = "repair",
			description = L["Apprentice Weaponsmith"],
			faction = "Alliance",
		},
		[30204520] = {
			name = L["Burdrak Harglhelm"],
			category = "repair",
			description = L["Leather Armor Merchant"],
			faction = "Alliance",
		},
		[63004980] = {
			name = L["Turuk Amberstill"],
			category = "repair",
			description = L["Dwarven Weaponsmith"],
			faction = "Alliance",
		},
		[29406980] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[47005500] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[54203900] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[47005265] = {
			name = L["Shelby Stoneflint"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Alliance",
		},
		[28606620] = {
			name = L["Alamar Grimm"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warlock Trainer"],
			classes = {
				WARLOCK = true,
			},
			faction = "Alliance",
		},
		[28606640] = {
			name = L["Branstock Khalder"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Priest Trainer"],
			classes = {
				PRIEST = true,
			},
			faction = "Alliance",
		},
		[29006740] = {
			name = L["Thorgas Grimson"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Hunter Trainer"],
			classes = {
				HUNTER = true,
			},
			faction = "Alliance",
		},
		[28806720] = {
			name = L["Thran Khorman"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warrior Trainer"],
			classes = {
				WARRIOR = true,
			},
			faction = "Alliance",
		},
		[28406740] = {
			name = L["Solm Hargrin"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Rogue Trainer"],
			classes = {
				ROGUE = true,
			},
			faction = "Alliance",
		},
		[28806820] = {
			name = L["Bromos Grummner"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Paladin Trainer"],
			classes = {
				PALADIN = true,
			},
			faction = "Alliance",
		},
		[28606645] = {
			name = L["Marryk Nurribit"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Mage Trainer"],
			classes = {
				MAGE = true,
			},
			faction = "Alliance",
		},
		[47205220] = {
			name = L["Maxan Anvol"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Priest Trainer"],
			classes = {
				PRIEST = true,
			},
			faction = "Alliance",
		},
		[47405200] = {
			name = L["Magis Sparkmantle"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Mage Trainer"],
			classes = {
				MAGE = true,
			},
			faction = "Alliance",
		},
		[47205260] = {
			name = L["Granis Swiftaxe"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warrior Trainer"],
			classes = {
				WARRIOR = true,
			},
			faction = "Alliance",
		},
		[45805300] = {
			name = L["Grif Wildheart"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Hunter Trainer"],
			classes = {
				HUNTER = true,
			},
			faction = "Alliance",
		},
		[47605200] = {
			name = L["Azar Stronghammer"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Paladin Trainer"],
			classes = {
				PALADIN = true,
			},
			faction = "Alliance",
		},
		[47605260] = {
			name = L["Hogral Bakkan"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Rogue Trainer"],
			classes = {
				ROGUE = true,
			},
			faction = "Alliance",
		},
		[45205205] = {
			name = L["Tognus Flintfire"],
			category = "primaryProfession",
			profession = "Blacksmith",
			description = L["Journeyman Blacksmith"],
			faction = "Alliance",
		},
		[68405440] = {
			name = L["Cook Ghilm"],
			category = "secondaryProfession",
			profession = "Cooking",
			description = L["Cooking Trainer"],
			faction = "Alliance",
		},
		[47605240] = {
			name = L["Gremlock Pilsnor"],
			category = "secondaryProfession",
			profession = "Cooking",
			description = L["Cooking Trainer"],
			faction = "Alliance",
		},
		[35404020] = {
			name = L["Paxton Ganter"],
			category = "secondaryProfession",
			profession = "Fishing",
			description = L["Fisherman"],
			faction = "Alliance",
		},
		[69205540] = {
			name = L["Dank Drizzlecut"],
			category = "primaryProfession",
			profession = "Mining",
			description = L["Mining Trainer"],
			faction = "Alliance",
		},
		[50205040] = {
			name = L["Bronk Guzzlegear"],
			category = "primaryProfession",
			profession = "Engineering",
			description = L["Journeyman Engineer"],
			faction = "Alliance",
		},
		[47205265] = {
			name = L["Thamner Pol"],
			category = "secondaryProfession",
			profession = "First Aid",
			description = L["Physician"],
			faction = "Alliance",
		},
		[46605380] = {
			name = L["Peria Lamenur"],
			category = "trainers",
			description = L["Pet Trainer"],
			faction = "Alliance",
		},
		[63805020] = {
			name = L["Ultham Ironhorn"],
			category = "trainers",
			description = L["Ram Riding Instructor"],
			faction = "Alliance",
		},
		[50005020] = {
			name = L["Yarr Hammerstone"],
			category = "primaryProfession",
			profession = "Mining",
			description = L["Mining Trainer"],
			faction = "Alliance",
		},
		[47205360] = {
			name = L["Gimrizz Shadowcog"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warlock Trainer"],
			classes = {
				WARLOCK = true,
			},
			faction = "Alliance",
		},
		[49204800] = {
			name = L["Binjy Featherwhistle"],
			category = "trainers",
			description = L["Mechanostrider Pilot"],
			faction = "Alliance",
		},
		[30007140] = {
			name = L["Adlin Pridedrift"],
			category = "vendors",
			description = L["General Supplies"],
			faction = "Alliance",
		},
		[68605460] = {
			name = L["Kazan Mogosh"],
			category = "vendors",
			description = L["Food & Drink Merchant"],
			faction = "Alliance",
		},
		[63405060] = {
			name = L["Veron Amberstill"],
			category = "vendors",
			description = L["Ram Breeder"],
			faction = "Alliance",
		},
		[63205080] = {
			name = L["Yarlyn Amberstill"],
			category = "vendors",
			faction = "Alliance",
		},
		[47205240] = {
			name = L["Kreg Bilmn"],
			category = "vendors",
			description = L["General Supplies"],
			faction = "Alliance",
		},
		[46605360] = {
			name = L["Golorn Frostbeard"],
			category = "vendors",
			description = L["Tradesman"],
			faction = "Alliance",
		},
		[50004940] = {
			name = L["Loslor Rudge"],
			category = "vendors",
			description = L["Engineering Supplies"],
			faction = "Alliance",
		},
		[30404580] = {
			name = L["Keeg Gibn"],
			category = "vendors",
			description = L["Ale and Wine"],
			faction = "Alliance",
		},
		[47205365] = {
			name = L["Dannie Fizzwizzle"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Demon Trainer"],
			classes = {
				WARLOCK = true,
			},
			faction = "Alliance",
		},
		[28806620] = {
			name = L["Wren Darkspring"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Demon Trainer"],
			classes = {
				WARLOCK = true,
			},
			faction = "Alliance",
		},
		[49004800] = {
			name = L["Milli Featherwhistle"],
			category = "vendors",
			description = L["Mechanostrider Merchant"],
			faction = "Alliance",
		},
		[31404460] = {
			name = L["Gretta Ganter"],
			category = "vendors",
			description = L["Fisherman Supplies"],
			faction = "Alliance",
		},
		[52603600] = {
			name = L["Wagner Hammerstrike"],
			category = "vendors",
			faction = "Alliance",
		},
		[71405140] = {
			name = L["Hammerspine"],
			category = "rares",
			faction = "Neutral",
		},
		[71405180] = {
			name = L["Hammerspine"],
			category = "rares",
			faction = "Neutral",
		},
		[71605220] = {
			name = L["Hammerspine"],
			category = "rares",
			faction = "Neutral",
		},
		[72205280] = {
			name = L["Hammerspine"],
			category = "rares",
			faction = "Neutral",
		},
		[72605280] = {
			name = L["Hammerspine"],
			category = "rares",
			faction = "Neutral",
		},
		[72805380] = {
			name = L["Hammerspine"],
			category = "rares",
			faction = "Neutral",
		},
		[73005180] = {
			name = L["Hammerspine"],
			category = "rares",
			faction = "Neutral",
		},
		[52405840] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[52405860] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[52805840] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[52805880] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[53405700] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[54005640] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[54205780] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[54205860] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[54605680] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[54605760] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[54805640] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[55405920] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[55805860] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[55805960] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[56205720] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[56405640] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[56605660] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[56805520] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[58806040] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[58806100] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[58806260] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[59005840] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[59006180] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[59205720] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[59405900] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[60005780] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[62405840] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[62405860] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[62406080] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[62605880] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[62805740] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[63206000] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[63805980] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[65005960] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[31204320] = {
			name = L["Timber"],
			category = "rares",
			faction = "Neutral",
		},
		[31804080] = {
			name = L["Timber"],
			category = "rares",
			faction = "Neutral",
		},
		[32004180] = {
			name = L["Timber"],
			category = "rares",
			faction = "Neutral",
		},
		[32204020] = {
			name = L["Timber"],
			category = "rares",
			faction = "Neutral",
		},
		[32804300] = {
			name = L["Timber"],
			category = "rares",
			faction = "Neutral",
		},
		[33004040] = {
			name = L["Timber"],
			category = "rares",
			faction = "Neutral",
		},
		[33203920] = {
			name = L["Timber"],
			category = "rares",
			faction = "Neutral",
		},
		[33204160] = {
			name = L["Timber"],
			category = "rares",
			faction = "Neutral",
		},
		[33404100] = {
			name = L["Timber"],
			category = "rares",
			faction = "Neutral",
		},
		[33804120] = {
			name = L["Timber"],
			category = "rares",
			faction = "Neutral",
		},
		[34003920] = {
			name = L["Timber"],
			category = "rares",
			faction = "Neutral",
		},
		[34004020] = {
			name = L["Timber"],
			category = "rares",
			faction = "Neutral",
		},
		[34204180] = {
			name = L["Timber"],
			category = "rares",
			faction = "Neutral",
		},
		[34404300] = {
			name = L["Timber"],
			category = "rares",
			faction = "Neutral",
		},
		[34603900] = {
			name = L["Timber"],
			category = "rares",
			faction = "Neutral",
		},
		[34604140] = {
			name = L["Timber"],
			category = "rares",
			faction = "Neutral",
		},
		[34604400] = {
			name = L["Timber"],
			category = "rares",
			faction = "Neutral",
		},
		[35004040] = {
			name = L["Timber"],
			category = "rares",
			faction = "Neutral",
		},
		[35404200] = {
			name = L["Timber"],
			category = "rares",
			faction = "Neutral",
		},
		[36003780] = {
			name = L["Timber"],
			category = "rares",
			faction = "Neutral",
		},
		[36204260] = {
			name = L["Timber"],
			category = "rares",
			faction = "Neutral",
		},
		[36404180] = {
			name = L["Timber"],
			category = "rares",
			faction = "Neutral",
		},
		[36804300] = {
			name = L["Timber"],
			category = "rares",
			faction = "Neutral",
		},
		[39004760] = {
			name = L["Edan the Howler"],
			category = "rares",
			faction = "Neutral",
		},
		[39204640] = {
			name = L["Edan the Howler"],
			category = "rares",
			faction = "Neutral",
		},
		[39204740] = {
			name = L["Edan the Howler"],
			category = "rares",
			faction = "Neutral",
		},
		[39604820] = {
			name = L["Edan the Howler"],
			category = "rares",
			faction = "Neutral",
		},
		[39804600] = {
			name = L["Edan the Howler"],
			category = "rares",
			faction = "Neutral",
		},
		[40404680] = {
			name = L["Edan the Howler"],
			category = "rares",
			faction = "Neutral",
		},
		[40604680] = {
			name = L["Edan the Howler"],
			category = "rares",
			faction = "Neutral",
		},
		[40804540] = {
			name = L["Edan the Howler"],
			category = "rares",
			faction = "Neutral",
		},
		[41004920] = {
			name = L["Edan the Howler"],
			category = "rares",
			faction = "Neutral",
		},
		[42204640] = {
			name = L["Edan the Howler"],
			category = "rares",
			faction = "Neutral",
		},
		[43204960] = {
			name = L["Edan the Howler"],
			category = "rares",
			faction = "Neutral",
		},
		[43404900] = {
			name = L["Edan the Howler"],
			category = "rares",
			faction = "Neutral",
		},
		[21205160] = {
			name = L["Great Father Arctikus"],
			category = "rares",
			faction = "Neutral",
		},
		[21205280] = {
			name = L["Great Father Arctikus"],
			category = "rares",
			faction = "Neutral",
		},
		[21405040] = {
			name = L["Great Father Arctikus"],
			category = "rares",
			faction = "Neutral",
		},
		[21405100] = {
			name = L["Great Father Arctikus"],
			category = "rares",
			faction = "Neutral",
		},
		[21405360] = {
			name = L["Great Father Arctikus"],
			category = "rares",
			faction = "Neutral",
		},
		[21605260] = {
			name = L["Great Father Arctikus"],
			category = "rares",
			faction = "Neutral",
		},
		[21805500] = {
			name = L["Great Father Arctikus"],
			category = "rares",
			faction = "Neutral",
		},
		[22005120] = {
			name = L["Great Father Arctikus"],
			category = "rares",
			faction = "Neutral",
		},
		[22005200] = {
			name = L["Great Father Arctikus"],
			category = "rares",
			faction = "Neutral",
		},
		[22405020] = {
			name = L["Great Father Arctikus"],
			category = "rares",
			faction = "Neutral",
		},
		[22405420] = {
			name = L["Great Father Arctikus"],
			category = "rares",
			faction = "Neutral",
		},
		[22605020] = {
			name = L["Great Father Arctikus"],
			category = "rares",
			faction = "Neutral",
		},
		[22605180] = {
			name = L["Great Father Arctikus"],
			category = "rares",
			faction = "Neutral",
		},
		[23205080] = {
			name = L["Great Father Arctikus"],
			category = "rares",
			faction = "Neutral",
		},
		[23605380] = {
			name = L["Great Father Arctikus"],
			category = "rares",
			faction = "Neutral",
		},
		[23805080] = {
			name = L["Great Father Arctikus"],
			category = "rares",
			faction = "Neutral",
		},
		[24005280] = {
			name = L["Great Father Arctikus"],
			category = "rares",
			faction = "Neutral",
		},
		[25605000] = {
			name = L["Great Father Arctikus"],
			category = "rares",
			faction = "Neutral",
		},
		[24004340] = {
			name = L["Gibblewilt"],
			category = "rares",
			faction = "Neutral",
		},
		[24204360] = {
			name = L["Gibblewilt"],
			category = "rares",
			faction = "Neutral",
		},
		[24604560] = {
			name = L["Gibblewilt"],
			category = "rares",
			faction = "Neutral",
		},
		[24804360] = {
			name = L["Gibblewilt"],
			category = "rares",
			faction = "Neutral",
		},
		[25004280] = {
			name = L["Gibblewilt"],
			category = "rares",
			faction = "Neutral",
		},
		[25204460] = {
			name = L["Gibblewilt"],
			category = "rares",
			faction = "Neutral",
		},
		[25804440] = {
			name = L["Gibblewilt"],
			category = "rares",
			faction = "Neutral",
		},
		[25804520] = {
			name = L["Gibblewilt"],
			category = "rares",
			faction = "Neutral",
		},
		[26203660] = {
			name = L["Gibblewilt"],
			category = "rares",
			faction = "Neutral",
		},
		[26403640] = {
			name = L["Gibblewilt"],
			category = "rares",
			faction = "Neutral",
		},
		[27203580] = {
			name = L["Gibblewilt"],
			category = "rares",
			faction = "Neutral",
		},
		[27203660] = {
			name = L["Gibblewilt"],
			category = "rares",
			faction = "Neutral",
		},
		[27603820] = {
			name = L["Gibblewilt"],
			category = "rares",
			faction = "Neutral",
		},
		[28003720] = {
			name = L["Gibblewilt"],
			category = "rares",
			faction = "Neutral",
		},
		[59205500] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[59605700] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[59605760] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[59806020] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[62205720] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[62805680] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[62805800] = {
			name = L["Bjarn"],
			category = "rares",
			faction = "Neutral",
		},
		[33203820] = {
			name = L["Timber"],
			category = "rares",
			faction = "Neutral",
		},
		[33803940] = {
			name = L["Timber"],
			category = "rares",
			faction = "Neutral",
		},
		[22605460] = {
			name = L["Great Father Arctikus"],
			category = "rares",
			faction = "Neutral",
		},
		[23205260] = {
			name = L["Great Father Arctikus"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1420] = {
		[61605200] = {
			name = L["Innkeeper Renee"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Horde",
		},
		[61405310] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Horde",
		},
		[32406560] = {
			name = L["Archibald Kava"],
			category = "repair",
			description = L["Cloth & Leather Armor Merchant"],
			faction = "Horde",
		},
		[32406620] = {
			name = L["Blacksmith Rand"],
			category = "repair",
			description = L["Apprentice Armorer"],
			faction = "Horde",
		},
		[32406640] = {
			name = L["Harold Raims"],
			category = "repair",
			description = L["Apprentice Weaponsmith"],
			faction = "Horde",
		},
		[60205300] = {
			name = L["Abe Winters"],
			category = "repair",
			description = L["Apprentice Armorer"],
			faction = "Horde",
		},
		[60205340] = {
			name = L["Oliver Dwor"],
			category = "repair",
			description = L["Apprentice Weaponsmith"],
			faction = "Horde",
		},
		[60405280] = {
			name = L["Eliza Callen"],
			category = "repair",
			description = L["Leather Armor Merchant"],
			faction = "Horde",
		},
		[52605560] = {
			name = L["Constance Brisboise"],
			category = "repair",
			description = L["Apprentice Clothier"],
			faction = "Horde",
		},
		[31206480] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[56204940] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[79004080] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[82006940] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[60005220] = {
			name = L["Morganus"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Horde",
		},
		[59805200] = {
			name = L["Faruza"],
			category = "primaryProfession",
			profession = "Herbalism",
			description = L["Apprentice Herbalist"],
			faction = "Horde",
		},
		[32606560] = {
			name = L["Dannal Stern"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warrior Trainer"],
			classes = {
				WARRIOR = true,
			},
			faction = "Horde",
		},
		[32406565] = {
			name = L["David Trias"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Rogue Trainer"],
			classes = {
				ROGUE = true,
			},
			faction = "Horde",
		},
		[31006600] = {
			name = L["Dark Cleric Duesten"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Priest Trainer"],
			classes = {
				PRIEST = true,
			},
			faction = "Horde",
		},
		[30806600] = {
			name = L["Isabella"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Mage Trainer"],
			classes = {
				MAGE = true,
			},
			faction = "Horde",
		},
		[30806620] = {
			name = L["Maximillion"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warlock Trainer"],
			classes = {
				WARLOCK = true,
			},
			faction = "Horde",
		},
		[61605240] = {
			name = L["Rupert Boch"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warlock Trainer"],
			classes = {
				WARLOCK = true,
			},
			faction = "Horde",
		},
		[61805240] = {
			name = L["Cain Firesong"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Mage Trainer"],
			classes = {
				MAGE = true,
			},
			faction = "Horde",
		},
		[61605220] = {
			name = L["Dark Cleric Beryl"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Priest Trainer"],
			classes = {
				PRIEST = true,
			},
			faction = "Horde",
		},
		[61605205] = {
			name = L["Marion Call"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Rogue Trainer"],
			classes = {
				ROGUE = true,
			},
			faction = "Horde",
		},
		[61805245] = {
			name = L["Austil de Mon"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warrior Trainer"],
			classes = {
				WARRIOR = true,
			},
			faction = "Horde",
		},
		[59405220] = {
			name = L["Carolai Anise"],
			category = "primaryProfession",
			profession = "Alchemy",
			description = L["Journeyman Alchemist"],
			faction = "Horde",
		},
		[52605565] = {
			name = L["Bowen Brisboise"],
			category = "primaryProfession",
			profession = "Tailoring",
			description = L["Journeyman Tailor"],
			faction = "Horde",
		},
		[65406000] = {
			name = L["Shelene Rhobart"],
			category = "primaryProfession",
			profession = "Leatherworking",
			description = L["Journeyman Leatherworker"],
			faction = "Horde",
		},
		[60005240] = {
			name = L["Velma Warnam"],
			category = "trainers",
			description = L["Undead Horse Riding Instructor"],
			faction = "Horde",
		},
		[67205100] = {
			name = L["Clyde Kellen"],
			category = "secondaryProfession",
			profession = "Fishing",
			description = L["Fisherman"],
			faction = "Horde",
		},
		[61605160] = {
			name = L["Vance Undergloom"],
			category = "primaryProfession",
			profession = "Enchanting",
			description = L["Journeyman Enchanter"],
			faction = "Horde",
		},
		[61805280] = {
			name = L["Nurse Neela"],
			category = "secondaryProfession",
			profession = "First Aid",
			description = L["First Aid Trainer"],
			faction = "Horde",
		},
		[65606000] = {
			name = L["Rand Rhobart"],
			category = "primaryProfession",
			profession = "Skinning",
			description = L["Skinner"],
			faction = "Horde",
		},
		[32206540] = {
			name = L["Joshua Kien"],
			category = "vendors",
			description = L["General Supplies"],
			faction = "Horde",
		},
		[61005240] = {
			name = L["Abigail Shiel"],
			category = "vendors",
			description = L["Trade Supplies"],
			faction = "Horde",
		},
		[61005260] = {
			name = L["Mrs. Winters"],
			category = "vendors",
			description = L["General Supplies"],
			faction = "Horde",
		},
		[56605220] = {
			name = L["Hamlin Atkins"],
			category = "vendors",
			description = L["Mushroom Farmer"],
			faction = "Horde",
		},
		[61805000] = {
			name = L["Selina Weston"],
			category = "vendors",
			description = L["Alchemy & Herbalism Supplies"],
			faction = "Horde",
		},
		[65805960] = {
			name = L["Martine Tramblay"],
			category = "vendors",
			description = L["Fishing Supplies"],
			faction = "Horde",
		},
		[59805260] = {
			name = L["Zachariah Post"],
			category = "vendors",
			description = L["Undead Horse Merchant"],
			faction = "Horde",
		},
		[30806640] = {
			name = L["Kayla Smithe"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Demon Trainer"],
			classes = {
				WARLOCK = true,
			},
			faction = "Horde",
		},
		[61605260] = {
			name = L["Gina Lang"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Demon Trainer"],
			classes = {
				WARLOCK = true,
			},
			faction = "Horde",
		},
		[83206820] = {
			name = L["Argent Quartermaster Hasana"],
			category = "vendors",
			description = L["The Argent Dawn"],
			faction = "Horde",
		},
		[83206920] = {
			name = L["Apothecary Dithers"],
			category = "vendors",
			faction = "Horde",
		},
		[83206960] = {
			name = L["Werg Thickblade"],
			category = "vendors",
			description = L["Leatherworking Supplies"],
			faction = "Horde",
		},
		[47003940] = {
			name = L["Lost Soul"],
			category = "rares",
			faction = "Neutral",
		},
		[47603540] = {
			name = L["Lost Soul"],
			category = "rares",
			faction = "Neutral",
		},
		[48603540] = {
			name = L["Lost Soul"],
			category = "rares",
			faction = "Neutral",
		},
		[49403740] = {
			name = L["Lost Soul"],
			category = "rares",
			faction = "Neutral",
		},
		[53004620] = {
			name = L["Lost Soul"],
			category = "rares",
			faction = "Neutral",
		},
		[53204860] = {
			name = L["Lost Soul"],
			category = "rares",
			faction = "Neutral",
		},
		[53404660] = {
			name = L["Lost Soul"],
			category = "rares",
			faction = "Neutral",
		},
		[53404840] = {
			name = L["Lost Soul"],
			category = "rares",
			faction = "Neutral",
		},
		[53604640] = {
			name = L["Lost Soul"],
			category = "rares",
			faction = "Neutral",
		},
		[53604680] = {
			name = L["Lost Soul"],
			category = "rares",
			faction = "Neutral",
		},
		[53604800] = {
			name = L["Lost Soul"],
			category = "rares",
			faction = "Neutral",
		},
		[53604860] = {
			name = L["Lost Soul"],
			category = "rares",
			faction = "Neutral",
		},
		[43403240] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[43803120] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[44003160] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[44003620] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[44203660] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[44403340] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[44403420] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[44403540] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[45003140] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[45003760] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[45403520] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[45803660] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[46203160] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[46403020] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[46403080] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[46403620] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[46603600] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[46603720] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[46803040] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[47003280] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[47003780] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[47203540] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[47403120] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[47403160] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[47603240] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[47803320] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[47803420] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[47803520] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[48603480] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[33404380] = {
			name = L["Muad"],
			category = "rares",
			faction = "Neutral",
		},
		[33804240] = {
			name = L["Muad"],
			category = "rares",
			faction = "Neutral",
		},
		[34404440] = {
			name = L["Muad"],
			category = "rares",
			faction = "Neutral",
		},
		[35004380] = {
			name = L["Muad"],
			category = "rares",
			faction = "Neutral",
		},
		[35004500] = {
			name = L["Muad"],
			category = "rares",
			faction = "Neutral",
		},
		[35204140] = {
			name = L["Muad"],
			category = "rares",
			faction = "Neutral",
		},
		[35204340] = {
			name = L["Muad"],
			category = "rares",
			faction = "Neutral",
		},
		[35804640] = {
			name = L["Muad"],
			category = "rares",
			faction = "Neutral",
		},
		[36204240] = {
			name = L["Muad"],
			category = "rares",
			faction = "Neutral",
		},
		[36404120] = {
			name = L["Muad"],
			category = "rares",
			faction = "Neutral",
		},
		[36404340] = {
			name = L["Muad"],
			category = "rares",
			faction = "Neutral",
		},
		[36404400] = {
			name = L["Muad"],
			category = "rares",
			faction = "Neutral",
		},
		[36404460] = {
			name = L["Muad"],
			category = "rares",
			faction = "Neutral",
		},
		[36803900] = {
			name = L["Muad"],
			category = "rares",
			faction = "Neutral",
		},
		[36804000] = {
			name = L["Muad"],
			category = "rares",
			faction = "Neutral",
		},
		[36804080] = {
			name = L["Muad"],
			category = "rares",
			faction = "Neutral",
		},
		[36804180] = {
			name = L["Muad"],
			category = "rares",
			faction = "Neutral",
		},
		[37004340] = {
			name = L["Muad"],
			category = "rares",
			faction = "Neutral",
		},
		[37004440] = {
			name = L["Muad"],
			category = "rares",
			faction = "Neutral",
		},
		[37603920] = {
			name = L["Muad"],
			category = "rares",
			faction = "Neutral",
		},
		[37604040] = {
			name = L["Muad"],
			category = "rares",
			faction = "Neutral",
		},
		[37604140] = {
			name = L["Muad"],
			category = "rares",
			faction = "Neutral",
		},
		[37604160] = {
			name = L["Muad"],
			category = "rares",
			faction = "Neutral",
		},
		[37804340] = {
			name = L["Muad"],
			category = "rares",
			faction = "Neutral",
		},
		[57402840] = {
			name = L["Deeb"],
			category = "rares",
			faction = "Neutral",
		},
		[58002640] = {
			name = L["Deeb"],
			category = "rares",
			faction = "Neutral",
		},
		[58202660] = {
			name = L["Deeb"],
			category = "rares",
			faction = "Neutral",
		},
		[58402780] = {
			name = L["Deeb"],
			category = "rares",
			faction = "Neutral",
		},
		[58602760] = {
			name = L["Deeb"],
			category = "rares",
			faction = "Neutral",
		},
		[58802720] = {
			name = L["Deeb"],
			category = "rares",
			faction = "Neutral",
		},
		[59602700] = {
			name = L["Deeb"],
			category = "rares",
			faction = "Neutral",
		},
		[63202840] = {
			name = L["Deeb"],
			category = "rares",
			faction = "Neutral",
		},
		[34405140] = {
			name = L["Farmer Solliden"],
			category = "rares",
			faction = "Neutral",
		},
		[34405240] = {
			name = L["Farmer Solliden"],
			category = "rares",
			faction = "Neutral",
		},
		[34605200] = {
			name = L["Farmer Solliden"],
			category = "rares",
			faction = "Neutral",
		},
		[34805260] = {
			name = L["Farmer Solliden"],
			category = "rares",
			faction = "Neutral",
		},
		[35605200] = {
			name = L["Farmer Solliden"],
			category = "rares",
			faction = "Neutral",
		},
		[36404940] = {
			name = L["Farmer Solliden"],
			category = "rares",
			faction = "Neutral",
		},
		[36804940] = {
			name = L["Farmer Solliden"],
			category = "rares",
			faction = "Neutral",
		},
		[36804960] = {
			name = L["Farmer Solliden"],
			category = "rares",
			faction = "Neutral",
		},
		[36805080] = {
			name = L["Farmer Solliden"],
			category = "rares",
			faction = "Neutral",
		},
		[37005300] = {
			name = L["Farmer Solliden"],
			category = "rares",
			faction = "Neutral",
		},
		[37204840] = {
			name = L["Farmer Solliden"],
			category = "rares",
			faction = "Neutral",
		},
		[37405200] = {
			name = L["Farmer Solliden"],
			category = "rares",
			faction = "Neutral",
		},
		[37604920] = {
			name = L["Farmer Solliden"],
			category = "rares",
			faction = "Neutral",
		},
		[37805280] = {
			name = L["Farmer Solliden"],
			category = "rares",
			faction = "Neutral",
		},
		[38005140] = {
			name = L["Farmer Solliden"],
			category = "rares",
			faction = "Neutral",
		},
		[38005160] = {
			name = L["Farmer Solliden"],
			category = "rares",
			faction = "Neutral",
		},
		[38205020] = {
			name = L["Farmer Solliden"],
			category = "rares",
			faction = "Neutral",
		},
		[38605140] = {
			name = L["Farmer Solliden"],
			category = "rares",
			faction = "Neutral",
		},
		[38804940] = {
			name = L["Farmer Solliden"],
			category = "rares",
			faction = "Neutral",
		},
		[38805160] = {
			name = L["Farmer Solliden"],
			category = "rares",
			faction = "Neutral",
		},
		[39005260] = {
			name = L["Farmer Solliden"],
			category = "rares",
			faction = "Neutral",
		},
		[40005160] = {
			name = L["Farmer Solliden"],
			category = "rares",
			faction = "Neutral",
		},
		[39404160] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[39804260] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[40404240] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[40604200] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[40804140] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[41405240] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[41405280] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[41405380] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[41805240] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[41805280] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[45205100] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[45405320] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[45605160] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[45805300] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[46005080] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[46605140] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[46605180] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[46805260] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[48404920] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[49205060] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[49804900] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[50005020] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[50005080] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[50605100] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[52605340] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[55603940] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[56204060] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[57003840] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[57003980] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[57203940] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[57404060] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[57604040] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[58004080] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[42606880] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[43006640] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[43006760] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[43206440] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[43406700] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[43606620] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[43606740] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[46006500] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[46006600] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[46606640] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[47006500] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[48806540] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[49406580] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[49606340] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[50006540] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[50206440] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[50206560] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[51006620] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[51206380] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[51406320] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[51806440] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[51806540] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[52206340] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[52406240] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[52606220] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[52606380] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[55406100] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[55406180] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[55806000] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[55806180] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[56406140] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[57406300] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[74005960] = {
			name = L["Fellicent's Shade"],
			category = "rares",
			faction = "Neutral",
		},
		[74206080] = {
			name = L["Fellicent's Shade"],
			category = "rares",
			faction = "Neutral",
		},
		[74405900] = {
			name = L["Fellicent's Shade"],
			category = "rares",
			faction = "Neutral",
		},
		[74406160] = {
			name = L["Fellicent's Shade"],
			category = "rares",
			faction = "Neutral",
		},
		[75006080] = {
			name = L["Fellicent's Shade"],
			category = "rares",
			faction = "Neutral",
		},
		[75006200] = {
			name = L["Fellicent's Shade"],
			category = "rares",
			faction = "Neutral",
		},
		[75205940] = {
			name = L["Fellicent's Shade"],
			category = "rares",
			faction = "Neutral",
		},
		[75206000] = {
			name = L["Fellicent's Shade"],
			category = "rares",
			faction = "Neutral",
		},
		[75206320] = {
			name = L["Fellicent's Shade"],
			category = "rares",
			faction = "Neutral",
		},
		[75805780] = {
			name = L["Fellicent's Shade"],
			category = "rares",
			faction = "Neutral",
		},
		[76005960] = {
			name = L["Fellicent's Shade"],
			category = "rares",
			faction = "Neutral",
		},
		[76006260] = {
			name = L["Fellicent's Shade"],
			category = "rares",
			faction = "Neutral",
		},
		[76206060] = {
			name = L["Fellicent's Shade"],
			category = "rares",
			faction = "Neutral",
		},
		[76405740] = {
			name = L["Fellicent's Shade"],
			category = "rares",
			faction = "Neutral",
		},
		[76405860] = {
			name = L["Fellicent's Shade"],
			category = "rares",
			faction = "Neutral",
		},
		[76406220] = {
			name = L["Fellicent's Shade"],
			category = "rares",
			faction = "Neutral",
		},
		[76605900] = {
			name = L["Fellicent's Shade"],
			category = "rares",
			faction = "Neutral",
		},
		[76606040] = {
			name = L["Fellicent's Shade"],
			category = "rares",
			faction = "Neutral",
		},
		[76806120] = {
			name = L["Fellicent's Shade"],
			category = "rares",
			faction = "Neutral",
		},
		[76806200] = {
			name = L["Fellicent's Shade"],
			category = "rares",
			faction = "Neutral",
		},
		[77806320] = {
			name = L["Fellicent's Shade"],
			category = "rares",
			faction = "Neutral",
		},
		[83005580] = {
			name = L["Sri'skulk"],
			category = "rares",
			faction = "Neutral",
		},
		[83205500] = {
			name = L["Sri'skulk"],
			category = "rares",
			faction = "Neutral",
		},
		[83805600] = {
			name = L["Sri'skulk"],
			category = "rares",
			faction = "Neutral",
		},
		[84005380] = {
			name = L["Sri'skulk"],
			category = "rares",
			faction = "Neutral",
		},
		[84404940] = {
			name = L["Sri'skulk"],
			category = "rares",
			faction = "Neutral",
		},
		[84405060] = {
			name = L["Sri'skulk"],
			category = "rares",
			faction = "Neutral",
		},
		[84405220] = {
			name = L["Sri'skulk"],
			category = "rares",
			faction = "Neutral",
		},
		[84405460] = {
			name = L["Sri'skulk"],
			category = "rares",
			faction = "Neutral",
		},
		[84805020] = {
			name = L["Sri'skulk"],
			category = "rares",
			faction = "Neutral",
		},
		[85004920] = {
			name = L["Sri'skulk"],
			category = "rares",
			faction = "Neutral",
		},
		[85005540] = {
			name = L["Sri'skulk"],
			category = "rares",
			faction = "Neutral",
		},
		[85205080] = {
			name = L["Sri'skulk"],
			category = "rares",
			faction = "Neutral",
		},
		[88405140] = {
			name = L["Sri'skulk"],
			category = "rares",
			faction = "Neutral",
		},
		[88605000] = {
			name = L["Sri'skulk"],
			category = "rares",
			faction = "Neutral",
		},
		[88605200] = {
			name = L["Sri'skulk"],
			category = "rares",
			faction = "Neutral",
		},
		[88805060] = {
			name = L["Sri'skulk"],
			category = "rares",
			faction = "Neutral",
		},
		[89204680] = {
			name = L["Sri'skulk"],
			category = "rares",
			faction = "Neutral",
		},
		[89204800] = {
			name = L["Sri'skulk"],
			category = "rares",
			faction = "Neutral",
		},
		[89404020] = {
			name = L["Sri'skulk"],
			category = "rares",
			faction = "Neutral",
		},
		[89404140] = {
			name = L["Sri'skulk"],
			category = "rares",
			faction = "Neutral",
		},
		[89404600] = {
			name = L["Sri'skulk"],
			category = "rares",
			faction = "Neutral",
		},
		[89604160] = {
			name = L["Sri'skulk"],
			category = "rares",
			faction = "Neutral",
		},
		[89604340] = {
			name = L["Sri'skulk"],
			category = "rares",
			faction = "Neutral",
		},
		[89604700] = {
			name = L["Sri'skulk"],
			category = "rares",
			faction = "Neutral",
		},
		[90204600] = {
			name = L["Sri'skulk"],
			category = "rares",
			faction = "Neutral",
		},
		[90204760] = {
			name = L["Sri'skulk"],
			category = "rares",
			faction = "Neutral",
		},
		[44603140] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[44803620] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[45403180] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[46403180] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[46803180] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[47403560] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[47603200] = {
			name = L["Tormented Spirit"],
			category = "rares",
			faction = "Neutral",
		},
		[36204000] = {
			name = L["Muad"],
			category = "rares",
			faction = "Neutral",
		},
		[36403940] = {
			name = L["Muad"],
			category = "rares",
			faction = "Neutral",
		},
		[58602860] = {
			name = L["Deeb"],
			category = "rares",
			faction = "Neutral",
		},
		[63802940] = {
			name = L["Deeb"],
			category = "rares",
			faction = "Neutral",
		},
		[40004240] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[40204360] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[42005140] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[49005100] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[49805000] = {
			name = L["Bayne"],
			category = "rares",
			faction = "Neutral",
		},
		[45606400] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[45806680] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[55205980] = {
			name = L["Ressan the Needler"],
			category = "rares",
			faction = "Neutral",
		},
		[74806240] = {
			name = L["Fellicent's Shade"],
			category = "rares",
			faction = "Neutral",
		},
		[75005900] = {
			name = L["Fellicent's Shade"],
			category = "rares",
			faction = "Neutral",
		},
		[77606160] = {
			name = L["Fellicent's Shade"],
			category = "rares",
			faction = "Neutral",
		},
		[85005040] = {
			name = L["Sri'skulk"],
			category = "rares",
			faction = "Neutral",
		},
		[85204820] = {
			name = L["Sri'skulk"],
			category = "rares",
			faction = "Neutral",
		},
		[88405380] = {
			name = L["Sri'skulk"],
			category = "rares",
			faction = "Neutral",
		},
		[89604220] = {
			name = L["Sri'skulk"],
			category = "rares",
			faction = "Neutral",
		},
		[89804580] = {
			name = L["Sri'skulk"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1429] = {
		[43806580] = {
			name = L["Innkeeper Farley"],
			category = "innkeepers",
			description = L["Innkeeper"],
			faction = "Alliance",
		},
		[42906540] = {
			name = L["Mailbox"],
			category = "mailboxes",
			faction = "Alliance",
		},
		[41606580] = {
			name = L["Corina Steele"],
			category = "repair",
			description = L["Weaponsmith"],
			faction = "Alliance",
		},
		[41406560] = {
			name = L["Kurran Steele"],
			category = "repair",
			description = L["Cloth & Leather Armor Merchant"],
			faction = "Alliance",
		},
		[47204180] = {
			name = L["Janos Hammerknuckle"],
			category = "repair",
			description = L["Weaponsmith"],
			faction = "Alliance",
		},
		[47604140] = {
			name = L["Dermot Johns"],
			category = "repair",
			description = L["Cloth & Leather Armor Merchant"],
			faction = "Alliance",
		},
		[25207380] = {
			name = L["Veldan Lightfoot"],
			category = "repair",
			description = L["Leather Armor Merchant"],
			faction = "Alliance",
		},
		[64606960] = {
			name = L["Morley Eberlein"],
			category = "repair",
			description = L["Clothier"],
			faction = "Alliance",
		},
		[83206600] = {
			name = L["Rallic Finn"],
			category = "repair",
			description = L["Bowyer"],
			faction = "Alliance",
		},
		[47604145] = {
			name = L["Godric Rothgar"],
			category = "vendors",
			description = L["Armorer & Shieldcrafter"],
			faction = "Alliance",
		},
		[25207400] = {
			name = L["Quartermaster Hudson"],
			category = "repair",
			description = L["Armorer & Shieldcrafter"],
			faction = "Alliance",
		},
		[25207385] = {
			name = L["Quartermaster Hicks"],
			category = "vendors",
			description = L["Master Weaponsmith"],
			faction = "Alliance",
		},
		[41606560] = {
			name = L["Andrew Krighton"],
			category = "repair",
			description = L["Armorer & Shieldcrafter"],
			faction = "Alliance",
		},
		[39406040] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[49404340] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[83606960] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
		[42806580] = {
			name = L["Erma"],
			category = "stablemasters",
			description = L["Stable Master"],
			faction = "Alliance",
		},
		[49603940] = {
			name = L["Khelden Bremen"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Mage Trainer"],
			classes = {
				MAGE = true,
			},
			faction = "Alliance",
		},
		[43206620] = {
			name = L["Zaldimar Wefhellt"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Mage Trainer"],
			classes = {
				MAGE = true,
			},
			faction = "Alliance",
		},
		[49803960] = {
			name = L["Priestess Anetta"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Priest Trainer"],
			classes = {
				PRIEST = true,
			},
			faction = "Alliance",
		},
		[43206560] = {
			name = L["Priestess Josetta"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Priest Trainer"],
			classes = {
				PRIEST = true,
			},
			faction = "Alliance",
		},
		[49804260] = {
			name = L["Drusilla La Salle"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warlock Trainer"],
			classes = {
				WARLOCK = true,
			},
			faction = "Alliance",
		},
		[41606565] = {
			name = L["Smith Argus"],
			category = "primaryProfession",
			profession = "Blacksmith",
			description = L["Journeyman Blacksmith"],
			faction = "Alliance",
		},
		[44406620] = {
			name = L["Maximillian Crowe"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warlock Trainer"],
			classes = {
				WARLOCK = true,
			},
			faction = "Alliance",
		},
		[50204220] = {
			name = L["Llane Beshere"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warrior Trainer"],
			classes = {
				WARRIOR = true,
			},
			faction = "Alliance",
		},
		[41006580] = {
			name = L["Lyria Du Lac"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Warrior Trainer"],
			classes = {
				WARRIOR = true,
			},
			faction = "Alliance",
		},
		[50403980] = {
			name = L["Jorik Kerridan"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Rogue Trainer"],
			classes = {
				ROGUE = true,
			},
			faction = "Alliance",
		},
		[43806585] = {
			name = L["Barkeep Dobbins"],
			category = "vendors",
			description = L["Bartender"],
			faction = "Alliance",
		},
		[50404200] = {
			name = L["Brother Sammuel"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Paladin Trainer"],
			classes = {
				PALADIN = true,
			},
			faction = "Alliance",
		},
		[41006600] = {
			name = L["Brother Wilhelm"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Paladin Trainer"],
			classes = {
				PALADIN = true,
			},
			faction = "Alliance",
		},
		[79206900] = {
			name = L["Eldrin"],
			category = "primaryProfession",
			profession = "Tailoring",
			description = L["Journeyman Tailor"],
			faction = "Alliance",
		},
		[39804840] = {
			name = L["Alchemist Mallory"],
			category = "primaryProfession",
			profession = "Alchemy",
			description = L["Journeyman Alchemist"],
			faction = "Alliance",
		},
		[39804845] = {
			name = L["Herbalist Pomeroy"],
			category = "primaryProfession",
			profession = "Herbalism",
			description = L["Herbalism Trainer"],
			faction = "Alliance",
		},
		[44206600] = {
			name = L["Tomas"],
			category = "secondaryProfession",
			profession = "Cooking",
			description = L["Cook"],
			faction = "Alliance",
		},
		[46406220] = {
			name = L["Adele Fielder"],
			category = "primaryProfession",
			profession = "Leatherworking",
			description = L["Journeyman Leatherworker"],
			faction = "Alliance",
		},
		[47406220] = {
			name = L["Lee Brown"],
			category = "secondaryProfession",
			profession = "Fishing",
			description = L["Fisherman"],
			faction = "Alliance",
		},
		[43406560] = {
			name = L["Michelle Belle"],
			category = "secondaryProfession",
			profession = "First Aid",
			description = L["Physician"],
			faction = "Alliance",
		},
		[84206480] = {
			name = L["Randal Hunter"],
			category = "trainers",
			description = L["Horse Riding Instructor"],
			faction = "Alliance",
		},
		[46206220] = {
			name = L["Helene Peltskinner"],
			category = "primaryProfession",
			profession = "Skinning",
			description = L["Skinner"],
			faction = "Alliance",
		},
		[64807040] = {
			name = L["Kitta Firewind"],
			category = "primaryProfession",
			profession = "Enchanting",
			description = L["Artisan Enchanter"],
			faction = "Alliance",
		},
		[41806700] = {
			name = L["Tharynn Bouden"],
			category = "vendors",
			description = L["Trade Supplies"],
			faction = "Alliance",
		},
		[43806600] = {
			name = L["Brog Hamfist"],
			category = "vendors",
			description = L["General Supplies"],
			faction = "Alliance",
		},
		[47404160] = {
			name = L["Brother Danil"],
			category = "vendors",
			description = L["General Supplies"],
			faction = "Alliance",
		},
		[42408920] = {
			name = L["Joshua Maclure"],
			category = "vendors",
			description = L["Vintner"],
			faction = "Alliance",
		},
		[84006540] = {
			name = L["Katie Hunter"],
			category = "vendors",
			description = L["Horse Breeder"],
			faction = "Alliance",
		},
		[42606640] = {
			name = L["Antonio Perelli"],
			category = "vendors",
			description = L["Traveling Salesman"],
			faction = "Alliance",
		},
		[33608300] = {
			name = L["Homer Stonefield"],
			category = "vendors",
			description = L["Fruit Seller"],
			faction = "Alliance",
		},
		[24007300] = {
			name = L["Sergeant De Vries"],
			category = "vendors",
			description = L["Morale Officer"],
			faction = "Alliance",
		},
		[64806920] = {
			name = L["Dawn Brightstar"],
			category = "vendors",
			description = L["Arcane Goods"],
			faction = "Alliance",
		},
		[83206660] = {
			name = L["Drake Lindgren"],
			category = "vendors",
			description = L["General & Trade Supplies"],
			faction = "Alliance",
		},
		[82806340] = {
			name = L["Terry Palin"],
			category = "vendors",
			description = L["Lumberjack"],
			faction = "Alliance",
		},
		[44206605] = {
			name = L["Toddrick"],
			category = "vendors",
			description = L["Butcher"],
			faction = "Alliance",
		},
		[39405660] = {
			name = L["Kira Songshine"],
			category = "vendors",
			description = L["Traveling Baker"],
			faction = "Alliance",
		},
		[44205320] = {
			name = L["Donni Anthania"],
			category = "vendors",
			description = L["Crazy Cat Lady"],
			faction = "Alliance",
		},
		[50004260] = {
			name = L["Dane Winslow"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Demon Trainer"],
			classes = {
				WARLOCK = true,
			},
			faction = "Alliance",
		},
		[44406600] = {
			name = L["Cylina Darkheart"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Demon Trainer"],
			classes = {
				WARLOCK = true,
			},
			faction = "Alliance",
		},
		[28405960] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[29205840] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[29405860] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[30005820] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[30605820] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[49005980] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[50008140] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[50008320] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[50208380] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[50407840] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[50608320] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[50808140] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[51205920] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[51208220] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[51208500] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[51408040] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[51605980] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[51805900] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[52008060] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[52008200] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[52605920] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[52606200] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[53205800] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[53406020] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[53805920] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[54206020] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[87807960] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[88407720] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[88607840] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[88607980] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[89407920] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[89607720] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[89607860] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[90407620] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[39808060] = {
			name = L["Narg the Taskmaster"],
			category = "rares",
			faction = "Neutral",
		},
		[40807740] = {
			name = L["Narg the Taskmaster"],
			category = "rares",
			faction = "Neutral",
		},
		[41007820] = {
			name = L["Narg the Taskmaster"],
			category = "rares",
			faction = "Neutral",
		},
		[41207880] = {
			name = L["Narg the Taskmaster"],
			category = "rares",
			faction = "Neutral",
		},
		[41407960] = {
			name = L["Narg the Taskmaster"],
			category = "rares",
			faction = "Neutral",
		},
		[41608020] = {
			name = L["Narg the Taskmaster"],
			category = "rares",
			faction = "Neutral",
		},
		[29006400] = {
			name = L["Morgaine the Sly"],
			category = "rares",
			faction = "Neutral",
		},
		[29406540] = {
			name = L["Morgaine the Sly"],
			category = "rares",
			faction = "Neutral",
		},
		[29806040] = {
			name = L["Morgaine the Sly"],
			category = "rares",
			faction = "Neutral",
		},
		[29806460] = {
			name = L["Morgaine the Sly"],
			category = "rares",
			faction = "Neutral",
		},
		[30406660] = {
			name = L["Morgaine the Sly"],
			category = "rares",
			faction = "Neutral",
		},
		[30806520] = {
			name = L["Morgaine the Sly"],
			category = "rares",
			faction = "Neutral",
		},
		[30806660] = {
			name = L["Morgaine the Sly"],
			category = "rares",
			faction = "Neutral",
		},
		[31206560] = {
			name = L["Morgaine the Sly"],
			category = "rares",
			faction = "Neutral",
		},
		[31406440] = {
			name = L["Morgaine the Sly"],
			category = "rares",
			faction = "Neutral",
		},
		[31606440] = {
			name = L["Morgaine the Sly"],
			category = "rares",
			faction = "Neutral",
		},
		[31806560] = {
			name = L["Morgaine the Sly"],
			category = "rares",
			faction = "Neutral",
		},
		[32206540] = {
			name = L["Morgaine the Sly"],
			category = "rares",
			faction = "Neutral",
		},
		[32606660] = {
			name = L["Morgaine the Sly"],
			category = "rares",
			faction = "Neutral",
		},
		[32806540] = {
			name = L["Morgaine the Sly"],
			category = "rares",
			faction = "Neutral",
		},
		[25209240] = {
			name = L["Gruff Swiftbite"],
			category = "rares",
			faction = "Neutral",
		},
		[25209280] = {
			name = L["Gruff Swiftbite"],
			category = "rares",
			faction = "Neutral",
		},
		[26009140] = {
			name = L["Gruff Swiftbite"],
			category = "rares",
			faction = "Neutral",
		},
		[26009200] = {
			name = L["Gruff Swiftbite"],
			category = "rares",
			faction = "Neutral",
		},
		[26009300] = {
			name = L["Gruff Swiftbite"],
			category = "rares",
			faction = "Neutral",
		},
		[26208760] = {
			name = L["Gruff Swiftbite"],
			category = "rares",
			faction = "Neutral",
		},
		[26609100] = {
			name = L["Gruff Swiftbite"],
			category = "rares",
			faction = "Neutral",
		},
		[26609320] = {
			name = L["Gruff Swiftbite"],
			category = "rares",
			faction = "Neutral",
		},
		[27208920] = {
			name = L["Gruff Swiftbite"],
			category = "rares",
			faction = "Neutral",
		},
		[27608840] = {
			name = L["Gruff Swiftbite"],
			category = "rares",
			faction = "Neutral",
		},
		[28008920] = {
			name = L["Gruff Swiftbite"],
			category = "rares",
			faction = "Neutral",
		},
		[28408740] = {
			name = L["Gruff Swiftbite"],
			category = "rares",
			faction = "Neutral",
		},
		[28808820] = {
			name = L["Gruff Swiftbite"],
			category = "rares",
			faction = "Neutral",
		},
		[28808920] = {
			name = L["Gruff Swiftbite"],
			category = "rares",
			faction = "Neutral",
		},
		[28809060] = {
			name = L["Gruff Swiftbite"],
			category = "rares",
			faction = "Neutral",
		},
		[29008960] = {
			name = L["Gruff Swiftbite"],
			category = "rares",
			faction = "Neutral",
		},
		[60204720] = {
			name = L["Mother Fang"],
			category = "rares",
			faction = "Neutral",
		},
		[60204780] = {
			name = L["Mother Fang"],
			category = "rares",
			faction = "Neutral",
		},
		[60604960] = {
			name = L["Mother Fang"],
			category = "rares",
			faction = "Neutral",
		},
		[61005120] = {
			name = L["Mother Fang"],
			category = "rares",
			faction = "Neutral",
		},
		[61204720] = {
			name = L["Mother Fang"],
			category = "rares",
			faction = "Neutral",
		},
		[61404820] = {
			name = L["Mother Fang"],
			category = "rares",
			faction = "Neutral",
		},
		[61404880] = {
			name = L["Mother Fang"],
			category = "rares",
			faction = "Neutral",
		},
		[61604740] = {
			name = L["Mother Fang"],
			category = "rares",
			faction = "Neutral",
		},
		[61804760] = {
			name = L["Mother Fang"],
			category = "rares",
			faction = "Neutral",
		},
		[66204080] = {
			name = L["Fedfennel"],
			category = "rares",
			faction = "Neutral",
		},
		[66603880] = {
			name = L["Fedfennel"],
			category = "rares",
			faction = "Neutral",
		},
		[66604100] = {
			name = L["Fedfennel"],
			category = "rares",
			faction = "Neutral",
		},
		[67203960] = {
			name = L["Fedfennel"],
			category = "rares",
			faction = "Neutral",
		},
		[67604180] = {
			name = L["Fedfennel"],
			category = "rares",
			faction = "Neutral",
		},
		[67604620] = {
			name = L["Fedfennel"],
			category = "rares",
			faction = "Neutral",
		},
		[67803940] = {
			name = L["Fedfennel"],
			category = "rares",
			faction = "Neutral",
		},
		[67803960] = {
			name = L["Fedfennel"],
			category = "rares",
			faction = "Neutral",
		},
		[67804500] = {
			name = L["Fedfennel"],
			category = "rares",
			faction = "Neutral",
		},
		[68004400] = {
			name = L["Fedfennel"],
			category = "rares",
			faction = "Neutral",
		},
		[68804400] = {
			name = L["Fedfennel"],
			category = "rares",
			faction = "Neutral",
		},
		[69003980] = {
			name = L["Fedfennel"],
			category = "rares",
			faction = "Neutral",
		},
		[69004180] = {
			name = L["Fedfennel"],
			category = "rares",
			faction = "Neutral",
		},
		[69004540] = {
			name = L["Fedfennel"],
			category = "rares",
			faction = "Neutral",
		},
		[69203840] = {
			name = L["Fedfennel"],
			category = "rares",
			faction = "Neutral",
		},
		[69404260] = {
			name = L["Fedfennel"],
			category = "rares",
			faction = "Neutral",
		},
		[69804560] = {
			name = L["Fedfennel"],
			category = "rares",
			faction = "Neutral",
		},
		[70203780] = {
			name = L["Fedfennel"],
			category = "rares",
			faction = "Neutral",
		},
		[70204440] = {
			name = L["Fedfennel"],
			category = "rares",
			faction = "Neutral",
		},
		[70803800] = {
			name = L["Fedfennel"],
			category = "rares",
			faction = "Neutral",
		},
		[30805680] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[50408200] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[89607800] = {
			name = L["Thuros Lightfingers"],
			category = "rares",
			faction = "Neutral",
		},
		[31606540] = {
			name = L["Morgaine the Sly"],
			category = "rares",
			faction = "Neutral",
		},
		[23608980] = {
			name = L["Gruff Swiftbite"],
			category = "rares",
			faction = "Neutral",
		},
		[27408800] = {
			name = L["Gruff Swiftbite"],
			category = "rares",
			faction = "Neutral",
		},
		[28208860] = {
			name = L["Gruff Swiftbite"],
			category = "rares",
			faction = "Neutral",
		},
		[69603800] = {
			name = L["Fedfennel"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1416] = {
		[39408160] = {
			name = L["Thanthaldis Snowgleam"],
			category = "repair",
			description = L["Stormpike Supply Officer"],
			faction = "Alliance",
		},
		[62805940] = {
			name = L["Jekyll Flandring"],
			category = "repair",
			description = L["Frostwolf Supply Officer"],
			faction = "Horde",
		},
		[84408020] = {
			name = L["Fahrad"],
			category = "trainers",
			subcategory = "classTrainer",
			description = L["Grand Master Rogue"],
			classes = {
				ROGUE = true,
			},
			faction = "Neutral",
		},
		[38403880] = {
			name = L["Bro'kin"],
			category = "vendors",
			description = L["Alchemy Supplies"],
			faction = "Neutral",
		},
		[47203520] = {
			name = L["Rizz Loosebolt"],
			category = "vendors",
			description = L["Engineering Supplies"],
			faction = "Alliance",
		},
		[86008000] = {
			name = L["Zan Shivsproket"],
			category = "vendors",
			description = L["Speciality Engineer"],
			faction = "Neutral",
		},
		[86007960] = {
			name = L["Smudge Thunderwood"],
			category = "vendors",
			subcategory = "poisonvendor",
			description = L["Poison Vendor"],
			faction = "Horde",
		},
		[40208000] = {
			name = L["Mirvyna Jinglepocket"],
			category = "vendors",
			description = L["Smokywood Pastures"],
			faction = "Neutral",
		},
		[62005860] = {
			name = L["Dillord Copperpinch"],
			category = "vendors",
			description = L["Smokywood Pastures"],
			faction = "Horde",
		},
		[64404020] = {
			name = L["Stone Fury"],
			category = "rares",
			faction = "Neutral",
		},
		[64404880] = {
			name = L["Stone Fury"],
			category = "rares",
			faction = "Neutral",
		},
		[64604100] = {
			name = L["Stone Fury"],
			category = "rares",
			faction = "Neutral",
		},
		[65204300] = {
			name = L["Stone Fury"],
			category = "rares",
			faction = "Neutral",
		},
		[66604720] = {
			name = L["Stone Fury"],
			category = "rares",
			faction = "Neutral",
		},
		[70204640] = {
			name = L["Stone Fury"],
			category = "rares",
			faction = "Neutral",
		},
		[71804640] = {
			name = L["Stone Fury"],
			category = "rares",
			faction = "Neutral",
		},
		[74404600] = {
			name = L["Stone Fury"],
			category = "rares",
			faction = "Neutral",
		},
		[75404680] = {
			name = L["Stone Fury"],
			category = "rares",
			faction = "Neutral",
		},
		[75804620] = {
			name = L["Stone Fury"],
			category = "rares",
			faction = "Neutral",
		},
		[76604600] = {
			name = L["Stone Fury"],
			category = "rares",
			faction = "Neutral",
		},
		[76804680] = {
			name = L["Stone Fury"],
			category = "rares",
			faction = "Neutral",
		},
		[77604840] = {
			name = L["Stone Fury"],
			category = "rares",
			faction = "Neutral",
		},
		[78004640] = {
			name = L["Stone Fury"],
			category = "rares",
			faction = "Neutral",
		},
		[78204460] = {
			name = L["Stone Fury"],
			category = "rares",
			faction = "Neutral",
		},
		[79604640] = {
			name = L["Stone Fury"],
			category = "rares",
			faction = "Neutral",
		},
		[80404060] = {
			name = L["Stone Fury"],
			category = "rares",
			faction = "Neutral",
		},
		[26807380] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[38808320] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[55406500] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[55806880] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[58805880] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[63003760] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[69004620] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[73606560] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[74404680] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[75004520] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[75204620] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[75406460] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[75804660] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[76006520] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[76406340] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[77206500] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[77806160] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[78205960] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[78206480] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[78405920] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[78606500] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[78804520] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[78806300] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[79204440] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[79806040] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[80203820] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[80205800] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[80406100] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[80604680] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[81005360] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[81204440] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[81405320] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[81605040] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[82205140] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[83005440] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[29406080] = {
			name = L["Skhowl"],
			category = "rares",
			faction = "Neutral",
		},
		[30606020] = {
			name = L["Skhowl"],
			category = "rares",
			faction = "Neutral",
		},
		[31405180] = {
			name = L["Skhowl"],
			category = "rares",
			faction = "Neutral",
		},
		[31805200] = {
			name = L["Skhowl"],
			category = "rares",
			faction = "Neutral",
		},
		[33405220] = {
			name = L["Skhowl"],
			category = "rares",
			faction = "Neutral",
		},
		[37003620] = {
			name = L["Skhowl"],
			category = "rares",
			faction = "Neutral",
		},
		[37403700] = {
			name = L["Skhowl"],
			category = "rares",
			faction = "Neutral",
		},
		[42606260] = {
			name = L["Skhowl"],
			category = "rares",
			faction = "Neutral",
		},
		[44406240] = {
			name = L["Skhowl"],
			category = "rares",
			faction = "Neutral",
		},
		[44806260] = {
			name = L["Skhowl"],
			category = "rares",
			faction = "Neutral",
		},
		[52604620] = {
			name = L["Lo'Grosh"],
			category = "rares",
			faction = "Neutral",
		},
		[57004280] = {
			name = L["Gravis Slipknot"],
			category = "rares",
			faction = "Neutral",
		},
		[57204160] = {
			name = L["Gravis Slipknot"],
			category = "rares",
			faction = "Neutral",
		},
		[58004280] = {
			name = L["Gravis Slipknot"],
			category = "rares",
			faction = "Neutral",
		},
		[59204300] = {
			name = L["Gravis Slipknot"],
			category = "rares",
			faction = "Neutral",
		},
		[60004160] = {
			name = L["Gravis Slipknot"],
			category = "rares",
			faction = "Neutral",
		},
		[60004460] = {
			name = L["Gravis Slipknot"],
			category = "rares",
			faction = "Neutral",
		},
		[61204200] = {
			name = L["Gravis Slipknot"],
			category = "rares",
			faction = "Neutral",
		},
		[62204380] = {
			name = L["Gravis Slipknot"],
			category = "rares",
			faction = "Neutral",
		},
		[62604400] = {
			name = L["Gravis Slipknot"],
			category = "rares",
			faction = "Neutral",
		},
		[62804240] = {
			name = L["Gravis Slipknot"],
			category = "rares",
			faction = "Neutral",
		},
		[31408480] = {
			name = L["Araga"],
			category = "rares",
			faction = "Neutral",
		},
		[38208920] = {
			name = L["Araga"],
			category = "rares",
			faction = "Neutral",
		},
		[19205100] = {
			name = L["Cranky Benj"],
			category = "rares",
			faction = "Neutral",
		},
		[30003980] = {
			name = L["Cranky Benj"],
			category = "rares",
			faction = "Neutral",
		},
		[58606860] = {
			name = L["Jimmy the Bleeder"],
			category = "rares",
			faction = "Neutral",
		},
		[58607020] = {
			name = L["Jimmy the Bleeder"],
			category = "rares",
			faction = "Neutral",
		},
		[58607100] = {
			name = L["Jimmy the Bleeder"],
			category = "rares",
			faction = "Neutral",
		},
		[69404680] = {
			name = L["Stone Fury"],
			category = "rares",
			faction = "Neutral",
		},
		[53802980] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[62204880] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[65404400] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[75004720] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[75804820] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[76006500] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[77604480] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[78206080] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[79406180] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[79604260] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[79605240] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[80604380] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[80806080] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[81405180] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[81805480] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[82005780] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[82205340] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[83805340] = {
			name = L["Narillasanz"],
			category = "rares",
			faction = "Neutral",
		},
		[31006000] = {
			name = L["Skhowl"],
			category = "rares",
			faction = "Neutral",
		},
		[36003860] = {
			name = L["Skhowl"],
			category = "rares",
			faction = "Neutral",
		},
		[59004440] = {
			name = L["Gravis Slipknot"],
			category = "rares",
			faction = "Neutral",
		},
		[59604320] = {
			name = L["Gravis Slipknot"],
			category = "rares",
			faction = "Neutral",
		},
		[62204340] = {
			name = L["Gravis Slipknot"],
			category = "rares",
			faction = "Neutral",
		},
		[63604160] = {
			name = L["Gravis Slipknot"],
			category = "rares",
			faction = "Neutral",
		},
		[30208580] = {
			name = L["Araga"],
			category = "rares",
			faction = "Neutral",
		},
	}
	nodes[1430] = {
		[40007500] = {
			name = L["Spirit Healer"],
			category = "spirithealers",
			faction = "Neutral",
		},
	}
	
	CarbMigr = { FLIGHT_DATA = {} }
	
	for mid, n in pairs(nodes) do
		for coords, npc in pairs(n) do
			if npc.category == "flightmasters" then 
				local x = floor(coords / 10000) / 100
				local y = (coords % 10000) / 100
				
				local side = 0
				if npc.faction == "Alliance" then side = 1 end
				if npc.faction == "Horde" then side = 2 end
			
				CarbMigr.FLIGHT_DATA[""..side..","..mid..","..x..","..y..""] = "|"..npc.name..", "..Nx.Map.MapWorldInfo[mid].Name.."|"
			end
		end
	end
end

function Nx:UNIT_NAME_UPDATE (event, arg1, ...)
	Nx.PlayerFnd = true
	
	if _G.TomTom then
		Nx.RealTom = true
		SLASH_CBWAY1 = '/cbway'
		SlashCmdList["CBWAY"] = function (msg, editbox)
			Nx:TTWayCmd(msg)
		end	
	end

	Nx.EmulateTomTom()
end

function Nx:LocaleInit()
	local loc = GetLocale()
	Nx.Locale = loc
end

--------
-- Register events

function Nx:InitEvents()

	local Com = Nx.Com
	local Guide = Nx.Map.Guide
	local AuctionAssist = Nx.AuctionAssist
	local Travel = Nx.Travel
	
	LibStub("AceEvent-3.0"):Embed(Com)
	LibStub("AceEvent-3.0"):Embed(Guide)
	LibStub("AceEvent-3.0"):Embed(AuctionAssist)
	LibStub("AceEvent-3.0"):Embed(Travel)
	
	Nx:RegisterEvent("PLAYER_LOGIN", "OnPlayer_login")
	Nx:RegisterEvent("UPDATE_MOUSEOVER_UNIT", "OnUpdate_mouseover_unit")
	Nx:RegisterEvent("PLAYER_REGEN_DISABLED", "OnPlayer_regen_disabled")
	Nx:RegisterEvent("PLAYER_REGEN_ENABLED", "OnPlayer_regen_enabled")
	Nx:RegisterEvent("UNIT_SPELLCAST_SENT", "OnUnit_spellcast_sent")
	Nx:RegisterEvent("ZONE_CHANGED_NEW_AREA", "OnZone_changed_new_area")
	Nx:RegisterEvent("PLAYER_LEVEL_UP", "OnPlayer_level_up")
	Nx:RegisterEvent("GROUP_ROSTER_UPDATE", "OnParty_members_changed")
	Nx:RegisterEvent("UPDATE_BATTLEFIELD_SCORE", "OnUpdate_battlefield_score")	
	
	Com:RegisterEvent("PLAYER_LEAVING_WORLD", "OnEvent")
	Com:RegisterEvent("FRIENDLIST_UPDATE", "OnFriendguild_update")
	Com:RegisterEvent("GUILD_ROSTER_UPDATE", "OnFriendguild_update")
	--Com:RegisterEvent("SOCIAL_QUEUE_UPDATE", "OnFriendguild_update")
	Com:RegisterEvent("BN_FRIEND_LIST_SIZE_CHANGED", "OnFriendguild_update")
	Com:RegisterEvent("GROUP_ROSTER_UPDATE", "OnFriendguild_update")
	Com:RegisterEvent("CHAT_MSG_CHANNEL_JOIN", "OnChatEvent")
	Com:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE", "OnChatEvent")
	Com:RegisterEvent("CHAT_MSG_CHANNEL_LEAVE", "OnChatEvent")
	Com:RegisterEvent("CHAT_MSG_CHANNEL", "OnChat_msg_channel")
	--Com:RegisterEvent("CHAT_MSG_SYSTEM", "OnChat_msg_channel")
	
	AuctionAssist:RegisterEvent("AUCTION_HOUSE_SHOW", "OnAuction_house_show")
	AuctionAssist:RegisterEvent("AUCTION_HOUSE_CLOSED", "OnAuction_house_closed")
	AuctionAssist:RegisterEvent("AUCTION_ITEM_LIST_UPDATE", "OnAuction_item_list_update")
		
	Guide:RegisterEvent("MERCHANT_SHOW", "OnMerchant_show")
	Guide:RegisterEvent("MERCHANT_UPDATE", "OnMerchant_update")
	Guide:RegisterEvent("GOSSIP_SHOW", "OnGossip_show")
	Guide:RegisterEvent("TRAINER_SHOW", "OnTrainer_show")

	Travel:RegisterEvent("TAXIMAP_OPENED", "OnTaximap_opened")
end

-- Handle frame events
function Nx:NXOnEvent (event, ...)
	local h = self.Events[event]
	if h then
		h (nil, event, ...)
	else
		assert (0)
	end
end

--------
-- Login message

function Nx:OnPlayer_login (event, ...)
	Nx:OnParty_members_changed()	
	Nx.Com:OnEvent (event)
	Nx.InitWins()

	Nx.BlizzChatFrame_DisplayTimePlayed = ChatFrame_DisplayTimePlayed		-- Save func
	ChatFrame_DisplayTimePlayed = function() end

--	RequestTimePlayed()		-- Blizz does not do anymore on login???
	Nx.RequestTime = true;
end

--------

function Nx:OnUpdate_mouseover_unit (event, ...)	
	if Nx.Quest then
		Nx.Quest:TooltipProcess (true)
	end

	local data, guid, id, typ = Nx:UnitDGet ("mouseover")
	if guid then

		local tip = GameTooltip

		if typ == 0 then
			tip:AddLine (format (L["GUID player"] .. " %s", strsub (guid, 6)))

		elseif typ == 3 then
			tip:AddLine (format (L["GUID NPC"] .." %d", id))

			Nx:UnitDTip()

		elseif typ == 4 then
			tip:AddLine (format (L["GUID pet"] .. " %s", strsub (guid, 13)))
		end

		tip:AddLine (format (" %s", guid))
		tip:Show()	-- Adjusts size
	end
end

function Nx:UnitDGet (target)

	if Nx.db.profile.Debug.DebugUnit then

		local guid = UnitGUID (target)
		if guid then

			local id = tonumber (strsub (guid, 7, 10), 16)
			local typ = tonumber (strsub (guid, 5, 5), 16)

			local data = Nx.db.profile.Debug.DBUnit or {}
			local ver = 2

			if (data["Ver"] or 0) < ver then
				data = {}
				data["Ver"] = ver
			end

			Nx.db.profile.Debug.DBUnit = data

			return data, guid, id, typ
		end
	end
end

-- Capture pos of target

function Nx:UnitDCapture()

	local data, guid, id, typ = self:UnitDGet ("target")
	if data and typ == 3 then

		local mid = Nx.Map:GetCurrentMapAreaID()
		local plZX, plZY = Nx.Map.GetPlayerMapPosition ("player")
		if mid and (plZX > 0 or plZY > 0) then

			local s = data[id] or "0~0~~~~"
			local reactA, reactH, _, _, _, tipStr = Nx.Split ("~", s)

			data[id] = format ("%s~%s~%s~%s~0~%s", reactA, reactH, mid, self:PackXY (plZX * 100, plZY * 100), tipStr)

			Nx.prt ("UnitDCap: %s, %s, %s", id, plZX * 10000, plZY * 10000)

		else

			Nx.prt (L["Unit map error"])
		end
	end
end

function Nx:UnitDTip()

	local data, guid, id, typ = self:UnitDGet ("mouseover")
	if data and typ == 3 then

		local midCur = Nx.Map:GetCurrentMapAreaID()
		local plZX, plZY = Nx.Map.GetPlayerMapPosition ("player")
		if midCur and (plZX > 0 or plZY > 0) then

			local react = UnitReaction ("mouseover", "player")

			local s = data[id]

			local reactA, reactH, mid, xy, dist = Nx.Split ("~", s or "0~0~~000000~9")

			reactA = reactA or 0
			reactH = reactH or 0

			local x, y = self:UnpackXY (xy)

			if Nx.PlFactionNum == 0 then
				reactA = react
			else
				reactH = react
			end

			dist = tonumber (dist)

			local dcur = 9
			if CheckInteractDistance ("mouseover", 1) then		-- 28 yards
				dcur = 2
			end
			if CheckInteractDistance ("mouseover", 3) then		-- 9.9 yards
				dcur = 1
			end

			if dcur <= dist then
				dist = dcur
				mid = midCur
				x = plZX * 100
				y = plZY * 100
			end

			local tipStr = ""
			local tip = GameTooltip
			local textName = "GameTooltipTextLeft"

			for n = 1, tip:NumLines() do
				local s = _G[textName .. n]:GetText()
				if s then
					tipStr = tipStr .. s .. "^"
				end
			end

			data[id] = format ("%s~%s~%s~%s~%s~%s", reactA, reactH, mid, self:PackXY (x, y), dist, tipStr)

			if IsControlKeyDown() then
				Nx.prt ("UnitDTip: %s %s, %d, %d (%d)", id, react or "nil", x * 100 + .5, y * 100 + .5, dist)
			end

			if IsShiftKeyDown() and IsControlKeyDown() and (x > 0 or y > 0) then

				local Map = Nx.Map
				local mapId = Map:GetCurrentMapId()
				local m = Map:GetMap (1)

				local tar = m:SetTargetXY (mapId, x, y, "UnitD " .. id)
		  		tar.Radius = 1
			end

		else

			Nx.prt (L["Unit map error"])
		end
	end
end

function Nx:OnPlayer_regen_disabled()
	Nx.Window:UpdateCombat()
end

function Nx:OnPlayer_regen_enabled()
	Nx.Window:UpdateCombat()
end

function Nx:OnUnit_spellcast_sent (event, arg1, arg2, arg3, arg4)	
	if arg1 == "player" then
		local Nx = Nx
		if Nx:IsGathering(arg2) == "Herb Gathering" then
			Nx.GatherTarget = Nx.TooltipLastText

			if Nx.db.profile.Debug.DBGather then
				Nx.prt (L["Gather"] .. ": %s %s", arg2, Nx.GatherTarget or "nil")
			end

			if Nx.GatherTarget then
				Nx.UEvents:AddHerb (Nx.GatherTarget)
				Nx.GatherTarget = nil
			end

		elseif Nx:IsGathering(arg2) == L["Mining"] then
			Nx.GatherTarget = Nx.TooltipLastText

			if Nx.db.profile.Debug.DBGather then
				Nx.prt (L["Gather"] .. ": %s %s", arg2, Nx.GatherTarget)
			end

			if Nx.GatherTarget then
				Nx.UEvents:AddMine (Nx.GatherTarget)
				Nx.GatherTarget = nil
			end
		elseif arg2 == L["Searching for Artifacts"] then
			Nx.UEvents:AddOpen ("Art", arg4)
		elseif arg2 == L["Extract Gas"] then
			Nx.UEvents:AddOpen ("Gas", L["Extract Gas"])
		elseif Nx:IsGathering(arg2) == L["Logging"] then
			Nx.GatherTarget = Nx.TooltipLastText
			if Nx.GatherTarget then
				Nx.UEvents:AddTimber(Nx.GatherTarget)
			end
		elseif arg2 == L["Opening"] or arg2 == L["Opening - No Text"] then
			Nx.GatherTarget = Nx.TooltipLastText

			if arg4 == L["Glowcap"] then
				Nx.UEvents:AddHerb (arg4)

			elseif arg4 == L["Everfrost Chip"] then
				Nx.UEvents:AddOpen ("Everfrost", arg4)

			end
		end
	end
end

function Nx:OnZone_changed_new_area (event)

	Nx.UEvents:AddInfo (L["Entered"])

	Nx.Com:OnEvent (event)
end

function Nx:OnPlayer_level_up (event, arg1)

	Nx.UEvents:AddInfo (format (L["Level"] .. " %d", arg1))

	Nx.Com:OnPlayer_level_up (event, arg1)
end

function Nx.OnParty_members_changed()

	local self = Nx

	local members = {}
	self.GroupMembers = members

	local memberCnt = MAX_PARTY_MEMBERS
	local unitName = "party"

	if IsInRaid() then
		memberCnt = MAX_RAID_MEMBERS
		unitName = "raid"
	end

	self.GroupType = unitName

	for n = 1, memberCnt do

		local unit = unitName .. n
		local name = UnitName (unit)
		if name then
			members[name] = n
		end
	end
	if Nx.Quest then
		Nx.Quest.OnParty_members_changed()
	end
end

function Nx:OnUpdate_battlefield_score (event)

	local plName = UnitName ("player")
	local scores = GetNumBattlefieldScores()
	local cb = Nx.Combat

	local show

	for n = 1, scores do
		local name, kbs, hks, deaths, honor, faction, race, class, classCap, damDone, healDone = GetBattlefieldScore (n)
		if name == plName then

			honor = floor (honor)	--V4 returns weird fractions

			local any = kbs + deaths + hks + honor

			if any > 0 and (cb.KBs ~= kbs or cb.Deaths ~= deaths or cb.HKs ~= hks or cb.Honor ~= honor) then
				cb.KBs = kbs
				cb.Deaths = deaths
				cb.HKs = hks
				cb.Honor = honor

				show = true
			end

			cb.DamDone = damDone
			cb.HealDone = healDone

			break
		end
	end

	if show and Nx.db.profile.Battleground.ShowStats then

		local kbrank = 1

		for n = 1, scores do
			local name, kbs = GetBattlefieldScore (n)
			if name ~= plName then

				if kbs > cb.KBs then
					kbrank = kbrank + 1
				end
			end
		end

		Nx.prt ("%s KB (#%d), %s " .. L["Deaths"] .. ", %s HK, %d " .. L["Bonus"], cb.KBs, kbrank, cb.Deaths, cb.HKs, cb.Honor)
	end

end

--------
-- Generic update

function Nx:NXOnUpdate (elapsed)    
	if InCombatLockdown() and not Nx.Initialized and not Nx.CombatMessage then		
		Nx.prt("You are in combat! Carbonite will resume loading when your safe.")
		Nx.CombatMessage = true
	end
	local Nx = Nx

	if Nx.Loaded and Nx.PlayerFnd and not Nx.Initialized and not InCombatLockdown() then	-- Safety check
		Nx:SetupEverything()
		return
	end
	if not Nx.Loaded or not Nx.PlayerFnd or not Nx.Initialized then
		return
	end
	Nx.Tick = Nx.Tick + 1
	if Nx.LootOn then
		Nx:LootIt()
	end
	
	Nx.Proc:OnUpdate (elapsed)

	-- Tooltip stuff

	if not GameTooltip:IsVisible() then
		Nx.TooltipLastDiffText = nil
	end

	local s = GameTooltipTextLeft1:GetText()
	if s then

		if Nx.Tick % 4 == 1 and GameTooltipTextLeft1:IsVisible() and #s > 5 then
			if Nx.TooltipLastDiffText ~= s or Nx.TooltipLastDiffNumLines ~= GameTooltip:NumLines() then
				if Nx.Quest then
					Nx.Quest:TooltipProcess()
				end
			end
		end
		Nx.TooltipLastText = s
	end

	if Nx.TooltipOwner then
		if not Nx.TooltipOwner:IsVisible() then
			if GameTooltip:IsOwned (Nx.TooltipOwner) then
				GameTooltip:Hide()
			end
			Nx.TooltipOwner = nil
		end
	end

	--

	if self.NetSendPos then

		local t = GetTime()

		if t > self.NetPlyrSendTime then

			local plX, plY = Nx.Map.GetPlayerMapPosition ("player")

			if plX > 0 or plY > 0 then

				local s = format ("Map~%d~%d~%d", plX * 100000000, plY * 100000000, Nx.Map:GetCurrentMapId())
				Nx.prt ("NetSend %s", s)
				Nx.Com:Send ("Z", s)

				self.NetPlyrSendTime = t + 1.5
			end
		end
	end

	local combat = UnitAffectingCombat ("player")
	if Nx.InCombat ~= combat then

		Nx.InCombat = combat
	end

	Nx.Com:OnUpdate (elapsed)
	Nx.Map:MainOnUpdate (elapsed)

	if Nx.Quest then
		Nx.Quest:OnUpdate (elapsed)
	end

	if Nx.Tick % 11 == 0 then
		Nx:RecordCharacter()
		if Nx.Warehouse then
			Nx.Warehouse:RecordCharacter()
		end
	end
	if Nx.WhatsNewUnread() then
		if Nx.Tick % 50 == 0 then
			if Nx.GlowOn then
				NXMiniMapBut:SetNormalTexture("Interface\\AddOns\\Carbonite\\Gfx\\MMBut")
				Nx.GlowOn = false
			else
				NXMiniMapBut:SetNormalTexture("Interface\\AddOns\\Carbonite\\Gfx\\MMButFilled")
				Nx.GlowOn = true
			end
		end
	end
	if not Nx.Whatsnew.HasWhatsNew then -- Adding it here to be at bottom of menu always.
		Nx.Whatsnew.HasWhatsNew = true
		Nx.NXMiniMapBut.Menu:AddItem(0,"")
		local function func ()
			Nx.Whatsnew:ToggleShow()
		end
		Nx.NXMiniMapBut.Menu:AddItem(0, L["Whats New!"], func, Nx.NXMiniMapBut)			
	end

end

function Nx:WhatsNewUnread()
	local checkread
	for a,b in pairs(Nx.Whatsnew.Categories) do
		for c,d in pairs(Nx.Whatsnew[b]) do
			if Nx.db.profile.Whatsnew.lastreadtime < c then
				return true
			end
		end
	end
	return false
end

function Nx.Whatsnew:ToggleShow()

	if not self.Win then
		self:Create()
	end

	self.Win:Show (not self.Win:IsShown())

	if self.Win:IsShown() then
		self:Update()
	end
end

function Nx.Whatsnew:Create()	
	local win = Nx.Window:Create ("NxWhatsNew", nil, nil, nil, 1)
	self.Win = win
	self.SelectedLine = 1
	win.Frm.NxInst = self
	win:CreateButtons (true, true)
	win:InitLayoutData (nil, -.25, -.15, -.5, -.6)
	win.Frm:SetToplevel (true)	
	win:Show (false)	
	win.Frm:SetScript ("OnHide",self.Recordtime)
	tinsert (UISpecialFrames, win.Frm:GetName())
	Nx.List:SetCreateFont ("Font.Medium", 16)
	local list = Nx.List:Create (false, 0, 0, 1, 1, win.Frm)
	self.List = list
	list:SetUser (self, self.OnListEvent)
	list:SetLineHeight (4)
	list:ColumnAdd ("", 1, 24)
	list:ColumnAdd ("Date", 2, 200)	
	list:SetUser (self, self.OnListEvent)
	win:Attach (list.Frm, 0, .2, 0, 1)
	local list = Nx.List:Create (false, 0, 0, 1, 1, win.Frm)
	self.WhatsNewList = list	
	list:ColumnAdd ("", 1, 500)
	win:Attach (list.Frm, .2, 1, 0, 1)	
	local bw, bh = win:GetBorderSize()
	local pos = 150
	for a,b in pairs(Nx.Whatsnew.Categories) do
		local function func()
			Nx.Whatsnew:Cat_button(a)
		end
		local but = Nx.Button:Create (win.Frm, "Txt64", b, nil, pos, -bh, "TOPLEFT", string.len(b)*10, 20, func, self)
		pos = pos + but.Frm:GetWidth()
	end
	self:Update()
	self.List:Select (0)
	self.List:FullUpdate()	
end

function Nx.Whatsnew:Recordtime()
	Nx.db.profile.Whatsnew.lastreadtime = time()
	NXMiniMapBut:SetNormalTexture("Interface\\AddOns\\Carbonite\\Gfx\\MMBut")	
end

function Nx.Whatsnew:Cat_button(num)
	Nx.Whatsnew.WhichCat = num
	Nx.Whatsnew.SelectedLine = 1
	Nx.Whatsnew:Update()
end

function Nx.Whatsnew:OnListEvent (eventName, sel, val2, click)
	local data = self.List:ItemGetData (sel) or 0
	local id = data % 1000
	self.SelectedLine = id	
	if eventName == "select" then
		self:Update()
	end
end

function Nx.Whatsnew:Update()
	self.Win:SetTitle (L["Carbonite What's New"])
	local list = self.List
	list:Empty()
	local cnt = 1
	local display = {}
	local cat = Nx.Whatsnew.Categories[Nx.Whatsnew.WhichCat]
	for a,b in pairs(Nx.Whatsnew[cat]) do
		list:ItemAdd(cnt)
		list:ItemSet(2, date("%m/%d/%y",a))
		if cnt == self.SelectedLine then			
			display = b
		end
		cnt = cnt + 1
	end
	list:Update()
	list = self.WhatsNewList
	list:Empty()
	cnt = 1		
	for a,b in pairs(display) do	
		list:ItemAdd(cnt)
		list:ItemSet(1, b)
		cnt = cnt + 1
	end
	list:Update()
end

--------
-- Loot vendor Test

function Nx:LootIt()

	local b = _G["GossipTitleButton1"]

	if b:IsVisible() then
		b:Click()
	end
end

--------
-- Show a generic message with optional function callback

function Nx:ShowMessage (msg, func1Txt, func1, func2Txt, func2)

	local pop = StaticPopupDialogs["NxMsg"]

	if not pop then

		pop = {
			["whileDead"] = 1,
			["hideOnEscape"] = 1,
			["timeout"] = 0,
		}
		StaticPopupDialogs["NxMsg"] = pop
	end

	pop["text"] = msg
	pop["button1"] = func1Txt
	pop["OnAccept"] = func1
	pop["button2"] = func2Txt
	pop["OnCancel"] = func2
	
	pop["OnShow"] = function (this) 
		this:SetFrameStrata("FULLSCREEN_DIALOG")
		this:SetFrameLevel(100)
	end
	
	StaticPopup_Show ("NxMsg")
end

--------
-- Show a generic edit box with optional function callback

function Nx:ShowEditBox (msg, val, userData, funcAccept, funcCancel)

--	Nx.prt ("ShowEditBox")

	local pop = StaticPopupDialogs["NxEdit"]

	if not pop then

		pop = {
			["whileDead"] = 1,
			["hideOnEscape"] = 1,
			["timeout"] = 0,
			["exclusive"] = 1,
			["hasEditBox"] = 1,
		}
		StaticPopupDialogs["NxEdit"] = pop
	end

	pop["maxLetters"] = 110
	pop["text"] = msg

	Nx.ShowEditBoxVal = tostring (val)
	Nx.ShowEditBoxUData = userData
	Nx.ShowEditBoxFunc = funcAccept

	pop["OnAccept"] = function (this)
		if Nx.ShowEditBoxFunc then
			Nx.ShowEditBoxFunc (_G[this:GetName().."EditBox"]:GetText(), Nx.ShowEditBoxUData)
		end
	end

	pop["EditBoxOnEnterPressed"] = function (this)
		if Nx.ShowEditBoxFunc then
			Nx.ShowEditBoxFunc (_G[this:GetParent():GetName().."EditBox"]:GetText(), Nx.ShowEditBoxUData)
		end
		this:GetParent():Hide()
	end

	pop["EditBoxOnEscapePressed"] = function (this)
		this:GetParent():Hide()
	end

	pop["OnShow"] = function (this)
		this:SetFrameStrata("FULLSCREEN_DIALOG")
		this:SetFrameLevel(100)
		
		ChatEdit_FocusActiveWindow()
		local eb = _G[this:GetName().."EditBox"]
		eb:SetFocus()
		eb:SetText (Nx.ShowEditBoxVal)
		eb:HighlightText()
	end

	pop["OnHide"] = function (this)
		_G[this:GetName().."EditBox"]:SetText ("")
	end

	pop["button1"] = ACCEPT
	pop["button2"] = CANCEL
	pop["OnCancel"] = funcCancel

	StaticPopup_Show ("NxEdit")
end

--------
-- Show a trial message

function Nx:ShowMessageTrial()
end

--------
-- Find active chat frame edit box. Added for patch 3.35 because there is one for each possible chat window now
-- Was called ChatFrameEditBox. Now ChatFrame1EditBox to ChatFrame10EditBox

function Nx:FindActiveChatFrameEditBox()
	return ChatEdit_GetActiveWindow()
end

--------
-- Get time in seconds * 100. Adds fake hundreths

function Nx:Time()

	local tm = time()

	if tm > self.TimeLast then
		self.TimeFrac = 0
	else
		self.TimeFrac = self.TimeFrac + 1
	end

	self.TimeLast = tm

	return tm * 100 + self.TimeFrac
end

function Nx:UnitIsPlusMob (target)
	local c = UnitClassification (target)
	return c == "elite" or c == "rareelite" or c == "worldboss"
end

--------------------------------------------------------------------------------
-- Global Data Management

-- Gather format {}
--  Herb [map id] = { [#] = { Id = #, Cnt = times gathered, X, Y } }
--  Mine ^

function Nx:InitGlobal()
	if Nx.db.profile.Version.OptionsVersion < Nx.VERSIONDATA then

		if Nx.db.profile.Version.OptionsVersion > 0 then
			Nx.prt (L["Reset old data"] .. " %f", Nx.db.profile.Version.OptionsVersion)
		end

		Nx.db:ResetDB("Default")
		Nx.db.profile.Version.OptionsVersion = Nx.VERSIONDATA
		Nx.db.global.Characters = {}		-- Indexed by "Server.Name"
	end

	if not Nx.db.profile.Version.NXVer1 then
		Nx.db.profile.Version.NXVer1 = Nx.VERSION
	end
	Nx:InitCharacter()

	--

--	local unitName = Nx.DemungeStr ("TnjrManc")	-- UnitName
--	Nx.PlayerName = _G[unitName] (Nx.DemungeStr ("olbwdr"))		-- player

	-- Global options

	local opts = Nx.db.profile

	if not opts or opts.Version.OptionsVersion < Nx.VERSIONGOPTS then

		if opts and opts.Version.OptionsVersion < Nx.VERSIONGOPTS then
			Nx.prt (L["Reset old global options"] .. " %f", opts.Version.OptionsVersion)
			Nx:ShowMessage (L["Options have been reset for the new version."] .. "\n" .. L["Privacy or other settings may have changed."], "OK")
		end

		opts = {}
		Nx.db:ResetDB("Default")
		Nx.db.profile.Version.OptionsVersion = Nx.VERSIONGOPTS

--		Nx.Opts:Reset()
	end

	-- Clean old junk

--	opts.NXCleaned = nil

	if not opts.NXCleaned then

		opts.NXCleaned = true

		local keep = {
			["Characters"] = 1,
			["NXCap"] = 1,
			["NXFav"] = 1,
			["NXGather"] = 1,
			["NXGOpts"] = 1,
			["NXHUDOpts"] = 1,
			["NXInfo"] = 1,
			["NXQOpts"] = 1,
			["NXSocial"] = 1,
			["NXTravel"] = 1,
			["NXVendorV"] = 1,
			["NXVendorVVersion"] = 1,
			["NXVer1"] = 1,
			["NXVerT"] = 1,
			["NXWare"] = 1,
			["Version"] = 1,
		}

		local cnt = 0
		if cnt > 0 then
			Nx.prt (L["Cleaned"] .. " %d " .. L["items"], cnt)
		end
	end

	-- HUD options

	local opts = Nx.db.profile.HUDOpts

	if not opts or opts.Version < Nx.VERSIONHUDOPTS then

		if opts then
			Nx.prt (L["Reset old HUD options"] .. " %f", opts.Version)
		end

		opts = {}
		Nx.db.profile.HUDOpts = opts
		opts.Version = Nx.VERSIONHUDOPTS

--		Nx.HUD:OptsReset()
	end

	-- Travel data

	local tr = Nx.db.char.Travel

	if not tr or tr.Version < Nx.VERSIONTRAVEL then

		if tr then
			Nx.prt (L["Reset old travel data"] .. " %f", tr.Version)
		end

		tr = {}
		Nx.db.char.Travel = tr
		tr.Version = Nx.VERSIONTRAVEL
	end

	tr["TaxiTime"] = tr["TaxiTime"] or {}

	local cd = Nx.db.char.Travel.Taxi

	if not cd or cd.Version < Nx.VERSIONCharData then
		cd = {}
		Nx.db.char.Travel.Taxi = cd
		cd.Version = Nx.VERSIONCharData
		cd["Taxi"] = {}		-- Taxi nodes we have
	end

	--

	-- Gather data

	local gath = Nx.db.profile.GatherData

	if not gath or gath.Version < Nx.VERSIONGATHER then

		if gath and gath.Version < 0 then
			Nx.DoGatherUpgrade = gath.Version

		else
			if gath then
				Nx.prt (L["Reset old gather data"] .. " %f", gath.Version)
			end

			gath = {}
			Nx.db.profile.GatherData = gath
			gath.NXHerb = {}
			gath.NXMine = {}
			gath.NXTimber = {}
		end

		gath.Version = Nx.VERSIONGATHER
	end

	gath["Misc"] = gath["Misc"] or {}
--	gath.NXGas = gath.NXGas or {}

	-- Capture data

	local cap = Nx.db.global.Capture		-- Keep NX

--	cap = nil		-- Nuke test

	if not cap or cap.Version < Nx.VERSIONCAP then

--		if cap then
--			Nx.prt ("Reset old cap %f", cap.Version)
--		end

		cap = {}
		Nx.db.global.Capture = cap
		cap.Version = Nx.VERSIONCAP
		cap["Q"] = {}

--		Nx.HUD:OptsReset()
	end

	cap["NPC"] = cap["NPC"] or {}
end

--------
-- Get generic named data (global, character, database)

function Nx:GetData (name, ch)

	ch = ch or Nx.CurCharacter

	if name == "Events" then
		return ch.E

	elseif name == "List" then
		return ch["L"]

	elseif name == "Quests" then
		return ch.Q

	elseif name == "Win" then
		return Nx.db.profile.WinSettings

	elseif name == "Herb" then
		return Nx.db.profile.GatherData.NXHerb
	elseif name == "Timber" then
		return Nx.db.profile.GatherData.NXTimber
	elseif name == "Mine" then
		return Nx.db.profile.GatherData.NXMine

	end
end

--------
-- Copy character data

function Nx:CopyCharacterData (srcName, dstName)

	if not srcName then

		-- Export me to everyone

		local sch = Nx.CurCharacter

		for rc, dch in pairs (Nx.db.global.Characters) do

			if dch ~= sch then
				dch["L"] = sch["L"]
				dch["TBar"] = sch["TBar"]
			end
		end
	else

		local sch = Nx:FindCharacter (srcName)
		local dch = Nx:FindCharacter (dstName)

		if not sch or not dch then
			Nx.prt (L["Missing character data!"])
			return
		end

		-- Change references. Save will make copy
		dch["L"] = sch["L"]
		dch["TBar"] = sch["TBar"]
	end

	return true
end

--------
-- Delete character data

function Nx:DeleteCharacterData (srcName)

	self:DeleteCharacter (srcName)
	self:CalcRealmChars()
	if Nx.Warehouse then
		self.Warehouse:Update()
	end
end

--------
-- Get data

function Nx:GetDataToolBar()
	return Nx.CurCharacter["TBar"]
end

--------
-- Get HUD options

function Nx:GetHUDOpts()
	return Nx.db.profile.HUDOpts
end

--------
-- Get Captured data

function Nx:GetCap()
	return Nx.db.global.Capture
end

function Nx:CaptureFind (t, key)

	assert (type (t) == "table" and key)

	local d = t[key] or {}
	t[key] = d
	return d
end

--------
-- Make packed XY string
-- (xy 0-100)

function Nx:PackXY (x, y)

	x = max (0, min (100, x))
	y = max (0, min (100, y))
	return format ("%03x%03x", x * 40.9 + .5, y * 40.9 + .5)		-- Round off
end

--------

function Nx:UnpackXY (xy)

	local x = tonumber (strsub (xy, 1, 3), 16) / 40.9
	local y = tonumber (strsub (xy, 4, 6), 16) / 40.9
	return x, y
end

--------------------------------------------------------------------------------
-- Character Data Management

-- Event format OLD! Now a packed string!
--  Type table [Info, Kill, Death, Mine, Herb]
--   All have: Name, Time, Map, X, Y
--   T added by GetAllEvents for type ("I" "K" "D" "M" "H")
--   Kill: Level

-- Quest format
--  table index [quest id]
--  string "STime"
--   S (status char): C completed, c not completed, W watched
--   Time is number from time()

function Nx:InitCharacter()
	local chars = Nx.db.global.Characters
	local fullName = self:GetRealmCharName()
	local ch = chars[fullName]

	if not ch or ch.Version < Nx.VERSIONCHAR then
		-- Add a new character
		ch = {}
		chars[fullName] = ch

		ch.Version = Nx.VERSIONCHAR

		ch.E = {}	-- Events		
	end

	Nx.CurCharacter = ch

	ch["Opts"] = ch["Opts"] or {}		-- Character options

	ch["L"] = ch["L"] or {}			-- List

	if not ch["TBar"] then
		ch["TBar"] = {}			-- Tool Bar layouts
	end
	self:DeleteOldEvents()
	ch.NXLoggedOnNum = ch.NXLoggedOnNum or 0 + 1
	--
	self:CalcRealmChars()
end


--------
--

function Nx:GetRealmCharName()
	return GetRealmName() .. "." .. UnitName ("player")
end

--------
--

function Nx:CalcRealmChars()
	local chars = Nx.db.global.Characters
	local realmName = GetRealmName()
	local fullName = realmName .. "." .. UnitName ("player")
	local t = {}
	for rc, v in pairs (chars) do
		if v ~= Nx.CurCharacter then
			local rname = Nx.Split (".", rc)
			if rname == realmName then
				tinsert (t, rc)
			end
		end
	end
	local connectedrealms = GetAutoCompleteRealms()
	if connectedrealms then
		for i=1,#connectedrealms do
			for rc, v in pairs (chars) do
				if v ~= Nx.CurCharacter then
					local rname = Nx.Split (".", rc)
					if rname == connectedrealms[i] and connectedrealms[i] ~= realmName then
						tinsert (t, rc)
					end
				end
			end
		end
	end
	sort (t)			-- Alphabetical
	tinsert (t, 1, fullName)	-- Put me at top
	self.RealmChars = t
	-- Fix char data
	for cnum, rc in ipairs (self.RealmChars) do
		local ch = chars[rc]
		if ch then
			if ch["XP"] then
				ch["XPMax"] = ch["XPMax"] or 1
				ch["XPRest"] = ch["XPRest"] or 0
				ch["LXP"] = ch["LXP"] or 0
				ch["LXPMax"] = ch["LXPMax"] or 1
				ch["LXPRest"] = ch["LXPRest"] or 0
			end
			ch["TimePlayed"] = ch["TimePlayed"] or 0
		end
	end
end

--------
-- Find character data for a named character on current realm or all realms if "realm.name"

function Nx:FindCharacter (name)

	for cnum, rc in ipairs (Nx.RealmChars) do

		local ch = Nx.db.global.Characters[rc]
		if ch then

			local rname, cname = Nx.Split (".", rc)
			if cname == name then
				return ch
			end
		end
	end

	return Nx.db.global.Characters[name]
end

--------
-- Delete character data for a named character on current realm or all realms if "realm.name"

function Nx:DeleteCharacter (name)

	for cnum, rc in ipairs (Nx.RealmChars) do

		local ch = Nx.db.global.Characters[rc]
		if ch then

			local rname, cname = Nx.Split (".", rc)
			if cname == name then
				Nx.db.global.Characters[rc] = nil
				return
			end
		end
	end

	Nx.db.global.Characters[name] = nil
end

--------

function Nx:GetUnitClass()
	local _, cls = UnitClass ("player")
	cls = gsub (Nx.Util_CapStr (cls), L["Deathknight"], L["Death Knight"])
	return cls
end

--------
-- Record logged in state

function Nx:RecordCharacter()
	local ch = self.CurCharacter
	ch["Level"] = UnitLevel ("player")
	ch["Class"] = Nx:GetUnitClass()
end

function Nx:DeleteOldEvents()

	for rc, ch in pairs (Nx.db.global.Characters) do
		if not ch.E or ch.E["Info"] then		-- Missing or has an old table? (User had missing table)
			ch.E = {}
		end

		self:DeleteOldEvent (ch.E, 60)
	end
end

function Nx:DeleteOldEvent (ev, maxE)
	if #ev > maxE then

		for n = 1, #ev - maxE do
			tremove (ev, 1)
		end
	end
end

--------
-- Add event
-- (event) 1 letter name: I,K,D,H,M
-- (data) is optional string

function Nx:AddEvent (event, name, time, mapId, x, y, data)

	local ev = Nx.CurCharacter.E

--[[
	local i = #ev + 1

	local item = {}

	item.NXName = name
	item.NXTime = time
	item.NXMapId = mapId
	item.NXX = x
	item.NXY = y
--]]

	local s = Nx:PackXY (x, y)
	name = gsub (name, "^", "")

	s = format ("%s^%.0f^%d^%s^%s", event, time, mapId or 0, s, name)

	if data then
		s = s .. "^" .. data
	end

	tinsert (ev, s)
end

--------

--function Nx:GetEventType (evStr)
--	return strsub (evStr, 1, 1)
--end

--------

function Nx:GetEventMapId (evStr)

	local _, _, map = Nx.Split ("^", evStr)

	return tonumber (map) or 0
end

--------

function Nx:UnpackEvent (evStr)
	local typ, tm, map, xy, text, data = Nx.Split ("^", evStr)
	tm = tonumber (tm)
	map = tonumber (map) or 0
	local x, y = Nx:UnpackXY (xy)
	return typ, tm, map, x, y, text, data
end

--------

function Nx:AddInfoEvent (name, time, mapId, x, y)
	self:AddEvent ("I", name, time, mapId, x, y)
end

function Nx:AddDeathEvent (name, time, mapId, x, y)
	self:AddEvent ("D", name, time, mapId, x, y)
end

function Nx:AddKillEvent (name, time, mapId, x, y)

	local ev = self.CurCharacter.E

	local kills = 1

	for k, item in ipairs (ev) do

		local typ, tm, mapId, x, y, text = self:UnpackEvent (item)

		if typ == "K" and text == name then
			kills = kills + 1
		end
	end

	self:AddEvent ("K", name, time, mapId, x, y, format ("%d", kills))
end

function Nx:AddHerbEvent (name, time, mapId, x, y)
	self:AddEvent ("H", name, time, mapId, x, y)
end

function Nx:AddTimberEvent(name, time, mapId, x, y)
	self:AddEvent ("T", name, time, mapId, x, y)
end

function Nx:AddMineEvent (name, time, mapId, x, y)
	self:AddEvent ("M", name, time, mapId, x, y)
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Title

function Nx.Title:Init()

	local f = CreateFrame ("Frame", nil, UIParent)
	f.NxInst = self
	self.Frm = f

	f:SetFrameStrata ("HIGH")

	f:SetWidth (400)
	f:SetHeight (192)

	local bk = {
		["bgFile"] = "Interface\\Buttons\\White8x8",
		["edgeFile"] = "Interface\\DialogFrame\\UI-DialogBox-Border",
		["tile"] = true,
		["tileSize"] = 16,
		["edgeSize"] = 16,
		["insets"] = { ["left"] = 2, ["right"] = 2, ["top"] = 2, ["bottom"] = 2 }
	}

	f:SetBackdrop (bk)
	f:SetBackdropColor (0, 0, .1, 1)

	local lf = CreateFrame ("Frame", nil, f)

	lf:SetWidth (256)
	lf:SetHeight (128)

	lf:SetPoint ("CENTER", 0, 0)

	local t = lf:CreateTexture()
	t:SetTexture (Nx.Logo)
--	t:SetVertexColor (1, 1, 1, 1)
	t:SetAllPoints (lf)
	lf.texture = t

	for n = 1, 2 do
		local fstr = f:CreateFontString()
		self["NXFStr"..n] = fstr
		fstr:SetFontObject ("GameFontNormal")
		fstr:SetJustifyH ("CENTER")
		fstr:SetPoint ("TOPLEFT", 0, -158 - (n - 1) * 14)
		fstr:SetWidth (400)
		fstr:Show()
	end

	local str

	if Nx.VERMINOR > 0 then
		str = NXTITLEFULL .. " |cffe0e0ff" .. L["Version"] .. " %d.%d Build %s"
	else
		str = NXTITLEFULL .. " |cffe0e0ff" .. L["Version"] .. " %d.%d Build %s"
	end

	str = format (str, Nx.VERMAJOR,Nx.VERMINOR*10, Nx.BUILD)

	self.NXFStr1:SetText (str)
	self.NXFStr2:SetText ("|cffe0e0ff" .. L["Maintained by"] .. " The community.")

	Nx.Proc:New (self, self.TickWait, 40)

--	f:Show()
end

function Nx.Title:TickWait (proc)

	Nx.Map:StartupZoom()
	Nx.Proc:SetFunc (proc, self.TickWait2)
	return 30
end

function Nx.Title:TickWait2 (proc)
	self.X = 0
	self.Y = GetScreenHeight() * .4
	self.XV = 0
	self.YV = 0
	self.Scale = .8
	self.ScaleTarget = .8
	self.Alpha = 0
	self.AlphaTarget = 1

--	Nx.prt ("Y %s", self.Y)

	if Nx.db.profile.General.TitleSoundOn then
		PlaySound(SOUNDKIT.READY_CHECK);
	end

	Nx.Proc:SetFunc (proc, self.Tick)
end

function Nx.Title:Tick()

	local this = self.Frm

--PAIDS!
	if not Nx.db.profile.General.TitleOff then
		this:Hide()
	end
--PAIDE!

	self.X = self.X + self.XV
	self.Y = self.Y + self.YV

	self.Scale = Nx.Util_StepValue (self.Scale, self.ScaleTarget, .8 / 60)

	this:SetPoint ("CENTER", self.X / self.Scale, self.Y / self.Scale)
	this:SetScale (self.Scale)

--	Nx.prt ("Title %f %f", elapsed, self.Alpha)

	self.Alpha = Nx.Util_StepValue (self.Alpha, self.AlphaTarget, .8 / 60)
	this:SetAlpha (self.Alpha)

	if self.Alpha == 1 then

		local sw = GetScreenWidth() / 2
		local sh = GetScreenHeight() / 2
		self.XV = (sw * .95 - self.X) / 80
		self.YV = (sh * .95 - self.Y) / 80

		self.ScaleTarget = .03
		self.AlphaTarget = 0

		return 1 * 60
	end

	if self.Alpha == 0 then

		this:Hide()
		return -1	-- Die
	end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Auction

--PAIDS!

function Nx.AuctionAssist.OnAuction_house_show()

--	Nx.prt ("OnAUCTION_HOUSE_SHOW")

	if IsAddOnLoaded ("Blizzard_AuctionUI") then
		hooksecurefunc ("AuctionFrameBrowse_Update", Nx.AuctionAssist.AuctionFrameBrowse_Update)
		Nx.AuctionAssist:Create()
	end
end

function Nx.AuctionAssist.OnAuction_house_closed()

--	Nx.prt ("OnAUCTION_HOUSE_CLOSED")

	local self = Nx.AuctionAssist
	if self.Win then
		self.Win:Show (false)
		self.ItemList:Empty()
	end
end

function Nx.AuctionAssist.OnAuction_item_list_update()
--	Nx.prt ("OnAUCTION_ITEM_LIST_UPDATE")
	Nx.AuctionAssist:Update()
end

--------
-- Create favorites window

function Nx.AuctionAssist:Create()
end

--------
-- On list events

function Nx.AuctionAssist:OnListEvent (eventName, sel, val2, click)

--	Nx.prt ("Guide list event "..eventName)

	local name = self.List:ItemGetData (sel)

	Nx.prt ("%s", name)

	BrowseName:SetText (name)
	AuctionFrameBrowse_Search()
end

function Nx.AuctionAssist:Update()

end

--------

function Nx.AuctionAssist.AuctionFrameBrowse_Update()

	if not Nx.AuctionShowBOPer then
		return
	end

--	Nx.prt ("Auction")

	local low = 99999999
	local lowName
	local lowIName

	local numBatchAuctions, totalAuctions = GetNumAuctionItems ("list")
	local offset = FauxScrollFrame_GetOffset (BrowseScrollFrame)
	local last = offset + NUM_BROWSE_TO_DISPLAY

--	Nx.prt ("Auction off %d %d %d", offset, numBatchAuctions, totalAuctions)

	for n = 1, NUM_AUCTION_ITEMS_PER_PAGE do

		local name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner = GetAuctionItemInfo ("list", n)

--		Nx.prt ("Auction #%d %d %d", n, buyoutPrice, count)

		local index = n + NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameBrowse["page"]

		if index > numBatchAuctions + NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameBrowse["page"] then
			break
		end

		if bidAmount == 0 then
			requiredBid = minBid
		else
			requiredBid = bidAmount + minIncrement
		end

		if requiredBid >= MAXIMUM_BID_PRICE then
			buyoutPrice = requiredBid
		end

		if buyoutPrice > 0 then

			local price1 = floor (buyoutPrice / count)

			if n > offset and n <= last then

				local buttonName = "BrowseButton" .. (n - offset)
				local itemName = _G[buttonName .. "Name"]

				if itemName then

					if price1 < low then
						low = price1
						lowName = name
						lowIName = itemName
					end

--					Nx.prtVar ("name", buttonName)

					if count > 1 then

						itemName:SetText (format ("%s *", name))

						local color = ITEM_QUALITY_COLORS[quality]
						itemName:SetVertexColor (color.r, color.g, color.b)

						local bf = _G[buttonName.."BuyoutFrameMoney"]
						if bf then
							MoneyFrame_Update (bf:GetName(), price1)
						end
					end
				end

			elseif price1 < low then
				low = price1
				lowName = nil
			end
		end
	end

	if lowName then
		lowIName:SetText (format ("%s * low", lowName))
	end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- User events recording and list

function Nx.UEvents:Init()

--	self.Sorted = {}
end

------
-- Add info to list

function Nx.UEvents:AddInfo (name)

	local mapId, x, y = self:GetPlyrPos()

	Nx:AddInfoEvent (name, Nx:Time(), mapId, x, y)

	self:UpdateAll()

	return mapId
end

------
-- Add player death to list

function Nx.UEvents:AddDeath (name)

	local mapId, x, y = self:GetPlyrPos()

	Nx:AddDeathEvent (name, Nx:Time(), mapId, x, y)

	self:UpdateAll()

--	Nx:SendComm (2, "Death "..name)

	if Nx.Map:IsBattleGroundMap (mapId) then
--		Nx.prt ("Req D")
		RequestBattlefieldScoreData()
	end
end

------
-- Add kill to list

function Nx.UEvents:AddKill (name)

	local mapId, x, y = self:GetPlyrPos()

	Nx:AddKillEvent (name, Nx:Time(), mapId, x, y)

	self:UpdateAll()

--	Nx:SendComm (2, "Killed "..name)
end

------
-- Add honor info to list

function Nx.UEvents:AddHonor (name)

	local mapId = self:AddInfo (name)

	if Nx.Map:IsBattleGroundMap (mapId) then
--		Nx.prt ("Req H")
		RequestBattlefieldScoreData()
	end
end

------
-- Add herb to list

function Nx.UEvents:AddHerb (name)

	local mapId, x, y, level = self:GetPlyrPos()
	mapId = Nx.Map:GetCurrentMapAreaID()
	if Nx.db.profile.Guide.GatherEnabled then
		local id = Nx:HerbNameToId (name)
		if id then
			Nx:AddHerbEvent (name, Nx:Time(), mapId, x, y)
			Nx:GatherHerb (id, mapId, x, y, level)
		end
		self:UpdateAll (true)
	end
end


function Nx.UEvents:AddTimber(name)
	local mapId, x, y, level = self:GetPlyrPos()
	local size = false
	if Nx.db.profile.Guide.GatherEnabled then		
		if name == L["Small Timber"] then
			size = 1
		elseif name == L["Timber"] then
			size = 2
		elseif name == L["Large Timber"] then
			size = 3
		end
		if size then
			Nx.prt(size)
			Nx:AddTimberEvent (name, Nx:Time(), mapId, x, y)
			Nx:GatherTimber (size, mapId, x, y, level)
		end
		self:UpdateAll (true)
	end
end
------
-- Add mine to list

function Nx.UEvents:AddMine (name)	
	local mapId, x, y, level = self:GetPlyrPos()
	mapId = Nx.Map:GetCurrentMapAreaID()
	if Nx.db.profile.Guide.GatherEnabled then
		local id = Nx:MineNameToId (name)
		if id then
			Nx:AddMineEvent (name, Nx:Time(), mapId, x, y)
			Nx:GatherMine (id, mapId, x, y, level)
		end
		self:UpdateAll (true)
	end
end

------
-- Add open to list

function Nx.UEvents:AddOpen (typ, name)

	local mapId = self:AddInfo (name)
	if Nx.db.profile.Guide.GatherEnabled then
		local mapId, x, y, level = self:GetPlyrPos()
		mapId = Nx.Map:GetCurrentMapAreaID()
		Nx:Gather ("Misc", typ, mapId, x, y, level)
		self:UpdateAll()
	end
end

--------
-- Get player map pos

function Nx.UEvents:GetPlyrPos()
	local mapId = Nx.Map:GetRealMapId()
	local map = Nx.Map:GetMap (1)	
	return mapId, map.PlyrRZX, map.PlyrRZY, Nx.Map.DungeonLevel
end

--------

function Nx.UEvents:UpdateAll (upGuide)

	self:Sort()
	self:UpdateMap (upGuide)
	self.List:Update()
end

--------
-- Sort compare

function Nx.UEvents.SortCmp (v1, v2)

--	prtD ("Sort "..v1.Time.." "..v2.Time)

	local _, tm1 = Nx.Split ("^", v1)
	local _, tm2 = Nx.Split ("^", v2)

	return tonumber (tm1) < tonumber (tm2)
end

--------

function Nx.UEvents:Sort()

--	wipe (self.Sorted)

--	Nx:AddAllEvents (self.Sorted)

--	sort (self.Sorted, self.SortCmp)

	sort (Nx.CurCharacter.E, self.SortCmp)		-- Should already be sorted, but whatever
end

--------
-- Open and init or toggle user events list

function Nx.UEvents.List:Open()

	local UEvents = Nx.UEvents

	local win = self.Win

	if win then
		if win:IsShown() then
			win:Show (false)
		else
			win:Show()
		end
		return
	end

	-- Create Window

	local win = Nx.Window:Create ("NxEventsList", nil, nil, nil, nil, nil, true)
	self.Win = win

	win:CreateButtons (true)

	win:InitLayoutData (nil, -.75, -.6, -.25, -.1)

	local list = Nx.List:Create ("Events", 2, -2, 100, 12 * 3, win.Frm)
	self.List = list
	list:ColumnAdd (L["Time"], 1, 70)
	list:ColumnAdd (L["Event"], 2, 140)
	list:ColumnAdd ("#", 3, 30, "CENTER")
	list:ColumnAdd (L["Position"], 4, 500)

	win:Attach (list.Frm, 0, 1, 0, 1)

	UEvents:UpdateAll()
end

------
function Nx.UEvents.List:Update()

	local Nx = Nx
	local UEvents = Nx.UEvents

	if not self.Win then
		return
	end

	local sorted = Nx.CurCharacter.E

	self.Win:SetTitle (format (L["Events"] .. ": %d", #sorted))

	local list = self.List
	local isLast = list:IsShowLast()
	list:Empty()

	for k, item in ipairs (sorted) do

		local typ, tm, mapId, x, y, text, data = Nx:UnpackEvent (item)

		list:ItemAdd()
		list:ItemSet (1, date ("%d %H:%M:%S", tm / 100))

		local eStr = text

		if typ == "D" then

			eStr = "|cffff6060" .. L["Died"] .. "! " .. text

		elseif typ == "K" then

			list:ItemSet (3, data)

			eStr = "|cffff60ff" .. L["Killed"] .. " " .. text

		elseif typ == "H" then

			eStr = "|cff60ff60" .. L["Picked"] .. " " .. text

		elseif typ == "M" then

			eStr = "|cffc0c0c0" .. L["Mined"] .. " " .. text

		elseif typ == "F" then

			eStr = "|cffc0c0c0" .. L["Fished"] .. " " .. text

		end
		list:ItemSet (2, eStr)

		local mapName = Nx.Map:IdToName (mapId)

		local str = format ("%s %.0f %.0f", mapName, x, y)
		list:ItemSet (4, str)
	end

	list:Update (isLast)
end

------
-- Update user event data on map

function Nx.UEvents:UpdateMap (upGuide)

--	Nx.prt ("UEvents:UpdateMap")

	local Nx = Nx
	local Map = Nx.Map

	local mapId = Map:GetCurrentMapId()
	local m = Map:GetMap (1)

	if m then

		if upGuide then
			m.Guide:Update()
		end

		m:InitIconType ("Kill", nil, "Interface\\TargetingFrame\\UI-TargetingFrame-Skull", 16, 16)
		m:InitIconType ("Death", nil, "Interface\\TargetingFrame\\UI-TargetingFrame-Seal", 16, 16)

		local icon

		for k, item in ipairs (Nx.CurCharacter.E) do

			local iMapId = Nx:GetEventMapId (item)

			if iMapId == mapId then

				local typ, _, _, x, y, text = Nx:UnpackEvent (item)

				if typ == "K" then
					icon = m:AddIconPt ("Kill", x, y)
					m:SetIconTip (icon, text)

				elseif typ == "D" then
					icon = m:AddIconPt ("Death", x, y)
					m:SetIconTip (icon, text)
				end
			end
		end

	end
end

-------------------------------------------------------------------------------

Nx.GatherInfo = {
	[" "] = {	-- Misc
		["Art"] = { 0, "Trade_Archaeology", L["Artifact"]},
		["Everfrost"] = { 0, "spell_shadow_teleport", L["Everfrost"]},
		["Gas"] = { 0, "inv_gizmo_zapthrottlegascollector",	L["Gas"]},
	},
	["L"] = {
		{ 1,	"inv_tradeskillitem_03",L["Small Timber"]},
		{ 2,	"inv_tradeskillitem_03",L["Medium Timber"]},
		{ 3,	"inv_tradeskillitem_03",L["Large Timber"]},
	},
	["H"] = {	-- Herbs
		{ 340,	"inv_misc_herb_ancientlichen",L["Ancient Lichen"]},
		{ 220,	"inv_misc_herb_13",L["Arthas' Tears"]},
		{ 300,	"inv_misc_herb_17",L["Black Lotus"]},
		{ 235,	"inv_misc_herb_14",L["Blindweed"]},
		{ 1,	"inv_misc_herb_11a",L["Bloodthistle"]},
		{ 70,	"inv_misc_root_01",L["Briarthorn"]},
		{ 100,	"inv_misc_herb_01",L["Bruiseweed"]},
		{ 270,	"inv_misc_herb_dreamfoil",L["Dreamfoil"]},
		{ 315,	"inv_misc_herb_dreamingglory",L["Dreaming Glory"]},
		{ 15,	"inv_misc_herb_07",L["Earthroot"]},
		{ 160,	"inv_misc_herb_12",L["Fadeleaf"]},
		{ 300,	"inv_misc_herb_felweed",L["Felweed"]},
		{ 205,	"inv_misc_herb_19",L["Firebloom"]},
		{ 335,	"inv_misc_herb_flamecap",L["Flame Cap"]},
		{ 245,	"inv_mushroom_08",L["Ghost Mushroom"]},
		{ 260,	"inv_misc_herb_sansamroot",L["Golden Sansam"]},
		{ 170,	"inv_misc_herb_15",L["Goldthorn"]},
		{ 120,	"inv_misc_dust_02",L["Grave Moss"]},
		{ 250,	"inv_misc_herb_16",L["Gromsblood"]},
		{ 290,	"inv_misc_herb_iceCap",L["Icecap"]},
		{ 185,	"inv_misc_herb_08",L["Khadgar's Whisker"]},
		{ 125,	"inv_misc_herb_03",L["Kingsblood"]},
		{ 150,	"inv_misc_root_02",L["Liferoot"]},
		{ 50,	"spell_shadow_seathanddecay",L["Mageroyal"]},
		{ 375,	"inv_misc_herb_manathistle",L["Mana Thistle"]},
		{ 280,	"inv_misc_herb_mountainsilversage",L["Mountain Silversage"]},
		{ 350,	"inv_misc_herb_netherbloom",L["Netherbloom"]},
		{ 350,	"inv_enchant_dustsoul",L["Netherdust Bush"]},
		{ 365,	"inv_misc_herb_nightmarevine",L["Nightmare Vine"]},
		{ 1,	"inv_misc_flower_02",L["Peacebloom"]},
		{ 285,	"inv_misc_herb_plaguebloom",L["Sorrowmoss"]},
		{ 210,	"inv_misc_herb_17",L["Purple Lotus"]},
		{ 325,	"inv_misc_herb_ragveil",L["Ragveil"]},
		{ 1,	"inv_misc_herb_10",L["Silverleaf"]},
		{ 85,	"inv_misc_herb_11",L["Stranglekelp"]},
		{ 230,	"inv_misc_herb_18",L["Sungrass"]},
		{ 325,	"inv_misc_herb_terrocone",L["Terocone"]},	-- Someone should check if inv_misc_herb_Terrocone needs to be changed to Terocone (http://www.wowhead.com/item=22789)
		{ 115,	"inv_misc_flower_01",L["Wild Steelbloom"]},
		{ 195,	"inv_misc_flower_03",L["Dragon's Teeth"]},
		{ 1,	"inv_mushroom_02",L["Glowcap"]},
		{ 350,	"inv_misc_herb_goldclover",L["Goldclover"]},
		{ 385,	"inv_misc_herb_talandrasrose",L["Talandra's Rose"]},
		{ 400,	"inv_misc_herb_evergreenmoss",L["Adder's Tongue"]},
		{ 400,	"inv_misc_herb_goldclover",L["Frozen Herb"]},
		{ 400,	"inv_misc_herb_tigerlily",L["Tiger Lily"]},
		{ 425,	"inv_misc_herb_whispervine",L["Lichbloom"]},
		{ 435,	"inv_misc_herb_icethorn",L["Icethorn"]},
		{ 450,	"inv_misc_herb_frostlotus",L["Frost Lotus"]},
		{ 360,	"inv_misc_herb_11a",L["Firethorn"]},
		{ 425,	"inv_misc_herb_azsharasveil",L["Azshara's Veil"]},
		{ 425,	"inv_misc_herb_cinderbloom",L["Cinderbloom"]},
		{ 425,	"inv_misc_herb_stormvine",L["Stormvine"]},
		{ 475,	"inv_misc_herb_heartblossom",L["Heartblossom"]},
		{ 500,	"inv_misc_herb_whiptail",L["Whiptail"]},
		{ 525,	"inv_misc_herb_twilightjasmine",L["Twilight Jasmine"]},
		{ 600,	"inv_misc_herb_foolscap",L["Fool's Cap"]},
		{ 550,	"inv_misc_herb_goldenlotus",L["Golden Lotus"]},
		{ 500,	"inv_misc_herb_jadetealeaf",L["Green Tea Leaf"]},
		{ 525,	"inv_misc_herb_rainpoppy",L["Rain Poppy"]},
		{ 575,	"inv_misc_herb_shaherb",L["Sha-Touched Herb"]},
		{ 545,	"inv_misc_herb_silkweed",L["Silkweed"]},
		{ 575,	"inv_misc_herb_snowlily",L["Snow Lily"]},
		{ 600,	"inv_misc_herb_chamlotus",L["Chameleon Lotus"]},
		{ 600,	"inv_misc_herb_frostweed",L["Frostweed"]},
		{ 600,	"inv_misc_herb_flytrap",L["Gorgrond Flytrap"]},
		{ 600,	"inv_misc_herb_starflower",L["Starflower"]},
		{ 600,	"inv_misc_herb_arrowbloom",L["Nagrand Arrowbloom"]},
		{ 600,	"inv_misc_herb_taladororchid",L["Talador Orchid"]},
		{ 600,	"inv_misc_herb_fireweed",L["Fireweed"]},
		{ 600,	"inv_farm_pumpkinseed_yellow",L["Withered Herb"]},
		{ 700,	"inv_herbalism_70_aethril",L["Aethril"]},
		{ 700,	"inv_herbalism_70_dreamleaf",L["Dreamleaf"]},
		{ 700,	"inv_herbalism_70_felwort",L["Felwort"]},
		{ 700,	"inv_herbalism_70_fjarnskaggl",L["Fjarnskaggl"]},
		{ 700,	"inv_herbalism_70_foxflower",L["Foxflower"]},
		{ 700,	"inv_herbalism_70_starlightrosepetals",L["Starlight Rose"]},
		{ 700,  "inv_misc_herb_astralglory",L["Astral Glory"]},
		-- BfA
		{ 700,  "inv_misc_herb_akundasbite",L["Akunda's Bite"]},
		{ 700,  "inv_misc_herb_anchorweed",L["Anchor Weed"]},
		{ 700,  "inv_misc_herb_riverbud",L["Riverbud"]},
		{ 700,  "inv_misc_herb_seastalk",L["Sea Stalks"]},
		{ 700,  "inv_misc_herb_pollen",L["Siren's Sting"]},
		{ 700,  "inv_misc_herb_starmoss",L["Star Moss"]},
		{ 700,  "inv_misc_herb_winterskiss",L["Winter's Kiss"]},
	},
	["M"] = {	-- Mine node
		{ 325,	"inv_ore_adamantium",L["Adamantite Deposit"]},
		{ 375,	"inv_misc_gem_01",L["Ancient Gem Vein"]},
		{ 1,	"inv_ore_copper_01",L["Copper Vein"]},
		{ 230,	"inv_ore_mithril_01",L["Dark Iron Deposit"]},
		{ 275,	"inv_ore_feliron",L["Fel Iron Deposit"]},
		{ 155,	"inv_ore_copper_01",L["Gold Vein"]},
		{ 65,	"inv_ore_thorium_01",L["Incendicite Mineral Vein"]},
		{ 150,	"inv_ore_mithril_01",L["Indurium Mineral Vein"]},
		{ 125,	"inv_ore_iron_01",L["Iron Deposit"]},
		{ 375,	"inv_ore_khorium",L["Khorium Vein"]},
		{ 305,	"inv_stone_15",L["Large Obsidian Chunk"]},
		{ 75,	"inv_ore_thorium_01",L["Lesser Bloodstone Deposit"]},
		{ 175,	"inv_ore_mithril_02",L["Mithril Deposit"]},
		{ 275,	"inv_ore_ethernium_01",L["Nethercite Deposit"]},
		{ 350,	"inv_ore_adamantium",L["Rich Adamantite Deposit"]},
		{ 255,	"inv_ore_thorium_02",L["Rich Thorium Vein"]},
		{ 75,	"inv_stone_16",L["Silver Vein"]},
		{ 305,	"inv_misc_stonetablet_01",L["Small Obsidian Chunk"]},
		{ 230,	"inv_ore_thorium_02",L["Small Thorium Vein"]},
		{ 65,	"inv_ore_tin_01",L["Tin Vein"]},
		{ 230,	"inv_ore_truesilver_01",L["Truesilver Deposit"]},
		{ 350,	"inv_ore_cobalt",L["Cobalt Deposit"]},
		{ 375,	"inv_ore_cobalt",L["Rich Cobalt Deposit"]},
		{ 425,	"inv_ore_saronite_01",L["Saronite Deposit"]},
		{ 425,	"inv_ore_saronite_01",L["Rich Saronite Deposit"]},
		{ 450,	"inv_ore_platinum_01",L["Titanium Vein"]},
		{ 425,	"item_elementiumore",L["Obsidium Deposit"]},
		{ 450,	"item_elementiumore",L["Rich Obsidium Deposit"]},
		{ 475,	"item_pyriumore",L["Elementium Vein"]},
		{ 500,	"item_pyriumore",L["Rich Elementium Vein"]},
		{ 525,	"inv_ore_arcanite_01",L["Pyrite Deposit"]},
		{ 525,	"inv_ore_arcanite_01",L["Rich Pyrite Deposit"]},
		{ 515,	"inv_ore_ghostiron",L["Ghost Iron Deposit"]},
		{ 550,	"inv_ore_ghostiron",L["Rich Ghost Iron Deposit"]},
		{ 550,	"inv_ore_manticyte",L["Kyparite Deposit"]},
		{ 575,	"inv_ore_manticyte",L["Rich Kyparite Deposit"]},
		{ 600,	"inv_ore_trilliumwhite",L["Trillium Vein"]},
		{ 600,	"inv_ore_trilliumWhite",L["Rich Trillium Vein"]},
		{ 600,	"inv_ore_trueironore",L["Rich True Iron Deposit"]},
		{ 600,	"inv_ore_trueironore",L["Smoldering True Iron Deposit"]},
		{ 600,	"inv_ore_trueironore",L["True Iron Deposit"]},
		{ 600,	"inv_ore_blackrock_ore",L["Blackrock Deposit"]},
		{ 600,	"inv_ore_blackrock_ore",L["Rich Blackrock Deposit"]},
		{ 700,	"inv_felslate",L["Felslate Deposit"]},
		{ 700,	"inv_felslate",L["Felslate Seam"]},
		{ 700,	"inv_felslate",L["Living Felslate"]},
		{ 700,	"inv_leystone",L["Leystone Deposit"]},
		{ 700,	"inv_leystone",L["Leystone Seam"]},
		{ 700,	"inv_leystone",L["Living Leystone"]},		
		{ 700,  "inv_misc_starmetal",L["Empyrium Deposit"]},
		{ 700,  "inv_misc_starmetal",L["Rich Empyrium Deposit"]},
		{ 700,  "inv_misc_starmetal",L["Empyrium Seam"]},
		-- BfA
		{ 800,  "inv_ore_monalite",L["Monelite Deposit"]},
		{ 800,  "inv_ore_monalite",L["Rich Monelite Deposit"]},
		{ 800,  "inv_ore_monalite",L["Monelite Seam"]},
		{ 800,  "inv_ore_platinum",L["Platinum Deposit"]},
		{ 800,  "inv_ore_platinum",L["Rich Platinum Deposit"]},
		{ 800,  "inv_ore_stormsilver",L["Storm Silver Deposit"]},
		{ 800,  "inv_ore_stormsilver",L["Rich Storm Silver Deposit"]},
		{ 800,  "inv_ore_stormsilver",L["Storm Silver Seam"]},
		
	}
}

Nx.GatherRemap = {
	["NXHerb"] = {
		[47] = 46,		-- Icethorn
	},
	["NXMine"] = {
		[6] = 9,		-- Gold
		[17] = 20,		-- Silver
		[23] = 22,		-- Rich Cobalt Deposit
		[25] = 24,		-- Rich Saronite Deposit
		[26] = 24,		-- Titanium
	}
}

--------
-- Init. Call after map init

function Nx:GatherInit()
	if self.DoGatherUpgrade then
		self.DoGatherUpgrade = nil
		Nx:GatherVerUpgrade()
	end
	Nx.GatherVerUpgrade = nil		-- Kill it
	Nx.GatherVerUpgradeType = nil		-- Kill it
end

function Nx:GetGather (typ, id)
	local v = Nx.GatherInfo[typ][id]
	if v then
		return v[3], v[2], v[1]
	end
end

Nx.GatherCache = {}
Nx.GatherCache.L = {}
Nx.GatherCache.H = {}
Nx.GatherCache.M = {}
function Nx:IsGathering(nodename)
	if #Nx.GatherCache.L == 0 then
		for k, v in ipairs (Nx.GatherInfo["L"]) do
			Nx.GatherCache.L[v[3]] = true
		end
	end
	if #Nx.GatherCache.H == 0 then
		for k, v in ipairs (Nx.GatherInfo["H"]) do
			Nx.GatherCache.H[v[3]] = true
		end
	end
	if #Nx.GatherCache.M == 0 then
		for k, v in ipairs (Nx.GatherInfo["M"]) do
			Nx.GatherCache.M[v[3]] = true
		end
	end
	if Nx.GatherCache.L[nodename] then return L["Logging"] end
	if Nx.GatherCache.H[nodename] then return "Herb Gathering" end
	if Nx.GatherCache.M[nodename] then return L["Mining"] end
end

function Nx:HerbNameToId (name)
	for k, v in ipairs (Nx.GatherInfo["H"]) do
		if v[3] == name then
			return k
		end
	end

	if Nx.db.profile.Debug.DBGather then
		Nx.prt (L["Unknown herb"] .. " %s", name)
	end
end

function Nx:MineNameToId (name)

	name = gsub (name, L["Ooze Covered"] .. " ", "")
	if name == L["Thorium Vein"] then				-- Created when Ooze Covered removed
		name = L["Small Thorium Vein"]
	end
	for k, v in ipairs (Nx.GatherInfo["M"]) do
		if v[3] == name then
			return k
		end
	end

	if Nx.db.profile.Debug.DBGather then
		Nx.prt (L["Unknown ore"] .. " %s", name)
	end
end

--------
-- Upgrade gather data

function Nx:GatherVerUpgrade()
	Nx:GatherVerUpgradeType ("NXHerb")
	Nx:GatherVerUpgradeType ("NXMine")
	Nx:GatherVerUpgradeType ("NXTimber")
end

function Nx:GatherVerUpgradeType (tName)
end

--------
-- Save location of gathered herb
-- xy is zone coords

function Nx:GatherHerb (id, mapId, x, y, level)
	self:Gather ("NXHerb", id, mapId, x, y, level)
end


function Nx:GatherTimber(id, mapId, x, y, level)
	self:Gather ("NXTimber", id, mapId, x, y, level)
end
--------
-- Save location of gathered mining
-- xy is zone coords

function Nx:GatherMine (id, mapId, x, y, level)
	self:Gather ("NXMine", id, mapId, x, y, level)
end

--------
-- Add gathered item. xy zone coords 0-100

function Nx:Gather (nodeType, id, mapId, x, y, level)	
	local remap = self.GatherRemap[nodeType]
	if remap then
		id = remap[id] or id
	end	
	local data = Nx.db.profile.GatherData[nodeType]
	if not data then
		Nx.db.profile.GatherData[nodeType] = {}
		data = Nx.db.profile.GatherData[nodeType]
	end
	
	local zoneT = data[mapId]

	if not zoneT or not Nx.Map.MapWorldInfo[mapId] then
--		Nx.prt ("Gather new %d", mapId)
		zoneT = {}
		data[mapId] = zoneT
	end

	local maxDist = (5 / Nx.Map:GetWorldZoneScale (mapId)) ^ 2	
	local index
	local nodeT = zoneT[id] or {}
	zoneT[id] = nodeT

	for n, node in ipairs (nodeT) do		
		local nx, ny, nlevel = Nx.Split("|",node)		
		nx, ny, nlevel = tonumber(nx), tonumber(ny), tonumber(nlevel)
		
		if not nlevel then
			nlevel = 0
		end
		if nlevel == level then			
			local dist = (nx - x) ^ 2 + (ny - y) ^ 2			
			if dist < maxDist then		-- Squared compare
				index = n
				break
			end
		end
	end
	local cnt = 1
	if not index then
		index = #nodeT + 1		
	else
		local nx,xy, level = Nx.Split ("|", nodeT[index])		
	end
	nodeT[index] = format ("%f|%f|%d", x, y, level)
end

--------

function Nx:GatherUnpack (item)
	local x,y, level = Nx.Split ("|", item)
	if not level then
		level = 0
	end
	x = tonumber (x)
	y = tonumber (y)	
	level = tonumber(level)
	return x, y, level
end

--------

function Nx:GatherDeleteHerb()
	Nx.db.profile.GatherData.NXHerb = {}
end

function Nx:GatherDeleteTimber()
	Nx.db.profile.GatherData.NXTimber = {}
end

function Nx:GatherDeleteMine()
	Nx.db.profile.GatherData.NXMine = {}
end

function Nx:GatherDeleteMisc()
	Nx.db.profile.GatherData["Misc"] = {}
end

--------

function Nx:GatherImportCarbHerb()
	Nx:GatherImportCarb ("NXHerb")
end

function Nx:GatherImportCarbMine()
	Nx:GatherImportCarb ("NXMine")
end

function Nx:GatherImportCarbMisc()
	Nx:GatherImportCarb ("Misc")
end

function Nx:GatherConvert (id)
	return floor(id/1000000)/10000, floor(id % 1000000 / 100)/10000, id % 100
end

function Nx:GatherNodeToCarb (id)

	local gatherIDs = {
	-- Mining Node Conversions
		[201] = 3,
		[202] = 20,
		[203] = 9,
		[204] = 17,
		[205] = 6,
		[206] = 13,
		[207] = 13,
		[208] = 21,
		[209] = 17,
		[210] = 6,
		[211] = 21,
		[212] = 16,
		[213] = 19,
		[214] = 19,
		[215] = 16,
		[216] = 19,
		[217] = 4,
		[218] = 12,
		[219] = 7,
		[220] = 8,
		[221] = 5,
		[222] = 1,
		[223] = 15,
		[224] = 10,
		[225] = 11,
		[226] = 18,
		[227] = 14,
		[228] = 22,
		[229] = 23,
		[230] = 26,
		[231] = 24,
		[232] = 25,
		[233] = 27,
		[234] = 27,
		[235] = 24,
		[236] = 29,
		[237] = 30,
		[238] = 31,
		[239] = 28,
		[240] = 32,
		[241] = 33,
		[242] = 34,
		[243] = 37,
		[244] = 37,
		[245] = 35,
		[246] = 36,
		[247] = 37,
		[248] = 38,
		[249] = 41,
		[250] = 40,
		[251] = 42,
		[252] = 43,
		-- Legion
		[253] = 47,
		[254] = 49,
		[255] = 48,
		[256] = 44,
		[257] = 46,
		[258] = 45,
		[259] = 50, -- guessing at this logically, needs confirmation after 7.3 release, regular node
		[260] = 51, -- rich deposit
		[261] = 52, -- seam
		-- BfA
		[262] = 53,
		[263] = 54,
		[264] = 55,
		[265] = 56,
		[266] = 57,
		[267] = 58,
		[268] = 59,
		[269] = 60,
	-- Herbalism Nodes
		[401] = 30,
		[402] = 34,
		[403] = 10,
		[404] = 24,
		[405] = 6,
		[406] = 6,
		[407] = 35,
		[408] = 7,
		[409] = 38,
		[410] = 18,
		[411] = 22,
		[412] = 23,
		[413] = 11,
		[414] = 17,
		[415] = 21,
		[416] = 0,
		[417] = 13,
		[418] = 32,
		[419] = 32,
		[420] = 2,
		[421] = 36,
		[422] = 4,
		[423] = 15,
		[424] = 19,
		[425] = 16,
		[426] = 8,
		[427] = 26,
		[428] = 0,
		[429] = 20,
		[430] = 0,
		[431] = 3,
		[432] = 12,
		[433] = 9,
		[434] = 37,
		[435] = 1,
		[436] = 5,
		[437] = 25,
		[438] = 27,
		[439] = 29,
		[440] = 33,
		[441] = 14,
		[442] = 28,
		[443] = 43,
		[444] = 0,
		[445] = 0,
		[446] = 41,
		[447] = 47,
		[448] = 46,
		[449] = 42,
		[450] = 45,
		[451] = 49,
		[452] = 44,
		[453] = 48,
		[454] = 39,
		[455] = 31,
		[456] = 50,
		[457] = 51,
		[458] = 52,
		[459] = 53,
		[460] = 55,
		[461] = 54,
		[462] = 57,
		[463] = 56,
		[464] = 62,
		[465] = 61,
		[466] = 58,
		[467] = 59,
		[468] = 60,
		[469] = 68,
		[470] = 67,
		[471] = 66,
		[472] = 65,
		[473] = 69,
		[474] = 64,
		[475] = 70,
		-- Legion
		[476] = 71,
		[477] = 72,
		[478] = 73,
		[479] = 74,
		[480] = 75,
		[481] = 76,
		[482] = 77,
		-- BfA
		[485] = 78,
		[486] = 79,
		[487] = 80,
		[488] = 81,
		[489] = 82,
		[490] = 83,
		[491] = 84,
	}
	return gatherIDs[id]
end

function Nx:GatherImportCarb (nodeType)
	LoadAddOn("Carbonite.Gathermate2_Data")
	if nodeType == "NXMine" then
		if not GatherMateData2MineDB then
			Nx.prt (L["Carbonite.Gathermate2_Data addon is not loaded!"])
			return
		end
	end

	if nodeType == "NXHerb" then
		if not GatherMateData2HerbDB then
			Nx.prt (L["Carbonite.Gathermate2_Data addon is not loaded!"])
			return
		end
	end

	local srcT = nil

	if nodeType == "NXMine" then
		srcT = GatherMateData2MineDB
	elseif nodeType == "NXHerb" then
		srcT = GatherMateData2HerbDB
	end

	local cnt = 0
	if srcT then
		for mapId, zoneT in pairs (srcT) do
			for coords, nodetype in pairs(zoneT) do
				local nx, ny = Nx:GatherConvert(coords)
				local nodeId = Nx:GatherNodeToCarb (nodetype)
				if nx and ny and nodeId then
					Nx:Gather (nodeType, nodeId, mapId, nx * 100, ny * 100)
					cnt = cnt + 1
				end
			end
		end

		Nx.prt (L["Imported"] .. " %s " .. L["nodes from Carbonite.Gathermate2_Data"], cnt, nodeType)
	end
end

-------------------------------------------------------------------------------
-- Item handling

function Nx.Item:Init()
	self.Asked = {}
end

function Nx.Item:Load (id)
	if not self.Asked[id] then			-- Ask once
		local name, link = GetItemInfo (id)
		if name then			
			self.Asked[id] = name
		end
	end
end

function Nx.Item.EnableLoadFromServer()

--	Nx.prt ("EnableLoadFromServer")

	local self = Nx.Item

	self.TooltipFrm = CreateFrame ("GameTooltip", "NxTooltipItem", UIParent, "GameTooltipTemplate")
	self.TooltipFrm:SetOwner (UIParent, "ANCHOR_NONE")		-- We won't see with this anchor

	self.ItemsRequested = 0

	Item = Nx:ScheduleTimer (self.Timer, 1)
end

function Nx.Item.DisableLoadFromServer()

--	Nx.prt ("DisableLoadFromServer")

	local self = Nx.Item
	self.Needed = {}
	self.Load = function() end		-- Nuke function

	AskDeleteVV = Nx:ScheduleTimer (self.AskDeleteVV, 0)
end

function Nx.Item.AskDeleteVV()

	local function func()
			Nx.db.profile.VendorV = nil
			Nx.Map.Guide:UpdateVisitedVendors()
	end

	Nx:ShowMessage (Nx.TXTBLUE.."Carbonite:\n|cffffff60" .. L["Delete visited vendor data?"] .. "\n" .. L["This will stop the attempted retrieval of items on login."], L["Delete"], func, L["Cancel"])
end

function Nx.Item:ShowTooltip (id, compare)

--	Nx.prtVar ("ShowTooltip", id)

	local id = tostring (id)

	id = Nx.Split ("^", id)

	if not strfind (id, "item:") then
		if strfind (id, "quest:") then
		else
			id = "item:" .. id .. ":0:0:0:0:0:0:0"		-- Without the 7 ":0" Pawn prints an error
		end
	end

	GameTooltip:SetHyperlink (id)

	if compare then
		GameTooltip_ShowCompareItem()
	end
end

function Nx.Item:DrawTimer()

	if next (self.Needed) then		-- More?
		Nx.prt (" %d " .. L["items retrieved"], self.ItemsRequested)

	else
		Nx.prt (L["Item retrieval from server complete"])
	end

	local g = Nx.Map:GetMap (1).Guide
	g:UpdateVisitedVendors()
	g:Update()
end

-------------------------------------------------------------------------------
-- Minimap button functions

function Nx.NXMiniMapBut:Init()
	local f = NXMiniMapBut

	if not Nx.db.profile.MiniMap.ButOwn then
		f:RegisterForDrag ("LeftButton")
	end

	-- Create menu

	local menu = Nx.Menu:Create (f)
	self.Menu = menu
	menu:AddItem (0, L["Options"], self.Menu_OnOptions, self)
	menu:AddItem (0, L["Show Map"], self.Menu_OnShowMap, self)
	menu:AddItem (0, L["Show Events"], self.Menu_OnShowEvents, self)
	menu:AddItem (0, "", nil, self)

	local item = menu:AddItem (0, L["Show Auction Buyout Per Item"], self.Menu_OnShowAuction, self)
	item:SetChecked (false)

	if Nx.db.profile.Debug.DebugCom then
		menu:AddItem (0, "", nil, self)
		menu:AddItem (0, L["Show Com Window"], self.Menu_OnShowCom, self)
	end
	if Nx.db.profile.Debug.DebugMap then
		menu:AddItem (0, "", nil, self)
		menu:AddItem (0, L["Toggle Profiling"], self.Menu_OnProfiling, self)
	end

	-- Fix position if bad (does not work)

	NXMiniMapBut:SetClampedToScreen (true)

--	self:Move()

	-- Ask to disable profiling

	local ok, var = pcall (GetCVar, "scriptProfile")
	if ok and var ~= "0" then
		Nx:ShowMessage ("Profiling is on. This decreases game performance. Disable?", "Disable and Reload", self.ToggleProfiling, "Cancel")
	end
end

function Nx.NXMiniMapBut:Menu_OnOptions()
	Nx.Opts:Open()
end

function Nx.NXMiniMapBut:Menu_OnShowMap()
	Nx.Map:ToggleSize()
end

function Nx.NXMiniMapBut:Menu_OnShowEvents()
	Nx.UEvents.List:Open()
end

function Nx.NXMiniMapBut:Menu_OnHideWatch (item)
	local hide = item:GetChecked()
	Nx.Quest.Watch.Win:Show (not hide)
end

function Nx.NXMiniMapBut:Menu_OnShowAuction (item)
	Nx.AuctionShowBOPer = item:GetChecked()

	if AuctionFrame and AuctionFrame:IsShown() then
		AuctionFrameBrowse_Update()
	end
end

function Nx.NXMiniMapBut:Menu_OnShowCom()
	Nx.Com.List:Open()
end

function Nx.NXMiniMapBut:Menu_OnProfiling()
	Nx:ShowMessage ("Toggle profiling? Reloads UI", "Reload", self.ToggleProfiling, "Cancel")
end

function Nx.NXMiniMapBut:ToggleProfiling()

	RegisterCVar ("scriptProfile")

	local var = GetCVar ("scriptProfile")
--	Nx.prtVar ("v:", var)
	var = var == "0" and "1" or "0"
	SetCVar ("scriptProfile", var)

--	Nx.prt (format ("Profiling %s", var))
	ReloadUI()
end

function Nx.NXMiniMapBut:NXOnEnter (frm)

	local mmown = Nx.db.profile.MiniMap.ButOwn
	local tip = GameTooltip

	--V4 this
	tip:SetOwner (frm, "ANCHOR_LEFT")
	tip:SetText (NXTITLEFULL .. " " .. Nx.VERMAJOR .. "." .. Nx.VERMINOR*10)
	tip:AddLine (L["Left click toggle Map"], 1, 1, 1, true)

	if mmown then
		tip:AddLine (L["Shift left click toggle minimize"], 1, 1, 1, true)
	end

	tip:AddLine (L["Alt left click toggle Watch List"], 1, 1, 1, true)
	tip:AddLine (L["Middle click toggle Guide"], 1, 1, 1, true)
	tip:AddLine (L["Right click for Menu"], 1, 1, 1, true)

	if not mmown then
		tip:AddLine (L["Shift drag to move"], 1, 1, 1, true)
	end
	tip:AppendText ("")
end

function Nx.NXMiniMapBut:NXOnClick (button, down)

--	Nx.prt (button)

	if button == "LeftButton" then

		if IsShiftKeyDown() then
			Nx.db.profile.MiniMap.ButWinMinimize = not Nx.db.profile.MiniMap.ButWinMinimize
			Nx.Map.Dock:UpdateOptions()
		elseif IsAltKeyDown() and Nx.Quest then
			local w = Nx.Quest.Watch.Win
			w:Show (not w:IsShown())
		else
			Nx.Map:ToggleSize (0)
		end

	elseif button == "MiddleButton" then

		Nx.Map:GetMap (1).Guide:ToggleShow()

	else
		self:OpenMenu()
	end
end

function Nx.NXMiniMapBut:OpenMenu()
	if self.Menu then			-- Someone had error with this nil
		self.Menu:Open()
	end
end

--------
-- Move the minimap button around the minimap

function Nx.NXMiniMapBut:NXOnUpdate (frm)

--	Nx.prtVar ("NXOnUpdate", frm)

	--V4 this
	if frm.NXDrag then

--		Nx.prt ("Drag")

		local mm = _G["Minimap"]

		local x, y = GetCursorPosition()
		local s = mm:GetEffectiveScale()
		self:Move (x / s, y / s)
	end
end

function Nx.NXMiniMapBut:Move (x, y)

	local but = NXMiniMapBut		-- 32x32

	local mm = _G["Minimap"]

	local l = mm:GetLeft() + 70		-- Minimap is 140x140
	local b = mm:GetBottom() + 70
--[[
	if not x then
		x = but:GetLeft()
		y = but:GetTop()
		Nx.prt ("xy %s %s", x, y)
	end
--]]
	x = x - l
	y = y - b

	local ang = atan2 (y, x)
	local r = (x ^ 2 + y ^ 2) ^ .5
	r = max (r, 79)
	r = min (r, 110)

	x = r * cos (ang)
	y = r * sin (ang)
	but:SetPoint ("TOPLEFT", mm, "TOPLEFT", x + 54, y - 54)
	but:SetUserPlaced (true)
end

function Nx.ModChatReceive(msg,dist,target)
end

local TempTable = {}
setmetatable(TempTable, {__mode = "v"})

function Nx.Split(d, p)
	if p and not string.find(p,d) then
		return p
	end
	if not p then
		return nil
	end
	if p and #p <= 1 then return p end
	if TempTable[p] then
		return unpack(TempTable[p],1,table.maxn(TempTable[p]))
	else
		--local TempNum = 0
		local Tossaway = {strsplit(d, p)}
		--[[while true do
			local l=string.find(p,d,TempNum,true);
			if l~=nil then
				table.insert(Tossaway, string.sub(p,TempNum,l-1))
				TempNum=l+1
			else
				table.insert(Tossaway, string.sub(p,TempNum))
				break
			end
		end]]--
		TempTable[p] = Tossaway
		return unpack(Tossaway)
	end
end

function Nx.Proc:Init()

	self.Procs = {}
	self.TimeLeft = 0
end

function Nx.Proc:New (user, func, delay)

	local p = {}
	tinsert (self.Procs, p)
	p.User = user
	p.Func = func
	p.Delay = delay or 1
end

function Nx.Proc:SetFunc (proc, func)
	proc.Func = func
end

function Nx.Proc:OnUpdate (elapsed)

--	Nx.prt ("Proc Elapsed raw %s", elapsed)

	elapsed = min (elapsed, .2) * 60

--	Nx.prt ("Proc Elapsed %s", elapsed)

	elapsed = elapsed + self.TimeLeft

	while elapsed >= 1 do

		elapsed = elapsed - 1

		local n = 1

		while 1 do
			local p = self.Procs[n]
			if not p then
				break
			end

			local d = p.Delay - 1
			if d <= 0 then
				d = p.Func (p.User, p) or 1

				if d < 0 then				-- No time?
					tremove (self.Procs, n)		-- Kill proc
					n = n - 1			-- Same index again
				end
			end
			p.Delay = d

			n = n + 1
		end

	end

	self.TimeLeft = elapsed
end
---------------------------------------------------------------------------------------
--EOF