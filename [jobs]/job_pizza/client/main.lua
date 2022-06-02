local isSpawned, isDead = false, false
local vehicles, customers = {}, {}
local showBlip, buddyBlip = true, nil

local vehData = {}

Citizen.CreateThread(function()
    Citizen.Wait(500)

    local status = exports.data:getUserVar("status")
    if status == "spawned" or status == "dead" then
        isSpawned = true
        isDead = (status == "dead")
        TriggerServerEvent("job_pizza:sync")
    end

    exports.target:AddCircleZone("pizzaMaster", Config.Pizzeria.Coords.xyz, 1.0, {
        actions = {
            job = {
                cb = function()
                    if not WarMenu.IsAnyMenuOpened() then
                        if exports.license:hasLicense(Config.licenseNeeded, true) then
                            openMenu()
                        else
                            exports.notify:display({
                                type = "error",
                                title = "Pizza This...",
                                text = "Nemáte řidičské oprávnění skupiny " .. Config.licenseNeeded,
                                icon = "fas fa-utensils",
                                length = 3000
                            })
                        end
                    end
                end,
                icon = "fas fa-utensils",
                label = "Oslovit slečnu"
            }
        },
        distance = 0.2
    })

    checkMisc()
end)

RegisterNetEvent("s:statusUpdated")
AddEventHandler("s:statusUpdated", function(status)
    if status == "choosing" then
        isSpawned = false
    elseif status == "spawned" or status == "dead" then
        isDead = (status == "dead")

        if not isSpawned then
            isSpawned = true
            checkMisc()
            TriggerServerEvent("job_pizza:sync")
        end
    end
end)

RegisterNetEvent("job_pizza:sync")
AddEventHandler("job_pizza:sync", function(serverVehs, serverCust)
    vehicles = serverVehs
    customers = serverCust
end)

function openMenu()
    Citizen.CreateThread(function()
        WarMenu.CreateMenu("post", "Pizza This...", "Zvolte akci")
        WarMenu.OpenMenu("post")

        if not vehData.VehId then
            while true do
                if WarMenu.IsMenuOpened("post") then
                    if WarMenu.Button("Nové vozidlo") then
                        if isVehPlaceClean() then
                            TriggerServerEvent("job_pizza:createNewVehicle")
                            WarMenu.CloseMenu()
                        else
                            exports.notify:display({
                                type = "error",
                                title = "Pizza This...",
                                text = "Momentálně není nikde místo pro další vozidlo..",
                                icon = "fas fa-utensils",
                                length = 3000
                            })
                        end
                    elseif WarMenu.Button("Zavřít") then
                        WarMenu.CloseMenu()
                    end
                    WarMenu.Display()
                else
                    break
                end

                Citizen.Wait(0)
            end
        else
            while true do
                if WarMenu.IsMenuOpened("post") then
                    if vehicles[vehData.VehId].Players[1] == GetPlayerServerId(PlayerId()) then
                        if WarMenu.Button("Nabrat kámoše") then
                            if tableLength(vehicles[vehData.VehId].Players) < 2 then
                                WarMenu.CloseMenu()
                                Citizen.Wait(10)
                                TriggerEvent("util:closestPlayer", {
                                    radius = 2.0
                                }, function(player)
                                    if player then
                                        TriggerServerEvent("job_pizza:addPlayerToVeh", vehData, player)
                                    end
                                end)
                            else
                                exports.notify:display({
                                    type = "error",
                                    title = "Pizza This...",
                                    text = "Už u sebe máš plno!",
                                    icon = "fas fa-utensils",
                                    length = 3000
                                })
                            end
                        end
                    end
                    if WarMenu.Button("Ukončit práci") then
                        TriggerServerEvent("job_pizza:endJob", vehData.VehId)
                        WarMenu.CloseMenu()
                    elseif WarMenu.Button("Vzít salámovou pizzu") then
                        takePackages("salami")
                    elseif WarMenu.Button("Vzít šunkovou pizzu") then
                        takePackages("ham")
                    elseif WarMenu.Button("Vzít sýrovou pizzu") then
                        takePackages("cheese")
                    elseif WarMenu.Button("Zavřít") then
                        WarMenu.CloseMenu()
                    end
                    WarMenu.Display()
                else
                    break
                end

                Citizen.Wait(0)
            end
        end
    end)
end

RegisterNetEvent("job_pizza:startWork")
AddEventHandler("job_pizza:startWork", function(vehId)
    if spawnVehicle(vehId) == "done" then
        exports.notify:display({
            type = "success",
            title = "Pizza This...",
            text = "Dostal jsi vozidlo s SPZ " .. vehData.Plate .. ".",
            icon = "fas fa-utensils",
            length = 3000
        })
        startWork(vehId)
    end
end)

function startWork(vehId)
    exports.target:AddCircleZone("post_delivery", customers[vehicles[vehId].Current.Id].Coords.xyz, 1.0, {
        actions = {
            deliver = {
                cb = function(delivery)
                    TriggerServerEvent("job_pizza:deliveryPackage", delivery.Id)
                end,
                cbData = {
                    Id = vehId
                },
                icon = "fas fa-utensils",
                label = "Odevzdat zásilku"
            }
        },
        distance = 0.2
    })
    blip = createNewBlip({
        coords = customers[vehicles[vehId].Current.Id].Coords.xyz,
        sprite = 280,
        display = 4,
        scale = 0.7,
        colour = 24,
        isShortRange = true,
        text = "Zákazník - " .. exports.inventory:getItem(vehicles[vehId].Current.Type).label
    })
    SetNewWaypoint(customers[vehicles[vehId].Current.Id].Coords)
end

RegisterNetEvent("job_pizza:nextDelivery")
AddEventHandler("job_pizza:nextDelivery", function(vehId)
    local item = string.lower(exports.inventory:getItem(vehicles[vehId].Current.Type).label)
    exports.notify:display({
        type = "success",
        title = "Pizza This...",
        text = "Jeďte na další místo! Chtějí " .. item,
        icon = "fas fa-utensils",
        length = 4000
    })
    exports.target:AddCircleZone("post_delivery", customers[vehicles[vehId].Current.Id].Coords.xyz, 1.0, {
        actions = {
            deliver = {
                cb = function(delivery)
                    TriggerServerEvent("job_pizza:deliveryPackage", delivery.Id)
                end,
                cbData = {
                    Id = vehId
                },
                icon = "fas fa-utensils",
                label = "Odevzdat zásilku"
            }
        },
        distance = 0.2
    })
    SetBlipCoords(blip, customers[vehicles[vehId].Current.Id].Coords.xyz)
    renameExistingBlip({
        blip = blip,
        text = "Zákazník - " .. item
    })
    SetNewWaypoint(customers[vehicles[vehId].Current.Id].Coords)
end)

RegisterNetEvent("job_pizza:noMoreDelivery")
AddEventHandler("job_pizza:noMoreDelivery", function()
    exports.notify:display({
        type = "error",
        title = "Pizza This...",
        text = "Nemáme již žádné zakázky. Vrať se zpátky.",
        icon = "fas fa-utensils",
        length = 4000
    })
    exports.target:RemoveZone("post_delivery")
    RemoveBlip(blip)
end)

RegisterNetEvent("job_pizza:AddPlayerToVeh")
AddEventHandler("job_pizza:AddPlayerToVeh", function(newVehData)
    if not vehData.VehId then
        vehData = newVehData
        startWork(vehData.VehId)
        exports.notify:display({
            type = "success",
            title = "Pizza This...",
            text = "Kámoš tě přidal! Máš SPZ " .. vehData.Plate .. ".",
            icon = "fas fa-utensils",
            length = 3000
        })
    end
end)

RegisterNetEvent("job_pizza:endJob")
AddEventHandler("job_pizza:endJob", function()
    if vehData.VehId then
        RemoveBlip(blip)
        exports.target:RemoveZone("post_delivery")
        vehData = {
            NetId = nil,
            Plate = nil,
            VehId = nil
        }
        if savedOutfit then
            exports.skinchooser:setPlayerOutfit(savedOutfit)
            savedOutfit = nil
        end
        exports.notify:display({
            type = "success",
            title = "Pizza This...",
            text = "Odešel jsi z práce..",
            icon = "fas fa-utensils",
            length = 3000
        })
    end
end)

RegisterNetEvent("job_pizza:deleteVehicle")
AddEventHandler("job_pizza:deleteVehicle", function(netId)
    if NetworkDoesEntityExistWithNetworkId(netId) then
        local vehicle = NetworkGetEntityFromNetworkId(netId)
        if DoesEntityExist(vehicle) then
            DeleteEntity(vehicle)
        end
    end
end)

function checkMisc()
    if not DoesEntityExist(buddy) then
        createBuddy()
    end
    showBlip = exports.settings:getSettingValue("brigadeBlips")
    if showBlip and not DoesBlipExist(buddyBlip) then
        createBlip()
    end
end

AddEventHandler("settings:changed", function(setting, value)
    if setting == "brigadeBlips" then
        showBlip = value
        if not showBlip then
            RemoveBlip(buddyBlip)
            buddyBlip = nil
        else
            createBlip()
        end
    end
end)

function createBlip()
    buddyBlip = createNewBlip({
        coords = Config.Pizzeria.Coords.xyz,
        sprite = 273,
        display = 4,
        scale = 0.7,
        colour = 0,
        isShortRange = true,
        text = "Pizza This..."
    })
    SetBlipCategory(buddyBlip, 10)

end

function isVehPlaceClean()
    for _, spawn in each(Config.Spawns) do
        if not IsAnyVehicleNearPoint(spawn.xyz, 2.5) then
            return true
        end
    end
    return false
end

function createBuddy()
    while not HasModelLoaded(Config.Pizzeria.Ped) do
        RequestModel(Config.Pizzeria.Ped)
        Wait(5)
    end
    buddy = CreatePed(4, Config.Pizzeria.Ped, Config.Pizzeria.Coords.xyz, false, false)
    SetEntityHeading(buddy, Config.Pizzeria.Coords.w)
    SetEntityAsMissionEntity(buddy, true, true)
    SetPedHearingRange(buddy, 0.0)
    SetPedSeeingRange(buddy, 0.0)
    SetPedAlertness(buddy, 0.0)
    SetPedFleeAttributes(buddy, 0, 0)
    SetBlockingOfNonTemporaryEvents(buddy, true)
    SetPedCombatAttributes(buddy, 46, true)
    SetPedFleeAttributes(buddy, 0, 0)
    SetEntityInvincible(buddy, true)
    FreezeEntityPosition(buddy, true)
    TaskStartScenarioInPlace(buddy, "WORLD_HUMAN_CLIPBOARD", 0, false)
end

function spawnVehicle(vehId)
    local model = GetHashKey("faggio")

    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(1)
    end

    local spawnpoint = nil
    for _, spawn in each(Config.Spawns) do
        if not IsAnyVehicleNearPoint(spawn.xyz, 2.5) then
            spawnpoint = _
            break
        end
    end

    if spawnpoint ~= nil then
        local truck = CreateVehicle(model, Config.Spawns[spawnpoint], true, true)
        vehData = {
            NetId = NetworkGetNetworkIdFromEntity(truck),
            Plate = GetVehicleNumberPlateText(truck),
            VehId = vehId
        }
        TriggerServerEvent("job_pizza:updateVehicle", vehData)
        return "done"
    else
        return "nospace"
    end
end

function tableLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

function takePackages(type)
    exports.input:openInput("number", {
        title = "Zadejte počet, který chcete",
        placeholder = "0 - 100"
    }, function(count)
        if not count or count == "" then
            exports.notify:display({
                type = "error",
                title = "Pizza This...",
                text = "Musíš zadat správný počet!",
                icon = "fas fa-utensils",
                length = 3500
            })
        else
            TriggerServerEvent("job_pizza:getPackages", type, tonumber(count))
        end
    end)
    WarMenu.CloseMenu()
end
