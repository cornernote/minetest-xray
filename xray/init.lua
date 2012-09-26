local function xray(mode)
XRAY_MODE = mode
end 

minetest.register_chatcommand("xray", {
	params = "<mode>",
	description = "Make stone invisible.",
	privs = {shout=true},	
	func = function(name, param)
		if param == 'on'  then xray(1)
		  minetest.chat_send_player(name, "Xray turned on.")
		elseif param == 'off' then xray(2)
		  minetest.chat_send_player(name, "Xray turned off.")
		else
		  minetest.chat_send_player(name, "Please enter 'on' or 'off'.")
		end
	end,
})

minetest.register_abm({
		nodenames = {"default:stone", "xray:stone"},
		interval = 0,
		chance = 4,	
		
		action = function(pos, node, active_object_count, active_object_count_wider)
		  if XRAY_MODE == 1 then
			  if node.name == "default:stone" then
				  minetest.env:add_node(pos,{name="xray:stone"})
		  elseif XRAY_MODE == 2 then
		      if node.name == "xray:stone" then
			      minetest.env:add_node(pos,{name="xray:stone"})
	
				end
			end
		end
	end
})

minetest.register_node("xray:stone", {
	description = "Xray Stone",
	tiles = {"xray_stone.png"},
	is_ground_content = true,
	groups = {cracky=3},
	drop = 'default:cobble',
	legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})

