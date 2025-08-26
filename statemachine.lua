statemachine = {
    states = {},
    active_state = nil
}

function statemachine:switch(state_key, params)
    if self.active_state then
        self.active_state:exit()
    end
    self.active_state = self.states[state_key]
    self.active_state:enter(params)
end

function statemachine:add(key, state)
    self.states[key] = state
end

function statemachine:update()
    self.active_state:update()
end

function statemachine:draw()
    self.active_state:draw()
end

