pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
 cfg = {
	debug = true,
	bg_col = 1,
	cam_x = 0, cam_y = 0,
	world_w = 256, world_h = 144,
	min_h = 60, max_h = 110,
	slope_limit = 4,
	target_coverage_pct = 50,
	seed = 1,
	cam_speed = 1
}

lastSoilPct = 0
cam = { x = 0, y = 0}

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
	
	-- Harmonische Parameter
	local base_height = cfg.world_h * 0.6  -- Grundhれへhe bei ~55% (hれへher = mehr Coverage)
	local wave1_amp = 20	-- Groれかe Hれもgel
	local wave1_freq = 0.01 -- Langsame Frequenz
	local wave2_amp = 4     -- Mittlere Details  
	local wave2_freq = 0.06 -- Mittlere Frequenz
	local wave3_amp = 1    -- Feine Details
	local wave3_freq = 0.2  -- Schnelle Frequenz
	
	-- Seed-basierte Phasenverschiebung fれもr Variation
	local phase1 = cfg.seed * 0.1
	local phase2 = cfg.seed * 0.3  
	local phase3 = cfg.seed * 0.9
	
	local y_prev = base_height
	
	for x = 0, cfg.world_w do
		-- Harmonische れうberlagerung
		local height_variation = 
			sin((x * wave1_freq + phase1)) * wave1_amp +
			sin((x * wave2_freq + phase2)) * wave2_amp +  
			sin((x * wave3_freq + phase3)) * wave3_amp
			
		local y_target = base_height + height_variation
		
		-- Slope-Limit anwenden (aus deiner bisherigen Logik)
		local y_next = clamp(y_target, y_prev - cfg.slope_limit, y_prev + cfg.slope_limit)
		y_next = clamp(y_next, cfg.min_h, cfg.max_h)
		y_prev = y_next
		
		add(surface_y, y_next)
		local lines = {}
		
		-- Terrain-Sれさule von surface bis Boden
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

function _update60()
	-- Check for debug keys (G and D)
	if btn(0) then
		pancam(-1, 0)
	end
	if btn(1) then
		pancam(1, 0)
	end
	if btn(2) then
		pancam(0, -1)
	end
	if btn(3) then
		pancam(0, 1)
	end
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
	for x = cam.x, cam.x + 128 do
		x = min(cfg.world_w, x)
		-- scanline
		local lines = terrain[x + 1]
		for sl in all(lines) do
			line(x, sl[1], x, sl[2] - 1, 8)
		end
	end
end

function pancam(x, y)

	cam.x += x * cfg.cam_speed
	cam.y += y * cfg.cam_speed
	cam.x = clamp(cam.x, 0, cfg.world_w - 128)
	cam.y = clamp(cam.y, 0, cfg.world_h - 128)
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
	camera(cam.x, cam.y)
	cls(cfg.bg_col)
	drawmap()
	camera()
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
