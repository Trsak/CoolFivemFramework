local isSpawned, isDead = false, false
local robberies = {}
local sellBlip, globalHouseId, globalHouseData = false, nil, nil
local isRemoving = false

DoScreenFadeIn(2000)
Citizen.CreateThread(function()
    Citizen.Wait(500)

    while not exports.data:isUserLoaded() do
        Citizen.Wait(100)
    end

    local status = exports.data:getUserVar("status")
    if status == "spawned" or status == "dead" then
        isSpawned = true
        isDead = (status == "dead")

        loadJobs()
    end
end)

RegisterNetEvent("s:statusUpdated")
AddEventHandler("s:statusUpdated", function(status)
    if status == "choosing" then
        isSpawned, isDead = false, false
        if globalHouseId then
            endRemovingLocator("fail", globalHouseId)
        end
        if DoesBlipExist(sellBlip) then
            RemoveBlip(sellBlip)
            sellBlip = nil
        end
    elseif status == "spawned" or status == "dead" then
        isDead = (status == "dead")
        if not isSpawned then
            isSpawned = true
            loadJobs()
            TriggerServerEvent("rob_locator:getData")
        end
    end
end)

RegisterNetEvent("s:jobUpdated")
AddEventHandler("s:jobUpdated", function(newJobs)
    loadJobs(newJobs)
end)

function loadJobs(Jobs)
    jobs = {}
    for _, data in pairs(Jobs ~= nil and Jobs or exports.data:getCharVar("jobs")) do
        jobs[data.job] = {
            Name = data.job,
            Type = exports.base_jobs:getJobVar(data.job, "type"),
            Grade = data.job_grade,
            Duty = data.duty
        }
    end
end

function hasWhitelistedJob()
    for _, data in pairs(jobs) do
        if Config.WhitelistedJobs[data.Type] or Config.WhitelistedJobs[data.Name] then
            return true
        end
    end

    return false
end

RegisterNetEvent("rob_locator:sendRobberies")
AddEventHandler("rob_locator:sendRobberies", function(newRobberies, npcNetId)
    robberies = newRobberies
    if npcNetId then
        setPedFlags(npcNetId)
    end
end)

RegisterNetEvent("rob_locator:vehicleIsGone")
AddEventHandler("rob_locator:vehicleIsGone", function()
    isRemoving, globalHouseId, globalHouseData = false, nil, nil
    exports.notify:display({
        type = "warning",
        title = "Smůla",
        text = "Vozidlo s lokátorem zmizelo!",
        icon = "fas fa-times",
        length = 3000
    })
end)

RegisterNetEvent("rob_locator:openHouse")
AddEventHandler("rob_locator:openHouse", function(houseId, houseData)
    globalHouseId, globalHouseData = tostring(houseId), houseData
    exports.target:AddCircleZone("locator-house-" .. houseId, houseData.Enter.xyz, 1.0, {
        actions = {
            enter = {
                cb = function(data)
                    if not hasWhitelistedJob() then
                        TriggerServerEvent("rob_locator:enterHouse", data.House)
                    end
                end,
                cbData = {
                    House = houseId,
                    HouseData = houseData
                },
                icon = "fas fa-comments",
                label = "Vstoupit dovnitř"
            }
        },
        distance = 0.2
    })
    local garageType = houseData.Type
    exports.target:AddCircleZone("locator-house-exit-" .. houseId, Config.Garages[garageType].Doors.xyz, 1.0, {
        actions = {
            job = {
                cb = function()
                    leaveHouse(houseId)
                end,
                icon = "fas fa-comments",
                label = "Odejít z domu"
            }
        },
        distance = 0.2
    })
end)

function leaveHouse(houseData)
    TriggerServerEvent("instance:quitInstance")
    Citizen.Wait(1000)
    SetEntityCoords(PlayerPedId(), houseData.Enter)
end

function createGaragePolyZones(houseId, garageType)
    local keyPlace = math.random(1, #(Config.Garages[garageType].Places))
    -- print("Selected Key Position:", keyPlace)
    exports.target:RemoveZone("locator-house-" .. houseId)
    for i, coords in each(Config.Garages[garageType].Places) do
        exports.target:AddCircleZone("locator-house-places-" .. i, coords, 1.0, {
            actions = {
                enter = {
                    cb = function(data)
                        if not hasWhitelistedJob() then
                            searchPlace(data)
                        end
                    end,
                    cbData = {
                        Key = keyPlace,
                        Current = i,
                        House = houseId,
                        Garage = garageType
                    },
                    icon = "fas fa-search",
                    label = "Prohledat"
                }
            },
            distance = 0.2
        })
    end
end

function searchPlace(data)
    
    exports.progressbar:startProgressBar({
        Duration = 5000,
        Label = "Prohledáváš místo..",
        CanBeDead = false,
        CanCancel = true,
        DisableControls = {
            Movement = true,
            CarMovement = true,
            Mouse = false,
            Combat = true
        },
        Animation = {
            animDict = "missexile3",
            anim = "ex03_dingy_search_case_a_michael"
        }
    }, function(finished)
        if finished then
            if data.Key == data.Current then
                TriggerServerEvent("rob_locator:foundKeys", data.House)
                startExitThread(data.House)
                removePlacesZones(data.Garage)
            else
                exports.target:RemoveZone("locator-house-places-" .. data.Current)
                exports.notify:display({
                    type = "warning",
                    title = "Smůla",
                    text = "Tady klíčky rozhodně nebyly!",
                    icon = "fas fa-times",
                    length = 3000
                })
            end
        end
    end)
end

function startExitThread(houseId)
    local stringHouseId = tostring(houseId)
    Citizen.CreateThread(function()
        local vehicle = NetToVeh(robberies[stringHouseId].NetId)
        -- print("Started checking thread")
        while true do
            Citizen.Wait(0)
            if IsPedInVehicle(PlayerPedId(), vehicle) and GetEntitySpeed(vehicle) > 2.0 then
                fadeEffect()
                SetPedCoordsKeepVehicle(PlayerPedId(), globalHouseData.Exit.xyz)
                SetEntityHeading(vehicle, globalHouseData.Exit.w)
                TriggerServerEvent("rob_locator:announceLocator", houseId)
                break
            end
        end
        -- print("Stopped checking thread")
        startTimer(robberies[stringHouseId].NetId, houseId)
    end)
end

function removePlacesZones(garageType)
    -- print("Removing zones for garages:", garageType)
    for i, _ in each(Config.Garages[garageType].Places) do
        exports.target:RemoveZone("locator-house-places-" .. i)
    end
end

RegisterNetEvent("rob_locator:enterHouse")
AddEventHandler("rob_locator:enterHouse", function(houseId)
    local playerPed = PlayerPedId()
    TriggerServerEvent("sound:playSound", "lockpick", 3.0, GetEntityCoords(playerPed), "rob_locator_" .. houseId)
    exports.progressbar:startProgressBar({
        Duration = 10000,
        Label = "Páčíš zámek..",
        CanBeDead = false,
        CanCancel = true,
        DisableControls = {
            Movement = true,
            CarMovement = true,
            Mouse = false,
            Combat = true
        },
        Animation = {
            animDict = "missheistfbisetup1",
            anim = "hassle_intro_loop_f"
        }
    }, function(finished)
        if finished then
            DoScreenFadeOut(2000)
            while not IsScreenFadedOut() do
                Citizen.Wait(10)
            end
            TriggerServerEvent("instance:joinInstance", "rob_locator_" .. houseId)
            Citizen.Wait(1000)
            local garageType = globalHouseData.Type
            SetEntityCoords(playerPed, Config.Garages[garageType].Doors.xyz)
            SetEntityHeading(playerPed, Config.Garages[garageType].Doors.w)
            Citizen.Wait(200)
            
            TriggerServerEvent("rob_locator:spawnVehicle", houseId)
            while not robberies[tostring(houseId)] and
                not NetworkDoesEntityExistWithNetworkId(robberies[tostring(houseId)].NetId) do
                Citizen.Wait(100)
            end
            DoScreenFadeIn(2000)
            while not IsScreenFadedIn() do
                Citizen.Wait(2000)
                DoScreenFadeIn(2000)
            end
            createGaragePolyZones(houseId, garageType)
        end
    end)
end)

local font = RegisterFontId("AMSANSL")
function drawTxt(text)
    SetTextFont(font)
    SetTextScale(0.5, 0.5)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    EndTextCommandDisplayText(0.8, 0.5)
end

function fadeEffect()
    DoScreenFadeOut(1000)
    Citizen.Wait(3000)
    DoScreenFadeIn(1000)
end

function tableLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

function startTimer(netId, houseId)
    Citizen.CreateThread(function()
        local timer = 0
        isRemoving, hasPassenger = true, false
        local veh = NetworkGetEntityFromNetworkId(netId)
        while isRemoving do
            Citizen.Wait(1)
            local text = "Lokátor"
            local passenger = GetPedInVehicleSeat(veh, 0)
            local secondSeat = DoesEntityExist(passenger)
            if GetEntitySpeed(veh) == 0.0 and IsPedInVehicle(PlayerPedId(), veh) or secondSeat then
                if not hasPassenger and secondSeat then
                    hasPassenger = GetPlayerServerId(NetworkGetEntityOwner(passenger))
                    -- print("Sharing locator with server ID", hasPassenger)
                    TriggerServerEvent("rob_locator:shareLocator", hasPassenger, houseId)
                elseif hasPassenger and not secondSeat then
                    -- print("Stoping sharing locator with server ID", hasPassenger)
                    hasPassenger = false
                end

                timer = timer + 10
                text = "Odstraňuješ lokátor"
                Entity(veh).state:set("locator", timer, true)
                if makeNewTime(timer) >= 100 then
                    isRemoving = false
                    endRemovingLocator("success", houseId)
                end
            end
            drawTxt(text .. "~b~ " .. makeNewTime(timer) .. "~s~%")
        end
    end)
end

function makeNewTime(oldTime)
    return math.floor((oldTime / 1000) / 360 * 100) -- 360
end

function endRemovingLocator(status, houseId)
    if status == "success" then
        exports.notify:display({
            type = "success",
            title = "Lokátor",
            text = "Odstranil/a jsi lokátor!",
            icon = "fas fa-car",
            length = 3000
        })
    else
        exports.notify:display({
            type = "warning",
            title = "Smůla",
            text = "Auto s lokátorem zmizelo!",
            icon = "fas fa-car",
            length = 3000
        })
        globalHouseId, globalHouseData = nil, nil
    end
    TriggerServerEvent("rob_locator:removeLocator", houseId, status)
end

RegisterNetEvent("rob_locator:shareLocator")
AddEventHandler("rob_locator:shareLocator", function(houseId)
    if robberies[houseId] and robberies[houseId].NetId then
        Citizen.CreateThread(function()
            local netId = robberies[houseId].NetId
            local veh = NetworkGetEntityFromNetworkId(netId)
            while GetPedInVehicleSeat(veh, 0) == PlayerPedId() and makeNewTime(Entity(veh).state.locator) < 100.0 do
                Citizen.Wait(1)
                while not Entity(veh).state.locator do
                    Citizen.Wait(10)
                end
                drawTxt("Odstraňuješ lokátor~b~ " .. makeNewTime(Entity(veh).state.locator) .. "~s~%")
            end
        end)
    end
end)

RegisterNetEvent("rob_locator:sellPoint")
AddEventHandler("rob_locator:sellPoint", function(sellPoint)
    local veh = NetToVeh(robberies[tostring(globalHouseId)].NetId)

    createSellBlip(sellPoint)
    local isShowingHint = false
    -- print("Selected sell point", sellPoint)
    while true do
        local toWait = 2000
        if #(GetEntityCoords(PlayerPedId()) - sellPoint) <= 5.0 then
            toWait = 0
            if not isShowingHint then
                isShowingHint = true
                exports.key_hints:displayHint({
                    name = "rob_locator",
                    key = "~INPUT_PICKUP~",
                    text = "Odevzdat",
                    coords = sellPoint
                })
            end
            if IsControlJustReleased(0, 54) then
                if IsPedInVehicle(PlayerPedId(), veh) then
                    fadeEffect()
                    TriggerServerEvent("rob_locator:finishTheft", tostring(globalHouseId))
                    endSellingLocator()
                    break
                else
                    exports.notify:display({
                        type = "error",
                        title = "Chyba",
                        text = "Kde máš auto?",
                        icon = "fas fa-times",
                        length = 3000
                    })
                end
            end
        end

        if toWait > 0 and isShowingHint then
            isShowingHint = false
            exports.key_hints:hideHint({
                name = "rob_locator"
            })
        end
        Citizen.Wait(toWait)
    end
end)

function createSellBlip(sellPoint)
    sellBlip = createNewBlip({
        coords = sellPoint,
        sprite = 524,
        display = 4,
        scale = 0.4,
        colour = 69,
        isShortRange = true,
        text = "Místo odevzdání vozidla"
    })
    SetBlipRoute(sellBlip, true)
end

function endSellingLocator()
    exports.key_hints:hideHint({
        name = "rob_locator"
    })
    RemoveBlip(sellBlip)
    sellBlip, globalHouseId = false, nil
end

RegisterNetEvent("rob_locator:deleteVehicle")
AddEventHandler("rob_locator:deleteVehicle", function(netId)
    if NetworkDoesEntityExistWithNetworkId(netId) then
        local vehicle = NetworkGetEntityFromNetworkId(netId)
        DeleteEntity(vehicle)
    end
end)

function setPedFlags(npcNetId)
    while not NetworkDoesEntityExistWithNetworkId(npcNetId) do
        Citizen.Wait(5000)
    end
    local npcHandle = NetToPed(npcNetId)
    exports.target:AddTargetObject({GetEntityModel(npcHandle)}, {
        actions = {
            ask = {
                cb = function()
                    if not hasWhitelistedJob() then
                        TriggerServerEvent("rob_locator:askForJob")
                    end
                end,
                icon = "fas fa-comments",
                label = "Oslovit chlapíka"
            }
        },
        netId = npcNetId,
        distance = 1.5
    })
    FreezeEntityPosition(npcHandle, true)
    SetPedResetFlag(npcHandle, 249, 1)
    SetPedConfigFlag(npcHandle, 185, true)
    SetPedConfigFlag(npcHandle, 108, true)
    SetPedConfigFlag(npcHandle, 208, true)
    SetEntityCanBeDamaged(npcHandle, false)
    SetPedCanBeTargetted(npcHandle, false)
    SetPedCanBeDraggedOut(npcHandle, false)
    SetPedCanBeTargettedByPlayer(npcHandle, PlayerId(), false)
    SetBlockingOfNonTemporaryEvents(npcHandle, true)
    SetPedCanRagdollFromPlayerImpact(npcHandle, false)
    SetEntityAsMissionEntity(npcHandle, true, true)
    SetPedHearingRange(npcHandle, 0.0)
    SetPedSeeingRange(npcHandle, 0.0)
    SetPedAlertness(npcHandle, 0.0)
    SetPedFleeAttributes(npcHandle, 0, 0)
    SetPedCombatAttributes(npcHandle, 46, true)
    SetPedFleeAttributes(npcHandle, 0, 0)
    SetEntityInvincible(npcHandle, true)
end
