-- normal state where current player can move, after time out or shot..
-- .. state switches to the projectileFollow state

play_state = {}

-- TODO: Called when this state becomes active.
-- Use this to choose the active worm and set up any per-turn state
-- such as timers or camera focus.
function play_state:enter(params)
  -- TODO: store parameters like the active worm and reset the camera
  --       to follow it.
end

-- TODO: Clean up any temporary values before switching away from play.
function play_state:exit()
  -- TODO: perform cleanup here if necessary.
end

function play_state:update()
  -- update fn modifier and aiming state
  fn_active = btn(cfg.buttons.fn)

  -- update all worms; only the active worm receives player input
  for t in all(teams) do
    for w in all(t.worms) do
      update_worm(w, w == active_worm)
    end
  end

  -- handle shooting charge/release for the active worm
  local c_worm = active_worm
  if btn(cfg.buttons.shoot) then
    c_worm.power = min(c_worm.max_power, c_worm.power + c_worm.power_step)
    if c_worm.power == c_worm.max_power then
      -- auto-fire at max power
      local dx = cos(c_worm.aim_angle) * c_worm.power * 0.3
      local dy = sin(c_worm.aim_angle) * c_worm.power * 0.3
      local sx = c_worm.x + cos(c_worm.aim_angle) * (c_worm.r + 1)
      local sy = c_worm.y + sin(c_worm.aim_angle) * (c_worm.r + 1)
      create_projectile(sx, sy, dx, dy, 2, 8)
      c_worm.power = 0
      statemachine:switch("projectileFollow", { projectile = projectiles[#projectiles] })
      return
    end
  elseif c_worm.power > 0 then
    -- fire on button release
    local dx = cos(c_worm.aim_angle) * c_worm.power * 0.3
    local dy = sin(c_worm.aim_angle) * c_worm.power * 0.3
    local sx = c_worm.x + cos(c_worm.aim_angle) * (c_worm.r + 1)
    local sy = c_worm.y + sin(c_worm.aim_angle) * (c_worm.r + 1)
    create_projectile(sx, sy, dx, dy, 2, 8)
    c_worm.power = 0
    statemachine:switch("projectileFollow", { projectile = projectiles[#projectiles] })
    return
  end

  -- update transient effects
  update_damage_nums()

  -- keep camera centered on the active worm
  cfg.cam_target = active_worm
  update_cam()
end
