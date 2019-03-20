local default_nodes = {
	"stone",
	"stone_block",
	"cobble",
	"mossycobble",
	"brick",
	"sandstone",
	"steelblock",
	"goldblock",
	"copperblock",
	"bronzeblock",
	"diamondblock",
	"tinblock",
	"desert_stone",
	"desert_stone_block",
	"desert_cobble",
	"meselamp",
	"glass",
	"tree",
	"wood",
	"jungletree",
	"junglewood",
	"pine_tree",
	"pine_wood",
	"acacia_tree",
	"acacia_wood",
	"aspen_tree",
	"aspen_wood",
	"obsidian",
	"obsidian_block",
	"obsidianbrick",
	"obsidian_glass",
	"stonebrick",
	"desert_stonebrick",
	"sandstonebrick",
	"silver_sandstone",
	"silver_sandstone_brick",
	"silver_sandstone_block",
	"desert_sandstone",
	"desert_sandstone_brick",
	"desert_sandstone_block",
	"sandstone_block",
	"meselamp",
}

for _, name in pairs(default_nodes) do
	letters.register_letters("default:"..name)
end

if minetest.get_modpath("wool") then
	local nodes = {
		"black",
		"cyan",
		"brown",
		"dark_green",
		"dark_grey",
		"green",
		"grey",
		"magenta",
		"orange",
		"pink",
		"violet",
		"red",
		"white",
		"yellow",
	}
	for _, name in pairs(nodes) do
		letters.register_letters("wool:"..name)
	end
end

if minetest.get_modpath("bakedclay") then
	local nodes = {
		"black",
		"cyan",
		"brown",
		"dark_green",
		"dark_grey",
		"green",
		"grey",
		"magenta",
		"orange",
		"pink",
		"violet",
		"red",
		"white",
		"yellow",
	}
	for _, name in pairs(nodes) do
		letters.register_letters("bakedclay:"..name)
	end
end

if minetest.get_modpath("plasticbox") then
	letters.register_letters("plasticbox:plasticbox", {
		paramtype2 = "colorwallmounted",
		palette = "unifieddyes_palette_colorwallmounted.png",
		on_construct = unifieddyes.on_construct,
	},
	{ud_param2_colorable = 1})
end
