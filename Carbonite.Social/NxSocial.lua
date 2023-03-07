---------------------------------------------------------------------------------------
-- NxSocial - Social Window (friends, guild)
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
-- Init
---------------------------------------------------------------------------------------

local _G = getfenv(0)

Nx.VERSIONSOCIAL		= .2				-- Social data
Nx.Social = {}
Nx.Social.List = {}
Nx.Social.PunksHUD = {}
Nx.Social.TeamHUD = {}
Nx.Social.Cols = {}

CarboniteSocial = LibStub("AceAddon-3.0"):NewAddon("CarboniteSocial", "AceTimer-3.0", "AceEvent-3.0", "AceComm-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("Carbonite.Social", true)

-- Use C_FriendList.GetFriendInfo or C_FriendList.GetFriendInfoByIndex instead
function GetFriendInfo(friend)
	local info;
	if type(friend) == "number" then
		info = C_FriendList.GetFriendInfoByIndex(friend);
	elseif type(friend) == "string" then
		info = C_FriendList.GetFriendInfo(friend);
	end

	if info then
		local chatFlag = "";
		if info.dnd then
			chatFlag = CHAT_FLAG_DND;
		elseif info.afk then
			chatFlag = CHAT_FLAG_AFK;
		end
		return info.name,
			info.level,
			info.className,
			info.area,
			info.connected,
			chatFlag,
			info.notes;
			--info.rafLinkType ~= Enum.RafLinkType.None,
			--info.guid;
	end
end

-- Use C_FriendList.SetSelectedFriend instead
SetSelectedFriend = C_FriendList.SetSelectedFriend;

-- Use C_FriendList.RemoveFriend or C_FriendList.RemoveFriendByIndex instead
function RemoveFriend(friend)
	if type(friend) == "number" then
		C_FriendList.RemoveFriendByIndex(friend);
	elseif type(friend) == "string" then
		C_FriendList.RemoveFriend(friend);
	end
end

local defaults = {
	profile = {
		Social = {
			MapShowPunks = true,
			PunkAreaColor = ".125|.05|.05|1",
			PunkAreaSize = 80,
			PunkBGAreaColor = "24|.141|.141|1",
			PunkBGAreaSize = 60,
			PunkIconColor = "1|.5|.5|1",
			PunkMAreaColor = ".09|.44|.09|1",
			PunkMAreaSize = 200,
			PunkMAlertText = true,
			PunkMAlertSnd = true,
			PunkShowInSafeArea = false,
			PunkNewLocalWarnChat = true,
			PunkNewLocalWarnSnd = false,
			PunkShowInBG = true,
			PunkTWinTitle = "Punks:",
			PunkTWinHide = false,
			PunkTWinLock = false,
			PunkTWinMaxButs = 5,
			SocialEnable = true,
			PunkEnable = true,
			TeamTWinEnable = false,
			TeamTWinHide = true,
			TeamTWinMaxButs = 15,
		},
	},
}

local socialoptions
local function socialConfig()
	if not socialoptions then
		socialoptions = {
			type = "group",
			name = L["Social Options"],
			childGroups	= "tab",
			args = {
				socialWin = {
					order = 1,
					type = "group",
					name = L["Social Options"],
					args = {
						socenable = {
							order = 1,
							type = "toggle",
							width = "full",
							name = L["Enable the enhanced social window"],
							desc = L["When enabled, Carbonite will use the enhanced social window instead of blizzards (REQUIRES RELOAD)"],
							get = function()
								return Nx.scdb.profile.Social.SocialEnable
							end,
							set = function()
								Nx.scdb.profile.Social.SocialEnable = not Nx.scdb.profile.Social.SocialEnable
								Nx.Opts.NXCmdReload()
							end,
						},
					},
				},
				punkWin = {
					order = 2,
					type = "group",
					name = L["Punk Options"],
					args = {
						pnkenable = {
							order = 1,
							type = "toggle",
							width = "full",
							name = L["Enable the Punk System"],
							desc = L["When enabled, Carbonite allows use of the Punk system (REQUIRES RELOAD)"],
							get = function()
								return Nx.scdb.profile.Social.PunkEnable
							end,
							set = function()
								Nx.scdb.profile.Social.PunkEnable = not Nx.scdb.profile.Social.PunkEnable
								Nx.Opts.NXCmdReload()
							end,
						},
						spacer = {
							order = 2,
							type = "description",
							width = "full",
							name = " ",
						},
						pnkhide = {
							order = 3,
							type = "toggle",
							width = "full",
							name = L["Hide the Punk Window"],
							desc = L["When enabled, Carbonite will hide the punk window"],
							get = function()
								return Nx.scdb.profile.Social.PunkTWinHide
							end,
							set = function()
								Nx.scdb.profile.Social.PunkTWinHide = not Nx.scdb.profile.Social.PunkTWinHide
								Nx.Window:SetAttribute("NxPunkHUD","H",Nx.scdb.profile.Social.PunkTWinHide)
							end,
						},
						pnklock = {
							order = 4,
							type = "toggle",
							width = "full",
							name = L["Lock the Punk Window"],
							desc = L["When enabled, Carbonite will lock the punk window"],
							get = function()
								return Nx.scdb.profile.Social.PunkTWinLock
							end,
							set = function()
								Nx.scdb.profile.Social.PunkTWinLock = not Nx.scdb.profile.Social.PunkTWinLock
								Nx.Window:SetAttribute("NxPunkHUD","L",Nx.scdb.profile.Social.PunkTWinLock)
							end,
						},
						pnktitle = {
							order = 5,
							type = "input",
							width = "full",
							name = L["Punk Window Title"],
							get = function()
								return Nx.scdb.profile.Social.PunkTWinTitle
							end,
							set = function(info,value)
								Nx.scdb.profile.Social.PunkTWinTitle = value
								Nx.Opts.NXCmdReload()
							end,
						},
						maxtargets = {
							order = 6,
							type = "range",
							name = L["Max punk target buttons"],
							desc = L["Sets the number of punks that will show in the punk window. (REQUIRES RELOAD)"],
							min = 0,
							max = 15,
							step = 1,
							bigStep = 1,
							get = function()
								return Nx.scdb.profile.Social.PunkTWinMaxButs
							end,
							set = function(info,value)
								Nx.scdb.profile.Track.PunkTWinMaxButs = value
								Nx.Opts.NXCmdReload()
							end,
						},
						spacer2 = {
							order = 7,
							type = "description",
							width = "full",
							name = " ",
						},
						pnkotxt = {
							order = 8,
							type = "toggle",
							width = "full",
							name = L["Show Others Punks Message"],
							desc = L["When enabled, Carbonite will show a message on other users in the zone detecting punks"],
							get = function()
								return Nx.scdb.profile.Social.PunkMAlertText
							end,
							set = function()
								Nx.scdb.profile.Social.PunkMAlertText = not Nx.scdb.profile.Social.PunkMAlertText
							end,
						},
						pnkosnd = {
							order = 9,
							type = "toggle",
							width = "full",
							name = L["Play Others Punk Sound"],
							desc = L["When enabled, Carbonite will play a sound when another Carbonite user in the zone sees a punk"],
							get = function()
								return Nx.scdb.profile.Social.PunkMAlertSnd
							end,
							set = function()
								Nx.scdb.profile.Social.PunkMAlertSnd = not Nx.scdb.profile.Social.PunkMAlertSnd
							end,
						},
						pnktxt = {
							order = 10,
							type = "toggle",
							width = "full",
							name = L["Show Punks Message"],
							desc = L["When enabled, Carbonite will show a message in your chat when you detect a punk"],
							get = function()
								return Nx.scdb.profile.Social.PunkNewLocalWarnChat
							end,
							set = function()
								Nx.scdb.profile.Social.PunkNewLocalWarnChat = not Nx.scdb.profile.Social.PunkNewLocalWarnChat
							end,
						},
						pnksnd = {
							order = 11,
							type = "toggle",
							width = "full",
							name = L["Play Punk Sound"],
							desc = L["When enabled, Carbonite will play a sound when you detect a new punk"],
							get = function()
								return Nx.scdb.profile.Social.PunkNewLocalWarnSnd
							end,
							set = function()
								Nx.scdb.profile.Social.PunkNewLocalWarnSnd = not Nx.scdb.profile.Social.PunkNewLocalWarnSnd
							end,
						},
						pnksafe = {
							order = 12,
							type = "toggle",
							width = "full",
							name = L["Show Punks In Safe Areas"],
							desc = L["When enabled, Carbonite will show punks even in sanctuary areas"],
							get = function()
								return Nx.scdb.profile.Social.PunkShowInSafeArea
							end,
							set = function()
								Nx.scdb.profile.Social.PunkShowInSafeArea = not Nx.scdb.profile.Social.PunkShowInSafeArea
							end,
						},
						spacer3 = {
							order = 13,
							type = "description",
							width = "full",
							name = " ",
						},
						pnkshowmap = {
							order = 14,
							type = "toggle",
							width = "full",
							name = L["Show Punks On Map"],
							desc = L["When enabled, Carbonite will show punks on your map"],
							get = function()
								return Nx.scdb.profile.Social.MapShowPunks
							end,
							set = function()
								Nx.scdb.profile.Social.MapShowPunks = not Nx.scdb.profile.Social.MapShowPunks
							end,
						},
						pnkiconcol = {
							order = 15,
							type = "color",
							width = "full",
							name = L["Color of punk icon"],
							hasAlpha = true,
							get = function()
								local arr = { strsplit("|",Nx.scdb.profile.Social.PunkIconColor) }
								local r = arr[1]
								local g = arr[2]
								local b = arr[3]
								local a = arr[4]
								return r,g,b,tonumber(a)
							end,
							set = function(_,r,g,b,a)
								Nx.scdb.profile.Social.PunkIconColor = r .. "|" .. g .. "|" .. b .. "|" .. a
								Nx.Social:SetCols()
							end,
						},
						pnkareacol = {
							order = 16,
							type = "color",
							width = "full",
							name = L["Color of punk map area"],
							hasAlpha = true,
							get = function()
								local arr = { strsplit("|",Nx.scdb.profile.Social.PunkAreaColor) }
								local r = arr[1]
								local g = arr[2]
								local b = arr[3]
								local a = arr[4]
								return r,g,b,tonumber(a)
							end,
							set = function(_,r,g,b,a)
								Nx.scdb.profile.Social.PunkAreaColor = r .. "|" .. g .. "|" .. b .. "|" .. a
								Nx.Social:SetCols()
							end,
						},
						pnkareasize = {
							order = 17,
							type = "range",
							name = L["Punk Area Size"],
							desc = L["Sets the size of the punk area notify on the map."],
							min = 0,
							max = 5000,
							step = 10,
							bigStep = 10,
							get = function()
								return Nx.scdb.profile.Social.PunkAreaSize
							end,
							set = function(info,value)
								Nx.scdb.profile.Social.PunkAreaSize = value
							end,
						},
						pnkmareacol = {
							order = 18,
							type = "color",
							width = "full",
							name = L["Color of other peoples detected punks"],
							hasAlpha = true,
							get = function()
								local arr = { strsplit("|",Nx.scdb.profile.Social.PunkMAreaColor) }
								local r = arr[1]
								local g = arr[2]
								local b = arr[3]
								local a = arr[4]
								return r,g,b,tonumber(a)
							end,
							set = function(_,r,g,b,a)
								Nx.scdb.profile.Social.PunkMAreaColor = r .. "|" .. g .. "|" .. b .. "|" .. a
								Nx.Social:SetCols()
							end,
						},
						pnkmareasize = {
							order = 19,
							type = "range",
							name = L["Others Punk Area Size"],
							desc = L["Sets the size of the punk area notify on the map from other carbonite users."],
							min = 0,
							max = 5000,
							step = 10,
							bigStep = 10,
							get = function()
								return Nx.scdb.profile.Social.PunkMAreaSize
							end,
							set = function(info,value)
								Nx.scdb.profile.Social.PunkMAreaSize = value
							end,
						},
						pnkmap = {
							order = 20,
							type = "toggle",
							width = "full",
							name = L["Show Battleground Punks On Map"],
							desc = L["When enabled, Carbonite will show punks on your map in battlegrounds"],
							get = function()
								return Nx.scdb.profile.Social.PunkShowInBG
							end,
							set = function()
								Nx.scdb.profile.Social.PunkShowInBG = not Nx.scdb.profile.Social.PunkShowInBG
							end,
						},
						pnkbgareacol = {
							order = 21,
							type = "color",
							width = "full",
							name = L["Battleground punk color"],
							hasAlpha = true,
							get = function()
								local arr = { strsplit("|",Nx.scdb.profile.Social.PunkBGAreaColor) }
								local r = arr[1]
								local g = arr[2]
								local b = arr[3]
								local a = arr[4]
								return r,g,b,tonumber(a)
							end,
							set = function(_,r,g,b,a)
								Nx.scdb.profile.Social.PunkBGAreaColor = r .. "|" .. g .. "|" .. b .. "|" .. a
								Nx.Social:SetCols()
							end,
						},
						pnkbgareasize = {
							order = 22,
							type = "range",
							name = L["Battleground Punk Area Size"],
							desc = L["Sets the size of the punk area in BGs."],
							min = 0,
							max = 5000,
							step = 10,
							bigStep = 10,
							get = function()
								return Nx.scdb.profile.Social.PunkBGAreaSize
							end,
							set = function(info,value)
								Nx.scdb.profile.Social.PunkBGAreaSize = value
							end,
						},
					},
				},
				teamWin = {
					order = 3,
					type = "group",
					name = L["Team Options"],
					args = {
						teamenable = {
							order = 1,
							type = "toggle",
							width = "full",
							name = L["Enable the Team HUD"],
							desc = L["When enabled, Carbonite can display a HUD of your team mates (RELOAD REQUIRED)"],
							get = function()
								return Nx.scdb.profile.Social.TeamTWinEnable
							end,
							set = function()
								Nx.scdb.profile.Social.TeamTWinEnable = not Nx.scdb.profile.Social.TeamTWinEnable
								Nx.Opts.NXCmdReload()
							end,
						},
						teamhide = {
							order = 2,
							type = "toggle",
							width = "full",
							name = L["Hide the team button window"],
							desc = L["When enabled, Carbonite will hide the team window"],
							get = function()
								return Nx.scdb.profile.Social.TeamTWinHide
							end,
							set = function()
								Nx.scdb.profile.Social.TeamTWinHide = not Nx.scdb.profile.Social.TeamTWinHide
								Nx.Window:SetAttribute("NxTeamHUD","H",Nx.scdb.profile.Social.TeamTWinHide)
							end,
						},
						teamtargets = {
							order = 3,
							type = "range",
							name = L["number of target buttons"],
							desc = L["Sets the number of buttons for team members in the teamhud (RELOAD REQUIRED)"],
							min = 0,
							max = 40,
							step = 1,
							bigStep = 1,
							get = function()
								return Nx.scdb.profile.Social.TeamTWinMaxButs
							end,
							set = function(info,value)
								Nx.scdb.profile.Track.TeamTWinMaxButs = value
								Nx.Opts.NXCmdReload()
							end,
						},
					},
				},
			},
		}
	end
	Nx.Opts:AddToProfileMenu(L["Social"],5,Nx.scdb)
	return socialoptions
end

function CarboniteSocial:OnInitialize()
	if not Nx.Initialized then
		CarbSocialInit = Nx:ScheduleTimer(CarboniteSocial.OnInitialize,1)
		return
	end
	Nx.scdb = LibStub("AceDB-3.0"):New("NXSocial",defaults, true)

	local soc = Nx.scdb.profile.SocialData

	if not soc or soc.Version < Nx.VERSIONSOCIAL then

		if soc then
			Nx.prt ("Reset old social data %f", soc.Version)
		end

		soc = {}
		Nx.scdb.profile.SocialData = soc
		soc.Version = Nx.VERSIONSOCIAL
	end

	local rn = GetRealmName()

	if not soc[rn] then
		local t = {}
		soc[rn] = t
		t["Pal"] = {}
		t["Pal"][""] = {}		-- Default non person
		t["Pk"] = {}
	end

	soc[rn]["PkAct"] = soc[rn]["PkAct"] or {}
	Nx.Social:Init()
	CarboniteSocial:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "OnCombat_log_event_unfiltered")
	--CarboniteSocial:RegisterEvent("PLAYER_ENTERING_WORLD", "On_Event")
	Nx.Social.UpdateTicker = C_Timer.NewTicker(1, function() CarboniteSocial:On_Event("FORCE_UPDATE"); Nx.Social:OnUpdateTimer(); end)
	CarboniteSocial:RegisterComm("carbmodule",Nx.Social.OnChat_msg_addon)
--	CarboniteSocial.EventTimer = CarboniteSocial:ScheduleRepeatingTimer("On_Update",2)
	Nx:AddToConfig("Social & Punks Module",socialConfig(),L["Social & Punks Module"])
	Nx.Social:SetCols()
end

function Nx.Social:OnChat_msg_addon(msg,dist,target)
	if msg == "PUNK_DECODE" then
		Nx.Social:DecodeComRcvPunks (Nx.pTEMPname, Nx.pTEMPinfo, Nx.pTEMPmsg)
	elseif msg == "LIST_UPDATE" then
		Nx.Social.List:Update()
	end
end

function Nx.Social:SetCols()
	Nx.Social.Cols["areaR"], Nx.Social.Cols["areaG"], Nx.Social.Cols["areaB"] = Nx.Util_str2rgba (Nx.scdb.profile.Social.PunkAreaColor)
	Nx.Social.Cols["iconR"], Nx.Social.Cols["iconG"], Nx.Social.Cols["iconB"], Nx.Social.Cols["iconA"] = Nx.Util_str2rgba (Nx.scdb.profile.Social.PunkIconColor)
	Nx.Social.Cols["areaRM"], Nx.Social.Cols["areaGM"], Nx.Social.Cols["areaBM"] = Nx.Util_str2rgba (Nx.scdb.profile.Social.PunkMAreaColor)
	Nx.Social.Cols["areaBGR"], Nx.Social.Cols["areaBGG"], Nx.Social.Cols["areaBGB"] = Nx.Util_str2rgba (Nx.scdb.profile.Social.PunkBGAreaColor)
end

function CarboniteSocial:On_Event(event,...)
	if event == "PLAYER_ENTERING_WORLD" or event == "FORCE_UPDATE" then
		Nx.Social.PunksHUD:Update()
		Nx.Social.TeamHUD:Update()
		Nx.Social:OnUpdate()

		local targetName = UnitName ("target")
		local BG = Nx.InBG
		if UnitIsPlayer ("target") and UnitIsEnemy ("player", "target") then

			local lvl = UnitLevel ("target") or 0
			if not BG then
				Nx.Com.Punks[targetName] = lvl
			end
			Nx.Social:AddLocalPunk (targetName, nil, lvl, UnitClass ("target"))
		end
		if UnitIsPlayer ("mouseover") and UnitIsEnemy ("player", "mouseover") then
			local moName = UnitName ("mouseover")
			if moName ~= targetName then
				local lvl = UnitLevel ("mouseover") or 0
				if not BG then
					Nx.Com.Punks[moName] = lvl
				end
				Nx.Social:AddLocalPunk (moName, nil, lvl, UnitClass ("mouseover"))
			end
		end
		if Nx.ModPAction == "PUNK_DECODE" then
			Nx.ModPAction = ""
			Nx.Social:DecodeComRcvPunks (Nx.pTEMPname, Nx.pTEMPinfo, Nx.pTEMPmsg)
		end
	end
end

function Nx.Social:Init()
	self.List.Sorted = {}
	if Nx.scdb.profile.Social.SocialEnable then

--		Nx.prt ("SocialEnable")

		local ff = FriendsFrame
		GetUIPanelWidth (ff)
		ff:SetAttribute ("UIPanelLayout-enabled", false)

		hooksecurefunc ("PanelTemplates_SetTab", Nx.Social.PanelTemplates_SetTab)
	end

	self.Punks = Nx:GetSocial ("Pk")
	self.PunksActive = Nx:GetSocial ("PkAct")

	for k, v in pairs (self.PunksActive) do
		if not (v.MId and v.X and v.Y and v.Time) then	-- Munge changed?
			Nx:ClearSocial ("PkAct")
			self.PunksActive = Nx:GetSocial ("PkAct")
			break
		end
	end
	if Nx.scdb.profile.Social.PunkEnable then
		self.PunkNewDir = 0
		self.PunksHUD:Create()
	end
	self.TeamHUD:Create()

	CarboniteSocial:RegisterEvent("PLAYER_REGEN_DISABLED","EventHandler")

	hooksecurefunc ("ShowUIPanel", Nx.Social.PShowUIPanel)
	hooksecurefunc ("HideUIPanel", Nx.Social.PHideUIPanel)
	hooksecurefunc ("CloseWindows", Nx.Social.PCloseWindows)
	
	local func = function ()
		if Nx.scdb.profile.Social.SocialEnable then
			local ff = FriendsFrame
			local ffH = self.FFHolder

			ff:SetToplevel (false)
			ff:SetParent (ffH)
			ff:SetPoint ("TOPLEFT", ffH, "TOPLEFT", 0, 0)

			if ff:IsVisible() then

				if ff:GetFrameStrata() ~= self.Win.Frm:GetFrameStrata() then
					ff:SetFrameStrata (self.Win.Frm:GetFrameStrata())
				end

				if ff:GetFrameLevel() <= self.Win.Frm:GetFrameLevel() then
					ff:Raise()
				end
			end
			
			local f = GuildControlPopupFrame
			if f:IsVisible() then

				if f:GetFrameStrata() ~= self.Win.Frm:GetFrameStrata() then
					f:SetFrameStrata (self.Win.Frm:GetFrameStrata())
				end

				if f:GetFrameLevel() <= self.Win.Frm:GetFrameLevel() then
					f:Raise()
				end
			end
		end
	end
	
	GuildControlPopupFrameCancelButton:HookScript("OnClick", func)
	hooksecurefunc ("GuildFramePopup_Show", func)

	
	Nx.Window:SetAttribute("NxPunkHUD","H",Nx.scdb.profile.Social.PunkTWinHide)
	Nx.Window:SetAttribute("NxPunkHUD","L",Nx.scdb.profile.Social.PunkTWinLock)
end

function CarboniteSocial:EventHandler(event, arg1, arg2, arg3)
	if event == "PLAYER_REGEN_DISABLED" then
		Nx.Social:PreCombatHide()
	end
end

--[[
function Nx.Social.Hook (v)
	Nx.prt ("HOOK %s", v)
	Nx.Social.HookOrig (v)

	Nx.prtFrame ("GuildFrame", GuildFrame)
end
--]]

function Nx.Social:ShowUIPanel (frame)

	if not GameMenuFrame:IsShown() and not self.NoShow then

		if self.InOnTabBar then
			return
		end

--		Nx.prtFrame ("FF", frame)

		if InCombatLockdown() and(GetNumGroupMembers()>0 or _G["RaidGroupFrame_Update"]) then
			return
		end

--		Nx.prt ("Social:ShowUIPanel %s", debugstack (2, 3, 0))

--		if IsAltKeyDown() then
--			return
--		end

--		Nx.prt ("Social:ShowUIPanel")

		self.NoShow = true

		self:Create()

		local win = self.Win
		local wf	= win.Frm

		wf:Raise()

		if not win:IsShown() then		-- Toggle off?

--			Nx.prt ("Social:ShowUIPanel show win")

			win:Show()
			self:ShowBlizzTabs (false)

			C_Timer.After(0, function() self.Bar:Select (self.TabSelected, true) end)
			--self.Bar:Select (self.TabSelected, true)
		end
		
		local ff = FriendsFrame
		local ffH = self.FFHolder

		ff:SetToplevel (false)
		ff:SetParent (ffH)
		ff:SetPoint ("TOPLEFT", ffH, "TOPLEFT", 0, 0)

		if ff:IsVisible() then

			if ff:GetFrameStrata() ~= self.Win.Frm:GetFrameStrata() then
				ff:SetFrameStrata (self.Win.Frm:GetFrameStrata())
			end

			if ff:GetFrameLevel() <= self.Win.Frm:GetFrameLevel() then
				ff:Raise()
--					Nx.prt ("raise")
			end
		end

		
--[[	--V4
		local guildTabI = self.OrigTabI + 2

		self.Bar:Enable (guildTabI, IsInGuild() ~= nil)

		if self.TabSelected == guildTabI then

			local function func()
				GuildFrame:Show()
--				Nx.prt ("FF G UPD")
			end

			Nx.Timer:Start ("SocialFFUpdate", 0, self, func)
		end
--]]

		self.NoShow = false
	end
end

function Nx.Social:HideUIPanel (frame)

	if self.Win then

--		Nx.prt ("Social:HideUIPanel")

		self.NoShow = true

		self:RestoreFriendsFrame()
		self:Show (false)

		self.NoShow = false

--		Nx.prt ("Social:HideUIPanel2")
	end
end

---------------------------------------------------------------------------------------

function Nx.Social:RestoreFriendsFrame()

	local ff = FriendsFrame

--	Nx.prtFrame ("RestoreFF", ff)

	if ff:GetParent() == self.FFHolder then

--		Nx.prt ("Social:RestoreFriendsFrame")

--		ff:SetAttribute ("UIPanelLayout-enabled", false)

		local l = ff:GetFrameLevel (ff)

--		self.Win:Detach (ff)
		self:ShowBlizzTabs()

		ff:SetParent (UIParent)		-- This can cause ShowUIPanel calls if Esc key was pressed
		ff:SetToplevel (true)
		ff:SetFrameLevel (l)
		ff:Raise()
		ff:Hide()
	end
end

---------------------------------------------------------------------------------------
-- Open window
---------------------------------------------------------------------------------------

function Nx.Social:Show (on)

	self:Create()

	if self.Win then
		self.Win:Show (on)
	end
end

---------------------------------------------------------------------------------------
-- Hide window. Used before combat lockdown
---------------------------------------------------------------------------------------

function Nx.Social:PreCombatHide()

	if self.Win then
		if IsInRaid() then

--			Nx.prt ("PreCombatHide")

			local ff = FriendsFrame
--			ff:SetAttribute ("UIPanelLayout-enabled", true)
--			ff:SetMovable (true)

			self:HideUIPanel (ff)
		end
	end
end

---------------------------------------------------------------------------------------
-- Create window
---------------------------------------------------------------------------------------

function Nx.Social:Create()
	if not Nx.scdb.profile.Social.SocialEnable then
		return
	end

	if self.Win then
		return
	end

	local tbH = Nx.TabBar:GetHeight()

	-- Create Window

	local win = Nx.Window:Create ("NxSocial")
	self.Win = win
	local frm = win.Frm

	win:CreateButtons (true, true)

	win:InitLayoutData (nil, -.25, -.18, -.5, -.64)

	frm:SetToplevel (true)
	frm:Hide()

	tinsert (UISpecialFrames, frm:GetName())

	win:SetUser (self, self.OnWin)
	LibStub("AceEvent-3.0"):Embed(win)
	--win:RegisterEvent ("FRIENDLIST_SHOW", Nx.Social.OnFriendListUpdate)
	win:RegisterEvent ("FRIENDLIST_UPDATE", Nx.Social.OnFriendListUpdate)
	win:RegisterEvent ("GUILD_ROSTER_UPDATE", Nx.Social.OnFriendListUpdate)

	-- FF

	local ffH = CreateFrame ("Frame", "NxSocFFH", UIParent)
	self.FFHolder = ffH

	ffH:SetWidth (384)
	ffH:SetHeight (512)

	local ff = FriendsFrame
	ff:SetParent (ffH)
	ff:SetPoint ("TOPLEFT", ffH, "TOPLEFT", 0, 0)

	win:Attach (ffH, 0, 1, 0, -tbH, 384 - 20, 512 - 40)

--	win:Attach (ff, 0, 1, 0, -tbH)

	-- Create Tab Bar

	local bar = Nx.TabBar:Create (nil, frm, 1, 1)
	self.Bar = bar

	win:Attach (bar.Frm, 0, 1, -tbH, 1)

	bar:SetUser (self, self.OnTabBar)

	local palw = 0
	local selected = 2
--PAIDS!
	palw = 46
	selected = 1
--PAIDE!

	local orig = 3

	bar:AddTab (L["Pals"], 1, palw)
	bar:AddTab (L["Punks"], 2, 46)

	if Nx.db.profile.Debug.VerDebug then
		bar:AddTab ("Com", 3, 38)
		orig = 4
	end

	self.OrigTabI = orig

	bar:AddTab (L["Friends"], orig, 60, false, "FriendsFrameTabTemplate", 1)
	bar:AddTab (L["Who"], orig + 1, 45, false, "FriendsFrameTabTemplate", 2)
--	bar:AddTab (L["Guild"], orig + 2, 45, false, "FriendsFrameTabTemplate", 3)		--V4 moved
	bar:AddTab (L["Guild"], orig + 2, 45, false, "FriendsFrameTabTemplate", 3)
	bar:AddTab (L["Raid"], orig + 3, 45, false, "FriendsFrameTabTemplate", 4)

	--

	self.List:Create()

	self.TabSelected = selected
	bar:Select (selected)					-- Select after list is created
end

---------------------------------------------------------------------------------------

function Nx.Social:OnWin (typ)

	if typ == "Close" then
		self:HideUIPanel (FriendsFrame)
	end
end

function Nx.Social:OnFriendListUpdate (event)

--[[
	Nx.prt ("OnFriendListUpdate %s", event)

	for n = 1, C_FriendList.GetNumFriends() do
		local name, level, class, area, connected, status, note = C_FriendList.GetFriendInfo (n)
		Nx.prt ("#%s %s", n, name or "nil")
	end
--]]

	Nx.Social.List:Update()
end

---------------------------------------------------------------------------------------

function Nx.Social:OnUpdate()

	if self.Win then

		local wf = self.Win.Frm
		if wf:IsVisible() then

			if self.Win:IsMovingOrSizing() then
				return
			end

			--[[local f = ChannelFrameDaughterFrame
			if f:IsVisible() then
				f:SetFrameLevel (wf:GetFrameLevel() + 100)
			end]]--
		end
	end
end

---------------------------------------------------------------------------------------

function Nx.Social.PanelTemplates_SetTab (frame, index)

	local self = Nx.Social
	local ff = FriendsFrame

	if frame == ff and self.Bar and not self.InOnTabBar then

		index = index + self.OrigTabI - 1

--		Nx.prt ("PanelTemplates_SetTab #%s", index)
		self.Bar:Select (index)
	end
end

---------------------------------------------------------------------------------------

function Nx.Social:OnTabBar (index, click, inSetTab)

	if self.InOnTabBar then
--		Nx.prt ("OnTabBar %s in tab bar", index)
		return
	end

--	Nx.prt ("OnTabBar %s", index)

--	local oldSel = self.TabSelected
	self.TabSelected = index

	if not self.Win:IsShown() then
--		Nx.prt ("OnTabBar %s !win", index)
		return
	end

	self.InOnTabBar = true
--[[
	if self.TabSelected == self.OrigTabI + 2 and not IsInGuild() then
		self.Bar:Select (oldSel)
		self.InOnTabBar = false
		return
	end
--]]
	local list = self.List.List
	local ff = FriendsFrame
	local tbH = Nx.TabBar:GetHeight()

	if ff:GetParent() ~= self.FFHolder then

--		Nx.prt ("OnTabBar %s Parent", index)

		local ffH = self.FFHolder

		ff:SetToplevel (false)
		ff:SetParent (ffH)
		ff:SetPoint ("TOPLEFT", ffH, "TOPLEFT", 0, 0)

		self:ShowBlizzTabs (false)
	end

	if index < self.OrigTabI then

		self.FFHolder:Hide()
		list.Frm:Show()

	else

		list.Frm:Hide()
		self.FFHolder:Show()
		ff:Show()
	end

	self.List:Update()

	self.InOnTabBar = false

--	Nx.prt ("OnTabBar %s done", index)
end

function Nx.Social:ShowBlizzTabs (show)

	for n = 1, 10 do
		local tabf = _G["FriendsFrameTab" .. n]
		if tabf then
			if show ~= false then
				tabf:Show()
			else
				tabf:Hide()
			end
		end
	end
end

---------------------------------------------------------------------------------------
-- Create social list
---------------------------------------------------------------------------------------

function Nx.Social.List:Create()

	local win = Nx.Social.Win
	local tbH = Nx.TabBar:GetHeight()

	-- Dummy frame
--[[
	local f = CreateFrame ("Frame", nil, UIParent)
	self.Frm = f
	f.NxSocialList = self

	f:SetMovable (true)
	f:EnableMouse (true)

	f:SetFrameStrata ("MEDIUM")

	local t = f:CreateTexture()
	t:SetColorTexture (.2, .2, .2, .5)
	t:SetAllPoints (f)
	f.texture = t

	f:Show()

	win:Attach (f, 0, .02, 0, -tbH)
--]]

	-- List

	Nx.List:SetCreateFont ("Font.Medium")

	local list = Nx.List:Create ("Social", 2, -2, 100, 12 * 3, win.Frm)
	self.List = list

	list:SetUser (self, self.OnListEvent)
--	list:SetLineHeight (12)

	list:ColumnAdd ("", 1, 80)
	list:ColumnAdd (L["Character"], 2, 110)
	list:ColumnAdd (L["Lvl"], 3, 30)
	list:ColumnAdd (L["Class"], 4, 65)
	list:ColumnAdd (L["Zone"], 5, 150)
	list:ColumnAdd (L["Note"], 6, 500)

	win:Attach (list.Frm, 0, 1, 0, -tbH)

	-- FF

	local ff = FriendsFrame
	self.FriendsFrame = ff

	self:SetLevels()

	-- Generic menu

	local function funcOpenOptions()
		Nx.Opts:Open (L["Social & Punks"])
	end

	-- Create pals menu

	local menu = Nx.Menu:Create (list.Frm, 230)
	self.PalsMenu = menu

	local function func (self)
		if self.MenuSelName then

			local box = ChatEdit_ChooseBoxForSend()	--V4
			ChatEdit_ActivateChat (box)
			box:SetText ("/w " .. self.MenuSelName .. " " .. box:GetText())
--[[
			local frm = DEFAULT_CHAT_FRAME
			local eb = frm["editBox"]
			if not eb:IsVisible() then
				ChatFrame_OpenChat ("/w " .. self.MenuSelName, frm)
			else
				eb:SetText ("/w " .. self.MenuSelName .. " " .. eb:GetText())
			end
--]]
		end
	end

	menu:AddItem (0, L["Whisper"], func, self)

	local function func (self)
		if self.MenuSelName then
			InviteUnit (self.MenuSelName)
		end
	end

	menu:AddItem (0, L["Invite"], func, self)

	menu:AddItem (0, "")

	local function func (self)
		if UnitIsPlayer ("target") and UnitCanCooperate ("player", "target") then
--			Nx.prt ("target %s", UnitName ("target"))
			C_FriendList.AddFriend (UnitName ("target"))			--V4 was C_FriendList.AddFriend ("target")
		else
			StaticPopup_Show ("ADD_FRIEND")
		end
	end

	menu:AddItem (0, L["Add Pal And Friend"], func, self)

	local function func (self)
		if self.MenuSelName then
			self:ClrFriend (self.MenuSelName)
			local i = self:FindFriendI (self.MenuSelName)
			if i then
				RemoveFriend (self.MenuSelName)
			else
				self:Update()
			end
		end
	end

	menu:AddItem (0, L["Remove Pal And Friend"], func, self)

	menu:AddItem (0, "")

	local function func (self)
		if self.MenuSelName then
			local i = self:FindFriendI (self.MenuSelName)
			if i then
				self.FriendsFrame["NotesID"] = i
				local name = GetFriendInfo (i)
				FriendsFrame.NotesID = name
				StaticPopup_Show ("SET_FRIENDNOTE", name)
			end
		end
	end

	self.PalMenuINote = menu:AddItem (0, L["Set Note"], func, self)
	menu:AddItem (0, L["Set Person"], self.Menu_OnSetPerson, self)

	menu:AddItem (0, "")

	menu:AddItem (0, L["Make Pal (Red) Into Friend"], self.Menu_OnMakePalFriend, self)
	menu:AddItem (0, L["Make All Pals Into Friends"], self.Menu_OnMakePalsFriends, self)

	menu:AddItem (0, "")
	menu:AddItem (0, L["Options..."], funcOpenOptions, self)

	-- Create punks menu

	local menu = Nx.Menu:Create (list.Frm)
	self.PunksMenu = menu

	local function func (self)
		self:GotoPunk (self.List.MenuSelName)
	end

	menu:AddItem (0, L["Goto"], func, Nx.Social)

	menu:AddItem (0, L["Add Character"], self.Menu_OnPunkAdd, self)
	menu:AddItem (0, L["Remove Character"], self.Menu_OnPunkRemove, self)

	menu:AddItem (0, L["Set Note"], self.Menu_OnPunkSetNote, self)

	local function func (self)
		Nx:ClearSocial ("PkAct")
		self.PunksActive = Nx:GetSocial ("PkAct")
	end

	menu:AddItem (0, L["Clear Actives"], func, Nx.Social)

	menu:AddItem (0, "")
	menu:AddItem (0, L["Options..."], funcOpenOptions, self)

end

function Nx.Social.List:SetLevels()

	local win = Nx.Social.Win
	local wf	= win.Frm
	local ff = self.FriendsFrame

	ff:SetToplevel (false)
--	ff:SetAlpha (1)

--	Nx.prt ("Lev1 "..wf:GetFrameLevel().." "..ff:GetFrameLevel())

	wf:Raise()

--	Nx.prt ("Lev2 "..wf:GetFrameLevel().." "..ff:GetFrameLevel())

	local f = _G["FriendsFrameCloseButton"]
	local lev = f:GetFrameLevel()
	ff:SetFrameLevel (lev - 1)
	wf:SetFrameLevel (lev - 2)

--	Nx.prt ("Lev3 "..wf:GetFrameLevel().." "..ff:GetFrameLevel())
end

function Nx.Social.List:Menu_OnSetPerson()

	if self.MenuSelName then
		local person = self:FindFriendPerson (self.MenuSelName) or ""
		Nx:ShowEditBox (L["Set person who owns character"], person, self.MenuSelName, self.SetPersonAccept)
	end
end

function Nx.Social.List.SetPersonAccept (person, friend)

	person = Nx.Util_CleanName (person)
	local list = Nx.Social.List
	list:SetPersonFriend (person, friend)
	list:Update()
end

function Nx.Social.List:Menu_OnMakePalFriend()
	if self.MenuSelName then
		C_FriendList.AddFriend (self.MenuSelName)
	end
end

function Nx.Social.List:Menu_OnMakePalsFriends()

	local pal = Nx:GetSocial ("Pal")

	for _, friends in pairs (pal) do
		for fName, v in pairs (friends) do
			if not self:FindFriendI (fName) then	-- Not a friend?
				C_FriendList.AddFriend (fName)
			end
		end
	end
end

function Nx.Social.List:Menu_OnPunkAdd()

	local name = UnitName ("target")

	if name and UnitIsPlayer ("target") and UnitIsEnemy ("player", "target") then
		self:PunkAdd (name, UnitLevel ("target"), UnitClass ("target"))
		self:Update()
	else
		Nx:ShowEditBox (L["Add punk name"], self.MenuSelName or Nx.Social.LastLocalPunk or "", self, self.PunkAddAccept)
	end
end

function Nx.Social.List.PunkAddAccept (name, list)

	list:PunkAdd (name)
	list:Update()
end

function Nx.Social.List:PunkAdd (name, level, class)

	local punks = Nx:GetSocial ("Pk")
	name = Nx.Util_CleanName (name)

	local punk = Nx.Social.PunksActive[name]
	if punk then
		level = level or punk.Lvl
		class = class or punk.Class
	end

	punks[name] = format ("%s~%s~%s", time(), level or "", class or "")
end

function Nx.Social.List:Menu_OnPunkRemove()
	if self.MenuSelName then
		local punks = Nx:GetSocial ("Pk")
		punks[self.MenuSelName] = nil
		self:Update()
	end
end

function Nx.Social.List:Menu_OnPunkSetNote()

	if self.MenuSelName then
		local punks = Nx:GetSocial ("Pk")
		local punk = punks[self.MenuSelName]

		if punk then
			self.MenuPunkName = self.MenuSelName
			local tm, lvl, class, note = strsplit ("~", punk)
			Nx:ShowEditBox (L["Set note"], note or "", self, self.PunkSetNote)
		end
	end
end

function Nx.Social.List.PunkSetNote (text, list)

	local punks = Nx:GetSocial ("Pk")
	local punk = punks[list.MenuPunkName]
	local tm, lvl, class, note = strsplit ("~", punk)
	punks[list.MenuPunkName] = format ("%s~%s~%s~%s", tm, lvl, class, text)
	list:Update()
end

---------------------------------------------------------------------------------------
-- On list control updates
---------------------------------------------------------------------------------------

function Nx.Social.List:OnListEvent (eventName, sel, val2, click)

	local name = self.List:ItemGetData (sel)
	self.SelName = name

	local tabI = Nx.Social.TabSelected

	if tabI == 1 then

		local i = self:FindFriendI (name)
		if i then
--			Nx.prt ("Sel %s", i)
			SetSelectedFriend (i)
		end
	end

	if eventName == "select" or eventName == "mid" or eventName == "back" then

	elseif eventName == "menu" then

--		Nx.prt ("OnListEvent %s", val2)

		self.MenuSelName = self.SelName

		if tabI == 1 then

			local i = self:FindFriendI (self.SelName)
			self.PalMenuINote:Show (i ~= nil)

			self.PalsMenu:Open()

		elseif tabI == 2 then
			self.PunksMenu:Open()

		else
			self.ComMenu:Open()
		end

	end
end

function Nx.Social.List:FindFriendI (friend)

	local cnt = C_FriendList.GetNumFriends()
	for n = 1, cnt do

		local name, level, class, area, connected, status, note = GetFriendInfo (n)

		if name == friend then
			return n
		end
	end
end

---------------------------------------------------------------------------------------
-- Find person who has friend
-- (friend name)
-- ret person name
---------------------------------------------------------------------------------------

function Nx.Social.List:FindFriendPerson (friend)

	local pal = Nx:GetSocial ("Pal")

	for person, friends in pairs (pal) do
		for fname, v in pairs (friends) do
			if friend == fname then
				return person
			end
		end
	end
end

function Nx.Social.List:SetPersonFriend (person, friend)

	self:ClrFriend (friend)

	local pal = Nx:GetSocial ("Pal")

	local friends = pal[person] or {}
	pal[person] = friends

	friends[friend] = ""
end

---------------------------------------------------------------------------------------
-- Clear friend from all persons
---------------------------------------------------------------------------------------

function Nx.Social.List:ClrFriend (friend)

	local pal = Nx:GetSocial ("Pal")

	for person, friends in pairs (pal) do
		friends[friend] = nil
--		Nx.prt ("delete %s", friend)

		if not next (friends) then		-- No friends left?
			if person ~= "" then
--				Nx.prt ("delete %s", person)
				pal[person] = nil
			end
		end
	end
end

function Nx.Social.List:Update()

--	Nx.prt ("SocialListUpdate")

	local soc = Nx.Social

	local win = soc.Win
	local list = self.List
	if not (win and list) then		-- Can be called with nil List if GuildProfiler present during create
		return
	end

	self.SelName = nil

	local pal = Nx:GetSocial ("Pal")
	local tabI = soc.TabSelected

	win:SetTitle ("")

	list:Empty()

	if tabI == 1 then

--PAIDS!
		list:ColumnSetName (1, L["Person"])

		-- Person A Char A
		-- Person A Char B
		-- Person B Char A

		local data = {}
		local f2p = {}
		local fConnected = {}

		for pName, friends in pairs (pal) do
			for fName, _ in pairs (friends) do
				tinsert (data, format ("%s~%s", pName, fName))
				f2p[fName] = pName
			end
		end

		local fI = {}

		local cnt = C_FriendList.GetNumFriends()

		for n = 1, cnt do
			local name, level, class, area, connected, status, note = GetFriendInfo (n)
			if name then

				fI[name] = n
				fConnected[name] = connected

				local pName = f2p[name]
				local pData = pal[pName or ""]

				if connected then
					pData[name] = format ("%s~%s", level, class)
				else
					pData[name] = pData[name] or ""	-- Keep last data or start a new entry
				end

				if not pName then
					tinsert (data, format ("~%s", name))
				end
			end
		end

		local function func (a, b)
			local pName1, fName1 = strsplit ("~", a)
			local pName2, fName2 = strsplit ("~", b)

			if fConnected[fName1] and not fConnected[fName2] then
				return true
			end
			if not fConnected[fName1] and fConnected[fName2] then
				return false
			end

			if pName1 == pName2 then
				return fName1 < fName2
			end
			if pName1 == "" then
				return false
			end
			if pName2 == "" then
				return true
			end

			return pName1 < pName2
		end

		sort (data, func)

		win:SetTitle (format (L["Pals: |cffffffff%d/%d"], cnt, 50))

		for _, plyr in ipairs (data) do

			local pName, fName = strsplit ("~", plyr)
			local i = fI[fName]

			list:ItemAdd (fName)

			local conCol = fConnected[fName] and "|cff80f080" or "|cff808080"

			if #pName > 0 then
				list:ItemSet (1, conCol .. pName)
			end

			if not i then
				conCol = "|cfff04040"
			end

			list:ItemSet (2, conCol .. fName)

			local name, level, class, area, connected, status, note

			if i then
				name, level, class, area, connected, status, note = GetFriendInfo (i)
			end

			if connected then
				list:ItemSet (5, area)
			else
				local pData = pal[pName]
				level, class = strsplit ("~", pData[fName])
			end

			if level ~= "" then
				list:ItemSet (3, format ("%s", level))
				local color = Nx.ClassColorStrs[NXClassLocToCap[class]] or ""
				list:ItemSet (4, color .. class)
			end

			local s = status or ""

			if note then
				s = s .. " " .. note
			end

			list:ItemSet (6, s)
		end
--PAIDE!

	elseif tabI == 2 then

		list:ColumnSetName (1, L["Status"])

		local punks = soc.Punks
		local punksA = soc.PunksActive

		local tm = GetTime()
		local myCnt = 0
		local actCnt = 0

		local data = {}

		for pName, str in pairs (punks) do
			tinsert (data, pName)
		end

		sort (data)

		for _, pName in ipairs (data) do

			myCnt = myCnt + 1

			local tm, lvl, class, note = strsplit ("~", punks[pName])

			list:ItemAdd (pName)

			if punksA[pName] then
				list:ItemSet (1, L["|cffff6060Found"])
			end
			list:ItemSet (2, pName)

			if lvl and lvl ~= 0 then
				list:ItemSet (3, tostring (lvl))
			end

			if class then
				local color = Nx.ClassColorStrs[NXClassLocToCap[class]] or ""
				list:ItemSet (4, color .. class)
			end

			if note and #note > 0 then
				list:ItemSet (6, note)
			end
		end

		list:ItemAdd()
		list:ItemAdd()
		list:ItemSet (2, L["|cff8080ff-- Active --"])

		local data = {}

		for pName in pairs (punksA) do
--			Nx.prt ("PkList %s", pName)
			tinsert (data, pName)
		end

--		Nx.prtVar ("", data)

		sort (data)

		for _, pName in ipairs (data) do

			actCnt = actCnt + 1

			local punk = punksA[pName]

			list:ItemAdd (pName)
			local seconds = tm - punk.Time
			list:ItemSet (1, format ("%d:%02d", seconds / 60 % 60, seconds % 60))

			local name = punks[pName] and pName or ("|cffafafaf" .. pName)
			list:ItemSet (2, name)
			if punk.Lvl ~= 0 then
				list:ItemSet (3, tostring (punk.Lvl))
			end
			if punk.Class then
				list:ItemSet (4, punk.Class)
			end
			local mapName = Nx.Map:GetMapNameByID(punk.MId) or "?"
			list:ItemSet (5, format ("%s %d %d", mapName, punk.X, punk.Y))

			list:ItemSet (6, format (L["Near %s"], punk.FinderName))
		end

		win:SetTitle (format (L["Punks: %s  Active: %s"], myCnt, actCnt))

	elseif Nx.db.profile.Debug.VerDebug and tabI == 3 then

		local actCnt = Nx.Util_tcount (Nx.Quest.CapturePlyrData)

		for _, data in pairs (Nx.Quest.CapturePlyrData) do
			list:ItemAdd()
			list:ItemSet (2, data.Name)
			list:ItemSet (3, data.Level)
			list:ItemSet (6, format ("%s/%s", data.RcvCnt, data.Total))
		end

		if actCnt > 0 then
			list:ItemAdd()
		end

		local data = Nx.Com:SortUserQuests()

		local cnt = 0
		local qcnt = 0

		for n, msg in ipairs (data) do

			local name, ver, r, c, dt, ver1, qCnt, lvl, mId = strsplit ("^", msg)
			ver = tonumber (ver)

			cnt = cnt + 1
			qcnt = qcnt + (qCnt or 0)

			list:ItemAdd()
			list:ItemSet (2, name)
			if lvl then
				list:ItemSet (3, tostring (tonumber (lvl, 16)))
			end

			if mId then
				local name = Nx.Map:GetMapNameByID(tonumber (mId, 16)) or "?"
				list:ItemSet (5, name)
			end

			local i = strfind (msg, "%^")
			if i then
				msg = strsub (msg, i + 1)
			end
			list:ItemSet (6, msg)
		end

		local capCnt = Nx.Util_tcount (Nx:GetCap()["Q"])

		win:SetTitle (format (L["Total: %s Q%s, active %s, data %s"], cnt, qcnt, actCnt, capCnt))
	end

	list:Update()
end

---------------------------------------------------------------------------------------
-- Punks management
---------------------------------------------------------------------------------------

function Nx.Social:DecodeComRcvPunks (finderName, info, punksStr)

--	Nx.prt ("%s: %s %s %s", finderName, punksStr, info.X, info.Y)
	if not punksStr or #punksStr < 1 then
		return
	end
	local punksT = { strsplit ("!", punksStr) }

	for n, v in ipairs (punksT) do

		local lvl = tonumber (strsub (v, 1, 2), 16)
		if not lvl then	-- Error?
			break
		end

		local name = strsub (v, 3)
		if lvl >= 0xff then
			name = strsub (v, 9)
			lvl = 0
		end
		if Nx.scdb.profile.Social.PunkEnable then
			if info.MId < 1000 then
				local punk = self:GetPunk (name, nil, info.MId, info.X, info.Y)
				punk.FinderName = finderName
				punk.Lvl = max (lvl, punk.Lvl or 0)
				punk.Time = info.T
			end
		end
	end

	if Nx:TimeLeft(SocialUpdate) == 0 then
		SocialUpdate = Nx:ScheduleTimer(self.OnUpdateTimer,2,self)
	end
	Nx.TEMPname = nil
	Nx.TEMPinfo = nil
	Nx.TEMPmsg = nil
end

---------------------------------------------------------------------------------------
-- Add a punk we detected ourselves
---------------------------------------------------------------------------------------

function Nx.Social:AddLocalPunk (name, plyrNear, level, class)

--	Nx.prt ("AddLocalPunk %s", name)
	if Nx.scdb.profile.Social.PunkEnable then
	if Nx.InBG and not plyrNear then
		return
	end

	local map = Nx.Map:GetMap (1)

	name = strmatch (name, "[^-]+")		-- Remove server name

	self.LastLocalPunk = name

	local rMapId = map.UpdateMapID
	local x, y = map.PlyrRZX, map.PlyrRZY

	if plyrNear then

		plyrNear = strmatch (plyrNear, "[^-]+")		-- Remove server name
		local i = Nx.GroupMembers[plyrNear]

		if i then

			local unit = Nx.GroupType .. i
			local s = UnitName (unit)
			if s then

				local pX, pY = Nx.Map.GetPlayerMapPosition (unit)

				if pX ~= 0 or pY ~= 0 then
					x = pX * 100
					y = pY * 100
				end

				-- DEBUG!
--				if IsControlKeyDown() then
--					Nx.prt ("Local punk %s near %s #%s %s %s", name, plyrNear, i, x, y)
--				end
			end
		end
	end

	-- DEBUG!
--	if IsControlKeyDown() then
--		Nx.prt ("-Local punk %s near %s %s %s", name, plyrNear or "nil", x, y)
--	end

	local punk = self:GetPunk (name, plyrNear, rMapId, x, y)
	if not punk.Time and not Nx.InBG and Nx.scdb.profile.Social.PunkNewLocalWarnChat then	-- New?

		if not Nx.InSanctuary or Nx.scdb.profile.Social.PunkShowInSafeArea then
			local typ = self.Punks[name] and L["|cffff4040Punk"] or L["Enemy"]
			Nx.prt (L["%s %s detected near you"], typ, name)
			if Nx.scdb.profile.Social.PunkNewLocalWarnSnd then
				Nx:PlaySoundFile (566027)
			end
		end
	end

	punk.FinderName = "me"		-- Maybe replace with translation string. Must take a look
	punk.Lvl = level or punk.Lvl or 0
	punk.Class = class or punk.Class
	if not punk.Time or GetTime() - punk.Time > 2 then
		punk.Time = GetTime()
	end

	if Nx:TimeLeft(SocialUpdate) == 0 then
		SocialUpdate = Nx:ScheduleTimer(self.OnUpdateTimer,2,self)
	end

	self.PunksHUD:Add (name)
	end
end

---------------------------------------------------------------------------------------

function Nx.Social:GetPunk (name, plyrNear, mId, x, y)
	if Nx.scdb.profile.Social.PunkEnable then
	local punk = self.PunksActive[name]
	if not punk then
		punk = {}
		self.PunksActive[name] = punk

		punk.DrawDir = self.PunkNewDir

		self.PunkNewDir = self.PunkNewDir + 3.14159 / 4.25

		punk.CircleTime = GetTime()
	end

	if not Nx.InBG or not punk.PlyrNear or plyrNear and plyrNear ~= punk.PlyrNear then

--		Nx.prt ("Punk %s near %s %s %s", name, plyrNear or "nil", x, y)

		punk.PlyrNear = plyrNear
		punk.MId = mId
		punk.X = x
		punk.Y = y
	end

--	punk.Alert = nil

	if not punk.Alert and self.Punks[name] then

		self.PunksHUD:Add (name)

		if Nx.scdb.profile.Social.PunkMAlertText then

			local tm, lvl, class, note = strsplit ("~", self.Punks[name])

--			note = "Test note. xyz. abc 12213213872xxx"

			if note then
				UIErrorsFrame:AddMessage (format (L["Note: %s"], note), 1, 0, 1, 1)
			end

			local map = Nx.Map:GetMap (1)
			local wx, wy = map:GetWorldPos (mId, x, y)
			local dist = ((map.PlyrX - wx) ^ 2 + (map.PlyrY - wy) ^ 2) ^ .5 * 4.575
			local s = dist < 100 and L["|cffff4000near you"] or format (L["at %d yards"], dist)

			UIErrorsFrame:AddMessage (format (L["|cffff4000%s|r detected %s!"], name, s), 1, 1, 0, 1)
		end
		if Nx.scdb.profile.Social.PunkMAlertSnd then
			Nx:PlaySoundFile (568986)
		end
		punk.Alert = true
	end

	if GetTime() - punk.CircleTime > 4 then	-- Long enough for visual refresh?
		punk.CircleTime = GetTime()
	end

	return punk
	end
end

---------------------------------------------------------------------------------------

function Nx.Social:OnUpdateTimer()

	if not Nx.scdb.profile.Social.PunkEnable then
		return 3
	end

	self:CalcPunks()

	-- Check tab selection first, since they could be nil
	if self.TabSelected == 2 and self.Win:IsShown() then
		self.List:Update()
		return 3
	end
end

---------------------------------------------------------------------------------------
-- Update punks data
---------------------------------------------------------------------------------------

function Nx.Social:CalcPunks()

	local punks = self.Punks
	local punksA = self.PunksActive
	local tm = GetTime() - (Nx.InBG and 30 or 90)				-- Expire time (1.5 min)

	for pName, punk in pairs (punksA) do

		if punks[pName] then					-- On our list?
			if tm - 240 > punk.Time then	-- Expired? (5 mins)
				punksA[pName] = nil
				self.PunksHUD:Remove (pName)
			end
		else
			if tm > punk.Time then			-- Expired?
				punksA[pName] = nil
				self.PunksHUD:Remove (pName)
			end
		end
	end
end

---------------------------------------------------------------------------------------
-- Update map icons (called by map)
---------------------------------------------------------------------------------------

function Nx.Social:UpdateIcons (map)
	if Nx.scdb.profile.Social.PunkEnable then
		if Nx.Tick % 120 == 4 then
			self:CalcPunks()
		end

		local math = math
		local alt = IsAltKeyDown()
		local tm = GetTime()

		local punks = self.Punks
		local punksA = self.PunksActive

		local size = Nx.scdb.profile.Social.PunkAreaSize * map.ScaleDraw
		local sizeM = Nx.scdb.profile.Social.PunkMAreaSize * map.ScaleDraw

		local areaR, areaG, areaB = Nx.Social.Cols["areaR"], Nx.Social.Cols["areaG"], Nx.Social.Cols["areaB"]
		local iconR, iconG, iconB, iconA = Nx.Social.Cols["iconR"], Nx.Social.Cols["iconG"], Nx.Social.Cols["iconB"], Nx.Social.Cols["iconA"]
		local areaRM, areaGM, areaBM = Nx.Social.Cols["areaRM"], Nx.Social.Cols["areaGM"], Nx.Social.Cols["areaBM"]

		local showInSafeArea = Nx.scdb.profile.Social.PunkShowInSafeArea

		local decay = .24
		local decayM = .21

		local inBG = Nx.InBG

		if inBG then
			if not Nx.scdb.profile.Social.PunkShowInBG or Nx.Free then
				return
			end

			size = Nx.scdb.profile.Social.PunkBGAreaSize * map.ScaleDraw
			areaR = Nx.Social.Cols["areaBGR"]
			areaG = Nx.Social.Cols["areaBGG"]
			areaB = Nx.Social.Cols["areaBGB"]

			local decay = 2
			local decayM = .25
		end

		local iconGlow = abs (GetTime() * 400 % 200 - 100) / 400 + .75

		if alt then
			map.Level = map.Level + 11
		end

		for pName, punk in pairs (punksA) do

			local dur = tm - punk.Time
			local circleDur = tm - punk.CircleTime
			local punkMId = punk.MId
			if punkMId < 1000 then			---- Work around to stop chat spam, to be removed at a later time when everyone is on official carbonite.
				local wx, wy = map:GetWorldPos (punkMId, punk.X, punk.Y)
				local x = wx + math.sin (punk.DrawDir) * 2
				local y = wy + math.cos (punk.DrawDir) * 2
				if punks[pName] then	-- Punk match?
					local sz = sizeM / (circleDur * decayM + 1)
					if sz >= 1 then
						sz = max (sz, 25)
						local f = map:GetIconNI()
						if map:ClipFrameW (f, x, y, sz, sz, 0) then
							f.texture:SetBlendMode ("ADD")
							f.texture:SetTexture ("Interface\\AddOns\\Carbonite\\Gfx\\Map\\IconCircle")
							if dur < .1 then
								f.texture:SetVertexColor (.3, 1, .3, 1)
							else
								f.texture:SetVertexColor (areaRM, areaGM, areaBM, 1)
							end
						end
					end
				else
					if (not Nx.InSanctuary or showInSafeArea) then
						local sz = size / (circleDur * decay + 1)
						if sz >= 1 then
							sz = max (sz, 22)
							local f = map:GetIconNI()
							if map:ClipFrameW (f, x, y, sz, sz, 0) then
								f.texture:SetBlendMode ("ADD")
								f.texture:SetTexture ("Interface\\AddOns\\Carbonite\\Gfx\\Map\\IconCircle")
								if dur < .05 then
									if inBG then
										f.texture:SetVertexColor (.15, .15, .15, 1)
									else
										f.texture:SetVertexColor (.25, .25, .25, 1)
									end
								else
									f.texture:SetVertexColor (areaR, areaG, areaB, 1)
								end
							end
						end
					end
				end
			-- Draw punk dot
				if punks[pName] then	-- Punk match?
					local f = map:GetIcon (2)
					if map:ClipFrameW (f, x, y, 14, 14, 0) then
						local lvl = punk.Lvl > 0 and punk.Lvl or "?"
						local mapName = Nx.Map:GetMapNameByID(punkMId) or "?"
						f.NxTip = format (L["*|cffff0000%s %s, %d:%02d ago\n%s (%d,%d)"], pName, lvl, dur / 60 % 60, dur % 60, mapName, punk.X, punk.Y)
						f.NXType = 3001
						f.NXData = pName
						f.texture:SetTexture ("Interface\\AddOns\\Carbonite\\Gfx\\Map\\IconPlyrZ")
						f.texture:SetVertexColor (iconR, iconG, iconB, iconA * iconGlow)
						if alt then
							local txt = map:GetText (format ("*|cffff0000%s|r*", pName))
							map:MoveTextToIcon (txt, f, 18, 1)
						end
					end
				else
					if (not Nx.InSanctuary or showInSafeArea) then
						local i = dur < 10 and 2 or 1
						local f = map:GetIcon (i)
						if map:ClipFrameW (f, x, y, 10, 10, 0) then
							local lvl = punk.Lvl > 0 and punk.Lvl or "?"
							local mapName = Nx.Map:GetMapNameByID(punkMId) or "?"
							f.NxTip = format (L["|cffff6060%s %s, %d:%02d ago\n%s (%d,%d)"], pName, lvl, dur / 60 % 60, dur % 60, mapName, punk.X, punk.Y)
							f.NXType = 3001
							f.NXData = pName
							f.texture:SetTexture ("Interface\\AddOns\\Carbonite\\Gfx\\Map\\IconPlyrZ")
							if dur < 10 then
								f.texture:SetVertexColor (iconR, iconG, iconB, iconA * iconGlow)
							else
								f.texture:SetVertexColor (iconR, iconG, iconB, iconA * .6)
							end
						end
					end
				end
			end
		end
		if alt then
			map.Level = map.Level - 11
		else
			map.Level = map.Level + 3
		end
	end
end

---------------------------------------------------------------------------------------
-- Goto a named punk
---------------------------------------------------------------------------------------

function Nx.Social:GotoPunk (name)
	local punk = self.PunksActive[name]
	if punk.MId < 1000 then --- WORK AROUND
		if punk then
			local map = Nx.Map:GetMap (1)
			local wx, wy = map:GetWorldPos (punk.MId, punk.X, punk.Y)
			local x = wx + math.sin (punk.DrawDir) * 2
			local y = wy + math.cos (punk.DrawDir) * 2
			map:SetTarget (L["Goto"], x, y, x, y, false, 0, name)
		end
	end
end

---------------------------------------------------------------------------------------
-- Get a named punks paste info
---------------------------------------------------------------------------------------

function Nx.Social:GetPunkPasteInfo (name)

	local punk = self.PunksActive[name]
	if punk then

		local lvl = punk.Lvl > 0 and punk.Lvl or "?"
		local class = punk.Class or "?"
		return format (L["Punk: %s, %s %s at %s %d %d"], name, lvl, class, Nx.Map:GetMapNameByID(punk.MId) or "?", punk.X, punk.Y)
	end

	return ""
end

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
-- Create punk HUD
---------------------------------------------------------------------------------------

function Nx.Social.PunksHUD:Create()

	self.Punks = {}
	self.Buts = {}
	self.NumButs = Nx.scdb.profile.Social.PunkTWinMaxButs
	self.NumButsUsed = 0

	self.Changed = true

	-- Create Window

--	Nx.Window:ClrSaveData ("NxPunkHUD")		-- DEBUG!

	Nx.Window:SetCreateFade (.5, 0)

	local win = Nx.Window:Create ("NxPunkHUD", nil, nil, true, 1, 1, nil, true)
	self.Win = win

	win:InitLayoutData (nil, -.6, -.1, 128, 68)

--	win:CreateButtons (nil, true)

	win:SetBGAlpha (0, .5)
	win.Frm:SetToplevel (true)

	-- Create buttons

	local ox, oy = win:GetClientOffset()
	local x = ox - 2
	local y = -oy

	for n = 1, self.NumButs do

--		Nx.prt ("But #%s create", n)

		local but = CreateFrame ("Button", nil, win.Frm, "SecureUnitButtonTemplate")
		self.Buts[n] = but

		but:SetPoint ("TOPLEFT", x, y)
		y = y - 13

		but:SetAttribute ("type1", "macro")
--		but:SetAttribute ("macrotext1", "/targetenemy")

--		but:SetAttribute ("type2", "target")
--		but:SetAttribute ("unit", "player")

		but:SetAttribute ("*type2", "click")
		but:SetAttribute ("*clickbutton2", but)

		but["Click"] = Nx.Social.PunksHUD.Click

		but:RegisterForClicks ("LeftButtonDown", "RightButtonDown")

		local t = but:CreateTexture()
		t:SetColorTexture (1, 1, 1, 1)
		t:SetAllPoints (but)
		but.texture = t

		but:SetWidth (125)
		but:SetHeight (12)

		but:Hide()

		local fstr = but:CreateFontString()
		but.NXFStr = fstr
		fstr:SetFontObject ("GameFontNormalSmall")
		fstr:SetJustifyH ("LEFT")
		fstr:SetPoint ("TOPLEFT", 0, 1)
		fstr:SetWidth (125)
		fstr:SetHeight (12)
	end

--PAIDE!

end

---------------------------------------------------------------------------------------
-- SecureTemplates Click handler
-- self is button frame
---------------------------------------------------------------------------------------

function Nx.Social.PunksHUD:Click()

	local but = self
--	Nx.prt ("click %s", but.NXName or "nil")

	if IsShiftKeyDown() then
		Nx.Social.List:PunkAdd (but.NXName)
		Nx.prt (L["Punk %s added"], but.NXName or "")
	else
		Nx.Social.PunksHUD:Remove (but.NXName)
	end
end

---------------------------------------------------------------------------------------

function Nx.Social.PunksHUD:Add (name)

--PAIDS!

	if not self.Punks[name] then

		local punks = Nx.Social.Punks

		if punks[name] then		-- Match?
			tinsert (self.Punks, 1, name)		-- Top of list

		else
			local found
			for n = 1, #self.Punks do
				if not punks[self.Punks[n]] then
					tinsert (self.Punks, n, name)		-- Top of non matches
					found = true
					break
				end
			end
			if not found then
				tinsert (self.Punks, name)		-- End
			end
		end
	end

	self.Punks[name] = true
	self.Changed = true

--PAIDE!
end

---------------------------------------------------------------------------------------

function Nx.Social.PunksHUD:Remove (name)

--PAIDS!

	for n = 1, #self.Punks do
		if self.Punks[n] == name then
			tremove (self.Punks, n)
			break
		end
	end

	self.Punks[name] = nil
	self.Changed = true

--PAIDE!
end

---------------------------------------------------------------------------------------

function Nx.Social.PunksHUD:Update()

--PAIDS!

	if not self.Win then
		return
	end

	local Social = Nx.Social

	if self.Changed then

		local lockDown = InCombatLockdown() ~= false
		local lchanged = self.LockedDown ~= lockDown
		self.LockedDown = lockDown

		if not lockDown then

			self.Changed = false

			local punks = Social.Punks
			local punksA = Social.PunksActive

			local n = 1

			for index, name in ipairs (self.Punks) do

				local punk = self.Punks[name]

--				Nx.prt ("But #%s update %s", n, name)

				local but = self.Buts[n]

				local function func (self)
					Nx.prt (L["hey"])
				end

				but:SetAttribute ("macrotext1", "/targetexact " .. name)
--				but:SetAttribute ("shift-macrotext1", "/target " .. name .. "-target")

				but.NXName = name

				local s = name

				if punks[name] then	-- Match?
					s = "|cffff80ff*" .. name
				end

				local class = punksA[name] and punksA[name].Class
				if class then
					s = s .. ", |cffa0a0a0" .. class
				end

				but.NXFStr:SetText (s)
				but:Show()

				n = n + 1
				if n > self.NumButs then
					break
				end
			end

			self.NumButsUsed = n - 1

			for i = n, self.NumButs do
				local but = self.Buts[i]
				but:Hide()
			end

			self.Win:SetSize (120, n * 13 - 15)
		end

		if lchanged then

			local win = self.Win

			if lockDown then
				win:SetTitle ("|cffff2020" .. Nx.scdb.profile.Social.PunkTWinTitle)
			else
				win:SetTitle (Nx.scdb.profile.Social.PunkTWinTitle)
			end
		end
	end

	--

	local punksA = Social.PunksActive
	local tm = GetTime()

	for n = 1, self.NumButsUsed do

		local but = self.Buts[n]
		local punk = punksA[but.NXName]
		if punk then

			local dur = tm - punk.Time
			dur = dur < .3 and dur or dur * .05 + .285		-- Quick pulse, then slow fade
--			Nx.prt ("Punk #%s %s", n, dur)
			local r = min (max (1 - dur, .1), 1)
			but.texture:SetVertexColor (r, 0, 0, .5)
		end
	end

--PAIDE!
end

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
-- Create group HUD
---------------------------------------------------------------------------------------

function Nx.Social.TeamHUD:Create()

	if not Nx.scdb.profile.Social.TeamTWinEnable then
		return
	end

	self.Players = {}

	for n = 1, MAX_RAID_MEMBERS do
		local data = {}
		data.Dist = 999999999
		self.Players[n] = data
	end

	self.Buts = {}
	self.NumButs = Nx.scdb.profile.Social.TeamTWinMaxButs
	self.HealthFrms = {}
	self.FStrs = {}

	self.UpdateTime = 0

	-- Create Window

--	Nx.Window:ClrSaveData ("NxTeamHUD")		-- DEBUG!

	Nx.Window:SetCreateFade (.5, 0)

	local win = Nx.Window:Create ("NxTeamHUD", 20, nil, true, 1, nil, true, true)	-- Hidden
	self.Win = win

	win:SetBGAlpha (0, 1)

	win:InitLayoutData (nil, -.6, -.3, 100, 10)

--	win:CreateButtons (nil, true)

	win.Frm:SetToplevel (true)

	-- Create buttons

	local ox, oy = win:GetClientOffset()
	local x = ox - 2
	local y = -oy

	for n = 1, self.NumButs do

--		Nx.prt ("But #%s create", n)

		local but = CreateFrame ("Button", nil, win.Frm, "SecureUnitButtonTemplate")
		self.Buts[n] = but

		but:SetPoint ("TOPLEFT", x, y)
		y = y - 14

		if n == 1 then
			but:SetAttribute ("type", "target")
			but:SetAttribute ("unit1", "player")
			but:SetAttribute ("unit2", "targetenemy")
		else
			but:SetAttribute ("type", "macro")
			but:Hide()
		end

		but:RegisterForClicks ("LeftButtonDown", "RightButtonDown")

		local t = but:CreateTexture()
		t:SetColorTexture (0, .1, 0, .9)
		t:SetAllPoints (but)
		but.texture = t

		but:SetWidth (50)
		but:SetHeight (12)

		local f = CreateFrame ("Frame", nil, but)
		self.HealthFrms[n] = f

		f:SetPoint ("TOPLEFT", 0, 0)

		local t = f:CreateTexture()
--		t:SetColorTexture (0, .1, 0, .4)
		t:SetAllPoints (f)
		f.texture = t

--		f:SetWidth (50)
		f:SetHeight (12)

		local fstr = f:CreateFontString()
		self.FStrs[n] = fstr
		fstr:SetAllPoints (but)
		fstr:SetFontObject ("GameFontNormalSmall")
		fstr:SetJustifyH ("LEFT")
		fstr:SetPoint ("TOPLEFT", 0, 0)
		fstr:SetWidth (50)
		fstr:SetHeight (12)

		fstr:SetText ("Me")
	end

--PAIDE!
end

---------------------------------------------------------------------------------------

function Nx.Social.TeamHUD:Update()

--PAIDS!

	if not self.Win or not self.Win.Frm:IsVisible() then
		return
	end

	local tm = GetTime()
	local update = tm - self.UpdateTime > 1
	if update then
		self.UpdateTime = tm
	end

	local cw, ch = self.Win:GetSize()

	local Social = Nx.Social
	local lockDown = InCombatLockdown() ~= false
	local lchanged = self.LockedDown ~= lockDown
	self.LockedDown = lockDown

	if update and not lockDown then

		local Map = Nx.Map
		local map = Map:GetMap (1)
		local mapId, plX, plY = map.UpdateMapID, map.PlyrRZX, map.PlyrRZY
		local plX, plY = Map:GetWorldPos (mapId, plX, plY)

		local inArena = Nx.InArena

		local members = MAX_PARTY_MEMBERS
		local unitName = "party"
		local maxDist = 999999990

		if IsInRaid() then		-- Arenas are raids
			members = MAX_RAID_MEMBERS
			unitName = "raid"
			maxDist = 250
		end

		for n = 1, members do

			local player = self.Players[n]

			local unit = unitName .. n
			local name = UnitName (unit)
			player.Name = name or "zzz"

--			if IsControlKeyDown() then
--				Nx.prt ("%s %s", n, name or "nil")
--			end

			player.Dist = 999999999

			if name and not UnitIsUnit (unit, "player") then

				player.Unit = unit

--				Nx.prt ("Pal %s %s", name, per)

				local pX, pY = Nx.Map.GetPlayerMapPosition (unit)

				if pX == 0 then
					player.Dist = 999999
				else

					pX = pX * 100
					pY = pY * 100

					local wx, wy = Map:GetWorldPos (map.MapId, pX, pY)
					local dist = (plX - wx) ^ 2 + (plY - wy) ^ 2
					player.Dist = dist ^ .5 * 4.575
				end
			end
		end

		if not lockDown then

			if inArena then
				sort (self.Players, function (a, b) return a.Name < b.Name end)
			else
				local func = function (a, b)
						if a.Dist < 100 then
							if b.Dist < 100 then
								return a.Name < b.Name
							end
							return true
						else
							if b.Dist < 100 then
								return false
							end
							return a.Dist < b.Dist
						end
						return a.Name < b.Name
					end
				sort (self.Players, func)
			end

			local but = self.Buts[1]
			but:SetWidth (cw)

			local n = 2

			for index, player in ipairs (self.Players) do

				player.But = nil

				if player.Dist < maxDist or player.Dist == 999999 then

					local name = player.Name

--					Nx.prt ("But #%s update %s", n, name)

					local but = self.Buts[n]
					player.But = but
					player.FrmI = n

					but:SetAttribute ("macrotext1", "/targetexact " .. name)
					but:SetAttribute ("macrotext2", "/target " .. name .. "-target")

					but:SetWidth (cw)
					but:Show()

					local f = self.HealthFrms[n]
					player.HealthFrm = f

					n = n + 1
					if n > self.NumButs then
						break
					end
				end
			end

			for i = n, self.NumButs do
				local but = self.Buts[i]
				but:Hide()
			end

			self.Win:SetSize (cw, n * 14 - 14)
		end
	end

	-- Update text

	local fstr = self.FStrs[1]

	local h = UnitIsDeadOrGhost ("player") and 0 or UnitHealth ("player")
	local per = min (h / UnitHealthMax ("player"), 1)		-- Can overflow?

--	Nx.prt ("%s %s", h, per)
	local f = self.HealthFrms[1]
	f:SetWidth (per * cw + 1)
	f.texture:SetColorTexture (1 - per, per, 0, .5)

	local plTarget = UnitName ("target")

	for index, player in ipairs (self.Players) do

		local but = player.But
		if but then

			local unit = player.Unit

			local h = UnitIsDeadOrGhost (unit) and 0 or UnitHealth (unit)
			local per = min (h / UnitHealthMax (unit), 1)		-- Can overflow?

			local f = player.HealthFrm
			f:SetWidth (per * cw + 1)
			f.texture:SetColorTexture (.6 - per * .6, per * .6, 0, .7)

			local name = player.Name
--			local cls = UnitClass (unit) or ""
			local targetStr = plTarget == name and "|cff8080ff>" or ""
			local combatStr = UnitAffectingCombat (unit) and "|cffff4040*" or ""
			local colStr = player.Dist < 41 and "|cffc0ffc0" or "|cff808080"
			local distStr = player.Dist ~= 999999 and format ("%d " .. L["yds"], player.Dist) or ""
			local s = format ("%s%s%s%s %s", targetStr, combatStr, colStr, name, distStr)

			self.FStrs[player.FrmI]:SetText (s)
		end
	end

	if lchanged then

		local win = self.Win

		if lockDown then
			win:SetTitle (L["|cffff2020Team:"])
		else
			win:SetTitle (L["Team:"])
		end
	end

--PAIDE!
end

function Nx.Social.PShowUIPanel (frame)
	if frame then
		if frame == _G["FriendsFrame"] and Nx.scdb.profile.Social.SocialEnable then
			Nx.Social:ShowUIPanel (frame)
		else
			if not InCombatLockdown() then
				frame:Raise()
			end
		end
	end
end

function Nx.Social.PHideUIPanel (frame)
	if frame then
		if frame == _G["FriendsFrame"] and Nx.scdb.profile.Social.SocialEnable then
			Nx.Social:HideUIPanel (frame)
		end
	end
end

function Nx.Social.PCloseWindows()
	if not InCombatLockdown() then
		Nx.Social:HideUIPanel (_G["FriendsFrame"])		-- Causing taint in BGs
	end
end


---------------------------------------------------------------------------------------
-- Get Social data
---------------------------------------------------------------------------------------

function Nx:GetSocial (typ)
	local rn = GetRealmName()
	return Nx.scdb.profile.SocialData[rn][typ]
end

---------------------------------------------------------------------------------------
-- Clear Social data
---------------------------------------------------------------------------------------

function Nx:ClearSocial (typ)
	local rn = GetRealmName()
	Nx.scdb.profile.SocialData[rn][typ] = {}
end

function CarboniteSocial:OnCombat_log_event_unfiltered (event, ...)
	local timestamp, event, hideCaster, sId, sName, sFlags, sFlags2, dId, dName, dFlags, dFlags = CombatLogGetCurrentEventInfo()

	if sName and bit.band (sFlags, 0x440) == 0x440 then
--		Nx.prt ("punk-s %s", sName)
		local near
		if dName and bit.band (dFlags, 0x440) == 0x400 then
			near = dName
		end
		Nx.Social:AddLocalPunk (sName, near)
		if not Nx.InBG then
			Nx.Com.Punks[sName] = 0
		end
	end
	if dName and dName ~= sName and bit.band (dFlags, 0x440) == 0x440 then
--		Nx.prt ("punk-d %s", dName)
		local near
		if sName and bit.band (sFlags, 0x440) == 0x400 then
			near = sName
		end
		Nx.Social:AddLocalPunk (dName, near)
		if not Nx.InBG then
			Nx.Com.Punks[dName] = 0
		end
	end
end

---------------------------------------------------------------------------------------
-- EOF
