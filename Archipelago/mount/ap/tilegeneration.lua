local M = {}

_G.unlockedLetters = persistent.archipelago.unlockedLetters

local utilsLetters = require("utils.letters")

local function isLetterUnlocked(letter)
    if not letter then return false end
    local checkLetter = letter == "QU" and "Q" or letter:upper()
    return _G.unlockedLetters[checkLetter] ~= false
end

local function getFallbackLetter(funcName)
    if funcName:lower():find("vowel") then
        return "E"
    elseif funcName:lower():find("consonant") then
        return "T"
    else
        return "E"
    end
end

local functionsToHook = {
    "getCrazyRandom",
    "getRandom",
    "getRandomConsonant",
    "getRandomFirstLetter",
    "getRandomHDiagraph",
    "getRandomHiragana",
    "getRandomLastLetter",
    "getRandomStartOrEnd",
    "getRandomVowel"
}

for _, funcName in ipairs(functionsToHook) do
    local originalFunc = utilsLetters[funcName]
    
    if originalFunc then
        utilsLetters[funcName] = function(...)
            local attempts = 0
            while attempts < 100 do
                local results = { originalFunc(...) }
                local letter = results[1]
                
                if isLetterUnlocked(letter) then
                    return unpack(results)
                end
                attempts = attempts + 1
            end
            
            return getFallbackLetter(funcName), nil, nil
        end
    end
end

return M
