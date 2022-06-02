local TE, TCE, TSE, RNE, RSE, AEH, CCT, SNM, RNC = TriggerEvent, TriggerClientEvent, TriggerServerEvent, RegisterNetEvent, RegisterNetEvent, AddEventHandler, Citizen.CreateThread, SendNUIMessage, RegisterNUICallback
local pref = Config

CCT(function()
        CCT(function()
            while true do
                Citizen.Wait(300)

            end
        end)
end)

SetNuiFocus(false, false)

RNC('close', function()
    SetNuiFocus(false, false)
    SNM({ action = "close" })
end)

RegisterCommand('insurance', function(source, args)
    SetNuiFocus(true, true)
    SNM({ action = "open" })
end, false)

RegisterCommand('insurancec', function(source, args)
    SetNuiFocus(false, false)
    SNM({ action = "close" })
end, false)