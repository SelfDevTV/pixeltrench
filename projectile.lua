projectiles = {}

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

function explode(cx, cy, damage_radius)
  carve_circle(cx, cy, damage_radius)
  local max_damage = 70
  for t in all(teams) do
    for w in all(t.worms) do
      local dist = sqrt((cx - w.x) ^ 2 + (cy - w.y) ^ 2)
      if dist <= damage_radius then
        -- check if terrain is between and block damage, reduce it
        local target_x, target_y = w.x - cx, w.y - cy
        local step_x, step_y = target_x / dist, target_y / dist
        local blocks_between = 0
        for i = 1, flr(dist) do
          if is_solid(cx + step_x * i, cy + step_y * i) then
            blocks_between += 1
          end
        end
        local damage_factor = (dist / damage_radius)
        local damage = max_damage * damage_factor
        w.hp -= damage
        create_damage_num(w.x, w.y - w.r - 2, flr(damage))
        local push_x = w.x - cx
        local push_y = w.y - cy
        local len = sqrt(push_x * push_x + push_y * push_y)
        if len == 0 then len = 1 end
        local norm_x = push_x / len
        local norm_y = push_y / len
        local strength = damage_factor * 2
        w.y -= 2
        w.vx = norm_x * strength
        w.vy = norm_y * strength
      end
    end
  end
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
