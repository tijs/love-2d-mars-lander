-- Constants for terrain generation and rendering
local Constants = {}

-- Terrain generation constants
Constants.MIN_HEIGHT = 330       -- Even lower minimum height for deeper valleys
Constants.MAX_HEIGHT = 580       -- Higher maximum height for taller mountains
Constants.SEGMENT_WIDTH = 18     -- Slightly wider segments for cleaner look
Constants.LANDING_PAD_WIDTH = 80 -- Keep landing pad width

-- Enhanced Mars terrain colors with smoother gradient
Constants.TERRAIN_COLORS = {
    { 0.88, 0.45, 0.30 }, -- Light reddish-orange (surface)
    { 0.78, 0.38, 0.24 }, -- Medium reddish-brown
    { 0.68, 0.32, 0.18 }, -- Dark reddish-brown
    { 0.58, 0.26, 0.14 }, -- Very dark reddish-brown (deep terrain)
    { 0.92, 0.52, 0.32 }  -- Light orange-red (highlights)
}

-- Sky colors for atmospheric gradient
Constants.SKY_COLORS = {
    { 0.82, 0.42, 0.32 }, -- Light orange-red (horizon)
    { 0.62, 0.28, 0.22 }, -- Medium red (mid sky)
    { 0.42, 0.18, 0.18 }  -- Dark red (upper sky)
}

-- Ridge constants (formerly crater constants)
Constants.CRATER_CHANCE = 0.20      -- Reduced chance for cleaner look
Constants.MIN_CRATER_SIZE = 10      -- Larger minimum size for more pronounced ridges
Constants.MAX_CRATER_SIZE = 30      -- Larger max size for more dramatic ridges
Constants.CRATER_DEPTH_FACTOR = 0.4 -- Deeper features for more dramatic landscape

-- Rock constants
Constants.ROCK_CHANCE = 0.15 -- Reduced chance for cleaner look
Constants.MIN_ROCK_SIZE = 5  -- Larger minimum rock size
Constants.MAX_ROCK_SIZE = 15 -- Larger maximum rock size

-- Dust constants
Constants.DUST_PARTICLES = 80 -- Fewer dust particles for cleaner look
Constants.DUST_SIZE_MIN = 1
Constants.DUST_SIZE_MAX = 3
Constants.DUST_SPEED_MIN = 10
Constants.DUST_SPEED_MAX = 30

return Constants
