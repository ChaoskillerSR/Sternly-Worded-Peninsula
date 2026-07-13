return {
    key = 'wayfarer',
    article = 'a',
    name = 'Wayfarer',
    sprite = 'rpg/sprites/assassin.lua',
    nameGen = require'rpg.names.adventurer',
    index = 10,
    icon = love.graphics.newImage'ui/graphics/icons/classes/assassin.png',
    categories = {
        'human',
        'adult',
    },
    color = {158/255,14/255,48/255},
    colors = {
        iris = {141/255,  18/255,  84/255},
        skin = {238/255, 195/255, 154/255},
        hair = {143/255,  63/255,  24/255},
        doublet = {138/255, 92/255, 78/255},
        robe = {158/255,  14/255,  48/255},
        pants= { 41/255,  32/255,  32/255},
    },
    hsls = {
        iris = {328, 0.87, 0.55},
        skin = {29,  0.35, 0.93},
        hair = {20,  0.83, 0.56},
        doublet = {14, 0.43, 0.54},
        robe = {346, 0.91, 0.62},
        pants= {0,   0.22, 0.16},
    },
    colorConfigOrder = {
        'hair',
        'robe',
        'skin',
        'doublet',
        'iris',
        'pants',
    },
    colorConfigDisplayNames = {
        'Hair',
        'Shirt',
        'Skin',
        'Top',
        'Eyes',
        'Trews',
    },
    colorConfigVariantEnabled = {
        hair = 4,
    },
    visualFlags = {
        'hair_ponytail',
        'hair_ponytail_hat',
    },
    visualHash = {
        hair_ponytail = true,
        hair_ponytail_hat = true,
    },
    colourRandomiser = require'utils.colours'.assassin,
    unlocked = true,
    available = true,
    availableMessageShort = 'Adventure!',
    startAchievement = 'ach_startAsAdventurer',
    anomalyAchievement = 'ach_anomalyAsAdventurer',
    newGameData = function()
        return {
            player = {
                health = 12,
                maxHealth = 12,
                class = 'wayfarer',
            },
            items = {
            },
            passives = {
                'capitalPassport',
                'turboSnail',
                'bedroll',
                'nexusSatchel'
            },
            potentialBoons = {
            },
        }
    end,
}
