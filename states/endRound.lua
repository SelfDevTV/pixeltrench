-- State executed after a projectile has finished its flight.
-- Gives the world time to settle before the next player's turn.
-- For now the state only renders the world without player UI.

end_round_state = {}

-- TODO: Called when a projectile has finished and the round ends.
-- Use this to start any delay timer and prepare the next player.
function end_round_state:enter(params)
  -- TODO: capture parameters such as which worm should act next.
  -- TODO: optionally start a countdown to let the world settle.
end


function end_round_state:exit()
  -- reset any per-round timers or transient state
  self.delay = 0
  self.next_worm = nil
  -- ensure camera targets the active worm for the next state
  cfg.cam_target = active_worm
end

-- TODO: Wait for the world to settle, then advance to the next turn.
function end_round_state:update()
  -- TODO: update physics if needed and watch for the delay timer expiring.
  -- TODO: when ready, switch back to the `play` state using
  --       `statemachine:switch("play")` and pass the next worm.
  -- TODO: check win/loss conditions before switching back.
end
