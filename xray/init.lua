
-- expose api
xray = {}

-- the range of the xray effect
xray.range = 5

-- how long before the nodes turn back to stone
xray.timer = 10

-- mode is used to store the xray mode for each player
xray.mode = {}

-- should we spew out log messages?
xray.debug = true
 
-- log
xray.log = function(message)
	if not xray.debug then
		return
	end
	minetest.log("action", "[xray] "..message)
end
 
-- replace stone with xray
xray.replace = function(player_pos)
	local pos = minetest.env:find_node_near(player_pos, xray.range, "default:stone")
	while pos~= nil do
		xray.log("replace default:stone with xray:stone at "..dump(pos))
		minetest.env:add_node(pos,{name="xray:stone"})
		minetest.after(xray.timer, xray.restore, pos)
		pos = minetest.env:find_node_near(player_pos, xray.range, "default:stone")
	end
end

-- restore xray to stone
xray.restore = function(pos)
	for _,object in ipairs(minetest.env:get_objects_inside_radius(pos, xray.range+2)) do
		if object:is_player() and xray.mode[object:get_player_name()]==1 then
			return
		end
	end
	xray.log("restore xray:stone to default:stone at "..dump(pos))
	minetest.env:add_node(pos,{name="default:stone"})
end

-- register_chatcommand
minetest.register_chatcommand("xray", {
	params = "<mode>",
	description = "Make stone invisible.",
	privs = {shout=true},	
	func = function(name, param)
		if param == 'on'  then xray.mode[name]=1
		  minetest.chat_send_player(name, "Xray turned on.")
		elseif param == 'off' then xray.mode[name]=0
		  minetest.chat_send_player(name, "Xray turned off.")
		else
		  minetest.chat_send_player(name, "Please enter 'on' or 'off'.")
		end
	end,
})

-- register_node
minetest.register_node("xray:stone", {
	description = "Xray Stone",
	tiles = {"xray_stone.png"},
	is_ground_content = true,
	groups = {cracky=3},
	drop = 'default:cobble',
	legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
	drawtype = "nodebox",
	paramtype = "light",
	walkable = true,
	node_box = {
		type = "fixed",
		fixed = {
			{-1,-1,-1, 1,1,1},
		},
	},
})

-- register_globalstep - replace default:stone with xray:stone in range of players with xray
minetest.register_globalstep(function(dtime)
	for _,player in ipairs(minetest.get_connected_players()) do
		local pos = player:getpos()
		if xray.mode[player:get_player_name()] == 1 then
			xray.replace(pos)
		end
	end
end)

-- register_abm - restore any stray xray:stone nodes to default:stone
minetest.register_abm({
	nodenames = {"xray:stone"},
	interval = xray.timer,
	chance = 1,
	action = xray.restore,
})