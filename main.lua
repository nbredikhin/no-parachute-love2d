local ScreenManager = require("ui.ScreenManager")

local screenManager

function love.load()
    screenManager = ScreenManager:new()
    screenManager:show(require("ui.screens.MainMenuScreen"))
end

function love.update(deltaTime)
    screenManager:emit("update", deltaTime)
end

function love.draw()
    screenManager:emit("draw")
end

function love.keypressed(...)
    screenManager:emit("handleKeyPress", ...)
end

function love.keyreleased(...)
    screenManager:emit("handleKeyRelease", ...)
end