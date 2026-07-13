return {
    archipelagoItem = {
        name = "Archipelago Item",
        description =
            "An Archipelago item.",
        type = "passive",

        purchaseFunction = function()
            local item = AP.currentAPReward

            if not item then
                print("[AP] Missing AP reward data")
                return false
            end

            print(
                "[AP] Claiming:",
                item.apItem,
                item.apGame,
                item.apPlayer
            )

            if item.apLocation then
                AP.client.check_location(item.apLocation)
            end

            AP.currentAPReward = nil

            return true
        end,

        icon =
            "mods/archipelago/ui/graphics/items/check-32.png",

        class = {
            wayfarer = true
        },

        sources = {
            combatReward = true,
            churchStock = 'randomGear'
        },

        cost = 0,
        archipelagoItem = true
    }
}