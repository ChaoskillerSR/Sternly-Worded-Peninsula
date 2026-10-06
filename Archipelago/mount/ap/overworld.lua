print("[AP] overworld.lua loaded")

local M = {}

function M.installOverworldHooks(overworld)

    local overworldview = require("overworldview")
    local overworld = require("overworld")
    local world = require("overworld/generators/world")
    for k, v in pairs(world) do
        print(k, v)
    end
    local moddedItemFunctions = require("mods.archipelago.mount.ap.moddeditems")
    if AP.overworldHooksInstalled then return end
    AP.overworldHooksInstalled = true

    print("[AP] Installing overworld hooks")

    oldEulogize = overworld.eulogize
    
    overworld.eulogize = function(self, runSaveData, mainSaveData, modeAfterPostgame)
        local wasDeathLink = M.deathLinkEncounter

        local result = oldEulogize(self, runSaveData, mainSaveData, modeAfterPostgame)
        
        -- if mainSaveData and mainSaveData.items then
        --     print("[AP] Eulogize: Saving items to isolated mod file...")
            
        --     local transferData = {
        --         preservedItems = mainSaveData.items
        --     }
            
        --     saveFileData('archipelago_transfer', transferData)
        --     print("[AP] Items safely written to disk.")
        -- else
        --     print("[AP] Warning: mainSaveData or mainSaveData.items was nil during eulogize!")
        -- end

        if wasDeathLink then
            if mainSaveData then self:load(mainSaveData, {eulogize = true}) end
            M.deathLinkEncounter = false
        end

        return result
    end



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
    function (self, selectionStartData)
        
        local transferData = loadSaveFileData('archipelago_transfer')
    
        if transferData and transferData.preservedItems and #transferData.preservedItems > 0 then
            print("[AP] startNewGame: Found items to inject into generator structures!")
            
            if selectionStartData then
                selectionStartData.items = transferData.preservedItems
                print("[AP] Injected items into selectionStartData.")
            end
        end

        local result =
            oldStartNewGame(self, selectionStartData)

        local ok, config = pcall(require, "apconfig")

        if transferData and transferData.preservedItems and #transferData.preservedItems > 0 then
            if transferData.server == config.server then
                if self.items then
                    self.items = transferData.preservedItems
                    print("[AP] Injected items into live overworld.items table.")
                elseif self.player and self.player.items then
                    self.player.items = transferData.preservedItems
                    print("[AP] Injected items into inventory.")
                end
            else
                print("[AP] The transfer file was for a different server/port!")
            end
                     
        end

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


    local oldGenerate = world.generate
    world.generate = 
    function (...)
        local result = oldGenerate(...)

        for k, v in pairs(locationTypeData) do
            print(k, v)
        end

        print("Removing Lost Woods from world generation...")
        world.locationTypeData[lost_woods] = nil
        world.locationTypeData[corrupt_lost_woods] = nil

        for k, v in pairs(locationTypeData) do
            print(k, v)
        end

        return result
    end



    print("[AP] overworld hooks installed")
    print(
        "[AP] current player location:",
        overworldview.playerCurrentLocationKey()
    )
end

return M