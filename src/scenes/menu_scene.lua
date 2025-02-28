-- Menu scene for the Mars Lander game
local MenuScene = {}
MenuScene.__index = MenuScene

-- Import required modules
local SceneManager = require("src.scenes.scene_manager")
local ScrollablePanel = require("src.ui.scrollable_panel")
local Button = require("src.ui.button")
local Theme = require("src.ui.theme")

-- Constants
local MENU_ITEM_SPACING = Theme.MENU.ITEM_SPACING
local MENU_START_Y = Theme.MENU.START_Y

-- Mars surface colors
local MARS_SURFACE_COLOR = Theme.ENVIRONMENT.MARS_SURFACE_COLOR
local MARS_SKY_COLOR = Theme.ENVIRONMENT.MARS_SKY_COLOR

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
        { text = "Credits",     action = function() SceneManager.changeScene("credits") end },
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

    -- Create back button for instructions
    self.back_button = Button.new({
        text = "Back to Menu",
        font = fonts.large,
        text_color = Theme.BUTTON.TEXT_COLOR,
        pulse = true,
        pulse_speed = Theme.BUTTON.PULSE_SPEED,
        pulse_amount = Theme.BUTTON.PULSE_AMOUNT,
        action = function() self.showing_instructions = false end
    })

    -- Create scrollable panel for instructions
    self.instructions_panel = ScrollablePanel.new({
        title = "HOW TO PLAY",
        title_font = fonts.title_font,
        content_font = fonts.medium,
        section_font = fonts.large,
        hint_font = fonts.small,
        show_hint = true,
        hint_text = "Press ESC or ENTER to return",
        content = {
            "Welcome to Mars Lander!",
            "",
            "Your mission is to safely land the spacecraft",
            "on the designated landing pads on the surface of Mars.",
            "",
            "CONTROLS:",
            "- LEFT/RIGHT ARROW KEYS: Rotate the lander",
            "- UP ARROW KEY: Fire main engine (thrust)",
            "- DOWN ARROW KEY: Fire retro rockets (slow descent)",
            "",
            "LANDING REQUIREMENTS:",
            "- Land GENTLY on a flat landing pad",
            "- Keep your vertical speed under 20 m/s",
            "- Keep your horizontal speed under 15 m/s",
            "- Land with the lander in an upright position",
            "",
            "FUEL MANAGEMENT:",
            "- Monitor your fuel gauge carefully",
            "- Once you run out of fuel, you can no longer",
            "  control the lander's descent",
            "",
            "TIPS:",
            "- Start slowing your descent early",
            "- Use short bursts to conserve fuel",
            "- Aim for the center of the landing pad",
            "- Counter horizontal movement before landing",
            "",
            "Good luck, Commander!"
        },
        bg_color = Theme.PANEL.BACKGROUND_COLOR,
        header_color = Theme.PANEL.HEADER_COLOR,
        text_color = Theme.PANEL.TEXT_COLOR,
        show_button = false, -- We'll use our custom button instead
        show_scroll_indicators = true,
        scroll_speed = 300
    })

    -- Scrolling for instructions
    self.scroll_position = 0
    self.scroll_speed = 300 -- Pixels per second

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

    -- Update the selected menu item based on keyboard input
    if not self.showing_instructions then
        -- Update lander
        self.lander.rotation = self.lander.rotation + math.sin(love.timer.getTime() * 0.5) * 0.002

        -- Random thruster effect
        self.lander.thruster_timer = self.lander.thruster_timer - dt
        if self.lander.thruster_timer <= 0 then
            self.lander.thruster = not self.lander.thruster
            self.lander.thruster_timer = math.random(5, 15) / 10 -- Random time between thruster changes
        end
    else
        -- Update instructions panel
        self.instructions_panel:update(dt)

        -- Update back button
        self.back_button:update(dt)
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
    love.graphics.setColor(Theme.LANDER.BODY_COLOR)
    love.graphics.polygon("fill", 0, -10, 10, 10, -10, 10)

    -- Draw landing legs
    love.graphics.setColor(Theme.LANDER.LEGS_COLOR)
    love.graphics.line(-10, 10, -15, 15)
    love.graphics.line(10, 10, 15, 15)

    -- Draw thruster flame if active
    if self.lander.thruster then
        love.graphics.setColor(Theme.LANDER.THRUSTER_COLOR)
        love.graphics.polygon("fill", -5, 10, 5, 10, 0, 20)
    end

    love.graphics.pop()
end

---Draws the main menu
function MenuScene:drawMenu()
    -- Draw title with the new font
    love.graphics.setFont(fonts.title_font)
    love.graphics.setColor(Theme.MENU.TITLE_COLOR)
    local title = "MARS LANDER"
    local title_width = fonts.title_font:getWidth(title)
    love.graphics.print(title, (love.graphics.getWidth() - title_width) / 2, 120)

    -- Draw subtitle
    love.graphics.setFont(fonts.medium)
    love.graphics.setColor(Theme.COLORS.WHITE_TRANSPARENT)
    local subtitle = "A mission to the red planet"
    local subtitle_width = fonts.medium:getWidth(subtitle)
    love.graphics.print(subtitle, (love.graphics.getWidth() - subtitle_width) / 2, 170)

    -- Draw menu items
    love.graphics.setFont(fonts.large)
    for i, item in ipairs(self.menu_items) do
        if i == self.selected_item then
            love.graphics.setColor(Theme.MENU.SELECTED_ITEM_COLOR)
            love.graphics.print("> " .. item.text,
                (love.graphics.getWidth() - fonts.large:getWidth(item.text)) / 2 - 20,
                MENU_START_Y + (i - 1) * MENU_ITEM_SPACING)
        else
            love.graphics.setColor(Theme.MENU.ITEM_COLOR)
            love.graphics.print(item.text,
                (love.graphics.getWidth() - fonts.large:getWidth(item.text)) / 2,
                MENU_START_Y + (i - 1) * MENU_ITEM_SPACING)
        end
    end

    -- Draw footer
    love.graphics.setFont(fonts.small)
    love.graphics.setColor(Theme.COLORS.LIGHT_GRAY)
    local footer = "Use arrow keys to navigate, Enter to select"
    local footer_width = fonts.small:getWidth(footer)
    love.graphics.print(footer,
        (love.graphics.getWidth() - footer_width) / 2,
        love.graphics.getHeight() - 30)
end

---Draws the instructions screen
function MenuScene:drawInstructions()
    -- Draw the instructions panel
    local panel_width = love.graphics.getWidth() * 0.6
    local panel_height = love.graphics.getHeight() * 0.65
    local panel_x = love.graphics.getWidth() * 0.15
    local panel_y = love.graphics.getHeight() * 0.15

    -- Update panel dimensions
    self.instructions_panel.x = panel_x
    self.instructions_panel.y = panel_y
    self.instructions_panel.width = panel_width
    self.instructions_panel.height = panel_height

    -- Draw the panel
    self.instructions_panel:draw()

    -- Update and draw back button
    local button_width = 200
    local button_height = 50
    local button_x = (love.graphics.getWidth() - button_width) / 2
    local button_y = panel_y + panel_height + 30

    self.back_button:setPosition(button_x, button_y)
    self.back_button:setDimensions(button_width, button_height)
    self.back_button:draw()
end

---Shows the instructions screen
function MenuScene:showInstructions()
    self.showing_instructions = true
    self.instructions_panel:resetScroll() -- Reset scroll position
end

---Handles key press events
---@param key string The key that was pressed
function MenuScene:keypressed(key)
    if self.showing_instructions then
        -- Handle back button via keyboard first
        if key == "escape" or key == "backspace" or key == "return" or key == "space" then
            self.showing_instructions = false
            return true
        end

        -- Then let the panel handle scrolling keys
        if self.instructions_panel:keypressed(key) then
            return
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
    -- No longer needed as the panel handles this
end

function MenuScene:mousepressed(x, y, button)
    if self.showing_instructions then
        -- Check if back button was clicked
        if self.back_button:mousepressed(x, y, button) then
            return
        end

        -- Let the panel handle mouse presses
        if self.instructions_panel:mousepressed(x, y, button) then
            return
        end
    end
end

return MenuScene
