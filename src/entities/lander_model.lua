-- Mars lander model - handles physics, state, and game logic
local LanderModel = {}
LanderModel.__index = LanderModel

-- Constants
local GRAVITY = 38  -- Mars gravity (38% of Earth's gravity)
local THRUST_POWER = 200
local ROTATION_SPEED = 3
local FUEL_CONSUMPTION_RATE = 40.0  -- Significantly increased from 2.0 for faster fuel depletion
local INITIAL_FUEL = 100
local SAFE_LANDING_VELOCITY = 80
local SAFE_LANDING_ANGLE = 0.5  -- About 28 degrees in radians

-- Explosion constants
local EXPLOSION_DURATION = 1.5  -- Duration of explosion animation in seconds
local EXPLOSION_PARTICLES = 60  -- Number of particles in the explosion

---Creates a new lander model instance
---@param x number Initial x position
---@param y number Initial y position
---@return table The new lander model instance
function LanderModel.new(x, y)
    local self = setmetatable({}, LanderModel)
    
    -- Position
    self.x = x
    self.y = y
    
    -- Size
    self.width = 20
    self.height = 30
    
    -- Velocity
    self.velocity_x = 0
    self.velocity_y = 0
    
    -- Rotation (in radians)
    self.rotation = 0
    
    -- State
    self.thrust_active = false
    self.fuel = INITIAL_FUEL
    self.landed = false
    self.crashed = false
    
    -- Explosion particles
    self.explosion = {
        active = false,
        particles = {},
        timer = 0
    }
    
    return self
end

---Updates the lander
---@param dt number Delta time
---@param terrain table The terrain to check for collisions
function LanderModel:update(dt, terrain)
    -- Skip update if landed or crashed
    if self.landed or self.crashed then
        -- If crashed, update explosion
        if self.crashed and self.explosion.active then
            self:updateExplosion(dt)
        end
        return
    end
    
    self:applyPhysics(dt)
    self:updatePosition(dt)
    self:handleScreenBoundaries()
    self:checkTerrainCollision(terrain)
end

---Applies physics forces (gravity and thrust)
---@param dt number Delta time
function LanderModel:applyPhysics(dt)
    -- Apply gravity
    self.velocity_y = self.velocity_y + GRAVITY * dt
    
    -- Apply thrust if active and has fuel
    if self.thrust_active and self.fuel > 0 then
        -- Calculate thrust vector based on rotation
        local thrust_x = math.sin(self.rotation) * THRUST_POWER * dt
        local thrust_y = -math.cos(self.rotation) * THRUST_POWER * dt
        
        -- Apply thrust
        self.velocity_x = self.velocity_x + thrust_x
        self.velocity_y = self.velocity_y + thrust_y
        
        -- Consume fuel
        self.fuel = math.max(0, self.fuel - FUEL_CONSUMPTION_RATE * dt)
    end
end

---Updates the lander's position based on velocity
---@param dt number Delta time
function LanderModel:updatePosition(dt)
    self.x = self.x + self.velocity_x * dt
    self.y = self.y + self.velocity_y * dt
end

---Handles screen boundaries (wrap horizontally)
function LanderModel:handleScreenBoundaries()
    -- Check for screen boundaries
    local screen_width = love.graphics.getWidth()
    
    -- Wrap around horizontally
    if self.x < 0 then
        self.x = screen_width
    elseif self.x > screen_width then
        self.x = 0
    end
end

---Updates the explosion animation
---@param dt number Delta time
function LanderModel:updateExplosion(dt)
    -- Update explosion timer
    self.explosion.timer = self.explosion.timer + dt
    
    -- Update each particle
    for i, particle in ipairs(self.explosion.particles) do
        -- Update position
        particle.x = particle.x + particle.vx * dt
        particle.y = particle.y + particle.vy * dt
        
        -- Apply gravity to particles
        particle.vy = particle.vy + GRAVITY * 0.5 * dt
        
        -- Fade out particles over time
        local life_factor = 1 - (self.explosion.timer / EXPLOSION_DURATION)
        particle.alpha = particle.base_alpha * life_factor
        
        -- Shrink particles over time
        particle.size = particle.base_size * life_factor
    end
    
    -- Check if explosion is complete
    if self.explosion.timer >= EXPLOSION_DURATION then
        self.explosion.active = false
    end
end

---Checks for collision with the terrain
---@param terrain table The terrain to check for collisions
function LanderModel:checkTerrainCollision(terrain)
    -- Get lander bottom center point (landing gear position)
    local lander_bottom_x = self.x
    local lander_bottom_y = self.y + self.height / 2
    
    -- Check if the lander is below any terrain segment
    for i = 1, #terrain.segments do
        local segment = terrain.segments[i]
        
        -- Check if lander is horizontally within this segment
        if lander_bottom_x >= segment.x1 and lander_bottom_x <= segment.x2 then
            -- Calculate the y-coordinate of the terrain at the lander's x-position
            local terrain_y = segment.y1 + (segment.y2 - segment.y1) * 
                             ((lander_bottom_x - segment.x1) / (segment.x2 - segment.x1))
            
            -- Check if lander has hit the terrain
            if lander_bottom_y >= terrain_y then
                self:handleTerrainContact(segment, terrain_y)
                return
            end
        end
    end
end

---Handles contact with terrain (landing or crashing)
---@param segment table The terrain segment the lander contacted
---@param terrain_y number The y-coordinate of the terrain at the contact point
function LanderModel:handleTerrainContact(segment, terrain_y)
    -- Check if this is a landing pad
    if segment.is_landing_pad then
        -- Check landing conditions
        local velocity = math.sqrt(self.velocity_x^2 + self.velocity_y^2)
        local angle_diff = math.abs(self.rotation)
        
        if velocity <= SAFE_LANDING_VELOCITY and angle_diff <= SAFE_LANDING_ANGLE then
            -- Safe landing
            self.landed = true
            self.velocity_x = 0
            self.velocity_y = 0
            self.y = terrain_y - self.height / 2  -- Adjust position to sit on terrain
        else
            -- Crashed on landing pad
            self.crashed = true
            self:createExplosion()
        end
    else
        -- Crashed on regular terrain
        self.crashed = true
        self:createExplosion()
    end
end

---Creates an explosion effect
function LanderModel:createExplosion()
    self.explosion.active = true
    self.explosion.timer = 0
    self.explosion.particles = {}
    
    -- Create explosion particles
    for i = 1, EXPLOSION_PARTICLES do
        -- Random angle and velocity
        local angle = math.random() * math.pi * 2
        local speed = 50 + math.random() * 150
        
        -- Random color index (will be used by graphics module)
        local color_index = math.random(1, 4)
        
        -- Create particle
        local particle = {
            x = self.x,
            y = self.y,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed,
            size = 2 + math.random() * 4,
            base_size = 2 + math.random() * 4,
            color_index = color_index,
            alpha = 1,
            base_alpha = 1,
            rotation = math.random() * math.pi * 2,
            rotation_speed = (math.random() - 0.5) * 5
        }
        
        table.insert(self.explosion.particles, particle)
    end
end

---Activates the lander's thrust
function LanderModel:activateThrust()
    if not self.landed and not self.crashed and self.fuel > 0 then
        self.thrust_active = true
    elseif self.fuel <= 0 then
        self.thrust_active = false
    end
end

---Deactivates the lander's thrust
function LanderModel:deactivateThrust()
    self.thrust_active = false
end

---Rotates the lander left
---@param dt number Delta time
function LanderModel:rotateLeft(dt)
    if not self.landed and not self.crashed then
        self.rotation = self.rotation - ROTATION_SPEED * dt
    end
end

---Rotates the lander right
---@param dt number Delta time
function LanderModel:rotateRight(dt)
    if not self.landed and not self.crashed then
        self.rotation = self.rotation + ROTATION_SPEED * dt
    end
end

-- Export constants that might be needed by other modules
LanderModel.CONSTANTS = {
    GRAVITY = GRAVITY,
    THRUST_POWER = THRUST_POWER,
    ROTATION_SPEED = ROTATION_SPEED,
    FUEL_CONSUMPTION_RATE = FUEL_CONSUMPTION_RATE,
    INITIAL_FUEL = INITIAL_FUEL,
    SAFE_LANDING_VELOCITY = SAFE_LANDING_VELOCITY,
    SAFE_LANDING_ANGLE = SAFE_LANDING_ANGLE,
    EXPLOSION_DURATION = EXPLOSION_DURATION,
    EXPLOSION_PARTICLES = EXPLOSION_PARTICLES
}

return LanderModel 