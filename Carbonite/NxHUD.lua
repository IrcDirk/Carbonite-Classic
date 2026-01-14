---------------------------------------------------------------------------------------
-- NxHUD - HUD (Heads-Up Display) Code
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
-- The HUD (Heads-Up Display) module provides a directional arrow and distance
-- indicator that guides players to their current waypoint/target. It displays:
--   - A rotating arrow pointing toward the destination
--   - Distance in yards to the target
--   - Estimated time of arrival (ETA) based on current movement speed
--   - Target name/description
---------------------------------------------------------------------------------------

-- Localization library reference
local L = LibStub("AceLocale-3.0"):GetLocale("Carbonite")

---------------------------------------------------------------------------------------
-- HUD Initialization
---------------------------------------------------------------------------------------

--- Initialize the HUD module
-- Sets up available arrow texture names and opens the HUD window
function Nx.HUD:Init()
    -- Available arrow texture styles: default, Chip, Gloss, Glow, Neon
    Nx.HUD.TexNames = { "", "Chip", "Gloss", "Glow", "Neon" }

    Nx.HUD:Open()
end

---------------------------------------------------------------------------------------
-- HUD Window Management
---------------------------------------------------------------------------------------

--- Open and display the HUD window
-- Creates the HUD if it doesn't exist, then shows it
function Nx.HUD:Open()
    if not self.Created then
        self:Create()
        self.Created = true
    end

    local inst = self
    inst.Win:Show()
end

--- Create the HUD window and all its UI elements
-- Sets up the window, arrow frame, target button, and context menu
function Nx.HUD:Create()
    local inst = self

    -- ETA update delay counter (prevents flickering updates)
    inst.ETADelay = 0

    -- Create the HUD Window
    Nx.Window:SetCreateFade(1, .15)

    local win = Nx.Window:Create("NxHUD", nil, nil, nil, 2, 1, nil, true)
    inst.Win = win

    -- Configure window title alignment (centered on both lines)
    win:SetTitleJustify("CENTER", 1)
    win:SetTitleJustify("CENTER", 2)

    -- Set transparent background when locked
    win:SetBGAlpha(0, 1)

    -- Position window at top-center of screen
    -- 999999 = far right (will be clamped), -.17 = 17% from top
    win:InitLayoutData(nil, 999999, -.17, 1, 1)

    -- Keep HUD on top of other frames
    win.Frm:SetToplevel(true)

    -- Create the directional arrow frame
    local f = CreateFrame("Frame", nil, win.Frm)
    inst.Frm = f
    f.NxInst = inst

    -- Arrow doesn't intercept mouse clicks
    f:EnableMouse(false)

    -- Create arrow texture
    local t = f:CreateTexture()
    t:SetAllPoints(f)
    f.texture = t

    -- Create secure target button (allows targeting in combat)
    -- This button overlays the arrow and enables click-to-target functionality
    local but = CreateFrame("Button", nil, UIParent, "SecureUnitButtonTemplate")
    inst.But = but

    -- Configure button to target player by default
    but:SetAttribute("type", "target")
    but:SetAttribute("unit", "player")

    -- Create button texture (circular indicator)
    local t = but:CreateTexture()
    t:SetAllPoints(but)
    t:SetTexture("Interface\\AddOns\\Carbonite\\Gfx\\Map\\IconCircle")
    but.texture = t
    but:SetWidth(10)
    but:SetHeight(10)

    -- Apply user options
    self:UpdateOptions()

    -- Add context menu items for waypoint management
    local menu = win.Menu
    menu:AddItem(0, "--------------")

    -- Menu item: Remove current waypoint
    local function removeCurrentPoint()
        local map = Nx.Map:GetMap(1)
        tremove(map.Targets, 1)
    end
    menu:AddItem(0, L["Remove Current Point"], removeCurrentPoint, self)

    -- Menu item: Remove all waypoints
    local function removeAllPoints()
        local map = Nx.Map:GetMap(1)
        map:Menu_OnClearGoto()
    end
    menu:AddItem(0, L["Remove All Points"], removeAllPoints, self)
end

---------------------------------------------------------------------------------------
-- Public API Functions
---------------------------------------------------------------------------------------

--- Get current tracking information (for external addon use)
-- @return direction Direction to target in degrees
-- @return distance Distance to target in yards
-- @return name Name/description of the target
function Nx.HUDGetTracking()
    local map = Nx.Map:GetMap(1)
    return map.TrackDir, map.TrackDistYd, map.TrackName
end

--- Set HUD fade level (override default fade behavior)
-- @param fade Fade level (0-1)
-- Note: Currently a stub function, fade is handled elsewhere
function Nx.HUD:SetFade(fade)
    -- Fade handling is done through window system
end

--- Show or hide the HUD
-- @param show Boolean - true to show, false to hide
function Nx.HUD:Show(show)
    self.Win:Show(show)
end

---------------------------------------------------------------------------------------
-- Options and Configuration
---------------------------------------------------------------------------------------

--- Update HUD display based on current user options
-- Applies settings for arrow texture, size, position, colors, and lock state
function Nx.HUD:UpdateOptions()
    local win = self.Win

    -- Handle window transparency based on lock state (paid feature)
    if not Nx.Free then
        local lock = win:IsLocked()
        win:SetBGAlpha(0, lock and 0 or 1)
    end

    local gopts = self.GOpts

    -- Set arrow texture based on user preference
    local name = Nx.db.profile.Track.AGfx
    self.Frm.texture:SetTexture("Interface\\AddOns\\Carbonite\\Gfx\\Map\\HUDArrow" .. name)

    -- Position and size the arrow frame
    local f = self.Frm
    f:SetPoint("CENTER", Nx.db.profile.Track.AXO, -win.TitleH / 2 - 32 - Nx.db.profile.Track.AYO)

    local wh = Nx.db.profile.Track.ASize
    f:SetWidth(wh)
    f:SetHeight(wh)

    -- Apply lock state from options
    if Nx.db.profile.Track.Lock then
        win:Lock(true, true)
    else
        win:Lock(false, true)
    end

    -- Update target button size (only outside combat due to secure frame restrictions)
    if not InCombatLockdown() then
        local f = self.But
        f:SetWidth(wh)
        f:SetHeight(wh)
        f:Hide()
    end

    -- Parse button colors from saved settings
    self.ButR, self.ButG, self.ButB, self.ButA = Nx.Util_str2rgba(Nx.db.profile.Track.TButColor)
    self.ButCR, self.ButCG, self.ButCB, self.ButCA = Nx.Util_str2rgba(Nx.db.profile.Track.TButCombatColor)
end

---------------------------------------------------------------------------------------
-- HUD Update (called every frame)
---------------------------------------------------------------------------------------

--- Update the HUD display each frame
-- Calculates and displays direction arrow, distance, and ETA to current target
-- @param map The main map instance containing tracking data
function Nx.HUD:Update(map)
    local win = self.Win
    local gopts = self.GOpts
    local opts = Nx:GetHUDOpts()
    local noLockDown = not InCombatLockdown()

    -- Check if we have a valid tracking target and HUD should be visible
    local shouldShow = map.TrackDir
        and not Nx.db.profile.Track.Hide
        and not (Nx.InBG and Nx.db.profile.Track.HideInBG)

    if shouldShow then
        local frm = self.Frm
        local but = self.But
        local wfrm = win.Frm

        -- Show window if hidden (and not combat-hidden)
        if not wfrm:IsVisible() then
            if not win:IsCombatHidden() then
                win:Show()
            end
        end

        -- Calculate direction relative to player facing
        local dist = map.TrackDistYd
        local dir = (map.TrackDir - map.PlyrDir) % 360

        -- Don't rotate arrow when very close to target
        if dist < 1 then
            dir = 0
        end

        -- Calculate angular distance (0-180, how far off we're facing)
        local dirDist = dir <= 180 and dir or 360 - dir

        -- Display target name in first title line
        local str = map.TrackName or ""
        win:SetTitle(str)

        -- Update secure button target for click-to-target (paid feature)
        if map.TrackPlayer and noLockDown then
            but:SetAttribute("unit1", map.TrackPlayer)
            but:SetAttribute("shift-unit1", map.TrackPlayer .. "-target")
            but:SetAttribute("unit2", map.TrackPlayer .. "-target")
        end

        -- Build distance string with color coding
        -- Blue color when facing within 5 degrees of target
        local col = dirDist < 5 and "|cffa0a0ff" or ""
        local str = format("%s%d " .. L["yds"], col, dist)

        -- Optionally show direction offset in degrees
        if Nx.db.profile.Track.ShowDir then
            local fmt = dirDist < 1 and L[" %.1f deg"] or L[" %d deg"]
            str = str .. format(fmt, dirDist)
        end

        -- Calculate and display ETA when moving
        if map.PlyrSpeed > .1 then
            self.ETADelay = self.ETADelay - 1

            -- Update ETA string periodically to prevent flickering
            if self.ETADelay <= 0 then
                self.ETADelay = 10

                local eta = map.TrackETA or dist / map.PlyrSpeed

                if eta < 60 then
                    self.ETAStr = format("|cffdfffdf %.0f " .. L["secs"], eta)
                else
                    self.ETAStr = format("|cffdfdfdf %.1f " .. L["mins"], eta / 60)
                end
            end

            str = str .. self.ETAStr
        else
            -- Reset ETA delay when stopped
            self.ETADelay = 3
            self.ETAStr = ""
        end

        -- Display distance/ETA in second title line
        win:SetTitle(str, 2)

        -- Resize window to fit title text
        local atPt, relTo, relPt, x, y = wfrm:GetPoint()
        local w, h = win:GetSize()
        local tw = win:GetTitleTextWidth() + 2
        local d = (tw - w) / 2

        -- Adjust position to keep window anchored correctly
        if strfind(atPt, "LEFT") then
            x = x - d
        elseif strfind(atPt, "RIGHT") then
            x = x + d
        end

        -- Update window position and size (only outside combat)
        if not InCombatLockdown() then
            wfrm:ClearAllPoints()
            wfrm:SetPoint(atPt, x, y)
            win:SetSize(tw, 0, true)
        end

        -- Show/update target button (paid feature)
        if Nx.db.profile.Track.TBut and not win:IsCombatHidden() then
            if noLockDown then
                but:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", frm:GetLeft(), frm:GetTop())
                but:SetScale(wfrm:GetScale())
                but:Show()
                but.texture:SetVertexColor(self.ButR, self.ButG, self.ButB, self.ButA)
            else
                -- Use combat color when in combat
                but.texture:SetVertexColor(self.ButCR, self.ButCG, self.ButCB, self.ButCA)
            end
        end

        -- Calculate rotated texture coordinates for arrow
        -- This rotates the arrow texture to point toward the target
        local texX1 = -.5
        local texX2 = .5
        local texY1 = -.5
        local texY2 = .5
        local co = cos(dir)
        local si = sin(dir)

        -- Calculate rotated corner positions
        t1x = texX1 * co + texY1 * si + .5
        t1y = texX1 * -si + texY1 * co + .5
        t2x = texX1 * co + texY2 * si + .5
        t2y = texX1 * -si + texY2 * co + .5
        t3x = texX2 * co + texY1 * si + .5
        t3y = texX2 * -si + texY1 * co + .5
        t4x = texX2 * co + texY2 * si + .5
        t4y = texX2 * -si + texY2 * co + .5

        -- Apply rotated texture coordinates
        local tex = frm.texture
        tex:SetTexCoord(t1x, t1y, t2x, t2y, t3x, t3y, t4x, t4y)

        -- Set arrow color based on direction accuracy
        if dirDist < 5 then
            -- Facing target (within 5 degrees)
            if dist < 1 then
                -- Very close: green, faded
                tex:SetVertexColor(.2, 1, .2, .4)
                tex:SetBlendMode("BLEND")
            else
                -- Correct direction: blue-white, additive glow
                tex:SetVertexColor(.7, .7, 1, 1)
                tex:SetBlendMode("ADD")
            end
        else
            -- Not facing target: yellow
            tex:SetVertexColor(1, 1, .5, .9)
            tex:SetBlendMode("BLEND")
        end
    else
        -- No tracking target or HUD hidden - hide everything
        win:Show(false)

        if noLockDown then
            self.But:Hide()
        end
    end
end

---------------------------------------------------------------------------------------
-- EOF
---------------------------------------------------------------------------------------
