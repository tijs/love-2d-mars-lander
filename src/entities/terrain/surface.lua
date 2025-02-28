-- Terrain surface generation and rendering
local Surface = {}

-- Import constants
local Constants = require("src.entities.terrain.constants")

-- Store random detail elements to ensure consistency between frames
local rock_formations = {}
local color_variations = {}
local initialized = false

---Generates terrain points
---@param screen_width number The screen width
---@return table Generated terrain data
function Surface.generate(screen_width)
    local points = {}
    local segments = {}
    local landing_pad_start = nil
    local landing_pad_end = nil
    local landing_pad_height = nil

    local num_points = math.ceil(screen_width / Constants.SEGMENT_WIDTH) + 1

    -- Choose a random position for the landing pad
    local landing_pad_segments = math.floor(Constants.LANDING_PAD_WIDTH / Constants.SEGMENT_WIDTH)
    local landing_pad_start_index = math.random(2, num_points - landing_pad_segments - 1)
    local landing_pad_end_index = landing_pad_start_index + landing_pad_segments

    -- Generate height for each point with improved terrain variation
    local prev_height = math.random(Constants.MIN_HEIGHT, Constants.MAX_HEIGHT)

    -- Track the last few heights to create more natural terrain
    local height_history = { prev_height, prev_height, prev_height }

    -- Add more mountain peaks for dramatic landscape
    local mountain_peaks = {}
    local num_mountains = math.random(4, 7) -- Increased number of mountains
    for i = 1, num_mountains do
        local peak_index = math.random(1, num_points)
        -- Avoid placing mountains on or near landing pads
        while peak_index >= landing_pad_start_index - 3 and peak_index <= landing_pad_end_index + 3 do
            peak_index = math.random(1, num_points)
        end
        mountain_peaks[peak_index] = true
    end

    for i = 1, num_points do
        local x = (i - 1) * Constants.SEGMENT_WIDTH
        local y

        -- If this is part of the landing pad, make it flat
        if i >= landing_pad_start_index and i <= landing_pad_end_index then
            -- If this is the first point of the landing pad, set a random height
            if i == landing_pad_start_index then
                -- Make sure landing pad is in a valley, not too high
                y = math.random(Constants.MIN_HEIGHT + 50, Constants.MAX_HEIGHT - 50)
                prev_height = y
                height_history = { prev_height, prev_height, prev_height }
            else
                -- Otherwise use the same height as the previous point
                y = points[i - 1].y
            end

            -- Store landing pad coordinates
            if i == landing_pad_start_index then
                landing_pad_start = x
                landing_pad_height = y
            elseif i == landing_pad_end_index then
                landing_pad_end = x
            end
        else
            -- Check if this is a mountain peak
            if mountain_peaks[i] then
                -- Create a taller mountain peak with more dramatic height
                local peak_height = math.random(120, 200) -- Increased height for more dramatic mountains
                y = math.max(Constants.MIN_HEIGHT, prev_height - peak_height)
            else
                -- Generate a more natural terrain with smoother transitions
                -- Use the average of the last few heights plus a random change
                local avg_height = (height_history[1] + height_history[2] + height_history[3]) / 3

                -- Approaching a mountain or leaving a mountain
                local near_mountain = false
                for j = -2, 2 do
                    if mountain_peaks[i + j] then
                        near_mountain = true
                        break
                    end
                end

                local height_change
                if near_mountain then
                    -- Steeper slopes near mountains (increased range)
                    height_change = math.random(-50, 50) -- More dramatic height changes
                else
                    -- Normal terrain
                    height_change = math.random(-15, 15)
                end

                -- Occasionally add sharp crags
                if math.random() < 0.1 and not near_mountain then
                    height_change = height_change * 2.5 -- More dramatic crags
                end

                -- Ensure we stay within bounds
                local new_height = avg_height + height_change
                if new_height < Constants.MIN_HEIGHT then
                    new_height = Constants.MIN_HEIGHT
                elseif new_height > Constants.MAX_HEIGHT then
                    new_height = Constants.MAX_HEIGHT
                end

                y = new_height
            end

            prev_height = y
            table.remove(height_history, 1)
            table.insert(height_history, y)
        end

        table.insert(points, { x = x, y = y })
    end

    -- Create segments from points
    segments = Surface.createSegments(points, landing_pad_start, landing_pad_end)

    -- Reset detail elements when generating new terrain
    rock_formations = {}
    color_variations = {}
    initialized = false

    return {
        points = points,
        segments = segments,
        landing_pad_start = landing_pad_start,
        landing_pad_end = landing_pad_end,
        landing_pad_height = landing_pad_height
    }
end

---Creates line segments from the terrain points
---@param points table Array of terrain points
---@param landing_pad_start number Start X coordinate of the landing pad
---@param landing_pad_end number End X coordinate of the landing pad
---@return table Array of line segments
function Surface.createSegments(points, landing_pad_start, landing_pad_end)
    local segments = {}

    for i = 1, #points - 1 do
        local x1, y1 = points[i].x, points[i].y
        local x2, y2 = points[i + 1].x, points[i + 1].y

        -- Check if this segment is part of the landing pad
        local is_landing_pad = false
        if landing_pad_start and landing_pad_end then
            if x1 >= landing_pad_start and x2 <= landing_pad_end then
                is_landing_pad = true
            end
        end

        -- Calculate slope for identifying steep segments
        local slope = math.abs((y2 - y1) / (x2 - x1))
        local is_steep = slope > 0.8 -- Identify steep segments

        -- Create segment
        local segment = {
            x1 = x1,
            y1 = y1,
            x2 = x2,
            y2 = y2,
            is_landing_pad = is_landing_pad,
            is_steep = is_steep
        }

        table.insert(segments, segment)
    end

    return segments
end

-- Initialize detail elements once to ensure consistency between frames
function Surface.initializeDetailElements(segments)
    if initialized then return end

    -- Initialize color variations for gradient steps
    for i = 1, #segments do
        color_variations[i] = {}
        for step = 0, 19 do            -- Increased gradient steps for smoother transition
            color_variations[i][step] = {}
            for color_idx = 1, 4 do    -- 4 color indices
                local variation = 0.03 -- Reduced variation for cleaner look
                color_variations[i][step][color_idx] = {
                    math.random() * variation * 2 - variation,
                    math.random() * variation * 2 - variation,
                    math.random() * variation * 2 - variation
                }
            end
        end
    end

    -- Initialize rock formations only on steep segments
    for i, segment in ipairs(segments) do
        if not segment.is_landing_pad and segment.is_steep and math.random() < 0.4 then
            local height_diff = math.abs(segment.y2 - segment.y1)

            -- Only add formations to steep segments
            local base_x = segment.x1 + (segment.x2 - segment.x1) * math.random(0.3, 0.7)
            local base_y = segment.y1 + (segment.y2 - segment.y1) * math.random(0.3, 0.7)
            local spire_height = math.random(25, 45) + height_diff * 0.7 -- Taller spires
            local num_points = math.random(5, 8)                         -- More points for more detail
            local spire_width = math.random(8, 18)                       -- Wider spires

            local spire_points = {}

            -- Base points
            table.insert(spire_points, base_x - spire_width / 2)
            table.insert(spire_points, base_y)

            -- Middle jagged points
            for j = 1, num_points - 2 do
                local t = j / (num_points - 1)
                local x_offset = (math.random() - 0.5) * spire_width
                local y_offset = -t * spire_height

                table.insert(spire_points, base_x + x_offset)
                table.insert(spire_points, base_y + y_offset)
            end

            -- Top point
            table.insert(spire_points, base_x)
            table.insert(spire_points, base_y - spire_height)

            -- Right base point
            table.insert(spire_points, base_x + spire_width / 2)
            table.insert(spire_points, base_y)

            rock_formations[i] = spire_points
        end
    end

    initialized = true
end

---Draws the terrain surface
---@param segments table Array of line segments
function Surface.draw(segments)
    -- Initialize detail elements if not already done
    Surface.initializeDetailElements(segments)

    -- Draw the terrain fill with an enhanced gradient effect
    for i, segment in ipairs(segments) do
        -- Fill the area below the terrain with a smooth gradient
        local y_bottom = love.graphics.getHeight()
        local gradient_steps = 20 -- More steps for smoother gradient
        local step_height = (y_bottom - segment.y1) / gradient_steps

        for step = 0, gradient_steps - 1 do
            -- Calculate color based on depth using a smoother transition
            local t = step / gradient_steps
            local color_index

            -- Smoother color transition
            if t < 0.15 then
                -- Surface layer
                color_index = 1
            elseif t < 0.4 then
                -- Middle layer
                color_index = 2
            elseif t < 0.7 then
                -- Deep layer
                color_index = 3
            else
                -- Very deep layer
                color_index = 4
            end

            local color = Constants.TERRAIN_COLORS[color_index]

            -- Use pre-calculated color variation with reduced randomness
            local var = color_variations[i][math.min(step, 19)][color_index]
            local r = math.max(0, math.min(1, color[1] * (1 + var[1])))
            local g = math.max(0, math.min(1, color[2] * (1 + var[2])))
            local b = math.max(0, math.min(1, color[3] * (1 + var[3])))

            love.graphics.setColor(r, g, b)

            local y1 = segment.y1 + step * step_height
            local y2 = segment.y1 + (step + 1) * step_height

            love.graphics.polygon("fill",
                segment.x1, y1,
                segment.x2, y1,
                segment.x2, y2,
                segment.x1, y2
            )
        end
    end

    -- Draw rock formations on steep segments
    Surface.drawRockFormations(segments)

    -- Draw the terrain outline last for a clean edge
    for _, segment in ipairs(segments) do
        love.graphics.setColor(Constants.TERRAIN_COLORS[1][1] * 0.8,
            Constants.TERRAIN_COLORS[1][2] * 0.8,
            Constants.TERRAIN_COLORS[1][3] * 0.8)
        love.graphics.setLineWidth(2)
        love.graphics.line(segment.x1, segment.y1, segment.x2, segment.y2)
    end
end

---Draws jagged rock formations and spires
---@param segments table Array of line segments
function Surface.drawRockFormations(segments)
    for i, segment in ipairs(segments) do
        -- Skip landing pad segments
        if not segment.is_landing_pad and rock_formations[i] then
            -- Draw pre-calculated rock formation
            local spire_points = rock_formations[i]

            -- Draw the spire with gradient fill
            local base_y = segment.y1
            local top_y = base_y - 40 -- Approximate height

            -- Draw with gradient
            local gradient_steps = 8
            for step = 0, gradient_steps - 1 do
                local t = step / gradient_steps
                local color_idx = math.min(4, math.max(1, math.floor(t * 3) + 1))
                local color = Constants.TERRAIN_COLORS[color_idx]

                -- Darken as we go deeper
                local darkness = 1.0 - t * 0.3
                love.graphics.setColor(
                    color[1] * darkness,
                    color[2] * darkness,
                    color[3] * darkness
                )

                -- Draw a portion of the spire
                love.graphics.polygon("fill", unpack(spire_points))
            end

            -- Draw outline
            love.graphics.setColor(Constants.TERRAIN_COLORS[4][1] * 0.8,
                Constants.TERRAIN_COLORS[4][2] * 0.8,
                Constants.TERRAIN_COLORS[4][3] * 0.8)
            love.graphics.setLineWidth(1)
            love.graphics.polygon("line", unpack(spire_points))
        end
    end
end

return Surface
