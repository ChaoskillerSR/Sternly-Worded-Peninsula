return {

    nexusCharge = {

        name = "Nexus Charge",

        description = "A mysterious power that allows an item to be withdrawn from the Nexus Satchel. Nexus Charges persist between runs.",

        type = "passive",

        purchaseFunction = function()
            print("Nexus Charge obtained!")
            persistent.archipelago.nexus.maxCharges = persistent.archipelago.nexus.maxCharges + 1
            persistent.archipelago.nexus.currentCharges = persistent.archipelago.nexus.currentCharges + 1
            saveFileData('persistentSaveData', persistent)
        end,

        icon = "mods/archipelago/ui/graphics/items/check-32.png",

        class = {
            wayfarer = true
        },

        sources = {
            combatReward = true,
            churchStock = 'loot'
        },

        cost = 0,

        archipelagoItem = true

    }

}