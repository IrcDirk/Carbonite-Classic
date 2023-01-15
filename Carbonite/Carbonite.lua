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
  [1568657164] = {"Sept 16th 2019","","This is Alpha version of Carbonite Classic, all bugs/issues please report to", "GitHub repo: https://github.com/IrcDirk/Carbonite-Classic."},
  [1653631200] = {"May 27th 2022","","Fixed map path generation using FlightMasters", "Fixed HandyNotes icons disappearing while standing still", "Fixed Carbonite Map causing errors while trying to open map in combat", "Fixed Carbonite maps going out while traveling between islands/subcontinents in Kalimdor/Eastern Kingdoms/Outlands", "Fixed Warehouse module not showing equipped wands", "Add tracking of goods bought in Auction House in Warehouse module", "Add localizations for various strings (need translators for some languages)", "Updated translations for some of the Carbonite modules"},
  [1660510987] = {"Aug 14th 2022","","Implemented WotLK Classic support for Pre-patch","Updated Flight Masters data", "Updated Flight Masters locales for DE,ES,FR,KO,PT,RU,TW Languages", "Fixed various small errors caused by division by zero."}
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
			}
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
			mapUpdate = .05,
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
	
	-- Adding support for Zygor Waypoint system
	if ZGV and ZGV.Pointer then
		hooksecurefunc(ZGV.Pointer, "SetWaypoint", function (e, m, x, y, data, arrow)
			local map = Nx.Map:GetMap (1)
			if not m then
				if WorldMapFrame:IsShown() then m=WorldMapFrame:GetMapID() else m=C_Map.GetBestMapForUnit("player") end
			end
			
			x = x or 0;	
			y = y or 0;
			
			local wx, wy = map:GetWorldPos (m, x*100, y*100)
			local title = (ZGV.CurrentStep and ZGV.CurrentStep.current_waypoint_goal_num and ZGV.CurrentStep.goals) and ZGV.CurrentStep.goals[ZGV.CurrentStep.current_waypoint_goal_num]:GetText() or ""
			
			if ZygorGuidesViewerFrame:IsVisible() then 
				map:SetTarget ("Goto", wx, wy, wx, wy, nil, nil, title or "Zygor Waypoint (check step in Zygor Guide Viewer)", nil, m)
			end
			
			return waypoint
		end)
	end
	
	--GuildControlPopupFrame.initialized = 1
end

function Nx:ADDON_LOADED (event, arg1, ...)
	Nx.Loaded = true
	
	CarbMigr = {}
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
	Com:RegisterEvent("CHAT_MSG_SYSTEM", "OnChat_msg_channel")
	
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
	
	--[[if Nx.WhatsNewUnread() then
		if Nx.Tick % 50 == 0 then
			if Nx.GlowOn then
				NXMiniMapBut:SetNormalTexture("Interface\\AddOns\\Carbonite\\Gfx\\MMBut")
				Nx.GlowOn = false
			else
				NXMiniMapBut:SetNormalTexture("Interface\\AddOns\\Carbonite\\Gfx\\MMButFilled")
				Nx.GlowOn = true
			end
		end
	end]]--
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

function Nx:AddMineEvent (name, time, mapId, x, y)
	self:AddEvent ("M", name, time, mapId, x, y)
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Title

function Nx.Title:Init()

	local f = CreateFrame ("Frame", nil, UIParent, "BackdropTemplate")
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

	local lf = CreateFrame ("Frame", nil, f, "BackdropTemplate")

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
		{ 50,	"inv_jewelry_talisman_03",L["Mageroyal"]},
		{ 375,	"inv_misc_herb_manathistle",L["Mana Thistle"]},
		{ 280,	"inv_misc_herb_mountainsilversage",L["Mountain Silversage"]},
		{ 350,	"inv_misc_herb_netherbloom",L["Netherbloom"]},
		{ 350,	"inv_enchant_dustsoul",L["Netherdust Bush"]},
		{ 365,	"inv_misc_herb_nightmarevine",L["Nightmare Vine"]},
		{ 1,	"inv_misc_flower_02",L["Peacebloom"]},
		{ 285,	"inv_misc_herb_plaguebloom",L["Plaguebloom"]},
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
	},
	["M"] = {	-- Mine node
		{ 325,	"inv_ore_adamantium",L["Adamantite Deposit"]},
		{ 375,	"inv_misc_gem_01",L["Ancient Gem Vein"]},
		{ 1,	"inv_ore_copper_01",L["Copper Vein"]},
		{ 230,	"inv_ore_mithril_01",L["Dark Iron Deposit"]},
		{ 300,	"inv_ore_feliron",L["Fel Iron Deposit"]},
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
Nx.GatherCache.H = {}
Nx.GatherCache.M = {}
function Nx:IsGathering(nodename)
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
end

function Nx:GatherVerUpgradeType (tName)
end

--------
-- Save location of gathered herb
-- xy is zone coords

function Nx:GatherHerb (id, mapId, x, y, level)
	self:Gather ("NXHerb", id, mapId, x, y, level)
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
				if not nodeId and (nodeType == "NXMine" or nodeType == "NXHerb") then
					nodeId = nodetype
				end
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