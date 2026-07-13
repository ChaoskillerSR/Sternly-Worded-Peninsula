local hellPortal = require("overworld.locations.hellportal")
local oldOnComplete = hellPortal.onComplete
local apGoalSent = false

hellPortal.onComplete = function(location)
    if not apGoalSent and AP and AP.client then
        apGoalSent = true
        AP.client.set_goal()
        print("[AP] Goal sent: anomaly cleared!")
    end
    return oldOnComplete(location)
end