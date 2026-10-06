local hellPortal = require("overworld.locations.hellportal")
local oldOnComplete = hellPortal.onComplete
local apGoalSent = false

hellPortal.onComplete = function(location)
    if not apGoalSent and AP and AP.client then
        apGoalSent = true
        AP.client.set_goal()
        print("[AP] Goal sent: anomaly cleared!")
    else
        print("apGoalSent: ", apGoalSent)
        print("AP variable: ", AP)
        print("AP.client variable: ", AP.client)
        print("[AP] One of the requirements to release has not been met!")
    end
    return oldOnComplete(location)
end

package.loaded["overworld.locations.hellportal"] = hellPortal
