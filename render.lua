-- Generic world rendering utilities shared across states.
--
-- The core game loop delegates drawing to a state, but most states
-- render the same world elements (terrain, worms, projectiles,
-- damage numbers and optional debug overlays).  This module exposes a
-- single helper so states can render the world without duplicating
-- code.
--
-- Usage:
--   draw_world(true)  -- draws world and active worm UI
--   draw_world(false) -- draws world without UI elements
function draw_world(show_active_worm_ui)
  -- camera coordinates snapped to integers to avoid sub-pixel jitter
  local cam_x = flr(cfg.cam_x - 64 + 0.5)
  local cam_y = flr(cfg.cam_y - 64 + 0.5)
  camera(cam_x, cam_y)

  -- clear the screen and draw terrain relative to camera
  cls(cfg.bg_col)
  drawmap_with(cam_x)

  -- draw all worms; optionally show UI for the active worm
  for t in all(teams) do
    for w in all(t.worms) do
      local rx = flr(w.x + 0.5)
      local ry = flr(w.y + 0.5)
      circfill(rx, ry, w.r, t.col)

      -- UI elements such as aim indicator and power bar are only shown
      -- when player control is active.
      if show_active_worm_ui and w == active_worm then
        local aim_x = rx + cos(w.aim_angle) * (w.r + 8)
        local aim_y = ry + sin(w.aim_angle) * (w.r + 8)
        circfill(aim_x, aim_y, 1, 14)
        draw_shoot_progress_bar(w)
      end
    end
  end

  -- draw all active projectiles
  for proj in all(projectiles) do
    circfill(proj.x, proj.y, proj.r, 11)
  end

  -- floating damage numbers are always rendered
  draw_damage_nums()

  -- return to screen space for overlays like debug info
  camera()

  -- crosshair is only useful while the player is aiming
  if show_active_worm_ui then
    circfill(mx, my, 2, 10)
  end

  -- optional debugging overlays
  if cfg.debug then
    drawdebug()
  end
end
