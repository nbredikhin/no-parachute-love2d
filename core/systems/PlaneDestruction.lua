local Concord = require("lib.concord")
local mathUtils = require("utils.math")
local maf = require("lib.maf")
local assets = require("core.assets")

local PlaneDestruction = Concord.system({
    pool = {"breakableObstacle", "obstacleHitByEntityEvent"}
})

local partsDirections = {
    {-1, 0.2},
    {1, 0.5},
    {0.1, -1},
}

function PlaneDestruction:update(deltaTime)
    local gameManager = self:getWorld().gameManager
    for _, e in ipairs(self.pool) do
        local entity = e.obstacleHitByEntityEvent.value
        if entity.velocity and entity.character then
            local velocityIncrease = mathUtils.clamp01(entity.velocity.value.z / -gameManager.levelConfig.fallSpeed - 1)

            if velocityIncrease > 0.1 then
                e.obstacleHitByEntityEvent.value:remove("obstacleCollisionEvent")
                love.graphics.setCanvas(e.texture.value)
                love.graphics.setBlendMode("multiply", "premultiplied")
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.draw(assets.texture("plane_broken"), 0, 0)
                love.graphics.setCanvas()
                love.graphics.setBlendMode("alpha")

                if entity.controlledByPlayer then
                    Concord.entity(self:getWorld()):give("cameraShakeSource", 3)
                end

                local hitPos = e.obstacleHitByEntityEvent.value.position.value
                Concord.entity(self:getWorld())
                    :give("position", maf.vec3(hitPos.x, hitPos.y, hitPos.z))
                    :give("particleEmitDelay", 0)
                    :give("lifeTime", 0)
                    :give("particleColor", e.planeTextureColor.r, e.planeTextureColor.g, e.planeTextureColor.b, 1, true)
                    :give("particleSize", 0.08, 0.16)
                    :give("particleFriction", 0.1, 0.1)
                    :give("particleGravity", maf.vec3(0, 0, -30))
                    :give("particleRandomRotation")
                    :give("particleEmitCount", 50, 60)
                    :give("particleSpeed", -10+entity.velocity.value.x, 10+entity.velocity.value.x, -10+entity.velocity.value.y, 10+entity.velocity.value.y, entity.velocity.value.z, 0)
                    :give("particleLifeTime", 3, 5)

                local screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()
                for _ = 1, math.random(5, 15) do
                    local s = math.floor(screenHeight/128*4)
                    local b = math.random() + 0.5
                    Concord.entity(self:getWorld())
                        :give("position2d", screenWidth * math.random(), screenHeight * math.random())
                        :give("size2d", s, s)
                        :give("lifeTime", 1 + math.random() * 2)
                        :give("color", e.planeTextureColor.r*b, e.planeTextureColor.g*b, e.planeTextureColor.b*b, 1)
                end

                -- Broken parts
                for i = 1, 3 do
                    local texture = assets.texture("plane_broken_part"..i)

                    local canvas = love.graphics.newCanvas(texture:getWidth(), texture:getHeight())
                    love.graphics.setCanvas(canvas)
                    love.graphics.clear()
                    love.graphics.setColor(1, 1, 1, 1)
                    love.graphics.setBlendMode("alpha")
                    love.graphics.draw(e.collisionTexture.value, 0, 0)
                    love.graphics.setBlendMode("multiply", "premultiplied")
                    love.graphics.draw(texture, 0, 0)
                    canvas:setFilter("nearest", "nearest")

                    local speed = math.random() * 10 + 5
                    local vx = partsDirections[i][1] * (math.random() * 0.5 + 0.5) * speed
                    local vy = partsDirections[i][2] * (math.random() * 0.5 + 0.5) * speed
                    Concord.entity(self:getWorld())
                        :give("position", e.position.value:clone())
                        :give("size", maf.vec3(10, 10))
                        :give("rotation", e.rotation.value)
                        :give("drawable")
                        :give("texture", canvas)
                        :give("lifeTime", 3)
                        :give("rotationSpeed", (math.random() - 0.5) * 2)
                        :give("velocity", maf.vec3(vx, vy, entity.velocity.value.z * math.random()))
                end

                love.graphics.setBlendMode("alpha")
                love.graphics.setCanvas()
            end
        end
    end
end

return PlaneDestruction