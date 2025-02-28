-- Level complete scene for the Mars Lander game
local LevelCompleteScene = {}
LevelCompleteScene.__index = LevelCompleteScene

-- Import required modules
local SceneManager = require("src.scenes.scene_manager")

-- Constants
local TITLE_COLOR = {0.1, 0.8, 0.2, 1}  -- Green
local TEXT_COLOR = {0.9, 0.9, 0.9, 1}   -- White
local HIGHLIGHT_COLOR = {1, 0.8, 0, 1}  -- Gold

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
    self.show_next = false
    
    -- Celebration particles
    self.particles = {}
    for i = 1, 50 do
        table.insert(self.particles, {
            x = love.graphics.getWidth() / 2 + math.random(-200, 200),
            y = love.graphics.getHeight() / 2 + math.random(-100, 100),
            vx = math.random(-100, 100),
            vy = math.random(-100, 100),
            size = math.random(2, 5),
            color = {
                math.random(0.5, 1),
                math.random(0.5, 1),
                math.random(0.5, 1),
                1
            },
            life = math.random(1, 3)
        })
    end
end

---Updates the level complete scene
---@param dt number Delta time
function LevelCompleteScene:update(dt)
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
    self.fade_in = math.min(1, self.timer / 1.5)  -- Fade in over 1.5 seconds
    
    -- Show "Next Level" button after 3 seconds
    if self.timer > 3 and not self.show_next then
        self.show_next = true
    end
    
    -- Update particles
    for i = #self.particles, 1, -1 do
        local p = self.particles[i]
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        p.life = p.life - dt
        
        -- Remove dead particles
        if p.life <= 0 then
            table.remove(self.particles, i)
        end
    end
    
    -- Add new particles
    if self.timer < 3 and #self.particles < 100 then
        for i = 1, 2 do
            table.insert(self.particles, {
                x = love.graphics.getWidth() / 2 + math.random(-200, 200),
                y = love.graphics.getHeight() / 2 + math.random(-100, 100),
                vx = math.random(-100, 100),
                vy = math.random(-100, 100),
                size = math.random(2, 5),
                color = {
                    math.random(0.5, 1),
                    math.random(0.5, 1),
                    math.random(0.5, 1),
                    1
                },
                life = math.random(1, 3)
            })
        end
    end
end

---Draws the level complete scene
function LevelCompleteScene:draw()
    -- Draw background
    love.graphics.setColor(0.05, 0.05, 0.1)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Draw stars
    love.graphics.setColor(1, 1, 1, 0.8)
    for _, star in ipairs(self.stars) do
        love.graphics.circle("fill", star.x, star.y, star.size)
    end
    
    -- Draw particles
    for _, p in ipairs(self.particles) do
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], p.life / 3)
        love.graphics.circle("fill", p.x, p.y, p.size)
    end
    
    -- Apply fade-in effect
    local alpha = self.fade_in
    
    -- Draw title
    love.graphics.setFont(fonts.huge)
    love.graphics.setColor(TITLE_COLOR[1], TITLE_COLOR[2], TITLE_COLOR[3], alpha)
    local title = "LANDING SUCCESSFUL!"
    local title_width = fonts.huge:getWidth(title)
    love.graphics.print(title, (love.graphics.getWidth() - title_width) / 2, 120)
    
    -- Draw level info
    love.graphics.setFont(fonts.title)
    love.graphics.setColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], alpha)
    local level_text = "Level " .. self.level .. " Complete"
    local level_width = fonts.title:getWidth(level_text)
    love.graphics.print(level_text, (love.graphics.getWidth() - level_width) / 2, 180)
    
    -- Draw score breakdown
    if self.timer > 1 then
        love.graphics.setFont(fonts.large)
        
        -- Landing score
        love.graphics.setColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], alpha)
        local landing_text = "Landing Score:"
        love.graphics.print(landing_text, love.graphics.getWidth() / 2 - 200, 250)
        
        love.graphics.setColor(HIGHLIGHT_COLOR[1], HIGHLIGHT_COLOR[2], HIGHLIGHT_COLOR[3], alpha)
        love.graphics.print(self.landing_score, love.graphics.getWidth() / 2 + 100, 250)
        
        -- Fuel bonus
        if self.timer > 1.5 then
            love.graphics.setColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], alpha)
            local fuel_text = "Fuel Bonus:"
            love.graphics.print(fuel_text, love.graphics.getWidth() / 2 - 200, 290)
            
            love.graphics.setColor(HIGHLIGHT_COLOR[1], HIGHLIGHT_COLOR[2], HIGHLIGHT_COLOR[3], alpha)
            love.graphics.print(self.fuel_bonus, love.graphics.getWidth() / 2 + 100, 290)
        end
        
        -- Total score
        if self.timer > 2 then
            love.graphics.setColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], alpha)
            local total_text = "Total Score:"
            love.graphics.print(total_text, love.graphics.getWidth() / 2 - 200, 350)
            
            love.graphics.setFont(fonts.title)
            love.graphics.setColor(HIGHLIGHT_COLOR[1], HIGHLIGHT_COLOR[2], HIGHLIGHT_COLOR[3], alpha)
            love.graphics.print(self.score, love.graphics.getWidth() / 2 + 100, 350)
        end
    end
    
    -- Draw next level button
    if self.show_next then
        love.graphics.setFont(fonts.large)
        love.graphics.setColor(HIGHLIGHT_COLOR)
        
        local next_text = "Press ENTER for Next Level"
        local next_width = fonts.large:getWidth(next_text)
        love.graphics.print(next_text, 
            (love.graphics.getWidth() - next_width) / 2, 
            love.graphics.getHeight() - 100)
    end
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