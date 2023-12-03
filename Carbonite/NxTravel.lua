---------------------------------------------------------------------------------------
-- NxTravel - Travel code
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
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
---------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
-- Tables
---------------------------------------------------------------------------------------

local L = LibStub("AceLocale-3.0"):GetLocale("Carbonite")

function Nx.Travel:Init()
	self.OrigTakeTaxiNode = TakeTaxiNode
	TakeTaxiNode = self.TakeTaxiNode		-- Hook it

	local tr = {}
	for n = 1, Nx.Map.ContCnt do
		tr[n] = {}
	end
	tr[99] = {}
	self.Travel = tr

	self:Add (L["Flight Master"])

--	if Nx:GetUnitClass() == "DRUID" then
--		local taxiT = NxCData["Taxi"]
--		taxiT[""] = true
--	end

	self.WrathFlyName = GetSpellInfo (54197) or ""
	self.AzerothFlyName = GetSpellInfo (90267) or ""
	self.PandariaFlyName = GetSpellInfo(115913) or ""
	self.DraenorFlyName = GetSpellInfo(191645) or ""
	self.LegionFlyName = GetSpellInfo(233368) or ""
end

function Nx.Travel:Add (typ)
	local Map = Nx.Map
	local hideFac = UnitFactionGroup ("player") == "Horde" and 1 or 2
	for a,b in pairs(Nx.GuideData[typ]) do
		if a ~= "Mode" then
			local ext = { Nx.Split("|",b) }
			for c,d in pairs(ext) do
				if d then
					local side,x,y,level,num = Nx.Split(",",d)
					local fac,name,locName,zone,x,y,level = Nx.Split("|",Nx.NPCData[tonumber(num)])
					fac,zone,x,y = tonumber(fac),tonumber(zone),tonumber(x),tonumber(y)
					local _, _, _, _, cont, _, _ = Nx.Split ("|", Nx.Zones[tonumber(zone)])
					local tdata = self.Travel[tonumber(cont)]
					if fac ~= hideFac then
						local mapId = zone
						local wx, wy = Map:GetWorldPos (mapId, x, y)
						local node = {}
						node.Name = locName
						node.LocName = locName		-- Localize it
						node.MapId = mapId
						node.WX = wx
						node.WY = wy
						tinsert (tdata, node)
					end
				end
			end
		end
	end
end

---------------------------------------------------------------------------------------
-- Taxi Map open event
---------------------------------------------------------------------------------------

function Nx.Travel.OnTaximap_opened()

--	Nx.prt ("OnTaximap_opened")

	local self = Nx.Travel

	self:CaptureTaxi()
end

---------------------------------------------------------------------------------------
-- Record taxi locations we can use
---------------------------------------------------------------------------------------

function Nx.Travel:CaptureTaxi()

	self.TaxiNameStart = false

	local taxiT = Nx.db.char.Travel.Taxi["Taxi"]

	for n = 1, NumTaxiNodes() do

--		local locName = Nx.Split (",", TaxiNodeName (n))
		local locName = TaxiNodeName (n)
		local locStatus = TaxiNodeGetType(n)
		if locStatus == "CURRENT" or locStatus == "REACHABLE" then
			taxiT[locName] = true
		else
			taxiT[locName] = false
		end
		if TaxiNodeGetType (n) == "CURRENT" then

			self.TaxiNameStart = locName

			if Nx.db.profile.Debug.DebugMap then
				local name = Nx.Map.Guide:FindTaxis (locName)
				Nx.prt ("Taxi current %s (%s)", name or "nil", locName)
			end
		end
	end
end

---------------------------------------------------------------------------------------
-- Hook for Taxi use
---------------------------------------------------------------------------------------

function Nx.Travel.TakeTaxiNode (node)

	local self = Nx.Travel
	local map = Nx.Map

--	map.TaxiName = Nx.Split (",", TaxiNodeName (node))
	map.TaxiName = TaxiNodeName (node)

	local name, x, y = Nx.Map.Guide:FindTaxis (map.TaxiName)
--	map.TaxiNPCName = name
	map.TaxiX = x
	map.TaxiY = y

	Nx.Map.TaxiETA = false

	local tm = self:TaxiCalcTime (node)
	if tm > 0 and self.TaxiNameStart then

		self.TaxiTimeEnd = GetTime() + tm
		TaxiTime = Nx:ScheduleTimer(self.TaxiTimer,1,self)
	end

	if Nx.db.profile.Debug.DebugMap then
		Nx.prt ("Taxi %s (%s) %.2f secs, node %d, %s %s", name or "nil", map.TaxiName, tm, node, x or "?", y or "?")
	end

	Nx.Travel.OrigTakeTaxiNode (node)
end

---------------------------------------------------------------------------------------
--
---------------------------------------------------------------------------------------

function Nx.Travel:TaxiCalcTime (dest)

	local tm = 0
	local num = NumTaxiNodes()

	if num > 0 then

--		TaxiNodeSetCurrent (dest)

		local rCnt = GetNumRoutes (dest)

		for n = 1, rCnt do

			local x = TaxiGetSrcX (dest, n)
			local y = TaxiGetSrcY (dest, n)

			local srcNode = self:TaxiFindNodeFromRouteXY (x, y)

			local x = TaxiGetDestX (dest, n)
			local y = TaxiGetDestY (dest, n)

			local destNode = self:TaxiFindNodeFromRouteXY (x, y)

			if srcNode and destNode then

--				local srcName = Nx.Split (",", TaxiNodeName (srcNode))
--				local destName = Nx.Split (",", TaxiNodeName (destNode))

				local srcName = TaxiNodeName (srcNode)
				local destName = TaxiNodeName (destNode)

				local t = self:TaxiFindConnectionTime (srcName, destName)

				local routeName = srcName .. "#" .. destName

				if t == 0 then

					local tt = Nx.db.char.Travel["TaxiTime"]

					t = tt[routeName]

					if not t then

						if Nx.db.profile.Debug.DebugMap then
							Nx.prt (" No taxi data %s to %s", srcName, destName)
						end

						if rCnt == 1 then
							self.TaxiSaveName = routeName
						end

						return 0
					end
				end

				tm = tm + t

				if Nx.db.profile.Debug.DebugMap then
					Nx.prt (" #%s %s to %s, %s secs", n, srcName, destName, t)
				end

			end
		end
	end

	return tm
end

---------------------------------------------------------------------------------------
--
---------------------------------------------------------------------------------------

function Nx.Travel:TaxiFindNodeFromRouteXY (x, y)

	for n = 1, NumTaxiNodes() do

		local x2, y2 = TaxiNodePosition (n)
		local dist = (x - x2) ^ 2 + (y - y2) ^ 2

		if dist < .000001 then

--			if NxData.DebugMap then
--				Nx.prt (" #%s %s %s %s %s", n, TaxiNodeName (n), dist, x, y)
--			end

			return n
		end
	end
end

--------
--

function Nx.Travel:TaxiFindConnectionTime (srcName, destName)
	local srcNPCName, x, y = Nx.Map.Guide:FindTaxis (srcName)
	local destNPCName, x, y = Nx.Map.Guide:FindTaxis (destName)

--	Nx.prt ("NPC src %s %s", srcName, srcNPCName or "nil")
--	Nx.prt ("NPC dest %s %s", destName, destNPCName or "nil")

	-- single string comprising multiple 6 byte entries
	-- aabbcc
	-- aa = index of start npc (Nx.NPCData table)
	-- bb = index of end npc (Nx.NPCData table)
	-- cc = flight time in 10ths of a second
	-- all are base 221 encoded (indicies start at 1)

	local conn = Nx.FlightConnection

	for n = 1, #conn, 6 do

		local a1, a2, b1, b2, c1, c2 = strbyte (conn, n, n + 5)

		local i = (a1 - 35) * 221 + a2 - 35

		local npc = Nx.NPCData[i]
		if npc then

			local oStr = strsub (npc, 2)
			local desc, zone, loc = Nx.Map:UnpackObjective (oStr)
			local name = Nx.Split ("!", desc)

			if name == srcNPCName then

--				Nx.prt ("SNPC %s", desc)

				local i = (b1 - 35) * 221 + b2 - 35
				local npc = Nx.NPCData[i]
				if npc then

					local oStr = strsub (npc, 2)
					local desc, zone, loc = Nx.Map:UnpackObjective (oStr)
					local name = Nx.Split ("!", desc)

					if name == destNPCName then

--						Nx.prt ("DNPC %s", desc)

						return ((c1 - 35) * 221 + c2 - 35) / 10
					end
				else
					Nx.prt ("Travel: missing dnpc %s %s", destName, i)
				end
			end
		else
			Nx.prt ("Travel: missing snpc %s %s", srcName, i)
		end
	end

	return 0
end

function Nx.Travel:TaxiTimer()

	if UnitOnTaxi ("player") then

		Nx.Map.TaxiETA = max (0, self.TaxiTimeEnd - GetTime())

--		Nx.prt ("Taxi %s", Nx.Map.TaxiTime)
		return .5
	end
end

---------------------------------------------------------------------------------------
-- Called by map to save flight time
---------------------------------------------------------------------------------------

function Nx.Travel:TaxiSaveTime (tm)

	if self.TaxiSaveName then		-- Need?

		Nx.db.char.Travel["TaxiTime"][self.TaxiSaveName] = tm
		self.TaxiSaveName = false
	end
end

---------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------
-- Make shortest path
---------------------------------------------------------------------------------------
-- Straight line (flight master can shorten)
-- zone connection (FM can shorten)
--
-- C connection
-- P player
-- d destination
-- F flight master
--
--             ************
--  ***********            *
--  *          *            *
--  *  F        *            *
--  *          *             *
--  *    .....CCC....        *
--  *   .      *     ....    *
--  *  P       *         d   *
--  *   .      *       ..    *
--  *    .     *      F      *
--  *     .    *      |      *
--  *      .   *     /       *
--  *       .  *    /        *
--  *        .CC.F--         *
--  *          *             *
--  ************************
---------------------------------------------------------------------------------------

function Nx.Travel:MakePath (tracking, srcMapId, srcX, srcY, dstMapId, dstX, dstY, targetType)
	if not Nx.db.profile.Map.RouteUse then
		return
	end

	if UnitOnTaxi ("player") then
		return
	end

	local Map = Nx.Map
	local winfo = Map.MapWorldInfo

	local srcInfo = winfo[srcMapId] or {}
	srcMapId = srcInfo.EntryMId or srcMapId
	local dstInfo = winfo[dstMapId] or {}
	dstMapId = dstInfo.EntryMId or dstMapId

	local x = dstX - srcX
	local y = dstY - srcY
	local tarDist = (x * x + y * y) ^ .5

	if srcMapId == dstMapId and tarDist < 500 / 4.575 then		-- Short travel?
		return
	end

	local riding = Nx.Travel:GetRidingSkill()

	if IsAltKeyDown() then
--		Nx.prt ("Riding %s", riding)
		riding = 0
	end

	local cont1 = Map:IdToContZone (srcMapId)
	local cont2 = Map:IdToContZone (dstMapId)
	local lvl = UnitLevel ("player")

	self.FlyingMount = false

	if riding >= 225 then
		if cont1 == 1 or cont1 == 2 then
			self.FlyingMount = false
		elseif cont1 == 3 then
			self.FlyingMount = true
		elseif cont1 == 4 then
			self.FlyingMount = GetSpellInfo(self.WrathFlyName)
		end
	end

	local speed = 2 / 4.5
	if riding < 75 then
		speed = 1 / 4.5
	elseif riding < 150 then
		speed = 1.6 / 4.5
	elseif self.FlyingMount then
		speed = 2.5 / 4.5
	end

--	Nx.prt ("Tar %d, Spd %s, Fly %s, Cold:%s", tarDist * 4.575, speed, self.FlyingMount and 1 or 0)

	self.Speed = speed

	if cont1 == cont2 then

--		if srcMapId == 4003 or dstMapId == 4003 then		-- Dalaran?
--			return						-- Do a straight line
--		end

		if riding >= 300 and self.FlyingMount then		-- Epic flyer in flying area, don't route
			return
		end

		self.VisitedMapIds = {}

		local path = {}

		local node1 = {}
		node1.MapId = srcMapId
		node1.X = srcX
		node1.Y = srcY
		tinsert (path, node1)

		local node2 = {}
		node2.MapId = dstMapId
		node2.X = dstX
		node2.Y = dstY
		tinsert (path, node2)

--		Nx.prtCtrl ("** path nodes start %s to %s", srcMapId, dstMapId)

		local watchdog = 10

		repeat

			local nodeCnt = #path

			for n = 1, #path - 1 do

				local node1 = path[n]
				local node2 = path[n + 1]

				if not node1.NoSplit then

					if node1.MapId ~= node2.MapId then

						local conDist, con = self:FindConnection (node1.MapId, node1.X, node1.Y, node2.MapId, node2.X, node2.Y)
						local flyDist, fpath = self:FindFlight (node1.MapId, node1.X, node1.Y, node2.MapId, node2.X, node2.Y)

--						fpath = nil		-- Test

--						Nx.prtCtrl ("%d: con %s, fly %s", n, conDist or "nil", flyDist or "nil")

						if conDist and (not fpath or conDist < flyDist) then

--							Nx.prtCtrl (" con %s to %s", Nx.MapIdToName[node1.MapId], Nx.MapIdToName[node2.MapId])

							if con then
--								Nx.prtCtrl (" make con")

								local ang1 = math.deg (math.atan2 (srcX - con.StartX, srcY - con.StartY))
								local ang2 = math.deg (math.atan2 (srcX - con.EndX, srcY - con.EndY))
								local ang = abs (ang1 - ang2)
								ang = ang > 180 and 360 - ang or ang

--								Nx.prt ("Ang %s %s = %s", ang1, ang2, ang)

								if con.StartMapId ~= node1.MapId then		-- Open connection caused us to switch zones? No split
									node1.NoSplit = true
								end

								local name = format (L["Connection: %s to %s"], Map.MapWorldInfo[con.StartMapId].Name, Map.MapWorldInfo[con.EndMapId].Name)

								local node = {}
								node.NoSplit = true
								node.MapId = con.StartMapId
								node.X = con.StartX
								node.Y = con.StartY
								node.Name = name
								node.Tex = "Interface\\Icons\\Spell_Nature_FarSight"
								tinsert (path, n + 1, node)

								self.VisitedMapIds[con.StartMapId] = true

								if ang > 90 then
									node.Die = true
								end

								local node = {}
								node.MapId = con.EndMapId
								node.X = con.EndX
								node.Y = con.EndY
								node.Name = name
								node.Tex = "Interface\\Icons\\Spell_Nature_FarSight"
								tinsert (path, n + 2, node)
							end
						else
							if fpath then

--								Nx.prtCtrl (" flight %s to %s", node1.MapId, node2.MapId)

								tinsert (path, n + 1, fpath[1])
								tinsert (path, n + 2, fpath[2])
							end
						end

					else

						local directDist = ((node1.X - node2.X) ^ 2 + (node1.Y - node2.Y) ^ 2) ^ .5		-- Straight line distance
						local flyDist, fpath = self:FindFlight (node1.MapId, node1.X, node1.Y, node2.MapId, node2.X, node2.Y)

--						Nx.prtCtrl ("%d: direct %s, fly %s", n, directDist, flyDist or "nil")

						if fpath and flyDist < directDist then

--							Nx.prtCtrl (" flight in %s", node1.MapId)

							tinsert (path, n + 1, fpath[1])
							tinsert (path, n + 2, fpath[2])
						end
					end
				end
			end

			watchdog = watchdog - 1

			if watchdog < 0 then
--				Nx.prt ("path watchdog")
				break
			end

		until nodeCnt == #path

		-- Build path

--		Nx.prtCtrl ("path nodes %s", #path)

		for n = 2, #path - 1 do

			local node1 = path[n]
			if not node1.Die then

				local x, y = node1.X, node1.Y

				local t1 = {}
				t1.TargetType = targetType
				t1.TargetX1 = x
				t1.TargetY1 = y
				t1.TargetX2 = x
				t1.TargetY2 = y
				t1.TargetMX = x
				t1.TargetMY = y
				t1.TargetTex = node1.Tex
				t1.TargetName = node1.Name

				if node1.Flight then
					t1.Mode = "F"
				end

				tinsert (tracking, t1)
			end
		end
	end
end

function Nx.Travel:FindFlight (srcMapId, srcX, srcY, dstMapId, dstX, dstY)

	local t1Dist, t1Node, t1tex = self:FindClosest (srcMapId, srcX, srcY)

	if t1Node then

		local speed = self.Speed

		local t1Name = t1Node.Name
		local t1x, t1y = t1Node.WX, t1Node.WY

		local bt2Node
		local bestDist = 9999999999

		local distX = dstX - srcX
		local distY = dstY - srcY

--		for per = 0, 0, .2 do
		for per = 0, .5, .2 do

			local dx = dstX - distX * per		-- Push in towards middle
			local dy = dstY - distY * per

			local t2Dist, t2Node, t2tex = self:FindClosest (dstMapId, dx, dy)

			if t2Node then

				if t1Name == t2Node.Name then	-- Same flight master?
					break
				end

				local t2x, t2y = t2Node.WX, t2Node.WY

				local fltDist = ((t1x - t2x) ^ 2 + (t1y - t2y) ^ 2) ^ .5 * speed
				t2Dist = ((dstX - t2x) ^ 2 + (dstY - t2y) ^ 2) ^ .5	-- Real distance
				local travelDist = t1Dist + fltDist + t2Dist

--				Nx.prtCtrl ("F (%s %d) %d (%s %d)", t1Name, t1Dist * 4.575, fltDist * 4.575, t2Node.Name, t2Dist * 4.575)
--				Nx.prtCtrl ("F  %d %d, %d %d", t1x, t1y, t2x, t2y)
--				Nx.prtCtrl ("F %d, best %d, per %s", travelDist * 4.575, bestDist * 4.575, per)

				if bestDist > travelDist then
					bestDist = travelDist
					bt2Node = t2Node
				end
			end
		end

		if not bt2Node then
			return
		end

		local path = {}

		local name = format (L["Fly: %s to %s"], gsub (t1Node.Name, ".+!", ""), gsub (bt2Node.Name, ".+!", ""))
--		local name = format ("Fly: %s to %s", t1Node.Name, bt2Node.Name)

		local node1 = {}
		node1.NoSplit = true
		node1.MapId = t1Node.MapId
		node1.X = t1x
		node1.Y = t1y
		node1.Name = name

		node1.Tex = "Interface\\AddOns\\Carbonite\\Gfx\\Ability_mount_wyvern_01"
		tinsert (path, node1)

		local node2 = {}
		node2.Flight = true
		node2.MapId = bt2Node.MapId
		node2.X = bt2Node.WX
		node2.Y = bt2Node.WY
		node2.Name = name
		node2.Tex = "Interface\\AddOns\\Carbonite\\Gfx\\Ability_mount_wyvern_01"
		tinsert (path, node2)

		return bestDist, path
	end
end

---------------------------------------------------------------------------------------
-- Find closest
-- (mapid, world x, world y)
---------------------------------------------------------------------------------------

function Nx.Travel:FindClosest (mapId, posX, posY)
	local Map = Nx.Map

--	local cont = Map:GetContFromPos (posX, posY)
	local cont = Map:IdToContZone (mapId)

	local tr = self.Travel[cont]

	if not tr then		-- BGs?
		return
	end

	local taxiT = Nx.db.char.Travel.Taxi["Taxi"]

	local closeNode = false
	local closeDist = 9000111222333444

	for n, node in ipairs (tr) do
--	        Nx.prt(format("trying to go via %s", node.LocName))

		if taxiT[node.LocName] then
			local dist

			if mapId == node.MapId then

				dist = (node.WX - posX) ^ 2 + (node.WY - posY) ^ 2

			else
				dist = self:FindConnection (mapId, posX, posY, node.MapId, node.WX, node.WY)
				if not dist then
					dist = 9900111222333444
				else
					dist = dist ^ 2
				end
			end

			if dist < closeDist then
--				Nx.prt ("Close %s %d (%s %d %d)", node.Name, dist ^ .5, mapId, posX, posY)
				closeDist = dist
				closeNode = node
			end
		end
	end

	if closeNode then
		local tex = "Interface\\AddOns\\Carbonite\\Gfx\\Ability_mount_wyvern_01"
		return closeDist ^ .5, closeNode, tex
	end
end

---------------------------------------------------------------------------------------
-- Find best connection
---------------------------------------------------------------------------------------

function Nx.Travel:FindConnection (srcMapId, srcX, srcY, dstMapId, dstX, dstY, skipIndirect)

	if self.FlyingMount then					-- Can fly?
		return ((srcX - dstX) ^ 2 + (srcY - dstY) ^ 2) ^ .5	-- Use straight line distance
	end

	local winfo = Nx.Map.MapWorldInfo

	local srcT = winfo[srcMapId]
	if not srcT or not srcT.Connections then
		return
	end

	local zcon = srcT.Connections[dstMapId]

	if zcon and not self.VisitedMapIds[dstMapId] then

--		Nx.prtCtrl ("C %s to %s #%s", Nx.MapIdToName[srcMapId], Nx.MapIdToName[dstMapId], #zcon)

		if #zcon == 0 then
			return ((srcX - dstX) ^ 2 + (srcY - dstY) ^ 2) ^ .5	-- Open connection. Use straight line distance
		end

		local closeCon
		local closeDist = 9000111222333444

		for n, con in ipairs (zcon) do

			local dist1 = ((con.StartX - srcX) ^ 2 + (con.StartY - srcY) ^ 2) ^ .5
			local dist2 = ((con.EndX - dstX) ^ 2 + (con.EndY - dstY) ^ 2) ^ .5
			local d = dist1 + con.Dist + dist2

			if d < closeDist then
				closeCon = con
				closeDist = d
			end
		end

		return closeDist, closeCon

	elseif not skipIndirect then		-- No direct connection

		local closeCon
		local closeDist = 9000111222333444

		for mapId, zcon in pairs (srcT.Connections) do

			if not self.VisitedMapIds[mapId] then

--				Nx.prtCtrl ("C %s (%s to %s) #%s", Nx.MapIdToName[mapId], Nx.MapIdToName[srcMapId], Nx.MapIdToName[dstMapId], #zcon)

				if #zcon == 0 then

					local d, con = self:FindConnection (mapId, srcX, srcY, dstMapId, dstX, dstY, true)
					if d and d < closeDist then
						closeDist = d
						closeCon = con
					end

				else
					for n, con in ipairs (zcon) do

						local dist1 = ((con.StartX - srcX) ^ 2 + (con.StartY - srcY) ^ 2) ^ .5
						local dist2 = ((con.EndX - dstX) ^ 2 + (con.EndY - dstY) ^ 2) ^ .5

						local penalty = winfo[mapId].Connections[dstMapId] and 1 or 2

						local d = dist1 + con.Dist + dist2 * penalty		-- Penalty for no direct connection

						if d < closeDist then
							closeDist = d
							closeCon = con
						end
					end
				end
			end
		end

		if closeCon then

			local d, con = self:FindConnection (closeCon.EndMapId, closeCon.EndX, closeCon.EndY, dstMapId, dstX, dstY, true)	-- Find next connection
			if con then

--				Nx.prtCtrl ("C+ %s %d (%s to %s)", Nx.MapIdToName[srcMapId], d, Nx.MapIdToName[con.StartMapId], Nx.MapIdToName[con.EndMapId])

				closeDist = closeDist + d	-- Add 2nd connection. Fixes issues like going from Org to areas in Ashenvale near Org, which has no direct connection
			end
		end

--[[
		if closeCon then
			Nx.prtCtrl ("C- %s %d (%s to %s)", Nx.MapIdToName[srcMapId], closeDist, Nx.MapIdToName[closeCon.StartMapId], Nx.MapIdToName[closeCon.EndMapId])
		end
--]]

		return closeDist, closeCon
	end
end

---------------------------------------------------------------------------------------

function Nx.Travel:DebugCaptureTaxi()

	local num = NumTaxiNodes()

	if num > 0 then

--		NxData.TaxiCap = {}

		local map = Nx.Map:GetMap (1)
		local mid = Nx.Map:GetRealMapId()

		local cap = Nx.db.char.TaxiCap or {}
		Nx.db.char.TaxiCap = cap
		local d = {}
		cap[mid] = d

		for n = 1, num do
			local name = TaxiNodeName (n)
			local typ = TaxiNodeGetType (n)		-- NONE, CURRENT, REACHABLE, DISTANT
			local x, y = TaxiNodePosition (n)
			Nx.prt ("Taxi #%s %s, %s %f %f", n, name, typ, x, y)
			tinsert (d, name)
		end
--[[
		local dest = 6

		TaxiNodeSetCurrent (dest)

		for n = 1, GetNumRoutes (dest) do
			local x = TaxiGetDestX (dest, n)
			local y = TaxiGetDestY (dest, n)

			Nx.prt (" #%s %s %s", n, x, y)

			local match

			for n2 = 1, num do
				local name = TaxiNodeName (n2)
				local x2, y2 = TaxiNodePosition (n2)
				local dist = (x - x2) ^ 2 + (y - y2) ^ 2
--				Nx.prt (" %s %s", name, dist)
				if dist < .000001 then
					match = n2
					Nx.prt (" #%s %s %s %s %s %s", n, n2, name, dist, x, y)
					break
				end
			end
		end
--]]
	end
end

function Nx.Travel:GetRidingSkill()
	if not IsFlyableArea() then
		return 0
	end

	local RidingSkillName = L["Riding"]
	local RidingSkill = 0
        for skillIndex = 1, GetNumSkillLines() do
		PlayerSkill = {GetSkillLineInfo(skillIndex)}
		if PlayerSkill[1] == RidingSkillName then
			RidingSkill = PlayerSkill[4]
                       	break
		end
	end
	return RidingSkill
end

---------------------------------------------------------------------------------------
-- EOF
