-- Scrollable Panel Component for Mars Lander
-- A reusable UI component that creates a scrollable panel with content

local ScrollablePanel = {}
ScrollablePanel.__index = ScrollablePanel

-- Import Button component
local Button = require("src.ui.button")
-- Import Theme
local Theme = require("src.ui.theme")

---Creates a new scrollable panel
---@param config table Configuration options for the panel
---@return table The new scrollable panel instance
function ScrollablePanel.new(config)
    local self = setmetatable({}, ScrollablePanel)

    -- Initialize panel with default configuration
    self:initializeDimensions(config)
    self:initializeHeader(config)
    self:initializePanelStyle(config)
    self:initializeContent(config)
    self:initializeScrolling(config)
    self:initializeButton(config)
    self:initializeHint(config)
    self:initializeSections(config)

    return self
end

---Initializes panel dimensions and position
---@param config table Configuration options
function ScrollablePanel:initializeDimensions(config)
    -- Panel dimensions and position
    self.x = config.x or 0
    self.y = config.y or 0
    self.width = config.width or 400
    self.height = config.height or 300
end

---Initializes header configuration
---@param config table Configuration options
function ScrollablePanel:initializeHeader(config)
    -- Header configuration
    self.header_height = config.header_height or 60
    self.header_color = config.header_color or Theme.PANEL.HEADER_COLOR
    self.title = config.title or "Scrollable Panel"
    self.title_font = config.title_font or love.graphics.getFont()
    self.title_color = config.title_color or Theme.COLORS.BLACK
end

---Initializes panel styling
---@param config table Configuration options
function ScrollablePanel:initializePanelStyle(config)
    -- Panel styling
    self.panel_color = config.bg_color or Theme.PANEL.BACKGROUND_COLOR
    self.corner_radius = config.corner_radius or Theme.PANEL.CORNER_RADIUS
end

---Initializes content configuration
---@param config table Configuration options
function ScrollablePanel:initializeContent(config)
    -- Content configuration
    self.content = config.content or {}
    self.content_font = config.content_font or love.graphics.getFont()
    self.content_color = config.text_color or Theme.PANEL.TEXT_COLOR
    self.line_height = config.line_height or 28
    self.content_padding = config.content_padding or 40 -- Left padding for content
end

---Initializes scrolling configuration
---@param config table Configuration options
function ScrollablePanel:initializeScrolling(config)
    -- Scrolling
    self.scroll_position = 0
    self.scroll_speed = config.scroll_speed or 300 -- Pixels per second
end

---Initializes button configuration
---@param config table Configuration options
function ScrollablePanel:initializeButton(config)
    -- Button configuration (optional)
    self.show_button = config.show_button or false

    if not self.show_button then
        return
    end

    self.button_text = config.button_text or "Back"
    self.button_font = config.button_font or love.graphics.getFont()
    self.button_color = config.button_color or Theme.BUTTON.TEXT_COLOR
    self.button_bg_color = config.button_bg_color or Theme.BUTTON.BACKGROUND_COLOR
    self.button_width = config.button_width or 200
    self.button_height = config.button_height or 50
    self.button_action = config.button_action or function() end
    self.button_margin = config.button_margin or 30 -- Margin from bottom of panel

    -- Create button
    self.button = Button.new({
        text = self.button_text,
        font = self.button_font,
        text_color = self.button_color,
        bg_color = self.button_bg_color,
        width = self.button_width,
        height = self.button_height,
        action = self.button_action
    })
end

---Initializes hint configuration
---@param config table Configuration options
function ScrollablePanel:initializeHint(config)
    -- Hint text (optional)
    self.show_hint = config.show_hint or false
    self.hint_text = config.hint_text or "Press ENTER or ESC to return"
    self.hint_font = config.hint_font or love.graphics.getFont()
    self.hint_color = config.hint_color or Theme.PANEL.HINT_COLOR
end

---Initializes section formatting
---@param config table Configuration options
function ScrollablePanel:initializeSections(config)
    -- Section formatting (optional)
    self.sections = config.sections or nil
    self.section_font = config.section_font or love.graphics.getFont()
    self.section_color = config.section_color or Theme.PANEL.SECTION_COLOR
    self.section_spacing = config.section_spacing or
        0.8 -- Spacing after sections as a multiple of line height

    -- Highlight formatting (optional)
    self.highlight_color = config.highlight_color or Theme.PANEL.HIGHLIGHT_COLOR
end

---Draws the scrollable panel
function ScrollablePanel:draw()
    -- Draw panel background
    love.graphics.setColor(self.panel_color)
    love.graphics.rectangle("fill",
        self.x,
        self.y,
        self.width,
        self.height,
        self.corner_radius, self.corner_radius)

    -- Draw header
    love.graphics.setColor(self.header_color)
    love.graphics.rectangle("fill",
        self.x,
        self.y,
        self.width,
        self.header_height,
        self.corner_radius, self.corner_radius)

    -- Draw title
    love.graphics.setFont(self.title_font)
    love.graphics.setColor(self.title_color)
    local title_width = self.title_font:getWidth(self.title)
    love.graphics.print(self.title,
        self.x + (self.width - title_width) / 2,
        self.y + (self.header_height - self.title_font:getHeight()) / 2)

    -- Content area dimensions
    local content_start_y = self.y + self.header_height + 20
    local content_end_y = self.y + self.height - (self.show_button and 80 or 20)
    local content_area_height = content_end_y - content_start_y

    -- Set up scissor to create scrollable area
    love.graphics.setScissor(self.x, content_start_y, self.width, content_area_height)

    -- Draw content
    local content_height
    if self.sections then
        content_height = self:drawSectionedContent(content_start_y, content_end_y)
    else
        content_height = self:drawRegularContent(content_start_y, content_end_y)
    end

    -- Reset scissor
    love.graphics.setScissor()

    -- Calculate max scroll position
    local max_scroll = math.max(0, content_height - content_area_height)
    self.scroll_position = math.min(self.scroll_position, max_scroll)

    -- Draw scroll indicators if content is scrollable
    if max_scroll > 0 then
        self:drawScrollIndicators(content_start_y, content_area_height, max_scroll)
    end

    -- Draw button if enabled
    if self.show_button then
        self:drawButton()
    end

    -- Draw hint if enabled
    if self.show_hint then
        self:drawHint()
    end
end

---Draws regular content (simple list of text)
---@param content_start_y number The Y position where content starts
---@param content_end_y number The Y position where content ends
---@return number The total height of the content
function ScrollablePanel:drawRegularContent(content_start_y, content_end_y)
    love.graphics.setFont(self.content_font)
    love.graphics.setColor(self.content_color)

    local content_y = content_start_y - self.scroll_position
    local total_content_height = #self.content * self.line_height

    for i, line in ipairs(self.content) do
        local y_pos = content_y + (i - 1) * self.line_height

        -- Only draw lines that are visible in the viewport
        if y_pos + self.line_height >= content_start_y and y_pos <= content_end_y then
            -- Check if this is a line with a highlight (format: {text = "text", highlight = true})
            if type(line) == "table" and line.text then
                if line.highlight then
                    love.graphics.setColor(self.highlight_color)
                else
                    love.graphics.setColor(self.content_color)
                end
                love.graphics.print(line.text, self.x + self.content_padding, y_pos)
            else
                -- Check if line contains a colon for key:value highlighting
                local colon_pos = string.find(line, ":")
                if colon_pos then
                    -- Draw the key part in highlight color
                    love.graphics.setColor(self.highlight_color)
                    local key_part = string.sub(line, 1, colon_pos)
                    love.graphics.print(key_part, self.x + self.content_padding, y_pos)

                    -- Draw the value part in regular color
                    love.graphics.setColor(self.content_color)
                    local value_part = string.sub(line, colon_pos + 1)
                    local key_width = self.content_font:getWidth(key_part)
                    love.graphics.print(value_part, self.x + self.content_padding + key_width, y_pos)
                else
                    -- Regular line
                    love.graphics.setColor(self.content_color)
                    love.graphics.print(line, self.x + self.content_padding, y_pos)
                end
            end
        end
    end

    return total_content_height
end

---Draws sectioned content (content organized in sections)
---@param content_start_y number The Y position where content starts
---@param content_end_y number The Y position where content ends
---@return number The total height of the content
function ScrollablePanel:drawSectionedContent(content_start_y, content_end_y)
    local content_y = content_start_y - self.scroll_position
    local total_content_height = 0

    -- Calculate total content height first
    for _, section in ipairs(self.sections) do
        total_content_height = total_content_height + self.line_height * 1.2                  -- Section title
        total_content_height = total_content_height + #section.content * self.line_height     -- Content lines
        total_content_height = total_content_height + self.line_height * self.section_spacing -- Spacing after section
    end

    -- Draw each section
    for _, section in ipairs(self.sections) do
        -- Only draw if this section would be visible
        if content_y + self.line_height * 2 >= content_start_y and content_y <= content_end_y then
            -- Section title
            love.graphics.setFont(self.section_font)
            love.graphics.setColor(self.section_color)
            love.graphics.print(section.title, self.x + self.content_padding, content_y)
        end

        content_y = content_y + self.line_height * 1.2

        -- Section content
        love.graphics.setFont(self.content_font)
        for _, line in ipairs(section.content) do
            -- Only draw if this line would be visible
            if content_y + self.line_height >= content_start_y and content_y <= content_end_y then
                love.graphics.setColor(self.content_color)
                love.graphics.print(line, self.x + self.content_padding, content_y)
            end
            content_y = content_y + self.line_height
        end

        -- Add spacing after section
        content_y = content_y + self.line_height * self.section_spacing
    end

    return total_content_height
end

---Draws scroll indicators
---@param content_start_y number The Y position where content starts
---@param content_area_height number The height of the content area
---@param max_scroll number The maximum scroll position
function ScrollablePanel:drawScrollIndicators(content_start_y, content_area_height, max_scroll)
    -- Draw scroll bar background
    love.graphics.setColor(0.3, 0.3, 0.3, 0.5)
    love.graphics.rectangle("fill",
        self.x + self.width - 20,
        content_start_y,
        10,
        content_area_height)

    -- Draw scroll bar handle
    local ratio = content_area_height / (content_area_height + max_scroll)
    local handle_height = math.max(30, content_area_height * ratio)
    local scroll_ratio = self.scroll_position / max_scroll
    local handle_position = content_start_y + scroll_ratio * (content_area_height - handle_height)

    love.graphics.setColor(0.7, 0.7, 0.7, 0.8)
    love.graphics.rectangle("fill",
        self.x + self.width - 20,
        handle_position,
        10,
        handle_height)

    -- Draw scroll hint
    love.graphics.setFont(self.hint_font)
    love.graphics.setColor(self.hint_color)
    local scroll_hint = "Use UP/DOWN to scroll"
    local scroll_hint_width = self.hint_font:getWidth(scroll_hint)
    love.graphics.print(scroll_hint,
        self.x + (self.width - scroll_hint_width) / 2,
        content_start_y - 20)
end

---Draws the button
function ScrollablePanel:drawButton()
    -- Calculate button position
    local button_x = self.x + (self.width - self.button_width) / 2
    local button_y = self.y + self.height - self.button_height - self.button_margin

    -- Update button position and dimensions
    if self.button then
        self.button:setPosition(button_x, button_y)
        self.button:setDimensions(self.button_width, self.button_height)
        self.button:draw()
    else
        -- Fallback to drawing the button directly if button object doesn't exist
        -- Button background
        love.graphics.setColor(self.button_bg_color)
        love.graphics.rectangle("fill",
            button_x,
            button_y,
            self.button_width,
            self.button_height,
            8, 8) -- Rounded corners

        -- Button border
        love.graphics.setColor(self.button_color)
        love.graphics.rectangle("line",
            button_x,
            button_y,
            self.button_width,
            self.button_height,
            8, 8) -- Rounded corners

        -- Button text
        love.graphics.setFont(self.button_font)
        love.graphics.setColor(self.button_color)
        local text_width = self.button_font:getWidth(self.button_text)
        love.graphics.print(self.button_text,
            button_x + (self.button_width - text_width) / 2,
            button_y + (self.button_height - self.button_font:getHeight()) / 2)
    end
end

---Draws the hint text
function ScrollablePanel:drawHint()
    love.graphics.setFont(self.hint_font)
    love.graphics.setColor(self.hint_color)
    local hint_width = self.hint_font:getWidth(self.hint_text)
    love.graphics.print(self.hint_text,
        self.x + (self.width - hint_width) / 2,
        self.y + self.height - 15)
end

---Handles key press events
---@param key string The key that was pressed
---@return boolean Whether the key was handled
function ScrollablePanel:keypressed(key)
    if key == "up" then
        self.scroll_position = math.max(0, self.scroll_position - 50)
        return true
    elseif key == "down" then
        self.scroll_position = self.scroll_position + 50
        return true
    elseif (key == "return" or key == "escape" or key == "space") and self.show_button and self.button_action then
        self.button_action()
        return true
    end

    return false
end

---Updates the scroll position based on continuous key presses
---@param dt number Delta time
function ScrollablePanel:update(dt)
    -- Handle continuous scrolling
    if love.keyboard.isDown("up") then
        self.scroll_position = math.max(0, self.scroll_position - self.scroll_speed * dt)
    elseif love.keyboard.isDown("down") then
        self.scroll_position = self.scroll_position + self.scroll_speed * dt
    end

    -- Update button if present
    if self.show_button and self.button then
        self.button:update(dt)
    end
end

---Checks if a point is inside the button
---@param x number The x coordinate
---@param y number The y coordinate
---@return boolean Whether the point is inside the button
function ScrollablePanel:isPointInButton(x, y)
    if not self.show_button then
        return false
    end

    local button_x = self.x + (self.width - self.button_width) / 2
    local button_y = self.y + self.height - self.button_height - self.button_margin

    return x >= button_x and x <= button_x + self.button_width and
        y >= button_y and y <= button_y + self.button_height
end

---Handles mouse press events
---@param x number The x coordinate
---@param y number The y coordinate
---@param button number The button that was pressed
---@return boolean Whether the mouse press was handled
function ScrollablePanel:mousepressed(x, y, button)
    -- Check if the button was clicked
    if self.show_button and self.button and button == 1 then
        if self.button:mousepressed(x, y, button) then
            return true
        end
    elseif button == 1 and self:isPointInButton(x, y) and self.button_action then
        self.button_action()
        return true
    end

    return false
end

---Resets the scroll position
function ScrollablePanel:resetScroll()
    self.scroll_position = 0
end

return ScrollablePanel
