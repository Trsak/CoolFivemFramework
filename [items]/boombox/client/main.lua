local isSpawned, isDead = false, false

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned = false
        elseif status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
        end
    end
)

Citizen.CreateThread(
    function()
        Citizen.Wait(500)
        local boomboxes = {
            GetHashKey("prop_boombox_01"),
            GetHashKey("prop_ghettoblast_02")
        }
        exports.target:AddTargetObject(
            boomboxes,
            {
                actions = {
                    playMusic = {
                        cb = function(boomboxData)
                            local id = "boombox-" .. NetworkGetNetworkIdFromEntity(boomboxData.entity)
                            exports.input:openInput(
                                "text",
                                {
                                    title = "Zadejte Youtube ID videa (nocopyright)",
                                    placeholder = "https://www.youtube.com/watch?v=(XE1sVe60j1U) <-- Toto"
                                },
                                function(videoID)
                                    if videoID then
                                        TriggerServerEvent(
                                            "sound:playYoutubeSound",
                                            videoID,
                                            15.0,
                                            GetEntityCoords(boomboxData.entity),
                                            id
                                        )
                                    end
                                end
                            )
                        end,
                        icon = "fas fa-play",
                        label = "Pustit hudbu"
                    },
                    playRadio = {
                        cb = function(boomboxData)

                            TriggerServerEvent(
                                "sound:playRadio",
                                "weazel",
                                15.0,
                                GetEntityCoords(boomboxData.entity),
                                id
                            )
                        end,
                        icon = "fas fa-podcast",
                        label = "Pustit Gans Radio LS by Weazel"
                    },
                    stopMusic = {
                        cb = function(boomboxData)
                            local id = "boombox-" .. NetworkGetNetworkIdFromEntity(boomboxData.entity)
                            TriggerServerEvent("sound:stopSound", id)
                        end,
                        icon = "fas fa-stop",
                        label = "Zastavit hudbu"
                    },
                    takeFromGround = {
                        cb = function(boomboxData)
                            local id = "boombox-" .. NetworkGetNetworkIdFromEntity(boomboxData.entity)
                            NetworkRequestControlOfEntity(boomboxData.entity)
                            startAnimation("anim@heists@narcotics@trash", "pickup")

                            Citizen.Wait(700)

                            SetEntityAsMissionEntity(boomboxData.entity, false, true)
                            DeleteEntity(boomboxData.entity)

                            TriggerServerEvent("sound:stopSound", id)
                            if not DoesEntityExist(boomboxData.entity) then
                                TriggerServerEvent("boombox:takeFromGround")
                                closestBoombox = nil
                                showingBoomboxHint = false
                                exports.key_hints:hideHint({name = "boombox"})
                            end

                            Citizen.Wait(500)
                            ClearPedTasks(PlayerPedId())
                        end,
                        icon = "fas fa-box",
                        label = "Vzít ze země"
                    }
                },
                distance = 5.0
            }
        )

        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
        end
    end
)

RegisterNetEvent("boombox:place")
AddEventHandler(
    "boombox:place",
    function()
        local pPed = PlayerPedId()
        startAnimation("anim@heists@money_grab@briefcase", "put_down_case")
        Citizen.Wait(1000)
        ClearPedTasks(pPed)

        local model = GetHashKey("prop_boombox_01")
        local coords = GetEntityCoords(pPed)

        while not HasModelLoaded(model) do
            RequestModel(model)
            Citizen.Wait(0)
        end

        local position = GetOffsetFromEntityInWorldCoords(pPed, 1, 0.5, -0.98)

        local object = CreateObject(model, position, true, true, true)
        SetEntityHeading(object, GetEntityHeading(pPed))
    end
)

function startAnimation(lib, anim)
    while not HasAnimDictLoaded(lib) do
        RequestAnimDict(lib)
        Citizen.Wait(1)
    end
    TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 1, 0, false, false, false)
end
