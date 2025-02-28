-- Landing pad for the Martian terrain
local LandingPad = {}

-- Initialize variables for pulsating effect
local pulse_speed = 2 -- Speed of pulsation
local pulse_min = 0.4 -- Minimum brightness
local pulse_max = 1.0 -- Maximum brightness

---Draws the landing pad
---@param landing_pad_start number Start X coordinate of the landing pad
---@param landing_pad_end number End X coordinate of the landing pad
---@param landing_pad_height number Y coordinate of the landing pad
function LandingPad.draw(landing_pad_start, landing_pad_end, landing_pad_height)
    if landing_pad_start and landing_pad_end then
        local pad_y = landing_pad_height

        -- Draw landing pad base/foundation
        love.graphics.setColor(0.15, 0.15, 0.15)
        love.graphics.rectangle("fill",
            landing_pad_start,
            pad_y,
            landing_pad_end - landing_pad_start,
            6
        )

        -- Draw the landing pad platform
        love.graphics.setColor(0.2, 0.6, 0.8) -- Blue-ish color for landing pad
        love.graphics.rectangle("fill",
            landing_pad_start,
            pad_y - 2,
            landing_pad_end - landing_pad_start,
            4
        )

        -- Draw landing pad glow effect
        love.graphics.setColor(0.2, 0.6, 0.8, 0.2)
        love.graphics.rectangle("fill",
            landing_pad_start - 5,
            pad_y - 10,
            landing_pad_end - landing_pad_start + 10,
            20
        )

        -- Calculate pulsating effect for marker lights
        local pulse_factor = pulse_min + (pulse_max - pulse_min) *
            (0.5 + 0.5 * math.sin(love.timer.getTime() * pulse_speed))

        -- Draw pulsating landing markers
        love.graphics.setColor(1 * pulse_factor, 0.8 * pulse_factor, 0) -- Pulsating amber color

        -- Left marker
        love.graphics.rectangle("fill",
            landing_pad_start + 5,
            pad_y - 6,
            5,
            8
        )

        -- Right marker
        love.graphics.rectangle("fill",
            landing_pad_end - 10,
            pad_y - 6,
            5,
            8
        )

        -- Add a subtle glow around the markers that also pulsates
        love.graphics.setColor(1, 0.8, 0, 0.3 * pulse_factor)

        -- Left marker glow
        love.graphics.circle("fill",
            landing_pad_start + 7.5,
            pad_y - 2,
            8)

        -- Right marker glow
        love.graphics.circle("fill",
            landing_pad_end - 7.5,
            pad_y - 2,
            8)

        -- Draw landing pad markings
        local pad_width = landing_pad_end - landing_pad_start
        local stripe_width = pad_width / 6

        for i = 0, 2 do
            love.graphics.setColor(0.1, 0.1, 0.1) -- Dark gray/black
            love.graphics.rectangle("fill",
                landing_pad_start + i * stripe_width * 2,
                pad_y - 2,
                stripe_width,
                4
            )
        end

        -- Removed "LAND HERE" text as it's clear where to land from the colors
    end
end

return LandingPad
