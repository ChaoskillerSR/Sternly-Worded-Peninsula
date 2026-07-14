local M = {}

function M.getCurrentNexusCharges()
    return persistent.archipelago.nexus.currentCharges or 0
end

function M.getMaxNexusCharges()
    return persistent.archipelago.nexus.maxCharges or 0
end

function M.setCurrentNexusCharges(value)
    persistent.archipelago.nexus.currentCharges = value

    saveFileData('persistentSaveData', persistent)
end

function M.getNexusItemPool()

    local items = require "items"

    local pool = {}

    for _, name in ipairs(items.getAllItemNames()) do

        local item = items.getData(name)

        if item then

            local validType =
                item.type == "gear"
                or item.type == "passive"
                or item.type == "consumable"

            if validType
            and not item.variantOf
            and not item.archipelagoItem
            and item.sortsubtype ~= "curse"
            and item.purchaseFunction then

                table.insert(pool, name)

            end
        end
    end

    return pool
end

return M