local MOD_ROOT = os.getenv("APPDATA") ..
    "\\SternlyWordedAdventures\\mods\\Archipelago\\mount\\"

local f = assert(io.open(MOD_ROOT .. "ap\\bootstrap.lua", "rb"))
local chunk = assert(loadstring(f:read("*a")))
f:close()
chunk()

package.path = package.path
    .. ";mods/Archipelago/mount/?.lua"






-- local installed = false
-- local oldUpdate = love.update

-- love.update = function(dt)
--     if not installed then
--         installed = true

--         local items = require("items")

--         local oldGive = items.give

--         items.give = function(item, source, ...)
--             print(item, source)
--             return oldGive(item, source, ...)
--         end
--     end

--     return oldUpdate(dt)
-- end

return {}
