-- cam follows projectile, worms control disabled
-- after explosion or out of world bounds, switch to endRound state

-- state responsible for tracking a projectile mid flight.
-- The state assumes a projectile table instance is provided on enter via
-- the params table.
-- While active it:
--  * keeps the camera centered on the projectile
--  * updates projectile and world physics
--  * ignores player controls by updating all worms as inactive
-- Once the projectile is no longer alive (exploded or out of bounds)
-- it transitions to the `endRound` state.

projectile_follow_state = {}

function projectile_follow_state:enter(params)
  -- store a reference to the projectile we should follow
  -- params is expected to be a table like {projectile = <proj>}
  -- if no projectile provided we fallback to the last one created
  self.projectile = params and params.projectile or projectiles[#projectiles]
  -- ensure camera tracks this projectile
  cfg.cam_target = self.projectile
end

function projectile_follow_state:exit()
  -- when leaving we point the camera back to the active worm
  cfg.cam_target = active_worm
end

function projectile_follow_state:update()
  -- update physics for projectiles and floating damage numbers
  update_projectiles()
  update_damage_nums()

  -- update worms without letting the player control them
  -- by always passing false for the is_active flag
  for t in all(teams) do
    for w in all(t.worms) do
      update_worm(w, false)
    end
  end

  -- If the projectile is still alive keep the camera centered on it
  if self.projectile and self.projectile.alive then
    cfg.cam_target = self.projectile
    update_cam()

    -- handle out of world bounds by killing the projectile
    if self.projectile.x < 0 or self.projectile.x > cfg.world_w
       or self.projectile.y < 0 or self.projectile.y > cfg.world_h then
      self.projectile.alive = false
    end
  else
    -- projectile is gone → switch to end of round
    statemachine:switch("endRound")
  end
end

