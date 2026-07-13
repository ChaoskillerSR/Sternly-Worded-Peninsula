print("[AP] rewards.lua loaded")

local M = {}
local function getCurrentCheck()

    local overworldview = require("overworldview")
    local location = overworldview.playerCurrentLocation()
    print(
        "[AP] Current location:",
        location.key,
        location.type,
        location.level,
        location.parentNode and location.parentNode.type,
        location.parentNode and location.parentNode.level
    )
    
    if location.type == "crypt" then
        return AP.resolveCheckName(location)
    end

    if location.type == "chest" and location.parentNode then

        local parent = location.parentNode

        if parent.type == "pine_spider_forest"
        or parent.type == "oak_spider_forest" then

            return AP.resolveCheckName(parent)

        elseif parent.type == "bandit_camp_pine"
        or parent.type == "bandit_camp_oak" then

            return AP.resolveCheckName(parent)
        end
    end

    if not location then
        return nil
    end

    --------------------------------------------------
    -- Combat rewards
    --------------------------------------------------

    if AP.currentCombatReward then
        local check = AP.resolveCheckName()

        if check then
            persistent.archipelago.currentCombatCheck = check
            saveFileData("persistentSaveData", persistent)
            return check
        end

        return persistent.archipelago.currentCombatCheck
    end

    --------------------------------------------------
    -- Chapel ruins
    --------------------------------------------------

    if location.type == "chapel_ruin" then
        return AP.resolveCheckName(location)
    end

    --------------------------------------------------
    -- Chest nodes
    --------------------------------------------------

    if location.type == "chest" and location.parentNode then

        local parent = location.parentNode.type

        if parent == "pine_spider_forest"
        or parent == "oak_spider_forest" then
            return AP.resolveCheckName(location)

        elseif parent == "bandit_camp_pine"
        or parent == "bandit_camp_oak" then
            return AP.resolveCheckName(location)
        end
    end

    return nil
end

function M.installRewardHooks()

    if AP.rewardHooksInstalled then
        return
    end

    AP.rewardHooksInstalled = true

    print("[AP] Installing reward hook")

    local oldSelection = require("ui.itemselection")

    package.loaded["ui.itemselection"] = function(callback, drops, options)
        if options.archipelagoIgnoreRewardHook then
            return oldSelection(callback, drops, options)
        end
        print("[AP] Reward selection intercepted")

        local checkName = getCurrentCheck()

        if checkName then
            persistent.archipelago.currentCombatCheck = checkName

            saveFileData(
                "persistentSaveData",
                persistent
            )
        end
        
        if not checkName then
            print("[AP] No check resolved, refusing fallback")
        end

        -- if not checkName then
        --     checkName = persistent.archipelago.currentCombatCheck

        --     if checkName then
        --         print(
        --             "[AP] Restored combat check from save:",
        --             checkName
        --         )
        --     end
        -- end

        print(
            "[AP] resolved check:",
            checkName
        )

        if checkName then

            local rewardID = AP.locations[checkName]

            print(
                "[AP] reward ID:",
                rewardID
            )

            if rewardID then

                local reward =
                    AP.locationItems[rewardID]

                if reward then

                    AP.currentAPReward = {
                        apLocation = rewardID,
                        apItem = reward.item_name,
                        apGame = reward.game_name,
                        apPlayer = reward.player_name,
                    }

                    print(
                        "[AP] Replacing reward:",
                        reward.item_name
                    )

                    local itemDef =
                        require("items").getData("archipelagoItem")

                    itemDef.name =
                        string.format(
                            "%s\n%s\n%s",
                            reward.item_name,
                            reward.game_name,
                            reward.player_name
                        )

                    itemDef.description =
                        string.format(
                            "From %s in %s",
                            reward.player_name,
                            reward.game_name
                        )

                    drops = {
                        "archipelagoItem"
                    }

                else
                    print(
                        "[AP] No item data for:",
                        rewardID
                    )
                end

            else
                print(
                    "[AP] No AP location ID for:",
                    checkName
                )
            end

        else
            print("[AP] No check resolved")
        end

        return oldSelection(callback, drops, options)

    end

    print("[AP] Reward hook installed")

end

return M