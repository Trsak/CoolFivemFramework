local TE, TCE, TSE, RNE, RSE, AEH, CCT, SNM, RNC = TriggerEvent, TriggerClientEvent, TriggerServerEvent, RegisterNetEvent, RegisterNetEvent, AddEventHandler, Citizen.CreateThread, SendNUIMessage, RegisterNUICallback
local prefIT, prefIL, prefCP, prefM, prefOT, prefAV = Config.Type, Config.List, Config.CheckPoints, Config.Menu, Config.OtherTexts, Config.AuthorizedVehicles
local sended, sendedT, boxes, alreadyBoxed, boxesInVeh, boxesSellPoint, prop, maxBoxes, missionVehicle, onPoint, ende, distance, sFuel, eFuel = false, false, nil, false, 0, 0, nil, nil, nil, false, false, 0, 0, 0
local inProgWork = {}

AEH(GetHandlerName('work'), function(data, dataW)
    local coords = nil
    local pref = nil
    inProgWork = data
    if IsWaypointActive() == 1 then
        SetWaypointOff()
    end
    while inProgWork['uuid'] == nil do Citizen.Wait(0) end
    if inProgWork['uuid'] ~= nil then
        pref = prefCP[inProgWork.key][inProgWork.workR]
        coords = pref['GetPoint']
        TE(GetHandlerName('drawW'), true, true, prefOT['Warehouseman'])
        TE(GetHandlerName('chckdistance'), true, coords)
        SetNewWaypoint(coords.x, coords.y)
    end
end)

AEH(GetHandlerName('drawW'), function(status, x, y, z, text)
    while status do
        if ende then text = nil break end
        if sendedT or inProgWork['uuid'] == nil then break else
            Citizen.Wait(1)
            if text == nil then break end
            if boxes == nil then
                Utils.DrawText3D(x, y, z, text)
            else
                if not onPoint then
                    Utils.DrawText3D(x, y, z, string.format(prefOT['Warehouseman5'], boxes))
                else
                    Utils.DrawText3D(x, y, z, text)
                end
            end

            if Utils.GetKeyPressed('E') then
                if boxes == nil then
                    if isPlayerEligible() then
                        if IsWaypointActive() == 1 then
                            SetWaypointOff()
                        end
                        Items = getItems()
                        TSE(GetHandlerName('checkItems'), Items)
                    else
                        exports.tchaj_notify:Notify('error', (prefOT['nEmployee']):format(prefM[inProgWork.company].Job))
                    end
                else
                    if onPoint then
                        if alreadyBoxed and prop ~= nil then
                            if boxesSellPoint >= 0 then
                                FreezeEntityPosition(PlayerPedId(), true)
                                playAnim(true)
                                boxesSellPoint = boxesSellPoint + 1

                                if boxesSellPoint == maxBoxes then
                                    exports.tchaj_notify:Notify('success', prefOT['nSellerSuccess'])
                                    workComplete(distance)
                                else
                                    exports.tchaj_notify:Notify('success', prefOT['nSeller'])
                                    break
                                end
                            end
                        else
                            exports.tchaj_notify:Notify('error', prefOT['nAlreadyCarry'])
                        end
                    else
                        if boxes ~= 0 and prop == nil and not alreadyBoxed then
                            FreezeEntityPosition(PlayerPedId(), true)
                            playAnim(false)
                            boxes = boxes - 1
                            exports.tchaj_notify:Notify('success', prefOT['nFindVeh'])
                            break
                        else
                            exports.tchaj_notify:Notify('error', prefOT['nAlreadyCarry'])
                        end
                    end
                end
            end
        end
    end
end)

AEH(GetHandlerName('drawC'), function(status, x, y, z, text, vehicle)
    if missionVehicle == nil then veh = vehicle else veh = missionVehicle end
    local authorized = false
    while status do
        if ende then text = nil break  end
        if sendedT or inProgWork['uuid'] == nil then break else
            Citizen.Wait(1)
            if text == nil or #prefAV[inProgWork.key] == nil then break end
            Utils.DrawText3D(x, y, z, text)
            if Utils.GetKeyPressed('E') then
                if not onPoint then
                    for i = 1, #prefAV[inProgWork.key] do
                        if GetEntityModel(veh) == GetHashKey(prefAV[inProgWork.key][i]) then
                            authorized = true
                        elseif GetEntityModel(veh) == prefAV[inProgWork.key][i] then
                            authorized = true
                        end
                    end
                    if authorized then
                        if boxesInVeh ~=  maxBoxes then
                            missionVehicle = vehicle
                            boxesInVeh = boxesInVeh + 1
                            FreezeEntityPosition(PlayerPedId(), true)
                            playAnim(true)
                            if boxesInVeh ==  maxBoxes then
                                alreadyBoxed = true
                                TE(GetHandlerName('chckdistance'), false)
                                TE(GetHandlerName('drive'), true, veh)
                                sendedT = true
                                break
                            end
                        end
                    else
                        exports.tchaj_notify:Notify('error', prefOT['nAuthorized'])
                        break
                    end
                else
                    boxesInVeh = boxesInVeh -1
                    FreezeEntityPosition(PlayerPedId(), true)
                    playAnim(false)
                end
            end
        end
    end
end)

AEH(GetHandlerName('drawT'), function(status,text)
    while status do
        Citizen.Wait(1)
        if ende  then text = nil break end
        if sended or inProgWork['uuid'] == nil  then break else
            if text ~= nil then
                Utils.TText(text)
            else
                break
            end
        end
    end
end)

AEH(GetHandlerName('drive'), function(status, vehicle)
    local CP = getWPs()
    local number = 1
    local chckDistance = nil
    local prefe = prefCP[inProgWork.key][inProgWork.workR]['CheckPoints']
    local sent = false
    SetWaypointOff()
    UpdateFuel()
    while status do
        Citizen.Wait(50)
        if ende then break end
        while missionVehicle == nil do Citizen.Wait(0) end
        local plyCoords = Utils.GetCoords()

        if IsPedInVehicle(PlayerPedId(), missionVehicle, true) then
            sent = false
            if number <= #prefe then
                chckDistance = GetDistanceBetweenCoords(plyCoords, prefe[number].x, prefe[number].y, prefe[number].z, false)
                TE(GetHandlerName('drawT'), false)
                if (chckDistance < 30) then
                    if IsWaypointActive() then
                        SetWaypointOff()

                        number = number + 1
                    end
                else
                    if not IsWaypointActive() then
                        SetNewWaypoint(prefe[number].x, prefe[number].y)
                        Citizen.Wait(50)
                        distance = distance + math.floor(chckDistance)
                    end
                end
            else
                onPoint = true
            end
        else
            if not onPoint then
                if not sent then
                    TE(GetHandlerName('drawT'), true, prefOT['inVeh'])
                    sent = true
                end
            else
                pref = prefCP[inProgWork.key][inProgWork.workR]
                coords = pref['SellPoint']
                TE(GetHandlerName('tst'), true, coords)
                TE(GetHandlerName('drawT'),false)
                sended = false
                sendedT = false
                UpdateFuel()
                break
            end
        end
    end
end)

AEH(GetHandlerName('tst'), function(status, coords)
    local size = 2.5
    local chckDistance = nil
    while status do
        Citizen.Wait(50)
        chckDistance = nil
        local carCoords = nil
        local plyCoords = Utils.GetCoords()
        if ende then break end

        if alreadyBoxed then
            if prop == nil then
                carCoords = GetEntityCoords(missionVehicle)
                chckDistance = GetDistanceBetweenCoords(plyCoords, carCoords.x, carCoords.y, carCoords.z, true)
            else
                chckDistance = GetDistanceBetweenCoords(plyCoords, coords.x, coords.y, coords.z, true)
            end

            if chckDistance ~= nil and not IsPedInAnyVehicle(PlayerPedId(), true) then
                if (chckDistance < size) then
                    if not sended then
                        if sendedT then
                            TE(GetHandlerName('drawT'), false)
                            sendedT = false
                        end
                        if prop == nil then
                            if DoesEntityExist(missionVehicle) then
                                TE(GetHandlerName('drawC'), true, carCoords.x, carCoords.y, carCoords.z, string.format(prefOT['Seller'], boxesInVeh), vehicle)
                            end
                        else
                            TE(GetHandlerName('drawW'), true, coords.x, coords.y, coords.z, string.format(prefOT['Seller2'], boxesSellPoint))
                        end
                        sended = true
                    end
                else
                    if not sendedT then
                        if sended then
                            TE(GetHandlerName('drawW'), false)
                            TE(GetHandlerName('drawC'), false)
                            sended = false
                        end
                        if boxesSellPoint > 0 then
                            boxesRemaining = maxBoxes - boxesSellPoint
                            TE(GetHandlerName('drawT'), true, string.format(prefOT['Seller3'], boxesRemaining))
                        else
                            TE(GetHandlerName('drawT'), true, prefOT['Warehouseman3'])
                        end
                        sendedT = true
                    end
                end
            else
                if not sendedT then
                    if sended then
                        TE(GetHandlerName('drawW'), false)
                        sended = false
                    end

                    if boxesSellPoint == 0 then
                        TE(GetHandlerName('drawT'), true, prefOT['Warehouseman3'])
                    else
                        if boxesSellPoint > 0 then
                            boxesRemaining = maxBoxes - boxesSellPoint
                            TE(GetHandlerName('drawT'), true, string.format(prefOT['Seller3'], boxesRemaining))
                        else
                            TE(GetHandlerName('drawT'), true, prefOT['Warehouseman3'])
                        end
                    end
                    sendedT = true
                end
            end
        end
    end
end)

AEH(GetHandlerName('chckdistance'), function(status, coords)
    local size = 2.5
    local chckDistance = nil
    local vehicle = nil
    local plyCoords = nil
    local carCoords = nil
    if status == false then
        coords = nil
    end
    while status do
        chckDistance = nil
        vehicle = nil
        carCoords = nil
        plyCoords = Utils.GetCoords()
        Citizen.Wait(50)

        if ende == true then break end

        if not alreadyBoxed then
            if prop == nil then
                chckDistance = GetDistanceBetweenCoords(plyCoords, coords.x, coords.y, coords.z, true)
            else
                if missionVehicle == nil then
                    vehicle = Utils.GetVehicleInDirectory()
                else
                    vehicle = missionVehicle
                end
                if vehicle ~= nil and vehicle ~= 0 then
                    carCoords = GetEntityCoords(vehicle)
                    chckDistance = GetDistanceBetweenCoords(plyCoords, carCoords.x, carCoords.y, carCoords.z, true)
                end
            end
        end

        if not alreadyBoxed then
            if chckDistance ~= nil then
                if (chckDistance < size) then
                    if not sended then
                        if sendedT then
                            TE(GetHandlerName('drawT'), false)
                            sendedT = false
                        end
                        if coords.x ~= nil and vehicle == nil then
                            TE(GetHandlerName('drawW'), true, coords.x, coords.y, coords.z, prefOT['Warehouseman2'])
                        else
                            if DoesEntityExist(vehicle) then
                                TE(GetHandlerName('drawC'), true, carCoords.x, carCoords.y, carCoords.z, string.format(prefOT['Veh'], boxesInVeh), vehicle)
                            end
                        end
                        sended = true
                    end
                else
                    if not sendedT then
                        if sended then
                            TE(GetHandlerName('drawW'), false)
                            sended = false
                        end

                        if boxes == nil then
                            TE(GetHandlerName('drawT'), true, prefOT['Warehouseman'])
                        else
                            if boxesInVeh > 0 then
                                boxesRemaining = maxBoxes - boxesInVeh
                                TE(GetHandlerName('drawT'), true, string.format(prefOT['Veh2'], boxesRemaining, inProgWork.key))
                            else
                                TE(GetHandlerName('drawT'), true, string.format(prefOT['Veh3'], inProgWork.key))
                            end
                        end
                        sendedT = true
                    end
                end
            else
                if not sendedT then
                    if sended then
                        TE(GetHandlerName('drawW'), false)
                        sended = false
                    end

                    if prop == nil then
                        TE(GetHandlerName('drawT'), true, prefOT['Warehouseman'])
                    else
                        if boxesInVeh > 0 then
                            boxesRemaining = maxBoxes - boxesInVeh
                            TE(GetHandlerName('drawT'), true, string.format(prefOT['Veh2'], boxesRemaining, inProgWork.key))
                        else
                            TE(GetHandlerName('drawT'), true, string.format(prefOT['Veh3'], inProgWork.key))
                        end
                    end
                    sendedT = true
                end
            end
        end
    end
end)

RNE(GetHandlerName('packaging'))
AEH(GetHandlerName('packaging'), function(state, count)
    if state then
        boxes = math.floor(tonumber(count) / 20)
        maxBoxes = boxes
    end
end)

function playAnim(del)
    if not del then
        local propName = 'prop_cs_cardbox_01'
        local anim = 'lift_box'
        local animD = 'anim@heists@load_box'
        local playerPed = GetPlayerPed(-1)
        local x,y,z = table.unpack(GetEntityCoords(playerPed))
        prop = CreateObject(GetHashKey(propName), x+0.5, y+0.2, z-1 , true, true, true)
        local boneIndex = GetPedBoneIndex(playerPed, 60309)

        RequestAnimDict(animD)

        while not HasAnimDictLoaded(animD) do
            Citizen.Wait(0)
        end

        TaskPlayAnim(playerPed, animD, anim, 8.0, -8, -1, 49, 0, 0, 0, 0)
        Citizen.Wait(1200)
        AttachEntityToEntity(prop, playerPed, boneIndex, 0.025, 0.08, 0.255, -145.0, 290.0, 0.0, true, true, false, true, 1, true)
        Citizen.Wait(2000)
        TaskPlayAnim(playerPed, animD, 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)
        Citizen.Wait(1200)
        FreezeEntityPosition(PlayerPedId(), false)
    else
        local anim = 'load_box_4'
        local animD = 'anim@heists@load_box'
        local playerPed = GetPlayerPed(-1)
        local x,y,z = table.unpack(GetEntityCoords(playerPed))
        TaskPlayAnim(playerPed, animD, anim, 8.0, -8, -1, 49, 0, 0, 0, 0)
        Citizen.Wait(2000)
        ClearPedSecondaryTask(GetPlayerPed(-1))
        DeleteObject(prop)
        FreezeEntityPosition(PlayerPedId(), false)
        prop = nil
    end
end

function tst2()
    ende = true
    sended, sendedT, boxes, boxesInVeh, boxesSellPoint, prop, maxBoxes, missionVehicle, onPoint, distance, sFuel, eFuel = false, false, nil, 0, 0, nil, nil, nil, false, 0, 0, 0
    Citizen.Wait(50)
    text = nil
    sended, sendedT, alreadyBoxed = false, false, false
    TE(GetHandlerName('tst'), false)
    TE(GetHandlerName('chckdistance'), false)
    inProgWork = {}
    Citizen.Wait(100)
    ende = false
end

function fuha()
    sended = false
    TE(GetHandlerName('drawT'), false, nil)
end

function UpdateFuel()
    if not onPoint then
        sFuel = DecorGetFloat(missionVehicle, '_FUEL_LEVEL')
        print('Paliv: '..sFuel)
    else
        eFuel = DecorGetFloat(missionVehicle, '_FUEL_LEVEL')
        print('Paliv: '..eFuel)
    end
end

function GetFuel()
    return sFuel, eFuel
end

function debug()
    return sended, sendedT, boxes, boxesInVeh, boxesSellPoint, prop, maxBoxes, missionVehicle, onPoint, distance, sFuel, eFuel
end

RegisterCommand('tc', function(source, args)
    veh = Utils.GetVehicleInDirectory()
    print(veh)
    print(GetEntityModel(veh))
    print(GetHashKey('cuban800'))
end, false)