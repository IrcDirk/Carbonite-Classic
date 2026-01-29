---------------------------------------------------------------------------------------
-- NxTravel - Travel and Flight Path Code
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

---------------------------------------------------------------------------------------
-- Module Description:
-- The Travel module handles pathfinding and flight path calculations. It provides:
--   - Flight path ETA calculations
--   - Zone connection detection
--   - Optimal route calculation between two points
--   - Flight master location tracking
--   - Integration with the taxi/flight master system
---------------------------------------------------------------------------------------

-- Localization library reference
local L = LibStub("AceLocale-3.0"):GetLocale("Carbonite")

---------------------------------------------------------------------------------------
-- Travel System Initialization
---------------------------------------------------------------------------------------

local DoesSpellExist = C_Spell.DoesSpellExist or DoesSpellExist

--- Initialize the travel system
-- Sets up taxi hooks, flight master data, and flying skill detection
function Nx.Travel:Init()
    -- Hook the TakeTaxiNode function to track flight times
    self.OrigTakeTaxiNode = TakeTaxiNode
    TakeTaxiNode = self.TakeTaxiNode

    -- Initialize travel data structure for each continent
    local tr = {}
    for n = 1, Nx.Map.ContCnt do
        tr[n] = {}
    end
    tr[99] = {}  -- Special container for cross-continent travel
    self.Travel = tr

    -- Load flight master locations from guide data
    self:Add(L["Flight Master"])

    -- Cache flying skill spell names for each expansion
    -- These are used to determine if the player can fly in specific zones
    self.WrathFlyName    = C_Spell.GetSpellInfo(54197)  and C_Spell.GetSpellInfo(54197).name or ""  -- Cold Weather Flying (Northrend)
    self.AzerothFlyName  = C_Spell.GetSpellInfo(90267)  and C_Spell.GetSpellInfo(90267).name or ""  -- Flight Master's License (Azeroth)
    self.PandariaFlyName = C_Spell.GetSpellInfo(115913) and C_Spell.GetSpellInfo(115913).name or "" -- Wisdom of the Four Winds
    self.DraenorFlyName  = C_Spell.GetSpellInfo(191645) and C_Spell.GetSpellInfo(191645).name or "" -- Draenor Pathfinder
    self.LegionFlyName   = C_Spell.GetSpellInfo(233368) and C_Spell.GetSpellInfo(233368).name or "" -- Broken Isles Pathfinder
    self.BattleFlyName   = C_Spell.GetSpellInfo(278833) and C_Spell.GetSpellInfo(278833).name or "" -- Battle for Azeroth Pathfinder
    self.SkyRidingName   = C_Spell.GetSpellInfo(376027) and C_Spell.GetSpellInfo(376027).name or "" -- SkyRiding
end

---------------------------------------------------------------------------------------
-- Flight Master Data Loading
---------------------------------------------------------------------------------------

--- Add travel points of a specific type from guide data
-- Parses NPC data to extract flight master locations and adds them to the travel network
-- @param typ The type of travel point to add (e.g., "Flight Master")
function Nx.Travel:Add(typ)
    local Map = Nx.Map

    -- Determine which faction's NPCs to hide (opposite of player's faction)
    local hideFac = UnitFactionGroup("player") == "Horde" and 1 or 2

    -- Iterate through guide data for this travel type
    for a, b in pairs(Nx.GuideData[typ]) do
        if a ~= "Mode" then
            -- Parse multiple entries separated by |
            local ext = { Nx.Split("|", b) }

            for c, d in pairs(ext) do
                if d then
                    -- Parse individual entry: side, x, y, level, NPC ID
                    local side, x, y, level, num = Nx.Split(",", d)

                    -- Get NPC details from NPC database
                    local fac, name, locName, zone, x, y, level = Nx.Split("|", Nx.NPCData[tonumber(num)])
                    fac, zone, x, y = tonumber(fac), tonumber(zone), tonumber(x), tonumber(y)

                    -- Get continent from zone data
                    local _, _, _, _, cont, _, _ = Nx.Split("|", Nx.Zones[tonumber(zone)])
                    local tdata = self.Travel[tonumber(cont)]

                    -- Only add if this NPC is for player's faction
                    if fac ~= hideFac then
                        local mapId = zone
                        local wx, wy = Map:GetWorldPos(mapId, x, y)

                        -- Create travel node
                        local node = {}
                        node.Name = locName
                        node.LocName = locName    -- Localized name
                        node.MapId = mapId
                        node.WX = wx              -- World X coordinate
                        node.WY = wy              -- World Y coordinate

                        tinsert(tdata, node)
                    end
                end
            end
        end
    end
end

---------------------------------------------------------------------------------------
-- Taxi Map Events
---------------------------------------------------------------------------------------

--- Called when the taxi/flight path map is opened
-- Triggers capturing of available taxi nodes
function Nx.Travel.OnTaximap_opened()
    local self = Nx.Travel
    self:CaptureTaxi()
end

---------------------------------------------------------------------------------------
-- Taxi Node Capture
---------------------------------------------------------------------------------------

--- Record which taxi locations the player can use
-- Scans all taxi nodes on the current map and records their availability
function Nx.Travel:CaptureTaxi()
    self.TaxiNameStart = false

    local taxiT = Nx.db.char.Travel.Taxi["Taxi"]

    -- Iterate through all taxi nodes on the current map
    for n = 1, NumTaxiNodes() do
        local locName = TaxiNodeName(n)
        local locStatus = TaxiNodeGetType(n)

        -- Record whether node is reachable or not
        if locStatus == "CURRENT" or locStatus == "REACHABLE" then
            taxiT[locName] = true
        else
            taxiT[locName] = false
        end

        -- Track the starting node (player's current location)
        if TaxiNodeGetType(n) == "CURRENT" then
            self.TaxiNameStart = locName

            if Nx.db.profile.Debug.DebugMap then
                local name = Nx.Map.Guide:FindTaxis(locName)
                Nx.prt("Taxi current %s (%s)", name or "nil", locName)
            end
        end
    end
end

---------------------------------------------------------------------------------------
-- Taxi System Hook
---------------------------------------------------------------------------------------

--- Hook function for TakeTaxiNode
-- Called when player takes a flight path, calculates ETA
-- @param node The taxi node index being traveled to
function Nx.Travel.TakeTaxiNode(node)
    local self = Nx.Travel
    local map = Nx.Map

    -- Store destination name
    map.TaxiName = TaxiNodeName(node)

    -- Find destination coordinates
    local name, x, y = Nx.Map.Guide:FindTaxis(map.TaxiName)
    map.TaxiX = x
    map.TaxiY = y

    Nx.Map.TaxiETA = false

    -- Calculate expected travel time
    local tm = self:TaxiCalcTime(node)

    if tm > 0 and self.TaxiNameStart then
        -- Set up timer for ETA tracking
        self.TaxiTimeEnd = GetTime() + tm
        TaxiTime = Nx:ScheduleTimer(self.TaxiTimer, 1, self)
    end

    if Nx.db.profile.Debug.DebugMap then
        Nx.prt("Taxi %s (%s) %.2f secs, node %d, %s %s", name or "nil", map.TaxiName, tm, node, x or "?", y or "?")
    end

    -- Call original function to actually take the flight
    Nx.Travel.OrigTakeTaxiNode(node)
end

---------------------------------------------------------------------------------------
-- Flight Time Calculation
---------------------------------------------------------------------------------------

--- Calculate total flight time to destination
-- Sums up individual route segments to get total flight duration
-- @param dest The destination taxi node index
-- @return Total flight time in seconds
function Nx.Travel:TaxiCalcTime(dest)
    local tm = 0
    local num = NumTaxiNodes()

    if num > 0 then
        local rCnt = GetNumRoutes(dest)

        -- Sum up time for each route segment
        for n = 1, rCnt do
            -- Get source position for this segment
            local x = TaxiGetSrcX(dest, n)
            local y = TaxiGetSrcY(dest, n)
            local srcNode = self:TaxiFindNodeFromRouteXY(x, y)

            -- Get destination position for this segment
            local x = TaxiGetDestX(dest, n)
            local y = TaxiGetDestY(dest, n)
            local destNode = self:TaxiFindNodeFromRouteXY(x, y)

            if srcNode and destNode then
                local srcName = TaxiNodeName(srcNode)
                local destName = TaxiNodeName(destNode)

                -- Look up time for this route segment
                local t = self:TaxiFindConnectionTime(srcName, destName)
                local routeName = srcName .. "#" .. destName

                if t == 0 then
                    -- Check if we have saved time data
                    local tt = Nx.db.char.Travel["TaxiTime"]
                    t = tt[routeName]

                    if not t then
                        if Nx.db.profile.Debug.DebugMap then
                            Nx.prt(" No taxi data %s to %s", srcName, destName)
                        end

                        -- Mark for saving if this is a single-segment route
                        if rCnt == 1 then
                            self.TaxiSaveName = routeName
                        end

                        return 0
                    end
                end

                tm = tm + t

                if Nx.db.profile.Debug.DebugMap then
                    Nx.prt(" #%s %s to %s, %s secs", n, srcName, destName, t)
                end
            end
        end
    end

    return tm
end

---------------------------------------------------------------------------------------
-- Taxi Node Lookup
---------------------------------------------------------------------------------------

--- Find a taxi node by its route position
-- Searches for a taxi node that matches the given route coordinates
-- @param x X coordinate from route data
-- @param y Y coordinate from route data
-- @return Node index if found, nil otherwise
function Nx.Travel:TaxiFindNodeFromRouteXY(x, y)
    for n = 1, NumTaxiNodes() do
        local x2, y2 = TaxiNodePosition(n)
        local dist = (x - x2) ^ 2 + (y - y2) ^ 2

        -- Use small epsilon for floating point comparison
        if dist < .000001 then
            return n
        end
    end
end

---------------------------------------------------------------------------------------
-- Flight Connection Time Lookup
---------------------------------------------------------------------------------------

--- Find the flight time between two connected taxi nodes
-- Searches the flight connection database for the time between two NPCs
-- @param srcName Source taxi node name
-- @param destName Destination taxi node name
-- @return Flight time in seconds, or 0 if not found
function Nx.Travel:TaxiFindConnectionTime(srcName, destName)
    local srcNPCName, x, y = Nx.Map.Guide:FindTaxis(srcName)
    local destNPCName, x, y = Nx.Map.Guide:FindTaxis(destName)

    -- Flight connection data format (6 bytes per entry):
    -- aa = index of start NPC (base 221 encoded)
    -- bb = index of end NPC (base 221 encoded)
    -- cc = flight time in 10ths of a second (base 221 encoded)

    local conn = Nx.FlightConnection

    for n = 1, #conn, 6 do
        local a1, a2, b1, b2, c1, c2 = strbyte(conn, n, n + 5)

        -- Decode source NPC index
        local i = (a1 - 35) * 221 + a2 - 35
        local npc = Nx.NPCData[i]

        if npc then
            local oStr = strsub(npc, 2)
            local desc, zone, loc = Nx.Map:UnpackObjective(oStr)
            local name = Nx.Split("!", desc)

            if name == srcNPCName then
                -- Decode destination NPC index
                local i = (b1 - 35) * 221 + b2 - 35
                local npc = Nx.NPCData[i]

                if npc then
                    local oStr = strsub(npc, 2)
                    local desc, zone, loc = Nx.Map:UnpackObjective(oStr)
                    local name = Nx.Split("!", desc)

                    if name == destNPCName then
                        -- Decode and return flight time (convert from 10ths of seconds)
                        return ((c1 - 35) * 221 + c2 - 35) / 10
                    end
                else
                    Nx.prt("Travel: missing dnpc %s %s", destName, i)
                end
            end
        else
            Nx.prt("Travel: missing snpc %s %s", srcName, i)
        end
    end

    return 0
end

---------------------------------------------------------------------------------------
-- Flight Timer
---------------------------------------------------------------------------------------

--- Timer callback during taxi flight
-- Updates the ETA display while player is on a taxi
-- @return Timer interval, or nil to stop timer
function Nx.Travel:TaxiTimer()
    if UnitOnTaxi("player") then
        -- Update remaining time
        Nx.Map.TaxiETA = max(0, self.TaxiTimeEnd - GetTime())
        return .5  -- Continue timer every 0.5 seconds
    end
    -- Return nil to stop timer when no longer on taxi
end

---------------------------------------------------------------------------------------
-- Flight Time Saving
---------------------------------------------------------------------------------------

--- Save discovered flight time for a route segment
-- Called when we learn a new flight time that wasn't in the database
-- @param tm The flight time in seconds
function Nx.Travel:TaxiSaveTime(tm)
    if self.TaxiSaveName then
        Nx.db.char.Travel["TaxiTime"][self.TaxiSaveName] = tm
        self.TaxiSaveName = false
    end
end

---------------------------------------------------------------------------------------
-- Path Finding System
---------------------------------------------------------------------------------------
-- The pathfinding system creates optimal routes between two points, considering:
-- - Zone connections (portals, roads, etc.)
-- - Flight masters
-- - Flying ability
--
-- Visual representation of pathfinding:
--             ************
--  ***********            *
--  *          *            *
--  *  F        *            *     F = Flight Master
--  *          *             *     C = Zone Connection
--  *    .....CCC....        *     P = Player
--  *   .      *     ....    *     d = Destination
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

--- Create an optimal path between two points
-- Analyzes zone connections and flight paths to find the best route
-- @param tracking Table to store path waypoints
-- @param srcMapId Source map ID
-- @param srcX Source world X coordinate
-- @param srcY Source world Y coordinate
-- @param dstMapId Destination map ID
-- @param dstX Destination world X coordinate
-- @param dstY Destination world Y coordinate
-- @param targetType Type of target for waypoint display
function Nx.Travel:MakePath(tracking, srcMapId, srcX, srcY, dstMapId, dstX, dstY, targetType)
    -- Check if routing is enabled
    if not Nx.db.profile.Map.RouteUse then
        return
    end

    -- Don't calculate paths while on a taxi
    if UnitOnTaxi("player") then
        return
    end

    local Map = Nx.Map
    local winfo = Map.MapWorldInfo

    -- Handle instance entry points
    local srcInfo = winfo[srcMapId] or {}
    srcMapId = srcInfo.EntryMId or srcMapId
    local dstInfo = winfo[dstMapId] or {}
    dstMapId = dstInfo.EntryMId or dstMapId

    -- Calculate straight-line distance to target
    local x = dstX - srcX
    local y = dstY - srcY
    local tarDist = (x * x + y * y) ^ .5

    -- Skip routing for short distances (less than ~110 yards)
    if srcMapId == dstMapId and tarDist < 500 / 4.575 then
        return
    end

    -- Get player's riding skill to determine travel speed
    local riding = Nx.Travel:GetRidingSkill()

    -- Alt key overrides flying for testing
    if IsAltKeyDown() then
        riding = 0
    end

    local cont1 = Map:IdToContZone(srcMapId)
    local cont2 = Map:IdToContZone(dstMapId)
    local lvl = UnitLevel("player")

    -- Determine if player can fly in this zone
    self.FlyingMount = false

    if riding >= 225 then
        if cont1 == 1 or cont1 == 2 or cont1 == 5 then
            -- Kalimdor, Eastern Kingdoms, or Maelstrom
            if DoesSpellExist(90267) then
                self.FlyingMount = self.AzerothFlyName
            end
        elseif cont1 == 3 then
            -- Outland - always flyable
            self.FlyingMount = true
        elseif cont1 == 4 then
            -- Northrend
            if DoesSpellExist(54197) then
                self.FlyingMount = self.WrathFlyName
            end
        elseif cont1 == 6 then
            -- Pandaria
            if DoesSpellExist(15913) then
                self.FlyingMount = self.PandariaFlyName
            end
        elseif cont1 == 7 then
            local _,_,_,complete = GetAchievementInfo(10018)
            if complete then
                if DoesSpellExist(191645) then
                    self.FlyingMount = self.DraenorFlyName
                end
            end
        elseif cont1 == 8 then
            local _,_,_,complete = GetAchievementInfo(11446)
            if complete then
                if DoesSpellExist(233368) then
                    self.FlyingMount = self.LegionFlyName
                end
            end
        elseif cont1 == 11 then
            local _,_,_,complete = GetAchievementInfo(13250)
            if complete then
                if DoesSpellExist(278833) then
                    self.FlyingMount = self.BattleFlyName
                end
            end
        end
    end

    if C_QuestLog.IsQuestFlaggedCompleted(68795) then
        self.FlyingMount = self.SkyRidingName
    end

    -- Calculate travel speed based on riding skill
    local speed = 2 / 4.5      -- Default: 100% mount speed
    if riding < 75 then
        speed = 1 / 4.5        -- No mount: walking speed
    elseif riding < 150 then
        speed = 1.6 / 4.5      -- Slow mount: 60% speed
    elseif self.FlyingMount then
        speed = 2.5 / 4.5      -- Flying mount: 150% speed
    end

    self.Speed = speed

    -- Only calculate paths within the same continent
    if cont1 == cont2 then
        -- Epic flyers in flyable areas don't need routing
        if riding >= 300 and self.FlyingMount then
            return
        end

        -- Track visited map IDs to prevent infinite loops
        self.VisitedMapIds = {}

        -- Initialize path with start and end nodes
        local path = {}

        local node1 = {}
        node1.MapId = srcMapId
        node1.X = srcX
        node1.Y = srcY
        tinsert(path, node1)

        local node2 = {}
        node2.MapId = dstMapId
        node2.X = dstX
        node2.Y = dstY
        tinsert(path, node2)

        -- Iteratively split path segments until no more splits possible
        local watchdog = 10

        repeat
            local nodeCnt = #path

            for n = 1, #path - 1 do
                local node1 = path[n]
                local node2 = path[n + 1]

                if not node1.NoSplit then
                    if node1.MapId ~= node2.MapId then
                        -- Different zones: look for connections or flights
                        local conDist, con = self:FindConnection(node1.MapId, node1.X, node1.Y, node2.MapId, node2.X, node2.Y)
                        local flyDist, fpath = self:FindFlight(node1.MapId, node1.X, node1.Y, node2.MapId, node2.X, node2.Y)

                        if conDist and (not fpath or conDist < flyDist) then
                            -- Zone connection is faster than flying
                            if con then
                                -- Calculate angle to determine if we should skip this connection
                                local ang1 = math.deg(math.atan2(srcX - con.StartX, srcY - con.StartY))
                                local ang2 = math.deg(math.atan2(srcX - con.EndX, srcY - con.EndY))
                                local ang = abs(ang1 - ang2)
                                ang = ang > 180 and 360 - ang or ang

                                if con.StartMapId ~= node1.MapId then
                                    node1.NoSplit = true
                                end

                                local name = format(L["Connection: %s to %s"], Map.MapWorldInfo[con.StartMapId].Name, Map.MapWorldInfo[con.EndMapId].Name)

                                -- Insert connection start point
                                local node = {}
                                node.NoSplit = true
                                node.MapId = con.StartMapId
                                node.X = con.StartX
                                node.Y = con.StartY
                                node.Name = name
                                node.Tex = "Interface\\Icons\\Spell_Nature_FarSight"
                                tinsert(path, n + 1, node)

                                self.VisitedMapIds[con.StartMapId] = true

                                if ang > 90 then
                                    node.Die = true
                                end

                                -- Insert connection end point
                                local node = {}
                                node.MapId = con.EndMapId
                                node.X = con.EndX
                                node.Y = con.EndY
                                node.Name = name
                                node.Tex = "Interface\\Icons\\Spell_Nature_FarSight"
                                tinsert(path, n + 2, node)
                            end
                        else
                            -- Flight path is faster
                            if fpath then
                                tinsert(path, n + 1, fpath[1])
                                tinsert(path, n + 2, fpath[2])
                            end
                        end
                    else
                        -- Same zone: check if flight is faster than direct travel
                        local directDist = ((node1.X - node2.X) ^ 2 + (node1.Y - node2.Y) ^ 2) ^ .5
                        local flyDist, fpath = self:FindFlight(node1.MapId, node1.X, node1.Y, node2.MapId, node2.X, node2.Y)

                        if fpath and flyDist < directDist then
                            tinsert(path, n + 1, fpath[1])
                            tinsert(path, n + 2, fpath[2])
                        end
                    end
                end
            end

            watchdog = watchdog - 1
            if watchdog < 0 then
                break
            end
        until nodeCnt == #path

        -- Build final path waypoints (skip first and last nodes)
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

                tinsert(tracking, t1)
            end
        end
    end
end

---------------------------------------------------------------------------------------
-- Flight Path Finding
---------------------------------------------------------------------------------------

--- Find the best flight path between two points
-- Searches for flight masters near source and destination to create a flight route
-- @param srcMapId Source map ID
-- @param srcX Source world X coordinate
-- @param srcY Source world Y coordinate
-- @param dstMapId Destination map ID
-- @param dstX Destination world X coordinate
-- @param dstY Destination world Y coordinate
-- @return Best distance and path table if found
function Nx.Travel:FindFlight(srcMapId, srcX, srcY, dstMapId, dstX, dstY)
    -- Find closest flight master to source
    local t1Dist, t1Node, t1tex = self:FindClosest(srcMapId, srcX, srcY)

    if t1Node then
        local speed = self.Speed

        local t1Name = t1Node.Name
        local t1x, t1y = t1Node.WX, t1Node.WY

        local bt2Node
        local bestDist = 9999999999

        local distX = dstX - srcX
        local distY = dstY - srcY

        -- Try different points along the route to find best destination FM
        for per = 0, .5, .2 do
            local dx = dstX - distX * per
            local dy = dstY - distY * per

            local t2Dist, t2Node, t2tex = self:FindClosest(dstMapId, dx, dy)

            if t2Node then
                -- Skip if same flight master
                if t1Name == t2Node.Name then
                    break
                end

                local t2x, t2y = t2Node.WX, t2Node.WY

                -- Calculate total travel distance
                local fltDist = ((t1x - t2x) ^ 2 + (t1y - t2y) ^ 2) ^ .5 * speed
                t2Dist = ((dstX - t2x) ^ 2 + (dstY - t2y) ^ 2) ^ .5
                local travelDist = t1Dist + fltDist + t2Dist

                if bestDist > travelDist then
                    bestDist = travelDist
                    bt2Node = t2Node
                end
            end
        end

        if not bt2Node then
            return
        end

        -- Build flight path
        local path = {}
        local name = format(L["Fly: %s to %s"], gsub(t1Node.Name, ".+!", ""), gsub(bt2Node.Name, ".+!", ""))

        -- Source flight master node
        local node1 = {}
        node1.NoSplit = true
        node1.MapId = t1Node.MapId
        node1.X = t1x
        node1.Y = t1y
        node1.Name = name
        node1.Tex = "Interface\\AddOns\\Carbonite\\Gfx\\Ability_mount_wyvern_01"
        tinsert(path, node1)

        -- Destination flight master node
        local node2 = {}
        node2.Flight = true
        node2.MapId = bt2Node.MapId
        node2.X = bt2Node.WX
        node2.Y = bt2Node.WY
        node2.Name = name
        node2.Tex = "Interface\\AddOns\\Carbonite\\Gfx\\Ability_mount_wyvern_01"
        tinsert(path, node2)

        return bestDist, path
    end
end

---------------------------------------------------------------------------------------
-- Closest Flight Master Search
---------------------------------------------------------------------------------------

--- Find the closest accessible flight master to a position
-- @param mapId Map ID to search from
-- @param posX World X coordinate
-- @param posY World Y coordinate
-- @return Distance, node data, and texture if found
function Nx.Travel:FindClosest(mapId, posX, posY)
    local Map = Nx.Map

    local cont = Map:IdToContZone(mapId)
    local tr = self.Travel[cont]

    if not tr then
        return  -- No travel data for this continent (e.g., battlegrounds)
    end

    local taxiT = Nx.db.char.Travel.Taxi["Taxi"]

    local closeNode = false
    local closeDist = 9000111222333444

    for n, node in ipairs(tr) do
        -- Only consider flight masters the player can use
        if taxiT[node.LocName] then
            local dist

            if mapId == node.MapId then
                -- Same zone: direct distance
                dist = (node.WX - posX) ^ 2 + (node.WY - posY) ^ 2
            else
                -- Different zone: use connection distance
                dist = self:FindConnection(mapId, posX, posY, node.MapId, node.WX, node.WY)
                if not dist then
                    dist = 9900111222333444
                else
                    dist = dist ^ 2
                end
            end

            if dist < closeDist then
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
-- Zone Connection Finding
---------------------------------------------------------------------------------------

--- Find the best zone connection between two points
-- Searches for portals, roads, or other connections between zones
-- @param srcMapId Source map ID
-- @param srcX Source world X coordinate
-- @param srcY Source world Y coordinate
-- @param dstMapId Destination map ID
-- @param dstX Destination world X coordinate
-- @param dstY Destination world Y coordinate
-- @param skipIndirect If true, don't search for indirect connections
-- @return Distance and connection data if found
function Nx.Travel:FindConnection(srcMapId, srcX, srcY, dstMapId, dstX, dstY, skipIndirect)
    -- If player can fly, use straight line distance
    if self.FlyingMount then
        return ((srcX - dstX) ^ 2 + (srcY - dstY) ^ 2) ^ .5
    end

    local winfo = Nx.Map.MapWorldInfo

    local srcT = winfo[srcMapId]
    if not srcT or not srcT.Connections then
        return
    end

    -- Check for direct connection to destination
    local zcon = srcT.Connections[dstMapId]

    if zcon and not self.VisitedMapIds[dstMapId] then
        if #zcon == 0 then
            -- Open connection (no specific points)
            return ((srcX - dstX) ^ 2 + (srcY - dstY) ^ 2) ^ .5
        end

        -- Find closest connection point
        local closeCon
        local closeDist = 9000111222333444

        for n, con in ipairs(zcon) do
            local dist1 = ((con.StartX - srcX) ^ 2 + (con.StartY - srcY) ^ 2) ^ .5
            local dist2 = ((con.EndX - dstX) ^ 2 + (con.EndY - dstY) ^ 2) ^ .5
            local d = dist1 + con.Dist + dist2

            if d < closeDist then
                closeCon = con
                closeDist = d
            end
        end

        return closeDist, closeCon

    elseif not skipIndirect then
        -- No direct connection: search for indirect routes
        local closeCon
        local closeDist = 9000111222333444

        for mapId, zcon in pairs(srcT.Connections) do
            if not self.VisitedMapIds[mapId] then
                if #zcon == 0 then
                    -- Open connection: recursively search
                    local d, con = self:FindConnection(mapId, srcX, srcY, dstMapId, dstX, dstY, true)
                    if d and d < closeDist then
                        closeDist = d
                        closeCon = con
                    end
                else
                    -- Specific connection points
                    for n, con in ipairs(zcon) do
                        local dist1 = ((con.StartX - srcX) ^ 2 + (con.StartY - srcY) ^ 2) ^ .5
                        local dist2 = ((con.EndX - dstX) ^ 2 + (con.EndY - dstY) ^ 2) ^ .5

                        -- Add penalty for zones without direct connection to destination
                        local penalty = winfo[mapId].Connections[dstMapId] and 1 or 2
                        local d = dist1 + con.Dist + dist2 * penalty

                        if d < closeDist then
                            closeDist = d
                            closeCon = con
                        end
                    end
                end
            end
        end

        if closeCon then
            -- Find the next connection in the chain
            local d, con = self:FindConnection(closeCon.EndMapId, closeCon.EndX, closeCon.EndY, dstMapId, dstX, dstY, true)
            if con then
                closeDist = closeDist + d
            end
        end

        return closeDist, closeCon
    end
end

---------------------------------------------------------------------------------------
-- Debug Functions
---------------------------------------------------------------------------------------

--- Debug function to capture and print taxi node data
-- Used for development and data gathering
function Nx.Travel:DebugCaptureTaxi()
    local num = NumTaxiNodes()

    if num > 0 then
        local map = Nx.Map:GetMap(1)
        local mid = Nx.Map:GetRealMapId()

        local cap = Nx.db.char.TaxiCap or {}
        Nx.db.char.TaxiCap = cap
        local d = {}
        cap[mid] = d

        for n = 1, num do
            local name = TaxiNodeName(n)
            local typ = TaxiNodeGetType(n)    -- NONE, CURRENT, REACHABLE, DISTANT
            local x, y = TaxiNodePosition(n)
            Nx.prt("Taxi #%s %s, %s %f %f", n, name, typ, x, y)
            tinsert(d, name)
        end
    end
end

---------------------------------------------------------------------------------------
-- Riding Skill Detection
---------------------------------------------------------------------------------------

--- Get the player's riding skill level
-- Determines the highest riding skill the player has learned
-- @return Riding skill level (0, 75, 150, 225, 300, or 375)
function Nx.Travel:GetRidingSkill()
    -- Can only fly in flyable areas
    if not IsFlyableArea() then
        return 0
    end

    local RidingSkill = 0

    if Nx.OldRidingSkill then
	local RidingSkillName = L["Riding"]
        for skillIndex = 1, GetNumSkillLines() do
		PlayerSkill = {GetSkillLineInfo(skillIndex)}
		if PlayerSkill[1] == RidingSkillName then
			RidingSkill = PlayerSkill[4]
                       	break
		end
	end
	return RidingSkill
    else
    -- Riding skill spell IDs and their corresponding skill levels
        local RidingSpells = {
            [75]  = 33389, -- Apprentice Riding
            [150] = 33392, -- Journeyman Riding
            [225] = 34092, -- Expert Riding
            [300] = 34093, -- Artisan Riding
            [375] = 90265, -- Master Riding
        }

    -- Check each riding skill from lowest to highest
        for skill, spellId in pairs(RidingSpells) do
            if C_Spell.GetSpellInfo(spellId) then
                RidingSkill = skill
                break
            end
        end
    end
    return RidingSkill
end

---------------------------------------------------------------------------------------
-- EOF
---------------------------------------------------------------------------------------
