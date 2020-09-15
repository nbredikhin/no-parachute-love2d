local class = require("lib.middleclass")
local Concord = require("lib.concord")
local maf = require("lib.maf")
local Assets = require("engine.Assets")

Concord.utils.loadNamespace("engine/components")

local GameManager = class("GameManager")

function GameManager:initialize()
    self.world = Concord.world()
    self.world.gameManager = self

    self.world:addSystem(require("engine.systems.ObstacleCollisionCheck"))
    self.world:addSystem(require("engine.systems.PlayerControl"))
    self.world:addSystem(require("engine.systems.CharacterMovement"))
    self.world:addSystem(require("engine.systems.CharacterRotation"))
    self.world:addSystem(require("engine.systems.Movement"))
    self.world:addSystem(require("engine.systems.LimbPoses"))
    self.world:addSystem(require("engine.systems.LimbAttach"))
    self.world:addSystem(require("engine.systems.CameraFollowPlayer"))
    self.world:addSystem(require("engine.systems.CameraShaking"))
    self.world:addSystem(require("engine.systems.BoundaryLimit"))
    self.world:addSystem(require("engine.systems.DecorativePlaneCycling"))
    self.world:addSystem(require("engine.systems.ObstacleSpawn"))
    self.world:addSystem(require("engine.systems.DestroyAboveCamera"))
    self.world:addSystem(require("engine.systems.CharacterDeath"))
    self.world:addSystem(require("engine.systems.LimbDetach"))
    self.world:addSystem(require("engine.systems.PlaneRendering"))
    -- Optional debug systems
    self.world:addSystem(require("engine.systems.debug.DebugCollisions"))
    self.world:addSystem(require("engine.systems.debug.DebugInfo"))

    -- Side wall planes
    local count = 40
    for i = 0, count - 1 do
        local z = -100 + i * 100 / count
        Concord.entity(self.world)
            :give("position", maf.vec3(0, 0, z))
            :give("size", maf.vec3(10, 10))
            :give("rotation", math.random(1, 4)*math.pi * 0.5)
            :give("drawable")
            :give("decorativePlane")
            :give("color", 1, 1, 1)
            :give("texture", Assets.texture("level1/decorative"..math.random(1, 3)))
    end

    local player = self:createCharacter()
        :give("playerControlled")
        :give("rotationSpeed", 0.1)

    -- Camera
    Concord.entity(self.world)
        :give("position", maf.vec3(0, 0, 0))
        :give("rotation", 0)
        :give("camera")
        :give("target", player)

    -- Obstacle spawner
    Concord.entity(self.world)
        :give("position", maf.vec3(0, 0, -100))
        :give("lastObstacleDistance")
end

function GameManager:createCharacter()
    -- Player
    local character = Concord.entity(self.world)
        :give("name", "character")
        :give("position", maf.vec3(0, 0, -10))
        :give("size", maf.vec3(2.5, 2.5))
        :give("rotation", 0)
        :give("rotationSpeed", 0)
        :give("drawable")
        :give("character")
        :give("alive")
        :give("velocity", maf.vec3(0, 0, -25))
        :give("moveDirection")
        :give("texture", Assets.texture("player/torso"))

    -- Limbs
    -- Right Hand
    Concord.entity(self.world)
        :give("name", "right_hand")
        :give("position")
        :give("size", maf.vec3(2.5, 2.5))
        :give("rotation", 0)
        :give("drawable")
        :give("alive")
        :give("limbParent", character)
        :give("limbRotation", 0)
        :give("limbRotationPoses", -0.2, 0.2, 0.1, -0.3)
        :give("texture", Assets.texture("player/hand"))
        :give("limbMissingTexture", Assets.texture("player/hand_missing"))
        :give("offset", maf.vec3(0, 0, 0))
        :give("obstacleCollisionCheckOffset", maf.vec3(0.55, -0.7, 0))

    -- Left Hand
    Concord.entity(self.world)
        :give("name", "left_hand")
        :give("position")
        :give("size", maf.vec3(-2.5, 2.5))
        :give("rotation", 0)
        :give("drawable")
        :give("alive")
        :give("limbParent", character)
        :give("limbRotation", 0)
        :give("limbRotationPoses", -0.2, 0.2, -0.1, 0.3)
        :give("texture", Assets.texture("player/hand"))
        :give("limbMissingTexture", Assets.texture("player/hand_missing2"))
        :give("offset", maf.vec3(-0.08, 0, 0))
        :give("obstacleCollisionCheckOffset", maf.vec3(-0.55, -0.7, 0))

    -- Right Leg
    Concord.entity(self.world)
        :give("name", "right_leg")
        :give("position")
        :give("size", maf.vec3(2.5, 2.5))
        :give("rotation", 0)
        :give("drawable")
        :give("alive")
        :give("limbParent", character)
        :give("limbRotation", 0)
        :give("limbRotationPoses", -0.2, 0.2, 0.2, -0.25)
        :give("texture", Assets.texture("player/leg"))
        :give("limbMissingTexture", Assets.texture("player/leg_missing"))
        :give("offset", maf.vec3(0, 0, 0))
        :give("obstacleCollisionCheckOffset", maf.vec3(0.4, 0.85, 0))

    -- Left Leg
    Concord.entity(self.world)
        :give("name", "left_leg")
        :give("position")
        :give("size", maf.vec3(-2.5, 2.5))
        :give("rotation", 0)
        :give("drawable")
        :give("alive")
        :give("limbParent", character)
        :give("limbRotation", 0)
        :give("limbRotationPoses", -0.2, 0.2, -0.2, 0.25)
        :give("texture", Assets.texture("player/leg"))
        :give("limbMissingTexture", Assets.texture("player/leg_missing2"))
        :give("offset", maf.vec3(-0.08, 0, 0))
        :give("obstacleCollisionCheckOffset", maf.vec3(-0.4, 0.85, 0))

    return character
end

function GameManager:update(deltaTime)
    self.world:emit("update", deltaTime)
end

function GameManager:draw()
    love.graphics.clear(0, 0, 0, 1)
    self.world:emit("draw")
    love.graphics.origin()
    love.graphics.setColor(1, 1, 1, 1)
end

function GameManager:handleKeyPress(...)
    self.world:emit("keyPress", ...)
end

function GameManager:handleKeyRelease(...)
    self.world:emit("keyRelease", ...)
end

return GameManager