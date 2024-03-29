local Concord = require("lib.concord")

Concord.component("obstacleCollisionEvent", function(component, entity, hitPosition, textureX, textureY)
    component.value = entity
    component.hitPosition = hitPosition
    component.textureX = textureX
    component.textureY = textureY
end)

Concord.component("characterSpawnRequest", function(component, characterType, controlledByPlayer)
    component.characterType = characterType or "player"
    component.controlledByPlayer = not not controlledByPlayer
end)

Concord.component("damageEvent", function(component, damage, cooldown)
    component.damage = damage or 0
    component.cooldown = cooldown or 0
end)

Concord.component("deathEvent")
Concord.component("planeSpawnEvent")
Concord.component("sidePlaneRespawnEvent")
Concord.component("obstaclePassedPlayerEvent")

Concord.component("obstacleHitByEntityEvent", function(component, entity, hitPosition, textureX, textureY)
    component.value = entity
    component.hitPosition = hitPosition
    component.textureX = textureX
    component.textureY = textureY
end)

Concord.component("updateTunnelShapeEvent", function(component, direction, offset, rotationSpeed)
    component.direction = direction
    component.offset = offset
    component.rotationSpeed = rotationSpeed
end)

Concord.component("stopMusicEvent", function(component)
end)

Concord.component("stopAmbientEvent", function(component)
end)

Concord.component("playMusicEvent", function(component, name)
    component.name = name
end)

Concord.component("playAmbientEvent", function(component, name)
    component.name = name
end)