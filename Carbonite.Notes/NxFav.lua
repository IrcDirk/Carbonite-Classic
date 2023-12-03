---------------------------------------------------------------------------------------
-- NxFav - Favorites window
-- Copyright 2008-2012 Carbon Based Creations, LLC
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

Nx.VERSIONFAV			= .16				-- Favorite data

Nx.Notes = {}

CarboniteNotes = LibStub("AceAddon-3.0"):NewAddon("CarboniteNotes", "AceTimer-3.0", "AceEvent-3.0", "AceComm-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Carbonite.Notes", true)

-- Keybindings
BINDING_HEADER_CarboniteNotes	= "|cffc0c0ff" .. L["Carbonite Notes"] .. "|r"
BINDING_NAME_NxTOGGLEFAV	= L["NxTOGGLEFAV"]

local addonNotes = {}

local defaults = {
	profile = {
		Notes = {
			ShowMap = true,
			HandyNotes = true,
			HandyNotesSize = 15,
		},
		Addons = {
		},
	}
}

local notesoptions
local function notesConfig()
	if not notesoptions then
		notesoptions = {
			type = "group",
			name = L["Note Options"],
			args = {
				notemap = {
					order = 1,
					type = "toggle",
					width = "full",
					name = L["Show Notes On Map"],
					desc = L["Shows your notes on the carbonite map"],
					get = function()
						return Nx.fdb.profile.Notes.ShowMap
					end,
					set = function()
						Nx.fdb.profile.Notes.ShowMap = not Nx.fdb.profile.Notes.ShowMap
					end,
				},
				handy = {
					order = 2,
					type = "toggle",
					width = "full",
					name = L["Display Handynotes On Map"],
					desc = L["If you have HandyNotes installed, allows them on the Carbonite map"],
					get = function()
						return Nx.fdb.profile.Notes.HandyNotes
					end,
					set = function()
						local map = Nx.Map:GetMap (1)						
						Nx.fdb.profile.Notes.HandyNotes = not Nx.fdb.profile.Notes.HandyNotes
						if Nx.fdb.profile.Notes.HandyNotes then
							Nx.Notes:HandyNotes(Nx.Map:GetCurrentMapAreaID())
						else
							map:ClearIconType("!HANDY")
						end
					end,
					disabled = function()
						if HandyNotes then
							return false
						end
						return true
					end,
				},
				handysize = {
					order = 3,
					type = "range",
					width = "normal",
					min = 10,					
					max = 60,
					step = 5,
					name = L["Handnotes Icon Size"],
					get = function()
						return Nx.fdb.profile.Notes.HandyNotesSize
					end,
					set = function(input,value)
						local map = Nx.Map:GetMap (1)						
						Nx.fdb.profile.Notes.HandyNotesSize = value
						map:ClearIconType("!HANDY")
						Nx.Notes:HandyNotes(Nx.Map:GetCurrentMapAreaID())
					end,
					disabled = function()
						if HandyNotes then
							return false
						end
						return true
					end,
				},
			},
		}
	end
	Nx.Opts:AddToProfileMenu(L["Notes"],4,Nx.fdb)
	return notesoptions
end

function CarboniteNotes:OnInitialize()
	if not Nx.Initialized then
		CarbNotesInit = Nx:ScheduleTimer(CarboniteNotes.OnInitialize,1)
		return
	end
	Nx.fdb = LibStub("AceDB-3.0"):New("NXNotes",defaults, true)	
	Nx.Notes:Init()
	CarboniteNotes:RegisterComm("carbmodule",Nx.Notes.OnChat_msg_addon)
	local function func()
		Nx.Notes:ToggleShow()
	end
	Nx.Button.TypeData["MapFav"] = {
		Up = "$INV_Torch_Lit",
		SizeUp = 22,
		SizeDn = 22,
	}
	Nx.NXMiniMapBut.Menu:AddItem(0, L["Show Notes"], func, Nx.NXMiniMapBut)
	tinsert (Nx.ModuleUpdateIcon,"Notes")
	tinsert (Nx.BarData,{"MapFav", L["-Notes-"], Nx.Notes.OnButToggleFav, false })
	Nx.Map.Maps[1]:CreateToolBar()
	Nx.Map.Maps[1].Menu:AddItem (0, L["Add Note"], Nx.Notes.Menu_OnAddNote, Nx.Map.Maps[1])
	Nx.Map.Maps[1].GIconMenu:AddItem (0, L["Add Note"], Nx.Notes.Menu_OnAddNote, Nx.Map.Maps[1])
	Nx:AddToConfig("Notes Module",notesConfig(),L["Notes Module"])
	tinsert(Nx.BrokerMenuTemplate,{ text = L["Toggle Notes"], func = function() Nx.Notes:ToggleShow() end })
end

function Nx.Notes:OnChat_msg_addon(msg, dist, target)
	local ssplit = { strsplit("|",msg) }
	if ssplit[1] == "CMD" then
		if ssplit[2] == "note" then
			Nx.Notes:SetNoteAtStr (ssplit[3])
		end
	end
end

function Nx.Notes:Init()

	local fav = Nx.fdb.profile.Notes

	if not fav or not fav.Version or fav.Version < Nx.VERSIONFAV then

		if fav and fav.Version then
			Nx.prt (L["Reset old notes data"] .. " %f", fav.Version)
		end

		fav = {}
		Nx.fdb.profile.Notes = fav
		fav.Version = Nx.VERSIONFAV
	end


	self.Folders = Nx.GetFav()
	self.NoteIcons = {
	"Interface\\TargetingFrame\\UI-RaidTargetingIcon_1",
	"Interface\\TargetingFrame\\UI-RaidTargetingIcon_2",
	"Interface\\TargetingFrame\\UI-RaidTargetingIcon_3",
	"Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
	"Interface\\TargetingFrame\\UI-RaidTargetingIcon_5",
	"Interface\\TargetingFrame\\UI-RaidTargetingIcon_6",
	"Interface\\TargetingFrame\\UI-RaidTargetingIcon_7",
	"Interface\\TargetingFrame\\UI-RaidTargetingIcon_8",
	"Interface\\Minimap\\Tracking\\Auctioneer",
	"Interface\\Minimap\\Tracking\\Banker",
	"Interface\\Minimap\\Tracking\\BattleMaster",
	"Interface\\Minimap\\Tracking\\FlightMaster",
	"Interface\\Minimap\\Tracking\\Innkeeper",
	"Interface\\Minimap\\Tracking\\Mailbox",
	"Interface\\Minimap\\Tracking\\Repair",
	"Interface\\Minimap\\Tracking\\StableMaster",
	"Interface\\Minimap\\Tracking\\Class",
	"Interface\\Minimap\\Tracking\\Profession",
	"Interface\\Minimap\\Tracking\\TrivialQuests",
	"Interface\\Minimap\\Tracking\\Ammunition",
	"Interface\\Minimap\\Tracking\\Food",
	"Interface\\Minimap\\Tracking\\Poisons",
	"Interface\\Minimap\\Tracking\\Reagents",
	"Interface\\TargetingFrame\\UI-PVP-Alliance",
	"Interface\\TargetingFrame\\UI-PVP-Horde",
	"Interface\\TargetingFrame\\UI-PVP-FFA",
	"Interface\\PVPFrame\\PVP-ArenaPoints-Icon",
	"Interface\\Icons\\Spell_Arcane_PortalDalaran",
	}
	
	CarboniteNotes:RegisterEvent("LOOT_CLOSED", function() Nx.Notes:Update(); end )
end

function Nx.Notes:GetIconInline (index)
	local file = self.NoteIcons[index]
	return format ("|T%s:16|t", file)
end

function Nx.Notes:GetIconFile (index)
	return self.NoteIcons[index]
end

-- xpcall safecall implementation
local xpcall = xpcall

local function errorhandler(err)
	return geterrorhandler()(err)
end

local function safecall(func, ...)
	-- we check to see if the func is passed is actually a function here and don't error when it isn't
	-- this safecall is used for optional functions like OnEnter OnLeave etc. When they are not
	-- present execution should continue without hinderance
	if type(func) == "function" then
		return xpcall(func, errorhandler, ...)
	end
end

local handypin = {}

function handypin:OnEnter(motion)
	WorldMapBlobFrame:SetScript("OnUpdate", nil)
	safecall(HandyNotes.plugins[self.pluginName].OnEnter, self, self.mapFile, self.coord)
end

function handypin:OnLeave(motion)
	WorldMapBlobFrame:SetScript("OnUpdate", WorldMapBlobFrame_OnUpdate)
	safecall(HandyNotes.plugins[self.pluginName].OnLeave, self, self.mapFile, self.coord)
end

---------------------------------------------------------------------------------------
-- Create favorites window
---------------------------------------------------------------------------------------

function Nx.Notes:Create()

	self.Side = 1

	-- Create Window

	local win = Nx.Window:Create ("NxFav", 240, nil, nil, 1)
	self.Win = win
	win.Frm.NxInst = self

	win:CreateButtons (true, true)
	win:SetTitleLineH (18)
	win:SetTitleXOff (220)

	win:InitLayoutData (nil, -.23, -.25, -.54, -.5)
	win.Frm:SetToplevel (true)

	win:Show (false)

	tinsert (UISpecialFrames, win.Frm:GetName())

	-- Buttons

	local bw, bh = win:GetBorderSize()

	local but = Nx.Button:Create (win.Frm, "Txt64B", L["Record"], nil, bw + 1, -bh, "TOPLEFT", 44, 20, self.But_OnRecord, self)
	self.RecBut = but

	local but = Nx.Button:Create (win.Frm, "Txt64", L["Up"], nil, bw + 48, -bh, "TOPLEFT", 40, 20, self.But_OnUp, self)
	local but = Nx.Button:Create (but.Frm, "Txt64", L["Down"], nil, 42, 0, "TOPLEFT", 40, 20, self.But_OnDown, self)
	Nx.Button:Create (but.Frm, "Txt64", L["Delete Item"], nil, 54, 0, "TOPLEFT", 72, 20, self.But_OnItemDel, self)

	-- Folder List

	Nx.List:SetCreateFont ("Font.Medium", 16)

	local list = Nx.List:Create ("FavF", 0, 0, 1, 1, win.Frm)
	self.List = list

	list:SetUser (self, self.OnListEvent)

	list:SetLineHeight (4)

	list:ColumnAdd ("", 1, 20)
	list:ColumnAdd (L["Name"], 2, 900)

	win:Attach (list.Frm, 0, .3, 0, 1)

	-- Item List

	Nx.List:SetCreateFont ("Font.Medium", 16)

	local list = Nx.List:Create ("FavI", 0, 0, 1, 1, win.Frm)
	self.ItemList = list

	list:SetUser (self, self.OnItemListEvent)

	list:SetLineHeight (2)

	list:ColumnAdd ("", 1, 17)
	list:ColumnAdd (L["Type"], 2, 90)
	list:ColumnAdd (L["Value"], 3, 250)
	list:ColumnAdd (L["Location"], 4, 900)

	win:Attach (list.Frm, .3, 1, 0, 1)			-- 18, 1 with editbox

	-- Filter Edit Box

--	self.EditBox = Nx.EditBox:Create (win.Frm, self, self.OnEditBox, 30)

--	win:Attach (self.EditBox.Frm, .3, 1, 0, 18)

	--

	self:CreateMenu()

	--
	
	self:Update()

	self.List:FullUpdate()
end

---------------------------------------------------------------------------------------

function Nx.Notes:But_OnRecord (but)
	self:SetRecord (but:GetPressed())
end

function Nx.Notes:SetRecord (on)

	local but = self.RecBut

	if on then
		if self.CurFav then
			self.Recording = self.CurFav
			self.RecAlphaAnim = 1000
			self.FavRec = Nx:ScheduleRepeatingTimer(self.RecordAnimTimer,0.1,self)
			but:SetPressed (true)
		else
			Nx.prt (L["Select a favorite before recording"])
			but:SetPressed (false)
		end
	else
		Nx:CancelTimer(self.FavRec)
		self.Recording = nil
		but:SetAlpha (1)
		but:SetPressed (false)
	end
end

function Nx.Notes:RecordAnimTimer()

	if self.Recording then
		local a = (self.RecAlphaAnim - 35) % 1000
		self.RecAlphaAnim = a
		self.RecBut:SetAlpha (abs (a - 500) / 1000 + .5)
	end
end

function Nx.Notes:But_OnUp()
	self:MoveCur (true)
end

function Nx.Notes:But_OnDown()
	self:MoveCur()
end

function Nx.Notes:MoveCur (low)

	if self.Side == 1 then

		local item = self.CurFavOrFolder
		if item then

			local parent = self:GetParent (item)

			Nx.Util_TMoveItem (parent, item, low)

			local i = self:FindListI (item)
			if i > 0 then
				self.List:Select (i + 1)		-- Add one for "Root" entry
			end
		end
	else
		local fav = self.CurFav
		if fav and self.CurItemI then
			local i = Nx.Util_TMoveI (fav, self.CurItemI, low)
			if i then
				self.CurItemI = i
				self.ItemList:Select (i)
			end
		end
	end

	self:Update()
end

function Nx.Notes:But_OnItemDel()

	local fav = self.CurFav
	if fav and self.CurItemI then
		if fav[self.CurItemI] then
			tremove (fav, self.CurItemI)
		end
	end

	self:Update()
end

---------------------------------------------------------------------------------------
-- Create menu
---------------------------------------------------------------------------------------

function Nx.Notes:CreateMenu()

	local menu = Nx.Menu:Create (self.List.Frm, 250)
	self.Menu = menu

	menu:AddItem (0, L["Add Folder"], self.Menu_OnAddFolder, self)
	menu:AddItem (0, L["Add Favorite"], self.Menu_OnAddFavorite, self)
	menu:AddItem (0, "")
	menu:AddItem (0, L["Rename"], self.Menu_OnRename, self)
	menu:AddItem (0, L["Cut"], self.Menu_OnCut, self)
	menu:AddItem (0, L["Copy"], self.Menu_OnCopy, self)
	menu:AddItem (0, L["Paste"], self.Menu_OnPaste, self)

	local function func()
		Nx.Opts:Open ("Favorites")
	end

	menu:AddItem (0, "")
	menu:AddItem (0, L["Options"] .. "...", func)

	local menu = Nx.Menu:Create (self.List.Frm, 250)
	self.ItemMenu = menu

	menu:AddItem (0, L["Add Comment"], self.IMenu_OnAddComment, self)
	menu:AddItem (0, "")
	menu:AddItem (0, L["Rename"], self.IMenu_OnRename, self)
	menu:AddItem (0, L["Cut"], self.IMenu_OnCut, self)
	menu:AddItem (0, L["Copy"], self.IMenu_OnCopy, self)
	menu:AddItem (0, L["Paste"], self.IMenu_OnPaste, self)

	menu:AddItem (0, "")
	menu:AddItem (0, L["Set Icon"], self.IMenu_OnSetIcon, self)
end

function Nx.Notes:Menu_OnAddFolder (item)

	local function func (str, self)
		self:AddFolder (str, self.CurFolder)
		self:Update()
	end

	Nx:ShowEditBox (L["Name"], "", self, func)
end

function Nx.Notes:Menu_OnAddFavorite (item)

	local function func (str, self)
		self:AddFavorite (str, self.CurFolder)
		self:Update()
	end

	Nx:ShowEditBox (L["Name"], "", self, func)
end

function Nx.Notes:Menu_OnRename (item)

	local function func (str, self)
		if self.CurFavOrFolder then
			self.CurFavOrFolder["Name"] = str
			self:Update()
		end
	end

	if self.CurFavOrFolder then
		local name = self.CurFavOrFolder["Name"]
		Nx:ShowEditBox (L["Name"], name, self, func)
	end
end

function Nx.Notes:Menu_OnCut()

	local item = self.CurFavOrFolder
	if item then

		local parent = self:GetParent (item)

		for i, it in ipairs (parent) do
			if it == item then
				tremove (parent, i)
				self.CopyBuf = item
				self:Update()
			end
		end

		self:SelectCur()
	end
end

function Nx.Notes:Menu_OnCopy()

	local item = self.CurFavOrFolder
	if item then
		self.CopyBuf = Nx.Util_TCopyRecurse (item)
	end
end

function Nx.Notes:Menu_OnPaste()

	if not self.CopyBuf then
		Nx.prt (L["Nothing to paste"])
		return
	end

	if type (self.CopyBuf) ~= "table" then
		Nx.prt (L["Can't paste that on the left side"])
		return
	end

	local new = Nx.Util_TCopyRecurse (self.CopyBuf)
	local item = self.CurFav

	if item then
		local parent = self:GetParent (item)
		local i = Nx.Util_TFindItemI (parent, item)
		tinsert (parent, i, new)
	else
		tinsert (self.CurFolder, 1, new)
	end

	self:Update()
	self:SelectCur()
end

---------------------------------------------------------------------------------------

function Nx.Notes:IMenu_OnAddComment()

	local function func (str, self)
		local s = self:CreateItem ("", 0, str)
		self:AddItem (self.CurFav, self.CurItemI, s)
	end

	Nx:ShowEditBox (L["Name"], "", self, func)
end

function Nx.Notes:IMenu_OnRename()

	local function func (str, self)
		if self.CurFavOrFolder then
			self:SetItemName (self.CurItemI, str)
			self:Update()
		end
	end

	local typ, name = self:GetItemTypeName (self.CurItemI)
	Nx:ShowEditBox (L["Name"], name, self, func)
end

function Nx.Notes:IMenu_OnCut()
	local fav = self.CurFav
	if fav and self.CurItemI then

		if fav[self.CurItemI] then
			self.CopyBuf = fav[self.CurItemI]
			tremove (fav, self.CurItemI)
		end
	end

	self:Update()
end

function Nx.Notes:IMenu_OnCopy()
	local fav = self.CurFav
	if fav then
		self.CopyBuf = fav[self.CurItemI]
	end
end

function Nx.Notes:IMenu_OnPaste()

	if not self.CopyBuf then
		Nx.prt (L["Nothing to paste"])
		return
	end

	if type (self.CopyBuf) ~= "string" then
		Nx.prt (L["Can't paste that on the right side"])
		return
	end

	local fav = self.CurFav
	if fav then
		local i = min (self.CurItemI, #fav) + 1
		tinsert (fav, i, self.CopyBuf)
	end

	self:Update()
end

function Nx.Notes:IMenu_OnSetIcon()

	Nx.DropDown:Start (self, self.SetIconAccept)

	for i, name in ipairs (self.NoteIcons) do

		local iconStr = self:GetIconInline (i)
		local s = format ("%s", iconStr)

		Nx.DropDown:Add (s, false)
	end

	Nx.DropDown:Show (self.Win.Frm)
end

function Nx.Notes:SetIconAccept (name, sel)

	local fav = self.CurFav
	local index = self.CurItemI

	if fav and index then

		local item = fav[index]
		local typ, flags, name, data = self:ParseItem (item)

		flags = strbyte (flags) - 35

		if typ == "N" then
			local icon, id, x, y, level = self:ParseItemNote (data)
			fav[index] = self:CreateItem ("N", flags, name, sel, id, x, y, level)

			self:Update()
		end
	end
end

---------------------------------------------------------------------------------------
-- Show or hide
---------------------------------------------------------------------------------------

function Nx:NXFavKeyToggleShow()
	Nx.Notes:ToggleShow()
end

---------------------------------------------------------------------------------------
-- Show or hide
---------------------------------------------------------------------------------------

function Nx.Notes:ToggleShow()

	if not self.Win then
		self:Create()
	end

	self.Win:Show (not self.Win:IsShown())

	if self.Win:IsShown() then
		self:Update()
	end
end

---------------------------------------------------------------------------------------
-- Handle item list filter edit box
---------------------------------------------------------------------------------------

function Nx.Notes:OnEditBox (editbox, message)

	if message == "Changed" then
		self:Update()
	end
end

---------------------------------------------------------------------------------------
-- On list events
---------------------------------------------------------------------------------------

function Nx.Notes:OnListEvent (eventName, sel, val2, click)

	-- Nx.prt ("Notes list event "..eventName)

	local data = self.List:ItemGetData (sel)

	if not data then
		self.CurFolder = self.Folders
		self.CurFav = nil
	else
		if data["T"] == "F" then
			self.CurFolder = data
			self.CurFav = nil
		else
			self.CurFolder = self:GetParent (data)
			self.CurFav = data
			self:SelectItems (1)
		end
	end

	self.CurFavOrFolder = data	-- This is nil if root

	self.Side = 1

	if eventName == "select" or eventName == "mid" or eventName == "menu" then

		if eventName == "menu" then
			if type(self.CurFav) == "string" then
				self.Menu:Show(-1)
			else
				self.Menu:Show(1)
			end
			self.Menu:Open()
		end

		self:Update()

	elseif eventName == "button" then	-- Button icon

		self.List:Select (sel)
		if data then
			if type(data) == "string" then
				data = addonNotes
			end
			if data["Hide"] then
				data["Hide"] = nil
			else
				data["Hide"] = true
			end
			self:Update()
		end
	end
end

---------------------------------------------------------------------------------------
-- On item list events
---------------------------------------------------------------------------------------

function Nx.Notes:OnItemListEvent (eventName, sel, val2, click)

--	Nx.prt ("List event "..eventName)

	local list = self.ItemList

	local item = list:ItemGetData (sel)

	self.CurItemI = sel
	self.Side = 2

	if eventName == "select" or eventName == "mid" or eventName == "menu" then

		if eventName == "menu" then
			self.ItemMenu:Show (self.CurFav and true or -1)
			if type(self.CurFav) == "string" then
				self.ItemMenu:Show(-1)
			end
			self.ItemMenu:Open()
		end

	elseif eventName == "button" then	-- Button icon

		local flags = val2 and 1 or 0		-- Pressed
		self:SetItemFlags (sel, 0xfe, flags)

	end

	self:SelectItems (sel)
	self:Update()
end

---------------------------------------------------------------------------------------
-- Update Fav
---------------------------------------------------------------------------------------

function Nx.Notes:Update()

	self.Draw = false		-- Force map to update icons

	local Nx = Nx

	if not self.Win then
		return
	end

	-- List

	local list = self.List

	list:Empty()

	list:ItemAdd()
	list:ItemSet (2, "|cff808080Root")

	self.FavCnt = 0

	self:UpdateFolder (self.Folders, 1)
	self:AddonFolders(1)
	list:Update()
	-- Right side list

	self:UpdateItems()

	-- Title

	self.Win:SetTitle (format (L["Notes"] .. ": %s", self.FavCnt))
end

function Nx.Notes:AddonFolders(level)
	local list = self.List
	local hide = addonNotes.Hide
	list:ItemAdd("addons")
	list:ItemSet(2,"  " .. L["Note Addons"])
	list:ItemSetButton ("QuestHdr", hide)
	if not hide then
		for a,b in pairs(addonNotes) do
			if a ~= "Hide" then
				local space = strrep ("  ", level+1)
				list:ItemAdd(a)
				list:ItemSet(2, format ("%s|cffdfdfdf%s",space,a))
			end
		end
	end
end

function Nx.Notes:UpdateFolder (folder, level)

	local list = self.List

	local hide = folder["Hide"]

	if level > 1 then
		list:ItemAdd (folder)
		local space = strrep ("  ", level - 1)
		list:ItemSet (2, format ("%s%s", space, folder["Name"]))
		list:ItemSetButton ("QuestHdr", hide)
	end

	if not hide then

		local space = strrep ("  ", level)

		for index, item in ipairs (folder) do

			local typ = item["T"]
			local name = item["Name"]

			if typ == "F" then
				self:UpdateFolder (item, level + 1)
			else

				self.FavCnt = self.FavCnt + 1

				list:ItemAdd (item)
				list:ItemSet (2, format ("%s|cffdfdfdf%s", space, name))

				if self.FavToSelect == item then
					self.FavToSelect = nil
					list:Select (list:ItemGetNum())
				end
			end
		end
	end
end

function Nx.Notes:UpdateItems (selectI)

	local list = self.ItemList

	if not list then
		return
	end

	list:Empty()

	if self.CurFav then
		if type(self.CurFav) == "string" then
			if self.CurFav == "addons" then
				selectI = 0
			else
				if self.CurFav ~= "Hide" then
					if addonNotes[self.CurFav] then
						for a,b in pairs (addonNotes[self.CurFav]["notes"]) do
							local name, data = a,b
							list:ItemAdd(item)
							local icon, id, x, y, level = self:ParseItemNote (data)
							icon = self:GetIconInline (icon)
							id = Nx.Map:GetMapNameByID(id) or "?"
							list:ItemSet (2, "Note:")
							list:ItemSet (3, format ("%s %s", icon, name))
							list:ItemSet (4, format ("|cff80ef80(%s %.1f %.1f)", id, x, y))
						end
					end
				end
			end
		else
			for index, str in ipairs (self.CurFav) do

				local typ, flags, name, data = self:ParseItem (str)

				list:ItemAdd (item)
				list:ItemSetButton ("Chk", bit.band (strbyte (flags) - 35, 1) > 0)

				if typ == "" then			-- Comment
					list:ItemSet (3, format ("|cffa0a0a0-- %s", name))

				elseif typ == "N" then			-- Note

					local icon, id, x, y, level = self:ParseItemNote (data)
					icon = self:GetIconInline (icon)
					local newid = Nx.Map:GetMapNameByID(id) or "?"
					list:ItemSet (2, L["Note"] .. ":")
					list:ItemSet (3, format ("%s %s", icon, name))
					list:ItemSet (4, format ("|cff80ef80(%s %.1f %.1f)", newid, x, y))

				elseif typ == "T" or typ == "t" then			-- Target

					local typName = typ == "T" and "Target 1st" or "Target"
					local mapId, x, y = self:ParseItemTarget (data)
					local mapName = Nx.Map:GetMapNameByID(mapId) or "?"
					list:ItemSet (2, format ("%s:", typName))
					list:ItemSet (3, format ("%s", name))
					list:ItemSet (4, format ("|cff80ef80(%s %.1f %.1f)", mapName, x, y))
				end
			end
		end
	end

	if selectI then
		list:Select (selectI)
	end

	list:Update()
end

---------------------------------------------------------------------------------------
-- Select current favorite
---------------------------------------------------------------------------------------

function Nx.Notes:SelectCur()

	self.List:SendUserSelect()
	self:SelectItems (1)
end

---------------------------------------------------------------------------------------
-- Get the parent of the item
-- (item, folder to start search or nil for root)
---------------------------------------------------------------------------------------

function Nx.Notes:GetParent (item, folder)

	folder = folder or self.Folders

	for _, it in ipairs (folder) do

		if it == item then
			return folder
		end

		local typ = it["T"]
		if typ == "F" then
			local v = self:GetParent (item, it)
			if v then
				return v
			end
		end
	end
end

---------------------------------------------------------------------------------------
-- Find a folder by name
-- (name)
---------------------------------------------------------------------------------------

function Nx.Notes:FindFolder (name, parent)

	parent = parent or self.Folders

	for _, item in ipairs (parent) do

		if item["T"] == "F" then
			if item["Name"] == name then
				return item
			end
		end
	end
end

---------------------------------------------------------------------------------------
-- Find a favorite by a variable name
-- (name)
---------------------------------------------------------------------------------------

function Nx.Notes:FindFav (val, varName, parent)

	parent = parent or self.Folders

	for _, item in ipairs (parent) do

		if item["T"] == nil then
			if item[varName] == val then
				return item
			end
		end
	end
end

---------------------------------------------------------------------------------------
--
-- (item)
---------------------------------------------------------------------------------------

function Nx.Notes:OpenFoldersToFav (item, folder)

	folder = folder or self.Folders

	for index, it in ipairs (folder) do

		if it == item then
			return index
		end

		if it["T"] == "F" then

			index = self:OpenFoldersToFav (item, it)

			if index then	-- Found?
				it["Hide"] = nil
				return index
			end
		end
	end
end

---------------------------------------------------------------------------------------
-- Find the index where an item would be in list
-- (item)
---------------------------------------------------------------------------------------

function Nx.Notes:FindListI (item, folder, index)

	folder = folder or self.Folders
	index = index or 1

	for _, it in ipairs (folder) do

		if it == item then
			return index
		end

		index = index + 1

		if it["T"] == "F" then
			if not it["Hide"] then
				index = self:FindListI (item, it, index)
				if index > 0 then	-- Found?
					return index
				end
				index = -index
			end
		end
	end

	return -index		-- Failed
end

function Nx.Notes:AddFolder (name, parent, index)

	local folder = {}
	folder["Name"] = name
	folder["T"] = "F"

	parent = parent or self.Folders

	if parent then
		index = index or #parent + 1
		tinsert (parent, index, folder)
	end

	return folder
end

function Nx.Notes:AddFavorite (name, parent, index)

	local fav = {}
	fav["Name"] = name

	parent = parent or self.Folders

	if parent then
		index = index or #parent + 1
		tinsert (parent, index, fav)
	end

	return fav
end

function Nx.Notes:AddItem (fav, index, item)

--	Nx.prt ("Fav AddItem %s #%s %s", fav["Name"], index or "nil", item)

	if fav then

		local i = max (min (index or 999999, #fav), 0) + 1
		tinsert (fav, i, item)

		self:SelectItems (i)
	end
end

function Nx.Notes:CreateItem (typ, flags, name, p1, p2, p3, p4, p5)

	p5 = p5 or 0

	flags = flags + 35

	name = gsub (name, "[~^]", "")
	name = gsub (name, "\n", " ")

	if typ == "" then			-- Comment
		return format ("~%c~%s", flags, name)

	elseif typ == "N" then	-- Note
		return format ("N~%c~%s~%s|%s|%s|%s|%s", flags, name, p1, p2, p3,p4, p5)
	elseif typ == "T" or typ == "t" then	-- Target		
		return format ("%s~%c~%s~%s|%s|%s|%s", typ, flags, name, p1, p2, p3, p5)
	end
end

function Nx.Notes:MakeXY (x, y)
	local s = Nx:PackXY (x, y % 100)
	return s .. strchar (floor (y / 100) + 35)	-- Add dungeon level to end
end

function Nx.Notes:ParseItem (item)
	if item then
		return strsplit ("~", item)	-- Type~Flags (# based)~Name~Data
	end
end

function Nx.Notes:ParseItemNote (data)
	local iconI,zone,x,y, dLvl = Nx.Split("|",data)
	if not dLvl then
		dLvl = 0
	end
	return tonumber(iconI), tonumber(zone), tonumber(x), tonumber(y), tonumber(dLvl)
end

function Nx.Notes:ParseItemTarget (data)
	local zone, x, y, dLvl = Nx.Split("|",data)
	if not dLvl then
		dLvl = 0
	end
	return tonumber(zone), tonumber(x), tonumber(y), tonumber(dLvl)
end

function Nx.Notes:GetItemTypeName (index)

	local fav = self.CurFav
	if fav then
		local typ, flags, name = strsplit ("~", fav[index])
		return typ, name
	end
end

function Nx.Notes:SetItemFlags (index, mask, orFlags)

	local fav = self.CurFav
	if fav then
		local typ, flags, name, data = strsplit ("~", fav[index])

		flags = bit.bor (bit.band (strbyte (flags) - 35, mask), orFlags) + 35

		if data then
			fav[index] = format ("%s~%c~%s~%s", typ, flags, name, data)
		else
			fav[index] = format ("%s~%c~%s", typ, flags, name)
		end
	end
end

function Nx.Notes:SetItemName (index, name)

	name = gsub (name, "[~^]", "")
	name = gsub (name, "\n", " ")

	local fav = self.CurFav
	if fav then
		local typ, flags, _, data = strsplit ("~", fav[index])
		if data then
			fav[index] = format ("%s~%s~%s~%s", typ, flags, name, data)
		else
			fav[index] = format ("%s~%s~%s", typ, flags, name)
		end
	end
end

---------------------------------------------------------------------------------------
-- Select items in item list
---------------------------------------------------------------------------------------

function Nx.Notes:SelectItems (index)

	if self.CurFav then

		if self.Recording ~= self.CurFav then
			self:SetRecord (false)
		end

		self.CurItemI = min (index, #self.CurFav)

		self:UpdateItems (self.CurItemI)

		self:UpdateTargets()
	end
end

---------------------------------------------------------------------------------------

function Nx.Notes:Record (typ, name, id, x, y, level)
	if self.InUpdateTarget then
		return
	end

	local fav = self.Recording

	self.RecId = id
	self.RecX = x
	self.RecY = y
	self.RecL = level or 0
	if typ == "Note" then

		local function func (name, self)
			local fav = self.Recording or self:GetNoteFav (self.RecId)
			local s = self:CreateItem ("N", 0, name, 1, self.RecId, self.RecX, self.RecY, self.RecL)
			self:AddItem (fav, self.CurItemI, s)
			self:Update()
		end

		Nx:ShowEditBox ("Name", name, self, func)

	elseif typ == "TargetS" then	-- Start

		local fav = self.Recording
		if fav then
			local s = self:CreateItem ("T", 0, name, self.RecId, self.RecX, self.RecY, self.RecL)
			self:AddItem (fav, self.CurItemI, s)
			self:Update()
		end

	elseif typ == "Target" then

		local fav = self.Recording
		if fav then
			local s = self:CreateItem ("t", 0, name, self.RecId, self.RecX, self.RecY, self.RecL)
			self:AddItem (fav, self.CurItemI, s)
			self:Update()
		end
	end
end

function Nx.Notes:GetNoteFav (mapId)

	local notes = self:FindFolder (L["My Notes"])

	if not notes then
		notes = self:AddFolder (L["My Notes"])
	end

	local name = Nx.Map:IdToName (mapId)

	local fav = self:FindFav (name, "Name", notes)

	if not fav then
		fav = self:AddFavorite (name, notes)
		fav["ID"] = mapId
		sort (notes, function (a, b) return a["Name"] < b["Name"] end)
	end

	return fav
end

function Nx.Notes:SetNoteAtStr (str)

	local words = {}
	local quote
	local strDone
	local curStr = ""

	for s in gmatch (str, ".") do

--		Nx.prt ("%s", s)

		if s == quote then
			quote = false
			strDone = true

		elseif not quote and (s == '"' or s == "'") then
			quote = s

		elseif s == ' ' and not quote then
			strDone = true

		else
			curStr = curStr .. s
		end

		if strDone then
			if #curStr > 0 then
				tinsert (words, curStr)
			end
			strDone = false
			curStr = ""
		end
	end

	if #curStr > 0 then
		tinsert (words, curStr)
	end

	--

	local map = Nx.Map:GetMap (1)

	local mId = map.RMapId
	local zx, zy = map.PlyrRZX, map.PlyrRZY
	local level = map.DungeonLevel
	
	if #words > 1 then
		mId, zx, zy = map:ParseTargetStr (table.concat (words, " ", 2))
	end

	if mId then
		local fav = self.Recording or self:GetNoteFav (mId)
		local s = self:CreateItem ("N", 0, words[1] or "", 1, mId, zx, zy, level)
		self:AddItem (fav, nil, s)
		self:Update()
	end
end

---------------------------------------------------------------------------------------
-- Show note in window
---------------------------------------------------------------------------------------

function Nx.Notes:ShowIconNote (icon)

	local fav, index = Nx.Map:GetIconFavData (icon)

	self:OpenFoldersToFav (fav)
	self.FavToSelect = fav

	self.CurFolder = self:GetParent (fav)
	self.CurFav = fav
	self.CurItemI = index

	self.CurFavOrFolder = fav

	if not (self.Win and self.Win:IsShown()) then
		self:ToggleShow()
		if not self.Win then		-- Not validated?
			return
		end
	else
		self:Update()
	end

	self:SelectItems (index)
end

function Nx.Notes:UpdateTargets()

	local shown = self.Win and self.Win:IsShown()

	if self.CurFav and self.CurItemI	and (self.Recording or shown) then

		self.InUpdateTarget = true

		local map = Nx.Map:GetMap (1)

		local keep

		for n = self.CurItemI, #self.CurFav do

			local str = self.CurFav[n]
			local typ, flags, name, data = self:ParseItem (str)
			if typ == "T" then

				if n ~= self.CurItemI then		-- Another 1st target?
					break
				end

				local mapId, x, y = self:ParseItemTarget (data)
				map:SetTargetXY (mapId, x, y, name, keep)
				keep = true

			elseif typ == "t" then

				local mapId, x, y = self:ParseItemTarget (data)
				map:SetTargetXY (mapId, x, y, name, keep)
				keep = true

			else

				break
			end
		end

		if keep then	-- Had a target?
			map:GotoPlayer()
		end

		self.InUpdateTarget = false
	end
end

---------------------------------------------------------------------------------------
--
---------------------------------------------------------------------------------------

function Nx.Notes:UpdateIcons()
	local Map = Nx.Map
	local map = Map:GetMap (1)

	if self.CurFav and self.CurItemI then

		map:InitIconType ("!Fav2", "WP", "", 21, 21)
		local str
		local typ, flags, name, data
		if type(self.CurFav) == "string" then
		else
			str = self.CurFav[self.CurItemI]
			typ, flags, name, data = self:ParseItem (str)
		end

		if typ == "N" then

			local icon, mapId, x, y, level = self:ParseItemNote (data)
			icon = self:GetIconFile (icon)
			local wx, wy = Map:GetWorldPos (mapId, x, y)

			local icon = map:AddIconPt ("!Fav2", wx, wy, level, nil, icon)
			map:SetIconTip (icon, L["Note"] .. ": " .. name)
			map:SetIconFavData (icon, self.CurFav, self.CurItemI)

			map:SetIconTypeAlpha ("!Fav2", abs ((GetTime() * 100 % 100 - 50) / 50))
		end

	else
		map:ClearIconType ("!Fav2")
	end
	
	local mapId = map.MapId
	local draw = map.ScaleDraw > .3 and Nx.fdb.profile.Notes.ShowMap

	if mapId == self.DrawMapId and draw == self.Draw and self.InstLevelSet == Nx.Map:GetCurrentMapDungeonLevel() then
		return
	end

	self.DrawMapId = mapId
	self.Draw = draw

	map:InitIconType ("!Fav", "WP", "", 17, 17)
--	map:SetIconTypeAlpha ("!Fav", map.GOpts["MapIconFavAlpha"])

	if not draw and self.InstLevelSet == Nx.Map:GetCurrentMapDungeonLevel() then
		return
	end
	
	self.InstLevelSet = Nx.Map:GetCurrentMapDungeonLevel()
	
	local cont = map:IdToContZone (mapId)
	cont = tonumber(cont)
--	Nx.prt ("mapid %s, cont %s", mapId, cont)

	if cont > 0 and cont < 90 then

		local notes = self:FindFolder (L["My Notes"])

		if notes then

			local fav = self:FindFav (mapId, "ID", notes)
			if fav then
				for n, str in ipairs (fav) do
					local typ, flags, name, data = self:ParseItem (str)

					if typ == "N" then
						local icon, _, x, y, level = self:ParseItemNote (data)
						icon = self:GetIconFile (icon)
						local wx, wy = Map:GetWorldPos (mapId, x, y)

						local icon = map:AddIconPt ("!Fav", wx, wy, level, nil, icon)
						map:SetIconTip (icon, L["Note"] .. ": " .. name)
						map:SetIconFavData (icon, fav, n)
					end
				end
			end
		end
		for a,b in pairs(addonNotes) do
			if a ~= "Hide" then
				for c,d in pairs(addonNotes[a]["notes"]) do
					local icon, zoneid, x, y, level = self:ParseItemNote(d)
					if zoneid == mapId then
						icon = self:GetIconFile (icon)
						local wx, wy = Map:GetWorldPos(mapId,x,y)
						local icon = map:AddIconPt("!Fav", wx, wy, level, nil, icon)
						map:SetIconTip(icon, L["Note"] .. ": " .. c)
						map:SetIconFavData(icon, fav, d)
					end
				end
			end
		end
		Nx.Notes:HandyNotes(mapId)
		--WorldMap_HijackTooltip(map.Frm)
		GameTooltip:Hide()		
	end
end

function Nx.Notes:HandyNotes(mapId)
	local map = Nx.Map:GetMap (1)
	if (Nx.fdb.profile.Notes.HandyNotes and HandyNotes) then
		if C_Map.GetMapInfo(mapId).mapType ~= 3 then
			return
		end
		map:InitIconType ("!HANDY", "WP", "", Nx.fdb.profile.Notes.HandyNotesSize or 15, Nx.fdb.profile.Notes.HandyNotesSize or 15)
		map:SetIconTypeChop ("!HANDY", true)
		map:SetIconTypeLevel ("!HANDY", 20)
		--local mapFile, textureHeight, textureWidth, isMicroDungeon, microDungeonMapName = GetMapInfo()
		local lvl = Nx.Map:GetCurrentMapDungeonLevel()
		--if isMicroDungeon then mapFile = microDungeonMapName end
		for pluginName, pluginHandler in pairs(HandyNotes.plugins) do
			HandyNotes:UpdateWorldMapPlugin(pluginName)
			local pluginNodes, mapFile
			if type(pluginHandler.GetNodes) == "function" then
				mapFile = select(3, Nx.Map:GetLegacyMapInfo(mapId))
				pluginNodes = {pluginHandler:GetNodes(mapFile, false, lvl)}
			else
				pluginNodes = {pluginHandler:GetNodes2(mapId, false)}
			end
			Nx.pluginNodes = pluginNodes
			for coord, mapFile2, iconpath, scale, alpha, level2 in unpack(pluginNodes) do				
				local x, y = floor(coord / 10000) / 100, (coord % 10000) / 100
				local texture
				local wx, wy = Nx.Map:GetWorldPos(mapId,x,y)
				local x1, x2, y1, y2
				if type(iconpath) == "table" then
					texture = iconpath.icon
					if iconpath.tCoordLeft then
						x1 = iconpath.tCoordLeft
						x2 = iconpath.tCoordRight
						y1 = iconpath.tCoordTop
						y2 = iconpath.tCoordBottom
					end
				else
					texture = iconpath
				end						
				local icon = CreateFrame("Frame", "HandyCarb", UIParent)
				local tmpFrame = WorldMapFrame:GetCanvas()
				icon:SetParent(tmpFrame)
				icon:ClearAllPoints()
				icon:SetHeight(scale)
				icon:SetWidth(scale)
				icon:SetPoint("CENTER", tmpFrame, "TOPLEFT", x*tmpFrame:GetWidth(), -y*tmpFrame:GetHeight())
				safecall(HandyNotes.plugins[pluginName].OnEnter, icon, mapFile and mapFile or mapId, coord)
				local tooltip = ""
				local tooltipName = "GameTooltip"
				local handynote
				if x1 then
					handynote = map:AddIconPt("!HANDY", wx, wy, level2, "FFFFFF", texture, x1, x2, y1, y2)
				else
					handynote = map:AddIconPt("!HANDY", wx, wy, level2, "FFFFFF", texture)
				end
				for i = 1,10 do
					local text = _G[tooltipName .. "TextLeft" .. i]
					if text and text:IsShown() then
						local R, G, B, A = text:GetTextColor()
						R = Nx.Util_dec2hex(R * 255)
						G = Nx.Util_dec2hex(G * 255)
						B = Nx.Util_dec2hex(B * 255)
						if strlen(tooltip) == 0 then
							tooltip = "|cFF" .. R .. G .. B .. text:GetText()
						else
							tooltip = tooltip .. "\n" .. "|cFF" .. R .. G .. B .. text:GetText()
						end
					end
				end
				map:SetIconTip(handynote,tooltip)
				safecall(HandyNotes.plugins[pluginName].OnLeave, icon, mapFile and mapFile or mapId, coord)
			end
		end
	end
end

---------------------------------------------------------------------------------------

function Nx.Notes:OnButToggleFav (but)
	Nx.Notes:ToggleShow()
end

---------------------------------------------------------------------------------------
-- Get Favorite data
---------------------------------------------------------------------------------------

function Nx:GetFav()
	return Nx.fdb.profile.Notes
end

function Nx.Notes:Menu_OnAddNote()
	local map = Nx.Map:GetMap (1)
	local mId = map.RMapId
	local wx, wy = self:FramePosToWorldPos (self.ClickFrmX, self.ClickFrmY)
	local zx, zy = self:GetZonePos (mId, wx, wy)
	local level = map.DungeonLevel
	Nx.Notes:AddNote ("?", mId, zx, zy, level)
end

function Nx.Notes:AddNote (name, id, x, y, level)
		Nx.Notes:Record ("Note", name, id, x, y, level)
end

function Nx.Notes:AddonNote(folder,name,icon,id,x,y)
	if not addonNotes[folder] then
		addonNotes[folder] = {}
		addonNotes[folder]["notes"] = {}
	end
	addonNotes[folder]["notes"][name] = icon .. "|" .. id .. "|" .. x .. "|" .. y
end
-- Nx.Notes:AddonNote("Test2","Test",4,301,33.3,33.3)
---------------------------------------------------------------------------------------
-- EOF
