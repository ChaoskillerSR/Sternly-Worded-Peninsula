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

    if not location then
        return nil
    end

    if location.type == "crypt" then
        return AP.resolveCheckName(location)
    end

    if location.type == "chest" and location.parentNode then

        local parent = location.parentNode

        if parent.type == "pine_spider_forest"
        or parent.type == "corrupt_pine_spider_forest"
        or parent.type == "corrupt_oak_spider_forest"
        or parent.type == "oak_spider_forest" then

            return AP.resolveCheckName(parent)

        elseif parent.type == "bandit_camp_pine"
        or parent.type == "corrupt_bandit_camp_oak"
        or parent.type == "corrupt_bandit_camp_pine"
        or parent.type == "bandit_camp_oak" then

            return AP.resolveCheckName(parent)
        end
    end

    if AP.currentCombatReward then
        local check, key = AP.resolveCheckName()

        if check then
            persistent.archipelago.currentCombatCheck = check
            persistent.archipelago.currentCombatKey = key
            saveFileData("persistentSaveData", persistent)
            return check
        end

        return persistent.archipelago.currentCombatCheck
    end


    if location.type == "chapel_ruin"
    or location.type == "tomb" then
        return AP.resolveCheckName(location)
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
        
        local checkName, counterKey = getCurrentCheck()

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
                    
                    local count = persistent.archipelago.nexus.checks[counterKey] or 0

                    count = count + 1

                    local originalCallback = callback 
                        callback = function(...)
                            print("[AP] Selection screen closed. Updating value now!")
                            if counterKey then
                                persistent.archipelago.nexus.checks[counterKey] = count

                                saveFileData(
                                    "persistentSaveData",
                                    persistent
                                )
                            end
                            
                            if type(originalCallback) == "function" then
                                return originalCallback(...)
                                
                            elseif type(originalCallback) == "table" then
                                local item = ...
                                
                                if originalCallback.type or originalCallback.save or originalCallback.getUserFunctions then
                                    local mode = originalCallback
                                    require 'overworld'
                                    require 'items'.give(item, 'reward')
                                    if options and options.bonuses and options.bonuses[item] then
                                        for i, bonusItem in ipairs(options.bonuses[item]) do
                                            require 'items'.give(bonusItem, 'bonus')
                                        end
                                    end
                                    setActiveMode(mode)
                                    if mode.save then
                                        mode:save()
                                    end
                                    return true
                                else
                                    return true
                                end
                                
                            else
                                return true
                            end
                        end


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