local Concord = require("lib.concord")
local mathUtils = require("utils.math")
local maf = require("lib.maf")
local assets = require("core.assets")
local joystickManager = require("utils.joystickManager")

local PlaneDestruction = Concord.system({
    characterPool = {"character", "obstacleCollisionEvent"}
})

local partsDirections = {
    {-1, 0.2},
    {1, 0.5},
    {0.1, -1},
}

function PlaneDestruction:update(deltaTime)
    local joystick = joystickManager.get()

    for _, e in ipairs(self.characterPool) do
        local obstacle = e.obstacleCollisionEvent.value

        local velocityIncrease = mathUtils.clamp01(e.velocity.value.z / e.character.fallSpeed - 1)
        local isSpeedUp = love.keyboard.isDown("space") or (joystick and joystick:isDown(1)) or velocityIncrease > 0.01
        if obstacle.breakableObstacle and isSpeedUp then
            e:remove("obstacleCollisionEvent")
            love.graphics.setCanvas(obstacle.texture.value)
            love.graphics.setBlendMode("multiply", "premultiplied")
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(assets.texture("plane_broken"), 0, 0)
            love.graphics.setCanvas()
            love.graphics.setBlendMode("alpha")

            if e.controlledByPlayer then
                Concord.entity(self:getWorld()):give("cameraShakeSource", 3)
            end

            local hitPos = obstacle.obstacleHitByEntityEvent.value.position.value
            Concord.entity(self:getWorld())
                :give("position", maf.vec3(hitPos.x, hitPos.y, hitPos.z))
                :give("particleEmitDelay", 0)
                :give("lifeTime", 0)
                :give("particleColor", obstacle.planeTextureColor.r, obstacle.planeTextureColor.g, obstacle.planeTextureColor.b, 1, true)
                :give("particleSize", 0.08, 0.16)
                :give("particleFriction", 0.1, 0.1)
                :give("particleGravity", maf.vec3(0, 0, -30))
                :give("particleRandomRotation")
                :give("particleEmitCount", 30, 40)
                :give("particleSpeed",
                    -15+e.velocity.value.x,
                    15+e.velocity.value.x,
                    -15+e.velocity.value.y,
                    15+e.velocity.value.y,
                    e.velocity.value.z,
                    e.velocity.value.z*0.5)
                :give("particleLifeTime", 3, 5)

            -- Broken parts
            for i = 1, 3 do
                local texture = assets.texture("plane_broken_part"..i)

                local canvas = love.graphics.newCanvas(texture:getWidth(), texture:getHeight())
                love.graphics.setCanvas(canvas)
                love.graphics.clear()
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.setBlendMode("alpha")
                love.graphics.draw(obstacle.collisionTexture.value, 0, 0)
                love.graphics.setBlendMode("multiply", "premultiplied")
                love.graphics.draw(texture, 0, 0)
                love.graphics.draw(assets.texture("plane_cracks"), 0, 0)
                canvas:setFilter("nearest", "nearest")

                local speed = math.random() * 10 + 5
                local vx = partsDirections[i][1] * (math.random() * 0.5 + 0.5) * speed
                local vy = partsDirections[i][2] * (math.random() * 0.5 + 0.5) * speed
                Concord.entity(self:getWorld())
                    :give("position", obstacle.position.value:clone())
                    :give("size", maf.vec3(10, 10))
                    :give("rotation", obstacle.rotation.value)
                    :give("drawable")
                    :give("texture", canvas)
                    :give("lifeTime", 3)
                    :give("rotationSpeed", (math.random() - 0.5) * 2)
                    :give("velocity", mathUtils.rotateVector2D(maf.vec3(vx, vy, e.velocity.value.z * math.random()), obstacle.rotation.value))
            end

            love.graphics.setBlendMode("alpha")
            love.graphics.setCanvas()
        end
    end
end

return PlaneDestruction