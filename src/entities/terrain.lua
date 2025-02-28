-- Terrain entity representing the Martian surface
local Terrain = {}
Terrain.__index = Terrain

-- Constants for terrain generation
local MIN_HEIGHT = 400
local MAX_HEIGHT = 550
local SEGMENT_WIDTH = 20
local LANDING_PAD_WIDTH = 80  -- Increased from 60 to make landing easier

-- Mars terrain colors
local TERRAIN_COLORS = {
    {0.8, 0.4, 0.2},  -- Light reddish-orange
    {0.7, 0.3, 0.2},  -- Medium reddish-brown
    {0.6, 0.25, 0.15} -- Dark reddish-brown
}

-- Crater constants
local CRATER_CHANCE = 0.15  -- Chance of a crater at each terrain point
local MIN_CRATER_SIZE = 5
local MAX_CRATER_SIZE = 15

---Creates a new terrain instance
---@return table The new terrain instance
function Terrain.new()
    local self = setmetatable({}, Terrain)
    
    -- Generate terrain points
    self.points = {}
    self.segments = {}
    self.landing_pad_start = nil
    self.landing_pad_end = nil
    self.landing_pad_height = nil
    
    -- Craters for visual detail
    self.craters = {}
    
    -- Generate the terrain
    self:generate()
    
    return self
end

---Generates the terrain points
function Terrain:generate()
    local screen_width = love.graphics.getWidth()
    local num_points = math.ceil(screen_width / SEGMENT_WIDTH) + 1
    
    -- Choose a random position for the landing pad
    local landing_pad_segments = math.floor(LANDING_PAD_WIDTH / SEGMENT_WIDTH)
    local landing_pad_start_index = math.random(2, num_points - landing_pad_segments - 1)
    local landing_pad_end_index = landing_pad_start_index + landing_pad_segments
    
    -- Generate height for each point
    for i = 1, num_points do
        local x = (i - 1) * SEGMENT_WIDTH
        local y
        
        -- If this is part of the landing pad, make it flat
        if i >= landing_pad_start_index and i <= landing_pad_end_index then
            -- If this is the first point of the landing pad, set a random height
            if i == landing_pad_start_index then
                y = math.random(MIN_HEIGHT, MAX_HEIGHT)
            else
                -- Otherwise use the same height as the previous point
                y = self.points[i-1].y
            end
            
            -- Store landing pad coordinates
            if i == landing_pad_start_index then
                self.landing_pad_start = x
                self.landing_pad_height = y
            elseif i == landing_pad_end_index then
                self.landing_pad_end = x
            end
        else
            -- Generate a random height for non-landing pad points
            y = math.random(MIN_HEIGHT, MAX_HEIGHT)
        end
        
        table.insert(self.points, {x = x, y = y})
        
        -- Randomly add craters for visual detail (not on landing pads)
        if math.random() < CRATER_CHANCE and (i < landing_pad_start_index or i > landing_pad_end_index) then
            local crater_size = math.random(MIN_CRATER_SIZE, MAX_CRATER_SIZE)
            local crater_x = x + math.random(-SEGMENT_WIDTH/2, SEGMENT_WIDTH/2)
            local crater_y = y - crater_size/2
            
            table.insert(self.craters, {
                x = crater_x,
                y = crater_y,
                size = crater_size,
                color = TERRAIN_COLORS[math.random(2, 3)]  -- Darker colors for craters
            })
        end
    end
    
    -- Create segments from points
    self:createSegments()
end

---Creates line segments from the terrain points
function Terrain:createSegments()
    for i = 1, #self.points - 1 do
        local x1, y1 = self.points[i].x, self.points[i].y
        local x2, y2 = self.points[i+1].x, self.points[i+1].y
        
        -- Check if this segment is part of the landing pad
        local is_landing_pad = false
        if x1 >= self.landing_pad_start and x2 <= self.landing_pad_end then
            is_landing_pad = true
        end
        
        -- Create segment
        local segment = {
            x1 = x1,
            y1 = y1,
            x2 = x2,
            y2 = y2,
            is_landing_pad = is_landing_pad
        }
        
        table.insert(self.segments, segment)
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

---Draws the terrain on the screen
function Terrain:draw()
    -- Draw the terrain outline
    love.graphics.setColor(TERRAIN_COLORS[1])
    
    -- Draw the terrain fill with a gradient effect
    for _, segment in ipairs(self.segments) do
        -- Draw the line segment
        love.graphics.setLineWidth(2)
        love.graphics.line(segment.x1, segment.y1, segment.x2, segment.y2)
        
        -- Fill the area below the terrain with a gradient
        local y_bottom = love.graphics.getHeight()
        local gradient_steps = 10
        local step_height = (y_bottom - segment.y1) / gradient_steps
        
        for i = 0, gradient_steps - 1 do
            -- Gradually darken the color as we go down
            local darkness_factor = 1 - (i / gradient_steps) * 0.5
            local color = TERRAIN_COLORS[1]
            love.graphics.setColor(
                color[1] * darkness_factor,
                color[2] * darkness_factor,
                color[3] * darkness_factor
            )
            
            local y1 = segment.y1 + i * step_height
            local y2 = segment.y1 + (i + 1) * step_height
            
            love.graphics.polygon("fill", 
                segment.x1, y1, 
                segment.x2, y1, 
                segment.x2, y2, 
                segment.x1, y2
            )
        end
    end
    
    -- Draw craters
    for _, crater in ipairs(self.craters) do
        love.graphics.setColor(crater.color)
        love.graphics.circle("fill", crater.x, crater.y, crater.size)
        
        -- Draw crater rim (slightly lighter)
        love.graphics.setColor(
            crater.color[1] * 1.1,
            crater.color[2] * 1.1,
            crater.color[3] * 1.1
        )
        love.graphics.circle("line", crater.x, crater.y, crater.size)
    end
    
    -- Draw the landing pad with a different color
    if self.landing_pad_start and self.landing_pad_end then
        -- Draw the landing pad platform
        love.graphics.setColor(0.2, 0.6, 0.8)  -- Blue-ish color for landing pad
        local pad_y = self.landing_pad_height
        love.graphics.rectangle("fill", 
            self.landing_pad_start, 
            pad_y - 2, 
            self.landing_pad_end - self.landing_pad_start, 
            4
        )
        
        -- Draw landing markers
        love.graphics.setColor(1, 0.8, 0)  -- Amber color for markers
        love.graphics.rectangle("fill", 
            self.landing_pad_start + 5, 
            pad_y - 6, 
            5, 
            8
        )
        love.graphics.rectangle("fill", 
            self.landing_pad_end - 10, 
            pad_y - 6, 
            5, 
            8
        )
        
        -- Draw landing pad markings
        local pad_width = self.landing_pad_end - self.landing_pad_start
        local stripe_width = pad_width / 6
        
        for i = 0, 2 do
            love.graphics.setColor(0.1, 0.1, 0.1)  -- Dark gray/black
            love.graphics.rectangle("fill",
                self.landing_pad_start + i * stripe_width * 2,
                pad_y - 2,
                stripe_width,
                4
            )
        end
        
        -- Draw "LAND HERE" text
        love.graphics.setColor(1, 1, 1)
        local pad_center_x = (self.landing_pad_start + self.landing_pad_end) / 2
        love.graphics.print("LAND HERE", pad_center_x - 30, pad_y - 25)
    end
end

return Terrain 