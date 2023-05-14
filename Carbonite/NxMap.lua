---------------------------------------------------------------------------------------
-- NxMap - Map code
-- Copyright 2007-2012 Carbon Based Creations, LLC
---------------------------------------------------------------------------------------
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
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see <http://www.gnu.org/licenses/>.
---------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Map

local _G = getfenv(0)
local L = LibStub("AceLocale-3.0"):GetLocale("Carbonite")

NxMAPOPTS_VERSION	= .30

NxMapOptsDefaults = {
	Version = NxMAPOPTS_VERSION,
	NXAutoScaleOn = true,
	NXKillShow = false,
	NXMMFull = false,
	NXMMAlpha = .1,
	NXMMDockScale = .4,
	NXMMDockScaleBG = .4,
	NXMMDockAlpha = 1,
	NXMMDockOnAtScale = .6,
	NXBackgndAlphaFade = .4,
	NXBackgndAlphaFull = 1,
	NXArchAlpha = .3,
	NXQuestAlpha = .3,
	NXAutoScaleMin = .01,
	NXAutoScaleMax = 4,
	NXDotZoneScale = 1,
	NXDotPalScale = 1,
	NXDotPartyScale = 1,
	NXDotRaidScale = 1,
	NXIconNavScale = 1,
	NXIconScale = 3,
	NXDetailScale = 4,
	NXDetailAlpha = 1,
	NXPOIAtScale = 1,
	NXShowUnexplored = false,
	NXUnexploredAlpha = .35,
	NXOverlayAlpha = nil,
	NXMiniAlpha = nil,
	NXMiniShow = nil,
}

NXMapOptsMapsDefault = 	{
	[0] = {	-- Default map id
		NXPlyrFollow = true,
		NXInstanceMaps = true,
		NXWorldShow = true,
	},
	[93] = {	-- AB
		NXPlyrFollow = true,
		NXInstanceMaps = true,
		NXWorldShow = false,
	},
	[92] = {	-- WG
		NXPlyrFollow = true,
		NXInstanceMaps = true,
		NXWorldShow = false,
	},
	[91] = {	-- AV
		NXPlyrFollow = true,
		NXInstanceMaps = true,
		NXWorldShow = false,
	},
	[112] = {	-- EOS
		NXPlyrFollow = true,
		NXInstanceMaps = true,
		NXWorldShow = false,
	},
	[128] = {	-- SoA
		NXPlyrFollow = true,
		NXInstanceMaps = true,
		NXWorldShow = false,
	},
	[169] = {	-- IC
		NXPlyrFollow = true,
		NXInstanceMaps = true,
		NXWorldShow = false,
	},
	[275] = {	-- TBG
		NXPlyrFollow = true,
		NXInstanceMaps = true,
		NXWorldShow = false,
	},
	[206] = {	-- TP
		NXPlyrFollow = true,
		NXInstanceMaps = true,
		NXWorldShow = false,
	},
	[397] = {   -- EOSv2	
		NXPlyrFollow = true,
		NXInstanceMaps = true,
		NXWorldShow = false,	
	},
	[417] = {	-- TK
		NXPlyrFollow = true,
		NXInstanceMaps = true,
		NXWorldShow = false,
	},
	[423] = {	-- SM
		NXPlyrFollow = true,
		NXInstanceMaps = true,
		NXWorldShow = false,
	},
	[519] = {
		NXPlyrFollow = true,
		NXInstanceMaps = true,
		NXWorldShow = false,
	},
	[623] = {
		NXPlyrFollow = true,
		NXInstanceMaps = true,
		NXWorldShow = false,
	},
}

--------
-- Init map stuff

function Nx.Map:Init()

	local plFaction = UnitFactionGroup ("player")
--	Nx.prt ("fac %s", plFaction)
	plFaction = strsub (plFaction, 1, 1)
	self.PlFactionNum = plFaction == "A" and 0 or 1
	self.PlFactionShort = plFaction == "A" and "Ally" or "Horde"
	Nx.Map.Indoors = false

	self.Maps = {}
	self.Created = false

	self:InitFuncs()
	self:InitTables()

	self.PlyrNames = {}
	self.AFKers = {}
	self.PlyrNamesTipStr = ""

	self.ScanContinentsMod = 10

	self.ContPOIs = {}
	for cont = 1, self.ContCnt do
		self.ContPOIs[cont] = {}
	end

	self.BGTimers = {}

	local hist = {}
	self.PlyrHist = hist
	hist.LastX = -99999999
	hist.LastY = -99999999
	hist.Next = 1
	hist.Cnt = Nx.db.profile.Map.TrailCnt

	for n = 1, hist.Cnt * 4, 4 do
		hist[n] = 0		-- Secs
		hist[n + 1] = 0		-- World X
		hist[n + 2] = 0		-- World Y
		hist[n + 3] = 0		-- Direction
	end

	Nx.MapPOITypes = {
		[0] =
		0, 0, 2, 1, 1, 0, 0, 0,  0, 1, 2, 1, 2, 2, 2, 1,
		0, 1, 1, 2, 2, 0, 1, 1,  2, 2, 0, 1, 1, 2, 2, 0,
		1, 1, 2, 2, 0, 1, 1, 2,  2, 0, 0, 1, 2, 0, 1, 1,
		2, 2,
		[136] = 1,
		[137] = 1,
		[138] = 2,
		[139] = 2,
		[141] = 1,
		[142] = 1,
		[143] = 2,
		[144] = 2,
		[146] = 1,
		[147] = 1,
		[148] = 2,
		[149] = 2,
		[151] = 1,
		[152] = 1,
		[153] = 2,
		[154] = 2,
	}

	self.WorldMapHideNames = {
		"WorldMapCorpse", "WorldMapDeathRelease", "WorldMapPing", "OutlandButton", "AzerothButton"
	}
	self.AddonMinimapNames = {			-- # is stripped
		["GatherNote"] = true,
		["GatherMatePin"] = true,
		["MobMapMinimapDot_"] = true,
		["CartographerNotesPOI"] = true,
		["RecipeRadarMinimapIcon"] = true,
		["NauticusMiniIcon"] = true,
		["ZGVMarkerMini"] = true,		-- Zygor ZGVMarker1Mini
		["HandyNotesPin"] = true,		-- HandyNotes
	}
	-- Emulate TomTom
	if Nx.db.profile.Track.EmuTomTom and not Nx.RealTom then
		TomTom = {}
		Nx.EmulateTomTom()
	end	
	Nx.Map.UpdateMapID = WorldMapFrame.mapID
	if Nx.Map.UpdateMapID then
		WorldMapFrame:SetMapID(Nx.Map.UpdateMapID)
	end
end

function Nx.Map:SetMapByID(zone)
	--[[if Nx.Map:GetMap(1).MapWorldInfo and (Nx.Map:IsInstanceMap(zone) or Nx.Map:IsBattleGroundMap(zone)) then
		Nx.CurrentSetZone = nil
		WorldMapFrame:SetMapID(zone) 	
		return
	end
	if Nx.Map.MouseOver then
		if Nx.Map.MouseIsOverMap then
			zone = Nx.Map.MouseIsOverMap
			Nx.Map.RMapId = zone
		else
			Nx.Map.RMapId = zone
			return
		end
	else
		Nx.Map.RMapId = zone
	end
	if not Nx.CurrentSetZone or Nx.CurrentSetZone ~= zone then
		if zone then
			Nx.CurrentSetZone = zone
			if not WorldMapFrame:IsShown() then 
				WorldMapFrame:SetMapID(zone) 
			end
		end
	end]]--
	if not WorldMapFrame:IsShown() and WorldMapFrame.ScrollContainer.zoomLevels then 
		if zone == 12 then zone = 1414 end
		if zone == 13 then zone = 1415 end
		WorldMapFrame:SetMapID(zone) 
	end
end


function Nx.Map:GetMapInfo(mapId)
	if mapId and mapId ~= 0 then
		if mapId == 12 then mapId = 1414 end
		if mapId == 13 then mapId = 1415 end
		local mapInfo = C_Map.GetMapInfo(mapId)
		if mapInfo.mapType == 2 then
			if mapInfo.mapID == 1414 then mapInfo.mapID = 12 end
			if mapInfo.mapID == 1415 then mapInfo.mapID = 13 end
        	end
		if mapInfo.mapType == 3 then
			if mapInfo.parentMapID == 1414 then mapInfo.parentMapID = 12 end
			if mapInfo.parentMapID == 1415 then mapInfo.parentMapID = 13 end
        	end
		return mapInfo
	else
		return nil
	end
end

--------
-- Open and init

function Nx.Map:Open()
	local Map = Nx.Map

	local m = self.Maps[1]

	if not Nx.db.profile.MapSettings then		-- Missing?
		Nx.db.profile.MapSettings = {}
		Nx.db.profile.MapSettings.Version = 0
	end

	if Nx.db.profile.MapSettings.Version < NxMAPOPTS_VERSION then

		if Nx.db.profile.MapSettings.Version > 0 then
			Nx.prt ("Reset map options %f", NxMAPOPTS_VERSION)
		end
		Nx.prt("RESETTING MAP OPTIONS")
		Nx.db.profile.MapSettings = NxMapOptsDefaults
		Nx.db.profile.MapSettings.Maps = NXMapOptsMapsDefault
	end

	if self.Created then

		if m.Frm:IsShown() then
			m.Frm:Hide()
		else
			m.Frm:Show()
		end
		return
	end
	Nx.Map:VerifySettings()
	--
	self.Maps[1] = {}
	self.Maps[1] = self:Create (1)
	self.Dock:Create()

	self.Created = true
end

function Nx.Map:VerifySettings()
	for k,v in pairs (NxMapOptsDefaults) do
		if  Nx.db.profile.MapSettings[k] == nil then
			Nx.db.profile.MapSettings[k] = v
		end
	end

	local opts = Nx.db.profile.MapSettings.Maps

	for k, v in pairs (NXMapOptsMapsDefault) do
		if Nx.db.profile.MapSettings.Maps[k] == nil then
			Nx.db.profile.MapSettings.Maps[k] = v
		end
	end
end

--------

function Nx.Map:UpdateOptions (index)

	local src = Nx.Map.Maps[index]
	local dst = Nx.db.profile.MapSettings
	assert (src)
	assert (dst)

	dst.NXShowUnexplored = src.ShowUnexplored
	dst.NXKillShow = src.KillShow

	dst.NXBackgndAlphaFade = src.BackgndAlphaFade
	dst.NXBackgndAlphaFull = src.BackgndAlphaFull

	dst.NXArchAlpha = src.ArchAlpha
	dst.NXQuestAlpha = src.QuestAlpha

	dst.NXDotZoneScale = src.DotZoneScale
	dst.NXDotPalScale = src.DotPalScale
	dst.NXDotPartyScale = src.DotPartyScale
	dst.NXDotRaidScale = src.DotRaidScale
	dst.NXIconNavScale = src.IconNavScale
	dst.NXIconScale = src.IconScale

	local opts = src.CurOpts
	if opts then
--		Nx.prt ("Map UpdateOptions %s %s", src.MapPosX, src.MapPosY)
		opts.NXMapPosX = src.MapPosX
		opts.NXMapPosY = src.MapPosY
		opts.NXScale = src.Scale
	end
end

--------
-- Switch to a new set of options
-- self = map

function Nx.Map:SwitchOptions (id, startup)

--	Nx.prt ("Map SwitchOptions %s", id)

	local opts = Nx.db.profile.MapSettings.Maps
	local copts = opts[id] or opts[0]

	if copts ~= self.CurOpts then

--		Nx.prt ("Map SwitchOptions Diff %s", id)

		self.CurOpts = copts

		if copts.NXPlyrFollow then
			self:GotoPlayer()
		end

--		Nx.prtVar ("copts", copts)
--		Nx.prtVar ("inBG", Nx.InBG)

		if (not copts.NXPlyrFollow or startup) and copts.NXMapPosX then

--			Nx.prt ("Map SwitchOptions %s NXMapPosX %f %f %f", id, copts.NXMapPosX, copts.NXMapPosY, copts.NXScale)
--			Nx.prt(copts.NXMapPosX)
			self.MapPosX = copts.NXMapPosX
			self.MapPosY = copts.NXMapPosY
			self.Scale = copts.NXScale
			self.RealScale = self.Scale
			self.StepTime = 1

		elseif copts.NXPlyrFollow or Nx.InBG then

--			Nx.prt ("Map SwitchOptions GotoCurrentZone")
			self:GotoCurrentZone()
		end

		local mode = opts[id] and tostring (id) or ""
		self.Win:SwitchLayoutMode (mode)
	end
end

--------

function Nx.Map:GetOptionsT (index)

	local map = Nx.Map.Maps[index]
	local opts = Nx.db.profile.MapSettings.Maps
	return opts[map.UpdateMapID] or opts[0]
end

--------

function Nx.Map:GetOption (index, name)

	local map = Nx.Map.Maps[index]
	local opts = Nx.db.profile.MapSettings.Maps

	local id = map.UpdateMapID
	id = opts[id] and id or 0

	return opts[id][name]
end

--------

function Nx.Map:SetOption (index, name, value)

	local map = Nx.Map.Maps[index]
	local opts = NxMapOpts.NXMaps[index]

	local id = map.UpdateMapID
	id = opts[id] and id or 0

	opts[id][name] = value
end

--------

function Nx.Map:InitFuncs()

	self.Funcs = {
		[L["None"]] = function() end,
		[L["Goto"]] = self.SetTargetAtClick,
		[L["Show Player Zone"]] = self.GotoCurrentZone,
		[L["Show Selected Zone"]] = self.CenterMap,
		[L["Menu"]] = self.OpenMenu,
		[L["Zoom In"]] = self.ClickZoomIn,
		[L["Zoom Out"]] = self.ClickZoomOut,
	}
end

function Nx.Map:GetFuncs()

	local t = {}

	for name in pairs (self.Funcs) do
		tinsert (t, name)
	end

	sort (t)

	return t
end

--------
-- Call a map function from an option setting
-- self = map

function Nx.Map:CallFunc (optName)

	local name = Nx.db.profile.Map[optName]
	if name == L["None"] then
		return	-- return nil
	end

	local func = self.Funcs[name]
	if func then
		func (self)
	else
		Nx.prt ("Unknown map function %s", name)
	end

	return true	-- We did something
end

--------
-- Create a map

function Nx.Map:Test()
	local arr = {}
	for i=1,1000 do
		local znm = Nx.Map:GetMapNameByID(i)

		if not arr[znm] and znm then
			arr[znm] = i
		else
			if znm then
				Nx.prt("dupe " .. znm)
			else
				Nx.prt("no zone " .. i)
			end
		end
	end
end

function Nx.Map:Create (index)

	local Map = Nx.Map	
	local m = {}

	local opts = Nx.db.profile.MapSettings
	m.LOpts = opts		-- Local for map (stuff without a map mode)

	opts.NXPOIAtScale = opts.NXPOIAtScale or 1

	setmetatable (m, self)
	self.__index = self

	m.Tick = 0						-- Debug tick
	m.Debug = nil						-- Debug on
	m.DebugTime = nil
	m.DebugFullCoords = nil					-- Debug high precision map coords
	m.DebugAdjustScale = .1

	m.MapIndex = index
	m.MMOwn = Nx.db.profile.MiniMap.Own and index == 1

	m.ShowUnexplored = opts.NXShowUnexplored

	m.KillShow = opts.NXKillShow

	m.TitleH = 0
	m.PadX = 0
	m.Scale = .025
	m.RealScale = .025
	m.ScaleDraw = .025					-- Actual draw scale
	m.MapScale = 0.005--opts.NXMapScale or 1
	m.MapW = 150
	m.MapH = 140
	m.W = m.MapW + m.PadX * 2
	m.H = m.MapH + m.TitleH + 1
	m.LClickTime = 0
	m.MouseEnabled = true
	m.Scrolling = false
	m.StepTime = 0
	m.MapId = 0
	m.BaseScale = 1						-- Scale values, because instances are smaller
	m.PlyrX = 0
	m.PlyrY = 0
	m.PlyrRZX = 0
	m.PlyrRZY = 0
	m.PlyrDir = 0
	m.PlyrLastDir = 999
	m.PlyrSpeed = 0
	m.PlyrSpeedX = 0
	m.PlyrSpeedY = 0
	m.PlyrSpeedCalcTime = GetTime()
	m.MoveDir = 0
	m.MoveLastX = 0
	m.MoveLastY = 0
	m.ViewSavedData = {}
	m.MapPosX = 2200					-- World position of map
	m.MapPosY = -100
	m.MapPosXDraw = m.MapPosX				-- Actual draw position
	m.MapPosYDraw = m.MapPosY
	m.MapsDrawnOrder = {}					-- [index (1st is newest)] = map id
	m.MapsDrawnFade = {}					-- [map id] = fade
	m.MiniBlks = Nx.db.profile.Map.DetailSize
	m.ArchAlpha = opts.NXArchAlpha
	m.QuestAlpha = opts.NXQuestAlpha
	m.BackgndAlphaFade = opts.NXBackgndAlphaFade
	m.BackgndAlphaFull = opts.NXBackgndAlphaFull
	m.BackgndAlpha = 0					-- Current value
	m.BackgndAlphaTarget = m.BackgndAlphaFade		-- Target value
	m.WorldAlpha = 0
	m.DotZoneScale = opts.NXDotZoneScale
	m.DotPalScale = opts.NXDotPalScale
	m.DotPartyScale = opts.NXDotPartyScale
	m.DotRaidScale = opts.NXDotRaidScale	
	m.IconNavScale = opts.NXIconNavScale
	m.IconScale = opts.NXIconScale
	m.ArrowPulse = 1
	m.ArrowScroll = 0
	m.UpdateTargetDelay = 0
	m.UpdateTrackingDelay = 0

	m.Targets = {}
	m.TargetNextUniqueId = 1
	m.Tracking = {}
	m.TrackPlyrs = {}

	m.Data = {}
	m.IconFrms = {}
	m.IconFrms.Next = 1
	m.IconNIFrms = {}					-- Non interactive
	m.IconNIFrms.Next = 1
	m.IconStaticFrms = {}
	m.IconStaticFrms.Next = 1
	m.IconWQFrms = {}
	m.IconWQFrms.Next = 1
	
	m.TextFStrs = {}
	m.TextFStrs.Next = 1

	m.MMGathererUpdateDelay = 1

	-- Create Window

	Nx.Window:SetCreateFade (1, 0)

	local wname = m:GetWinName()

	local i = Nx.db.profile.Map.ShowTitle2 and 2 or 1

	local win = Nx.Window:Create (wname, nil, nil, nil, i)
	m.Win = win
	
	win:SetBGAlpha (0, 1)

	win:CreateButtons (true)
	win:InitLayoutData (nil, -.0001, -.4, -.19, -.3, 1)

	win:InitLayoutData ("91", -.0001, -.4, -.19, -.3, 1)
	win:InitLayoutData ("93", -.0001, -.4, -.19, -.3, 1)
	win:InitLayoutData ("519", -.0001, -.4, -.19, -.3, 1)
	win:InitLayoutData ("112", -.0001, -.4, -.19, -.3, 1)
	win:InitLayoutData ("397", -.0001, -.4, -.19, -.3, 1)
	win:InitLayoutData ("169", -.0001, -.4, -.19, -.3, 1)
	win:InitLayoutData ("423", -.0001, -.4, -.19, -.3, 1)
	win:InitLayoutData ("128", -.0001, -.4, -.19, -.3, 1)
	win:InitLayoutData ("417", -.0001, -.4, -.19, -.3, 1)
	win:InitLayoutData ("275", -.0001, -.4, -.19, -.3, 1)
	win:InitLayoutData ("206", -.0001, -.4, -.19, -.3, 1)
	win:InitLayoutData ("92", -.0001, -.4, -.19, -.3, 1)
	win:InitLayoutData ("623", -.0001, -.4, -.19, -.3, 1)

	win:SetUser (m, self.OnWin)
	win.UserUpdateFade = m.WinUpdateFade

	win.Frm:SetToplevel (true)
	win.Frm.NxMap = m

	m.StartupShown = win:IsShown()
	win.Frm:Show()	
	
	-- Create main frame

	local f = CreateFrame ("Frame", nil, UIParent)
	m.Frm = f
	f.NxMap = m
	
	--WorldMap_HijackTooltip(m.Frm)
	
	win:Attach (f, 0, 1, 0, 1)
	LibStub("AceEvent-3.0"):Embed(Nx.Map)
	--Nx.Map:RegisterEvent ("WORLD_MAP_UPDATE", "OnEvent")
	Nx.Map:RegisterEvent ("PLAYER_REGEN_DISABLED", "OnEvent")
	Nx.Map:RegisterEvent ("PLAYER_REGEN_ENABLED", "OnEvent")
	Nx.Map:RegisterEvent ("ZONE_CHANGED", "OnEvent")
	Nx.Map:RegisterEvent ("ZONE_CHANGED_INDOORS", "OnEvent")
	Nx.Map:RegisterEvent ("ZONE_CHANGED_NEW_AREA", "OnEvent")

	f:SetScript ("OnMouseDown", self.OnMouseDown)
	f:SetScript ("OnMouseUp", self.OnMouseUp)
	f:SetScript ("OnMouseWheel", self.OnMouseWheel)
	f:EnableMouse (true)
	f:EnableMouseWheel (true)

	f:SetMovable (true)
	f:SetResizable (true)

	f:SetFrameStrata ("LOW")
	f:SetWidth (m.W)
	f:SetHeight (m.H)
	f:SetResizeBounds (50, 50)

	local t = f:CreateTexture()
	t:SetColorTexture (0, 0, 0, .2)
	t:SetAllPoints (f)
	f.texture = t

	f:Show()

	-- Create text frame

	local tsf = CreateFrame ("ScrollFrame", nil, f)
	m.TextScFrm = tsf

	tsf:SetAllPoints (f)

	local tf = CreateFrame ("Frame", nil, tsf)
	m.TextFrm = tf
	tf:SetPoint ("TOPLEFT", 0, 0)
	tf:SetWidth (100)
	tf:SetHeight (100)

--	tf:SetAllPoints (f)
	tsf:SetScrollChild (tf)

	-- Tip

	m:CreateLocationTip()

	-- Create tool bar

	m:CreateToolBar()

	-- Create buttons

	local bw, bh = win:GetBorderSize()

	local function func (self, but)
		self.LOpts.NXAutoScaleOn = but:GetPressed()
	end

	m.ButAutoScaleOn = Nx.Button:Create (win.Frm, "MapAutoScale", nil, nil, -20, -bh, "TOPRIGHT", 12, 12, func, m)
	m.ButAutoScaleOn:SetPressed (opts.NXAutoScaleOn)

	-- Create menu

	local menu = Nx.Menu:Create (f)
	m.Menu = menu
 	menu:AddItem (0, L["Goto"], self.Menu_OnGoto, m)
	menu:AddItem (0, L["Clear Goto"], self.Menu_OnClearGoto, m)
	menu:AddItem (0, L["Save Map Scale"], self.Menu_OnScaleSave, m)
	menu:AddItem (0, L["Restore Map Scale"], self.Menu_OnScaleRestore, m) 	
    menu:AddItem (0, "", nil, self)
	m.MenuIPlyrFollow = menu:AddItem (0, L["Follow You"], self.Menu_OnPlyrFollow, m)

	local item = menu:AddItem (0, L["Select Cities Last"], self.SetLevelWorldHotspots, m)
	item:SetChecked (m, "NXCitiesUnder")

	m.MenuIMonitorZone = menu:AddItem (0, L["Monitor Zone"], self.Menu_OnMonitorZone, m)
	m.MenuIInstanceMaps = menu:AddItem (0, L["Show Instance Map"], self.Menu_InstanceMap, m)

	menu:AddItem (0, "", nil, self)

	-- Create route sub menu

	local routeMenu = Nx.Menu:Create (f)
	menu:AddSubMenu (routeMenu, L["Route..."])

	local function func (self)
		self:RouteGathers()
	end
	local item = routeMenu:AddItem (0, L["Current Gather Locations"], func, m)

	local function func (self)
		self:RouteTargets()
	end
	local item = routeMenu:AddItem (0, L["Current Goto Targets"], func, m)

	local function func (self)
		self.ShowUnexplored = false
		self:UpdateOverlayUnexplored()
		self:TargetOverlayUnexplored()
		self:RouteTargets()
	end

	routeMenu:AddItem (0, L["Unexplored Locations"], func, m)

	local function func (self)
		self:ReverseTargets()
	end

	routeMenu:AddItem (0, L["Reverse Targets"], func, m)

	local item = routeMenu:AddItem (0, L["Recycle Reached Targets"])
	item:SetChecked (Nx.db.profile.Route, "Recycle")

	local item = routeMenu:AddItem (0, L["Gather Target Radius"])
	item:SetSlider (Nx.db.profile.Route, 7, 300, nil, "GatherRadius")

	local item = routeMenu:AddItem (0, L["Gather Merge Radius"])
	item:SetSlider (Nx.db.profile.Route, 0, 100, nil, "MergeRadius")

	-- Create show sub menu

	local showMenu = Nx.Menu:Create (f)
	menu:AddSubMenu (showMenu, L["Show..."])

	showMenu:AddItem (0, L["Show Player Zone"], self.Menu_OnShowPlayerZone, m)

	local function func (self)
		self.Guide:UpdateGatherFolders()
	end

	local item = showMenu:AddItem (0, L["Show Herb Locations"], func, m)
	m.MenuIShowHerb = item
	item:SetChecked (Nx.db.char.Map, "ShowGatherH")
	local item = showMenu:AddItem (0, L["Show Mining Locations"], func, m)
	m.MenuIShowMine = item
	item:SetChecked (Nx.db.char.Map, "ShowGatherM")

	local function func (self)
		self.Guide.POIDraw = nil
		Nx.Map.Guide:ClearShowFolders()
		Nx.Map.Guide:UpdateMapIcons()
	end

	local item = showMenu:AddItem (0, L["Show Continent POIs"], func, m)
	item:SetChecked (Nx.db.char.Map, "ShowContPois")
	local item = showMenu:AddItem (0, L["Show Guide POIs"], func, m)
	item:SetChecked (Nx.db.char.Map, "ShowMailboxes")
	local item = showMenu:AddItem (0, L["Show Custom Icons"], func, m)
	item:SetChecked (Nx.db.char.Map, "ShowCustom")
	local item = showMenu:AddItem(0, L["Show Instance Raid Bosses"], func, m)
	item:SetChecked (Nx.db.char.Map, "ShowRaidBoss")
--	local item = showMenu:AddItem(0, L["Show World Quests"], func, m)
--	item:SetChecked (Nx.db.char.Map, "ShowWorldQuest")
--	local item = showMenu:AddItem(0, L["Show Archaeology Blobs"], func, m)	
--	item:SetChecked (Nx.db.char.Map, "ShowArchBlobs")	
	local item = showMenu:AddItem(0, L["Show Quest Blobs"], func, m)
	item:SetChecked (Nx.db.char.Map, "ShowQuestBlobs")

	local function func (self, item)
		self.ShowUnexplored = item:GetChecked()
	end

	local item = showMenu:AddItem (0, L["Show Unexplored Areas"], func, m)
	item:SetChecked (m.ShowUnexplored)

	m.MenuIShowWorld = showMenu:AddItem (0, L["Show World"], self.Menu_OnShowWorld, m)


	local function forceShowCont (self)
		self.ScanContinentsMod = 10
	end

	local item = showMenu:AddItem (0, L["Show Cities"], forceShowCont, Map)
	item:SetChecked (Nx.db.profile.Map, "ShowCCity")

	local item = showMenu:AddItem (0, L["Show Towns"], forceShowCont, Map)
	item:SetChecked (Nx.db.profile.Map, "ShowCTown")

	local item = showMenu:AddItem (0, L["Show Extras"], forceShowCont, Map)
	item:SetChecked (Nx.db.profile.Map, "ShowCExtra")

	local item = showMenu:AddItem (0, L["Show Kill Icons"], self.Menu_OnShowKills, m)
	item:SetChecked (m.KillShow)

	-- Create minimap sub menu

	if not Nx.Free then

		local mmmenu = Nx.Menu:Create (f)

		menu:AddSubMenu (mmmenu, L["Minimap..."])

		local function func (self, item)
			self.LOpts.NXMMFull = item:GetChecked()
			self.MMZoomChanged = true
		end

		local item = mmmenu:AddItem (0, L["Full Size"], func, m)
		self.MMMenuIFull = item
		item:SetChecked (opts.NXMMFull)

		local function func (self, item)
			self.LOpts.NXMMAlpha = item:GetSlider()
		end

		local item = mmmenu:AddItem (0, L["Transparency"], func, m)
		item:SetSlider (opts.NXMMAlpha, 0, 1)

		local function func (self, item)
			self.LOpts.NXMMDockScale = item:GetSlider()
			self.MMZoomChanged = true
		end

		local item = mmmenu:AddItem (0, L["Docked Scale"], func, m)
		item:SetSlider (opts.NXMMDockScale, .01, 3)

		local function func (self, item)
			self.LOpts.NXMMDockScaleBG = item:GetSlider()
			self.MMZoomChanged = true
		end

		local item = mmmenu:AddItem (0, L["Docked Scale In BG"], func, m)
		item:SetSlider (opts.NXMMDockScaleBG, .01, 3)

		local function func (self, item)
			self.LOpts.NXMMDockAlpha = item:GetSlider()
		end

		local item = mmmenu:AddItem (0, L["Docked Transparency"], func, m)
		item:SetSlider (opts.NXMMDockAlpha, 0, 1)

		local function func (self, item)
			self.LOpts.NXMMDockOnAtScale = item:GetSlider()
		end

		local item = mmmenu:AddItem (0, L["Docking Below Map Scale"], func, m)
		item:SetSlider (opts.NXMMDockOnAtScale, 0, 5)
	end

	-- Create scale sub menu

	local smenu = Nx.Menu:Create (f)

	menu:AddSubMenu (smenu, L["Scale..."])

	local item = smenu:AddItem (0, L["Auto Scale Min"])
	item:SetSlider (opts, .01, 10, nil, "NXAutoScaleMin")

	local item = smenu:AddItem (0, L["Auto Scale Max"])
	item:SetSlider (opts, .25, 10, nil, "NXAutoScaleMax")

	local item = smenu:AddItem (0, L["Zone Dot Scale"], self.Menu_OnDotZoneScale, m)
	item:SetSlider (m.DotZoneScale, 0.1, 10)

	local item = smenu:AddItem (0, L["Friend/Guild Dot Scale"], self.Menu_OnDotPalScale, m)
	item:SetSlider (m.DotPalScale, 0.1, 10)

	local item = smenu:AddItem (0, L["Party Dot Scale"], self.Menu_OnDotPartyScale, m)
	item:SetSlider (m.DotPartyScale, 0.1, 10)

	local item = smenu:AddItem (0, L["Raid Dot Scale"], self.Menu_OnDotRaidScale, m)
	item:SetSlider (m.DotRaidScale, 0.1, 10)

	local item = smenu:AddItem (0, L["Icon Scale"], self.Menu_OnIconScale, m)
	item:SetSlider (m.IconScale, 0.1, 10)

	local item = smenu:AddItem (0, L["Navigation Icon Scale"], self.Menu_OnIconNavScale, m)
	item:SetSlider (m.IconNavScale, 0.1, 10)

	local function func (self, item)
		self.LOpts.NXDetailScale = item:GetSlider()
	end

	local item = smenu:AddItem (0, L["Details At Scale"], func, m)
	item:SetSlider (opts.NXDetailScale, .05, 10)

	local item = smenu:AddItem (0, L["Gather Icons At Scale"])
	item:SetSlider (Nx.db.profile.Map, .01, 10, nil, "IconGatherAtScale")

	local item = smenu:AddItem (0, L["POI Icons At Scale"])
	item:SetSlider (opts, .1, 10, nil, "NXPOIAtScale")

	local ismenu = Nx.Menu:Create (f)

	menu:AddSubMenu (ismenu, L["Instance Scale..."])
	
	local item = ismenu:AddItem (0, L["Player Arrow"])
	item:SetSlider (Nx.db.profile.Map, 1, 50, nil, "InstancePlayerSize")

	local item = ismenu:AddItem (0, L["Group Player Size"])
	item:SetSlider (Nx.db.profile.Map, 1, 50, nil, "InstanceGroupSize")

	local item = ismenu:AddItem (0, L["Raid Boss Size"])
	item:SetSlider (Nx.db.profile.Map, 1, 50, nil, "InstanceBossSize")
	
	local item = ismenu:AddItem (0, L["Icon Scaling Size"])
	item:SetSlider (Nx.db.profile.Map, 1, 50, nil, "InstanceScale")
	
	-- Create transparency sub menu

	local tmenu = Nx.Menu:Create (f)
	m.TransMenu = tmenu

	menu:AddSubMenu (tmenu, L["Transparency..."])

	local item = tmenu:AddItem (0, L["Detail Transparency"], self.Menu_OnDetailAlpha, m)
	item:SetSlider (opts.NXDetailAlpha, .25, 1)

	local item = tmenu:AddItem (0, L["Fade In Transparency"], self.Menu_OnBackgndAlphaFull, m)
	item:SetSlider (m.BackgndAlphaFull, .25, 1)

	local item = tmenu:AddItem (0, L["Fade Out Transparency"], self.Menu_OnBackgndAlphaFade, m)
	item:SetSlider (m.BackgndAlphaFade, 0, 1)

	local function func (self)
		self.Guide:UpdateGatherFolders()
	end

	local item = tmenu:AddItem (0, L["Gather Icon Transparency"], func, m)
	item:SetSlider (Nx.db.profile.Map, .2, 1, nil, "IconGatherA")

	local item = tmenu:AddItem (0, L["POI Icon Transparency"])
	item:SetSlider (Nx.db.profile.Map, .2, 1, nil, "IconPOIAlpha")

	local function func (self, item)
		self.LOpts.NXUnexploredAlpha = item:GetSlider()
	end

	local item = tmenu:AddItem (0, L["Unexplored Transparency"], func, m)
	item:SetSlider (opts.NXUnexploredAlpha, 0, .9)

	local item = tmenu:AddItem(0, L["Archaeology Blob Transparency"],self.Menu_OnArchAlpha, m)
	item:SetSlider (m.ArchAlpha,0,1)

	local item = tmenu:AddItem(0, L["Quest Blob Transparency"],self.Menu_OnQuestAlpha, m)
	item:SetSlider (m.QuestAlpha,0,1)

	-- Options menu

	local item = menu:AddItem (0, L["Options..."], self.Menu_OnOptions, m)

	-- Debug menu

	if Nx.db.profile.Debug.DebugMap then

		m.DebugMap = true

		local dbmenu = Nx.Menu:Create (f)

		menu:AddItem (0, "", nil, self)
		menu:AddSubMenu (dbmenu, L["Debug..."])

		local function func (self, item)
			self.Debug = item:GetChecked()
		end

		local item = dbmenu:AddItem (0, L["Map Debug"], func, m)
		item:SetChecked (false)

--[[
		Nx.prt ("*** DebugHotspots is ON")
		m["DebugHotspots"] = true
--]]
		local item = dbmenu:AddItem (0, L["Hotspots"], func, m)
		item:SetChecked (m, "DebugHotspots")

		dbmenu:AddItem (0, L["Hotspots pack"], self.PackHotspotsDebug, m)

		local function func (self, item)
			self.DebugTime = item:GetChecked()
		end

		local item = dbmenu:AddItem (0, L["Map Debug Time"], func, m)
		item:SetChecked (false)

		local item = dbmenu:AddItem (0, L["Map Full Coords"], self.Menu_OnMapDebugFullCoords, m)
		item:SetChecked (m.DebugFullCoords)
		if Nx.Quest then
			local item = dbmenu:AddItem (0, L["Quest Debug"], self.Menu_OnQuestDebug, m)
			item:SetChecked (Nx.Quest.Debug)
		end

		local function func (self, item)
			self.DebugScale = item:GetSlider()
		end

		local item = dbmenu:AddItem (0, L["Scale"], func, m)
		item:SetSlider (0, 4, 6)
		
		local item = dbmenu:AddItem (0, L["ZWOff"], function (self, item)
			self.DebugMZWOff = item:GetSlider()
		end, m)
		item:SetSlider (0, -400, 400)
		
		local item = dbmenu:AddItem (0, L["ZHOff"], function (self, item)
			self.DebugMZHOff = item:GetSlider()
		end, m)
		item:SetSlider (0, -400, 400)
		
		local item = dbmenu:AddItem (0, L["XOff"], function (self, item)
			self.DebugMXOff = item:GetSlider()
		end, m)
		item:SetSlider (0, -400, 400)
		
		local item = dbmenu:AddItem (0, L["YOff"], function (self, item)
			self.DebugMYOff = item:GetSlider()
		end, m)
		item:SetSlider (0, -400, 400)
		
		local item = dbmenu:AddItem (0, L["PXOff"], function (self, item)
			self.DebugPXOff = item:GetSlider()
		end, m)
		item:SetSlider (0, -400, 400)
		
		local item = dbmenu:AddItem (0, L["PYOff"], function (self, item)
			self.DebugPYOff = item:GetSlider()
		end, m)
		item:SetSlider (0, -400, 400)
	end

	-- Create player icon menu

	local menu = Nx.Menu:Create (f)
	m.PIconMenu = menu

	menu:AddItem (0, L["Whisper"], self.Menu_OnWhisper, m)
	menu:AddItem (0, L["Invite"], self.Menu_OnInvite, m)
	local item = menu:AddItem (0, L["Track Player"], self.Menu_OnTrackPlyr, m)
	local item = menu:AddItem (0, L["Remove From Tracking"], self.Menu_OnRemoveTracking, m)

	menu:AddItem (0, L["Report Player AFK"], self.Menu_OnReportPlyrAFK, m)
--	menu:AddItem (0, "Report All AFK", self.Menu_OnReportAllAFK, m)

	menu:AddItem (0, "")

	local item = menu:AddItem (0, L["Grow Conflict Bars"], self.Menu_OnGrowConflictBars, m)
	item:SetChecked (true)
	m.BGGrowBars = true

	-- Create general icon menu

	m:CreateIconMenu (f)

	-- Create BG icon menu

	m.BGIncNum = 0

	local menu = Nx.Menu:Create (f)
	m.BGIconMenu = menu

	local BGMessages = {		-- Battleground messages. Menu text, message text
		L["Incoming"], L["Inc"],
		L["Clear"], L["Clear"],
		L["Help"], L["Help"],
		L["Attack"], L["Attack"],
		L["Guard"], L["Guard"],
		L["Well Defended"], L["Well Defended"],
		L["Losing"], L["Losing"],
	}

	for n = 1, #BGMessages, 2 do

		local function func (self)
			self:BGMenu_Send (BGMessages[n + 1])	-- Inherit n from loop
		end

		menu:AddItem (0, BGMessages[n], func, m)
	end

	menu:AddItem (0, L["Report Status"], self.BGMenu_OnStatus, m)

	-- Create player icon

	local plf = CreateFrame ("Frame", nil, f)
	m.PlyrFrm = plf
	plf.NxMap = m

	plf:SetWidth (3)
	plf:SetHeight (3)

	t = plf:CreateTexture()
	plf.texture = t
	t:SetTexture ("Interface\\Minimap\\MinimapArrow")
	t:SetAllPoints (plf)
	t:SetSnapToPixelGrid(false)
	t:SetTexelSnappingBias(0)
	
	plf:SetPoint ("CENTER", 0, (m.TitleH - 1) * -.5)
	plf:Show()

	-- Init map frames

	m:InitFrames()

	-- Test

--[[
	m:InitIconType ("Test", nil, "Interface\\TargetingFrame\\TargetDead", 64, 64)

	for i = 1, 100, .2 do
		m:AddIconData ("Test", i, 30, 0)
	end
--]]

--[[
	m:InitIconType ("Test2", nil, 64, 64)

	for i = 1, 100, .2 do
		m:AddIconData ("Test2", i, 10, "00ff00")
	end
--]]

--[[
	m:InitIconType ("TestZR", "ZR")

	for i = 1, 10, 2 do
		m:AddIconRect ("TestZR", i, 5, i+1, 6, "00ff0080")
	end
--]]

	Nx.Map.RMapId = 9000		-- Safe default
	Nx.Map.UpdateMapID = 9000

	m:SwitchOptions (-1, true)

	m:UpdateAll()

	m.Guide = Map.Guide:Create (m)

	--

	self.MMFrm = _G["Minimap"]
	assert (self.MMFrm)

	m:MinimapOwnInit()
	-- Force player to be shown after init done and not in BG

	local function func (self)
		if not Nx.InBG then
			self:GotoPlayer()
		end
	end

	MapIShow = Nx:ScheduleTimer(func, 1, m)

	-- Show Quest Log - restore World tooltip
	--[[hooksecurefunc ("ShowUIPanel", function(...) 
		WorldMap_RestoreTooltip()
	end)
	hooksecurefunc ("HideUIPanel", function(...) 
		WorldMap_HijackTooltip(m.Frm)
	end)]]--
	
	f:SetScript ("OnUpdate", self.OnUpdate)
	
	return m
end

--------

function Nx.Map:GetWinName()
	return "NxMap" .. self.MapIndex
end

--------
-- Create map tool bar

function Nx.Map:CreateToolBar()

	local bar = Nx.ToolBar:Create (self:GetWinName().."TB", self.Frm, 22, true, true)
	self.ToolBar = bar

	bar:SetUser (self)

--	bar.Frm:SetFrameLevel (self.Frm:GetFrameLevel() + 30)
	if not Nx.BarData then
		Nx.BarData = {
			{ "MapZIn", L["Zoom In"], self.OnButZoomIn, false },
			{ "MapZOut", L["Zoom Out"], self.OnButZoomOut, false },
			{ "MapGuide", L["Guide"], self.OnButToggleGuide, false },
			{ "MapCombat", L["Combat"], self.OnButToggleCombat, false },
			{ "MapEvents", L["Events"], self.OnButToggleEvent, false },
		}
	end
	for i, b in ipairs (Nx.BarData) do

		if Nx.Free and i > 3 then
			break
		end
		bar:AddButton (b[1], b[2], nil, b[3], b[4])
	end

	bar:Update()

	self:UpdateToolBar()
end

function Nx.Map:UpdateToolBar()

	local frm = self.ToolBar.Frm
	if Nx.db.profile.Map.ShowToolBar then
		frm:Show()
	else
		frm:Hide()
	end
end

function Nx.Map:CreateIconMenu (frm)

	-- Create general icon menu

	local menu = Nx.Menu:Create (frm)
	self.GIconMenu = menu

	self.GIconMenuITogInst = menu:AddItem (0, L["Toggle Instance Map"], self.GMenu_OnTogInst, self)
	self.GIconMenuIFindNote = menu:AddItem (0, L["Find Note"], self.GMenu_OnFindNote, self)

	menu:AddItem (0, L["Goto"], self.GMenu_OnGoto, self)
	menu:AddItem (0, L["Clear Goto"], self.Menu_OnClearGoto, self)
	menu:AddItem (0, L["Paste Link"], self.GMenu_OnPasteLink, self)
end

--------

function Nx.Map:CreateLocationTip()

	local f = CreateFrame ("Frame", "NxMapTip", self.Frm)
--	f.NxInst = self
	self.LocTipFrm = f

	f:SetClampedToScreen(true)

--	f:ClearAllPoints()
--	f:SetPoint ("BOTTOMLEFT", 0, 0)

	local t = f:CreateTexture()
	f.texture = t
	t:SetAllPoints (f)
	t:SetColorTexture (0, 0, 0, .85)

	-- Font strings

	local fstrs = {}
	self.LocTipFStrs = fstrs

	local h = Nx.Font:GetH ("Font.MapLoc")

	for n = 1, 4 do
		local fstr = f:CreateFontString()
		tinsert (fstrs, fstr)
		fstr:SetFontObject ("NxFontMapLoc")
		fstr:SetJustifyH ("LEFT")
	end
end

function Nx.Map:SetLocationTip (tipStr)

	local f = self.LocTipFrm
	local a = Nx.db.profile.Map.LocTipAnchor
	if tipStr and a ~= "None" then

		local ar = Nx.db.profile.Map.LocTipAnchorRel
		ar = ar == "None" and a or ar
		f:ClearAllPoints()
		f:SetPoint (a, self.Frm, ar)

		local h = Nx.Font:GetH ("Font.MapLoc")
		local fstrs = self.LocTipFStrs
		local i = 1
		local textW = 0

		for s in gmatch (tipStr, "(%C+)") do		-- gmatch makes garbage!
--			Nx.prt (s)
			local fstr = fstrs[i]
			fstr:SetPoint ("TOPLEFT", 2, 0 - (i - 1) * h)
			fstr:SetText (s)
			textW = max (textW, fstr:GetStringWidth())
			i = i + 1
		end

		for n = i, #fstrs do
			fstrs[n]:SetText ("")
		end

--		Nx.prt (textW)

--		f:SetFrameStrata ("DIALOG")
		f:SetWidth (4 + textW)
		f:SetHeight (2 + (i - 1) * h)
		f:Show()

	else
		f:Hide()
	end
end

-------------------------------------------------------

--------
-- Startup so show map

function Nx.Map:StartupZoom()
--	local map = self:GetMap (1)
--	map:GotoCurrentZone()
end

--------
-- Main frame update event handler

function Nx.Map:MainOnUpdate (elapsed)

	if self.Created then

		local map = self:GetMap (1)
		local win = map.Win
		local show, showsv = win:IsShown()

--		if not show and GameTooltip:IsOwned (win.Frm) then
--			GameTooltip:Hide()
--		end

		if not show then

			if showsv and not win:IsCombatHidden() then	-- We've been hidden, but not by us (Escape key)?
				win:Show()
				map:RestoreSize()
				return
			end

			self.OnUpdate (map.Frm, elapsed)
		end
	end
end

--------

function Nx.Map:OnWin (typ)

--	Nx.prt ("MapOnWin %s", typ)

	if typ == "SizeNorm" then
		self:RestoreSize()

	elseif typ == "SizeMax" then

		if WorldMapFrame:IsShown() then
			HideUIPanel (WorldMapFrame)
		end
		tinsert (UISpecialFrames, self:GetWinName())

		self:AttachWorldMap()

	elseif typ == "Close" then

	end
end

--------
--

function Nx.Map:AttachWorldMap()
--[[
	if not Nx.db.profile.Map.WOwn then
		return
	end
	local f = _G["WorldMapButton"]
	if f then

--		Nx.prt ("AttachWorldMap")

		self.WorldMapFrm = f
		self.WorldMapFrmParent = f:GetParent()
		self.WorldMapFrmScale = f:GetScale()
		
		f:SetParent (self.TextFrm)				
		
		f:Show()

		f:EnableMouse (false)

		self:SetWorldMapIcons (.001)

		local tipf = _G["GameTooltip"]
		if tipf then
			tipf:SetParent (self.Frm)			
		end

		local af = _G["WorldMapFrameAreaFrame"]
		if af then
			af:Hide()
--			af:SetParent (self.Frm)
--			af:SetPoint ("TOP", self.Frm, "TOP", 0, 0)
		end

--		Gatherer.MapNotes.MapDraw = function() Nx.prt ("Gath mapdraw") end

		-- Remove leftovers
		for n = 1, NUM_WORLDMAP_POIS do
			local f = _G["WorldMapFramePOI" .. n]
			f:Hide()
		end

		self.WorldMapFrmMapId = 0
	end
]]--
end

--------
--

function Nx.Map:DetachWorldMap()
	---- THIS DOES NOT WORK, UNTIL FIXED DISABLING IT
--[[	
	local f = self.WorldMapFrm

	if f then

--		Nx.prt ("DetachWorldMap")

		self.WorldMapFrm = nil

		f:SetParent (self.WorldMapFrmParent)
		f:SetScale (self.WorldMapFrmScale)
		f:SetPoint ("TOPLEFT", "WorldMapDetailFrame", "TOPLEFT", 0, 0)
		f.GetCenter = self.WorldMapFrmGetCenter

		f:EnableMouse (true)

		self:SetWorldMapIcons (1)

		local tipf = _G["GameTooltip"]
		if tipf then
			tipf:SetParent (self.WorldMapFrmParent)
			tipf:SetFrameStrata ("TOOLTIP")
		end

		local af = _G["WorldMapFrameAreaFrame"]
		if af then
			af:Show()
--			af:SetParent (f)
--			af:SetPoint ("TOP", f, "TOP", 0, -10)
		end

	end
]]--
end

--------
-- Update Blizzard world map frame if we grabbed it

function Nx.Map:UpdateWorldMap()

	local f = self.WorldMapFrm

	for factionIndex = 1, GetNumFactions() do
		local name, description, standingId, bottomValue, topValue, earnedValue, atWarWith,canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild = GetFactionInfo(factionIndex)
		if (name == L["Operation: Shieldwall"]) or (name == L["Dominance Offensive"]) then
			self.MapWorldInfo[857].Overlay = "krasarang_terrain1"
		end
	end

	if f then

		if self.StepTime ~= 0 or self.Scrolling or IsShiftKeyDown() then
			f:Hide()
		else

			local tipf = _G["GameTooltip"]
			if tipf then
				tipf:SetFrameStrata ("TOOLTIP")
			end
			local af = _G["WorldMapFrameAreaFrame"]
			if af then
				af:SetFrameStrata ("HIGH")
			end

			f:Show()

			self:ClipZoneFrm (self.Cont, self.Zone, f, 1)
			f:SetFrameLevel (self.Level)			
			if self.WorldMapFrmMapId ~= self.MapId then
--				Nx.prt ("mapid %s", self.MapId)
				self.WorldMapFrmMapId = self.MapId
				self:SetChildLevels (f, self.Level + 1)
				self.Level = self.Level + 4
			end
		end

		for k, v in ipairs (_G["MAP_VEHICLES"]) do
			v:SetScale (.001)
		end
	end
end

--------
-- Recursively set child levels

function Nx.Map:SetChildLevels (frm, lvl)

	local ch = { frm:GetChildren() }

	for n, chf in pairs (ch) do

		chf:SetFrameLevel (lvl)

		if chf:GetNumChildren() > 0 then
			self:SetChildLevels (chf, lvl + 1)
		end
	end
end

--------
-- Set scale on world map icons

function Nx.Map:SetWorldMapIcons (scale)

	for n = 1, MAX_PARTY_MEMBERS do
		local f = _G["WorldMapParty" .. n]
		if f then
			f:SetScale (scale)
		end
	end
	for n = 1, MAX_RAID_MEMBERS do
		local f = _G["WorldMapRaid" .. n]
		if f then
			f:SetScale (scale)
		end
	end
	local flags = GetNumBattlefieldFlagPositions()
	for n = 1, flags do
		local f = _G["WorldMapFlag" .. n]
		if f then
			f:SetScale (scale)
		end
	end

	for k, f in ipairs (_G["MAP_VEHICLES"]) do
		f:SetScale (scale)
	end

	for k, name in ipairs (Nx.Map.WorldMapHideNames) do

		local f = _G[name]
		if f then
			f:SetScale (scale)
		end
	end
end

--------
--

function Nx.Map:OnButZoomIn()
	self:SetScaleOverTime (2)
end

function Nx.Map:OnButZoomOut()
	self:SetScaleOverTime (-2)
end

function Nx.Map:OnButToggleGuide (but)
	self.Guide:ToggleShow()
end

function Nx.Map:OnButToggleEvent (but)
	Nx.UEvents.List:Open()
end

--------
-- Init static map frames

function Nx.Map:InitFrames()

	local f = self.Frm
	local m = self

	-- Create map zone tile frames

	self.TileFrms = {}

	local tf

	for i = 1, 150 do

		tf = CreateFrame ("Frame", nil, f)
		m.TileFrms[i] = tf

		local t = tf:CreateTexture()
		t:SetAllPoints (tf)
		tf.texture = t
	end

	-- Init continent frames

	Nx.ContBlks = {
		{
			0,1,1,0,
			0,1,1,0,
			0,1,1,0
		},
		{
			0,1,1,0,
			0,1,1,0,
			0,1,1,0
		},
		{
			1,1,1,1,
			1,1,1,1,
			1,1,1,1
		},
		{
			1,1,1,1,
			1,1,1,1,
			1,1,1,1
		}
	}

	self.ContFrms = {}

	for n = 1, Nx.Map.ContCnt do

		self.ContFrms[n] = {}

		local mapFileName = self.MapInfo[n].FileName
		local texi = 1

--		Nx.prtD ("Map Update ".. mapFileName)
		local tileX = self.MapInfo[n].TileX or 4
		local tileY = self.MapInfo[n].TileY or 3
		
		local numtiles = tileX * tileY
		
		for i = 1, numtiles do

			if Nx.ContBlks[n][i] ~= 0 then

				local cf = CreateFrame ("Frame", nil, f)
				m.ContFrms[n][i] = cf

				local t = cf:CreateTexture()
				t:SetAllPoints (cf)
				cf.texture = t

				if n == 0 then
					t:SetTexture ("Interface\\AddOns\\Carbonite\\Gfx\\Map\\Cont\\".."Kal"..texi)
					texi = texi + 1
				else
					t:SetTexture ("Interface\\WorldMap\\"..mapFileName.."\\"..mapFileName..i)
				end
				
				t:SetSnapToPixelGrid(false)
				t:SetTexelSnappingBias(0)
			end
		end
	end

	-- Create mini frames

	self.MiniFrms = {}

	for n = 1, self.MiniBlks ^ 2 do

		local tf = CreateFrame ("Frame", nil, f)
		m.MiniFrms[n] = tf

		local t = tf:CreateTexture()
		tf.texture = t
		t:SetAllPoints (tf)
		
		t:SetSnapToPixelGrid(false)
		t:SetTexelSnappingBias(0)
	end

	self:InitHotspots()
end

--------
-- Init hotspots

function Nx.Map:InitHotspots()

	local quad = {}
	self.WorldHotspots = quad
	local quadCity = {}
	self.WorldHotspotsCity = quadCity

	for contN = 1, Nx.Map.ContCnt do

		cname = self:GetWorldContinentInfo (contN)
		if not cname then
			break
		end
		for _,zoneN in pairs(Nx.Map.MapZones[contN]) do
			zname, zx, zy, zw, zh = self:GetWorldZoneInfo (contN, zoneN)
			if not zx then
				break
			end

			local color, infoStr = self:GetMapNameDesc (zoneN)
			local tipStr = format ("%s, %s%s (%s)", L[cname], color, zname, infoStr)

			local loc = Nx.MapWorldHotspots[nxz]	-- Old way
			local locSize = 4
			local mapId = zoneN

			if not loc then

				loc = Nx.MapWorldHotspots2[mapId]
				if loc then
					locSize = 12
				else
					loc = format ("%c%c%c%c", 85, 85, 135, 135)
				end
			end

			for n = 0, 100 do

				local locN = n * locSize + 1

				local loc1 = strsub (loc, locN, locN + locSize - 1)
				if loc1 == "" then
					break
				end

				local zx, zy, zw, zh

				if locSize == 4 then
					zx, zy, zw, zh = Nx.Map:UnpackLocRect (loc1)
				else
					zx = tonumber (strsub (loc1, 1, 3), 16) * 100 / 4095
					zy = tonumber (strsub (loc1, 4, 6), 16) * 100 / 4095
					zw = tonumber (strsub (loc1, 7, 9), 16) * 1002 / 4095
					zh = tonumber (strsub (loc1, 10, 12), 16) * 668 / 4095
				end

				local spot = {}

				local wzone = self:GetWorldZone (mapId)

				if wzone.City or wzone.StartZone then
					tinsert (quadCity, spot)
				else
					tinsert (quad, spot)
				end

				spot.MapId = mapId
				
				spot.x = tonumber (strsub (loc1, 1, 3), 16)
				spot.y = tonumber (strsub (loc1, 4, 6), 16)
				spot.zx = zx
				spot.zy = zy
				
				local wx, wy = self:GetWorldPos (mapId, zx, zy)
				spot.WX1 = wx
				spot.WY1 = wy
				zw = zw / 1002 * 100
				zh = zh / 668 * 100
				local wx, wy = self:GetWorldPos (mapId, zx + zw, zy + zh)
				spot.WX2 = wx
				spot.WY2 = wy

				spot.NxTipBase = tipStr

--				if contN == 5 then
--					Nx.prtVar ("Spot", spot)
--				end

			end
		end
	end

end

--------
-- Get description (color) that goes with a map nane

function Nx.Map:GetMapNameDesc (mapId)

--	Nx.prt ("MapId %s", mapId)
	local whichzone = Nx.Zones[mapId] or Nx.Zones[0]
	local _, minLvl, maxLvl, faction = Nx.Split ("|", whichzone)
	minLvl = tonumber (minLvl)
	faction = tonumber (faction)

	local infoStr = format ("%d-%d", minLvl, maxLvl)

	local color = "|cffffffff"
	if self.PlFactionNum == faction then
		color = "|cff20ff20"
	elseif faction == 2 then
		color = "|cffffff00"
	elseif faction < 2 then
		color = "|cffff6060"
	end

	if minLvl == 0 then
		infoStr = L["Any"]
	end
	if self:GetWorldZone(mapId).City then
		infoStr = L["City"]
		minLvl = -1
	end

	return color, infoStr, minLvl
end

--------
-- Init minimap ownership

function Nx.Map:MinimapOwnInit()
	self.MMScales = {}
	for n = 1, 6 do
		self.MMScales[n] = (8 - n) * 66.6666666666666 / 5.0
	end
	self.MMScalesC = { 300, 240, 180, 120, 80, 50 }
	for n = 1, 6 do
		self.MMScalesC[n] = self.MMScalesC[n] / 5.0
	end
	--
	local mm = self.MMFrm
	local mmc = _G["MinimapCluster"]
	self.MMChkDelay = 5		-- Prevent crash here
	self.MMOwnedFrms = {}
	if not self.MMOwn then
		self.Win:Show (self.StartupShown)
		Nx.Map:MinimapButtonShowUpdate()
		return
	end
	mm:SetMaskTexture ("textures\\MinimapMask")
	self:MinimapNodeGlowInit()
	Nx.Map:MinimapButtonShowUpdate (true)

	mm:SetClampedToScreen (true)
	mm:SetWidth (140)
	mm:SetHeight (140)
	self.MMAlphaDelay = 100

	mm:SetParent (self.Frm)

	--self.MMFrm:SetQuestBlobRingAlpha(1)
	self.MMFrm:SetPOIArrowTexture("Interface\\Addons\\Carbonite\\Gfx\\Map\\32Transparent")
	self.MMFrm:SetStaticPOIArrowTexture("Interface\\Addons\\Carbonite\\Gfx\\Map\\32Transparent")
	mm:SetScript ("OnMouseDown", self.MinimapOnMouseDown)
	mm:SetScript ("OnMouseUp", self.MinimapOnMouseUp)
	mm:SetScript ("OnEnter", self.MinimapOnEnter)
	mm:SetScript ("OnLeave", self.MinimapOnLeave)

--	local prtFrameChildren = Nx.prtFrameChildren
--	prtFrameChildren ("Minimap", mm)
--	prtFrameChildren ("MinimapCluster", mmc)

--[[
	local mmsf = CreateFrame ("ScrollFrame", nil, self.Frm)
	self.MMScFrm = mmsf

	mm:SetParent (mmsf)

	mmsf:SetAllPoints (self.Frm)
--	mmsf:SetScrollChild (mm)
--]]

	-- Ping

--[[	--V4
	local ping = MinimapPing
	ping:SetParent (UIParent)

	self.MMOwnedFrms[ping] = 0
--]]

	-- Data setup

	self.MMModels = {}
	self.MMAddonFrms = {}

	local f = _G["MinimapBackdrop"]
	if f then
		f:Hide()
		f:SetParent (mmc)
	end

	hooksecurefunc ("Minimap_ZoomIn", Nx.Map.Minimap_ZoomInClick)
	hooksecurefunc ("Minimap_ZoomOut", Nx.Map.Minimap_ZoomOutClick)

-- Dont work anymore
--	hooksecurefunc ("Minimap_ZoomInClick", Nx.Map.Minimap_ZoomInClick)
--	hooksecurefunc ("Minimap_ZoomOutClick", Nx.Map.Minimap_ZoomOutClick)
--	hooksecurefunc ("MinimapPing_OnEvent", Nx.Map.Minimap_OnEvent)
end

function Nx.Map.Minimap_ZoomInClick()
	local map = Nx.Map:GetMap (1)
	map:MinimapZoom (2)
end

function Nx.Map.Minimap_ZoomOutClick()
	local map = Nx.Map:GetMap (1)
	map:MinimapZoom (-2)
end

function Nx.Map.Minimap_OnEvent()

--	Nx.prt ("Minimap_OnEvent %s", arg1 or "nil")

	local map = Nx.Map:GetMap (1)
	map:MinimapZoom()
end

function Nx.Map:MinimapZoom (value)

--	Nx.prt ("MinimapZoom %s", value)

	if value then
		self:SetScaleOverTime (value)
	end

	local f = _G["MinimapZoomIn"]
	if f then
		f:Enable()
	end

	local f = _G["MinimapZoomOut"]
	if f then
		f:Enable()
	end
end

function Nx.Map:MinimapOnMouseDown (button)
--	Nx.prt ("click %s", button)

	local this = self			--V4

	local map = Nx.Map.Maps[1]

	if (map.MMZoomType == 0 and button == "LeftButton") or
			(IsShiftKeyDown() and not IsControlKeyDown()) then
		this.NXPing = true
	else
		this.NXPing = nil

		this.NxMap = map
		map.OnMouseDown (this, button)
	end
end

function Nx.Map:MinimapOnMouseUp (button)
--	Nx.prt ("click %s", button)

	local this = self			--V4

	local map = Nx.Map.Maps[1]

	if this.NXPing then
		if map.MMZoomType == 0 then
			Minimap_OnClick (this)
		else
			map:Ping()
		end

	else
		this.NxMap = map
		map.OnMouseUp (this, button)
	end
end

function Nx.Map:Ping()

	local frm = self.Frm
	local mx, my = Nx.Util_GetMouseClampedXY (frm)
	local top = frm:GetTop()
	local bottom = frm:GetBottom()
	my = top - (my + bottom)

	local mm = self.MMFrm

	local scales = self.MMScales
	local info = self.MapWorldInfo[self.MapId]

	if info.City and not info.MMOutside then
		scales = self.MMScalesC
	end

	local zoom = mm:GetZoom() + 1

	local wx, wy = self:FramePosToWorldPos (mx, my)

	local sc = scales[zoom] / mm:GetWidth()
	local x = wx - self.PlyrX
	local y = self.PlyrY - wy

--	Nx.prt ("Ping %f %f %f %f", x, y, sc, mm:GetScale())
--	Nx.prt (" Sc %f, W %f", scales[zoom], mm:GetWidth())

	mm:PingLocation (x / sc, y / sc)
end

function Nx.Map:MinimapOnEnter (motion)

	local map = Nx.Map.Maps[1]
	if map.MMZoomType ~= 0 then
		local this = self			--V4
		this.NxMap = map
		map.IconOnEnter (self, motion)
	end
end

function Nx.Map:MinimapOnLeave (motion)

	local map = Nx.Map.Maps[1]
	if map.MMZoomType ~= 0 then
		local this = self			--V4
		this.NxMap = map
		map.IconOnLeave (self, motion)
	end
end

function Nx.Map:MinimapButtonShowUpdate (justNameplate)
	local t = {
		"MinimapCluster", "ShowOldNameplate",
		"NXMiniMapBut", "ButShowCarb",
		"GameTimeFrame", "ButShowCalendar",
		"TimeManagerClockButton", "ButShowClock",
		"MiniMapWorldMapButton", "ButShowWorldMap",
	}

	for n = 1, #t, 2 do

		local skip

		if Nx.Free then
			if t[n] == "MinimapCluster" then
				skip = true
			end
		end
		if InCombatLockdown() then
			skip = true
		end
		if not skip then

			local f = _G[t[n]]
			if f then
				if Nx.db.profile.MiniMap[t[n + 1]] then
					f:Show()
				else
					f:Hide()
				end
			end
		end

		if justNameplate then
			break
		end
	end
end

--------
-- Init minimap node glow. Also called by options

CreateFrame("FRAME","NXMinimapBlinkerFrame")
function Nx.Map:MinimapNodeGlowInit (reset)

	local mm = self.MMFrm

	Nx:CancelTimer (MapNodeGlow)

	if reset then
		mm:SetBlipTexture ("Interface\\Minimap\\ObjectIconsAtlas")
	end

	local delay = Nx.db.profile.MiniMap.NodeGD

	if delay > 0 then

		if not self.MMGlowInited then

			self.MMGlowInited = true

			-- Force blip textures to stay in mem, so minimap does not show corruption when switching

			local t = NXMinimapBlinkerFrame:CreateTexture (nil, "OVERLAY")
			t:SetAllPoints()
			t:SetTexture ("Interface\\AddOns\\Carbonite\\Gfx\\Map\\MMOIcons")
			--t:SetNonBlocking(true)
			--t:Hide()
			local t = NXMinimapBlinkerFrame:CreateTexture (nil, "OVERLAY")
			t:SetAllPoints()
			t:SetTexture ("Interface\\AddOns\\Carbonite\\Gfx\\Map\\MMOIconsG")
			--t:SetNonBlocking(true)
			--t:Hide()
		end
		GlowLetter = ""
		MapNodeGlow = Nx:ScheduleRepeatingTimer(self.OnMinimapNodeGlowTimer, Nx.db.profile.MiniMap.NodeGD * 2, self)
	end
end

function Nx.Map:OnMinimapNodeGlowTimer (name)
	if GlowLetter == "" then
		self:MinimapNodeGlowSet ("")
		GlowLetter = "G"
	else
		self:MinimapNodeGlowSet("G")
		GlowLetter = ""
	end
	return Nx.db.profile.MiniMap.NodeGD * 2
end

function Nx.Map:MinimapNodeGlowSet (letter)

	--local count = GetNumTrackingTypes()
	--for n = 1, count do
	--	local name, texture, active, category = GetTrackingInfo (n)

	--	if active and category == "spell" then
				self.MMFrm:SetBlipTexture ("Interface\\AddOns\\Carbonite\\Gfx\\Map\\MMOIcons" .. letter)
			--break
	--	end
	--end
end

--------
--

function Nx.Map:MinimapUpdate()

	if not self.MMOwn then
		self:MinimapDetachFrms()
		return
	end

	--

	--[[if Nx.db.profile.MiniMap.MoveCapBars then

		local y = 0

		for n = 1, NUM_EXTENDED_UI_FRAMES do

			local f = _G["WorldStateCaptureBar" .. n]
			if f and f:IsShown() then

--				Nx.prtFrame ("WorldState", f)

				f:SetPoint ("TOPRIGHT", self.Win.Frm, "BOTTOMRIGHT", 0, y)
				y = y + f:GetHeight()
			end
		end
	end]]--

	--

	if self.DebugScale then
		self.MMScale = 0
		local sc = self.DebugScale

		for n = 1, 6 do
			self.MMScales[n] = (8 - n) * 66.6666666666666 / sc
		end
	end

	--

	local mm = self.MMFrm
	
	local lOpts = self.LOpts

	local scales = self.MMScales
	local info = self.MapWorldInfo[Nx.Map.UpdateMapID]
	if not info then
		info = {}
	end
	if info.City and not info.MMOutside then
		scales = self.MMScalesC
	end
	
	local zoomType = 0
	local zoom = mm:GetZoom (1)

	local dock = lOpts.NXMMFull or Nx.db.profile.MiniMap.DockAlways

	if self.Win:IsSizeMax() and Nx.db.profile.MiniMap.DockOnMax then
		dock = true
	end

	if (self:IsInstanceMap(Nx.Map.RMapId) or self:IsBattleGroundMap(Nx.Map.RMapId)) and self.CurOpts.NXInstanceMaps then
		dock = true
	end
	
	if not dock and not self.InstanceId
			and self.ScaleDraw > lOpts.NXMMDockOnAtScale then
		if not InCombatLockdown() then
			mm:ClearAllPoints()
		else
			return
		end

		for n = 1, 6 do

			local sz = scales[n]

			if self:ClipMMW (mm, self.PlyrX, self.PlyrY, sz, sz) then
--				Nx.prt ("MM #%d sz %d", n, sz)
				zoomType = n
--				self.MMSize = sz * self.ScaleDraw
				break
			end
		end
	end

	local al = lOpts.NXMMAlpha

	local indoors = IsIndoors() or Nx.Map.Indoors
	local resting = IsResting()
	local indoorChange = self.Indoors ~= indoors
	self.Indoors = indoors
	local bugged = false
	local bugtest = GetSubZoneText()
	for _,zonetest in ipairs(Nx.BuggedAreas) do
		if Nx.Map:GetCurrentMapAreaID() == zonetest and not indoors then
			bugged = true
		end
	end
	for _,zonetest in ipairs(Nx.BuggedSubZones) do
		if bugtest == zonetest then
			bugged = true
		end
	end
	if self.InstanceId and not self.CurOpts.NXInstanceMaps then
		al = 1
	else		
		if indoors and Nx.db.profile.MiniMap.DockIndoors then
			zoomType = 0
		end
		if bugged and Nx.db.profile.MiniMap.DockBugged then
			zoomType = 0
		end
		if Nx.InBG then
			zoomType = 0
		end
		if indoorChange and Nx.db.profile.MiniMap.IndoorTogFullSize then
			lOpts.NXMMFull = false
			if not info.City and indoors then
				lOpts.NXMMFull = true
			end
			self.MMMenuIFull:SetChecked (lOpts.NXMMFull)
			Nx.Menu:CheckUpdate (self.MMMenuIFull)
		end
		if Nx.db.profile.MiniMap.BuggedTogFullSize then
			if bugged then
				lOpts.NXMMFull=true
			else
				lOpts.NXMMFull=false
			end
			self.MMMenuIFull:SetChecked(lOpts.NXMMFull)
			Nx.Menu:CheckUpdate(self.MMMenuIFull)
		end
		if Nx.db.profile.MiniMap.InstanceTogFullSize then
			local _, instanceType = GetInstanceInfo()
			if self:IsInstanceMap (Nx.Map.RMapId) or (instanceType ~= nil and instanceType ~= "none") then
				lOpts.NXMMFull=true
			end
		end	
		if zoomType == 0 then
			al = 1
		end

		if IsControlKeyDown() or IsIndoors() or Nx.Map.Indoors then
			al = IsAltKeyDown() and 1 or .8
			self.MMZoomChanged = true
		end
	end

	if self.MMZoomType ~= zoomType or zoomType > 0 and self.MMScale ~= self.ScaleDraw
			or indoorChange then
		
		self.MMZoomType = zoomType
		self.MMScale = self.ScaleDraw

		self.MMZoomChanged = true

--		Nx.prt ("MMZoomChanged")

		if self.MMAlphaDelay == 0 then
--		if zoomType == 0 and self.MMAlphaDelay == 0 then
			self.MMAlphaDelay = 2
		end
	end

	if self.MMAlphaDelay > 0 then
		self.MMAlphaDelay = self.MMAlphaDelay - 1
--		al = 1
--		Nx.prt ("MMAFix %s", self.MMAlphaDelay)
		self.MMZoomChanged = true
	end

	mm:SetAlpha (al)
	
	self:MinimapDetachFrms()

	if zoomType > 0 then

		self:MinimapUpdateMask ("Square")

		local above = IsControlKeyDown()

		if Nx.db.profile.MiniMap.AboveIcons then
			above = not above
		end

		local lvl = self.Level
		if above then
			lvl = lvl + 15
		end

		mm:SetFrameLevel (lvl)
		self:MinimapUpdateDetachedFrms (lvl + 1)
		self.Level = self.Level + 2

	else

		local sc = self.MMFScale

		self.MMFScale = Nx.InBG and lOpts.NXMMDockScaleBG or lOpts.NXMMDockScale
		if lOpts.NXMMFull then
			self.MMFScale = min (self.MapW, self.MapH) / 140
		end
	end

--[[
	local mmsf = self.MMScFrm

	mmsf:SetScrollChild (mm)
	mmsf:UpdateScrollChildRect()

	mmsf:SetFrameLevel (self.Level)
--]]

end

function Nx.Map:MinimapUpdateEnd()

	if not self.MMOwn then
		return
	end
	--if InCombatLockdown() and Nx.db.profile.Map.Compatibility then
	if InCombatLockdown() then
		return
	end
	local mm = self.MMFrm
	local mmfull = self.LOpts.NXMMFull
	
	local info = self:GetWorldZone(Nx.Map:GetCurrentMapAreaID())
	local _, class = UnitClass("player");
	if (self:IsInstanceMap(Nx.Map.UpdateMapID) or self:IsBattleGroundMap(Nx.Map.UpdateMapID)) and self.CurOpts.NXInstanceMaps then
	else
		if self.Win:IsSizeMax() and Nx.db.profile.MiniMap.HideOnMax 
			or self.MMFScale < .02 
			or Nx.Map.NInstMapId ~= nil -- Instance
			or info.City and not info.MMOutside -- Cites
		then
			mm:SetPoint ("TOPLEFT", 1, 0)
			mm:SetScale (.02)
			mm:SetFrameLevel (1)
--		mm:Hide()

			for n, f in ipairs (self.MMModels) do
				f:SetScale (.001)
			end
			return
		end
	end

	if self.MMZoomType == 0 then		
		self:MinimapUpdateMask ("DockSquare")

		local iconScale = Nx.db.profile.MiniMap.DockIScale

		self:MinimapSetScale (self.MMFScale, iconScale)
--		mm:SetScale (self.MMFScale)

		local x = 0
		local y = 0
		local sz = 140 * self.MMFScale

		if Nx.db.profile.MiniMap.DockRight then
			x = (self.MapW - sz + 1)
		end
		if Nx.db.profile.MiniMap.DockBottom then
			y = (self.MapH - sz + 1)
		end

		mm:ClearAllPoints()
		mm:SetPoint ("TOPLEFT", (x + Nx.db.profile.MiniMap.DXO) / iconScale,
										(-y - Nx.db.profile.MiniMap.DYO) / iconScale)
		mm:Show()
		if (self:IsInstanceMap(Nx.Map.RMapId) or self:IsBattleGroundMap(Nx.Map.RMapId)) and self.CurOpts.NXInstanceMaps then
			mm:SetFrameLevel (self.Level + 50)
		else
			mm:SetFrameLevel (self.Level)
		end
		self:MinimapUpdateDetachedFrms (self.Level + 1)
		self.Level = self.Level + 2
	end

	if self.MMZoomChanged then

		self.MMZoomChanged = false

		local zoom = max (self.MMZoomType - 1, 0)

		if self.MMZoomType == 0 then
			zoom = Nx.db.profile.MiniMap.DockZoom
		end

		local z = zoom - 1
		if z < 0 then
			z = 1
		end

		-- Force icon update
		mm:SetZoom (z)
		mm:SetZoom (zoom)

--		Nx.prt ("zoom %d", zoom)

		if self.MMZoomType == 0 then
			mm:SetAlpha (1)
		end

--		if Gatherer then
--			Nx.Timer:Start ("Gatherer", .1, self, self.OnGathererTimer)
--		end
	end

	-- Transfer window and minimap scale

	--V4 gone TEST!!!!!!!!!
--	MinimapPing:SetScale (self.Win.Frm:GetScale() * mm:GetScale())
end

function Nx.Map:MinimapSetScale (scale, iconScale)
	--if InCombatLockdown() and Nx.db.profile.Map.Compatibility then
	if InCombatLockdown() then
		return
	end
	local mm = self.MMFrm
	local sz = 140 * scale / iconScale
	mm:SetWidth (sz)
	mm:SetHeight (sz)
	mm:SetScale (iconScale)
end

function Nx.Map:MinimapUpdateMask (optName)

	local name = Nx.db.profile.MiniMap[optName] and "Interface\\Buttons\\White8x8" or "textures\\MinimapMask"

--	if IsControlKeyDown() then
--		self.MMMaskName = nil
--	end

	if self.MMMaskName ~= name then
		self.MMMaskName = name

		local mm = self.MMFrm
		mm:SetMaskTexture (name)

--		Nx.prt ("MMmask %s", name)
	end

	local name = self.MMZoomType == 0 and "Interface\\Minimap\\MinimapArrow" or "Interface\\Addons\\Carbonite\\Gfx\\Map\\32Transparent"
	if self.MMArrowName ~= name then
		self.MMArrowName = name
		if (name ~= "") then
			self.MMFrm:SetPlayerTexture (name)
		end
	end
end

--[[
function Nx.Map.OnGathererTimer()

	Nx.prt ("Gatherer update")

	local mn = Gatherer["MiniNotes"]
	if mn then
		local update = mn["ForceUpdate"]
		if update then
			update()
		end
	else
		Nx.prt ("no mn")
	end
end
--]]

function Nx.Map:MinimapDetachFrms()

	local mm = self.MMFrm
	local mmc = _G["MinimapCluster"]
	local winf = self.Win.Frm
	local dock = Nx.Map.Dock

	if dock.InitPending then
		return
	end

	self.MMChkDelay = self.MMChkDelay - 1

	if self.MMChkDelay < 1 then

		self.MMChkDelay = 40		-- Reset

		-- Find and own any minimap child windows

		local mmNames = self.AddonMinimapNames
		local ch = { mm:GetChildren() }

		for n = 1, #ch do

			local c = ch[n]
			if c ~= mmc then

--				if not c:IsVisible() then
--					Nx.prt ("MM Frm v0 %s", c:GetName() or "nil")
--				end

				if c:IsShown() and not self.MMOwnedFrms[c] then

					if c:IsObjectType ("Model") then
--						Nx.prt ("MM Model %s", c:GetName() or "nil")

						if self.MMOwn then

							c:SetParent (winf)
							self.MMOwnedFrms[c] = 0
							tinsert (self.MMModels, c)
						end

					elseif c:IsObjectType ("Frame") then

						local name = gsub (c:GetName() or "", "%d", "")

						if mmNames[name] then

							if self.MMOwn then
								self.MMOwnedFrms[c] = 0
								self.MMAddonFrms[c] = 1
							end

						elseif dock.MMFrms then

							local excludeFrame = false
							local excludeFrames = {'HandyNotesPin', 'QuestieFrame'}
							
							for k, exF in ipairs (excludeFrames) do
								if c:GetName() and Nx.strpos(c:GetName(), exF) then excludeFrame = true end
							end
							
							if not excludeFrame then 						
								self.MMOwnedFrms[c] = 0
								tinsert (dock.MMFrms, c)
								
	--							Nx.prt ("MM Frm %s #%s %s", c:GetName() or "nil", c:GetNumChildren(), Nx.strpos(c:GetName(), 'QuestieFrame'))
	--							Nx.prtFrameChildren (c:GetName() or "nil", c)

								if c:GetNumChildren() > 0 then

									local ch = { c:GetChildren() }
									for k, c in ipairs (ch) do

	--									if not c:IsShown() then
	--										Nx.prt ("MM Frm v0 %s", c:GetName() or "nil")
	--									end

										if c:IsShown() then
											if c:IsObjectType ("Frame") then
												local pt, relTo = c:GetPoint()
												if relTo == mm then
													tinsert (dock.MMFrms, c)
	--												Nx.prt ("MMCC %s", c:GetName())
												end
											end
										end
									end
								end
							end

						end
					end
				end
			end
		end
	end

	--
	if HandyNotes then
		HandyNotes:UpdateMinimap()
	end

	dock:MinimapDetachFrms()
end

function Nx.Map:MinimapUpdateDetachedFrms (lvl)

--	self:MinimapDetachFrms()

	local sc = self.MMFScale
	local arrowsc = sc
	local msc = min (1 / sc, 1) * .5

	if Nx.InBG then
		arrowsc = .001
	end

	local mmplyr = Nx.Map.MinimapPlyrModel		-- Old

	for n, f in ipairs (self.MMModels) do

		if f:IsShown() then

			f:SetFrameLevel (lvl)

			local name = f:GetModel()

			if name == "interface\\minimap\\ping\\minimapping.m2" then
				f:SetScale (sc)
				f:SetModelScale (msc)
				f:SetAlpha (1)

			elseif f == mmplyr then
				if self.MMZoomType == 0 then
					f:SetScale (max (.4, min (.9, sc)) * Nx.db.profile.Map.PlyrArrowSize / 28)
--					f:SetModelScale (min (.2, sc))
					f:SetModelScale (1)
				else
					f:SetScale (.1)
					f:SetModelScale (1)
				end
			else
				f:SetScale (arrowsc)
				f:SetModelScale (msc)
			end
--[[
			if IsAltKeyDown() then
				Nx.prt ("Model %s (%s %s)", f:GetModel() or "", f:GetScale(), f:GetModelScale())
			end
--]]
		end
	end

	for f, v in pairs (self.MMAddonFrms) do
		f:SetFrameLevel (lvl)
--		f:SetScale (sc)
--		f:SetModelScale (msc)
	end
end

--------

function Nx.Map:Menu_OnGoto (item)
	self:SetTargetAtClick()
end

function Nx.Map:Menu_OnClearGoto (item)
	self:ClearTargets()
	self.Guide:ClearAll()
end

function Nx.Map:Menu_OnMonitorZone (item)
	Nx.Com:MonitorZone (self.MenuMapId, item:GetChecked())
end

function Nx.Map:Menu_OnScaleSave()
	self.CurOpts.NXScaleSave = self.Scale
end

function Nx.Map:Menu_OnScaleRestore()
	local s = Nx.Map:GetMap(1).CurOpts.NXScaleSave
	if s then
		Nx.Map:GetMap(1).Scale = s
		Nx.Map:GetMap(1).RealScale = s
		Nx.Map:GetMap(1).StepTime = 10
	else
--		Nx.prt ("Scale not set")
	end
end

function Nx:NXMapKeyScaleRestore()
	local map = Nx.Map:GetMap (1)
	map:Menu_OnScaleRestore()
end

function Nx.Map:Menu_OnPlyrFollow (item)
	self.CurOpts.NXPlyrFollow = item:GetChecked()
end

function Nx.Map:Menu_InstanceMap (item)
	self.CurOpts.NXInstanceMaps = item:GetChecked()
end

function Nx.Map:Menu_OnShowWorld (item)
	self.CurOpts.NXWorldShow = item:GetChecked()
end

function Nx.Map:Menu_OnShowPlayerZone()
	self:GotoCurrentZone()
end

function Nx.Map:Menu_OnShowKills (item)
	self.KillShow = item:GetChecked()
end

function Nx.Map:Menu_OnDetailAlpha (item)
	self.LOpts.NXDetailAlpha = item:GetSlider()
end

function Nx.Map:Menu_OnBackgndAlphaFade (item)
	self.BackgndAlphaFade = item:GetSlider()
end

function Nx.Map:Menu_OnArchAlpha (item)
	self.ArchAlpha = item:GetSlider()
end

function Nx.Map:Menu_OnQuestAlpha (item)
	self.QuestAlpha = item:GetSlider()
end

function Nx.Map:Menu_OnBackgndAlphaFull (item)
	self.BackgndAlphaFull = item:GetSlider()
end

function Nx.Map:Menu_OnDotZoneScale (item)
	self.DotZoneScale = item:GetSlider()
end

function Nx.Map:Menu_OnDotPalScale (item)
	self.DotPalScale = item:GetSlider()
end

function Nx.Map:Menu_OnDotPartyScale (item)
	self.DotPartyScale = item:GetSlider()
end

function Nx.Map:Menu_OnDotRaidScale (item)
	self.DotRaidScale = item:GetSlider()
end

function Nx.Map:Menu_OnIconScale (item)
	self.IconScale = item:GetSlider()
end

function Nx.Map:Menu_OnIconNavScale (item)
	self.IconNavScale = item:GetSlider()
end

function Nx.Map:Menu_OnOptions (item)
	Nx.Opts:Open ("Map")
end

-- Debug sub menu

function Nx.Map:Menu_OnMapDebugFullCoords (item)
	self.DebugFullCoords = item:GetChecked()
end

function Nx.Map:Menu_OnQuestDebug (item)
	Nx.Quest.Debug = item:GetChecked()
end

-- Plyr icon menu

function Nx.Map:Menu_OnWhisper()

	for _, name in pairs (Nx.Map.PlyrNames) do

		local box = ChatEdit_ChooseBoxForSend()
		ChatEdit_ActivateChat (box)
		box:SetText ("/w " .. name .. " " .. box:GetText())
--[[
		local frm = DEFAULT_CHAT_FRAME
		local eb = frm["editBox"]
		if not eb:IsVisible() then
			ChatFrame_OpenChat ("/w " .. name, frm)
		else
			eb:SetText ("/w " .. name .. " " .. eb:GetText())
		end
--]]
		break
	end
end

-- Plyr icon menu

function Nx.Map:Menu_OnInvite()

	for _, name in pairs (Nx.Map.PlyrNames) do
		InviteUnit (name)
		break
	end
end

function Nx.Map:Menu_OnGetQuests (item)
	if Nx.Quest then
	for _, name in pairs (Nx.Map.PlyrNames) do
		Nx.Quest:GetFromPlyr (name)
		break
	end
	end
end

function Nx.Map:Menu_OnTrackPlyr (item)

	for _, name in pairs (Nx.Map.PlyrNames) do
		self.TrackPlyrs[name] = true
	end
end

function Nx.Map:Menu_OnRemoveTracking (item)

	for _, name in pairs (Nx.Map.PlyrNames) do
		self.TrackPlyrs[name] = nil
	end
end

function Nx.Map:Menu_OnReportPlyrAFK (item)
	local n = 0
	for k, v in pairs (Nx.Map.AFKers) do
		ReportPlayerIsPVPAFK (v)
		n = n + 1
	end
	Nx.prt ("%d " .. L["reported"], n)
end

--[[
function Nx.Map:Menu_OnReportAllAFK (item)

	local members = MAX_PARTY_MEMBERS
	local unitName = "party"

	if IsInRaid() > 0 then
		members = MAX_RAID_MEMBERS
		unitName = "raid"
	end

	local cnt = 0

	for i = 1, members do

		local unit = unitName..i

		if not UnitIsUnit (unit, "player") then
			ReportPlayerIsPVPAFK (unit)
			cnt = cnt + 1
		end
	end

	Nx.prt ("%d reported", cnt)
end
--]]

function Nx.Map:Menu_OnGrowConflictBars (item)
	self.BGGrowBars = item:GetChecked()
end

function Nx.Map:GMenuOpen (icon, typ)

	self.GIconMenuITogInst:Show (false)
	self.GIconMenuIFindNote:Show (false)

	if typ == 3000 then
		if icon.UData then
			self.GIconMenuITogInst:Show()
		end

		if icon.FavData1 then
			self.GIconMenuIFindNote:Show()
		end
	end
	self.GIconMenu:Open()
end

--------
-- Instance icon

function Nx.Map:GMenu_OnTogInst()

	local icon = self.ClickIcon

	local mapId = icon.UData

	if mapId then
		if self.InstMapId == mapId then
			self:SetInstanceMap()
		else
			local atlas = _G["AtlasMaps"]

--			Nx.prt ("%s", mapId)

			if not (Nx.Map.InstanceInfo[mapId] or atlas) then
				UIErrorsFrame:AddMessage ("This instance map requires the Atlas addon be installed", 1, .1, .1, 1)
				return
			end

			self:SetInstanceMap (mapId)
		end
	end
end

--------
-- Favorite icon

function Nx.Map:GMenu_OnFindNote()
	Nx.Notes:ShowIconNote (self.ClickIcon)
end

--------
-- Generic icon goto

function Nx.Map:GMenu_OnGoto()
	if Nx.Quest.Watch then
		Nx.Quest.Watch:ClearAutoTarget()
	end
	if self.ClickType == 3001 then
		if Nx.Social then
			Nx.Social:GotoPunk (self.ClickIcon)
		end
	else
		local icon = self.ClickIcon
		local x = icon.X
		local y = icon.Y
		local name = icon.Tip and Nx.Split ("\n", icon.Tip) or ""

		self:SetTarget ("Goto", x, y, x, y, false, 0, name, IsShiftKeyDown())
	end
end

--------
-- Generic icon goto

function Nx.Map:GMenu_OnPasteLink()

	local name

	if self.ClickType == 3001 then
		if Nx.Social then
			name = Nx.Social:GetPunkPasteInfo (self.ClickIcon)
		end
	else
		local icon = self.ClickIcon
		name = gsub (icon.Tip, "\n", ", ")
	end

	name = gsub (name, "|cff......", "")
	name = gsub (name, "|r", "")

	local frm = DEFAULT_CHAT_FRAME
	local eb = frm["editBox"]
	if eb:IsVisible() then
		eb:SetText (eb:GetText() .. name)
	else
		Nx.prt (L["No edit box open!"])
	end
end

--------
-- Send BG messages

function Nx.Map:BGMenu_OnIncoming (item)
	self:BGMenu_Send (NXlBGMsgIncoming)
end

function Nx.Map:BGMenu_OnClear (item)
	self:BGMenu_Send ("Clear")
end

function Nx.Map:BGMenu_OnHelp (item)
	self:BGMenu_Send ("Help")
end

function Nx.Map:BGMenu_OnAttack (item)
	self:BGMenu_Send ("Attack")
end

function Nx.Map:BGMenu_OnGuard (item)
	self:BGMenu_Send ("Guard")
end

function Nx.Map:BGMenu_OnLosing (item)
	self:BGMenu_Send ("Losing")
end

--------
-- BG icon status

function Nx.Map:BGMenu_OnStatus (item)

	local id, x, y, str = Nx.Split ("~", self.BGMsg)
	if id == "1" then
		self:BGMenu_Send()
--		SendChatMessage (str, "BATTLEGROUND")
	else
		Nx.prt ("No Status")
	end
end

--------
-- BG icon status

function Nx.Map:BGMenu_Send (msg)

	local id, tx, ty, str = Nx.Split ("~", self.BGMsg)
	tx, ty = self:GetWorldPos (Nx.Map.UpdateMapID, tonumber (tx), tonumber (ty))

	local members = MAX_PARTY_MEMBERS
	local unitName = "party"

	if IsInRaid() then
		members = MAX_RAID_MEMBERS
		unitName = "raid"
	end

	local cnt = 0
	local maxDist = (100 / 4.575) ^ 2	-- Yards to world space squared

	for i = 1, members do

		local unit = unitName..i
		local pX, pY = Nx.Map.GetPlayerMapPosition (unit)

		if (pX > 0 or pY > 0) and not UnitIsDeadOrGhost (unit) then

			local x, y = self:GetWorldPos (Nx.Map.UpdateMapID, pX * 100, pY * 100)
			local dist = (tx - x) ^ 2 + (ty - y) ^ 2

--			Nx.prt ("%s %s %s = %s", unit, pX, pY, sqrt (dist) * 4.575)

			if dist <= maxDist then
				cnt = cnt + 1
--				Nx.prt (" %s", UnitName (unit))
			end
		end
	end

	local dstr = ", No "
	if cnt > 0 then
		dstr = format (", %d ", cnt)
	end

	dstr = dstr .. Nx.Map.PlFactionShort .. " in area"

	if msg then
		SendChatMessage (msg .. " - " .. str .. dstr, "INSTANCE_CHAT")
	else
		SendChatMessage (str .. dstr, "INSTANCE_CHAT")
	end

--	Nx.prt ("count %d", cnt)
--	Nx.prt (msg .. " - " .. str .. dstr)
end

function Nx.Map:BGIncSendTimer()

	local str = format (L["Incoming"] .. " %s", self.BGIncNum)
	self:BGMenu_Send (str)

	self.BGIncNum = 0

--	Nx.prt ("BGIncSendTimer %s", str)
end

--------
-- Hook Blizz World Map Toggle

--[[hooksecurefunc ("ToggleFrame", function(frame) 
	if frame then
		if frame == _G["WorldMapFrame"] then
			if Nx.Map.BlizzToggling or IsAltKeyDown() or not Nx.db.profile.Map.MaxOverride then
				if WorldMapFrame:IsShown() then
					Nx.Map:RestoreBlizzBountyMap()	
					local map = Nx.Map:GetMap (1)
					map:DetachWorldMap()
				end
			else
				HideUIPanel (WorldMapFrame) 
				Nx.Map:ToggleSize()	
			end
		end
	end
end)]]--

--[[WorldMapFrame:HookScript("OnKeyDown", function(self, key) 
	local binding = GetBindingFromClick(key)
	if binding == "TOGGLEGAMEMENU" then
		Nx.Map:ToggleSize()
	end
end)]]--

Nx.Map.WMFOnShow = true
WorldMapFrame:HookScript("OnShow", function()
	--_G["Minimap"]:Show()
	
	-- Fix for ElvUI constant WorldMapFrame Show and Hide
	if ElvUI then
		ElvUI[1].global.general.fadeMapWhenMoving = false
	end
	if Nx.Map.WMFOnShow then
		local orgin = IsAltKeyDown()
		if not Nx.db.profile.Map.MaxOverride then
			orgin = not orgin
		end
		if Nx.Map.BlizzToggling or orgin then
			--[[if Nx.db.profile.MiniMap.Own then 
				_G["Minimap"]:Hide()
			end]]--
			if WorldMapFrame:IsShown() then
				Nx.Map:RestoreBlizzBountyMap()	
				local map = Nx.Map:GetMap (1)
				map:DetachWorldMap()
			end
		else
			-- DugisGuide FIX
			if DugisGuideViewer then  
				local isGuideMode, isEssentialMode, isOffMode = DugisGuideViewer.GetPluginMode()	
				if not isOffMode and GPSArrowIcon and not GPSArrowIcon:IsShown() then
					HideUIPanel (WorldMapFrame) 
					return
				end
			end
		
			HideUIPanel (WorldMapFrame) 
			Nx.Map:ToggleSize()	
		end
	end
end)

function ToggleWorldMap()
	if Nx.Map.BlizzToggling or WorldMapFrame:IsShown() or IsAltKeyDown() or not Nx.db.profile.Map.MaxOverride then
		if not Nx.db.profile.Map.MaxOverride and IsAltKeyDown() then
			Nx.Map:ToggleSize()
		else
			Nx.Map:BlizzToggleWorldMap()
		end
	else
		Nx.Map:ToggleSize()
	end
end

--------
-- Override blizz WotLK frame toggle

--[[function ToggleFrame (frame)

	if frame ~= WorldMapFrame then
		if frame:IsShown() then
			HideUIPanel (frame)
		else
			ShowUIPanel (frame)
		end
		return
	end

	if Nx.Map.BlizzToggling or WorldMapFrame:IsShown() or IsAltKeyDown() or not Nx.db.profile.Map.MaxOverride then
		Nx.Map:BlizzToggleWorldMap()
	else
		Nx.Map:ToggleSize()
	end
end]]--

-------
-- BOUNTY MAP
-------

function Nx.Map:HijackBlizzBountyMap()
	local map = self:GetMap (1)

	WorldMap_HijackTooltip(map.Frm)
	
	local bountyBoard = NXBountyBoard;
	if bountyBoard == nil then bountyBoard = CreateFrame('BUTTON', 'NXBountyBoard', map.Frm, 'WorldMapBountyBoardTemplate') end
	bountyBoard:RegisterEvent('QUEST_LOG_UPDATE')
	bountyBoard.FindBestMapForSelectedBounty = function() end
	bountyBoard:SetParent(map.Frm)
	bountyBoard:SetFrameLevel(140)
	bountyBoard:SetMapAreaID(619)
	local bountyBoardLocation = bountyBoard:GetDisplayLocation()
	if bountyBoardLocation then
		WorldMapFrame_SetOverlayLocation(bountyBoard, bountyBoardLocation);
	end	
	bountyBoard:Show()
end

function Nx.Map:RestoreBlizzBountyMap(tooltip)
	--[[if tooltip ~= false then WorldMap_RestoreTooltip() end
	if NXBountyBoard then 
		NXBountyBoard:UnregisterEvent('QUEST_LOG_UPDATE')
		NXBountyBoard:Clear()
		NXBountyBoard:Hide()
	end]]--
end

-------
-- Changing orginal Blizz functions to fix world map toggle

--[[WorldMapFrame.UIElementsFrame.ActionButton.oRefresh = WorldMapFrame.UIElementsFrame.ActionButton.Refresh
function WorldMapFrame.UIElementsFrame.ActionButton:Refresh()
	if UnitAffectingCombat("player") then return end
	WorldMapFrame.UIElementsFrame.ActionButton:oRefresh()
end]]--

--[[local oWorldMapFrame_SetOverlayLocation = WorldMapFrame_SetOverlayLocation
function WorldMapFrame_SetOverlayLocation(frame, location)
	if UnitAffectingCombat("player") then return end
	oWorldMapFrame_SetOverlayLocation(frame, location)
end]]--

-------
-- Blizz map toggle

function Nx.Map:BlizzToggleWorldMap()
	
	if WorldMapFrame:IsShown() then
		if not InCombatLockdown() then
			HideUIPanel (WorldMapFrame)
		else
			WorldMapFrame:Hide()
		end
	else
		Nx.Map:RestoreBlizzBountyMap()

		local map = self:GetMap (1)
		map:DetachWorldMap()
		if not InCombatLockdown() then
			WorldMapFrame:HandleUserActionToggleSelf();
		else
			WorldMapFrame:Show()
		end
	end
end

--------
-- Key binding toggle map size. Open blizz map
-- global func

function Nx:NXMapKeyTogOriginal()

	-- Does not get called when map fullscreen

	Nx.Map.BlizzToggling = true
	ToggleWorldMap()
	Nx.Map.BlizzToggling = nil
end

--------
-- Key binding toggle map size
-- global func

function Nx:NXMapKeyTogNormalMax()
	Nx.Map:ToggleSize()
end

--------
-- Key binding toggle map size
-- global func

function Nx:NXMapKeyTogNoneMax()
	Nx.Map:ToggleSize (1)
end

--------
-- Key binding toggle map size
-- global func

function Nx:NXMapKeyTogNoneNormal()
	Nx.Map:ToggleSize (0)
end

--------
-- Toggle map size
-- global func

function Nx.Map:ToggleSize (szmode)

	if not self.Maps then	-- Healbot called ToggleFrame on load that caused us to fail in GetMap
		return
	end
	
	Nx.Map:RestoreBlizzBountyMap(false)

	local map = self:GetMap (1)
	local win = map.Win
	
	if not win:IsShown() and not win:IsSizeMax() then
		win:Show()
		if szmode == 0 then
			--MapBarFrame:SetParent("WorldMapFrame")
			--WorldMapPlayerLower:SetAlpha(1)
			--WorldMapPlayerUpper:SetAlpha(1)
			map:RestoreSize()
			Nx.Map:RestoreBlizzBountyMap()		
		elseif szmode == 1 then
			--MapBarFrame:SetParent(win.Frm)
			--MapBarFrame:SetFrameLevel(win.Frm:GetFrameLevel() + 10)
			--WorldMapPlayerLower:SetAlpha(0)
			--WorldMapPlayerUpper:SetAlpha(0)
			map:MaxSize()
		elseif Nx.db.profile.Map.MaxCenter then
			--MapBarFrame:SetParent(win.Frm)
			--MapBarFrame:SetFrameLevel(win.Frm:GetFrameLevel() + 10)
			--WorldMapPlayerLower:SetAlpha(0)
			--WorldMapPlayerUpper:SetAlpha(0)
			map:MaxSize()
		end
		if Nx.db.char.Map.ShowWorldQuest then
			--Nx.Map:HijackBlizzBountyMap()
		end
	elseif szmode then
		win:Show (false)
	elseif not win:IsSizeMax() then
		--MapBarFrame:SetParent(win.Frm)
		--MapBarFrame:SetFrameLevel(win.Frm:GetFrameLevel() + 10)
		--WorldMapPlayerLower:SetAlpha(0)
		--WorldMapPlayerUpper:SetAlpha(0)
		map:MaxSize()
		if Nx.db.char.Map.ShowWorldQuest then
			--Nx.Map:HijackBlizzBountyMap()
		end
	else
		--MapBarFrame:SetParent("WorldMapFrame")
		--WorldMapPlayerLower:SetAlpha(1)
		--WorldMapPlayerUpper:SetAlpha(1)
		map:RestoreSize()
	end

	if Nx.TooltipOwner == win.Frm then
		GameTooltip:Hide()
		Nx.TooltipOwner = nil
	end
end

--------
-- Restore map size

function Nx.Map:RestoreSize()

	self:MouseEnable (false)

	if self.Win:IsSizeMax() then
		Nx.Map:RestoreBlizzBountyMap(false)	
--		Nx.prt ("Map RestoreSize ToggleSize")
		self.Win:ToggleSize()

		self:RestoreView ("")
		self:DetachWorldMap()

		if Nx.db.profile.Map.MaxRestoreHide then
			self.Win:Show (false)
		end
	end
	local wname = self:GetWinName()
	for n, name in pairs (UISpecialFrames) do
		if name == wname then
			tremove (UISpecialFrames, n)
			break
		end
	end
end

--------
-- Maximize map size

function Nx.Map:MaxSize()

	if not self.Win:IsSizeMax() then

		if Nx.db.profile.Debug.DBMapMax then
			Nx.prt ("MapMax %s", debugstack (2, 4, 0))
		end

		self.Win:ToggleSize()

		self:SaveView ("")

		self:MouseEnable (true)
		if self:IsInstanceMap(Nx.Map.UpdateMapID) then
			self.Scale = 256.0
		end
		if Nx.db.profile.Map.MaxCenter then
			self:CenterMap()
		end
		self.StepTime = min (self.StepTime, 1)
	end
end

--------
-- Key binding toggle owned minimap to full size
-- global func

function Nx:NXMapKeyTogMiniFull()

	if Nx.Free then
		return
	end

	local map = Nx.Map:GetMap (1)
	map.LOpts.NXMMFull = not map.LOpts.NXMMFull
	map.MMZoomChanged = true
	map.MMMenuIFull:SetChecked (map.LOpts.NXMMFull)
	Nx.Menu:CheckUpdate (map.MMMenuIFull)
end

--------
-- Key binding toggle herbs
-- global func

function Nx:NXMapKeyTogHerb()
	local map = Nx.Map:GetMap (1)
	Nx.db.char.Map.ShowGatherH = not Nx.db.char.Map.ShowGatherH
	map.MenuIShowHerb:SetChecked (Nx.db.char.Map, "ShowGatherH")
	map.Guide:UpdateGatherFolders()
end

--------
-- Key binding toggle mining
-- global func

function Nx:NXMapKeyTogMine()
	local map = Nx.Map:GetMap (1)
	Nx.db.char.Map.ShowGatherM = not Nx.db.char.Map.ShowGatherM
	map.MenuIShowMine:SetChecked (Nx.db.char.Map, "ShowGatherM")
	map.Guide:UpdateGatherFolders()
end

--------
-- Enable or disable map mouse input

function Nx.Map:MouseEnable (max)

--	Nx.prt ("MouseEnable %s %s", max and "max" or "min", alt and 1 or 0)

	local on = true

	if max then
		if Nx.db.profile.Map.MaxMouseIgnore then
			on = IsAltKeyDown() and true or false		-- IsAltKeyDown returns nil or 1
		end
	else
		if Nx.db.profile.Map.MaxMouseIgnore then
			on = IsAltKeyDown() and true or false		-- IsAltKeyDown returns nil or 1
		end
	end

	if self.MouseEnabled ~= on then

--		Nx.prt ("MouseEnable up")

		self.MouseEnabled = on

		self.Win:EnableMouse (on)

		if on then
			self.ButAutoScaleOn.Frm:Show()
			self:UpdateToolBar()		-- Will show or hide
		else
			self.ButAutoScaleOn.Frm:Hide()
			self.ToolBar.Frm:Hide()
		end

		self.Frm:EnableMouse (on)
		self.Frm:EnableMouseWheel (on)

		self.MMFrm:EnableMouse (on)
		self.MMFrm:EnableMouseWheel (on)

		for n, f in ipairs (self.IconFrms) do
			f:EnableMouse (on)
		end

		for n, f in ipairs (self.IconStaticFrms) do
			f:EnableMouse (on)
		end
	end
	
	--[[if not Nx.db.profile.Map.MaxMouseIgnore and ((Nx.Map:IsInstanceMap(Nx.Map.RMapId) or Nx.Map:IsBattleGroundMap(Nx.Map.RMapId)) and self.CurOpts.NXInstanceMaps) then
		self.Win:EnableMouse (true)
		self.Frm:EnableMouse (true)
		self.ButAutoScaleOn.Frm:Show()
		self:UpdateToolBar()
	end]]--
end

--------
-- Handle events
-- self = map table

function Nx.Map:OnEvent (event, ...)
--	Nx.prtVar ("Map Event", self)
--	Nx.prt ("Map Event %s", event)
	local map = Nx.Map:GetMap (1)
	if event == "WORLD_MAP_UPDATE" then
		if not map.Win then
			return
		end		
		if map.Win.Frm:IsVisible() then
			map:UpdateAll()
		end
	elseif event == "PLAYER_REGEN_DISABLED" then
		local win = map.Win
		if (Nx.db.profile.Map.HideCombat and win:IsSizeMax()) then
			map.Win.Frm:Hide()
		end
		--map.Arch:Hide()
		--map.QuestWin:Hide()
		--map.Arch:SetParent(nil)
		--map.QuestWin:SetParent(nil)
		--map.Arch:ClearAllPoints()
		--map.QuestWin:ClearAllPoints()
	elseif event == "PLAYER_REGEN_ENABLED" then
		--map.Arch:SetParent(map.TextScFrm:GetScrollChild())		
		--map.QuestWin:SetParent(map.TextScFrm:GetScrollChild())		
		--map.Arch:Show()
		--map.QuestWin:Hide()
	elseif event == "ZONE_CHANGED_NEW_AREA" then
		-- DETECT EXIT INSTANCE
		if Nx.Map.NInstMapId then 
			Nx.Map:Menu_OnScaleRestore()
			Nx.Map.NInstMapId = nil
			Nx.Map:HideNewPlrFrame()
		end
	elseif event == "ZONE_CHANGED" then
		Nx.Map.Indoors = false
		Nx.Map.NInstMapId = nil
		Nx.Map:HideNewPlrFrame()
		Nx.Map:SetToCurrentZone()
	elseif event == "ZONE_CHANGED_INDOORS" then
		Nx.Map.Indoors = true
		Nx.Map.NInstMapId = nil
		Nx.Map:HideNewPlrFrame()
		Nx.Map:SetToCurrentZone()
	end
end

function Nx.Map:OnMouseDown (button)

	local map = self.NxMap	--V4 this
	local this = map.Frm

	local x, y = GetCursorPosition()
	x = x / this:GetEffectiveScale()
	y = y / this:GetEffectiveScale()

	map:CalcClick()

	ResetCursor()

--	Nx.prt ("Map MouseDown %s %s %s %s %s", button, x, y, rgt, bot)

	if button == "LeftButton" then

--[[
		if map["DebugHotspots"] then

			map.HotspotDebugCurT = nil

			if map:IsDoubleClick() then
				map.DebugMapId = map.MapId
			else
				map.LClickTime = GetTime()
				map.Scrolling = true
				map.ScrollingX = x
				map.ScrollingY = y
				map.ScrollingFrm = map.ClickFrm
			end
			return
		end
--]]

		if IsControlKeyDown() and map:CallFunc ("ButLCtrl") then	-- If func does nothing continue

		elseif IsAltKeyDown() and map:CallFunc ("ButLAlt") then	-- If func does nothing continue

		elseif IsShiftKeyDown() then
			map:Ping()

		else

			if map:IsDoubleClick() then

				map:CenterMap()
				map.DebugMapId = map.MapId

			else
				if (Nx.Map:IsInstanceMap(Nx.Map.RMapId) or Nx.Map:IsBattleGroundMap(Nx.Map.RMapId)) and map.CurOpts.NXInstanceMaps then
					return
				end
				map.LClickTime = GetTime()
				map.Scrolling = true
				map.ScrollingX = x
				map.ScrollingY = y
				map.ScrollingFrm = map.ClickFrm				
			end
		end

	elseif button == "MiddleButton" then

		if IsControlKeyDown() then
			map:CallFunc ("ButMCtrl")
		elseif IsAltKeyDown() then
			map:CallFunc ("ButMAlt")
		else
			map:CallFunc ("ButM")
		end

	elseif button == "RightButton" then

		if IsControlKeyDown() and map:CallFunc ("ButRCtrl") then

		elseif IsAltKeyDown() and map:CallFunc ("ButRAlt") then

		else
			map:CallFunc ("ButR")
		end

	elseif button == "Button4" then

		if IsControlKeyDown() then
			map:CallFunc ("But4Ctrl")
		elseif IsAltKeyDown() then
			map:CallFunc ("But4Alt")
		else
			map:CallFunc ("But4")
		end
	end
end

function Nx.Map:CalcClick()

	local f = self.Frm

	local x, y = GetCursorPosition()
	x = x / f:GetEffectiveScale()
	y = y / f:GetEffectiveScale()

	self.ClickFrmX = x - f:GetLeft()
	self.ClickFrmY = f:GetTop() - y
end

function Nx.Map:IsDoubleClick()

	if GetTime() - self.LClickTime < .5 then
--		Nx.prt ("Map DBL Click")
		self.LClickTime = 0
		return true
	end
end

function Nx.Map:OpenMenu()

	local opts = self:GetOptionsT (self.MapIndex)
	self.MenuIInstanceMaps:SetChecked (self.CurOpts.NXInstanceMaps)
	self.MenuIPlyrFollow:SetChecked (self.CurOpts.NXPlyrFollow)
	self.MenuIShowWorld:SetChecked (self.CurOpts.NXWorldShow)

--PAIDS!
	self.MenuIMonitorZone:SetChecked (Nx.Com:IsZoneMonitored (self.MapId))
--PAIDE!

	self.MenuMapId = self.MapId

	self.Menu:Open()
end

function Nx.Map:OnMouseUp (button)

--	Nx.prt ("Map MouseUp "..tostring (button))

	local this = self			--V4
	local map = this.NxMap
	map.Scrolling = false
end

--------

function Nx.Map:ClickZoomIn()
	self:MouseWheel (1)
end

function Nx.Map:ClickZoomOut()
	self:MouseWheel (-1)
end

function Nx.Map:OnMouseWheel (value)
	self.NxMap:MouseWheel (value)
end

function Nx.Map:MouseWheel (value)

--	Nx.prt ("Map MouseWheel "..tostring (value))

	local map = self
	local this = map.Frm
	if (Nx.Map:IsInstanceMap(Nx.Map.RMapId) or Nx.Map:IsBattleGroundMap(Nx.Map.RMapId)) and map.CurOpts.NXInstanceMaps then
		return
	end
	if map.MMZoomType == 0 and Nx.Util_IsMouseOver (map.MMFrm) then

		map.MMZoomChanged = true

		local i = Nx.db.profile.MiniMap.DockZoom

		if value < 0 then
			i = max (i - 1, 0)
		else
			i = min (i + 1, 5)
		end

		Nx.db.profile.MiniMap.DockZoom = i

		return
	end

	local x, y = GetCursorPosition()
	x = x / this:GetEffectiveScale()
	y = y / this:GetEffectiveScale()

	local left = this:GetLeft()
	local rgt = this:GetRight()
	local top = this:GetTop()
	local bot = this:GetBottom()

	local ox = map.MapPosX + (x - left - map.PadX - map.MapW / 2) / map.Scale
	local oy = map.MapPosY + (top - y - map.TitleH - map.MapH / 2) / map.Scale

	map.Scale = map:ScrollScale (value)
	map.StepTime = 10
	map.MapScale = map.Scale / 10.02
	local nx = map.MapPosX + (x - left - map.PadX - map.MapW / 2) / map.Scale
	local ny = map.MapPosY + (top - y - map.TitleH - map.MapH / 2) / map.Scale

	map.MapPosX = map.MapPosX + ox - nx
	map.MapPosY = map.MapPosY + oy - ny
end

function Nx.Map:ScrollScale (value)

	local s = self.Scale
	if value < 0 then
		value = value * .76923
	end

	return math.max (s + value * s * .3, .015)
end

function Nx.Map:SetScaleOverTime (steps)

	local step = steps >= 0 and 1 or -1
	for n = 1, abs (steps) do
		self.Scale = self:ScrollScale (step)
	end

	self.StepTime = 10
end

--------
-- Update event handler
local ttl = 0
function Nx.Map.OnUpdate (this, elapsed)	--V4 this

	ttl = ttl + elapsed
	if ttl < (Nx.db.profile.Map.mapUpdate or .05) then
		return
	end
	ttl = 0
	
	-- Temp HACK - Hide unused HANDYNOTES icons
	--[[if not WorldMapFrame:IsShown() then
		for n = 1, 2000 do 
			if _G["HandyNotesPin"..n] then
				_G["HandyNotesPin"..n]:Hide()
			else
				break
			end 
		end
	end]]--
	
	if _G['ReputationFrame'] then
		if not _G['ReputationFrame'].CarbFix then
			_G['ReputationFrame'].CarbFix = true
			_G['ReputationFrame']:UnregisterEvent('QUEST_LOG_UPDATE')
			_G['ReputationFrame']:RegisterEvent('UNIT_QUEST_LOG_CHANGED')
			_G['ReputationFrame']:HookScript('OnShow', function(self, event, ...)
				_G['ReputationFrame']:UnregisterEvent('QUEST_LOG_UPDATE')
				_G['ReputationFrame']:RegisterEvent('UNIT_QUEST_LOG_CHANGED')
			end)
			_G['ReputationFrame']:HookScript('OnEvent', function(self, event, ...)
				if ( event == "UPDATE_FACTION" or event == "LFG_BONUS_FACTION_ID_UPDATED" or event == "UNIT_QUEST_LOG_CHANGED" ) then
					ReputationFrame_Update();
				end
			end)
		end
	end
	
	local Nx = Nx

	local profileTime = GetTime()

	local map = this.NxMap
	local gopts = map.GOpts

	map.Tick = map.Tick + 1

	map.EffScale = this:GetEffectiveScale()
	map.Size1 = Nx.db.profile.Map.LineThick * .75 / map.EffScale

	Nx.Map:UpdateOptions (map.MapIndex)

	local winx, winy = Nx.Util_IsMouseOver (this)
	if not this:IsVisible() or not map.MouseEnabled then
		winx = nil
		map.Scrolling = false
	end

	if (Nx.Map:IsInstanceMap(Nx.Map.RMapId) or Nx.Map:IsBattleGroundMap(Nx.Map.RMapId)) and map.CurOpts.NXInstanceMaps then	
		winx = nil	
		map.Scrolling = false
	end

	if map.MMZoomType == 0 and Nx.Util_IsMouseOver (map.MMFrm) then
		winx = nil
	end

	map.MouseIsOver = winx

	if winx then
		Nx.Map.MouseOver = true
	else
		Nx.Map.MouseOver = false
	end
	
	if Nx.Map:IsInstanceMap(Nx.Map.RMapId) then 												
		--winx = nil	
		--Nx.Map.MouseOver = false
	end
	
	-- Scroll map with mouse

	if map.Scrolling then		
		local cx, cy = GetCursorPosition()
		cx = cx / map.EffScale
		cy = cy / map.EffScale		
		local x = cx - map.ScrollingX
		local y = cy - map.ScrollingY

--[[
		if map["DebugHotspots"] or (map.Debug and IsAltKeyDown()) then
			if map:OnButScrollDebug (0, 0, x, -y) then
				x = 0
				y = 0
			end
		end
--]]

		if x ~= 0 or y ~= 0 then		-- Moved? Cancel double click
			map.LClickTime = 0
		end

		map.ScrollingX = cx
		map.ScrollingY = cy

		local left = this:GetLeft()
		local top = this:GetTop()

		local mx = x / map.ScaleDraw
		local my = y / map.ScaleDraw
		map.MapPosXDraw = map.MapPosXDraw - mx
		map.MapPosYDraw = map.MapPosYDraw + my

		map.MapPosX = map.MapPosXDraw
		map.MapPosY = map.MapPosYDraw
		map.Scale = map.ScaleDraw
	end

	map:Update (elapsed)

	-- Title text

	local title = ""
	if Nx.db.profile.Map.ShowTitleName then
		title = map:IdToName (map.UpdateMapID)
--		for n = 1, MAX_BATTLEFIELD_QUEUES do
		for n = 1, GetMaxBattlefieldID() do		-- Patch 4.3

			local status, _, instId = GetBattlefieldStatus (n)
			if status == "active" then
				title = title .. format (" #%s", instId)
				break
			end
		end
	end

	if Nx.db.profile.Map.ShowTitleXY then
		if map.PlyrRZX ~= 0 or map.PlyrRZY ~= 0 then				
			if map.DebugFullCoords then
				title = title .. format (" %4.2f, %4.2f", map.PlyrRZX, map.PlyrRZY)
			else
				title = title .. format (" %4.1f, %4.1f", map.PlyrRZX, map.PlyrRZY)
			end		
		end
	end

	if map.PlyrSpeed > 0 and Nx.db.profile.Map.ShowTitleSpeed then

		local speed = map.PlyrSpeed

		local sa = Nx.Map.MapWorldInfo[map.MapId] and Nx.Map.MapWorldInfo[map.MapId].ScaleAdjust or 1
		if sa then
			speed = speed * sa
		end

		speed = speed / 6.4 * 100 - 100
		if abs (speed) < .5 then	-- Removes small -0%
			speed = 0
		end
		title = title..format (" |cffa0a0a0" .. L["Speed"] .. "%+.0f%%", speed)
--		Nx.prt ("Speed %f %f, Tm %.4f, %.3f %.3f", map.PlyrSpeed, speed, elapsed, map.PlyrX, map.PlyrY)		-- DEBUG!
	end

--	title = title..format (" Dir %.1f", map.PlyrDir)

	local cursorLocStr = ""
	local cursorLocXY = ""

	local menuOpened = Nx.Menu:IsAnyOpened()

	if winx then

		map.BackgndAlphaTarget = map.BackgndAlphaFull

		winy = this:GetHeight() - winy

		if winy >= map.TitleH then

			local wx, wy = map:FramePosToWorldPos (winx, winy)			
			if not menuOpened then
--				local tm = GetTime()
				map:CheckWorldHotspots (wx, wy)
--				Nx.prt ("CheckWorldHotspots Time %s", GetTime() - tm)
			end

			local x, y = map:GetZonePos (Nx.Map.RMapId, wx, wy)			
			x = floor (x * 10) / 10	-- Chop fraction to tenths
			y = floor (y * 10) / 10
			local dist = ((wx - map.PlyrX) ^ 2 + (wy - map.PlyrY) ^ 2) ^ .5 * 4.575

			cursorLocXY = format ("|cff80b080%.1f %.1f %.0f " .. L["yds"], x, y, dist)
			cursorLocStr = cursorLocXY

			--[[local name = UpdateMapHighlight (x / 100, y / 100)
			if name then
				cursorLocStr = format ("%s\n|cffafafaf%s", cursorLocStr, name)
			end]]--
		end

	else
--		if GameTooltip:IsOwned (map.Win.Frm) and map.TooltipType == 1 then
--			Nx.prt ("map TT hide")
--			map.TooltipType = 0
--			GameTooltip:Hide()
--		end

		if not map.Scrolling and not menuOpened then

			map.BackgndAlphaTarget = map.BackgndAlphaFade

			local rid = map.RMapId

			if rid ~= 9000 then

				local mapId = map:GetCurrentMapId()
				if map:IsInstanceMap (rid) then
					if not Nx.Map.InstanceInfo[rid] then		-- Don't convert WotLK/Cata instances
						local lrid = Nx.Map.MapWorldInfo[rid].EntryMId
						if lrid ~= nil then rid = lrid end
					end
					local lvl = Nx.Map:GetCurrentMapDungeonLevel()
					if lvl ~= map.InstLevelSet then
						map.MapId = 0	-- Force set
--						Nx.prt ("map force set inst")
					end
				end

				if map.UpdateMapID ~= rid then
					if map:IsBattleGroundMap (rid) then
						Nx.Map:SetToCurrentZone()
						Nx.Map.UpdateMapID = WorldMapFrame.mapID										
					else										
						map:SetCurrentMap (rid)
					end
				end
			end
		end
	end
	
	if IsIndoors() or Nx.Map.Indoors then 
		map.BackgndAlphaTarget = map.BackgndAlphaFull 
	end
	
	-- Check quest window
	if Nx.Quest then
		if map.Guide.Win.Frm:IsVisible() or Nx.Quest.List.Win and Nx.Quest.List.Win.Frm:IsVisible() then
			map.BackgndAlphaTarget = map.BackgndAlphaFull
		end
	end

	-- Profiling

	if map.DebugTime then

		profileTime = GetTime() - profileTime
		local t = map.DebugProfileTime or .01
		t = t * .95 + profileTime * .05
		map.DebugProfileTime = t

		UpdateAddOnMemoryUsage()
		local mem = GetAddOnMemoryUsage ("Carbonite")

		local memdif = mem - (map.DebugMemUse or 0)
		map.DebugMemUse = mem

		title = title..format (" Time %.4f Mem %d %.4f", t, mem, memdif)
	end

	if GetCVar ("scriptProfile") == "1" then

		UpdateAddOnCPUUsage()

		title = title..format (" |cffffffffCPU %6.3f %6.3f", GetAddOnCPUUsage ("CARBONITE"), GetScriptCPUUsage())

		ResetCPUUsage()
	end

	--

	if Nx.Tick % 3 == 0 then	-- Do less often, since tip makes garbage

		local tip = format (" %s", cursorLocStr)
		if map.Debug and winx then
			local x, y = map:FramePosToWorldPos (winx, winy)
			tip = tip .. format ("\n|cffc080a0%.2f WXY %6.2f %6.2f PXY %6.2f %6.2f", map.Scale, x, y, map.PlyrX, map.PlyrY)
			map.DebugWX = x
			map.DebugWY = y
		end

		local over = winx and not Nx.Util_IsMouseOver (map.ToolBar.Frm)
		map:SetLocationTip (over and not menuOpened and map.WorldHotspotTipStr and (map.WorldHotspotTipStr .. tip))
	end

	if map.Win:IsSizeMax() then
		local s = Nx.Map:GetZoneAchievement (true)
		if s then
			title = title .. "  " .. s
		end
	end

	map.Win:SetTitle (title, 1)

	if Nx.db.profile.Map.ShowTitle2 then

		local s = GetSubZoneText()
		local pvpType = GetZonePVPInfo()
		if pvpType then
			s = s .. " (" .. L[pvpType] .. ")"
		end
		map.Win:SetTitle (format ("%s %s", s, cursorLocXY), 2)
	end
end

--------
-- Handle mouse click on icon

--[[
function Nx.Map:WorldHotspotOnMouseDown (button)

--	Nx.prt ("MapWorldHotspotOnMouseDown "..button.." "..(this:GetName() or "?"))

	local map = this.NxMap
	map.ClickFrm = this
	this = map.Frm
	map:OnMouseDown (button)
end
--]]

--------
-- Handle mouse on icon

--[[
function Nx.Map:WorldHotspotOnEnter (motion)

	local map = this.NxMap

	if not map.Scrolling then

		local mapId = this.NxMapId
		map:SetCurrentMap (mapId)

		map:IconOnEnter (motion)
	end
end
--]]

--------
-- Flag for update all map data

function Nx.Map:UpdateAll()

	self.NeedWorldUpdate = true

--	Nx.prt ("%d Map UpdateAll %d (%d)", self.Tick, self:GetCurrentMapId(), self.MapId)
end

--------
-- Update all map data

function Nx.Map:UpdateWorld()

	if self.Debug then
--		Nx.prt ("%d Map UpdateWorld1 %d L%d",
--				self.Tick, self:GetCurrentMapId(), GetCurrentMapDungeonLevel())
	end

	self.NeedWorldUpdate = false
	if not Nx.Map.MouseOver and not Nx.Util_IsMouseOver(self.MMFrm) then			
		--Nx.Map:UnregisterEvent ("WORLD_MAP_UPDATE")
		Nx.Map:SetToCurrentZone()	
		--Nx.Map:RegisterEvent ("WORLD_MAP_UPDATE", "OnEvent")	
	end
	local mapId = self:GetCurrentMapId()
	
	local winfo = self.MapWorldInfo[mapId]
	if winfo and self.MapWorldInfo[mapId].BaseMap then
	  winfo = self.MapWorldInfo[self.MapWorldInfo[mapId].BaseMap]
	end
	if not winfo then
		winfo = {}
	end
	if winfo.MapLevel then
		if Nx.Map:GetCurrentMapDungeonLevel() ~= winfo.MapLevel then	-- Wrong level?
			--SetDungeonMapLevel (winfo.MapLevel)
		end
	end

	local i = self:GetExploredOverlayNum()

	if self.CurWorldUpdateMapId == mapId and i == self.CurWorldUpdateOverlayNum and Nx.Map:GetCurrentMapDungeonLevel() == self.LastDungeonLevel then
		return
	end

	self.CurWorldUpdateMapId = mapId
	self.CurWorldUpdateOverlayNum = i
	self.LastDungeonLevel = Nx.Map:GetCurrentMapDungeonLevel()

	self.LastDungeonLevel = Nx.Map:GetCurrentMapDungeonLevel()
--	local mapInfo = C_Map.GetMapInfo(mapId)
	local mapInfo = Nx.Map:GetMapInfo(mapId)
	local mapFileName = winfo.Overlay or (mapInfo.name and mapInfo.name:gsub(" ", "") or "")
	if not mapFileName then
		if Nx.Map:GetCurrentMapContinent() == WORLDMAP_COSMIC_ID then
			mapFileName = "Cosmic"
		else
			mapFileName = "World"
		end
	end
	local texPath = "Interface\\WorldMap\\"..(isMicro and "MicroDungeon\\"..mapFileName.."\\"..microTex or mapFileName).."\\"	
	local texName = microTex or mapFileName

	self:UpdateOverlayUnexplored()

	Nx.UEvents:UpdateMap (true)
	local dungeonLevel = Nx.Map:GetCurrentMapDungeonLevel();
	--[[if (DungeonUsesTerrainMap()) then
		dungeonLevel = dungeonLevel - 1;
	end]]--
	if dungeonLevel>0 then texName = texName..dungeonLevel.."_" end
	if winfo.MapBaseName and not winfo.Garrison then texName = winfo.MapBaseName end
	if winfo.Garrison and not isMicro then
		local level, mapname, x, y = C_Garrison.GetGarrisonInfo(LE_GARRISON_TYPE_6_0)
		if not level then
			level = "1"
		end
		texPath = "Interface\\WorldMap\\" .. winfo.MapBaseName .. level.."\\"
		texName = winfo.MapBaseName .. level
	end
	
	if self.Debug then
		Nx.prt ("%d Map UpdateWorld %d", self.Tick, self:GetCurrentMapId())
		Nx.prt (" File %s", texPath..texName..mapId)
	end
	
	local tileX = winfo.TileX or 4
	local tileY = winfo.TileY or 3
	local numtiles = tileX * tileY
	
	local GetMapArtLayerTexturesMapId = ((self.MapWorldInfo[mapId] and self.MapWorldInfo[mapId].RBaseMap) and self.MapWorldInfo[mapId].RBaseMap or mapId)
	if GetMapArtLayerTexturesMapId == nil then
		return
	end

	if GetMapArtLayerTexturesMapId == 12 then GetMapArtLayerTexturesMapId = 1414 end
	if GetMapArtLayerTexturesMapId == 13 then GetMapArtLayerTexturesMapId = 1415 end
	
	local texturesIDs = C_Map.GetMapArtLayerTextures(GetMapArtLayerTexturesMapId, 1)
	
	for i = 1, numtiles do
		self.TileFrms[i].texture:SetTexture (texturesIDs[i])
		self.TileFrms[i].texture:SetSnapToPixelGrid(false)
		self.TileFrms[i].texture:SetTexelSnappingBias(0)
	end
end

--------
-- Update window fade

function Nx.Map:WinUpdateFade (fade)
	--self.ToolBar:SetFade (fade * .9 + .1)
	self.ButAutoScaleOn.Frm:SetAlpha (fade * .9 + .1)
end

--------
-- Update map. Called every tick, make it quick

function Nx.Map:Update (elapsed)
	if IS_BACKGROUND_WORLD_CACHING then
		return
	end
	if WorldMapFrame:IsVisible() then
		--return
	end
	local Nx = Nx
	local Map = Nx.Map

	self:MouseEnable (self.Win:IsSizeMax())

	--if self.NeedWorldUpdate then		
		self:UpdateWorld()
	--end

	self.MapW = self.Frm:GetWidth() - self.PadX * 2
	self.MapH = self.Frm:GetHeight() - self.TitleH
	self.Level = self.Frm:GetFrameLevel() + 1	
	local mapId = Nx.Map:GetCurrentMapAreaID()
	self.Cont, self.Zone = self:IdToContZone (mapId)

	Nx.InSanctuary = GetZonePVPInfo() == "sanctuary"

	local doSetCurZone
	local mapChange

	if self.MapId ~= mapId then

--		Nx.prtD ("%d Map change %d to %d", self.Tick, self.MapId, mapId)

		self.CurMapBG = self:IsBattleGroundMap (mapId)

		if not self:IsBattleGroundMap (self.MapId) then
--			self.MapIdOld = self.MapId
			self:AddOldMap (mapId)
		end

		self.MapId = mapId
		mapChange = true

		Nx.Com.PlyrChange = GetTime()
	end

	local rid = self.MapId
	Nx.Map.UpdateMapID = rid
	local inBG = self:IsBattleGroundMap (rid)
	
	if Nx.InBG and Nx.InBG ~= rid then	-- Left or changed BG?

--		Nx.prt ("Left BG %s", Nx.InBG)
		
		local cb = Nx.Combat

		if Nx.InArena then
			local s = Nx.Map:GetShortName (Nx.InArena)
			Nx.UEvents:AddInfo (format ("Left %s %d %d %dD %dH", s, cb.KBs, cb.Deaths, cb.DamDone, cb.HealDone))

		else
			local total = cb.KBs + cb.Deaths + cb.HKs + cb.Honor
			if total > 0 then
				local sname = Nx.Map:GetShortName (Nx.InBG)
				Nx.UEvents:AddInfo (format ("Left %s %d %d %d %d", sname, cb.KBs, cb.Deaths, cb.HKs, cb.Honor))

				local tm = GetTime() - cb.BGEnterTime
				--local _, honor = GetCurrencyInfo (392)		--V4
				--local hGain = honor - cb.BGEnterHonor
				
				RequestBattlefieldScoreData();
			
				for i=1, GetNumBattlefieldScores() do
					local name, killingBlows, honorableKills, deaths, hGain, faction, rank, race, class = GetBattlefieldScore(i);
					if (name == UnitName("player")) then
						Nx.UEvents:AddInfo (format (" %s +%d honor, +%d hour", Nx.Util_GetTimeElapsedMinSecStr (tm), hGain, hGain / tm * 3600))
					end
				end

				local xpGain = UnitXP ("player") - cb.BGEnterXP
				if xpGain > 0 then
					Nx.UEvents:AddInfo (format (" +%d xp, +%d hour", xpGain, xpGain / tm * 3600))
				end
			end
		end

		cb.KBs = 0
		cb.Deaths = 0
		cb.HKs = 0
		cb.Honor = 0
		Nx.InBG = nil

		if Nx.InArena then
			self.LOpts.NXMMFull = false
		end
		Nx.InArena = nil
	end

	if inBG and Nx.InBG ~= rid then
		Nx.InBG = rid

		local cb = Nx.Combat
		cb.BGEnterTime = GetTime()
		--local _, honor = GetCurrencyInfo (392)		--V4
		cb.BGEnterHonor = 0
		cb.BGEnterXP = UnitXP ("player")

		if self.MapWorldInfo[rid].Arena then
			Nx.InArena = rid
			self.LOpts.NXMMFull = true
		end

--		Nx.prt ("Entering BG %s", rid)
		doSetCurZone = true
	end

	-- Taxi update

	Nx.Map.DungeonLevel = Nx.Map:GetCurrentMapDungeonLevel()
	
	local ontaxi = UnitOnTaxi ("player")

	if ontaxi then
		if not Map.TaxiOn then	-- New taxi ride?
			Map.TaxiStartTime = GetTime()
			Map.TaxiOn = true
			if Nx.db.profile.Debug.DebugMap then
				Nx.prt ("Taxi start")
			end
		end

	elseif Map.TaxiOn then	-- Done with taxi
		Map.TaxiOn = false
		Map.TaxiX = nil		-- Clear so if we pop on a taxi by a unhooked method we don't track old

		local tm = GetTime() - Map.TaxiStartTime

		Nx.Travel:TaxiSaveTime (tm)

		if Nx.db.profile.Debug.DebugMap then
			Nx.prt ("Taxi time %.1f seconds", tm)
		end
	end

	-- Real map switch

	if Nx.Map.RMapId ~= rid then
		if rid ~= 9000 then
--			Nx.prtD ("Map zone changed %d, %d", rid, mapId)

			if Nx.Map.RMapId == 9000 then	-- Loading?
				self.CurOpts = nil
				self:SwitchOptions (rid, true)
			end
			if not Nx.Menu:IsAnyOpened() then
				Nx.Map:SetMapByID(rid)						
				Nx.Map.RMapId = rid				
				Nx.Map.DungeonLevel = Nx.Map:GetCurrentMapDungeonLevel()
				self:SwitchOptions (rid)
				self:SwitchRealMap (rid)
			end
		end
		--self.Scale = self.RealScale
	end
	local plZX, plZY = Nx.Map.GetPlayerMapPosition ("player")		
	if (Nx.Map:IsInstanceMap(Nx.Map.RMapId) or Nx.Map:IsBattleGroundMap(Nx.Map.RMapId)) and self.CurOpts.NXInstanceMaps then		
		Nx.Map.MoveWorldMap()
		Nx.Map:GetMap(1).PlyrFrm:Hide()
	else
		Nx.Map.RestoreWorldMap()
		Nx.Map:GetMap(1).PlyrFrm:Show()
	end
	if (Nx.Map.RMapId ~= Nx.Map.UpdateMapID) then
		plZX = 0
		plZY = 0
	end
	local dungeontest = Nx.Map:GetCurrentMapDungeonLevel()
	self.InstanceId = false
	
	if self:IsInstanceMap (Nx.Map.UpdateMapID) and not self.CurOpts.NXInstanceMaps then
		self.InstanceId = Nx.Map.UpdateMapID
		plZX = plZX * 100
		plZY = plZY * 100

--		self.PlyrInstX = plZX
--		self.PlyrInstY = plZY

--		Nx.prt ("XY %s %s", plZX, plZY)

		self.PlyrRZX = plZX
		self.PlyrRZY = plZY

		local x, y = self:GetWorldPos (Nx.Map.UpdateMapID, 0, 0)		
		local lvl = max (Nx.Map:GetCurrentMapDungeonLevel(), 1)		-- 0 if no level		
		if Nx.Map:GetCurrentMapAreaID() == 520 then
			if Nx.Map:GetCurrentMapDungeonLevel() == 0 then
				lvl = 1
			else
				lvl = 2
			end
		end

		if not self.InstMapId then		-- Not showing instance?
			plZX = 0
			plZY = 0

		elseif plZX == 0 and plZY == 0 then

			self.InstLevelSet = -1
		end

		local layerIndex = WorldMapFrame:GetCanvasContainer():GetCurrentLayerIndex();
		local layers = C_Map.GetMapArtLayers(mapId)

		self.PlyrX = x + plZX * layers[layerIndex].layerWidth / 25600
		self.PlyrY = y + plZY * layers[layerIndex].layerHeight / 25600 + (lvl - 1) * layers[layerIndex].layerHeight / 256
--		self.InstanceLevel = GetCurrentMapDungeonLevel()

		self.PlyrSpeed = 0
		
		Nx.Map.MouseOver = false
	elseif plZX > 0 or plZY > 0 then	-- Update world position of player if we can get it

		plZX = plZX * 100
		plZY = plZY * 100
		PLMapID = MapUtil.GetDisplayableMapForPlayer()
		if PLMapID == 1414 then PLMapID = 12 end
		if PLMapID == 1415 then PLMapID = 13 end

		local x, y = self:GetWorldPos (PLMapID, plZX, plZY)

		if elapsed > 0 then

			if x == self.PlyrX and y == self.PlyrY then	-- Not moving?
				self.PlyrSpeedCalcTime = GetTime()
				self.PlyrSpeed = 0
				self.PlyrSpeedX = x
				self.PlyrSpeedY = y				
			else
				local tmDif = GetTime() - self.PlyrSpeedCalcTime
				if tmDif > .5 then
					self.PlyrSpeedCalcTime = GetTime()
					self.PlyrSpeed = ((x - self.PlyrSpeedX) ^ 2 + (y - self.PlyrSpeedY) ^ 2) ^ .5 * 4.575 / tmDif
					self.PlyrSpeedX = x
					self.PlyrSpeedY = y					
				end
			end
		end

--		if elapsed > 0 then
--			self.PlyrSpeed = ((x - self.PlyrX) ^ 2 + (y - self.PlyrY) ^ 2) ^ .5 * 4.575 / elapsed
--		end

		self.PlyrX = x
		self.PlyrY = y
		if mapId ~= rid then			-- Not in real zone?
			if (self:IsMicroDungeon(mapId)) then
			else
				plZX, plZY = self:GetZonePos (rid, x, y)
			end
		end

		self.PlyrRZX = plZX
		self.PlyrRZY = plZY

		if mapChange then
			self.MoveLastX = x
			self.MoveLastY = y
		end
	end

--	Nx.prt ("Dir %s", GetPlayerFacing())
	self.PlyrDir = 0 
	if GetPlayerFacing() ~= nil then
		self.PlyrDir = 360 - GetPlayerFacing() / 2 / math.pi * 360
	end

	local plX = self.PlyrX
	local plY = self.PlyrY
	local x = plX - self.MoveLastX
	local y = plY - self.MoveLastY
	local ang = self.PlyrDir - self.PlyrLastDir

	local moveDist = (x * x + y * y) ^ .5

--	if moveDist > 0 then Nx.prt ("MoveDist %f %f", moveDist, self.BaseScale) end

	if moveDist >= .01 * self.BaseScale or abs (ang) > .01 then
		Nx.Com.PlyrChange = GetTime()

		if self.MoveLastX ~= -1 then
			self.MoveDir = math.deg (math.atan2 (x, -y / 1.5))
		end

		self.MoveLastX = plX
		self.MoveLastY = plY

--		if not rotOk then
--			self.PlyrDir = self.MoveDir
--		end

		self.PlyrLastDir = self.PlyrDir

		if not self.Scrolling and not self.MouseIsOver then			
			if self.CurOpts.NXPlyrFollow then
				local scOn = self.LOpts.NXAutoScaleOn		--self.GOpts["MapFollowChangeScale"]
				if plZX ~= 0 or plZY ~= 0 then
					if #self.Tracking == 0 or not scOn then
						self:Move (plX, plY, nil, 30)
					end
				end
				if scOn then					
					local midX
					local midY
					local dtx
					local dty
					local cX, cY
					if C_Map.GetBestMapForUnit("player") then
						local CorpseInfo = C_DeathInfo.GetCorpseMapPosition(C_Map.GetBestMapForUnit("player"))
						if CorpseInfo then
							cX = CorpseInfo.x or 0
							cY = CorpseInfo.y or 0
						end
					end
					if cX == nil or cY == nil then
						cX = 0
						cY = 0
					end
					
					if cX ~= 0 or cY ~= 0 then

						midX, midY = self:GetWorldPos (mapId, cX * 100, cY * 100)
						dtx = 1
						dty = 1

					elseif #self.Tracking > 0 then

						local tr = self.Tracking[1]
						midX = tr.TargetMX
						midY = tr.TargetMY
						dtx = abs (tr.TargetX1 - tr.TargetX2)
						dty = abs (tr.TargetY1 - tr.TargetY2)

					elseif Map.TaxiX then

						midX, midY = self.TaxiX, self.TaxiY
						dtx = 1
						dty = 1
					end

					if midX then

						local mX = (midX + self.PlyrX) * .5
						local mY = (midY + self.PlyrY) * .5						
						local dx = abs (midX - self.PlyrX)						
						local dy = abs (midY - self.PlyrY)						
--						Nx.prt ("Map scale target %f %f", dx, dy)
						if dx == 0 then
							dx = 0.1 
						end
						if dy == 0 then
							dy = 0.1
						end
						dx = self.MapW / dx
						dy = self.MapH / dy
						local scale = min (dx, dy) * .5
--						Nx.prt ("Map scales %f %f", dx, dy)

--						Nx.prt ("Map scale target %f %f", dtx, dty)
						if dtx == 0 then
							dtx = 0.1
						end
						if dty == 0 then
							dty = 0.1
						end
						dx = self.MapW / dtx
						dy = self.MapH / dty
						scale = min (min (dx, dy), scale)	-- Smaller of target rect of player to target center

						local scmax = self.InstanceId and 800 or self.LOpts.NXAutoScaleMax

						scale = max (min (scale, scmax), self.LOpts.NXAutoScaleMin)
						self:Move (mX, mY, scale, 30)
					end
				end

				if rid ~= mapId then
					doSetCurZone = true
--					Nx.prt ("Map Nx.Map:SetToCurrentZone")
				end
			end
		end
	end

	-- Adjust draw scale and position

	local scaleDiff = abs (self.ScaleDraw - self.Scale)
	local xDiff = self.MapPosXDraw - self.MapPosX
	local yDiff = self.MapPosYDraw - self.MapPosY

	if self.StepTime ~= 0 and (scaleDiff > 0 or xDiff ~= 0 or yDiff ~= 0) then
--	if (xDiff ~= 0 or yDiff ~= 0) and (self.Tick % 1 == 0) then

--		Nx.prt ("Tick %f", self.Tick)

		if self.StepTime > 0 then

--			Nx.prt ("Steptime Go #%d %f", self.Tick, self.StepTime)

			self.StepTime = -self.StepTime

			self.ScaleDrawW = 1 / self.ScaleDraw
			self.ScaleW = 1 / self.Scale
		end

		local st = -self.StepTime

		self.MapPosXDraw = Nx.Util_StepValue (self.MapPosXDraw, self.MapPosX, abs (xDiff) / st)
		self.MapPosYDraw = Nx.Util_StepValue (self.MapPosYDraw, self.MapPosY, abs (yDiff) / st)
		self.ScaleDrawW = Nx.Util_StepValue (self.ScaleDrawW, self.ScaleW, abs (self.ScaleDrawW - self.ScaleW) / st)
		self.ScaleDraw = 1 / self.ScaleDrawW

--		Nx.prt ("Map scrl #%d %f %f", self.StepTime, self.MapPosXDraw, self.MapPosX)
--		Nx.prt ("Map scrl %f %f", self.OCur, self.OEnd)
--		Nx.prt ("Map scrl %f %f", self.ScaleDraw, self.Scale)

		self.StepTime = self.StepTime + 1
	end

	local _, zx, zy, zw = self:GetWorldZoneInfo (self.Cont, self.Zone)
	if zx then
		self.MapScale = self.Scale / 10.02
	end

	--

	local plSize = Nx.db.profile.Map.PlyrArrowSize
	if IsShiftKeyDown() then
		plSize = 5
	end
	if self.PlyrFrm:IsVisible() then
		self:ClipFrameW (self.PlyrFrm, self.PlyrX, self.PlyrY, plSize, plSize, self.PlyrDir)
	end
	self.InCombat = UnitAffectingCombat ("player")
	local g = 1
	local b = 1
	local al = 1
	if self.InCombat then
		g = 0
		b = 0
		al = abs (GetTime() % 1 - .5) / .5 * .5 + .4
	end
	self.PlyrFrm.texture:SetVertexColor (1, g, b, al)

--	local str = format ("%s %d %d", UnitName ("player"), UnitHealth ("player"), UnitMana ("player"))
--	self.PlyrFrm.NxTip = str

	self.BackgndAlpha = Nx.Util_StepValue (self.BackgndAlpha, self.BackgndAlphaTarget, .05)
	self.Frm.texture:SetVertexColor (1, 1, 1, self.BackgndAlpha)

	self.WorldAlpha = (self.BackgndAlpha - self.BackgndAlphaFade) / (self.BackgndAlphaFull - self.BackgndAlphaFade) * self.BackgndAlphaFull

	self:ResetIcons()

	self:MoveContinents()
--	self:MoveWorldHotspots()

--	if not (IsAltKeyDown() and IsControlKeyDown()) then
--	end

	self:UpdateZones()
	self:UpdateInstanceMap()

	self:MinimapUpdate()
--	self.MMFrm:GetParent():SetAlpha(0)
	self:UpdateWorldMap()

	self:DrawContinentsPOIs()

	if Nx.db.profile.Map.ShowTrail then		
		self:UpdatePlyrHistory()
	end
	
--[[
	if self["DebugHotspots"] then
		self:UpdateHotspotsDebug()
	end
--]]
	if Nx.Social and Nx.scdb then
		if Nx.scdb.profile.Social.MapShowPunks then
			Nx.Social:UpdateIcons (self)
		end
	end

	-- Battlefield Vehicles

	local vtex = _G["VECHICLE_DRAW_INFO"]
	
	-- POI's (Points of interest)

	local oldLev = self.Level

	if IsShiftKeyDown() or inBG then
		oldLev = oldLev - 4
		self.Level = self.Level + 16
	end
	
	local type, name, description, txIndex, pX, pY, atlasIcon
	local txX1, txX2, txY1, txY2
	
	--local poiNum = 0 --GetNumMapLandmarks()
	if not IsAltKeyDown() then
		--for i = 1, poiNum do
		local tPOIs = {}--C_TaxiMap.GetTaxiNodesForMap(rid)
		local pPOIs = {}--C_PetInfo.GetPetTamersForMap(rid)
		local dPOIs = {}--C_ResearchInfo.GetDigSitesForMap(rid)
		
		local zPOIs = Nx.ArrayConcat(tPOIs, pPOIs, dPOIs)
		
		for i, zPOI in ipairs(zPOIs) do
			-- type, name, desc, txIndex, pX, pY = C_WorldMap.GetMapLandmarkInfo (n)
			local type = zPOI._type
			local name = zPOI.name
			local txIndex = zPOI.textureIndex
			local pX = zPOI.position.x
			local pY = zPOI.position.y
			local atlasIcon = zPOI.atlasName
			local desc = zPOI.description
			local faction = zPOI.faction
			
			local skip = false
			
			local _, splitname = strsplit(",", name)
			if type == 1 and not Nx.strpos(Nx.Map:GetMapNameByID(rid), strtrim(splitname and splitname or name)) then
				skip = true
			end
			
			-- type, name, desc, txIndex, pX, pY = C_WorldMap.GetMapLandmarkInfo (i)
			-- local type, name, desc, txIndex, pX, pY, mapLinkID, inBattleMap, graveyardID, areaID, poiID, isObjectIcon, atlasIcon = C_WorldMap.GetMapLandmarkInfo(i);
			-- Nx.prtCtrl ("LandMs %s, %s, %s, %s, %s, %s, %s, %s", i, poiID, txIndex or '-', name, type, isObjectIcon, atlasIcon, WorldMap_IsSpecialPOI(poiID))
			if (atlasIcon or (pX and txIndex ~= 0)) and not skip then		-- WotLK has 0 index POIs for named locations
				if (type ~= 4 or (type == 4 and Nx.db.char.Map.ShowArchBlobs)) and (faction == nil or faction == 0 or Nx.PlFactionNum == faction) then
					local tip = name
					if desc then
						tip = format ("%s\n%s", name, desc)
					end			
					pX = pX * 100
					pY = pY * 100
					
		--			Nx.prtCtrl ("poi %d %s %s %d", i, name, desc, txIndex)

					local f = self:GetIcon (3)

					if self.CurMapBG then

						f.NXType = 2000

						local iconType = Nx.MapPOITypes[txIndex]

						local sideStr = ""
						if iconType == 1 then	-- Ally?
							sideStr = " (Ally)"
						elseif iconType == 2 then	-- Horde?
							sideStr = " (Horde)"
						end

						if desc == L["In Conflict"] then

							local state = self.BGTimers[name]
							if state ~= txIndex then
								self.BGTimers[name] = txIndex
								self.BGTimers[name.."#"] = GetTime()
							end

							local dur = GetTime() - self.BGTimers[name.."#"]
							local doneDur = (rid == 461 or rid == 540 or rid == 736) and 64 or 241
							local leftDur = max (doneDur - dur, 0)
							local tmStr

							if leftDur < 60 then
								tmStr = format (":%02d", leftDur)
							else
								tmStr = format ("%d:%02d", floor (leftDur / 60), floor (leftDur % 60))
							end

							f.NXData = format ("1~%f~%f~%s%s %s", pX, pY, name, sideStr, tmStr)

							tip = format ("%s\n%s", tip, tmStr)

							-- Horizontal bar

							local sz = 30 / self.ScaleDraw

							local f2 = self:GetIcon (0)
							self:ClipFrameZTLO (f2, pX, pY, sz, sz, -15, -15)
							f2.texture:SetColorTexture (0, 0, 0, .35)

							f2.NXType = 2000
							f2.NxTip = tip
							f2.NXData = f.NXData

							local f2 = self:GetIconNI (1)

							if leftDur < 10 then

								if self.BGGrowBars then

									local al = abs (GetTime() % .4 - .2) / .2 * .2 + .8

									local f3 = self:GetIconNI (2)
									self:ClipFrameZTLO (f3, pX, pY, sz * (10 - leftDur) * .1, 3 / self.ScaleDraw, -15, -15)
									f3.texture:SetColorTexture (.5, 1, .5, al)

									local f3 = self:GetIconNI (2)
									self:ClipFrameZTLO (f3, pX, pY, sz * (10 - leftDur) * .1, 3 / self.ScaleDraw, -15, 12)
									f3.texture:SetColorTexture (.5, 1, .5, al)
								end

		--						f2.texture:SetColorTexture (.5, 1, .5, abs (GetTime() % .6 - .3) / .3 * .7 + .3)
							end

							local red = .3
							local blue = 1
							if iconType == 2 then	-- Horde?
								red = 1
								blue = .3
							end

							f2.texture:SetColorTexture (red, .3, blue, abs (GetTime() % 2 - 1) * .5 + .5)

							local per = leftDur / doneDur
							local vper = per > .1 and 1 or per * 10

							if self.BGGrowBars then
								per = 1 - per
								vper = 1
							else
								per = max (per, .1)
							end

							self:ClipFrameZTLO (f2, pX, pY, sz * per, sz * vper, -15, -15)

						else	-- No conflict

							f.NXData = format ("0~%f~%f~%s%s", pX, pY, name, sideStr)

							self.BGTimers[name] = nil

							-- Rect

							local sz = 30 / self.ScaleDraw

							local f2 = self:GetIcon (0)
							self:ClipFrameZTLO (f2, pX, pY, sz, sz, -15, -15)

		--					Nx.prtCtrl ("I %s %s %s", name, txIndex, iconType or "nil")

							if iconType == 1 then	-- Ally?
								f2.texture:SetColorTexture (0, 0, 1, .3)
		--						Nx.prtCtrl ("Blue")
							elseif iconType == 2 then	-- Horde?
								f2.texture:SetColorTexture (1, 0, 0, .3)
		--						Nx.prtCtrl ("Red")
							else
								f2.texture:SetColorTexture (0, 0, 0, .3)
							end

							f2.NXType = 2000
							f2.NxTip = tip
							f2.NXData = f.NXData

						end
					end

					f.NxTip = tip
					
					-- Sentinax and Broken Shore bosses
					if atlasIcon and (Nx.strpos(atlasIcon, 'DemonShip') == 1 or Nx.strpos(atlasIcon, 'DemonInvasion') == 1) then
						pX, pY = self:GetWorldPos (self.MapId, pX, pY)
						if self.ScaleDraw > 1 then	
							self:ClipFrameTL (f, pX-16, pY-16, 32 / self.ScaleDraw, 32 / self.ScaleDraw, 0)
						else
							self:ClipFrameTL (f, pX-16, pY-16, 32, 32, 0)
						end
						f.texture:SetAtlas(atlasIcon)
					else
						self:ClipFrameZ (f, pX, pY, 16, 16, 0)
						if atlasIcon then
							f.texture:SetAtlas(atlasIcon)
						else
							f.texture:SetTexture ("Interface\\Minimap\\POIIcons")
							txX1, txX2, txY1, txY2 = C_Minimap.GetPOITextureCoords (txIndex)
							f.texture:SetTexCoord (txX1 + .003, txX2 - .003, txY1 + .003, txY2 - .003)
							f.texture:SetVertexColor (1, 1, 1, 1)
						end
					end
				end
			end
		end
	end
	
	self.Level = oldLev + 4

	-- Update misc icons (herbs, ore, ...)
	-- Levels:
	--  +0 quest areas
	--  +1 quest area target
	--  +2-3 com players (++3 if alt key)
	--  +4 quest icons
	--  +5 ?

	Nx.HUD:Update (self)

	local comTrackName, comTrackX, comTrackY = Nx.Com:UpdateIcons (self)

	self.Level = self.Level + 2
	self.Guide:UpdateZonePOIIcons()
	for a,b in pairs(Nx.ModuleUpdateIcon) do
		if b ~= "test" then
			Nx[b]:UpdateIcons(self)
			self.Level = self.Level + 2
		end
	end

	self:UpdateIcons (self.KillShow)

	-- Battlefield flags

	local fX, fY, fToken
	local flagNum = GetNumBattlefieldFlagPositions()

	for i = 1, flagNum do

		fX, fY, fToken = GetBattlefieldFlagPosition (i)

		if fX ~= 0 or fY ~= 0 then

			local f = self:GetIconNI()
			f.texture:SetTexture (fToken)
			self:ClipFrameZ (f, (fX or 0) * 100, (fY or 0) * 100, 36, 36, 0)
		end
	end

	self.Level = self.Level + 1

	-- Raid or party icons (AKA group)

	local palName, palX, palY = self:UpdateGroup (plX, plY)

	-- Tracking animation

	if self.PlyrSpeed == 0 then

--		self.ArrowPulse = self.ArrowPulse + .05
--		if self.ArrowPulse > cnt then
--			self.ArrowPulse = 1
--		end

		self.ArrowScroll = self.ArrowScroll + .01
		if self.ArrowScroll >= 1 then
			self.ArrowScroll = 0
		end
	end

	-- Corpse or target tracking

	self.TrackDir = false

	self.Guide:OnMapUpdate()	-- For closest target

	if #self.Targets > 0 then

		self:UpdateTargets()
		self:UpdateTracking()
		self.Level = self.Level + 2
	end

	self.TrackETA = false
	local cX, cY
	if C_Map.GetBestMapForUnit("player") then
	  local CorpseInfo = C_DeathInfo.GetCorpseMapPosition(C_Map.GetBestMapForUnit("player"))
	  if CorpseInfo then
		  cX = CorpseInfo.x or 0
		  cY = CorpseInfo.y or 0
	  end
	end
	if cX == nil or cY == nil then
		cX = 0
		cY = 0
	end
	
	if (cX > 0 or cY > 0) and not inBG then	-- We dead, but not in BG?

		if Nx.db.profile.Track.ATCorpse then

			self.TrackName = "Corpse"

			local x, y = self:GetWorldPos (C_Map.GetBestMapForUnit("player"), cX * 100, cY * 100)
			self:DrawTracking (plX, plY, x, y, false, "D")

			local f = self:GetIcon (1)

			f.NxTip = "Your corpse"
			f.texture:SetTexture ("Interface\\Minimap\\POIIcons")
			self:ClipFrameZ (f, cX * 100, cY * 100, 16, 16, 0)
			-- Override clipping (FIX maybe?)
			f.texture:SetTexCoord (0.56640625, 0.6328125, 0.00390625, 0.0703125)	-- 16x16 grid (.0625 uv size)

			self.Level = self.Level + 2
		end

	elseif ontaxi and Map.TaxiX then

		if Nx.db.profile.Track.ATTaxi then

			self.TrackName = Map.TaxiName
			self.TrackETA = Map.TaxiETA

			local x, y = self.TaxiX, self.TaxiY
			self:DrawTracking (plX, plY, x, y, false, "F")

--			Nx.prt ("taxi %s %s", x, y)

			local f = self:GetIcon (1)

			f.NxTip = Map.TaxiName
			f.texture:SetTexture ("Interface\\AddOns\\Carbonite\\Gfx\\Ability_mount_wyvern_01")
			self:ClipFrameByMapType (f, x, y, 16, 16, 0)

			self.Level = self.Level + 2
		end
	end

	-- Battle ground or manual pal tracking

	if (palX or comTrackX) and (inBG or next (self.TrackPlyrs)) then

		if palX then

			self.TrackName = palName
			self:DrawTracking (plX, plY, palX, palY, false, "B")
		else
			self.TrackName = comTrackName
			self:DrawTracking (plX, plY, comTrackX, comTrackY, false)
		end

		self.Level = self.Level + 2
	end

	-- Set final levels

	self.TextScFrm:SetFrameLevel (self.Level)
	self.PlyrFrm:SetFrameLevel (self.Level + 1)

	self.ToolBar:SetLevels (self.Level + 2)

	self.Level = self.Level + 3

	self:MinimapUpdateEnd()		-- Uses 2 levels

	self.LocTipFrm:SetFrameLevel (self.Level + 2)

	-- Hide leftovers

	self:HideExtraIcons()

	-- Scan. Switch maps if needed. Do at end so we dont glitch

	if Nx.Tick % self.ScanContinentsMod == 3 then
		self:ScanContinents()
	end

	if doSetCurZone then		
		self:SetToCurrentZone()
	end
	
	self.Frm:SetAlpha(self.BackgndAlpha)
	
	-- Debug
--[[
	Nx.prt ("Map WPos %s ZPos %s WScale %s", self.GetWorldPosCnt or 0, self.GetZonePosCnt or 0, self.GetWorldZoneScaleCnt or 0)
	self.GetWorldPosCnt = 0
	self.GetZonePosCnt = 0
	self.GetWorldZoneScaleCnt = 0
--]]

end

function Nx.Map:SetInstanceMap (mapId)
	self.InstMapId = nil
	if not mapId then
		return
	end
	local Map = Nx.Map
	local info = Map.InstanceInfo[mapId]

	if not(info) then
		Nx.Map:GetInstanceMapTextures(mapId)
		info=Map.InstanceInfo[mapId]
	end

	local sizex, sizey = 1002, 668
	if info then
		self:SetCurrentMap (mapId)
		self.InstMapId = mapId
		self.InstMapInfo = info
		local winfo = Map.MapWorldInfo[mapId]
		if winfo.BaseMap then
			winfo = Map.MapWorldInfo[winfo.BaseMap]
		end
		local wx = winfo.X
		local wy = winfo.Y
		self.InstMapWX1 = wx
		self.InstMapWY1 = wy
		self.InstMapWX2 = wx + sizex / 256
		self.InstMapWY2 = wy + sizey / 256 * #info / 3
	end
end

function Nx.Map:GetNumDungeonMapLevels()
	local maps = { GetNumDungeonMapLevels() }
	local first = GetNumDungeonMapLevels()
	if not first then
		if Nx.Map:GetCurrentMapDungeonLevel() == 0 then
			return 0,0
		end
		return 1, 1
	end
	local count = 0
	for _ in pairs(maps) do 
		count = count + 1
	end	
	return count, 1
end

function Nx.Map:GetInstanceMapTextures(mapId)
	local areaId = mapId
	if areaId then
		Nx.Map:SetMapByID(areaId)
		local mapName = C_Map.GetMapInfo(mapId).name:gsub('%W','')
--		local levels, first = Nx.Map:GetNumDungeonMapLevels()
--		local useTerrainMap = DungeonUsesTerrainMap()
		Nx.Map.InstanceInfo[mapId] = {}		
		local fileName = mapName.."\\"..mapName;
		Nx.Map.InstanceInfo[mapId][4] = 0
		Nx.Map.InstanceInfo[mapId][5] = -100
		Nx.Map.InstanceInfo[mapId][6] = fileName
	end
end

--------
-- Switch to a new map
-- self = map

function Nx.Map:SwitchRealMap (id)
	if self:IsInstanceMap (id) then
		self:SetInstanceMap (id)			-- Turn it on
		
		self:GotoCurrentZone()
		--self:CenterMap (id)
		--[[local s = 100
		self.Scale = s
		self.RealScale = s
		self.StepTime = 10]]--
	else
		self:SetInstanceMap()				-- Turn it off
	end

	local map = Nx.Map:GetMap (1)
	map.Guide:UpdateMapIcons()
end
--------
-- Scan the continents for POI data

function Nx.Map:ScanContinents()

	Nx.Map.ScanContinentsMod = 500

	local oldCont = Nx.Map:GetCurrentMapContinent()
	if oldCont < 0 then
		return
	end

	--local oldZone = GetCurrentMapZone()
	local mapLvl = Nx.Map:GetCurrentMapDungeonLevel()
	local isMicroDungeon = Nx.Map:IsMicroDungeon(Nx.Map:GetCurrentMapAreaID())

--	Nx.prt ("ScanContinents cont zone, %s %s", oldCont, oldZone)

	--

	--ObjectiveTrackerFrame:UnregisterEvent ("WORLD_MAP_UPDATE")

	local hideT = {}
	hideT[0] = true	-- WotLK has 0 index POIs for named locations
	hideT[6] = not Nx.db.profile.Map.ShowCCity
	hideT[46] = not Nx.db.profile.Map.ShowCCity
	hideT[48] = not Nx.db.profile.Map.ShowCCity
	hideT[41] = not Nx.db.profile.Map.ShowCExtra
	hideT[5] = not Nx.db.profile.Map.ShowCTown

	for cont = 1, self.ContCnt do

		local poiT = {}
		self.ContPOIs[cont] = poiT

		--SetMapZoom (cont)
		local mapId = Nx.Map.MapZones[0][cont]
		
		local mapId2 = mapId
		if mapId2 == 12 then mapId2 = 1414 end
		if mapId2 == 13 then mapId2 = 1415 end
		
		local name, description, txIndex, pX, pY
		local txX1, txX2, txY1, txY2
		
		local areaPOIs = C_AreaPoiInfo.GetAreaPOIForMap(mapId2);
		for i, areaPoiID in ipairs(areaPOIs) do
			-- type, name, desc, txIndex, pX, pY = C_WorldMap.GetMapLandmarkInfo (n)
			local cPOI = C_AreaPoiInfo.GetAreaPOIInfo(mapId2, areaPoiID)
			name = cPOI.name
			txIndex = cPOI.textureIndex
			pX = cPOI.position.x
			pY = cPOI.position.y
				
			if pX and name and not hideT[txIndex] then

				local poi = {}
				tinsert (poiT, poi)
				poi.Name = name
				poi.Desc = desc
				poi.TxIndex = txIndex
				if cPOI.atlasName then 
					poi.atlasIcon = cPOI.atlasName
				end

				local x, y = self:GetWorldPos (mapId, pX * 100, pY * 100)
				poi.WX = x
				poi.WY = y
			end
		end
	end

	--
--[[
	local members = MAX_PARTY_MEMBERS
	local unitName = "party"
	local raid

	if IsInRaid() > 0 then
		members = MAX_RAID_MEMBERS
		unitName = "raid"
		raid = true
	end

	local pals = Nx.Com.PalNames
	local palName
	local palDist = 99999999
	local palX, palY
	local combatName
	local combatUnit
	local combatHealth
	local combatDist = 99999999
	local combatX, combatY

	local palsInfo = Nx.Com.PalsInfo

	for i = 1, members do

		local unit = unitName .. i
		local name, unitRealm = UnitName (unit)

		local mapId = self.MapId

		local pX, pY = Nx.GetPlayerMapPosition (unit)
		if pX <= 0 and pY <= 0 then

			local info = palsInfo[name]
			if info and info.EntryMId == mapId then
				mapId = info.MId
				pX = info.X + .00001
				pY = info.Y
			end

		else
			pX = pX * 100
			pY = pY * 100
		end

		if (pX ~= 0 or pY ~= 0) and not UnitIsUnit (unit, "player") then

			local fullName = unitRealm and (name .. "-" .. unitRealm) or name

			local wx, wy = self:GetWorldPos (mapId, pX, pY)

		end
	end
--]]
	-- Restore

	if(isMicroDungeon)then
		Nx.Map:SetToCurrentZone()		
	else
		--SetMapZoom (oldCont, oldZone)
		--SetDungeonMapLevel (mapLvl)
	end

	--ObjectiveTrackerFrame:RegisterEvent ("WORLD_MAP_UPDATE")
end

function Nx.Map:GetAreaPOIs(mapId)
	local areaPOIs = C_AreaPoiInfo.GetAreaPOIForMap(mapId);
	for i, areaPoiID in ipairs(areaPOIs) do
		local cPOI = C_AreaPoiInfo.GetAreaPOIInfo(mapId, areaPoiID)
		areaPOIs[i] = cPOI
	end
	return areaPOIs
end

--------
-- Draw the continents POI data

function Nx.Map:DrawContinentsPOIs()
	
	if self.ScaleDraw > self.LOpts.NXPOIAtScale then

		if not Nx.db.char.Map.ShowGatherA then
			return
		end
	end
	
	if not Nx.db.char.Map.ShowContPois then
		return
	end
	
	local getCoords = C_Minimap.GetPOITextureCoords

	for cont = 1, self.ContCnt do

		for k, poi in ipairs (self.ContPOIs[cont]) do
			local txi = poi.TxIndex
			local z = txi == 177 and 13 or 3

			local f = self:GetIcon (z)

			if self:ClipFrameByMapType (f, poi.WX, poi.WY, 16, 16, 0) then

				f.NxTip = poi.Name			 --.. poi.TxIndex

				-- 1 2
				-- 4 3

				local t1x, t1y, t4x, t4y, t2x = f.texture:GetTexCoord()

				f.texture:SetTexture ("Interface\\Minimap\\POIIcons")
				local txX1, txX2, txY1, txY2 = getCoords (txi)
--				f.texture:SetTexCoord (txX1 + .003, txX2 - .003, txY1 + .003, txY2 - .003)

				local x = txX1 + .003
				local y = txY1 + .003
				local w = txX2 - .003 - x
				local h = txY2 - .003 - y
				f.texture:SetTexCoord (x + w * t1x, x + w * t2x,
							y + h * t1y, y + h * t4y)

--				Nx.prtCtrl ("%s %s %s %s %s %s", t1x, t1y, t4x, t4y, t2x, t2y)
			end
		end
	end

	self.Level = self.Level + 1
end

--------
-- Draw group (raid or party)
-- (player world pos)

function Nx.Map:UpdateGroup (plX, plY)

	local alt = IsAltKeyDown()
	local redGlow = abs (GetTime() * 400 % 200 - 100) / 200 + .5

	local members = MAX_PARTY_MEMBERS
	local unitName = "party"
	local raid

	if IsInRaid() then
		members = MAX_RAID_MEMBERS
		unitName = "raid"
		raid = true
	end

	local pals = Nx.Com.PalNames
	local palName
	local palDist = 99999999
	local palX, palY
	local combatName
	local combatUnit
	local combatHealth
	local combatDist = 99999999
	local combatX, combatY

	local palsInfo = Nx.Com.PalsInfo

	for i = 1, members do

		local unit = unitName .. i
		local name, unitRealm = UnitName (unit)

		local mapId = self.MapId
		
		local pX, pY = Nx.Map.GetPlayerMapPosition (unit)
		
		if pX <= 0 and pY <= 0 then

			local info = palsInfo[name]
			if info and info.EntryMId == mapId then
				mapId = info.MId
				pX = info.X + .00001
				pY = info.Y
			end

		else
			pX = pX * 100
			pY = pY * 100
			local lvl = max (Nx.Map:GetCurrentMapDungeonLevel(), 1)
			if Nx.Map:GetCurrentMapAreaID() == 520 then
				if Nx.Map:GetCurrentMapDungeonLevel() == 0 then
					lvl = 1
				else
					lvl = 2
				end
			end
--			pY = pY + (((lvl - 1) * 668) / 256)
			pY = pY + (lvl - 1) * 100
		end
		if (pX ~= 0 or pY ~= 0) and not UnitIsUnit (unit, "player") then

			local fullName = unitRealm and #unitRealm > 0 and (name .. "-" .. unitRealm) or name

			local wx, wy = self:GetWorldPos (mapId, pX, pY)

			local sz = 16 * self.DotRaidScale
			if UnitInParty (unit) then
				sz = 18 * self.DotPartyScale
			end

			local cls = UnitClass (unit) or ""
			local inCombat
--PAIDS!
			inCombat = UnitAffectingCombat (unit)
--PAIDE!
			local h = UnitHealth (unit)
			if UnitIsDeadOrGhost (unit) then
				h = 0
			end
			local m = UnitHealthMax (unit)
			local per = min (Nx.Util_NanToZero(h / m), 1)			-- Can overflow?

			if per > 0 then

				if pals[name] ~= nil or self.TrackPlyrs[name] then

--					Nx.prtCtrl ("Pal %s", name)

					sz = 20 * self.DotPalScale

					if self.TrackPlyrs[name] then
						sz = 25 * self.DotPalScale
					end

					local dist = (plX - wx) ^ 2 + (plY - wy) ^ 2
					if dist < palDist then
						palName = name
						palDist = dist
						palX, palY = wx, wy

--						Nx.prtCtrl ("Pal %s %s", name, dist)
					end
				end

				if inCombat then

					local dist = (plX - wx) ^ 2 + (plY - wy) ^ 2
					if dist < combatDist then
						combatName = name
						combatUnit = unit
						combatHealth = per
						combatDist = dist
						combatX, combatY = wx, wy
					end
				end
			end

			local f1 = self:GetIcon (1)

			if self:ClipFrameByMapType (f1, wx, wy, sz, sz, 0) then

				f1.NXType = 1000
				f1.NXData = unit
				f1.NXData2 = fullName

				local inactive
				for n = 1, MAX_TARGET_DEBUFFS do
					if UnitDebuff (unit, n) == "Inactive" then
						inactive = true
						per = 0
						break
					end
				end

				local txName = "IconPlyrP"

				if pals[name] == false then
					txName = "IconPlyrF"
				elseif pals[name] == true then
					txName = "IconPlyrG"
				end

				if inCombat then
					txName = txName.."C"
				end

				f1.texture:SetTexture ("Interface\\AddOns\\Carbonite\\Gfx\\Map\\"..txName)

--				Nx.prt ("#%d %.1f %.1f", i, pX, pY)

				-- Show health

				local tStr = ""
--PAIDS!
				f = self:GetIconNI (2)

				if per > .33 then

					-- Horizontal bar at top left

					local sc = self.ScaleDraw
					self:ClipFrameTL (f, wx - 9 / sc, wy - 10 / sc, 16 * per / sc, 1 / sc)
--					self:ClipFrameZTLO (f, pX, pY, 12 * per / self.ScaleDraw, .9 / self.ScaleDraw, -7, -7)
					f.texture:SetColorTexture (1, 1, 1, 1)

				else
					self:ClipFrameByMapType (f, wx, wy, 7, 7, 0)
--					self:ClipFrameZ (f, pX, pY, 7, 7, 0)

					if per > 0 then
						f.texture:SetColorTexture (1, .1, .1, 1 - per * 2)
					else
						if inactive then
							f.texture:SetColorTexture (1, 0, 1, .7)	-- Punk
						else
							f.texture:SetColorTexture (0, 0, 0, .5)	-- Dead
						end
					end
				end

				-- Show target info

				local unitTarget = unit.."target"
				local tName = UnitName (unitTarget)
				local tEnPlayer

				if tName then

					local tLvl = UnitLevel (unitTarget)
					local tCls = UnitClass (unitTarget) or ""
					if tName == tCls then
						tCls = ""
					end

					local th = UnitHealth (unitTarget)
					if UnitIsDeadOrGhost (unitTarget) then
						th = 0
					end
					local tm = max (UnitHealthMax (unitTarget), 1)
					local per = min (Nx.Util_NanToZero(th / tm), 1)

--					Nx.prt ("H %d", th)

					local f = self:GetIconNI (2)
					local sc = self.ScaleDraw

					if UnitIsFriend ("player", unitTarget) then

						-- Horizontal green bar
						self:ClipFrameTL (f, wx - 9 / sc, wy - 2 / sc, 16 * per / sc, 1 / sc)
						f.texture:SetColorTexture (0, 1, 0, 1)

						tStr = format ("\n|cff80ff80%s %d %s %.f", tName, tLvl, tCls, th)

						if not UnitIsPlayer (unitTarget) then	-- NPC?
							tStr = tStr .. "%"
						end
					else
						self:ClipFrameTL (f, wx - 9 / sc, wy - 9 / sc, 1 / sc, 15 * per / sc)

						if UnitIsPlayer (unitTarget) then

							tEnPlayer = true
							tStr = format ("\n|cffff4040%s %d %s %.f%%", tName, tLvl, tCls, th)
							f.texture:SetColorTexture (redGlow, .1, 0, 1)

						elseif UnitIsEnemy ("player", unitTarget) then

							tStr = format ("\n|cffffff40%s %d %s %.f%%", tName, tLvl, tCls, th)

							if Nx:UnitIsPlusMob (unitTarget) then
								f.texture:SetColorTexture (1, .4, 1, 1)
							else
								f.texture:SetColorTexture (1, 1, 0, 1)
							end

						else
							tStr = format ("\n|cffc0c0ff%s %d %s %.f%%", tName, tLvl, tCls, th)
							f.texture:SetColorTexture (.7, .7, 1, 1)
						end
					end
				end
--PAIDE!
				local lvl = UnitLevel (unit)
				local qStr = Nx.Com:GetPlyrQStr (name)

				if raid then
					local name, rank, grp = GetRaidRosterInfo (i)
					cls = cls .. " G" .. grp
				end

				f1.NxTip = format ("%s %d %s %d%%\n(%d,%d) %s %s%s", fullName, lvl, cls, per * 100, pX, pY, inactive and "Inactive" or "", tStr, qStr or "")

--				if alt then
					-- tStr has \n
--					local s = tEnPlayer and (name .. tStr) or name
--					local txt = self:GetText (s)
--					self:MoveTextToIcon (txt, f1, 15, 1)
--				end
			end
		end
	end

	self.Level = self.Level + 3

	if palName and Nx.db.profile.Track.ATBGPal then
		if not combatName or combatDist > palDist then
			self.TrackPlayer = palName
			return palName, palX, palY
		end
	end

	if combatName then

		if not self.InCombat or combatDist > 35 then
			self.TrackPlayer = combatName
			return format ("Combat, %s %d%%", combatName, combatHealth * 100), combatX, combatY
		end
	end
end

--------
-- Draw player position history

function Nx.Map:UpdatePlyrHistory()

	local Map = Nx.Map			-- Use global map
	local hist = Map.PlyrHist

	local tm = GetTime()

	local scale = self.BaseScale
	local usezone = nil
	
	local x = hist.LastX - self.MoveLastX
	local y = hist.LastY - self.MoveLastY
	
	if (self:IsInstanceMap(Nx.Map.UpdateMapID) or self:IsBattleGroundMap(Nx.Map.UpdateMapID)) and self.CurOpts.NXInstanceMaps then
		local _x1, _y1 = self:GetZonePos(Nx.Map.UpdateMapID,hist.LastX,hist.LastY)
		local _x2, _y2 = self:GetZonePos(Nx.Map.UpdateMapID,self.MoveLastX,self.MoveLastY)
		x = _x1 - _x2
		y = _y1 - _y2
		scale = 1
	end		
	
	local moveDist = (x * x + y * y) ^ .5	
	
	if moveDist > Nx.db.profile.Map.TrailDist * scale then

		hist.LastX = self.MoveLastX
		hist.LastY = self.MoveLastY

		hist.Time = tm

		local next = hist.Next
		local o = next * 4 - 3

		hist[o] = GetTime()
		hist[o + 1] = self.PlyrX
		hist[o + 2] = self.PlyrY
		hist[o + 3] = self.PlyrDir

		if next >= hist.Cnt then
			next = 0
		end

		hist.Next = next + 1
	end

	local size = min (max (4 * self.ScaleDraw * self.BaseScale, 3), 25)
	local fadeTime = Nx.db.profile.Map.TrailTime	
	for n = 1, hist.Cnt * 4, 4 do

		local secs = hist[n]
		local tmdif = tm - secs

		if tmdif < fadeTime then

			local x = hist[n + 1]
			local y = hist[n + 2]
			local dir = hist[n + 3]
			
			local f = self:GetIconNI()
			
			if self:ClipFrameByMapType (f, x, y, size, size, dir) then
				f.texture:SetTexture ("Interface\\AddOns\\Carbonite\\Gfx\\Map\\IconCircleFade")
				local a = (fadeTime - tmdif) / fadeTime * .9
				f.texture:SetVertexColor (1, 0, 0, a)												
			end

		end
	end
end

--------
-- Targets

function Nx.Map:UpdateTargets()

	local delay = self.UpdateTargetDelay
	if delay > 0 then
		self.UpdateTargetDelay = delay - 1
		return
	end

	local tar = self.Targets[1]

	local x = tar.TargetMX - self.PlyrX
	local y = tar.TargetMY - self.PlyrY	
	
	local distYd = (x * x + y * y) ^ .5 * 4.575

	if (self:IsInstanceMap(Nx.Map.RMapId) or self:IsBattleGroundMap(Nx.Map.RMapId)) and self.CurOpts.NXInstanceMaps then
		local _x1, _y1 = self:GetZonePos(Nx.Map.RMapId,tar.TargetMX,tar.TargetMY)
		local _x2, _y2 = self:GetZonePos(Nx.Map.RMapId,self.PlyrX,self.PlyrY)
		x = _x1 - _x2
		y = _y1 - _y2
		distYd = (x * x + y * y) ^ .5
	end	
	
	if distYd < (tar.Radius or 7) * self.BaseScale then

		if tar.TargetType ~= "Q" then	-- Not for quest, so clear

			self.UpdateTargetDelay = 20
			self.UpdateTrackingDelay = 0

--			Nx.prtVar ("", self.Targets[1])

			tremove (self.Targets, 1)

			if #self.Targets > 0 and Nx.db.profile.Route.Recycle then
				tinsert (self.Targets, tar)
			end

			if Nx.db.profile.Track.TSoundOn then
				Nx:PlaySoundFile (567455)
			end

			UIErrorsFrame:AddMessage ("Target " .. tar.TargetName .. " reached", 1, 1, 1, 1)

			self.Guide:ClearAll()

			if tar.RadiusFunc then
--				Nx.prt ("Target radius func")
				tar.RadiusFunc ("distance", tar.UniqueId, tar.Radius, distYd, distYd)
				tar.RadiusFunc = nil
			end
		end
	end
end

function Nx.Map:UpdateTracking()

	local delay = self.UpdateTrackingDelay - 1

	if delay <= 0 then

		self:CalcTracking()
		delay = 45
	end

	self.UpdateTrackingDelay = delay

	--

	self.Level = self.Level + 2

	local dist1
	local dir1

	local srcX = self.PlyrX
	local srcY = self.PlyrY

	for n = 1, #self.Tracking do

		local tr = self.Tracking[n]

		self:DrawTracking (srcX, srcY, tr.TargetMX, tr.TargetMY, tr.TargetTex, tr.Mode, tr.TargetName)

		if n == 1 then
			self.TrackName = tr.TargetName
			dist1 = self.TrackDistYd
			dir1 = self.TrackDir
		end

		srcX = tr.TargetMX
		srcY = tr.TargetMY
	end

	self.TrackDistYd = dist1
	self.TrackDir = dir1
end

function Nx.Map:CalcTracking()
	local Travel = Nx.Travel

	local tr = {}
	self.Tracking = tr

	local srcX = self.PlyrX
	local srcY = self.PlyrY
	local srcMapId = MapUtil.GetDisplayableMapForPlayer()

	for n, tar in ipairs (self.Targets) do
		Travel:MakePath (tr, srcMapId, srcX, srcY, tar.MapId, tar.TargetMX, tar.TargetMY, tar.TargetType)

		tinsert (tr, tar)

		srcX = tar.TargetMX
		srcY = tar.TargetMY
		srcMapId = tar.MapId
	end
end

--------
-- Draw a tracking cursor and lines

function Nx.Map:DrawTracking (srcX, srcY, dstX, dstY, tex, mode, name)

	function shortendistance(n)
		if n >= 10^6 then
			return string.format("%.2fm", n / 10^6)
		elseif n >= 10^3 then
			return string.format("%.2fk", n / 10^3)
		else
			return tostring(n)
		end
	end

	local x = dstX - srcX
	local y = dstY - srcY

	local dist = (x * x + y * y) ^ .5
	self.TrackDistYd = dist * 4.575

	if tex ~= false then

		local f = self:GetIcon (1)

		local size = 16 * self.IconNavScale
		self:ClipFrameByMapType (f, dstX, dstY, size, size, 0)

		local s = name or self.TrackName
		f.NxTip = format ("%s\n%s " .. L["yds"], s, shortendistance(ceil(dist * 4.575)))

		f.texture:SetTexture (tex or "Interface\\AddOns\\Carbonite\\Gfx\\Map\\IconWayTarget")
	end

	self.TrackDir = false

	if 1 then

		local dir = math.deg (math.atan2 (y, x)) + 90

		self.TrackDir = dir

		local sx = self.ScaleDraw
		local sy = self.ScaleDraw / 1.5

		x = x * sx
		y = y * sy

		-- Offset toward target
--		local off = 1 / sqrt (x * x + y * y)
--		local xo = x * off
--		local yo = y * off

		local cnt = (x * x + y * y) ^ .5 / 15 / self.IconNavScale
		if cnt < 5 then
			cnt = cnt + .5
		end
		cnt = min (floor (cnt), 40)

		if cnt >= 1 then

			local dx = x / cnt
			local dy = y / cnt

			local offset = self.ArrowScroll
			x = dx * offset
			y = dy * offset

			local size = 16 * self.IconNavScale
--			local pulse = floor (self.ArrowPulse)
			local usedIcon = true
			local f

			for n = 1, cnt do

				local wx = srcX + x / sx
				local wy = srcY + y / sy

--[[			-- Needed if we use an offset
				if n >= cnt then
					if sqrt ((wx - srcX) ^ 2 + (wy - plY) ^ 2) > dist then
						Nx.prt ("Target arrow")
						break
					end
				end
--]]
				if usedIcon then
					usedIcon = false
					f = self:GetIconNI()
				end

				if self:ClipFrameByMapType (f, wx, wy, size, size, dir) then

					f.texture:SetTexture ("Interface\\AddOns\\Carbonite\\Gfx\\Map\\IconArrowGrad")

--					local a = n == pulse and .8 or .2
--					f.texture:SetVertexColor (1, 1, 1, a)

					if mode == "B" then
						f.texture:SetVertexColor (.7, .7, 1, .5)
					elseif mode == "F" then
						f.texture:SetVertexColor (1, 1, 0, .9)
					elseif mode == "D" then
						f.texture:SetVertexColor (1, 0, 0, 1)
					end

					usedIcon = true
				end

				x = x + dx
				y = y + dy
			end
		end
	end
end

--------
-- Move continent frames

function Nx.Map:MoveContinents()

	if self.CurOpts and self.CurOpts.NXWorldShow then

		for contN = 1, Nx.Map.ContCnt do
			local lvl = contN <= 2 and self.Level or self.Level + 1
			if contN == 12 then 
				lvl = 6 
				self.Level = self.Level + 6
			end
			self:MoveZoneTiles (contN, 0, self.ContFrms[contN], self.WorldAlpha, lvl)
		end

		local f = self.ContFillFrm
		if f then
			if Nx.V30 then
				self:ClipFrameTL (f, 1600, -1600, 1500, 4400, 0)
			else
				self:ClipFrameTL (f, 1600, -1900, 1500, 4650, 0)
			end
			f:SetFrameLevel (self.Level + 1)
			f:SetAlpha (self.WorldAlpha)
		end

--[[	-- Map cap
		local frms, frm

		frms = self.ContFrms[self.Cont or 1]

		for i = 1, 12 do
			frm = frms[i]
			if frm then
				frm.texture:SetVertexColor (0, 0, 0, 1)
			end
		end
--]]
		self.Level = self.Level + 2

	else

		local frms, frm

		for contN = 1, Nx.Map.ContCnt do
			frms = self.ContFrms[contN]
			local numtiles = 12
			if self.MapInfo[contN].TileX and self.MapInfo[contN].TileY then
				numtiles = self.MapInfo[contN].TileX * self.MapInfo[contN].TileY
			end
			for i = 1, numtiles do
				frm = frms[i]
				if frm then
					frm:Hide()
				end
			end
		end

		if self.ContFillFrm then
			self.ContFillFrm:Hide()
		end
	end
end

--------
-- Check world zone hotspots

function Nx.Map:CheckWorldHotspots (wx, wy)

	if IsAltKeyDown() then
		return
	end

	if self.InstMapId then
		if wx >= self.InstMapWX1 and wx <= self.InstMapWX2 and wy >= self.InstMapWY1 and wy <= self.InstMapWY2 then

			local lvl = floor ((wy - self.InstMapWY1) / 668 * 256) + 1

			if self.InstMapId ~= self.MapId then

--				Nx.prt ("Hit Inst %s, lvl %s", self.InstMapId, lvl)

				self:SetCurrentMap (self.InstMapId)
			end

			--SetDungeonMapLevel (lvl)

			self.InstLevelSet = -1

			self.WorldHotspotTipStr = self:IdToName(self.InstMapId) .. "\n"

			return
		end
	end

	local quad1 = self.WorldHotspotsCity
	local quad2 = self.WorldHotspots

	if self.NXCitiesUnder then
		quad1, quad2 = quad2, quad1
	end

	if self:CheckWorldHotspotsType (wx, wy, quad1) then
		return
	end

	if self:CheckWorldHotspotsType (wx, wy, quad2) then
		return
	end

	self.WorldHotspotTipStr = false

--	local tt = GameTooltip
--	if tt:IsOwned (self.Win.Frm) and self.TooltipType == 1 then
--		tt:Hide()
--	end
end

--------
-- Check world zone hotspots type
-- This is very fast. No need to make a quad tree

function Nx.Map:CheckDropdownListVisible()
	for i = 1, 10 do
		local _DropdownList = _G["DropDownList" .. i]
		if _DropdownList and _DropdownList:IsVisible() and _DropdownList:GetFrameStrata() == "FULLSCREEN_DIALOG" then
			return true
		end
	end
	
	return false
end

function Nx.Map:CheckWorldHotspotsType (wx, wy, quad)

	for n, spot in ipairs (quad) do
		if wx >= spot.WX1 and wx <= spot.WX2 and wy >= spot.WY1 and wy <= spot.WY2 then

			local curId = self:GetCurrentMapId()

			if spot.MapId ~= curId then

--				Nx.prt ("hotspot %s %s %s %s %s", spot.MapId, spot.WX1, spot.WX2, spot.WY1, spot.WY2)
				if not Nx.Map:CheckDropdownListVisible() then self:SetCurrentMap (spot.MapId) end		
			end
			Nx.Map.MouseIsOverMap = spot.MapId
			self.WorldHotspotTipStr = spot.NxTipBase .. "\n"
--[[
			if false then

				local tt = GameTooltip
				local owner = self.Win.Frm

				owner.NXTip = spot.NxTipBase

				if not tt:IsVisible() then

--					Nx.prt ("hotspot tip")

					local tippos = "ANCHOR_TOPLEFT"

					Nx.TooltipOwner = owner
					self.TooltipType = 1

					tt:SetOwner (owner, tippos, 0, 0)
					Nx:SetTooltipText (owner.NXTip .. Nx.Map.PlyrNamesTipStr)

					owner["UpdateTooltip"] = Nx.Map.OnUpdateTooltip
				end
			end
--]]
			return true
		end
	end
end

--------
-- Called by tooltip
-- self = frame

--[[
function Nx.Map:OnUpdateTooltip()

	local map = self.NxMap
	map:BuildPlyrLists()

	Nx:SetTooltipText (self.NXTip .. map.TipStr .. Nx.Map.PlyrNamesTipStr)

--	Nx.prt ("OnUpdateTooltip %s %s", self.NXTip, map.TipStr)
end
--]]

--------
-- Move world zone hotspot frames

--[[
function Nx.Map:MoveWorldHotspots()

	local clip = self.ClipFrameTL

	local level = self.Level
	local alpha = 0

	if self.Debug then
		level = level + 15
		alpha = self.BackgndAlpha * .5
	end

	self.Level = self.Level + 2

	local cont = self.Cont
	local zone = self.Zone

	local _, zx, zy, zw, zh = self:GetWorldZoneInfo (cont, zone)
	if not zx then
		return
	end

--	Nx.prt ("Map World XY "..basex.." "..basey)

	local frms = self.WorldHotFrms

	frms.UpStart = (frms.UpStart + 1) % 3

	for n = frms.UpStart + 1, #frms, 3 do

		local f = frms[n]

		if clip (self, f, f.NXWX, f.NXWY, f.NXW, f.NXH) then

			if self.DebugMap then
				f.texture:SetVertexColor (1, 1, 1, alpha)
			end

			f:SetFrameLevel (level + f.NXLev)

			f.NxTip = f.NxTipBase .. self.TipStr .. "~T"
		end
	end
end
--]]

--------
-- Update

function Nx.Map:SetLevelWorldHotspots()
--[[
	local lvl =	self.NXCitiesUnder and -1 or 1

	for _, f in ipairs (self.WorldHotFrms) do
		if f.NXLev ~= 0 then		-- A city?
			f.NXLev = lvl
		end
	end
--]]
end

--------
-- Update map zone tiles

function Nx.Map:MoveCurZoneTiles (clear)

	local mapId = self.MapId
	local wzone = self:GetWorldZone (mapId)
	if not wzone then
		wzone = {}
	end
	if not clear and
			(not wzone or wzone.City or (wzone.StartZone and Nx.Map.RMapId == mapId) or
			self:IsBattleGroundMap (Nx.Map.RMapId)) or self:IsMicroDungeon(Nx.Map.RMapId) then

--		Nx.prt ("MoveCurZoneTiles %d", mapId)
		local alpha = self.BackgndAlpha * (wzone.Alpha or 1)

		self:MoveZoneTiles (self.Cont, self.Zone, self.TileFrms, alpha, self.Level)
		self.Level = self.Level + 1

	else
--		Nx.prt ("ClearCurZoneTiles %d", mapId)
		local frms, frm

		frms = self.TileFrms

		for i = 1, 150 do
			frm = frms[i]
			if frm then
				frm:Hide()
			end
		end
	end
end

--------
-- Hide extra (Dalaran) map zone tiles

function Nx.Map:HideExtraZoneTiles()

	local frms = self.TileFrms
	frms[4]:Hide()
	frms[8]:Hide()
	frms[9]:Hide()
	frms[12]:Hide()
end

--------
-- Update map zone tiles (4 x 3 or custom TileX x TileY blocks)

function Nx.Map:MoveZoneTiles (cont, zone, frms, alpha, level)
	local zname, zx, zy, zw, zh = self:GetWorldZoneInfo (cont, zone)
	if not zx then
		return
	end
	-- Nx.prt ("MapZ %f, %f", zx, zy, zone)

	local scale = self.ScaleDraw
	local tilex, tiley
	if zone == 0 then
		tilex = self.MapInfo[cont].TileX or 4
		tiley = self.MapInfo[cont].TileY or 3
		
		if self.MapInfo[cont].ZXOff and self.MapInfo[cont].ZYOff then
			zx = zx + self.MapInfo[cont].ZXOff
			zy = zy + self.MapInfo[cont].ZYOff
		end
		
		if self.MapInfo[cont].ZWOff and self.MapInfo[cont].ZHOff then
			zw = zw + self.MapInfo[cont].ZWOff
			zh = zh + self.MapInfo[cont].ZHOff
		end
	else
		tilex = self.MapWorldInfo[zone].TileX or 4
		tiley = self.MapWorldInfo[zone].TileY or 3
		
		if self.MapWorldInfo[zone].ZXOff and self.MapWorldInfo[zone].ZYOff then
			zx = zx + self.MapWorldInfo[zone].ZXOff
			zy = zy + self.MapWorldInfo[zone].ZYOff
		end
		
		if self.MapWorldInfo[zone].ZWOff and self.MapWorldInfo[zone].ZHOff then
			zw = zw + self.MapWorldInfo[zone].ZWOff
			zh = zh + self.MapWorldInfo[zone].ZHOff
		end
	end
	
	--[[if cont == 11 then 
		zw = zw + (self.DebugMZWOff or 0)
		zh = zh + (self.DebugMZHOff or 0)
		zx = zx + (self.DebugMXOff or 0)
		zy = zy + (self.DebugMYOff or 0)
	end]]--
	
	local clipW = self.MapW
	local clipH = self.MapH
	local x = (zx - self.MapPosXDraw) * scale + clipW / 2
	local y = (zy - self.MapPosYDraw) * scale + clipH / 2
	local bx = 0
	local by = 0
	local bw = zw * (tilex == 15 and 1 or 1024 / 1002) / tilex * scale
	local bh = zh * (tiley == 10 and 1 or 768 / 668) / tiley * scale
	
	if zone > 0 then	
		local layerIndex = 1;--WorldMapFrame:GetCanvasContainer():GetCurrentLayerIndex();
		local layers = C_Map.GetMapArtLayers(zone);
		local layerInfo = layers[layerIndex];
		local TILE_SIZE_WIDTH = layerInfo.tileWidth;
		local TILE_SIZE_HEIGHT = layerInfo.tileHeight;
	end
	
	local w, h
	local texX1, texX2
	local texY1, texY2
	local numtiles = tilex * tiley
	
	for i = 1, numtiles do
		
		local frm = frms[i]
		if frm then
			--Nx.prt ("MapZ %f", i)
			texX1 = 0
			texX2 = 1
			texY1 = 0
			texY2 = 1

			local vx0 = bx * bw + x
			local vx1 = vx0
			local vx2 = vx0 + bw

			if vx1 < 0 then
				vx1 = 0
				texX1 = (vx1 - vx0) / bw
			end

			if vx2 > clipW then
				vx2 = clipW
				texX2 = (vx2 - vx0) / bw
			end

			local vy0 = by * bh + y
			local vy1 = vy0
			local vy2 = vy0 + bh

			if vy1 < 0 then
				vy1 = 0
				texY1 = (vy1 - vy0) / bh
			end

			if vy2 > clipH then
				vy2 = clipH
				texY2 = (vy2 - vy0) / bh
			end

			w = vx2 - vx1
			h = vy2 - vy1

			if w <= 0 or h <= 0 then
				frm:Hide()
			else
				frm:SetPoint ("TOPLEFT", vx1, -vy1 - self.TitleH)
				frm:SetWidth (w)
				frm:SetHeight (h)
				frm:SetFrameLevel (level)

				frm.texture:SetTexCoord (texX1, texX2, texY1, texY2)
				--frm.texture:SetVertexColor (1, 1, 1, self.BackgndAlpha)

				frm:Show()
			end
		end

		bx = bx + 1

		if bx >= tilex then
			bx = 0
			by = by + 1
		end
	end
end

--------
-- Add old map zone to list

function Nx.Map:AddOldMap (newMapId)

	if self.MapId == 0 then		-- Happens on startup
		return
	end

	-- Remove any for new zone

	local off = 1
	local dup

	for n = 1, #self.MapsDrawnOrder do
		if self.MapsDrawnOrder[off] == newMapId then
			tremove (self.MapsDrawnOrder, off)
			dup = true
		else
			off = off + 1
		end
	end

	local drawCnt = Nx.db.profile.Map.ZoneDrawCnt

	if not dup then

--		Nx.prt ("no dup")

		local extra = #self.MapsDrawnOrder - drawCnt + 2
		for n = 1, extra do
			tremove (self.MapsDrawnOrder, 1)
		end
	end

	if drawCnt > 1 then

		self.MapsDrawnFade[self.MapId] = -1
		tinsert (self.MapsDrawnOrder, self.MapId)		-- Newest at end

--		Nx.prt ("Cur map %s", self:GetCurrentMapId())
--		Nx.prtVar ("order", self.MapsDrawnOrder)
	end
end

--------
-- Update the zones

function Nx.Map:UpdateZones()

	local mapId = self.MapId
	local winfo = self.MapWorldInfo[mapId]
	if not winfo then
		winfo = {}
	end
--	Nx.prt ("UpdateZones %s, %s", mapId, winfo.Name or "nil")

	local s = self.LOpts.NXDetailScale

	local freeOrScale = self.ScaleDraw <= s

	if freeOrScale or
		winfo.City or winfo.NoTilemap or 
		(winfo.StartZone and Nx.Map.UpdateMapID == mapId) or
		self:IsBattleGroundMap (Nx.Map.UpdateMapID) or
		self:IsMicroDungeon(Nx.Map.UpdateMapID)  then

--		if freeOrScale and self.MapIdOld and self.MapIdOld ~= mapId then
--			self:UpdateOverlay (id, .8, true)
--		end
		for n, id in ipairs (self.MapsDrawnOrder) do
			self:UpdateOverlay (id, .8, true)
		end
		if winfo.City then
--			Nx.prt ("city %s", self.Level)
			self:UpdateMiniFrames()
			self:MoveCurZoneTiles()
		else
			self:MoveCurZoneTiles()
			self:UpdateOverlay (mapId, 1)
			self:UpdateMiniFrames()
		end

	else
		self:MoveCurZoneTiles (true)		-- Clear
		self:UpdateMiniFrames()
	end
end

function Nx.Map:GetExploredOverlayNum()

--	local overlayNum = GetNumMapOverlays()		-- Cartographer makes this return 0

	local overlays = C_MapExplorationInfo.GetExploredMapTextures(C_Map.GetBestMapForUnit('player') or 0)
	return overlays and #overlays or 0
end

function Nx.Map:UpdateOverlayUnexplored()

	self.CurOverlays = rm
	local txFolder

	local mapId = self:GetCurrentMapId(true)	
	local wzone = self:GetWorldZone (mapId)
	if wzone then
		if wzone.City then
			return
		end
		txFolder = wzone.Overlay
	end

	local overlays

	if txFolder then
		overlays = Nx.Map.ZoneOverlays[txFolder]
	end

	if not overlays or not self.ShowUnexplored then		
--		local overlayNum = GetNumMapOverlays()		-- Cartographer makes this return 0
--		Nx.prt ("Overlays %s", overlayNum)

		local s1, s2, file
		local ol = {}

		if overlays then
			for txName, whxyStr in pairs (overlays) do	-- Copy overlay table
				ol[txName] = whxyStr
			end
		end

		overlays = ol

		--[[for i = 1, 99 do

			-- Terrokar has 4 overlays with "" for name

			local txName, txW, txH, oX, oY = GetMapOverlayInfo (i)
			if not txName then
				break
			end

			local s1, s2, folder, file = strfind (txName, ".+\\.+\\(.+)\\(.+)")
			if s1 then
				txFolder = folder
				file = strlower (file)
				overlays[file] = format ("%d,%d,%d,%d", oX - 10000, oY, txW, txH)

--				Nx.prt (" %s %s", txName, overlays[file])
			end
		end]]--

		if not txFolder then		-- Can happen on log in
			overlays = false
		end
	end

	self.CurOverlays = overlays
	self.CurOverlaysTexFolder = txFolder
end

function Nx.Map:TargetOverlayUnexplored()

	local mapId = self:GetCurrentMapId(true)	
	self:ClearTargets()		-- Will change current mapid

	local wzone = self:GetWorldZone (mapId)
	if wzone and wzone.City then
		return
	end

	local overlays = self.CurOverlays

	if not overlays then	-- Not found? New stuff probably
		return
	end

	for txName, whxyStr in pairs (overlays) do

		local oX, oY, txW, txH = Nx.Split (",", whxyStr)

		oX = tonumber (oX)
		oY = tonumber (oY)

		if oX >= 0 then

			txW = tonumber (txW)
			txH = tonumber (txH)

			if txW == 512 then
				txW = txW * .75
			end
			if txH == 512 then
				txH = txH * .75
			end

--			Nx.prt ("%s %s %s %s %s", txName, oX, oY, txW, txH)

			local x, y = (oX + txW / 2) / 1002 * 100, (oY + txH / 2) / 668 * 100
--			local wx, wy = self:GetWorldPos (mapId, (oX) / 1002 * 100, (oY) / 668 * 100)

			self:SetTargetXY (mapId, x, y, "Explore", true)
		end
	end
end

--------
-- Update the overlays

function Nx.Map:UpdateOverlay (mapId, bright, noUnexplored)
	if(mapId == 0) then mapId = Nx.Map:GetCurrentMapAreaID(); end
	if (mapId == nil or mapId == -1) then
		return
	end
	local wzone = self:GetWorldZone (mapId)
	if wzone and (wzone.City or self:IsMicroDungeon(mapId)) then
		return
	end
	local txFolder = wzone and wzone.Overlay or ""	
	local overlays = Nx.Map.ZoneOverlays[txFolder]
	local unex
	if not noUnexplored and (not overlays or not self.ShowUnexplored) then
		if not (wzone and wzone.Explored) then
			unex = true
		end
		--overlays = self.CurOverlays
		--txFolder = self.CurOverlaysTexFolder
	end
	if self:IsBattleGroundMap(Nx.Map.UpdateMapID) then
		return
	end
	if not overlays then	-- Not found? New stuff probably
		return
	end

	local bW, bH
	local txIndex
	local txPixelW, txFileW, txPixelH, txFileH

	local path = "Interface\\Worldmap\\" .. txFolder .. "\\"

	local alpha = self.BackgndAlpha
	local unExAl = self.LOpts.NXUnexploredAlpha
	local zscale = self:GetWorldZoneScale (mapId) / 10

	local exploredWHXY = {}
	local explored = C_MapExplorationInfo.GetExploredMapTextures(mapId)
	if explored and unex then
		for i, ex in ipairs(explored) do
			local key = ex.offsetX..","..ex.offsetY..","..ex.textureWidth..","..ex.textureHeight;
			exploredWHXY[key] = true
		end
	end	
	
	local layerIndex = WorldMapFrame:GetCanvasContainer():GetCurrentLayerIndex();
	local layers = C_Map.GetMapArtLayers(mapId);
	local layerInfo = layers[layerIndex];
	local TILE_SIZE_WIDTH = layerInfo.tileWidth;
	local TILE_SIZE_HEIGHT = layerInfo.tileHeight;
	--Nx.prt ("%s TW TH: %s %s", mapId, TILE_SIZE_WIDTH, TILE_SIZE_HEIGHT)
	
	for txName, whxyStr in pairs (overlays) do		
		local lev = 0
		local brt = bright
		oName = txName
		txName = path .. txName

		local arTx
		if string.find(oName, ",") then
			arTx = {Nx.Split (",", oName)}
		end
		if tonumber(oName) then
		    arTx = {oName}	   
		end
		
		local oX, oY, txW, txH, mode = Nx.Split (",", whxyStr)
		if (oName == "dynamic") then
			return --txName, txW, txH, oX, oY = GetMapOverlayInfo(1)
		end

		local whxyKey = oX..","..oY..","..txW..","..txH
		if exploredWHXY[whxyKey] then
			oX = oX - 10000
		end
		
		txW = tonumber (txW)
		txH = tonumber (txH)
		oX = tonumber (oX)
		oY = tonumber (oY)
		
		if unex then		-- Dimming unexplored?
			if oX < 0 then
				oX = oX + 10000	-- Fix explored x
			else
				brt = unExAl		-- Dim
				lev = 1
			end
		end

--		if self.Debug then
--			Nx.prt ("%d %f %f", i, oX, oY)
--		end

		bW = ceil (txW / TILE_SIZE_WIDTH)
		bH = ceil (txH / TILE_SIZE_HEIGHT)
		txIndex = 1

		for bY = 0, bH - 1 do

			if bY < bH - 1 then
				txPixelH = TILE_SIZE_HEIGHT
				txFileH = TILE_SIZE_HEIGHT
			else
				txPixelH = mod (txH, TILE_SIZE_HEIGHT)
				if txPixelH == 0 then
					txPixelH = TILE_SIZE_HEIGHT
				end
				txFileH = 16
				while txFileH < txPixelH do
					txFileH = txFileH * 2
				end
			end

			for bX = 0, bW - 1 do

				if bX < bW - 1 then
					txPixelW = TILE_SIZE_WIDTH
					txFileW = TILE_SIZE_WIDTH
				else
					txPixelW = mod (txW, TILE_SIZE_WIDTH)
					if txPixelW == 0 then
						txPixelW = TILE_SIZE_WIDTH
					end
					txFileW = 16
					while txFileW < txPixelW do
						txFileW = txFileW * 2
					end
				end

				local f = self:GetIconNI (lev)

				local wx, wy = self:GetWorldPos (mapId, (oX + bX * TILE_SIZE_WIDTH) / layerInfo.layerWidth * 100, (oY + bY * TILE_SIZE_HEIGHT) / layerInfo.layerHeight * 100)

				if self:ClipFrameTL (f, wx, wy, txFileW * zscale, txFileH * zscale) then

					f.texture:SetColorTexture (1, 0, 0, 0) -- fix for background green overlays
--[[
					if IsAltKeyDown() then		-- DEBUG!
						alpha = .2
					end
--]]
					if arTx then
						f.texture:SetTexture (arTx[txIndex])
					else 
						f.texture:SetTexture (mode and txName or txName .. txIndex)
					end
					f.texture:SetVertexColor (brt, brt, brt, alpha)					
--					if IsControlKeyDown() then
--						Nx.prt ("Overlay %s, %s, %s %s", txName, txIndex, oX, oY)
--					end

--[[ -- Map cap
					if bright < 1 then
						f.texture:SetVertexColor (1, 1, 1, 1)
--						SetDesaturation (f.texture, 1)
					end
--]]
				end

				txIndex = txIndex + 1
			end
		end
	end

	self.Level = self.Level + 2	
end

--------
-- Update frames for mini map texture layer (detail layer)

function Nx.Map:UpdateMiniFrames()

--[[
	SaveView (5)
--	local x = GetCVar ("cameraYawD")
--	local y = GetCVar ("cameraPitchD")
--	local isLook = IsMouselooking()

--	Nx.prtCtrl ("Cam %s %s %s", x, y, isLook or "nil")

	local vartest = {
		"cameraYaw",
		"cameraYawA",
		"cameraYawB",
		"cameraYawC",
		"cameraYawD",
	}

	for k, name in pairs (vartest) do
		Nx.prtCtrl ("Cam %s %s", name, GetCVar (name) or "nil")
	end
--]]

	local Map = Nx.Map
	local mapId = self.MapId
	local winfo = self.MapWorldInfo[mapId]

	local opts = self.LOpts

	local alphaRange = opts.NXDetailScale * .35
	local s = opts.NXDetailScale - alphaRange

--	s = .1

--	or winfo.City

	if self.ScaleDraw <= s or opts.NXDetailAlpha <= 0 or self:IsBattleGroundMap (Nx.Map.UpdateMapID) or self:IsMicroDungeon(Nx.Map.UpdateMapID) then
		self:HideMiniFrames()
		return
	end

	local alphaPer = min ((self.ScaleDraw - s) / alphaRange, 1)
--	Nx.prt ("alpha %s", alphaPer)

--	local cont = self.Cont
--	local zname, zx, zy

	local miniT, basex, basey = self:GetMiniInfo (mapId)
--	basex = basex + (self.DebugPXOff or 0)
--	basey = basey + (self.DebugPYOff or 0)
	
	if not miniT then
		self:HideMiniFrames()
		return
	end

	local level = self.Level
	self.Level = self.Level + 1
	
	local f
	local frmNum = 1

	local scale = 256 * 0.416767770014
	local size = scale

--	size = size - 4

	local miniX = floor ((self.MapPosXDraw - basex) / scale - self.MiniBlks / 2 + .5)
	local miniY = floor ((self.MapPosYDraw - basey) / scale - self.MiniBlks / 2 + .5)

--	Nx.prt ("MiniXY %f %f", miniX, miniY)

	basex = basex + miniX * scale
	basey = basey + miniY * scale

	local wx
	local wy = basey
	local al = self.BackgndAlpha * opts.NXDetailAlpha * alphaPer

	for y = miniY, miniY + self.MiniBlks - 1 do

		wx = basex

		for x = miniX, miniX + self.MiniBlks - 1 do

			f = self.MiniFrms[frmNum]
			--Nx.prt(mapId.." | "..miniT[3] .." "..miniT[4] .." "..miniT[7].." | "..x.." "..y.." | "..(tonumber(format("%02d%02d", (x + miniT[3]), (y + miniT[4])))).." | "..(txname and txname or "nil"));
			local txname = miniT[1][tonumber(format("%02d%02d", (x + miniT[3]), (y + miniT[4])))] --Map:GetMiniBlkName (miniT, x, y)
			
			if txname and txname ~= "" then

				if self:ClipFrameTL (f, wx, wy, size, size) then

					f:SetFrameLevel (level)
					f.texture:SetVertexColor (1, 1, 1, al)
--					txname = "Textures\\Minimap\\"..txname
					f.texture:SetTexture (txname)
					
--					Nx.prtD("%s %s, %s", x, y, txname)
--[[
--					Nx.prtCtrl ("%s %s, %s", x, y, txname)

					local r, r2, r3 = f.texture:SetTexture (txname)		--V4 always returns r=1?
					Nx.prtVar ("mmtex", r)
					Nx.prtVar ("mmtex2", r2)
					Nx.prtVar ("mmtex3", r3)
					if not r then
						Nx.prtCtrl ("%s %s, %s", x, y, txname)
					end
--]]
				end

			else

				f:Hide()
			end

			wx = wx + scale
			frmNum = frmNum + 1
		end

		wy = wy + scale
	end

end

function Nx.Map:HideMiniFrames()

	for n = 1, self.MiniBlks ^ 2 do
		self.MiniFrms[n]:Hide()
	end
end

--------
-- Update POI

--[[
Nx.POITypes = { "Mailbox", "Anvil", "Forge", "Moonwell", "Manaloom" }
Nx.POITex = { "Icons\\INV_Letter_15",
	"Icons\\Trade_BlackSmithing",
	"Icons\\INV_Sword_09",
	"Icons\\Spell_Fire_BlueFlameRing",
	"Icons\\Spell_Fire_BlueFlameRing"
}

function Nx.Map:UpdateNxPOI()

	local Map = Nx.Map

	for poiType, v in pairs (Nx.POI) do

		local str = Nx.POI[poiType]

		for n = 1, #str, 5 do

			local zone = strbyte (str, n)
			if not zone then
				break
			end

			zone = zone - 35

			local x = ((strbyte (str, n + 1) - 35) * 221 + (strbyte (str, n + 2) - 35)) / 100
			local y = ((strbyte (str, n + 3) - 35) * 221 + (strbyte (str, n + 4) - 35)) / 100

			if self.Debug then
--				Nx.prt ("POI #%d %d %d %d", (n+4) / 5, zone, x, y)
			end

			local mapId = Map.NxzoneToMapId[tonumber (zone)]

			if not mapId then
--				Nx.prt ("POI #%d %d %d %d", (n+4) / 5, zone, x, y)

			else
				x, y = self:GetWorldPos (mapId, x, y)

				local f = self:GetIcon()

				if self:ClipFrameW (f, x, y, 16, 16, 0) then
					f.NxTip = format ("%s", Nx.POITypes[poiType])
					f.texture:SetTexture ("Interface\\" .. Nx.POITex[poiType])
				end
			end
		end
	end
end
--]]

--------
--
--[[
function Nx.Map:DrawZoneRect (mapId, x, y, w, h, tip)

	mapId = mapId or self.MapId

	local wx, wy = self:GetWorldPos (mapId, x, y)
	local scale = self:GetWorldZoneScale (mapId) / 10.02

	local f = map:GetIcon()

	if self:ClipFrameTL (f, wx, wy, w * scale, h * scale) then
		f.NxTip = tip
		f.texture:SetTexture (r, g, b, .5)
	end
end
--]]

--------
-- Zone clip a frame to the map and set position, size and texture coords
-- XY is center. Width and height are not scaled

function Nx.Map:ClipFrameZ (frm, x, y, w, h, dir)

	x, y = self:GetWorldPos (self.MapId, x, y)
	return self:ClipFrameByMapType (frm, x, y, w, h, dir)
end

--------
-- Zone clip a frame to the map and set position (top left), size and texture coords
-- Width and height are scaled

function Nx.Map:ClipFrameZTL (frm, x, y, w, h)

	x, y = self:GetWorldPos (self.MapId, x, y)
	return self:ClipFrameTL (frm, x, y, w, h)
end

--------
-- Zone clip a frame (top left with offset)
-- Width and height are scaled

function Nx.Map:ClipFrameZTLO (frm, x, y, w, h, xo, yo)

	x, y = self:GetWorldPos (self.MapId, x, y)
	return self:ClipFrameTL (frm, x + xo / self.ScaleDraw, y + yo / self.ScaleDraw, w, h)
end


function Nx.Map:ClipFrameByMapType (frm, bx, by, w, h, dir)	
	if (self:IsInstanceMap(Nx.Map.RMapId) or self:IsBattleGroundMap(Nx.Map.RMapId)) and self.CurOpts.NXInstanceMaps then
		return self:ClipFrameMF (frm, bx, by, w, h, dir)
	else
		return self:ClipFrameW (frm, bx, by, w, h, dir)
	end
end

--------
-- Clip a frame to the map and set position, size and texture coords
-- XY is center. Width and height are not scaled

function Nx.Map:ClipFrameW (frm, bx, by, w, h, dir)	
	local scale = self.ScaleDraw

	-- Calc x

	local bw = w
	local clipW = self.MapW
	local x = (bx - self.MapPosXDraw) * scale + clipW * .5

	local texX1 = 0
	local texX2 = 1

	local vx0 = x - bw * .5		-- Center frame at bx
	local vx1 = vx0
	local vx2 = vx0 + bw

	if vx1 < 0 then
		vx1 = 0
		texX1 = (vx1 - vx0) / bw
	end

	if vx2 > clipW then
		vx2 = clipW
		texX2 = (vx2 - vx0) / bw
	end

	w = vx2 - vx1

	if w < .3 then

		if self.ScrollingFrm ~= frm then
			frm:Hide()
		else
			frm:SetWidth (.001)
		end
		return false
	end

	-- Calc y

	local bh = h
	local clipH = self.MapH
	local y = (by - self.MapPosYDraw) * scale + clipH * .5

	local texY1 = 0
	local texY2 = 1

	local vy0 = y - bh * .5		-- Center frame at by
	local vy1 = vy0
	local vy2 = vy0 + bh

	if vy1 < 0 then
		vy1 = 0
		texY1 = (vy1 - vy0) / bh
	end

	if vy2 > clipH then
		vy2 = clipH
		texY2 = (vy2 - vy0) / bh
	end

	h = vy2 - vy1

	if h < .3 then

		if self.ScrollingFrm ~= frm then
			frm:Hide()
		else
			frm:SetWidth (.001)
		end
		return false
	end

	-- Set frame

	frm:SetPoint ("TOPLEFT", vx1, -vy1 - self.TitleH)
	frm:SetWidth (w)
	frm:SetHeight (h)

	if dir == 0 then

		frm.texture:SetTexCoord (texX1, texX2, texY1, texY2)

	else
		-- 13 UV order
		-- 24
		local t1x, t1y, t2x, t2y, t3x, t3y, t4x, t4y

		-- Make UV range -.5 to .5
		texX1 = texX1 - .5
		texX2 = texX2 - .5
		texY1 = texY1 - .5
		texY2 = texY2 - .5

		local co = cos (dir)
		local si = sin (dir)
		t1x = texX1 * co + texY1 * si + .5
		t1y = texX1 * -si + texY1 * co + .5
		t2x = texX1 * co + texY2 * si + .5
		t2y = texX1 * -si + texY2 * co + .5
		t3x = texX2 * co + texY1 * si + .5
		t3y = texX2 * -si + texY1 * co + .5
		t4x = texX2 * co + texY2 * si + .5
		t4y = texX2 * -si + texY2 * co + .5
		frm.texture:SetTexCoord (t1x, t1y, t2x, t2y, t3x, t3y, t4x, t4y)

--		Nx.prt (" T1 "..t1x.." "..t1y)
--		Nx.prt (" T2 "..t2x.." "..t2y)
	end
	
	frm.texture:SetSnapToPixelGrid(false)
	frm.texture:SetTexelSnappingBias(0)
	
	frm:Show()

	return true
end

--------
-- Clip a frame to the map and set position, size and texture coords
-- XY is center. Width and height are not scaled

function Nx.Map:ClipFrameWChop (frm, bx, by, w, h)

	local bw = w
	local bh = h
	local clipW = self.MapW
	local clipH = self.MapH

	local scale = self.ScaleDraw
	local x = (bx - self.MapPosXDraw) * scale + clipW / 2
	local y = (by - self.MapPosYDraw) * scale + clipH / 2

	local texX1 = 0
	local texX2 = 1

	-- Center frame at bx, by

	local vx0 = x - bw * .5
	local vx1 = vx0
	local vx2 = vx0 + bw

	if vx1 < 0 then
		vx1 = 0
		texX1 = (vx1 - vx0) / bw
	end

	if vx2 > clipW then
		vx2 = clipW
		texX2 = (vx2 - vx0) / bw
	end

	w = vx2 - vx1

	if w < .3 then
		if self.ScrollingFrm ~= frm then
			frm:Hide()
		else
			frm:SetWidth (.001)
		end
		return false
	end

	local texY1 = 0
	local texY2 = 1

	local vy0 = y - bh * .5
	local vy1 = vy0
	local vy2 = vy0 + bh

	if vy1 < 0 then
		vy1 = 0
		texY1 = (vy1 - vy0) / bh
	end

	if vy2 > clipH then
		vy2 = clipH
		texY2 = (vy2 - vy0) / bh
	end

	h = vy2 - vy1

	if h < .3 then
		if self.ScrollingFrm ~= frm then
			frm:Hide()
		else
			frm:SetWidth (.001)
		end
		return false
	end

	frm:SetPoint ("TOPLEFT", vx1, -vy1 - self.TitleH)
	frm:SetWidth (w)
	frm:SetHeight (h)

	frm.texture:SetTexCoord (texX1 * .9 + .05, texX2 * .9 + .05, texY1 * .9 + .05, texY2 * .9 + .05)
	
	frm.texture:SetSnapToPixelGrid(false)
	frm.texture:SetTexelSnappingBias(0)
	
	frm:Show()

	return true
end

--------
-- Clip minimap frame to the map and set position, size and texture coords
-- XY is center. Width and height are not scaled

function Nx.Map:ClipMMW (frm, bx, by, w, h)

	local scale = self.ScaleDraw

	-- Each world unit maps to a pixel, so w * scale == size in pixels

	local bw = w * scale
	local bh = h * scale
	local clipW = self.MapW
	local clipH = self.MapH
	local x = (bx - self.MapPosXDraw) * scale + clipW * .5
	local y = (by - self.MapPosYDraw) * scale + clipH * .5

	local vx0 = x - bw * .5
	local vx1 = vx0
	local vx2 = vx0 + bw

	if vx1 < 0 or vx2 > clipW then
		return false
	end

	w = vx2 - vx1

	if w <= 0 then
		return false
	end

	local vy0 = y - bh * .5
	local vy1 = vy0
	local vy2 = vy0 + bh

	if vy1 < 0 or vy2 > clipH then
		return false
	end

	h = vy2 - vy1

	if h <= 0 then
		return false
	end

--	frm:SetPoint ("TOPLEFT", vx1, -vy1 - self.TitleH)
--	frm:SetWidth (w)
--	frm:SetHeight (h)

	local sc = w / 140
	self.MMFScale = sc

	local isc = Nx.db.profile.MiniMap.IScale
	self:MinimapSetScale (sc, isc)

--	frm:SetScale (sc)
	frm:SetPoint ("TOPLEFT", self.Frm, "TOPLEFT", vx1 / isc, (-vy1 - self.TitleH) / isc)

	frm:Show()

	return true
end

--------
-- Clip a frame to the map and set position (top left), size and texture coords
-- Width and height are scaled by base (zone) scale

function Nx.Map:ClipFrameTL (frm, bx, by, w, h)

	-- Each world unit maps to a pixel, so w * scale == size in pixels

	local scale = self.ScaleDraw

	-- Calc x

	local bw = w * scale
	local clipW = self.MapW
	local x = (bx - self.MapPosXDraw) * scale + clipW * .5

	local texX1 = 0
	local texX2 = 1

	local vx1 = x
	local vx2 = x + bw

	if vx1 < 0 then
		vx1 = 0
		texX1 = (vx1 - x) / bw
	end

	if vx2 > clipW then
		vx2 = clipW
		texX2 = (vx2 - x) / bw
	end

	w = vx2 - vx1

	if w < .3 then
		if self.ScrollingFrm ~= frm then
			frm:Hide()
		else
			frm:SetWidth (.001)
		end
		return false
	end

	-- Calc y

	local bh = h * scale
	local clipH = self.MapH
	local y = (by - self.MapPosYDraw) * scale + clipH * .5

	local texY1 = 0
	local texY2 = 1

	local vy1 = y
	local vy2 = y + bh

	if vy1 < 0 then
		vy1 = 0
		texY1 = (vy1 - y) / bh
	end

	if vy2 > clipH then
		vy2 = clipH
		texY2 = (vy2 - y) / bh
	end

	h = vy2 - vy1

	if h < .3 then
		if self.ScrollingFrm ~= frm then
			frm:Hide()
		else
			frm:SetWidth (.001)
		end
		return false
	end

	frm:SetPoint ("TOPLEFT", vx1, -vy1 - self.TitleH)

	if w <= 1.2 then		-- Adjust so we get a clean line
		w = self.Size1
		if w <= 0 then
			frm:SetWidth (.001)
			return
		end
	end

	if h <= 1.2 then
		h = self.Size1
		if h <= 0 then
			frm:SetWidth (.001)
			return
		end
	end

	frm:SetWidth (w)
	frm:SetHeight (h)

	frm.texture:SetTexCoord (Nx.Util_NanToZero(texX1), Nx.Util_NanToZero(texX2), Nx.Util_NanToZero(texY1), Nx.Util_NanToZero(texY2))
	
	frm.texture:SetSnapToPixelGrid(false)
	frm.texture:SetTexelSnappingBias(0)
	
	frm:Show()

	return true
end

--------
-- Clip a frame to the main carbonite map frame (absolute to TOPLEFT)

function Nx.Map:ClipFrameMF (frm, bx, by, w, h, dir)
	local x, y = Nx.Map:GetZonePos(self.MapId, bx, by)	
	
	local bw = w
	local clipW = self.MapW	

	local texX1 = 0
	local texX2 = 1

	local vx0 = x - bw * .5
	local vx1 = vx0
	local vx2 = vx0 + bw

	if vx1 < 0 then
		vx1 = 0
		texX1 = (vx1 - vx0) / bw
	end

	if vx2 > clipW then
		vx2 = clipW
		texX2 = (vx2 - vx0) / bw
	end

	w = vx2 - vx1
	
	local bh = h
	local clipH = self.MapH	
	
	local texY1 = 0
	local texY2 = 1

	local vy0 = y - bh * .5		-- Center frame at by
	local vy1 = vy0
	local vy2 = vy0 + bh

	if vy1 < 0 then
		vy1 = 0
		texY1 = (vy1 - vy0) / bh
	end

	if vy2 > clipH then
		vy2 = clipH
		texY2 = (vy2 - vy0) / bh
	end

	h = vy2 - vy1
	
	frm:SetPoint("TOPLEFT", x / 100 * self.MapW - 8, -y  / 100 * self.MapH + 8)
	
	frm:SetWidth (Nx.db.profile.Map.InstanceScale)
	frm:SetHeight (Nx.db.profile.Map.InstanceScale)
	
	frm.texture:SetTexCoord (0, 1, 0, 1)

	if dir == 0 then
		if texX1 <= 1 and texX1 >= 0 and texX2 <= 1 and texX2 >= 0 and texY1 <= 1 and texY1 >= 0 and texY2 <= 1 and texY2 >= 0 then
			frm.texture:SetTexCoord (texX1, texX2, texY1, texY2)
		end
	else
		local t1x, t1y, t2x, t2y, t3x, t3y, t4x, t4y
		texX1 = texX1 - .5
		texX2 = texX2 - .5
		texY1 = texY1 - .5
		texY2 = texY2 - .5

		local co = cos (dir)
		local si = sin (dir)
		t1x = texX1 * co + texY1 * si + .5
		t1y = texX1 * -si + texY1 * co + .5
		t2x = texX1 * co + texY2 * si + .5
		t2y = texX1 * -si + texY2 * co + .5
		t3x = texX2 * co + texY1 * si + .5
		t3y = texX2 * -si + texY1 * co + .5
		t4x = texX2 * co + texY2 * si + .5
		t4y = texX2 * -si + texY2 * co + .5
		if t1x <= 1 and t1x >= 0 and t2x <= 1 and t2x >= 0 and t3x <= 1 and t3x >= 0 and t4x <= 1 and t4x >= 0 and t1y <= 1 and t1y >= 0 and t2y <= 1 and t2y >= 0 and t3y <= 1 and t3y >= 0 and t4y <= 1 and t4y >= 0 then
			frm.texture:SetTexCoord (t1x, t1y, t2x, t2y, t3x, t3y, t4x, t4y)
		end
	end
	frm:SetFrameLevel(50)
	
	frm.texture:SetSnapToPixelGrid(false)
	frm.texture:SetTexelSnappingBias(0)
	
	frm:Show()

	return true, x, y
end

--------
-- Clip a frame to instance map

function Nx.Map:ClipFrameINST (frm, bx, by, w, h, ret)

	-- Each world unit maps to a pixel, so w * scale == size in pixels

	local scale = self.ScaleDraw

	-- Calc x

	local bw = w * scale
	local clipW = self.MapW
	local x = (bx - self.MapPosXDraw) * scale + clipW * .5

	local texX1 = 0
	local texX2 = 1
	
	local sx1 = 0
	local sx2 = 0
	
	local vx1 = x
	local vx2 = x + bw

	if vx1 < 0 then
		vx1 = 0
		texX1 = (vx1 - x) / bw
		sx1 = vx1 - x
	end

	if vx2 > clipW then
		vx2 = clipW
		texX2 = (vx2 - x) / bw
		sx2 = vx2 - (x + bw)
	end

	w = vx2 - vx1

	if w < .3 then
		if self.ScrollingFrm ~= frm then
			frm:Hide()
		else
			frm:SetWidth (.001)
		end
	end

	-- Calc y

	local bh = h * scale
	local clipH = self.MapH
	local y = (by - self.MapPosYDraw) * scale + clipH * .5

	local texY1 = 0
	local texY2 = 1
	
	local sy1 = 0
	local sy2 = 0
	
	local vy1 = y
	local vy2 = y + bh

	if vy1 < 0 then
		vy1 = 0
		texY1 = (vy1 - y) / bh
		sy1 = vy1 - y
	end

	if vy2 > clipH then
		vy2 = clipH
		texY2 = (vy2 - y) / bh
		sy2 = vy2 - (y + bh)
	end

	h = vy2 - vy1

	if h < .3 then
		if self.ScrollingFrm ~= frm then
			frm:Hide()
		else
			frm:SetWidth (.001)
		end
	end

	frm:SetPoint ("TOPLEFT", vx1, -vy1 - self.TitleH)

	if w <= 1.2 then		-- Adjust so we get a clean line
		--w = self.Size1
		if w <= 0 then
			frm:SetWidth (.001)
			return 0, 0, 0, 0
		end
	end

	if h <= 1.2 then
		--h = self.Size1
		if h <= 0 then
			frm:SetWidth (.001)
			return 0, 0, 0, 0
		end
	end

	frm:SetWidth (w)
	frm:SetHeight (h)
	frm:Show()

	return sx1, sy1, sx2, sy2
end

--------
-- Clip a frame to the map and set position (top left), size and texture coords
-- Width and height are scaled by base (zone) scale
-- Solid color texture version

function Nx.Map:ClipFrameTLSolid (frm, bx, by, w, h)

	-- Each world unit maps to a pixel, so w * scale == size in pixels

	local scale = self.ScaleDraw

	-- Calc x

	local clipW = self.MapW
	local vx1 = (bx - self.MapPosXDraw) * scale + clipW * .5
	local vx2 = vx1 + w * scale

	if vx1 < 0 then
		vx1 = 0
	end

	if vx2 > clipW then
		vx2 = clipW
	end

	w = vx2 - vx1

	if w < .3 then
		if self.ScrollingFrm ~= frm then
			frm:Hide()
		else
			frm:SetWidth (.001)
		end
		return false
	end

	-- Calc y

	local clipH = self.MapH
	local vy1 = (by - self.MapPosYDraw) * scale + clipH * .5
	local vy2 = vy1 + h * scale

	if vy1 < 0 then
		vy1 = 0
	end

	if vy2 > clipH then
		vy2 = clipH
	end

	h = vy2 - vy1

	if h < .3 then
		if self.ScrollingFrm ~= frm then
			frm:Hide()
		else
			frm:SetWidth (.001)
		end
		return false
	end

	frm:SetPoint ("TOPLEFT", vx1, -vy1 - self.TitleH)

	frm:SetWidth (w)
	frm:SetHeight (h)

	frm:Show()

	return true
end

--------
-- Clip full zone frame to map

function Nx.Map:ClipZoneFrm (cont, zone, frm, alpha)

	local zname, zx, zy, zw, zh
	zname, zx, zy, zw, zh = self:GetWorldZoneInfo (cont, zone)
	if not zx then
		return
	end

	local scale = self.ScaleDraw

	local clipW = self.MapW
	local clipH = self.MapH
	local x = (zx - self.MapPosXDraw) * scale + clipW / 2
	local y = (zy - self.MapPosYDraw) * scale + clipH / 2
	local bx = 0
	local by = 0
	local bw = zw * scale
	local bh = zh * scale
	local w, h

	local level = self.Level

	if frm then

		local vx0 = bx * bw + x
		local vx1 = vx0
		local vx2 = vx0 + bw

		local vy0 = by * bh + y
		local vy1 = vy0
		local vy2 = vy0 + bh

		w = vx2 - vx1
		h = vy2 - vy1

		if w <= 0 or h <= 0 then
			frm:Hide()
		else
			local sc = w / 1002
			vx1 = vx1 / sc
			vy1 = vy1 / sc
			frm:SetPoint ("TOPLEFT", vx1, -vy1 - self.TitleH)
			frm:SetScale (sc)
			if level then frm:SetFrameLevel (level) end

			frm:Show()

--			Nx.prt ("ClipZF %f, %f (%s)", vx1, vy1, sc)
		end
	end
end

--------
-- Init a map icon type and set drawing info

function Nx.Map:InitIconType (iconType, drawMode, texture, w, h)

	local d = self.Data

	local t = wipe (d[iconType] or {})
	d[iconType] = t
	t.Num = 0
	t.Enabled = true
	t.DrawMode = drawMode or "ZP"	-- Zone point is default
	t.Tex = texture
	t.W = w
	t.H = h
	t.Scale = 1	-- USED???	
end

--------
-- Clear a map icon type

function Nx.Map:ClearIconType (iconType)

	local d = self.Data
	d[iconType] = nil
end

--------
-- Set alpha for an icon type

function Nx.Map:SetIconTypeAlpha (iconType, alpha, alphaNear)

	local d = self.Data
	assert (d[iconType])

	d[iconType].Alpha = alpha
	d[iconType].AlphaNear = alphaNear
end

--------
-- Set at scale for an icon type

function Nx.Map:SetIconTypeAtScale (iconType, scale)

	local d = self.Data
	assert (d[iconType])

	d[iconType].AtScale = scale
end

--------
-- Set level for an icon type

function Nx.Map:SetIconTypeLevel (iconType, level)

	local d = self.Data
	assert (d[iconType])

	d[iconType].Lvl = level
end

--------
-- Set level for an icon type

function Nx.Map:SetIconTypeChop (iconType, on)

	local d = self.Data
	assert (d[iconType])

	d[iconType].ClipFunc = on and self.ClipFrameWChop or self.ClipFrameW
end

--------
-- Add point icon to map data
-- ret: icon

function Nx.Map:AddIconPt (iconType, x, y, level, color, texture, tx1, ty1, tx2, ty2)
	local d = self.Data

	assert (d[iconType])

	local tdata = d[iconType]
	tdata.Num = tdata.Num + 1 -- Use # instead??	

	local icon = {}
	tdata[tdata.Num] = icon

	icon.X = x
	icon.Y = y
	icon.iconType = iconType
	icon.Level = level	
	icon.Color = color
	icon.Tex = texture
	if tx1 and ty1 and tx2 and ty2 then
		icon.TX1 = tx1
		icon.TY1 = ty1
		icon.TX2 = tx2
		icon.TY2 = ty2
	end
	assert (tdata.Tex or texture or color)

	return icon
end

--------
-- Get icon count

function Nx.Map:GetIconCnt (iconType)

	return #self.Data[iconType]
end

--------
-- Get point icon XY at index (for routing code)

function Nx.Map:GetIconPt (iconType, index)

	local icon = self.Data[iconType][index]
	if (icon.Level == Nx.Map.DungeonLevel) then
		return icon.X, icon.Y
	end	
end

--------
-- Add rectangle icon to map data (zone coords)
-- ret: icon

function Nx.Map:AddIconRect (iconType, mapId, x, y, x2, y2, color)

	local d = self.Data

	assert (d[iconType])

	local tdata = d[iconType]
	tdata.Num = tdata.Num + 1

	local icon = {}
	tdata[tdata.Num] = icon

	icon.MapId = mapId
	icon.X = x
	icon.Y = y
	icon.X2 = x2
	icon.Y2 = y2
	icon.Color = color

	return icon
end

--------
-- Add icon tool tip

function Nx.Map:SetIconTip (icon, tip)
	icon.Tip = tip
end

--------
-- Set user data

function Nx.Map:SetIconUserData (icon, data)
	icon.UData = data
end

--------
-- Set favorite data

function Nx.Map:SetIconFavData (icon, data1, data2)
	icon.FavData1 = data1
	icon.FavData2 = data2
end

--------
-- Set favorite data

function Nx.Map:GetIconFavData (icon)
	return icon.FavData1, icon.FavData2
end

--------
-- Update all icons

function Nx.Map:UpdateIcons (drawNonGuide)
	local c2rgb = Nx.Util_c2rgb
	local c2rgba = Nx.Util_c2rgba
	local d = self.Data

	local wpScale = 1
	local wpMin = Nx.db.profile.Map.IconScaleMin
	if wpMin >= 0 then
		wpScale = self.ScaleDraw * .08
	end
	if Nx.Map:GetMap(1).LOpts.NXMMFull then
		return
	end
	for type, v in pairs (d) do
		v.Enabled = drawNonGuide or strbyte (type) == 33	-- "!" is guide types		
		if v.AtScale then
			if self.ScaleDraw < v.AtScale then				
				v.Enabled = false
			end
		end
		if (self:IsInstanceMap(Nx.Map.UpdateMapID) or self:IsBattleGroundMap(Nx.Map.UpdateMapID)) and self.CurOpts.NXInstanceMaps then
			v.Enabled = true	
			v.Lvl = 20
		end
	end
	for k, v in pairs (d) do

--		Nx.prt ("UpdateIcons %s %s", k, v.DrawMode)

		if v.Enabled then

			if v.DrawMode == "ZP" then		-- Zone point				
				local scale = self.IconScale
				local w = v.W * scale
				local h = v.H * scale				
				for n = 1, v.Num do											
					if (not v[n].Level and Nx.Map.DungeonLevel == 0) or (v[n].Level and v[n].Level == Nx.Map.DungeonLevel) then						
						local icon = v[n]
						local f = self:GetIconStatic (v.Lvl)
						if self:ClipFrameZ (f, icon.X, icon.Y, w, h, 0) then							
							f.NxTip = icon.Tip							
	--						assert (icon.Tex or v.Tex or icon.Color)

							if icon.Tex then
								f.texture:SetTexture (icon.Tex)
								if icon.Color then
									f.texture:SetVertexColor (c2rgb (icon.Color))
								end
							elseif v.Tex then
								f.texture:SetTexture (v.Tex)
							else
								f.texture:SetColorTexture (c2rgb (icon.Color))
							end
							if icon.TX1 then
								f.texture:SetTexCoord(icon.TX1, icon.TY1, icon.TX2, icon.TY2)
							end
						end
					end
				end

			elseif v.DrawMode == "WP" then		-- World point

				local scale = self.IconScale * v.Scale * wpScale
				local w = max (v.W * scale, wpMin)
				local h = max (v.H * scale, wpMin)

				local curMapId = Nx.Map:GetCurrentMapAreaID()
				if self.Win:IsSizeMax() then
					local myzone = curMapId
					if (myzone == 87) or (myzone == 125) then
						w = w / 2
						h = h / 2
					end
				end
				
				if (self:IsInstanceMap(Nx.Map.UpdateMapID) or self:IsBattleGroundMap(Nx.Map.UpdateMapID)) then
					w = Nx.db.profile.Map.InstanceScale
					h = Nx.db.profile.Map.InstanceScale
				end
				
				if v.AlphaNear then

					local aNear = v.AlphaNear * (abs (GetTime() % .7 - .35) / .7 + .5)	-- 50% to 100% pulse

					for n = 1, v.Num do
						if (not v[n].Level and Nx.Map.DungeonLevel == 0) or (v[n].Level and v[n].Level == Nx.Map.DungeonLevel) then
							local icon = v[n]
							local f = self:GetIconStatic (v.Lvl)							
							if self:ClipFrameByMapType (f, icon.X, icon.Y, w, h, 0) then								
								f.NxTip = icon.Tip								
								f.NXType = 3000
								f.NXData = icon
								if icon.Tex then
									local pos = string.find(icon.Tex, "atlas:")
									if pos then
										local whichatlas = string.sub (icon.Tex,7)										
										f.texture:SetAtlas(whichatlas)
									else
										f.texture:SetTexture (icon.Tex)
									end
									if icon.Color then
										f.texture:SetVertexColor (c2rgb (icon.Color))
									end
								elseif v.Tex then
									f.texture:SetTexture (v.Tex)
								else
									f.texture:SetColorTexture (c2rgb (icon.Color))
								end
								local a = v.Alpha
								local dist = (icon.X - self.PlyrX) ^ 2 + (icon.Y - self.PlyrY) ^ 2
								if dist < 306 then	-- 80 yards * 4.575 ^ 2
									a = aNear
	--								Nx.prt ("fade %s %s", dist ^ .5, a)
								end
								f.texture:SetVertexColor (1, 1, 1, a)
							end
						end
					end
				else
					for n = 1, v.Num do	
						local offY = nil
						local Level = v[n].Level						
						local _h = 3 * (668 / 768)
						local _dungeonLevel = Nx.Map:GetCurrentMapDungeonLevel() > 0 and Nx.Map:GetCurrentMapDungeonLevel() -1 or 0
						--Level = Nx.Map.DungeonLevel
						if Nx.Map:IsInstanceMap(Nx.Map.RMapId) and not self.CurOpts.NXInstanceMaps then
							offY = _h * _dungeonLevel
						end						
						if (not Level and Nx.Map.DungeonLevel == 0) or (Level and Level == Nx.Map.DungeonLevel) then												
							local icon = v[n]
							local f = self:GetIconStatic(v.Lvl)
							f:ClearAllPoints()
							local actuallyIcon = false
							if type(icon.Tex) == "table" then
								actuallyIcon = true
								f = icon.Tex
							end
							if self:ClipFrameByMapType (f, icon.X, icon.Y + (offY or 0), w, h, 0) then
								f.NxTip = icon.Tip																
								f.NXType = 3000
								f.NXData = icon
								if actuallyIcon then
									f:SetFrameLevel(self.Level + (v.Lvl or 0))
								elseif icon.Tex then
									local pos = string.find(icon.Tex, "atlas:")
									if pos then
										local whichatlas = string.sub (icon.Tex,7)											
										f.texture:SetAtlas(whichatlas)
									else
										f.texture:SetTexture (icon.Tex)
									end																	
									if icon.Color then
										f.texture:SetVertexColor (c2rgb (icon.Color))
									end
								elseif v.Tex then
									f.texture:SetTexture (v.Tex)
								else
									f.texture:SetColorTexture (c2rgb (icon.Color))
								end
								if v.Alpha and not actuallyIcon then
									f.texture:SetVertexColor (1, 1, 1, v.Alpha)
								end
								if icon.TX1 then
									f.texture:SetTexCoord(icon.TX1, icon.TY1, icon.TX2, icon.TY2)
								end
								f.texture:SetSnapToPixelGrid(false)
								f.texture:SetTexelSnappingBias(0)
							end
						end
					end
				end
			elseif v.DrawMode == "ZR" then	-- Zone rectangle
				local x, y, x2, y2
--				local x0, y0, x2, y2 = self:GetWorldRect (self.MapId, 0, 0, 100, 100)

				for n = 1, v.Num do
					if (not v[n].Level and Nx.Map.DungeonLevel == 0) or (v[n].Level and v[n].Level == Nx.Map.DungeonLevel) then				
						local icon = v[n]
						local f = self:GetIconStatic (v.Lvl)
--						Nx.prt ("ZR #%d %f %f %f %f", n, icon.X, icon.Y, icon.X2, icon.Y2)

						f.NxTip = icon.Tip

						x, y = self:GetWorldPos (icon.MapId, icon.X, icon.Y)
						x2, y2 = self:GetWorldPos (icon.MapId, icon.X2, icon.Y2)

	--					Nx.prt ("%f %f %f %f", x, y, x2, y2)

						if self:ClipFrameTL (f, x, y, x2-x, y2-y) then
							if v.Texture then
								f.texture:SetTexture (v.Tex)
							else
								f.texture:SetColorTexture (c2rgba (icon.Color))
							end
						end
					end
				end
			end
		end
	end
	if Nx.Map:GetCurrentMapAreaID() == 85 and Nx.Map.DungeonLevel == 0 then
		Nx.Map.DungeonLevel = 1
	end
end

------
-- Reset icons

function Nx.Map:ResetIcons()

	local frms = self.IconFrms
	frms.Used = frms.Next - 1		-- Save last frame used
	frms.Next = 1

	local frms = self.IconNIFrms
	frms.Used = frms.Next - 1		-- Save last frame used
	frms.Next = 1

	local frms = self.IconStaticFrms
	frms.Used = frms.Next - 1		-- Save last frame used
	frms.Next = 1

	local data = self.TextFStrs
	data.Used = data.Next - 1		-- Save last used
	data.Next = 1
	
	local data = self.IconWQFrms
	data.Used = data.Next - 1		-- Save last used
	data.Next = 1
end

------
-- Hide extra icons (a hide and then show will reset mouse state, breaking OnMouseUp)

function Nx.Map:HideExtraIcons()

	local frms = self.IconFrms

	for n = frms.Next, frms.Used do		-- Hide up to last frames used amount
		frms[n]:Hide()
	end

	local frms = self.IconNIFrms

	for n = frms.Next, frms.Used do		-- Hide up to last frames used amount
		frms[n]:Hide()
	end

	local frms = self.IconStaticFrms

	for n = frms.Next, frms.Used do		-- Hide up to last frames used amount
		frms[n]:Hide()
	end

	local data = self.TextFStrs

	for n = data.Next, data.Used do		-- Hide up to last used amount
		data[n]:Hide()
	end
	
	local data = self.IconWQFrms

	for n = data.Next, data.Used do		-- Hide up to last used amount
		data[n]:Hide()
	end
end

------
-- Get next available map icon or create one
-- ret: icon frame

function Nx.Map:GetIcon (levelAdd)

	local frms = self.IconFrms
	local pos = frms.Next

	if pos > 1500 then
		pos = 1500	-- Too many used. Reuse
	end

	local f = frms[pos]
	if not f then

		f = CreateFrame ("Frame", "NxIcon"..pos, self.Frm)
		frms[pos] = f
		f.NxMap = self

		f:SetScript ("OnMouseDown", self.IconOnMouseDown)
		f:SetScript ("OnMouseUp", self.IconOnMouseUp)
		f:SetScript ("OnEnter", self.IconOnEnter)
		f:SetScript ("OnLeave", self.IconOnLeave)
		f:SetScript ("OnHide", self.IconOnLeave)

		f:EnableMouse (true)

		local t = f:CreateTexture()
		f.texture = t
		t:SetAllPoints (f)
	end

	f:SetFrameLevel (self.Level + (levelAdd or 0))

	f.texture:SetVertexColor (1, 1, 1, 1)
--	f.texture:SetBlendMode ("BLEND")

	f.NxTip = nil
	f.NXType = nil			-- 1000 plyr, 2000 BG, 3000 POI, 8000 debug, 9000+ quest
	f.NXData = nil
	f.NXData2 = nil

	frms.Next = pos + 1

	return f
end

------
-- Get next available map icon for WorldQuest or create one
-- ret: icon frame

function Nx.Map:GetIconWQ (levelAdd)
	
	local frms = self.IconWQFrms
	local pos = frms.Next

	if pos > 1500 then
		pos = 1500	-- Too many used. Reuse
	end

	local f = frms[pos]
	if not f then

		f = CreateFrame ("Button", "NxIconWQ"..pos, self.Frm)
		frms[pos] = f
		f.NxMap = self

		f:EnableMouse (true)

		local t = f:CreateTexture()
		f.texture = t
		t:SetAllPoints (f)
		f.texture:SetSnapToPixelGrid(false)
		f.texture:SetTexelSnappingBias(0)
		
		f:SetFlattensRenderLayers(true);
		
		--[[f:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		f:SetScript("OnEnter", TaskPOI_OnEnter);
		f:SetScript("OnLeave", TaskPOI_OnLeave);
		f:SetScript("OnClick", TaskPOI_OnClick);]]--

		f.Texture = f:CreateTexture(f:GetName().."Texture", "BACKGROUND");

		f.Glow = f:CreateTexture(f:GetName().."Glow", "BACKGROUND", -2);
		f.Glow:SetSize(50, 50);
		f.Glow:SetPoint("CENTER");
		f.Glow:SetTexture("Interface/WorldMap/UI-QuestPoi-IconGlow.tga");
		f.Glow:SetBlendMode("ADD");
		f.Glow:SetSnapToPixelGrid(false)
		f.Glow:SetTexelSnappingBias(0)
		
		f.CriteriaMatchRing = f:CreateTexture(f:GetName().."CriteriaMatchRing", "BACKGROUND", nil, 2);
		f.CriteriaMatchRing:SetAtlas("worldquest-emissary-ring", true)
		f.CriteriaMatchRing:SetPoint("CENTER", 0, 0)
		
		f.SelectedGlow = f:CreateTexture(f:GetName().."SelectedGlow", "OVERLAY", 2);
		f.SelectedGlow:SetBlendMode("ADD");
		f.SelectedGlow:SetSnapToPixelGrid(false)
		f.SelectedGlow:SetTexelSnappingBias(0)
		
		f.CriteriaMatchGlow = f:CreateTexture(f:GetName().."CriteriaMatchGlow", "BACKGROUND", -1);
		f.CriteriaMatchGlow:SetAlpha(.6);
		f.CriteriaMatchGlow:SetBlendMode("ADD");
		f.CriteriaMatchGlow:SetSnapToPixelGrid(false)
		f.CriteriaMatchGlow:SetTexelSnappingBias(0)
		
		f.SpellTargetGlow = f:CreateTexture(f:GetName().."SpellTargetGlow", "OVERLAY", 1);
		f.SpellTargetGlow:SetAtlas("worldquest-questmarker-abilityhighlight", true);
		f.SpellTargetGlow:SetAlpha(.6);
		f.SpellTargetGlow:SetBlendMode("ADD");
		f.SpellTargetGlow:SetPoint("CENTER", 0, 0);
		f.SpellTargetGlow:SetSnapToPixelGrid(false)
		f.SpellTargetGlow:SetTexelSnappingBias(0)
		
		f.Underlay = f:CreateTexture(f:GetName().."Underlay", "BACKGROUND");
		f.Underlay:SetWidth(34);
		f.Underlay:SetHeight(34);
		f.Underlay:SetPoint("CENTER", 0, -1);
		f.Underlay:SetSnapToPixelGrid(false)
		f.Underlay:SetTexelSnappingBias(0)
		
		f.TimeLowFrame = CreateFrame("Frame", nil, f);
		f.TimeLowFrame:SetSize(22, 22);
		f.TimeLowFrame:SetPoint("CENTER", -10, -10);
		f.TimeLowFrame.Texture = f.TimeLowFrame:CreateTexture(nil, "OVERLAY");
		f.TimeLowFrame.Texture:SetAllPoints(f.TimeLowFrame);
		f.TimeLowFrame.Texture:SetAtlas("worldquest-icon-clock");
		
		--f:SetNormalTexture(nil)
		--f:SetPushedTexture(nil)
		--f:SetHighlightTexture(nil)
	end
	
	f:SetWidth(32);
	f:SetHeight(32);
	f.Texture:SetWidth(28);
	f.Texture:SetHeight(28);
	f.Texture:SetPoint("CENTER", 0, 0);
	f.Texture:SetTexture("Interface\\Minimap\\ObjectIconsAtlas");
	if f.HighlightTexture then
		f.HighlightTexture:SetTexture("Interface\\Minimap\\ObjectIconsAtlas");
		f.HighlightTexture:SetSnapToPixelGrid(false)
		f.HighlightTexture:SetTexelSnappingBias(0)
	end
	
	f.Texture:SetSnapToPixelGrid(false)
	f.Texture:SetTexelSnappingBias(0)
	
	--[[f:SetScript ("OnMouseDown", self.IconOnMouseDown)
	f:SetScript ("OnMouseUp", self.IconOnMouseUp)]]--
	f:SetScript ("OnEnter", function (self) 
		TaskPOI_OnEnter(self) 
		GameTooltip:SetFrameStrata("TOOLTIP");
		GameTooltip.ItemTooltip.Tooltip:SetClampedToScreen(false)
	end)
	f:SetScript ("OnLeave", TaskPOI_OnLeave)
	--f:SetScript ("OnHide", self.IconOnLeave)]]--

	f:SetFrameLevel (self.Level + (levelAdd or 0))
	
	--f.texture:SetVertexColor (1, 1, 1, 1)
	
	f.NxTip = nil
	f.NXType = nil			-- 1000 plyr, 2000 BG, 3000 POI, 8000 debug, 9000+ quest
	f.NXData = nil
	f.NXData2 = nil
	
	frms.Next = pos + 1

	return f
end

------
-- Get next available map non interactive icon or create one
-- ret: icon frame

function Nx.Map:GetIconNI (levelAdd)

	local frms = self.IconNIFrms
	local pos = frms.Next

	if pos > 1500 then
		pos = 1500	-- Too many used. Reuse
	end

	local f = frms[pos]
	if not f then

		f = CreateFrame ("Frame", "NxIconNI"..pos, self.Frm)
		frms[pos] = f
		f.NxMap = self

		local t = f:CreateTexture()
		f.texture = t
		t:SetAllPoints (f)
	end

	local add = levelAdd or 0
	f:SetFrameLevel (self.Level + add)

	f.texture:SetVertexColor (1, 1, 1, 1)
	f.texture:SetBlendMode ("BLEND")

	frms.Next = pos + 1

	return f
end

------
-- Get next available map static (for non moving stuff) icon or create one
-- ret: icon frame

function Nx.Map:GetIconStatic (levelAdd)

	local frms = self.IconStaticFrms
	local pos = frms.Next

	if pos > 1500 then
		pos = 1500	-- Too many used. Reuse
	end
	
	local f = frms[pos]
	if not f then

		f = CreateFrame ("Frame", "NxIconS"..pos, self.Frm)
		frms[pos] = f
		f.NxMap = self

		f:SetScript ("OnMouseDown", self.IconOnMouseDown)
		f:SetScript ("OnMouseUp", self.IconOnMouseUp)
		f:SetScript ("OnEnter", self.IconOnEnter)
		f:SetScript ("OnLeave", self.IconOnLeave)
		f:SetScript ("OnHide", self.IconOnLeave)

		f:EnableMouse (true)

		local t = f:CreateTexture()
		f.texture = t
		t:SetAllPoints (f)
	end

	local add = levelAdd or 0
	f:SetFrameLevel (self.Level + add)

	f.texture:SetVertexColor (1, 1, 1, 1)
--	f.texture:SetBlendMode ("BLEND")

	f.NxTip = nil
	f.NXType = nil			-- 1000 plyr, 2000 BG, 3000 POI, 8000 debug, 9000+ quest
	f.NXData = nil
	f.NXData2 = nil

	frms.Next = pos + 1

	return f
end

--------
-- Handle mouse click on icon

function Nx.Map:IconOnMouseDown (button)

	local this = self			--V4

--	Nx.prt ("MapIconMouseDown "..button.." "..(this:GetName() or "?"))

	local map = this.NxMap
	map:CalcClick()
	map.ClickFrm = this
	map.ClickType = this.NXType
	map.ClickIcon = this.NXData

	local shift = IsShiftKeyDown()

	if button == "LeftButton" then

		local cat = floor ((this.NXType or 0) / 1000)

		if cat == 2 and shift then		-- BG location

			if map.BGIncNum > 0 then

				local _, _, _, str = Nx.Split ("~", map.BGMsg)
				local _, _, _, str2 = Nx.Split ("~", this.NXData)

				if str ~= str2 then				-- Different node?
--					Nx.Timer:Fire ("BGInc")		-- Clear if pending
				end
			end

			map.BGMsg = this.NXData
			map.BGIncNum = map.BGIncNum + 1

			UIErrorsFrame:AddMessage ("Inc " .. map.BGIncNum, 1, 1, 1, 1)

			BGInc = Nx:ScheduleTimer(map.BGIncSendTimer,1.5,map)

--		elseif cat == 8 then
--			map:HotspotDebugClick (button)

		else
			if map:IsDoubleClick() then
				if cat == 3 then
--					Nx.prt ("Icon dbl click")
					map:GMenu_OnGoto()
				end

			else
				map.OnMouseDown (map.Frm, button)
			end
		end

	else		--if button == "MiddleButton" or button == "Button4" or IsShiftKeyDown() then

		if button == "RightButton" then

			local typ = this.NXType

--			Nx.prt ("Icon type %s", typ or 0)

			if typ then

				local i = floor (typ / 1000)

				if i == 1 then
					map:BuildPlyrLists()
					map.PIconMenu:Open()

				elseif i == 2 then				-- BG location

--					Nx.Timer:Fire ("BGInc")		-- Clear if pending

					map.BGMsg = this.NXData
					map.BGIconMenu:Open()

				elseif i == 3 then

					map:GMenuOpen (this.NXData, typ)

				elseif i == 9 then				-- Quest

					Nx.Quest:IconOnMouseDown (this)
				end
			end

		else
			map.OnMouseDown (map.Frm, button)
		end
	end
end

function Nx.Map:BuildPlyrLists()

	local Map = Nx.Map

	Map.PlyrNames = {}
	Map.AFKers = {}
	local tipStr = ""

	local frms = self.IconFrms
	local f

	local cnt = 0

	for n = 1, frms.Next-1 do

		f = frms[n]
		local plyr = f.NXType == 1000 and f.NXData2
		if plyr then

			local x, y = Nx.Util_IsMouseOver (f)
			if x then

--				Nx.prt ("Plyr %s", plyr)

				tinsert (Map.PlyrNames, plyr)

				if f.NXData then
					tinsert (Map.AFKers, f.NXData)
--					Nx.prt ("AFKer %d %s %s", #Nx.Map.AFKers, plyr, f.NXData)
				end
			end
		end
	end

	if #Map.PlyrNames >= 2 then

		tipStr = format ("\n\n|cff00cf00%s " .. L["players"] .. ":", #Map.PlyrNames)

		sort (Map.PlyrNames)

		for _, name in ipairs (Map.PlyrNames) do
			tipStr = tipStr .. "\n" .. name
		end
	end

	Map.PlyrNamesTipStr = tipStr

end

function Nx.Map:IconOnMouseUp (button)

--	Nx.prt ("MapIconMouseUp "..button)

	local this = self			--V4
	this.NxMap.OnMouseUp (this.NxMap.Frm, button)
end

--------
-- Handle mouse on icon

function Nx.Map:IconOnEnter (motion)

	local this = self			--V4

--	Nx.prt ("MapIconEnter %s", this:GetName() or "nil")

	local map = this.NxMap

--	map.BackgndAlphaTarget = map.BackgndAlphaFull

	map:BuildPlyrLists()

	if this.NxTip then
--		Nx.prt ("MapIconEnter %s %s", this:GetName() or "nil", this.NxTip)

		local tt = GameTooltip

		local str = Nx.Split ("~", this.NxTip)

		local owner = this
		local tippos = "ANCHOR_CURSOR"

		if Nx.db.profile.Map.TopTooltip then
			owner = map.Win.Frm
			tippos = "ANCHOR_TOPLEFT"
		end

		owner.NXIconFrm = this

--		Nx.TooltipOwner = owner
--		map.TooltipType = 2

		tt:SetOwner (owner, tippos, 0, 0)

		Nx:SetTooltipText (str .. Nx.Map.PlyrNamesTipStr)

		owner["UpdateTooltip"] = Nx.Map.IconOnUpdateTooltip
	end

	local t = this.NXType or -1

	if t >= 9000 then					-- Quest
		Nx.Quest:IconOnEnter (this)
	end
end

--------
-- Called by tooltip
-- self = frame

function Nx.Map:IconOnUpdateTooltip()

	local f = self.NXIconFrm

	if f and f.NxTip then

		local map = f.NxMap
		map:BuildPlyrLists()

		local str = Nx.Split ("~", f.NxTip)
		Nx:SetTooltipText (str .. Nx.Map.PlyrNamesTipStr)

		if Nx.Quest then
			Nx.Quest:TooltipProcess()
		end

--		Nx.prt ("IconOnUpdateTooltip")
	end
end

--------
-- Handle mouse leaving icon (or icon hiding)

function Nx.Map:IconOnLeave (motion)

	local this = self			--V4
	local t = this.NXType or -1

	if t >= 9000 then					-- Quest
		Nx.Quest:IconOnLeave (this)
	end

--	self.TooltipType = 0

--	if not this:IsVisible() then
--		Nx.prt ("IconOnLeave not vis")
--		return
--	end

--	local map = this.NxMap
--	local owner = map.Win.Frm

	if GameTooltip:IsOwned (this) or GameTooltip:IsOwned (this.NxMap.Win.Frm) then
		GameTooltip:Hide()
--		Nx.prt ("MapIconLeave hide tip")
	end
end

--------
-- Get next available map text or create one
-- ret: text font string

function Nx.Map:GetText (text, levelAdd)

	local data = self.TextFStrs
	local pos = data.Next

	if pos > 100 then
		pos = 1	-- Reset. Too many used
	end

	local fstr = data[pos]
	if not fstr then

		fstr = self.TextFrm:CreateFontString()
		data[pos] = fstr

		fstr:SetFontObject ("NxFontMap")
		fstr:SetJustifyH ("LEFT")
		fstr:SetJustifyV ("TOP")
--		fstr:SetWidth (400)
		fstr:SetHeight (100)
		fstr:SetTextColor (1, 1, 1, 1)
	end

	fstr:SetText (text)

--	local add = levelAdd or 0
--	f:SetFrameLevel (self.Level + add)

	data.Next = pos + 1

	return fstr
end

--------
-- Move text

function Nx.Map:MoveTextToIcon (fstr, icon, ox, oy)

	local f = icon
	local atPt, relTo, relPt, x, y = f:GetPoint()

--	Nx.prt ("Text %s %s %s", relPt, x, y)

	fstr:SetPoint ("TOPLEFT", x + ox, y - oy)
	fstr:Show()
end

--------
-- Update instance map

function Nx.Map:UpdateInstanceMap()
	
	local mapId = self.InstMapId
	if not mapId or not Nx.Initialized then
		return
	end
	
	local curId = Nx.Map:GetCurrentMapId()

	if not Nx.Map.NInstMapId or Nx.Map.NInstMapId ~= curId then
		Nx.Map.NInstMapId = curId
	end
	Nx.Map:SetCurrentMap (Nx.Map.NInstMapId)
	
	local Map = Nx.Map
	local winfo = Map.MapWorldInfo[mapId]
	local info = self.InstMapInfo				-- Valid if Id not nil
	if Map.MapWorldInfo[mapId].BaseMap then
	  winfo = Map.MapWorldInfo[Map.MapWorldInfo[mapId].BaseMap]
	end
--	Nx.prt ("Inst id %s", mapId)

	if self.InstMapAtlas then

		local wx = winfo.X
		local wy = winfo.Y

		local n = 4;
		if info then
		--for n = 1, #info, 3 do

			local sc = 668 / 256
			local f = self:GetIconNI()

			if self:ClipFrameTL (f, wx, wy + (n - 1) * 668 / 768, sc, sc) then
				local tex = string.gsub(info[n + 2], " ", "")
				tex = "Interface\\AddOns\\Atlas\\Images\\" .. tex
				f.texture:SetTexture (tex)
			end
		end

		self.Level = self.Level + 1

	else

		local wx = winfo.X
		local wy = winfo.Y

		local is_n = nil
		
		local n = 4;
		
		local layerIndex = WorldMapFrame:GetCanvasContainer():GetCurrentLayerIndex();
		local textures = C_Map.GetMapArtLayerTextures(mapId, layerIndex)
		
		if info then
		--for n = 1, #info, 3 do
			local imgI = 1

			local offx = 0		-- info[n] * .04 * 1002 / 1024
			local offy = 0		-- info[n + 1] * .03 * 668 / 768

			for by = 0, 2 do

				for bx = 0, 3 do

					local sc = 1
					local f = self:GetIconNI(10)

					--Nx.prt ("Inst %s, %s %s %s %s", mapId, wx, wy, bx, by)

					if self:ClipFrameTL (f, wx + bx - offx, wy + by - offy, sc, sc) then
					    if not is_n then is_n = n end
						local tex = string.gsub(info[n + 2], " ", "")
						tex = "Interface\\WorldMap\\" .. tex .. imgI
						f.texture:SetTexture (textures[imgI])
					end
					imgI = imgI + 1
				end
			end
		end
		
		if not ((Nx.Map:IsInstanceMap(Nx.Map.RMapId) or Nx.Map:IsBattleGroundMap(Nx.Map.RMapId)) and self.CurOpts.NXInstanceMaps) then		
			
			Nx.Map.MouseOver = false
			Nx.Map:GetMap(1).PlyrFrm:Hide()
			
			NXWorldMapUnitPositionFrame:ClearAllPoints()
			NXWorldMapUnitPositionFrame:SetFrameLevel(40)
			local c = NXWorldMapUnitPositionFrame
			local f = self.NewPlrFrm
			if not self.NewPlrFrm then 
				f = CreateFrame ("ScrollFrame", "NewPlrFrm", self.Frm)
				self.NewPlrFrm = f
				f:SetFrameLevel(20)
				f:SetFrameStrata("HIGH")
				
				-- RED BG FOR TESTING
				--f.texture = f:CreateTexture()
				--f.texture:SetAllPoints (f)
				--f.texture:SetColorTexture (1, 0, 0, 0.2)
			end
			
			c:SetParent(f)
			c:SetSize(100,100)
			f:SetScrollChild(c)
			
			--Nx.prt("%s", info[is_n + 1])
			local w = 4 * (1002 / 1024)  -- (info[is_n + 1] * .04 * 1002 / 1024) * -1
			local h = 3 * (668 / 768) -- (info[is_n + 1] * .03 * 668 / 768) * -1
			local dungeonLevel = Nx.Map:GetCurrentMapDungeonLevel() > 0 and Nx.Map:GetCurrentMapDungeonLevel() -1 or 0
			
			local x1, y1, x2, y2 = self:ClipFrameINST (f, wx, wy + (h * dungeonLevel), w, h, true)
			
			--Nx.prt("%s, %s, %s, %s", x1, y1, x2, y2)
			
			c:SetPoint("TOPLEFT", x1 * -1, y1) -- -10, 10
			c:SetPoint("BOTTOMRIGHT", x2 * -1, y2) -- 10, -10
			
			Nx.Map:NXWorldMapUnitPositionFrame_UpdatePlayerPins()
		else 
			Nx.Map:HideNewPlrFrame()
		end
		
		self.Level = self.Level + 1
	end
end

------------------------------------------
-- Helpers

--------
-- Get a map by index

function Nx.Map:GetMap (mapIndex)
	if self.Maps then
		return self.Maps[mapIndex]
	end
	assert(0, "Erroneous Map Index requested (probably by some other addon): mapIndex = " .. (mapIndex or 'missing'))
end

--------
-- Set map target name

function Nx.Map:SetTargetName (name)

	local tar = self.Maps[1].Targets[1]
	if tar then
		tar.TargetName = name
	end
end

--------
-- Get map target type, id

function Nx.Map:GetTargetInfo()

	local tar = self.Maps[1].Targets[1]
	if tar then
		return tar.TargetType, tar.TargetId
	end
end

--------
-- Get map target pos

function Nx.Map:GetTargetPos()

	local tar = self.Maps[1].Targets[1]
	if tar then
		return tar.TargetX1, tar.TargetY1, tar.TargetX2, tar.TargetY2
	end
end

--------
-- Center the map in view

function Nx.Map:CurrentCenterMap (mapId)

	local map = self.Maps[1]
	map:CenterMap (mapId)
end

------------------------------------------
-- Map table access

--------
-- Init map tables

function Nx.Map:InitTables()

	local Nx = Nx

	local worldInfo = self.MapWorldInfo
	Nx.MapOverlayToMapId = {}

	-- Get Blizzard's alphabetical set of names

	--V403

	Nx.Map.MapZones = {
		[0] = {12,13,1945,113,0,-1},
		[1] = {1411,1412,1413,1438,1439,1440,1441,1442,1443,1444,1445,1446,1447,1448,1449,1450,1451,1452,1454,1456,1457,1943,1947,1950},
		[2] = {1416,1417,1418,1419,1420,1421,1422,1423,1424,1425,1426,1427,1428,1429,1430,1431,1432,1433,1434,1435,1436,1437,1453,1455,1458,1941,1942,1954,1957,124},
		[3] = {1944,1946,1948,1949,1951,1952,1953,1955},
		[4] = {114,115,116,117,118,119,120,121,123,125,127,170},
		[90] = {91,92,93,112,128,169,206,275,397,417,423,519,623},		 
		[100] = {},
	}

	--[[for mi, mapName in pairs (Nx.Map.MapZones[2]) do
		for mi2, mapName2 in pairs (Nx.Map.MapZones[2]) do
			if mapName == mapName2 and mi ~= mi2 then			-- Duplicate name? (Gilneas, Ruins of Gilneas (EU))
				Nx.Map.MapZones[2][mi2] = mapName .. "2"			-- Hack it!
--				Nx.prt ("Dup zone name %s", mapName)
				break
			end
		end
	end]]--

	-- Support maps with multiple level
	self.ContCnt = 4

--	continentNums = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 90 }
	for k, v in pairs (worldInfo) do
		local winfo = worldInfo[k]
		if Nx.PlFactionNum == 0 and winfo.QAchievementIdA then
			winfo.QAchievementId = winfo.QAchievementIdA				-- Copy Ally Id to generic Id
		end
		if Nx.PlFactionNum == 1 and winfo.QAchievementIdH then
			winfo.QAchievementId = winfo.QAchievementIdH				-- Copy Horde Id to generic Id
		end
		if winfo.BaseMap then
			Nx.Map.MapWorldInfo[k] = Nx.Map.MapWorldInfo[winfo.BaseMap]
			Nx.Map.MapWorldInfo[k].RBaseMap = k
			Nx.Map.MapWorldInfo[k].OBaseMap = winfo.BaseMap
		end
	end
	for k, v in pairs (Nx.Zones) do
		if Nx.Map:GetContinentMapID(k) == 113 then
			local name, minLvl, maxLvl, faction, cont, entryId, ex, ey, z = Nx.Split ("|", v)
			if cont == "5" then 
				local _, _ , _, data = Nx.Map:GetLegacyMapInfo(k);
				for mk, mv in pairs (data) do
					mk = tonumber(mk)
					if mk ~= nil and mv ~= k then 
						Nx.Zones[mv] = v
					end
				end
			end
		end
	end
	for k, v in pairs (Nx.Zones) do
		if worldInfo[k] then
			local name, minLvl, maxLvl, faction, cont, entryId, ex, ey = Nx.Split ("|", v)
			worldInfo[k].Cont = tonumber(cont)
			worldInfo[k].Zone = k
			local ov = worldInfo[k].Overlay
			if ov then
				Nx.MapOverlayToMapId[ov] = k
			end
		end
	end
--	for n = 1, self.ContCnt do
--		CZ2Id[n][0] = n * 1000
--	end

	-- Init for getting map id to and from name

--	for _, ci in ipairs (continentNums) do

--		for mi, mapName in pairs (self.MapNames[ci]) do

--			if ci == 2 then
--				Nx.prt ("Map %s %s", mapName, self.CZ2Id[ci][mi] or "nil")
--			end
--			local mid = self.CZ2Id[ci][mi]

--			if Nx.MapNameToId[mapName] then
--				Nx.prt ("Dup map name: %s (%s %s)", mapName, ci, mi)
--				Nx.MapNameToId[mapName .. "2"] = mid
--			else
--				Nx.MapNameToId[mapName] = mid
--			end

--			if not mid then
--				Nx.prt (L["Unknown map name"] .. ": %s (%s %s)", mapName, ci, mi)
--			else
--				Nx.MapIdToName[mid] = mapName
--			end
--		end
--	end

	-- Localize the zone name

--	for id, v in pairs (Nx.Zones) do
--		local i = strfind (v, "|")
--		local name = strsub (v, 1, i - 1)
--		local data = strsub (v, i + 1)
--		Nx.Zones[id] = L[name] .. "|" .. data
--	end

-- Make world coords for each zone
--		Nx.prt ("WC %s %s %s", ci, cx, cy)

	for n = 0, self.ContCnt do
		for _, id in pairs (Nx.Map.MapZones[n]) do
			local winfo = worldInfo[id]
			if winfo then
				local info = self.MapInfo[winfo.Cont]
				if info then
					if winfo.XOff then	-- Had pos offset?
						winfo.X = winfo.X + winfo.XOff
						winfo.Y = winfo.Y + winfo.YOff
						winfo.XOff = nil
						winfo.YOff = nil
					end
					local cx = info.X
					local cy = info.Y
					if winfo.X ~= nil and winfo.Y ~= nil then
						winfo[4] = cx + winfo.X
						winfo[5] = cy + winfo.Y
					else
						if n ~= nil and n ~= 0 then
							Nx.prt("Map Error: " .. tostring(n))
						end
					end
				else
				end
			end
		end
	end

	for _, id in pairs (Nx.Map.MapZones[90]) do
		local winfo = worldInfo[id]
		if winfo then
			local info = self.MapInfo[90]
			if info then
				local cx = info.X
				local cy = info.Y
				if winfo.X ~= nil and winfo.Y ~= nil then
					winfo[4] = cx + winfo.X
					winfo[5] = cy + winfo.Y
				else
					if n ~= nil and n ~= 0 then
						Nx.prt("Map Error: " .. tostring(n))
					end
				end
				winfo.Cont = 90
				winfo.Zone = id
			else
			end
		end
	end

	--
	for id, v in pairs (Nx.Zones) do

		local name, minLvl, maxLvl, faction, cont, entryId, ex, ey = Nx.Split ("|", v)

		-- Faction:
		-- 0 Alliance
		-- 1 Horde
		-- 2 Contested
		-- 3 Instance
		-- 4 Unknown

		-- Continent:
		-- 1 Kalimdor
		-- 2 EasternKingdoms
		-- 3 Outland
		-- 4 Northrend
		-- 5 Maelstorm
		-- 6 Pandaria
		-- 7 Draenor
		-- 8 Broken Isles
		-- 9 Argus
		-- 99 Battlegrounds
		-- 100 Instances

		if faction == "3" and cont == "5" then		-- Instance

			assert (entryId)

			if entryId == "0" then
				Nx.prt("Instance " .. name .. " trying entryId 0")
				entryId = "125"
			end
--[[
			local i = strfind (name, ": ")
			if i then
				name = strsub (name, i + 2)
			end
--]]

--			Nx.prt ("Inst %s %d", name, id)

			local entryZone = Nx.Zones[tonumber (entryId)]
			local ename, _, _, entryfact, entrycont, entrybase = Nx.Split ("|", entryZone)
			local mid = id
			tinsert(Nx.Map.MapZones[100],id)
			local emid = tonumber(entryId)
			while entryfact == "3" and entrycont == "5" do
				Nx.prt(entrybase)
				_, _, _, entryfact, entrycont, entrybase = Nx.Split ("|", entrybase)
			end
			
			if self.MapWorldInfo[mid] and self.MapWorldInfo[mid].BaseMap then
				mid = self.MapWorldInfo[mid].BaseMap
			end
			if self.MapWorldInfo[mid] then			-- Adjustment exists?
				ex = ex + self.MapWorldInfo[mid].X
				ey = ey + self.MapWorldInfo[mid].Y
			end

--			Nx.prt ("Inst %s %s, %s %s %f %f", name, mid, ename, emid or "nil", ex, ey)			
			local x, y = self:GetWorldPos (emid, ex, ey)

--			Nx.prt ("Inst %s %d, %d %f %f", name, mid, emid, x, y)

			local ewinfo = self.MapWorldInfo[emid]
			if not ewinfo then
--				Nx.prt ("? %s %s", ename, emid or "nil")
			end

			local winfo = {}
			winfo.EntryMId = emid
			winfo.Scale = 1002 / 25600 --ewinfo[1]		-- Scale
			winfo.X = x				-- X
			winfo.Y = y				-- Y
			winfo[4] = x				-- X
			winfo[5] = y				-- Y
			winfo.Cont = entrycont
			winfo.Zone = mid
			winfo.Instance = true
			self.MapWorldInfo[mid] = winfo
		end
	end

	--	DEBUG for Jamie

	Nx.ZoneConnections = Nx["ZoneConnections"] or Nx.ZoneConnections	-- Copy unmunged data to munged data

	-- Init zone connections
		for n = 0, 1999 do
			local mapId = n
			local winfo = worldInfo[mapId]
			if not winfo then
				
			else

			local cons = {}
			winfo.Connections = cons
			if winfo.Short then

			end
			for _, str in ipairs (Nx.ZoneConnections) do

				local flags, conTime, name1, z1, x1, y1, name2, z2, x2, y2 = Nx.Split ("|",str)

				conTime = tonumber(conTime)
				local mapId1 = tonumber(z1)
				local mapId2 = tonumber(z2)

				if not (mapId1 and mapId2) then
					Nx.prt ("zone conn err %s to %s", z1 - 35, z2 - 35)
					conTime = 0
				end

				if conTime == 1 and (mapId == mapId1 or (mapId == mapId2 and bit.band (flags, 1) == 1)) then

					local cont1 = self:IdToContZone (mapId1)
					local cont2 = self:IdToContZone (mapId2)

					if cont1 == cont2 then

						if mapId == mapId2 then		-- Swap?
							mapId1, mapId2 = mapId2, mapId1
							x1, y1, x2, y2 = x2, y2, x1, y1
						end

						local zcons = cons[mapId2] or {}
						cons[mapId2] = zcons

						if x1 ~= 0 and y1 ~= 0 then	-- Specific connection? Else connects anywhere

							local con = {}
							tinsert (zcons, con)

							x1, y1 = self:GetWorldPos (mapId1, x1, y1)
							x2, y2 = self:GetWorldPos (mapId2, x2, y2)

							con.StartMapId = mapId1
							con.StartX = x1
							con.StartY = y1
							con.EndMapId = mapId2
							con.EndX = x2
							con.EndY = y2
							con.Dist = ((x1 - x2) ^ 2 + (y1 - y2) ^ 2) ^ .5
						end

--					else
--						Nx.prt ("%s to %s", mapId1, mapId2)
					end
				end
			end
			end
		end
end

--------
-- Convert raw cont and zone to mapid
-- self: not used

function Nx.Map:ConnectionUnpack (str)
	-- File needs dungeon level updates
	local flags, typ, nam1, z1, x1, y1, nam2, z2, x2, y2 = Nx.Split ("|",str)
	if not nam1 then
		nam1 = ""
	end
	if not nam2 then
		nam2 = ""
	end
	return tonumber(flags), tonumber(typ), nam1, tonumber(z1), tonumber(x1), tonumber(y1), 0, nam2, tonumber(z2), tonumber(x2), tonumber(y2), 0
end

--------
-- Convert raw cont and zone to mapid
-- self: not used

function Nx.Map:CZ2MapId (cont, zone)

	if cont <= 0 then
		return 9000
	end

	return self.CZ2Id[cont][zone]
end

--------
-- Get the real player location map id without map level calculation

function Nx.Map:GetRealBaseMapId()
		return Nx.Map.UpdateMapID
end

--------
-- Get the real player location map id
-- asdf
function Nx.Map:GetInstanceID(id)
  if Nx.Zones[tonumber(id)] then
	local name, minLvl, maxLvl, faction, cont, entryId, entryPos = Nx.Split ("|", Nx.Zones[tonumber(id)])
	local entryZone = Nx.Zones[tonumber (entryId)]
	if entryZone then
		return entryId
	end
  end
  return 9000
end

function Nx.Map:GetRealMapId()
	return Nx.Map:GetCurrentMapAreaID()
end

--------
-- Get the current selected map id
-- Do not call Nx.Map:SetToCurrentZone() here or crash

function Nx.Map:GetCurrentMapId(conv)
	if Nx.Map.RMapId == 9000 then
		return Nx.Map:GetCurrentMapAreaID()
	end	
	return Nx.Map.RMapId
end

--------
-- Set the current using a map id

function Nx.Map:SetCurrentMap (mapId)
	if mapId then
---		Nx.prt ("Nx.Map:SetToCurrentZone %s", mapId)
		self.BaseScale = 1
		for n = 1, Nx.Map.ContCnt do
			for i,j in pairs (Nx.Map.MapZones[n]) do
				if mapId == j then
					local cont = self.MapWorldInfo[mapId].Cont
					local zone = self.MapWorldInfo[mapId].Zone

					if not self.MapWorldInfo[mapId].City and (not cont or not zone or mapId == self:GetRealBaseMapId() or mapId == self:GetRealMapId()) then						
						Nx.Map:SetToCurrentZone()		-- This fixes the Scarlet Enclave map selection, so we get player position						
						--SetDungeonMapLevel (1)
					else
--						SetMapZoom (cont, i)
						Nx.Map:SetMapByID(mapId)						
					end

					return
				end
			end
		end
		if self:IsInstanceMap(mapId) then	-- Instance?
			local aid = mapId
			if aid then
				self.MapId = 0				-- Force change (needed?)
				if mapId == self:GetRealBaseMapId() then
					Nx.Map:SetToCurrentZone()					
				else
					local caid = Nx.Map:GetCurrentMapAreaID()
					if caid ~= aid then
--						Nx.prt ("SetCurrentMap dif %s", caid)
						Nx.Map:SetMapByID (aid)						
						--SetDungeonMapLevel (1)
					end
				end
			else
				if mapId == self:GetRealBaseMapId() then
					self.MapId = 0				-- Force change
					Nx.Map:SetToCurrentZone()					
				else
					self.MapId = mapId
					--SetMapZoom (-1)			-- Cosmic map. Has no POIs
				end
			end
		end
		self.InstLevelSet = Nx.Map:GetCurrentMapDungeonLevel()
	end
end

--------
-- Set the map to current zone

function Nx.Map:SetToCurrentZone()
	Nx.Map:SetMapByID(MapUtil.GetDisplayableMapForPlayer())
end

function Nx.Map:GetCurrentMapAreaID()
	local displayableMapID = MapUtil.GetDisplayableMapForPlayer()
	local mapID = Nx.Map.MouseOver and WorldMapFrame:GetMapID() or displayableMapID

	local _, instanceType = GetInstanceInfo() 
	if (instanceType ~= nil and instanceType ~= "none") then mapID = displayableMapID end
	if mapID == 1414 then mapID = 12 end
	if mapID == 1415 then mapID = 13 end
	return mapID
end

--------
-- Save map view

function Nx.Map:SaveView (name)

	local str = format ("%s%s", Nx.InBG or "", name)

--	Nx.prt ("Save view %s", str)

	local v = self.ViewSavedData[str]

	if not v then
		v = {}
		self.ViewSavedData[str] = v
	end

	v.Scale = self.Scale
	v.X = self.MapPosX
	v.Y = self.MapPosY
end

--------
-- Restore map view

function Nx.Map:RestoreView (name)

	local str = format ("%s%s", Nx.InBG or "", name)

--	Nx.prt ("Restore view %s", str)

	local v = self.ViewSavedData[str]

	if v then
		self.Scale = v.Scale
		self.MapPosX = v.X
		self.MapPosY = v.Y

		self.StepTime = 5
	end
end

--------
-- Move map

function Nx.Map:Move (x, y, scale, stepTime)

--	Nx.prt ("Move %s %s sc %s time %s", x, y, scale or "nil", stepTime)

	self.MapPosX = x
	self.MapPosY = y

	if scale then
		self.Scale = scale
	end

	local dist = ((self.MapPosXDraw - self.MapPosX) ^ 2 + (self.MapPosYDraw - self.MapPosY) ^ 2) ^ .5

	local sz = max (self.MapW, self.MapH)

--	Nx.prt ("Move dist %f %f val %f", sz, dist, dist * self.Scale / sz)

	if dist * self.Scale / sz > 10 then	-- Zoomed in and a large jump?
		stepTime = 1	-- Go fast
	end

--	Nx.prt ("Move #%d %f steptime %f ", self.Tick, dist, self.StepTime)

	local st = abs (self.StepTime)	-- Will be neg if triggered

	if st > 0 and st < stepTime then		-- Already stepping? Use short time
		stepTime = st
--		Nx.prt ("Move steptime %f", stepTime)
	end

	self.StepTime = stepTime

	if dist < .25 then

--		Nx.prt ("Move snap XY")

		self.MapPosXDraw = self.MapPosX
		self.MapPosYDraw = self.MapPosY
	end

	if abs (1 / self.ScaleDraw - 1 / self.Scale) < .01 then
		self.ScaleDraw = self.Scale

--		Nx.prt ("Move snap scale")

		if dist < .25 then
			self.StepTime = 0
		end
	end

--[[
	if self.Debug then
		local plZX, plZY = Nx.GetPlayerMapPosition ("player")
		Nx.prt ("Move %f %f (%f %f)", x, y, plZX, plZY)
	end
--]]
end

--------
-- Goto current zone and center map

function Nx.Map:GotoCurrentZone()

--	Nx.prt ("GotoCurrentZone")

	if self.InstanceId then
		self:Move (self.PlyrX, self.PlyrY, 20, 15)
	else
		self:SetToCurrentZone()
		local mapId = MapUtil.GetDisplayableMapForPlayer()
		if mapId == 1414 then mapId = 12 end
		if mapId == 1415 then mapId = 13 end
		self:CenterMap (mapId)
	end
end

--------
-- Goto current zone and cause player moved update

function Nx.Map:GotoPlayer()

--	Nx.prt ("GotoPlayer")

	self:CalcTracking()

	self:SetToCurrentZone()

	self.MoveLastX = -1
	self.MoveLastY = -1
end

--------
-- Center the map in view

function Nx.Map:CenterMap (mapId, scale)
	if (mapId == nil or mapId == -1) then
		return
	end
	mapId = mapId or self.MapId

--[[ -- Map capture
	if 1 then
		self:CenterMap1To1 (floor (mapId / 1000) * 1000)
		return
	end
--]]

	if self:GetWorldZone (mapId).City then
		scale = 1
	end

	self.MapW = self.Frm:GetWidth() - self.PadX * 2
	self.MapH = self.Frm:GetHeight() - self.TitleH

	local x, y = self:GetWorldPos (mapId, 50, 50)
	local size = min (self.MapW / 1002, self.MapH / 668)
	if self.MapW < GetScreenWidth() / 2 then
		size = size * (scale or 1.5)
	end

	local scale = size / self:GetWorldZoneScale (mapId) * 10.02

	self:Move (x, y, scale, 15)

--	Nx.prt ("Center #%d %f (%f %f) (%d %d)", mapId, self.Scale, self.MapPosX, self.MapPosY, self.MapW, self.MapH)
end

--------
-- Center the map in view and 1 to 1 scale

function Nx.Map:CenterMap1To1 (mapId)
	self.MapPosX, self.MapPosY = self:GetWorldPos (mapId, 50, 50)

	self.Scale = 1002 / 100 / self:GetWorldZoneScale (mapId) * GetScreenWidth() / 1680 * 2
	self.ScaleDraw = self.Scale
	self.StepTime = 10
end

--------
-- Get a cont zone from the map id

function Nx.Map:IdToContZone (mapId)
	local info = self.MapWorldInfo[mapId]
	if not info then
		Nx.prtD("IdToCont Err " .. mapId)
		return 90, 0
	end
	return info.Cont or 90, info.Zone or 0
end

--------
-- Get map name from id

function Nx.Map:IdToName (mapId)
	if not mapId then
		return ""
	end	
	local name = Nx.Map:GetMapNameByID(mapId)
	if name then
		return name
	end
	return "?"
end

--------
-- Get map id from name

function Nx.Map:NameToId (mapName)
	return Nx.MapNameToId[mapName]
end

--------
--

function Nx.Map:IsNormalMap (mapId)
	for i = 1,self.ContCnt do
		for a,b in pairs(Nx.Map.MapZones[i]) do
			if b == mapId then
				return true
			end
		end
	end
	return false
end

--------
--

function Nx.Map:IsOutlandMap (mapId)
	return self.MapWorldInfo[zone].Cont == 3
end

--------
--

function Nx.Map:IsInstanceMap (mapId)
	if (Nx.Map:GetCurrentMapAreaID(true) == 20) then return false end
	local winfo = Nx.Map:GetMap(1).MapWorldInfo
	if mapId ~= 9000 and not winfo[mapId] then
		Nx.Map:GetZoneInfo (mapId)
	end
	if not winfo[mapId] then
		return false
	end
	if winfo[mapId].BaseMap then
	   mapId = Nx.Map.MapWorldInfo[mapId].BaseMap
	end	
	if winfo[mapId].Instance then
		return true
	end
	return false
end

--------
--

function Nx.Map:IsBattleGroundMap (mapId)
	if self.MapWorldInfo[mapId] and self.MapWorldInfo[mapId].Short then
		return true
	else
		return false
	end
end

function Nx.Map:IsMicroDungeon(mapId)
	local mapType = C_Map.GetMapInfo(mapId)
	if mapType == 5 then return true end
	return false
end

function Nx.Map:IsScenario(mapId)
	local name, instanceType, difficultyIndex, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, mapID = GetInstanceInfo()
	if (Nx.Map:GetCurrentMapId() == mapId) then
		if (difficultyIndex == 1) then
			return true
		end
	end
	return false
end

function Nx.Map:GCMI_OVERRIDE(mapId)
	return mapId and Nx.Map:GetWorldZone(mapId) and Nx.Map:GetWorldZone(mapId).overrideMapWorldId or mapId
end
--------
-- Get map short name (only BGs have)

function Nx.Map:GetShortName (mapId)
	return Nx.Map.MapWorldInfo[mapId].Short
end

--------
-- Get world info for a continent
-- (cont #)

function Nx.Map:GetWorldContinentInfo (cont)
	local info = self.MapInfo[cont]
	if Nx.inBG then
		info = self.MapInfo[90]
	end
	if not info then
		return
	end

	return info.Name, info.X, info.Y
end

--------
-- Get world info for a continent and zone
-- (cont #, zone #)

function Nx.Map:GetWorldZoneInfo (cont, zone)
	local org_zone = zone
	if not cont or not zone then
		return "unknown", 0, 0, 1002, 668
	end
	local name = Nx.Map:GetMapNameByID(zone) or "Unknown Zone"
--	local cont = self.MapWorldInfo[zone].Cont
	local info = self.MapInfo[cont]
	if not info then
		return name, 0, 0, 1002, 668
	end
	if zone == 0 then
		zone = Nx.Map.MapZones[0][cont]
	end
	local winfo = self.MapWorldInfo[zone]
	if not winfo then
		return
	end
	if not winfo.X then
		return name, 0, 0, 1002, 668
	end
	local x = info.X + winfo.X
	local y = info.Y + winfo.Y
	
	if (cont == 10 and org_zone == 0) or (cont == 11 and org_zone == 0) then
		--winfo.Scale = (self.DebugPXOff or 1)
	end
	local scale = winfo.Scale * 100

	return name, x, y, scale, scale / 1.5		-- x, y, w, h
end

--------
-- Get world zone from map id
-- (id)

function Nx.Map:GetWorldZone (mapId)
	if self.MapWorldInfo[mapId] then
		return self.MapWorldInfo[mapId]
	else
		return {}
	end
end

--------
-- Get world zone scale from map id
-- (id)

function Nx.Map:GetWorldZoneScale (mapId)
	local winfo = self.MapWorldInfo[mapId]
	if winfo and winfo.BaseMap then
		winfo = self.MapWorldInfo[winfo.BaseMap]
	end
	if winfo and winfo.Scale then
		return winfo.Scale
	else
		return 10.02
	end
end

--------
-- Get world position of map (zone) location
-- (id, x (0-100), y (0-100)

function Nx.Map:GetWorldPos (mapId, mapX, mapY)
	if mapId == 9000 then
		return 0,0
	end
	local winfo = self.MapWorldInfo[mapId]
	if winfo then
		if winfo.BaseMap then
			winfo = self.MapWorldInfo[winfo.BaseMap]
		end
		local scale = winfo.Scale						
			if not winfo[4] or not winfo[5] then
--			Nx.prt("GetWorldErr (Not Calculated): " .. mapId)
			return 0,0
		end		
		if not scale then
--			Nx.prt("GetWorldErr (Scale): " .. mapId)
			return 0,0
		end

		return	winfo[4] + mapX * scale,
					winfo[5] + mapY * scale / 1.5
	end
	if mapId then
		Nx.prtStack("GetPos Err:" .. mapId)
	else
		Nx.prtStack("GetPos Err")
	end
	return 0, 0
end

--------
-- Get world positions of map (zone) rectangle
-- (id, x, y)

function Nx.Map:GetWorldRect (mapId, mapX, mapY, mapX2, mapY2)

	local x, y = self:GetWorldPos (mapId, mapX, mapY)
	local x2, y2 = self:GetWorldPos (mapId, mapX2, mapY2)

	return x, y, x2, y2
end

--------
-- Get zone position of world location
-- (id, x, y)

function Nx.Map:GetZonePos (mapId, worldX, worldY)

--	self.GetZonePosCnt = (self.GetZonePosCnt or 0) + 1

--	Nx.prt ("WXY for map %s is %f %f", mapId, worldX, worldY)

	local winfo = self.MapWorldInfo[mapId]

	if winfo then
		if winfo.Scale and winfo[4] and winfo[5] then
			local scale = winfo.Scale
				return	(worldX - winfo[4]) / scale,
						(worldY - winfo[5]) / scale * 1.5
		else
			return 0,0
		end
--		local x = (worldX - info.X - winfo[2]) / scale
--		local y = (worldY - info.Y - winfo[3]) / scale * 1.5

--		Nx.prt ("XY %f %f %f", x, y, scale)

--		return x, y
	end

	return 0, 0
end

--------
-- Get continent of world location
-- (wx, wy)

--[[
function Nx.Map:GetContFromPos (worldX, worldY)

	if worldY < -2050 then
		return 3
	end

	if worldX > 2200 then
		return 2
	end

	return 1
end
--]]

--------
-- Convert frame (top left) to zone positions

function Nx.Map:FramePosToZonePos (x, y)
	x = x / (self.MapW - self.PadX) * 100
	y = y / (self.MapH - self.TitleH) * 100
	return x, y
end


--------
-- Convert frame (top left) to world positions

function Nx.Map:FramePosToWorldPos (x, y)
	x = self.MapPosX + (x - self.PadX - self.MapW / 2) / 10.02 / self.MapScale	
	y = self.MapPosY + (y - self.TitleH - self.MapH / 2) / 10.02 / self.MapScale	
	return x, y
end



--------
-- Set map target
-- (type string, x, y, x2, y2, texture (nil for default, false for none), user id, name)

function Nx.Map:SetTarget (typ, x1, y1, x2, y2, tex, id, name, keep, mapId)

	self.UpdateTrackingDelay = 0

	local sbt = self.ScaleBeforeTarget

--	if self.ScaleBeforeTarget then
--		self.Scale = self.ScaleBeforeTarget
		self.ScaleBeforeTarget = false
--	end

	if not keep then
		self:ClearTargets()
	end

	self.ScaleBeforeTarget = sbt or not next (self.Targets) and Nx.db.profile.Map.RestoreScaleAfterTrack and self.Scale

	local tar = {}
	tinsert (self.Targets, tar)

	assert (x1)

	tar.TargetType = typ
	tar.TargetX1 = x1
	tar.TargetY1 = y1
	tar.TargetX2 = x2
	tar.TargetY2 = y2
	tar.TargetMX = (x1 + x2) * .5		-- Mid point
	tar.TargetMY = (y1 + y2) * .5
	tar.TargetTex = tex
	tar.TargetId = id
	tar.TargetName = name
--	tar.ArrowPulse = 1

	mapId = mapId or self.MapId
	tar.MapId = mapId

	local i = self.TargetNextUniqueId
	tar.UniqueId = i
	self.TargetNextUniqueId = i + 1

	local typ = keep and "Target" or "TargetS"
	local zx, zy = self:GetZonePos (mapId, tar.TargetMX, tar.TargetMY)
	if Nx.Notes then
		Nx.Notes:Record (typ, name, mapId, zx, zy)
	end

	return tar
end

--------
-- Clear all targets
-- (matchType we will clear or nil for any)

function Nx.Map:ClearTargets (matchType)

	if matchType then
		local tar = self.Targets[1]
		if tar then
			if tar.TargetType ~= matchType then
				return
			end
		end
	end

	self.Targets = {}
	self.Tracking = {}

	if self.LOpts.NXAutoScaleOn and self.ScaleBeforeTarget then

--		Nx.prt ("ScaleBeforeTarget trigger %s", matchType or "nil")
--		self.Scale = self.ScaleBeforeTarget

		self:GotoPlayer()		-- Map won't move if cursor on it
		self:Move (self.PlyrX, self.PlyrY, self.ScaleBeforeTarget, 30)
	end

	self.ScaleBeforeTarget = false
end

--------

function Nx.Map:ClearTarget (uniqueId)

	self.Tracking = {}

	local tar, i = self:FindTarget (uniqueId)

	if tar then
--		Nx.prt ("ClearTarget %s %s", uniqueId, i)
		tremove (self.Targets, i)
	end

end

function Nx.Map:FindTarget (uniqueId)

	for n, tar in ipairs (self.Targets) do
		if tar.UniqueId == uniqueId then
			return tar, n
		end
	end
end

--------
-- Changes indexed or last target to a new index

function Nx.Map:ChangeTargetOrder (srcI, dstI)

	srcI = srcI >= 0 and srcI or #self.Targets	-- -1 for last target

	local t = tremove (self.Targets, srcI)
	tinsert (self.Targets, dstI, t)

	self.Tracking = {}
end

--------
-- Reverse order of all targets

function Nx.Map:ReverseTargets()

	local tar = self.Targets
	local n2 = #tar

	for n = 1, n2 / 2 do
		local a = tar[n]
		tar[n] = tar[n2]
		tar[n2] = a
		n2 = n2 - 1
	end

	self.Tracking = {}
end

--------
-- Set map target at zone xy (pos 0-100)
-- Ret target table

function Nx.Map:SetTargetXY (mid, zx, zy, name, keep)
if Nx.Quest and Nx.Quest.Watch then
	Nx.Quest.Watch:ClearAutoTarget()
end
	local wx, wy = self:GetWorldPos (mid, zx, zy)
	return self:SetTarget ("Goto", wx, wy, wx, wy, nil, nil, name or "", keep, mid)
end

--------
-- Set map target at mouse click

function Nx.Map:SetTargetAtClick()
if Nx.Quest and Nx.Quest.Watch then
	Nx.Quest.Watch:ClearAutoTarget()
end
	local wx, wy
	if (self:IsInstanceMap(Nx.Map.RMapId) or self:IsBattleGroundMap(Nx.Map.RMapId)) and self.CurOpts.NXInstanceMaps then
		local _x, _y = self:FramePosToZonePos (self.ClickFrmX, self.ClickFrmY)
		wx, wy = self:GetWorldPos(self.MapId, _x, _y)
	else
		wx,wy = self:FramePosToWorldPos (self.ClickFrmX, self.ClickFrmY)
	end
	local zx, zy = self:GetZonePos (self.MapId, wx, wy)
	local str = format (L["Goto %.0f, %.0f"], zx, zy)

	self:SetTarget ("Goto", wx, wy, wx, wy, nil, nil, str, IsShiftKeyDown())
end

function Nx.Map:SetTargetAtStr (str, keep)

	local mId, zx, zy, desc = self:ParseTargetStr (str)
	if mId then
		local wx, wy = self:GetWorldPos (mId, zx, zy)
		local str = format ("%.0f, %.0f", zx, zy)
		if desc then
			str = desc
		end
		self:SetTarget ("Goto", wx, wy, wx, wy, nil, nil, str, keep, mId)
	end
end

--------
-- Parse map target string. "[zone] x y"
-- (string)

function Nx.Map:ParseTargetStr (str)

--	Nx.prt (str)

--	local str = gsub (strlower (str), ",", " ")

	local zone
	local zx, zy
	local desc

	for s in gmatch (str, "%S+") do
		if not zx and strsub(s,#s,#s) == "," then
			s = strsub(s,0,#s - 1)			
		end
		local i = tonumber (s)
		if i then
			if zx then
				zy = zy or i
			else
				zx = i
			end
		else
			if zx and zy then
				if desc then
					desc = desc .. " " .. s
				else
					desc = s
				end
			else
				s = strlower(s)
				if zone then
					zone = zone .. " " .. s
				else
					zone = s
				end
			end
		end
	end

	local mid = Nx.Map.UpdateMapID

	if zone then		
		mid = nil
		local cont = 0
		local curmid = Nx.Map:GetCurrentMapAreaID()				
		
		for contN = 1, Nx.Map.ContCnt do		
			local doesExist = string.find(zone, ":" .. string.lower(Nx.Map.MapInfo[contN].Name))			
			if doesExist then
				zone = string.sub(zone,0,doesExist-1)
				cont = contN
			end
		end
		
		for id, zonedesc in pairs (Nx.Zones) do
			local name = strlower (string.gsub (zonedesc, "|.*", ""))
			if name == zone or string.sub (name, 1, #zone) == zone then
				if (cont > 0) and Nx.Map.MapWorldInfo[id].Cont == cont then
					mid = id
				elseif (cont == 0) then
					if not mid or math.abs(mid - curmid) > math.abs(mid - id) then
						mid = id
					end				
				end			
			end
		end

		if not mid then			
			if cont ~= 0 then
				Nx.prt("zone %s not found on continent %s",zone,Nx.Map.MapInfo[cont].Name)
			else
				Nx.prt ("zone %s not found", zone)
			end
			return
		end
	end

	if not zx or not zy then
		Nx.prt ("zone coordinate error")
		return
	end

	return mid, zx, zy, desc
end

----------------
-- External functions (for TomTom and Cartographer emulation)

--------
-- Used for id = TomTom:AddWaypoint (x, y, desc, persistent, minimap, world, silent)
-- self is bad if called by TomTom
-- TomTom:AddWaypoint parameters chaged to emulate current TomTom version: v80200-1.0.5
function Nx:TTAddWaypoint (mid, zx, zy, opt)

	local map = Nx.Map:GetMap (1)

	local tar = map:SetTargetXY (mid, zx*100, zy*100, opt.title, true)

	map:ChangeTargetOrder (-1, 1)

	return tar.UniqueId
end

function Nx:TTWayCmd(msg,editbox)
	local map = Nx.Map:GetMap(1)
	map:SetTargetAtStr (msg, true)
end

--------
-- Used for id = TomTom:AddZWaypoint (c, z, x, y, desc, persistent, minimap, world, callbacks, silent, crazy)

function Nx:TTAddZWaypoint (cont, zone, zx, zy, name, _persist, _minimap, _world, callbackT)

	local map = Nx.Map:GetMap (1)
	local mid = map:GetCurrentMapId()

	if cont and zone then
		mid = map:CZ2MapId (cont, zone)
	end

	return Nx:TTSetTarget (mid, zx, zy, name, callbackT)
end

--------
--	Used for id = TomTom:SetCustomWaypoint (c, z, x, y, callback, minimap, world, silent)

function Nx:TTSetCustomWaypoint (cont, zone, zx, zy, callbackT)

	return Nx:TTAddZWaypoint (cont, zone, zx, zy, "", false, nil, nil, callbackT)
end

--------
--	Used for id = TomTom:SetCustomMFWaypoint (m, f, x, y, opts)

function Nx:TTSetCustomMFWaypoint (aid, _floor, zx, zy, opts)

	zx = zx * 100
	zy = zy * 100

	return Nx:TTSetTarget (aid, zx, zy, opts["title"], opts["callbacks"])
end


function Nx:TTSetTarget (mid, zx, zy, name, callbackT)

--	Nx.prt ("TTSetTarget %s %s %s %s", name or "nil", mid or "nil", zx, zy)

	local map = Nx.Map:GetMap (1)
	local tar = map:SetTargetXY (mid, zx, zy, name, true)

	map:ChangeTargetOrder (-1, 1)

	if callbackT and callbackT["distance"] then

		local d = 99999
		local f

		for dist, func in pairs (callbackT["distance"]) do
			if dist < d then
				d = dist
				f = func
			end
		end

		tar.Radius = d
		tar.RadiusFunc = f

--		Nx.prt (" R %s", d)
	end

	return tar.UniqueId
end

--------
-- Used for TomTom:RemoveWaypoint (uid)

function Nx:TTRemoveWaypoint (id)

	local map = Nx.Map:GetMap (1)
	map:ClearTarget (id)
end

--------
-- Used for TomTom:SetCrazyArrow (uid, dist, title)

function Nx:TTSetCrazyArrow (id, dist, str)

	local map = Nx.Map:GetMap (1)
	local tar = map:FindTarget (id)
	if tar then
		tar.Radius = dist
		tar.TargetName = str
	end
end

--------
-- For RareSeeker and others

function Nx.MapMinimapOwned()
	local map = Nx.Map:GetMap (1)
	return map.MMOwn
end

function Nx.MapInitIconType (iconType, drawMode)

	local map = Nx.Map:GetMap (1)
	map:InitIconType (iconType, drawMode)
end

function Nx.MapAddIconPoint (iconType, mapName, x, y, texture, level)

	local map = Nx.Map:GetMap (1)
	local mapId = Nx.MapNameToId[mapName]

	if mapId then
		local wx, wy = map:GetWorldPos (mapId, x, y)
		map:AddIconPt (iconType, wx, wy, level, nil, texture)
	end
end

function Nx.MapAddIcon (name, mapId, x, y, level, tip, texture, tx1, ty1, tx2, ty2)
	if not Nx.CustomIcons then
		Nx.CustomIcons = {}
	end
	local map = Nx.Map:GetMap(1)
	if not Nx.CustomIcons[mapId] then
		Nx.CustomIcons[mapId] = {}
	end
	local wx, wy = map:GetWorldPos (mapId, x, y)
	Nx.CustomIcons[mapId][name] = {}
	Nx.CustomIcons[mapId][name].x = wx
	Nx.CustomIcons[mapId][name].y = wy
	Nx.CustomIcons[mapId][name].Level = level
	Nx.CustomIcons[mapId][name].tip = tip
	Nx.CustomIcons[mapId][name].texture = texture
	if tx1 and ty1 and tx2 and ty2 then
		Nx.CustomIcons[mapId][name].tx1 = tx1
		Nx.CustomIcons[mapId][name].ty1 = ty1
		Nx.CustomIcons[mapId][name].tx2 = tx2
		Nx.CustomIcons[mapId][name].ty2 = ty2
	end
	local CurMapId = map:GetCurrentMapId()
	if not Nx.db.char.Map.ShowCustom then
		return
	end
	if tx1 then
		local icon = map:AddIconPt("!CUSTOM",wx, wy, level, "FF0000", texture, tx1, ty1, tx2, ty2)
		if tip then
			map:SetIconTip(icon,tip)
		end
	else
		local icon = map:AddIconPt("!CUSTOM",wx, wy, level, "FF0000", texture)
		if tip then
			map:SetIconTip(icon,tip)
		end
	end
end

function Nx.MapRemoveIcon (name, mapNum)
	if not Nx.CustomIcons then
		return
	end
	local mapId = Nx.NxzoneToMapId[mapNum]
	if not Nx.CustomIcons[mapId] then
		return
	end
	if not Nx.CustomIcons[mapId][name] then
		return
	end
	Nx.CustomIcons[mapId][name] = nil
	local map = Nx.Map:GetMap (1)
	map:Update(1)
end

function Nx.MapAddIconRect (iconType, mapName, x, y, x2, y2, color)

	local map = Nx.Map:GetMap (1)
	local mapId = Nx.MapNameToId[mapName]

	if mapId then
		map:AddIconRect (iconType, mapId, x, y, x2, y2, color)
	end
end

function Nx.MapSetIconTip (icon, tip)

	local map = Nx.Map:GetMap (1)
	map:SetIconTip (icon, tip)
end

--------

function Nx.NXMapKeyTargetSkip()

	local self = Nx.Map:GetMap (1)

	local tar = self.Targets[1]
	if tar then
		tar.Radius = 999999999999
	end
end

-------------------------------------------------------------------------------
--

function Nx.Map.Dock:Create()

--PAIDS!

	if Nx.Free then
		return
	end

	self.UpdateMod = 100		-- Prevent error

	if not Nx.db.profile.MiniMap.ButOwn then
		return
	end

	-- Create Window

	Nx.Window:SetCreateFade (1, 0)

	local win = Nx.Window:Create ("NxMapDock", nil, nil, nil, 1, 1, nil, true)
	self.Win = win

	win:SetBGAlpha (0, 1)


	win:CreateButtons()
	win:InitLayoutData (nil, 100045, -.08, 45, 50, 2)

	win.Frm:SetToplevel (true)

	self:UpdateOptions()

	self.InitPending = true

	DockMinimapScan = Nx:ScheduleTimer(self.MinimapOwnInit,3,self)

--PAIDE!
end

--------
-- Init minimap button ownership

function Nx.Map.Dock:MinimapOwnInit()

	self.InitPending = nil

	local map = Nx.Map:GetMap (1)
	local mm = _G["Minimap"]

	local mmOwnerNames = {
		"NXMiniMapBut","GameTimeFrame","TimeManagerClockButton","MiniMapWorldMapButton","MiniMapMailFrame","MiniMapTracking","MiniMapVoiceChatFrame","QueueStatusMinimapButton","MiniMapInstanceDifficulty","GarrisonLandingPageMinimapButton",
	}

	local f = _G["MinimapBackdrop"]	-- Add so it gets ignored
	map.MMOwnedFrms[f] = 0

	self.MMFrms = {}

	for k, name in ipairs (mmOwnerNames) do
		local f = _G[name]
		if f then

			map.MMOwnedFrms[f] = 0
			tinsert (self.MMFrms, f)

			f:SetParent (self.Win.Frm)

			if name == "MiniMapTracking" then
				f:Show()
			end
		end
	end

	-- Scan all frames

	local texnames = { ["Interface\\AddOns\\CT_Core\\Images\\minimapIcon"] = 1, }

	local mapf = map.Frm
	local winf = self.Win.Frm

	local found = {}

	local f = EnumerateFrames()
	while f do

		if not f:IsObjectType ("Model") then
--		if f:IsShown() and not f:IsObjectType ("Model") then
			
			if pcall(f.GetPoint, f) then
				local pt, relTo = f:GetPoint()
				if relTo == mm then

					local parent = f:GetParent()
					if parent ~= mm and parent ~= mapf then
	--					Nx.prtFrame ("Dock Scan", f)
						found[f] = 1
					end
				end
			end

			local reg = { f:GetRegions() }
			for k, v in ipairs (reg) do

				if v:IsObjectType ("Texture") then
					v:SetSnapToPixelGrid(false)
					v:SetTexelSnappingBias(0)
					local tname = v:GetTexture()
					if tname and texnames[tname] then
--					if tname and strfind (tname, "CT") then
--						Nx.prt ("Tex %s", tname)

						found[f] = 1
						break
					end
				end
			end
		end

		f = EnumerateFrames (f)
	end

	-- Add found frames to list

	for f in pairs (found) do

		if not map.MMOwnedFrms[f] then
			map.MMOwnedFrms[f] = 0
			tinsert (self.MMFrms, f)
			f:SetParent (winf)
		end
	end

	map.Win:Show (map.StartupShown)

	Nx.Map:MinimapButtonShowUpdate()

	if Nx.db.profile.Debug.DebugDock then
		Nx.prt ("DockScan %s", #self.MMFrms)
	end
end

--------

function Nx.Map.Dock:UpdateOptions()

	local win = self.Win
	if win then

		local lock = win:IsLocked()
		win:SetBGAlpha (0, lock and 0 or 1)

		self.UpdateMod = 1
	end
end

--------

function Nx.Map.Dock:MinimapDetachFrms()

	if Nx.Map:GetMap (1).Frm.NxMap.Tick % self.UpdateMod ~= 0 then
		return
	end

	if not self.Win then
		return
	end

	self.UpdateMod = 30

	if Nx.db.profile.Debug.DebugDock then
		Nx.prt ("Dock %s", #self.MMFrms)
	end

	local mm = _G["Minimap"]
	local mmClock = _G["TimeManagerClockButton"]
	local win = self.Win
	local winf = win.Frm
	local butLvl = winf:GetFrameLevel() + 1
	local cLvl = butLvl + 1
	local setCLvls = Nx.Util_SetChildLevels
	local strata = winf:GetFrameStrata()

	local mini = Nx.db.profile.MiniMap.ButWinMinimize

	local cx, cy = win:GetClientOffset()
	local cw, ch = win:GetSize()

	local columnCnt = mini and 1 or Nx.db.profile.MiniMap.ButColumns		-- max (floor (cw / 30), 1)
	local columnStart = 0
	local columnEnd = columnCnt - 1

	local colAdd = 1
	local spacing = Nx.db.profile.MiniMap.ButSpacing
	local yAdd = spacing
	local y = cy + 6

	local s = Nx.db.profile.MiniMap.ButCorner
	if s == "TopRight" or s == "BottomRight" then
		columnEnd = -columnEnd
--		columnStart, columnEnd = columnEnd, columnStart
		colAdd = -1
	end
	if s == "BottomLeft" or s == "BottomRight" then
		yAdd = -yAdd
		y = cy - 6
	end

	local column = columnStart
	local borderSize = win:GetBorderSize()
	local baseX = borderSize + 17
	local baseY = y
	local incRow

--	if IsAltKeyDown() then return end

	for n, f in ipairs (self.MMFrms) do

		if f:IsVisible() then

			local w = f:GetWidth()
			if w > 0 then

				local sc = 32 / max (w, 32)

				if incRow then
					incRow = false
					column = columnStart
					y = y + yAdd
				end

				if mini and n > 1 then
					column = 0
					y = baseY
					butLvl = 1
					cLvl = 1
					sc = .1
				end

				local x = baseX + column * spacing

				f:SetParent (winf)
				f:ClearAllPoints()

				if f == mmClock then
					sc = sc * 1.5
--					f:SetPoint ("CENTER", winf, "TOPLEFT", x / sc - 3, -y / sc + 3)
				end

				f:SetPoint ("CENTER", winf, "TOPLEFT", x / sc, -y / sc)

--				if f == mmt then
--					sc = .82
--					f:SetPoint ("CENTER", winf, "TOPLEFT", x / sc - 3, -y / sc + 3)
--				end

				f:SetScale (sc)

				f:SetFrameStrata (strata)
				f:SetFrameLevel (butLvl)
				setCLvls (f, cLvl)
--[[
				if IsControlKeyDown() then
					Nx.prt ("MMFrms #%d %s %s", n, f:GetName() or "nil", w)
					Nx.prtFrame ("", f)
				end
--]]
				if column == columnEnd then
					incRow = true
				end

				column = column + colAdd
			end

		elseif f:IsShown() then		-- Strange? Fixes Outfitter Minimap button not drawing

--			Nx.prt ("Frm vis error %s", f:GetName() or "nil")
			f:Show()
		end
	end

	if not win.MovSizing then
--		local h = min (ch, cy - y)

		local x = winf:GetLeft()
		if not InCombatLockdown() then
			win:SetSize (34, 11)
		end
	end

	-- Debug

--[[

	if IsControlKeyDown() then

		local frms = {}

		for n, f in ipairs (self.MMFrms) do
			if frms[f] then
				Nx.prt ("Dup frm %s #%s", f:GetName() or "nil", n)
			end
			frms[f] = n
		end
	end
--]]
end

-------------------------------------------------------------------------------
-- Routing

--------
-- Gather icons

function Nx.Map:RouteGathers()

	local points = {}
	local cnt = self:GetIconCnt ("!Ga")

	for n = 1, cnt do
		local wx, wy = self:GetIconPt ("!Ga", n)
		local x, y = self:GetZonePos (self.MapId, wx, wy)

		local pt = {}
		tinsert (points, pt)
		pt.X = x
		pt.Y = y
	end

	self:RouteMerge (points)

	local route = self:Route (points)
	if route then
		self:RouteToTargets (route, false)
	end
end

function Nx.Map:RouteTargets()

	local points = {}

	for n, tar in ipairs (self.Targets) do

		local wx = tar.TargetMX
		local wy = tar.TargetMY
		local x, y = self:GetZonePos (self.MapId, wx, wy)

		local pt = {}
		tinsert (points, pt)
		pt.Name = tar.TargetName
		pt.X = x
		pt.Y = y
	end

	local route = self:Route (points)
	if route then
		self:RouteToTargets (route)
	end
end

function Nx.Map:RouteQuests (points)

	local route = self:Route (points)
	if route then
		self:RouteToTargets (route, false)
	end
end

--------
-- Merge close points

function Nx.Map:RouteMerge (points)

	local radius = Nx.db.profile.Route.MergeRadius

	if #points < 2 or radius < 1 then
		return
	end

	local tm = GetTime()

	sort (points, function (a, b) return a.X < b.X end)

--	for n, pt in ipairs (points) do
--		Nx.prt ("%s %s", n, pt.X)
--	end

	radius = radius / Nx.Map:GetWorldZoneScale (self.MapId) / 4.575
--	Nx.prt ("rad %s", radius)

	local radiusSq = radius ^ 2	-- Yards to world space squared

	local startCnt = #points
	local merged = true

	while merged do

		merged = false

		local close = 999999999
		local closeI1
		local closeI2

		for n1, pt1 in ipairs (points) do

--			local done

			for n2 = n1 + 1, #points do

				local pt2 = points[n2]

				if pt2.X - pt1.X > radius then
--					Nx.prt ("done %s %s", pt1.X, pt2.X)
--					done = true
					break
				end

				local d = (pt1.X - pt2.X) ^ 2 + ((pt1.Y - pt2.Y) / 1.5) ^ 2
				if d < close then
					close = d
					closeI1 = n1
					closeI2 = n2
--[[
					if d ^ .5 < radius * .5 then	-- Close enough? Early out
						Nx.prt ("%s + %s, %s", n1, n2, d ^ .5)
						done = true
						break
					end
--]]
				end
			end

--			if done then
--				break
--			end
		end

		if close ^ .5 < radius then

--			Nx.prt (" + %s %s", closeI1, closeI2)

			local pt1 = points[closeI1]
			local pt2 = points[closeI2]

			pt1.X = (pt1.X + pt2.X) * .5		-- Average
			pt1.Y = (pt1.Y + pt2.Y) * .5

			tremove (points, closeI2)
			merged = true

			sort (points, function (a, b) return a.X < b.X end)
		end
	end

	Nx.prt ("Merged %s in %.1f secs", startCnt - #points, GetTime() - tm)
end

--------
-- Make a route and target it

function Nx.Map:Route (points)

	if #points == 0 then
		return
	end

	-- Test

	local tm = GetTime()
--[[
	local blks = 20
	local scale = 5

	local points = {}
	for n = 0, 399 do
		local pt = {}
		points[n + 1] = pt
		pt.X = n % blks * scale + floor (n / 7) % 2 * 3
		pt.Y = floor (n / blks) * scale + floor (n / 3) % 2 * 4
--		pt.X = random (1, 20)
--		pt.Y = random (1, 20)
	end
--]]

	--

	local route = {}

	for n, pt in ipairs (points) do
		pt.Y = pt.Y / 1.5		-- Make Y same units as X
	end

	-- Nearest neighbor

	if #points > 1 then

		local x = points[1].X
		local y = points[1].Y
		if x == points[#points].X and y == points[#points].Y then	-- End same as start?
			tremove (points)
		end
	end

	local x, y = self:GetZonePos (self.MapId, self.PlyrX, self.PlyrY)
	y = y / 1.5

	while #points > 0 do

		local closeDist = 999999999
		local closeI

		for n, pt in ipairs (points) do

			local dist = (x - pt.X) ^ 2 + (y - pt.Y) ^ 2
			if dist < closeDist then
				closeDist = dist
				closeI = n
			end
		end

		local pt = tremove (points, closeI)

		local r = {}
		tinsert (route, r)
		r.Name = pt.Name
		r.X = pt.X
		r.Y = pt.Y
		r.Weight = pt.Weight or 1

		x = pt.X
		y = pt.Y
	end

	-- Add first node at end if needed for loop

	local x = route[1].X
	local y = route[1].Y

	if x ~= route[#route].X or y ~= route[#route].Y then

--		Nx.prt ("%f %f %f %f", x, route[#route].X, y, route[#route].Y)

		local r = {}
		r.X = x
		r.Y = y
		tinsert (route, r)
	end

	-- Calc length (sets node distances)

	local len = self:RouteLen (route)
--	Nx.prt ("Route len %s, %s secs", len, GetTime() - tm)

	-- Optimize .517 secs on 400

	for n = 1, 5 do
		local swap = self:RouteOptimize (route)
--		local len = self:RouteLen (route)
--		Nx.prt ("Route opt #%s len %s, %s secs", #route, len, GetTime() - tm)
		if not swap then
			break
		end
	end

	-- Show info

	local scale = self:GetWorldZoneScale (self.MapId)
	local len = self:RouteLen (route)
	Nx.prt ("Routed %s nodes, %d yards in %.1f secs", #route, len * scale * 4.575, GetTime() - tm)

	return route
end

function Nx.Map:GetZoneAchievement (always)

	local mId = Nx.Map:GetCurrentMapId()
--	local mId = Map:GetRealMapId()
	if not Nx.Map.MapWorldInfo[mId] then
		return
	end
	local a = Nx.Map.MapWorldInfo[mId].QAchievementId
	--[[if a then

		local id, name, _, done = GetAchievementInfo (a)
		if always or not done then
			if GetAchievementNumCriteria(a) > 0 then
				local _, _, done, cnt, need = GetAchievementCriteriaInfo (a, 1)
				local col = done and "|cff808080" or "|cff8080ff"
				return format ("%s%s %d/%d", col, name, cnt, need)
			end
		end
	end]]--
end

function Nx.Map:RouteToTargets (route, targetIcon)
	if Nx.Quest and Nx.Quest.Watch then
		Nx.Quest.Watch:ClearAutoTarget()
	end
	local mapId = self.MapId

	for n, r in ipairs (route) do

		local wx, wy = self:GetWorldPos (mapId, r.X, r.Y * 1.5)
		local s = format ("Route%s (%s) %s", n, #route - n + 1, r.Name or "")
		local tar = self:SetTarget ("Route", wx, wy, wx, wy, targetIcon, nil, s, n ~= 1)

		tar.Radius = Nx.db.profile.Route.GatherRadius

--		self:SetTargetXY (mapId, r.X, r.Y * 1.5, "r" .. n, true)
	end
end

function Nx.Map:RouteLen (route)

	local len = 0

	for n = 1, #route - 1 do
		local r1 = route[n]
		local r2 = route[n + 1]
		r1.Dist = ((r1.X - r2.X) ^ 2 + (r1.Y - r2.Y) ^ 2) ^ .5
		len = len + r1.Dist
--		Nx.prt ("Route %s len %s", n, ((x - r.X) ^ 2 + (y - r.Y) ^ 2) ^ .5)
	end

	return len
end

function Nx.Map:RouteOptimize (route)

	local swap

---[[ 1394.4788 len
	for len = #route - 2, 2, -1 do

		for n = 1, #route - len - 1 do

			local r1 = route[n]
			local r2 = route[n + 1]
			local n2 = n + len
			local r3 = route[n2]
			local r4 = route[n2 + 1]

			if r1.Dist + r3.Dist >
				((r1.X - r3.X) ^ 2 + (r1.Y - r3.Y) ^ 2) ^ .5 + ((r2.X - r4.X) ^ 2 + (r2.Y - r4.Y) ^ 2) ^ .5 then

				self:RouteSwap (route, n + 1, len)

--				local dist1 = ((r1.X - r2.X) ^ 2 + (r1.Y - r2.Y) ^ 2) ^ .5 + ((r3.X - r4.X) ^ 2 + (r3.Y - r4.Y) ^ 2) ^ .5
--				local dist2 = ((r1.X - r3.X) ^ 2 + (r1.Y - r3.Y) ^ 2) ^ .5 + ((r2.X - r4.X) ^ 2 + (r2.Y - r4.Y) ^ 2) ^ .5
--				Nx.prt ("Route %s swap %s %s %s", len, n, dist1 or 0, dist2 or 0)

				swap = true
			end
		end
	end
--]]

--[[	Little slower
	for last = #route - 1, 2, -1 do

		for n = 1, last - 2 do

			local r1 = route[n]
			local r2 = route[n + 1]
			local n2 = last
			local r3 = route[n2]
			local r4 = route[n2 + 1]

			if r1.Dist + r3.Dist >
				((r1.X - r3.X) ^ 2 + (r1.Y - r3.Y) ^ 2) ^ .5 + ((r2.X - r4.X) ^ 2 + (r2.Y - r4.Y) ^ 2) ^ .5 then

				self:RouteSwap (route, n + 1, last - n)

--				local dist1 = ((r1.X - r2.X) ^ 2 + (r1.Y - r2.Y) ^ 2) ^ .5 + ((r3.X - r4.X) ^ 2 + (r3.Y - r4.Y) ^ 2) ^ .5
--				local dist2 = ((r1.X - r3.X) ^ 2 + (r1.Y - r3.Y) ^ 2) ^ .5 + ((r2.X - r4.X) ^ 2 + (r2.Y - r4.Y) ^ 2) ^ .5
				Nx.prt ("Route %s swap %s %s %s", last - n, n, dist1 or 0, dist2 or 0)

				swap = true
			end
		end
	end
--]]

	return swap
end

function Nx.Map:RouteSwap (route, first, len)

	-- 1 2 3 4 5 6 7 8	Before (3, +4)
	-- 1 2 6 5 4 3 7 8	After

	local last = first + len - 1
	local stop = first + floor (len / 2) - 1

--[[	Loop unroll does not help
	local loops = floor (len / 2)

--	if loops > 1 then

--		Nx.prt ("Route swap loops %s", loops)

		if loops % 2 ~= 0 then
			route[first], route[last] = route[last], route[first]
			first = first + 1
			last = last - 1
		end

		for n = first, stop, 2 do
			route[n], route[last] = route[last], route[n]
			route[n+1], route[last-1] = route[last-1], route[n+1]
			last = last - 2
		end
	else
--]]

	local n2 = last
	for n = first, stop do
		route[n], route[n2] = route[n2], route[n]
		n2 = n2 - 1
	end

	for n = first - 1, last do
		local r1 = route[n]
		local r2 = route[n + 1]
		r1.Dist = ((r1.X - r2.X) ^ 2 + (r1.Y - r2.Y) ^ 2) ^ .5
	end
end

function Nx.Map:UnpackLocPtRelative (str, loc)

	local cnt
	local ox, oy = Nx.Map:UnpackLocPtOff (str, loc)

	ox = ox - 50
	oy = oy - 50

	for n = 1, GetNumBattlefieldVehicles() do

		local x, y, unitName, possessed, typ, dir, player = GetBattlefieldVehicleInfo (n, Nx.Map:GetCurrentMapId())
		if x and not player then

			if typ == Nx.AirshipType then
				cnt = 1

				dir = dir / PI * 180
				oy = oy / 1.5
				ox, oy = ox * cos (dir) + oy * sin (dir), (ox * -sin (dir) + oy * cos (dir)) * 1.5
				ox = x * 100 + ox
				oy = y * 100 + oy

--				Nx.prt ("%s Airship %s %s %s", name, typ, ox, oy)
				break
			end
		end
	end

	if not cnt then
		ox = ox + 62
		oy = oy + 42
	end

	return ox, oy
end

--------
-- Unpack location data " xywh" or "xxyy"
-- (string, offset)

function Nx.Map:UnpackLoc (locStr, off)

	local isPt = strbyte (locStr, off) <= 33		-- Space or !

	if isPt then

		local x1, x2, y1, y2 = strbyte (locStr, 1 + off, 4 + off)
		return	((x1 - 35) * 221 + (x2 - 35)) / 100,
					((y1 - 35) * 221 + (y2 - 35)) / 100
	end

	local x, y, w, h = strbyte (locStr, 0 + off, 3 + off)

	return	(x - 35) * .5,		-- * 100 / 200, Optimised
				(y - 35) * .5		-- * 100 / 200

end

--------
-- Unpack location data "xywh"
-- (string)

function Nx.Map:UnpackLocRect (locStr)

	local x, y, w, h = strbyte (locStr, 1, 4)

	return	(x - 35) * .5,		-- * 100 / 200	Optimised
				(y - 35) * .5,		-- * 100 / 200
				(w - 35) * 5.01,	-- * 1002 / 200,
				(h - 35) * 3.34	-- * 668 / 200
end

--------
-- Unpack location data point "xxyy"
-- (string)

function Nx.Map:UnpackLocPt (locStr)
	local x1, x2, y1, y2 = strbyte (locStr, 1, 4)
	return	((x1 - 35) * 221 + (x2 - 35)) / 100,
				((y1 - 35) * 221 + (y2 - 35)) / 100
end

--------
-- Unpack location data point "xxyy"
-- (string)

function Nx.Map:UnpackLocPtOff (locStr, off)

	local x1, x2, y1, y2 = strbyte (locStr, off, 3 + off)
	return	((x1 - 35) * 221 + (x2 - 35)) / 100,
				((y1 - 35) * 221 + (y2 - 35)) / 100
end

function Nx.Map:UnpackObjective (obj)
	if not obj then
		return
	end

	local i = strbyte (obj) - 35 + 1
	local desc = strsub (obj, 2, i)

	if #obj == i then
		return desc
	end

	local zone = strbyte (obj, i + 1) - 35
	return desc, zone, i + 2
end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Test code

function Nx.Map:VehicleDumpPos()

	-- Right Reaver guard .431 -.701  -359

	for n = 1, GetNumBattlefieldVehicles() do

		local x, y, unitName, possessed, typ, dir, player = GetBattlefieldVehicleInfo (n, Nx.Map:GetCurrentMapId())
		if x and not player then

			local xo = self.PlyrRZX - x * 100
			local yo = (self.PlyrRZY - y * 100) / 1.5
			dir = dir / PI * -180
			xo, yo = xo * cos (dir) + yo * sin (dir), (xo * -sin (dir) + yo * cos (dir)) * 1.5

			Nx.prt ("#%s %s %f %f %.3f %s", n, unitName or "nil", xo, yo, dir or -1, typ or "no type")
		end
	end
end

function Nx.Map.RestoreWorldMap()
	if not Nx.Map.WMDF then
		return
	end
	
	--[[local layers = C_Map.GetMapArtLayers(Nx.Map.RMapId)
	local layerInfo = layers[1]
	local rows, cols = math.ceil(layerInfo.layerHeight / layerInfo.tileHeight), math.ceil(layerInfo.layerWidth / layerInfo.tileWidth)
	
	for i=1, cols do
	  for j=1, rows do
		local index = (j - 1) * cols + i
		Nx.Map.WMDT[index]:SetTexture(nil)	
	  end
	end]]--
	
	foreach(Nx.Map.WMDT, function (k, v)
		Nx.Map.WMDT[k]:SetTexture(nil)	
	end)
	
	Nx.Map.WMDF:Hide()
	local index = 1
	local bossButton = _G["NXEJMapButton"..index]	
	while bossButton do
		bossButton:Hide()
		index = index + 1
		bossButton = _G["NXEJMapButton"..index]
	end	
	--Nx.Map.NInstMapId = nil
end

function Nx.Map.MoveWorldMap()	
	local curId = Nx.Map:GetCurrentMapId()
	if not Nx.Map.NInstMapId or Nx.Map.NInstMapId ~= curId then
		Nx.Map.NInstMapId = curId
	end
	Nx.Map:SetCurrentMap (Nx.Map.NInstMapId)
	
	local mapInfo = C_Map.GetMapInfo(curId)
	if not mapInfo.name then
		return
	end	
	local layers = C_Map.GetMapArtLayers(curId)
	local layerInfo = layers[1]
	local rows, cols = math.ceil(layerInfo.layerHeight / layerInfo.tileHeight), math.ceil(layerInfo.layerWidth / layerInfo.tileWidth)
	
	if not Nx.Map.WMDF then
		Nx.Map.WMDF = CreateFrame("Frame", "WMDF")		
		Nx.Map.WMDF:SetFrameStrata("BACKGROUND")
		Nx.Map.WMDT = {}
		Nx.Map.EJMB = {}
		for i = 1,cols do
			for j = 1, rows do
		    	local index = (j - 1) * cols + i 			 
				Nx.Map.WMDT[index] = Nx.Map.WMDF:CreateTexture("WMDT" .. index)
			end
		end		
		Nx.Map.WMDT[1]:SetPoint("TOPLEFT")
		Nx.Map.WMDT[2]:SetPoint("TOPLEFT","WMDT1","TOPRIGHT")
		Nx.Map.WMDT[3]:SetPoint("TOPLEFT","WMDT2","TOPRIGHT")
		Nx.Map.WMDT[4]:SetPoint("TOPLEFT","WMDT3","TOPRIGHT")
		Nx.Map.WMDT[5]:SetPoint("TOPLEFT","WMDT1","BOTTOMLEFT")
		Nx.Map.WMDT[6]:SetPoint("TOPLEFT","WMDT5","TOPRIGHT")
		Nx.Map.WMDT[7]:SetPoint("TOPLEFT","WMDT6","TOPRIGHT")
		Nx.Map.WMDT[8]:SetPoint("TOPLEFT","WMDT7","TOPRIGHT")
		Nx.Map.WMDT[9]:SetPoint("TOPLEFT","WMDT5","BOTTOMLEFT")
		Nx.Map.WMDT[10]:SetPoint("TOPLEFT","WMDT9","TOPRIGHT")
		Nx.Map.WMDT[11]:SetPoint("TOPLEFT","WMDT10","TOPRIGHT")
		Nx.Map.WMDT[12]:SetPoint("TOPLEFT","WMDT11","TOPRIGHT")
	end
	Nx.Map.WMDF:SetParent(Nx.Map:GetMap(1).Frm)
	Nx.Map.WMDF:SetFrameLevel(20)
	Nx.Map.WMDF:SetWidth(Nx.Map:GetMap(1).MapW)
	Nx.Map.WMDF:SetHeight(Nx.Map:GetMap(1).MapH)
	Nx.Map.WMDF:Show()
	
	local textures = C_Map.GetMapArtLayerTextures(curId,1)
	
	for i=1, 12 do
		Nx.Map.WMDT[i]:SetWidth(Nx.Map.WMDF:GetWidth() / 3.9)		
		Nx.Map.WMDT[i]:SetHeight(Nx.Map.WMDF:GetHeight() / 2.6)
		Nx.Map.WMDT[i]:SetTexture(textures[i])
	end	
	Nx.Map.WMDF:SetAllPoints()
	NXWorldMapUnitPositionFrame:SetParent(Nx.Map.WMDF)
	NXWorldMapUnitPositionFrame:SetAllPoints()
	NXWorldMapUnitPositionFrame:SetFrameLevel(40)
	Nx.Map:NXWorldMapUnitPositionFrame_UpdatePlayerPins()
	
--[[	local numEncounters = 0;
	if Nx.db.char.Map.ShowRaidBoss then
		local width = Nx.Map.WMDF:GetWidth();
		local height = Nx.Map.WMDF:GetHeight();

	    local mapEncounters = C_EncounterJournal.GetCurrentMapEncounters(WorldMapFrame.fromJournal);
		if ( mapEncounters ) then
			numEncounters = #mapEncounters;
			for index, mapEncounterInfo in ipairs(mapEncounters) do
				local bossButton = _G["NXEJMapButton"..index]
				if not bossButton then -- create button
					bossButton = CreateFrame("Button", "NXEJMapButton"..index, Nx.Map.WMDF, "EncounterMapButtonTemplate");				
				end

				local name, description, encounterID, rootSectionID, link, instanceID = EJ_GetEncounterInfo(mapEncounterInfo.encounterID);
				bossButton.instanceID = instanceID;
				bossButton.encounterID = encounterID;
				bossButton.tooltipTitle = name;
				bossButton.tooltipText = description;
				bossButton:SetPoint("CENTER", Nx.Map.WMDF, "BOTTOMLEFT", mapEncounterInfo.mapX*width, mapEncounterInfo.mapY*height);
				bossButton:SetFrameStrata("HIGH");
				local _, _, _, displayInfo = EJ_GetCreatureInfo(1, encounterID);
				bossButton.displayInfo = displayInfo;
				bossButton:SetWidth(Nx.db.profile.Map.InstanceBossSize);
				bossButton:SetHeight(Nx.db.profile.Map.InstanceBossSize);
				if ( displayInfo ) then
					SetPortraitTexture(bossButton.bgImage, displayInfo);
					bossButton.bgImage:SetWidth(Nx.db.profile.Map.InstanceBossSize / 1.3);
					bossButton.bgImage:SetHeight(Nx.db.profile.Map.InstanceBossSize / 1.3);
				else
					bossButton.bgImage:SetTexture("DoesNotExist");
				end			
				bossButton:Show();
			end
		end
	end	

	WorldMapFrame.hasBosses = numEncounters > 0;
	index = numEncounters + 1;	
	local bossButton = _G["NXEJMapButton"..index];
	while bossButton do
		bossButton:Hide();
		index = index + 1;
		bossButton = _G["NXEJMapButton"..index];
	end	]]--
end

function Nx.Map:UpdatePlayerPositions() -- Copy of the local defined player arrow function out of blizzards map code
	local timeNow = GetTime()

	NXWorldMapUnitPositionFrame:ClearUnits()

	local r, g, b = CheckColorOverrideForPVPInactive("player", timeNow, 1, 1, 1)	
	NXWorldMapUnitPositionFrame:AddUnit("player", "Interface\\WorldMap\\WorldMapArrow", Nx.db.profile.Map.InstancePlayerSize, Nx.db.profile.Map.InstancePlayerSize, r, g, b, 1, 7, true)

	local isInRaid = IsInRaid()
	local memberCount = 0
	local unitBase

	if isInRaid then
		memberCount = MAX_RAID_MEMBERS
		unitBase = "raid"
	elseif IsInGroup() then
		memberCount = MAX_PARTY_MEMBERS
		unitBase = "party"
	end

	for i = 1, memberCount do
		local unit = unitBase..i
		if UnitExists(unit) and not UnitIsUnit(unit, "player") then
			local atlas = UnitInSubgroup(unit) and "WhiteCircle-RaidBlips" or "WhiteDotCircle-RaidBlips"
			local class = select(2, UnitClass(unit))
			local r, g, b = CheckColorOverrideForPVPInactive(unit, timeNow, GetClassColor(class))
			NXWorldMapUnitPositionFrame:AddUnitAtlas(unit, atlas, Nx.db.profile.Map.InstanceGroupSize, Nx.db.profile.Map.InstanceGroupSize, r, g, b, 1)
		end
	end

	NXWorldMapUnitPositionFrame:FinalizeUnits()
end

function Nx.Map.NXWorldMapUnitPositionFrame_UpdatePlayerPins()
	if NXWorldMapUnitPositionFrame:NeedsFullUpdate()then
		Nx.Map.NXWorldMapUnitPositionFrame_UpdateFull(GetTime());	
	elseif NXWorldMapUnitPositionFrame:NeedsPeriodicUpdate() then
		Nx.Map.NXWorldMapUnitPositionFrame_UpdatePeriodic(GetTime());
	end
end

function Nx.Map.NXWorldMapUnitPositionFrame_UpdateFull(timeNow)
	assert(NXWorldMapUnitPositionFrame:NeedsFullUpdate());
	NXWorldMapUnitPositionFrame:ClearUnits()

	local r, g, b = CheckColorOverrideForPVPInactive("player", timeNow, 1, 1, 1)	
	NXWorldMapUnitPositionFrame:AddUnit("player", "Interface\\WorldMap\\WorldMapArrow", Nx.db.profile.Map.InstancePlayerSize, Nx.db.profile.Map.InstancePlayerSize, r, g, b, 1, 7, true)

	local isInRaid = IsInRaid()
	local memberCount = 0
	local unitBase

	if isInRaid then
		memberCount = MAX_RAID_MEMBERS
		unitBase = "raid"
	elseif IsInGroup() then
		memberCount = MAX_PARTY_MEMBERS
		unitBase = "party"
	end

	for i = 1, memberCount do
		local unit = unitBase..i
		if UnitExists(unit) and not UnitIsUnit(unit, "player") then
			local atlas = UnitInSubgroup(unit) and "WhiteCircle-RaidBlips" or "WhiteDotCircle-RaidBlips"
			local class = select(2, UnitClass(unit))
			local r, g, b = CheckColorOverrideForPVPInactive(unit, timeNow, GetClassColor(class))
			NXWorldMapUnitPositionFrame:AddUnitAtlas(unit, atlas, Nx.db.profile.Map.InstanceGroupSize, Nx.db.profile.Map.InstanceGroupSize, r, g, b, 1)
		end
	end
	
	NXWorldMapUnitPositionFrame:FinalizeUnits()
	NXWorldMapUnitPositionFrame.needsFullUpdate = false;
end

function Nx.Map.NXWorldMapUnitPositionFrame_UpdatePeriodic(timeNow)
	local r, g, b = CheckColorOverrideForPVPInactive("player", timeNow, 1, 1, 1)
	NXWorldMapUnitPositionFrame:SetUnitColor("player", r, g, b, 1);
	
	local isInRaid = IsInRaid()
	local memberCount = 0
	local unitBase

	if isInRaid then
		memberCount = MAX_RAID_MEMBERS
		unitBase = "raid"
	elseif IsInGroup() then
		memberCount = MAX_PARTY_MEMBERS
		unitBase = "party"
	end

	for i = 1, memberCount do
		local unit = unitBase..i
		if UnitExists(unit) and not UnitIsUnit(unit, "player") then
			local atlas = UnitInSubgroup(unit) and "WhiteCircle-RaidBlips" or "WhiteDotCircle-RaidBlips"
			local class = select(2, UnitClass(unit))
			local r, g, b = CheckColorOverrideForPVPInactive(unit, timeNow, GetClassColor(class))
			NXWorldMapUnitPositionFrame:SetUnitColor(unit, r, g, b, 1)
		end
	end
end

function Nx.Map:GetMapNameByID (mapId)
	if not mapId then
		mapId = Nx.Map:GetCurrentMapAreaID()
	end
--	local mapInfo = C_Map.GetMapInfo(mapId)
	local mapInfo = Nx.Map:GetMapInfo(mapId)
	return mapInfo and mapInfo.name or nil
end

function Nx.Map:GetCurrentMapDungeonLevel()
	return 0
end

function Nx.Map:GetCurrentMapContinent()
	return select(1, C_Map.GetWorldPosFromMapPos(C_Map.GetBestMapForUnit("player") or 0, {x=0, y=0})) or 0
	--[[local mapID = C_Map.GetBestMapForUnit("player")
    if(mapID) then
        local info = C_Map.GetMapInfo(mapID)
        if(info) then
            while(info['mapType'] and info['mapType'] > 2) do
                info = C_Map.GetMapInfo(info['parentMapID'])
            end
            if(info['mapType'] == 2) then
                return info['mapID']
            end
        end
    end]]--
end

function Nx.Map:HideNewPlrFrame()
	if NewPlrFrm then NewPlrFrm:Hide() end
end

function Nx.Map.GetPlayerMapPosition (unit)
	local mID = C_Map.GetBestMapForUnit(unit)		
	local x, y
	if(mID) then
		if unit ~= "player" and mID ~= Nx.Map.RMapId then		
			return 0,0
		end
		if C_Map.GetPlayerMapPosition (mID, unit) then
			x, y = C_Map.GetPlayerMapPosition (mID, unit):GetXY()
		else
			return 0,0
		end
	end

	if x == nil or y == nil then		
		return 0, 0
	end	
	return x, y
end

local zoneMapIDtoContinentMapID = {}
function Nx.Map:GetContinentMapID(uiMapID)
	-- First, check the cache, built during initialisation based on the zones returned by GetMapZonesAlt
	local continentMapID = zoneMapIDtoContinentMapID[uiMapID]
	if continentMapID then
		-- Done
		return continentMapID
	end
	
	-- Not in cache, look for the continent, searching up through the map hierarchy.
	-- Add the results to the cache to speed up future queries.
	local mapInfo = C_Map.GetMapInfo(uiMapID)
	if not mapInfo or mapInfo.mapType == 0 or mapInfo.mapType == 1 then
		-- No data or Cosmic map or World map
		zoneMapIDtoContinentMapID[uiMapID] = nil
		return nil
	end
	
	if mapInfo.mapType == 2 then
		-- Map is a Continent map
		zoneMapIDtoContinentMapID[uiMapID] = mapInfo.mapID
		return mapInfo.mapID
	end
	
	local parentMapInfo = C_Map.GetMapInfo(mapInfo.parentMapID)
	if not parentMapInfo then
		-- No parent -> no continent ID
		zoneMapIDtoContinentMapID[uiMapID] = nil
		return nil
	else
		if parentMapInfo.mapType == 2 then
			-- Found the continent
			zoneMapIDtoContinentMapID[uiMapID] = parentMapInfo.mapID
			return parentMapInfo.mapID
		else
			-- Parent is not the Continent -> Search up one level
			return Nx.Map:GetContinentMapID(parentMapInfo.mapID)
		end
	end
end

-------------------------------------------------------------------------------
-- EOF
