local potionBagItems = require("items/potionaugmentgear")

for i = 0, 18 do
    local key = ('bagEndlessPotions%d'):format(i)
    if potionBagItems[key] then
        potionBagItems[key].archipelagoIgnoreRewardHook = true
    end
end

return potionBagItems