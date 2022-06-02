local isSpawned, isDead = false, false
local vehicles, trashCans = {}, {}
local haveTrash = false
local savedOutfit = nil
local showBlip, buddyBlip = true, nil

local vehData = {}

Citizen.CreateThread(function()
    Citizen.Wait(500)

    local status = exports.data:getUserVar("status")
    if status == "spawned" or status == "dead" then
        isSpawned = true
        isDead = (status == "dead")
    end

    exports.target:AddCircleZone("trashMaster", vector3(-322.06, -1546.03, 30.51), 3.2, {
        actions = {
            job = {
                cb = function()
                    if not WarMenu.IsAnyMenuOpened() then
                        if exports.license:hasLicense(Config.licenseNeeded, true) then
                            openMenu()
                        else
                            exports.notify:display({
                                type = "error",
                                title = "Department Of Sanitation",
                                text = "Nemáte řidičské oprávnění skupiny " .. Config.licenseNeeded,
                                icon = "fas fa-trash",
                                length = 3000
                            })
                        end
                    end
                end,
                icon = "fas fa-trash",
                label = "Oslovit chlapíka"
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
        end
    end
end)

function openMenu()
    Citizen.CreateThread(function()
        WarMenu.CreateMenu("garbage", "Popeláři", "Zvolte akci")
        WarMenu.CreateMenu("garbage_kick", "Vyhodit kámoše", "Zvolte kámoše")
        WarMenu.OpenMenu("garbage")

        if vehData.VehId == nil then
            while true do
                if WarMenu.IsMenuOpened("garbage") then
                    if WarMenu.Button("Nové vozidlo") then
                        if isVehPlaceClean() then
                            TriggerServerEvent("job_garbage:createNewVehicle")
                            WarMenu.CloseMenu()
                        else
                            exports.notify:display({
                                type = "error",
                                title = "Department Of Sanitation",
                                text = "Momentálně není nikde místo pro další vozidlo..",
                                icon = "fas fa-trash",
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
                if WarMenu.IsMenuOpened("garbage") then
                    if vehicles[vehData.VehId].Players[1] == GetPlayerServerId(PlayerId()) then
                        if WarMenu.Button("Nabrat kámoše") then
                            if tableLength(vehicles[vehData.VehId].Players) < 4 then
                                WarMenu.CloseMenu()
                                Citizen.Wait(10)
                                TriggerEvent("util:closestPlayer", {
                                    radius = 2.0
                                }, function(player)
                                    if player then
                                        TriggerServerEvent("job_garbage:addPlayerToVeh", vehData, player)
                                    end
                                end)
                            else
                                exports.notify:display({
                                    type = "error",
                                    title = "Department Of Sanitation",
                                    text = "Už u sebe máš plno!",
                                    icon = "fas fa-trash",
                                    length = 3000
                                })
                            end
                        elseif WarMenu.Button("Vyložit odpad",
                            "Ve vozidle: " .. vehicles[vehData.VehId].InVehicle .. " / 50") then
                            if vehicles[vehData.VehId].InVehicle > 0 then
                                TriggerServerEvent("job_garbage:unloadTrash", vehData.VehId)
                            else
                                exports.notify:display({
                                    type = "error",
                                    title = "Department Of Sanitation",
                                    text = "Ve vozidle nic není..",
                                    icon = "fas fa-trash",
                                    length = 3000
                                })
                            end
                        elseif WarMenu.Button("Vyplatit peníze",
                            "Odevzdáno: " .. vehicles[vehData.VehId].Delivered .. " / 200") then
                            if vehicles[vehData.VehId].Delivered > 0 then
                                TriggerServerEvent("job_garbage:sellTrash", vehData.VehId)
                            else
                                exports.notify:display({
                                    type = "error",
                                    title = "Department Of Sanitation",
                                    text = "Nemáš nic na vyplacení!",
                                    icon = "fas fa-trash",
                                    length = 3000
                                })
                            end
                        end
                    end
                    if WarMenu.Button("Převléknout se") then
                        if not savedOutfit then
                            savedOutfit = exports.skinchooser:getPlayerOutfit()
                            local sex = exports.skinchooser:getPlayerSex() == 0 and "male" or "female"
                            exports.skinchooser:setPlayerOutfit(Config.Outfits[sex])
                        else
                            exports.skinchooser:setPlayerOutfit(savedOutfit)
                            savedOutfit = nil
                        end
                    elseif WarMenu.Button("Ukončit práci") then
                        TriggerServerEvent("job_garbage:endJob", vehData.VehId)
                        WarMenu.CloseMenu()
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

RegisterNetEvent("job_garbage:startWork")
AddEventHandler("job_garbage:startWork", function(vehId)
    if spawnVehicle(vehId) == "done" then
        exports.notify:display({
            type = "success",
            title = "Department Of Sanitation",
            text = "Dostal jsi vozidlo s SPZ " .. vehData.Plate .. ".",
            icon = "fas fa-trash",
            length = 3000
        })
        startWork(vehId)
    end
end)

function startWork(vehId)
    for i, data in pairs(trashCans) do
        exports.target:AddCircleZone("trashCan-" .. i, data.Coords.xyz, 2.0, {
            actions = {
                pickup = {
                    cb = function(trashCan)
                        if not haveTrash then
                            TriggerServerEvent("job_garbage:pickupGarbage", trashCan.Id)
                        else
                            exports.notify:display({
                                type = "warning",
                                title = "Department Of Sanitation",
                                text = "Již máš pytel v ruce!",
                                icon = "fas fa-trash",
                                length = 3000
                            })
                        end
                    end,
                    cbData = {
                        Id = i
                    },
                    icon = "fas fa-trash",
                    label = "Vybrat popelnici"
                }
            },
            distance = 0.2
        })
    end

    print(vehData.NetId)

    exports.target:AddTargetVehicleBone({"platelight"}, {
        actions = {
            throw = {
                cb = function()
                    if not isThrowing then
                        if haveTrash then
                            if (GetVehicleDoorAngleRatio(NetworkGetEntityFromNetworkId(vehData.NetId), 5) > 0.0) then
                                if vehicles[vehData.VehId].InVehicle < 50 then
                                    isThrowing = true
                                    TriggerServerEvent("job_garbage:throwGarbageToVeh", vehData.VehId)
                                else
                                    exports.notify:display({
                                        type = "error",
                                        title = "Department Of Sanitation",
                                        text = "Vozidlo je již plné!",
                                        icon = "fas fa-trash",
                                        length = 3000
                                    })
                                end
                            else
                                exports.notify:display({
                                    type = "error",
                                    title = "Department Of Sanitation",
                                    text = "Kufr je zavřený!",
                                    icon = "fas fa-trash",
                                    length = 3000
                                })
                            end
                        else
                            exports.notify:display({
                                type = "error",
                                title = "Department Of Sanitation",
                                text = "Nemáš v ruce pytel!",
                                icon = "fas fa-trash",
                                length = 3000
                            })
                        end
                    end
                end,
                icon = "fas fa-trash",
                label = "Vhodit pytel"
            },
            trunk = {
                cb = function()
                    local veh = NetworkGetEntityFromNetworkId(vehData.NetId)
                    if (GetVehicleDoorAngleRatio(veh, 5) > 0.0) then
                        SetVehicleDoorShut(veh, 5, false)
                    else
                        SetVehicleDoorOpen(veh, 5, false, false)
                    end
                end,
                icon = "fas fa-trash",
                label = "Otevřít / zavřít kufr"
            }
        },
        netId = vehData.NetId,
        distance = 2.0
    })
end

RegisterNetEvent("job_garbage:pickupGarbage")
AddEventHandler("job_garbage:pickupGarbage", function()
    haveTrash = true

    exports.progressbar:startProgressBar({
        Duration = 4000,
        Label = "Vybíráš popelnici..",
        CanBeDead = false,
        CanCancel = true,
        DisableControls = {
            Movement = true,
            CarMovement = true,
            Mouse = false,
            Combat = true
        },
        Animation = {
            scenario = "PROP_HUMAN_BUM_BIN"
        }
    }, function(finished)
        local playerPed = PlayerPedId()
        local hand = GetPedBoneIndex(playerPed, 57005)
        bin = CreateObject(GetHashKey("hei_prop_heist_binbag"), 0, 0, 0, true, true, true)
        AttachEntityToEntity(bin, playerPed, hand, 0.12, 0.0, 0.00, 25.0, 270.0, 180.0, true, true, false, true, 1, true)
        exports.key_hints:displayBottomHint({
            name = "garbage",
            key = "~INPUT_FRONTEND_RRIGHT~",
            text = "Upustit pytel"
        })
        while haveTrash do
            if IsControlJustReleased(0, 194) then
                exports.emotes:playEmoteByName("putdown")
                Citizen.Wait(1000)
                ClearPedTasks(playerPed)
                DetachEntity(bin)
                haveTrash = false
                exports.key_hints:hideBottomHint({
                    name = "garbage"
                })
            end
            Citizen.Wait(1)
        end
    end)
end)

RegisterNetEvent("job_garbage:throwGarbageToVeh")
AddEventHandler("job_garbage:throwGarbageToVeh", function()
    while not HasAnimDictLoaded("anim@heists@narcotics@trash") do
        RequestAnimDict("anim@heists@narcotics@trash")
        Citizen.Wait(1)
    end
    TaskPlayAnim(PlayerPedId(), "anim@heists@narcotics@trash", "throw_b", 1.0, -1.0, -1, 2, 0, 0, 0, 0)
    Citizen.Wait(1500)
    ClearPedTasksImmediately(PlayerPedId())
    DeleteEntity(bin)
    haveTrash, isThrowing = false, false
    exports.key_hints:hideBottomHint({
        name = "garbage"
    })
end)

RegisterNetEvent("job_garbage:sync")
AddEventHandler("job_garbage:sync", function(serverVehs, trashcans)
    vehicles = serverVehs
    trashCans = trashcans
end)

RegisterNetEvent("job_garbage:AddPlayerToVeh")
AddEventHandler("job_garbage:AddPlayerToVeh", function(newVehData)
    if not vehData.VehId then
        vehData = newVehData
        startWork(vehData.NetId)
        exports.notify:display({
            type = "success",
            title = "Department Of Sanitation",
            text = "Kámoš tě přidal! Máš SPZ " .. vehData.Plate .. ".",
            icon = "fas fa-trash",
            length = 3000
        })
    end
end)

RegisterNetEvent("job_garbage:deleteVehicle")
AddEventHandler("job_garbage:deleteVehicle", function(netId)
    if NetworkDoesEntityExistWithNetworkId(netId) then
        local vehicle = NetToVeh(netId)
        if DoesEntityExist(vehicle) then
            DeleteEntity(vehicle)
        end
    end
end)

RegisterNetEvent("job_garbage:endJob")
AddEventHandler("job_garbage:endJob", function()
    if vehData.VehId ~= nil then
        vehData = {
            NetId = nil,
            Plate = nil,
            VehId = nil
        }
        if savedOutfit then
            exports.skinchooser:setPlayerOutfit(savedOutfit)
            savedOutfit = nil
        end
        for i, _ in pairs(trashCans) do
            exports.target:RemoveZone("trashCan-" .. i)
        end
        exports.target:RemoveVehicleBone("platelight")
        exports.notify:display({
            type = "success",
            title = "Department Of Sanitation",
            text = "Odešel jsi z práce..",
            icon = "fas fa-trash",
            length = 3000
        })
    end
end)

function tableLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

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
        coords = Config.Buddy.Coords,
        sprite = 318,
        display = 4,
        scale = 0.7,
        colour = 0,
        isShortRange = true,
        text = "Depo popelářů"
    })
    SetBlipCategory(buddyBlip, 10)

end

function createBuddy()
    local config = Config.Buddy
    while not HasModelLoaded(config.Model) do
        RequestModel(config.Model)
        Wait(5)
    end
    buddy = CreatePed(4, config.Model, config.Coords.xy, config.Coords.z - 0.5, false, false)
    SetEntityHeading(buddy, config.Coords.w)
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

function isVehPlaceClean()
    for _, spawn in each(Config.Spawn) do
        if not IsAnyVehicleNearPoint(spawn.xyz, 2.5) then
            return true
        end
    end
    return false
end

function spawnVehicle(vehId)
    local model = GetHashKey("trash")

    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(1)
    end

    local spawnpoint = nil
    for _, spawn in each(Config.Spawn) do
        if not IsAnyVehicleNearPoint(spawn.xyz, 2.5) then
            spawnpoint = _
            break
        end
    end

    if spawnpoint ~= nil then
        local truck = CreateVehicle(model, Config.Spawn[spawnpoint], true, true)
        vehData = {
            NetId = NetworkGetNetworkIdFromEntity(truck),
            Plate = GetVehicleNumberPlateText(truck),
            VehId = vehId
        }
        SetEntityAsMissionEntity(truck)
        SetVehicleColours(truck, 53, 53)
        TriggerServerEvent("job_garbage:updateVehicle", vehData)
        return "done"
    else
        return "nospace"
    end
end
