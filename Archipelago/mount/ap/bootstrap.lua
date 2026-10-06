_G.AP = _G.AP or {}
local AP = _G.AP
AP.state = AP.state or {}
AP.state.connected =
    AP.state.connected or false

AP.state.slot_data =
    AP.state.slot_data or {}

AP.state.items_received =
    AP.state.items_received or {}

AP.state.level_access =
    persistent.archipelago.level_access
    or {}
AP.world = nil
AP.context = AP.context or {
    currentNode = nil
}
AP.postLoadHooks =
    AP.postLoadHooks or {}

AP.shopTracker = nil
AP.locations = {}
AP.locationItems = {}
AP.currentAPReward = nil

AP.isDeathLinkDeath = false
AP.last_deathlink_time = nil
AP.deathlink_received = false


local function getTierPrefix(level, early, mid, late)
    if level >= 1 and level <= 3 then
        return early
    elseif level >= 4 and level <= 6 then
        return mid
    elseif level >= 7 and level <= 9 then
        return late
    end
end

function AP.resolveCheckName(loc)

    if not loc then
        loc = AP.currentGameLocation
    end

    if not loc then
        print("[AP] No current game location")
        return nil, nil
    end

    local prefix
    local counterKey
    local level = loc.level

    if loc.type == "crypt" then

        prefix = getTierPrefix(
            level,
            "Early Crypt",
            "Mid Crypt",
            "Late Crypt"
        )

        counterKey =
            prefix
            and ({
                ["Early Crypt"] = "earlyCrypt",
                ["Mid Crypt"] = "midCrypt",
                ["Late Crypt"] = "lateCrypt",
            })[prefix]

    elseif loc.type == "chapel_ruin"
    or loc.type == "tomb" then

        local parent = loc.parentNode

        if parent then
            prefix = getTierPrefix(
                parent.level,
                "Early Graveyard",
                "Mid Graveyard",
                "Late Graveyard"
            )

            counterKey =
                prefix
                and ({
                    ["Early Graveyard"] = "earlyGraveyard",
                    ["Mid Graveyard"] = "midGraveyard",
                    ["Late Graveyard"] = "lateGraveyard",
                })[prefix]
        end

    elseif loc.type == "forest"
    or loc.type == "corrupt_pine_spider_forest"
    or loc.type == "corrupt_oak_spider_forest"
    or loc.type == "pine_spider_forest"
    or loc.type == "oak_spider_forest" then

        prefix = getTierPrefix(
            level,
            "Early Spider Forest",
            "Mid Spider Forest",
            "Late Spider Forest"
        )

        counterKey =
            prefix
            and ({
                ["Early Spider Forest"] = "earlySpiderForest",
                ["Mid Spider Forest"] = "midSpiderForest",
                ["Late Spider Forest"] = "lateSpiderForest",
            })[prefix]


    elseif loc.type == "banditCamp"
    or loc.type == "corrupt_bandit_camp_oak"
    or loc.type == "corrupt_bandit_camp_pine"
    or loc.type == "bandit_camp_oak"
    or loc.type == "bandit_camp_pine" then

        prefix = getTierPrefix(
            level,
            "Early Bandit Camp",
            "Mid Bandit Camp",
            "Late Bandit Camp"
        )

        counterKey =
            prefix
            and ({
                ["Early Bandit Camp"] = "earlyBanditCamp",
                ["Mid Bandit Camp"] = "midBanditCamp",
                ["Late Bandit Camp"] = "lateBanditCamp",
            })[prefix]
    end

    if not prefix or not counterKey then

        print(
            "[AP] Unsupported location:",
            loc.type,
            loc.level
        )

        return nil, nil
    end

    local count =
        persistent.archipelago.nexus.checks[counterKey] or 0

    count = count + 1

    local checkName =
        prefix .. " " .. count

    print(
        "[AP] Candidate check:",
        checkName
    )

    if AP.locations[checkName] then

        -- persistent.archipelago.nexus.checks[counterKey] = count

        -- saveFileData(
        --     "persistentSaveData",
        --     persistent
        -- )

        return checkName, counterKey

    end

    print(
        "[AP] Check does not exist:",
        checkName
    )

    return nil, nil
end


function AP.loadSlotData()

    local slot =
        AP.state.slot_data

    if not slot then
        print("[AP] No slot data")
        return
    end

    print("[AP] Parsing slot data")

    AP.locations = {}
    AP.locationNames = {}

    if slot.locations then
        for name,address in pairs(slot.locations) do
            if type(name) == "string"
            and type(address) == "number" then
                AP.locations[name] = address
            end
        end
    end

    if slot.location_items then
        for address,item in pairs(slot.location_items) do
            local id = tonumber(address)

            if id and type(item) == "table" then
                AP.locationItems[id] = item
            end
        end
    end

    local locationCount = 0

    for _ in pairs(AP.locations) do
        locationCount = locationCount + 1
    end

    for k,v in pairs(AP.locations) do
        print(k,v)
        break
    end

    local itemCount = 0

    for id,item in pairs(AP.locationItems) do
        itemCount = itemCount + 1
        if itemCount <= 5 then
            print(
                "[AP] Item:",
                id,
                item.item_name,
                item.game_name,
                "from",
                item.player_name
            )
        end
    end

    print(
        "[AP] Loaded locations:",
        locationCount
    )

    print(
        "[AP] Loaded item mappings:",
        itemCount
    )


    for name,address in pairs(slot.locations) do
        if type(name) == "string" and type(address) == "number" then
            AP.locations[name] = address
            AP.locationNames[address] = name
        end
    end

end

persistent.archipelago = persistent.archipelago or {}
persistent.archipelago.nexus =
persistent.archipelago.nexus or {
    currentCharges = 0,
    maxCharges = 0,
    checks = {
        earlyCrypt = 0,
        midCrypt = 0,
        lateCrypt = 0,

        earlyGraveyard = 0,
        midGraveyard = 0,
        lateGraveyard = 0,

        earlySpiderForest = 0,
        midSpiderForest = 0,
        lateSpiderForest = 0,

        earlyBanditCamp = 0,
        midBanditCamp = 0,
        lateBanditCamp = 0,
    }
}
persistent.archipelago.nexus.nexusSatchelObtainedItemsList = persistent.archipelago.nexus.nexusSatchelObtainedItemsList or {}
persistent.archipelago.pendingItems = persistent.archipelago.pendingItems or {}
persistent.archipelago.receivedItems = persistent.archipelago.receivedItems or {}
persistent.archipelago.pendingCombatCheck = persistent.archipelago.pendingCombatCheck or nil
persistent.archipelago.extraHearts = persistent.archipelago.extraHearts or 0
persistent.archipelago.extraGearSlots = persistent.archipelago.extraGearSlots or 0
persistent.archipelago.level_access =
    persistent.archipelago.level_access or {
        [1] = true,
        [2] = true,
        [3] = true,
    }

local APItemsFunctions =
    require(
        "mods.archipelago.mount.ap.items"
    )

local base =
    os.getenv("APPDATA")
    .. "\\SternlyWordedAdventures\\mods\\Archipelago\\mount\\ap\\"

local function load(file)
    local f =
        assert(
            io.open(
                base .. file,
                "rb"
            )
        )
    local chunk =
        assert(
            loadstring(
                f:read("*a")
            )
        )

    f:close()
    return chunk()
end

AP.client = load("client.lua")
print("[AP] client loaded:", AP.client)

for k,v in pairs(AP.client) do
    print("[AP] client export:", k, v)
end

AP.client.state = AP.state
AP.items = APItemsFunctions
AP.rewards = load("rewards.lua")
AP.progression = load("progression.lua")
AP.overworldHooks = load("overworld.lua")
AP.releaseCondition = load("releasecondition.lua")
AP.deathlink = load("deathlink.lua")
AP.tileGenerationHook = load("tilegeneration.lua")
AP.itemPreservationHook = load("itempreservation.lua")


overworldview = require("overworldview")

print("[AP] Running post load hooks")


for _,hook in ipairs(AP.postLoadHooks) do
    print("[AP] AP.overworld =", AP.overworld)
    print("[AP] loaded overworld =", package.loaded["overworld"])
    print("[AP] installing returnFromDungeon hook")
    local ok,err =
        pcall(hook)

    if not ok then
        print(
            "[AP] Post load hook failed:",
            err
        )
    end

end

local oldUpdate =
    love.update


love.update = function(dt)
    AP.client.poll()

    if AP.client
    and AP.state.connected
    and not AP.world then

        if _G.locationData then

            AP.initWorld(
                _G.locationData
            )

        end

    end

    if AP.deathlink_received and AP.deathlink_enabled then
        local location = overworldview.playerCurrentLocation()
        local parallax = overworldview.getLocationOutsideParallax(location)
        local flags = overworldview.getLocationParallaxFlags(location, parallax)
        overworld.startNewRun{
            parallax = parallax,
            flags = flags,
            level = location.level,
            seed = location.seed,
            fleeingCountsForCompletion = true,
            fixedRewards = {},
            generator = 'default',
            numBosses = 0,
            enemySet = location.parentNode.typeData.enemies,
            enemiesSD = 1,
            enemiesMean = 1,
            daylight = overworld.getDaylightStrength(),
            time = overworld.getTimeOfDay(),
            setpiece  = { type = 'treant_stump', parallaxStartPos = -10000, name = 'inevitable doom' },
        }
        rpg:gameOver()
        rpg:save()
        AP.deathlink_received = false
    end

    if activeModeIs'overworld'
    and #APItemsFunctions.pendingOverworldItems > 0 then
        print("[AP] Applying queued items")

        for _,fn in ipairs(
            APItemsFunctions.pendingOverworldItems
        ) do
            fn()
        end
        APItemsFunctions.pendingOverworldItems = {}
    end

    local queue = persistent.archipelago.pendingItems
    local overworld = package.loaded["overworld"]

    local ready =
        overworld
        and type(overworld) == "table" 
        and overworld.recordGoldStats

    if ready and #queue > 0 then


    local i = 1

    if ready and #queue > 0 then
        local i = 1

        while i <= #queue do
            local queued = queue[i]
            local def = AP.items.ITEM_DEFS[queued.item]

            if def == nil then
                print("[AP] Received unknown item:", queued.item)
                table.remove(queue, i)

            elseif activeModeIs'overworld' and not def.isTrap then
                print("[AP] Applying item:", def.name)

                def.apply()
                table.remove(queue, i)

            elseif activeModeIs'rpg' and def.isTrap then
                i = i + 1

            else
                i = i + 1
            end
        end
    end

    saveFileData(
        "persistentSaveData",
        persistent
    )
end

    local overworld = package.loaded["overworld"]
    local world = package.loaded["utils.world"]

    if overworld then
        if not AP.rewardHooksInstalled then
            AP.rewards.installRewardHooks(overworld)
        end

        if not AP.overworldHooksInstalled then
            AP.overworldHooks.installOverworldHooks(overworld)
        end

        if not AP.deathHookInstalled then
            AP.deathlink.installDeathHook()
        end

    end



    return oldUpdate(dt)

end