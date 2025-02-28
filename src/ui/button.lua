-- Button Component for Mars Lander
-- A reusable UI component that creates an interactive button

local Button = {}
Button.__index = Button

-- Import Theme
local Theme = require("src.ui.theme")

---Creates a new button
---@param config table Configuration options for the button
---@return table The new button instance
function Button.new(config)
    local self = setmetatable({}, Button)

    -- Position and dimensions
    self.x = config.x or 0
    self.y = config.y or 0
    self.width = config.width or 200
    self.height = config.height or 50

    -- Text and styling
    self.text = config.text or "Button"
    self.font = config.font or love.graphics.getFont()
    self.text_color = config.text_color or Theme.BUTTON.TEXT_COLOR
    self.bg_color = config.bg_color or Theme.BUTTON.BACKGROUND_COLOR
    self.border_color = config.border_color or self.text_color
    self.corner_radius = config.corner_radius or Theme.BUTTON.CORNER_RADIUS

    -- Effects
    self.pulse = config.pulse or false
    self.pulse_speed = config.pulse_speed or Theme.BUTTON.PULSE_SPEED
    self.pulse_amount = config.pulse_amount or Theme.BUTTON.PULSE_AMOUNT
    self.hover_effect = config.hover_effect or false

    -- State
    self.timer = 0
    self.hovered = false

    -- Action
    self.action = config.action or function() end

    return self
end

---Updates the button
---@param dt number Delta time
function Button:update(dt)
    -- Update timer for pulse effect
    self.timer = self.timer + dt

    -- Update hover state if hover effect is enabled
    if self.hover_effect then
        local mx, my = love.mouse.getPosition()
        self.hovered = self:isPointInside(mx, my)
    end
end

---Draws the button
function Button:draw()
    -- Calculate pulse effect if enabled
    local alpha_mod = 1
    if self.pulse then
        alpha_mod = (math.sin(self.timer * self.pulse_speed) * self.pulse_amount) + (1 - self.pulse_amount)
    end

    -- Apply hover effect if enabled and hovered
    local scale = 1
    if self.hover_effect and self.hovered then
        scale = 1.05
    end

    -- Draw button background
    love.graphics.setColor(self.bg_color)
    love.graphics.rectangle("fill",
        self.x,
        self.y,
        self.width * scale,
        self.height * scale,
        self.corner_radius, self.corner_radius)

    -- Draw button border
    love.graphics.setColor(self.border_color[1], self.border_color[2], self.border_color[3],
        self.border_color[4] * alpha_mod)
    love.graphics.rectangle("line",
        self.x,
        self.y,
        self.width * scale,
        self.height * scale,
        self.corner_radius, self.corner_radius)

    -- Draw button text
    love.graphics.setFont(self.font)
    love.graphics.setColor(self.text_color[1], self.text_color[2], self.text_color[3], self.text_color[4] * alpha_mod)
    local text_width = self.font:getWidth(self.text)
    local text_height = self.font:getHeight()
    love.graphics.print(self.text,
        self.x + (self.width * scale - text_width) / 2,
        self.y + (self.height * scale - text_height) / 2)
end

---Checks if a point is inside the button
---@param x number The x coordinate
---@param y number The y coordinate
---@return boolean Whether the point is inside the button
function Button:isPointInside(x, y)
    return x >= self.x and x <= self.x + self.width and
        y >= self.y and y <= self.y + self.height
end

---Handles mouse press events
---@param x number The x coordinate
---@param y number The y coordinate
---@param button number The button that was pressed
---@return boolean Whether the mouse press was handled
function Button:mousepressed(x, y, button)
    if button == 1 and self:isPointInside(x, y) then
        self.action()
        return true
    end
    return false
end

---Handles key press events
---@param key string The key that was pressed
---@return boolean Whether the key was handled
function Button:keypressed(key)
    if key == "return" or key == "space" then
        self.action()
        return true
    end
    return false
end

---Sets the button's position
---@param x number The x coordinate
---@param y number The y coordinate
function Button:setPosition(x, y)
    self.x = x
    self.y = y
end

---Sets the button's dimensions
---@param width number The width
---@param height number The height
function Button:setDimensions(width, height)
    self.width = width
    self.height = height
end

---Sets the button's text
---@param text string The text
function Button:setText(text)
    self.text = text
end

---Sets the button's action
---@param action function The action to perform when the button is clicked
function Button:setAction(action)
    self.action = action
end

return Button
