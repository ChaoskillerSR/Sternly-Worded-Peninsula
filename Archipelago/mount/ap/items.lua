local M = {}

local utils = require("utils.events")

local function getClient()
    return _G.AP and _G.AP.client
end

local function getGive()
    local ok, utils = pcall(require, 'utils.items')
    if not ok or not utils then
        print("[AP] ERROR: utils.items not available")
        return nil
    end
    return utils.getComponent('give')
end

M.pendingOverworldItems = {}
local function applyWhenOverworld(fn)
    if activeModeIs'overworld' then
        fn()
    else
        table.insert(M.pendingOverworldItems, fn)
    end
end
M.applyWhenOverworld = applyWhenOverworld

M.ITEM_DEFS = {
    [1] = {
        name = "Mid Node Access",
        apply = function()
            print("[AP] Unlocked Level 4-6 locations")
            AP.state.level_access[4] = true
            AP.state.level_access[5] = true
            AP.state.level_access[6] = true

            
            persistent.archipelago.level_access =
                AP.state.level_access

            saveFileData(
                "persistentSaveData",
                persistent
            )
        end
    },

    [2] = {
        name = "Late Node Access",
        apply = function()
            print("[AP] Unlocked Level 7+ locations")
            AP.state.level_access[7] = true
            AP.state.level_access[8] = true
            AP.state.level_access[9] = true

            
            persistent.archipelago.level_access =
                AP.state.level_access

            saveFileData(
                "persistentSaveData",
                persistent
            )
        end
    },

    [3] = {
        name = "Nexus Charge",
        apply = function()
            persistent.archipelago.nexus.maxCharges =
                persistent.archipelago.nexus.maxCharges + 1

            persistent.archipelago.nexus.currentCharges =
                persistent.archipelago.nexus.currentCharges + 1

            saveFileData('persistentSaveData', persistent)
        end
    },

    [4] = {
        name = "50 Gold",
        apply = function()
            print("[AP] Applying 50 gold")

            local give = getGive()
            if not give then return end

            local goldFn = give.gold(50)
            if type(goldFn) == "function" then
                goldFn()
            else
                print("[AP] ERROR: gold() did not return a function")
            end
        end
    },

    [5] = {
        name = "200 Gold",
        apply = function()
            print("[AP] Applying 200 gold")

            local give = getGive()
            if not give then return end

            local goldFn = give.gold(200)
            if type(goldFn) == "function" then
                goldFn()
            else
                print("[AP] ERROR: gold() did not return a function")
            end
        end
    },

    [6] = {
        name = "Gear Item Slot",
        apply = function()

            persistent.archipelago.extraGearSlots =
                persistent.archipelago.extraGearSlots + 1

            saveFileData(
                "persistentSaveData",
                persistent
            )

            applyWhenOverworld(function()
                overworld.affectPlayerGearSlotCount(1)
            end)
        end
    },

    [7] = {
        name = "Heart",
        apply = function()

            persistent.archipelago.extraHearts =
                persistent.archipelago.extraHearts + 1

            saveFileData(
                "persistentSaveData",
                persistent
            )

            applyWhenOverworld(function()
                overworld.addPlayerMaxHealth(4)
            end)
        end
    },


}

function M.receive(item)
    if not item or not item.index then
        print("[AP] Invalid item received")
        return
    end

    if persistent.archipelago.receivedItems[item.index] then
        print("[AP] Duplicate ignored:", item.index)
        return
    end

    persistent.archipelago.receivedItems[item.index] = true

    local def = M.ITEM_DEFS[item.item]

    if not def then
        print("[AP] Unknown item id:", item.item)
        return
    end

    print("[AP] Receiving:", def.name, "index:", item.index)

    table.insert(
        persistent.archipelago.pendingItems,
        {
            item = item.item,
            index = item.index
        }
    )

    saveFileData(
        "persistentSaveData",
        persistent
    )
end



-- debug stuff
function M.reset()
    received = {}
    print("[AP] item history cleared")
end

-- local debug_index = 100000

-- local function give(id)
--     M.receive({
--         item = id,
--         index = debug_index
--     })

--     debug_index = debug_index + 1
-- end

-- function love.keypressed(key)
--     if key == "f1" then
--         give(1) -- Mid Node Access

--     elseif key == "f2" then
--         give(2) -- Late Node Access

--     elseif key == "f3" then
--         give(3) -- 50 Gold

--     elseif key == "f4" then
--         give(4) -- 200 Gold

--     elseif key == "f5" then
--         give(5) -- Nexus Charge

--     elseif key == "f6" then
--         give(6) -- Extra Heart

--     elseif key == "f7" then
--         give(7) -- Extra Gear Slot
--     end
-- end

return M