function love.conf(t)
    t.title = "Mars Lander"
    t.version = "11.4"
    t.window.width = 800
    t.window.height = 600
    t.window.resizable = false
    
    -- Disable unused modules to save memory
    t.modules.joystick = false
    t.modules.physics = true
    t.modules.video = false
    
    -- Enable console output for debugging
    t.console = true
end 