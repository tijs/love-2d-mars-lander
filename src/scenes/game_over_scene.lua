-- Game over scene for the Mars Lander game
local GameOverScene = {}
GameOverScene.__index = GameOverScene

-- Import required modules
local SceneManager = require("src.scenes.scene_manager")

-- Constants
local TITLE_COLOR = {0.9, 0.1, 0.1, 1}  -- Red
local TEXT_COLOR = {0.9, 0.9, 0.9, 1}   -- White
local OPTION_COLOR = {1, 0.8, 0, 1}     -- Gold

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
    
    -- Background stars
    self.stars = {}
    for i = 1, 100 do
        table.insert(self.stars, {
            x = math.random(0, love.graphics.getWidth()),
            y = math.random(0, love.graphics.getHeight()),
            size = math.random(1, 3),
            speed = math.random(10, 30) / 10
        })
    end
    
    -- Animation timer
    self.timer = 0
    self.fade_in = 0
end

---Updates the game over scene
---@param dt number Delta time
function GameOverScene:update(dt)
    -- Update stars
    for _, star in ipairs(self.stars) do
        star.y = star.y + star.speed
        if star.y > love.graphics.getHeight() then
            star.y = 0
            star.x = math.random(0, love.graphics.getWidth())
        end
    end
    
    -- Update animation
    self.timer = self.timer + dt
    self.fade_in = math.min(1, self.timer / 2)  -- Fade in over 2 seconds
end

---Draws the game over scene
function GameOverScene:draw()
    -- Draw background
    love.graphics.setColor(0.05, 0.05, 0.1)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Draw stars
    love.graphics.setColor(1, 1, 1, 0.8)
    for _, star in ipairs(self.stars) do
        love.graphics.circle("fill", star.x, star.y, star.size)
    end
    
    -- Apply fade-in effect
    local alpha = self.fade_in
    
    -- Draw title
    love.graphics.setFont(fonts.huge)
    love.graphics.setColor(TITLE_COLOR[1], TITLE_COLOR[2], TITLE_COLOR[3], alpha)
    local title = "MISSION FAILED"
    local title_width = fonts.huge:getWidth(title)
    love.graphics.print(title, (love.graphics.getWidth() - title_width) / 2, 150)
    
    -- Draw message
    love.graphics.setFont(fonts.large)
    love.graphics.setColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], alpha)
    local message = "Your spacecraft has been lost on Mars"
    local message_width = fonts.large:getWidth(message)
    love.graphics.print(message, (love.graphics.getWidth() - message_width) / 2, 220)
    
    -- Draw score
    love.graphics.setFont(fonts.title)
    love.graphics.setColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], alpha)
    local score_text = "Final Score: " .. self.final_score
    local score_width = fonts.title:getWidth(score_text)
    love.graphics.print(score_text, (love.graphics.getWidth() - score_width) / 2, 300)
    
    -- Draw options
    if self.timer > 2 then  -- Only show options after 2 seconds
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

---Handles key press events
---@param key string The key that was pressed
function GameOverScene:keypressed(key)
    if self.timer > 2 then  -- Only respond after 2 seconds
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