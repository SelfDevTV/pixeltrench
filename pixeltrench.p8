pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
cfg = {
	debug = true,
	bg_col = 1,
	cam_x = 0, cam_y = 0,
	cam_target = nil,
	world_w = 256, world_h = 144,
	min_h = 60, max_h = 110,
        slope_limit = 10,
        max_slope = 4,
	target_coverage_pct = 50,
	seed = 1,
	cam_speed = 0.1,
	buttons = {
		shoot = 🅾️,
		fn = ❎
	}
}

fn_active = false

pi = 3.14
tau = pi * 2
grav = 0.05

lastSoilPct = 0

dbg_fns = {
	fps = function() return stat(7) end, -- eigener fps-counter
	time = function() return flr(t() * 100) / 100 end,
	soil = function() return lastSoilPct end,
	custom = function() return dbg_custom end
}

dbg_custom = ""

dbg_keys = { "fps", "time", "soil", "custom" }

function set_seed(seed)
	cfg.seed = seed
	srand(seed)
end

function bump_seed()
	set_seed(cfg.seed + 1)
end

terrain = {}
surface_y = {}

local debug_ball = {
	x = 20,
	y = 20,
	dx = 0.8,
	dy = 0.7,
	r = 5,
	max_bounce = 5
}

local worm = {
	x = 50,
	y = 30,
	vx = 0,
	vy = 0,
	r = 3,
	jumping = false,
	hp = 40,
	max_hp = 100,
	grounded = false,
	aim_angle = 0,
	-- 1 is to the right, -1 is to the left
	facing = 1,
	power = 0,
	max_power = 10,
	power_step = 0.4
}

cfg.cam_target = worm

projectiles = {}
damage_nums = {}

function genmap()
	terrain = {}
	surface_y = {}

	-- Harmonische Parameter
	local base_height = cfg.world_h * 0.6
	-- Grundhれへhe bei ~55% (hれへher = mehr Coverage)
	local wave1_amp = 20
	-- Groれかe Hれもgel
	local wave1_freq = 0.01
	-- Langsame Frequenz
	local wave2_amp = 4
	-- Mittlere Details
	local wave2_freq = 0.06
	-- Mittlere Frequenz
	local wave3_amp = 1
	-- Feine Details
	local wave3_freq = 0.2
	-- Schnelle Frequenz

	-- Seed-basierte Phasenverschiebung fれもr Variation
	local phase1 = cfg.seed * 0.1
	local phase2 = cfg.seed * 0.3
	local phase3 = cfg.seed * 0.9

	local y_prev = base_height

	for x = 0, cfg.world_w do
		-- Harmonische れうberlagerung
		local height_variation = sin((x * wave1_freq + phase1)) * wave1_amp
				+ sin((x * wave2_freq + phase2)) * wave2_amp
				+ sin((x * wave3_freq + phase3)) * wave3_amp

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

function circle_collides(x, y, r)
	for a = 0, 1, 0.125 do
		local px = x + cos(a) * r
		local py = y + sin(a) * r
		if is_solid(px, py) then return true end
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
	-- AABB Bounds fれもr Performance
	local x_start = max(0, cx - r)
	local x_end = min(cfg.world_w, cx + r)

	for x = x_start, x_end do
		local dx = x - cx
		if dx * dx <= r * r then
			local dy = sqrt(r * r - dx * dx)
			local y_top = cy - dy
			local y_bottom = cy + dy
			destroy_range(x, y_top, y_bottom)
		end
	end
end

function collide_circle(a, b, r)
	local sample_points = 16
	local angle_step = 1 / sample_points
	for i = 0, sample_points - 1 do
		local ang = i * angle_step
		local x = a + r * cos(ang)
		local y = b + r * sin(ang)
		if is_solid(x, y) then return true end
	end
	if is_solid(a, b) then return true end

	return false
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

function ground_normal(a, b, r)
	local sample_points = 16
	local angle_step = 1 / sample_points
	local normalX, normalY = 0, 0
	for i = 0, sample_points - 1 do
		local ang = i * angle_step
		local x = a + r * cos(ang)
		local y = b + r * sin(ang)

		if is_solid(x, y) then
			local dx = x - a
			local dy = y - b
			normalX += dx
			normalY += dy
		end
	end

	-- normalX = -normalX
	-- normalY = -normalY

	local l = sqrt(normalX * normalX + normalY * normalY)
	if l == 0 then
		return nil, nil
	end
	normalX = normalX / l
	normalY = normalY / l
	return -normalX, -normalY
end

function _init()
	poke(0x5f2d, 1)
	set_seed(rnd())
	-- Enable devkit mode
	genmap()
	lastSoilPct = soil_coverage_pct()
	-- for i = 1, 100 do
	-- 	carve_circle(rnd(cfg.world_w), rnd(40) + 100, rnd(10) + 2)
	-- end

	-- test
	-- for i = 1, 10 do
	-- 	local r = rnd(5) + 2
	-- 	create_projectile(rnd(50), rnd(20), rnd() * 2, rnd() * 2, r, r + 2)
	-- end

	create_projectile(worm.x - 6, worm.y - 10, 0, 0, 4, 10)
end

function jump(c_worm)
	worm.grounded = false
	c_worm.vy = -1
	c_worm.jumping = true
end

function find_surface_y(x, y, max)
	x = flr(x)
	y = flr(y)

	max = max or cfg.max_slope

	for i = 0, cfg.max_slope do
		if not is_solid(x, y - i) then return y - i end
	end

	return false
end

function find_ground_y(x, y)
	x = flr(x)
	y = flr(y)

	for i = 0, cfg.max_slope do
		if is_solid(x, y + i) then return y + i end
	end
	return false
end

function explode(cx, cy, damage_radius)
	carve_circle(cx, cy, damage_radius)
	local max_damage = 70
	-- TODO(human): Step 1 - Calculate distance from explosion to worm
	local dist = sqrt((cx - worm.x) ^ 2 + (cy - worm.y) ^ 2)
	if dist <= damage_radius then
		-- we hit the worm
		-- check if terrain is between and block damage, reduce it
		-- from the detonation y - some offset to destination the worm, check if some tiles are solid
		local target_x, target_y = worm.x - cx, worm.y - cy
		local step_x, step_y = target_x / dist, target_y / dist
		local blocks_between = 0
		for i = 1, flr(dist) do
			if is_solid(cx + step_x * i, cy + step_y * i) then
				blocks_between += 1
			end
		end

		local damage_factor = (dist / damage_radius)
		local damage = max_damage * damage_factor
		worm.hp -= damage
		create_damage_num(worm.x, worm.y - worm.r - 2, flr(damage))

		-- TODO switch to a new state?!?

		local push_x = worm.x - cx
		local push_y = worm.y - cy

		local len = sqrt(push_x * push_x + push_y * push_y)
		if len == 0 then len = 1 end

		local norm_x = push_x / len
		local norm_y = push_y / len

		local strength = damage_factor * 2
		worm.y -= 2
		worm.vx = norm_x * strength
		worm.vy = norm_y * strength
	end

	-- end (close the damage radius check)
end

function is_grounded(c_worm)
	return is_solid(c_worm.x, c_worm.y + c_worm.r + 1)
end

function try_move(c_worm, dx, dy)
        local r = c_worm.r

        if dx ~= 0 then
                local nx = c_worm.x + dx
                if circle_collides(nx, c_worm.y, r) then
                        local climbed = false
                        for i = 1, cfg.max_slope do
                                if not circle_collides(nx, c_worm.y - i, r) then
                                        c_worm.x = nx
                                        c_worm.y -= i
                                        climbed = true
                                        break
                                end
                        end
                        if not climbed then
                                c_worm.vx = 0
                        end
                else
                        c_worm.x = nx
                        local drop = 0
                        while drop < cfg.max_slope and not circle_collides(c_worm.x, c_worm.y + drop + 1, r) do
                                drop += 1
                        end
                        if drop > 0 and drop < cfg.max_slope and circle_collides(c_worm.x, c_worm.y + drop + 1, r) then
                                c_worm.y += drop
                        end
                end
        end

        if dy ~= 0 then
                local ny = c_worm.y + dy
                if dy > 0 then
                        if circle_collides(c_worm.x, ny, r) then
                                while dy > 0 and not circle_collides(c_worm.x, c_worm.y + 1, r) do
                                        c_worm.y += 1
                                        dy -= 1
                                end
                                c_worm.vy = 0
                                c_worm.jumping = false
                        else
                                c_worm.y = ny
                        end
                else
                        if circle_collides(c_worm.x, ny, r) then
                                while dy < 0 and not circle_collides(c_worm.x, c_worm.y - 1, r) do
                                        c_worm.y -= 1
                                        dy += 1
                                end
                                c_worm.vy = 0
                        else
                                c_worm.y = ny
                        end
                end
        end

        c_worm.grounded = is_grounded(c_worm)
        if c_worm.grounded then c_worm.jumping = false end
end

function create_damage_num(x, y, amount)
	local dam = {
		x = x,
		y = y,
		amount = amount,
		ttl = 0.4
	}

	add(damage_nums, dam)
end

function update_damage_nums()
	for i = #damage_nums, 1, -1 do
		local dam = damage_nums[i]
		dam.y -= 0.3
		dam.ttl -= 1 / 60
		if dam.ttl <= 0 then
			deli(damage_nums, i)
		end
	end
end

function draw_damage_nums()
	for dam in all(damage_nums) do
		print("- " .. dam.amount, dam.x, dam.y, 14)
	end
end

function create_projectile(x, y, vx, vy, r, explosion_radius, bounces)
	local proj = {
		x = x,
		y = y,
		vx = vx,
		vy = vy,
		r = r,
		explosion_radius = explosion_radius,
		bounces = bounces or 0,
		alive = true,
		-- 2 seconds
		ttl = 10
	}

	add(projectiles, proj)
end

function update_worm()
	worm.grounded = is_grounded(worm)
	if not worm.grounded then
		worm.vy += grav
	else
		worm.vx = 0
	end

	if btn(0) and worm.grounded then
		worm.vx = -0.2
		if worm.facing == 1 then
			worm.facing = -1
			-- mirror aim angle: right range [-0.2, 0.2] -> left range [0.7, 0.3]
			worm.aim_angle = 0.5 - worm.aim_angle
		end

		-- pancam(-1, 0)
	elseif btn(1) and worm.grounded then
		-- pancam(1, 0)

		worm.vx = 0.2
		if worm.facing == -1 then
			worm.facing = 1
			-- mirror aim angle: left range [0.3, 0.7] -> right range [0.2, -0.2]
			worm.aim_angle = 0.5 - worm.aim_angle
		end
	end
	if btn(2) and not worm.jumping and not fn_active then
		jump(worm)
		-- pancam(0, -1)
	end

	if btn(2) and fn_active then
		-- aim up
		local inc = worm.facing
		worm.aim_angle += 0.01 * worm.facing
	end

	if btn(3) and fn_active then
		-- aim down
		local inc = worm.facing
		worm.aim_angle -= 0.01 * worm.facing
	end

	if worm.facing == 1 then
		worm.aim_angle = clamp(worm.aim_angle, -0.2, 0.2)
	else
		worm.aim_angle = clamp(worm.aim_angle, 0.3, 0.7)
	end

	try_move(worm, worm.vx, worm.vy)
end

function update_projectiles()
	local time_per_frame = 1 / 60
	for i = #projectiles, 1, -1 do
		local proj = projectiles[i]
		if not proj.alive then deli(projectiles, i) end
		--proj.ttl -= time_per_frame
		if proj.ttl <= 0 then
			proj.alive = false
			explode(proj.x, proj.y, proj.explosion_radius)
		else
			proj.vy += grav * 2

			-- Store old position, move projectile, then check path for collision

			--local steps = max(flr(proj.vx), flr(proj.vy))
			local dist = flr(sqrt(proj.vx * proj.vx + proj.vy * proj.vy))
			local steps = max(1, dist)
			local nx, ny = proj.x + proj.vx, proj.y + proj.vy

			for i = 1, steps do
				local move = i / steps
				nx, ny = proj.x + proj.vx * move, proj.y + proj.vy * move
				if collide_circle(nx, ny, proj.r) then
					proj.alive = false
					local ground_y = find_surface_y(nx, ny, 10)

					-- explode(nx, ny + proj.r + 1, proj.explosion_radius, proj.explosion_radius * 2)
					explode(nx, ny + proj.r + 1, proj.explosion_radius)
					goto continue
				else
				end
			end

			::continue::
			proj.x = nx
			proj.y = ny
		end
	end
end

function update_cam()
	-- cfg.cam_x = lerp(cfg.cam_x, cfg.cam_target.x, cfg.cam_speed)
	-- cfg.cam_y = lerp(cfg.cam_y, cfg.cam_target.y, cfg.cam_speed)
	cfg.cam_x = cfg.cam_target.x
	cfg.cam_y = cfg.cam_target.y

	-- Clamp camera to world bounds
	cfg.cam_x = clamp(cfg.cam_x, 64, cfg.world_w - 64)
	cfg.cam_y = clamp(cfg.cam_y, 64, cfg.world_h - 64)
end

function _update60()
	update_projectiles()
	update_damage_nums()
	update_worm()
	update_cam()

	-- Check for debug keys (G and D)
	if debug_ball.max_bounce > 0 then
		debug_ball.dy += grav
	end
	local new_x = debug_ball.x
			+ debug_ball.dx
	local new_y = debug_ball.y
			+ debug_ball.dy

	-- 2. Kollision prれもfen
	if collide_circle(
		new_x, new_y,
		debug_ball.r
	) then
		debug_ball.max_bounce -= 1

		if debug_ball.max_bounce <= 0 then
			debug_ball.dx = 0
			debug_ball.dy = 0
		else
			local nx, ny = ground_normal(
				new_x,
				new_y, debug_ball.r
			)

			local dot = debug_ball.dx * nx + debug_ball.dy * ny

			debug_ball.dx = (debug_ball.dx - 2 * dot * nx) * 0.8
			debug_ball.dy = (debug_ball.dy - 2 * dot * ny) * 0.8

			debug_ball.x += debug_ball.dx
			debug_ball.y += debug_ball.dy
		end
		-- 3. Normale holen und Ball

		-- 4. Geschwindigkeit reflektieren
		-- 5. Position korrigieren
	else
		-- Keine Kollision: normal bewegen
		debug_ball.x = new_x
		debug_ball.y = new_y
	end

	mx, my = stat(32), stat(33)

	if stat(34) == 1 and #projectiles == 0 then
		-- Convert screen coordinates to world coordinates
		local world_x = mx + (cfg.cam_x - 64)
		local world_y = my + (cfg.cam_y - 64)
		dbg_custom = "mx=" .. mx .. " cx=" .. flr(cfg.cam_x) .. " wx=" .. flr(world_x)
		create_projectile(world_x, world_y, 0, 0, 4, 14)
	end

	if btn(3) then
		-- pancam(0, 1)
	end

	if btn(cfg.buttons.fn) then
		fn_active = true
	else
		fn_active = false
	end

	if btn(cfg.buttons.shoot) then
		--(x, y, vx, vy, r, explosion_radius, bounces)
		worm.power += worm.power_step
		worm.power = min(worm.max_power, worm.power)

		if worm.power == worm.max_power then
			dbg_custom = "shoot now"
			local aim_x = worm.x + cos(worm.aim_angle) * (worm.r + 1)
			local aim_y = worm.y + sin(worm.aim_angle) * (worm.r + 1)
			local dx = cos(worm.aim_angle) * worm.power * 0.3
			local dy = sin(worm.aim_angle) * worm.power * 0.3

			create_projectile(aim_x, aim_y, dx, dy, 2, 8)
			worm.power = 0
			-- shoot
		end
	else
		if worm.power > 0 then
			local dx = cos(worm.aim_angle) * worm.power * 0.3
			local dy = sin(worm.aim_angle) * worm.power * 0.3
			local aim_x = worm.x + cos(worm.aim_angle) * (worm.r + 1)
			local aim_y = worm.y + sin(worm.aim_angle) * (worm.r + 1)
			create_projectile(aim_x, aim_y, dx, dy, 2, 8)
			worm.power = 0
			-- shoot
		end
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

function drawmap_with(cam_x)
	local start_x = max(0, cam_x)
	local end_x = min(cfg.world_w, cam_x + 128)
	for x = start_x, end_x do
		-- scanline
		local lines = terrain[x + 1]
		if not lines then
			return
		end
		if #lines == 0 then
			-- Fallback: draw minimal terrain at bottom if completely destroyed
			--line(x, cfg.world_h - 5, x, cfg.world_h - 1, 8)
		else
			for sl in all(lines) do
				if not sl or #sl < 2 then
					return
				end
				line(x, sl[1], x, sl[2] - 1, 8)
			end
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

function draw_shoot_progress_bar()
	local rx, ry = flr(worm.x + 0.5), flr(worm.y + 0.5)
	local w, h = worm.r * 2 + 4, worm.r / 2

	-- draw progress

	local x1 = rx - worm.r - 2
	local x2 = lerp(x1, rx + worm.r + 2, worm.power / worm.max_power)

	if worm.power > 0 then
		rectfill(x1, ry - worm.r - 4, x2, ry - worm.r - 2, 12)
	end
	-- draw border

	if worm.power > 0 then
		rect(rx - worm.r - 2, ry - worm.r - 4, rx + worm.r + 2, ry - worm.r - 2, 14)
	end
end

function _draw()
	local cam_x, cam_y = flr(cfg.cam_x - 64 + 0.5), flr(cfg.cam_y - 64 + 0.5)
	camera(cam_x, cam_y)
	cls(cfg.bg_col)
	drawmap_with(cam_x)
	--circ(debug_ball.x, debug_ball.y, debug_ball.r)

	-- draw worms
	local rx, ry = flr(worm.x + 0.5), flr(worm.y + 0.5)
	circfill(rx, ry, worm.r, 9)
	-- aim
	local aim_x = rx + cos(worm.aim_angle) * (worm.r + 8)
	local aim_y = ry + sin(worm.aim_angle) * (worm.r + 8)

	circfill(aim_x, aim_y, 1, 14)

	-- shoot progress
	draw_shoot_progress_bar()

	-- draw projs
	for proj in all(projectiles) do
		circfill(proj.x, proj.y, proj.r, 11)
	end
	draw_damage_nums()
	camera()
	-- draw mouse (screen coordinates after camera reset)
	circfill(mx, my, 2, 10)
	if cfg.debug then
		drawdebug()
	end
end

function clamp(v, lo, hi)
	return mid(lo, v, hi)
end

function lerp(a, b, t)
	return (1 - t) * a + b * t
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
