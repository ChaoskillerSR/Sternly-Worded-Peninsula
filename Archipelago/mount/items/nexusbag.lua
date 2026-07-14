local utils = require ("utils.items")
local get = utils.getComponent
local moddedItemFunctions = require("mods.archipelago.mount.ap.moddeditems")

return {
    nexusSatchel = {
        name = "Nexus Satchel",

        description = "Spend a Nexus Charge to retrieve one random item.",

        type = "passive",
        
        class = {},

        sources = {
            combatReward = true,
            churchStock = 'loot'
        },

        cost = 0,

        usefulness = {
            overworld = true,
        },
        
        archipelagoItem = true,

        purchaseFunction = get'give'.gearLocking,

        icon = 'ui/graphics/items/bag-potions-7-32.png',

        highlightIf = function()
            return rpgview.getState() == "PlayerTurn"
                and moddedItemFunctions.getCurrentNexusCharges() > 0
        end,

        activateFunction = function()

            if moddedItemFunctions.getCurrentNexusCharges() <= 0 then
                return
            end

            moddedItemFunctions.setCurrentNexusCharges(
                moddedItemFunctions.getCurrentNexusCharges() - 1
            )

            local mode = getActiveMode()

            local itemFunctions = require "items"

            local pool = moddedItemFunctions.getNexusItemPool()

            local selection =
                require "ui.itemselection"(
                    function(item)

                        itemFunctions.give(item, "reward")

                        setActiveMode(mode)
                        
                        persistent.archipelago.nexus.nexusSatchelObtainedItemsList[item] = true

                        if mode.save then
                            mode:save()
                        end

                    end,

                    table.randomlyReduceDownTo(pool, 3),

                    {
                        hideInventory = true,
                        modeType = mode.type,
                        archipelagoIgnoreRewardHook = true,
                    }
                )

            setActiveMode(selection)

        end,
    }
}