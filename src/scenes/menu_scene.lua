-- Menu scene for the Mars Lander game
local MenuScene = {}
MenuScene.__index = MenuScene

-- Import required modules
local SceneManager = require("src.scenes.scene_manager")

-- Constants
local TITLE_COLOR = { 0.9, 0.3, 0.2, 1 }     -- Mars red
local MENU_ITEM_COLOR = { 1, 1, 1, 0.8 }     -- White with slight transparency
local SELECTED_ITEM_COLOR = { 1, 0.8, 0, 1 } -- Gold
local MENU_ITEM_SPACING = 40
local MENU_START_Y = 300

-- Mars surface colors
local MARS_SURFACE_COLOR = { 0.7, 0.3, 0.2, 1 } -- Darker Mars red for surface
local MARS_SKY_COLOR = { 0.1, 0.05, 0.1, 1 }    -- Dark purplish for Mars sky

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
        { text = "Start Game",  action = function() SceneManager.changeScene("game") end },
        { text = "How to Play", action = function() self:showInstructions() end },
        { text = "Settings",    action = function() SceneManager.changeScene("settings") end },
        { text = "Quit",        action = function() love.event.quit() end }
    }

    -- Current selected menu item
    self.selected_item = 1

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

    -- Flag to show instructions
    self.showing_instructions = false

    -- Create a simple lander for the menu
    self.lander = {
        x = love.graphics.getWidth() * 0.75,
        y = love.graphics.getHeight() * 0.4,
        rotation = -math.pi / 12, -- Slight tilt
        scale = 1.5,
        thruster = false,
        thruster_timer = 0
    }

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

---Updates the menu scene
---@param dt number Delta time
function MenuScene:update(dt)
    -- Update stars
    for _, star in ipairs(self.stars) do
        star.y = star.y + star.speed
        if star.y > love.graphics.getHeight() * 0.7 then
            star.y = 0
            star.x = math.random(0, love.graphics.getWidth())
        end
    end

    -- Update lander
    self.lander.rotation = self.lander.rotation + math.sin(love.timer.getTime() * 0.5) * 0.002

    -- Random thruster effect
    self.lander.thruster_timer = self.lander.thruster_timer - dt
    if self.lander.thruster_timer <= 0 then
        self.lander.thruster = not self.lander.thruster
        self.lander.thruster_timer = math.random(5, 15) / 10 -- Random time between thruster changes
    end
end

---Draws the menu scene
function MenuScene:draw()
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
    local ground_y = love.graphics.getHeight() * 0.75

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

    -- Draw the lander
    self:drawLander()

    if self.showing_instructions then
        self:drawInstructions()
    else
        self:drawMenu()
    end
end

---Draws the lander on the menu screen
function MenuScene:drawLander()
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

    -- Draw thruster flame if active
    if self.lander.thruster then
        love.graphics.setColor(1, 0.5, 0, 0.8)
        love.graphics.polygon("fill", -5, 10, 5, 10, 0, 20)
    end

    love.graphics.pop()
end

---Draws the main menu
function MenuScene:drawMenu()
    -- Draw title with the new font
    love.graphics.setFont(fonts.title_font)
    love.graphics.setColor(TITLE_COLOR)
    local title = "MARS LANDER"
    local title_width = fonts.title_font:getWidth(title)
    love.graphics.print(title, (love.graphics.getWidth() - title_width) / 2, 120)

    -- Draw subtitle
    love.graphics.setFont(fonts.medium)
    love.graphics.setColor(0.9, 0.9, 0.9, 0.8)
    local subtitle = "A mission to the red planet"
    local subtitle_width = fonts.medium:getWidth(subtitle)
    love.graphics.print(subtitle, (love.graphics.getWidth() - subtitle_width) / 2, 170)

    -- Draw menu items
    love.graphics.setFont(fonts.large)
    for i, item in ipairs(self.menu_items) do
        if i == self.selected_item then
            love.graphics.setColor(SELECTED_ITEM_COLOR)
            love.graphics.print("> " .. item.text,
                (love.graphics.getWidth() - fonts.large:getWidth(item.text)) / 2 - 20,
                MENU_START_Y + (i - 1) * MENU_ITEM_SPACING)
        else
            love.graphics.setColor(MENU_ITEM_COLOR)
            love.graphics.print(item.text,
                (love.graphics.getWidth() - fonts.large:getWidth(item.text)) / 2,
                MENU_START_Y + (i - 1) * MENU_ITEM_SPACING)
        end
    end

    -- Draw footer
    love.graphics.setFont(fonts.small)
    love.graphics.setColor(0.7, 0.7, 0.7, 0.7)
    local footer = "Use arrow keys to navigate, Enter to select"
    local footer_width = fonts.small:getWidth(footer)
    love.graphics.print(footer,
        (love.graphics.getWidth() - footer_width) / 2,
        love.graphics.getHeight() - 30)
end

---Draws the instructions screen
function MenuScene:drawInstructions()
    -- Keep drawing the background elements
    -- Draw background (Mars sky) - already drawn in the main draw function

    -- Calculate dimensions for better layout
    local panel_width = love.graphics.getWidth() * 0.7
    local panel_height = love.graphics.getHeight() * 0.75
    local panel_x = (love.graphics.getWidth() - panel_width) / 2
    local panel_y = love.graphics.getHeight() * 0.12
    local header_height = 60

    -- Draw a semi-transparent panel for instructions
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill",
        panel_x,
        panel_y,
        panel_width,
        panel_height,
        10, 10) -- Adding rounded corners

    -- Add a header bar
    love.graphics.setColor(TITLE_COLOR[1], TITLE_COLOR[2], TITLE_COLOR[3], 0.9)
    love.graphics.rectangle("fill",
        panel_x,
        panel_y,
        panel_width,
        header_height,
        10, 10) -- Rounded corners

    -- Draw title with the custom font
    love.graphics.setFont(fonts.title_font)
    love.graphics.setColor(0, 0, 0, 1) -- Black text on red header
    local title = "HOW TO PLAY"
    local title_width = fonts.title_font:getWidth(title)
    love.graphics.print(title,
        (love.graphics.getWidth() - title_width) / 2,
        panel_y + (header_height - fonts.title_font:getHeight()) / 2)

    -- Draw instructions
    love.graphics.setFont(fonts.medium)
    love.graphics.setColor(0.9, 0.9, 0.9, 1)

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

    local content_start_y = panel_y + header_height + 20
    local line_height = 28

    for i, line in ipairs(instructions) do
        local y_pos = content_start_y + (i - 1) * line_height

        -- Highlight key controls with gold color
        if i >= 4 and i <= 7 and line ~= "" then
            -- Split the line at the colon
            local parts = {}
            for part in string.gmatch(line, "[^:]+") do
                table.insert(parts, part)
            end

            if #parts == 2 then
                -- Draw the key part in gold
                love.graphics.setColor(SELECTED_ITEM_COLOR)
                love.graphics.print(parts[1] .. ":", panel_x + 40, y_pos)

                -- Draw the description in white
                love.graphics.setColor(0.9, 0.9, 0.9, 1)
                local key_width = fonts.medium:getWidth(parts[1] .. ":")
                love.graphics.print(parts[2], panel_x + 40 + key_width, y_pos)
            else
                love.graphics.print(line, panel_x + 40, y_pos)
            end
        else
            love.graphics.print(line, panel_x + 40, y_pos)
        end
    end

    -- Calculate button position to be inside the panel
    local button_width = 200
    local button_height = 50
    local button_x = (love.graphics.getWidth() - button_width) / 2
    local button_y = panel_y + panel_height - button_height - 30

    -- Button background
    love.graphics.setColor(0.2, 0.2, 0.2, 0.9)
    love.graphics.rectangle("fill",
        button_x,
        button_y,
        button_width,
        button_height,
        8, 8) -- Rounded corners

    -- Button border
    love.graphics.setColor(SELECTED_ITEM_COLOR)
    love.graphics.rectangle("line",
        button_x,
        button_y,
        button_width,
        button_height,
        8, 8) -- Rounded corners

    -- Button text
    love.graphics.setFont(fonts.large)
    love.graphics.setColor(SELECTED_ITEM_COLOR)
    local back_text = "Back to Menu"
    local back_width = fonts.large:getWidth(back_text)
    love.graphics.print(back_text,
        button_x + (button_width - back_width) / 2,
        button_y + (button_height - fonts.large:getHeight()) / 2)

    -- Add a hint at the bottom of the panel
    love.graphics.setFont(fonts.small)
    love.graphics.setColor(0.7, 0.7, 0.7, 0.7)
    local hint = "Press ENTER or ESC to return"
    local hint_width = fonts.small:getWidth(hint)
    love.graphics.print(hint,
        (love.graphics.getWidth() - hint_width) / 2,
        panel_y + panel_height - 15)
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
