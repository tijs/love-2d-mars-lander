-- Terrain features like rocks and ridges
local Features = {}

-- Import constants
local Constants = require("src.entities.terrain.constants")

---Generates rocky ridges for the terrain
---@param x number X coordinate
---@param y number Y coordinate
---@param is_landing_pad boolean Whether this is part of a landing pad
---@return table|nil Ridge data or nil if no ridge is generated
function Features.generateCrater(x, y, is_landing_pad)
    -- Don't generate ridges on landing pads
    if is_landing_pad then
        return nil
    end

    -- Random chance to generate a ridge (reduced for cleaner look)
    if math.random() < Constants.CRATER_CHANCE * 0.6 then
        local ridge_width = math.random(Constants.MIN_CRATER_SIZE * 2, Constants.MAX_CRATER_SIZE * 2)
        local ridge_height = math.random(8, 20) -- Taller ridges
        local ridge_x = x + math.random(-Constants.SEGMENT_WIDTH / 2, Constants.SEGMENT_WIDTH / 2)
        local ridge_y = y - ridge_height / 2

        -- Create jagged ridge points with more dramatic shape
        local ridge_points = {}
        local num_points = math.random(5, 7) -- Fewer points for cleaner look

        -- Left edge
        table.insert(ridge_points, ridge_x - ridge_width / 2)
        table.insert(ridge_points, ridge_y + ridge_height / 2)

        -- Middle jagged points with more dramatic height variation
        for i = 1, num_points - 2 do
            local t = i / (num_points - 1)
            local x_pos = ridge_x - ridge_width / 2 + t * ridge_width

            -- Create more dramatic peaks and valleys
            local height_factor = math.sin(t * math.pi) -- Creates a natural arc
            local y_offset = -ridge_height * height_factor * math.random(0.7, 1.3)

            table.insert(ridge_points, x_pos)
            table.insert(ridge_points, ridge_y + y_offset)
        end

        -- Right edge
        table.insert(ridge_points, ridge_x + ridge_width / 2)
        table.insert(ridge_points, ridge_y + ridge_height / 2)

        -- Choose a darker color for ridges to stand out
        local color_index = math.random(2, 3)

        return {
            points = ridge_points,
            color = Constants.TERRAIN_COLORS[color_index],
            highlight = Constants.TERRAIN_COLORS[5] -- Highlight color for edges
        }
    end

    return nil
end

---Generates rocks for the terrain
---@param x number X coordinate
---@param y number Y coordinate
---@param is_landing_pad boolean Whether this is part of a landing pad
---@return table|nil Rock data or nil if no rock is generated
function Features.generateRock(x, y, is_landing_pad)
    -- Don't generate rocks on landing pads
    if is_landing_pad then
        return nil
    end

    -- Random chance to generate a rock (reduced for cleaner look)
    if math.random() < Constants.ROCK_CHANCE then
        local rock_size = math.random(Constants.MIN_ROCK_SIZE, Constants.MAX_ROCK_SIZE * 1.2)
        local rock_x = x + math.random(-Constants.SEGMENT_WIDTH / 2, Constants.SEGMENT_WIDTH / 2)
        local rock_y = y - rock_size / 2

        -- Create a more angular rock shape with fewer points
        local rock_points = {}
        local num_points = math.random(4, 6) -- Fewer points for cleaner look

        -- Make rocks more angular with sharper peaks
        for j = 1, num_points do
            local angle = (j - 1) * (2 * math.pi / num_points)
            -- Add randomness to make it less circular
            angle = angle + (math.random() - 0.5) * 0.3

            -- Create more dramatic variation in radius
            local radius_variation = 0.6 + math.random() * 0.8 -- More variation
            local radius = rock_size * radius_variation

            table.insert(rock_points, rock_x + math.cos(angle) * radius)
            table.insert(rock_points, rock_y + math.sin(angle) * radius)
        end

        -- Choose a darker color for rocks to stand out
        local color_index = math.random(2, 4)

        return {
            points = rock_points,
            color = Constants.TERRAIN_COLORS[color_index],
            highlight = Constants.TERRAIN_COLORS[5]
        }
    end

    return nil
end

---Draws ridges
---@param ridges table Array of ridge data
function Features.drawCraters(ridges)
    for _, ridge in ipairs(ridges) do
        -- Draw ridge shadow for depth
        love.graphics.setColor(0, 0, 0, 0.4) -- Darker shadow
        love.graphics.polygon("fill", unpack(ridge.points))

        -- Draw ridge main body
        love.graphics.setColor(ridge.color)
        love.graphics.polygon("fill", unpack(ridge.points))

        -- Draw ridge outline with thinner line
        love.graphics.setColor(ridge.highlight[1] * 0.9, ridge.highlight[2] * 0.9, ridge.highlight[3] * 0.9, 0.8)
        love.graphics.setLineWidth(1.5)
        love.graphics.polygon("line", unpack(ridge.points))
    end
end

---Draws rocks
---@param rocks table Array of rock data
function Features.drawRocks(rocks)
    for _, rock in ipairs(rocks) do
        -- Draw rock shadow for depth
        love.graphics.setColor(0, 0, 0, 0.4) -- Darker shadow

        -- Offset shadow slightly for 3D effect
        local shadow_points = {}
        for i = 1, #rock.points do
            if i % 2 == 0 then                        -- Y coordinates
                shadow_points[i] = rock.points[i] + 2 -- Offset shadow down
            else                                      -- X coordinates
                shadow_points[i] = rock.points[i] + 1 -- Offset shadow right
            end
        end

        love.graphics.polygon("fill", unpack(shadow_points))

        -- Draw rock body
        love.graphics.setColor(rock.color)
        love.graphics.polygon("fill", unpack(rock.points))

        -- Draw rock outline with thinner line
        love.graphics.setColor(rock.highlight[1] * 0.9, rock.highlight[2] * 0.9, rock.highlight[3] * 0.9, 0.8)
        love.graphics.setLineWidth(1)
        love.graphics.polygon("line", unpack(rock.points))
    end
end

return Features
