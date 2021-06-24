local json = require("lib.json")
local Steam = require("luasteam")
local nativefs = require("lib.nativefs")
local assets = require("core.assets")

local levelLoader = {}

local function jsonToLevelConfig(levelConfig)
    if type(levelConfig.planes) ~= "table" then
        levelConfig.planes = {}
    end

    -- side planes as textures list
    if type(levelConfig.sidePlanes) == "table" then
        if type(levelConfig.sidePlanes[1]) == "string" then
            levelConfig.sidePlanes = {
                {
                    textures = levelConfig.sidePlanes
                }
            }
        end
    end

    if type(levelConfig.planeTypes) ~= "table" then
        levelConfig.planeTypes = {}
    end

    -- simple plane names as textures
    if type(levelConfig.planes) == "table" then
        for _, plane in pairs(levelConfig.planes) do
            if not levelConfig.planeTypes[plane.name] then
                levelConfig.planeTypes[plane.name] = plane.name
            end
        end
    end

    -- plane types as textures to full
    for name, value in pairs(levelConfig.planeTypes) do
        if type(value) == "string" then
            levelConfig.planeTypes[name] = { planes = { { texture = value } } }
        end
    end

    if type(levelConfig.fallSpeed) ~= "number" then
        levelConfig.fallSpeed = 25
    end
    if levelConfig.fallSpeed < 1 then
        levelConfig.fallSpeed = 1
    end

    if not levelConfig.fogColor or type(levelConfig.fogColor) ~= "table" then
        levelConfig.fogColor = {0, 0, 0}
    end
    if levelConfig.fogColor[1] ~= "number" or levelConfig.fogColor[2] ~= "number" or levelConfig.fogColor[3] ~= "number" then
        levelConfig.fogColor = {0, 0, 0}
    end

    if not levelConfig.fogDistance or type(levelConfig.fogDistance) ~= "number" then
        levelConfig.fogDistance = 100
    end
    if levelConfig.fogDistance < 10 then
        levelConfig.fogDistance = 10
    elseif levelConfig.fogDistance > 100 then
        levelConfig.fogDistance = 100
    end

    if type(levelConfig.playerRotationMode) ~= "string" then
        levelConfig.playerRotationMode = "none"
    end
    if type(levelConfig.playerRotationSpeed) ~= "number" then
        levelConfig.playerRotationSpeed = 0
    end
    if type(levelConfig.sidePlanesCount) ~= "number" then
        levelConfig.sidePlanesCount = 80
    end
    if levelConfig.sidePlanesCount < 30 then
        levelConfig.sidePlanesCount = 30
    elseif levelConfig.sidePlanesCount > 300 then
        levelConfig.sidePlanesCount = 300
    end

    if type(levelConfig.sidePlanesBrightness) ~= "number" then
        levelConfig.sidePlanesBrightness = 1
    end
    if levelConfig.sidePlanesBrightness > 1 then
        levelConfig.sidePlanesBrightness = 1
    elseif levelConfig.sidePlanesBrightness < 0 then
        levelConfig.sidePlanesBrightness = 0
    end

    return levelConfig
end

function levelLoader.loadFromPath(path)
    local levelConfigJSON = "{}"
    local levelConfig = {}
    pcall(function ()
        levelConfigJSON = nativefs.read(path.."/levelConfig.json")
        levelConfig = json.decode(levelConfigJSON)
    end)

    return jsonToLevelConfig(levelConfig)
end

function levelLoader.load(levelName, loadTextures)
    assert(type(levelName) == "string", "Level not specified")
    local levelType = "builtin"
    if levelName:sub(1, 5) == "mods/" then
        levelType = "mods_local"
        levelName = levelName:sub(6, -1)
    elseif levelName:sub(1, 9) == "workshop/" then
        levelType = "mods_downloaded"
        levelName = levelName:sub(10, -1)
    end

    if levelType == "builtin" then
        return require("config.levels."..levelName)
    end

    local path = ""
    if levelType == "mods_local" then
        path = love.filesystem.getSaveDirectory().."/mods/"..levelName
    elseif levelType == "mods_downloaded" then
        local id = Steam.extra.parseUint64(levelName)
        local isInstalled = false
        isInstalled, _, path = Steam.UGC.getItemInstallInfo(id)
        if not isInstalled then
            assert("level not installed")
        end
    end

    local levelConfig = levelLoader.loadFromPath(path)
    if loadTextures then
        levelLoader.preloadTextures(path, levelConfig)
    end
    return levelConfig, path
end

function levelLoader.preloadTextures(path, levelConfig)
    if type(levelConfig.sidePlanes) == "table" then
        for _, conf in ipairs(levelConfig.sidePlanes) do
            for _, name in ipairs(conf.textures) do
                assets.preloadModTexture(path.."/"..name..".png", name)
            end
        end
    end
    if type(levelConfig.planeTypes) == "table" then
        for _, conf in pairs(levelConfig.planeTypes) do
            if type(conf.planes) == "table" then
                for _, plane in ipairs(conf.planes) do
                    if plane.texture then
                        assets.preloadModTexture(path.."/"..plane.texture..".png", plane.texture)
                    end
                end
            end
        end
    end
end

return levelLoader