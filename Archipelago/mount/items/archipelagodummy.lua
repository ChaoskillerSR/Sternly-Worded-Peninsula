return {
    archipelagoPlaceholder = {
        name = "AP Dummy Item",
        type = "passive",

        class = {
            wayfarer = true,
        },

        sources = {
            combatReward = true,
            churchStock = 'loot'
        },
        
        cost = 0,

        archipelagoItem = true,

        purchaseFunction = function ()
            print("sampletext")
        end,

        icon = "mods/archipelago/ui/graphics/items/check-10.png",

        description = 'If you see this item in a rewards screen instead of the almanac, I have messed up.',
    }
}