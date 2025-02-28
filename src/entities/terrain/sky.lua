-- Sky and atmosphere effects for the Martian terrain
local Sky = {}

-- Import constants
local Constants = require("src.entities.terrain.constants")

---Initializes dust particles for atmospheric effect
---@param terrain table The terrain instance
---@return table Array of dust particles
function Sky.initDustParticles(terrain)
    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()
    local dust_particles = {}

    for i = 1, Constants.DUST_PARTICLES do
        local particle = {
            x = math.random(0, screen_width),
            y = math.random(0, screen_height),
            size = math.random(Constants.DUST_SIZE_MIN, Constants.DUST_SIZE_MAX) / 10,
            speed = math.random(Constants.DUST_SPEED_MIN, Constants.DUST_SPEED_MAX) / 10,
            alpha = math.random(10, 50) / 100,
            color = {
                Constants.TERRAIN_COLORS[1][1] + math.random(-10, 10) / 100,
                Constants.TERRAIN_COLORS[1][2] + math.random(-10, 10) / 100,
                Constants.TERRAIN_COLORS[1][3] + math.random(-10, 10) / 100
            }
        }
        table.insert(dust_particles, particle)
    end

    return dust_particles
end

---Updates dust particles
---@param dust_particles table Array of dust particles
---@param dt number Delta time
---@param getHeightAt function Function to get terrain height at a given x coordinate
function Sky.updateDustParticles(dust_particles, dt, getHeightAt)
    local screen_width = love.graphics.getWidth()

    for i, particle in ipairs(dust_particles) do
        -- Move particles horizontally (simulating wind)
        particle.x = particle.x + particle.speed * dt

        -- Reset particles that go off-screen
        if particle.x > screen_width then
            particle.x = 0
            particle.y = math.random(0, getHeightAt(0) + 100)
            particle.alpha = math.random(10, 50) / 100
        end
    end
end

---Draws the sky gradient
---@param screen_width number The screen width
---@param screen_height number The screen height
---@param alpha number Optional transparency value (0-1, default 1)
function Sky.drawSkyGradient(screen_width, screen_height, alpha)
    -- Set default alpha if not provided
    alpha = alpha or 1.0

    -- Draw sky gradient from top to horizon
    local gradient_steps = 20
    local step_height = screen_height / gradient_steps

    for i = 0, gradient_steps - 1 do
        local t = i / gradient_steps

        -- Interpolate between sky colors
        local r, g, b
        if t < 0.5 then
            -- Upper sky to mid sky
            local factor = t * 2
            r = Constants.SKY_COLORS[3][1] * (1 - factor) + Constants.SKY_COLORS[2][1] * factor
            g = Constants.SKY_COLORS[3][2] * (1 - factor) + Constants.SKY_COLORS[2][2] * factor
            b = Constants.SKY_COLORS[3][3] * (1 - factor) + Constants.SKY_COLORS[2][3] * factor
        else
            -- Mid sky to horizon
            local factor = (t - 0.5) * 2
            r = Constants.SKY_COLORS[2][1] * (1 - factor) + Constants.SKY_COLORS[1][1] * factor
            g = Constants.SKY_COLORS[2][2] * (1 - factor) + Constants.SKY_COLORS[1][2] * factor
            b = Constants.SKY_COLORS[2][3] * (1 - factor) + Constants.SKY_COLORS[1][3] * factor
        end

        -- Apply the alpha value
        love.graphics.setColor(r, g, b, alpha * (0.5 + t * 0.5)) -- More transparent at top, more opaque at horizon

        local y1 = i * step_height
        local y2 = (i + 1) * step_height

        love.graphics.rectangle("fill", 0, y1, screen_width, step_height)
    end
end

---Draws dust particles
---@param dust_particles table Array of dust particles
function Sky.drawDustParticles(dust_particles)
    for _, particle in ipairs(dust_particles) do
        love.graphics.setColor(particle.color[1], particle.color[2], particle.color[3], particle.alpha)
        love.graphics.circle("fill", particle.x, particle.y, particle.size)
    end
end

return Sky
