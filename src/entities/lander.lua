-- Mars lander entity - main file that combines model and graphics
local LanderModel = require("src.entities.lander_model")
local LanderGraphics = require("src.entities.lander_graphics")

local Lander = {}
Lander.__index = Lander

-- No need to duplicate constants here, they're defined in the model

---Creates a new lander instance
---@param x number Initial x position
---@param y number Initial y position
---@return table The new lander instance
function Lander.new(x, y)
    local self = setmetatable({}, Lander)
    
    -- Create the model and graphics components
    self.model = LanderModel.new(x, y)
    self.graphics = LanderGraphics.new(self.model)
    
    return self
end

-- Forward all model methods to the model component
function Lander:update(dt, terrain)
    self.model:update(dt, terrain)
end

function Lander:activateThrust()
    self.model:activateThrust()
end

function Lander:deactivateThrust()
    self.model:deactivateThrust()
end

function Lander:rotateLeft(dt)
    self.model:rotateLeft(dt)
end

function Lander:rotateRight(dt)
    self.model:rotateRight(dt)
end

-- Forward draw method to the graphics component
function Lander:draw()
    self.graphics:draw()
end

-- Expose model properties through getters
function Lander:getPosition()
    return self.model.x, self.model.y
end

function Lander:getVelocity()
    return self.model.velocity_x, self.model.velocity_y
end

function Lander:getRotation()
    return self.model.rotation
end

function Lander:getFuel()
    return self.model.fuel
end

function Lander:isLanded()
    return self.model.landed
end

function Lander:isCrashed()
    return self.model.crashed
end

function Lander:getWidth()
    return self.model.width
end

function Lander:getHeight()
    return self.model.height
end

-- Export constants from the model
Lander.CONSTANTS = LanderModel.CONSTANTS

return Lander 