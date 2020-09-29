local class = require("lib.middleclass")
local Concord = require("lib.concord")
local maf = require("lib.maf")
local assets = require("engine.assets")
local mathUtils = require("utils.math")
local LevelGenerator = require("engine.LevelGenerator")
local console = require("utils.console")

Concord.utils.loadNamespace("engine/components")

local GameManager = class("GameManager")

function GameManager:initialize(levelConfig, uiScreen)
    self.levelConfig = levelConfig
    self.levelGenerator = LevelGenerator:new(self.levelConfig)
    self.levelGenerator:generate()
    self.ui = uiScreen

    self.world = Concord.world()
    self.world.gameManager = self

    self.world:addSystem(require("engine.systems.Decals"))
    self.world:addSystem(require("engine.systems.LifeTime"))
    self.world:addSystem(require("engine.systems.BloodSpawnOnScreen"))
    self.world:addSystem(require("engine.systems.BloodSpawn"))
    self.world:addSystem(require("engine.systems.ParticleEmitter"))
    self.world:addSystem(require("engine.systems.RespawnTimeout"))
    self.world:addSystem(require("engine.systems.CharacterRespawn"))
    self.world:addSystem(require("engine.systems.ObstacleCollisionCheck"))
    self.world:addSystem(require("engine.systems.PlayerControl"))
    self.world:addSystem(require("engine.systems.CharacterMovement"))
    self.world:addSystem(require("engine.systems.PlayerRotation"))
    self.world:addSystem(require("engine.systems.Rotation"))
    self.world:addSystem(require("engine.systems.Movement"))
    self.world:addSystem(require("engine.systems.Friction"))
    self.world:addSystem(require("engine.systems.Gravity"))
    self.world:addSystem(require("engine.systems.LimbPoses"))
    self.world:addSystem(require("engine.systems.Attach"))
    self.world:addSystem(require("engine.systems.CameraFollowPlayer"))
    self.world:addSystem(require("engine.systems.CameraShaking"))
    self.world:addSystem(require("engine.systems.BoundaryCollisionCheck"))
    self.world:addSystem(require("engine.systems.DecorativePlaneCycling"))
    self.world:addSystem(require("engine.systems.ObstacleSpawn"))
    self.world:addSystem(require("engine.systems.DestroyOutOfBounds"))
    self.world:addSystem(require("engine.systems.CharacterDeath"))
    self.world:addSystem(require("engine.systems.LimbObstacleCollision"))
    self.world:addSystem(require("engine.systems.LimbBoundaryCollision"))
    self.world:addSystem(require("engine.systems.LimbDetach"))
    self.world:addSystem(require("engine.systems.BloodParticleCollision"))
    self.world:addSystem(require("engine.systems.DetachedLimbCollision"))
    self.world:addSystem(require("engine.systems.LevelFinish"))
    self.world:addSystem(require("engine.systems.LevelProgress"))
    self.world:addSystem(require("engine.systems.PlaneRendering"))
    self.world:addSystem(require("engine.systems.debug.DebugCollisions"))
    self.world:addSystem(require("engine.systems.debug.DebugInfo"))
    self.world:addSystem(require("engine.systems.debug.DebugFrameRateGraph"))
    self.world:addSystem(require("engine.systems.ScreenRendering"))
    self.world:addSystem(require("engine.systems.EventCleanup"))

    -- Side wall planes
    assert(self.levelConfig.decorations, "Invalid decorations config")
    assert(#self.levelConfig.decorations > 0, "Empty decorations table")
    assert(type(self.levelConfig.decorationPlanesCount) == "number", "Invalid decoration planes count")

    local count = math.max(27, self.levelConfig.decorationPlanesCount)
    for i = 0, count - 1 do
        local decoration = self.levelConfig.decorations[math.random(1, #self.levelConfig.decorations)]
        local z = -100 + i * 100 / count
        Concord.entity(self.world)
            :give("position", maf.vec3(0, 0, z))
            :give("size", maf.vec3(10 * mathUtils.sign(math.random() - 0.5), 10 * mathUtils.sign(math.random() - 0.5)))
            :give("rotation", math.random(1, 4)*math.pi * 0.5)
            :give("drawable")
            :give("decorativePlane")
            :give("texture", assets.texture(decoration.texture))
    end

    self:createCharacter()
        :give("playerControlled")

    -- Camera
    Concord.entity(self.world)
        :give("position", maf.vec3(0, 0, 0))
        :give("rotation", 0)
        :give("camera")

    -- Obstacle spawner
    assert(type(self.levelConfig.distanceBetweenObstacles) == "number", "Invalid distanceBetweenObstacles")
    Concord.entity(self.world)
        :give("lastObstacleZ", 0)
        :give("lastObstacleIndex", 0)
        :give("distanceBetweenObstacles", self.levelConfig.distanceBetweenObstacles)

    self.world:emit("init")
end

function GameManager:createCharacter()
    -- Character
    local character = Concord.entity(self.world)
        :give("name", "character")
        :give("position", maf.vec3(0, 0, -10))
        :give("size", maf.vec3(2.5, 2.5))
        :give("rotation", 0)
        :give("drawable")
        :give("canCollideWithObstacles")
        :give("canCollideWithBoundaries")
        :give("character")
        :give("alive")
        :give("velocity", maf.vec3(0, 0, -self.levelConfig.fallSpeed))
        :give("acceleration", 50)
        :give("friction", 3)
        :give("moveDirection")
        :give("texture", assets.texture("player/torso"))
        :give("levelProgress", 0)

    -- Limbs
    -- Right Hand
    Concord.entity(self.world)
        :give("name", "right_hand")
        :give("position")
        :give("size", maf.vec3(2.5, 2.5))
        :give("rotation", 0)
        :give("drawable")
        :give("canCollideWithObstacles")
        :give("canCollideWithBoundaries")
        :give("alive")
        :give("limb")
        :give("attachToEntity", character)
        :give("attachRotation", 0)
        :give("attachOffset", maf.vec3(0, 0, -0.26))
        :give("limbRotationPoses", -0.2, 0.2, 0.1, -0.3)
        :give("texture", assets.texture("player/hand"))
        :give("limbMissingTexture", assets.texture("player/hand_missing"))
        :give("obstacleCollisionCheckOffset", maf.vec3(0.5, -0.5, 0))

    -- Left Hand
    Concord.entity(self.world)
        :give("name", "left_hand")
        :give("position")
        :give("size", maf.vec3(-2.5, 2.5))
        :give("rotation", 0)
        :give("drawable")
        :give("canCollideWithObstacles")
        :give("canCollideWithBoundaries")
        :give("alive")
        :give("limb")
        :give("attachToEntity", character)
        :give("attachRotation", 0)
        :give("attachOffset", maf.vec3(-0.08, 0, -0.26))
        :give("limbRotationPoses", -0.2, 0.2, -0.1, 0.3)
        :give("texture", assets.texture("player/hand"))
        :give("limbMissingTexture", assets.texture("player/hand_missing2"))
        :give("obstacleCollisionCheckOffset", maf.vec3(-0.5, -0.5, 0))

    -- Right Leg
    Concord.entity(self.world)
        :give("name", "right_leg")
        :give("position")
        :give("size", maf.vec3(2.5, 2.5))
        :give("rotation", 0)
        :give("drawable")
        :give("canCollideWithObstacles")
        :give("canCollideWithBoundaries")
        :give("alive")
        :give("limb")
        :give("attachToEntity", character)
        :give("attachRotation", 0)
        :give("attachOffset", maf.vec3(0, 0, -0.26))
        :give("limbRotationPoses", -0.2, 0.2, 0.2, -0.25)
        :give("texture", assets.texture("player/leg"))
        :give("limbMissingTexture", assets.texture("player/leg_missing"))
        :give("obstacleCollisionCheckOffset", maf.vec3(0.18, 0.5, 0))

    -- Left Leg
    Concord.entity(self.world)
        :give("name", "left_leg")
        :give("position")
        :give("size", maf.vec3(-2.5, 2.5))
        :give("rotation", 0)
        :give("drawable")
        :give("canCollideWithObstacles")
        :give("canCollideWithBoundaries")
        :give("alive")
        :give("limb")
        :give("attachToEntity", character)
        :give("attachRotation", 0)
        :give("attachOffset", maf.vec3(-0.08, 0, -0.26))
        :give("limbRotationPoses", -0.2, 0.2, -0.2, 0.25)
        :give("texture", assets.texture("player/leg"))
        :give("limbMissingTexture", assets.texture("player/leg_missing2"))
        :give("obstacleCollisionCheckOffset", maf.vec3(-0.18, 0.5, 0))

    return character
end

function GameManager:update(deltaTime)
    self.world:emit("update", deltaTime)
end

function GameManager:draw()
    self.world:emit("draw")
end

function GameManager:handleKeyPress(...)
    self.world:emit("keyPress", ...)
end

function GameManager:handleKeyRelease(...)
    self.world:emit("keyRelease", ...)
end

return GameManager