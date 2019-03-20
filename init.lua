letters = {}
letters.known_nodes = {}
local cost = 0.110

function letters.register_letters(nodename, xdef, xgroups)
	local parts = nodename:split(":")
	local modname = parts[1]
	local subname = parts[2]
	local def = minetest.registered_nodes[nodename]
	if not def then
		minetest.log("warning", "Could not find node '"..nodename.."'")
		return
	end
	local texture
	if #def.tiles == 1 then
		texture = def.tiles[1]
	else
		texture = def.tiles[3]
	end
	if not texture then return end
	for letter in string.gmatch("abcdefghijklmnopqrstuvwxyz", ".") do
		local namel = subname.. "_letter_" ..letter
		local nameu = subname.. "_letter_" ..string.upper(letter)
		local descl = def.description.. " " ..letter
		local descu = def.description.. " " ..string.upper(letter)
		local tilesl = texture.. "^letters_" ..letter.. "_overlay.png^[makealpha:255,126,126"
		local tilesu = texture.. "^letters_" ..string.upper(letter).. "_overlay.png^[makealpha:255,126,126"
		local groups = {not_in_creative_inventory=1, not_in_craft_guide=1, oddly_breakable_by_hand=1, attached_node=1}
		xgroups = xgroups or {}
		for k, v in pairs(xgroups) do
			groups[k] = v
		end
		local nodedefl = {
			description = descl,
			drawtype = "signlike",
			tiles = {tilesl},
			inventory_image = tilesl,
			wield_image = tilesl,
			paramtype = "light",
			light_source = def.light_source or nil,
			paramtype2 = "wallmounted",
			sunlight_propagates = true,
			is_ground_content = false,
			walkable = false,
			selection_box = {
				type = "wallmounted",
			},
			groups = groups,
			legacy_wallmounted = false,
			sounds = def.sounds or nil,
		}
		local nodedefu = {
			description = descu,
			drawtype = "signlike",
			tiles = {tilesu},
			inventory_image = tilesu,
			wield_image = tilesu,
			paramtype = "light",
			light_source = def.light_source or nil,
			paramtype2 = "wallmounted",
			sunlight_propagates = true,
			is_ground_content = false,
			walkable = false,
			selection_box = {
				type = "wallmounted",
			},
			groups = groups,
			legacy_wallmounted = false,
			sounds = def.sounds or nil,
		}
		xdef = xdef or {}
		for k, v in pairs(xdef) do
			nodedefl[k] = v
			nodedefu[k] = v
		end
		minetest.register_node(":" ..modname..":"..namel, nodedefl)
		minetest.register_node(":" ..modname..":"..nameu, nodedefu)
	end		
	for i = 0, 9 do
		local tiles = texture.. "^letters_" ..i.. "_overlay.png^[makealpha:255,126,126"
		local groups = {not_in_creative_inventory=1, not_in_craft_guide=1, oddly_breakable_by_hand=1, attached_node=1}
		minetest.register_node(":" ..modname..":"..subname.. "_number_"..i, {
			description = def.description.." "..i,
			drawtype = "signlike",
			tiles = {tiles},
			inventory_image = tiles,
			wield_image = tiles,
			paramtype = "light",
			light_source = def.light_source or nil,
			paramtype2 = "wallmounted",
			sunlight_propagates = true,
			is_ground_content = false,
			walkable = false,
			selection_box = {
				type = "wallmounted",
			},
			groups = groups,
			legacy_wallmounted = false,
			sounds = def.sounds or nil,
		})
	end
	letters.known_nodes[nodename] = {modname, subname}
end

local function get_chars(type)
	local lets = "abcdefghijklmnopqrstuvwxyz"
	local funcs = {
		lower = function()
			local out = {}
			for letter in lets:gmatch(".") do
				out[#out+1] = "letter_"..letter
			end
			return out
		end,
		upper = function()
			local out = {}
			for letter in lets:gmatch(".") do
				out[#out+1] = "letter_"..string.upper(letter)
			end
			return out
		end,
		number = function()
			local out = {}
			for i = 0, 9 do
				out[#out+1] = "number_"..i
			end
			return out
		end,
	}
	if funcs[type] then
		return funcs[type]()
	end
end

local function get_type(pos)
	local meta = minetest.get_meta(pos)
	local infotext = meta:get_string("infotext")
	return infotext:sub(1, infotext:find("is")-2)
end

local function reset(pos)
	local meta = minetest.get_meta(pos)
	local inv  = meta:get_inventory()

	inv:set_list("input",  {})
	inv:set_list("output", {})
	meta:set_int("anz", 0)
	meta:set_string("infotext",	(get_type(pos).." cutter is empty (owned by %s)"):format(meta:get_string("owner")))
end

local function update_inventory(pos, amount, type)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	amount = meta:get_int("anz") + amount

	if amount < 1 then -- If the last block is taken out.
		reset(pos)
		return
	end
 
	local stack = inv:get_stack("input",  1)
	if stack:is_empty() then
		reset(pos)
		return
	end

	local node_name = stack:get_name() or ""
	local name_parts = letters.known_nodes[node_name] or ""
	local modname  = name_parts[1] or ""
	local material = name_parts[2] or ""

	inv:set_list("input", { 
		node_name.. " " .. math.floor(amount)
	})

	local function get_output_inv(modname, subname, amount, max)
		local list = {}
		if amount < 1 then
			return list
		end
	
		for _, c in ipairs(get_chars(type)) do
			table.insert(list, modname .. ":" .. subname .. "_" .. c.. " " .. math.min(math.floor(amount/cost), max))
		end
		return list
	end

	-- Display:
	inv:set_list("output", get_output_inv(modname, material, amount, meta:get_int("max_offered")))
	-- Store how many microblocks are available:
	meta:set_int("anz", amount)
	meta:set_string("infotext", (get_type(pos).." cutter is working (owned by %s)"):format(meta:get_string("owner")))
end

function letters.register_cutter(type, def)
	minetest.register_node("letters:letter_cutter_"..type,  {
		description = def.description.." Cutter", 
		drawtype = "nodebox",
		node_box = def.node_box,
		tiles = {"letters_letter_cutter_"..type.."_top.png",
			"default_tree.png",
			"letters_letter_cutter_side.png"},
		paramtype = "light", 
		sunlight_propagates = true,
		paramtype2 = "facedir", 
		groups = {choppy = 2,oddly_breakable_by_hand = 2},
		sounds = default.node_sound_wood_defaults(),
		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("formspec", "size[11,9]" ..
					"listcolors[#606060AA;#808080;#101010;#202020;#FFF]"..
					"label[0,0;Input\nmaterial]" ..
					"list[current_name;input;1.5,0;1,1;]" ..
					"list[current_name;output;2.8,0;8,4;]" ..
					"list[current_player;main;1.5,5;8,4;]")
		
			meta:set_int("anz", 0) -- No microblocks inside yet.
			meta:set_string("max_offered", 9) -- How many items of this kind are offered by default?
			meta:set_string("infotext", def.description.." cutter is empty")
		
			local inv = meta:get_inventory()
			inv:set_size("input", 1)    -- Input slot for full blocks of material x.
			inv:set_size("output", 4*8) -- 4x8 versions of stair-parts of material x.
		
			reset(pos)
		end,
		can_dig = function(pos)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			if not inv:is_empty("input") then
				return false
			end
			return true
		end,
		-- Set the owner of this circular saw.
		after_place_node = function(pos, placer)
			local meta = minetest.get_meta(pos)
			local owner = placer and placer:get_player_name() or ""
			meta:set_string("owner",  owner)
			meta:set_string("infotext",	(def.description.." cutter is empty (owned by %s)"):format(meta:get_string("owner")))
		end,
		allow_metadata_inventory_move = function()
			return 0
		end,
		-- Only input- and recycle-slot are intended as input slots:
		allow_metadata_inventory_put = function(pos, listname, index, stack)
			-- The player is not allowed to put something in there:
			if listname == "output" then
				return 0
			end
		
			local meta = minetest.get_meta(pos)
			local inv  = meta:get_inventory()
			local stackname = stack:get_name()
			local count = stack:get_count()
			
			-- Only accept certain blocks as input which are known to be craftable into stairs:
			if listname == "input" then
				if not inv:is_empty("input") and
						inv:get_stack("input", index):get_name() ~= stackname then
					return 0
				end
				for name, t in pairs(letters.known_nodes) do
					if name == stackname and inv:room_for_item("input", stack) then
						return count
					end
				end
				return 0
			end
		end,
		-- Taking is allowed from all slots (even the internal microblock slot). Moving is forbidden.
		-- Putting something in is slightly more complicated than taking anything because we have to make sure it is of a suitable material:
		on_metadata_inventory_put = function(pos, listname, index, stack)
			local meta = minetest.get_meta(pos)
			local inv  = meta:get_inventory()
			local stackname = stack:get_name()
			local count = stack:get_count()
		
			if listname == "input" then
				update_inventory(pos, count, type)
			end
		end,
		on_metadata_inventory_take = function(pos, listname, index, stack)
			if listname == "output" then
				-- We do know how much each block at each position costs:
				update_inventory(pos, 8 * -cost, type)
			elseif listname == "input" then
				-- Each normal (= full) block taken costs 8 microblocks:
				update_inventory(pos, 8 * -stack:get_count(), type)
			end
			-- The recycle field plays no role here since it is processed immediately.
		end,
	})
	
	minetest.register_craft({
		output = "letters:letter_cutter_"..type,
		recipe = def.recipe
	})
end

letters.register_cutter("lower", {
	description = "Lowercase Letter", 
	node_box = {
		type = "fixed", 
		fixed = {
			{-0.4375, -0.5, -0.4375, -0.3125, 0.125, -0.3125}, -- NodeBox1
			{-0.4375, -0.5, 0.3125, -0.3125, 0.125, 0.4375}, -- NodeBox2
			{0.3125, -0.5, 0.3125, 0.4375, 0.125, 0.4375}, -- NodeBox3
			{0.3125, -0.5, -0.4375, 0.4375, 0.125, -0.3125}, -- NodeBox4
			{-0.5, 0.0625, -0.5, 0.5, 0.25, 0.5}, -- NodeBox5
			{-0.125, 0.25, 0.125, 0.125, 0.3125, 0.1875}, -- NodeBox6
			{0.125, 0.25, 0.0625, 0.1875, 0.3125, 0.125}, -- NodeBox7
			{0.1875, 0.25, -0.1875, 0.25, 0.3125, 0.1875}, -- NodeBox8
			{-0.1875, 0.25, 0.0625, -0.125, 0.3125, 0.125}, -- NodeBox9
			{-0.25, 0.25, -0.1875, -0.1875, 0.3125, 0.0625}, -- NodeBox10
			{-0.1875, 0.25, -0.25, -0.125, 0.3125, -0.1875}, -- NodeBox11
			{-0.125, 0.25, -0.3125, 0.125, 0.3125, -0.25}, -- NodeBox12
			{0.125, 0.25, -0.25, 0.375, 0.3125, -0.1875}, -- NodeBox13
			{0.3125, 0.25, -0.1875, 0.375, 0.3125, -0.125}, -- NodeBox14
		},
	},
	recipe = {
		{"default:tree", "default:tree", "default:tree"},
		{"default:wood", "default:steel_ingot", "default:wood"},
		{"default:tree", "", "default:tree"},
	},
})

letters.register_cutter("upper", {
	description = "Uppercase Letter",
	node_box = {
		type = "fixed", 
		fixed = {
			{-0.4375, -0.5, -0.4375, -0.3125, 0.125, -0.3125}, -- NodeBox1
			{-0.4375, -0.5, 0.3125, -0.3125, 0.125, 0.4375}, -- NodeBox2
			{0.3125, -0.5, 0.3125, 0.4375, 0.125, 0.4375}, -- NodeBox3
			{0.3125, -0.5, -0.4375, 0.4375, 0.125, -0.3125}, -- NodeBox4
			{-0.5, 0.0625, -0.5, 0.5, 0.25, 0.5}, -- NodeBox5
			{0.1875, 0.25, -0.125, 0.125, 0.3125, -0.3125}, -- NodeBox6
			{0.125, 0.25, 0.125, 0.0625, 0.3125, -0.125}, -- NodeBox7
			{0.0625, 0.25, 0.3125, -0.0625, 0.3125, 0.0625}, -- NodeBox8
			{-0.0625, 0.25, 0.125, -0.125, 0.3125, -0.125}, -- NodeBox9
			{-0.125, 0.25, -0.125, -0.1875, 0.3125, -0.3125}, -- NodeBox10
			{0.125, 0.25, -0.125, -0.125, 0.3125, -0.1875}, -- NodeBox11
		},
	},
	recipe = {
		{"default:tree", "default:tree", "default:tree"},
		{"default:wood", "default:steel_ingot", "default:wood"},
		{"default:tree", "default:steel_ingot", "default:tree"},
	},
})

letters.register_cutter("number", {
	description = "Number", 
	node_box = {
		type = "fixed", 
		fixed = {
			{-0.4375, -0.5, 0.3125, -0.3125, 0.0625, 0.4375}, -- NodeBox1
			{0.3125, -0.5, 0.3125, 0.4375, 0.0625, 0.4375}, -- NodeBox2
			{0.3125, -0.5, -0.4375, 0.4375, 0.0625, -0.3125}, -- NodeBox3
			{-0.4375, -0.5, -0.4375, -0.3125, 0.0625, -0.3125}, -- NodeBox4
			{-0.5, 0.0625, -0.5, 0.5, 0.25, 0.5}, -- NodeBox5
			{-0.125, 0.25, -0.25, 0.1875, 0.3125, -0.1875}, -- NodeBox6
			{0, 0.25, -0.1875, 0.0625, 0.3125, 0.3125}, -- NodeBox7
			{-0.0625, 0.25, 0.1875, 0, 0.3125, 0.25}, -- NodeBox8
			{-0.125, 0.25, 0.125, -0.0625, 0.3125, 0.1875}, -- NodeBox9
		}
	},
	recipe = {
		{"default:tree", "default:tree", "default:tree"},
		{"default:wood", "default:copper_ingot", "default:wood"},
		{"default:tree", "default:steel_ingot", "default:tree"},
	},
})

dofile(minetest.get_modpath("letters").."/registrations.lua")

for letter in string.gmatch("abcdefghijklmnopqrstuvwxyz", ".") do
	for _, name in pairs(letters.known_nodes) do
		local modname  = name[1] or ""
		local material = name[2] or ""
		local let = modname .. ":" .. material .. "_letter_"
		minetest.register_alias(let..letter.."u", let..string.upper(letter))
		minetest.register_alias(let..letter.."l", let..letter)
	end
end
