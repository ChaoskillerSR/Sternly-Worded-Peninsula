local M = {}

function M.canAccessLocation(location)

    if not location.level then
        return true
    end

    if location.level == 1 or location.level == 0 then
        return true
    end

    return persistent.archipelago.level_access[location.level] == true
end

return M