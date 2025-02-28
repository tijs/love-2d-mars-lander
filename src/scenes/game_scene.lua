-- Game scene that manages the main gameplay on Mars
local GameScene = {}
GameScene.__index = GameScene

-- Import required entities
local Lander = require("src.entities.lander")
local Terrain = require("src.entities.terrain")
local Starfield = require("src.entities.starfield")
local SceneManager = require("src.scenes.scene_manager")

-- Constants
local INITIAL_LIVES = 3
local SCORE_PER_LANDING = 1000
local SCORE_PER_FUEL = 10
local FUEL_BONUS_THRESHOLD = 50
local FUEL_BONUS_SCORE = 500  -- Bonus score for landing with more than 50% fuel
local LEVEL_TRANSITION_TIME = 2  -- Time in seconds to show success before next level
local CRASH_DELAY = 2  -- Time to wait after crash before resetting level
local SAFE_LANDING_VELOCITY = 80  -- Maximum safe landing velocity
local SAFE_LANDING_ANGLE = 0.5    -- Maximum safe landing angle in radians (about 28 degrees)

---Creates a new game scene
---@return table The new game scene instance
function GameScene.new()
    local self = setmetatable({}, GameScene)
    
    -- Game state
    self.score = 0
    self.lives = INITIAL_LIVES
    self.level = 1
    self.game_over = false
    self.level_complete = false
    self.show_instructions = false
    self.level_transition_timer = 0
    self.crash_timer = 0
    self.success_message = ""
    
    -- Create starfield background
    self.starfield = Starfield.new()
    
    -- Create entities
    self:resetLevel()
    
    return self
end

---Resets the level
function GameScene:resetLevel()
    -- Create terrain
    self.terrain = Terrain.new()
    
    -- Create lander at the top center of the screen
    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()
    self.lander = Lander.new(screen_width / 2, screen_height / 5)
    
    -- Reset level state
    self.level_complete = false
    self.crash_timer = 0
end

---Loads the game scene
---@param level number Optional level number to start at
---@param score number Optional score to start with
function GameScene:load(level, score)
    -- Set initial level and score
    self.level = level or 1
    self.score = score or 0
    
    -- Reset game state
    self.lives = INITIAL_LIVES
    self.game_over = false
    self.level_complete = false
    self.show_instructions = false
    self.level_transition_timer = 0
    self.crash_timer = 0
    self.success_message = ""
    
    -- Create starfield background
    self.starfield = Starfield.new()
    
    -- Create entities
    self:resetLevel()
end

---Updates the game scene
---@param dt number Delta time
function GameScene:update(dt)
    -- Update starfield (always update regardless of game state)
    self.starfield:update(dt)
    
    -- Skip updates if showing instructions
    if self.show_instructions then
        return
    end
    
    -- Skip updates if game is over
    if self.game_over then
        return
    end
    
    -- Handle level transition
    if self.level_complete then
        self.level_transition_timer = self.level_transition_timer + dt
        
        if self.level_transition_timer >= LEVEL_TRANSITION_TIME then
            -- Transition to level complete scene
            local landing_score = SCORE_PER_LANDING
            local fuel_bonus = math.floor(self.lander:getFuel() * SCORE_PER_FUEL)
            if self.lander:getFuel() > FUEL_BONUS_THRESHOLD / 100 then
                fuel_bonus = fuel_bonus + FUEL_BONUS_SCORE
            end
            
            SceneManager.changeScene("level_complete", self.level, self.score, landing_score, fuel_bonus)
        end
        
        return  -- Skip other updates during transition
    end
    
    -- Update lander
    self.lander:update(dt, self.terrain)
    
    -- Check for level completion or failure
    if self.lander:isLanded() and not self.level_complete then
        -- Calculate score based on landing
        local fuel_bonus = math.floor(self.lander:getFuel() * SCORE_PER_FUEL)
        self.score = self.score + SCORE_PER_LANDING + fuel_bonus
        
        -- Add extra bonus for landing with more than 50% fuel
        if self.lander:getFuel() > FUEL_BONUS_THRESHOLD then
            self.score = self.score + FUEL_BONUS_SCORE
        end
        
        -- Set success message
        self.success_message = string.format(
            "Perfect landing! +%d pts\nFuel bonus: +%d pts", 
            SCORE_PER_LANDING, fuel_bonus
        )
        
        -- Set level complete flag
        self.level_complete = true
        self.level_transition_timer = 0
    elseif self.lander:isCrashed() then
        -- Update crash timer to allow explosion to play out
        self.crash_timer = self.crash_timer + dt
        
        -- Only proceed with life reduction after explosion animation
        if self.crash_timer >= CRASH_DELAY then
            self.lives = self.lives - 1
            
            if self.lives <= 0 then
                -- Game over
                self.game_over = true
                SceneManager.changeScene("game_over", self.score)
            else
                -- Reset the level
                self.crash_timer = 0
                self:resetLevel()
            end
        end
    end
end

---Handles key press events
---@param key string The key that was pressed
function GameScene:keypressed(key)
    -- Skip if game is over
    if self.game_over then
        return
    end
    
    -- Handle instructions screen (removed the check for show_instructions)
    
    -- Handle pause
    if key == "escape" then
        SceneManager.changeScene("menu")
        return
    end
    
    if key == "r" then
        -- Restart the game
        self.score = 0
        self.lives = INITIAL_LIVES
        self.level = 1
        self.game_over = false
        self:resetLevel()
        return
    end
    
    -- Lander controls
    if key == "up" or key == "w" then
        self.lander:activateThrust()
    end
end

---Handles key release events
---@param key string The key that was released
function GameScene:keyreleased(key)
    if key == "up" or key == "w" then
        self.lander:deactivateThrust()
    end
end

---Updates continuous key presses
function GameScene:updateKeyPresses()
    -- Skip if game is over or showing instructions
    if self.game_over or self.show_instructions then
        return
    end
    
    -- Rotation controls
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        self.lander:rotateLeft(love.timer.getDelta())
    end
    
    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        self.lander:rotateRight(love.timer.getDelta())
    end
end

---Draws the game scene
function GameScene:draw()
    -- Draw background (Mars sky)
    love.graphics.setBackgroundColor(0.5, 0.2, 0.1)
    
    -- Draw starfield background
    self.starfield:draw()
    
    -- Draw terrain
    self.terrain:draw()
    
    -- Draw lander
    self.lander:draw()
    
    -- Draw UI
    self:drawUI()
    
    -- Draw level transition screen
    if self.level_complete then
        self:drawLevelComplete()
    end
    
    -- Draw instructions if needed (keeping this for potential future use)
    if self.show_instructions then
        self:drawInstructions()
    end
    
    -- Draw game over screen if needed
    if self.game_over then
        self:drawGameOver()
    end
    
    -- Draw crash message if crashed
    if self.lander:isCrashed() and not self.game_over then
        self:drawCrashMessage()
    end
end

---Draws the game UI
function GameScene:drawUI()
    -- Set font
    love.graphics.setFont(fonts.medium)
    
    -- Draw score
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. self.score, 20, 20)
    
    -- Draw level
    love.graphics.print("Landing Site: " .. self.level, 20, 50)
    
    -- Draw lives
    love.graphics.print("Attempts: " .. self.lives, 20, 80)
    
    -- Draw fuel gauge
    self:drawFuelGauge()
    
    -- Draw velocity indicator
    self:drawVelocityIndicator()
end

---Draws the instructions screen
function GameScene:drawInstructions()
    -- Semi-transparent background
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Title
    love.graphics.setColor(1, 0.5, 0.3)
    love.graphics.setFont(fonts.title)
    love.graphics.printf("MARS LANDER", 0, 50, love.graphics.getWidth(), "center")
    
    -- Instructions
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.medium)
    
    local instructions = {
        "Land your spacecraft safely on the flat landing pads",
        "Use the arrow keys or WASD to control your lander:",
        "UP or W: Thrust",
        "LEFT/RIGHT or A/D: Rotate",
        "",
        "For a successful landing:",
        "- Land on a flat surface (landing pad)",
        "- Land with low velocity",
        "- Keep your spacecraft level (not tilted)",
        "- Conserve fuel for bonus points",
        "",
        "Watch out for the Martian dust storms!",
        "",
        "Press SPACE to start"
    }
    
    local y = 120
    for _, line in ipairs(instructions) do
        love.graphics.printf(line, 50, y, love.graphics.getWidth() - 100, "left")
        y = y + 25
    end
end

---Draws the game over screen
function GameScene:drawGameOver()
    -- Semi-transparent background
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Game over text
    love.graphics.setColor(1, 0.3, 0.3)
    love.graphics.setFont(fonts.huge)
    love.graphics.printf("MISSION FAILED", 0, love.graphics.getHeight() / 3, love.graphics.getWidth(), "center")
    
    -- Score
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.large)
    love.graphics.printf("Final Score: " .. self.score, 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
    
    -- Restart prompt
    love.graphics.setColor(1, 0.8, 0.3)
    love.graphics.setFont(fonts.medium)
    love.graphics.printf("Press SPACE to try again", 0, love.graphics.getHeight() * 2/3, love.graphics.getWidth(), "center")
end

---Draws the level complete screen
function GameScene:drawLevelComplete()
    -- Semi-transparent background
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Success message
    love.graphics.setColor(0.3, 1, 0.3)
    love.graphics.setFont(fonts.huge)
    love.graphics.printf("SUCCESSFUL LANDING!", 0, love.graphics.getHeight() / 3, love.graphics.getWidth(), "center")
    
    -- Score info
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.medium)
    love.graphics.printf(self.success_message, 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
    
    -- Next level message
    love.graphics.setColor(1, 0.8, 0.3)
    love.graphics.setFont(fonts.medium)
    love.graphics.printf("Preparing for next landing site...", 0, love.graphics.getHeight() * 2/3, love.graphics.getWidth(), "center")
end

---Draws the crash message
function GameScene:drawCrashMessage()
    -- Semi-transparent background for text
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, love.graphics.getHeight() / 2 - 40, love.graphics.getWidth(), 80)
    
    -- Crash message
    love.graphics.setColor(1, 0.3, 0.3)
    love.graphics.setFont(fonts.title)
    love.graphics.printf("SPACECRAFT CRASHED", 0, love.graphics.getHeight() / 2 - 30, love.graphics.getWidth(), "center")
    
    -- Lives remaining
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.medium)
    if self.lives > 0 then
        love.graphics.printf("Remaining attempts: " .. self.lives, 0, love.graphics.getHeight() / 2 + 10, love.graphics.getWidth(), "center")
    else
        love.graphics.printf("Mission failed!", 0, love.graphics.getHeight() / 2 + 10, love.graphics.getWidth(), "center")
    end
end

---Draws the fuel gauge
function GameScene:drawFuelGauge()
    -- Draw fuel label
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Fuel: ", 20, 110)
    
    -- Draw fuel bar background
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", 70, 110, 100, 15)
    
    -- Draw fuel bar
    local fuel_percentage = self.lander:getFuel() / 100
    local fuel_color = {0.2, 0.7, 1} -- Blue fuel color for Mars lander
    
    -- Change color to red when fuel is low
    if fuel_percentage < 0.3 then
        fuel_color = {1, 0.3, 0.3} -- Red for low fuel
    end
    
    love.graphics.setColor(fuel_color)
    love.graphics.rectangle("fill", 70, 110, 100 * fuel_percentage, 15)
    
    -- Draw fuel percentage text
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format("%.0f%%", fuel_percentage * 100), 175, 110)
end

---Draws the velocity indicator
function GameScene:drawVelocityIndicator()
    -- Calculate velocity
    local vx, vy = self.lander:getVelocity()
    local velocity = math.sqrt(vx^2 + vy^2)
    
    -- Draw velocity label and value
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Velocity: ", 20, 140)
    
    -- Color code based on safe landing velocity
    local velocity_color = {0.2, 1, 0.2} -- Green for safe velocity
    
    if velocity > SAFE_LANDING_VELOCITY * 0.7 and velocity <= SAFE_LANDING_VELOCITY then
        velocity_color = {1, 1, 0.2} -- Yellow for caution
    elseif velocity > SAFE_LANDING_VELOCITY then
        velocity_color = {1, 0.2, 0.2} -- Red for dangerous
    end
    
    love.graphics.setColor(velocity_color)
    love.graphics.print(string.format("%.1f", velocity), 100, 140)
    
    -- Draw angle indicator
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Angle: ", 20, 170)
    
    -- Get angle in degrees (convert from radians)
    local angle_degrees = math.abs(math.deg(self.lander:getRotation()) % 360)
    
    -- Color code based on safe landing angle
    local angle_color = {0.2, 1, 0.2} -- Green for safe angle
    
    if angle_degrees > math.deg(SAFE_LANDING_ANGLE) * 0.7 and angle_degrees <= math.deg(SAFE_LANDING_ANGLE) then
        angle_color = {1, 1, 0.2} -- Yellow for caution
    elseif angle_degrees > math.deg(SAFE_LANDING_ANGLE) then
        angle_color = {1, 0.2, 0.2} -- Red for dangerous
    end
    
    love.graphics.setColor(angle_color)
    love.graphics.print(string.format("%.1f°", angle_degrees), 100, 170)
end

return GameScene 