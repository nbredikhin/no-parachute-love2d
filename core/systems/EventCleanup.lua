local Concord = require("lib.concord")

local cleanupComponents = {
    "obstacleCollisionEvent",
    "damageEvent",
    "deathEvent",
    "planeSpawnEvent",
    "sidePlaneRespawnEvent",
    "obstacleHitByEntityEvent",
    "obstaclePassedPlayerEvent",
    "playMusicEvent",
    "stopMusicEvent",
    "playAmbientEvent",
    "stopAmbientEvent",
}

local pools = {}

for _, name in ipairs(cleanupComponents) do
    local poolName = name .. "Pool"
    pools[poolName] = {name}
end

local EventCleanup = Concord.system(pools)

function EventCleanup:update(deltaTime)
    for poolName in pairs(pools) do
        for _, e in ipairs(self[poolName]) do
            e:remove(pools[poolName][1])
        end
    end
end

return EventCleanup