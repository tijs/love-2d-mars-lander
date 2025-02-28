-- Scene Manager - Handles transitions between game scenes
local SceneManager = {}

-- The currently active scene
local current_scene = nil

-- Table of all registered scenes
local scenes = {}

---Registers a scene with the manager
---@param name string The name of the scene
---@param scene table The scene object (must implement load, update, draw, keypressed, keyreleased)
function SceneManager.register(name, scene)
    scenes[name] = scene
end

---Changes to a different scene
---@param name string The name of the scene to change to
---@param ... any Additional parameters to pass to the scene's load method
function SceneManager.changeScene(name, ...)
    if scenes[name] then
        -- Unload current scene if it exists
        if current_scene and current_scene.unload then
            current_scene:unload()
        end

        -- Set new scene
        current_scene = scenes[name]

        -- Load new scene
        if current_scene.load then
            current_scene:load(...)
        end
    else
        error("Scene '" .. name .. "' does not exist")
    end
end

---Gets the current scene
---@return table The current scene
function SceneManager.getCurrentScene()
    return current_scene
end

---Updates the current scene
---@param dt number Delta time
function SceneManager.update(dt)
    if current_scene and current_scene.update then
        current_scene:update(dt)
    end
end

---Draws the current scene
function SceneManager.draw()
    if current_scene and current_scene.draw then
        current_scene:draw()
    end
end

---Handles key press events
---@param key string The key that was pressed
function SceneManager.keypressed(key)
    if current_scene and current_scene.keypressed then
        current_scene:keypressed(key)
    end
end

---Handles key release events
---@param key string The key that was released
function SceneManager.keyreleased(key)
    if current_scene and current_scene.keyreleased then
        current_scene:keyreleased(key)
    end
end

---Handles continuous key presses
function SceneManager.updateKeyPresses()
    if current_scene and current_scene.updateKeyPresses then
        current_scene:updateKeyPresses()
    end
end

---Handles mouse press events
---@param x number The x coordinate
---@param y number The y coordinate
---@param button number The button that was pressed
function SceneManager.mousepressed(x, y, button)
    if current_scene and current_scene.mousepressed then
        current_scene:mousepressed(x, y, button)
    end
end

return SceneManager
