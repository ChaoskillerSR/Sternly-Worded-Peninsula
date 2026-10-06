local M = {}

M.deathLinkEncounter = false

local oldGameOver
local oldEulogize

function M.installDeathHook()
    if AP.deathHookInstalled or rpg == nil or overworld == nil then
        -- if rpg == nil then
        --     print("[AP DEBUG] rpg is nil!")
        -- end
        -- if overworld == nil then
        --     print("[AP DEBUG] overworld is nil!")
        -- end
        return
    end

    print("Installing death hooks")

    oldGameOver = rpg.gameOver

    rpg.gameOver = function(self, ...)
        if not AP.isDeathLinkDeath then
            local rpgview = _G.rpgview
            local ok, config = pcall(require, "apconfig")

            local playerName = config.slot
            local enemyName = rpgview.getCurrentEnemy().name or "an Enemy"

            local deathMessage = playerName .. " was killed by " .. enemyName
            AP.last_deathlink_time = AP.client:get_server_time()
            AP.client:send_deathlink_bounce(deathMessage, playerName)
            print("Sent deathlink: ", deathMessage)
        end

        AP.isDeathLinkDeath = false

        return oldGameOver(self, ...)
    end

    local oldOnPlayerTurn = tileboard.onPlayerTurn

    tileboard.onPlayerTurn = function(turnNo)
        oldOnPlayerTurn(turnNo)

        local queue = persistent.archipelago.pendingItems

        local i = 1

        while i <= #queue do
            local queued = queue[i]
            local def = AP.items.ITEM_DEFS[queued.item]

            if def and def.isTrap then
                print("[AP] Applying trap:", def.name)

                def.apply()
                table.remove(queue, i)
            else
                i = i + 1
            end
        end

        saveFileData(
            "persistentSaveData",
            persistent
        )
    end

    AP.deathHookInstalled = true


    print("Successfully installed death/trap hooks!")
end

return M