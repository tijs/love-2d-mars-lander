-- Mars skyfield entity representing the Martian sky background
local Starfield = {}
Starfield.__index = Starfield

-- Constants for the skyfield
local NUM_STARS_LAYER1 = 60  -- Distant stars (slow movement)
local NUM_STARS_LAYER2 = 30  -- Mid-distance stars (medium movement)
local NUM_STARS_LAYER3 = 15  -- Close stars (fast movement)
local STAR_SIZES = { 1, 2, 3 } -- Different star sizes

-- Constant movement speeds (pixels per second)
local SCROLL_SPEED1 = 3         -- Slow layer speed
local SCROLL_SPEED2 = 7         -- Medium layer speed
local SCROLL_SPEED3 = 12        -- Fast layer speed
local PHOBOS_SCROLL_SPEED = 1.5 -- Phobos moon movement
local DEIMOS_SCROLL_SPEED = 0.8 -- Deimos moon movement (slower, further away)

-- Mars sky colors (reddish hues)
local STAR_COLORS = {
    { 1,   1,    1 }, -- White
    { 1,   0.9,  0.8 }, -- Slight orange tint
    { 1,   0.85, 0.7 }, -- More orange
    { 0.9, 0.9,  1 } -- Light blue (still visible from Mars)
}

-- Dust storm constants
local DUST_PARTICLE_CHANCE = 0.01       -- Chance per update to spawn a dust particle
local DUST_PARTICLE_SPEED = 150         -- Speed of dust particles
local DUST_PARTICLE_SIZE_RANGE = { 1, 3 } -- Size range of dust particles
local DUST_COLORS = {
    { 0.8, 0.6, 0.4, 0.7 },             -- Light dust color
    { 0.7, 0.5, 0.3, 0.6 },             -- Medium dust color
    { 0.6, 0.4, 0.2, 0.5 }              -- Dark dust color
}

-- Mars moons constants
local PHOBOS_SIZE = 25
local DEIMOS_SIZE = 15
local PHOBOS_COLOR = { 0.7, 0.65, 0.6 }
local DEIMOS_COLOR = { 0.65, 0.6, 0.55 }

---Creates a new starfield instance
---@return table The new starfield instance
function Starfield.new()
    local self = setmetatable({}, Starfield)

    -- Screen dimensions
    self.width = love.graphics.getWidth()
    self.height = love.graphics.getHeight()

    -- Star layers (different scrolling speeds)
    self.stars = {
        layer1 = {}, -- Distant stars (slow)
        layer2 = {}, -- Mid-distance stars (medium)
        layer3 = {}  -- Close stars (fast)
    }

    -- Dust particles
    self.dust_particles = {}

    -- Mars moons positions
    self.phobos = {
        x = math.random(self.width * 0.1, self.width * 0.4),
        y = math.random(self.height * 0.1, self.height * 0.3),
        size = PHOBOS_SIZE,
        craters = {}
    }

    self.deimos = {
        x = math.random(self.width * 0.6, self.width * 0.9),
        y = math.random(self.height * 0.15, self.height * 0.25),
        size = DEIMOS_SIZE,
        craters = {}
    }

    -- Generate moon craters
    self:generateMoonCraters(self.phobos)
    self:generateMoonCraters(self.deimos)

    -- Offset for scrolling effect
    self.offset_x = 0

    -- Generate stars for each layer
    self:generateStars()

    return self
end

---Generates random stars for all layers
function Starfield:generateStars()
    -- Generate distant stars (layer 1)
    for i = 1, NUM_STARS_LAYER1 do
        local star = self:createRandomStar(1)
        table.insert(self.stars.layer1, star)
    end

    -- Generate mid-distance stars (layer 2)
    for i = 1, NUM_STARS_LAYER2 do
        local star = self:createRandomStar(2)
        table.insert(self.stars.layer2, star)
    end

    -- Generate close stars (layer 3)
    for i = 1, NUM_STARS_LAYER3 do
        local star = self:createRandomStar(3)
        table.insert(self.stars.layer3, star)
    end
end

---Creates a random star with properties based on the layer
---@param layer number The star layer (1=distant, 2=mid, 3=close)
---@return table The new star
function Starfield:createRandomStar(layer)
    local size = STAR_SIZES[math.random(1, #STAR_SIZES)]

    -- Make closer stars potentially larger
    if layer > 1 then
        size = size + (layer - 1)
    end

    -- Random color from the predefined colors
    local color = STAR_COLORS[math.random(1, #STAR_COLORS)]

    -- Add slight brightness variation
    local brightness = 0.7 + math.random() * 0.3
    color = { color[1] * brightness, color[2] * brightness, color[3] * brightness }

    -- Add slight speed variation to each star
    local speed_variation = 0.8 + math.random() * 0.4 -- 80% to 120% of base speed

    -- Create the star
    return {
        x = math.random(0, self.width),
        y = math.random(0, self.height),
        size = size,
        color = color,
        twinkle_offset = math.random() * math.pi * 2, -- Random starting phase for twinkling
        twinkle_speed = 0.5 + math.random() * 2,      -- Random twinkle speed
        speed_factor = speed_variation                -- Individual speed variation
    }
end

---Generates random craters on a moon
---@param moon table The moon object to generate craters for
function Starfield:generateMoonCraters(moon)
    -- Number of craters based on moon size
    local num_craters = math.floor(moon.size / 8) + math.random(1, 3)

    moon.craters = {}
    for i = 1, num_craters do
        -- Random position within the moon (polar coordinates for better distribution)
        local angle = math.random() * math.pi * 2
        local distance = math.random() * (moon.size * 0.7) -- Not too close to edge

        -- Convert to cartesian coordinates
        local x = math.cos(angle) * distance
        local y = math.sin(angle) * distance

        -- Random crater size
        local size = math.random(1, 4)

        table.insert(moon.craters, {
            x = x,
            y = y,
            size = size,
            color = { 0.6, 0.55, 0.5, 0.7 } -- Slightly darker than moon
        })
    end
end

---Updates the starfield
---@param dt number Delta time
function Starfield:update(dt)
    -- Update the scrolling offset based on constant speeds
    self.offset_x = self.offset_x + dt

    -- Update star twinkling
    self:updateTwinkling(dt)

    -- Update dust particles
    self:updateDustParticles(dt)

    -- Randomly create new dust particles
    if math.random() < DUST_PARTICLE_CHANCE then
        self:createDustParticle()
    end
end

---Updates the twinkling effect of stars
---@param dt number Delta time
function Starfield:updateTwinkling(dt)
    -- Update twinkling for all layers
    for _, layer in pairs(self.stars) do
        for _, star in ipairs(layer) do
            star.twinkle_offset = star.twinkle_offset + dt * star.twinkle_speed
        end
    end
end

---Updates the dust particles
---@param dt number Delta time
function Starfield:updateDustParticles(dt)
    for i = #self.dust_particles, 1, -1 do
        local particle = self.dust_particles[i]

        -- Update position
        particle.x = particle.x + particle.dx * dt
        particle.y = particle.y + particle.dy * dt

        -- Update lifetime
        particle.lifetime = particle.lifetime - dt

        -- Remove if off-screen or expired
        if particle.lifetime <= 0 or
            particle.x < -50 or particle.x > self.width + 50 or
            particle.y < -50 or particle.y > self.height + 50 then
            table.remove(self.dust_particles, i)
        end
    end
end

---Creates a new dust particle
function Starfield:createDustParticle()
    -- Determine starting position (usually from the sides)
    local start_from_side = math.random() < 0.8 -- 80% chance to start from sides

    local x, y
    if start_from_side then
        x = math.random() < 0.5 and -10 or self.width + 10 -- Left or right side
        y = math.random(0, self.height)
    else
        x = math.random(0, self.width)
        y = -10 -- Top of screen
    end

    -- Determine angle (horizontal with slight variation)
    local angle
    if start_from_side then
        -- If from left, angle right; if from right, angle left
        local base_angle = x < 0 and 0 or math.pi
        angle = base_angle + (math.random() - 0.5) * math.pi / 4 -- Slight variation
    else
        -- From top, angle downward with horizontal component
        angle = math.pi / 2 + (math.random() - 0.5) * math.pi / 3
    end

    -- Calculate velocity components
    local speed = DUST_PARTICLE_SPEED * (0.7 + math.random() * 0.6) -- 70-130% of base speed
    local dx = math.cos(angle) * speed
    local dy = math.sin(angle) * speed

    -- Random dust color
    local color = DUST_COLORS[math.random(1, #DUST_COLORS)]

    -- Random size
    local size = DUST_PARTICLE_SIZE_RANGE[1] + math.random() *
        (DUST_PARTICLE_SIZE_RANGE[2] - DUST_PARTICLE_SIZE_RANGE[1])

    -- Create the dust particle
    local dust_particle = {
        x = x,
        y = y,
        dx = dx,
        dy = dy,
        size = size,
        color = { color[1], color[2], color[3], color[4] * (0.5 + math.random() * 0.5) },
        lifetime = 1 + math.random() * 3 -- 1-4 seconds
    }

    table.insert(self.dust_particles, dust_particle)
end

---Draws the starfield
function Starfield:draw()
    -- Draw Mars sky gradient (reddish)
    self:drawMarsSkyShadow()

    -- Draw the moons (behind stars)
    self:drawMoons()

    -- Draw each layer with its own scrolling speed
    self:drawStarLayer(self.stars.layer1, SCROLL_SPEED1)
    self:drawStarLayer(self.stars.layer2, SCROLL_SPEED2)
    self:drawStarLayer(self.stars.layer3, SCROLL_SPEED3)

    -- Draw dust particles
    self:drawDustParticles()
end

---Draws a reddish gradient for Mars sky
function Starfield:drawMarsSkyShadow()
    -- Create a subtle reddish gradient at the bottom of the screen
    local gradient_height = self.height * 0.3 -- Reduced from 0.4

    -- Draw gradient from bottom up
    for i = 0, gradient_height, 2 do
        local ratio = i / gradient_height
        local alpha = 0.15 * (1 - ratio) -- Reduced from 0.2
        love.graphics.setColor(0.8, 0.3, 0.2, alpha)
        love.graphics.line(0, self.height - i, self.width, self.height - i)
    end
end

---Draws the dust particles
function Starfield:drawDustParticles()
    for _, particle in ipairs(self.dust_particles) do
        -- Set color with fade based on lifetime
        local alpha = math.min(1, particle.lifetime)
        love.graphics.setColor(
            particle.color[1],
            particle.color[2],
            particle.color[3],
            particle.color[4] * alpha
        )

        -- Draw the dust particle as a small circle
        love.graphics.circle("fill", particle.x, particle.y, particle.size)
    end
end

---Draws the Mars moons (Phobos and Deimos)
function Starfield:drawMoons()
    -- Draw Phobos (larger, closer moon)
    self:drawMoon(self.phobos, PHOBOS_COLOR, PHOBOS_SCROLL_SPEED)

    -- Draw Deimos (smaller, further moon)
    self:drawMoon(self.deimos, DEIMOS_COLOR, DEIMOS_SCROLL_SPEED)
end

---Draws a moon
---@param moon table The moon object to draw
---@param color table The color of the moon
---@param scroll_speed number The scrolling speed for this moon
function Starfield:drawMoon(moon, color, scroll_speed)
    -- Calculate scrolling position
    local moon_x = (moon.x - (self.offset_x * scroll_speed)) % self.width

    -- Draw the moon
    love.graphics.setColor(color)
    love.graphics.circle("fill", moon_x, moon.y, moon.size)

    -- Draw craters
    for _, crater in ipairs(moon.craters) do
        love.graphics.setColor(crater.color)
        love.graphics.circle("fill", moon_x + crater.x, moon.y + crater.y, crater.size)
    end
end

---Draws a single layer of stars with the specified scrolling speed
---@param layer table The star layer to draw
---@param speed number The scrolling speed for this layer
function Starfield:drawStarLayer(layer, speed)
    for _, star in ipairs(layer) do
        -- Calculate scrolling position (moving from right to left)
        -- Apply individual star speed variation
        local adjusted_speed = speed * star.speed_factor
        local scroll_x = (star.x - (self.offset_x * adjusted_speed)) % self.width

        -- Calculate twinkling brightness
        local twinkle = 0.7 + 0.3 * math.sin(star.twinkle_offset)

        -- Set star color with twinkling effect
        love.graphics.setColor(
            star.color[1] * twinkle,
            star.color[2] * twinkle,
            star.color[3] * twinkle
        )

        -- Draw the star
        love.graphics.circle("fill", scroll_x, star.y, star.size)
    end
end

return Starfield
