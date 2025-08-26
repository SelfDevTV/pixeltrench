function create_worm(x, y)
  return {
    x = x,
    y = y,
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
end

function create_team(col)
  return { worms = {}, col = col }
end

teams = {}
active_team_idx = 1
active_team = nil
active_worm_idx = 1
active_worm = nil

function jump(c_worm)
  c_worm.grounded = false
  c_worm.vy = -1
  c_worm.jumping = true
end

function is_grounded(c_worm)
  -- sample a circle slightly below the worm to detect ground under any part
  return circle_collides(c_worm.x, c_worm.y + 1, c_worm.r)
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
        -- ensure the worm stays grounded if blocked by a steep slope
        local drop = 0
        while drop < cfg.max_slope and not circle_collides(c_worm.x, c_worm.y + drop + 1, r) do
          drop += 1
        end
        if drop > 0 and drop < cfg.max_slope and circle_collides(c_worm.x, c_worm.y + drop + 1, r) then
          c_worm.y += drop
        end
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

function update_worm(c_worm, is_active)
  c_worm.grounded = is_grounded(c_worm)
  if not c_worm.grounded then
    c_worm.vy += grav
  else
    c_worm.vx = 0
  end

  if is_active then
    if btn(0) and c_worm.grounded then
      c_worm.vx = -0.2
      if c_worm.facing == 1 then
        c_worm.facing = -1
        -- mirror aim angle: right range [-0.2, 0.2] -> left range [0.7, 0.3]
        c_worm.aim_angle = 0.5 - c_worm.aim_angle
      end
    elseif btn(1) and c_worm.grounded then
      c_worm.vx = 0.2
      if c_worm.facing == -1 then
        c_worm.facing = 1
        -- mirror aim angle: left range [0.3, 0.7] -> right range [0.2, -0.2]
        c_worm.aim_angle = 0.5 - c_worm.aim_angle
      end
    end

    if btn(2) and not c_worm.jumping and not fn_active then
      jump(c_worm)
    end

    if btn(2) and fn_active then
      -- aim up
      c_worm.aim_angle += 0.01 * c_worm.facing
    end

    if btn(3) and fn_active then
      -- aim down
      c_worm.aim_angle -= 0.01 * c_worm.facing
    end
  end

  if c_worm.facing == 1 then
    c_worm.aim_angle = clamp(c_worm.aim_angle, -0.2, 0.2)
  else
    c_worm.aim_angle = clamp(c_worm.aim_angle, 0.3, 0.7)
  end

  try_move(c_worm, c_worm.vx, c_worm.vy)
end

function draw_shoot_progress_bar(c_worm)
  local rx, ry = flr(c_worm.x + 0.5), flr(c_worm.y + 0.5)
  local x1 = rx - c_worm.r - 2
  local x2 = lerp(x1, rx + c_worm.r + 2, c_worm.power / c_worm.max_power)
  if c_worm.power > 0 then
    rectfill(x1, ry - c_worm.r - 4, x2, ry - c_worm.r - 2, 12)
    rect(rx - c_worm.r - 2, ry - c_worm.r - 4, rx + c_worm.r + 2, ry - c_worm.r - 2, 14)
  end
end
