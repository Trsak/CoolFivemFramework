local callbackValue = nil
local hasCallbackValue = false

function openInput(type, data, cb)
    callbackValue = nil
    hasCallbackValue = false

    SendNUIMessage(
        {
            action = "openInput",
            type = type,
            data = data
        }
    )

    SetNuiFocus(true, true)

    Citizen.CreateThread(
        function()
            while not hasCallbackValue do
                Citizen.Wait(100)
            end

            cb(callbackValue)
        end
    )
end

RegisterNUICallback(
    "confirmed",
    function(data, cb)
        callbackValue = data.value
        hasCallbackValue = true

        SetNuiFocus(false, false)
    end
)

RegisterNUICallback(
    "closedmenu",
    function(data, cb)
        callbackValue = nil
        hasCallbackValue = true

        SetNuiFocus(false, false)
    end
)
