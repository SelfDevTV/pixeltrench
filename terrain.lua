terrain = {}
surface_y = {}

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
