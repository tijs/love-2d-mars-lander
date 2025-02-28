-- Level complete scene for the Mars Lander game
local LevelCompleteScene = {}
LevelCompleteScene.__index = LevelCompleteScene

-- Import required modules
local SceneManager = require("src.scenes.scene_manager")

-- Constants
local TITLE_COLOR = { 0.1, 0.8, 0.2, 1 } -- Green
local TEXT_COLOR = { 0.9, 0.9, 0.9, 1 }  -- White
local HIGHLIGHT_COLOR = { 1, 0.8, 0, 1 } -- Gold

-- Mars surface colors
local MARS_SURFACE_COLOR = { 0.7, 0.3, 0.2, 1 } -- Darker Mars red for surface
local MARS_SKY_COLOR = { 0.1, 0.05, 0.1, 1 }    -- Dark purplish for Mars sky

---Creates a new level complete scene
---@return table The new level complete scene instance
function LevelCompleteScene.new()
    local self = setmetatable({}, LevelCompleteScene)
    return self
end

---Loads the level complete scene
---@param level number The completed level
---@param score number The current score
---@param landing_score number The score for this landing
---@param fuel_bonus number The fuel bonus for this landing
function LevelCompleteScene:load(level, score, landing_score, fuel_bonus)
    self.level = level or 1
    self.score = score or 0
    self.landing_score = landing_score or 0
    self.fuel_bonus = fuel_bonus or 0

    -- Background stars (fewer, more subtle stars)
    self.stars = {}
    for i = 1, 50 do
        table.insert(self.stars, {
            x = math.random(0, love.graphics.getWidth()),
            y = math.random(0, love.graphics.getHeight() * 0.7), -- Only in the sky portion
            size = math.random(1, 2),                            -- Smaller stars
            speed = math.random(5, 15) / 20                      -- Slower movement
        })
    end

    -- Animation timer
    self.timer = 0
    self.fade_in = 0
    self.show_next = false

    -- Celebration particles
    self.particles = {}
    for i = 1, 30 do
        table.insert(self.particles, {
            x = love.graphics.getWidth() / 2 + math.random(-200, 200),
            y = love.graphics.getHeight() / 3 + math.random(-50, 50),
            vx = math.random(-50, 50),
            vy = math.random(-80, -20),
            size = math.random(2, 4),
            color = {
                math.random(0.7, 1),
                math.random(0.7, 1),
                math.random(0.7, 1),
                1
            },
            life = math.random(1, 2)
        })
    end

    -- Create successfully landed lander
    self.lander = {
        x = love.graphics.getWidth() * 0.7,
        y = love.graphics.getHeight() * 0.65,
        rotation = 0, -- Level orientation
        scale = 1.5,
        thruster = false,
        thruster_timer = 0
    }

    -- Mars surface features (simple hills with flat landing pad)
    self.surface = {}
    local segments = 20
    local width = love.graphics.getWidth()
    local base_height = love.graphics.getHeight() * 0.75

    for i = 0, segments do
        local x = (i / segments) * width
        -- Create a flat landing pad where the lander is
        if i >= 12 and i <= 14 then
            table.insert(self.surface, { x = x, y = base_height })
        else
            local height_variation = math.sin(i * 0.5) * 30
            table.insert(self.surface, { x = x, y = base_height + height_variation })
        end
    end
end

---Updates the level complete scene
---@param dt number Delta time
function LevelCompleteScene:update(dt)
    -- Update stars
    for _, star in ipairs(self.stars) do
        star.y = star.y + star.speed
        if star.y > love.graphics.getHeight() * 0.7 then
            star.y = 0
            star.x = math.random(0, love.graphics.getWidth())
        end
    end

    -- Update animation
    self.timer = self.timer + dt
    self.fade_in = math.min(1, self.timer / 1.5) -- Fade in over 1.5 seconds

    -- Show "Next Level" button after 3 seconds
    if self.timer > 3 and not self.show_next then
        self.show_next = true
    end

    -- Update particles
    for i = #self.particles, 1, -1 do
        local p = self.particles[i]
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        p.vy = p.vy + 50 * dt -- Add gravity
        p.life = p.life - dt

        -- Remove dead particles
        if p.life <= 0 then
            table.remove(self.particles, i)
        end
    end

    -- Add new particles during celebration
    if self.timer < 3 and #self.particles < 60 and math.random() < 0.1 then
        for i = 1, 3 do
            table.insert(self.particles, {
                x = love.graphics.getWidth() / 2 + math.random(-200, 200),
                y = love.graphics.getHeight() / 3 + math.random(-50, 50),
                vx = math.random(-50, 50),
                vy = math.random(-80, -20),
                size = math.random(2, 4),
                color = {
                    math.random(0.7, 1),
                    math.random(0.7, 1),
                    math.random(0.7, 1),
                    1
                },
                life = math.random(1, 2)
            })
        end
    end

    -- Update lander
    if self.timer > 1 then
        -- Slight hover effect
        self.lander.y = self.lander.y + math.sin(self.timer * 2) * 0.1
    end
end

---Draws the level complete scene
function LevelCompleteScene:draw()
    -- Draw background (Mars sky)
    love.graphics.setColor(MARS_SKY_COLOR)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- Draw stars
    love.graphics.setColor(1, 1, 1, 0.6)
    for _, star in ipairs(self.stars) do
        love.graphics.circle("fill", star.x, star.y, star.size)
    end

    -- Draw Mars surface
    love.graphics.setColor(MARS_SURFACE_COLOR)

    -- Draw the surface as a polygon
    local vertices = {}
    for _, point in ipairs(self.surface) do
        table.insert(vertices, point.x)
        table.insert(vertices, point.y)
    end
    -- Add bottom corners to complete the polygon
    table.insert(vertices, love.graphics.getWidth())
    table.insert(vertices, love.graphics.getHeight())
    table.insert(vertices, 0)
    table.insert(vertices, love.graphics.getHeight())

    love.graphics.polygon("fill", vertices)

    -- Draw landing pad
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill",
        love.graphics.getWidth() * 0.6,
        love.graphics.getHeight() * 0.75 - 5,
        love.graphics.getWidth() * 0.15,
        10)

    -- Draw successfully landed lander
    self:drawLander()

    -- Draw particles
    for _, p in ipairs(self.particles) do
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], p.life / 2)
        love.graphics.circle("fill", p.x, p.y, p.size)
    end

    -- Apply fade-in effect
    local alpha = self.fade_in

    -- Draw title with custom font
    love.graphics.setFont(fonts.title_font)
    love.graphics.setColor(TITLE_COLOR[1], TITLE_COLOR[2], TITLE_COLOR[3], alpha)
    local title = "LANDING SUCCESSFUL!"
    local title_width = fonts.title_font:getWidth(title)
    love.graphics.print(title, (love.graphics.getWidth() - title_width) / 2, 80)

    -- Draw level info
    love.graphics.setFont(fonts.title)
    love.graphics.setColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], alpha)
    local level_text = "Level " .. self.level .. " Complete"
    local level_width = fonts.title:getWidth(level_text)
    love.graphics.print(level_text, (love.graphics.getWidth() - level_width) / 2, 140)

    -- Draw score breakdown in a semi-transparent panel
    if self.timer > 1 then
        -- Draw panel background
        love.graphics.setColor(0, 0, 0, 0.6 * alpha)
        love.graphics.rectangle("fill",
            love.graphics.getWidth() / 2 - 220,
            200,
            440,
            180)

        love.graphics.setFont(fonts.large)

        -- Landing score
        love.graphics.setColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], alpha)
        local landing_text = "Landing Score:"
        love.graphics.print(landing_text, love.graphics.getWidth() / 2 - 200, 220)

        love.graphics.setColor(HIGHLIGHT_COLOR[1], HIGHLIGHT_COLOR[2], HIGHLIGHT_COLOR[3], alpha)
        love.graphics.print(self.landing_score, love.graphics.getWidth() / 2 + 100, 220)

        -- Fuel bonus
        if self.timer > 1.5 then
            love.graphics.setColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], alpha)
            local fuel_text = "Fuel Bonus:"
            love.graphics.print(fuel_text, love.graphics.getWidth() / 2 - 200, 270)

            love.graphics.setColor(HIGHLIGHT_COLOR[1], HIGHLIGHT_COLOR[2], HIGHLIGHT_COLOR[3], alpha)
            love.graphics.print(self.fuel_bonus, love.graphics.getWidth() / 2 + 100, 270)
        end

        -- Total score
        if self.timer > 2 then
            love.graphics.setColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], alpha)
            local total_text = "Total Score:"
            love.graphics.print(total_text, love.graphics.getWidth() / 2 - 200, 330)

            love.graphics.setFont(fonts.title)
            love.graphics.setColor(HIGHLIGHT_COLOR[1], HIGHLIGHT_COLOR[2], HIGHLIGHT_COLOR[3], alpha)
            love.graphics.print(self.score, love.graphics.getWidth() / 2 + 100, 330)
        end
    end

    -- Draw next level button
    if self.show_next then
        -- Semi-transparent background for button
        love.graphics.setColor(0, 0, 0, 0.6)
        love.graphics.rectangle("fill",
            love.graphics.getWidth() * 0.25,
            love.graphics.getHeight() - 120,
            love.graphics.getWidth() * 0.5,
            70)

        love.graphics.setFont(fonts.large)
        love.graphics.setColor(HIGHLIGHT_COLOR)

        local next_text = "Press ENTER for Next Level"
        local next_width = fonts.large:getWidth(next_text)
        love.graphics.print(next_text,
            (love.graphics.getWidth() - next_width) / 2,
            love.graphics.getHeight() - 100)
    end
end

---Draws the successfully landed lander
function LevelCompleteScene:drawLander()
    love.graphics.push()
    love.graphics.translate(self.lander.x, self.lander.y)
    love.graphics.rotate(self.lander.rotation)
    love.graphics.scale(self.lander.scale, self.lander.scale)

    -- Draw lander body
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.polygon("fill", 0, -10, 10, 10, -10, 10)

    -- Draw landing legs
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.line(-10, 10, -15, 15)
    love.graphics.line(10, 10, 15, 15)

    love.graphics.pop()
end

---Handles key press events
---@param key string The key that was pressed
function LevelCompleteScene:keypressed(key)
    if self.show_next and (key == "return" or key == "space") then
        SceneManager.changeScene("game", self.level + 1, self.score)
    end
end

---Handles key release events
---@param key string The key that was released
function LevelCompleteScene:keyreleased(key)
    -- Not needed for level complete scene
end

---Handles continuous key presses
function LevelCompleteScene:updateKeyPresses()
    -- Not needed for level complete scene
end

return LevelCompleteScene
