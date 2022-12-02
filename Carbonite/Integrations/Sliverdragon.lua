local myname, ns = ...

local HandyNotes = LibStub("AceAddon-3.0"):GetAddon("HandyNotes", true)
if not HandyNotes then return end

local core = LibStub("AceAddon-3.0"):GetAddon("SilverDragon")
local module = core:NewModule("HandyNotes", "AceEvent-3.0")
local Debug = core.Debug

local HBDMigrate = LibStub("HereBeDragons-Migrate", true)

local db

local nodes = {}
module.nodes = nodes

local handler = {}
do
	local function tex(atlas, r, g, b, scale)
		atlas = C_Texture.GetAtlasInfo(atlas)
		return {
			icon = atlas.file,
			tCoordLeft = atlas.leftTexCoord, tCoordRight = atlas.rightTexCoord, tCoordTop = atlas.topTexCoord, tCoordBottom = atlas.bottomTexCoord,
			r = r, g = g, b = b, a = 0.9,
			scale = scale or 1,
		}
	end
	-- DungeonSkull = skull
	-- VignetteKillElite = Skull with star around it
	-- Islands-AzeriteBoss = more detailed skull
	-- nazjatar-nagaevent = more detailed skull, glowing
	-- WhiteCircle-RaidBlips / PlayerPartyBlip = white circle
	-- WhiteDotCircle-RaidBlips / PlayerRaidBlip = white circle with dot
	-- PlayerDeadBlip = black circle with white X
	-- QuestSkull = gold glowy circle
	-- Warfront-NeutralHero-Silver = silver dragon on gold circle
	local icons = {
		circles = {
			default = tex("DungeonSkull", 1, 0.33, 0.33, 1.3), -- red skull
            partial = tex("DungeonSkull", 1, 1, 0.33, 1.3), -- yellow skull
            done = tex("DungeonSkull", 0.33, 1, 0.33, 1), -- green skull
            loot = tex("VignetteKillElite", 1, 0.33, 0.33, 1.3), -- red glowing skull
            loot_partial = tex("VignetteKillElite", 1, 1, 0.33, 1.3), -- yellow glowing skull
            loot_done = tex("VignetteKillElite", 0.33, 1, 0.33, 1), -- green glowing skull
            mount = tex("VignetteKillElite", 1, 0.33, 0.33, 1.8), -- red shiny skull
            mount_partial = tex("VignetteKillElite", 1, 1, 0.33, 1.8), -- yellow shiny skull
            mount_done = tex("VignetteKillElite", 0.33, 1, 0.33, 1), -- green shiny skull
		},
		skulls = {
			default = tex("DungeonSkull", 1, 0.33, 0.33, 1.3), -- red skull
            partial = tex("DungeonSkull", 1, 1, 0.33, 1.3), -- yellow skull
            done = tex("DungeonSkull", 0.33, 1, 0.33, 1), -- green skull
            loot = tex("VignetteKillElite", 1, 0.33, 0.33, 1.3), -- red glowing skull
            loot_partial = tex("VignetteKillElite", 1, 1, 0.33, 1.3), -- yellow glowing skull
            loot_done = tex("VignetteKillElite", 0.33, 1, 0.33, 1), -- green glowing skull
            mount = tex("VignetteKillElite", 1, 0.33, 0.33, 1.8), -- red shiny skull
            mount_partial = tex("VignetteKillElite", 1, 1, 0.33, 1.8), -- yellow shiny skull
            mount_done = tex("VignetteKillElite", 0.33, 1, 0.33, 1), -- green shiny skull
		},
		stars = {
			default = tex("DungeonSkull", 1, 0.33, 0.33, 1.3), -- red skull
            partial = tex("DungeonSkull", 1, 1, 0.33, 1.3), -- yellow skull
            done = tex("DungeonSkull", 0.33, 1, 0.33, 1), -- green skull
            loot = tex("VignetteKillElite", 1, 0.33, 0.33, 1.3), -- red glowing skull
            loot_partial = tex("VignetteKillElite", 1, 1, 0.33, 1.3), -- yellow glowing skull
            loot_done = tex("VignetteKillElite", 0.33, 1, 0.33, 1), -- green glowing skull
            mount = tex("VignetteKillElite", 1, 0.33, 0.33, 1.8), -- red shiny skull
            mount_partial = tex("VignetteKillElite", 1, 1, 0.33, 1.8), -- yellow shiny skull
            mount_done = tex("VignetteKillElite", 0.33, 1, 0.33, 1), -- green shiny skull
		}
	}
	local function should_show_mob(id)
		if db.hidden[id] or core:ShouldIgnoreMob(id) then
			return false
		end
		local quest, achievement, achievement_completed_by_alt = ns:CompletionStatus(id)
		if achievement ~= nil then
			if quest ~= nil then
				-- we have a quest *and* an achievement; we're going to treat "show achieved" as "show achieved if I can still loot them"
				return (db.questcomplete or not quest) and (db.achieved or not achievement)
			end
			-- no quest, but achievement
			return db.achieved or not achievement
		end
		if db.achievementless then
			-- no achievement, but quest
			return db.questcomplete or not quest
		end
		return false
	end
	local function key_for_mob(id)
        -- TODO: when I overhaul completion it needs to affect this
        local quest, achievement = ns:CompletionStatus(id)
        local prefix, suffix
        if ns.Loot.HasInterestingMounts(id) then
            -- an unknown mount or a BoE mount
            prefix = 'mount'
        elseif ns.Loot.Status.Toy(id) == false or ns.Loot.Status.Pet(id) == false then
            -- but toys and pets are only special until you loot them
            prefix = 'loot'
        end
        if quest ~= nil then
            -- if there's a quest, it controls because loot is irrelevant
            -- (and I don't think there's any way of having the quest
            -- done without getting achievement-credit)
            suffix = quest and 'done' or (achievement and 'partial')
        elseif achievement ~= nil then
            -- if there's an achievement, loot-status controls whether
            -- we're partial or complete, because achievement-only mobs
            -- can generally be farmed
            suffix = achievement and (prefix and 'partial' or 'done')
        end
        if prefix and suffix then
            return prefix .. '_' .. suffix
        end
        return prefix or suffix
    end
	local function icon_for_mob(id)
		local set = icons[db.icon_theme]
		if not ns.mobdb[id] then
			return set.default
		end
		return set[key_for_mob(id)] or set.default
	end
	local function scale(value, currmin, currmax, min, max)
		-- take a value between currmin and currmax and scale it to be between min and max
		return ((value - currmin) / (currmax - currmin)) * (max - min) + min
	end
	local function hasher(value)
		return scale(select(2, math.modf(math.abs(math.tan(value)) * 10000, 1)), 0, 1, 0.3, 1)
	end
	local function id_to_color(id)
		return hasher(id + 1), hasher(id + 2), hasher(id + 3)
	end
	local icon_cache = {}
	local function distinct_icon_for_mob(id)
		local icon = icon_for_mob(id)
		if not icon_cache[id] then
			icon_cache[id] = {}
		end
		for k,v in pairs(icon) do
			icon_cache[id][k] = v
		end
		local r, g, b = id_to_color(id)
		icon_cache[id].r = r
		icon_cache[id].g = g
		icon_cache[id].b = b
		return icon_cache[id]
	end
	local function iter(t, prestate)
		if not t then return nil end
		local state, value = next(t, prestate)
		while state do
			-- Debug("HandyNotes node", state, value, should_show_mob(value))
			if value and should_show_mob(value) then
				local icon
				if db.icon_color == 'distinct' then
					icon = distinct_icon_for_mob(value)
				else
					icon = icon_for_mob(value)
				end
				return state, nil, icon, db.icon_scale * icon.scale, db.icon_alpha
			end
			state, value = next(t, state)
		end
		return nil, nil, nil, nil, nil
	end
	function handler:GetNodes2(uiMapID, minimap)
		Debug("HandyNotes GetNodes2", uiMapID, minimap)
		if minimap and not db.minimap then
			return iter, {}, nil
		end
		return iter, nodes[uiMapID], nil
	end
end

function handler:OnEnter(uiMapID, coord)
	local tooltip = GameTooltip
	if self:GetCenter() > UIParent:GetCenter() then -- compare X coordinate
		tooltip:SetOwner(self, "ANCHOR_LEFT")
	else
		tooltip:SetOwner(self, "ANCHOR_RIGHT")
	end
	if HBDMigrate and type(uiMapID) == "string" then
		-- ...HandyNotes seems to be giving old mapfile stuff to minimap pins. So, compatibility layer.
		uiMapID = HBDMigrate:GetUIMapIDFromMapFile(uiMapID)
	end
	local id, name, questid, _, _, lastseen = core:GetMobByCoord(uiMapID, coord)
	if not name then
		tooltip:AddLine(UNKNOWN)
		tooltip:AddDoubleLine("At", uiMapID .. ':' .. coord)
		return tooltip:Show()
	end
	tooltip:AddLine(core:GetMobLabel(id))
	if ns.mobdb[id].notes then
		tooltip:AddDoubleLine("Note", ns.mobdb[id].notes)
	end
	tooltip:AddDoubleLine("Last seen", core:FormatLastSeen(lastseen))
	core:GetModule("Tooltip"):UpdateTooltip(id)

	tooltip:Show()
end

function handler:OnLeave(uiMapID, coord)
	GameTooltip:Hide()
end

local clicked_zone, clicked_coord

local function hideMob(button, uiMapID, coord)
	local id = core:GetMobByCoord(uiMapID, coord)
	if id then
		db.hidden[id] = true
		module:SendMessage("HandyNotes_NotifyUpdate", "SilverDragon")
	end
end

local function createWaypoint(button, uiMapID, coord)
	if TomTom then
		local x, y = HandyNotes:getXY(coord)
		local id, name = core:GetMobByCoord(uiMapID, coord)
		TomTom:AddWaypoint(uiMapID, x, y, {
			title = name,
			persistent = nil,
			minimap = true,
			world = true
		})
	end
end

local function createWaypointForAll(button, uiMapID, coord)
	if not TomTom then return end
	local id, name = core:GetMobByCoord(uiMapID, coord)
	if not (id and ns.mobsByZone[uiMapID] and ns.mobsByZone[uiMapID][id]) then return end
	for _, mob_coord in ipairs(ns.mobsByZone[uiMapID][id]) do
		local x, y = HandyNotes:getXY(mob_coord)
		TomTom:AddWaypoint(uiMapID, x, y, {
			title = name,
			persistent = nil,
			minimap = true,
			world = true
		})
	end
end

local dropdown = CreateFrame("Frame")
dropdown.displayMode = "MENU"

do
	local info = {}
	local function generateMenu(button, level)
		if (not level) then return end
		table.wipe(info)
		if (level == 1) then
			-- Create the title of the menu
			info.isTitle      = 1
			info.text         = "HandyNotes - SilverDragon"
			info.notCheckable = 1
			UIDropDownMenu_AddButton(info, level)

			if TomTom then
				-- Waypoint menu item
				info.disabled     = nil
				info.isTitle      = nil
				info.notCheckable = nil
				info.text = "Create waypoint"
				info.icon = nil
				info.func = createWaypoint
				info.arg1 = clicked_zone
				info.arg2 = clicked_coord
				UIDropDownMenu_AddButton(info, level)

				info.disabled = nil
				info.isTitle = nil
				info.notCheckable = nil
				info.text = "Create waypoint for all locations"
				info.icon = nil
				info.func = createWaypointForAll
				info.arg1 = clicked_zone
				info.arg2 = clicked_coord
				UIDropDownMenu_AddButton(info, level)
			end

			-- Hide menu item
			info.disabled     = nil
			info.isTitle      = nil
			info.notCheckable = nil
			info.text = "Hide mob"
			info.icon = "Interface\\Icons\\INV_Misc_Head_Dragon_01"
			info.func = hideMob
			info.arg1 = clicked_zone
			info.arg2 = clicked_coord
			UIDropDownMenu_AddButton(info, level)

			-- Close menu item
			info.text         = "Close"
			info.icon         = nil
			info.func         = function() CloseDropDownMenus() end
			info.arg1         = nil
			info.notCheckable = 1
			UIDropDownMenu_AddButton(info, level)
		end
	end
	dropdown.initialize = generateMenu
end

function handler:OnClick(button, down, uiMapID, coord)
	if button == "RightButton" and not down then
		clicked_zone = uiMapID
		clicked_coord = coord
		ToggleDropDownMenu(1, nil, dropdown, self, 0, 0)
	end
end

function module:OnInitialize()
	self.db = core.db:RegisterNamespace("HandyNotes", {
		profile = {
			icon_scale = 1.0,
			icon_alpha = 1.0,
			icon_theme = 'skulls', -- circles / skulls
			icon_color = 'distinct', -- completion / distinct
			achieved = true,
			questcomplete = false,
			achievementless = true,
			hidden = {},
			minimap = true,
		},
	})
	db = self.db.profile

	local options = {
		type = "group",
		name = "SilverDragon",
		desc = "Where the rares are",
		get = function(info) return db[info.arg] end,
		set = function(info, v)
			db[info.arg] = v
			module:SendMessage("HandyNotes_NotifyUpdate", "SilverDragon")
		end,
		args = {
			icon = {
				type = "group",
				name = "Icon settings",
				inline = true,
				args = {
					desc = {
						name = "These settings control the look and feel of the icon.",
						type = "description",
						order = 0,
					},
					icon_scale = {
						type = "range",
						name = "Icon Scale",
						desc = "The scale of the icons",
						min = 0.25, max = 2, step = 0.01,
						arg = "icon_scale",
						order = 20,
					},
					icon_alpha = {
						type = "range",
						name = "Icon Alpha",
						desc = "The alpha transparency of the icons",
						min = 0, max = 1, step = 0.01,
						arg = "icon_alpha",
						order = 30,
					},
					icon_theme = {
						type = "select",
						name = "Theme",
						desc = "Which icon set to use",
						values = {
							["skulls"] = "Skulls",
							["circles"] = "Circles",
							["stars"] = "Stars",
						},
						arg = "icon_theme",
						order = 40,
					},
					icon_color = {
						type = "select",
						name = "Color",
						desc = "How to color the icons",
						values = {
							["distinct"] = "Unique per-mob",
							["completion"] = "Completion status",
						},
						arg = "icon_color",
						order = 50,
					},
				},
			},
			display = {
				type = "group",
				name = "What to display",
				inline = true,
				args = {
					achieved = {
						type = "toggle",
						name = "Show achieved",
						desc = "Whether to show icons for mobs you have already killed (tested by whether you've got their achievement progress)",
						arg = "achieved",
						order = 10,
					},
					questcomplete = {
						type = "toggle",
						name = "Show quest-complete",
						desc = "Whether to show icons for mobs you have the tracking quest complete for (which probably means they won't drop anything)",
						arg = "questcomplete",
						order = 15,
					},
					achievementless = {
						type = "toggle",
						name = "Show non-achievement mobs",
						desc = "Whether to show icons for mobs which aren't part of the criteria for any known achievement",
						arg = "achievementless",
						width = "full",
						order = 20,
					},
					minimap = {
						type = "toggle",
						name = "Minimap",
						desc = "Whether to show icons on the minimap as well as the zone map",
						arg = "minimap",
						order = 30,
					},
					unhide = {
						type = "execute",
						name = "Reset hidden mobs",
						desc = "Show all nodes that you manually hid by right-clicking on them and choosing \"hide\".",
						func = function()
							wipe(db.hidden)
							module:SendMessage("HandyNotes_NotifyUpdate", "SilverDragon")
						end,
						order = 50,
					},
				},
			},
		},
	}

	local config = core:GetModule("Config", true)
	if config then
		config.options.plugins.handynotes = {
			handynotes = {
				type = "group",
				name = "HandyNotes",
				get = options.get,
				set = options.set,
				args = options.args,
			},
		}
	end

	HandyNotes:RegisterPluginDB("SilverDragon", handler, options)

	core.RegisterCallback(self, "Ready", "UpdateNodes")

	self:RegisterEvent("LOOT_CLOSED")
end

function module:UpdateNodes()
	wipe(nodes)
	for zone, mobs in pairs(ns.mobsByZone) do
		nodes[zone] = {}
		for id, locs in pairs(mobs) do
			if core:IsMobInPhase(id, zone) and not core:ShouldIgnoreMob(id, zone) then
				for _, loc in ipairs(locs) do
					nodes[zone][loc] = id
				end
			end
		end
	end
	self.nodes = nodes
	self:SendMessage("HandyNotes_NotifyUpdate", "SilverDragon")
end


function module:LOOT_CLOSED()
	self:SendMessage("HandyNotes_NotifyUpdate", "SilverDragon")
end
