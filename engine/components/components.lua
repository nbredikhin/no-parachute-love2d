local Concord = require("lib.concord")
local maf = require("lib.maf")

Concord.component("name", function(component, name)
    component.value = name or "unnamed"
end)

Concord.component("position", function(component, position)
    component.value = position or maf.vec3(0, 0, 0)
end)

Concord.component("size", function(component, size)
    component.value = size or maf.vec3(0, 0, 0)
end)

Concord.component("rotation", function(component, rotation)
    component.value = rotation or 0
end)

Concord.component("rotationSpeed", function(component, value)
    component.value = value or 0
end)

Concord.component("fillMode", function(component, mode)
    component.value = mode or "line"
end)

Concord.component("texture", function(component, texture)
    component.value = texture
    component.width = texture:getWidth()
    component.height = texture:getHeight()
end)

Concord.component("collisionTexture", function(component, texture)
    component.value = texture
end)

Concord.component("color", function(component, r, g, b, a)
    component.r = r or 0
    component.g = g or 0
    component.b = b or 0
    component.a = a or 1
end)

Concord.component("planeSideFill", function(component, width, r, g, b, a)
    component.width = width or 1
    component.r = r or 0
    component.g = g or 0
    component.b = b or 0
    component.a = a or 1
end)

Concord.component("velocity", function(component, velocity)
    component.value = velocity or maf.vec3(0, 0, 0)
end)

Concord.component("friction", function(component, value)
    component.value = value or 1
end)

Concord.component("moveDirection", function(component, value)
    component.value = value or maf.vec3(0, 0, 0)
end)

Concord.component("attachToEntity", function(component, entity)
    component.value = entity
end)

Concord.component("attachRotation", function(component, value)
    component.value = value or 0
end)

Concord.component("limbRotationPoses", function(component, left, right, up, down)
    component.left = left or 0
    component.right = right or 0
    component.up = up or 0
    component.down = down or 0
end)

Concord.component("limbMissingTexture", function(component, value)
    component.value = value
end)

Concord.component("attachOffset", function(component, offset)
    component.value = offset
end)

Concord.component("lastObstacleZ", function(component, value)
    component.value = value or 0
end)

Concord.component("distanceBetweenObstacles", function(component, value)
    component.value = value or 0
end)

Concord.component("target", function(component, entity)
    component.value = entity
end)

Concord.component("lastCollidedObstacle", function(component, entity, hitPosition, textureX, textureY)
    component.value = entity
    component.hitPosition = hitPosition
    component.textureX = textureX
    component.textureY = textureY
end)

Concord.component("obstacleCollisionCheckOffset", function(component, offset)
    component.value = offset or maf.vec3(0, 0, 0)
end)

Concord.component("cameraShakeEvent", function(component, level)
    component.level = level or 1
    component.time = 0
end)

Concord.component("respawnTimeout", function(component, value)
    component.value = value or 0
end)

Concord.component("lifeTime", function(component, value)
    component.value = value or 0
end)

Concord.component("bloodSpawnEvent", function(component, level)
    component.level = level or 1
end)

Concord.component("deferredDecal", function(component, name, entity, textureX, textureY)
    component.name = name
    component.entity = entity
    component.textureX = textureX
    component.textureY = textureY
end)