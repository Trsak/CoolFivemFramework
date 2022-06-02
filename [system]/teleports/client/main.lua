local nearestPort
local showingHint = false

Citizen.CreateThread(
    function()
        while true do
            Wait(2500)
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            nearestPort = nil

            for portId, portData in each(Config.Teleports) do
                local distance = #(portData.Coords - playerCoords)

                if distance <= portData.Distance then
                    nearestPort = portId

                    if not showingHint then
                        showingHint = true
                        exports.key_hints:displayBottomHint(
                            {
                                name = "teleport",
                                key = "~INPUT_DETONATE~",
                                text = portData.Text
                            }
                        )
                    end
                end
            end

            if not nearestPort and showingHint then
                showingHint = false
                exports.key_hints:hideBottomHint({ name = "teleport" })
            end
        end
    end
)

Citizen.CreateThread(
    function()
        while true do
            Wait(1)
            if nearestPort and IsControlJustReleased(0, 47) then
                local teleport = Config.Teleports[nearestPort]

                local targetEntity = PlayerPedId()
                local vehicle = GetVehiclePedIsIn(targetEntity, false)
                if DoesEntityExist(vehicle) then
                    targetEntity = vehicle
                end

                SetEntityCoordsNoOffset(targetEntity, teleport.To, 0, 0, 1)

                nearestPort = nil
                showingHint = false
                exports.key_hints:hideBottomHint({ name = "teleport" })
            end
        end
    end
)
