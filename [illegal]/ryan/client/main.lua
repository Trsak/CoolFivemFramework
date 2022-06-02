RegisterNetEvent("ryan:enteredArea")
AddEventHandler("ryan:enteredArea", function(netId)
    local ryanPed = NetToPed(netId)
    if DoesEntityExist(ryanPed) then
        exports["target"]:AddTargetObject({ GetHashKey("mp_f_freemode_01") }, {
            actions = {
                ryan_shop = {
                    cb = function(data)
                        TriggerServerEvent("base_shops:openSpecialShop", "Ryan")
                    end,
                    cbData = {},
                    icon = "game-icon game-icon-machine-gun-magazine",
                    label = "Zobrazit nabídku Ryan",
                }
            },
            id = ryanPed,
            distance = 1.5
        })

        applyPedConfig(ryanPed)
    end
end
)

RegisterNetEvent("ryan:markPosition")
AddEventHandler("ryan:markPosition", function(position, isSpawned)
    SetNewWaypoint(position.x, position.y)

    if isSpawned then
        exports.notify:display(
            {
                type = "success",
                title = "Ryan",
                text = "Ryan již prodává, nastavila jsem ti GPS na její pozici",
                icon = "game-icon game-icon-machine-gun-magazine",
                length = 6000
            }
        )
    else
        exports.notify:display(
            {
                type = "info",
                title = "Ryan",
                text = "Ryan začne v blízké době prodávat, nastavila jsem ti GPS na její pozici",
                icon = "game-icon game-icon-machine-gun-magazine",
                length = 6000
            }
        )
    end
end
)