print("[AP] overworld.lua loaded")

local M = {}

function M.installOverworldHooks(overworld)

    local overworldview = require("overworldview")
    local overworld = require("overworld")
    local moddedItemFunctions = require("mods.archipelago.mount.ap.moddeditems")
    if AP.overworldHooksInstalled then return end
    AP.overworldHooksInstalled = true

    print("[AP] Installing overworld hooks")

    local oldArriveAt = overworldview.arriveAt

    if not oldArriveAt then
        print("[AP] ERROR: overworld.arriveAt missing")
        return
    end
    
    overworldview.arriveAt = function(locationName, ...)
        print("[AP] arriveAt:", locationName)

        local location = overworldview.getLocation(locationName)

        if location then
            AP.currentGameLocation = {
                key = location.key,
                name = location.name,
                type = location.type,
                level = location.level,
                biome = location.biome,
                typeData = location.typeData
            }

            print(
                "[AP] current location:",
                AP.currentGameLocation.key,
                AP.currentGameLocation.type,
                AP.currentGameLocation.level
            )
        end

        return oldArriveAt(locationName, ...)
    end

    local oldCanTravelToDirect = overworldview.canTravelToDirect

    overworldview.canTravelToDirect =
    function(a,b)

        local vanilla = oldCanTravelToDirect(a,b)

        if not vanilla then
            return false
        end

        if AP.progression
        and not AP.progression.canAccessLocation(b) then

            print(
                "[AP] Blocked:",
                b.key,
                b.name,
                "level:",
                b.level
            )

            return false
        end

        return true
    end

    local oldCouldTravelBetween = overworldview.couldTravelBetween

    overworldview.couldTravelBetween =
    function(a,b)

        local vanilla = oldCouldTravelBetween(a,b)

        if not vanilla then
            return false
        end

        if AP.progression
        and not AP.progression.canAccessLocation(b) then

            print(
                "[AP] Blocked:",
                b.key,
                b.name,
                "level:",
                b.level
            )

            return false
        end

        return true
    end

    local oldStartNewGame = overworld.startNewGame
    local itemFunctions = require("mods.archipelago.mount.ap.items")


    overworld.startNewGame =
    function (...)

        local result =
            oldStartNewGame(...)

        moddedItemFunctions.setCurrentNexusCharges(
            moddedItemFunctions.getMaxNexusCharges()
        )

        local persistentAPSaveData = persistent.archipelago
        persistentAPSaveData.nexus.nexusSatchelObtainedItemsList = {}
        persistentAPSaveData.nexus.nexusSatchelObtainedItemsList['bedroll'] = true
        persistentAPSaveData.nexus.nexusSatchelObtainedItemsList['turboSnail'] = true

        itemFunctions.applyWhenOverworld(function()

            local persistentAPSaveData = persistent.archipelago

            if persistentAPSaveData.extraHearts > 0 then

                print(
                    "[AP] Restoring extra hearts:",
                    persistentAPSaveData.extraHearts
                )

                overworld.addPlayerMaxHealth(
                    persistentAPSaveData.extraHearts * 4
                )
            end


            if persistentAPSaveData.extraGearSlots > 0 then

                print(
                    "[AP] Restoring gear slots:",
                    persistentAPSaveData.extraGearSlots
                )

                overworld.affectPlayerGearSlotCount(
                    persistentAPSaveData.extraGearSlots
                )
            end

        end)


        return result
    end

    print("[AP] overworld hooks installed")
    print(
        "[AP] current player location:",
        overworldview.playerCurrentLocationKey()
    )
end

return M