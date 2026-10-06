local classesUtils = require'utils.classes'
local oldStartEulogyConfirm = classesUtils.startEulogyConfirm

classesUtils.startEulogyConfirm = function(existingSave, newClassData, startFun)
    print("[AP] Intercepted startEulogyConfirm! Backing up items immediately...")

    local freshMainSave = loadSaveFileData('mainSaveData')
    local ok, config = pcall(require, "apconfig")

    if freshMainSave and freshMainSave.items then
        print("[AP] Found items in fresh file read! Archiving...")
        local transferData = {
            server = config.server,
            preservedItems = {}
        }
        for _, item in ipairs(freshMainSave.items) do
            print("[AP] Safeguarding item:", item)
            table.insert(transferData.preservedItems, item)
        end
        
        saveFileData('archipelago_transfer', transferData)
        print("[AP] Isolated backup file written perfectly.")
    else
        print("[AP] Warning: No items found on a raw disk read during confirmation!")
    end

    return oldStartEulogyConfirm(existingSave, newClassData, startFun)
end
