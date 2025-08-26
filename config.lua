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
    shoot = 4,
    fn = 5
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

debug_ball = {
  x = 20,
  y = 20,
  dx = 0.8,
  dy = 0.7,
  r = 5,
  max_bounce = 5
}
