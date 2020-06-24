---------------------------------------------------------------------------------------
-- NxQuest - Quest stuff
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
-- Quest General
---------------------------------------------------------------------------------------

local _G = getfenv(0)

CarboniteQuest = LibStub("AceAddon-3.0"):NewAddon("Carbonite.Quest", "AceEvent-3.0", "AceComm-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Carbonite.Quest", true)

Nx.VERSIONQOPTS		= .12				-- Quest options
Nx.VERSIONCAP		= .80
Nx.Quest = {}
Nx.Quest.List = {}
Nx.Quest.AcceptPool = {}
Nx.Quest.Watch = {}
Nx.Quest.WQList = {}
Nx.Quest.Cols = {}
Nx.Quests = {}
Nx.qdb = {}
Nx.Quest.Tick = 0
Nx.QInit = false
Nx.Quest.Custom = {}
Nx.Quest.OldMap = 0
-- Keybindings
BINDING_HEADER_CarboniteQuests	= "|cffc0c0ff" .. L["Carbonite Quests"] .. "|r"
BINDING_NAME_NxTOGGLEWATCHMINI	= L["NxTOGGLEWATCHMINI"]
BINDING_NAME_NxWATCHUSEITEM	= L["NxWATCHUSEITEM"]

local IsClassic = select(4, GetBuildInfo()) < 20000


function Nx.List:Update (showLast)

	if self.SortColumnId and not self.Sorted then
		self:Sort()
	end

	local lineH = self:GetLineH()
	local hdrH = self.HdrH

--	Nx.prt ("List lineH %s", lineH)

	if showLast then
		self:ShowLast()
	end

	if self.ShowAll then
		self:Resize (0, 0)
	end

	self.Top = min (self.Top, self.Num - self.Vis + 1)
	self.Top = max (self.Top, 1)

	self.Selected = min (self.Selected, self.Num)

	local last = self.Top + self.Vis - 1
	last = min (last, self.Num)

	if self.Offsets or #self.Strs < self.Vis then
		self:CreateStrings()
	end

	local strNum = 1
	local cNum = 1

	for k, column in ipairs (self.Columns) do

		for line = self.Top, last do

			local txt = column.Data[line]
			self.Strs[strNum]:SetText (txt)

			strNum = strNum + 1
		end

		-- Hide extras

		for n = strNum, self.Vis * cNum do
			self.Strs[n]:SetText ("")
			strNum = strNum + 1
		end

		cNum = cNum + 1
	end

	-- Do final resize and size parent win

	if self.ShowAll then

		self:Resize (0, 0)

		local f = self.Frm
		local win = f:GetParent().NxWin

		if win then
			win:SetSize (f:GetWidth(), -7, true)
		end
	end

	-- Slider

	if not self.ShowAll then
		self.Slider:Set (self.Top, 1, self.Num, self.Vis)
		self.Slider:Update()
	end

	-- Buttons

	if self.ButData then

		if not self.Buts or #self.Buts < self.Vis then
			self:CreateButtons()
		end

--		Nx.prt ("List Update Vis %s", self.Vis)

		local padW = 1
		local padH = 0

		local butNum = 1
		local f = self.Frm
		local offX = 0
		local offY = 0
		local adjY = hdrH + padH + lineH/2 + .5

		for n = 1, self.Vis do

			local line = self.Top + n - 1

			local but = self.Buts[butNum]
			local butType = self.ButData[line]

			if butType then

				if not but then
					Nx.prt (L["!BUT %s"], #self.Buts)
				end
				assert (but)

--				prt ("ListResize but #%d %s", n, butType)

				but:SetType (butType)
				but:SetId (line)

				local butTx = self.ButData[line + 1000000]

				if butType == "Color" then
					local t = self.ButData[line + 8000000]
					butTx = t[self.ButData[line + 9000000]]
				end

--				prtVar ("But Tex", butTx)
				but:SetTexture (butTx)

				local butTip = self.ButData[line + 2000000]
				but.Frm.NxTip = butTip
				but.Frm.NXTipFrm = self.ButData[line + 3000000]

				-- Causes update
				but:SetPressed (self.ButData[-line])

				if self.Offsets then
					offX = self.Offsets[line] or 0
					offY = self.Offsets[-line] or 0
				end

				local scale = self:GetLineH() / self.BaseLineH
				local y = (-(n - 1) * lineH - adjY - offY) / scale

				but.Frm:SetPoint ("CENTER", f, "TOPLEFT", (padW + lineH/2 + offX) / scale, y)
				but.Frm:Show()

			elseif but then

				but.Frm:Hide()
			end

			butNum = butNum + 1
		end

	elseif self.Buts then

		self:CreateButtons()		-- Hides all since we have no data
	end

	-- Frames

--[[ Example: (OLD)
	  text 1 frm 1 (color)
	--------- Visible
	1 text 2
	2 text 3 frm 2 (color). Get frm to keep until scrolls off visible area of list
	3 text 4
	4 text 5 frm 3 (color). Get frm
	---------
	  text 6
--]]

	if self.FrmData then			-- Only used for Info and Watch Items

		Nx.List:FreeFrames (self)

		local lfrm = self.Frm
		local offX = 3
		local offY = 3
		local adjY = hdrH + .5
		local doBind = true

		for n = 1, self.Vis do

			local line = self.Top + n - 1
			local data = self.FrmData[line]

			if data then

				local typ, v1, v2, v3 = Nx.Split ("~", data)

--				Nx.prt ("%s", -(n - 1) * lineH - adjY - offY)

				if typ == "Info" then

					if self.UserFunc then
						self.UserFunc (self.User, "update", v1, -(n - 1) * lineH - adjY)
					end

				elseif typ == "WatchItem" then
					if InCombatLockdown() then
						return
					end
					local f = Nx.List:GetFrame (self, typ)
					f:ClearAllPoints()

					local scale = self.ItemFrameScale * .07 * lineH / 13

					f:SetPoint ("TOPRIGHT", lfrm, "TOPLEFT", offX, -(n - 1) * lineH / scale - adjY - offY)

					f["rangeTimer"] = -1

					f:SetScale (scale)
					f:SetWidth (29)
					f:SetHeight (30)
					f:SetAlpha (self.ItemFrameAlpha)

					local id = tonumber (v1)					
					f:SetID(id)
					
					

					SetItemButtonTexture (f, v2);
					SetItemButtonCount (f, tonumber (v3));
					f["charges"] = tonumber (v3);

					f["questLogIndex"] = id
	
					if Nx.QItems[qId] then
						local start, duration, enable = GetItemCooldown(Nx.QItems[qId])
					end
					
					if start then
						CooldownFrame_Set (f.Cooldown, start, duration, enable)
						if ( duration > 0 and enable == 0 ) then
							SetItemButtonTextureVertexColor (itemButton, 0.4, 0.4, 0.4)
						else
							SetItemButtonTextureVertexColor (itemButton, 1, 1, 1)
						end
 					end
					
					_, _, _, _, _, _, _, qId = GetQuestLogTitle(id)
					
					if Nx.QItems[qId] then
						local link = Nx.QItems[qId]
					end
					f:SetAttribute ("item", link)
					f:SetAttribute("item", "item:" .. Nx.QItems[qId])

					if doBind then
						doBind = false
						local key = GetBindingKey ("NxWATCHUSEITEM")
						if key then
							Nx.qdb.profile.QuestWatch.KeyUseItem = key
							Nx.prt (L["Key %s transfered to Watch List Item"], key)
						end

						if #Nx.qdb.profile.QuestWatch.KeyUseItem > 0 and not InCombatLockdown() then

							local s = GetBindingAction (Nx.qdb.profile.QuestWatch.KeyUseItem)
							s = strmatch (s, L["CLICK (.+):"])
--							Nx.prt ("Key's frm %s", s or "nil")
							if s ~= f:GetName() then
								local ok = SetBindingClick (Nx.qdb.profile.QuestWatch.KeyUseItem, f:GetName())
								Nx.prt (L["Key %s %s #%s %s"], Nx.qdb.profile.QuestWatch.KeyUseItem, f:GetName(), line, ok or "nil")
								Nx.qdb.profile.QuestWatch.KeyUseItem = ""
							end
						end
					end

					f:Show()

				end
			end
		end

	end

	-- Position selected line

	local sfrm = self.SelFrm
	local selY = self.Selected - self.Top

	if selY < 0 or selY >= self.Vis then
		sfrm:Hide()

	else
		sfrm:SetHeight (lineH + 1)
		sfrm:SetPoint ("TOPLEFT", 0, -selY * lineH - self.HdrH)
		sfrm:Show()
	end
end


if IsClassic then
   function GetQuestLogCriteriaSpell()
      return
   end

   function GetNumQuestLogRewardCurrencies()
      return 0
   end

   function GetQuestLogRewardSkillPoints()
      return 0
   end

   function GetQuestLogRewardArtifactXP()
      return 0
   end

   function GetQuestLogRewardHonor()
      return 0
   end

   function GetQuestLogRewardTitle()
      return
   end

   function ProcessQuestLogRewardFactions()
      return
   end

   function GetQuestLogPortraitGiver()
      return
   end

   function GetQuestLink()
      return
   end
end

CQUEST_TEMPLATE_LOG = { questLog = true, chooseItems = nil, contentWidth = 285,
	canHaveSealMaterial = false, sealXOffset = 160, sealYOffset = -6,
	elements = {
		QuestInfo_ShowTitle, 5, -5,
		QuestInfo_ShowType, 0, -5,
		QuestInfo_ShowObjectivesText, 0, -5,
		QuestInfo_ShowTimer, 0, -10,
		QuestInfo_ShowObjectives, 0, -10,
		QuestInfo_ShowSpecialObjectives, 0, -10,
		QuestInfo_ShowRequiredMoney, 0, 0,
		QuestInfo_ShowGroupSize, 0, -10,
		QuestInfo_ShowDescriptionHeader, 0, -10,
		QuestInfo_ShowDescriptionText, 0, -5,
		QuestInfo_ShowSeal, 0, 0,
		QuestInfo_ShowRewards, 0, -10,
		QuestInfo_ShowSpacer, 0, -10
	}
}

CBQUEST_TEMPLATE = CQUEST_TEMPLATE_LOG
CBQUEST_TEMPLATE.canHaveSealMaterial = nil

local defaults = {
	profile = {
		Quest = {
			QuestFont = "Friz",
			QuestFontSize = 10,
			QuestFontSpacing = 1,
			Enable = true,
			AddTooltip = true,
			AutoAccept = false,
			AutoTurnIn = false,
			AutoTurnInAC = false,
			BroadcastQChanges = true,
			BroadcastQChangesNum = 999,
			DetailBC = ".75|.75|.44|1",
			DetailTC = ".125|.06|.03|1",
			DetailScale = .95,
			HCheckCompleted = false,
			maxLoadLevel = false,
			LevelsToLoad = 10,
			MapQuestGiversHighLevel = 60,
			MapQuestGiversLowLevel = 1,
			MapShowWatchAreas = true,
			MapWatchAreaAlpha = "1|1|1|.4",
			MapWatchAreaGfx = "Solid",
			MapWatchAreaTrackColor = ".7|.7|.7|.5",
			MapWatchAreaHoverColor = "1|1|1|.6",
			MapWatchColorPerQ = true,
			MapWatchColorCnt = 12,
			MapWatchC1 = "1|0|0|1",
			MapWatchC2 = "0|1|0|1",
			MapWatchC3 = ".2|.2|1|1",
			MapWatchC4 = "1|1|0|1",
			MapWatchC5 = "0|1|1|1",
			MapWatchC6 = "1|0|1|1",
			MapWatchC7 = "1|.5|0|1",
			MapWatchC8 = "0|1|.5|1",
			MapWatchC9 = ".5|.066|1|1",
			MapWatchC10 = ".5|1|0|1",
			MapWatchC11 = "0|.5|1|1",
			MapWatchC12 = "1|0|.5|1",
			PartyShare = true,
			ShowDailyCount = true,
			ShowDailyReset = true,
			ShowId = false,
			ShowLinkExtra = true,
			SideBySide = true,
			UseAltLKey = false,
			SndPlayCompleted = true,
			Snd1 = true,
			Snd2 = false,
			Snd3 = false,
			Snd4 = false,
			Snd5 = false,
			Snd6 = false,
			Snd7 = false,
			Snd8 = false,
			Load0 = true,	-- dailies
			Load1 = true,	--  1 - 10
			Load2 = true,	-- 11 - 20
			Load3 = true,	-- 21 - 30
			Load4 = true,	-- 31 - 40
			Load5 = true,	-- 41 - 50
			Load6 = true,	-- 51 - 60
			Load7 = true,	-- 61 - 70
			Load8 = true,	-- 71 - 80
			Load9 = true,	-- 81 - 85
			Load10 = true,	-- 86 - 90
			Load11 = true,	-- 91 - 100
			Load12 = true,  -- 101 - 110
			ScrollIMG = true,
		},
		QuestWatch = {
			AchTrack = true,
			AchZoneShow = true,
			AddNew = true,
			AddChanged = true,
			BGColor = "0|0|0|.4",
			BlizzModify = true,
			BonusBar = false,
			BonusTask = true,
			ChalTrack = true,
			FadeAll = false,
			FixedSize = true,
			GrowUp = false,
			HideBlizz = true,
			HideDoneObj = false,
			HideRaid = false,
			ItemAlpha = "1|1|1|.6",
			ItemScale = 10,
			KeyUseItem = "",
			OCntFirst = false,
			OMaxLen = 60,
			RefreshTimer = 500,
			RemoveComplete = false,
			ScenTrack = true,
			ShowClose = false,
			ShowDist = true,
			ShowPerColor = false,
			CompleteColor = "1|.82|0|1",
			IncompleteColor = ".75|.6|0|1",
			OCompleteColor = "1|1|1|1",
			OIncompleteColor = ".8|.8|.8|1",
			Sync = true,
			WatchFont = "Arial",
			WatchFontSize = 11,
			WatchFontSpacing = 2,
		},
		WQList = {
			showgear = true,
			showap = true,
			showorder = true,
			showgold = true,
			showother = true,
			showpvp = true,
			showbounty = false,
			sortmode = 1,
			zoneonly = false,
			showfaronis = true,
			showdreamweaver = true,
			showhighmountain = true,
			showlegionfall = true,
			showargussian = true,
			shownightfallen = true,
			showwardens = true,
			showkirintor = true,
			showarmyoflight = true,
			showvalarjar = true,
			bountycolor = true,
		},
	},
}

local GlobalAddonName = ...
local inspectScantip = CreateFrame("GameTooltip", GlobalAddonName.."WQInspectScanningTooltip", nil, "GameTooltipTemplate")
inspectScantip:SetOwner(UIParent, "ANCHOR_NONE")

local WQTable = {}
local ITEM_LEVEL = (ITEM_LEVEL or "NO DATA FOR ITEM_LEVEL"):gsub("%%d","(%%d+%+*)")

local questoptions
local worldquestdb = {}
local emmBfA = {}
local emmLegion = {}
local worldquesttip = CreateFrame("GameTooltip", "WQListTip", nil, "GameTooltipTemplate")
worldquesttip:SetOwner(UIParent, "ANCHOR_NONE")

local function QuestOptions ()
	if not questoptions then
		questoptions = {
			type = "group",
			name = L["Quest Options"],
			childGroups	= "tab",
			args = {
				quest = {
					type = "group",
					name = L["Quest Options"],
					order = 1,
					args = {
						name = {
							order = 1,
							type = "description",
							name = L["Quest Window Options"],
						},
						qaltl = {
							order = 2,
							type = "toggle",
							width = "full",
							name = L["Use Alt-L instead of L for Carbonite Quests"],
							desc = L["When enabled, leaves L as the default blizzard window and Alt-L for carbonite quests"],
							get = function()
								return Nx.qdb.profile.Quest.UseAltLKey
							end,
							set = function()
								Nx.qdb.profile.Quest.UseAltLKey = not Nx.qdb.profile.Quest.UseAltLKey
							end,
						},
						qlsidebyside = {
							order = 3,
							type = "toggle",
							width = "full",
							name = L["Show Quests Side by Side"],
							desc = L["When enabled, shows the quest details to the right side of the quest window"],
							get = function()
								return Nx.qdb.profile.Quest.SideBySide
							end,
							set = function()
								Nx.qdb.profile.Quest.SideBySide = not Nx.qdb.profile.Quest.SideBySide
								Nx.Quest.List:AttachFrames()
							end,
						},
						qlshowreset = {
							order = 4,
							type = "toggle",
							width = "full",
							name = L["Show Daily Reset Time"],
							desc = L["When enabled, shows the time until dailies reset"],
							get = function()
								return Nx.qdb.profile.Quest.ShowDailyReset
							end,
							set = function()
								Nx.qdb.profile.Quest.ShowDailyReset = not Nx.qdb.profile.Quest.ShowDailyReset
							end,
						},
						qlshowcount = {
							order = 5,
							type = "toggle",
							width = "full",
							name = L["Show Daily Quest Count"],
							desc = L["When enabled, shows the number of daily quests you've done"],
							get = function()
								return Nx.qdb.profile.Quest.ShowDailyCount
							end,
							set = function()
								Nx.qdb.profile.Quest.ShowDailyCount = not Nx.qdb.profile.Quest.ShowDailyCount
							end,
						},
						qlshowid = {
							order = 6,
							type = "toggle",
							width = "full",
							name = L["Show Quest ID"],
							desc = L["When enabled, shows the quest ID beside the quest"],
							get = function()
								return Nx.qdb.profile.Quest.ShowId
							end,
							set = function()
								Nx.qdb.profile.Quest.ShowId = not Nx.qdb.profile.Quest.ShowId
							end,
						},
						ImgorBG = {
							order = 7,
							type = "toggle",
							width = "full",
							name = L["Use scroll image in quest log"],
							desc = L["When enabled, uses paper looking background for quest details"],
							get = function()
								return Nx.qdb.profile.Quest.ScrollIMG
							end,
							set = function()
								Nx.qdb.profile.Quest.ScrollIMG = not Nx.qdb.profile.Quest.ScrollIMG
								Nx.Opts.NXCmdReload()
							end,
						},
						qbgcol = {
							order = 8,
							type = "color",
							width = "full",
							name = L["Quest Details Background Color"],
							hasAlpha = true,
							get = function()
								local arr = { Nx.Split("|",Nx.qdb.profile.Quest.DetailBC) }
								local r = arr[1]
								local g = arr[2]
								local b = arr[3]
								local a = arr[4]
								return r,g,b,a
							end,
							set = function(_,r,g,b,a)
								Nx.qdb.profile.Quest.DetailBC = r .. "|" .. g .. "|" .. b .. "|" .. a
							end,
						},
						qtcol = {
							order = 9,
							type = "color",
							width = "full",
							name = L["Quest Details Text Color"],
							hasAlpha = true,
							get = function()
								local arr = { Nx.Split("|",Nx.qdb.profile.Quest.DetailTC) }
								local r = arr[1]
								local g = arr[2]
								local b = arr[3]
								local a = arr[4]
								return r,g,b,a
							end,
							set = function(_,r,g,b,a)
								Nx.qdb.profile.Quest.DetailTC = r .. "|" .. g .. "|" .. b .. "|" .. a
							end,
						},
						qtscale = {
							order = 10,
							type = "range",
							name = L["Quest Details Scale"],
							desc = L["Sets the size of the quest details"],
							min = .5,
							max = 2,
							step = .01,
							bigStep = .01,
							get = function()
								return Nx.qdb.profile.Quest.DetailScale
							end,
							set = function(info,value)
								Nx.qdb.profile.Quest.DetailScale = value
							end,
						},
						spacer = {
							order = 11,
							type = "description",
							width = "full",
							name = " ",
						},
						spacer2 = {
							order = 12,
							type = "description",
							width = "full",
							name = " ",
						},
						questdesc = {
							order = 13,
							type = "description",
							name = L["Quest Options"],
						},
						qtool = {
							order = 14,
							type = "toggle",
							width = "full",
							name = L["Show Quest Tooltips"],
							desc = L["When enabled, adds quest information to tooltips"],
							get = function()
								return Nx.qdb.profile.Quest.AddTooltip
							end,
							set = function()
								Nx.qdb.profile.Quest.AddTooltip = not Nx.qdb.profile.Quest.AddTooltip
							end,
						},
						qparty = {
							order = 15,
							type = "toggle",
							width = "full",
							name = L["Share Quest Progress"],
							desc = L["When enabled, shares your quest progress to group members and accepts their shares"],
							get = function()
								return Nx.qdb.profile.Quest.PartyShare
							end,
							set = function()
								Nx.qdb.profile.Quest.PartyShare = not Nx.qdb.profile.Quest.PartyShare
							end,
						},
						qauto = {
							order = 16,
							type = "toggle",
							width = "full",
							name = L["Auto Accept Quests"],
							desc = L["When enabled, will auto accept quests that get offered to you"],
							get = function()
								return Nx.qdb.profile.Quest.AutoAccept
							end,
							set = function()
								Nx.qdb.profile.Quest.AutoAccept = not Nx.qdb.profile.Quest.AutoAccept
							end,
						},
						qautoturn = {
							order = 17,
							type = "toggle",
							width = "full",
							name = L["Auto Turn In Quests"],
							desc = L["When enabled, automatically turns in quests"],
							get = function()
								return Nx.qdb.profile.Quest.AutoTurnIn
							end,
							set = function()
								Nx.qdb.profile.Quest.AutoTurnIn = not Nx.qdb.profile.Quest.AutoTurnIn
							end,
						},
						qautoac = {
							order = 18,
							type = "toggle",
							width = "full",
							name = L["Auto Turn In Self-Completion Quests"],
							desc = L["When enabled, auto turns in quests that are self-completing"],
							get = function()
								return Nx.qdb.profile.Quest.AutoTurnInAC
							end,
							set = function()
								Nx.qdb.profile.Quest.AutoTurnInAC = not Nx.qdb.profile.Quest.AutoTurnInAC
							end,
						},
						qbroad = {
							order = 19,
							type = "toggle",
							width = "double",
							name = L["Broadcast Quest Changes"],
							desc = L["When enabled, will send a group/raid message when you complete an objective"],
							get = function()
								return Nx.qdb.profile.Quest.BroadcastQChanges
							end,
							set = function()
								Nx.qdb.profile.Quest.BroadcastQChanges = not Nx.qdb.profile.Quest.BroadcastQChanges
							end,
						},
						qbroadnum = {
							order = 20,
							type = "range",
							name = L["Broadcast after number of changes"],
							desc = L["Sets the number of objective changes before it sends the group/raid message"],
							min = 1,
							max = 999,
							step = 1,
							bigStep = 1,
							get = function()
								return Nx.qdb.profile.Quest.BroadcastQChangesNum
							end,
							set = function(info,value)
								Nx.qdb.profile.Quest.BroadcastQChangesNum = value
							end,
						},
						qextra = {
							order = 21,
							type = "toggle",
							width = "full",
							name = L["Show Extended Info in Quest Links"],
							desc = L["When enabled, adds information about level and part number in quest links"],
							get = function()
								return Nx.qdb.profile.Quest.ShowLinkExtra
							end,
							set = function()
								Nx.qdb.profile.Quest.ShowLinkExtra = not Nx.qdb.profile.Quest.ShowLinkExtra
							end,
						},
						qlogin = {
							order = 22,
							type = "toggle",
							width = "full",
							name = L["Get Completed Quest Information on Login"],
							desc = L["When enabled, will get all your completed quests from the server each login"],
							get = function()
								return Nx.qdb.profile.Quest.HCheckCompleted
							end,
							set = function()
								Nx.qdb.profile.Quest.HCheckCompleted = not Nx.qdb.profile.Quest.HCheckCompleted
							end,
						},
						spacer3 = {
							order = 23,
							type = "description",
							width = "full",
							name = " ",
						},
						questmaps = {
							order = 24,
							type = "description",
							name = L["Quest Map Options"],
						},
						qmshow = {
							order = 25,
							type = "toggle",
							width = "full",
							name = L["Always Show Quest Watched Areas"],
							desc = L["When enabled, will always show your watched quests on the map. This only works for quests carbonite knows"],
							get = function()
								return Nx.qdb.profile.Quest.MapShowWatchAreas
							end,
							set = function()
								Nx.qdb.profile.Quest.MapShowWatchAreas = not Nx.qdb.profile.Quest.MapShowWatchAreas
							end,
						},
						qmwcol = {
							order = 26,
							type = "color",
							width = "full",
							name = L["Color of Watched Areas When Tracked"],
							hasAlpha = true,
							get = function()
								local arr = { Nx.Split("|",Nx.qdb.profile.Quest.MapWatchAreaTrackColor) }
								local r = arr[1]
								local g = arr[2]
								local b = arr[3]
								local a = arr[4]
								return r,g,b,a
							end,
							set = function(_,r,g,b,a)
								Nx.qdb.profile.Quest.MapWatchAreaTrackColor = r .. "|" .. g .. "|" .. b .. "|" .. a
								Nx.Quest:SetCols()
							end,
						},
						qmwtrackcol = {
							order = 27,
							type = "color",
							width = "full",
							name = L["Color of Watched Areas on Mouse Over"],
							hasAlpha = true,
							get = function()
								local arr = { Nx.Split("|",Nx.qdb.profile.Quest.MapWatchAreaHoverColor) }
								local r = arr[1]
								local g = arr[2]
								local b = arr[3]
								local a = arr[4]
								return r,g,b,a
							end,
							set = function(_,r,g,b,a)
								Nx.qdb.profile.Quest.MapWatchAreaHoverColor = r .. "|" .. g .. "|" .. b .. "|" .. a
								Nx.Quest:SetCols()
							end,
						},
						qmwtracktrans = {
							order = 28,
							type = "color",
							width = "full",
							name = L["Alpha of Watched Areas"],
							hasAlpha = true,
							get = function()
								local arr = { Nx.Split("|",Nx.qdb.profile.Quest.MapWatchAreaAlpha) }
								local r = arr[1]
								local g = arr[2]
								local b = arr[3]
								local a = arr[4]
								return r,g,b,a
							end,
							set = function(_,r,g,b,a)
								Nx.qdb.profile.Quest.MapWatchAreaAlpha = r .. "|" .. g .. "|" .. b .. "|" .. a
							end,
						},
						qmgraph = {
							order = 29,
							type = "select",
							name = L["Watched Area Graphic"],
							desc = L["Sets the graphic to be used for watched areas"],
							get	= function()
								local vals = Nx.Opts:CalcChoices("QArea")
								for a,b in pairs(vals) do
								if (b == Nx.qdb.profile.Quest.MapWatchAreaGfx) then
									return a
								end
								end
								return ""
							end,
							set	= function(info, name)
								local vals = Nx.Opts:CalcChoices("QArea")
								Nx.qdb.profile.Quest.MapWatchAreaGfx = vals[name]
								Nx.Quest:CalcWatchColors()
							end,
							values	= function()
								return Nx.Opts:CalcChoices("QArea")
							end,
						},
						spacer4 = {
							order = 30,
							type = "description",
							width = "full",
							name = " ",
						},
						qmcolperq = {
							order = 31,
							type = "toggle",
							name = L["Use One Color Per Quest"],
							width = "full",
							desc = L["When enabled, will use one specific color per quest area"],
							get = function()
								return Nx.qdb.profile.Quest.MapWatchColorPerQ
							end,
							set = function()
								Nx.qdb.profile.Quest.MapWatchColorPerQ = not Nx.qdb.profile.Quest.MapWatchColorPerQ
							end,
						},
						qttlcols = {
							order = 32,
							type = "range",
							name = L["Total Colors To Use"],
							desc = L["Sets the number of possible colors to use for quest watching"],
							min = 1,
							max = 12,
							step = 1,
							bigStep = 1,
							get = function()
								return Nx.qdb.profile.Quest.MapWatchColorCnt
							end,
							set = function(info,value)
								Nx.qdb.profile.Quest.MapWatchColorCnt = value
								Nx.Quest:CalcWatchColors()
							end,
						},
						qcol1 = {
							order = 33,
							type = "color",
							width = "full",
							name = L["Watch Color 1"],
							hasAlpha = true,
							get = function()
								local arr = { Nx.Split("|",Nx.qdb.profile.Quest.MapWatchC1) }
								local r = arr[1]
								local g = arr[2]
								local b = arr[3]
								local a = arr[4]
								return r,g,b,a
							end,
							set = function(_,r,g,b,a)
								Nx.qdb.profile.Quest.MapWatchC1 = r .. "|" .. g .. "|" .. b .. "|" .. a
								Nx.Quest:CalcWatchColors()
							end,
						},
						qcol2 = {
							order = 34,
							type = "color",
							width = "full",
							name = L["Watch Color 2"],
							hasAlpha = true,
							get = function()
								local arr = { Nx.Split("|",Nx.qdb.profile.Quest.MapWatchC2) }
								local r = arr[1]
								local g = arr[2]
								local b = arr[3]
								local a = arr[4]
								return r,g,b,a
							end,
							set = function(_,r,g,b,a)
								Nx.qdb.profile.Quest.MapWatchC2 = r .. "|" .. g .. "|" .. b .. "|" .. a
								Nx.Quest:CalcWatchColors()
							end,
						},
						qcol3 = {
							order = 35,
							type = "color",
							width = "full",
							name = L["Watch Color 3"],
							hasAlpha = true,
							get = function()
								local arr = { Nx.Split("|",Nx.qdb.profile.Quest.MapWatchC3) }
								local r = arr[1]
								local g = arr[2]
								local b = arr[3]
								local a = arr[4]
								return r,g,b,a
							end,
							set = function(_,r,g,b,a)
								Nx.qdb.profile.Quest.MapWatchC3 = r .. "|" .. g .. "|" .. b .. "|" .. a
								Nx.Quest:CalcWatchColors()
							end,
						},
						qcol4 = {
							order = 36,
							type = "color",
							width = "full",
							name = L["Watch Color 4"],
							hasAlpha = true,
							get = function()
								local arr = { Nx.Split("|",Nx.qdb.profile.Quest.MapWatchC4) }
								local r = arr[1]
								local g = arr[2]
								local b = arr[3]
								local a = arr[4]
								return r,g,b,a
							end,
							set = function(_,r,g,b,a)
								Nx.qdb.profile.Quest.MapWatchC4 = r .. "|" .. g .. "|" .. b .. "|" .. a
								Nx.Quest:CalcWatchColors()
							end,
						},
						qcol5 = {
							order = 37,
							type = "color",
							width = "full",
							name = L["Watch Color 5"],
							hasAlpha = true,
							get = function()
								local arr = { Nx.Split("|",Nx.qdb.profile.Quest.MapWatchC5) }
								local r = arr[1]
								local g = arr[2]
								local b = arr[3]
								local a = arr[4]
								return r,g,b,a
							end,
							set = function(_,r,g,b,a)
								Nx.qdb.profile.Quest.MapWatchC5 = r .. "|" .. g .. "|" .. b .. "|" .. a
								Nx.Quest:CalcWatchColors()
							end,
						},
						qcol6 = {
							order = 38,
							type = "color",
							width = "full",
							name = L["Watch Color 6"],
							hasAlpha = true,
							get = function()
								local arr = { Nx.Split("|",Nx.qdb.profile.Quest.MapWatchC6) }
								local r = arr[1]
								local g = arr[2]
								local b = arr[3]
								local a = arr[4]
								return r,g,b,a
							end,
							set = function(_,r,g,b,a)
								Nx.qdb.profile.Quest.MapWatchC6 = r .. "|" .. g .. "|" .. b .. "|" .. a
								Nx.Quest:CalcWatchColors()
							end,
						},
						qcol7 = {
							order = 39,
							type = "color",
							width = "full",
							name = L["Watch Color 7"],
							hasAlpha = true,
							get = function()
								local arr = { Nx.Split("|",Nx.qdb.profile.Quest.MapWatchC7) }
								local r = arr[1]
								local g = arr[2]
								local b = arr[3]
								local a = arr[4]
								return r,g,b,a
							end,
							set = function(_,r,g,b,a)
								Nx.qdb.profile.Quest.MapWatchC7 = r .. "|" .. g .. "|" .. b .. "|" .. a
								Nx.Quest:CalcWatchColors()
							end,
						},
						qcol8 = {
							order = 40,
							type = "color",
							width = "full",
							name = L["Watch Color 8"],
							hasAlpha = true,
							get = function()
								local arr = { Nx.Split("|",Nx.qdb.profile.Quest.MapWatchC8) }
								local r = arr[1]
								local g = arr[2]
								local b = arr[3]
								local a = arr[4]
								return r,g,b,a
							end,
							set = function(_,r,g,b,a)
								Nx.qdb.profile.Quest.MapWatchC8 = r .. "|" .. g .. "|" .. b .. "|" .. a
								Nx.Quest:CalcWatchColors()
							end,
						},
						qcol9 = {
							order = 41,
							type = "color",
							width = "full",
							name = L["Watch Color 9"],
							hasAlpha = true,
							get = function()
								local arr = { Nx.Split("|",Nx.qdb.profile.Quest.MapWatchC9) }
								local r = arr[1]
								local g = arr[2]
								local b = arr[3]
								local a = arr[4]
								return r,g,b,a
							end,
							set = function(_,r,g,b,a)
								Nx.qdb.profile.Quest.MapWatchC9 = r .. "|" .. g .. "|" .. b .. "|" .. a
								Nx.Quest:CalcWatchColors()
							end,
						},
						qcol10 = {
							order = 42,
							type = "color",
							width = "full",
							name = L["Watch Color 10"],
							hasAlpha = true,
							get = function()
								local arr = { Nx.Split("|",Nx.qdb.profile.Quest.MapWatchC10) }
								local r = arr[1]
								local g = arr[2]
								local b = arr[3]
								local a = arr[4]
								return r,g,b,a
							end,
							set = function(_,r,g,b,a)
								Nx.qdb.profile.Quest.MapWatchC10 = r .. "|" .. g .. "|" .. b .. "|" .. a
								Nx.Quest:CalcWatchColors()
							end,
						},
						qcol11 = {
							order = 43,
							type = "color",
							width = "full",
							name = L["Watch Color 11"],
							hasAlpha = true,
							get = function()
								local arr = { Nx.Split("|",Nx.qdb.profile.Quest.MapWatchC11) }
								local r = arr[1]
								local g = arr[2]
								local b = arr[3]
								local a = arr[4]
								return r,g,b,a
							end,
							set = function(_,r,g,b,a)
								Nx.qdb.profile.Quest.MapWatchC11 = r .. "|" .. g .. "|" .. b .. "|" .. a
								Nx.Quest:CalcWatchColors()
							end,
						},
						qcol12 = {
							order = 44,
							type = "color",
							width = "full",
							name = L["Watch Color 12"],
							hasAlpha = true,
							get = function()
								local arr = { Nx.Split("|",Nx.qdb.profile.Quest.MapWatchC12) }
								local r = arr[1]
								local g = arr[2]
								local b = arr[3]
								local a = arr[4]
								return r,g,b,a
							end,
							set = function(_,r,g,b,a)
								Nx.qdb.profile.Quest.MapWatchC12 = r .. "|" .. g .. "|" .. b .. "|" .. a
								Nx.Quest:CalcWatchColors()
							end,
						},
						spacer5 = {
							order = 45,
							type = "description",
							width = "full",
							name = " ",
						},
						QuestFont = {
							order = 46,
							type = "select",
							name = L["Quest Font"],
							desc = L["Sets the font to be used on the quest window"],
							get	= function()
								local vals = Nx.Opts:CalcChoices("FontFace","Get")
								for a,b in pairs(vals) do
								  if (b == Nx.qdb.profile.Quest.QuestFont) then
									 return a
								  end
								end
								return ""
							end,
							set	= function(info, name)
								local vals = Nx.Opts:CalcChoices("FontFace","Get")
								Nx.qdb.profile.Quest.QuestFont = vals[name]
								Nx.Opts:NXCmdFontChange()
							end,
							values	= function()
								return Nx.Opts:CalcChoices("FontFace","Get")
							end,
						},
						QuestFontSize = {
							order = 47,
							type = "range",
							name = L["Quest Font Size"],
							desc = L["Sets the size of the quest window font"],
							min = 6,
							max = 20,
							step = 1,
							bigStep = 1,
							get = function()
								return Nx.qdb.profile.Quest.QuestFontSize
							end,
							set = function(info,value)
								Nx.qdb.profile.Quest.QuestFontSize = value
								Nx.Opts:NXCmdFontChange()
							end,
						},
						QuestFontSpacing = {
							order = 48,
							type = "range",
							name = L["Quest Font Spacing"],
							desc = L["Sets the spacing of the quest window font"],
							min = -10,
							max = 20,
							step = 1,
							bigStep = 1,
							get = function()
								return Nx.qdb.profile.Quest.QuestFontSpacing
							end,
							set = function(info,value)
								Nx.qdb.profile.Quest.QuestFontSpacing = value
								Nx.Opts:NXCmdFontChange()
							end,
						},
					},
				},
				watch = {
					type = "group",
					name = L["Watch Options"],
					order = 2,
					args = {
						qwhide = {
							order = 1,
							type = "toggle",
							width = "full",
							name = L["Hide Quest Watch Window"],
							desc = L["When enabled, stops carbonite from displaying the quest watch window"],
							get = function()
								return Nx.qdb.profile.QuestWatch.Hide
							end,
							set = function()
								Nx.qdb.profile.QuestWatch.Hide = not Nx.qdb.profile.QuestWatch.Hide
								Nx.Window:SetAttribute("NxQuestWatch","H",Nx.qdb.profile.QuestWatch.Hide)
							end,
						},
						qwraidhide = {
							order = 2,
							type = "toggle",
							width = "full",
							name = L["Hide Quest Watch Window in Raids"],
							desc = L["When enabled, stops carbonite from displaying the quest watch window while your in a raid"],
							get = function()
								return Nx.qdb.profile.QuestWatch.HideRaid
							end,
							set = function()
								Nx.qdb.profile.QuestWatch.HideRaid = not Nx.qdb.profile.QuestWatch.HideRaid
							end,
						},
						qwlock = {
							order = 3,
							type = "toggle",
							width = "full",
							name = L["Lock Quest Watch Window"],
							desc = L["When enabled, stops carbonite from being able to move"],
							get = function()
								return Nx.qdb.profile.QuestWatch.Lock
							end,
							set = function()
								Nx.qdb.profile.QuestWatch.Lock = not Nx.qdb.profile.QuestWatch.Lock
								Nx.Window:SetAttribute("NxQuestWatch","L",Nx.qdb.profile.QuestWatch.Lock)
							end,
						},
						qwgrowup = {
							order = 4,
							type = "toggle",
							width = "full",
							name = L["Grow quest watch window Upwards"],
							desc = L["When enabled, objectives and quests get added in an upward direction instead of down"],
							get = function()
								return Nx.qdb.profile.QuestWatch.GrowUp
							end,
							set = function()
								Nx.qdb.profile.QuestWatch.GrowUp = not Nx.qdb.profile.QuestWatch.GrowUp
								Nx.Quest.Watch:Update()
							end,
						},
						qwfixedsize = {
							order = 5,
							type = "toggle",
							width = "full",
							name = L["Use A Fixed Size for Quest Watch"],
							desc = L["When enabled, the carbonite quest watch window does not allow resizing, just movement (RELOAD REQUIRED)"],
							get = function()
								return Nx.qdb.profile.QuestWatch.FixedSize
							end,
							set = function()
								Nx.qdb.profile.QuestWatch.FixedSize = not Nx.qdb.profile.QuestWatch.FixedSize
								Nx.Opts.NXCmdReload()
							end,
						},
						qwhideblizz = {
							order = 6,
							type = "toggle",
							width = "full",
							name = L["Hide Blizzards Quest Track Window"],
							desc = L["When enabled, hides blizzards version of the track window"],
							get = function()
								return Nx.qdb.profile.QuestWatch.HideBlizz
							end,
							set = function()
								Nx.qdb.profile.QuestWatch.HideBlizz = not Nx.qdb.profile.QuestWatch.HideBlizz
							end,
						},
						qwblizzauto = {
							order = 7,
							type = "toggle",
							width = "full",
							name = L["Disable Blizzards Auto Quest Tracking"],
							desc = L["When enabled, turns off blizzards quest watch window auto adding new quests (RELOAD REQUIRED)"],
							get = function()
								return Nx.qdb.profile.QuestWatch.BlizzModify
							end,
							set = function()
								Nx.qdb.profile.QuestWatch.BlizzModify = not Nx.qdb.profile.QuestWatch.BlizzModify
								Nx.Opts.NXCmdReload()
							end,
						},
						qwtextsize = {
							order = 8,
							type = "range",
							name = L["Object Text Length Before Linewrap"],
							desc = L["Sets the number of characters before an objective wraps"],
							min = 20,
							max = 999,
							step = 1,
							bigStep = 1,
							get = function()
								return Nx.qdb.profile.QuestWatch.OMaxLen
							end,
							set = function(info,value)
								Nx.qdb.profile.QuestWatch.OMaxLen = value
								Nx.Quest.Watch:Update()
							end,
						},
						qsync = {
							order = 9,
							type = "toggle",
							width = "full",
							name = L["Sync Carbonite Quest Watch with Blizzard Quest Watch"],
							desc = L["When enabled, syncs the two watch lists which enables blizzard quest blobs to appear on the minimap"],
							get = function()
								return Nx.qdb.profile.QuestWatch.Sync
							end,
							set = function()
								Nx.qdb.profile.QuestWatch.Sync = not Nx.qdb.profile.QuestWatch.Sync
							end,
						},
						qrefresh = {
							order = 10,
							type = "range",
							name = L["Watch Delay Time"],
							desc = L["Sets the forced delay time of watch update in ms, performance toggle for systems that need it"],
							min = 250,
							max = 1000,
							step = 1,
							bigStep = 1,
							get = function()
								return Nx.qdb.profile.QuestWatch.RefreshTimer
							end,
							set = function(info,value)
								Nx.qdb.profile.QuestWatch.RefreshTimer = value
								Nx.Quest.Watch:Update()
							end,
						},
						spacer = {
							order = 11,
							type = "description",
							width = "full",
							name = " ",
						},
						spacer1 = {
							order = 12,
							type = "description",
							width = "full",
							name = " ",
						},
						qwautonew = {
							order = 13,
							type = "toggle",
							width = "full",
							name = L["Auto Watch New Quests"],
							desc = L["When enabled, any new quest you pickup is automatically watched"],
							get = function()
								return Nx.qdb.profile.QuestWatch.AddNew
							end,
							set = function()
								Nx.qdb.profile.QuestWatch.AddNew = not Nx.qdb.profile.QuestWatch.AddNew
							end,
						},
						qwaddchanged = {
							order = 14,
							type = "toggle",
							width = "full",
							name = L["Auto Watch Changed Quests"],
							desc = L["When enabled, any quest whose objective changes from you looting an item, or talking to someone is automatically watched"],
							get = function()
								return Nx.qdb.profile.QuestWatch.AddChanged
							end,
							set = function()
								Nx.qdb.profile.QuestWatch.AddChanged = not Nx.qdb.profile.QuestWatch.AddChanged
							end,
						},
						qwremovecomplete = {
							order = 15,
							type = "toggle",
							width = "full",
							name = L["Auto Remove Completed Quests"],
							desc = L["When enabled, when you complete a quest it will be removed from your watch list"],
							get = function()
								return Nx.qdb.profile.QuestWatch.RemoveComplete
							end,
							set = function()
								Nx.qdb.profile.QuestWatch.RemoveComplete = not Nx.qdb.profile.QuestWatch.RemoveComplete
							end,
						},
						qwshowdist = {
							order = 16,
							type = "toggle",
							width = "full",
							name = L["Show distance to quest objectives"],
							desc = L["When enabled, attempts to display how far approximately you are from a quest or objective"],
							get = function()
								return Nx.qdb.profile.QuestWatch.ShowDist
							end,
							set = function()
								Nx.qdb.profile.QuestWatch.ShowDist = not Nx.qdb.profile.QuestWatch.ShowDist
								Nx.Quest.Watch:Update()
							end,
						},
						qwhideobject = {
							order = 17,
							type = "toggle",
							width = "full",
							name = L["Auto Hide Finished Objectives"],
							desc = L["When enabled, objectives that are 100% complete will be removed from the list"],
							get = function()
								return Nx.qdb.profile.QuestWatch.HideDoneObj
							end,
							set = function()
								Nx.qdb.profile.QuestWatch.HideDoneObj = not Nx.qdb.profile.QuestWatch.HideDoneObj
								Nx.Quest.Watch:Update()
							end,
						},
						qwobjfirst = {
							order = 18,
							type = "toggle",
							width = "full",
							name = L["Show Objective Amount First"],
							desc = L["When enabled, puts your objective progress before the objective instead of after"],
							get = function()
								return Nx.qdb.profile.QuestWatch.OCntFirst
							end,
							set = function()
								Nx.qdb.profile.QuestWatch.OCntFirst = not Nx.qdb.profile.QuestWatch.OCntFirst
								Nx.Quest.Watch:Update()
							end,
						},
						spacer2 = {
							order = 19,
							type = "description",
							width = "full",
							name = " ",
						},
						qwwatchscen = {
							order = 20,
							type = "toggle",
							width = "full",
							name = L["Watch Scenarios"],
							desc = L["When enabled, will place scenario status at the top of your watch window"],
							get = function()
								return Nx.qdb.profile.QuestWatch.ScenTrack
							end,
							set = function()
								Nx.qdb.profile.QuestWatch.ScenTrack = not Nx.qdb.profile.QuestWatch.ScenTrack
								Nx.Quest.Watch:Update()
							end,
						},
						qwwatchach = {
							order = 21,
							type = "toggle",
							width = "full",
							name = L["Watch Achievements"],
							desc = L["When enabled, will place any tracked achievements at the top of your watch window"],
							get = function()
								return Nx.qdb.profile.QuestWatch.AchTrack
							end,
							set = function()
								Nx.qdb.profile.QuestWatch.AchTrack = not Nx.qdb.profile.QuestWatch.AchTrack
								Nx.Quest.Watch:Update()
							end,
						},
						qwwatchtask = {
							order = 22,
							type = "toggle",
							width = "full",
							name = L["Watch Bonus Tasks"],
							desc = L["When enabled, will place bonus tasks onto the quest tracker when your in range."],
							get = function()
								return Nx.qdb.profile.QuestWatch.BonusTask
							end,
							set = function()
								Nx.qdb.profile.QuestWatch.BonusTask = not Nx.qdb.profile.QuestWatch.BonusTask
								Nx.Quest.Watch:Update()
							end,
						},
						qwwatchpbar = {
							order = 23,
							type = "toggle",
							width = "full",
							name = L["Show Progress Bar instead of Text"],
							desc = L["If active, instead of a text, the percentage of progress will be shown with a bar."],
							get = function()
								return Nx.qdb.profile.QuestWatch.BonusBar
							end,
							set = function()
								Nx.qdb.profile.QuestWatch.BonusBar = not Nx.qdb.profile.QuestWatch.BonusBar
								Nx.Quest.Watch:Update()
							end,
						},
						qwwatchchal = {
							order = 24,
							type = "toggle",
							width = "full",
							name = L["Watch Challenge Modes"],
							desc = L["When enabled, will place the timer for your challenge mode at the top of your watch window"],
							get = function()
								return Nx.qdb.profile.QuestWatch.ChalTrack
							end,
							set = function()
								Nx.qdb.profile.QuestWatch.ChalTrack = not Nx.qdb.profile.QuestWatch.ChalTrack
								Nx.Quest.Watch:Update()
							end,
						},
						qwwatchzone = {
							order = 25,
							type = "toggle",
							width = "full",
							name = L["Show Zone Achievement if Known"],
							desc = L["When enabled, if carbonite knows there is a zone achievement for number of quests it will display it"],
							get = function()
								return Nx.qdb.profile.QuestWatch.AchZoneShow
							end,
							set = function()
								Nx.qdb.profile.QuestWatch.AchZoneShow = not Nx.qdb.profile.QuestWatch.AchZoneShow
								Nx.Quest.Watch:Update()
							end,
						},
						spacer3 = {
							order = 26,
							type = "description",
							width = "full",
							name = " ",
						},
						qwshowclose = {
							order = 27,
							type = "toggle",
							width = "full",
							name = L["Show Close Button"],
							desc = L["When enabled, will place a button on the watch window to close it (RELOADS UI)"],
							get = function()
								return Nx.qdb.profile.QuestWatch.ShowClose
							end,
							set = function()
								Nx.qdb.profile.QuestWatch.ShowClose = not Nx.qdb.profile.QuestWatch.ShowClose
								Nx.Opts.NXCmdReload()
							end,
						},
						qwfadeall = {
							order = 28,
							type = "toggle",
							width = "full",
							name = L["Fade Entire Window"],
							desc = L["When enabled, if the quest watch window fades, will ensure all of it fades text and all instead of just the window itself"],
							get = function()
								return Nx.qdb.profile.QuestWatch.FadeAll
							end,
							set = function()
								Nx.qdb.profile.QuestWatch.FadeAll = not Nx.qdb.profile.QuestWatch.FadeAll
								Nx.Quest.Watch:WinUpdateFade (Nx.qdb.profile.QuestWatch.FadeAll and Nx.Quest.Watch.Win:GetFade() or 1, true)
							end,
						},
						qwbgcol = {
							order = 29,
							type = "color",
							width = "full",
							name = L["Quest Watch Background Color"],
							hasAlpha = true,
							get = function()
								local arr = { Nx.Split("|",Nx.qdb.profile.QuestWatch.BGColor) }
								local r = arr[1]
								local g = arr[2]
								local b = arr[3]
								local a = arr[4]
								return r,g,b,a
							end,
							set = function(_,r,g,b,a)
								Nx.qdb.profile.QuestWatch.BGColor = r .. "|" .. g .. "|" .. b .. "|" .. a
								Nx.Quest:SetCols()
								Nx.Quest.Watch:Update()
							end,
						},
						qwcompletecol = {
							order = 30,
							type = "color",
							width = "full",
							name = L["Quest Complete Color"],
							hasAlpha = true,
							get = function()
								local arr = { Nx.Split("|",Nx.qdb.profile.QuestWatch.CompleteColor) }
								local r = arr[1]
								local g = arr[2]
								local b = arr[3]
								local a = arr[4]
								return r,g,b,a
							end,
							set = function(_,r,g,b,a)
								Nx.qdb.profile.QuestWatch.CompleteColor = r .. "|" .. g .. "|" .. b .. "|" .. a
								Nx.Quest:SetCols()
								Nx.Quest.Watch:Update()
							end,
						},
						qwicompletecol = {
							order = 31,
							type = "color",
							width = "full",
							name = L["Quest Incomplete Color"],
							hasAlpha = true,
							get = function()
								local arr = { Nx.Split("|",Nx.qdb.profile.QuestWatch.IncompleteColor) }
								local r = arr[1]
								local g = arr[2]
								local b = arr[3]
								local a = arr[4]
								return r,g,b,a
							end,
							set = function(_,r,g,b,a)
								Nx.qdb.profile.QuestWatch.IncompleteColor = r .. "|" .. g .. "|" .. b .. "|" .. a
								Nx.Quest:SetCols()
								Nx.Quest.Watch:Update()
							end,
						},
						qwocompletecol = {
							order = 32,
							type = "color",
							width = "full",
							name = L["Objective Complete Color"],
							hasAlpha = true,
							get = function()
								local arr = { Nx.Split("|",Nx.qdb.profile.QuestWatch.OCompleteColor) }
								local r = arr[1]
								local g = arr[2]
								local b = arr[3]
								local a = arr[4]
								return r,g,b,a
							end,
							set = function(_,r,g,b,a)
								Nx.qdb.profile.QuestWatch.OCompleteColor = r .. "|" .. g .. "|" .. b .. "|" .. a
								Nx.Quest:SetCols()
								Nx.Quest.Watch:Update()
							end,
						},
						qwoincompletecol = {
							order = 33,
							type = "color",
							width = "full",
							name = L["Objective Incomplete Color"],
							hasAlpha = true,
							get = function()
								local arr = { Nx.Split("|",Nx.qdb.profile.QuestWatch.OIncompleteColor) }
								local r = arr[1]
								local g = arr[2]
								local b = arr[3]
								local a = arr[4]
								return r,g,b,a
							end,
							set = function(_,r,g,b,a)
								Nx.qdb.profile.QuestWatch.OIncompleteColor = r .. "|" .. g .. "|" .. b .. "|" .. a
								Nx.Quest:SetCols()
								Nx.Quest.Watch:Update()
							end,
						},
						qwobjshade = {
							order = 34,
							type = "toggle",
							width = "full",
							name = L["Color Objective Based on Progress"],
							desc = L["When enabled, will color your objectives based on how complete they are"],
							get = function()
								return Nx.qdb.profile.QuestWatch.ShowPerColor
							end,
							set = function()
								Nx.qdb.profile.QuestWatch.ShowPerColor = not Nx.qdb.profile.QuestWatch.ShowPerColor
								Nx.Quest.Watch:Update()
							end,
						},
						spacer4 = {
							order = 35,
							type = "description",
							width = "full",
							name = " ",
						},
						qwiconsize = {
							order = 36,
							type = "range",
							name = L["Clickable Icon Size (0 disables)"],
							desc = L["If a quest has an item to be used, will draw it beside the quest at the size defined here"],
							min = 0,
							max = 50,
							step = 1,
							bigStep = 1,
							get = function()
								return Nx.qdb.profile.QuestWatch.ItemScale
							end,
							set = function(info,value)
								Nx.qdb.profile.QuestWatch.ItemScale = value
								Nx.Quest.Watch:Update()
							end,
						},
						spacer5 = {
							order = 37,
							type = "description",
							width = "full",
							name = " ",
						},
						qwitemalpha = {
							order = 38,
							type = "color",
							width = "full",
							name = L["Item Transparency"],
							desc = L["Only uses the Alpha value, and is used to make clickable items in the watch list transparent"],
							hasAlpha = true,
							get = function()
								local arr = { Nx.Split("|",Nx.qdb.profile.QuestWatch.ItemAlpha) }
								local r = arr[1]
								local g = arr[2]
								local b = arr[3]
								local a = arr[4]
								return r,g,b,a
							end,
							set = function(_,r,g,b,a)
								Nx.qdb.profile.QuestWatch.ItemAlpha = r .. "|" .. g .. "|" .. b .. "|" .. a
								Nx.Quest.Watch:Update()
							end,
						},
						spacer6 = {
							order = 39,
							type = "description",
							width = "full",
							name = " ",
						},
						QuestWatchFont = {
							order = 40,
							type = "select",
							name = L["Quest Watch Font"],
							desc = L["Sets the font to be used on the quest watch window"],
							get	= function()
								local vals = Nx.Opts:CalcChoices("FontFace","Get")
								for a,b in pairs(vals) do
								  if (b == Nx.qdb.profile.QuestWatch.WatchFont) then
									 return a
								  end
								end
								return ""
							end,
							set	= function(info, name)
								local vals = Nx.Opts:CalcChoices("FontFace","Get")
								Nx.qdb.profile.QuestWatch.WatchFont = vals[name]
								Nx.Opts:NXCmdFontChange()
							end,
							values	= function()
								return Nx.Opts:CalcChoices("FontFace","Get")
							end,
						},
						QuestWatchFontSize = {
							order = 41,
							type = "range",
							name = L["Watch Font Size"],
							desc = L["Sets the size of the quest watch font"],
							min = 6,
							max = 20,
							step = 1,
							bigStep = 1,
							get = function()
								return Nx.qdb.profile.QuestWatch.WatchFontSize
							end,
							set = function(info,value)
								Nx.qdb.profile.QuestWatch.WatchFontSize = value
								Nx.Opts:NXCmdFontChange()
							end,
						},
						QuestWatchFontSpacing = {
							order = 42,
							type = "range",
							name = L["Watch Font Spacing"],
							desc = L["Sets the spacing of the quest watch font"],
							min = -10,
							max = 20,
							step = 1,
							bigStep = 1,
							get = function()
								return Nx.qdb.profile.QuestWatch.WatchFontSpacing
							end,
							set = function(info,value)
								Nx.qdb.profile.QuestWatch.WatchFontSpacing = value
								Nx.Opts:NXCmdFontChange()
							end,
						},
					},
				},
				sounds = {
					type = "group",
					name = L["Sound Options"],
					order = 3,
					args = {
						sndEnable = {
							order = 1,
							type = "toggle",
							width = "full",
							name = L["Play Quest Complete Sound"],
							desc = L["When enabled, one of the selected sounds below will play on quest completion"],
							get = function()
								return Nx.qdb.profile.Quest.SndPlayCompleted
							end,
							set = function()
								Nx.qdb.profile.Quest.SndPlayCompleted = not Nx.qdb.profile.Quest.SndPlayCompleted
							end,
						},
						sndtitle = {
							order = 2,
							type = "description",
							width = "full",
							name = L["Place a check in sounds you want carbonite to play when a quest is complete.\nChecking a box will play the sound for you to hear."]
						},
						snd1 = {
							order = 3,
							type = "toggle",
							width = "full",
							name = L["Carbonite Quest Complete"],
							get = function()
								return Nx.qdb.profile.Quest.Snd1
							end,
							set = function()
								Nx.qdb.profile.Quest.Snd1 = not Nx.qdb.profile.Quest.Snd1
								if Nx.qdb.profile.Quest.Snd1 then
									Nx.Quest:PlaySound(1)
								end
							end,
						},
						snd2 = {
							order = 4,
							type = "toggle",
							width = "full",
							name = L["Peon Work Complete"],
							get = function()
								return Nx.qdb.profile.Quest.Snd2
							end,
							set = function()
								Nx.qdb.profile.Quest.Snd2 = not Nx.qdb.profile.Quest.Snd2
								if Nx.qdb.profile.Quest.Snd2 then
									Nx.Quest:PlaySound(2)
								end
							end,
						},
						snd3 = {
							order = 5,
							type = "toggle",
							width = "full",
							name = L["Undead Well Done"],
							get = function()
								return Nx.qdb.profile.Quest.Snd3
							end,
							set = function()
								Nx.qdb.profile.Quest.Snd3 = not Nx.qdb.profile.Quest.Snd3
								if Nx.qdb.profile.Quest.Snd3 then
									Nx.Quest:PlaySound(3)
								end
							end,
						},
						snd4 = {
							order = 6,
							type = "toggle",
							width = "full",
							name = L["Female Congratulations"],
							get = function()
								return Nx.qdb.profile.Quest.Snd4
							end,
							set = function()
								Nx.qdb.profile.Quest.Snd4 = not Nx.qdb.profile.Quest.Snd4
								if Nx.qdb.profile.Quest.Snd4 then
									Nx.Quest:PlaySound(4)
								end
							end,
						},
						snd5 = {
							order = 7,
							type = "toggle",
							width = "full",
							name = L["Dwarven Well Done"],
							get = function()
								return Nx.qdb.profile.Quest.Snd5
							end,
							set = function()
								Nx.qdb.profile.Quest.Snd5 = not Nx.qdb.profile.Quest.Snd5
								if Nx.qdb.profile.Quest.Snd5 then
									Nx.Quest:PlaySound(5)
								end
							end,
						},
						snd6 = {
							order = 8,
							type = "toggle",
							width = "full",
							name = L["Gnome Good Job"],
							get = function()
								return Nx.qdb.profile.Quest.Snd6
							end,
							set = function()
								Nx.qdb.profile.Quest.Snd6 = not Nx.qdb.profile.Quest.Snd6
								if Nx.qdb.profile.Quest.Snd6 then
									Nx.Quest:PlaySound(6)
								end
							end,
						},
						snd7 = {
							order = 9,
							type = "toggle",
							width = "full",
							name = L["Tauren Well Done"],
							get = function()
								return Nx.qdb.profile.Quest.Snd7
							end,
							set = function()
								Nx.qdb.profile.Quest.Snd7 = not Nx.qdb.profile.Quest.Snd7
								if Nx.qdb.profile.Quest.Snd7 then
									Nx.Quest:PlaySound(7)
								end
							end,
						},
						snd8 = {
							order = 10,
							type = "toggle",
							width = "full",
							name = L["Undead What Now"],
							get = function()
								return Nx.qdb.profile.Quest.Snd8
							end,
							set = function()
								Nx.qdb.profile.Quest.Snd8 = not Nx.qdb.profile.Quest.Snd8
								if Nx.qdb.profile.Quest.Snd8 then
									Nx.Quest:PlaySound(8)
								end
							end,
						},
					},
				},
				database = {
					type = "group",
					name = L["Databases"],
					order = 4,
					args = {
						title = {
							order = 1,
							type = "description",
							name = L["Reload the UI with the button at the bottom to change which quests are loaded."],
						},
						spacer1 = {
							order = 2,
							type = "description",
							name = " ",
						},
						maxLoadLevel = {
							order = 3,
							type = "toggle",
							width = "full",
							name = L["Load quest data by threshold"],
							desc = L["Loads all the carbonite quest data between player level - level threshold to 60"],
							get = function()
								return Nx.qdb.profile.Quest.maxLoadLevel
							end,
							set = function()
								Nx.qdb.profile.Quest.maxLoadLevel = not Nx.qdb.profile.Quest.maxLoadLevel
								Nx.Opts.NXCmdReload()
							end,
						},
						LevelsToLoad = {
							order = 4,
							type = "range",
							name = L["Level Threshold"],
							desc = L["Levels above player level to load quest data on reload"],
							min = 1,
							max = 60,
							step = 1,
							bigStep = 1,
							get = function()
								return Nx.qdb.profile.Quest.LevelsToLoad
							end,
							set = function(info,value)
								Nx.qdb.profile.Quest.LevelsToLoad = value
								--Nx.Opts:NXCmdFontChange()
							end,
						},
						spacer2 = {
							order = 5,
							type = "description",
							name = " ",
						},
						q0 = {
							order = 6,
							type = "toggle",
							width = "full",
							name = L["Load Quests for Level 0 (holidays, professions, etc)"],
							desc = L["Loads all the carbonite quest data in this range on reload"],
							get = function()
								return Nx.qdb.profile.Quest.Load0
							end,
							set = function()
								Nx.qdb.profile.Quest.Load0 = not Nx.qdb.profile.Quest.Load0
							end,
						},
						q1 = {
							order = 7,
							type = "toggle",
							width = "full",
							name = L["Load Quests for Levels 1-10"],
							desc = L["Loads all the carbonite quest data in this range on reload"],
							get = function()
								return Nx.qdb.profile.Quest.Load1
							end,
							set = function()
								Nx.qdb.profile.Quest.Load1 = not Nx.qdb.profile.Quest.Load1
							end,
						},
						q2 = {
							order = 8,
							type = "toggle",
							width = "full",
							name = L["Load Quests for Levels 11-20"],
							desc = L["Loads all the carbonite quest data in this range on reload"],
							get = function()
								return Nx.qdb.profile.Quest.Load2
							end,
							set = function()
								Nx.qdb.profile.Quest.Load2 = not Nx.qdb.profile.Quest.Load2
							end,
						},
						q3 = {
							order = 9,
							type = "toggle",
							width = "full",
							name = L["Load Quests for Levels 21-30"],
							desc = L["Loads all the carbonite quest data in this range on reload"],
							get = function()
								return Nx.qdb.profile.Quest.Load3
							end,
							set = function()
								Nx.qdb.profile.Quest.Load3 = not Nx.qdb.profile.Quest.Load3
							end,
						},
						q4 = {
							order = 10,
							type = "toggle",
							width = "full",
							name = L["Load Quests for Levels 31-40"],
							desc = L["Loads all the carbonite quest data in this range on reload"],
							get = function()
								return Nx.qdb.profile.Quest.Load4
							end,
							set = function()
								Nx.qdb.profile.Quest.Load4 = not Nx.qdb.profile.Quest.Load4
							end,
						},
						q5 = {
							order = 11,
							type = "toggle",
							width = "full",
							name = L["Load Quests for Levels 41-50"],
							desc = L["Loads all the carbonite quest data in this range on reload"],
							get = function()
								return Nx.qdb.profile.Quest.Load5
							end,
							set = function()
								Nx.qdb.profile.Quest.Load5 = not Nx.qdb.profile.Quest.Load5
							end,
						},
						q6 = {
							order = 12,
							type = "toggle",
							width = "full",
							name = L["Load Quests for Levels 51-60"],
							desc = L["Loads all the carbonite quest data in this range on reload"],
							get = function()
								return Nx.qdb.profile.Quest.Load6
							end,
							set = function()
								Nx.qdb.profile.Quest.Load6 = not Nx.qdb.profile.Quest.Load6
							end,
						},
						spacer3 = {
							order = 19,
							type = "description",
							name = " ",
						},
						gather = {		-- Change to qgather perhaps?
							order = 20,
							type = "toggle",
							width = "full",
							name = L["Quests Data Gathering"],
							desc = L["Gathers quests data"],
							get = function()
								return Nx.db.profile.General.CaptureEnable
							end,
							set = function()
								Nx.db.profile.General.CaptureEnable = not Nx.db.profile.General.CaptureEnable
							end,
						},
						spacer4 = {
							order = 21,
							type = "description",
							name = " ",
						},
						reboot = {
							order = 22,
							type = "execute",
							width = "full",
							func = function()
								Nx.Opts.NXCmdReload()
							end,
							name = L["Reload UI"]
						},
					},
				},
			},
		}
	end
	Nx.Opts:AddToProfileMenu(L["Quest"],3,Nx.qdb)
	return questoptions
end

function CarboniteQuest:OnInitialize()
	if not Nx.Initialized then
		CarbQuestInit = Nx:ScheduleTimer(CarboniteQuest.OnInitialize,5)
		return
	end
	Nx.qdb = LibStub("AceDB-3.0"):New("NXQuest",defaults, true)
	Nx.Quest:ConvertData()
	Nx.Quest:InitQuestCharacter()
	Nx.Font:ModuleAdd("Quest.QuestFont",{ "NxFontQ", "GameFontNormal","qdb" })
	Nx.Font:ModuleAdd("QuestWatch.WatchFont",{ "NxFontW", "GameFontNormal","qdb" })
	Nx.Map.Maps[1].PIconMenu:AddItem (0, "Get Quests", Nx.Map.Menu_OnGetQuests,Nx.Map.Maps[1])
	Nx.Quest.List.LoggingIn = true
	local qopts = Nx.qdb.profile.QuestOpts

	if not qopts or qopts.Version < Nx.VERSIONQOPTS then

		if qopts then
			Nx.prt (L["Reset old quest options %f"], qopts.Version)
		end

		qopts = {}
		Nx.qdb.profile.QuestOpts = qopts
		qopts.Version = Nx.VERSIONQOPTS

		Nx.Quest:OptsReset()
	end
	tinsert(Nx.ModuleUpdateIcon,"Quest")
	Nx.Button.TypeData["QuestHdr"] = {
		Bool = true,
		Skin = true,
		Up = "RoundMinus",
		Dn = "RoundPlus",
		SizeUp = 11,
		SizeDn = 11,
		VRGBAUp = ".56|.56|.56|1",
		VRGBADn = ".56|.56|.56|1",
	}
	Nx.Button.TypeData["QuestWatching"] = {
		Bool = true,
		Up = "Interface\\Addons\\Carbonite\\Gfx\\Buttons\\DotOn",
		Dn = "Interface\\Addons\\Carbonite\\Gfx\\Buttons\\DotOn",
		SizeUp = 11,
		SizeDn = 11,
		VRGBAUp = "1|1|.25|.5",
		VRGBADn = ".87|.87|.185|.94",
	}
	Nx.Button.TypeData["QuestWatchMenu"] = {
		Tip = L["Menu"],
		Skin = true,
		Up = "ButWatchMenu",
		Dn = "ButWatchMenu",
		SizeUp = 14,
		SizeDn = 14,
		VRGBAUp = "1|1|1|.5",
		VRGBADn = "1|1|1|.75",
	}
	Nx.Button.TypeData["QuestWatchPri"] = {
		Tip = L["Priorities"],
		Skin = true,
		Up = "ButWatchMenu",
		Dn = "ButWatchMenu",
		SizeUp = 14,
		SizeDn = 14,
		VRGBAUp = "1|1|.5|.5",
		VRGBADn = "1|1|.5|.75",
	}
	Nx.Button.TypeData["QuestWatchSwap"] = {
		Tip = L["Swap Views"],
		Skin = true,
		Up = "ButWatchMenu",
		Dn = "ButWatchMenu",
		SizeUp = 14,
		SizeDn = 14,
		VRGBAUp = "1|1|1|.5",
		VRGBADn = "1|1|1|.75",
	}
	Nx.Button.TypeData["QuestWatchShowOnMap"] = {
		Tip = L["Show Quests On Map"],
		Bool = true,
		Up = "Interface\\Addons\\Carbonite\\Gfx\\Buttons\\DotOn",
		Dn = "Interface\\Addons\\Carbonite\\Gfx\\Buttons\\DotOn",
		SizeUp = 10,
		SizeDn = 13,
		VRGBAUp = ".25|1|.25|.56",
		VRGBADn = ".25|1|.25|.87",
	}
	Nx.Button.TypeData["QuestWatchATrack"] = {
		Tip = L["Auto Track"],
		Bool = true,
		Up = "Interface\\Addons\\Carbonite\\Gfx\\Buttons\\DotOn",
		Dn = "Interface\\Addons\\Carbonite\\Gfx\\Buttons\\DotOn",
		SizeUp = 10,
		SizeDn = 13,
		VRGBAUp = "1|0|1|.56",
		VRGBADn = "1|.25|1|.87",
	}
	Nx.Button.TypeData["QuestWatchGivers"] = {
		Tip = L["Quest Givers"],
		States = 3,
		Tx = "Interface\\Addons\\Carbonite\\Gfx\\Buttons\\DotOn",
		{
			Size = 10,
			VRGBA = "1|.811|.25|.56",
		},
		{
			Size = 13,
			VRGBA = "1|.811|.25|.87",
		},
		{
			Size = 13,
			VRGBA = ".56|.56|1|.87",
		}
	}
	Nx.Button.TypeData["QuestWatchParty"] = {
		Tip = L["Show Party Quests"],
		Bool = true,
		Up = "Interface\\Addons\\Carbonite\\Gfx\\Buttons\\DotOn",
		Dn = "Interface\\Addons\\Carbonite\\Gfx\\Buttons\\DotOn",
		SizeUp = 10,
		SizeDn = 13,
		VRGBAUp = ".811|.811|.811|.56",
		VRGBADn = "1|1|1|.87",
	}
	Nx.Button.TypeData["QuestWatch"] = {
		Bool = true,
		Up = "Interface\\Addons\\Carbonite\\Gfx\\Buttons\\DotOn",
		Dn = "Interface\\Addons\\Carbonite\\Gfx\\Buttons\\DotOn",
		SizeUp = 9,
		SizeDn = 9,
		AlphaUp = .3,
		AlphaDn = .85,
	}
	Nx.Button.TypeData["QuestWatchAC"] = {		-- Auto complete
		Up = "Interface\\Addons\\Carbonite\\Gfx\\Map\\IconQuestion",
		SizeUp = 15,
		VRGBAUp = ".75|1|.75|1",
	}
	Nx.Button.TypeData["QuestWatchTip"] = {
		Up = "Interface\\Addons\\Carbonite\\Gfx\\Buttons\\DotOn",
		Dn = "Interface\\Addons\\Carbonite\\Gfx\\Buttons\\DotOn",
		SizeUp = 7,
		SizeDn = 7,
		VRGBAUp = "0|0|0|.313",
		VRGBADn = "0|0|0|.5",
		WatchTip = 1
	}
	Nx.Button.TypeData["QuestWatchTipItem"] = {
		SizeUp = 11,
		SizeDn = 11,
		VRGBAUp = "1|1|1|.75",
		VRGBADn = "1|1|1|1",
		WatchTip = 1
	}
	Nx.Button.TypeData["QuestWatchCustomTip"] = {
		Up = "Interface\\Addons\\Carbonite\\Gfx\\Buttons\\DotOn",
		Dn = "Interface\\Addons\\Carbonite\\Gfx\\Buttons\\DotOn",
		SizeUp = 11,
		SizeDn = 11,
		VRGBAUp = "1|1|1|.75",
		VRGBADn = "1|1|1|1",
		CustomTip = 1
	}
	Nx.Button.TypeData["QuestWatchEmissaryTip"] = {
		Bool = true,
		Up = "Interface\\Addons\\Carbonite\\Gfx\\Buttons\\DotOn",
		Dn = "Interface\\Addons\\Carbonite\\Gfx\\Buttons\\DotOn",
		SizeUp = 9,
		SizeDn = 9,
		AlphaUp = .3,
		AlphaDn = .85,
		EmissaryTip = 1
	}
	Nx.Button.TypeData["QuestWatchTarget"] = {
		Bool = true,
		Up = "Interface\\Addons\\Carbonite\\Gfx\\Buttons\\DotOn",
		Dn = "Interface\\Addons\\Carbonite\\Gfx\\Buttons\\DotOn",
		SizeUp = 12,
		SizeDn = 12,
		AlphaUp = .4,
		AlphaDn = 1,
	}
	Nx.Button.TypeData["QuestWatchErr"] = {
		Up = "Interface\\Addons\\Carbonite\\Gfx\\Buttons\\DotOn",
		Dn = "Interface\\Addons\\Carbonite\\Gfx\\Buttons\\DotOn",
		SizeUp = 9,
		SizeDn = 12,
		VRGBAUp = "1|.5|.125|.435",
		VRGBADn = "1|.5|.125|.94",
		WatchError = 1
	}
	Nx.Button.TypeData["QuestWatchTrial"] = {
		Up = "Interface\\Addons\\Carbonite\\Gfx\\Buttons\\DotOn",
		Dn = "Interface\\Addons\\Carbonite\\Gfx\\Buttons\\DotOn",
		SizeUp = 9,
		SizeDn = 12,
		VRGBAUp = "1|1|.25|.686",
		VRGBADn = "1|1|.25|1",
	}
	Nx.Button.TypeData["QuestListWatch"] = {
		Bool = true,
		Up = "Interface\\Addons\\Carbonite\\Gfx\\Buttons\\DotOn",
		Dn = "Interface\\Addons\\Carbonite\\Gfx\\Buttons\\DotOn",
		SizeUp = 9,
		SizeDn = 9,
		VRGBAUp = "1|1|1|.31",
		VRGBADn = "1|1|1|.85",
	}
	Nx.Button.TypeData["WQListMenu"] = {
		Tip = L["Menu"],
		Skin = true,
		Up = "ButWatchMenu",
		Dn = "ButWatchMenu",
		SizeUp = 14,
		SizeDn = 14,
		VRGBAUp = "1|1|1|.5",
		VRGBADn = "1|1|1|.75",
	}
	-- Capture data
	local cap = NXQuest.Gather

	if not cap or cap.Version < Nx.VERSIONCAP then
		cap = {}
		cap.Version = Nx.VERSIONCAP
		cap["Q"] = {}
		NXQuest.Gather = cap
	end

	NXQuest.Gather.UserLocale = GetLocale()

	Nx.Quest:Init()
	if Nx.qdb.profile.Quest.Enable then
		Nx.Quest:HideUIPanel (_G["QuestMapFrame"])
	end
	CarboniteQuest:RegisterComm("carbmodule",Nx.Quest.OnChat_msg_addon)
	Nx:AddToConfig("Quest Module",QuestOptions(),L["Quest Module"])
	Nx.Quest:SetCols()
	Nx.Quest.Initialized = true
	Nx.Quest.RecordQuests(true)
	Nx.Quest.List:LogUpdate()
	--CarboniteQuest:OnTrackedAchievementsUpdate()
	Nx.Quest.Watch:Update()
	Nx.Quest.WQList:Update()
	
	-- Update Emmissaries
	local pLvl = UnitLevel ("player")
	if not hideBfAEmmissaries and pLvl > 111 then emmBfA = GetQuestBountyInfoForMapID(875) end
	if not hideLegionEmmissaries and pLvl > 109 then emmLegion = GetQuestBountyInfoForMapID(619) end
	
	tinsert(Nx.BrokerMenuTemplate,{ text = L["Toggle Quest Watch"], func = function() Nx.Quest.Watch.Win:Show(not Nx.Quest.Watch.Win:IsShown()) end })
	tinsert(Nx.Whatsnew.Categories, "Quests")
	Nx.Whatsnew.Quests = {
		[1504562405] = {"Sept 4th 2017","","New feature for world quests.","Carbonite Quests now has it's own WorldQuest Tracker","","You can find it as World Quest List under the menu in the top left of quest watch.","(Play button icon)"}
	}
	
	Nx.qdb.RegisterCallback(Nx.Quest, "OnProfileChanged", "OnProfileChanged")
	Nx.qdb.RegisterCallback(Nx.Quest, "OnProfileCopied", "OnProfileChanged")
	Nx.qdb.RegisterCallback(Nx.Quest, "OnProfileReset", "OnProfileChanged")
end

function Nx.Quest:OnProfileChanged(event, database, newProfileKey)
	if event == "OnProfileReset" then
		qopts = {}
		Nx.qdb.profile.QuestOpts = qopts
		qopts.Version = Nx.VERSIONQOPTS
		Nx.Quest:OptsReset()
	end
		
	Nx.Opts.NXCmdReload()
end

function Nx.Quest:InitQuestCharacter()
	local chars = Nx.qdb.global.Characters
	local fullName = Nx:GetRealmCharName()
	local ch = chars[fullName]
	if not ch then
		ch = {}
	end
	if not ch.Q then
		ch.Q = {}
	end
	Nx.Quest.CurCharacter = ch
end

function Nx.Quest:OnChat_msg_addon(msg,dist,target)
	if msg == "QUEST_DECODE" then
		Nx.Quest:DecodeComRcv (Nx.qTEMPinfo, Nx.qTEMPmsg)
	end
end

function Nx.Quest:ConvertData()
	if not Nx.qdb.global then
		Nx.qdb.global = {}
	end
	if not Nx.qdb.global.Characters then
		Nx.qdb.global.Characters = {}
	end
	for ch,data in pairs(Nx.db.global.Characters) do
		if not Nx.qdb.global.Characters[ch] then
			Nx.qdb.global.Characters[ch] = {}
		end
		if Nx.db.global.Characters[ch].Q then
			Nx.qdb.global.Characters[ch].Q = Nx.db.global.Characters[ch].Q
			Nx.db.global.Characters[ch].Q = nil
		end
	end
end

function Nx.Quest:OptsReset()

	local qopts = Nx.Quest:GetQuestOpts()

	qopts.NXShowHeaders = true
	qopts.NXSortWatchMode = 1

	qopts.NXWAutoMax = nil
	qopts.NXWVisMax = 8
	qopts.NXWShowOnMap = true
	qopts.NXWWatchParty = true
	
	qopts.NXWHideBfAEmmissaries = false
	qopts.NXWHideLegionEmmissaries = false
	
	qopts.NXWHideUnfinished = false
	qopts.NXWHideGroup = false
	qopts.NXWHideNotInZone = false
	qopts.NXWHideNotInCont = false
	qopts.NXWHideDist = 20000

	qopts.NXWPriDist = 1
	qopts.NXWPriComplete = 50
	qopts.NXWPriLevel = 20

	qopts.NXWPriGroup = -100			-- Not used yet
end

---------------------------------------------------------------------------------------
-- DEBUG
---------------------------------------------------------------------------------------

--function Nx.Quest.SelectQuestLogEntry (qn)
--	Nx.prt ("QSel %s", qn)
--	Nx.Quest.OldSelectQuestLogEntry (qn)
--end

---------------------------------------------------------------------------------------
-- Init quest and watch data and windows
---------------------------------------------------------------------------------------

function Nx.Quest:Init()
	
	QuestWatchFrame:Hide()
	
	self.Enabled = Nx.qdb.profile.Quest.Enable
	if not self.Enabled then

--		Nx.Quest = nil
		Nx.Quests = nil	-- Data
		return
	end

	self.GOpts = Nx.db.profile

	if Nx.qdb.profile.QuestWatch.BlizzModify then
--		if not GetCVarBool ("advancedWatchFrame") then

--			SetCVar ("questFadingDisable", 1)	--V4 gone
			SetCVar ("autoQuestProgress", 0)
			SetCVar ("autoQuestWatch", 0)
--			SetCVar ("advancedWatchFrame", 1)
--			SetCVar ("watchFrameIgnoreCursor", 0)
--		end
	end

	-- DEBUG
--	self.OldSelectQuestLogEntry = SelectQuestLogEntry
--	SelectQuestLogEntry = Nx.Quest.SelectQuestLogEntry

	-- Force it to create/enable and then we disable
	GetUIPanelWidth (QuestLogFrame)
	--QuestLogFrame:SetAttribute ("UIPanelLayout-enabled", false)

	if QuestLogDetailFrame then	-- Patch 3.2
		GetUIPanelWidth (QuestLogDetailFrame)
		QuestLogDetailFrame:SetAttribute ("UIPanelLayout-enabled", false)
	end

	local Map = Nx.Map

	self.QIds = {}					-- Our quests by id
	self.QIdsNew = {}				-- Time stamp of getting a new quest. [Id] = time()

	self.Tracking = {}
	self.Sorted = {}

	self.CurQ = {}					-- Current quests (including gotos)
	self.RealQ = {}				-- Real Blizzard quests
	self.RealQEntries = 0
	self.PartyQ = {}				-- Party quests

	self.IdToCurQ = {}

	self.HeaderExpanded = {}	-- Blizzard quest headers we expanded
	self.HeaderHide = {}			-- Names of quest headers to hide

	self.RcvPlyrLast = "None"
	self.RcvCnt = 0
	self.RcvTotal = 0
	self.FriendQuests = {}

	self.IconTracking = {}
	self.QInit = false

	self:CalcWatchColors()

	self.TagNames = {
		["Group"] = "+",
		["Legendary"] = "L",
		["Heroic"] = "H",
		["Account"] = "A",
		["Raid"] = "R",
		["Dungeon"] = "D",
		["Elite"] = "*",
	}

	self.PerColors = {
		"|cffc00000", "|cffc03000", "|cffc06000", "|cffc09000", "|cffc0c000", "|cff90c000", "|cff60c000", "|cff30c000", "|cff00c000",
	}

	self.CapturePlyrData = {}

	self.CapFactionAbr = {
		["Argent Crusade"] = 1,
		["Argent Dawn"] = 2,
		["Ashtongue Deathsworn"] = 3,
		["Bloodsail Buccaneers"] = 4,
		["Booty Bay"] = 5,
		["Brood of Nozdormu"] = 6,
		["Cenarion Circle"] = 7,
		["Cenarion Expedition"] = 8,
		["Darkmoon Faire"] = 9,
		["Darkspear Trolls"] = 10,
		["Darnassus"] = 11,
		["Everlook"] = 12,
		["Exodar"] = 13,
		["Explorers' League"] = 14,
		["Frenzyheart Tribe"] = 15,
		["Frostwolf Clan"] = 16,
		["Gadgetzan"] = 17,
		["Gelkis Clan Centaur"] = 18,
		["Gnomeregan Exiles"] = 19,
		["Honor Hold"] = 20,
		["Hydraxian Waterlords"] = 21,
		["Ironforge"] = 22,
		["Keepers of Time"] = 23,
		["Kirin Tor"] = 24,
		["Knights of the Ebon Blade"] = 25,
		["Kurenai"] = 26,
		["Lower City"] = 27,
		["Magram Clan Centaur"] = 28,
		["Netherwing"] = 29,
		["Ogri'la"] = 30,
		["Orgrimmar"] = 31,
		["Ratchet"] = 32,
		["Ravenholdt"] = 33,
		["Sha'tari Skyguard"] = 34,
		["Shattered Sun Offensive"] = 35,
		["Shen'dralar"] = 36,
		["Silvermoon City"] = 37,
		["Silverwing Sentinels"] = 38,
		["Sporeggar"] = 39,
		["Stormpike Guard"] = 40,
		["Stormwind"] = 41,
		["Syndicate"] = 42,
		["The Aldor"] = 43,
		["The Consortium"] = 44,
		["The Defilers"] = 45,
		["The Frostborn"] = 46,
		["The Hand of Vengeance"] = 47,
		["The Kalu'ak"] = 48,
		["The League of Arathor"] = 49,
		["The Mag'har"] = 50,
		["The Oracles"] = 51,
		["The Scale of the Sands"] = 52,
		["The Scryers"] = 53,
		["The Sha'tar"] = 54,
		["The Silver Covenant"] = 55,
		["The Sons of Hodir"] = 56,
		["The Taunka"] = 57,
		["The Violet Eye"] = 58,
		["The Wyrmrest Accord"] = 59,
		["Thorium Brotherhood"] = 60,
		["Thrallmar"] = 61,
		["Thunder Bluff"] = 62,
		["Timbermaw Hold"] = 63,
		["Tranquillien"] = 64,
		["Undercity"] = 65,
		["Valiance Expedition"] = 66,
		["Warsong Offensive"] = 67,
		["Warsong Outriders"] = 68,
		["Wildhammer Clan"] = 69,
		["Wintersaber Trainers"] = 70,
		["Zandalar Tribe"] = 71,
	}

	self.DailyTypes = {
		["1"] = L["Daily"],
		["2"] = L["Daily Dungeon"],
		["3"] = L["Daily Heroic"],
	}
	self.Reputations = {
		["A"] = L["Aldor"],
		["S"] = L["Scryer"],
		["c"] = L["Consortium"],
		["e"] = L["Cenarion Expedition"],
		["g"] = L["Sha'tari Skyguard"],
		["k"] = L["Keepers of Time"],
		["l"] = L["Lower City"],
		["n"] = L["Netherwing"],
		["o"] = L["Ogri'la"],
		["s"] = L["Shattered Sun Offensive"],
		["t"] = L["Sha'tar"],
		["z"] = L["Honor Hold/Thrallmar"],
		-- WotLK
		["C"] = L["Argent Crusade"],
		["E"] = L["Explorers' League"],
		["F"] = L["Frenzyheart Tribe"],
		["f"] = L["The Frostborn"],
		["H"] = L["Horde Expedition"],
		["K"] = L["The Kalu'ak"],
		["i"] = L["Kirin Tor"],
		["N"] = L["Knights of the Ebon Blade"],
		["O"] = L["The Oracles"],
		["h"] = L["The Sons of Hodir"],
		["a"] = L["Alliance Vanguard"],
		["V"] = L["Valiance Expedition"],
		["W"] = L["Warsong Offensive"],
		["w"] = L["The Wyrmrest Accord"],
		["I"] = L["The Silver Covenant"],		-- Patch 3.1
		["R"] = L["The Sunreavers"],				-- Patch 3.1
	}
	self.Requirements = {
--		["1"] = L["Alliance"],		-- Already stripped out by quest side removal code
--		["2"] = L["Horde"],
		["oH"] = L["Ogri'la Honored"],
		["H350"] = L["Herbalism 350"],
		["M350"] = L["Mining 350"],
		["S350"] = L["Skining 350"],
		["G"] = L["Gathering Skill"],
		["nF"] = L["Netherwing Friendly"],
		["nH"] = L["Netherwing Honored"],
		["nRA"] = L["Netherwing Revered (Aldor)"],
		["nRS"] = L["Netherwing Revered (Scryer)"],
		-- WotLK
		["hH"] = L["The Sons of Hodir Honored"],
		["hR"] = L["The Sons of Hodir Revered"],
		["J375"] = L["Jewelcrafting 375"],
		["C"] = L["Cooking"],
		["F"] = L["Fishing"],
	}

	self.DailyIds = {
		-- Type ^ Reward (Gold*100+Silver) ^ Rep letter/Rep amount (000) ^ Requirement
		-- Req - H herb, M mine, S skin, G any gather, F friendly, H honored, R revered

		-- Honor Hold/Thrallmar
		[10106] = "1^70^z150",		-- Hellfire Fortifications
		[10110] = "1^70^z150",		-- Hellfire Fortifications
		-- Ogri'la
		[11023] = "1^1199^o500g500",	-- Bomb Them Again!
		[11066] = "1^1199^o350g350",	-- Wrangle More Aether Rays!
		[11080] = "1^910^o350",		-- The Relic's Emanation
		[11051] = "1^1199^o350^oH",	-- Banish More Demons
		-- Netherwing
		[11020] = "1^1199^n250",	-- A Slow Death
		[11035] = "1^1199^n250",	-- The Not-So-Friendly Skies...
		[11049] = "1^1828^n350",	-- The Great Netherwing Egg Hunt
		[11015] = "1^1199^n250",	-- Netherwing Crystals
		[11017] = "1^1199^n250^H350",	-- Netherdust Pollen (Herbalist)
		[11018] = "1^1199^n250^M350",	-- Nethercite Ore (Miner)
		[11016] = "1^1199^n250^S350",	-- Nethermine Flayer Hide (Skinner)
		[11055] = "1^1199^n350^nF",	-- The Booterang: A Cure For The Common Worthless Peon
		[11076] = "1^1828^n350^nF",	-- Picking Up The Pieces...
		[11086] = "1^1199^n500^nH",	-- Disrupting the Twilight Portal
		[11101] = "1^1828^n500^nRA",	-- The Deadliest Trap Ever Laid (Aldor)
		[11097] = "1^1828^n500^nRS",	-- The Deadliest Trap Ever Laid (Scryer)
		-- Shattered Sun
		[11514] = "1^1010^s250",	-- Maintaining the Sunwell Portal
		[11515] = "1^1199^s250",	-- Blood for Blood
		[11516] = "1^1010^s250",	-- Blast the Gateway
		[11521] = "1^1388^s350",	-- Rediscovering Your Roots
		[11523] = "1^910^s150",		-- Arm the Wards!
		[11525] = "1^910^s150",		-- Further Conversions
		[11533] = "1^910^s150",		-- The Air Strikes Must Continue
		[11536] = "1^1199^s250",	-- Don't Stop Now....
		[11537] = "1^1010^s250",	-- The Battle Must Go On
		[11540] = "1^1199^s250",	-- Crush the Dawnblade
		[11541] = "1^1199^s250",	-- Disrupt the Greengill Coast
		[11543] = "1^759^s250",		-- Keeping the Enemy at Bay
		[11544] = "1^1828^s350",	-- Ata'mal Armaments
		[11546] = "1^1199^s250",	-- Open for Business
		[11547] = "1^1199^s250",	-- Know Your Ley Lines
		[11548] = "1^-1000^s150",	-- Your Continued Support
		[11877] = "1^1010^s250",	-- Sunfury Attack Plans
		[11880] = "1^910^s250",		-- The Multiphase Survey
		[11875] = "1^1639^s250^G",	-- Gaining the Advantage
		-- Skettis
		[11008] = "1^1199^g350",	-- Fires Over Skettis
		[11085] = "1^910^g150",		-- Escape from Skettis

		-- WotLK Borean Tundra
		[11940] = "1^470^w250",		-- Drake Hunt
		[11945] = "1^500^K500",		-- Preparing for the Worst
		[13414] = "1^740^w250",		-- Aces High!
		-- WotLK Howling Fjord
		[11153] = "1^470^a 38V250^1",	-- Break the Blockade
		[11391] = "1^470^E250^1",	-- Steel Gate Patrol
		[11472] = "1^470^K500",		-- The Way to His Heart...
		-- WotLK Dragonblight
		[11960] = "1^500^K500",		-- Planning for the Future
		[12372] = "1^560^w250",		-- Defending Wyrmrest Temple
		-- WotLK Grizzly Hills
		[12437] = "1^560^^1",		-- Riding the Red Rocket
		[12444] = "1^560^a 38V250^1",	-- Blackriver Skirmish
		[12316] = "1^560^^1",		-- Keep Them at Bay!
		[12289] = "1^560^a 38V250^1",	-- Kick 'Em While They're Down
		[12296] = "1^560^a 38V250^1",	-- Life or Death
		[12268] = "1^560^^1",		-- Pieces Parts
		[12244] = "1^560^^1",		-- Shredder Repair
		[12323] = "1^560^^1",		-- Smoke 'Em Out
		[12314] = "1^560^^1",		-- Down With Captain Zorna!
		[12038] = "1^986",		-- Seared Scourge
		[12433] = "1^560",		-- Seeking Solvent
		[12170] = "1^560^H250^2",	-- Blackriver Brawl
		[12284] = "1^560^W250^2",	-- Keep 'Em on Their Heels
		[12280] = "1^560^W250^2",	-- Making Repairs
		[12288] = "1^560^W250^2",	-- Overwhelmed!
		[12270] = "1^560^W250^2",	-- Shred the Alliance
		[12315] = "1^560^^2",		-- Crush Captain Brightwater!
		[12324] = "1^560^^2",		-- Smoke 'Em Out
		[12317] = "1^560^^2",		-- Keep Them at Bay
		[12432] = "1^560^^2",		-- Riding the Red Rocket
		-- WotLK Zul'Drak
		[12501] = "1^620^C250",		-- Troll Patrol
		[12541] = "1^158^C 75",		-- Troll Patrol: The Alchemist's Apprentice
		[12502] = "1^158^C 75",		-- Troll Patrol: High Standards
		[12564] = "1^158^C 75",		-- Troll Patrol: Something for the Pain
		[12588] = "1^158^C 75",		-- Troll Patrol: Can You Dig It?
		[12568] = "1^158^C 75",		-- Troll Patrol: Done to Death
		[12509] = "1^158^C250",		-- Troll Patrol: Intestinal Fortitude
		[12591] = "1^158^C 75",		-- Troll Patrol: Throwing Down
		[12585] = "1^158^C 75",		-- Troll Patrol: Creature Comforts
		[12519] = "1^158^C 25",		-- Troll Patrol: Whatdya Want, a Medal?
		[12594] = "1^158^C 75",		-- Troll Patrol: Couldn't Care Less
		[12604] = "1^1860^C350",	-- Congratulations!
		-- WotLK Sholazar Basin
		[12704] = "1^650^O250",		-- Appeasing the Great Rain Stone
		[12761] = "1^1360^O350",	-- Mastery of the Crystals
		[12762] = "1^1360^O350",	-- Power of the Great Ones
		[12705] = "1^1360^O350",	-- Will of the Titans
		[12735] = "1^740^O500",		-- A Cleansing Song
		[12737] = "1^740^O250",		-- Song of Fecundity
		[12736] = "1^740^O250",		-- Song of Reflection
		[12726] = "1^740^O500",		-- Song of Wind and Water
		[12689] = "1^330^O***",		-- Hand of the Oracles (one time rep bonus)
		[12582] = "1^330^F***",		-- Frenzyheart Champion (one time rep bonus)
		[12702] = "1^650^F500",		-- Chicken Party!
		[12703] = "1^1360^F350",	-- Kartak's Rampage
		[12760] = "1^1360^F350",	-- Secret Strength of the Frenzyheart
		[12759] = "1^1360^F350",	-- Tools of War
		[12734] = "1^740^F500",		-- Rejek: First Blood
		[12758] = "1^740^F500",		-- A Hero's Headgear
		[12741] = "1^740^F500",		-- Strength of the Tempest (check rep??)
		[12732] = "1^740^F500",		-- The Heartblood's Strength
		-- WotLK Icecrown
		[13309] = "1^740^V250^1",	-- Assault by Air
		[13284] = "1^740^V250^1",	-- Assault by Ground
		[13336] = "1^740^V250^1",	-- Blood of the Chosen
		[13323] = "1^740^^1",		-- Drag and Drop
		[13344] = "1^740^^1",		-- Not a Bug
		[13322] = "1^740^^1",		-- Retest Now
		[13404] = "1^740^^1",		-- Static Shock Troops: the Bombardment
		[13300] = "1^740^C250^1",	-- Slaves to Saronite
		[13289] = "1^740^^1",		-- That's Abominable!
		[13292] = "1^740^^1",		-- The Solution Solution
		[13333] = "1^740^^1",		-- Capture More Dispatches
		[13297] = "1^2220^^1",		-- Neutralizing the Plague
		[13350] = "1^2220^^1",		-- No Rest For The Wicked
		[13280] = "1^740^V250^1",	-- King of the Mountain
		[13233] = "1^740^^1",		-- No Mercy!
		[13310] = "1^740^W250^2",	-- Assault by Air
		[13301] = "1^740^W250^2",	-- Assault by Ground
		[13330] = "1^740^W250^2",	-- Blood of the Chosen
		[13353] = "1^740^^2",		-- Drag and Drop
		[13365] = "1^740^^2",		-- Not a Bug
		[13357] = "1^740^^2",		-- Retest Now
		[13406] = "1^740^^2",		-- Riding the Wavelength: The Bombardment
		[13302] = "1^740^C250^2",	-- Slaves to Saronite
		[13376] = "1^740^^2",		-- Total Ohmage: The Valley of Lost Hope!
		[13276] = "1^740^^2",		-- That's Abominable!
		[13331] = "1^740^W250^2",	-- Keeping the Alliance Blind
		[13261] = "1^740^^2",		-- Volatility
		[13281] = "1^2220^^2",		-- Neutralizing the Plague
		[13368] = "1^2220^^2",		-- No Rest For The Wicked
		[13283] = "1^740^W250^2",	-- King of the Mountain
		[13234] = "1^740^^2",		-- Make Them Pay!
		[12813] = "1^740^N250",		-- From Their Corpses, Rise!
		[12838] = "1^740^N250",		-- Intelligence Gathering
		[12995] = "1^740^N250",		-- Leave Our Mark
		[12815] = "1^740^N250",		-- No Fly Zone
		[13069] = "1^740^N250",		-- Shoot 'Em Up
		[13071] = "1^370^N250",		-- Vile Like Fire!
		-- WotLK Icecrown Argent Tournament
--		[13681] = "1^740",		-- A Chip Off the Ulduar Block (OLD)
--		[13627] = "1^740",		-- Jack Me Some Lumber (OLD)
		[13625] = "1^580^I250",		-- Learning The Reins (A)
		[13677] = "1^580^R250",		-- Learning The Reins (H)
		[13671] = "1^580^I250",		-- Training In The Field (A)
		[13676] = "1^580^R250",		-- Training In The Field (H)
		[13666] = "1^580^I250",		-- A Blade Fit For A Champion (A)
		[13603] = "1^740^I250",		-- A Blade Fit For A Champion
		[13741] = "1^740^I250",		-- A Blade Fit For A Champion
		[13746] = "1^740^I250",		-- A Blade Fit For A Champion
		[13752] = "1^740^I250",		-- A Blade Fit For A Champion
		[13757] = "1^740^I250",		-- A Blade Fit For A Champion
		[13673] = "1^580^R250",		-- A Blade Fit For A Champion (H)
		[13762] = "1^740^R250",		-- A Blade Fit For A Champion
		[13768] = "1^740^R250",		-- A Blade Fit For A Champion
		[13783] = "1^740^R250",		-- A Blade Fit For A Champion
		[13773] = "1^740^R250",		-- A Blade Fit For A Champion
		[13778] = "1^740^R250",		-- A Blade Fit For A Champion
		-- WotLK The Storm Peaks
		[12994] = "1^740^h350^hH",	-- Spy Hunter
		[12833] = "1^680",		-- Overstock
		[13424] = "1^740",		-- Back to the Pit (Hyldnir Spoils)
		[12977] = "1^740^h250",		-- Blowing Hodir's Horn
		[13423] = "1^740",		-- Defending Your Title (Hyldnir Spoils)
		[13046] = "1^740^h250^hR",	-- Feeding Arngrim
		[12981] = "1^740^h250",		-- Hot and Cold
		[13422] = "1^550",		-- Maintaining Discipline (Hyldnir Spoils)
		[13006] = "1^740^h250",		-- Polishing the Helm
		[12869] = "1^680^f250",		-- Pushed Too Far
		[13425] = "1^740",		-- The Aberrations Must Die (Hyldnir Spoils)
		[13003] = "1^1480^h500^hH",	-- Thrusting Hodir's Spear
		-- WotLK Wintergrasp
		[13156] = "1^740",		-- A Rare Herb
		[13195] = "1^740",		-- A Rare Herb
		[13154] = "1^740",		-- Bones and Arrows
		[13193] = "1^740",		-- Bones and Arrows
		[13196] = "1^740",		-- Bones and Arrows
		[13199] = "1^740",		-- Bones and Arrows
		[13222] = "1^740",		-- Defend the Siege
		[13223] = "1^740",		-- Defend the Siege
		[13191] = "1^740",		-- Fueling the Demolishers
		[13197] = "1^740",		-- Fueling the Demolishers
		[13200] = "1^740",		-- Fueling the Demolishers
		[13194] = "1^740",		-- Healing with Roses
		[13201] = "1^740",		-- Healing with Roses
		[13202] = "1^740",		-- Jinxing the Walls
		[13177] = "1^740",		-- No Mercy for the Merciless
		[13179] = "1^740",		-- No Mercy for the Merciless
		[13178] = "1^740",		-- Slay them all!
		[13180] = "1^740",		-- Slay them all!
		[13538] = "1^740",		-- Southern Sabotage
		[13185] = "1^740",		-- Stop the Siege
		[13186] = "1^740",		-- Stop the Siege
		[13539] = "1^740",		-- Toppling the Towers
		[13181] = "1^740",		-- Victory in Wintergrasp
		[13183] = "1^740",		-- Victory in Wintergrasp
		[13192] = "1^740",		-- Warding the Walls
		[13153] = "1^740",		-- Warding the Warriors
		[13198] = "1^740",		-- Warding the Warriors
		-- WotLK Cooking
		[13101] = "1^580^i150^C",	-- Convention at the Legerdemain
		[13113] = "1^580^i150^C",	-- Convention at the Legerdemain
		[13100] = "1^580^i150^C",	-- Infused Mushroom Meatloaf
		[13112] = "1^580^i150^C",	-- Infused Mushroom Meatloaf
		[13107] = "1^580^i150^C",	-- Mustard Dogs!
		[13116] = "1^580^i150^C",	-- Mustard Dogs!
		[13102] = "1^580^i150^C",	-- Sewer Stew
		[13114] = "1^580^i150^C",	-- Sewer Stew
		-- WotLK Jewelcrafting
		[12958] = "1^740^i 25^J375",	-- Shipment: Blood Jade Amulet
		[12962] = "1^740^i 25^J375",	-- Shipment: Bright Armor Relic
		[12959] = "1^740^i 25^J375",	-- Shipment: Glowing Ivory Figurine
		[12961] = "1^740^i 25^J375",	-- Shipment: Intricate Bone Figurine
		[12963] = "1^740^i 25^J375",	-- Shipment: Shifting Sun Curio
		[12960] = "1^740^i 25^J375",	-- Shipment: Wicked Sun Brooch
		-- WotLK Fishing
		[13833] = "1^0^i250^F",		-- Blood Is Thicker
		[13834] = "1^0^i250^F",		-- Dangerously Delicious
		[13832] = "1^0^i250^F",		-- Jewel Of The Sewers
		[13836] = "1^0^i250^F",		-- Monsterbelly Appetite
		[13830] = "1^0^i250^F",		-- The Ghostfish
	}
	self.DailyDungeonIds = {
		-- Dungeon
		[11389] = "2^1639^c250t250",	-- Wanted: Arcatraz Sentinels
		[11371] = "2^1639^c250e250",	-- Wanted: Coilfang Myrmidons
		[11376] = "2^1639^c250l250",	-- Wanted: Malicious Instructors
		[11383] = "2^1639^c250k250",	-- Wanted: Rift Lords
		[11364] = "2^1639^c250z250",	-- Wanted: Shattered Hand Centurions
		[11500] = "2^1639^c250s250",	-- Wanted: Sisters of Torment
		[11385] = "2^1639^c250t250",	-- Wanted: Sunseeker Channelers
		[11387] = "2^1639^c250t250",	-- Wanted: Tempest-Forge Destroyers
		-- Dungeon Heroic
		[11369] = "3^2460^c250e250",	-- Wanted: A Black Stalker Egg
		[11384] = "3^2460^c350t350",	-- Wanted: A Warp Splinter Clipping
		[11382] = "3^2460^c350k350",	-- Wanted: Aeonus's Hourglass
		[11363] = "3^2460^c350z350",	-- Wanted: Bladefist's Seal
		[11362] = "3^2460^c350z350",	-- Wanted: Keli'dan's Feathered Stave
		[11375] = "3^2460^c350l350",	-- Wanted: Murmur's Whisper
		[11354] = "3^2460^c350z350",	-- Wanted: Nazan's Riding Crop
		[11386] = "3^2460^c350t350",	-- Wanted: Pathaleon's Projector
		[11373] = "3^2460^c500",	-- Wanted: Shaffar's Wondrous Pendant
		[11378] = "3^2460^c350k350",	-- Wanted: The Epoch Hunter's Head
		[11374] = "3^2460^c350l350",	-- Wanted: The Exarch's Soul Gem
		[11372] = "3^2460^c350l350",	-- Wanted: The Headfeathers of Ikiss
		[11368] = "3^2460^c350e350",	-- Wanted: The Heart of Quagmirran
		[11388] = "3^2460^c350t350",	-- Wanted: The Scroll of Skyriss
		[11499] = "3^2460^c350s350",	-- Wanted: The Signet Ring of Prince Kael'thas
		[11370] = "3^2460^c350e350",	-- Wanted: The Warlord's Treatise
		-- WotLK Dungeon
		[13240] = "2^3466^i 75",	-- Timear Foresees Centrifuge Constructs in your Future!
		[13243] = "2^3466^i 75",	-- Timear Foresees Infinite Agents in your Future!
		[13244] = "2^3466^i 75",	-- Timear Foresees Titanium Vanguards in your Future!
		[13241] = "2^3466^i 75",	-- Timear Foresees Ymirjar Berserkers in your Future!
		-- WotLK Dungeon Heroic
		[13190] = "2^4200",		-- All Things in Good Time
		[13254] = "2^4866^i 75",	-- Proof of Demise: Anub'arak
		[13256] = "2^4866^i 75",	-- Proof of Demise: Cyanigosa
		[13250] = "2^4866^i 75",	-- Proof of Demise: Gal'darah
		[13255] = "2^4866^i 75",	-- Proof of Demise: Herald Volazj
		[13245] = "2^4866^i 75",	-- Proof of Demise: Ingvar the Plunderer
		[13246] = "2^4866^i 75",	-- Proof of Demise: Keristrasza
		[13248] = "2^4866^i 75",	-- Proof of Demise: King Ymiron
		[13247] = "2^4866^i 75",	-- Proof of Demise: Ley-Guardian Eregos
		[13253] = "2^4866^i 75",	-- Proof of Demise: Loken
		[13251] = "2^4866^i 75",	-- Proof of Demise: Mal'Ganis
		[13252] = "2^4866^i 75",	-- Proof of Demise: Sjonnir The Ironshaper
		[14199] = "2^4866^i 75",	-- Proof of Demise: The Black Knight
		[13249] = "2^4866^i 75",	-- Proof of Demise: The Prophet Tharon'ja
	}
	self.DailyPVPIds = {			-- For not auto watching
		[11335] = "1",			-- AV, AB, EOS, WG both sides
		[11336] = "1",
		[11337] = "1",
		[11338] = "1",
		[11339] = "1",
		[11340] = "1",
		[11341] = "1",
		[11342] = "1",
		[13405] = "1",			-- SoA
		[13407] = "1",
		[14163] = "1",			-- IoC
		[14164] = "1",
	}

	--	DEBUG for Jamie
	Nx.Quest:LoadQuestDB()
	--

	self.List:Open()
	self.Watch:Open()		
	self.WQList:Open()
	
	-- Menu

	local menu = Nx.Menu:Create (self.Map.Frm)
	self.IconMenu = menu

	menu:AddItem (0, "Track", self.Menu_OnTrack, self)
	menu:AddItem (0, "Show Quest Log", self.Menu_OnShowQuest, self)
	self.IconMenuIWatch = menu:AddItem (0, "Watch", self.Menu_OnWatch, self)

	menu:AddItem (0, "Add Note", self.Map.Menu_OnAddNote, self.Map)

	-- Hook quests

	self.BlizzAcceptQuest = AcceptQuest
	AcceptQuest = self.AcceptQuest

--[[	self.BlizzCompleteQuest = CompleteQuest
	CompleteQuest = self.CompleteQuest ]]--

	self.BlizzGetQuestReward = GetQuestReward
	GetQuestReward = self.GetQuestReward

	local function func()
--		Nx.prt ("QAccept")
		--[[if QuestGetAutoAccept() then
--			Nx.prt ("auto")
			Nx.Quest:RecordQuestAcceptOrFinish()
		end]]--
		
		QuestFrameDetailPanel_OnShow()
		
		local qId = GetQuestID()
		local quest = Nx.Quests[qId]
		local name, side, lvl, minlvl, nextId, category, xp = self:Unpack (quest["Quest"])
		xp = xp or 0
		
		QuestInfoRewardsFrame.XPFrame:Hide()
		if xp > 0 then
			QuestInfo_ToggleRewardElement(QuestInfoRewardsFrame.XPFrame, BreakUpLargeNumbers(xp), QuestInfoRewardsFrame)
			QuestInfoRewardsFrame.XPFrame:Show()
		end
		
		local auto = Nx.qdb.profile.Quest.AutoAccept
		if IsShiftKeyDown() and IsControlKeyDown() then
			auto = not auto
		end
		if auto then
			AcceptQuest()
		end
	end

	QuestFrameDetailPanel:SetScript ("OnShow", func);

	-- Hook tooltip

	local ttHooks = {
		"SetAction", 
		"SetAuctionItem", 
		"SetBagItem", 
		--"SetGuildBankItem", 
		"SetHyperlink", 
		"SetInboxItem", 
		"SetInventoryItem", 
		"SetLootItem",
		"SetLootRollItem", 
		"SetMerchantItem", 
		--"SetRecipeReagentItem",
		--"SetRecipeResultItem",
		"SetQuestItem", 
		"SetQuestLogItem", 
		"SetTradeTargetItem",
	}

	for k, name in ipairs (ttHooks) do
			hooksecurefunc (GameTooltip, name, Nx.Quest.TooltipHook)
	end

	local unitNames = {	-- 5 letter and shorter words are already blocked
		"Hunter", "Paladin", "Priest",
		"Shaman", "Warlock", "Warrior", "Deathknight", "Demonhunter"
	}

	self.TTIgnore = {
		["Attack"] = true,
		["Lumber Mill"] = true,
		["Stables"] = true,
		["Blacksmith"] = true,
		["Gold Mine"] = true,
	}

	self.TTIgnore[UnitName ("player")] = true

	for _, v in pairs (unitNames) do
		self.TTIgnore[v] = true
	end

	self.TTChange = {
		["Bloodberry Bush"] = "Bloodberries",
		["Erratic Sentry"] = "Erratic Sentries",
	}

	--hooksecurefunc ("ShowUIPanel", CarboniteQuest.ShowUIPanel)
	--hooksecurefunc ("HideUIPanel", CarboniteQuest.HideUIPanel)
	--[[hooksecurefunc ("ToggleQuestLog", function(...)
		Nx.Map.WMFOnShow = false
		local orig = IsAltKeyDown() and not self.IgnoreAlt
		if Nx.qdb.profile.Quest.UseAltLKey then
			orig = not orig
		end
		if not orig then
			
		end
		Nx.Map.WMFOnShow = truel
	end)]]--
	Nx.Quest.OldToggleQuestLog = ToggleQuestLog
	function ToggleQuestLog(...)
		Nx.Map.WMFOnShow = false
		local orig = IsAltKeyDown() and not self.IgnoreAlt
		if Nx.qdb.profile.Quest.UseAltLKey then
			orig = not orig
		end
		if orig then
			--WorldMapFrame:SetQuestLogPanelShown(true)
			Nx.Quest:OldToggleQuestLog()
		else
			if self.InShowUIPanel then
				Nx.Quest:HideUIPanel(QuestMapFrame)
				self.InShowUIPanel = false
			else
				Nx.Quest:ShowUIPanel(QuestMapFrame)
				self.InShowUIPanel = true
			end
		end	
		Nx.Map.WMFOnShow = true
	end
	--[[Nx.Quest.OldWindow = ToggleQuestLog
	function ToggleQuestLog(...)
		local orig = IsAltKeyDown() and not self.IgnoreAlt
		if Nx.qdb.profile.Quest.UseAltLKey then
			orig = not orig
		end
		if orig then
			Nx.Map.WMFOnShow = false
			self.IsOrigOpen = WorldMapFrame:IsShown()
			if self.IsOrigOpen then
				HideUIPanel(WorldMapFrame)
			else
				QuestMapFrame_Open(true)
				OpenQuestLog()
			end
			Nx.Map.WMFOnShow = true
		else
			--if self.IsOpen then
			--	self.IsOpen = QuestMapFrame:IsShown()
			--end
			if self.InShowUIPanel then
				Nx.Quest:HideUIPanel(QuestMapFrame)
				self.InShowUIPanel = false
			else
				Nx.Quest:ShowUIPanel(QuestMapFrame)
				self.InShowUIPanel = true
			end
		end
	end]]--
end

-------
-- Changing orginal Blizz functions to fix quest map toggle

--[[local oQuestMapFrame_Show = QuestMapFrame_Show
function QuestMapFrame_Show()
	QuestMapFrame:SetFrameLevel(2)
	if UnitAffectingCombat("player") then 
		QuestMapFrame_UpdateAll();
		QuestMapFrame:SetFrameLevel(4)
		QuestMapFrame:Show();
		
		WorldMapFrame.UIElementsFrame.OpenQuestPanelButton:Hide();
		WorldMapFrame.UIElementsFrame.CloseQuestPanelButton:Show();
		return 
	end
	oQuestMapFrame_Show()
end

local oQuestMapFrame_Hide = QuestMapFrame_Hide
function QuestMapFrame_Hide()
	if UnitAffectingCombat("player") then 
		QuestMapFrame:Hide();
		QuestMapFrame_UpdateAll();
		
		WorldMapFrame.UIElementsFrame.OpenQuestPanelButton:Show();
		WorldMapFrame.UIElementsFrame.CloseQuestPanelButton:Hide();
		return
	end
	oQuestMapFrame_Hide()
end]]--

function CarboniteQuest.ShowUIPanel(frame)
	if frame then
		if frame == _G["QuestMapFrame"] and Nx.qdb.profile.Quest.Enable then
			Nx.Quest:ShowUIPanel (frame)
		end
	end
end

function CarboniteQuest.HideUIPanel (frame)
	if frame then
		if frame == _G["QuestMapFrame"] and Nx.qdb.profile.Quest.Enable then
			Nx.Quest:HideUIPanel (frame)
		end
	end
end

function Nx.Quest:ProcessQuestDB(questTotal)
	if InCombatLockdown() then
		C_Timer.After(5, function() Nx.Quest:ProcessQuestDB(questTotal) end)
		return
	end
	local maxLoadLevel = Nx.qdb.profile.Quest.maxLoadLevel
	local enFact = Nx.PlFactionNum == 1 and 1 or 2
	local qLoadLevel = max(1, UnitLevel ("player") + Nx.qdb.profile.Quest.LevelsToLoad)
	local qMaxLevel = 999

	for mungeId, q in pairs (Nx.Quests) do
		if mungeId < 0 then
			if Nx.Quests[abs(mungeId)] then
				--Nx.prt(mungeId)
				Nx.Quests[mungeId] = nil
			end
		else
			local name, side, level, minlevel, qnext = self:Unpack (q["Quest"])
			if side == enFact or level > 0 and (maxLoadLevel and level > qLoadLevel) or level > qMaxLevel then
				Nx.Quests[mungeId] = nil
			else
				--[[if q["End"] and q["End"] == q["Start"] then
				no enders
				end]]
				self:CheckQuestSE (q, 3)
				for n = 1, 99 do
					if not q[n] then
						break
					end
					self:CheckQuestObj (q, n)
				end
				-- insert to sorted table (need to do proper sorting)
				tinsert(self.Sorted, mungeId)
				if not q.CNum and qnext and qnext > 0 then
					local clvlmax = level
					local qc = q
					local cnum = 0
					local _qids = {}
					while qc do
						cnum = cnum + 1
						qc.CNum = cnum
						local name, side, level, minlevel, qnext = self:Unpack (qc["Quest"])
						clvlmax = max (clvlmax, level)
						if not qnext or qnext == 0 or _qids[qnext] == true or cnum > 40 then
							break
						end
						_qids[qnext] = true;
						qc = Nx.Quests[qnext]
					end
					q.CLvlMax = clvlmax		-- Max level in chain
				end
			end
		end
	end

--[[
	for lvl = 0, 110 do
		local grp = {}
		for id, q in pairs (Nx.Quests) do
			if id > 0 then
				local name, side, level = self:Unpack (q["Quest"])
				if level == lvl then
					if side ~= enFact then
						if not q.CNum then
							tinsert (grp, format ("%s^%d", name, id))
						elseif q.CNum == 1 then
							local qc = q
							local _qids = {}
							while qc do
								local pname, side, _, _, next = self:Unpack (qc["Quest"])
								if _qids[next] == true then
									break
								end
								_qids[next] = true;
								tinsert (grp, format ("%s%2d^%d", name, qc.CNum, id))
								qc = Nx.Quests[next]
								id = next
							end
						end
					end
				end
			end
		end
		for _, v in ipairs (grp) do
			local name, id = Nx.Split ("^", v)
			tinsert (self.Sorted, tonumber (id))
		end
	end
	]]--
	local usedIds = {}
	local starters = {}
	self.QGivers = starters
	for qsIndex, qId in pairs (self.Sorted) do
		if not usedIds[qId] then
			local quest = Nx.Quests[qId]
			if quest then
				local sName, zone, x, y = self:GetSEPos (quest["Start"])
				if zone and x ~= 0 and y ~= 0 then
					usedIds[qId] = true
					sName = format ("%s=%d%d", sName, x, y)
					local stmap = starters[zone] or {}
					starters[zone] = stmap
					local s = stmap[sName] or ""
					stmap[sName] = s .. format ("%4x", qId)
				end
			end
		end
	end
	Nx.prt("|cff00ff00[|cffffff00QUEST LOADER|cff00ff00] |cffffffff" .. questTotal .. " Quests Loaded")
	Nx.QInit = true
	--Nx.Quest.List:LogUpdate()
	C_Timer.After(1, function() Nx.Quest:RecordQuests() end)
	--Nx.Quest.Watch:Update()
end

function Nx.Quest:LoadQuestDB()
	local questTotal = 0
	local timeDelay = 1
	local numQLoad = 0;
	local maxQLoad = 0;
	local Map = Nx.Map
	self.Map = Map:GetMap (1)
	Nx.Quests = {}
	Nx.prt("|cff00ff00[|cffffff00QUEST LOADER|cff00ff00] |cffffffffStarting Background Quest Data Loading...")
	if Nx.qdb.profile.Quest.Load0 then
		C_Timer.After(1, function() questTotal = questTotal + Nx.ModQuests:Load0(); numQLoad = numQLoad - 1; end)
		timeDelay = timeDelay + 1
		numQLoad = numQLoad + 1
		maxQLoad = maxQLoad + 1
	else
		Nx.ModQuests:Clear0()
	end
	if Nx.qdb.profile.Quest.Load1 then
		C_Timer.After(1, function() questTotal = questTotal + Nx.ModQuests:Load1(); numQLoad = numQLoad - 1; end)
		timeDelay = timeDelay + 1
		numQLoad = numQLoad + 1
		maxQLoad = maxQLoad + 1
	else
		Nx.ModQuests:Clear1()
	end
	if Nx.qdb.profile.Quest.Load2 then
		C_Timer.After(1, function() questTotal = questTotal + Nx.ModQuests:Load2(); numQLoad = numQLoad - 1; end)
		timeDelay = timeDelay + 1
		numQLoad = numQLoad + 1
		maxQLoad = maxQLoad + 1
	else
		Nx.ModQuests:Clear2()
	end
	if Nx.qdb.profile.Quest.Load3 then
		C_Timer.After(1, function() questTotal = questTotal + Nx.ModQuests:Load3(); numQLoad = numQLoad - 1; end)
		timeDelay = timeDelay + 1
		numQLoad = numQLoad + 1
		maxQLoad = maxQLoad + 1
	else
		Nx.ModQuests:Clear3()
	end
	if Nx.qdb.profile.Quest.Load4 then
		C_Timer.After(1, function() questTotal = questTotal + Nx.ModQuests:Load4(); numQLoad = numQLoad - 1; end)
		timeDelay = timeDelay + 1
		numQLoad = numQLoad + 1
		maxQLoad = maxQLoad + 1
	else
		Nx.ModQuests:Clear4()
	end
	if Nx.qdb.profile.Quest.Load5 then
		C_Timer.After(1, function() questTotal = questTotal + Nx.ModQuests:Load5(); numQLoad = numQLoad - 1; end)
		timeDelay = timeDelay + 1
		numQLoad = numQLoad + 1
		maxQLoad = maxQLoad + 1
	else
		Nx.ModQuests:Clear5()
	end
	if Nx.qdb.profile.Quest.Load6 then
		C_Timer.After(1, function() questTotal = questTotal + Nx.ModQuests:Load6(); numQLoad = numQLoad - 1; end)
		timeDelay = timeDelay + 1
		numQLoad = numQLoad + 1
		maxQLoad = maxQLoad + 1
	else
		Nx.ModQuests:Clear6()
	end

	local qStep = 100 / maxQLoad
	C_Timer.NewTicker(1, function(self)
		if (Nx.Initialized == true and numQLoad == 0) or self._remainingIterations == 0 then
			self:Cancel()
			Nx.ModQuests = {} -- Destroing unused table to free memory as we never use it again
			C_Timer.After(1, function() Nx.Quest:ProcessQuestDB(questTotal) end)
			return
		end
		--Nx.prt("|cff00ff00[|cffffff00QUEST LOADER|cff00ff00] |cffffffffLoading Quest Data... (%d%%)", ( math.floor(qStep * (maxQLoad - numQLoad)) ))
	end, 120)
end

function Nx.Quest:SetCols()
	Nx.Quest.Cols["compColor"] = Nx.Util_str2colstr (Nx.qdb.profile.QuestWatch.CompleteColor)
	Nx.Quest.Cols["incompColor"] = Nx.Util_str2colstr (Nx.qdb.profile.QuestWatch.IncompleteColor)
	Nx.Quest.Cols["oCompColor"] = Nx.Util_str2colstr (Nx.qdb.profile.QuestWatch.OCompleteColor)
	Nx.Quest.Cols["oIncompColor"] = Nx.Util_str2colstr (Nx.qdb.profile.QuestWatch.OIncompleteColor)
	Nx.Quest.Cols["BGColorR"], Nx.Quest.Cols["BGColorG"], Nx.Quest.Cols["BGColorB"], Nx.Quest.Cols["BGColorA"] =  Nx.Util_str2rgba (Nx.qdb.profile.QuestWatch.BGColor)
	Nx.Quest.Cols["trkR"], Nx.Quest.Cols["trkG"], Nx.Quest.Cols["trkB"], Nx.Quest.Cols["trkA"] =  Nx.Util_str2rgba (Nx.qdb.profile.Quest.MapWatchAreaTrackColor)
	Nx.Quest.Cols["hovR"], Nx.Quest.Cols["hovG"], Nx.Quest.Cols["hovB"], Nx.Quest.Cols["hovA"] =  Nx.Util_str2rgba (Nx.qdb.profile.Quest.MapWatchAreaHoverColor)
end

function Nx.Quest:CheckQuestSE (q, n)

	local _, zone, x, y = self:GetSEPos (q[n])
	local mapId = zone

	if (x == 0 or y == 0) and mapId and not Nx.Map:IsInstanceMap (mapId) then
		q[n] = format ("%s# ####", strsub (q[n], 1, 2))	-- Zero it to get a red button
--		local oName = self:UnpackSE (q[n])
--		Nx.prt ("zeroed %s, %s", self:UnpackName (q[1]), oName)
	end
end

function Nx.Quest:CheckQuestObj (q, n)

	local oName, zone, x, y = self:GetObjectivePos (q[n])
	local mapId = zone

	if (x == 0 or y == 0) and mapId and not Nx.Map:IsInstanceMap (mapId) then
		q[n] = format ("%c%s# ####", #oName + 35, oName)	-- Zero it to get a red button
--		Nx.prt ("zeroed %s, %s", self:UnpackName (q[1]), oName)
	end
end

-------------------------------------------------------------------------------
-- Calculate the watch colors
-------------------------------------------------------------------------------

function Nx.Quest:CalcWatchColors()

--	Nx.QLocColors = { 1,0,0, "QuestWatchR", 0,1,0, "QuestWatchG", .2,.2,1, "QuestWatchB" }

	local opts = self.GOpts

	local colors = {}
	self.QLocColors = colors

	local a = Nx.Util_str2a (Nx.qdb.profile.Quest.MapWatchAreaAlpha)

	local colMax = Nx.qdb.profile.Quest.MapWatchColorCnt
	local colI = 1

	for n = 1, 15 do

		local color = {}
		colors[n] = color

		local r, g, b = Nx.Util_str2rgba (Nx.qdb.profile.Quest["MapWatchC" .. colI])
		color[1] = r
		color[2] = g
		color[3] = b
		color[4] = a
		color[5] = "QuestListWatch"

		colI = colI + 1
		colI = colI > colMax and 1 or colI
	end
end

-------------------------------------------------------------------------------
-- Menu
-------------------------------------------------------------------------------

function Nx.Quest:Menu_OnTrack()

	local cur = self.IconMenuCur
	local v = cur.QId * 0x10000 + self.IconMenuObjI * 0x100 + cur.QI

--	Nx.prt ("Track %x (%d)", v, self.IconMenuObjI)

	self.Watch:Set (v, true, true)

--	self.IconMenuCur
--	self.IconMenuObjI
end

function Nx.Quest:Menu_OnShowQuest()

	ToggleQuestLog()
	--ShowUIPanel (QuestMapFrame)

	self.List.Bar:Select (1)

	local cur = self.IconMenuCur
	self.List:Select (cur.QId, cur.QI)
end

function Nx.Quest:Menu_OnWatch (item)

	local cur = self.IconMenuCur
	self.List:ToggleWatch (cur.QId, cur.QI, 0)
end

-------------------------------------------------------------------------------
-- Track quest acception
-------------------------------------------------------------------------------

function Nx.Quest.AcceptQuest (...)

	Nx.Quest:RecordQuestAcceptOrFinish()
	Nx.Quest.BlizzAcceptQuest (...)
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------

--[[
function Nx.Quest.CompleteQuest (...)

--	Nx.prt ("CompleteQuest ")
--	Nx.prt ("Title '%s'", GetTitleText())

	Nx.Quest.BlizzCompleteQuest (...)
end
--]]

function Nx.Quest.GetQuestReward (choice, ...)

--	Nx.prt ("GetQuestReward %s", choice or "nil")

	local q = Nx.Quest
	q:FinishQuest()
	q.BlizzGetQuestReward (choice, ...)
end

function Nx.Quest:FinishQuest()

--	Nx.prt ("FinishQuest")

	local finTitle = GetTitleText()
	finTitle = self:ExtractTitle (finTitle)

	local i, cur = self:FindCur (finTitle)

	if not i then

--		Nx:ShowMessage (Nx.TXTBLUE.."Carb:\n|rCan't find quest in list!\nAn addon may have modified the title\n'" .. finTitle .. "'", "Continue")
--		assert (nil)
		return
	end

	cur.QI = 0		-- 0 so we dont get a final party message

	local qId = cur.QId

	assert (type (qId) ~= "string")

	local id = qId > 0 and qId or cur.Title
	Nx.Quest:SetQuest (id, "C", time())

	self:RecordQuestAcceptOrFinish()
	self:Capture (i, -1)

--	Nx.prt ("FinishQuest #%s (%s) %s", i, id, cur.Title)

	if cur.Q then

		self.Tracking[qId] = 0
		self:TrackOnMap (qId, 0)
	end

--	self.List:Update()
	self.Watch:Update()
	self.WQList:Update()
end

-------------------------------------------------------------------------------
-- Do Blizzard select quest
-------------------------------------------------------------------------------

function Nx.Quest:SelectBlizz (qi)
	if qi > 0 then
		SelectQuestLogEntry (qi)
	end
end

-------------------------------------------------------------------------------
-- Expand any collapsed quests
-------------------------------------------------------------------------------

function Nx.Quest:ExpandQuests()

--	if next (self.HeaderExpanded) then	-- Currently expanded?
--		Nx.prt ("ExpandQuests skip")
--		return
--	end

--	Nx.prt ("ExpandQuests")

	repeat
		local found = false
		local cnt = GetNumQuestLogEntries()

		for qn = 1, cnt do

			local title, level, groupCnt, isHeader, isCollapsed, _, _, questID = GetQuestLogTitle (qn)
			local tagID, tag = GetQuestTagInfo(questID)
			if isHeader and isCollapsed then
				local he = self.HeaderExpanded
				he[title] = true
				ExpandQuestHeader (qn)
--				Nx.prt ("Expand #%s %s %s", qn, title, isCollapsed or "nil")
				found = true
				break
			end
		end
	until not found
end

-------------------------------------------------------------------------------
-- Expand any collapsed quests
-------------------------------------------------------------------------------

function Nx.Quest:RestoreExpandQuests()

--[[

	if self.List.Win:IsShown() then		-- Don't restore if our window is shown
--		Nx.prt ("RestoreExpandQuests skip")
		return
	end

--	Nx.prt ("RestoreExpandQuests")

	for hName in pairs (self.HeaderExpanded) do

--		Nx.prt ("Collapse %s", hName)

		local cnt = GetNumQuestLogEntries()
		for qn = 1, cnt do

			local title, level, groupCnt, isHeader, isCollapsed = GetQuestLogTitle (qn)
			if isHeader and title == hName then
				CollapseQuestHeader (qn)
--				Nx.prt ("Collapse #%s %s %s", qn, title, isCollapsed or "nil")
				break
			end
		end

		self.HeaderExpanded[hName] = nil
	end

--]]

end

-------------------------------------------------------------------------------
-- Access all quests. Forces game to fetch data, so we do not get ": x/x" objectives
-------------------------------------------------------------------------------

function Nx.Quest:AccessAllQuests()

--	Nx.prt ("AccessAllQuests")

	self:ExpandQuests()

	local qcnt = GetNumQuestLogEntries()

	for qi = 1, qcnt do

		local title, level = GetQuestLogTitle (qi)

		local lbCnt = GetNumQuestLeaderBoards (qi)
		for n = 1, lbCnt do
			GetQuestLogLeaderBoard (n, qi)
		end
	end

	self:RestoreExpandQuests()
end

-------------------------------------------------------------------------------
-- Record quests
-- Example:
--  1 Get Attack << Fake quest (no blizz Num)
--  2 Bring
--  3 Capture
-------------------------------------------------------------------------------

function Nx.Quest:RecordQuests(worldcheck)
--	Nx.prt ("Record Quests")
	local self = Nx.Quest
	local qcnt = GetNumQuestLogEntries()
	for qn = 1, qcnt do	-- Test all quests

		local title, level = GetQuestLogTitle (qn)
		if level < 0 then		-- If a -1 then data not updated. QuestGuru causes this to happen when zoning
			return
		end
	end
--	local tm = GetTime()
	self:ScanBlizzQuestDataZone()			-- Capture current zone
	if worldcheck == nil then
		self:ScanBlizzQuestData()				-- Triggers RecordQuestsLog() after done
	end
	self:RecordQuestsLog()

--	Nx.prt ("%f secs", GetTime() - tm)
end

-------------------------------------------------------------------------------

function Nx.Quest:RecordQuestsLog()

	local qcnt = GetNumQuestLogEntries()

	local opts = self.GOpts
	local curq = self.CurQ
	local oldSel = GetQuestLogSelection()

--	Nx.prt ("RecordQuestsLog %s, %s", qcnt, #curq)

	local lastChanged

	local qIds = {}
	self.QIds = qIds

	--

	local partySend

	if self.RealQEntries == qcnt then	-- No quests added or removed?

		for curi, cur in ipairs (curq) do

			local qi = cur.QI
			if qi > 0 then

				local title, level, groupCnt, isHeader, isCollapsed, isComplete, _, questID = GetQuestLogTitle (qi)
				title = self:ExtractTitle (title)

--				Nx.prt ("QD %s %s %s %s", title, qi, isHeader and "H1" or "H0", isComplete and "C1" or "C0")

				if cur.Title == title then		-- Still matches?

					local change

					if isComplete == 1 and not cur.Complete then
						Nx.prt (L["Quest Complete '%s'"], title)

						if Nx.qdb.profile.Quest.SndPlayCompleted then
							self:PlaySound()
						end

						if Nx.qdb.profile.Quest.AutoTurnInAC and cur.IsAutoComplete then
							ShowQuestComplete (qi)
						end

						if Nx.qdb.profile.QuestWatch.RemoveComplete and not cur.IsAutoComplete then
							self.Watch:RemoveWatch (cur.QId, cur.QI)
							self.Watch:Update()
							self.WQList:Update()
							change = false
						else
							change = true
						end

					end

					local lbCnt = GetNumQuestLeaderBoards (qi)
					for n = 1, lbCnt do

						local desc, _, done = GetQuestLogLeaderBoard (n, qi)

						--V4

						if desc and (desc ~= cur[n] or done ~= cur[n + 100]) then

--							Nx.prt ("Q Change %s->%s", desc, cur[n] or "nil")

							if Nx.qdb.profile.QuestWatch.AddChanged then
								if change == nil then
									change = true
								end
							end

							local s1, _, oldCnt = strfind (cur[n] or "", "(%d+)/%d+ ")
							if s1 then
								oldCnt = tonumber (oldCnt)
							end

							local s1, _, newCnt = strfind (desc, "(%d+)/%d+ ")
							if s1 then
--								Nx.prt ("%s %s", i, total)
								newCnt = tonumber (newCnt)
							end

							if done or (oldCnt and newCnt and newCnt > oldCnt) then
								self:Capture (curi, n)
							end

							lastChanged = cur

							partySend = true
						end
					end

					if change and Nx.qdb.profile.QuestWatch.AddChanged then
						self.Watch:Add (curi)
					end
				end
			end
		end

	else

		partySend = true
	end

	-- Remove real blizz quests

	local fakeq = {}

	local n = 1
	while curq[n] do

		local cur = curq[n]
		if not cur.Goto or cur.Party then
--			Nx.prt ("RecordQuests RemoveQ %s - %s", cur.Title, cur.QI)
			table.remove (curq, n)
		else
			fakeq[cur.Q] = cur
			n = n + 1
		end
	end

	-- Add blizz quests

	self.RealQ = {}

	local header = "?"

	self.RealQEntries = qcnt

	local index = #curq + 1

	for qn = 1, qcnt do
		local title, level, groupCnt, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isBounty, isStory, isHidden = GetQuestLogTitle(qn)
		local tagID, tag, worldQuestType, rarity, isElite, tradeskillLineIndex = GetQuestTagInfo(questID)
		
		groupCnt = tonumber(groupCnt)
		
		local isDaily = frequency
--		Nx.prt ("Q %d %s %s %d %s %s %s %s", qn, isHeader and "H" or " ", title, level, tag or "nil", groupCnt or "nil", isDaily or "not daily", isComplete and "C1" or "C0")

		if isHeader then
			header = title or "?"
--			if isCollapsed then
--				Nx.prt ("Q %s collapsed!", title)
--			end
		else
			title = self:ExtractTitle (title)
			SelectQuestLogEntry (qn)
			local qDesc, qObj = GetQuestLogQuestText()
			--local qId, qLevel = self:GetLogIdLevel (qn)
			
			local qId = questID
			local qLevel = level
			
			--Nx.prt ("%d",GetQuestLogQuestType(qn)) -- Seeing what quest type function returns
			--Nx.prt("%s", qDesc)
			if qId and not isHidden then
				local quest = Nx.Quests[qId]
				local lbCnt = GetNumQuestLeaderBoards (qn)
				local cur = quest and fakeq[quest]
				if not cur then
					cur = {}
					curq[index] = cur
					cur.Index = index
					index = index + 1
				else
					cur.Goto = nil					-- Might have been a goto quest
					cur.Index = index
					if quest then
						self.Tracking[qId] = 0
						self:TrackOnMap (qId, 0, true)
					end
				end

				qIds[qId] = cur

				cur.Q = quest
				cur.QI = qn						-- Blizzard index
				cur.QId = qId
				cur.Header = header
				cur.Title = title
				cur.ObjText = qObj
				cur.DescText = qDesc
				cur.Level = level
				cur.RealLevel = qLevel
				cur.NewTime = self.QIdsNew[qId]				-- Copy new time

				cur.Tag = tag
				cur.GCnt = groupCnt or 0
				
				--Nx.prt("%s", cur.Title)
				
				cur.PartySize = groupCnt or 1
--			if cur.Tag then Nx.prt ("%s %s", cur.Tag, cur.GCnt) end
				if tag == "Heroic" then
					cur.PartySize = 5
				end

				cur.TagShort = self.TagNames[tag] or ""

				cur.Daily = isDaily
				if isDaily == LE_QUEST_FREQUENCY_DAILY then
					cur.TagShort = "$" .. cur.TagShort
				end
				if isDaily == LE_QUEST_FREQUENCY_WEEKLY then
					cur.TagShort = "#" .. cur.TagShort
				end
				cur.CanShare = GetQuestLogPushable()
				cur.Complete = isComplete			-- 1 is Done, nil not. Otherwise failed
				cur.IsAutoComplete = false --GetQuestLogIsAutoComplete (qn)

				local left = GetQuestLogTimeLeft()
				if left then
					cur.TimeExpire = time() + left
					cur.HighPri = true
				end

				--print(qId)
				if Nx.QItems[qId] then
				_,cur.ItemLink = GetItemInfo(Nx.QItems[qId])
				
				end

				--Nx.prt("Q num: %d itmLink: %s item: %s charges: %d", qn, cur.ItemLink or " ", cur.ItemImg or " ", cur.ItemCharges)
				if cur.ItemLink then
					local itemString = string.match(cur.ItemLink, ".+|Hitem:([^:]+):.+")
					if itemString then
					--	Nx.prt("itemID: %s",itemString)
						cur.ItemID = tonumber(itemString)
					else
						cur.ItemID = 0
					end
				end
				cur.Priority = 1
				cur.Distance = 999999999
				cur.LBCnt = lbCnt

				for n = 1, lbCnt do
					local desc, _, done = GetQuestLogLeaderBoard (n, qn)
					cur[n] = desc or "?"		--V4
					cur[n + 100] = done
				end

				local mask = 0
				local ender = quest and (quest["End"] or quest["Start"])

				if (isComplete and ender) or lbCnt == 0 or (cur.Goto and quest["Start"]) then
					mask = 1

				else
					for n = 1, 99 do
						local done
						if n <= lbCnt then
							done = cur[n + 100]
						end

						local obj = quest and quest["Objectives"]

						if not obj then
							break
						else obj = quest and quest["Objectives"][n]
						end
						if not obj then
							break
						end

						if obj and not done then
							mask = mask + bit.lshift (1, n)
						end
					end
				end
				cur.TrackMask = mask

--			Nx.prt ("%s %x", title, mask)

				self.RealQ[title] = cur			-- For diff

			-- Calc total number in quest chain

				if quest then
					self:CalcCNumMax (cur, quest)
				end
			end
		end
	end


	if Nx.qdb.profile.Quest.PartyShare and self.Watch.ButShowParty:GetPressed() then

--		Nx.prt ("-PQuest-")

		local pq = self.PartyQ

		for plName, pdata in pairs (pq) do

		--Nx.prt ("PQuest %s", plName)
			for qId, qT in pairs (pdata) do
				local quest = Nx.Quests[qId]
				local cur = qIds[qId]

				if cur then		-- We have the quest?
					local s = format ("\n|cff8080f0%s|r", plName)

					if not cur.PartyDesc then

						cur.PartyDesc = ""
						cur.PartyNames = "\n|cfff080f0Me"
						cur.PartyCnt = 0
						cur.PartyComplete = cur.Complete

						for n, cnt in ipairs (qT) do
							cur[n + 200] = cur[n + 100]
							cur[n + 400] = "\n|cfff080f0Me" .. s
						end
					end

					cur.PartyDesc = cur.PartyDesc .. s
					cur.PartyNames = cur.PartyNames .. s
					cur.PartyCnt = cur.PartyCnt + 1
					cur.PartyComplete = cur.PartyComplete and qT.Complete

					local mask = (cur.PartyComplete or #qT == 0) and 1 or 0

					for n, cnt in ipairs (qT) do

						local total = qT[n + 100]

						--local desc, done = self:CalcDesc (qId, n, cnt, total)
						
						desc = qT[n + 200]
						cur[n] = desc
						
						local done = qT[n + 300]
						
						done = cur[n + 200] and done
						cur[n + 200] = done

						cur.PartyDesc = cur.PartyDesc .. "\n " .. desc
						cur[n + 400] = cur[n + 400] .. " " .. desc

						if not done then
							mask = mask + bit.lshift (1, n)
						end
					end

					cur.TrackMask = mask

				elseif quest then

					local name, side, lvl = self:Unpack (quest["Quest"])

--					Nx.prt ("PartyQ %s", name)

					local cur = {}
					cur.Goto = true
					cur.Party = plName
					cur.PartyDesc = format ("\n|cff8080f0%s|r", plName)
					cur.PartyNames = cur.PartyDesc
					cur.Q = quest
					cur.QI = 0
					cur.QId = qId
					cur.Header = "Party, " .. plName
					cur.Title = name
					cur.ObjText = ""
					cur.Level = lvl
					cur.PartySize = 1
					cur.TagShort = ""
					cur.Complete = qT.Complete
					cur.Priority = 1
					cur.Distance = 999999999

					self:CalcCNumMax (cur, quest)

					tinsert (curq, cur)
					cur.Index = #curq

					cur.LBCnt = #qT

					local mask = (qT.Complete or #qT == 0) and 1 or 0

					for n, cnt in ipairs (qT) do

						local total = qT[n + 100]

						--cur[n], cur[n + 100] = self:CalcDesc (qId, n, cnt, total)
						
						cur[n] = qT[n + 200]
						cur[n + 100] = qT[n + 300]
						
						cur[n + 400] = cur.PartyNames

						if not cur[n + 100] then
							mask = mask + bit.lshift (1, n)
						end
					end

					cur.TrackMask = mask
				end
			end
		end
	end

	for curi, cur in ipairs (curq) do
		if cur.PartyCnt then
			cur.CompleteMerge = cur.PartyComplete

			for n, desc in ipairs (cur) do
				cur[n + 300] = cur[n + 200]
			end

		else
			cur.CompleteMerge = cur.Complete

			for n, desc in ipairs (cur) do
				cur[n + 300] = cur[n + 100]
			end
		end
	end

	--

	if lastChanged then
		self.QLastChanged = self:FindCurFromOld (lastChanged)
	end

	SelectQuestLogEntry (oldSel)

--	Nx.prt ("CurQ %d", #curq)

	self:SortQuests()

	if partySend then
		self:PartyStartSend()
	end

--	local map = Nx.Map:GetMap (1)
	self.Map.Guide:UpdateMapIcons()
end

-------------------------------------------------------------------------------
-- Scan
-- <QuestPOIFrame name="WorldMapBlobFrame">
--  DrawQuestBlob (id, bool)
--  UpdateMouseOverTooltip
--  GetNumTooltips()
--  GetTooltipIndex (i)
-------------------------------------------------------------------------------

function Nx.Quest:ScanBlizzQuestData()

--	if Nx.Timer:IsActive ("QScanBlizz") then
--		Nx.prt ("ScanQ skip")
--		return
--	end

--	Nx.prt ("ScanQ")

--	SetCVar ("questPOI", 1)		-- Enable or no POI data returned

--	self.ScanBlizzChanged = false

	self.ScanBlizzMapId = 1
	-- Use delay or some quests won't be ready
--	QScanBlizz = C_Timer.After(1, function() Nx.Quest:ScanBlizzQuestDataTimer() end) 
end

function Nx.Quest:IsDaily(checkID)
	local isdaily = false
	for qn = 1, GetNumQuestLogEntries() do
		local title, level, groupCnt, isHeader, isCollapsed, isComplete, frequency, questID = GetQuestLogTitle (qn)
		if questID == checkID then
			if frequency == LE_QUEST_FREQUENCY_DAILY or frequency == LE_QUEST_FREQUENCY_WEEKLY then
				isdaily = true
			end
			break
		end
	end
	return isdaily
end

function Nx.Quest:ScanBlizzQuestDataTimer()
	if IS_BACKGROUND_WORLD_CACHING then
		return
	end
	IS_BACKGROUND_WORLD_CACHING = true
	--ObjectiveTrackerFrame:UnregisterEvent ("WORLD_MAP_UPDATE")		-- Map::ScanContinents can enable this again
--	local tm = GetTime()

	local Map = Nx.Map
	local curMapId = Map:GetCurrentMapId()
		for a,b in pairs(Nx.Zones) do
			local mapId = a
			if Nx.Map.MapWorldInfo[mapId] then
				if InCombatLockdown() then
					--ObjectiveTrackerFrame:RegisterEvent ("WORLD_MAP_UPDATE")	-- Back on when done
					Nx.Quest.WorldUpdate = false
					IS_BACKGROUND_WORLD_CACHING = false
					return
				end
				C_QuestLog.SetMapForQuestPOIs(mapId)
				Nx.Quest:MapChanged()
				--C_Timer.After(.01, function(mapId) Nx.Quest:MapChanged(mapId) end) 
				--Nx.Quest:MapChanged()
				--WorldMapFrame:SetMapID(mapId)			-- Triggers WORLD_MAP_UPDATE, which calls MapChanged
				--local cont = Nx.Map.MapWorldInfo[mapId].Cont
				--local info = Map.MapInfo[cont]
			end
		end
	Nx.Quest.Watch:Update()
	--ObjectiveTrackerFrame:RegisterEvent ("WORLD_MAP_UPDATE")
	-- Back on when done
	--Map:SetCurrentMap (curMapId)
	C_QuestLog.SetMapForQuestPOIs(curMapId)
	IS_BACKGROUND_WORLD_CACHING = false
	self:RecordQuestsLog()
end

-------------------------------------------------------------------------------
-- Called by map QUEST_POI_UPDATE
-------------------------------------------------------------------------------

local qelapsed = 0
local qlasttime
local qttl = 9999

function Nx.Quest:MapChanged()
	if Nx.ModQAction == "QUEST_DECODE" then
		Nx.ModQAction = ""
		Nx.Quest:DecodeComRcv (Nx.qTEMPinfo, Nx.qTEMPmsg)
	end
	if qlasttime then
		local curtime = debugprofilestop()
		qelapsed = curtime - qlasttime
		qlasttime = curtime
	else
		qlasttime = debugprofilestop()
	end
	qttl = qttl + qelapsed
	if qttl < 2000 and not IS_BACKGROUND_WORLD_CACHING then
		return
	end
	qttl = 0
	if Nx.QInit then	-- Quests inited?
		self:ScanBlizzQuestDataZone(true)
	end
end

-- /dump Nx.Quest:ScanBlizzQuestDataTimer()
function Nx.Quest:ScanBlizzQuestDataZone(WatchUpdate)
	if not Nx.QInit then
		return
	end
	
	--local tm = GetTime()
	local mapId = nil -- C_QuestLog.GetMapForQuestPOIs()
	if not mapId then
		return
	end
	local mapQuests = C_QuestLog.GetQuestsOnMap(mapId)
	local num = mapQuests and #mapQuests or 0--QuestMapUpdateAllQuests()		-- Blizz calls these in this order
	if num > 0 then
--		QuestPOIUpdateIcons()
--		Nx.prt("%s %s", num or 0, mapId)
		if Nx.Map:IsBattleGroundMap(mapId) then
			return
		end
		for n = 1, num do
			local id = mapQuests[n] and mapQuests[n].questID or -1
			local qi = GetQuestLogIndexByID(id)
--			Nx.prt("%s %s", id, qi)
			if mapQuests[n] and qi and qi > 0 then
				local objectives = C_QuestLog.GetQuestObjectives(id)
				local title, level, groupCnt, isHeader, isCollapsed, isComplete, _, questID = GetQuestLogTitle (qi)
				local tagID, tagName, worldQuestType, rarity, isElite, tradeskillLineIndex = GetQuestTagInfo(id)
				local lbCnt = objectives and #objectives or 0; --GetNumQuestLeaderBoards (qi)
				local qObjl = 0;
				local quest = Nx.Quests[id] or {}
				local patch = Nx.Quests[-id] or 0
				if quest and quest["Objectives"] then
					qObjl = #quest["Objectives"]
				end
				local needEnd = isComplete and not quest["End"]
				local fac = UnitFactionGroup ("player") == "Horde" and 1 or 2
				
				if worldQuestType == nil and (patch > 0 or needEnd or (not isComplete and not quest["Objectives"])) or qObjl < lbCnt then
					local x, y, objective;
					x = mapQuests[n].x
					y = mapQuests[n].y
					objective = objectives[1] or nil;
					if x then	-- Miner's Fortune was found in org, but x, y, obj were nil
						x = x * 100
						y = y * 100
--						Nx.prt ("%s #%s %s %s %s %s", mapId, n, id, x or "nil", y or "nil", objective and objective.text or "nil")
						if not quest["Quest"] then
							quest["Quest"] = format ("[[%s|%s|%s|0|0|0]]",title,fac,level)
						end
						if needEnd or bit.band (patch, 1) then
							if not quest["End"] or (bit.band(patch,1) and mapId == MapUtil.GetDisplayableMapForPlayer()) then
								quest["End"] = format ("|%s|32|%f|%f", mapId, x, y)
							end
							patch = bit.bor (patch, 1)		-- Flag as a patched quest
						end

						if not isComplete then
							if not quest["Objectives"] or qObjl < lbCnt then
								quest["Objectives"] = {}
							end
							patch = bit.bor (patch, 2)

							local s = title
							for i = 1, lbCnt do
								if not quest["Objectives"][i] then
									local obj = format ("%s|%s|32|%f|%f|6|6", objectives[i] and objectives[i].text or "?", mapId, x, y)
									quest["Objectives"][i] = {obj}
								end
							end
						end
					end
					Nx.Quests[-id] = patch
					Nx.Quests[id] = quest
				end
			end
		end
	end
	if not Nx.Quest.List.LoggingIn and not WatchUpdate then
		Nx.Quest.Watch:Update()
	end
	--Nx.prt ("%f secs", GetTime() - tm)
end


-------------------------------------------------------------------------------

function Nx.Quest:CalcCNumMax (cur, quest)
	if quest.CNum then
		cur.CNumMax = quest.CNum - 1

		local qc = quest
		local _qids = {}
		local cnum = 0
		while qc do
			cnum = cnum + 1
			cur.CNumMax = cur.CNumMax + 1
			qnext = self:UnpackNext (qc["Quest"])
			if not qnext or qnext == 0 or _qids[qnext] == true or cnum > 40 then
				break
			end
			_qids[qnext] = true;
			qc = Nx.Quests[qnext]
		end
	end
end

-------------------------------------------------------------------------------
-- Set quests done
-------------------------------------------------------------------------------

function Nx.Quest:CurQSetPreviousDone()

--	local sTime = GetTime()

	local cnt = 0

	for curi, cur in ipairs (self.CurQ) do
		if cur.QI > 0 then
			cnt = cnt + self:CalcPreviousDone (cur.QId)
		end
	end

	if cnt > 0 then
		Nx.prt (L["Set %d chain quests as done"], cnt)
	end

--	Nx.prt ("Calc %f secs", GetTime() - sTime)
end

function Nx.Quest:CalcPreviousDone (qId)

	local cnt = 0

	for mungeId, q in pairs (Nx.Quests) do
		if mungeId < 0 then
			break
		end

		if q.CNum == 1 then		-- Only look at chain starters

			local id = (mungeId + 3) / 2 - 7
			local qc = q
			while qc do

				if id == qId then		-- Found me in chain? Mark before me complete

					local id = (mungeId + 3) / 2 - 7
					local qc = q
					while id ~= qId do

						local qStatus = Nx.Quest:GetQuest (id)
						if qStatus ~= "C" then

							cnt = cnt + 1

--							Nx.prt ("%s %s", id, qId)
							Nx.Quest:SetQuest (id, "C", time())
						end

						id = self:UnpackNext (qc["Quest"])
						qc = Nx.Quests[id]
					end

					break
				end

				id = self:UnpackNext (qc["Quest"])
				qc = Nx.Quests[id]
			end
		end
	end

	return cnt
end

-------------------------------------------------------------------------------
-- Fired on login
-------------------------------------------------------------------------------

function Nx.Quest:GetHistoryTimer()

--	local down = GetNetStats()		-- .08 to 4. Seems to be an average since it creeps down

--	Nx.prt ("GetNetStats %f", down)

--	if down > 2.5 then	-- Wait?
--		return 2
--	end
	if not Nx.Quest.CurCharacter["QHAskedGet"] then
		Nx.Quest.CurCharacter["QHAskedGet"] = true
		local function func()
			QHistQuery = Nx:ScheduleTimer(Nx.Quest.QuestQueryTimer, .1, Nx.Quest)
		end

		Nx:ShowMessage (L["Get character's quest completion data from the server?"], "Get", func, "Cancel")
	end
end

function Nx.Quest:QuestQueryTimer()

	local qc = GetQuestsCompleted()
	if not qc then
		Nx.prt (L["QuestQueryTimer wait"])
		return 1
	end

--	Nx.prtVar ("OnQuest_query_complete", qc)

	local cnt = 0

	for id in pairs (qc) do

		local qStatus = Nx.Quest:GetQuest (id)
		if qStatus ~= "C" then

			cnt = cnt + 1
			Nx.Quest:SetQuest (id, "C", time())
		end
	end

	if cnt > 0 then
		Nx.prt (L["Set %d previous quests as done"], cnt)
		Nx.Quest.List:Update()
	end
end

function Nx.Quest:CalcDesc (qId, objI, cnt, total)

	local odesc = Nx.Quest:GetQuestObjectiveInfo(qId, objI, false);
	local desc, _, _ = strmatch (odesc or "", "(.+): (%d+)/(%d+)")
	
	if not desc then
		desc = odesc or "?"
	end
	
--	Nx.prt("%s, %s, %s, %s, %s", qId, objI, desc, cnt, total)
	
	if total == 0 then
		return desc, cnt == 1
	else
		return format ("%s: %d/%d", desc, cnt, total), cnt >= total
	end
end

function Nx.Quest:GetQuestObjectiveInfo(qId, objI, qText)
	local obj = C_QuestLog.GetQuestObjectives(qId)

	obj = (obj and obj[objI]) or nil
	
	if obj then
		return obj.text, obj.type, obj.finished
	end
	
	return 
end

function Nx.Quest:GetLogIdLevel (questID)
	if questID > 0 then
		local qlink = nil --GetQuestLink (questID)
		if qlink then
			--local s1, _, id, level = strfind (qlink, "Hquest:(%d+):(.%d*)")
			local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isStory = GetQuestLogTitle(i);
			if s1 then
--				Nx.prt ("qlink %s", gsub (qlink, "|", "^"))
				return tonumber (id), tonumber (level)
			end
		end
	end
end

function Nx.Quest:CreateLink (qId, realLevel, title)

	if realLevel <= 0 then	-- Could be a 0
		realLevel = -1
	end
	return format ("\124cffffff00\124Hquest:%s:%s\124h[%s]\124h\124r", qId, realLevel, title)
end

function Nx.Quest:ExtractTitle (title)

--	Nx.prt ("Orig '%s'", title)

	local _, e = strfind (title, "^%[%S+%] ")
	if e then
		title = strsub (title, e + 1)

	else
		local _, e = strfind (title, "^%d+%S* ")
		if e then
			title = strsub (title, e + 1)
		end
	end

--	Nx.prt ("'%s'", title)

	return title
end

-------------------------------------------------------------------------------
-- Sort quests
-------------------------------------------------------------------------------

function Nx.Quest:SortQuests()

	local curq = self.CurQ

	-- Sort by level

	repeat
		local done = true

		for n = 1, #curq - 1 do

			if curq[n].Level > curq[n + 1].Level then
				curq[n], curq[n + 1] = curq[n + 1], curq[n]
				done = false
			end
		end

	until done

	-- Sort by header

	if self.List.QOpts.NXShowHeaders then

		local hdrNames = {}

		for n = 1, #curq do
			hdrNames[curq[n].Header] = 1
		end

		local hdrs = {}

		for name in pairs (hdrNames) do
			tinsert (hdrs, name)
		end

		sort (hdrs)

--		Nx.prtVar ("HDR", hdrs)

		local curq2 = curq
		curq = {}

		for _, name in ipairs (hdrs) do

			for n = 1, #curq2 do

				if curq2[n].Header == name then
					tinsert (curq, curq2[n])
				end
			end
		end

		self.CurQ = curq

--		Nx.prtVar ("curq", curq)
	end

	-- Build id mapping

	local t = {}
	self.IdToCurQ = t

	for k, cur in ipairs (curq) do

		if cur.Q then
			local id = cur.QId
			t[id] = cur
		end
	end
end

-------------------------------------------------------------------------------
-- Detect a new quest
-------------------------------------------------------------------------------

function Nx.Quest:FindNewQuest()

	-- Id
	if self.AcceptQId then	-- Auto accept quest triggered?

		local qi = GetQuestLogIndexByID (self.AcceptQId)
		self.AcceptQId = nil

		local title = self:ExtractTitle (GetQuestLogTitle (qi))

		if not self.RealQ[title] then
			return qi
		end
	end

	-- Scan by name

	local aQName = self.AcceptQName

	if not aQName then
		return
	end

	local cnt = GetNumQuestLogEntries()

--	Nx.prt ("FindNewQuest %d", cnt)

	for qn = 1, cnt do

		local title, level, groupCnt, isHeader, isCollapsed, _, _, questID = GetQuestLogTitle (qn)
		local tagID, tag = GetQuestTagInfo(questID)

		if not isHeader then
			title = self:ExtractTitle (title)
			if title == aQName then
				if not self.RealQ[title] then
--					Nx.prtVar ("RealQ", self.RealQ)
					self.AcceptQName = nil
					return qn
				end
			end
		end
	end
end

--------

function Nx.Quest:RecordQuestAcceptOrFinish()

	local giver = UnitName ("npc") or "?"

	local guid = UnitGUID ("npc")
	if guid then

	local typ, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit ("-", guid)
		if typ == "Player" then
			giver = "p"
		elseif typ == "GameObject" then
			giver = format ("%s#o%x", giver, npc_id)
		elseif typ == "Creature" then		-- NPC
			giver = format ("%s#%x", giver, npc_id)
		end
	end

	self.AcceptGiver = giver

	local qname = GetTitleText()		-- Also works for auto accept
	self.AcceptQName = qname
	local id = Nx.Map:GetRealMapId()
	self.AcceptAId = id or 0
	self.AcceptDLvl = 0

	if Nx.Map:GetCurrentMapId() == id then
		self.AcceptDLvl = Nx.Map:GetCurrentMapDungeonLevel()
	end

	local map = Nx.Map:GetMap (1)
	self.AcceptX = map.PlyrRZX
	self.AcceptY = map.PlyrRZY

--	Nx.prt ("AcceptQuest (%s) (%s) %s,%s", giver, qname, self.AcceptAId, self.AcceptDLvl)

end

-------------------------------------------------------------------------------

function CarboniteQuest:OnChat_msg_combat_faction_change (event, arg1)

	local self = Nx.Quest

--	Nx.prt ("OnChat_msg_combat_faction_change %s", arg1)

	local form = FACTION_STANDING_INCREASED
	form = gsub (form, "%%s", "(.+)")
	form = gsub (form, "%%d", "(%%d+)")
	local facName, rep = strmatch (arg1, form)
	rep = tonumber (rep)

	if facName and rep and self.CaptureQEndTime and GetTime() - self.CaptureQEndTime < 2 then

		local facNum = self.CapFactionAbr[facName]
		if facNum then

			local _, race = UnitRace ("player")
			if race == "Human" then
				rep = rep / 1.1 + .5
			end

--			Nx.prt ("Fac %s %s", facName, rep)

			local cap = NXQuest.Gather
			local quests = Nx:CaptureFind (cap, "Q")
			local qdata = { Nx.Split ("~", quests[self.CaptureQEndId]) }
			local ender, reps = Nx.Split ("@", qdata[2])

			local repdata = reps and { Nx.Split ("^", reps) } or {}
			tinsert (repdata, format ("%d %x", rep, facNum))
			reps = table.concat (repdata, "^")

			qdata[2] = format ("%s@%s", ender, reps)
			quests[self.CaptureQEndId] = table.concat (qdata, "~")	-- concat is not global!!!
		end
	end

	self.CaptureQEndTime = nil
end

-------------------------------------------------------------------------------
-- Capture a quest
-- (current index, objective # (nil for start, -1 end)
-------------------------------------------------------------------------------

function Nx.Quest:Capture (curi, objNum)

	local Nx = Nx
	local opts = self.GOpts

	if not Nx.db.profile.General.CaptureEnable then
		return
	end

	local cur = self.CurQ[curi]
	local id = cur.QId

	if Nx.db.profile.Debug.DebugMap and (not objNum or objNum < 0) then	-- Start or end
		Nx.prt ("Quest Capture %s", id or "nil")
	end

	if not id then
		return
	end

	local cap = NXQuest.Gather

	local facI = UnitFactionGroup ("player") == "Horde" and 1 or 0
	local quests = Nx:CaptureFind (cap, "Q")
	local saveId = id * 2 + facI

	local len = 0

	for id, str in pairs (quests) do
		len = len + 4 + #str + 1
	end

	if len > 110 * 1024 then
		return
	end

--	Nx.prt ("Cap len %s", len)

--[[
	if not objNum or objNum < 0 then
		Nx.prt (L["Capture %s %s %s %.2f,%.2f"], self.AcceptGiver, self.AcceptAId or 0, self.AcceptDLvl, self.AcceptX, self.AcceptY)
	else
		local map = self.Map
		Nx.prt (L["Capture #%s %s %.2f,%.2f"], objNum, map.RMapId, map.PlyrRZX, map.PlyrRZY)
	end
--]]

--	local ids = self:CaptureGet (quests, id)
--	ids["I"] = format ("%d^%s^%s", cur.RealLevel, cur.Title, cur.Header)

	local q = quests[saveId]

	if not q then
		q = strrep ("~", cur.LBCnt + 1)
	end

	local qdata = { Nx.Split ("~", q) }

	if not objNum then	-- Starter

--		local flags = bit.bor (tonumber (strsub (qdata[1], 1, 1), 16) or 0, facMask)
		local plLvl = UnitLevel ("player")

		-- 0 is reserved
		local s = Nx:PackXY (self.AcceptX, self.AcceptY)
--		qdata[1] = format ("0%s^%02x%02x%s", self.AcceptGiver, plLvl, self.AcceptAId, s)
		qdata[1] = format ("0%s^%03x%x%s", self.AcceptGiver, self.AcceptAId, self.AcceptDLvl, s)

--		Nx.prt ("Capture start %s", qdata[1])

	elseif objNum < 0 then	-- Ender

		local s = Nx:PackXY (self.AcceptX, self.AcceptY)
		qdata[2] = format ("%s^%03x%x%s", self.AcceptGiver, self.AcceptAId, self.AcceptDLvl, s)

		self.CaptureQEndTime = GetTime()
		self.CaptureQEndId = saveId

--		Nx.prt ("Capture end %s", qdata[2])

	else

		local map = self.Map:GetMap(1)
		local nxzone = map.UpdateMapID
		if nxzone then

			local index = objNum + 2
			local obj = qdata[index]

			if not obj then
--				Nx.prt (L["Capture err %s, %s"], cur.Title, objNum)	-- Debug message
				return
			end

			if #obj >= 3 then
				local z = tonumber (strsub (obj, 1, 3), 16)
				if nxzone ~= z then
					return
				end
			else
				obj = format ("%03x", nxzone)
			end

			local cnt = (#obj - 3) / 6
			if cnt >= 15 then
				return
			end

			qdata[index] = obj .. Nx:PackXY (map.PlyrRZX, map.PlyrRZY)

--			Nx.prt ("Capture%d #%d %s", objNum, cnt, qdata[index])
		end
	end

	quests[saveId] = table.concat (qdata, "~")	-- concat is not global!!!

--	Nx.prt ("CapStr %s", quests[saveId])
end

function Nx.Quest:CaptureGetCount()

	local cap = NXQuest.Gather
	local quests = Nx:CaptureFind (cap, "Q")

	local cnt = 0

	for id, str in pairs (quests) do
		cnt = cnt + 1
	end

	return cnt
end

-------------------------------------------------------------------------------
-- Play a completed sound
-- (snd index or nil for random)
-------------------------------------------------------------------------------

function Nx.Quest:PlaySound (sndI)

	if not sndI then

		local opts = self.GOpts
		local cnt = 0

		for n = 1, 10 do
			if Nx.qdb.profile.Quest["Snd" .. n] then
				cnt = cnt + 1
			end
		end

		if cnt > 0 then

			local i = random (1, cnt)
			cnt = 0

			for n = 1, 10 do
				if Nx.qdb.profile.Quest["Snd" .. n] then
					cnt = cnt + 1
					if cnt == i then
						sndI = n
						break
					end
				end
			end
		end
	end

	if sndI then
		local snd = Nx.OptsDataSounds[sndI]
		Nx:PlaySoundFile (snd)
	end
end

-------------------------------------------------------------------------------
-- Tell party of quest changes
-------------------------------------------------------------------------------

function Nx.Quest:TellPartyOfChanges()

--PAIDS!

	if self.RealQEntries ~= GetNumQuestLogEntries() then	-- Quests added or removed?
		return
	end

	local opts = self.GOpts
	if not Nx.qdb.profile.Quest.BroadcastQChanges then
		return
	end

	local curq = self.CurQ

	for _, cur in ipairs (curq) do

		if cur.QI > 0 then

			for n = 1, cur.LBCnt do

				local skip
				local desc, _, done = GetQuestLogLeaderBoard (n, cur.QI)
				if desc then
					if not done then

						local num = Nx.qdb.profile.Quest.BroadcastQChangesNum
						local oldCnt = tonumber (strmatch (cur[n] or "", "(%d+)/"))
						local newCnt = tonumber (strmatch (desc, "(%d+)/"))
						if oldCnt and newCnt then
							if floor (oldCnt / num) == floor (newCnt / num) then
								skip = true
							end
						end
					end
					if not skip and desc ~= cur[n] then
						Nx.Com:Send ("P", desc)
--						Nx.prt ("%s", desc)
					end
				end
			end
		end
	end

--PAIDE!
end

-------------------------------------------------------------------------------
-- unused???
-------------------------------------------------------------------------------

function Nx.Quest:GetLongTitle (cur)

	local title = format ("[%d] %s", cur.Level, cur.Title)

	local quest = cur.Q
	if quest and quest.CNum then
		title = title .. format (L[" (Part %d of %d)"], quest.CNum, cur.CNumMax)
	end

	return title
end

function Nx.Quest:GetPartTitle (quest, cur)

	local s = ""

	if quest and quest.CNum then
		if cur then
			s = s .. format (L["(Part %d of %d)"], quest.CNum, cur.CNumMax)
		else
			s = s .. format (L["(Part %d)"], quest.CNum)
		end
	end

	return s
end

function Nx.Quest:FindCur (qId, qIndex)

	if type (qId) == "string" then	-- Quest title?

		for n, v in ipairs (self.CurQ) do
			if v.Title == qId then
				return n, v, qId
			end
		end

		return
	end

	if qIndex and qIndex > 0 and qId == 0 then
		local i, cur = self:FindCurByIndex (qIndex)
		return i, cur, cur.Title	-- Also return string type id
	end

	assert (qId > 0)

	for n, v in ipairs (self.CurQ) do
		if v.QId == qId then
			return n, v, qId
		end
	end
end

function Nx.Quest:FindCurByIndex (qi)
	assert (qi > 0)
	local curq = self.CurQ

	for n, v in ipairs (curq) do
		if v.QI == qi then
			return n, v
		end
	end
end

function Nx.Quest:FindCurFromOld (oldCur)

	for n, cur in ipairs (self.CurQ) do
		if cur.Title == oldCur.Title and cur.ObjText == oldCur.ObjText then
			return cur
		end
	end
end

-------------------------------------------------------------------------------
-- Check if any part of quest in the map
-------------------------------------------------------------------------------

function Nx.Quest:CheckShow (mapId, qId)

	local nxid = mapId
	local quest = Nx.Quests[qId]

	if not quest then
		return
	end

	local qname, side, lvl, minlvl, next = self:Unpack (quest["Quest"])

	--	Check start, end and objectives
--[[
	if not quest[2] then
		Nx.prt (L["quest error: %s %s"], qname, qId)
		assert (quest[2])
	end
--]]
	local _, startMapId = self:UnpackSE (quest["Start"])
	if startMapId then
		if startMapId == nxid then
			return true
		end
	end

	if quest["End"] then
		local _, endMapId = self:UnpackSE (quest["End"])
		if endMapId then
			if endMapId == nxid then
				return true
			end
		end
	end

	for n = 1, 15 do

		local obj = quest["Objectives"]
		if not obj or not obj[n] then
			break
		end

		local _, objMapId = self:UnpackObjective (obj[n][1])

		if objMapId then

			if objMapId == nxid then
				return true
			end
		end
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------

function Nx.Quest:WatchAtLogin()

	for n, cur in ipairs (self.CurQ) do

		local qStatus = Nx.Quest:GetQuest (cur.QId)
		if not qStatus then

--			Nx.prt ("Add watch %s", cur.Title)
			self.Watch:Add (n)

--		elseif qStatus == "W" then
--			Nx.prt ("Watched %s", cur.Title)

--		elseif qStatus == "C" then
--			Nx.prt ("Completed %s", cur.Title)

		end
	end
end

function Nx.Quest:WatchAll()

	local curq = self.CurQ
	if curq then
		for i, cur in ipairs (curq) do
			self.Watch:Add (i)
		end
	end
end

function Nx.Quest:Goto (qId)

	if qId == 0 then
		return
	end

--	Nx.prt ("Goto %s", qId)

	local i = self:FindCur (qId)

	if i then
		Nx.prt (L["Already going to quest"])
		return
	end

	local curq = self.CurQ
	local quest = Nx.Quests[qId]

	if not quest["Start"] then
		Nx.prt ("No quest starter")
		return
	end

	local name, side, lvl = self:Unpack (quest["Quest"])

	local cur = {}
	cur.Goto = true
	cur.Q = quest
	cur.QI = 0
	cur.QId = qId
	cur.Header = L["Goto"]
	cur.Title = L["Goto: "] .. name
	cur.ObjText = ""
	cur.Level = lvl
	cur.PartySize = 1
	cur.LBCnt = 0
	cur.TrackMask = 1
	cur.TagShort = ""

	cur.Priority = 1
	cur.Distance = 999999999

	cur.HighPri = true

	self:CalcCNumMax (cur, quest)

	tinsert (curq, cur)
	cur.Index = #curq

	self.Watch:Add (#curq)

	self:RecordQuests(0)
	self.List:Update()
end

function Nx.Quest:Abandon (qIndex, qId)

	if qIndex > 0 then

		self:ExpandQuests()

		local title, level, groupCnt, isHeader = GetQuestLogTitle (qIndex)

		if not isHeader then

--			Nx.prt ("Abandon %s %s", qIndex, title)		
--			QuestLog_SetSelection (qIndex)
			
			local text = format(ABANDON_QUEST_CONFIRM, title);
			local items = GetAbandonQuestItems()
			if items then
				text = format(ABANDON_QUEST_CONFIRM_WITH_ITEMS, title, items);
			end
			
			Nx:ShowMessage (
				text,
				YES,
				function(self)
					SelectQuestLogEntry (qIndex)				
					SetAbandonQuest()
					
					-- native blizz
					AbandonQuest();
					--if ( QuestLogPopupDetailFrame:IsShown() ) then
					--	HideUIPanel(QuestLogPopupDetailFrame);
					--end
					PlaySound(SOUNDKIT.IG_QUEST_LOG_ABANDON_QUEST);					
					-- carb
					if qId > 0 then
						--Nx.Quest.CurQ[qIndex] = nil
						Nx.Quest:NullQuest (qId)
					end
				end,
				NO,
				function(self)
				end
			)
		end

		self:RestoreExpandQuests()

	else
		if qId > 0 then

			self.Watch:RemoveWatch (qId, qIndex)
			local i = self:FindCur (qId)
			if i then
				local curq = self.CurQ
				tremove (curq, i)
			end
			Nx.Quest:NullQuest (qId)
		end
	end
end

-------------------------------------------------------------------------------
-- Link a quest to chat edit frame
-------------------------------------------------------------------------------

function Nx.Quest:LinkChat (qId)

	local box = ChatEdit_ChooseBoxForSend()
	ChatEdit_ActivateChat (box)

	if box then
		local s = self.List:MakeDescLink (nil, qId, IsControlKeyDown())
		if s then
			box:Insert (s)
		end
	else

		Nx.prt (L["|cffff4040No edit box open!"])
	end
end

-------------------------------------------------------------------------------
-- Get quests from a player
-------------------------------------------------------------------------------

function Nx.Quest:GetFromPlyr (plName)

	Nx.ShowMessageTrial()

--	Nx.prt ("GetFromPlyr %s", plName)

	self.List.Bar:Select (4)

	self.FriendQuests = {}

	self.RcvPlyr = plName
	self.RcvPlyrLast = plName

	Nx.Com:Send ("W", "Q*", plName)
end

-------------------------------------------------------------------------------
-- Clear captured quests
-------------------------------------------------------------------------------

function Nx.Quest:ClearCaptured()
	NXQuest.Gather["Q"] = {}
end

-------------------------------------------------------------------------------
-- Quest com message from a player
-------------------------------------------------------------------------------

function Nx.Quest:OnMsgQuest (plName, msg)

--	Nx.prt ("OnMsgQuest (%s) %s", plName, msg)
	loc = strfind(plName,"-")
	if loc and loc > 0 then
		plName = string.gsub(plName,strsub(plName,loc),"")
	end
	local id = strsub (msg, 2, 2)

	if id == "*" then		-- Request for all quests

--		if nil then
		if not self.SendPlyr or self.SendPlyr == plName then

			Nx.prt (L["Sending quests to %s"], plName)

			self.SendPlyr = plName
			self:BuildQSendData()
			QSendAll = Nx:ScheduleTimer(self.QSendAllTimer,0,self)
		else

			Nx.Com:Send ("W", "QB", plName)
		end

	elseif id == "B" then	-- Busy

		if plName == self.RcvPlyr then

			local mode = strsub (msg, 3, 3)

			if mode == "s" then
				Nx.prt (L[" %s -share"], self.RcvPlyr)
			elseif mode == "C" then
				Nx.prt (L[" %s busy"], self.RcvPlyr)
			else
				tinsert (self.FriendQuests, L[" ^Player is busy"])
			end

			self.RcvPlyr = nil

			local pd = self.CapturePlyrData[plName]
			if pd then
				pd.RcvPlyrCapName = nil
			end
		end

	elseif id == "D" then	-- Incoming quest data

		if plName == self.RcvPlyr then

			if #msg >= 4 then

				local data = strsub (msg, 3)
				local mode = strsub (msg, 3, 3)

				if mode == "0" then

					self.RcvCnt = 0
					self.RcvTotal = tonumber (strsub (data, 3)) or 0

				elseif mode == "H" then

					tinsert (self.FriendQuests, data)
					self.List:Update()

				elseif mode == "T" then

					self.RcvCnt = self.RcvCnt + 1
					tinsert (self.FriendQuests, data)

--					Nx.prt ("Quest Data %s", data)

					self.List:Update()

				elseif mode == "O" then

					tinsert (self.FriendQuests, data)
					self.List:Update()
				end
			else
				self.RcvPlyr = nil
			end
		end

	elseif id == "p" then	-- Incoming party data

		self:OnPartyMsg (plName, msg)

	end
end

function Nx.Quest:BuildQSendData()

	local data = {}

	self.QSendData = data
	self.QSendDataI = 1

	local header
	local cnt = 0

	for n, cur in ipairs (self.CurQ) do

		if not cur.Goto then

			if cur.Header ~= header then
				header = cur.Header

				local str = format ("QDH^%s", header)
				tinsert (data, str)
			end

			local qStatus = Nx.Quest:GetQuest (cur.QId)
			local watched = qStatus == "W" and 1 or 0

			local str = format ("QDT^%s^%s^%s^%s^%s", cur.QId, watched, cur.Complete or 0, cur.Level, cur.Title)
			tinsert (data, str)

			for n = 1, cur.LBCnt do
				local str = format ("QDO^%s^%s", -n, cur[n])
				tinsert (data, str)
			end

			cnt = cnt + 1
		end
	end

	tinsert (data, "QD")

	local str = format ("QD0^%d", cnt)
	tinsert (data, 1, str)
end

function Nx.Quest:QSendAllTimer()

	local qi = self.QSendDataI
	local data = self.QSendData[qi]

	if data then

		Nx.Com:Send ("W", data, self.SendPlyr)

--		Nx.prt ("QSendAllTimer: %s", data)
	end

	self.QSendDataI = qi + 1

	if self.QSendData[self.QSendDataI] then
		return .2
	end

	self.SendPlyr = nil
end

-------------------------------------------------------------------------------
-- Show quest is not in DB
-------------------------------------------------------------------------------

function Nx.Quest:MsgNotInDB (typ)

	if typ == "O" then
		UIErrorsFrame:AddMessage (L["This objective is not in the database"], 1, 0, 0, 1)
	elseif typ == "Z" then
		UIErrorsFrame:AddMessage (L["This objective zone is not in the database"], 1, 0, 0, 1)
	else
		UIErrorsFrame:AddMessage (L["This quest is not in the database"], 1, 0, 0, 1)
	end
end

-------------------------------------------------------------------------------

-- Troll Patrol: The Alchemist's Apprentice quest

Nx.Quest.AlchemistsApprenticeData = {

	["Abomination Guts"] = "3~4~3492~5283",
	["Amberseed"] = "3~3~3496~5157",
	["Ancient Ectoplasm"] = "3~2~3498~5157",
	["Blight Crystal"] = "3~2~3488~5347",
	["Chilled Serpent Mucus"] = "3~3~3509~5342",
	["Crushed Basilisk Crystals"] = "4~2~3487~5339",
	["Crystallized Hogsnot"] = "3~4~3494~5157",
	["Frozen Spider Ichor"] = "3~2~3472~5309",
	["Ghoul Drool"] = "4~     4~3490~5100",
	["Hairy Herring Head"] = "Floor~Crate~3511~5127",
	["Icecrown Bottled Water"] = "2~1~3499~5157",
	["Knotroot"] = "4~1~3499~5152",
	["Muddy Mire Maggots"] = "Floor~Sack~3485~5155",
	["Pickled Eagle Egg"] = "2~2~3497~5157",
	["Prismatic Mojo"] = "4~3~3491~5289",
	["Pulverized Gargoyle Teeth"] = "2~4~3494~5157",
	["Putrid Pirate Perspiration"] = "2~3~3496~5157",
	["Raptor Claw"] = "3~2~3489~5283",
	["Seasoned Slider Cider"] = "Floor~Barrel~3508~5317",
	["Shrunken Dragon's Claw"] = "3~3~3489~5093",
	["Speckled Guano"] = "2~3~3490~5093",
	["Spiky Spider Egg"] = "3~4~3510~5095",
	["Trollbane"] = "3~1~     3505~5095",
	["Wasp's Wings"] = "3~1~3499~5157",
	["Withered Batwing"] = "4~3~3496~5153",
}

function CarboniteQuest:OnChat_msg_raid_boss_whisper (event, arg1)

	if arg1 then

		if GetMinimapZoneText() == "Heb'Valok" then

			local self = Nx.Quest	-- Need?
--			Nx.prt ("%s, %s, %s", arg1, arg2 or "nil", arg3 or "nil")

			local name = gsub (arg1, "!", "")

			local data = self.AlchemistsApprenticeData[name]
			if data then
				local shelf, item, x, y = Nx.Split ("~", data)
				x = tonumber (x) * .01
				y = tonumber (y) * .01

				local s = format (L["%s on %s in %s"], name, shelf, item)

				if tonumber (shelf) then
					s = format (L["%s, shelf %s, item %s"], name, shelf, item)
				end

				self.Map:SetTargetXY (4011, x, y, s)
			end
		end
	end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Quest tooltips
-------------------------------------------------------------------------------

function	Nx.Quest.TooltipHook()

--	Nx.prt ("TooltipHook")

	Nx.Quest:TooltipProcess()
end

function	Nx.Quest:TooltipProcess (stripColor)

	local tipStr = GameTooltipTextLeft1:GetText()
	if not tipStr then		-- Happens in WotLK on empty slots
		return
	end

--	Nx.prt ("TooltipProcess %s", tipStr)

	Nx.TooltipLastDiffText = tipStr

--	local sTime = GetTime()

	local show = Nx.Quest:TooltipProcess2 (stripColor, tipStr)

	if show then
		GameTooltip:Show()	-- Adjusts size
	end

--	Nx.prt ("TTProcess %f secs", GetTime() - sTime)

	Nx.TooltipLastDiffNumLines = GameTooltip:NumLines()	-- Stop multiple checks
end

function Nx.Quest:TooltipProcess2 (stripColor, tipStr)
	if not Nx.QInit then
		return
	end
	if not Nx.qdb.profile.Quest.AddToolTip then
		return
	end

	local tip = GameTooltip

	-- Check if already added

	local textName = "GameTooltipTextLeft"
	local questStr = format (L["|cffffffffQ%suest:"], Nx.TXTBLUE)

	for n = 2, tip:NumLines() do
		local s = _G[textName .. n]:GetText()
		if s then

			local s1 = strfind (s, questStr)
			if s1 then
--				Nx.prt ("TTM #%s", GameTooltip:NumLines())
				return
			end
			if strsub (s, 1, 3) == " - " then	-- Blizz added quest info?

				local fstr = _G[textName .. (n - 1)]
				local qTitle = fstr:GetText()

				local i, cur = self:FindCur (qTitle)
				if cur then
					local color = self:GetDifficultyColor (cur.Level)
					color = format ("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
					fstr:SetText (format ("%s %s%d %s", questStr, color, cur.Level, cur.Title))
				end

				tip:AddLine (" ")		-- Add blank or same tip will not add info again

				return true;
			end
		end
	end

	-- Scan tooltip

	if stripColor then
		tipStr = gsub (tipStr, "|c%x%x%x%x%x%x%x%x", "")
	end

	if tipStr and #tipStr > 5 and #tipStr < 50 and not self.TTIgnore[tipStr] then

		tipStr = self.TTChange[tipStr] or tipStr
		local tipStrLower = strlower (tipStr)

		local curq = self.CurQ

		for curi, cur in ipairs (curq) do

			if not cur.Goto then		-- Skip Goto and Party quests

				local s1 = strfind (cur.ObjText, tipStr, 1, true)
				if not s1 then
					s1 = strfind (cur.DescText, tipStr, 1, true)
				end
				if not s1 then
					s1 = strfind (cur.ObjText, tipStrLower, 1, true)
				end
				if not s1 then
					s1 = strfind (cur.DescText, tipStrLower, 1, true)
				end
				if not s1 then
					for n = 1, cur.LBCnt do
						if cur[n] then	-- V4
							s1 = strfind (cur[n], tipStr)
							if s1 then
								break
							end
						end
					end
				end

				if s1 then

					local color = self:GetDifficultyColor (cur.Level)
					color = format ("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)

					tip:AddLine (format ("%s %s%d %s", questStr, color, cur.Level, cur.Title))

					for n = 1, cur.LBCnt do
						if strfind (cur[n], tipStr) then
							local color, s1 = self:CalcPercentColor (cur[n], cur[n + 100])
							if s1 then
								local oName = strsub (cur[n], 1, s1 - 1)
								tip:AddLine (format ("    |cffb0b0b0%s%s%s", oName, color, strsub (cur[n], s1)))
							else
								tip:AddLine (format ("    %s%s", color, cur[n]))
							end
						end
					end

--					Nx.prt ("TTProcess %s #%s", tipStr, tip:NumLines())

					return true;
				end
			end
		end
	end
end

-------------------------------------------------------------------------------

function Nx.Quest:GetDifficultyColor (level)

	return GetQuestDifficultyColor (level)
end

-------------------------------------------------------------------------------

function Nx.Quest:CalcPercentColor (desc, done)

	local s1, _, i, total = strfind (desc, "(%d+)/(%d+)")

	if done then
		return self.PerColors[9], s1
	else
		i = s1 and floor (tonumber (i) / tonumber (total) * 8.99) + 1 or 1
		return self.PerColors[i], s1
	end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Quest list
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Open and init or toggle Quest frame
-------------------------------------------------------------------------------

function Nx.Quest.List:Open()
	local qopts = Nx.Quest:GetQuestOpts()
	self.QOpts = qopts

	local TabBar = Nx.TabBar

	self.ShowAllZones = false
	self.Opened = true

	-- Create window

	local win = Nx.Window:Create ("NxQuestList")
	self.Win = win

	win:CreateButtons (true, true)
	win:InitLayoutData (nil, -.24, -.15, -.52, -.65)

	tinsert (UISpecialFrames, "QuestMapFrame")
	tinsert (UISpecialFrames, win.Frm:GetName())

	win.Frm:SetToplevel (true)
	win.Frm:SetMinResize (250, 120)

	win:SetUser (self, self.OnWin)
	CarboniteQuest:RegisterEvent ("PLAYER_LOGIN", "OnQuestUpdate")
	--CarboniteQuest:RegisterEvent ("UPDATE_FACTION", "OnQuestUpdate")
	--CarboniteQuest:RegisterEvent ("GARRISON_MISSION_COMPLETE_RESPONSE", "OnQuestUpdate")
	--CarboniteQuest:RegisterEvent ("WORLD_QUEST_COMPLETED_BY_SPELL", "OnQuestUpdate")
	CarboniteQuest:RegisterEvent ("UNIT_QUEST_LOG_CHANGED", "OnQuestUpdate")
	CarboniteQuest:RegisterEvent ("QUEST_PROGRESS", "OnQuestUpdate")
	CarboniteQuest:RegisterEvent ("QUEST_COMPLETE", "OnQuestUpdate")
	CarboniteQuest:RegisterEvent ("QUEST_ACCEPTED", "OnQuestUpdate")
	CarboniteQuest:RegisterEvent ("QUEST_REMOVED", "OnQuestUpdate")
	CarboniteQuest:RegisterEvent ("QUEST_TURNED_IN", "OnQuestUpdate")
	CarboniteQuest:RegisterEvent ("QUEST_DETAIL", "OnQuestUpdate")
	--CarboniteQuest:RegisterEvent ("QUEST_WATCH_UPDATE", "OnQuestUpdate")
	--CarboniteQuest:RegisterEvent ("SCENARIO_UPDATE", "OnQuestUpdate")
	--CarboniteQuest:RegisterEvent ("SCENARIO_CRITERIA_UPDATE", "OnQuestUpdate")
	CarboniteQuest:RegisterEvent ("WORLD_STATE_TIMER_START", "OnQuestUpdate")
	CarboniteQuest:RegisterEvent ("WORLD_STATE_TIMER_STOP", "OnQuestUpdate")
	--CarboniteQuest:RegisterEvent ("QUEST_POI_UPDATE", "OnQuestUpdate")
	--CarboniteQuest:RegisterEvent ("TRACKED_ACHIEVEMENT_UPDATE", "OnTrackedAchievementUpdate")
	--CarboniteQuest:RegisterEvent ("TRACKED_ACHIEVEMENT_LIST_CHANGED", "OnTrackedAchievementsUpdate")
	CarboniteQuest:RegisterEvent ("CHAT_MSG_COMBAT_FACTION_CHANGE", "OnChat_msg_combat_faction_change")
	CarboniteQuest:RegisterEvent ("CHAT_MSG_RAID_BOSS_WHISPER", "OnChat_msg_raid_boss_whisper")
	-- Filter Edit Box

	local f = CreateFrame ("EditBox", "NxQuestFilter", win.Frm)
	self.FilterFrm = f

	f.NxInst = self

	f:SetScript ("OnEditFocusGained", self.FilterOnEditFocusGained)
	f:SetScript ("OnEditFocusLost", self.FilterOnEditFocusLost)
	f:SetScript ("OnTextChanged", self.FilterOnTextChanged)
	f:SetScript ("OnEnterPressed", self.FilterOnEnterPressed)
	f:SetScript ("OnEscapePressed", self.FilterOnEscapePressed)

	f:SetFontObject ("NxFontS")

	local t = f:CreateTexture()
	t:SetColorTexture (.1, .2, .3, 1)
	t:SetAllPoints (f)
	f.texture = t

	f:SetAutoFocus (false)
	f:ClearFocus()

	win:Attach (f, 0, 1, 0, 18)

	self.FilterDesc = L["Search: [click]"]
	self.FilterDescEsc = L["Search: %[click%]"]

--	if Nx.Free then
--		self.FilterDesc = L["Search: "] .. Nx.FreeMsg
--	end

	self.Filters = { "", "", "", ""}

	f:SetText (self.FilterDesc)
	f:SetMaxLetters (30)

	-- List

	Nx.List:SetCreateFont ("Quest.QuestFont", 12)

	local list = Nx.List:Create ("Quest", 0, 0, 1, 1, win.Frm)
	self.List = list

	list:SetUser (self, self.OnListEvent)

	list:SetLineHeight (0, 6)

	list:ColumnAdd ("", 1, 20)
	list:ColumnAdd ("", 2, 300)
--	list:ColumnAdd ("Lvl", 3, 20, "CENTER")
	list:ColumnAdd ("", 3, 0)
	list:ColumnAdd ("", 4, 600)
	list:ColumnAdd ("", 5, 200)
	list:ColumnAdd ("", 6, 500)

	-- Create menu

	local menu = Nx.Menu:Create (list.Frm, 240)
	self.Menu = menu

	local menui1 = {}
	self.MenuItems1 = menui1

	local menui2 = {}
	self.MenuItems2 = menui2

	local menui3 = {}
	self.MenuItems3 = menui3

	local menui4 = {}
	self.MenuItems4 = menui4

	local item = menu:AddItem (0, L["Toggle High Watch Priority"], self.Menu_OnHighPri, self)
	tinsert (menui1, item)

	local item = menu:AddItem (0, L["Show Category Headers"], self.Menu_OnShowHeaders, self)
	item:SetChecked (qopts.NXShowHeaders)
	tinsert (menui1, item)

	local item = menu:AddItem (0, L["Show Objectives"], self.Menu_OnShowObjectives, self)
	item:SetChecked (qopts.NXShowObj)
	tinsert (menui1, item)

	local item = menu:AddItem (0, L["Show Only Party Quests"], self.Menu_OnShowParty, self)
	item:SetChecked (false)
	tinsert (menui1, item)

	local item = menu:AddItem (0, "")
	tinsert (menui1, item)

	local item = menu:AddItem (0, L["Watch All Quests"], self.Menu_OnWatchAll, self)
	tinsert (menui1, item)

	local item = menu:AddItem (0, L["Watch All Completed Quests"], self.Menu_OnWatchCompleted, self)
	tinsert (menui1, item)

	local item = menu:AddItem (0, "")
	tinsert (menui1, item)

	local item = menu:AddItem (0, L["Broadcast Quest Changes To Party"], nil, self)
	item:SetChecked (Nx.qdb.profile.Quest, "BroadcastQChanges")
	tinsert (menui1, item)
	local item = menu:AddItem (0, L["Send Quest Status To Party"], self.Menu_OnSendQInfo, self)
	tinsert (menui1, item)
	local item = menu:AddItem (0, L["Share"], self.Menu_OnShare, self)
	self.MenuIShare = item
	tinsert (menui1, item)

	local item = menu:AddItem (0, "")
	tinsert (menui1, item)
	local item = menu:AddItem (0, L["Abandon"], self.Menu_OnAbandon, self)
	tinsert (menui1, item)

	local item = menu:AddItem (0, L["Remove"], self.Menu_OnCompleted, self)
	tinsert (menui2, item)

	local item = menu:AddItem (0, L["Remove All"], self.Menu_OnHistoryRemoveAll, self)
	tinsert (menui2, item)

	local function func()
		QHistLogin = Nx:ScheduleTimer(Nx.Quest.QuestQueryTimer,.1,Nx.Quest)
	end
	local item = menu:AddItem (0, L["Get Completed From Server"], func, self)
	tinsert (menui2, item)

	local item = menu:AddItem (0, L["Mark As Previously Completed"], self.Menu_OnCompleted, self)
	tinsert (menui3, item)

	tinsert (menui3, menu:AddItem (0, L["Goto Quest Giver"], self.Menu_OnGoto, self))

	local item = menu:AddItem (0, "")
	tinsert (menui2, item)
	tinsert (menui3, item)

	local item = menu:AddItem (0, L["Show All Quests"], self.Menu_OnShowAllQuests, self)
	item:SetChecked (false)
	tinsert (menui2, item)
	tinsert (menui3, item)

	local item = menu:AddItem (0, L["Show Low Level Quests"], self.Menu_OnShowLowLevel, self)
	item:SetChecked (false)
--	tinsert (menui2, item)
	tinsert (menui3, item)

	local item = menu:AddItem (0, L["Show High Level Quests"], self.Menu_OnShowHighLevel, self)
	item:SetChecked (false)
--	tinsert (menui2, item)
	tinsert (menui3, item)

	local item = menu:AddItem (0, L["Show Quests From All Zones"], self.Menu_OnShowAllZones, self)
	item:SetChecked (false)
	tinsert (menui2, item)
	tinsert (menui3, item)

	local item = menu:AddItem (0, L["Show Finished Quests"], self.Menu_OnShowFinished, self)
	item:SetChecked (false)
	tinsert (menui3, item)

	local item = menu:AddItem (0, L["Show Only Non Dungeon Dailies"], self.Menu_OnShowOnlyDailies, self)
	item:SetChecked (false)
	tinsert (menui3, item)

	local item = menu:AddItem (0, "")
	tinsert (menui3, item)
	local item = menu:AddItem (0, L["Track None"], self.Menu_OnTrackNone, self)
	tinsert (menui3, item)

	local item = menu:AddItem (0, "")
	tinsert (menui1, item)
	tinsert (menui2, item)
	tinsert (menui3, item)

	local function func()
		Nx.Opts:Open ("Quest")
	end
	local item = menu:AddItem (0, L["Options..."], func)
	tinsert (menui1, item)
	tinsert (menui2, item)
	tinsert (menui3, item)

	-- Quest details

	local f = CreateFrame ("ScrollFrame", "NxQuestD", win.Frm, "NxQuestDetails")

	self.DetailsFrm = f
	f.NxSetSize = self.OnDetailsSetSize

	f:SetMovable (true)
	f:EnableMouse (true)
	f:SetFrameStrata ("MEDIUM")
	local t = f:CreateTexture()
	if Nx.qdb.profile.Quest.ScrollIMG then
		t:SetTexture ("Interface\\QuestFrame\\QuestBG", true, true)
	else
		t:SetColorTexture(Nx.Util_str2rgba(Nx.qdb.profile.Quest.DetailBC))
	end
	t:SetAllPoints (f)
	t:SetTexCoord(0, .585, 0.02, .655)
	f.texture = t

	f:Show()

	-- Create Tab Bar

	local bar = TabBar:Create (nil, win.Frm, 1, 1)
	self.Bar = bar

	local tbH = TabBar:GetHeight()

	win:Attach (bar.Frm, 0, 1, -tbH, 1)

	bar:SetUser (self, self.OnTabBar)

	self.TabSelected = 1

	bar:AddTab (L["Current"], 1, nil, true)
	bar:AddTab (L["History"], 2)
	bar:AddTab (L["Database"], 3)
	bar:AddTab (L["Player"], 4)

	-- Old attach

--	local qdf = getglobal ("QuestLogDetailScrollFrame")
--	win:Attach (qdf, 0, 1, .6, 1)
--[[
	local t = qdf:CreateTexture()
	t:SetColorTexture (.7, .7, .5, .7)
	t:SetAllPoints (qdf)
	qdf.texture = t
--]]
	-- Quest log

--	local qlogf = getglobal ("QuestLogFrame")
--	win:Attach (qlogf, .8, 1, 0, 1, true)

	--

	self:AttachFrames()
end

-------------------------------------------------------------------------------
-- Attach our frames
-------------------------------------------------------------------------------

function Nx.Quest.List:AttachFrames()
	local win = self.Win
	local list = self.List
	local tbH = Nx.TabBar:GetHeight()

	if Nx.qdb.profile.Quest.SideBySide then

		local r = .55
		if self.TabSelected ~= 1 then
			r = 1
		end
		win:Attach (list.Frm, 0, r, 18, -tbH)
		win:Attach (self.DetailsFrm, .55, 1, 18, -tbH)

	else
		local bot = .6
		if self.TabSelected ~= 1 then
			bot = -tbH
		end
		win:Attach (list.Frm, 0, 1, 18, bot)
		win:Attach (self.DetailsFrm, 0, 1, .6, -tbH)
	end
end

function Nx.Quest.List:UpdateMenu()

	local showi = self.MenuItems1
	local hidei1 = self.MenuItems2
	local hidei2 = self.MenuItems3

	if self.TabSelected == 2 then

		showi = self.MenuItems2
		hidei1 = self.MenuItems1

	elseif self.TabSelected == 3 then

		showi = self.MenuItems3
		hidei2 = self.MenuItems1
	end

	for k, v in pairs (hidei1) do
		v:Show (false)
	end

	for k, v in pairs (hidei2) do
		v:Show (false)
	end

	for k, v in pairs (showi) do		-- Do last so items in multiple lists work
		v:Show()
	end

	if self.TabSelected == 1 then

		local show = -1
		local i = self.List:ItemGetData()
		if i then

			local qi = bit.band (i, 0xff)
			if qi > 0 then
				local i, cur = Nx.Quest:FindCurByIndex (qi)
				if cur then
					if cur.CanShare then
						show = true
					end
				end
			end
		end

		self.MenuIShare:Show (show)
	end
end

-------------------------------------------------------------------------------

function Nx.Quest:ShowUIPanel (frame)
	if self.InShowUIPanel then
		return
	end
	self.InShowUIPanel = true
	local detailFrm = QuestLogDetailFrame
	local orig = IsAltKeyDown() and not self.IgnoreAlt
	local opts = self.GOpts
	if Nx.qdb.profile.Quest.UseAltLKey then
		orig = not orig
	end
	if orig then	-- Show original quest log?
		self.IsOrigOpen = true
		--frame:SetScale (1)
		--QuestMapFrame:SetAttribute ("UIPanelLayout-enabled", true)
		--ShowUIPanel (WorldMapFrame)
		--if detailFrm then
			--detailFrm:SetScale (1)
		--end
		self:LightHeadedAttach (frame)
	else
		Nx.Quest.List:Refresh()
		self.IsOpen = true
		local win = self.List.Win
		if win and not GameMenuFrame:IsShown() then
			self:ExpandQuests()
			local wf	= win.Frm
			win:Show()
			self.List:Update()
			wf:Raise()
			--frame:Show()
			--if detailFrm then
				--detailFrm:SetScale (.1)
			--end
			self:LightHeadedAttach (wf, true)
		end
	end
	self.InShowUIPanel = false
end

-------------------------------------------------------------------------------

function Nx.Quest:HideUIPanel (frame)
	local orig = IsAltKeyDown() and not self.IgnoreAlt
	if Nx.qdb.profile.Quest.UseAltLKey then
		orig = not orig
	end
	if orig then
		--QuestMapFrame:SetAttribute ("UIPanelLayout-enabled", true)
		--HideUIPanel(WorldMapFrame)
		--Nx.Quest.OldWindow()
		--Nx.Quest.OldWindow()
		self.IsOrigOpen = false
	else
		self.IsOpen = false
		local detailFrm = QuestLogDetailFrame
		--if detailFrm then
			--detailFrm:SetScale (1)
		--end
		self.List.Win:Show (false)
		if self.List.List:ItemGetNum() > 0 then
			self.List.List:Empty()
		end
		self:RestoreExpandQuests()		-- Hide window first, then restore
		self.LHAttached = nil
	end
end

function Nx.Quest:LightHeadedAttach (frm, attach, onlyLevels)

	local lh = _G["LightHeaded"]
	local lhf = _G["LightHeadedFrame"]
	if not (lh and lhf) then
		return
	end

	local db = lh["db"]
	if not db then
		return
	end

	local profile = db["profile"]
	if not profile then
		return
	end

--	Nx.prtFrame ("LightHeaded", lhf)
--	Nx.prtFrameChildren ("LightHeaded", lhf)

	lhf:SetParent (frm)

	local lvl = frm:GetFrameLevel()
	local open = profile["open"]

	if not attach then

		lvl = lvl - 1
		local x = open and -15 or -328
		lhf:ClearAllPoints()
		lhf:SetPoint ("LEFT", frm, "RIGHT", x, 0)		--  OLD -50, 19

	else

		self.LHAttached = profile
		self.LHOpen = open

		lvl = open and lvl or 1
		local x = open and -4 or -326
		lhf:ClearAllPoints()
		lhf:SetPoint ("TOPLEFT", frm, "TOPRIGHT", x, -19)
	end

	lhf:SetFrameLevel (lvl)
	Nx.Util_SetChildLevels (lhf, lvl + 1)

	if not onlyLevels then

		lhf:Show()

		if not profile["attached"] then
			lh["LockUnlockFrame"](lh)
		end
	end
end

-------------------------------------------------------------------------------
-- Frame update. Called by main addon frame
-------------------------------------------------------------------------------

local elap = nil
function Nx.Quest:OnUpdate (elapsed)
	if not Nx.Quest.Initialized then
		return
	end

	-- DeaTHCorE - missing questwatch update... the quest range as a example are updated very late without updates,
	-- so i have added here a update every 1 secound. this update is any more required for update questwatch itembutton in
	-- conjunction with the InCombatLockdown() call ( :Hide() quest itembutton is a example for missing update by InCombatLockdown(),
	-- the call of :Hide() are not called a the frame lists etcetera are wiped.	)
	-- I have tested with a CPU Profiling addon and no performence lost i have seen...
	-- I call the update here to spare one more timer ;)
	if not elap then
		elap = GetTime()
		return
	end
	local t = GetTime()
	if t - elap >= 1 then
		Nx.Quest.Watch:Update()		
		elap = t
	end

	if not self.List.Win:IsShown() then
--		Nx.prt ("skip")
		return
	end

	if self.LHAttached then

		local profile = self.LHAttached
		if self.LHOpen ~= profile["open"] then
			self:LightHeadedAttach (self.List.Win.Frm, true)
		end

		if Nx.Tick % 20 == 0 then
			self:LightHeadedAttach (self.List.Win.Frm, true, true)
		end
	end
end

-------------------------------------------------------------------------------
-- Select quest in list
-------------------------------------------------------------------------------

function Nx.Quest.List:Select (qId, qI)

	local list = self.List

	for n = 1, list:ItemGetNum() do

		local i = list:ItemGetData (n)
		if i then

			local qi = bit.band (i, 0xff)
			local qid = bit.rshift (i, 16)

			if qi == qI and qid == qId then

				Nx.Quest:SelectBlizz (qi)
				list:Select (n)
				self:Update()

				break
			end
		end
	end
end

-------------------------------------------------------------------------------

function Nx.Quest.List:GetCurSelected()

	local i = self.List:ItemGetData()
	if i then

		local qi = bit.band (i, 0xff)
		local qid = bit.rshift (i, 16)
		if qid > 0 or qi > 0 then
			local _, cur = Nx.Quest:FindCur (qid, qi)
			return cur
		end
--[[
		local qi = bit.band (i, 0xff)
		if qi > 0 then

			local i, cur = Nx.Quest:FindCurByIndex (qi)
			return cur
		else

			local qid = bit.rshift (i, 16)
			local i, cur = Nx.Quest:FindCur (qid)
			return cur
		end
--]]
	end
end

-------------------------------------------------------------------------------

function Nx.Quest.List:OnWin (typ)

	if typ == "Close" then
		HideUIPanel (QuestMapFrame)
--		QuestLogFrame:Hide()
	end
end

-------------------------------------------------------------------------------

function Nx.Quest.List:FilterOnEditFocusGained()

	Nx.ShowMessageTrial()

	local this = self			--V4
	local self = this.NxInst

	local s = self.Filters[self.TabSelected]
	if s ~= "" then
		this:SetText (s)
	else
		this:SetText ("")
	end
end

function Nx.Quest.List:FilterOnEditFocusLost()

	local this = self			--V4
	local self = this.NxInst

	if self.Filters[self.TabSelected] == "" then
		this:SetText (self.FilterDesc)
	end
end

function Nx.Quest.List:FilterOnTextChanged()

	local this = self			--V4
	local self = this.NxInst
	self.Filters[self.TabSelected] = gsub (this:GetText(), self.FilterDescEsc, "")
--	Nx.prt ("Filter #%s = %s", self.TabSelected, self.Filters[self.TabSelected])
	self:Update()
end

function Nx.Quest.List:FilterOnEnterPressed()
	local this = self			--V4
	this:ClearFocus()
end

function Nx.Quest.List:FilterOnEscapePressed()

	local this = self			--V4
	local self = this.NxInst
	self.Filters[self.TabSelected] = ""

	this:ClearFocus()
end

-------------------------------------------------------------------------------

function Nx.Quest.List:OnTabBar (index, click)

	self.FilterFrm:ClearFocus()

	self.TabSelected = index

	if index == 1 then
		self.DetailsFrm:Show()
		self:AttachFrames()
	else
		self.DetailsFrm:Hide()
		self:AttachFrames()
	end

	local s = self.Filters[self.TabSelected]
	s = s ~= "" and s or self.FilterDesc
	self.FilterFrm:SetText (s)

	self:Update()
end

-------------------------------------------------------------------------------
-- Menu handlers
-------------------------------------------------------------------------------

function Nx.Quest.List:Menu_OnGoto (item)

	local i = self.List:ItemGetData()
	if i then

		local qIndex = bit.band (i, 0xff)

		if qIndex > 0 then
			Nx.prt (L["Already have the quest!"])

		else
			local qId = bit.rshift (i, 16)
			Nx.Quest:Goto (qId)

			self:Update()
		end
	end
end

function Nx.Quest.List:Menu_OnHighPri (item)

	local cur = self:GetCurSelected()
	if cur then
		cur.HighPri = not cur.HighPri
		self:Update()
	end
end

function Nx.Quest.List:Menu_OnShowHeaders (item)

	self.QOpts.NXShowHeaders = item:GetChecked()
	Nx.Quest:SortQuests()
	self:Update()
end

function Nx.Quest.List:Menu_OnShowObjectives (item)

	self.QOpts.NXShowObj = item:GetChecked()
--	Nx.Quest:SortQuests()
	self:Update()
end

function Nx.Quest.List:Menu_OnShowAllQuests (item)
	self.ShowAllQuests = item:GetChecked()
	self:Update()
end

function Nx.Quest.List:Menu_OnShowLowLevel (item)
	self.ShowLowLevel = item:GetChecked()
	self:Update()
end

function Nx.Quest.List:Menu_OnShowHighLevel (item)
	self.ShowHighLevel = item:GetChecked()
	self:Update()
end

function Nx.Quest.List:Menu_OnShowAllZones (item)
	self.ShowAllZones = item:GetChecked()
	self:Update()
end

function Nx.Quest.List:Menu_OnShowFinished (item)
	self.ShowFinished = item:GetChecked()
	self:Update()
end

function Nx.Quest.List:Menu_OnShowOnlyDailies (item)
	self.ShowOnlyDailies = item:GetChecked()
	self:Update()
end

function Nx.Quest.List:Menu_OnShowParty (item)
	self.ShowParty = item:GetChecked()
	self:Update()
end

function Nx.Quest.List:Menu_OnCompleted (item)

	local i = self.List:ItemGetData()
	if i then

		local qId = bit.rshift (i, 16)
		local qStatus, qTime = Nx.Quest:GetQuest (qId)

		if qStatus == "C" then
			qStatus = "c"
		else
			qStatus = "C"
			qTime = time()
		end

--		Nx.prt ("ToggleQuestComplete %d %s %s", qId, qStatus, qTime)

		Nx.Quest:SetQuest (qId, qStatus, qTime)

		self:Update()
	end
end

function Nx.Quest.List:Menu_OnHistoryRemoveAll()

	local idT = Nx.Quest.IdToCurQ
	local questT = Nx.Quest.CurCharacter.Q

	for id in pairs (questT) do
		if not idT[id] then
			questT[id] = nil
		end
	end

	Nx.prt (L["History cleared"])
	self:Update()
end


function Nx.Quest.List:Menu_OnSortWatched (item)
	local on = item:GetChecked()
	Nx.Quest:SetWatchSortMode (on and 1 or 0)
end

function Nx.Quest.List:Menu_OnWatchAll()
	Nx.Quest:WatchAll()
	self:Update()
end

function Nx.Quest.List:Menu_OnWatchCompleted (item)

	local curq = Nx.Quest.CurQ

	if curq then

		for i, cur in ipairs (curq) do

--			Nx.prt ("Q #%d %s %s", i, cur.Title, cur.Complete or "nil")

			if cur.Complete and cur.Complete == 1 then
				Nx.Quest.Watch:Add (i)
			end
		end

		self:Update()
	end
end

function Nx.Quest.List:Menu_OnSendQInfo (item)

	local i = self.List:ItemGetData()
	if i then

		local qi = bit.band (i, 0xff)
		self:SendQuestInfo (qi)
	end
end

function Nx.Quest.List:SendQuestInfo (qi)

	if qi > 0 then

		self.SendQInfoQI = qi
		self.SendQInfoMode = -1
		self.SendQTarget = nil

		local box = Nx.FindActiveChatFrameEditBox()
		if box then
			local typ = box:GetAttribute ("chatType")
--			Nx.prt ("chattype %s", typ)
			if typ == "WHISPER" then
				self.SendQTarget = box:GetAttribute ("tellTarget")
				self.SendQLanguage = box["language"]
				ChatEdit_OnEscapePressed (box)
			end
		end

		QSendInfo = Nx:ScheduleTimer(self.OnSendQuestInfoTimer,0,self)
	end
end

function Nx.Quest.List:OnSendQuestInfoTimer()

	local qi = self.SendQInfoQI
	local i, cur = Nx.Quest:FindCurByIndex (qi) --qi > 0 and Nx.Quest:FindCurByIndex (qi) or nil, nil

	if not i then
		return
	end

	local sendStr
	local mode = self.SendQInfoMode

	if mode == -1 then

		sendStr = self:MakeDescLink (cur)
		mode = 0
--[[
	elseif mode == 0 then
		local str = strsub (cur.ObjText, 1, 180)
		str = format (" %s", str)
		str = gsub (str, "[\n\r\t]", "")
		if #cur.ObjText > 180 then
			str = str .. "..."
		end
		Nx.Com:Send ("P", str)
--]]
	else

		local desc = cur[mode]
		if not desc then
			return
		end

		sendStr = format ("  %s", desc)
	end

	if self.SendQTarget then
--		Nx.Com:Send ("W", sendStr, self.SendQTarget)
		SendChatMessage (sendStr, "WHISPER", self.SendQLanguage, self.SendQTarget);
	else
		Nx.Com:Send ("P", sendStr)
	end

	self.SendQInfoMode = mode + 1

	return .33
end

function Nx.Quest.List:Menu_OnShare (item)

	local i = self.List:ItemGetData()
	if i then

		local qi = bit.band (i, 0xff)
		if qi > 0 then
			if GetNumSubgroupMembers() > 0 then
				QuestLogPushQuest()
			else
				Nx.prt (L["Must be in party to share"])
			end
		end
	end
end

function Nx.Quest.List:Menu_OnAbandon (item)

	local i = self.List:ItemGetData()
	if i then

		local qIndex = bit.band (i, 0xff)
		local qId = bit.rshift (i, 16)
		Nx.Quest:Abandon (qIndex, qId)

--		self:Update()	-- Dialog gets closed!
	end
end

--[[
function Nx.Quest.List:Menu_OnTrackAll (item)

	local curq = Nx.Quest.CurQ

	if curq then

		for _, cur in ipairs (curq) do

			local quest = cur.Q
			if quest then
				Nx.Quest.Tracking[cur.QId] = 0xffffffff		-- Track all
			end
		end

		self:Update()
	end
end
--]]

function Nx.Quest.List:Menu_OnTrackNone (item)
	Nx.Quest.Watch:ClearAutoTarget()
	self:Update()
end

-------------------------------------------------------------------------------
-- On list control updates
-------------------------------------------------------------------------------

function Nx.Quest.List:OnListEvent (eventName, sel, val2, click)

	local Quest = Nx.Quest
	local Map = Nx.Map

	local itemData = self.List:ItemGetData (sel) or 0
	local hdrCur = self.List:ItemGetDataEx (sel, 1)

	local qIndex = bit.band (itemData, 0xff)
	local qId = bit.rshift (itemData, 16)

	local shift = IsShiftKeyDown() or eventName == "mid"

--	Nx.prt (format ("Data #%d, Id%d", qIndex, qId))

	if eventName == "select" or eventName == "mid" or eventName == "back" then

		local columnId = val2

		if shift then

			if hdrCur then		-- Header?

				local setStr

				for n = sel + 1, sel + 99 do		-- Toggle watch of all

					local itemData = self.List:ItemGetData (n)
					if not itemData or itemData == 0 then
						break
					end

					local qIndex = bit.band (itemData, 0xff)
					local qId = bit.rshift (itemData, 16)

					local i, cur, id = Quest:FindCur (qId, qIndex)

					if not setStr then

						local qStatus = Nx.Quest:GetQuest (id)
						setStr = qStatus == "W" and "c" or "W"
					end

					Nx.Quest:SetQuest (id, setStr)
				end

				Quest:PartyStartSend()

			else

				-- Track or paste to chat

				local i, cur, id = Quest:FindCur (qId, qIndex)

				local box = Nx:FindActiveChatFrameEditBox()
				if box then

					local s = self:MakeDescLink (cur, id or qId, IsControlKeyDown())
					if s then
						box:Insert (s)
					end

				else

					if cur then

						-- Shift click toggles quest-watch

						local qStatus = Nx.Quest:GetQuest (id)
						if qStatus == "W" then
							Nx.Quest:SetQuest (id, "c")
						else
							Nx.Quest:SetQuest (id, "W")
						end

						Quest:PartyStartSend()
					end
				end
			end
		end

		Nx.Quest:SelectBlizz (qIndex)

		self:Update()

		if qId > 0 then

			-- 0 is quest name line
			local qObj = bit.band (bit.rshift (itemData, 8), 0xff)

			local mapId = Map:GetCurrentMapId()
			Quest:TrackOnMap (qId, qObj, qIndex > 0, shift)
			Map:SetCurrentMap (mapId)

			-- LightHeaded select

			if self.TabSelected == 3 then
				local lh = _G["LightHeaded"]
				if lh then
					lh["UpdateFrame"] (lh, qId)
--					Nx.prt ("LH qid %s", qId)
				end
			end
		end

	elseif eventName == "button" then

		if hdrCur then		-- Header?

			local v
			if not Quest.HeaderHide[hdrCur.Header] then
				v = true
			end
			Quest.HeaderHide[hdrCur.Header] = v

			self:Update()

		else
			-- 0 is quest name line
			local qObj = bit.band (bit.rshift (itemData, 8), 0xff)

			if self.TabSelected == 1 then

				self:ToggleWatch (qId, qIndex, qObj, shift)

			elseif self.TabSelected == 3 then

				local tbits = Quest.Tracking[qId] or 0

				if qObj == 0 then
					Quest.Tracking[qId] = bit.bxor (tbits, 1)
				else
					Quest.Tracking[qId] = bit.bxor (tbits, bit.lshift (1, qObj))
				end

				self:Update()
			end
		end

	elseif eventName == "menu" then

		if qIndex > 0 then

			Quest:SelectBlizz (qIndex)
			self:Update()
		end

		if self.TabSelected ~= 4 then

			self:UpdateMenu()
			self.Menu:Open()
		end
	end
end

function Nx.Quest.List:ToggleWatch (qId, qIndex, qObj, shift)

	local Quest = Nx.Quest
	local Map = Nx.Map

	if qObj == 0 and not shift then

		local i, cur, id = Quest:FindCur (qId, qIndex)
		if cur then

			local qStatus = Nx.Quest:GetQuest (id)
			if qStatus == "W" then

				Nx.Quest.Watch:RemoveWatch (qId, qIndex)
			else
				Nx.Quest:SetQuest (id, "W")
			end

			Quest:PartyStartSend()
		end
	else

		if qId > 0 and qObj > 0 then	-- FIX: Diabled qObj == 0 case

			if shift and qObj == 0 or qObj > 0 then

				local tbits = Quest.Tracking[qId] or 0

				if qObj == 0 then
					if bit.band (tbits, 1) > 0 then
						Quest.Tracking[qId] = nil
					else
						Quest.Tracking[qId] = 0xffffffff		-- Track all
					end
				else
					Quest.Tracking[qId] = bit.bxor (tbits, bit.lshift (1, qObj))
				end

				self:Update()
			end

			local mapId = Map:GetCurrentMapId()
			Quest:TrackOnMap (qId, qObj, qIndex > 0, true)
			Map:SetCurrentMap (mapId)
		end
	end

	self:Update()
end

-------------------------------------------------------------------------------
-- Make a quest link
-- (cur or id can be nil)
-------------------------------------------------------------------------------

function Nx.Quest.List:MakeDescLink (cur, id, debug)

	local qId = cur and cur.QId or id	-- Database list will have nil cur

	local Quest = Nx.Quest
	local quest = cur and cur.Q or Nx.Quests[qId]

	local title = cur and cur.Title or ''
	local realLevel = cur and cur.RealLevel or 0

	if quest then
		local t = GetQuestLogTitle(GetQuestLogIndexByID(id))
		local s
		s, _, realLevel = Quest:Unpack (quest["Quest"])
		title = s or title
		title = t or title
	end

	local level = realLevel or 0

	if level <= 0 then
		level = UnitLevel ("player") or 0
	end
	
	local s = title --Quest:CreateLink (qId, realLevel, title) or '' --

	-- Needs a leading space according to Blizzard. White color breaks link
	if quest and Nx.qdb.profile.Quest.ShowLinkExtra then
		local part = Quest:GetPartTitle (quest, cur) or ''
		if part ~= "" then
			part = " " .. part
		end
		if level > 0 then
			s = format (" [%s] %s%s", level, s, part)
		else 
			s = format (" %s%s", s, part)
		end
	else
		s = format (" %s", s)
	end

	if debug then
		local fac = strsub (UnitFactionGroup ("player"), 1, 1)
		s = format ("%s[%s %d]", s, fac, qId)
	end

--	Nx.prt ("quest %s", gsub (s, "|", "^"))

	return s
end

-------------------------------------------------------------------------------
-- On quest updates
-------------------------------------------------------------------------------

local QuestListRefreshTimer
function Nx.Quest.List:Refresh(event)		
	if QuestListRefreshTimer then
		QuestListRefreshTimer:Cancel()
	end
	
	local func = function ()	
		Nx.prtD("Nx.Quest.List:Refresh")
		if QuestListRefreshTimer then
			QuestListRefreshTimer:Cancel()
		end		
		
		local isInst = IsInInstance()
		-- Update Emmissaries	
		if not isInst then
			local pLvl = UnitLevel ("player")
			if not hideBfAEmmissaries and pLvl > 111 then emmBfA = GetQuestBountyInfoForMapID(875) end
			if not hideLegionEmmissaries and pLvl > 109 then emmLegion = GetQuestBountyInfoForMapID(619) end
		end
		
		Nx.Quest.List:LogUpdate()
		Nx.Quest:RecordQuests(isInst and 0 or nil)
	end
	
	--Nx.Quest.List:LogUpdate()
	
	--[[local func = function(timer)	
		C_Timer.After(.5, function()
			--Nx.Quest:ScanBlizzQuestDataZone()
			Nx.Quest:RecordQuests()
			--Nx.Quest:RecordQuests(event == "QUEST_LOG_UPDATE" and true or nil)	
			Nx.Quest.List:LogUpdate()
			Nx.prtD ("R %s", "Nx.Quest.List:Refresh")
		end)
	end]]--
	
	if event == "QUEST_ACCEPTED" then
		func()
	else 
		QuestListRefreshTimer = C_Timer.NewTimer(IsInInstance() and 2 or 1, func)
	end
end

function CarboniteQuest:OnQuestUpdate (event, ...)
	local Quest = Nx.Quest
	local arg1, arg2, arg3 = select (1, ...)
	
	Nx.prtD ("OnQuestUpdate %s", event)
	
	if event == "PLAYER_LOGIN" then
		self.LoggingIn = true
	elseif event == "QUEST_TURNED_IN" then
		Nx.Quest.List:Refresh(event)
	elseif event == "QUEST_POI_UPDATE" then
		local oldmap = Nx.Map:GetCurrentMapAreaID()
		if Nx.Quest.OldMap ~= oldmap then
			Nx.Quest.OldMap = oldmap
			Nx.Quest:MapChanged()
			Nx.Quest.Watch:Update()
		end
	elseif event == "QUEST_PROGRESS" then
		local auto = Nx.qdb.profile.Quest.AutoTurnIn

		if IsShiftKeyDown() and IsControlKeyDown() then
			auto = not auto
		end

		if auto then
			CompleteQuest()
--			Nx.prt ("Auto turn in")
		end
		Nx.Quest.List:Refresh(event)
		return
	elseif event == "QUEST_COMPLETE" then
		local auto = Nx.qdb.profile.Quest.AutoTurnIn
		if IsShiftKeyDown() and IsControlKeyDown() then
			auto = not auto
		end
		if auto then
			if GetNumQuestChoices() == 0 then
				GetQuestReward()
--				Nx.prt ("Auto turn in choice")
			end
		end
		Nx.Quest.List:Refresh(event)
		return
	elseif event == "QUEST_ACCEPTED" then
		--[[if QuestGetAutoAccept() then
			local auto = Nx.qdb.profile.Quest.AutoAccept
			if IsShiftKeyDown() and IsControlKeyDown() then
				auto = not auto
			end
			if auto then
				QuestFrameDetailPanel:Hide();
				CloseQuest();
			end
		end]]--
		if arg1 and Nx.qdb.profile.QuestWatch.AddNew then
			local qId = Nx.Quest:GetQuestID (arg1)
			local qStatus = Nx.Quest:GetQuest (qId)
			if Nx.Quest:IsDaily(qId) then
				Nx.Quest:SetQuest (qId, "W")
				Quest:PartyStartSend()
			end
		end
		Nx.Quest:RecordQuests()
		--Nx.Quest.List:Refresh(event)
		Nx.Quest.List:Refresh()
		--Nx.Quest:RecordQuests()
	elseif event == "QUEST_REMOVED" then
		local questId = arg1
		--[[if QuestUtils_IsQuestWorldQuest (questId) then
			SetSuperTrackedQuestID(0);
			worldquestdb[questId] = nil
			Nx.Quest.WQList:UpdateDB()
		end]]--
	elseif event == "QUEST_DETAIL" then		-- Happens when auto accept quest is given
		--if QuestGetAutoAccept() and QuestIsFromAreaTrigger() then
			Quest:RecordQuestAcceptOrFinish()
			local auto = Nx.qdb.profile.Quest.AutoAccept
			if IsShiftKeyDown() and IsControlKeyDown() then
				auto = not auto
			end
			if auto then
				CloseQuest();
			end
--			Quest.AcceptQId = GetQuestID()
			table.insert(Quest.AcceptPool, GetQuestID())
			Nx.prtD ("QUEST_DETAIL %s", GetQuestID())
			Nx.Quest.List:Refresh(event)
		--end
	elseif event == "QUEST_LOG_UPDATE" or event == "UNIT_QUEST_LOG_CHANGED" or event == "WORLD_QUEST_COMPLETED_BY_SPELL" then

--		Nx.prtStack ("QUpdate")
--		Nx.prt ("#%d", GetNumQuestLogEntries())

		if self.LoggingIn then
			Quest:AccessAllQuests()
			QLogUpdate = Nx:ScheduleTimer(self.LogUpdate,.5,self)	-- Small delay, so access works (0 does work)
		else
			Nx.Quest.List:Refresh("QUEST_LOG_UPDATE")
		end
	elseif event == "GARRISON_MISSION_COMPLETE_RESPONSE" then
		Nx.Quest.List:LogUpdate()
	else
		Nx.Quest.Watch:Update()
	end
--	Nx.prtD ("OnQuestUpdate %s Done", event)

	QuestWatchFrame:Hide()
end

hooksecurefunc("QuestWatch_Update", function (...) QuestWatchFrame:Hide(); end);

Nx.Quest.TrackedAchievements = {}
function CarboniteQuest:OnTrackedAchievementsUpdate (event, ...)
	Nx.Quest.TrackedAchievements = {}
	local ach = { GetTrackedAchievements() }
	for _, id in ipairs (ach) do
		CarboniteQuest:OnTrackedAchievementUpdate(event, id)
	end
end

function CarboniteQuest:OnTrackedAchievementUpdate (event, id)
	local achT = {}
	local aId, aName, aPoints, aComplete, aMonth, aDay, aYear, aDesc = GetAchievementInfo (id)
	achT = { aId, aName, aPoints, aComplete, aMonth or false, aDay or false, aYear or false, aDesc }
	
	local numC = GetAchievementNumCriteria (id)
	achT[9] = numC
	achT[10] = {}
	local progressCnt = 0
	local tip = aDesc
	for n = 1, numC do
		local cName, cType, cComplete, cQuantity, cReqQuantity, _, _, _, cQuantityString = GetAchievementCriteriaInfo (id, n)
		achT[10][n] = { cName, cType, cComplete, cQuantity, cReqQuantity, _, _, _, cQuantityString }
	end
	
	Nx.Quest.TrackedAchievements[id] = achT
end

-------------------------------------------------------------------------------
-- Quest Log update
-------------------------------------------------------------------------------

function Nx.Quest.List:LogUpdate()

--	Nx.prtStack ("QUpdate")
--	Nx.prt ("#%d", GetNumQuestLogEntries())

	local Quest = Nx.Quest

	local qn

	Quest:ExpandQuests()

	if not self.LoggingIn then
		qn = Quest:FindNewQuest()
		if not qn then
--			Quest:CheckForNewCompleted()
			Quest:TellPartyOfChanges()
		end
	end
	Quest:RecordQuests(0)

	if self.LoggingIn then
		QWatchLogin = Nx:ScheduleTimer(Quest.WatchAtLogin,.7,Quest)
		QSetPDLogin = Nx:ScheduleTimer(Quest.CurQSetPreviousDone,2,Quest)
		if Nx.qdb.profile.Quest.HCheckCompleted  then
			QHistLogin = Nx:ScheduleTimer(Quest.QuestQueryTimer, 1, Quest)
		end
	end
	
	for k, qn in ipairs (Quest.AcceptPool) do
		local qi = GetQuestLogIndexByID (qn)
		if qi > 0 then
			local curi, cur = Quest:FindCurByIndex (qi)
			if cur then
				Quest.QIdsNew[cur.QId] = time()
				--Nx.prt ("OnQuestUpdate Watch %d %d", qn, k)
				if Nx.qdb.profile.QuestWatch.AddNew and not Quest.DailyPVPIds[cur.QId] then
					Quest.Watch:Add (curi,true)
				end
				Quest:Capture (curi)
			end
			table.remove(Quest.AcceptPool, k)
		end
	end
	
	Quest:RestoreExpandQuests()

	self.LoggingIn = nil

	Quest.Watch:ClearCompleted()
	self:Update()
	Quest.Watch:Update()
	Quest.WQList:Update()
end

-------------------------------------------------------------------------------
-- Update list security stub
-------------------------------------------------------------------------------

function Nx.Quest.List:Update()

	if not self.Win:IsShown() then
		return
	end

--	Nx.prt ("QuestListUpdate")

	local Nx = Nx
	local Quest = Nx.Quest
	local Map = Nx.Map
	local qLocColors = Quest.QLocColors
	local showQId = Nx.qdb.profile.Quest.ShowId

	-- Title

	local _, i = GetNumQuestLogEntries()

	local dailyStr = ""
	--[[local dailysDone = GetDailyQuestsCompleted()
	if Nx.qdb.profile.Quest.ShowDailyCount then
		if dailysDone > 0 then
			dailyStr = L["Daily Quests Completed:"] .. " |cffffffff" .. dailysDone
		end
	end
	if Nx.qdb.profile.Quest.ShowDailyReset then
		dailyStr = dailyStr .. "|r  " .. L["Daily reset:"] .. " |cffffffff" .. Nx.Util_GetTimeElapsedStr (GetQuestResetTime())
	end]]--

	self.Win:SetTitle (format (L["Quests:"] .. " |cffffffff%d/%d|r  %s", i, MAX_QUESTS, dailyStr))

	-- List

	local list = self.List
	list:Empty()
	
	if self.TabSelected == 1 then

		local oldSel = GetQuestLogSelection()

		local header
		local curq = Quest.CurQ

		for n = 1, curq and #curq or 0 do

			local cur = curq[n]
			local quest = cur.Q
			local qId = cur.QId

			local title, level, tag, isComplete = cur.Title, cur.Level, cur.Tag, cur.Complete
			local qn = cur.QI
			
			if qn > 0 then
				SelectQuestLogEntry (qn)
			end

			local onQ = 0
			local onQStr = ""

			if qn > 0 then
				for n = 1, 4 do
					if IsUnitOnQuest (qn, "party"..n) then
						if onQ > 0 then
							onQStr = onQStr .. "," .. UnitName ("party" .. n)
						else
							onQStr = onQStr .. UnitName ("party" .. n)
						end
						onQ = onQ + 1
					end
				end
			end

			if not self.ShowParty or onQ > 0 then

				local lvlStr = "  "
				if level > 0 then
					lvlStr = format ("|cffd0d0d0%2d", level)
				end

				local color = Quest:GetDifficultyColor (level)
				color = format ("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)

				local nameStr = format ("%s %s%s", lvlStr, color, title)

				if quest and quest.CNum then
					nameStr = nameStr .. format (L[" (Part %d of %d)"], quest.CNum, cur.CNumMax)
				end

				if onQ > 0 then
					nameStr = format ("(%d) %s (%s)", onQ, nameStr, onQStr)
				end

				if isComplete then
					nameStr = nameStr .. (isComplete == 1 and "|cff80ff80 - "..L["Complete"] or "|cfff04040 - "..FAILED)
				end

				if tag and cur.GCnt > 0 then
					tag = tag .. " " .. cur.GCnt
				end

				if cur.Daily == LE_QUEST_FREQUENCY_DAILY then
					if tag then
						tag = format (DAILY_QUEST_TAG_TEMPLATE, tag)
					else
						tag = DAILY
					end
				end

				local show = true

				if self.Filters[self.TabSelected] ~= "" then

					local str = strlower (format ("%s %s", nameStr, tag or ""))
					local filtStr = strlower (self.Filters[self.TabSelected])

					show = strfind (str, filtStr, 1, true)
				end

				if self.QOpts.NXShowHeaders and cur.Header ~= header then
					header = cur.Header
					if show then
						list:ItemAdd (0)
						list:ItemSet (2, format ("|cff8f8fff---- %s ----", header))
						list:ItemSetDataEx (list:ItemGetNum(), cur, 1)
						list:ItemSetButton ("QuestHdr", Quest.HeaderHide[cur.Header])
					end
				end

				if show and not Quest.HeaderHide[cur.Header] then

					local id = qId > 0 and qId or cur.Title
					local qStatus = Nx.Quest:GetQuest (id)
					local qWatched = qStatus == "W"

					list:ItemAdd (qId * 0x10000 + qn)

					local trackMode = Quest.Tracking[qId] or 0

					local butType = "QuestWatch"
					local butOn

					local trkStr = " "
					if bit.band (trackMode, 1) > 0 then
						trkStr = "*"
						butOn = true
					end

					if qWatched then
						butType = "QuestWatching"
						butOn = true
					end

					list:ItemSetButton (butType, butOn)

					if quest and showQId then
						nameStr = nameStr .. format (" [%s]", qId)
					end

					if cur.HighPri then
						nameStr = "> " .. nameStr
					end

					list:ItemSet (2, nameStr)
					list:ItemSet (4, tag)

					if self.QOpts.NXShowObj then

						local num = GetNumQuestLeaderBoards (qn)
						local oCompColor = Nx.Quest.Cols["oCompColor"]
						local oIncompColor = Nx.Quest.Cols["oIncompColor"]

						local str = ""
						local desc, typ, done
						local zone, loc

						for ln = 1, num do

							zone = nil

							local obj = quest and quest["Objectives"]

							if obj then
								desc, zone, loc = Nx.Quest:UnpackObjectiveNew (obj[n])
							end
							if ln <= num then
								desc, typ, done = GetQuestLogLeaderBoard (ln, qn)
								desc = desc or "?"	--V4

							else
								if not obj then
									break
								end

								done = false
							end
							if not desc then desc = "?" end
							color = done and oCompColor or oIncompColor
							str = format ("     %s%s", color, desc)

							list:ItemAdd (qId * 0x10000 + ln * 0x100 + qn)

							local trkStr = ""

							if zone then
--								trkStr = "|cff505050o"
								list:ItemSetButton ("QuestWatch", false)
							end

							if bit.band (trackMode, bit.lshift (1, ln)) > 0 then
								list:ItemSetButton (qLocColors[ln][5], true)
							end
							list:ItemSet (1, trkStr)

							list:ItemSet (2, str)
						end
					end
				end
			end
		end

		SelectQuestLogEntry (oldSel)

	end

	-- Add history quests

	if Nx.Quests and self.TabSelected == 2 then

		local qIds = Quest.QIds

		local sortT = {}

		local showAllZones = self.ShowAllZones or self.ShowAllQuests
		local showLowLevel = self.ShowLowLevel or self.ShowAllQuests
		local showHighLevel = self.ShowHighLevel or self.ShowAllQuests
		local showFinished = self.ShowFinished or self.ShowAllQuests
		local showOnlyDailies = self.ShowOnlyDailies and not self.ShowAllQuests

		local mapId = Map:GetCurrentMapId()

		local minLevel = UnitLevel ("player") - GetQuestGreenRange()
		local maxLevel = showHighLevel and MAX_PLAYER_LEVEL or UnitLevel ("player") + 6

		-- Divider

		list:ItemAdd (0)
		list:ItemAdd (0)
		local dbTitleIndex = list:ItemGetNum()
		local dbTitleNum = 0
		list:ItemAdd (0)

		for qId in pairs (Nx.Quest.CurCharacter.Q) do			-- Loop over quests with history

			local quest = Nx.Quests[qId]
			local status, qTime = Nx.Quest:GetQuest (qId)
			local qCompleted = status == "C"

			local show = qCompleted

			if show and not showAllZones then
				show = Quest:CheckShow (mapId, qId)
			end

			if show then

				local qname, side_, lvl

				if quest then
					qname, side_, lvl = Quest:Unpack (quest["Quest"])
				else
					qname = format ("%s?", qId)
					lvl = 0
				end

--				Nx.prt ("%s [%s] %s", qname, qId, quest.CNum or "")

				local lvlStr = format ("|cffd0d0d0%2d", lvl)
				local title = qname

				if quest and quest.CNum then
					title = title .. format (L[" (Part %d)"], quest.CNum)
				end

				if showQId then
					title = title .. format (" [%s]", qId)
				end

				local dailyName = ""

				local dailyStr = Quest.DailyIds[qId] or Quest.DailyDungeonIds[qId] or Quest.DailyPVPIds[qId]
				if dailyStr then

					local typ = Nx.Split ("^", dailyStr)
					dailyName = format (" |cffd060d0(%s)", Quest.DailyTypes[typ])

					local age = time() - qTime
					local dayChange = 86400 - GetQuestResetTime()

					if age < dayChange then
						dailyName = dailyName .. L[" |cffff8080today"]
					end
				end

				local show = true

				if self.Filters[self.TabSelected] ~= "" then

					local str = strlower (format ("%2d %s %s%s", lvl, title, date ("%m/%d %H:%M:%S", qTime), dailyName))
					local filtStr = strlower (self.Filters[self.TabSelected])

					show = strfind (str, filtStr, 1, true)
				end

				if show then

					local t = {}
					tinsert (sortT, t)

					t.T = qTime
					t.QId = qId

					dbTitleNum = dbTitleNum + 1

					local haveStr = ""

					if qIds[qId] then
						haveStr = "|cffe0e0e0+ "
					end

					local color = Quest:GetDifficultyColor (lvl)
					color = format ("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)

					t.Desc = format ("%s %s%s%s", lvlStr, haveStr, color, title)
					t.Col4 = format ("%s %s", date ("|cff9f9fcf%m/%d %H:%M:%S", qTime), dailyName)
				end
			end
		end

		sort (sortT, function (a, b) return a.T > b.T end)

		for _, qEntry in ipairs (sortT) do

			list:ItemAdd (qEntry.QId * 0x10000)
			list:ItemSet (2, qEntry.Desc)
			list:ItemSet (4, qEntry.Col4)
		end

		local str = (showAllZones and "All" or Map:IdToName (mapId)) .. L[" Completed"]

		list:ItemSet (2, format ("|cffc0c0c0--- %s (%d) ---", str, dbTitleNum), dbTitleIndex)
	end

	-- Add database quests

	if Nx.Quests and self.TabSelected == 3 then

		local qIds = Quest.QIds

		local sortT = {}

		local showAllZones = self.ShowAllZones or self.ShowAllQuests
		local showLowLevel = self.ShowLowLevel or self.ShowAllQuests
		local showHighLevel = self.ShowHighLevel or self.ShowAllQuests
		local showFinished = self.ShowFinished or self.ShowAllQuests
		local showOnlyDailies = self.ShowOnlyDailies and not self.ShowAllQuests

		local mapId = Map:GetCurrentMapId()

		local minLevel = UnitLevel ("player") - GetQuestGreenRange()
		local maxLevel = showHighLevel and 60 or UnitLevel ("player") + 6

		-- Divider

		list:ItemAdd (0)
		list:ItemAdd (0)
		local dbTitleIndex = list:ItemGetNum()
		local dbTitleNum = 0
		list:ItemAdd (0)

		local addBlank
		local inchain
		local showchain

--		local qsIndex = 1
--		local qsLast = #Quest.Sorted
--		while qsIndex <= qsLast do

		for qsIndex, qId in pairs (Quest.Sorted) do

--			local qId = Quest.Sorted[qsIndex]

			local quest = Nx.Quests[qId]
			if not quest then
				Nx.prt (L["nil quest %s"], qId)
			end
			local qname, side, lvl, minlvl, next = Quest:Unpack (quest["Quest"])

			local status, qTime = Nx.Quest:GetQuest (qId)
			local qCompleted = status == "C"

			if not quest.CNum or quest.CNum == 1 then
				addBlank = true
			end

			local show = showchain

			if not inchain then

				show = true

				if quest.CLvlMax then
					inchain = true
				end

				if not showLowLevel then
					if quest.CLvlMax then
						show = show and quest.CLvlMax >= minLevel
					else
						show = show and ((lvl == 0) or (lvl >= minLevel))
					end
				end
				show = show and lvl <= maxLevel

				if show and not showAllZones then
					show = self:CheckShow (mapId, qsIndex)
				end

				showchain = show
			end

			if not Quest.DailyIds[qId] then
				if (not showFinished and qCompleted) or showOnlyDailies then
					show = false
				end
			end

			if show then

				local lvlStr = format ("|cffd0d0d0%2d", lvl)
				local title = qname

				local cati = Quest:UnpackCategory (quest["Quest"])
				if cati > 0 then
					title = title .. " <" .. Nx.QuestCategory[cati] .. ">"
				end

				if quest.CNum then

--					if quest.CNum > 1 then
--						lvlStr = "    " .. lvlStr
--					end
					title = title .. format (L[" (Part %d)"], quest.CNum)
				end

				local tag = qCompleted and L["(History) "] or ""

				local dailyStr = Quest.DailyIds[qId] or Quest.DailyDungeonIds[qId]
				if dailyStr then
					local typ, money, rep, req = Nx.Split ("^", dailyStr)
					tag = format ("|cffd060d0(%s %.2fg", Quest.DailyTypes[typ], money / 100)
					for n = 0, 1 do	-- Only support 2 reps
						local i = n * 4 + 1
						local repChar = strsub (rep or "", i, i)
						if repChar == "" then
							break
						end
						tag = format ("%s, %s %s", tag, strsub (rep, i + 1, i + 3), Quest.Reputations[repChar])
					end
					if req and Quest.Requirements[req] then	-- 1 and 2 (Ally, Horde) not in table
						tag = tag .. L[", |cffe0c020Need "] .. Quest.Requirements[req]
					end
					tag = tag .. ")"
				end

				local filterName = ""

				local sMapName
				local sName, sMapId = Quest:UnpackSE (quest["Start"])
				if sMapId then
					sMapName = Map:IdToName (sMapId)
					filterName = format ("%s(%s)", sName, sMapName)
				end

				local eMapName
				local eName, eMapId = Quest:UnpackSE (quest["End"])
				if eMapId then
					eMapName = Map:IdToName (eMapId)
					if sName ~= eName then
						filterName = format ("%s%s(%s)", filterName, eName, eMapName)
					end
				end

				local show = true

				if self.Filters[self.TabSelected] ~= "" then

					for n = 1, 15 do

						local obj = quest["Objectives"]
						if obj then obj = quest["Objectives"][n] end
						if not obj then
							break
						end

						local name, zone = Nx.Quest:UnpackObjectiveNew (obj)
						if zone then
							filterName = filterName .. Map:IdToName (zone)
						end
					end

					local str = strlower (format ("%2d %s %s %s", lvl, title, filterName, tag))
					local filtStr = strlower (self.Filters[self.TabSelected])

					show = strfind (str, filtStr, 1, true)
				end

				if show then

					if addBlank then
						addBlank = false
						list:ItemAdd (0)
					end

					dbTitleNum = dbTitleNum + 1

					local trackMode = Quest.Tracking[qId] or 0

					list:ItemAdd (qId * 0x10000)

					local haveStr = ""

					if qIds[qId] then
						haveStr = "|cffe0e0e0+ "
					end

					local color = Quest:GetDifficultyColor (lvl)
					color = format ("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)

					local str = format ("%s %s%s%s", lvlStr, haveStr, color, title)

					if showQId then
						str = str .. format (" [%s]", qId)
					end

					local questTip = "@" .. qId

					list:ItemSet (2, str)
					list:ItemSet (4, tag)

					if sName then
						list:ItemAdd (qId * 0x10000)

						if not eName then
							list:ItemSet (2, "     |cff6060ff" ..L["Start/End: "] .. sName)
						else
							list:ItemSet (2, "     |cff6060ff" ..L["Start: "] .. sName)
						end
						list:ItemSet (4, sMapName)

						list:ItemSetButton ("QuestWatch", false)
						if bit.band (trackMode, 1) > 0 then
							list:ItemSetButton ("QuestWatch", true)
						end
						list:ItemSetButtonTip (questTip)
					end
					if eName then
						list:ItemAdd (qId * 0x10000 + 16 * 0x100)
						list:ItemSet (2, L["     |cff6060ffEnd: "] .. eName)
						list:ItemSet (4, eMapName)

						list:ItemSetButton ("QuestWatch", false)
						if bit.band (trackMode, 0x10000) > 0 then
							list:ItemSetButton ("QuestWatch", true)
						end
						list:ItemSetButtonTip (questTip)
					end

					-- Objectives (max of 15)

					for n = 1, 15 do

						local obj = quest["Objectives"]
						if obj then obj = quest["Objectives"][n] end
						if not obj then
							break
						end

						list:ItemAdd (qId * 0x10000 + n * 0x100)

						local name, zone, loc = Nx.Quest:UnpackObjectiveNew (obj)
						if not name then
							name = "?"
						end
--						str = zone and "|cff505050o" or ""
						if zone then
							list:ItemSetButton ("QuestWatch", false)
							list:ItemSetButtonTip (questTip)
							list:ItemSet (4, Map:IdToName (zone))
						end

						if bit.band (trackMode, bit.lshift (1, n)) > 0 then
							list:ItemSetButton (qLocColors[n][5], true)
						end

--						list:ItemSet (1, str)
						list:ItemSet (2, format ("     |cff9f9faf%s", name))
					end
				end
			end

			if next == 0 then
				inchain = false
			end

--			qsindex = qsindex + 1
		end

		local str = (showAllZones and "Full" or Map:IdToName (mapId)) .. L[" Database"]

		list:ItemSet (2, format ("|cffc0c0c0--- %s (%d) ---", str, dbTitleNum), dbTitleIndex)

		local low = max (1, showLowLevel and 1 or minLevel)
		local high = min (MAX_PLAYER_LEVEL, maxLevel)
		list:ItemSet (2, format (L["|cffc0c0c0--- Levels %d to %d ---"], low, high), dbTitleIndex + 1)
	end

	-- Add other player quests

	if self.TabSelected == 4 then

		local qIds = Quest.QIds

		list:ItemAdd (0)
		list:ItemSet (2, format ("|cffc0c0c0--- %s %s/%s ---", Quest.RcvPlyrLast, Quest.RcvCnt, Quest.RcvTotal))

		for n = 1, #Quest.FriendQuests do

			local data = Quest.FriendQuests[n]
			local mode = strsub (data, 1, 1)

			list:ItemAdd (0)

			if mode == " " then		-- Simple text

				list:ItemSet (2, strsub (data, 3))

			elseif mode == "H" then

				list:ItemSet (2, format ("|cff8f8fff---- %s ----", strsub (data, 3)))

			elseif mode == "T" then

				local _, qId, watched, done, lvl, name = Nx.Split ("^", data)

				if qId and name then

					qId = tonumber (qId)

					if qId >= 0 then

--						watched = watched == "0" and "" or "*"

						if watched ~= "0" then
							list:ItemSet (1, "|cffcfcfcfw")
						end

						local haveStr = ""
						if qIds[qId] then
							haveStr = "|cffe0e0e0+ "
						end

						done = done == "0" and "" or "|cff80ff80 - " .. L["Complete"]

						list:ItemSet (2, format ("%s %s%s%s", lvl, haveStr, name, done))
					end
				end

			elseif mode == "O" then

				local _, qId, name = Nx.Split ("^", data)

				if name then

					local color = done and "|cff5f5f6f" or "|cff9f9faf"
					local str = format ("     %s%s", color, name)

					list:ItemSet (2, str)
				end
			end
		end
	end

	--

	list:Update()

	Quest.Watch:Update()

	if self.TabSelected == 1 then

		local i = list:GetSelected()
		local data = list:ItemGetData (i) or 0

--		Nx.prt ("%s %s", i, data)

		if data > 0 then
			Nx.Quest:SelectBlizz (bit.band (data, 0xff))
			NxQuestD:Show()

			Quest:UpdateQuestDetails()
		else
			NxQuestD:Hide()
		end
	end

end

function Nx.Quest.List:CheckShow (mapId, index)
	local Quest = Nx.Quest
	local _qids = {}
	local cnum = 0
	
	while true do
		cnum = cnum + 1
		local qId = Quest.Sorted[index]

		if Quest:CheckShow (mapId, qId) then
			return true
		end

		local quest = Nx.Quests[qId]
		local qnext = Quest:UnpackNext (quest["Quest"])

		if not qnext or qnext == 0 or _qids[qnext] == true or cnum > 40 then
			return
		end
		
		_qids[qnext] = true

		index = index + 1
	end
end

-------------------------------------------------------------------------------
-- CLONED BLIZZARD TEXTURE FUNCTIONS
-------------------------------------------------------------------------------

local function ApplyTextureToPOI(texture, width, height)
	texture:SetTexCoord(0, 1, 0, 1);
	texture:ClearAllPoints();
	texture:SetPoint("CENTER", texture:GetParent());
	texture:SetSize(width or 32, height or 32);
end

local function ApplyAtlasTexturesToPOI(button, normal, pushed, highlight, width, height)
	button:SetSize(20, 20);
	button:SetNormalAtlas(normal);
	ApplyTextureToPOI(button:GetNormalTexture(), width, height);

	button:SetPushedAtlas(pushed);
	ApplyTextureToPOI(button:GetPushedTexture(), width, height);

	button:SetHighlightAtlas(highlight);
	ApplyTextureToPOI(button:GetHighlightTexture(), width, height);

	if button.SelectedGlow then
		button.SelectedGlow:SetAtlas(pushed);
		ApplyTextureToPOI(button.SelectedGlow, width, height);
	end
end

local function ApplyStandardTexturesToPOI(button, selected)
	button:SetSize(20, 20);
	button:SetNormalTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons");
	ApplyTextureToPOI(button:GetNormalTexture());
	if selected then
		button:GetNormalTexture():SetTexCoord(0.500, 0.625, 0.375, 0.5);
	else
		button:GetNormalTexture():SetTexCoord(0.875, 1, 0.375, 0.5);
	end


	button:SetPushedTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons");
	ApplyTextureToPOI(button:GetPushedTexture());
	if selected then
		button:GetPushedTexture():SetTexCoord(0.375, 0.500, 0.375, 0.5);
	else
		button:GetPushedTexture():SetTexCoord(0.750, 0.875, 0.375, 0.5);
	end

	button:SetHighlightTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons");
	ApplyTextureToPOI(button:GetHighlightTexture());
	button:GetHighlightTexture():SetTexCoord(0.625, 0.750, 0.875, 1);
end

-------------------------------------------------------------------------------
-- Update map icons (called by map)
-------------------------------------------------------------------------------

function Nx.Quest:UpdateIcons (map)
	if not Nx.QInit then
		return
	end
	local Nx = Nx
	local Quest = Nx.Quest
	local Map = Nx.Map
	local qLocColors = Quest.QLocColors
	local ptSz = 4 * map.ScaleDraw

	local navscale = Map.Maps[1].IconNavScale * 16
	local showOnMap = Quest.Watch.ButShowOnMap:GetPressed()

	local opts = self.GOpts
	local showWatchAreas = Nx.qdb.profile.Quest.MapShowWatchAreas
	local trkR, trkG, trkB, trkA =  Nx.Quest.Cols["trkR"], Nx.Quest.Cols["trkG"], Nx.Quest.Cols["trkB"], Nx.Quest.Cols["trkA"]
	local hovR, hovG, hovB, hovA =  Nx.Quest.Cols["hovR"], Nx.Quest.Cols["hovG"], Nx.Quest.Cols["hovB"], Nx.Quest.Cols["hovA"]

	-- Update target

	local typ, tid = Map:GetTargetInfo()
	if typ == "Q" then

--		Nx.prt ("QTar %s", tid)

		local qid = floor (tid / 100)
		local i, cur = Quest:FindCur (qid)

		if cur then
			Quest:CalcDistances (cur.Index, cur.Index)
			Quest:TrackOnMap (cur.QId, tid % 100, cur.QI > 0 or cur.Party, true, true)

--			Nx.prt ("UpIcons target %s %s", typ or "nil", tid or "nil")
		end
	end

	-- Blob

--	local f = self.BlobFrm


	-- Draw completed quests

	for k, cur in ipairs (Quest.CurQ) do

		if cur.Q and cur.CompleteMerge then

			local q = cur.Q
			local obj = q["End"] or q["Start"]

			local endName, zone, x, y = Quest:GetSEPos (obj)
			local mapId = zone

			if mapId then

				local wx, wy = map:GetWorldPos (mapId, x, y)
				local f = map:GetIconStatic (4)

				if map:ClipFrameByMapType (f, wx, wy, navscale, navscale, 0) then

					f.NXType = 9000
					f.NXData = cur
					local qname = Nx.TXTBLUE .. "Quest: " .. cur.Title
					f.NxTip = format (L["%s\nEnd: %s (%.1f %.1f)"], qname, endName, x, y)
					if cur.PartyNames then
						f.NxTip = f.NxTip .. "\n" .. cur.PartyNames
					end
					f.texture:SetTexture ("Interface\\AddOns\\Carbonite\\Gfx\\Map\\IconQuestion")
				end
			end
		end
	end

	-- Update tracking data

	local tracking = self.IconTracking

	if Nx.Map:GetMap (1).Frm.NxMap.Tick % 10 == 0 then

--		tracking = {}		-- garbage creator
		wipe (tracking)

		for trackId, trackMode in pairs (Quest.Tracking) do
			tracking[trackId] = trackMode
		end

		if showOnMap then
			for k, cur in ipairs (Quest.CurQ) do
				if cur.Q and (Nx.Quest:GetQuest (cur.QId) == "W" or cur.PartyDesc) then
					tracking[cur.QId] = (tracking[cur.QId] or 0) + 0x10000		-- cur.TrackMask + i
				end
			end
		end

		self.IconTracking = tracking
	end

	-- Draw

	local areaTex = Nx.Opts.ChoicesQAreaTex[Nx.qdb.profile.Quest.MapWatchAreaGfx]

	local colorPerQ = Nx.qdb.profile.Quest.MapWatchColorPerQ
	local colMax = Nx.qdb.profile.Quest.MapWatchColorCnt

	for trackId, trackMode in pairs (tracking) do

		local cur = Quest.IdToCurQ[trackId]
		local quest = cur and cur.Q or Nx.Quests[trackId]
		local qname = Nx.TXTBLUE .. L["Quest: "] .. (cur and cur.Title or Quest:UnpackName (quest["Quest"]))

		local mask = showOnMap and cur and cur.TrackMask or trackMode
		local showEnd

		if bit.band (mask, 1) > 0 then

			if not (cur and (cur.QI > 0 or cur.Party)) then

				local startName, zone, x, y = Quest:GetSEPos (quest["Start"])
				local mapId = zone

				if mapId then

					local wx, wy = map:GetWorldPos (mapId, x, y)
					local f = map:GetIconStatic (4)

					if map:ClipFrameByMapType (f, wx, wy, navscale, navscale, 0) then
						f.NxTip = format (L["%s\nStart: %s (%.1f %.1f)"], qname, startName, x, y)
						f.texture:SetTexture ("Interface\\AddOns\\Carbonite\\Gfx\\Map\\IconExclaim")
					end
				end
			else

				showEnd = true
			end
		end

		if showEnd or bit.band (mask, 0x10000) > 0 then

			local obj = quest["End"] or quest["Start"]

			local endName, zone, x, y = Quest:GetSEPos (obj)
			local mapId = zone

			if mapId and (not cur or not cur.CompleteMerge) then

				local wx, wy = map:GetWorldPos (mapId, x, y)
				local f = map:GetIconStatic (4)

				if map:ClipFrameByMapType (f, wx, wy, navscale, navscale, 0) then

					f.NXType = 9000
					f.NXData = cur
					f.NxTip = format ("%s\n" ..L["End: "] .. "%s (%.1f %.1f)", qname, endName, x, y)
					if cur and cur.PartyNames then
						f.NxTip = f.NxTip .. "\n" .. cur.PartyNames
					end
					f.texture:SetVertexColor (.6, 1, .6, 1)
					f.texture:SetTexture ("Interface\\AddOns\\Carbonite\\Gfx\\Map\\IconQuestion")
--					f.texture:SetTexture ("Interface\\AddOns\\Carbonite\\Gfx\\Map\\IconQTarget")
				end
			end
		end

		-- Objectives (max of 15)

		if not cur or cur.QI > 0 or cur.Party then

			local drawArea

			if cur then
				local qStatus = Nx.Quest:GetQuest (cur.QId)
				drawArea = showWatchAreas and qStatus == "W"
			end
--			local drawArea = bit.band (trackMode, 0x10000) == 0

			for n = 1, 15 do

				local obj = quest["Objectives"]
				if obj then
					obj = quest["Objectives"][n]
				end
				if not obj then
					break
				end

				local objName, objZone, typ = Nx.Quest:UnpackObjectiveNew (obj)

				if objZone and objZone ~= 9000 then

					local mapId = objZone

					if not mapId then
--						Nx.prt ("Nxzone error %s %s", objName, objZone)
						break
					end
					if bit.band (mask, bit.lshift (1, n)) > 0 then
						local colI = n

						if colorPerQ then
							colI = ((cur and cur.Index or 1) - 1) % colMax + 1
						end

						local col = qLocColors[colI]
						local r = col[1]
						local g = col[2]
						local b = col[3]

						local oname = cur and cur[n] or objName

						if typ == 32 then  -- Points
--							Nx.prt ("%s, pt %s", objName, strsub (obj, loc + 1))
							local cnt = 1
							local sz = navscale

							if cnt > 1 then
								sz = map:GetWorldZoneScale (mapId) / 10.02 * ptSz
							end
							local x, y = Nx.Quest:UnpackLocPtOff (obj)
							local wx, wy = map:GetWorldPos (mapId, x, y)

							local f = map:GetIconStatic (4)
							if map:ClipFrameByMapType (f, wx, wy, sz, sz, 0) then
								f.NXType = 9000 + n
								f.NXData = cur
								f.NxTip = format ("%s\nObj: %s (%.1f %.1f)", qname, oname, x, y)
								if cur and cur[n + 400] then
									f.NxTip = f.NxTip .. "\n" .. cur[n + 400]
								end
								if cnt == 1 then
									f.texture:SetTexture ("Interface\\AddOns\\Carbonite\\Gfx\\Map\\IconQTarget")
									f.texture:SetVertexColor (r, g, b, .9)
								else
									f.texture:SetTexture ("Interface\\AddOns\\Carbonite\\Gfx\\Map\\IconCirclePlus")
									f.texture:SetVertexColor (r, g, b, .5)
								end
							end

						else -- Spans (areas)

--							Nx.prt ("%s, spans %s", objName, strsub (obj, loc))

							local hover = Quest.IconHoverCur == cur and Quest.IconHoverObjI == n
							local tracking = bit.band (trackMode, bit.lshift (1, n)) > 0

							local tip = format (L["%s\nObj: %s"], qname, oname)
							if cur and cur[n + 400] then
								tip = tip .. "\n" .. cur[n + 400]
							end

							local x

							if cur then
								local d = cur["OD"..n]
								if d and d > 0 then
									x = cur["OX"..n]
								end
							end

							if x then
								local y = cur["OY"..n]
								local f = map:GetIcon (4)
								local sz = navscale

								if not hover then
									sz = sz * .8
								end

								if map:ClipFrameByMapType (f, x, y, sz, sz, 0) then

									f.NXType = 9000 + n
									f.NXData = cur
									f.NxTip = tip

									f.texture:SetTexture ("Interface\\AddOns\\Carbonite\\Gfx\\Map\\IconAreaArrows")

									if tracking then
										f.texture:SetVertexColor (.8, .8, .8, 1)
									else
										f.texture:SetVertexColor (r, g, b, .7)
									end
								end
							end

							if not cur or drawArea or hover
									or (bit.band (trackMode, bit.lshift (1, n)) > 0 and tonumber(trkA) > .05) then

								local ssub = strsub

								for _,loc1 in pairs(obj) do
									if loc1 == "" then
										break
									end
									
									local _, mapId = Nx.Quest:UnpackObjectiveNew (loc1)
									local scale = map:GetWorldZoneScale (mapId) / 10.02
									
									local x, y, w, h = Nx.Quest:UnpackLocRect (loc1)
									local wx, wy = map:GetWorldPos (mapId, x, y)

									local f = map:GetIconStatic (hover and 1)
									if areaTex then

										if map:ClipFrameTL (f, wx, wy, w * scale, h * scale) then
											f.NXType = 9000 + n
											f.NXData = cur
											f.NxTip = tip

											f.texture:SetTexture (areaTex)

											if hover then
												f.texture:SetVertexColor (hovR, hovG, hovB, hovA)
											elseif tracking then
												f.texture:SetVertexColor (trkR, trkG, trkB, trkA)
											else
												f.texture:SetVertexColor (r, g, b, col[4])
											end
										end

									else

										if map:ClipFrameTLSolid (f, wx, wy, w * scale, h * scale) then

											f.NXType = 9000 + n
											f.NXData = cur
											f.NxTip = tip

											if hover then
												f.texture:SetColorTexture (hovR, hovG, hovB, hovA)
											elseif tracking then
												f.texture:SetColorTexture (trkR, trkG, trkB, trkA)
											else
												f.texture:SetColorTexture (r, g, b, col[4])
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

	-- BONUS TASKS and WORLD QUESTS icons
	local taskIconIndex = 1
	local activeWQ = {}
	if Map.UpdateMapID ~= 9000 then
		local taskInfo = nil -- C_TaskQuest.GetQuestsForPlayerByMapID(Map.UpdateMapID);
		if taskInfo and Nx.db.char.Map.ShowWorldQuest then
			for i=1,#taskInfo do				
				local info = taskInfo[i]
				local questId = taskInfo[i].questId				
				local title, faction = C_TaskQuest.GetQuestInfoByQuestID(questId)
				if QuestUtils_IsQuestWorldQuest (questId) and (worldquestdb[questId] and worldquestdb[questId].mapid == Map.UpdateMapID and not worldquestdb[questId].Filtered) then
					activeWQ[questId] = true
					C_TaskQuest.RequestPreloadRewardData (questId)
					local tid, name, questtype, rarity, elite, tradeskill = GetQuestTagInfo (questId)
					local timeLeft = C_TaskQuest.GetQuestTimeLeftMinutes(questId)
					if QuestUtils_ShouldDisplayExpirationWarning(questId) or (timeLeft and timeLeft > 0) then

						local x,y = info.x * 100, info.y * 100
						local f = map:GetIconWQ(120)

						map:ClipFrameZ (f, x, y, 24, 24, 0)

						local selected = info.questId == GetSuperTrackedQuestID();
						
						local function WQTGetOverlay (memberName)
							for i = 1, #WorldMapFrame.overlayFrames do
								local overlay = WorldMapFrame.overlayFrames [i]
								if (overlay [memberName]) then
									return overlay
								end
							end
						end
						local isCriteria = WQTGetOverlay("IsWorldQuestCriteriaForSelectedBounty"):IsWorldQuestCriteriaForSelectedBounty(info.questId);
						--local isSpellTarget = SpellCanTargetQuest() and IsQuestIDValidSpellTarget(info.questId);

						f.worldQuest = true;
						f.questID = info.questId
						f.numObjectives = info.numObjectives;
						f.Texture:SetDrawLayer("OVERLAY");
						f:SetScript("OnClick", function (self, button)
							map:SetTargetAtStr (format("%s, %s", x, y))
							if not InCombatLockdown() and self.worldQuest then
							  if ( not ChatEdit_TryInsertQuestLinkForQuestID(self.questID) ) then
								PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
								if ZygorGuidesViewer and ZygorGuidesViewer.WorldQuests then ZygorGuidesViewer.WorldQuests:SuggestWorldQuestGuideFromMap(nil,self.questID,"force",self.mapID) end
								if IsShiftKeyDown() then
								  if IsWorldQuestHardWatched(self.questID) or (IsWorldQuestWatched(self.questID) and GetSuperTrackedQuestID() == self.questID) then
									BonusObjectiveTracker_UntrackWorldQuest(self.questID);
								  else
									BonusObjectiveTracker_TrackWorldQuest(self.questID, true);
								  end
								else
								  if IsWorldQuestHardWatched(self.questID) then
									SetSuperTrackedQuestID(self.questID);
								  else
									BonusObjectiveTracker_TrackWorldQuest(self.questID);
								  end
								end
							   end
							 end
						end)

						QuestUtil.SetupWorldQuestButton(f, questtype, rarity, elite, tradeskill, info.inProgress, selected, isCriteria)

						f.texture:Hide()

						--[[if questtype == LE_QUEST_TAG_TYPE_PVP then
							f.NxTip = L["|cffffd100World Quest (Combat Task):\n"] .. title .. objTxt .. (WQTable[questId].reward or L["\n \nReward: Loading..."]) .. timeLeftTxt
						elseif questtype == LE_QUEST_TAG_TYPE_PET_BATTLE then
							f.NxTip = L["|cffffd100World Quest (Pet Task):\n"] .. title .. objTxt .. (WQTable[questId].reward or L["\n \nReward: Loading..."]) .. timeLeftTxt
						else
							f.NxTip = L["|cffffd100World Quest:\n"] .. title .. objTxt .. (WQTable[questId].reward or L["\n \nReward: Loading..."]) .. timeLeftTxt
						end]]--
					end
				else
					if not worldquestdb[questId] then
						taskIconIndex = taskIconIndex + 1
						local x,y = taskInfo[i].x * 100, taskInfo[i].y * 100
						local f = map:GetIcon (3)

						-- objectives
						local objTxt = ""
						for objectiveIndex = 1, taskInfo[i].numObjectives do
							local objectiveText, objectiveType, finished = GetQuestObjectiveInfo(questId, objectiveIndex, false)
							if ( objectiveText and #objectiveText > 0 ) then
								local color = finished and HIGHLIGHT_FONT_COLOR or GRAY_FONT_COLOR
								color = format("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255);
								objTxt = objTxt .. "\n- " .. color .. objectiveText
							end
						end
						
						if taskInfo[i].isCombatAllyQuest then
							if not taskInfo[i].inProgress  then
								f.questID = taskInfo[i].questId
								f.NxTip = "|cffffd100Daily Task:\n" .. title:gsub("Daily Objective: ", "") .. objTxt .. "\n" .. GREEN_FONT_COLOR:GenerateHexColorMarkup() .. GRANTS_FOLLOWER_XP
								f.texture:SetTexture ("Interface\\Minimap\\ObjectIconsAtlas")
								map:ClipFrameZ (f, x, y, 22, 22, 0)
								f.texture:SetTexCoord (GetObjectIconTextureCoords(4713))
								f:SetScript("OnMouseDown", function (self, button)
									 map:SetTargetAtStr (format("%s, %s", x, y))
									 if not InCombatLockdown() then
									  if ( not ChatEdit_TryInsertQuestLinkForQuestID(self.questID) ) then
										PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
										if ZygorGuidesViewer and ZygorGuidesViewer.WorldQuests then ZygorGuidesViewer.WorldQuests:SuggestWorldQuestGuideFromMap(nil,self.questID,"force",self.mapID) end
									   end
									 end
								end)
							end
						else
							f.NxTip = "|cffffd100Bonus Task:\n" .. title:gsub("Bonus Objective: ", "") .. objTxt
							f.texture:SetTexture ("Interface\\Minimap\\ObjectIconsAtlas")
							map:ClipFrameZ (f, x, y, 16, 16, 0)
							f.texture:SetTexCoord (GetObjectIconTextureCoords(4734))
						end
						
					end
				end
			end
		end

		-- clear unused WQ
		--[[for qId, value in ipairs (WQTable) do
			if not activeWQ[qId] then
				WQTable[qId] = nil
			end
		end]]--

	end
end

function Nx.Quest:IconOnEnter (frm)

	local i = frm.NXType - 9000
	local cur = frm.NXData

	self.IconHoverCur = cur
	self.IconHoverObjI = i
end

function Nx.Quest:IconOnLeave (frm)

	self.IconHoverCur = nil
end

function Nx.Quest:IconOnMouseDown (frm)

	local cur = self.IconHoverCur
	if cur then

		self.IconMenuCur = cur
		self.IconMenuObjI = self.IconHoverObjI

		local qStatus = Nx.Quest:GetQuest (cur.QId)
		self.IconMenuIWatch:SetChecked (qStatus == "W")

		self.IconMenu:Open()
	end
end

-------------------------------------------------------------------------------
-- Called when details frame size changes
-------------------------------------------------------------------------------

function Nx.Quest.List:OnDetailsSetSize (w, h)

--	Nx.prt ("QDetails %d %d", w, h)

	local scale = Nx.qdb.profile.Quest.DetailScale

	NXQuestLogDetailScrollChildFrame:SetScale (scale)

	local upH = NxQuestDScrollBarScrollUpButton:GetHeight()

	local bar = NxQuestDScrollBar
	local barW = bar:GetWidth()

	local details = NxQuestD
	bar:SetPoint ("TOPLEFT", details, "TOPRIGHT", 1, -upH)
	details:SetWidth (w - barW - 1)

	local dw = (w - barW - 8) / scale

--	Nx.Quest.List:DetailsSetWidth (dw)
end

function Nx.Quest.List:DetailsSetWidth (w)

--	NXQuestLogDetailScrollChildFrame:SetWidth (w)
--	QuestInfoFrame:SetWidth (w)
	QuestInfoObjectivesText:SetWidth (w)
	QuestInfoDescriptionText:SetWidth (w)
	QuestInfoItemChooseText:SetWidth (w)
--	QuestInfoRewardText:SetWidth (w)
end

-------------------------------------------------------------------------------
-- Details
-------------------------------------------------------------------------------

function Nx.Quest:UpdateQuestDetails()

	-- 1 tick delay, since Blizz is hiding/resetting on log open
	QDetail = Nx:ScheduleTimer(self.UpdateQuestDetailsTimer,0,self)
end

function Nx.Quest:UpdateQuestDetailsTimer()
	
	-- HACK
	function GetNumQuestLogRewardCurrencies()
      return 1
	end
	
	QuestInfoRewardsFrameQuestInfoItem1:Hide();
	
	--	Nx.prt ("UpdateQuestDetails")
	QuestInfo_Display (CBQUEST_TEMPLATE, NXQuestLogDetailScrollChildFrame, nil, nil)
	
	-- HACK
	function GetNumQuestLogRewardCurrencies()
      return 0
    end
	
	local r, g, b, a = Nx.Util_str2rgba (Nx.qdb.profile.Quest.DetailBC)

	-- 0.18, 0.12, 0.06 parchment
	local r, g, b = Nx.Util_str2rgba (Nx.qdb.profile.Quest.DetailTC)

	local t = {
			"QuestInfoTitleHeader", "QuestInfoDescriptionHeader", "QuestInfoObjectivesHeader",
			"QuestInfoDescriptionText", "QuestInfoObjectivesText", "QuestInfoGroupSize", "QuestInfoRewardText",
	}

	for k, name in ipairs (t) do
		if not _G[name] then
--			Nx.prt ("QDetails missing %s", name)
				if( name =="QuestInfoRewardsHeader") then
				local qirFrame = _G["QuestInfoRewardsFrame"]
				if qirFrame then
					local headerFrame = qirFrame.Header

					if headerFrame then
						local frameName = headerFrame:GetName() or "unnamed"
						--Nx.prt("Frame Name: " .. frameName)
						headerFrame:SetTextColor (r, g, b)
					end
				end
			end
		else
			_G[name]:SetTextColor (r, g, b)
		end
	end
	
	QuestInfoRewardsFrame.Header:SetTextColor(r, g, b)
	QuestInfoRewardsFrame["ItemChooseText"]:SetTextColor(r, g, b)
	QuestInfoRewardsFrame["ItemReceiveText"]:SetTextColor(r, g, b)
--	MapQuestInfoRewardsFrame["SpellLearnText"]:SetTextColor(r, g, b)
	QuestInfoRewardsFrame["PlayerTitleText"]:SetTextColor(r, g, b)
	
	local qId = select(8, GetQuestLogTitle(GetQuestLogSelection()))
	local quest = Nx.Quests[qId]
	local name, side, lvl, minlvl, nextId, category, xp = self:Unpack (quest["Quest"])
	xp = xp or 0

	QuestInfoRewardsFrame.XPFrame:Hide()
	if xp > 0 then
		QuestInfo_ToggleRewardElement(QuestInfoRewardsFrame.XPFrame, BreakUpLargeNumbers(xp), QuestInfoRewardsFrame)
		QuestInfoRewardsFrame.XPFrame.ReceiveText:SetTextColor(r, g, b)
		QuestInfoRewardsFrame.XPFrame:Show()
	end
	
	for n = 1, 10 do
		if _G["QuestInfoObjective" .. n] then
			_G["QuestInfoObjective" .. n]:SetTextColor (r, g, b)
		end
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------

function Nx.Quest:FrameItems_Update (questState)

	NxQuestDSCRewardTitleText:SetPoint ("TOPLEFT", "NxQuestDSC", "TOPLEFT", 0, -10)

	local questState = "NxQuestDSC"
	local questItemName = "NxQuestDSCItem"

	local numQuestRewards
	local numQuestChoices
	local money = GetQuestLogRewardMoney()
	local spacerFrame = NxQuestDSCSpacerFrame

	numQuestRewards = GetNumQuestLogRewards()
	numQuestChoices = GetNumQuestLogChoices()

	local numQuestSpellRewards = 0
	if GetQuestLogRewardSpell() then
		numQuestSpellRewards = 1
	end

	local totalRewards = numQuestRewards + numQuestChoices + numQuestSpellRewards
	local material = QuestFrame_GetMaterial()
	local questItemReceiveText = _G[QuestState.."ItemReceiveText"]

	if totalRewards == 0 and money == 0 then
		_G[questState.."RewardTitleText"]:Hide()
	else
		_G[questState.."RewardTitleText"]:Show()
		QuestFrame_SetTitleTextColor (_G[questState.."RewardTitleText"], material)
		QuestFrame_SetAsLastShown (_G[questState.."RewardTitleText"], spacerFrame)
	end

	if money == 0 then
		_G[questState.."MoneyFrame"]:Hide()
	else
		_G[questState.."MoneyFrame"]:Show()
		QuestFrame_SetAsLastShown (_G[questState.."MoneyFrame"], spacerFrame)
		MoneyFrame_Update (questState.."MoneyFrame", money)
	end

	-- Hide unused rewards

	for n = totalRewards + 1, MAX_NUM_ITEMS do
		_G[questItemName..n]:Hide()
	end

	local questItem, name, texture, isTradeskillSpell, isSpellLearned, quality, isUsable, numItems = 1
	local rewardsCount = 0

	-- Setup choosable rewards

	if numQuestChoices > 0 then

		local itemChooseText = _G[questState.."ItemChooseText"]
		itemChooseText:Show()
		QuestFrame_SetTextColor (itemChooseText, material)
		QuestFrame_SetAsLastShown (itemChooseText, spacerFrame)

		local index
		local baseIndex = rewardsCount

		for i = 1, numQuestChoices do

			index = i + baseIndex
			questItem = _G[questItemName..index]
			questItem.type = "choice"
			numItems = 1

			name, texture, numItems, quality, isUsable = GetQuestLogChoiceInfo (i)

			questItem:SetID (i)
			questItem:Show()

			-- For the tooltip
			questItem.rewardType = "item"

			_G[questItemName..index.."Name"]:SetText(name)
			SetItemButtonCount (questItem, numItems)
			SetItemButtonTexture (questItem, texture)

			if isUsable then
				SetItemButtonTextureVertexColor (questItem, 1.0, 1.0, 1.0)
				SetItemButtonNameFrameVertexColor (questItem, 1.0, 1.0, 1.0)
			else
				SetItemButtonTextureVertexColor (questItem, 0.9, 0, 0)
				SetItemButtonNameFrameVertexColor (questItem, 0.9, 0, 0)
			end

			if i > 1 then

				if mod (i, 2) == 1 then
					questItem:SetPoint ("TOPLEFT", questItemName..(index - 2), "BOTTOMLEFT", 0, -2)
					QuestFrame_SetAsLastShown (questItem, spacerFrame)

				else
					questItem:SetPoint ("TOPLEFT", questItemName..(index - 1), "TOPRIGHT", 1, 0)
				end

			else
				questItem:SetPoint ("TOPLEFT", itemChooseText, "BOTTOMLEFT", 0, -5)
				QuestFrame_SetAsLastShown (questItem, spacerFrame)
			end

			rewardsCount = rewardsCount + 1
		end
	else
		_G[questState.."ItemChooseText"]:Hide()
	end

	-- Setup spell rewards

	local learnSpellText = _G[questState.."SpellLearnText"]

	if numQuestSpellRewards > 0 then

		learnSpellText:Show()
		QuestFrame_SetTextColor (learnSpellText, material)
		QuestFrame_SetAsLastShown (learnSpellText, spacerFrame)

		--Anchor learnSpellText if there were choosable rewards
		if rewardsCount > 0 then
			learnSpellText:SetPoint("TOPLEFT", questItemName..rewardsCount, "BOTTOMLEFT", 3, -5)
		else
			learnSpellText:SetPoint("TOPLEFT", questState.."RewardTitleText", "BOTTOMLEFT", 0, -5)
		end

		texture, name, isTradeskillSpell, isSpellLearned = GetQuestLogRewardSpell()

		if isTradeskillSpell then
			learnSpellText:SetText (REWARD_TRADESKILL_SPELL)
		elseif not isSpellLearned then
			learnSpellText:SetText (REWARD_AURA)
		else
			learnSpellText:SetText (REWARD_SPELL)
		end

		rewardsCount = rewardsCount + 1

		questItem = _G[questItemName..rewardsCount]
		questItem:Show()
		-- For the tooltip
		questItem.rewardType = "spell"
		SetItemButtonCount (questItem, 0)
		SetItemButtonTexture (questItem, texture)
		_G[questItemName..rewardsCount.."Name"]:SetText(name)

		QuestFrame_SetAsLastShown (questItem, spacerFrame)

		questItem:SetPoint ("TOPLEFT", learnSpellText, "BOTTOMLEFT", 0, -5)
	else
		learnSpellText:Hide()
	end

	-- Setup mandatory rewards
	if numQuestRewards > 0 or money > 0 then

		QuestFrame_SetTextColor (questItemReceiveText, material)

		-- Anchor the reward text differently if there are choosable rewards
		if numQuestSpellRewards > 0 then
			questItemReceiveText:SetText (REWARD_ITEMS)
			questItemReceiveText:SetPoint ("TOPLEFT", questItemName..rewardsCount, "BOTTOMLEFT", 3, -5)

		elseif numQuestChoices > 0 then
			questItemReceiveText:SetText (REWARD_ITEMS)
			local index = numQuestChoices
			if mod (index, 2) == 0 then
				index = index - 1
			end
			questItemReceiveText:SetPoint ("TOPLEFT", questItemName..index, "BOTTOMLEFT", 3, -5)

		else
			questItemReceiveText:SetText (REWARD_ITEMS_ONLY)
			questItemReceiveText:SetPoint ("TOPLEFT", questState.."RewardTitleText", "BOTTOMLEFT", 3, -5)
		end

		questItemReceiveText:Show()
		QuestFrame_SetAsLastShown (questItemReceiveText, spacerFrame)

		-- Setup mandatory rewards
		local index
		local baseIndex = rewardsCount

		for i = 1, numQuestRewards do

			index = i + baseIndex
			questItem = _G[questItemName..index]
			questItem.type = "reward"
			numItems = 1

			name, texture, numItems, quality, isUsable = GetQuestLogRewardInfo (i)

			questItem:SetID (i)
			questItem:Show()
			-- For the tooltip
			questItem.rewardType = "item"
			_G[questItemName..index.."Name"]:SetText(name)
			SetItemButtonCount (questItem, numItems)
			SetItemButtonTexture (questItem, texture)

			if isUsable then
				SetItemButtonTextureVertexColor (questItem, 1.0, 1.0, 1.0)
				SetItemButtonNameFrameVertexColor (questItem, 1.0, 1.0, 1.0)
			else
				SetItemButtonTextureVertexColor (questItem, 0.5, 0, 0)
				SetItemButtonNameFrameVertexColor (questItem, 1.0, 0, 0)
			end

			if i > 1 then

				if mod (i, 2) == 1 then
					questItem:SetPoint ("TOPLEFT", questItemName..(index - 2), "BOTTOMLEFT", 0, -2)
					QuestFrame_SetAsLastShown (questItem, spacerFrame)

				else
					questItem:SetPoint ("TOPLEFT", questItemName..(index - 1), "TOPRIGHT", 1, 0)
				end

			else
				questItem:SetPoint ("TOPLEFT", questState.."ItemReceiveText", "BOTTOMLEFT", 0, -5)
				QuestFrame_SetAsLastShown (questItem, spacerFrame)

			end

			rewardsCount = rewardsCount + 1
		end
	else
		questItemReceiveText:Hide()
	end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Quest watch
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Init and open
-------------------------------------------------------------------------------

function Nx.Quest.Watch:Open()
	self.GOpts = opts
	local qopts = Nx.Quest:GetQuestOpts()

	self.Watched = {}

	self.Opened = true

	local fixedSize = Nx.qdb.profile.QuestWatch.FixedSize

	-- Create window

--	Nx.Window:ClrSaveData ("NxQuestWatch")

	Nx.Window:SetCreateFade (1, .15)

	local border = fixedSize and false or 0

	local win = Nx.Window:Create ("NxQuestWatch", nil, nil, nil, 1, border)
	self.Win = win
	
	win:InitLayoutData (nil, -.80, -.35, -.2, -.1)

	win:CreateButtons (Nx.qdb.profile.QuestWatch.ShowClose, nil, true)
	
	win:SetUser (self, self.OnWin)
	win:SetBGAlpha (0, 1)
	win.Frm:SetClampedToScreen (true)

	local xo = 0
	local yo = 0

	if fixedSize then
		xo = 7
		yo = 3
		win:SetBorderSize (0, 7)
		win.Sizeable = false
	end

	win:SetTitleXOff (84 + xo, -1 - yo)

--	win:SetTitle ("[  ]")
	win.UserUpdateFade = self.WinUpdateFade

	-- Update helper. Can't call directly due to validation changing function

	local function update (self)
		self:Update()
	end

	-- Buttons

	local function func (self)
		self.Menu:Open()
	end
	self.ButMenu = Nx.Button:Create (win.Frm, "QuestWatchMenu", nil, nil, 4, -5 + yo, "TOPLEFT", 1, 1, func, self)

	local function func (self)
		self.MenuPri:Open()
	end
	self.ButPri = Nx.Button:Create (win.Frm, "QuestWatchPri", nil, nil, 19, -5 + yo, "TOPLEFT", 1, 1, func, self)
	local function func (self)
		Nx.Quest.AltView = not Nx.Quest.AltView
		Nx.Quest.Watch:UpdateList()
	end
	--self.ButSwap = Nx.Button:Create (win.Frm, "QuestWatchSwap", nil, nil, 34, -5 + yo, "TOPLEFT", 1, 1, func, self)

	local function func (self, but)
		local qopts = Nx.Quest:GetQuestOpts()
		qopts.NXWShowOnMap = but:GetPressed()
	end
	self.ButShowOnMap = Nx.Button:Create (self.ButMenu.Frm, "QuestWatchShowOnMap", nil, nil, 44, 0, "CENTER", 1, 1, func, self)
	self.ButShowOnMap:SetPressed (qopts.NXWShowOnMap)

	local function func (self, but)
		if not but:GetPressed() and not IsShiftKeyDown() then
			Nx.Quest.Tracking = {}	-- Kill all
		end
		self:Update()
	end
	self.ButATarget = Nx.Button:Create (self.ButMenu.Frm, "QuestWatchATrack", nil, nil, 56, 0, "CENTER", 1, 1, func, self)

	local function func (self, but)
		Nx.db.char.Map.ShowQuestGivers = but:GetState()
		local map = Nx.Map:GetMap (1)
		map.Guide:UpdateGatherFolders()
	end
	self.ButQGivers = Nx.Button:Create (self.ButMenu.Frm, "QuestWatchGivers", nil, nil, 68, 0, "CENTER", 1, 1, func, self)
	self.ButQGivers:SetState (Nx.db.char.Map.ShowQuestGivers)

	local function func (self, but)
		qopts.NXWWatchParty = but:GetPressed()
		Nx.Quest:PartyUpdateTimer()
	end
	self.ButShowParty = Nx.Button:Create (self.ButMenu.Frm, "QuestWatchParty", nil, nil, 80, 0, "CENTER", 1, 1, func, self)
	self.ButShowParty:SetPressed (qopts.NXWWatchParty == nil or qopts.NXWWatchParty)

	-- List

	Nx.List:SetCreateFont ("QuestWatch.WatchFont", 12)

	local list = Nx.List:Create (false, 2, -2, 100, 12 * 3, win.Frm, fixedSize, true)
	self.List = list

	list:SetUser (self, self.OnListEvent)
--	self:SetFont()

	if fixedSize then
		list:SetMinSize (124, 1)		-- Sets the window minimum
		list.Frm:EnableMouse (false)
	end

	list:ColumnAdd ("", 1, 14)
	list:ColumnAdd ("Name", 2, not fixedSize and 900 or 20)
--	list:ColumnAdd ("", 3, 0)
--	list:ColumnAdd ("Type", 4, 60)
--	list:ColumnAdd ("Status", 5, 500)

	win:Attach (list.Frm, 0, 1, 0, 1)

	-- Create menu button menu

	local qlist = Nx.Quest.List

	local menu = Nx.Menu:Create (list.Frm)
	self.Menu = menu

	menu:AddItem (0, L["Watch All Quests"], qlist.Menu_OnWatchAll, qlist)
	menu:AddItem (0, L["Remove All Watches"], self.Menu_OnRemoveAllWatches, self)

	menu:AddItem (0, L["Track None"], qlist.Menu_OnTrackNone, qlist)

--	local item = menu:AddItem (0, L["Max Auto Track"], update, self)
--	item:SetSlider (qopts, 1, 25, 1, "NXWAutoMax")

	local i = 20

	local item = menu:AddItem (0, L["Max Visible In List"], update, self)
	item:SetSlider (qopts, 1, i, 1, "NXWVisMax")

--	menu:AddItem (0, "")
	local function func()
		Nx.Quest.WQList.Win:Show()
	end
	--menu:AddItem (0, L["Open World Quest List"], func)
	
	local function func()
		Nx.Opts:Open ("Quest Watch")
	end

	menu:AddItem (0, L["Options..."], func)
	
	--local item = menu:AddItem (0, L["Hide BfA Emmissaries"], update, self)
	--item:SetChecked (qopts, "NXWHideBfAEmmissaries")
	
	--local item = menu:AddItem (0, L["Hide Legion Emmissaries"], update, self)
	--item:SetChecked (qopts, "NXWHideLegionEmmissaries")
	
	-- Create priority button menu

	local menu = Nx.Menu:Create (list.Frm, 300)
	self.MenuPri = menu

	local item = menu:AddItem (0, L["Hide Unfinished Quests"], update, self)
	item:SetChecked (qopts, "NXWHideUnfinished")

	local item = menu:AddItem (0, L["Hide 5+ Group Quests"], update, self)
	item:SetChecked (qopts, "NXWHideGroup")

	local item = menu:AddItem (0, L["Hide Quests Not In Zone"], update, self)
	item:SetChecked (qopts, "NXWHideNotInZone")

--	local item = menu:AddItem (0, L["Hide Quests Not On Continent"], update, self)
--	item:SetChecked (qopts, "NXWHideNotInCont")

	local item = menu:AddItem (0, L["Hide Quests Farther Than"], update, self)
	item:SetSlider (qopts, 200, 20000, 1, "NXWHideDist")

	local item = menu:AddItem (0, L["Sort, Distance"], update, self)
	item:SetSlider (qopts, 0, 1, nil, "NXWPriDist")

	local item = menu:AddItem (0, L["Sort, Complete"], update, self)
	item:SetSlider (qopts, -200, 200, 1, "NXWPriComplete")

	local item = menu:AddItem (0, L["Sort, Low Level"], update, self)
	item:SetSlider (qopts, -200, 200, 1, "NXWPriLevel")

	local function func()
		Nx.Map:GetMap (1).Guide:UpdateGatherFolders()
	end

	local item = menu:AddItem (0, L["Quest Giver Lower Levels To Show"], func, self)
	item:SetSlider (Nx.qdb.profile.Quest, 0, 60, 1, "MapQuestGiversLowLevel")

	local item = menu:AddItem (0, L["Quest Giver Higher Levels To Show"], func, self)
	item:SetSlider (Nx.qdb.profile.Quest, 0, 60, 1, "MapQuestGiversHighLevel")

--	local item = menu:AddItem (0, L["Group"], update, self)
--	item:SetSlider (qopts, -200, 200, 1, "NXWPriGroup")

	-- Create watch button menu

	local menu = Nx.Menu:Create (list.Frm)
	self.WatchMenu = menu

	menu:AddItem (0, L["Remove Watch"], self.Menu_OnRemoveWatch, self)
	menu:AddItem (0, L["Link Quest (shift right click)"], self.Menu_OnLinkQuest, self)
	menu:AddItem (0, L["Show Quest Log (alt right click)"], self.Menu_OnShowQuest, self)
	menu:AddItem (0, L["Show On Map (shift left click)"], self.Menu_OnShowMap, self)
	menu:AddItem (0, L["Share"], self.Menu_OnShare, self)

	menu:AddItem (0, "")
	menu:AddItem (0, L["Abandon"], self.Menu_OnAbandon, self)
	
	-- Create right clik menu

	--[[local menu = Nx.Menu:Create (list.Frm)
	self.RMenu = menu

	menu:AddItem (0, L["FindGroup"], function(self) 
		local data = self.List:ItemGetData()
		if data then
			local qId = bit.rshift (data, 16)
			if qId > 0 then
				local activityID, categoryID, filters, questName = LFGListUtil_GetQuestCategoryData(qId)
				if not activityID then
					categoryID = 6
					filters = 0
				end
				PVEFrame_ShowFrame("GroupFinderFrame", LFGListPVEStub)
				local panel = LFGListFrame.CategorySelection;
				LFGListCategorySelection_SelectCategory(panel, categoryID, filters)
				
				local baseFilters = panel:GetParent().baseFilters;
 
				local searchPanel = panel:GetParent().SearchPanel;
				LFGListSearchPanel_Clear(searchPanel);
				searchPanel.SearchBox.Instructions:SetText(questName or "");
				LFGListSearchPanel_SetCategory(searchPanel, panel.selectedCategory, panel.selectedFilters, baseFilters)
				LFGListFrame_SetActivePanel(panel:GetParent(), searchPanel);
			end
		end
	end, self)]]--
	
	--

	self.FirstUpdate = true
	self.FlashColor = 0

	--

	self:SetSortMode (1)
	
	win:SetMinimize (win.SaveData["Minimized"])
	if Nx.qdb.profile.QuestWatch.HideBlizz then
		--ObjectiveTrackerFrame:Hide()		-- Hide Blizzard's
	end
end

-------------------------------------------------------------------------------
-- Setup list font
-------------------------------------------------------------------------------

function Nx.Quest.Watch:FixedChange()

	Nx.Window:ClrSaveData ("NxQuestWatch")
end

-------------------------------------------------------------------------------

function Nx.Quest.Watch:OnWin (typ)
	self:Update()
end

-------------------------------------------------------------------------------

function Nx.Quest.Watch:Menu_OnRemoveWatch (item)

	self:RemoveWatch (self.MenuQId, self.MenuQIndex)
	self:Update()
	Nx.Quest.List:Update()
end

function Nx.Quest.Watch:Menu_OnShowQuest()

	ToggleQuestLog()
	--ShowUIPanel (QuestMapFrame)

	Nx.Quest.List.Bar:Select (1)
	Nx.Quest.List:Select (self.MenuQId, self.MenuQIndex)
end

function Nx.Quest.Watch:Menu_OnShowMap (item)

	self:Set (self.MenuItemData, true)
end

function Nx.Quest.Watch:Menu_OnLinkQuest()

	Nx.Quest:LinkChat (self.MenuQId)
end

function Nx.Quest.Watch:Menu_OnShare (item)

	local qi = self.MenuQIndex
	if qi > 0 then

		if GetNumSubgroupMembers() > 0 then
			Nx.Quest:ExpandQuests()
--			Nx.Quest.List:Select (self.MenuQId, self.MenuQIndex)
			QuestLogPushQuest (qi)
			Nx.Quest:RestoreExpandQuests()
		else
			Nx.prt (L["Must be in party to share"])
		end
	end
end

function Nx.Quest.Watch:Menu_OnAbandon (item)
	Nx.Quest.List:Select (self.MenuQId, self.MenuQIndex)
	Nx.Quest:Abandon (self.MenuQIndex, self.MenuQId)
end

function Nx.Quest.Watch:Menu_OnRemoveAllWatches (item)

	local curq = Nx.Quest.CurQ

	for n = 1, curq and #curq or 0 do

		local cur = curq[n]
		self:RemoveWatch (cur.QId, cur.QI)
	end

	self:Update()
	Nx.Quest.List:Update()
end

function Nx.Quest.Watch:RemoveWatch (qId, qI)

	local i, cur, id = Nx.Quest:FindCur (qId, qI)

	if i then

		local qStatus, qTime = Nx.Quest:GetQuest (id)
		if qStatus == "W" then

			Nx.Quest:SetQuest (id, "c", qTime)
			Nx.Quest:PartyStartSend()

			if qId > 0 then
				Nx.Quest.Tracking[qId] = nil

				if Nx.Quest:IsTargeted (qId) then
					Nx.Quest.Map:ClearTargets()
				end
			end
		end

		if IsQuestWatched (qI) then	-- Blizz crap? Remove
			RemoveQuestWatch (qI)
		end
	end
end

-------------------------------------------------------------------------------
-- Show or hide
-------------------------------------------------------------------------------

function Nx.NXWatchKeyToggleMini()

	local self = Nx.Quest.Watch
--	self.ButMini:SetPressed (not self.ButMini:GetPressed())

	self.Win:ToggleMinimize()
	self:Update()
end

function Nx.NXWatchKeyUseItem()

	if NxListFrms1 then
		NxListFrms1:Click()
	end
end

function Nx.Quest.Watch:ClearAutoTarget (keepTracking)

	if Nx.Quest.Enabled then

		if not keepTracking then
			Nx.Quest.Tracking = {}	-- Kill all
		end
		self.ButATarget:SetPressed (false)
		self:Update()
	end
end

-------------------------------------------------------------------------------
-- Set sort mode
-------------------------------------------------------------------------------

function Nx.Quest.Watch:SetSortMode (mode)
	QuestWatchUpdate = Nx:ScheduleTimer(self.OnUpdateTimer,.01,self)
end

function Nx.Quest.Watch:OnUpdateTimer (item)

	if not Nx:TimeLeft(QuestWatchDist) == 0 then
		self:Update()
		self.CalcDistCnt = 3
	end
	return 1.5
end

-------------------------------------------------------------------------------
-- Update list security stub
-------------------------------------------------------------------------------

local qw_elapsed = 0
local qw_lasttime
local qw_ttl = 9999

local function checkWatchTimer()
	if qw_lasttime then
		local curtime = debugprofilestop()
		qw_elapsed = curtime - qw_lasttime
		qw_lasttime = curtime
	else
		qw_lasttime = debugprofilestop()
	end
	qw_ttl = qw_ttl + qw_elapsed
	if qw_ttl < Nx.qdb.profile.QuestWatch.RefreshTimer then
		return false
	end
	qw_ttl = 0
	return true
end

local QuestWatchDistUp
function Nx.Quest.Watch:Update()
	self.CalcDistI = 1
	self.CalcDistCnt = 25
	
	if QuestWatchDistUp then
		Nx:CancelTimer(QuestWatchDistUp)
	end
	
	QuestWatchDistUp = Nx:ScheduleTimer(self.OnTimer, 0.5, self)
end

function Nx.Quest.Watch:ClearCustom ()
	Nx.Quest.Custom = {}
end

function Nx.Quest.Watch:AddCustom(newstring, newstring2, newstring3)
	local num = #Nx.Quest.Custom
	num = num + 1
	Nx.Quest.Custom[num] = {}
	Nx.Quest.Custom[num].str = newstring
	if newstring2 then
		Nx.Quest.Custom[num].buttontxt = newstring2
	end
	if newstring3 then
		Nx.Quest.Custom[num].buttonfunc = newstring3
	end
end

function Nx.Quest.Watch:OnTimer (item)

	local curq = Nx.Quest.CurQ
	if not curq then
		return
	end

	local i = self.CalcDistI
	local cnt = self.CalcDistCnt

	Nx.Quest:CalcDistances (i, i + cnt - 1)

	i = i + cnt

	if i <= #curq then
		self.CalcDistI = i
		QuestWatchDist = Nx:ScheduleTimer(self.OnTimer,.2,self)
		return
	end

	local watched = self:UpdateList()

--	Nx.Quest:Route (watched)
end

-------------------------------------------------------------------------------
-- Update watch list
-------------------------------------------------------------------------------

function Nx.Quest.Watch:UpdateList()
--	Nx.prt ("QWatchUpdate")
	
	local Nx = Nx
	local Quest = Nx.Quest
	local Map = Nx.Map
	local map = Map:GetMap(1)
	local qopts = Nx.Quest:GetQuestOpts()
	local hideBfAEmmissaries = qopts["NXWHideBfAEmmissaries"]
	local hideLegionEmmissaries = qopts["NXWHideLegionEmmissaries"]
	local hideUnfinished = qopts["NXWHideUnfinished"]
	local hideGroup = qopts["NXWHideGroup"]
	local hideNotInZone = qopts["NXWHideNotInZone"]
	local hideNotInCont = qopts["NXWHideNotInCont"]
	local hideDist = qopts["NXWHideDist"] >= 19900 and 99999 or qopts["NXWHideDist"]
	local hideDist = hideDist / 4.575		-- Convert to world units
	local priDist = qopts.NXWPriDist

	local gopts = self.GOpts

	local fixedSize = Nx.qdb.profile.QuestWatch.FixedSize
	local showDist = Nx.qdb.profile.QuestWatch.ShowDist
	local showPerColor = Nx.qdb.profile.QuestWatch.ShowPerColor
	local hideDoneObj = Nx.qdb.profile.QuestWatch.HideDoneObj

	local compColor = Nx.Quest.Cols["compColor"]
	local incompColor = Nx.Quest.Cols["incompColor"]
	local oCompColor = Nx.Quest.Cols["oCompColor"]
	local oIncompColor = Nx.Quest.Cols["oIncompColor"]

	-- List

	local list = self.List

	local oldw, oldh = list:GetSize()

	local clearlist = checkWatchTimer()

	if clearlist then
		list:SetBGColor (Nx.Quest.Cols["BGColorR"], Nx.Quest.Cols["BGColorG"], Nx.Quest.Cols["BGColorB"], Nx.Quest.Cols["BGColorA"])
		list:Empty()
	end
	local watched = wipe (self.Watched)
	local curq = Quest.CurQ

	if curq then

		for n, cur in ipairs (curq) do
			local qId = cur.QId
			local id = qId > 0 and qId or cur.Title
			local qStatus = Nx.Quest:GetQuest (id)
			local qWatched = qStatus == "W" or cur.PartyDesc

--			Nx.prt ("qid %s %s dist %s", qId, qStatus, cur.Distance)

			if qWatched and (cur.Distance < hideDist or cur.Distance > 999999) then

				if (not hideUnfinished or cur.CompleteMerge) and
					(not hideGroup or cur.PartySize < 5) and
					(not hideNotInZone or cur.InZone) and
					(not hideNotInCont or cur.InCont) then

					local d = max (cur.Distance * priDist * cur.Priority * 10 + cur.Priority * 100, 0)
					d = cur.HighPri and 0 or d
					d = floor (d) * 256 + n
					tinsert (watched, d)
				end
			end
		end

		sort (watched)
		local disti = watched[1]

		-- Auto target objective of closest quest

		if self.ButATarget:GetPressed() then
			if disti then
				local cur = curq[bit.band (disti, 0xff)]
				Quest:CalcAutoTrack (cur)
			end
		end

		-- Remember closest quest for com

		self.ClosestCur = disti and curq[bit.band (disti, 0xff)]

		--
		
		-- Emmissaries
		local emmFunc = function(id) 
			qId = bit.rshift(id, 16)
			bId = bit.band(id, 0xff)
			--WorldMapFrame.overlayFrames[3].SetSelectedBountyIndex(bId)		
		end
		
		local emmBfA_Sel = nil --WorldMapFrame.overlayFrames[3].selectedBountyIndex
		local emmLegion_Sel = nil --WorldMapFrame.overlayFrames[3].selectedBountyIndex
		
		local function AddObjectives(questID, numObjectives)
			for objectiveIndex = 1, numObjectives do
				local objectiveText, objectiveType, finished = GetQuestObjectiveInfo(questID, objectiveIndex, false);
				if objectiveText and #objectiveText > 0 then
					local color = finished and GRAY_FONT_COLOR or HIGHLIGHT_FONT_COLOR;
					GameTooltip:AddLine(QUEST_DASH .. objectiveText, color.r, color.g, color.b, true);
				end
			end
		end
		
		local function ScanTip(bounty)
			local tipVisible = GameTooltip:IsShown()
		
			local tipText = ""
			local questIndex = GetQuestLogIndexByID(bounty.questID);
			local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isStory = GetQuestLogTitle(questIndex);
		
			if title and not tipVisible then
				GameTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
				GameTooltip.ItemTooltip:Hide();
				
				GameTooltip:SetText(title, HIGHLIGHT_FONT_COLOR:GetRGB());
				WorldMap_AddQuestTimeToTooltip(bounty.questID);

				local _, questDescription = GetQuestLogQuestText(questIndex);
				GameTooltip:AddLine(questDescription, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);

				AddObjectives(bounty.questID, bounty.numObjectives);

				if bounty.turninRequirementText then
					GameTooltip:AddLine(bounty.turninRequirementText, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
				end

				GameTooltip_AddQuestRewardsToTooltip(GameTooltip, bounty.questID, TOOLTIP_QUEST_REWARDS_STYLE_EMISSARY_REWARD);

				for i=1,GameTooltip:NumLines() do
				  if i == 2 or i == 3 or string.find(_G["GameTooltipTextLeft"..i]:GetText(), "Rewards") then
					tipText = tipText .. format ("|cff%02x%02x%02x%s", NORMAL_FONT_COLOR.r * 255, NORMAL_FONT_COLOR.g * 255, NORMAL_FONT_COLOR.b * 255, _G["GameTooltipTextLeft"..i]:GetText()) .. "|r\n"				  
				  else
					if i == GameTooltip:NumLines() then
						local money = GetQuestLogRewardMoney(bounty.questID)
						if ( money > 0 ) then
							tipText = tipText .. GetCoinTextureString(money)		
						end
					end
					tipText = tipText .. _G["GameTooltipTextLeft"..i]:GetText() .. "\n"
				  end
				end
				for i=1,GameTooltipTooltip:NumLines() do
				  local tipTexture = GameTooltip.ItemTooltip.Icon:GetTexture()
				  local r, g, b = _G["GameTooltipTooltipTextLeft"..i]:GetTextColor()
				  tipText = tipText .. ((i == 1 and tipTexture) and "|T"..tipTexture..":33|t " or "\n") .. format ("|cff%02x%02x%02x%s", r * 255, g * 255, b * 255, _G["GameTooltipTooltipTextLeft"..i]:GetText()) .. "|r\n"
				end
			end
			if not tipVisible then GameTooltip:Hide() end
			
			return tipText
		end
		
		-- BfA
		if not hideBfAEmmissaries and #emmBfA > 0 then 
			list:ItemAdd(0)
			list:ItemSet(2,"|cff00ff00----[ |cffffff00" .. "BfA Emissaries" .. " |cff00ff00]----")
			
			for bountyIndex, bounty in ipairs(emmBfA) do
				local objectiveText, objectiveType, finished, numFulfilled, numRequired = GetQuestObjectiveInfo(bounty.questID, 1, false)
				if objectiveText then
					list:ItemAdd(bounty.questID * 0x10000 + bountyIndex)
					list:ItemSetOffset (16, -1)
					list:ItemSet(2,"|cffcccccc" .. objectiveText)
					list:ItemSetButtonTip(ScanTip(bounty))
					list:ItemSetButton("QuestWatchEmissaryTip", emmBfA_Sel == (bountyIndex) and true or false)
					list:ItemSetFunc(emmFunc, bounty.questID * 0x10000 + bountyIndex)
				end
			end
			
			if #emmLegion == 0 or hideLegionEmmissaries then
				list:ItemAdd(0)
				list:ItemSet(2,"|cff00ff00--------------------------------")
			end
		end	
		
		-- Legion
		if not hideLegionEmmissaries and #emmLegion > 0 then	
			list:ItemAdd(0)
			list:ItemSet(2,"|cff00ff00----[ |cffffff00" .. "Legion Emissaries" .. " |cff00ff00]----")
			
			for bountyIndex, bounty in ipairs(emmLegion) do
				local objectiveText, objectiveType, finished, numFulfilled, numRequired = GetQuestObjectiveInfo(bounty.questID, 1, false)
			
				if objectiveText then
					list:ItemAdd(bounty.questID * 0x10000 + bountyIndex)
					list:ItemSetOffset (16, -1)
					list:ItemSet(2,"|cffcccccc" .. objectiveText)
					list:ItemSetButtonTip(ScanTip(bounty))
					list:ItemSetButton("QuestWatchEmissaryTip",emmLegion_Sel == (bountyIndex) and true or false)
					list:ItemSetFunc(emmFunc, bounty.questID * 0x10000 + bountyIndex)
				end
			end
			
			list:ItemAdd(0)
			list:ItemSet(2,"|cff00ff00-------------------------------------")	
		end
		
		if not self.Win:IsSizeMin() and self.Win:IsVisible() then
			self.FlashColor = (self.FlashColor + 1) % 2
			list:SetItemFrameScaleAlpha (Nx.qdb.profile.QuestWatch.ItemScale, Nx.Util_str2a (Nx.qdb.profile.QuestWatch.ItemAlpha))
			if Nx.qdb.profile.QuestWatch.HideBlizz and not InCombatLockdown() then
				--ObjectiveTrackerFrame:Hide()		-- Hide Blizzard's
			end
			if Nx.Quest.AltView then
				local curnum = 1
				for a,b in pairs (Nx.Quest.Custom) do
					list:ItemAdd(curnum)
					list:ItemSet(2,Nx.Quest.Custom[a].str)
					if Nx.Quest.Custom[a].buttontxt then
						list:ItemSetButtonTip(Nx.Quest.Custom[a].buttontxt)
						list:ItemSetButton("QuestWatchCustomTip",false)
					end
					if Nx.Quest.Custom[a].buttonfunc then
						list:ItemSetFunc(Nx.Quest.Custom[a].buttonfunc)
					end
					curnum = curnum + 1
				end
			else
				if clearlist then
				if Nx.qdb.profile.QuestWatch.ChalTrack then
				  local cTimer = {} --{GetWorldElapsedTimers()}
					for a,id in ipairs(cTimer) do
					  local ProvingGroundsType, _, _, _ = C_Scenario.GetProvingGroundsInfo()
					  if ProvingGroundsType ~= 0 then
						id = 2
					  end
					  local description, elapsedTime, isChallengeModeTimer = GetWorldElapsedTime(id)
					  if isChallengeModeTimer == 2 then
						list:ItemAdd(0)
						list:ItemSet(2,format("|cffff8888%s",description))
						list:ItemSetButton("QuestWatch",false)
						local s = "  |cffffffff" .. SecondsToTime(elapsedTime)
						list:ItemAdd(0)
						list:ItemSet(2,s)
					  end
					  if isChallengeModeTimer == 3 then
						local difficulty, curWave, maxWave, duration = C_Scenario.GetProvingGroundsInfo()
						local diff = ""
						list:ItemAdd(0)
						if difficulty == 1 then
							diff = "|cffffffff" ..L["Difficulty: "] .."|cff8C7853" ..L["Bronze"]
						end
						if difficulty == 2 then
							diff = "|cffffffff" ..L["Difficulty: "] .."|cffC0C0C0" ..L["Silver"]
						end
						if difficulty == 3 then
							diff = "|cffffffff" ..L["Difficulty: "] .."|cffC77826" ..L["Gold"]
						end
						list:ItemSet(2,format("|cffff8888%s",diff))
						list:ItemSetButton("QuestWatch",false)
						local s = "  |cffff0000 " ..L["Wave: "] .."[|cffffffff" .. curWave .. "|cffff0000/|cffffffff" .. maxWave .. "|cffff0000]|cff00ff00 " .. SecondsToTime(duration-elapsedTime)
						list:ItemAdd(0)
						list:ItemSet(2,s)
					  end
					end
				end
				--[[if Nx.qdb.profile.QuestWatch.ScenTrack then
					local name, currentStage, numStages = C_Scenario.GetInfo()
					if (currentStage > 0) then
						local stageName, stageDescription, numCriteria = C_Scenario.GetStepInfo()
						list:ItemAdd(0)
						list:ItemSet(2,format("|cffff8888" ..L["Scenario: "] .."%s",name))
						list:ItemSetButtonTip(stageDescription)
						list:ItemSetButton("QuestWatch",false)
						if (currentStage <= numStages) then
							s = format(" |cffff0000" ..L["Stage "] .."[|cffffffff%d|cffff0000/|cffffffff%d|cffff0000]:|cff00ff00%s", currentStage, numStages,stageName)
						else
							s = " |cffff0000[|cffffffff" ..L["Complete"] .."|cffff0000]"
						end
						list:ItemAdd(0)
						list:ItemSet(2,s)
						for criteria = 1, numCriteria do
							local text, _, finished, quantity, totalquantity = C_Scenario.GetCriteriaInfo(criteria)
							if finished then
								s = format("|cffffffff%d/%d %s |cffff0000[|cffffffff" ..L["Complete"] .."|cffff0000]", quantity, totalquantity, text)
							else
								s = format("|cffffffff%d/%d %s", quantity, totalquantity, text and text or "")
							end
							list:ItemAdd(0)
							list:ItemSetOffset (16, -1)
							list:ItemSet(2,s)
							list:ItemSetButton("QuestWatch",false)
						end
						local bonusSteps = C_Scenario.GetBonusSteps() or {}
						if #bonusSteps >= 1 then
							local title, task, _, completed = C_Scenario.GetStepInfo(bonusSteps[1])
							local tasktexts = { "Bonus |cff00ff00" }
							task:gsub('%S+%s*', function(word)
								if (#tasktexts[#tasktexts] + #word) < (Nx.qdb.profile.QuestWatch.OMaxLen + 10) then
									tasktexts[#tasktexts] = tasktexts[#tasktexts] .. word
								else
									tasktexts[#tasktexts+1] = " |cff00ff00" .. word
								end
							end)
							tasktexts[1] = " |cffff0000" .. tasktexts[1]
							if completed then
								tasktexts[#tasktexts] = tasktexts[#tasktexts] .. " |cffff0000[|cffffffff" ..L["Complete"] .."|cffff0000]"
							end
							for i = 1, #tasktexts do
								list:ItemAdd(0)
								list:ItemSet(2, tasktexts[i])
							end
							for criteria = 1, #bonusSteps do
								local index = bonusSteps[criteria]
								local task, criteriatype, completed, quantity, totalquantity, flags, assetid, quantitystring, criteriaid, duration, elapsed, failed, weighted = C_Scenario.GetCriteriaInfoByStep(index,1)
								if completed then
									task = format("|cffffffff%d/%d %s |cffff0000[|cffffffff" ..L["Complete"] .."|cffff0000]",quantity, totalquantity, task)																
								elseif failed then
								    task = format("|cffffffff%d/%d %s |cffff0000[|cffffffff" .. L["Failed"] .. "|cffff0000]",quantity, totalquantity, task)
								else
									task = format("|cffffffff%d/%d %s",quantity, totalquantity, task)
								end
								list:ItemAdd(0)
								list:ItemSetOffset (16, -1)
								list:ItemSet(2,task)
								list:ItemSetButton("QuestWatch",false)
								if (duration > 0 and elapsed <= duration and not (completed or failed)) then
									list:ItemAdd(0)
									list:ItemSetOffset(16,-1)
									list:ItemSet(2, L["Time Left"] .. ": " .. Nx.Util_GetTimeElapsedMinSecStr(duration - elapsed))									
								end
							end
						end
					end
				end]]--
				local tasks = {}
				--[[if Nx.qdb.profile.QuestWatch.BonusTask then
					local taskInfo = C_TaskQuest.GetQuestsForPlayerByMapID(map.UpdateMapID);
					if taskInfo then
						for i=1,#taskInfo do
							local questId = taskInfo[i].questId;
							local inArea, onMap, numObjectives = GetTaskInfo(questId)
							tasks[questId] = true
							if inArea then
								local title, factionID = C_TaskQuest.GetQuestInfoByQuestID(questId)
								local tagID, tagName, worldQuestType, rarity, isElite, tradeskillLineIndex = GetQuestTagInfo(questId)
								local task_title = L["BONUS TASK"]
								if worldQuestType ~= nil then task_title = L["WORLD QUEST"] end
								list:ItemAdd(0)
								list:ItemSet(2,"|cffff00ff----[ |cffffff00" .. task_title .. " |cffff00ff]----")
								list:ItemAdd(questId * 0x10000 + 0)
								list:ItemSet(2,Nx.Util_str2colstr (Nx.qdb.profile.QuestWatch.OIncompleteColor) .. title)
								--local _,x,y = QuestPOIGetIconInfo(questId)
								--Nx.prt("====%s: %s, %s", title, x, y)
								if numObjectives and numObjectives > 0 then
									for j=1,numObjectives do
										local text, objectiveType, finished = GetQuestObjectiveInfo (questId, j, false)
										if objectiveType == "progressbar" then
											list:ItemAdd(0)
											list:ItemSetOffset (16, -1)
											local percent = GetQuestProgressBarPercent(questId) or 0
											if Nx.qdb.profile.QuestWatch.BonusBar then
												if (math.floor(percent) == 0) then
													list:ItemSet(2, "0%")
												else
													list:ItemSet(2, format(" |TInterface\\Addons\\Carbonite\\Gfx\\Skin\\InfoBarB:12:%d:|t %.2f%%", math.floor(percent), percent))
												end
											else
												list:ItemSet(2,format("|cff00ff00%s %.2f%%", L["Progress: "], percent))
											end
										else
											list:ItemAdd(0)
											list:ItemSetOffset (16, -1)
											list:ItemSet(2,"|cff00ff00" .. text)
										end
									end
								end
								list:ItemAdd(0)
								if worldQuestType ~= nil then
									list:ItemSet(2,"|cffff00ff------------------------------")
								else
									list:ItemSet(2,"|cffff00ff----------------------------")
								end
							end
						end
					end
					local taskInfo = GetNumQuestLogEntries()
					if taskInfo > 0 then
						for i=1,taskInfo do
							local title, _, _, _, _, _, _, questId, _, _, _, _, isTask, _ = GetQuestLogTitle(i)
							if isTask and tasks[questId] ~= true then
								local title, factionID = C_TaskQuest.GetQuestInfoByQuestID(questId)
								local tagID, tagName, worldQuestType, rarity, isElite, tradeskillLineIndex = GetQuestTagInfo(questId)
								local task_title = L["BONUS TASK"]
								if worldQuestType ~= nil then task_title = L["WORLD QUEST"] end
								list:ItemAdd(0)
								list:ItemSet(2,"|cffff00ff----[ |cffffff00" .. task_title .. " |cffff00ff]----")
								list:ItemAdd(0)
								list:ItemSet(2,Nx.Util_str2colstr (Nx.qdb.profile.QuestWatch.OIncompleteColor) .. (title or ""))
								local _,_, numObjectives = GetTaskInfo(questId)
								if numObjectives and numObjectives > 0 then
									for j=1,numObjectives do
										local text, objectiveType, finished = GetQuestObjectiveInfo (questId, j, false)
										if objectiveType == "progressbar" then
											list:ItemAdd(0)
											list:ItemSetOffset (16, -1)
											local percent = GetQuestProgressBarPercent(questId) or 0
											if Nx.qdb.profile.QuestWatch.BonusBar then
												if (math.floor(percent) == 0) then
													list:ItemSet(2, "0%")
												else
													list:ItemSet(2, format(" |TInterface\\Addons\\Carbonite\\Gfx\\Skin\\InfoBarB:12:%d:|t %.2f%%", math.floor(percent), percent))
												end
											else
												list:ItemSet(2,format("|cff00ff00%s %.2f%%", L["Progress: "], percent))
											end
										else
											list:ItemAdd(0)
											list:ItemSetOffset (16, -1)
											list:ItemSet(2,"|cff00ff00" .. text)
										end
									end
								end
								list:ItemAdd(0)
								list:ItemSet(2,"|cffff00ff-------------------------------")
							end
						end
					end
				end
				if Nx.qdb.profile.QuestWatch.AchTrack then
					local achs = Nx.Quest.TrackedAchievements
					for id, ach in pairs (achs) do
						local aId, aName, aPoints, aComplete, aMonth, aDay, aYear, aDesc, numC, aCriteria = unpack(ach)
						if aName then		-- Person had nil name happen
							list:ItemAdd (0)
							list:ItemSet (2, format ("|cffdf9fff" ..L["Achievement:"] .. " %s", aName))
							local progressCnt = 0
							local tip = aDesc
							for n = 1, numC do
								local cName, cType, cComplete, cQuantity, cReqQuantity, _, _, _, cQuantityString = unpack(aCriteria[n])
								local color = cComplete and "|cff80ff80" or "|cffa0a0a0"
								if not cComplete and cReqQuantity > 1 and cQuantity > 0 then
									progressCnt = progressCnt + 1
									tip = tip .. (cQuantityString and format ("\n%s%s: %s", color, cName, cQuantityString) or format ("\n%s%s: %s / %s", color, cName, cQuantity, cReqQuantity))
								else
									tip = tip .. format ("\n%s%s", color, cName)
								end
							end
							list:ItemSetButton ("QuestWatchTip", false)
							list:ItemSetButtonTip (tip)
							local showCnt = 0
							for n = 1, numC do
								local cName, cType, cComplete, cQuantity, cReqQuantity, _, _, _, cQuantityString = unpack(aCriteria[n])
								if not cComplete and (progressCnt <= 3 or cQuantity > 0) then
									list:ItemAdd (0)
									local s = "  |cffcfafcf"
									if numC == 1 then
										if cReqQuantity > 1 then
											s = s .. (cQuantityString or format ("%s/%s", cQuantity, cReqQuantity))
										else
											s = s .. cName
										end
									else
										s = s .. cName
										if cReqQuantity > 1 then
											s = s .. format (": %s/%s", cQuantity, cReqQuantity)
										end
									end
									showCnt = showCnt + 1
									if showCnt >= 3 then
										s = s .. "..."
									end
									list:ItemSet (2, s)
									if showCnt >= 3 then
										break
									end
								end
							end
						end
					end
				end

				local s = Nx.qdb.profile.QuestWatch.AchZoneShow and Nx.Map:GetZoneAchievement()
				if s then
					list:ItemAdd (0)
					list:ItemSet (2, s)
				end]]--

	--			Nx.prtVar ("Watched", watched)

				local watchNum = 1

				for _, distn in ipairs (watched) do

					local n = bit.band (distn, 0xff)

					local cur = curq[n]
					local qId = cur.QId
					--if not IsQuestTask(qId) then
					if true then
						if 1 then
							local level, isComplete = cur.Level, cur.CompleteMerge
							local quest = cur.Q
							local qi = cur.QI
							local lbNum = cur.LBCnt
--							local link, item, charges = GetQuestLogSpecialItemInfo (questIndex)
							list:ItemAdd (qId * 0x10000 + qi)
							local trackMode = Quest.Tracking[qId] or 0
							local obj = quest and (quest["End"] or quest["Start"])
							if qId == 0 then
								list:ItemSetButton ("QuestWatchErr", false)
							elseif isComplete or lbNum == 0 then
								local butType = "QuestWatch"
								local pressed = false
								if bit.band (trackMode, 1) > 0 then
									pressed = true
								end
								if Quest:IsTargeted (qId, 0) then
									butType = "QuestWatchTarget"
								end
								if obj then 
									local name, zone = Quest:GetSEPos (obj)
									if not zone or not zone then
										butType = "QuestWatchErr"
									end
								end
								if isComplete and cur.IsAutoComplete then
									butType = "QuestWatchAC"
									pressed = false
								end
								list:ItemSetButton (butType, pressed)	
							elseif not obj then
								list:ItemSetButton ("QuestWatchErr", false)
							else
								list:ItemSetButton ("QuestWatchTip", false)		-- QuestWatchTip  >  QuestWatch?
							end
							if cur.ItemLink and Nx.qdb.profile.QuestWatch.ItemScale >= 1 then
								_, _, _, _, _, _,_, _, _, cur.ItemImg, _ = GetItemInfo(Nx.QItems[qId])
								--print(cur.ItemLink, cur.ItemImg)
								list:ItemSetFrame ("WatchItem~" .. cur.QI .. "~" .. cur.ItemImg) -- .. "~" .. cur.ItemCharges
							end
							list:ItemSetButtonTip ((cur.ObjText or "?") .. (cur.PartyDesc or ""))
							local color = isComplete and compColor or incompColor
							local lvlStr = ""
							if level > 0 then
								local col = Quest:GetDifficultyColor (level)
								lvlStr = format ("|cff%02x%02x%02x%2d%s ", col.r * 255, col.g * 255, col.b * 255, level, cur.TagShort)
							end
							local nameStr = format ("%s%s%s", lvlStr, color, cur.Title)
							if cur.NewTime and time() < cur.NewTime + 60 then
								nameStr = format ("|cff00%2x00" ..L["New: "] .."%s", self.FlashColor * 200 + 55, nameStr)
							end
							if isComplete then
								local obj = quest and (quest["End"] or quest["Start"])
								if lbNum > 0 or not obj then
									nameStr = nameStr .. (isComplete == 1 and "|cff80ff80 " ..L["(Complete)"] or "|cfff04040 - " .. FAILED)
								else
									local desc = Quest:UnpackSE (obj)
									nameStr = format ("%s |cffffffff(%s)", nameStr, desc)
								end
							end
							if showDist then
								local d = cur.Distance * 4.575
								if d < 1000 then
									nameStr = format ("%s |cff808080%d " .. L["yds"], nameStr, d)
								elseif cur.Distance < 99999 then
									nameStr = format ("%s |cff808080%.1fK " .. L["yds"], nameStr, d / 1000)
								end
							end
							if cur.PartyCnt then
								nameStr = format ("%s |cffb0b0f0(+%s)", nameStr, cur.PartyCnt)
							end
							if cur.Party then
								nameStr = nameStr .. " |cffb0b0f0" .. cur.Party
							end
							list:ItemSet (2, nameStr)
							if cur.TimeExpire then	-- Have a timer?
								list:ItemAdd (0)
								list:ItemSet (2, format ("  |cfff06060%s %s", TIME_REMAINING, SecondsToTime (cur.TimeExpire - time())))
							end
							if isComplete and cur.IsAutoComplete then
								list:ItemAdd (0)
								list:ItemSet (2, format ("|cff%2x0000--- " ..L["Click ? to complete"] .." ---", self.FlashColor * 200 + 55))
							end
							if qi > 0 or cur.Party then
								local desc, done
								local zone, loc
								local lnOffset = -1
								for ln = 1, 31 do
									local obj = quest and quest["Objectives"]
									if obj then
										obj = quest and quest["Objectives"][ln]
									end
									if not obj and ln > lbNum then
										break
									end
									zone = nil
									done = isComplete
									if obj then
										desc, zone = Nx.Quest:UnpackObjectiveNew (obj[1])
									end
									if ln <= lbNum then
										desc = cur[ln]
										done = cur[ln + 300]
									end
									--Nx.prt("%s", desc);
									if not (hideDoneObj and done) then
										if showPerColor then
											if done then
												color = Quest.PerColors[9]
											else
												local s1, _, i, total = strfind (desc, "(%d+)/(%d+)")
												if s1 then
--													Nx.prt ("%s %s", i, total)
													i = floor (tonumber (i) / tonumber (total) * 8.99) + 1
												else
													i = 1
												end
												color = Quest.PerColors[i]
											end
										else
											color = done and oCompColor or oIncompColor
										end
										if Nx.qdb.profile.QuestWatch.OCntFirst then
											local s1, s2 = strmatch (desc, "(.+): (.+)")
											if s2 then
												desc = format ("%s: %s", s2, s1)
											end
										end
										local str = color .. (desc or "?")	--V4
										if not done then
											local d = cur["OD"..ln]
											if d and d < .5 then			-- Not in yards
												str = "*" .. str
											end
										end
										list:ItemAdd (qId * 0x10000 + ln * 0x100 + qi)
										list:ItemSetOffset (16, lnOffset)
										local butType = "QuestWatchErr"
										if zone then
											if zone then
												butType = "QuestWatch"
												if Quest:IsTargeted (qId, ln) then
													butType = "QuestWatchTarget"
												end
											end
										end
	--									Nx.prt ("watch %s %s %s", qId, zone or "nil", butType or "nil")
										if not done and butType then
											if bit.band (trackMode, bit.lshift (1, ln)) > 0 then
												list:ItemSetButton (butType, true)
											else
												list:ItemSetButton (butType, nil)
											end
										end
										if fixedSize then
											local maxCOpt = Nx.qdb.profile.QuestWatch.OMaxLen + 10
											local maxC = maxCOpt
											while #str > maxC do
												for cn = maxC, 12, -1 do
													if strbyte (str, cn) == 32 then		-- Find last space
														maxC = cn - 1
														break
													end
												end
												local s = strsub (str, 1, maxC)
												list:ItemSet (2, s)
												str = color .. strsub (str, maxC + 1)
												list:ItemAdd (qId * 0x10000 + ln * 0x100 + qi)
												list:ItemSetOffset (16, lnOffset)
												maxC = maxCOpt
											end
										end
										list:ItemSet (2, str)
										lnOffset = lnOffset - 1
									end
								end
							end
							if fixedSize and watchNum >= qopts.NXWVisMax then
								list:ItemAdd (0)
								list:ItemSet (2, " ...")
								break
							end
							watchNum = watchNum + 1
						end
					end
				end
			end
			end
		end
	end
	if not fixedSize then
		list:FullUpdate()
	else
		if clearlist then
			list:Update()
		end
	end

	-- Grow upwards

	if self.Win:IsSizeMin() then
		self.FirstUpdate = true
		self.Win:SetTitle ("")

	else

		local w, h = list:GetSize()

		if Nx.qdb.profile.QuestWatch.GrowUp and not self.FirstUpdate then

			h = h - oldh
--			Nx.prt ("h dif %s", h)
			self.Win:OffsetPos (0, h)
		end

		if w < 127 then
			self.Win:SetTitle ("")
		else
			local _, i = GetNumQuestLogEntries()
			self.Win:SetTitle (format ("          |cff40af40%d/20", i))
		end

		self.FirstUpdate = nil
	end

	return watched
end

-------------------------------------------------------------------------------

function Nx.Quest.Watch:ShowUpdate()
	self.Win.RaidHid = nil
	if Nx.qdb.profile.QuestWatch.HideRaid then
		if IsInRaid() then
			self.Win.Frm:Hide()
			self.Win.RaidHid = true
		else
			self.Win.Frm:Show()
		end
	end
end

-------------------------------------------------------------------------------
-- Called by Window update
-- Self = win
-------------------------------------------------------------------------------

function Nx.Quest.Watch:WinUpdateFade (fade, force)

	if Nx.qdb.profile.QuestWatch.FadeAll or force then

		self.Win:SetTitleColors (1, 1, 1, fade)
		self.List.Frm:SetAlpha (fade)

		self.ButMenu.Frm:SetAlpha (fade)
		self.ButPri.Frm:SetAlpha (fade)
		self.ButShowOnMap.Frm:SetAlpha (fade)
		self.ButATarget.Frm:SetAlpha (fade)
	end
end

-------------------------------------------------------------------------------
-- On list control updates
-------------------------------------------------------------------------------

function Nx.Quest.Watch:OnListEvent (eventName, val1, val2, click, but)

--	Nx.prt ("QuestListUpdate "..eventName)
	
	if eventName == "menu" and self.RMenu then	
		local data = self.List:ItemGetData (val1)
		if data then
			local qId = bit.rshift (data, 16)
			if qId and qId > 0 then
				self.RMenu:Open()
			end
		end
	end
	
	if eventName == "button" then

		local Quest = Nx.Quest
		-- val1 = id
		-- val2 = pressed

		local data = self.List:ItemGetData (val1)
		if data then
			local qIndex = bit.band (data, 0xff)
			local qId = bit.rshift (data, 16)
			local typ = but:GetType()
			if typ.CustomTip or typ.EmissaryTip then
				local func = self.List:ItemGetFunc(data)
				func(data)
				return
			end
			if click == "LeftButton" then

--				Nx.prt ("Data #%d, Id%d", qIndex, qId)
--				Nx.prt ("List but %s", but:GetType().WatchError or "nil")

				if typ.WatchError then
					Quest:MsgNotInDB ("O")
				else

					if IsAltKeyDown() then
						Quest.List:SendQuestInfo (qIndex)

					else

						if typ.WatchTip then
--[[
							local i, cur = Quest:FindCur (qId, qIndex)
							if cur.ItemLink then
								UseQuestLogSpecialItem (qIndex)
							end
--]]
							val2 = false	-- Can't turn on cause will track missing stuff
							self:Set (data, val2)
--[[
							local i, cur = Quest:FindCur (qId, qIndex)
							if i then

								for n = cur.LBCnt, 1, -1 do

									data = bit.band (data, 0xffff00ff) + n * 0x100

--									Nx.prtVar ("", data)
									self:Set (data, val2, not IsShiftKeyDown())
								end
							end
--]]
						else

							local i, cur = Quest:FindCur (qId, qIndex)
							if cur and cur.CompleteMerge and cur.IsAutoComplete then
--								Nx.prt ("ShowQuestComplete %s", qIndex)
								ShowQuestComplete (qIndex)

							else
								self:Set (data, val2, not IsShiftKeyDown())

							end

						end
					end
				end

			elseif click == "RightButton" then

				if typ.WatchTip then
					return
				end

				if IsAltKeyDown() then
					Quest.IgnoreAlt = true
					ToggleQuestLog()
					Quest.IgnoreAlt = nil
					Quest.List.Bar:Select (1)
					Quest.List:Select (qId, qIndex)

				elseif IsShiftKeyDown() then

					Quest:LinkChat (qId)

				else
					self.MenuItemData = data
					self.MenuQIndex = qIndex
					self.MenuQId = qId

					self.WatchMenu:Open()
				end
			end
		end
	end
end

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------

function Nx.Quest.Watch:Set (data, on, track)

	local Quest = Nx.Quest

	local qIndex = bit.band (data, 0xff)
	local qId = bit.rshift (data, 16)

	if qId > 0 then

		local i, cur = Quest:FindCur (qId, qIndex)

		if not (cur and cur.Q) then
			Quest:MsgNotInDB()
			return
		end

--		Nx.prt ("Q Set %s %s", i, cur and cur.Name or "nil")

		local q = cur.Q
		if not q["Start"] and not q["End"] then

			Quest:MsgNotInDB()
			return
		end

		self:ClearAutoTarget (true)

		-- 0 is quest name line
		local qObj = bit.band (bit.rshift (data, 8), 0xff)

		local tbits = Quest.Tracking[qId] or 0

		if track then

			Quest.Tracking = {}	-- Kill all
			tbits = 0

			if not Quest:IsTargeted (qId, qObj) then
				on = true	-- Force on if on but not tracked
			end
		end

		if IsControlKeyDown() then
			on = false		-- Force off
		end

		if qObj == 0 then

			if on == false then
				Quest.Tracking[qId] = nil
			else
				Quest.Tracking[qId] = cur.TrackMask		-- Track all
			end
		else

			if on == false then
				Quest.Tracking[qId] = bit.band (tbits, bit.bnot (bit.lshift (1, qObj)))
			else
				Quest.Tracking[qId] = bit.bor (tbits, bit.lshift (1, qObj))
			end
		end

		if track then
			self:ClearCompleted (qId)
		end

		Quest:TrackOnMap (qId, qObj, qIndex > 0, track)

		self:Update()
		Quest.List:Update()

	else
		Quest:MsgNotInDB()
	end

end

-------------------------------------------------------------------------------
-- Add quest to watch
-- (CurQ number)
-------------------------------------------------------------------------------

function Nx.Quest.Watch:Add (curi,addnew)

	local Quest = Nx.Quest
	local cur = Quest.CurQ[curi]

	local qId = cur.QId > 0 and cur.QId or cur.Title
	if Nx.Quest:IsDaily(qId) and addnew then
		Nx.Quest:SetQuest (qId, "W")
		Quest:PartyStartSend()
	end
	local qStatus = Nx.Quest:GetQuest (qId)
	if not qStatus ~= "W" then
		Nx.Quest:SetQuest (qId, "W")
		Quest:PartyStartSend()
	end
end

-------------------------------------------------------------------------------
-- Clear completed quests
-------------------------------------------------------------------------------

function Nx.Quest.Watch:ClearCompleted (qIdMatch)

	local Quest = Nx.Quest

	self:Update()	-- Get list in sync with quests if added or removed

	local list = self.List

	for ln = 1, list:ItemGetNum() do

		local i = list:ItemGetData (ln)
		if i then

			local qIndex = bit.band (i, 0xff)
			local qId = bit.rshift (i, 16)

			if qId > 0 and (not qIdMatch or qIdMatch == qId) then

				local _, cur = Quest:FindCur (qId)
				if cur then

					local qComplete = cur.CompleteMerge	-- Remember for objectives
					local qObj = bit.band (bit.rshift (i, 8), 0xff)

--					Nx.prt ("Data #%d Id %d Obj %d C=%s", qIndex, qId, qObj, tostring (cur.CompleteMerge))

					local tbits = Quest.Tracking[qId] or 0

					if tbits > 0 then
						local objmask = bit.lshift (1, qObj)

						if qObj == 0 then
							if qComplete then

								local qStatus, qTime = Nx.Quest:GetQuest (qId)

								if qStatus ~= "C" then
--									Nx.prt ("track on")
									-- Turn on

									if Nx.Quest:IsTargeted (qId) then
										Quest.Tracking[qId] = bit.bor (tbits, objmask)
										Quest:TrackOnMap (qId, 0, qIndex > 0, true)
									end
								end
							end

						else
							local desc
							local done = qComplete
							local num = cur.LBCnt

							if qObj <= num then
								desc = cur[qObj]
								done = cur[qObj + 300]
							end

							if done then

								local on = bit.band (tbits, objmask)

								if on > 0 then
									-- Turn off
									Quest.Tracking[qId] = bit.band (tbits, bit.bnot (objmask))
									Quest:TrackOnMap (qId, qObj, qIndex > 0)
								end
							end
						end
					end
				end
			end
		end
	end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

function Nx.Quest:CreateGiverIconMenu (mainMenu, frm)
	local completedMenu = Nx.Menu:Create (frm)
	self.GiverIconMenuCompleted = completedMenu
	self.GiverIconMenuICompleted = mainMenu:AddSubMenu (completedMenu, L["Quest Completion..."])

	self.GiverIconMenuICompletedT = {}

	for n = 1, 29 do

		local function func (self, item)

			local s = item:GetChecked() and "C" or "c"
			Nx.Quest:SetQuest (item.UData, s, time())

			if item:GetChecked() then
				self:CalcPreviousDone (item.UData)
			end

			self:UpdateGiverIconMenu()
			self.GiverIconMenuCompleted:Update()

			local map = Nx.Map:GetMap (1)
			map.Guide:UpdateMapIcons()
		end

		self.GiverIconMenuICompletedT[n] = completedMenu:AddItem (0, "?", func, self)
		self.GiverIconMenuICompletedT[n]:SetChecked()
	end

	--

	local infoMenu = Nx.Menu:Create (frm)
	self.GiverIconMenuInfo = infoMenu
	self.GiverIconMenuIInfo = mainMenu:AddSubMenu (infoMenu, L["Quest Info (shift click - goto)..."])

	self.GiverIconMenuIInfoT = {}

	for n = 1, 29 do

		local function func (self, item)
--			Nx.prt ("%s", item.Text)

			if not IsShiftKeyDown() then
				local link = self:CreateLink (item.UData, -1, "x")
				SetItemRef (link)
			else

				self:Goto (item.UData)
			end
		end

		self.GiverIconMenuIInfoT[n] = infoMenu:AddItem (0, "?", func, self)
	end
end

function Nx.Quest:OpenGiverIconMenu (icon, typ)
	self.GiverIconMenuICompleted:Show (false)
	self.GiverIconMenuIInfo:Show (false)

	if typ ~= 3000 then
		return
	end

	self.GiverIconMenuCompleted:Show (false)
	self.GiverIconMenuInfo:Show (false)

	if icon.UDataQuestGiverD then
		self.GiverIconMenuICompleted:Show()
		self.GiverIconMenuIInfo:Show()

		self.GiverIconMenuCompletedD = icon.UDataQuestGiverD

		self:UpdateGiverIconMenu()
	end
end

function Nx.Quest:UpdateGiverIconMenu()

	local qdata = self.GiverIconMenuCompletedD

	local qIds = self.QIds
	local curI = 1

	for n = 1, #qdata, 4 do
		local qId = tonumber (strsub (qdata, n, n + 3), 16)

		local quest = Nx.Quests[qId]
		local qname, _, lvl, minlvl = self:Unpack (quest["Quest"])

		local col = ""

		local status, qTime = Nx.Quest:GetQuest (qId)
		if status == "C" then
			col = "|cff808080"
		else
			if qIds[qId] then
				col = "|cffa0f0a0"
			end
		end

		local s = format ("%s%d %s", col, lvl, qname)

--		Nx.prt ("Menu %s", s)

		local menuI = self.GiverIconMenuICompletedT[curI]
		if not menuI then
			break
		end

		menuI:Show()
		menuI:SetText (s)
		menuI.UData = qId
		menuI:SetChecked (status == "C")

		local menuI = self.GiverIconMenuIInfoT[curI]

		menuI:Show()
		menuI:SetText (s)
		menuI.UData = qId

		curI = curI + 1
	end
end

-------------------------------------------------------------------------------
-- Track quest on map
-------------------------------------------------------------------------------

function Nx.Quest:CalcAutoTrack (cur)

	local Nx = Nx
	local Quest = Nx.Quest
	local curq = Quest.CurQ
	local qopts = Nx.Quest:GetQuestOpts()

	Quest.Tracking = {}
	local closest = false
	local dist = 99999999

	if cur.Q then

--		Quest.Tracking[cur.QId] = cur.TrackMask

		local closeI = cur.CloseObjI
		if closeI and closeI >= 0 then

			Quest.Tracking[cur.QId] = cur.TrackMask			-- bit.lshift (1, closeI)
			Quest:TrackOnMap (cur.QId, closeI, cur.QI > 0 or cur.Party, true, true)
		end

		for objn = 1, 15 do

			local obj = cur.Q[objn + 3]
			if not obj then
				break
			end

			local obit = bit.lshift (1, objn)
			if bit.band (cur.TrackMask, obit) > 0 then

				if Quest:GetObjectiveType (obj) == 1 then

					local d = cur["OD"..objn]

					if d and d < dist then
						dist = d
						closest = cur
--						Quest.ClosestSpanI = objn
					end
				end
			end
		end
	end

--	Quest.ClosestSpanCur = closest
end

-------------------------------------------------------------------------------
-- Is targeted already?
-------------------------------------------------------------------------------

function Nx.Quest:IsTargeted (qId, qObj, x1, y1, x2, y2)

	local typ, tid = Nx.Map:GetTargetInfo()
	if typ == "Q" then

		local tqid = floor (tid / 100)
		if tqid == qId then		-- Same as us?

			if x1 then
				local tx1, ty1, tx2, ty2 = Nx.Map:GetTargetPos()
				if x1 ~= tx1 or y1 ~= ty1 or x2 ~= tx2 or y2 ~= ty2 then
					return
				end
			end

			if not qObj then
				return true
			end

			if tid % 100 == qObj then
				return true
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Track quest on map
-------------------------------------------------------------------------------

function Nx.Quest:TrackOnMap (qId, qObj, useEnd, target, skipSame)

	local Quest = Nx.Quest
	local Map = Nx.Map
	local BlizIndex = nil
	local quest = Nx.Quests[qId]

	if Nx.qdb.profile.QuestWatch.Sync then
		local i = 1
		while GetQuestLogTitle(i) do
			local _, _, _, _, _, _, _, questID = GetQuestLogTitle(i)
			if questID == qId then
				BlizIndex = i
			else
				if (IsQuestWatched(i)) then
					RemoveQuestWatch(i)
				end
			end
		i = i + 1
		end
	end
	if quest then

		local tbits = Quest.Tracking[qId] or 0
--[[
		if tbits == 0 then	-- Nothing tracked?

			local typ, tid = Map:GetTargetInfo()
			if typ == "Q" then

				local tqid = floor (tid / 100)
				if tqid == qId then		-- Same as us?
					self.Map:ClearTargets()
				end
			end
			return
		end
--]]
		local track = bit.band (tbits, bit.lshift (1, qObj))

		local questObj
		local name, zone, loc

		if qObj == 0 then
			questObj = useEnd and quest["End"] or quest["Start"]
			name, zone, loc = Quest:UnpackSE (questObj)
		else
			if quest["Objectives"] ~= nil then
				questObj = quest["Objectives"][qObj]
				if questObj and questObj[1] then
					name, zone, loc = Nx.Quest:UnpackObjectiveNew (questObj[1])
				end
			end
		end

--		Nx.prt ("TrackOnMap %s %s %s %s %s", qId, qObj, track, name, zone)

		if track > 0 and zone then
			if Nx.qdb.profile.QuestWatch.Sync then
				if BlizIndex then
					if not (IsQuestWatched(BlizIndex)) then
						AddQuestWatch(BlizIndex)
					end
				end
			end
	local QMap = NxMap1.NxMap
	if not InCombatLockdown() then
		local cur = self.QIds[qId]
		if cur then
			if not cur.Complete then
				--[[QMap.QuestWin:DrawNone();
				if Nx.db.char.Map.ShowQuestBlobs and Nx.Quests[-qId] then
					QMap.QuestWin:DrawBlob(qId,true)
					QMap:ClipZoneFrm( QMap.Cont, QMap.Zone, QMap.QuestWin, 1 )
					QMap.QuestWin:SetFrameLevel(QMap.Level)
					QMap.QuestWin:SetFillAlpha(255 * QMap.QuestAlpha)
					QMap.QuestWin:SetBorderAlpha( 255 * QMap.QuestAlpha )
					QMap.QuestWin:Show()
				else
					QMap.QuestWin:Hide()
				end]]--
			end
		end
	end

			local mId = zone
			if mId then

				if target then

					local x1, y1, x2, y2

					if qObj > 0 then

						local map = Map:GetMap (1)
						local px = map.PlyrX
						local py = map.PlyrY

						-- FIX!!!!!!!!!!!!

--						x1, y1, x2, y2 = Quest:GetClosestObjectiveRect (questObj, mId, px, py)
						x1, y1 = Quest:GetClosestObjectivePos (questObj, loc, mId, px, py)
						x2 = x1
						y2 = y1
					else

						x1, y1, x2, y2 = Quest:GetObjectiveRect (questObj, loc)
						x1, y1 = Map:GetWorldPos (mId, x1, y1)
						x2, y2 = Map:GetWorldPos (mId, x2, y2)
					end

					local cur = self.QIds[qId]
--					local _, cur = self:FindCur (qId)
					if cur then
						if qObj > 0 then
							name = cur[qObj] or name
--							Nx.prt ("TrackOnMap name %s", name)
						end

						if cur.Complete then
							name = name .. " |cff80ff80" ..L["(Complete)"]
						end
					end

					if skipSame then
						if self:IsTargeted (qId, qObj, x1, y1, x2, y2) then

							Map:SetTargetName (name)
							return
						end
					end

					self.Map:SetTarget ("Q", x1, y1, x2, y2, false, qId * 100 + qObj, name, false, mId)
--					Nx.prt ("TrackOnMap %s %s %s", qId, qObj, name)

					self.Map.Guide:ClearAll()
				end

				self.Map:GotoPlayer()

			else
				Nx.Quest:MsgNotInDB ("Z")
--				Nx.prt ("quest zone %s", zone)
			end

		else	-- Clear tracking

			local typ, tid = Map:GetTargetInfo()
			if typ == "Q" then

				local tqid = floor (tid / 100)
				if tqid == qId then		-- Same quest as us?

					if tbits == 0 or (tid == qId * 100 + qObj) then
						if Nx.qdb.profile.QuestWatch.Sync then
							RemoveQuestWatch(BlizIndex)
						end
						self.Map:ClearTargets()
						if not InCombatLockdown() then
							--[[local QMap = NxMap1.NxMap
							QMap.QuestWin:DrawNone();
							QMap.QuestWin:Hide()]]--
						end
					end
				end
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Unpack quest info
-- Format: (b) is byte
--  name len (b), name str, side (b), level (b), min lvl (b), next id (b3), category (b)
-------------------------------------------------------------------------------

function Nx.Quest:Unpack (info)
	if not info then return end
	local name, side, lvl, minlvl, nextId, category, xp = Nx.Split("|",info)
	return name, tonumber(side), tonumber(lvl), tonumber(minlvl), tonumber(nextId), tonumber(category), tonumber(xp)
end

-------------------------------------------------------------------------------
-- Unpack quest name
-------------------------------------------------------------------------------

function Nx.Quest:UnpackName (info)
	local name, side, lvl, minlvl, nextId, category = Nx.Split("|",info)
	return name
end

-------------------------------------------------------------------------------
-- Unpack quest next id
-------------------------------------------------------------------------------

function Nx.Quest:UnpackNext (info)
	local name, side, lvl, minlvl, nextId, category = Nx.Split("|",info)
	return tonumber(nextId)
end

-------------------------------------------------------------------------------
-- Unpack quest category
-------------------------------------------------------------------------------

function Nx.Quest:UnpackCategory (info)
	local name, side, lvl, minlvl, nextId, category = Nx.Split("|",info)
	return tonumber(category)
end

-------------------------------------------------------------------------------
-- Unpack start/end
-- Format: name index (byte x2), zone (byte), location data (may start with space)
-- Example: 00,1, xxyy
-- Example: 00,1,xywh
-------------------------------------------------------------------------------

function Nx.Quest:UnpackSE (obj)
	if not obj then
		return
	end

	local i, zone, typ, x, y = Nx.Split("|",obj)
	local name = Nx.QuestStartEnd[tonumber(i)]

	if not name then
--		Nx.prt ("UnpackSE err %s (%s)", i, obj)
		name = "?"
	end

	if #obj == 2 then
		return name
	end
	return name, tonumber(zone), tonumber(typ), tonumber(x), tonumber(y)
end

-------------------------------------------------------------------------------
-- Unpack objective or start/end
-- Format: name length (byte), name string, zone (byte), location data (may start with space)
-- Example: 3,the,1, xxyy
-- Example: 3,end,1,xywh
-------------------------------------------------------------------------------

function Nx.Quest:UnpackObjective (obj)

	if not obj then
		return
	end
	local desc, zone = Nx.Split("|",obj)
	return desc, tonumber(zone)
end

-------------------------------------------------------------------------------
-- Get type of objective (not start/end)
-------------------------------------------------------------------------------

function Nx.Quest:GetObjectiveType (obj)

	local desc, zone, typ = Nx.Split("|",obj)
	typ = tonumber(typ)
	if typ <= 33 then  -- Points
		return 0
	end

	return 1		-- Spans
end

-------------------------------------------------------------------------------
-- Get centered position of start/end
-------------------------------------------------------------------------------

function Nx.Quest:GetSEPos (str)

	local name, zone, typ, x, y = self:UnpackSE (str)

	if zone then
		return name, tonumber(zone), self:GetPosLoc (str)		-- x, y
	end
end

-------------------------------------------------------------------------------
-- Get centered position of objective
-------------------------------------------------------------------------------

function Nx.Quest:GetObjectivePos (str)

	local name, zone, typ, x, y = self:UnpackObjective (str)

	if zone then
		return name, tonumber(zone), self:GetPosLoc (str)		-- x, y
	end
end

-------------------------------------------------------------------------------
-- Get centered position from location string
-------------------------------------------------------------------------------

function Nx.Quest:GetPosLoc (str)

	local cnt = 0
	local ox = 0
	local oy = 0

	if type(str) == "table" then
		for i = 1,32 do
			if str[i] then
				local desc, zone, typ, x, y, w, h = Nx.Split("|",str[i])
				if tonumber(typ) == 32 then
					cnt = i
					ox = ox + tonumber(x)
					oy = oy + tonumber(y)
				elseif tonumber(typ) == 33 then
					cnt = 1
					ox, oy = self:UnpackLocPtRelative (str, loc + 1)
				else
					w = tonumber(w) / 1002 * 100
					h = tonumber(h) / 668 * 100
					local area = w * h
					cnt = cnt + area
					ox = ox + (tonumber(x) + w * .5) * area
					oy = oy + (tonumber(y) + h * .5) * area
				end
			end
		end
	elseif type(str) == "string" then
		local desc, zone, typ, x, y, w, h = Nx.Split("|",str)
		if tonumber(typ) == 32 then
			cnt = 1
			ox = ox + tonumber(x)
			oy = oy + tonumber(y)
		elseif tonumber(typ) == 33 then
			cnt = 1
			ox, oy = self:UnpackLocPtRelative (str, loc + 1)
		else
			w = tonumber(w) / 1002 * 100
			h = tonumber(h) / 668 * 100
			local area = w * h
			cnt = cnt + area
			ox = ox + (tonumber(x) + w * .5) * area
			oy = oy + (tonumber(y) + h * .5) * area
		end
	end

	ox = ox / cnt
	oy = oy / cnt
	return ox, oy
end

-------------------------------------------------------------------------------
-- Calc watch distance
-------------------------------------------------------------------------------

function Nx.Quest:CalcDistances (n1, n2)

	local Nx = Nx
	local Quest = Nx.Quest
	local qopts = Nx.Quest:GetQuestOpts()
	local Map = Nx.Map
	local map = Map:GetMap (1)
	local px = map.PlyrX
	local py = map.PlyrY
	local playerLevel = UnitLevel ("player")

	local curq = self.CurQ
	if not curq then	-- Bad stuff?
		return
	end

	for n = n1, n2 do

		local cur = curq[n]

		if not cur then
			break
		end

		local qi = cur.QI
		local qId = cur.QId

		local id = qId > 0 and qId or cur.Title
		local qStatus = Nx.Quest:GetQuest (id)
		local qWatched = (qStatus == "W")
		local quest = cur.Q

		cur.Priority = 1
		cur.Distance = 999999999
		cur.CloseObjI = -1

		if cur.Complete and cur.IsAutoComplete then
			cur.Distance = 0
		end

--		if quest and (qWatched or Nx.Free) then
		if quest then

			local cnt = (cur.CompleteMerge or cur.LBCnt == 0) and 0 or 99
			for qObj = 0, cnt do

				local questObj

				if qObj == 0 then
					questObj = (qi > 0 or cur.Party) and quest["End"] or quest["Start"]	-- Start if goto or no end?
				else
					if quest["Objectives"] then
						questObj = quest["Objectives"][qObj]
					end
				end

				if not questObj then
					break
				end

				if bit.band (cur.TrackMask, bit.lshift (1, qObj)) > 0 then

					local _, zone, loc

					if qObj == 0 then
						_, zone, loc = self:UnpackSE (questObj)
					else
						if (type (questObj) == "table") then
							_, zone = self:UnpackObjective (questObj[1])
						else
							_, zone = self:UnpackObjective (questObj)
						end
					end

					if zone then

						local mId = zone
						if mId and mId ~= 9000 then
							local x, y = self:GetClosestObjectivePos (questObj, loc, mId, px, py)
							if not x or not y then
								return
							end
							local dist = ((x - px) ^ 2 + (y - py) ^ 2) ^ .5

							if dist < cur.Distance then
								cur.CloseObjI = qObj
								cur.Distance = dist
							end
							cur["OX"..qObj] = x
							cur["OY"..qObj] = y
							cur["OD"..qObj] = dist
						end
					end
				end
			end

--PAIDS!
			local pri = 0

			-- Player lvl 30. PriLevel = 20
			-- Q1  100 Lvl 30: 0 ldif = 0
			-- Q2  400 Lvl 20: 10 ldif = 200, .1, 90% = 360
			-- Q3 2000 Lvl 25: 5 ldif = 100, .05, 95% = 1900

			-- Player lvl 30. PriLevel = 200
			-- Q1  100 Lvl 30: 0 ldif = 0
			-- Q2  400 Lvl 20: 10 ldif = 2000, .99, 1% = 4
			-- Q3 2000 Lvl 25: 5 ldif = 1000, .5, 50% = 1000

			-- Formula: cur.Distance * priDist * cur.Priority * 10 + cur.Priority * 100

			if cur.CompleteMerge then
				pri = qopts.NXWPriComplete * 8	-- +-1600

			else
				-- 20 default. 10 lvls max diff * 200 = +-2000
				local l = min (playerLevel - cur.Level, 10)
				l = max (l, -10)
				pri = l * qopts.NXWPriLevel
			end

			cur.Priority = 1 - pri / 2010

			cur.InZone = Quest:CheckShow (map.UpdateMapID, qId)
--PAIDE!
		end
	end
end

-------------------------------------------------------------------------------
-- Get closest position of objective or start/end
-------------------------------------------------------------------------------

function Nx.Quest:GetClosestObjectivePos (str, loc, mapId, px, py)
	local Map = Nx.Map
	if type(str) == "string" then
		local npc, zone, typ = Nx.Split("|",str)
		if tonumber(typ) <= 33 then  -- Point
			local x1, y1, x2, y2 = self:GetObjectiveRect (str, loc)
			x1, y1 = Map:GetWorldPos (mapId, (x1 + x2) / 2, (y1 + y2) / 2)
			return x1, y1
		else -- Multiple locations
			local closeDist = 999999999
			local closeX, closeY
			loc = loc - 1
			local loopCnt = floor ((#str - loc) / 4)
			cnt = 0
			for locN = loc + 1, loc + loopCnt * 4, 4 do
				local x, y
				local loc1 = strsub (str, locN, locN + 3)
				assert (loc1 ~= "")
				local x, y, w, h = Nx.Quest:UnpackLocRect (loc1)
				w = w / 1002 * 100
				h = h / 668 * 100
				local wx1, wy1 = Map:GetWorldPos (mapId, x, y)
				local wx2, wy2 = Map:GetWorldPos (mapId, x + w, y + h)
				x = wx1		-- Top left
				y = wy1
				if px >= wx1 and px <= wx2 then
					if py >= wy1 and py <= wy2 then		-- Within span?
						return px, py
					end
					x = px
				elseif px >= wx2 then	-- Right of span?
					x = wx2
				end
				if py >= wy1 then		-- Y within span?
					y = py
				end
				if py >= wy2 then	-- Below span?
					y = wy2
				end
				local dist = (x - px) ^ 2 + (y - py) ^ 2
				if dist < closeDist then
					closeDist = dist
					closeX = x
					closeY = y
				end
			end
			return closeX, closeY
		end
	elseif type(str) == "table" then
		local closeDist = 999999999
		local closeX, closeY
		cnt = 0
		for a,b in pairs(str) do
			local npc,zone,typ,x, y, w, h = Nx.Split ("|",b)
			w = w / 1002 * 100
			h = h / 668 * 100
			local wx1, wy1 = Map:GetWorldPos (mapId, x, y)
			local wx2, wy2 = Map:GetWorldPos (mapId, x + w, y + h)
			x = wx1		-- Top left
			y = wy1
			if px >= wx1 and px <= wx2 then
				if py >= wy1 and py <= wy2 then		-- Within span?
					return px, py
				end
				x = px
			elseif px >= wx2 then	-- Right of span?
				x = wx2
			end
			if py >= wy1 then		-- Y within span?
				y = py
			end
			if py >= wy2 then	-- Below span?
				y = wy2
			end
			local dist = (x - px) ^ 2 + (y - py) ^ 2
			if dist < closeDist then
				closeDist = dist
				closeX = x
				closeY = y
			end
		end
		return closeX, closeY
	end
end

-------------------------------------------------------------------------------
-- Get size of objective or start/end
-------------------------------------------------------------------------------

function Nx.Quest:GetObjectiveRect (str, loc)

	local Quest = Nx.Quest

	local x1 = 100
	local y1 = 100
	local x2 = 0
	local y2 = 0
	local cnt

	if type(str) == "string" then
		local desc,zone,typ,x,y,w,h = Nx.Split("|",str)
		if tonumber(typ) == 32 then
		  x1 = min (x1, x)
		  x2 = max (x2, x)
		  y1 = min (y1, y)
		  y2 = max (y2, y)
		end
	else
		if tonumber(typ) == 32 then  -- Point
		cnt = 0
		local x, y
		for locN = loc + 1, loc + cnt * 4, 4 do

--			local loc1 = strsub (str, locN, locN + 3)
--			assert (loc1 ~= "")

			x, y = Nx.Map:UnpackLocPtOff (str, locN)
			x1 = min (x1, x)
			y1 = min (y1, y)
			x2 = max (x2, x)
			y2 = max (y2, y)
		end

	elseif strbyte (str, loc) == 33 then  -- Point

		x1, y1 = Nx.Map:UnpackLocPtRelative (str, loc + 1)
		x2, y2 = x1, y1

	else -- Multiple locations

		loc = loc - 1

		cnt = floor ((#str - loc) / 4)

		for locN = loc + 1, loc + cnt * 4, 4 do

			local loc1 = strsub (str, locN, locN + 3)
--			assert (loc1 ~= "")

			local x, y, w, h = Nx.Quest:UnpackLocRect (loc1)

			x1 = min (x1, x)
			y1 = min (y1, y)
			x2 = max (x2, x + w / 1002 * 100)
			y2 = max (y2, y + h / 668 * 100)

--			Nx.prt ("Rect %f %f %f %f", x, y, w, h)
		end
	end

--	Nx.prt ("RectMinMax %f %f %f %f", x1, y1, x2, y2)
	end
	return x1, y1, x2, y2
end

-------------------------------------------------------------------------------
-- Calculate first level 24 bit quest hash
-------------------------------------------------------------------------------

--[[
function Nx.Quest:Hash (title, level)

	local str = title..level
	local h1 = 0
	local h2 = 0
	local h3 = 0
	local b1
	local b2
	local b3

	local strLen = #str
	local len = floor (strLen / 3) * 3

--	Nx.prt (format ("Hash %d %d"))

	for n = 1, len, 3 do

		b1, b2, b3 = strbyte (str, n, n + 2)
		h1 = h1 + b1
		h2 = h2 + b2
		h3 = h3 + b3
	end

	if strLen - len == 1 then
		h1 = h1 + strbyte (str, strLen)

	elseif strLen - len == 2 then
		h1 = h1 + strbyte (str, strLen - 1)
		h2 = h2 + strbyte (str, strLen)
	end

	return bit.band (h1, 0xff) + bit.band (h2, 0xff) * 0x100 + bit.band (h3, 0xff) * 0x10000
end
--]]

-------------------------------------------------------------------------------
-- Find quest in quests data from Blizzard title, level, description and objective
-------------------------------------------------------------------------------

--[[
function Nx.Quest:Find (title, level, desc, obj)

	local hash = self:Hash (title, level)

	local quest = Nx.Quests[hash]

	if quest then

		local hashPat = self:UHash (quest[1])
		if #hashPat > 0 then

			local found

			for n = 1, #hashPat, 4 do

				local mode = strbyte (hashPat, n, n)
				local off = tonumber (strsub (hashPat, n + 1, n + 2), 16) + 1
				local match = strsub (hashPat, n + 3, n + 3)

--				Nx.prt ("QFind #%d %d %d %s", n, mode, off, match)

				if mode == 48 then

					found = strsub (obj, off, off) == match

				elseif mode == 49 then

					found = strsub (obj, -off, -off) == match

				elseif mode == 50 then

					found = strsub (desc, off, off) == match

				elseif mode == 51 then

					found = strsub (desc, -off, -off) == match

				elseif mode >= 97 then

					local cnt = mode - 96
					local match = ","

					if mode >= 103 then
						cnt = mode - 102
						match = "."
					end

					local i = 1
					for findN = 1, cnt do
						i = strfind (desc, match, i)
						if not i then
							break
						end
						i = i + 1
					end

					if i then
						off = off + i - 1
						found = strsub (desc, off, off) == match
					end

				else
					Nx.prt (L["QFind bad mode %d"], mode)

				end

				if found then
					return Nx.Quests[hash + (n - 1) / 4 * 0x1000000]
				end

			end

			quest = nil
		end
	end

	if not quest then

		if level > 0 then	-- Only recurse once
			-- Quest level my be -1, so Jamie exports as 0
			return self:Find (title, 0, desc, obj)
		end

		if Nx.Quest.Debug then
			Nx.prt (L["QFind Failed to find"] .. "%s %d", title, level)
		end
	end

	return quest
end
--]]

-------------------------------------------------------------------------------
-- Com send / rcv
-------------------------------------------------------------------------------

function Nx.Quest:BuildComSend()

	local _
	local cur = self.Watch.ClosestCur
	local obj = 0
	local flgs = 2			-- Not a targeted quest flag

	if self.QLastChanged then	-- Quest change? Com nils this once send to zone

		cur = self.QLastChanged
--		Nx.prt ("Q Send Change %s", cur.Title)

	else
		local typ, tid = Nx.Map:GetTargetInfo()
		if typ == "Q" then

			local qid = floor (tid / 100)
			_, cur = self:FindCur (qid)
			obj = tid % 100
			flgs = 0
		end
	end

	if cur then

		if cur.Complete then
			flgs = flgs + 1
		end

		local str = format ("%04x%c%c%c", cur.QId, obj+35, flgs+35, cur.LBCnt+35)

		for n = 1, cur.LBCnt do

			local s1, _, cnt, total = strfind (cur[n], "(%d+)/(%d+)")
			if s1 then
				total = tonumber (total)
				if total > 50 then
					cnt = cnt / total * 60
					total = 60
				end
				cnt = cnt + 2
			else
				cnt = 0
				if cur[n + 100] then		-- Done?
					cnt = 1
				end
				total = 0
			end

			str = str .. format ("%c%c", cnt + 35, total + 35)
		end

--		Nx.prt ("QSend %s", str)

		return str, 4
	end

	return "", 0
end

function Nx.Quest:DecodeComRcv (info, msg)

	--	msg = "0000###"
	if not msg or #msg < 7 then	-- Too short?
		return	-- error, so nil length
	end

	local lbcnt = strbyte (msg, 7) - 35

	if not self.Enabled then
		return 7 + lbcnt * 2		-- Message length
	end

	local qId = tonumber (strsub (msg, 1, 4), 16) or 0
	local quest = Nx.Quests[qId]
	if not quest then						-- Unknown quest?
		if Nx.Com.PalsInfo[Nx.qTEMPname] ~= nil then
		  Nx.Com.PalsInfo[Nx.qTEMPname].QStr = format ("\n" ..L["Quest"] .. " %s", qId)
		end
		if Nx.Com.ZPInfo[Nx.qTEMPname] ~= nil then
			Nx.Com.ZPInfo[Nx.qTEMPname].QStr = format ("\n" ..L["Quest"] .. " %s", qId)
		end
		return
	end
	if not quest[1] then
		if Nx.Com.PalsInfo[Nx.qTEMPname] ~= nil then
		  Nx.Com.PalsInfo[Nx.qTEMPname].QStr = format ("\n" ..L["Quest"] .. " %s", qId)
		end
		if Nx.Com.ZPInfo[Nx.qTEMPname] ~= nil then
			Nx.Com.ZPInfo[Nx.qTEMPname].QStr = format ("\n" ..L["Quest"] .." %s", qId)
		end
		return
	end
	local name, side, lvl = self:Unpack (quest[1])

	local obji = strbyte (msg, 5) - 35
	local flgs = strbyte (msg, 6) - 35

	local targetStr = ""

	if bit.band (flgs, 2) == 0 then
		targetStr = "*"
	end

	local str = format ("\n|r%s%d |cffcfcf0f%s", targetStr, lvl, name)

	if bit.band (flgs, 1) > 0 then
		str = str .. L[" (Complete)"]
	end

	if #msg >= 7 + lbcnt * 2 then

		for n = 1, lbcnt do
			local off = (n - 1) * 2
			local cnt = strbyte (msg, 8 + off) - 35
			local total = strbyte (msg, 9 + off) - 35

			local obj = quest["Objectives"]
			if obj and obj[n] then
				obj = quest["Objectives"][n]
				local oname = self:UnpackObjective (obj)

				if obji == n then
					oname = "|cffcfcfff" .. oname
				else
					oname = "|cffafafaf" .. oname
				end

				if cnt == 0 then
					str = str .. format ("\n  %s", oname)
				elseif cnt == 1 then
					str = str .. format ("\n  %s " ..L["(done)"], oname)
				else
					str = str .. format ("\n  %s %d/%d", oname, cnt - 2, total)
				end
			end
		end

--	else
--		Nx.prt ("DecodeComRcv error quest %s", qId)

	end

	if Nx.Com.PalsInfo[Nx.qTEMPname] ~= nil then
	  Nx.Com.PalsInfo[Nx.qTEMPname].QStr = str
	end
	if Nx.Com.ZPInfo[Nx.qTEMPname] ~= nil then
	  Nx.Com.ZPInfo[Nx.qTEMPname].QStr = str
	end
	return 7 + lbcnt * 2		-- Message length
end

-------------------------------------------------------------------------------
-- Party quests
-------------------------------------------------------------------------------

function Nx.Quest.OnParty_members_changed()
	if not Nx.Quest.Initialized then
		return
	end
	local self = Nx.Quest

--	Nx.prt ("OnParty_members_changed")


	self.Watch:ShowUpdate()


	local pq = self.PartyQ

	for name in pairs (pq) do

		local found

		for n = 1, GetNumSubgroupMembers() do

			local pname = UnitName ("party" .. n)
			if name == pname then
				found = true
				break
			end
		end

		if not found then
			pq[name] = nil
--			Nx.prt ("Old %s", name)

			QPartyUpdate = Nx:ScheduleTimer(self.PartyUpdateTimer,1,self)
		end
	end

	if IsInRaid() then	-- In raid?
		return
	end

	if GetNumSubgroupMembers() == 0 then	-- Left party?
		return
	end

	local doSend

	for n = 1, GetNumSubgroupMembers() do

		local unit = "party" .. n
		local name = UnitName (unit)

		if not pq[name] then
			doSend = true
			pq[name] = {}
--			Nx.prt ("New %s %s", unit, name)
		end
	end

	if doSend then
		self:PartyStartSend()
	end
end

-------------------------------------------------------------------------------
-- Handle party message
-------------------------------------------------------------------------------

local pmsg_elapsed = 0
local pmsg_lasttime
local pmsg_ttl = 9999

function Nx.Quest:OnPartyMsg (plName, msg)

	if Nx.qdb and Nx.qdb.profile and not Nx.qdb.profile.Quest.PartyShare then
		return
	end
	
	local msgA = {Nx.Split("|", msg)}
	
	msg = msgA[1]
	
	-- msg = "Qp1iiiifo111122223333"

--	Nx.prt ("OnPartyMsg %s: %s", plName, msg)

	local pq = self.PartyQ
	local pl = pq[plName]

	if pl then

		if strbyte (msg, 3) == 49 then	-- "1" clear?
			pl = {}
			pq[plName] = pl
		end

		local Quest = Nx.Quest
		local off = 4

		for n = 1, 99 do

			if #msg < off + 5 then	-- No more?
				break
			end

			local qId = tonumber (strsub (msg, off, off + 3), 16) or 0
			local flgs, oCnt = strbyte (msg, off + 4, off + 5)
			flgs = flgs - 35
			oCnt = oCnt - 35

			if #msg < off + 5 + oCnt * 4 then	-- Too short?
				break
			end

			local quest = Nx.Quests[qId]
			if quest then

				local q = pl[qId] or {}
				pl[qId] = q

				q.Complete = bit.band (flgs, 1) == 1 and 1 or nil

	--			Nx.prt ("%s: %s %x %s", plName, qId, flgs, oCnt)

				for i = 1, oCnt do
					
					local desc, done = Nx.Split("^", msgA[i + 1])
					
					local o = off + 6 + (i - 1) * 4
					local cnt = tonumber (strsub (msg, o, o + 1), 16) or 0
					local total = tonumber (strsub (msg, o + 2, o + 3), 16) or 0

					q[i] = cnt
					q[i + 100] = total
					q[i + 200] = desc
					q[i + 300] = done == 1 and true or false
				end
			end

			off = off + 6 + oCnt * 4
		end
	end
	
	if pmsg_lasttime then
		local curtime = debugprofilestop()
		pmsg_elapsed = curtime - pmsg_lasttime
		pmsg_lasttime = curtime
	else
		pmsg_lasttime = debugprofilestop()
	end
	pmsg_ttl = pmsg_ttl + pmsg_elapsed
	if pmsg_ttl < 2000 then
		return
	end
	pmsg_ttl = 0
	
	QPartyUpdate = Nx:ScheduleTimer(self.PartyUpdateTimer,.5,self)
end

-------------------------------------------------------------------------------

function Nx.Quest:PartyUpdateTimer()
	self:RecordQuests(0)
	self.Watch:Update()
end

-------------------------------------------------------------------------------

function Nx.Quest:PartyStartSend()

	if IsInRaid() or GetNumSubgroupMembers() == 0 then
		return
	end

	if Nx.qdb.profile.Quest.PartyShare then
		QSendParty = Nx:ScheduleTimer(self.PartyBuildSendData,.5,self)
	end
end

local PartySendTimer
function Nx.Quest:PartyBuildSendData()

	local data = {}

	self.PartySendData = data
	self.PartySendDataI = 1

	local sendStr = ""

	for n, cur in ipairs (self.CurQ) do

		local qId = cur.QId

		if not cur.Goto and Nx.Quest:GetQuest (qId) == "W" then

			local flgs = 0

			if cur.Complete then
				flgs = flgs + 1
			end

			local str = format ("%04x%c%c", qId, flgs + 35, cur.LBCnt + 35)
			local strO = ""
			
			for n = 1, cur.LBCnt do

				local _, _, cnt, total = strfind (cur[n], "(%d+)/(%d+)")
				cnt = tonumber (cnt or 0)
				total = tonumber (total or 0)

				local desc, done = self:CalcDesc (qId, n, cnt, total)
				cur[n] = desc

				if cnt and total then
					if cnt > 200 then
						cnt = 200
					end
				else
					cnt = 0
					if cur[n + 100] then		-- Done?
						cnt = 1
					end
					total = 0
				end

				str = str .. format ("%02x%02x", cnt, total)
				
				if desc then
					strO = strO .. "|" .. desc .. "^" .. (done and 1 or 0)
				end
			end

			sendStr = sendStr .. str .. strO

			
			tinsert (data, sendStr)
			sendStr = ""
		end
	end

	PartySendTimer = Nx:ScheduleRepeatingTimer(self.PartySendTimer,0,self)

	return 0
end

function Nx.Quest:PartySendTimer()

	local qi = self.PartySendDataI
	local data = self.PartySendData[qi]

	if data then
		local s = qi == 1 and "1" or " "
		Nx.Com:Send ("p", "Qp" .. s .. data)
--		Nx.prt ("PQSend %s", data)
	end

	self.PartySendDataI = qi + 1

	if not self.PartySendData[self.PartySendDataI] then
		Nx:CancelTimer(PartySendTimer)
	end
end

function Nx.Quest:GetQuestOpts()
	return Nx.qdb.profile.QuestOpts
end

function Nx.Quest:UnpackObjectiveNew (obj)
	if not obj then
		return
	end
	if type(obj) == "table" then
		obj = obj[1]
	end
	local desc, zone, typ = Nx.Split("|",obj)
	return desc, tonumber(zone), tonumber(typ)
end

function Nx.Quest:UnpackLocRect (locStr)

	local _,_,_,x, y, w, h = Nx.Split ("|",locStr)

	return	tonumber(x),		-- * 100 / 200	Optimised
				tonumber(y),		-- * 100 / 200
				tonumber(w),
				tonumber(h)
end

function Nx.Quest:UnpackLocPtOff (locStr)
	if type(locStr) == "string" then
		local _,_,_,x1,x2,y1,y2 = Nx.Split("|",locStr)
		return tonumber(x1), tonumber(x2), tonumber(y1), tonumber(y2)
	else
		local _,_,_,x1,x2,y1,y2 = Nx.Split("|",locStr[1])
		return tonumber(x1), tonumber(x2), tonumber(y1), tonumber(y2)
	end
end

function Nx.Quest:GetQuest (qId)
	local quest = Nx.Quest.CurCharacter.Q[qId]
	if not quest then
		return
	end
	if type(quest) == "table" then
		Nx.Quest.CurCharacter.Q[qId] = ""
		return
	end
	local s1, s2, status, time = strfind (quest, "(%a)(%d+)")
	return status, time
end

function Nx.Quest:SetQuest (qId, qStatus, qTime)
	qTime = qTime or 0
	Nx.Quest.CurCharacter.Q[qId] = qStatus .. qTime
end

function Nx.Quest:NullQuest (qId)
	Nx.Quest.CurCharacter.Q[qId] = ""
end

function Nx.Quest:GetQuestID (loc)
	local _, _, _, _, _, _, _, questId, _, _, _, _, _, _ = GetQuestLogTitle(loc)
	return questId
end

function Nx.Quest.WQList:Open()
	self.GOpts = opts
	local qopts = Nx.Quest:GetQuestOpts()		
	local win = Nx.Window:Create ("NxQuestWQList", nil, nil, nil, 1, false)
	local xo, yo = 7,3
	Nx.Window:SetCreateFade (1, .15)
	self.Opened = true	
	self.Win = win	
	win:InitLayoutData (nil, -.80, -.35, -.2, -.1)	
	win:CreateButtons (true, nil, nil)
	win:SetBGAlpha (0, 1)
	win:SetBorderSize (0, 7)	
	win.Sizeable = false	
	win:SetTitleXOff (84 + xo, -1 - yo)
	win.Frm:SetClampedToScreen (true)
	win.UserUpdateFade = self.WinUpdateFade	
	win:SetTitle (L["World Quest Tracker"])	
	local function update (self)
		self:Update()
	end
	local function func (self)
		self.Menu:Open()
	end
	self.ButMenu = Nx.Button:Create (win.Frm, "WQListMenu", nil, nil, 4, -5 + yo, "TOPLEFT", 1, 1, func, self)
	local function func (self)
		self.MenuPri:Open()
	end
	Nx.List:SetCreateFont ("QuestWatch.WatchFont", 12)
	local list = Nx.List:Create (false, 2, -2, 100, 12 * 3, win.Frm, true, true)
	self.List = list
	list:SetMinSize (200, 20)
	list.Frm:EnableMouse (false)	
	list:ColumnAdd ("", 1, 14)
	list:ColumnAdd ("Name", 2, 120)
	list:ColumnAdd ("", 3, 0)
	list:ColumnAdd ("Faction", 4, 20)
	list:ColumnAdd ("Reward", 5, 40)
	list:ColumnAdd ("Time Left", 6, 20)
	win:Attach (list.Frm, 0, 1, 0, 1)
	list:SetUser (self, self.OnListEvent)
	
	local wqlist = Nx.Quest.WQList
	local menu = Nx.Menu:Create (list.Frm)
	self.Menu = menu
	
	local function func ()
		self:Update()
	end
	
	local item = menu:AddItem (0, L["Show Gold Rewards"], func, wqlist)
	item:SetChecked (Nx.qdb.profile.WQList, "showgold")
	local item = menu:AddItem (0, L["Show AP Rewards"], func, wqlist)
	item:SetChecked (Nx.qdb.profile.WQList, "showap")
	local item = menu:AddItem (0, L["Show Order Resource Rewards"], func, wqlist)
	item:SetChecked (Nx.qdb.profile.WQList, "showorder")
	local item = menu:AddItem (0, L["Show Gear Rewards"], func, wqlist)
	item:SetChecked (Nx.qdb.profile.WQList, "showgear")
	local item = menu:AddItem (0, L["Show PVP Rewards"], func, wqlist)
	item:SetChecked (Nx.qdb.profile.WQList, "showpvp")
	local item = menu:AddItem (0, L["Show Other Rewards"], func, wqlist)
	item:SetChecked (Nx.qdb.profile.WQList, "showother")
	local item = menu:AddItem (0, "", func, wqlist)
	local item = menu:AddItem (0, L["Court of Farondis"], func, wqlist)
	item:SetChecked (Nx.qdb.profile.WQList, "showfaronis")
	local item = menu:AddItem (0, L["Dreamweavers"], func, wqlist)
	item:SetChecked (Nx.qdb.profile.WQList, "showdreamweaver")	
	local item = menu:AddItem (0, L["Highmountain Tribe"], func, wqlist)
	item:SetChecked (Nx.qdb.profile.WQList, "showhighmountain")		
	local item = menu:AddItem (0, L["Armies of Legionfall"], func, wqlist)
	item:SetChecked (Nx.qdb.profile.WQList, "showlegionfall")
	local item = menu:AddItem (0, L["Nightfallen"], func, wqlist)
	item:SetChecked (Nx.qdb.profile.WQList, "shownightfallen")
	local item = menu:AddItem (0, L["Wardens"], func, wqlist)
	item:SetChecked (Nx.qdb.profile.WQList, "showwardens")	
	local item = menu:AddItem (0, L["Kirin Tor"], func, wqlist)
	item:SetChecked (Nx.qdb.profile.WQList, "showkirintor")	
	local item = menu:AddItem (0, L["Army of the Light"], func, wqlist)
	item:SetChecked (Nx.qdb.profile.WQList, "showarmyoflight")
	local item = menu:AddItem (0, L["Argussian Reach"], func, wqlist)
	item:SetChecked (Nx.qdb.profile.WQList, "showargussian")
	local item = menu:AddItem (0, L["Valarjar"], func, wqlist)
	item:SetChecked (Nx.qdb.profile.WQList, "showvalarjar")			
	local item = menu:AddItem (0, "", func, wqlist)
	local item = menu:AddItem (0, L["Color Active Faction Bounties"], func, wqlist)
	item:SetChecked (Nx.qdb.profile.WQList, "bountycolor")	
	local item = menu:AddItem (0, L["Current Zone Only"], func, wqlist)
	item:SetChecked (Nx.qdb.profile.WQList, "zoneonly")
	local item = menu:AddItem (0, L["Faction Bounties Only"], func, wqlist)
	item:SetChecked (Nx.qdb.profile.WQList, "showbounty")	
	self.FirstUpdate = true
	self.FlashColor = 0
	LibStub("AceEvent-3.0"):Embed(Nx.Quest.WQList)
	Nx.Quest.WQList:RegisterEvent ("QUEST_LOG_UPDATE", "UpdateDB")
	Nx.Quest.WQList:RegisterEvent ("UNIT_QUEST_LOG_CHANGED", "UpdateDB")
	--C_Timer.NewTicker(30, function() Nx.Quest.WQList:UpdateDB() end)
	Nx.Quest.WQList:RegisterEvent ("ZONE_CHANGED_NEW_AREA", "Update")	
	win.Frm:SetScript ("OnShow",self.UpdateDB)
--	self:SetSortMode (1)
	win.Frm:Hide()
end

function Nx.Quest.WQList:WinUpdateFade (fade)	
	Nx.Quest.WQList.Win:SetTitleColors (1, 1, 1, fade)		
	Nx.Quest.WQList.List.Frm:SetAlpha (fade)
	Nx.Quest.WQList.ButMenu.Frm:SetAlpha (fade)
end

function Nx.Quest.WQList:GenWQTip(questId)	
	if worldquestdb[questId].tip and worldquestdb[questId].tip ~= false then		
		return worldquestdb[questId].tip
	end
	worldquesttip:ClearLines()
	local title, factionID, capped = C_TaskQuest.GetQuestInfoByQuestID(questId)
	local tagID, tagName, worldQuestType, rarity, isElite, tradeskillLineIndex, displayTimeLeft = GetQuestTagInfo(questId)
	local color = WORLD_QUEST_QUALITY_COLORS[rarity]
	local style = TOOLTIP_QUEST_REWARDS_STYLE_DEFAULT
	local tipdone = false
	
	worldquesttip:SetText(title, color.r, color.g, color.b)	
	QuestUtils_AddQuestTypeToTooltip(worldquesttip, questId, NORMAL_FONT_COLOR)
	if factionID then
		local factionName = GetFactionInfoByID(factionID)
		if factionName then
			if capped then
				worldquesttip:AddLine(factionName, GRAY_FONT_COLOR:GetRGB())
			else
				worldquesttip:AddLine(factionName)
			end
		end
	end

	if displayTimeLeft then
		WorldMap_AddQuestTimeToTooltip(questId)
	end

	for objectiveIndex = 1, worldquestdb[questId].numobjectives do
		local objectiveText, objectiveType, finished = GetQuestObjectiveInfo(questId, objectiveIndex, false)
		if objectiveText and #objectiveText > 0 then
			local color = finished and GRAY_FONT_COLOR or HIGHLIGHT_FONT_COLOR
			worldquesttip:AddLine(QUEST_DASH .. objectiveText, color.r, color.g, color.b, true)
		end
	end

	local percent = C_TaskQuest.GetQuestProgressBarInfo(questId)
	if percent then				
		worldquesttip:AddLine(L["Percent Complete"] .. ":  " .. percent .. "%")
	end

	if (GetQuestLogRewardXP(questId) > 0 or GetNumQuestLogRewardCurrencies(questId) > 0 or GetNumQuestLogRewards(questId) > 0 or GetQuestLogRewardMoney(questId) > 0 or GetQuestLogRewardArtifactXP(questId) > 0 or GetQuestLogRewardHonor(questId)) then
		GameTooltip_AddBlankLinesToTooltip(worldquesttip, style.prefixBlankLineCount)
		worldquesttip:AddLine(style.headerText, style.headerColor.r, style.headerColor.g, style.headerColor.b, style.wrapHeaderText)
		GameTooltip_AddBlankLinesToTooltip(worldquesttip, style.postHeaderBlankLineCount)

		local xp = GetQuestLogRewardXP(questId)				
		if ( xp > 0 ) then
			worldquesttip:AddLine(BONUS_OBJECTIVE_EXPERIENCE_FORMAT:format(xp), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
			tipdone = true			
		end
		local artifactXP = GetQuestLogRewardArtifactXP(questId)
		if ( artifactXP > 0 ) then
			worldquesttip:AddLine(BONUS_OBJECTIVE_ARTIFACT_XP_FORMAT:format(artifactXP), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
			tipdone = true			
		end
		local numAddedQuestCurrencies = QuestUtils_AddQuestCurrencyRewardsToTooltip(questId, worldquesttip)
		if ( numAddedQuestCurrencies > 0 ) then
			tipdone = true			
		end		
		local honorAmount = GetQuestLogRewardHonor(questId)
		if ( honorAmount > 0 ) then
			worldquesttip:AddLine(BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT:format("Interface\\ICONS\\Achievement_LegionPVPTier4", honorAmount, HONOR), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)			
			tipdone = true
			worldquestdb[questId].PVP = true
		end		
		local money = GetQuestLogRewardMoney(questId)
		if ( money > 0 ) then
			worldquesttip:AddLine(Nx.Util_GetMoneyStr (money))
			tipdone = true			
		end
		local numQuestRewards = GetNumQuestLogRewards(questId)
		if numQuestRewards > 0 then			
			local name,icon,numItems,quality,_,itemID = GetQuestLogRewardInfo(1,questId)
			local color =  BAG_ITEM_QUALITY_COLORS[quality < LE_ITEM_QUALITY_COMMON and LE_ITEM_QUALITY_COMMON or quality]
			if name then
				worldquesttip:AddLine("|T"..icon..":0|t "..(numItems and numItems > 1 and numItems.."x " or "")..name, color.r, color.g, color.b)
				tipdone = true
			end
		end
	end
	if not tipdone then
		return false
	end
	local tip = ""
	for i=1, worldquesttip:NumLines() do
		local line = _G["WQListTipTextLeft" .. i]:GetText()
		local r, g, b = _G["WQListTipTextLeft" .. i]:GetTextColor()		
		tip = tip .. format("|cff%02x%02x%02x%s|r\n", r * 255, g * 255, b * 255, line)		
	end
	
	return tip
end

function Nx.Quest.WQList:GetWQReward(questId)
	local reward = ""
	
	local artxp = GetQuestLogRewardArtifactXP(questId)	
	if artxp > 0 then				
		return 10
	end
	local items = GetNumQuestLogRewards(questId)
	if items > 0 then
		worldquesttip:ClearLines()
		local name,icon,qty,quality,_,itemID = GetQuestLogRewardInfo(1,questId)
		local foundartifact = false
		worldquesttip:SetQuestLogItem("reward", 1, questId)
		local link = select(2,worldquesttip:GetItem())		
		for i=2, worldquesttip:NumLines() do
			local line = _G["WQListTipTextLeft" .. i]:GetText()
			if line and ( line:find(ARTIFACT_POWER.."|r$") or line:find("Artifact Power|r$") ) then
				return 10		
			end		
			if line and line:find(ITEM_LEVEL) then				
				return 40
			end
		end
		worldquesttip:ClearLines()
	end
	local gold = GetQuestLogRewardMoney(questId)
	if gold > 0 then
		return 20
	end
	local numcurrency = GetNumQuestLogRewardCurrencies(questId)
	for i = 1, numcurrency do
		local name, texture, num, id = GetQuestLogRewardCurrencyInfo(i, questId)
		if id == 1220 then
			return 30
		end
	end
	return false
end

function Nx.Quest.WQList:OnListEvent (eventName, sel, val2, click)
	local itemData = self.List:ItemGetData (sel) or 0
	local shift = IsShiftKeyDown() or eventName == "mid"
	local map = Nx.Map:GetMap (1)	
	if eventName == "button" and itemData then				
		local title, faction = C_TaskQuest.GetQuestInfoByQuestID(itemData.questid)		
		map:SetTargetXY (itemData.mapid, itemData.x, itemData.y, title, false)	
	end
end

local WQListUpdateDBTimer
function Nx.Quest.WQList:UpdateDB(event, ...)
	if WQListUpdateDBTimer then
		WQListUpdateDBTimer:Cancel()
	end
--	if not Nx.Quest.WQList.Win.Frm:IsVisible() then
--		return
--	end	

	local func = function ()
		Nx.prtD("Nx.Quest.WQList:UpdateDB")
		if WQListUpdateDBTimer then
			WQListUpdateDBTimer:Cancel()
		end
		
		local worldquestzones = { 947, 830, 885, 882, 1355, 1462 }	
		for i=1,#worldquestzones do
			local zonequests = {}
			if worldquestzones[i] == 625 then						
				zonequests = C_TaskQuest.GetQuestsForPlayerByMapID(worldquestzones[i])			
			else
				zonequests = C_TaskQuest.GetQuestsForPlayerByMapID(worldquestzones[i], worldquestzones[i])
			end
			for j, quest in pairs(zonequests) do 
				local questId = quest.questId			
				C_TaskQuest.RequestPreloadRewardData (questId)
				if questId and QuestUtils_IsQuestWorldQuest (questId) then
					if not worldquestdb[questId] then
						worldquestdb[questId] = {}					
					end
					worldquestdb[questId].x = quest.x * 100				
					worldquestdb[questId].y = quest.y * 100				
					worldquestdb[questId].mapid = C_TaskQuest.GetQuestZoneID(questId) --worldquestzones[i]
					worldquestdb[questId].questid = questId
					worldquestdb[questId].numobjectives = quest.numObjectives
					local tip = Nx.Quest.WQList:GenWQTip(questId)
					if not worldquestdb[questId].tip and tip then						
						worldquestdb[questId].tip = tip
					end
				end
			end
		end
		if Nx.Quest.WQList.Win.Frm:IsVisible() then
			Nx.Quest.WQList:Update() 
		end
	end
	
	if event == "QUEST_LOG_UPDATE" then
		Nx.Quest.WQList:UnregisterEvent("QUEST_LOG_UPDATE")
		--C_Timer.After(5, function() Nx.Quest.WQList:UpdateDB() end)
	else
		--WQListUpdateDBTimer = C_Timer.NewTimer(IsInInstance() and 5 or 1, func)
	end	
end

function Nx.Quest.WQList:CheckBounty(questId)
	local bounties = GetQuestBountyInfoForMapID(1014)
	local isbounty = false
	for bountyIndex, bounty in ipairs(bounties) do
		if IsQuestCriteriaForBounty(questId, bounty.questID) then
			isbounty = true
		end
	end
	return isbounty
end

function Nx.Quest.WQList:Update()	
	local list = Nx.Quest.WQList.List	
	list:Empty()		
	list:ColumnSetWidth(2,120)
	list:ColumnSetWidth(4,20)
	list:ColumnSetWidth(5,40)	
	list:ColumnSetWidth(6,20)		
	
	for quest, _ in pairs(worldquestdb) do
		local info = worldquestdb[quest]
		local questId = quest					
		local title, faction = C_TaskQuest.GetQuestInfoByQuestID(questId)
		local newwidth = #title * 7 + 10
		local timeleft = C_TaskQuest.GetQuestTimeLeftMinutes(questId) or 0
		local rewardstring = ""		
		local isbounty = Nx.Quest.WQList:CheckBounty(questId)
		
		if timeleft > 0 then								
			local reward = Nx.Quest.WQList:GetWQReward(questId)
			if (reward == 10 and not Nx.qdb.profile.WQList.showap) or
			   (reward == 20 and not Nx.qdb.profile.WQList.showgold) or 
			   (reward == 30 and not Nx.qdb.profile.WQList.showorder) or
			   (reward == 40 and not Nx.qdb.profile.WQList.showgear) or
			   (info.PVP and not Nx.qdb.profile.WQList.showpvp) or
			   (faction == 1900 and not Nx.qdb.profile.WQList.showfaronis) or
			   (faction == 1883 and not Nx.qdb.profile.WQList.showdreamweaver) or
			   (faction == 1828 and not Nx.qdb.profile.WQList.showhighmountain) or
			   (faction == 2045 and not Nx.qdb.profile.WQList.showlegionfall) or
			   (faction == 1859 and not Nx.qdb.profile.WQList.shownightfallen) or
			   (faction == 1894 and not Nx.qdb.profile.WQList.showwardens) or
			   (faction == 1948 and not Nx.qdb.profile.WQList.showvalarjar) or
			   (faction == 1090 and not Nx.qdb.profile.WQList.showkirintor) or
			   (faction == 2165 and not Nx.qdb.profile.WQList.showarmyoflight) or
			   (faction == 2170 and not Nx.qdb.profile.WQList.showargussian) or
			   (isbounty == false and Nx.qdb.profile.WQList.showbounty) or
			   (info.mapid ~= Nx.Map:GetCurrentMapAreaID() and Nx.qdb.profile.WQList.zoneonly) or
			   (reward == false and not Nx.qdb.profile.WQList.showother)then
					worldquestdb[questId].Filtered = true
			else					
				local colstring = "|r"
				if isbounty and Nx.qdb.profile.WQList.bountycolor then
					colstring = "|cff00DD00"
				end
				if newwidth > list:ColumnGetWidth(2) then
					list:ColumnSetWidth(2,newwidth)
				end
				list:ItemAdd(0)			
				list:ItemSet(2,colstring .. title)
				if faction then				
					local factionname = GetFactionInfoByID(faction)
					newwidth = #factionname * 7 + 10
					if newwidth > list:ColumnGetWidth(4) then
						list:ColumnSetWidth(4,newwidth)
					end					
					list:ItemSet(4,colstring .. factionname)
				end
				if reward == 10 then
					rewardstring = "Artifact Power"
				elseif reward == 20 then
					rewardstring = "Gold"
				elseif reward == 30 then
					rewardstring = "Order Resources"
				elseif reward == 40 then
					rewardstring = "Gear"
				end
				newwidth = #rewardstring * 7 + 10
				if newwidth > list:ColumnGetWidth(5) then
					list:ColumnSetWidth (5, newwidth)
				end
				list:ItemSet(5, colstring .. rewardstring)
				local timestr = Nx.Util_GetTimeElapsedStr (timeleft * 60)
				newwidth = #timestr * 7 +10
				if newwidth > list:ColumnGetWidth(6) then
					list:ColumnSetWidth (6, newwidth)
				end
				list:ItemSet(6,colstring .. timestr)				
				list:ItemSetButton ("QuestWatchCustomTip", false)
				list:ItemSetData(list:ItemGetNum(), info)
				if info.tip then
					list:ItemSetButtonTip(info.tip)
				end
				worldquestdb[questId].Filtered = false
			end
		end
	end
	list:Update()			
end

function NxWatchListItem_OnUpdate(self, elapsed)
	-- Handle range indicator
	local rangeTimer = self.rangeTimer;
	if ( rangeTimer ) then
		rangeTimer = rangeTimer - elapsed;
		if ( rangeTimer <= 0 ) then
			--print(self.questLogIndex)
			_, _, _, _, _, _, _, mquestID, _, _, _, _, _, _ = GetQuestLogTitle(self.questLogIndex);
			local charges = GetItemCount(Nx.QItems[mquestID],true,true)
			if ( not charges or charges ~= self.charges ) then
				--ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_QUEST);
				return;
			end
			local count = self.HotKey;
			local valid = IsQuestLogSpecialItemInRange(self.questLogIndex);
			if ( valid == 0 ) then
				count:Show();
				count:SetVertexColor(1.0, 0.1, 0.1);
			elseif ( valid == 1 ) then
				count:Show();
				count:SetVertexColor(0.6, 0.6, 0.6);
			else
				count:Hide();
			end
			rangeTimer = TOOLTIP_UPDATE_TIME;
		end
		self.rangeTimer = rangeTimer;
	end
end
-------------------------------------------------------------------------------
-- EOF
