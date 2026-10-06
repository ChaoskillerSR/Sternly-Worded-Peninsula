local dllPath = os.getenv("APPDATA")
    .. "\\SternlyWordedAdventures\\mods\\Archipelago\\mount\\ap\\lua-apclientpp\\?.dll"

package.cpath = package.cpath .. ";" .. dllPath

local base = os.getenv("APPDATA")
    .. "\\SternlyWordedAdventures\\mods\\Archipelago\\mount\\ap"

package.path = package.path .. ";" .. base .. "\\?.lua"

local APClient = require("lua-apclientpp")
local ok, config = pcall(require, "apconfig")

if not ok then
    error("Missing apconfig.lua")
end

local client = APClient("swa_test", "Sternly Worded Adventures", config.server)

local mt = getmetatable(client)

local deathlink = require("mods.archipelago.mount.ap.deathlink")

print("ClientStatus:")
for k, v in pairs(mt.ClientStatus) do
    print(k, v)
end

local function S()
    return _G.AP and _G.AP.state
end

function isDeathlinkOn(slot_data)
    if slot_data.options.death_link == 1 and config.overrideDeathlink == false then
        print("Deathlink is enabled!")
        AP.deathlink_enabled = true
        return true
    end
    print("Deathlink is NOT enabled!")
    AP.deathlink_enabled = false
    return false
end

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
    print("slot_data:")
    for k, v in pairs(slot_data) do
        print(k, v)
    end

    print()

    for k, v in pairs(slot_data.unlocked_letters) do
        print(k, v)
    end

    persistent.archipelago.unlockedLetters = persistent.archipelago.unlockedLetters or slot_data.unlocked_letters
    saveFileData("persistentSaveData", persistent)


    local tags = {"Lua-APClientPP"}
    if isDeathlinkOn(slot_data) then
        tags[#tags + 1] = "DeathLink"
    end

    state.connected = true
    state.slot_data = slot_data

    AP.loadSlotData()

    client:ConnectUpdate(7, tags)
end)


client:set_items_received_handler(function(items)
    print("RAW ITEM CALLBACK FIRED", #items)

    for _, item in ipairs(items) do
        AP.items.receive(item)
    end
end)

function on_bounced(bounce)
    if AP.last_deathlink_time ~= nil and tostring(AP.last_deathlink_time) == tostring(bounce.data.time) then
        print("Own deathlink, ignoring.")
        return
    end

    local has_deathlink_tag = false
    for _, tag in ipairs(bounce.tags or {}) do
        if tag == "DeathLink" then
            has_deathlink_tag = true
            break
        end
    end

    if has_deathlink_tag and bounce.data.time then
        AP.isDeathLinkDeath = true
        AP.deathlink_received = true
        print("Received deathlink!")
    end
end

client:set_bounced_handler(on_bounced)

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

function client.send_deathlink_bounce(cause, source)
    cause = cause or "Sternly Worded Adventures"
    source = source or config.slot or "Sternly Worded Adventures Player"
    local time = client.get_server_time()
    client:Bounce({
        time = time,
        cause = cause,
        source = source
    }, {}, {}, {"DeathLink"})
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
    end,

    send_deathlink_bounce = function(cause, source)
        cause = cause or "Sternly Worded Adventures"
        source = source or config.slot or "Sternly Worded Adventures Player"
        local time = client:get_server_time()
        client:Bounce({
            time = time,
            cause = cause,
            source = source
        }, {}, {}, {"DeathLink"})
    end,

    get_server_time = function()
        client:get_server_time()
    end
}