local currentInstance = nil
local closestPlant = nil
local isDead = false
local isSpawned = false
local refreshCounter = 0

Citizen.CreateThread(
    function()
        Citizen.Wait(1000)

        if exports.data:getUserVar("status") == "spawned" or exports.data:getUserVar("status") == "dead" then
            isSpawned = true
            if exports.data:getUserVar("status") == "dead" then
                isDead = true
            end
        end
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned = false
        elseif status == "spawned" then
            isSpawned = true
            isDead = false
        elseif status == "dead" then
            isSpawned = true
            isDead = true
        end
    end
)

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
        currentInstance = nil
    end
)

RegisterNetEvent("weed:seedUsed")
AddEventHandler(
    "weed:seedUsed",
    function(seedTemplate)
        if not seedTemplate then
            return
        end
        exports.progressbar:startProgressBar({
            Duration = 1500,
            Label = "Zasazuješ rostlinku..",
            CanBeDead = false,
            CanCancel = true,
            DisableControls = {
                Movement = true,
                CarMovement = true,
                Mouse = false,
                Combat = true
            }
        }, function(finished)
            if finished then
                local newPlantData = {}
                newPlantData.owner = exports.data:getCharVar("id")
                newPlantData.data = {}
                newPlantData.data.Instance = currentInstance

                newPlantData.data.Gender = seedTemplate.Gender
                newPlantData.data.Quality = seedTemplate.Quality
                newPlantData.data.Growth = seedTemplate.Growth
                newPlantData.data.Water = seedTemplate.Water
                newPlantData.data.Food = seedTemplate.Food
                newPlantData.data.Stage = seedTemplate.Stage
                newPlantData.data.Item = seedTemplate.Item

                local playerPed = PlayerPedId()
                local plyPos = GetEntityCoords(playerPed)
                local hk = GetHashKey(Config.Objects[seedTemplate.Stage])
                local dmin, dmax = GetModelDimensions(hk)
                local pos = GetOffsetFromEntityInWorldCoords(playerPed, 0, dmax.y * 2.5, 0)
                local npos = { x = pos.x, y = pos.y, z = plyPos.z }
                newPlantData.data.Position = npos

                TriggerServerEvent("weed:newPlant", seedTemplate.PlantID, newPlantData)
            end
        end)
    end
)

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(1000)

            if isSpawned then
                local coords = GetEntityCoords(PlayerPedId())
                local newClosetsPlant = nil
                local closestDistance = 100.0
                local growth = 0.0

                for i, object in pairs(Config.Objects) do
                    local closeObject = GetClosestObjectOfType(coords, 1.2, GetHashKey(object), false, false, false)
                    local distance = #(coords - GetEntityCoords(closeObject))

                    if closeObject ~= 0 and DoesEntityExist(closeObject) and closestDistance > distance and NetworkGetEntityIsNetworked(closeObject) then
                        closestDistance = distance

                        if closestPlant ~= nil and closestPlant.Object == closeObject and refreshCounter < 10 then
                            refreshCounter = refreshCounter + 1
                            newClosetsPlant = closestPlant
                        else
                            refreshCounter = 0

                            local ent = Entity(closeObject)
                            growth = ent.state.Growth

                            newClosetsPlant = {
                                Id = ent.state.Id,
                                Growth = growth,
                                Quality = ent.state.Quality,
                                Water = ent.state.Water,
                                Food = ent.state.Food,
                                Position = GetEntityCoords(closeObject),
                                Object = closeObject
                            }
                        end
                    end
                end

                if closestPlant == nil and newClosetsPlant ~= nil then
                    exports.key_hints:displayBottomHint({ name = "weed_destory", key = "~INPUT_VEH_FLY_ATTACK_CAMERA~", text = "Zničit rostlinu" })

                    if growth >= 98.0 then
                        exports.key_hints:displayBottomHint({ name = "weed_pickup", key = "~INPUT_PICKUP~", text = "Sklidit rostilnu" })
                    else
                        exports.key_hints:hideBottomHint({ name = "weed_pickup" })
                    end
                elseif closestPlant ~= nil and newClosetsPlant == nil then
                    exports.key_hints:hideBottomHint({ name = "weed_pickup" })
                    exports.key_hints:hideBottomHint({ name = "weed_destory" })
                end
                closestPlant = newClosetsPlant
            end
        end
    end
)

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(1)

            if closestPlant then
                local plantText = "Stav: " ..
                    round(closestPlant.Growth) ..
                    "% | " ..
                    "Kvalita: " ..
                    round(closestPlant.Quality) ..
                    "% | " ..
                    "Hnojivo: " ..
                    round(closestPlant.Food) ..
                    "% | " .. "Voda: " .. round(closestPlant.Water) .. "%"

                DrawText3D(
                    closestPlant.Position.x,
                    closestPlant.Position.y,
                    closestPlant.Position.z + 0.2,
                    plantText
                )

                if IsControlJustReleased(1, 121) then
                    destroyPlant(closestPlant.Id)
                elseif closestPlant.Growth >= 98.0 and IsControlJustReleased(0, 38) then
                    harvestPlant(closestPlant.Id)
                end
            end
        end
    end
)

function destroyPlant(plantId)
    TaskTurnPedToFaceEntity(PlayerPedId(), closestPlant.Object, 1.0)
    exports.progressbar:startProgressBar({
        Duration = 1000,
        Label = "Ničíš rostlinku..",
        CanBeDead = false,
        CanCancel = true,
        DisableControls = {
            Movement = true,
            CarMovement = true,
            Mouse = false,
            Combat = true
        }
    }, function(finished)
        if finished then
            TriggerServerEvent("weed:destroyWeed", plantId)
        end
    end)
end

function harvestPlant(plantId)
    TaskTurnPedToFaceEntity(PlayerPedId(), closestPlant.Object, 1.0)
    exports.progressbar:startProgressBar({
        Duration = 1000,
        Label = "Sklízíš rostlinku..",
        CanBeDead = false,
        CanCancel = true,
        DisableControls = {
            Movement = true,
            CarMovement = true,
            Mouse = false,
            Combat = true
        }
    }, function(finished)
        if finished then
            TriggerServerEvent("weed:collectWeed", plantId)
        end
    end)
end

function round(number)
    return string.format("%.1f", number)
end

RegisterNetEvent("weed:actionDone")
AddEventHandler(
    "weed:actionDone",
    function()
        exports.emotes:cancelEmote()
        refreshCounter = 100
    end
)

RegisterNetEvent("weed:useItem")
AddEventHandler(
    "weed:useItem",
    function(type, quality, itemName)
        local doing = "Zaléváš"
        if type == "food" then
            doing = "Hnojíš"
        end

        if closestPlant then
            TaskTurnPedToFaceEntity(PlayerPedId(), closestPlant.Object, 1.0)
            exports.progressbar:startProgressBar({
                Duration = 500,
                Label = doing .. " rostlinku..",
                CanBeDead = false,
                CanCancel = true,
                DisableControls = {
                    Movement = true,
                    CarMovement = true,
                    Mouse = false,
                    Combat = true
                }
            }, function(finished)
                if finished then
                    if closestPlant then
                        TriggerServerEvent("weed:useItem", closestPlant.Id, type, quality, itemName)
                    end
                end
            end)
        else
            exports.notify:display(
                {
                    type = "error",
                    title = "Chyba",
                    text = "Nemáš u sebe žádnou rostlinu!",
                    icon = "fas fa-exclamation-circle",
                    length = 5000
                }
            )
        end
    end
)
