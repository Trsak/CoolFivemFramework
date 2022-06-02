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
        for animal, data in pairs(Config.Huntable) do
            local models = {GetHashKey(data.Model)}

            exports.target:AddTargetObject(
                models,
                {
                    actions = {
                        hunting = {
                            cb = function(animData)
                                if not hunting and GetEntityHealth(animData.entity) <= 0 then
                                    hunting = true
                                    print(NetworkGetEntityIsNetworked(animData.entity))
                                    TriggerEvent(
                                        "mythic_progbar:client:progress",
                                        {
                                            name = "hunting",
                                            duration = 20000,
                                            label = "Děláš něco se srnkou",
                                            useWhileDead = false,
                                            canCancel = true,
                                            controlDisables = {
                                                disableMovement = true,
                                                disableCarMovement = true,
                                                disableMouse = false,
                                                disableCombat = true
                                            },
                                            animation = {
                                                task = "WORLD_HUMAN_GARDENER_PLANT"
                                            }
                                        },
                                        function(canceled)
                                            if not canceled then
                                                exports.notify:display(
                                                    {
                                                        type = "success",
                                                        title = "Lovení",
                                                        text = "něco si vzal z té srnky!",
                                                        icon = "fas fa-car",
                                                        length = 3000
                                                    }
                                                )
                                                DeleteEntity(animData.entity)
                                            end
                                            hunting = false
                                        end
                                    )
                                end
                            end,
                            cbData = {
                                animal = animal
                            },
                            icon = data.Icon,
                            label = data.Label
                        }
                    },
                    distance = 5.0
                }
            )
        end

        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
        end
    end
)
