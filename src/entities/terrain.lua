-- Terrain entity representing the Martian surface
local Terrain = {}
Terrain.__index = Terrain

-- Import modules
local Sky = require("src.entities.terrain.sky")
local Features = require("src.entities.terrain.features")
local LandingPad = require("src.entities.terrain.landing_pad")
local Surface = require("src.entities.terrain.surface")
local Starfield = require("src.entities.starfield")

-- Constants are now imported from Constants module
-- and used directly in the respective modules

---Creates a new terrain instance
---@return table The new terrain instance
function Terrain.new()
    local self = setmetatable({}, Terrain)

    -- Generate terrain data
    local screen_width = love.graphics.getWidth()
    local terrain_data = Surface.generate(screen_width)

    -- Store terrain data
    self.points = terrain_data.points
    self.segments = terrain_data.segments
    self.landing_pad_start = terrain_data.landing_pad_start
    self.landing_pad_end = terrain_data.landing_pad_end
    self.landing_pad_height = terrain_data.landing_pad_height

    -- Initialize features
    self.craters = {}
    self.rocks = {}

    -- Generate features
    self:generateFeatures()

    -- Initialize dust particles
    self.dust_particles = Sky.initDustParticles(self)

    -- Initialize starfield
    self.starfield = Starfield.new()

    return self
end

---Generates terrain features (craters, rocks, etc.)
function Terrain:generateFeatures()
    -- Generate craters and rocks for each terrain point
    for i, point in ipairs(self.points) do
        -- Determine if this point is part of a landing pad
        local is_landing_pad = false
        if self.landing_pad_start and self.landing_pad_end then
            if point.x >= self.landing_pad_start and point.x <= self.landing_pad_end then
                is_landing_pad = true
            end
        end

        -- Generate crater
        local crater = Features.generateCrater(point.x, point.y, is_landing_pad)
        if crater then
            table.insert(self.craters, crater)
        end

        -- Generate rock
        local rock = Features.generateRock(point.x, point.y, is_landing_pad)
        if rock then
            table.insert(self.rocks, rock)
        end
    end
end

---Gets the height of the terrain at a specific x coordinate
---@param x number The x coordinate to check
---@return number The height of the terrain at the given x coordinate
function Terrain:getHeightAt(x)
    -- Find the segment that contains the given x coordinate
    for _, segment in ipairs(self.segments) do
        if x >= segment.x1 and x <= segment.x2 then
            -- Interpolate between the two points to find the exact height
            local t = (x - segment.x1) / (segment.x2 - segment.x1)
            return segment.y1 + t * (segment.y2 - segment.y1)
        end
    end

    -- If we couldn't find a segment, return a default value
    return love.graphics.getHeight()
end

---Checks if a given x coordinate is on a landing pad
---@param x number The x coordinate to check
---@return boolean True if the coordinate is on a landing pad
function Terrain:isLandingPad(x)
    return x >= self.landing_pad_start and x <= self.landing_pad_end
end

---Updates the terrain
---@param dt number Delta time
function Terrain:update(dt)
    -- Update starfield
    self.starfield:update(dt)

    -- Update dust particles
    Sky.updateDustParticles(self.dust_particles, dt, function(x) return self:getHeightAt(x) end)
end

---Draws the terrain on the screen
function Terrain:draw()
    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()

    -- Clear the screen with a dark color to ensure stars are visible
    love.graphics.clear(0.05, 0.05, 0.1)

    -- Draw starfield (background)
    self.starfield:draw()

    -- Draw sky gradient with partial transparency to allow starfield to show through
    love.graphics.setBlendMode("alpha", "alphamultiply")
    Sky.drawSkyGradient(screen_width, screen_height, 0.6) -- Reduced transparency further
    love.graphics.setBlendMode("alpha")                   -- Reset blend mode

    -- Draw dust particles
    Sky.drawDustParticles(self.dust_particles)

    -- Draw the terrain surface
    Surface.draw(self.segments)

    -- Draw rocks
    Features.drawRocks(self.rocks)

    -- Draw craters
    Features.drawCraters(self.craters)

    -- Draw the landing pad
    LandingPad.draw(self.landing_pad_start, self.landing_pad_end, self.landing_pad_height)
end

return Terrain
