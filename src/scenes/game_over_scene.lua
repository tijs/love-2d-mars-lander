-- Game over scene for the Mars Lander game
local GameOverScene = {}
GameOverScene.__index = GameOverScene

-- Import required modules
local SceneManager = require("src.scenes.scene_manager")

-- Constants
local TITLE_COLOR = { 0.9, 0.1, 0.1, 1 } -- Red
local TEXT_COLOR = { 0.9, 0.9, 0.9, 1 }  -- White
local OPTION_COLOR = { 1, 0.8, 0, 1 }    -- Gold

-- Mars surface colors
local MARS_SURFACE_COLOR = { 0.7, 0.3, 0.2, 1 } -- Darker Mars red for surface
local MARS_SKY_COLOR = { 0.1, 0.05, 0.1, 1 }    -- Dark purplish for Mars sky

---Creates a new game over scene
---@return table The new game over scene instance
function GameOverScene.new()
    local self = setmetatable({}, GameOverScene)
    return self
end

---Loads the game over scene
---@param score number The player's final score
function GameOverScene:load(score)
    self.final_score = score or 0

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

    -- Create crashed lander
    self.lander = {
        x = love.graphics.getWidth() * 0.3,
        y = love.graphics.getHeight() * 0.6,
        rotation = math.pi / 4, -- Crashed angle
        scale = 2,
        debris = {}
    }

    -- Create debris particles
    for i = 1, 15 do
        table.insert(self.lander.debris, {
            x = self.lander.x + math.random(-30, 30),
            y = self.lander.y + math.random(-20, 20),
            rotation = math.random() * math.pi * 2,
            size = math.random(2, 8),
            alpha = math.random(0.5, 0.9)
        })
    end

    -- Mars surface features (simple hills)
    self.surface = {}
    local segments = 20
    local width = love.graphics.getWidth()
    local base_height = love.graphics.getHeight() * 0.75

    for i = 0, segments do
        local x = (i / segments) * width
        local height_variation = math.sin(i * 0.5) * 30
        table.insert(self.surface, { x = x, y = base_height + height_variation })
    end
end

---Updates the game over scene
---@param dt number Delta time
function GameOverScene:update(dt)
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
    self.fade_in = math.min(1, self.timer / 2) -- Fade in over 2 seconds
end

---Draws the game over scene
function GameOverScene:draw()
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

    -- Draw crashed lander and debris
    self:drawCrashedLander()

    -- Apply fade-in effect
    local alpha = self.fade_in

    -- Draw title with custom font
    love.graphics.setFont(fonts.title_font)
    love.graphics.setColor(TITLE_COLOR[1], TITLE_COLOR[2], TITLE_COLOR[3], alpha)
    local title = "MISSION FAILED"
    local title_width = fonts.title_font:getWidth(title)
    love.graphics.print(title, (love.graphics.getWidth() - title_width) / 2, 120)

    -- Draw message
    love.graphics.setFont(fonts.large)
    love.graphics.setColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], alpha)
    local message = "Your spacecraft has been lost on Mars"
    local message_width = fonts.large:getWidth(message)
    love.graphics.print(message, (love.graphics.getWidth() - message_width) / 2, 180)

    -- Draw score
    love.graphics.setFont(fonts.title)
    love.graphics.setColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], alpha)
    local score_text = "Final Score: " .. self.final_score
    local score_width = fonts.title:getWidth(score_text)
    love.graphics.print(score_text, (love.graphics.getWidth() - score_width) / 2, 240)

    -- Draw options
    if self.timer > 2 then -- Only show options after 2 seconds
        -- Semi-transparent background for options
        love.graphics.setColor(0, 0, 0, 0.6)
        love.graphics.rectangle("fill",
            love.graphics.getWidth() * 0.25,
            love.graphics.getHeight() - 180,
            love.graphics.getWidth() * 0.5,
            120)

        love.graphics.setFont(fonts.large)
        love.graphics.setColor(OPTION_COLOR)

        local retry_text = "Press ENTER to Try Again"
        local retry_width = fonts.large:getWidth(retry_text)
        love.graphics.print(retry_text,
            (love.graphics.getWidth() - retry_width) / 2,
            love.graphics.getHeight() - 150)

        local menu_text = "Press ESC for Main Menu"
        local menu_width = fonts.large:getWidth(menu_text)
        love.graphics.print(menu_text,
            (love.graphics.getWidth() - menu_width) / 2,
            love.graphics.getHeight() - 100)
    end
end

---Draws the crashed lander
function GameOverScene:drawCrashedLander()
    -- Draw debris first
    for _, debris in ipairs(self.lander.debris) do
        love.graphics.setColor(0.8, 0.8, 0.8, debris.alpha)
        love.graphics.push()
        love.graphics.translate(debris.x, debris.y)
        love.graphics.rotate(debris.rotation)
        love.graphics.rectangle("fill", -debris.size / 2, -debris.size / 2, debris.size, debris.size)
        love.graphics.pop()
    end

    -- Draw crashed lander
    love.graphics.push()
    love.graphics.translate(self.lander.x, self.lander.y)
    love.graphics.rotate(self.lander.rotation)
    love.graphics.scale(self.lander.scale, self.lander.scale)

    -- Draw broken lander body
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.polygon("fill", 0, -10, 10, 10, -10, 10)

    -- Draw broken landing legs
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.line(-10, 10, -5, 15) -- Broken leg
    love.graphics.line(10, 10, 15, 15)

    love.graphics.pop()
end

---Handles key press events
---@param key string The key that was pressed
function GameOverScene:keypressed(key)
    if self.timer > 2 then -- Only respond after 2 seconds
        if key == "return" or key == "space" then
            SceneManager.changeScene("game")
        elseif key == "escape" then
            SceneManager.changeScene("menu")
        end
    end
end

---Handles key release events
---@param key string The key that was released
function GameOverScene:keyreleased(key)
    -- Not needed for game over scene
end

---Handles continuous key presses
function GameOverScene:updateKeyPresses()
    -- Not needed for game over scene
end

return GameOverScene
