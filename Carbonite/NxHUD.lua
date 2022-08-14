---------------------------------------------------------------------------------------
-- NxHUD - HUD code
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

--------
-- Init HUD data

local L = LibStub("AceLocale-3.0"):GetLocale("Carbonite")

function Nx.HUD:Init()

	Nx.HUD.TexNames = { "", "Chip", "Gloss", "Glow", "Neon" }

	Nx.HUD:Open()
end

--------
-- Open HUD

function Nx.HUD:Open()

	if not self.Created then

		self:Create()
		self.Created = true
	end

	local inst = self

	inst.Win:Show()
end

--------
-- Open HUD

function Nx.HUD:Create()

	local inst = self

	inst.ETADelay = 0

	-- Create Window

--	Nx.Window:ClrSaveData ("NxHUD")

	Nx.Window:SetCreateFade (1, .15)

	local win = Nx.Window:Create ("NxHUD", nil, nil, nil, 2, 1, nil, true)
	inst.Win = win

--	win:CreateButtons (nil, true)

	win:SetTitleJustify ("CENTER", 1)
	win:SetTitleJustify ("CENTER", 2)

--	win:SetBGColor (0, 0, 0, .5)
	win:SetBGAlpha (0, 1)

	win:InitLayoutData (nil, 999999, -.17, 1, 1)

	win.Frm:SetToplevel (true)

	-- Create arrow frame

	local f = CreateFrame ("Frame", nil, win.Frm)

	inst.Frm = f
	f.NxInst = inst

	f:EnableMouse (false)
	local t = f:CreateTexture()
	t:SetAllPoints (f)
	f.texture = t
	local but = CreateFrame ("Button", nil, UIParent, "SecureUnitButtonTemplate")
	inst.But = but

	but:SetAttribute ("type", "target")
	but:SetAttribute ("unit", "player")

--	but:RegisterForClicks ("LeftButtonDown")

	local t = but:CreateTexture()
	t:SetAllPoints (but)
	t:SetTexture ("Interface\\AddOns\\Carbonite\\Gfx\\Map\\IconCircle")
	but.texture = t
	but:SetWidth (10)
	but:SetHeight (10)
	self:UpdateOptions()	
	local menu = win.Menu	
	local item = menu:AddItem(0,"--------------")
	local function func ()
		local map = Nx.Map:GetMap(1)
		tremove (map.Targets, 1)
	end
	local item = menu:AddItem(0,L["Remove Current Point"], func, self)
	local function func ()
		local map = Nx.Map:GetMap(1)
		map:Menu_OnClearGoto()
	end
	local item = menu:AddItem(0,L["Remove All Points"], func, self)
end

--------
-- Get tracking info. For other addon use

function Nx.HUDGetTracking()

	local map = Nx.Map:GetMap (1)
	return map.TrackDir, map.TrackDistYd, map.TrackName
end

--------
-- Set fade. Ovveride default fade

function Nx.HUD:SetFade (fade)
end

function Nx.HUD:Show (show)
	self.Win:Show (show)
end

function Nx.HUD:UpdateOptions()

	local win = self.Win

--PAIDS!
	if not Nx.Free then

		local lock = win:IsLocked()

		win:SetBGAlpha (0, lock and 0 or 1)

--		self.Frm:EnableMouse (not lock)
	end
--PAIDE!

	local gopts = self.GOpts

	local name = Nx.db.profile.Track.AGfx
	self.Frm.texture:SetTexture ("Interface\\AddOns\\Carbonite\\Gfx\\Map\\HUDArrow" .. name)

	local f = self.Frm

	f:SetPoint ("CENTER", Nx.db.profile.Track.AXO, -win.TitleH / 2 - 32 - Nx.db.profile.Track.AYO)

	local wh = Nx.db.profile.Track.ASize
	f:SetWidth (wh)
	f:SetHeight (wh)
	if (Nx.db.profile.Track.Lock) then
		win:Lock(true,true)
	else
		win:Lock(false,true)
	end
--PAIDS!
	if not InCombatLockdown() then
		local f = self.But
		f:SetWidth (wh)
		f:SetHeight (wh)
		f:Hide()
	end
--PAIDE!

	self.ButR, self.ButG, self.ButB, self.ButA = Nx.Util_str2rgba (Nx.db.profile.Track.TButColor)
	self.ButCR, self.ButCG, self.ButCB, self.ButCA = Nx.Util_str2rgba (Nx.db.profile.Track.TButCombatColor)
end

--[[
function Nx.HUD:OnMouseDown (button)
	if button == "RightButton" then
	end
end
--]]

function Nx.HUD:Update (map)

--	if IsControlKeyDown() then
--		Nx.prtFrame ("HUD", self.Frm)
--		Nx.prtVar ("Trk", map.TrackDir)
--	end

	local win = self.Win

	local gopts = self.GOpts
	local opts = Nx:GetHUDOpts()
	local noLockDown = not InCombatLockdown()

	if map.TrackDir and not Nx.db.profile.Track.Hide and not (Nx.InBG and Nx.db.profile.Track.HideInBG) then

		local frm = self.Frm
		local but = self.But
		local wfrm = win.Frm

		if not wfrm:IsVisible() then	-- Show also raises so only do if hidden
			if not win:IsCombatHidden() then
				win:Show()
			end
		end

		local dist = map.TrackDistYd
		local dir = (map.TrackDir - map.PlyrDir) % 360
		if dist < 1 then
			dir = 0
		end
		local dirDist = dir <= 180 and dir or 360 - dir

		local str = map.TrackName or ""
		win:SetTitle (str)

--PAIDS!
		if map.TrackPlayer and noLockDown then
--			Nx.prt ("HUD %s", map.TrackPlayer)
			but:SetAttribute ("unit1", map.TrackPlayer)
			but:SetAttribute ("shift-unit1", map.TrackPlayer .. "-target")
			but:SetAttribute ("unit2", map.TrackPlayer .. "-target")
		end
--PAIDE!

		local col = dirDist < 5 and "|cffa0a0ff" or ""
		local str = format ("%s%d " .. L["yds"], col, dist)

		if Nx.db.profile.Track.ShowDir then
			local fmt = dirDist < 1 and L[" %.1f deg"] or L[" %d deg"]
			str = str .. format (fmt, dirDist)
		end

		if map.PlyrSpeed > .1 then

--			Nx.prt ("HUD dir %f %f spd %f", dir, dirDist, map.PlyrSpeed)

			self.ETADelay = self.ETADelay - 1

			if self.ETADelay <= 0 then

				self.ETADelay = 10

				local eta = map.TrackETA or dist / map.PlyrSpeed

				if eta < 60 then
					self.ETAStr = format ("|cffdfffdf %.0f " .. L["secs"], eta)
				else
					self.ETAStr = format ("|cffdfdfdf %.1f " .. L["mins"], eta / 60)
				end
			end

			str = str .. self.ETAStr

		else
			self.ETADelay = 3		-- Delay for time to stabilize
			self.ETAStr = ""
		end

		win:SetTitle (str, 2)

		local atPt, relTo, relPt, x, y = wfrm:GetPoint()

		local w, h = win:GetSize()
		local tw = win:GetTitleTextWidth() + 2		
		local d = (tw - w) / 2		
		if strfind (atPt, "LEFT") then
			x = x - d
		elseif strfind (atPt, "RIGHT") then
			x = x + d
		end		
		if not InCombatLockdown() then		
			wfrm:ClearAllPoints()
			wfrm:SetPoint (atPt, x, y)
			win:SetSize (tw, 0, true)
		end
--PAIDS!
		if Nx.db.profile.Track.TBut and not win:IsCombatHidden() then

			if noLockDown then
				but:SetPoint ("TOPLEFT", UIParent, "BOTTOMLEFT", frm:GetLeft(), frm:GetTop())
				but:SetScale (wfrm:GetScale())
				but:Show()
				but.texture:SetVertexColor (self.ButR, self.ButG, self.ButB, self.ButA)
			else
				but.texture:SetVertexColor (self.ButCR, self.ButCG, self.ButCB, self.ButCA)
			end
		end
--PAIDE!

		local texX1 = -.5
		local texX2 = .5
		local texY1 = -.5
		local texY2 = .5
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

		local tex = frm.texture
		tex:SetTexCoord (t1x, t1y, t2x, t2y, t3x, t3y, t4x, t4y)

		if dirDist < 5 then
			if dist < 1 then
				tex:SetVertexColor (.2, 1, .2, .4)
				tex:SetBlendMode ("BLEND")
			else
				tex:SetVertexColor (.7, .7, 1, 1)
				tex:SetBlendMode ("ADD")
			end
		else
			tex:SetVertexColor (1, 1, .5, .9)
			tex:SetBlendMode ("BLEND")
		end
	else

		win:Show (false)

--PAIDS!
		if noLockDown then
			self.But:Hide()
		end
--PAIDE!
	end
end

-------------------------------------------------------------------------------
-- EOF
