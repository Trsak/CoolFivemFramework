local currentInstance = ""

RegisterNetEvent("instance:onEnter")
AddEventHandler(
    "instance:onEnter",
    function(instance)
        currentInstance = instance
    end
)

RegisterNetEvent("instance:onLeave")
AddEventHandler(
    "instance:onLeave",
    function()
        currentInstance = ""
    end
)

function getPlayerInstance()
    return currentInstance
end