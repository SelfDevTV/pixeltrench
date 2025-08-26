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

-- TODO: Main update loop for the player's turn.
function play_state:update()
  -- TODO: handle input to move and aim the active worm.
  -- TODO: when the player fires, create a projectile and switch to
  --       `projectileFollow` via `statemachine:switch`.
  -- TODO: update world physics and keep the camera centered on the
  --       active worm.
end

