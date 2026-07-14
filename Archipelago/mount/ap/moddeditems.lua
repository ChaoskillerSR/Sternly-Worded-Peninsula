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

local cachedPool

function M.invalidateNexusPool()
    cachedPool = nil
end

function M.getNexusItemPool()

    local items = require "items"

    if not cachedPool then
        items.regenerateGearLists(true)

        cachedPool = {}

        local function addItems(list)
            for _, name in ipairs(list) do
                local item = items.getData(name)

                if item
                and not item.archipelagoItem
                and item.sortsubtype ~= "curse"
                and item.type ~= "ephemeral"
                and not item.overworldData
                and not (item.craft and item.craft.recipe == "consumableMerge")
                and not item.boardData
                and item.purchaseFunction then

                    local include = true

                    if item.variantOf then
                        include = (name == item.variantOf .. "0")
                    end

                    if include then
                        table.insert(cachedPool, name)
                    end
                end
            end
        end

        addItems(items.getAllPermanentItemNames())
        addItems(items.getAllOtherItemNames())
    end

    -- Build the current pool by filtering the cached base pool.
    local pool = {}

    for _, name in ipairs(cachedPool) do
        if not persistent.archipelago.nexus.nexusSatchelObtainedItemsList[name] then
            table.insert(pool, name)
        end
    end

    return pool
end

return M