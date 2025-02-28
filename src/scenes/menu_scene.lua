-- Menu scene for the Mars Lander game
local MenuScene = {}
MenuScene.__index = MenuScene

-- Import required modules
local SceneManager = require("src.scenes.scene_manager")

-- Constants
local TITLE_COLOR = {0.9, 0.3, 0.2, 1}  -- Mars red
local MENU_ITEM_COLOR = {1, 1, 1, 1}    -- White
local SELECTED_ITEM_COLOR = {1, 0.8, 0, 1}  -- Gold
local MENU_ITEM_SPACING = 50
local MENU_START_Y = 300

---Creates a new menu scene
---@return table The new menu scene instance
function MenuScene.new()
    local self = setmetatable({}, MenuScene)
    return self
end

---Loads the menu scene
function MenuScene:load()
    -- Menu options
    self.menu_items = {
        {text = "Start Game", action = function() SceneManager.changeScene("game") end},
        {text = "How to Play", action = function() self:showInstructions() end},
        {text = "Settings", action = function() SceneManager.changeScene("settings") end},
        {text = "Quit", action = function() love.event.quit() end}
    }
    
    -- Current selected menu item
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
    
    -- Flag to show instructions
    self.showing_instructions = false
end

---Updates the menu scene
---@param dt number Delta time
function MenuScene:update(dt)
    -- Update stars
    for _, star in ipairs(self.stars) do
        star.y = star.y + star.speed
        if star.y > love.graphics.getHeight() then
            star.y = 0
            star.x = math.random(0, love.graphics.getWidth())
        end
    end
end

---Draws the menu scene
function MenuScene:draw()
    -- Draw background
    love.graphics.setColor(0.05, 0.05, 0.1)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Draw stars
    love.graphics.setColor(1, 1, 1, 0.8)
    for _, star in ipairs(self.stars) do
        love.graphics.circle("fill", star.x, star.y, star.size)
    end
    
    if self.showing_instructions then
        self:drawInstructions()
    else
        self:drawMenu()
    end
end

---Draws the main menu
function MenuScene:drawMenu()
    -- Draw title
    love.graphics.setFont(fonts.huge)
    love.graphics.setColor(TITLE_COLOR)
    local title = "MARS LANDER"
    local title_width = fonts.huge:getWidth(title)
    love.graphics.print(title, (love.graphics.getWidth() - title_width) / 2, 150)
    
    -- Draw subtitle
    love.graphics.setFont(fonts.medium)
    love.graphics.setColor(0.8, 0.8, 0.8)
    local subtitle = "A mission to the red planet"
    local subtitle_width = fonts.medium:getWidth(subtitle)
    love.graphics.print(subtitle, (love.graphics.getWidth() - subtitle_width) / 2, 200)
    
    -- Draw menu items
    love.graphics.setFont(fonts.large)
    for i, item in ipairs(self.menu_items) do
        if i == self.selected_item then
            love.graphics.setColor(SELECTED_ITEM_COLOR)
            love.graphics.print("> " .. item.text, 
                (love.graphics.getWidth() - fonts.large:getWidth(item.text)) / 2 - 20, 
                MENU_START_Y + (i-1) * MENU_ITEM_SPACING)
        else
            love.graphics.setColor(MENU_ITEM_COLOR)
            love.graphics.print(item.text, 
                (love.graphics.getWidth() - fonts.large:getWidth(item.text)) / 2, 
                MENU_START_Y + (i-1) * MENU_ITEM_SPACING)
        end
    end
    
    -- Draw footer
    love.graphics.setFont(fonts.small)
    love.graphics.setColor(0.7, 0.7, 0.7)
    local footer = "Use arrow keys to navigate, Enter to select"
    local footer_width = fonts.small:getWidth(footer)
    love.graphics.print(footer, 
        (love.graphics.getWidth() - footer_width) / 2, 
        love.graphics.getHeight() - 50)
end

---Draws the instructions screen
function MenuScene:drawInstructions()
    -- Draw title
    love.graphics.setFont(fonts.title)
    love.graphics.setColor(TITLE_COLOR)
    local title = "HOW TO PLAY"
    local title_width = fonts.title:getWidth(title)
    love.graphics.print(title, (love.graphics.getWidth() - title_width) / 2, 100)
    
    -- Draw instructions
    love.graphics.setFont(fonts.medium)
    love.graphics.setColor(0.9, 0.9, 0.9)
    
    local instructions = {
        "Land your spacecraft safely on the flat landing pads.",
        "Control your descent with the following keys:",
        "",
        "UP ARROW: Activate main thruster",
        "LEFT/RIGHT ARROWS: Rotate spacecraft",
        "R: Restart level",
        "ESC: Pause game",
        "",
        "For a successful landing:",
        "- Touch down gently (low velocity)",
        "- Land with a level orientation",
        "- Land on a designated landing pad",
        "- Conserve fuel for bonus points"
    }
    
    for i, line in ipairs(instructions) do
        local y_pos = 150 + i * 30
        love.graphics.print(line, 200, y_pos)
    end
    
    -- Draw back button
    love.graphics.setFont(fonts.large)
    love.graphics.setColor(SELECTED_ITEM_COLOR)
    local back_text = "Back to Menu"
    local back_width = fonts.large:getWidth(back_text)
    love.graphics.print(back_text, 
        (love.graphics.getWidth() - back_width) / 2, 
        love.graphics.getHeight() - 100)
end

---Shows the instructions screen
function MenuScene:showInstructions()
    self.showing_instructions = true
end

---Handles key press events
---@param key string The key that was pressed
function MenuScene:keypressed(key)
    if self.showing_instructions then
        if key == "return" or key == "escape" or key == "space" then
            self.showing_instructions = false
        end
    else
        if key == "up" then
            self.selected_item = math.max(1, self.selected_item - 1)
        elseif key == "down" then
            self.selected_item = math.min(#self.menu_items, self.selected_item + 1)
        elseif key == "return" or key == "space" then
            -- Execute the selected menu item's action
            self.menu_items[self.selected_item].action()
        end
    end
end

---Handles key release events
---@param key string The key that was released
function MenuScene:keyreleased(key)
    -- Not needed for menu scene
end

---Handles continuous key presses
function MenuScene:updateKeyPresses()
    -- Not needed for menu scene
end

return MenuScene 