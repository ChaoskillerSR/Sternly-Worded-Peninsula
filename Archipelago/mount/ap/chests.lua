local overworldview = require("overworldview")
local overworld = require("overworld")

local oldStartNewRun =
    overworld.startNewRun


function overworld.startNewRun(
    scenario,
    setupAndReturnModeOnly
)

    print("[AP] STARTNEWRUN CALLED")
    local location =
        overworldview.playerCurrentLocation()


    local locationName =
        location.name


    local apID =
        AP.locations[locationName]


    if apID then

        print(
            "[AP] Chest registered:",
            locationName,
            apID
        )


        AP.pendingLocation =
            apID

    else

        AP.pendingLocation = nil

    end


    return oldStartNewRun(
        scenario,
        setupAndReturnModeOnly
    )

end