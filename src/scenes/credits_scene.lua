-- Credits scene for the Mars Lander game
local CreditsScene = {}
CreditsScene.__index = CreditsScene

-- Import required modules
local SceneManager = require("src.scenes.scene_manager")
local ScrollablePanel = require("src.ui.scrollable_panel")
local Button = require("src.ui.button")
local Theme = require("src.ui.theme")

-- Mars surface colors
local MARS_SURFACE_COLOR = Theme.ENVIRONMENT.MARS_SURFACE_COLOR
local MARS_SKY_COLOR = Theme.ENVIRONMENT.MARS_SKY_COLOR

---Creates a new credits scene
---@return table The new credits scene instance
function CreditsScene.new()
    local self = setmetatable({}, CreditsScene)
    return self
end

---Loads the credits scene
function CreditsScene:load()
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

    -- Create a simple lander for the credits
    self.lander = {
        x = love.graphics.getWidth() * 0.85,
        y = love.graphics.getHeight() * 0.3,
        rotation = -math.pi / 12, -- Slight tilt
        scale = 1.2,
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

    -- Animation timer
    self.timer = 0

    -- Create scrollable panel for credits
    self.credits_panel = ScrollablePanel.new({
        title = "CREDITS",
        title_font = fonts.title_font,
        content_font = fonts.medium,
        section_font = fonts.large,
        hint_font = fonts.small,
        show_hint = true,
        hint_text = "Press ESC or ENTER to return",
        sections = {
            {
                title = "Game Development",
                content = {
                    "Mars Lander - A LÖVE2D Game",
                    "A physics-based landing simulation",
                    "Developed as an open-source project",
                    "Inspired by classic arcade games"
                }
            },
            {
                title = "Font Credits",
                content = {
                    "\"Press Start 2P\" Font by CodeMan38",
                    "Copyright 2012 The Press Start 2P Project Authors",
                    "Licensed under the SIL Open Font License, Version 1.1",
                    "Font available at fonts.google.com"
                }
            },
            {
                title = "AI Assistance",
                content = {
                    "Game design assistance by Claude 3.7 Sonnet",
                    "Developed by Anthropic",
                    "Used for code generation and game design",
                    "Part of the creative development process"
                }
            },
            {
                title = "Special Thanks",
                content = {
                    "LÖVE2D Framework and Community",
                    "Open Source Game Development Resources",
                    "Beta Testers and Early Players",
                    "Everyone who provided feedback and support"
                }
            }
        },
        header_color = Theme.PANEL.HEADER_COLOR,
        bg_color = Theme.PANEL.BACKGROUND_COLOR,
        text_color = Theme.PANEL.TEXT_COLOR,
        section_color = Theme.PANEL.SECTION_COLOR
    })

    -- Create back button
    self.back_button = Button.new({
        text = "Back to Menu",
        font = fonts.large,
        text_color = Theme.BUTTON.TEXT_COLOR,
        pulse = true,
        pulse_speed = Theme.BUTTON.PULSE_SPEED,
        pulse_amount = Theme.BUTTON.PULSE_AMOUNT,
        action = function() SceneManager.changeScene("menu") end
    })
end

---Updates the credits scene
---@param dt number Delta time
function CreditsScene:update(dt)
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

    -- Update animation timer
    self.timer = self.timer + dt

    -- Update credits panel
    self.credits_panel:update(dt)

    -- Update back button
    self.back_button:update(dt)
end

---Draws the credits scene
function CreditsScene:draw()
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

    -- Draw the lander
    self:drawLander()

    -- Draw credits panel
    local panel_width = love.graphics.getWidth() * 0.6
    local panel_height = love.graphics.getHeight() * 0.65
    local panel_x = love.graphics.getWidth() * 0.15
    local panel_y = love.graphics.getHeight() * 0.15

    -- Update panel dimensions
    self.credits_panel.x = panel_x
    self.credits_panel.y = panel_y
    self.credits_panel.width = panel_width
    self.credits_panel.height = panel_height

    -- Draw the panel
    self.credits_panel:draw()

    -- Update and draw back button
    local button_width = 200
    local button_height = 50
    local button_x = (love.graphics.getWidth() - button_width) / 2
    local button_y = panel_y + panel_height + 30

    self.back_button:setPosition(button_x, button_y)
    self.back_button:setDimensions(button_width, button_height)
    self.back_button:draw()
end

---Draws the lander on the credits screen
function CreditsScene:drawLander()
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

---Handles key press events
---@param key string The key that was pressed
function CreditsScene:keypressed(key)
    -- Check for back keys first
    if key == "escape" or key == "return" or key == "space" then
        SceneManager.changeScene("menu")
        return true
    end

    -- Then let the panel handle the key press
    if self.credits_panel:keypressed(key) then
        return true
    end
end

---Handles key release events
---@param key string The key that was released
function CreditsScene:keyreleased(key)
    -- Not needed for credits scene
end

---Handles continuous key presses
function CreditsScene:updateKeyPresses()
    -- No longer needed as the panel handles this
end

---Handles mouse press events
---@param x number The x coordinate
---@param y number The y coordinate
---@param button number The button that was pressed
function CreditsScene:mousepressed(x, y, button)
    -- Let the button handle the mouse press
    if self.back_button:mousepressed(x, y, button) then
        return
    end
end

return CreditsScene
