local IsNotLoaded = true
local currentInstance = ""

Citizen.CreateThread(
    function()
        Citizen.Wait(500)

        if exports.data:getUserVar("status") == "spawned" or exports.data:getUserVar("status") == "dead" then
            IsNotLoaded = false
        end

        currentInstance = exports.instance:getPlayerInstance()
        updatePlayerInstance()
        --print(NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(PlayerPedId())))
        --TriggerServerEvent("sound:playYoutubeSound", "SVJENXqb388", 60.0, GetEntityCoords(PlayerPedId()), "test", nil, 99)
        while true do
            if not IsNotLoaded then
                local coords = GetEntityCoords(PlayerPedId())
                SendNUIMessage(
                    {
                        action = "updatePlayerCoords",
                        coords = { ["x"] = coords.x, ["y"] = coords.y, ["z"] = coords.z },
                        heading = GetEntityHeading(PlayerPedId())
                    }
                )
            end

            Citizen.Wait(200)
        end
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isNotLoaded = true
        elseif (status == "spawned" or status == "dead") and IsNotLoaded then
            IsNotLoaded = false
        end
    end
)

RegisterNetEvent("instance:onEnter")
AddEventHandler(
    "instance:onEnter",
    function(instance)
        currentInstance = instance
        updatePlayerInstance()
    end
)

RegisterNetEvent("instance:onLeave")
AddEventHandler(
    "instance:onLeave",
    function()
        currentInstance = ""
        updatePlayerInstance()
    end
)

RegisterNetEvent("sound:playSound")
AddEventHandler(
    "sound:playSound",
    function(sound, maxDistance, coords, id, instance)
        if IsNotLoaded then
            return
        end

        SendNUIMessage(
            {
                action = "playSound",
                sound = sound,
                coords = { ["x"] = coords.x, ["y"] = coords.y, ["z"] = coords.z },
                maxDistance = maxDistance,
                id = id,
                instance = instance
            }
        )
    end
)

RegisterNetEvent("sound:playYoutubeSound")
AddEventHandler(
    "sound:playYoutubeSound",
    function(video, maxDistance, coords, id, instance)
        if IsNotLoaded then
            return
        end

        SendNUIMessage(
            {
                action = "playYoutubeSound",
                video = video,
                coords = { ["x"] = coords.x, ["y"] = coords.y, ["z"] = coords.z },
                maxDistance = maxDistance,
                id = id,
                instance = instance
            }
        )
    end
)

RegisterNetEvent("sound:playRadio")
AddEventHandler(
    "sound:playRadio",
    function(radio, maxDistance, coords, id, instance)
        if IsNotLoaded then
            return
        end

        SendNUIMessage(
            {
                action = "playRadio",
                radio = radio,
                coords = { ["x"] = coords.x, ["y"] = coords.y, ["z"] = coords.z },
                maxDistance = maxDistance,
                id = id,
                instance = instance
            }
        )
    end
)

RegisterNetEvent("sound:stopSound")
AddEventHandler(
    "sound:stopSound",
    function(id)
        if IsNotLoaded then
            return
        end

        SendNUIMessage(
            {
                action = "stopSound",
                id = id
            }
        )
    end
)

RegisterNetEvent("sound:updateAudioCoords")
AddEventHandler(
        "sound:updateAudioCoords",
        function(id, coords)
            if IsNotLoaded then
                return
            end
            
            SendNUIMessage(
                    {
                        action = "updateAudioCoords",
                        id = id,
                        coords = { ["x"] = coords.x, ["y"] = coords.y, ["z"] = coords.z },
                    }
            )
        end
)

function updatePlayerInstance()
    if currentInstance == " " or not currentInstance then
        currentInstance = ""
    end
    SendNUIMessage(
        {
            action = "updatePlayerInstance",
            instance = currentInstance
        }
    )
end