-- Mars lander graphics - handles all visual rendering of the lander
local LanderGraphics = {}
LanderGraphics.__index = LanderGraphics

-- Explosion colors - these are specific to the graphics component
local EXPLOSION_COLORS = {
    {1, 0.7, 0.1, 1},    -- Orange
    {1, 0.5, 0, 1},      -- Dark orange
    {1, 0.3, 0, 1},      -- Red-orange
    {1, 1, 0.3, 1}       -- Yellow
}

---Creates a new lander graphics instance
---@param model table The lander model to render
---@return table The new lander graphics instance
function LanderGraphics.new(model)
    local self = setmetatable({}, LanderGraphics)
    self.model = model
    return self
end

---Draws the lander
function LanderGraphics:draw()
    -- Save current transformation
    love.graphics.push()
    
    -- If crashed and explosion is active, draw explosion instead of lander
    if self.model.crashed and self.model.explosion.active then
        self:drawExplosion()
    else
        -- Move to lander position
        love.graphics.translate(self.model.x, self.model.y)
        love.graphics.rotate(self.model.rotation)
        
        self:drawLanderBody()
        
        -- Draw thrust flame if active
        if self.model.thrust_active and self.model.fuel > 0 then
            self:drawThrustFlame()
        end
    end
    
    -- Restore transformation
    love.graphics.pop()
end

---Draws the lander body and components
function LanderGraphics:drawLanderBody()
    -- Draw lander body (main module) - Mars mission color scheme
    love.graphics.setColor(0.8, 0.8, 0.8)  -- Light gray for the main body
    love.graphics.rectangle("fill", -self.model.width / 2, -self.model.height / 2, 
                           self.model.width, self.model.height)
    
    -- Draw top section (command module)
    love.graphics.setColor(0.7, 0.7, 0.7)  -- Slightly darker gray
    local top_width = self.model.width * 0.8
    local top_height = self.model.height * 0.4
    love.graphics.rectangle("fill", -top_width / 2, -self.model.height / 2, top_width, top_height)
    
    -- Draw window/viewport
    love.graphics.setColor(0.8, 0.9, 1)  -- Light blue for window
    local window_size = self.model.width * 0.3
    love.graphics.rectangle("fill", -window_size / 2, -self.model.height / 2 + top_height * 0.2, 
                           window_size, window_size)
    
    -- Draw side pods/fuel tanks - Mars mission orange accents
    love.graphics.setColor(0.9, 0.4, 0.1)  -- Mars orange color
    local pod_width = self.model.width * 0.2
    local pod_height = self.model.height * 0.5
    love.graphics.rectangle("fill", -self.model.width / 2 - pod_width, -pod_height / 2, 
                           pod_width, pod_height)
    love.graphics.rectangle("fill", self.model.width / 2, -pod_height / 2, 
                           pod_width, pod_height)
    
    self:drawLandingGear()
    self:drawDutchFlag()
end

---Draws the landing gear
function LanderGraphics:drawLandingGear()
    -- Draw landing gear (legs and feet)
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.setLineWidth(2)
    
    -- Left leg
    love.graphics.line(-self.model.width / 2, self.model.height / 2, 
                      -self.model.width, self.model.height / 2 + 8)
    -- Right leg
    love.graphics.line(self.model.width / 2, self.model.height / 2, 
                      self.model.width, self.model.height / 2 + 8)
    
    -- Feet
    love.graphics.rectangle("fill", -self.model.width - 5, self.model.height / 2 + 8, 10, 2)
    love.graphics.rectangle("fill", self.model.width - 5, self.model.height / 2 + 8, 10, 2)
end

---Draws the explosion effect
function LanderGraphics:drawExplosion()
    for _, particle in ipairs(self.model.explosion.particles) do
        local color = EXPLOSION_COLORS[particle.color_index]
        love.graphics.setColor(color[1], color[2], color[3], particle.alpha)
        
        -- Draw particle as a small circle
        love.graphics.circle("fill", particle.x, particle.y, particle.size)
    end
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

---Draws the thrust flame
function LanderGraphics:drawThrustFlame()
    -- Get current time for animation
    local time = love.timer.getTime()
    
    -- Base flame size with pulsing animation
    local flame_size = 12 + math.sin(time * 15) * 5
    
    -- Add slight random variation to make flame more dynamic
    flame_size = flame_size + math.random(-1, 1)
    
    -- Outer flame glow (semi-transparent orange)
    love.graphics.setColor(1, 0.5, 0.1, 0.3)
    love.graphics.polygon("fill", 
        -self.model.width / 2.5, self.model.height / 2,
        self.model.width / 2.5, self.model.height / 2,
        0, self.model.height / 2 + flame_size * 1.2
    )
    
    -- Main flame (yellow-orange)
    love.graphics.setColor(1, 0.7, 0.2)
    love.graphics.polygon("fill", 
        -self.model.width / 3, self.model.height / 2,
        self.model.width / 3, self.model.height / 2,
        0, self.model.height / 2 + flame_size
    )
    
    -- Inner flame (bright yellow)
    love.graphics.setColor(1, 1, 0.5)
    love.graphics.polygon("fill", 
        -self.model.width / 6, self.model.height / 2,
        self.model.width / 6, self.model.height / 2,
        0, self.model.height / 2 + flame_size * 0.8
    )
    
    -- Hottest part of flame (white core)
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.polygon("fill", 
        -self.model.width / 10, self.model.height / 2,
        self.model.width / 10, self.model.height / 2,
        0, self.model.height / 2 + flame_size * 0.5
    )
    
    self:drawFlameParticles(flame_size)
end

---Draws flame particles for a more dynamic effect
---@param flame_size number The base size of the flame
function LanderGraphics:drawFlameParticles(flame_size)
    for i = 1, 5 do
        local particle_size = 1.5 + math.random() * 3
        local offset_x = (math.random() - 0.5) * self.model.width * 0.8
        local offset_y = flame_size * (0.3 + math.random() * 0.7)
        
        -- Randomize particle color (yellow to orange to red)
        love.graphics.setColor(1, math.random(0.5, 1), math.random(0, 0.3), math.random(0.4, 0.9))
        love.graphics.circle("fill", offset_x, self.model.height / 2 + offset_y, particle_size)
    end
end

---Draws the Dutch flag on the lander
function LanderGraphics:drawDutchFlag()
    -- Flag dimensions
    local flag_width = self.model.width * 0.3
    local flag_height = self.model.height * 0.15
    
    -- Position flag at the bottom right of the mid section
    local flag_x = self.model.width * 0.1  -- Shifted to the right
    local flag_y = self.model.height * 0.05  -- Shifted to the bottom
    
    -- Draw flag outline
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("line", flag_x, flag_y, flag_width, flag_height)
    
    -- Draw the three horizontal stripes of the Dutch flag
    local stripe_height = flag_height / 3
    
    -- Top stripe (red)
    love.graphics.setColor(0.9, 0.1, 0.1)
    love.graphics.rectangle("fill", flag_x, flag_y, flag_width, stripe_height)
    
    -- Middle stripe (white)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", flag_x, flag_y + stripe_height, flag_width, stripe_height)
    
    -- Bottom stripe (blue)
    love.graphics.setColor(0.1, 0.1, 0.7)
    love.graphics.rectangle("fill", flag_x, flag_y + stripe_height * 2, flag_width, stripe_height)
end

return LanderGraphics 