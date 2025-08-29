pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
#include statemachine.lua
#include states/endRound.lua
#include states/play.lua
#include states/projectileFollow.lua
#include config.lua
#include util.lua
#include terrain.lua
#include damage.lua
#include projectile.lua
#include worm.lua
#include camera.lua
#include debug.lua


function _init()
  poke(0x5f2d, 1)
  set_seed(rnd())
  -- Enable devkit mode
  genmap()
  lastSoilPct = soil_coverage_pct()
  -- create two teams with two worms each
  local team1 = create_team(11) -- green
  local team2 = create_team(9) -- orange

  add(team1.worms, create_worm(50, 30))
  add(team1.worms, create_worm(80, 30))

  add(team2.worms, create_worm(150, 30))
  add(team2.worms, create_worm(180, 30))

  for w in all(team1.worms) do w.team = team1 end
  for w in all(team2.worms) do w.team = team2 end

  add(teams, team1)
  add(teams, team2)

  active_team = teams[active_team_idx]
  active_worm = active_team.worms[active_worm_idx]
  cfg.cam_target = active_worm

  -- create_projectile(active_worm.x - 6, active_worm.y - 10, 0, 0, 4, 10)

  -- Register and activate game states.  Drawing and update logic are
  -- delegated to the current state by the statemachine module.
  statemachine:add("play", play_state)
  statemachine:add("projectileFollow", projectile_follow_state)
  statemachine:add("endRound", end_round_state)
  statemachine:switch("play")
end

function _update60()
  statemachine:update()
  --update_projectiles()
  --update_damage_nums()
  -- for t in all(teams) do
  --   for w in all(t.worms) do
  --     update_worm(w, w == active_worm)
  --   end
  -- end
  cfg.cam_target = active_worm
  update_cam()

  -- Check for debug keys (G and D)
  if debug_ball.max_bounce > 0 then
    debug_ball.dy += grav
  end
  local new_x = debug_ball.x + debug_ball.dx
  local new_y = debug_ball.y + debug_ball.dy

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

  local c_worm = active_worm
  if btn(cfg.buttons.shoot) then
    c_worm.power += c_worm.power_step
    c_worm.power = min(c_worm.max_power, c_worm.power)

    if c_worm.power == c_worm.max_power then
      dbg_custom = "shoot now"
      local aim_x = c_worm.x + cos(c_worm.aim_angle) * (c_worm.r + 1)
      local aim_y = c_worm.y + sin(c_worm.aim_angle) * (c_worm.r + 1)
      local dx = cos(c_worm.aim_angle) * c_worm.power * 0.3
      local dy = sin(c_worm.aim_angle) * c_worm.power * 0.3

      create_projectile(aim_x, aim_y, dx, dy, 2, 8)
      c_worm.power = 0
    end
  else
    if c_worm.power > 0 then
      local dx = cos(c_worm.aim_angle) * c_worm.power * 0.3
      local dy = sin(c_worm.aim_angle) * c_worm.power * 0.3
      local aim_x = c_worm.x + cos(c_worm.aim_angle) * (c_worm.r + 1)
      local aim_y = c_worm.y + sin(c_worm.aim_angle) * (c_worm.r + 1)
      create_projectile(aim_x, aim_y, dx, dy, 2, 8)
      c_worm.power = 0
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

-- Shared world rendering helper used by the central draw routine.
#include render.lua

function _draw()
  -- Show worm UI only while the play state is active.
  local show_ui = statemachine.active_state == play_state
  draw_world(show_ui)
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
