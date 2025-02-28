-- Theme configuration for Mars Lander
-- Centralizes all colors and styling used throughout the game

local Theme = {}

-- Main color palette
Theme.COLORS = {
    -- Mars themed colors
    MARS_RED = { 0.9, 0.3, 0.2, 1 },               -- Bright Mars red (title color)
    MARS_RED_TRANSPARENT = { 0.9, 0.3, 0.2, 0.9 }, -- Semi-transparent Mars red (header background)
    MARS_ORANGE = { 0.9, 0.5, 0.3, 1 },            -- Light Mars orange (section titles)
    MARS_SURFACE = { 0.7, 0.3, 0.2, 1 },           -- Darker Mars red (surface)
    MARS_SKY = { 0.1, 0.05, 0.1, 1 },              -- Dark purplish (Mars sky)

    -- UI colors
    GOLD = { 1, 0.8, 0, 1 },              -- Gold (selected items, highlights)
    WHITE = { 1, 1, 1, 1 },               -- Pure white
    WHITE_TRANSPARENT = { 1, 1, 1, 0.8 }, -- Semi-transparent white (menu items)
    BLACK = { 0, 0, 0, 1 },               -- Pure black
    BLACK_TRANSPARENT = { 0, 0, 0, 0.8 }, -- Semi-transparent black (panel backgrounds)
    DARK_GRAY = { 0.2, 0.2, 0.2, 0.9 },   -- Dark gray (button backgrounds)
    LIGHT_GRAY = { 0.7, 0.7, 0.7, 0.7 },  -- Light gray (hints, footer text)

    -- Panel colors
    PANEL_BG = { 0.1, 0.1, 0.15, 0.9 }, -- Dark blue-gray with transparency (panel background)
}

-- Menu styling
Theme.MENU = {
    TITLE_COLOR = Theme.COLORS.MARS_RED,
    ITEM_COLOR = Theme.COLORS.WHITE_TRANSPARENT,
    SELECTED_ITEM_COLOR = Theme.COLORS.GOLD,
    ITEM_SPACING = 40,
    START_Y = 300,
}

-- Panel styling
Theme.PANEL = {
    HEADER_COLOR = Theme.COLORS.MARS_RED_TRANSPARENT,
    BACKGROUND_COLOR = Theme.COLORS.PANEL_BG,
    TEXT_COLOR = Theme.COLORS.WHITE_TRANSPARENT,
    SECTION_COLOR = Theme.COLORS.MARS_ORANGE,
    HIGHLIGHT_COLOR = Theme.COLORS.GOLD,
    HINT_COLOR = Theme.COLORS.LIGHT_GRAY,
    CORNER_RADIUS = 10,
}

-- Button styling
Theme.BUTTON = {
    TEXT_COLOR = Theme.COLORS.GOLD,
    BACKGROUND_COLOR = Theme.COLORS.DARK_GRAY,
    BORDER_COLOR = Theme.COLORS.GOLD,
    CORNER_RADIUS = 8,
    PULSE_SPEED = 2,
    PULSE_AMOUNT = 0.1,
}

-- Game environment
Theme.ENVIRONMENT = {
    MARS_SURFACE_COLOR = Theme.COLORS.MARS_SURFACE,
    MARS_SKY_COLOR = Theme.COLORS.MARS_SKY,
}

-- Lander colors
Theme.LANDER = {
    BODY_COLOR = { 0.9, 0.9, 0.9 },
    LEGS_COLOR = { 0.7, 0.7, 0.7 },
    THRUSTER_COLOR = { 1, 0.5, 0, 0.8 },
}

return Theme
