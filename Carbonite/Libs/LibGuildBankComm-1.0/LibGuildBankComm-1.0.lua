--- **LibGuildBankComm-1.0** synchronizes guild bank data across all guild members running the library or some embedding addon.
-- Data is stored privately within the library but can be accessed through the functions below.
-- See the [[examples]] page for information regarding the available callbacks and more complete examples of using the Library in your addons.
-- @class file
-- @name LibGuildBankComm-1.0
-- @release $Id: LibGuildBankComm-1.0.lua 79 2016-12-03 09:37:45Z myrroddin $

--[[
Name: LibGuildBankComm-1.0
Revision: $Revision: 79 $
Date: $Date: 2016-12-03 03:37:45 -0600 (Sat, 03 Dec 2016) $
Author(s): Myrroddin of Llane (Alliance US), Lyte of Lothar (Alliance US)
Description: Saves guild bank contents and sends/receives updates over the addon channel
Dependencies: LibStub, CallbackHandler-1.0, AceComm-3.0, AceSerializer-3.0, LibCompress
]]--

local MAJOR_VERSION = "LibGuildBankComm-1.0"
local MINOR_VERSION = tonumber(("$Revision: 79 $"):match("%d+"))

if not LibStub then error(MAJOR_VERSION.."requires LibStub") end
local lib, oldversion = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

local _G = getfenv(0)

LibStub("AceSerializer-3.0"):Embed(lib)
LibStub("AceComm-3.0"):Embed(lib)
local LibCompress = LibStub("LibCompress")
local LibEncode = LibCompress:GetAddonEncodeTable()

local TIMER_DELAY = 15 --the delay between a permissions update and actually requesting new data
local guildBank = {}
local noData = true
local waitingForReply
local playerUnguilded --set when the player leaves his/her guild, reset when they join a new one
local NOP = function() end
local playerName = UnitName("player")

local function printError(action, err)
	print(format("%s - Error during %s: %s"), MAJOR_VERSION, action, err)
end

lib.eventFrame = lib.eventFrame or CreateFrame("Frame")
lib.eventFrame:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)
lib.eventFrame:SetScript("OnShow", function(self)
	self.elapsed = 0
end)
lib.eventFrame:SetScript("OnUpdate", function(self, elapsed)
	elapsed = self.elapsed + elapsed
	if elapsed >= TIMER_DELAY then
		self:Hide()
		
		--clear any data the player should not see with current permissions
		if not noData then
			for i = 1, guildBank.numTabs do
				local _, _, canView = GetGuildBankTabInfo(i)
				if (not canView) and guildBank[i] then
					wipe(guildBank[i].links)
					wipe(guildBank[i].stacks)
				end
			end
		end
		
		waitingForReply = true
		lib:SendCommMessage("LGBC", "ANNOUNCE ", "GUILD", nil, "BULK") --Hey, I need fresh data!
	end
	self.elapsed = elapsed
end)
lib.eventFrame:UnregisterAllEvents()
lib.eventFrame:Hide()

lib.callbacks = lib.callbacks or LibStub("CallbackHandler-1.0"):New(lib)

function lib:OnCommReceived(prefix, msg, distribution, sender)
	if prefix ~= "LGBC" then return end
    if sender == playerName then return end
	
	local guildName = GetGuildInfo("player")	
	local command, value = msg:match("^(%S+) (.*)$")
	
	if command == "ANNOUNCE" then
		if not noData then
			--somebody pinged us and we have data, send a reply
			lib:SendCommMessage("LGBC", "REPLY ", "WHISPER", sender, "BULK")
		end
	elseif command == "REPLY" then
		--we received a reply from our login ping
		if waitingForReply then
			--if we were waiting for a reply, we aren't anymore
			waitingForReply = false
			--send a request for data to that player
			lib:SendCommMessage("LGBC", "REQUEST ", "WHISPER", sender, "BULK")
		end
	elseif command == "REQUEST" and not noData then
		local numTabs = guildBank.numTabs
		
		local commTabs = ("TABS %d"):format(numTabs)
		lib:SendCommMessage("LGBC", commTabs, "WHISPER", sender, "BULK")
		
		for page = 1, numTabs do
			local _, _, canView = GetGuildBankTabInfo(page)
			if canView then
				local serialized_data = lib:Serialize(guildBank[page])
				local compressed_data = LibCompress:CompressHuffman(serialized_data)
				local transmit_data = LibEncode:Encode(compressed_data)
				
				-- Construct a comm string for the compressed data.
				local commString = ("UPDATE_PAGE_%d "):format(page) .. transmit_data
				lib:SendCommMessage("LGBC", commString, "WHISPER", sender, "BULK")
			end
		end
		
		local commFunds = "FUNDS "..tostring(guildBank.guildFunds)
		lib:SendCommMessage("LGBC", commFunds, "WHISPER", sender, "BULK")
	elseif command == "FUNDS" then
		local f = tonumber(value)
		guildBank.guildFunds = f
		lib.callbacks:Fire("GuildBankComm_FundsUpdate", sender, f, guildName)
	elseif command == "TABS" then
		local n = tonumber(value)
		guildBank.numTabs = n
		lib.callbacks:Fire("GuildBankComm_TabsUpdate", sender, n, guildName)
	elseif command:find("^UPDATE_PAGE_%d+$") then
		local page = command:match("^UPDATE_PAGE_(%d+)$")
		page = tonumber(page)
		local _, _, canView = GetGuildBankTabInfo(page)
		
		if canView then
			local decoded_data = LibEncode:Decode(value)
			local decompressed_data, decompression_error = LibCompress:Decompress(decoded_data)
			if not decompressed_data then
				return printError("decompression", decompression_error)
			end
			
			local success, deserialized_data = lib:Deserialize(decompressed_data)
			if not success then
				return printError("deserialization", deserialized_data)
			end
			
			guildBank[page] = deserialized_data
			if page == guildBank.numTabs then noData = false end
			lib.callbacks:Fire("GuildBankComm_PageUpdate", sender, page, guildName)
		end
	end
end

lib:RegisterComm("LGBC")

function lib.eventFrame:PLAYER_ENTERING_WORLD()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	waitingForReply = true
	lib:SendCommMessage("LGBC", "ANNOUNCE ", "GUILD", nil, "BULK") --Hey, I need fresh data!
	
	--register the guild events now, since they fire so often before this event
	self:RegisterEvent("PLAYER_GUILD_UPDATE")
	--self:RegisterEvent("GUILDBANK_UPDATE_WITHDRAWMONEY")
end

function lib.eventFrame:PLAYER_GUILD_UPDATE()
	if not IsInGuild() then
		--when a player is no longer in a guild, wipe the bank
		wipe(guildBank)
		playerUnguilded = true
	else
		--if the player is in a guild, check if it is new
		if playerUnguilded then
			playerUnguilded = false
			waitingForReply = true
			lib:SendCommMessage("LGBC", "ANNOUNCE ", "GUILD", nil, "BULK") --Hey, I need fresh data!
		end
	end
end

function lib.eventFrame:GUILDBANK_UPDATE_WITHDRAWMONEY()
	--this event seems to fire for any permission change, not just the amount of money a player can take
	--this event only fires for the associated rank, and when a player is promoted/demoted
	--this even also fires for the Guild Master any time a change is made to permissions
	
	--this event can be spammy, each time we receive one delay the update request by TIMER_DELAY seconds
	self:Hide() --reset if the timer is already running
	self:Show() --start the timer
end

function lib.eventFrame:GUILDBANKFRAME_OPENED()
	guildBank.numTabs = GetNumGuildBankTabs()
	guildBank.guildFunds = GetGuildBankMoney()
	
	local name, icon
	for page = 1, guildBank.numTabs do
		name, icon = GetGuildBankTabInfo(page)
		
		if not guildBank[page] then
			guildBank[page] = {
				links = {},  --store the slot item links here
				stacks = {}, --store the slot stack counts here
				name = name,
				texture = icon
			}
		end
	end
	noData = false
	waitingForReply = false --if we get our own data from the bank, we don't need to sync
	
	--register the _CLOSED event whenever the bank is opened
	self:RegisterEvent("GUILDBANKFRAME_CLOSED")
end

function lib.eventFrame:GUILDBANK_UPDATE_MONEY()
	guildBank.guildFunds = GetGuildBankMoney()
end

function lib.eventFrame:GUILDBANK_UPDATE_TABS()
	local t = GetNumGuildBankTabs()
	guildBank.numTabs = t
	
	--if a new tab was purchased create the necessary 
	--storage structure
	if not guildBank[t] then
		local name, icon = GetGuildBankTabInfo(t)
		guildBank[t] = {
			links = {},
			stacks = {},
			name = name, 
			texture = icon
		}
	end
end

local num, itemString
function lib.eventFrame:GUILDBANKBAGSLOTS_CHANGED()
	if (GuildBankFrame and GuildBankFrame:IsVisible()) or (BagnonFrameguildbank and BagnonFrameguildbank:IsVisible()) then
		local page = GetCurrentGuildBankTab()
		
		--98 slots on a page
		for slot = 1, 98 do
			--see if the slot has an item in it
			if GetGuildBankItemLink(page, slot) then
				--if there is link, parse the ID and place that in table w/ key = slot
				_, _, itemString = string.find(GetGuildBankItemLink(page, slot), "^|c%x+|H(.+)|h%[.+%]")
				guildBank[page].links[slot] = itemString
				
				--get item info too, need for stack sizes in image
				_, num = GetGuildBankItemInfo(page, slot)
				guildBank[page].stacks[slot] = num
			else
				-- that slot is empty
				guildBank[page].links[slot] = nil
				guildBank[page].stacks[slot] = nil
			end
			num, itemString = nil, nil
		end
		
		--save a timestamp for this scan
		guildBank[page].lastScan = time()
	end
end

function lib.eventFrame:GUILDBANKFRAME_CLOSED()
	--we only need the first of the two _CLOSED events
	self:UnregisterEvent("GUILDBANKFRAME_CLOSED")
	
	-- we want to filter what the player sees
	-- and only send that rather than the whole of lib.guildBank	
	local guildName = GetGuildInfo("player")
	local numTabs = guildBank.numTabs

	local commTabs = ("TABS %d"):format(numTabs)
	lib:SendCommMessage("LGBC", commTabs, "GUILD", nil, "BULK")
	
	for page = 1, numTabs do
		local _, _, canView = GetGuildBankTabInfo(page)
		if canView then
			local serialized_data = lib:Serialize(guildBank[page])
			local compressed_data = LibCompress:CompressHuffman(serialized_data)
			local transmit_data = LibEncode:Encode(compressed_data)
				
			-- Construct a comm string for the compressed data.
			local commString = ("UPDATE_PAGE_%d "):format(page) .. transmit_data
			lib:SendCommMessage("LGBC", commString, "GUILD", nil, "BULK")
		end
	end
	
	--it is assumed the funds change often enough due to guild perks
	--that we should always send the latest value across
	local commFunds = "FUNDS "..tostring(guildBank.guildFunds)
	lib:SendCommMessage("LGBC", commFunds, "GUILD", nil, "BULK")
end

--- Returns the current guild funds in copper
-- @usage
-- local LGBC = LibStub("LibGuildBankComm-1.0")
-- local copper = LGBC:GetGuildFunds()
-- print("You have", GetCoinText(copper), "in your guild bank.")
function lib:GetGuildFunds()
	return guildBank.guildFunds or 0
end

--- Returns the current number of bank tabs owned by the guild
-- @usage
-- local LBGC = LibStub("LibGuildBankComm-1.0")
-- local numTabs = LGBC:GetNumBankTabs()
-- print("Your guild bank has", numTabs, "tabs.")
function lib:GetNumBankTabs()
	return guildBank.numTabs or 0
end

--- Returns the specified page's name and tab icon texture path
-- @param page The page number that you want the information from. Must be between 1 and the number of available tabs, inclusive.
-- @usage
-- local LGBC = LibStub("LibGuildBankComm-1.0")
-- local numTabs = LGBC:GetNumBankTabs()
-- for i = 1, numTabs do
--     local name, icon = LGBC:GetTabInfo(i)
--     print("Guild bank tab", i, "is called", name)
-- end
function lib:GetTabInfo(page)
	--make sure it's a number
	if type(page) ~= "number" then
		error("LibGuildBankComm:GetTabInfo(page) expected number", 2)
	end
	--make sure we have data
	if noData then return end
	--make sure it's a valid number
	if page < 1 or page > guildBank.numTabs then
		error(("LibGuildBankComm:GetTabInfo(page) : page must be between 1 and %d inclusive"):format(guildBank.numTabs), 2)
	end
	--make double sure we have data
	if not guildBank[page] then return end
	
	return guildBank[page].name, guildBank[page].texture
end

--- Returns an iterator over both the links and stack counts for the slots of the given page
-- This iterator will always yield a slot number (1-98, inclusive) and will yield nil for the item and stack count on empty slots.
-- @param page The page number that you want the information from. Must be between 1 and the number of available tabs, inclusive.
-- @usage
-- local LGBC = LibStub("LibGuildBankComm-1.0")
-- for slot, link, stack in LGBC:IteratePage(1) do
--     print("Slot number", slot, "contains", stack, link)
-- end
function lib:IteratePage(page)
	if type(page) ~= "number" then
		error("LibGuildBankComm:IteratePage(page) expected number", 2)
	end
	if noData then return NOP end --ensures we don't reach the next check on uninitialized tables
	if page < 1 or page > guildBank.numTabs then
		error(("LibGuildBankComm:IteratePage(page) : page must be between 1 and %d inclusive"):format(guildBank.numTabs), 2)
	end
	--make double sure we have data
	if not guildBank[page] then return NOP end
	
	local i = 0
	return function()
		i = i + 1
		if i <= 98 then
			return i, guildBank[page].links[i], guildBank[page].stacks[i]
		end
	end
end

--- Returns an iterator over the saved links of the specified page
-- The iterator will always yield the slot number (1-98, inclusive) and will yield nil for the link on empty slots.
-- @param page The page number that you want the information from. Must be between 1 and the number of available tabs, inclusive.
-- @usage
-- local LGBC = LibStub("LibGuildBankComm-1.0")
-- for slot, link in LGBC:IteratePageLinks(1) do
--     print("Slot number", slot, "contains", link)
-- end
function lib:IteratePageLinks(page)
	if type(page) ~= "number" then
		error("LibGuildBankComm:IteratePageLinks(page) expected number", 2)
	end
	if noData then return NOP end
	if page < 1 or page > guildBank.numTabs then
		error(("LibGuildBankComm:IteratePageLinks(page) : page must be between 1 and %d inclusive"):format(guildBank.numTabs), 2)
	end
	--make double sure we have data
	if not guildBank[page] then return NOP end
	
	local i = 0
	return function()
		i = i + 1
		if i <= 98 then
			return i, guildBank[page].links[i]
		end
	end
end

--- Returns an iterator over the saved stack counts of the specified page
-- The iterator will always yield the slot number (1-98, inclusive) and will yield nil for the stack count on empty slots.
-- @param page The page number that you want the information from. Must be between 1 and the number of available tabs, inclusive.
-- @usage
-- local LGBC = LibStub("LibGuildBankComm-1.0")
-- for slot, stack in LGBC:IteratePageStacks(1) do
--     print("Slot number", slot, "is a stack of", stack, "items.")
-- end
function lib:IteratePageStacks(page)
	if type(page) ~= "number" then
		error("LibGuildBankComm:IteratePageStacks(page) expected number", 2)
	end
	if noData then return NOP end
	if page < 1 or page > guildBank.numTabs then
		error(("LibGuildBankComm:IteratePageStacks(page) : page must be between 1 and %d inclusive"):format(guildBank.numTabs), 2)
	end
	--make double sure we have data
	if not guildBank[page] then return NOP end
	
	local i = 0
	return function()
		i = i + 1
		if i <= 98 then
			return i, guildBank[page].stacks[i]
		end
	end
end

--- Returns the requested page's scan timestamp
-- @param page The page number that you want the information from. Must be between 1 and the number of available tabs, inclusive.
-- @usage
-- local LGBC = LibStub("LibGuildBankComm-1.0")
-- local numTabs = LGBC:GetNumBankTabs()
-- for i = 1, numTabs do
--     local lastScan = LGBC:GetPageTimestamp(i)
--     print("Guild bank tab", i, "was last scanned", date("%x at %X", lastScan))
-- end
-- --if lastScan is 1302117202 for page 1 then
-- --the result is "Guild bank tab 1 was last scanned 04/06/11 at 14:13:22"
-- --assuming you are in the United States, Central timezone
function lib:GetPageTimestamp(page)
	if type(page) ~= "number" then
		error("LibGuildBankComm:GetPageTimestamp(page) expected number", 2)
	end
	if noData then return 0 end
	if page < 1 or page > guildBank.numTabs then
		error(("LibGuildBankComm:GetPageTimestamp(page) : page must be between 1 and %d inclusive"):format(guildBank.numTabs), 2)
	end
	return guildBank[page] and guildBank[page].lastScan or 0
end

function lib:Start()
	--events for saving the state of the guild bank
	--lib.eventFrame:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED")
	--lib.eventFrame:RegisterEvent("GUILDBANKFRAME_OPENED")
	--lib.eventFrame:RegisterEvent("GUILDBANK_UPDATE_TABS")
	--lib.eventFrame:RegisterEvent("GUILDBANK_UPDATE_MONEY")
	
	--events for getting fresh data on login/reload
	lib.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
end
lib:Start()
