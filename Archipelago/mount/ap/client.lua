local dllPath = os.getenv("APPDATA")
    .. "\\SternlyWordedAdventures\\mods\\Archipelago\\mount\\ap\\lua-apclientpp\\?.dll"

package.cpath = package.cpath .. ";" .. dllPath

local APClient = require("lua-apclientpp")
local ok, config = pcall(require, "apconfig")

if not ok then
    error("Missing archipelago_config.lua")
end

local client = APClient("swa_test", "Sternly Worded Adventures", config.server)

local mt = getmetatable(client)

print("ClientStatus:")
for k, v in pairs(mt.ClientStatus) do
    print(k, v)
end

local function S()
    return _G.AP and _G.AP.state
end

-------------------------------------------------
-- CALLBACKS
-------------------------------------------------

client:set_socket_connected_handler(function()
    print("AP socket connected")
end)

client:set_room_info_handler(function()
    print("AP room info received")
    client:ConnectSlot(config.slot, config.password, 7, {"Lua-APClientPP"}, {})
end)

client:set_slot_connected_handler(function(slot_data)
    local state = _G.AP and _G.AP.state
    if not state then return end

    print("SLOT CONNECTED (RAW)")
    print("slot_data:", slot_data)

    state.connected = true
    state.slot_data = slot_data

    AP.loadSlotData()

    -- CRITICAL: confirm assignment
    -- print("STATE UPDATED")
    -- print("connected:", S().connected)
    -- print("slot_data:")
    -- for k, v in pairs(S().slot_data) do
    --     if k == "locations" then
    --         print("locations")
    --         for subKey, subValue in pairs(v) do
    --             print(subKey, subValue)
    --         end
    --     elseif k == "location_items" then
    --         print("location_data")
    --         for subKey, subValue in pairs(v) do
    --             print(subKey, subValue)
    --         end
    --     else do
    --         print(k, v)
    --     end
    --     end
    -- end

    -- DO NOT pass table if your build errors on it
    client:ConnectUpdate(7, {"Lua-APClientPP"})
end)

client:set_items_received_handler(function(items)
    print("RAW ITEM CALLBACK FIRED", #items)

    for _, item in ipairs(items) do
        -- print("-----")
        -- for k, v in pairs(item) do
        --     print(k, v)
        -- end
        AP.items.receive(item)
    end
end)

-------------------------------------------------
-- API
-------------------------------------------------

function client.check_location(id)
    print("Checking location:", id)
    client:LocationChecks({id})
end

function client.has_received(index)
    return S().items_received[index] == true
end

function client.mark_received(index)
    local state = _G.AP and _G.AP.state
    if state then
        state.items_received[index] = true
    end
end

client.check_location = nil

return {
    raw = client,

    check_location = function(id)
        print("Checking location:", id)
        client:LocationChecks({id})
    end,

    poll = function()
        client:poll()
    end,

    has_received = function(index)
        return S().items_received[index] == true
    end,

    mark_received = function(index)
        local state = _G.AP and _G.AP.state
        if state then
            state.items_received[index] = true
        end
    end,

    set_goal = function()
        client:StatusUpdate(client.ClientStatus.GOAL)
    end
}