-- Settings scene for the Mars Lander game
local SettingsScene = {}
SettingsScene.__index = SettingsScene

-- Import required modules
local SceneManager = require("src.scenes.scene_manager")

-- Constants
local TITLE_COLOR = {0.9, 0.3, 0.2, 1}  -- Mars red
local TEXT_COLOR = {1, 1, 1, 1}         -- White
local SELECTED_COLOR = {1, 0.8, 0, 1}   -- Gold
local OPTION_COLOR = {0.8, 0.8, 0.8, 1} -- Light gray
local MENU_ITEM_SPACING = 50
local MENU_START_Y = 250

---Creates a new settings scene
---@return table The new settings scene instance
function SettingsScene.new()
    local self = setmetatable({}, SettingsScene)
    return self
end

---Loads the settings scene
function SettingsScene:load()
    -- Settings options
    self.settings = {
        {
            name = "Sound Volume",
            value = 100,
            min = 0,
            max = 100,
            step = 10,
            display = function(val) return val .. "%" end
        },
        {
            name = "Music Volume",
            value = 100,
            min = 0,
            max = 100,
            step = 10,
            display = function(val) return val .. "%" end
        },
        {
            name = "Difficulty",
            value = 2,
            min = 1,
            max = 3,
            step = 1,
            display = function(val)
                if val == 1 then return "Easy"
                elseif val == 2 then return "Normal"
                else return "Hard" end
            end
        },
        {
            name = "Show FPS",
            value = 0,
            min = 0,
            max = 1,
            step = 1,
            display = function(val) return val == 1 and "On" or "Off" end
        }
    }
    
    -- Current selected setting
    self.selected_item = 1
    
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
end

---Updates the settings scene
---@param dt number Delta time
function SettingsScene:update(dt)
    -- Update stars
    for _, star in ipairs(self.stars) do
        star.y = star.y + star.speed
        if star.y > love.graphics.getHeight() then
            star.y = 0
            star.x = math.random(0, love.graphics.getWidth())
        end
    end
end

---Draws the settings scene
function SettingsScene:draw()
    -- Draw background
    love.graphics.setColor(0.05, 0.05, 0.1)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Draw stars
    love.graphics.setColor(1, 1, 1, 0.8)
    for _, star in ipairs(self.stars) do
        love.graphics.circle("fill", star.x, star.y, star.size)
    end
    
    -- Draw title
    love.graphics.setFont(fonts.title)
    love.graphics.setColor(TITLE_COLOR)
    local title = "SETTINGS"
    local title_width = fonts.title:getWidth(title)
    love.graphics.print(title, (love.graphics.getWidth() - title_width) / 2, 150)
    
    -- Draw settings
    love.graphics.setFont(fonts.large)
    for i, setting in ipairs(self.settings) do
        local y_pos = MENU_START_Y + (i-1) * MENU_ITEM_SPACING
        
        -- Setting name
        if i == self.selected_item then
            love.graphics.setColor(SELECTED_COLOR)
        else
            love.graphics.setColor(TEXT_COLOR)
        end
        love.graphics.print(setting.name, 200, y_pos)
        
        -- Setting value
        love.graphics.setColor(OPTION_COLOR)
        local value_text = setting.display(setting.value)
        local value_width = fonts.large:getWidth(value_text)
        love.graphics.print(value_text, love.graphics.getWidth() - 200 - value_width, y_pos)
        
        -- Draw arrows for selected item
        if i == self.selected_item then
            love.graphics.setColor(SELECTED_COLOR)
            love.graphics.print("<", love.graphics.getWidth() - 230 - value_width, y_pos)
            love.graphics.print(">", love.graphics.getWidth() - 180, y_pos)
        end
    end
    
    -- Draw back button
    love.graphics.setFont(fonts.large)
    love.graphics.setColor(SELECTED_COLOR)
    local back_text = "Back to Menu"
    local back_width = fonts.large:getWidth(back_text)
    love.graphics.print(back_text, 
        (love.graphics.getWidth() - back_width) / 2, 
        love.graphics.getHeight() - 100)
    
    -- Draw instructions
    love.graphics.setFont(fonts.small)
    love.graphics.setColor(0.7, 0.7, 0.7)
    local instructions = "Use UP/DOWN to navigate, LEFT/RIGHT to change values, ESC to return"
    local instructions_width = fonts.small:getWidth(instructions)
    love.graphics.print(instructions, 
        (love.graphics.getWidth() - instructions_width) / 2, 
        love.graphics.getHeight() - 50)
end

---Handles key press events
---@param key string The key that was pressed
function SettingsScene:keypressed(key)
    if key == "up" then
        self.selected_item = math.max(1, self.selected_item - 1)
    elseif key == "down" then
        self.selected_item = math.min(#self.settings, self.selected_item + 1)
    elseif key == "left" then
        local setting = self.settings[self.selected_item]
        setting.value = math.max(setting.min, setting.value - setting.step)
    elseif key == "right" then
        local setting = self.settings[self.selected_item]
        setting.value = math.min(setting.max, setting.value + setting.step)
    elseif key == "escape" or key == "return" or key == "space" then
        SceneManager.changeScene("menu")
    end
end

---Handles key release events
---@param key string The key that was released
function SettingsScene:keyreleased(key)
    -- Not needed for settings scene
end

---Handles continuous key presses
function SettingsScene:updateKeyPresses()
    -- Not needed for settings scene
end

return SettingsScene 