function update_cam()
  -- cfg.cam_x = lerp(cfg.cam_x, cfg.cam_target.x, cfg.cam_speed)
  -- cfg.cam_y = lerp(cfg.cam_y, cfg.cam_target.y, cfg.cam_speed)
  cfg.cam_x = cfg.cam_target.x
  cfg.cam_y = cfg.cam_target.y
  -- Clamp camera to world bounds
  cfg.cam_x = clamp(cfg.cam_x, 64, cfg.world_w - 64)
  cfg.cam_y = clamp(cfg.cam_y, 64, cfg.world_h - 64)
end
