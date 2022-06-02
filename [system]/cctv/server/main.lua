AddEventHandler(
    "onResourceStart",
    function(resourceName)
        if (GetCurrentResourceName() ~= resourceName) then
            return
        end

        TriggerClientEvent(
            "cctv:client:sync",
            _source,
            {
                Info = Config.Locations,
                Blackout = blackout
            }
        )
    end
)

RegisterNetEvent("cctv:server:sync")
AddEventHandler(
    "cctv:server:sync",
    function()
        local _source = source
        local blackout = exports.powerplant:GetBlackout()
        TriggerClientEvent(
            "cctv:client:sync",
            _source,
            {
                Info = Config.Locations,
                Blackout = blackout
            }
        )
    end
)

RegisterNetEvent("cctv:server:systemHacked")
AddEventHandler(
    "cctv:server:systemHacked",
    function(building)
        Config.Locations[building].Accesable = not Config.Locations[building].Accesable
        TriggerClientEvent(
            "cctv:client:sync",
            -1,
            {
                Info = Config.Locations,
                Blackout = blackout
            }
        )
    end
)

RegisterNetEvent("powerplant:server:blackoutTrigger")
AddEventHandler(
    "powerplant:server:blackoutTrigger",
    function(state)
        blackout = state
        TriggerClientEvent(
            "cctv:client:sync",
            _source,
            {
                Info = Config.Locations,
                Blackout = blackout
            }
        )
    end
)
