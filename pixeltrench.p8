pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
cfg = {
	debug = true,
	bg_col = 1,
	cam_x = 0, cam_y = 0,
	world_w = 256, world_h = 144,
	min_h = 60, max_h = 110,
	slope_limit = 1,
	target_coverage_pct = 50,
	seed = 1
}

lastSoilPct = 0

dbg_fns = {
	fps = function() return stat(7) end, -- eigener fps-counter
	time = function() return flr(t() * 100) / 100 end,
	soil = function() return lastSoilPct end
}

dbg_keys = { "fps", "time", "soil" }

function set_seed(seed)
	cfg.seed = seed
	srand(seed)
end

function bump_seed()
	set_seed(cfg.seed + 1)
end

terrain = {}
surface_y = {}

function genmap()
	terrain = {}
	surface_y = {}
	local y = 0
	local y_prev = y
	for x = 0, cfg.world_w do
		if x == 0 then y_prev = 98 end
		local step = flr(rnd(5) - 2)
		local y_proposed = y_prev + step
		local y_next = clamp(y_proposed, y_prev - cfg.slope_limit, y_prev + cfg.slope_limit)
		y_next = clamp(y_next, cfg.min_h, cfg.max_h)
		y_prev = y_next

		add(surface_y, y_next)
		local lines = {}

		local line = { y_next, cfg.world_h }
		add(lines, line)
		add(terrain, lines)
	end
end

function is_solid(x, y)
	local x, y = flr(x), flr(y)
	local lines = terrain[x + 1]
	for l in all(lines) do
		if y >= l[1] and y < l[2] then
			return true
		end
	end

	return false
end

function destroy_range(x, y0, y1)
	local x = flr(x)
	local y0, y1 = flr(y0), flr(y1)

	y0 = min(max(y0, 0), cfg.world_h)
	y1 = min(max(y1, 0), cfg.world_h)
	if y1 <= y0 then return end

	local lines = terrain[x + 1]

	local new_lines = {}
	for l in all(lines) do
		local a, b = l[1], l[2]

		-- full overlap
		if y0 <= a and y1 >= b then
			-- dont add to lines

			-- no overlap
		elseif y0 >= b or y1 <= a then
			-- add line as is
			add(new_lines, l)

			-- cut at beginning
		elseif y0 <= a and y1 > a and y1 < b then
			a = y1
			b = b
			add(new_lines, { a, b })

			-- cut at end
		elseif y0 >= a and y0 < b and y1 >= b then
			b = y0
			add(new_lines, { a, b })

			-- cut in the middle, splitting
		elseif y0 > a and y1 < b then
			-- first line

			local l1start, l1end = a, y0
			add(new_lines, { l1start, l1end })

			--second line
			local l2start, l2end = y1, b
			add(new_lines, { l2start, l2end })
		else
			add(new_lines, l)
		end
	end

	terrain[x + 1] = new_lines
end

function carve_circle(cx, cy, r)
end

function soil_coverage_pct()
	local cols = cfg.world_w + 1
	local h = cfg.world_h
	local sum = 0
	for x = 1, cfg.world_w + 1 do
		local col = 0
		local sls = terrain[x]
		local totalSoil = 0
		for sl in all(sls) do
			col += max(0, sl[2] - sl[1])
		end

		sum += col / h
	end

	return (sum / cols) * 100
end

function _init()
	poke(0x5f2d, 1)
	set_seed(1)
	-- Enable devkit mode
	genmap()
	lastSoilPct = soil_coverage_pct()
end

function _update()
	-- Check for debug keys (G and D)
	if stat(30) then
		-- A keypress is available
		local key = stat(31) -- Get the pressed key
		if key == "g" then
			-- regenerate terrain
			bump_seed()
			genmap()
			lastSoilPct = soil_coverage_pct()
			-- Add your debug action here, e.g., toggle a debug mode
		elseif key == "d" then
			-- toggle debug
			cfg.debug = not cfg.debug
			-- Add another debug action, e.g., display stats
		elseif key == "x" then
			-- carve a cicle
			carve_circle(10, 10, 4)
		end
	end
end

function drawmap()
	for x = 0, cfg.world_w do
		-- scanline
		local lines = terrain[x + 1]
		for sl in all(lines) do
			line(x, sl[1], x, sl[2] - 1, 8)
		end
	end
end

function drawdebug()
	local x, y, c, sc = 1, 1, 7, 2
	-- deterministische reihenfolge
	for i, k in ipairs(dbg_keys) do
		local v = dbg_fns[k]
		local line = k .. ": " .. v()
		-- shadow fれもr bessere lesbarkeit
		print(line, x + 1, y + 1, sc)
		print(line, x, y, c)
		y += 6
	end
end

function _draw()
	camera(0, 0)
	cls(cfg.bg_col)
	drawmap()
	if cfg.debug then
		drawdebug()
	end
end

function clamp(v, lo, hi)
	return mid(lo, v, hi)
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
