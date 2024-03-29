local Concord = require("lib.concord")

local DebugInfo = Concord.system({
    sidePlanePool = {"sidePlane"},
    obstaclePool = {"obstaclePlane"},
    playerPool = {"controlledByPlayer"},
})

local startTime = love.timer.getTime()
local isBasicInfoVisible = false
local isECSInfoVisible = false

function DebugInfo:draw()
    love.graphics.origin()
    love.graphics.setColor(0, 1, 0, 1)

    if isBasicInfoVisible then
        local y = 10
        local fps = tostring(love.timer.getFPS())
        love.graphics.print("FPS: "..fps, 10, y)

        y = y + 18
        love.graphics.print("Side planes: "..tostring(#self.sidePlanePool), 10, y)
        y = y + 18
        love.graphics.print("Obstacle planes: "..tostring(#self.obstaclePool), 10, y)
        y = y + 18
        if self.playerPool[1] then
            love.graphics.print("Player Z: "..tostring(math.floor(self.playerPool[1].position.value.z)), 10, y)
            y = y + 18
        end
        love.graphics.print("Game time: "..tostring(math.floor(love.timer.getTime() - startTime)).."s", 10, y)
    end

    if isECSInfoVisible then
        local y = 10
        love.graphics.printf("Systems count: "..tostring(#self:getWorld():getSystems()), love.graphics.getWidth() - 210, y, 200, "right")
        y = y + 18
        love.graphics.printf("Entities count: "..tostring(#self:getWorld():getEntities()), love.graphics.getWidth() - 210, y, 200, "right")
    end
end

function DebugInfo:keyPress(key)
    if key == "f1" then
        isBasicInfoVisible = not isBasicInfoVisible
    elseif key == "f2" then
        isECSInfoVisible = not isECSInfoVisible
    end
end

return DebugInfo