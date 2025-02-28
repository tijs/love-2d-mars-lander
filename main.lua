-- Mars Lander Game
-- A simple Mars lander game made with LÖVE2D

-- Import the scene manager and scenes
local SceneManager = require("src.scenes.scene_manager")
local MenuScene = require("src.scenes.menu_scene")
local GameScene = require("src.scenes.game_scene")
local GameOverScene = require("src.scenes.game_over_scene")
local LevelCompleteScene = require("src.scenes.level_complete_scene")
local SettingsScene = require("src.scenes.settings_scene")

-- Global fonts
fonts = {
    small = nil,
    medium = nil,
    large = nil,
    title = nil,
    huge = nil,
    title_font = nil -- New title font for the Mars Lander title
}

-- Initialize the game
function love.load()
    -- Set random seed
    math.randomseed(os.time())

    -- Load fonts
    fonts.small = love.graphics.newFont(12)
    fonts.medium = love.graphics.newFont(16)
    fonts.large = love.graphics.newFont(20)
    fonts.title = love.graphics.newFont(24)
    fonts.huge = love.graphics.newFont(32)

    -- Load the custom title font
    fonts.title_font = love.graphics.newFont("assets/fonts/PressStart2P-Regular.ttf", 32)

    -- Set default font
    love.graphics.setFont(fonts.small)

    -- Register scenes
    SceneManager.register("menu", MenuScene.new())
    SceneManager.register("game", GameScene.new())
    SceneManager.register("game_over", GameOverScene.new())
    SceneManager.register("level_complete", LevelCompleteScene.new())
    SceneManager.register("settings", SettingsScene.new())

    -- Start with the menu scene
    SceneManager.changeScene("menu")
end

-- Update game state
function love.update(dt)
    -- Update the current scene
    SceneManager.update(dt)

    -- Update continuous key presses
    SceneManager.updateKeyPresses()
end

-- Draw the game
function love.draw()
    -- Draw the current scene
    SceneManager.draw()

    -- Draw FPS counter in debug mode
    if love.keyboard.isDown("f1") then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("FPS: " .. love.timer.getFPS(), love.graphics.getWidth() - 100, 10)
    end
end

-- Handle key press events
function love.keypressed(key)
    -- Pass key press to scene manager
    SceneManager.keypressed(key)

    -- Global key handling
    if key == "f12" then
        love.event.quit()
    end
end

-- Handle key release events
function love.keyreleased(key)
    -- Pass key release to scene manager
    SceneManager.keyreleased(key)
end
