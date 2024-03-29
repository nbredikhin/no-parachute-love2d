local class = require("lib.middleclass")
local Screen = require("ui.Screen")
local assets = require("core.assets")
local widgets = require("ui.widgets")
local lz = require("utils.language").localize

local SplashScreen = class("SplashScreen", Screen)
local ignoredKeys = {
    ["numlock"] = true,
    ["capslock"] = true,
    ["rshift"] = true,
    ["lshift"] = true,
    ["tab"] = true,
    ["rctrl"] = true,
    ["lctrl"] = true,
    ["ralt"] = true,
    ["lalt"] = true,
    ["mode"] = true,
    ["rgui"] = true,
    ["lgui"] = true,
    ["printscreen"] = true,
    ["application"] = true,
}

function SplashScreen:initialize()
    self.logoImage = assets.texture("logo")
    self.isInitializationFinished = false

    self.backgroundEffect = love.graphics.newShader([[
        extern float screenWidth;
        extern float screenHeight;
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
        {
            vec4 texel = mix(
                vec4(137.0/255.0, 70.0/255.0, 103.0/255.0, 1),
                vec4(130.0/255.0, 90.0/255.0, 150.0/255.0, 1),
                pixel_coords.x / screenWidth
            );
            texel = mix(texel, vec4(71.0/255.0, 60.0/255.0, 111.0/255.0, 1.0), pixel_coords.y / screenHeight);
            return texel;
        }
    ]])
end

function SplashScreen:draw()
    local screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()
    -- self.backgroundEffect:send("time", love.timer.getTime())
    self.backgroundEffect:send("screenWidth", screenWidth)
    self.backgroundEffect:send("screenHeight", screenHeight)

    love.graphics.clear(0.1, 0.1, 0.1)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setShader(self.backgroundEffect)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)
    love.graphics.setShader()

    local logoScale = math.min(screenWidth * 0.004, screenHeight * 0.004)
    local logoX = screenWidth * 0.5
    local logoY = screenHeight * 0.4 + screenHeight * 0.01 * math.sin(love.timer.getTime())
    love.graphics.setColor(1, 1, 1)
    local rotation = math.sin(love.timer.getTime() * 0.75) * 0.01
    love.graphics.draw(self.logoImage, logoX, logoY, rotation, logoScale, logoScale, self.logoImage:getWidth() * 0.5, self.logoImage:getHeight() * 0.5)
    if self.isInitializationFinished then
        widgets.label(lz("lbl_splash_press_any_button"), 0, screenHeight * 0.75, screenWidth, screenHeight * 0.035, true, "center")
    else
        love.graphics.setColor(0.8, 0.8, 0.8)
        widgets.label(lz("lbl_splash_loading"), 0, screenHeight * 0.75, screenWidth, screenHeight * 0.025, true, "center")
    end
end

function SplashScreen:handleKeyPress(key)
    if ignoredKeys[key] then
        return
    end
    self.screenManager:transition("MainMenuScreen")
end

function SplashScreen:handleMousePress()
    self.screenManager:transition("MainMenuScreen")
end

function SplashScreen:handleInitializationFinish()
    self.isInitializationFinished = true
end

return SplashScreen