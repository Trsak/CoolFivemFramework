local isSpawned, isDead, inVehicle, isOpened, canTakeVehicle = false, false, false, false, true
local playerCoords = nil
local closestGarage = nil
local jobs, garages = {}, nil
local showingGarageHint = false
local showAllBlips = false
local allGarageBlips = {}

Citizen.CreateThread(function()
    Citizen.Wait(500)
    playerPed = PlayerPedId()
    playerCoords = GetEntityCoords(playerPed)

    TriggerEvent("chat:removeSuggestion", "/garage_dev")

    local status = exports.data:getUserVar("status")
    if status == "spawned" or status == "dead" then
        showAllBlips = exports.settings:getSettingValue("allGarageBlips")
        isSpawned = true
        isDead = (status == "dead")
        loadJobs()
        if showAllBlips then
            createAllBlips()
        end
    end
    while true do
        Citizen.Wait(1500)
        if isSpawned and not isDead then
            playerPed = PlayerPedId()
            playerCoords = GetEntityCoords(playerPed)
            inVehicle = IsPedInAnyVehicle(playerPed)
        end
    end
end)

RegisterNetEvent("s:statusUpdated")
AddEventHandler("s:statusUpdated", function(status)
    if status == "choosing" then
        closeGarageMenu()
        isSpawned, isDead, isOpened, jobs = false, false, false, {}
    elseif status == "spawned" or status == "dead" then
        isDead = (status == "dead")
        if not isSpawned then
            isSpawned = true
            loadJobs()
            TriggerServerEvent("garages:sync")
        end

        if isDead then
            closeGarageMenu()
        end
    end
end)

RegisterNetEvent("s:jobUpdated")
AddEventHandler("s:jobUpdated", function(newJobs)
    loadJobs(newJobs)
end)

RegisterNetEvent("garages:sync")
AddEventHandler("garages:sync", function(sync)
    garages = sync
end)

RegisterNetEvent("garages:getAvailableVehiclesFromGarage")
AddEventHandler("garages:getAvailableVehiclesFromGarage", function(vehicles, type)
    if #vehicles > 0 then
        SendNUIMessage({
            action = "show",
            vehicles = getVehicleDetailsList(vehicles, type),
            garage = closestGarage.Id,
            garageLabel = Config.Blips[closestGarage.Type][closestGarage.Properties.vehicleType].Label
        })
        SetNuiFocus(true, true)
    else
        exports.notify:display({
            type = "error",
            title = (type == "garage" and "Garáž" or "Odtahovka"),
            text = "Nemáš zde žádné vozidlo!",
            icon = "fas fa-car",
            length = 3000
        })
        closeGarageMenu()
    end
end)

RegisterNetEvent("garages:takeVehicleFromGarage")
AddEventHandler("garages:takeVehicleFromGarage", function(status, hasCash, jobVeh)
    if hasCash == "done" then
        if status == "done" then
            exports.notify:display({
                type = "success",
                title = "Vytažení vozidla",
                text = "Vozidlo je na parkovišti!",
                icon = "fas fa-car",
                length = 3000
            })
            closeGarageMenu()
        else
            exports.notify:display({
                type = "error",
                title = "Vytažení vozidla",
                text = "Vozidlo jsme nenalezli!",
                icon = "fas fa-car",
                length = 3000
            })
        end
    else
        closeGarageMenu()
        exports.notify:display({
            type = "error",
            title = "Odtah",
            text = jobVeh and "Firma nemá dostatek peněz na účtu!" or "Nemáš dostatek peněz!",
            icon = "fas fa-car",
            length = 3000
        })
    end
end)

Citizen.CreateThread(function()
    while true do
        if isSpawned and garages and playerCoords then
            local cData = getClosestGarage()
            local blipCoords = type(cData.SelectCoords) ~= "table" and cData.SelectCoords or cData.SelectCoords[1]
            if not closestGarage then
                if cData then
                    closestGarage = cData
                    if not showAllBlips then
                        closestBlip = CreateBlip(cData, blipCoords)
                    end
                end
            elseif cData ~= closestGarage or not DoesBlipExist(closestBlip) then
                if not showAllBlips then
                    if DoesBlipExist(closestBlip) then
                        editBlipData(cData, blipCoords)
                    else
                        closestBlip = CreateBlip(cData, blipCoords)
                    end
                end

                closestGarage = cData
            end
        end
        Citizen.Wait(1000)
    end
end)

Citizen.CreateThread(function()
    while true do
        if isSpawned and playerCoords and closestGarage then
            local shouldBeDisplayingHint = false
            if not inVehicle then
                if type(closestGarage.SelectCoords) == "table" then
                    for _, coords in each(closestGarage.SelectCoords) do
                        if #(playerCoords - coords) <= 2.0 then
                            shouldBeDisplayingHint = true
                            if closestGarage.Id ~= lastGarage then
                                resetHint()
                            end
                            if not showingGarageHint then
                                showingGarageHint = true
                                closestPoint = "select"
                                lastGarage = closestGarage.Id
                                exports.key_hints:displayHint({
                                    name = "garage",
                                    key = "~INPUT_F2A3B7CC~",
                                    text = "Otevřít garáž",
                                    coords = coords
                                })
                            end
                        end
                    end
                else
                    if #(playerCoords - closestGarage.SelectCoords) <= 2.0 then
                        shouldBeDisplayingHint = true
                        if closestGarage.Id ~= lastGarage then
                            resetHint()
                        end
                        if not showingGarageHint then
                            showingGarageHint = true
                            closestPoint = "select"
                            lastGarage = closestGarage.Id
                            exports.key_hints:displayHint({
                                name = "garage",
                                key = "~INPUT_F2A3B7CC~",
                                text = "Otevřít garáž",
                                coords = closestGarage.SelectCoords
                            })
                        end
                    end
                end
            else
                if GetPedInVehicleSeat(GetVehiclePedIsIn(playerPed, false), -1) == playerPed then
                    if closestGarage.Type == "garage" or closestGarage.Type == "tow" and canStoreTow() then
                        local storeDistance = (closestGarage.Properties.radius and closestGarage.Properties.radius or
                                                  2.0)
                        for _, coords in each(closestGarage.SpawnLocations) do
                            local pointCoords = vec3(coords.x, coords.y, coords.z)
                            if #(playerCoords - pointCoords) <= storeDistance then
                                shouldBeDisplayingHint = true
                                if closestGarage.Id ~= lastGarage then
                                    resetHint()
                                end

                                if not showingGarageHint then
                                    showingGarageHint = true
                                    closestPoint = "store"
                                    lastGarage = closestGarage.Id
                                    exports.key_hints:displayBottomHint({
                                        name = "garage",
                                        key = "~INPUT_2F1EAB74~",
                                        text = "Uložit vozidlo do garáže"
                                    })
                                end
                            end
                        end
                    end
                end
            end
            if not shouldBeDisplayingHint and showingGarageHint then
                resetHint()
            end
        end
        Citizen.Wait(500)
    end
end)

RegisterNUICallback("selectvehicle", function(data, cb)
    if canTakeVehicle then
        if closestGarage.Type ~= "tow" or closestGarage.Type == "tow" and data.towed and not data.blocked then
            data.to_garage = 0
            canTakeVehicle = false
            local garage = data.garageid
            local closest = 100000.0
            data.spawnpoint = nil

            for _, location in each(closestGarage.SpawnLocations) do
                if not IsParkingSpotOccluded(vec3(location.x, location.y, location.z), location.h) then
                    local distance = #(playerCoords - vec3(location.x, location.y, location.z))

                    if distance < closest then
                        closest = distance

                        data.spawnpoint = location
                    end
                end
            end
            if not data.spawnpoint then
                exports.notify:display({
                    type = "error",
                    title = "Garáž",
                    text = "Musíte počkat, nikde tu není místo na výjezd",
                    icon = "fas fa-car",
                    length = 3000
                })
                closeGarageMenu()
                return
            end
            TriggerServerEvent("garages:takeVehicleFromGarage", data)
        else
            exports.notify:display({
                type = "error",
                title = "Odtahovka",
                text = "Toto vozidlo bylo pozastaveno Policií, proto jej vám nemůžeme vydat.",
                icon = "fas fa-car",
                length = 3000
            })
        end
    end
end)

RegisterNUICallback("closepanel", function(data, cb)
    closeGarageMenu()
end)

function resetHint()
    showingGarageHint = false
    closestPoint = nil
    exports.key_hints:hideHint({
        name = "garage"
    })
    exports.key_hints:hideBottomHint({
        name = "garage"
    })
end

function getClosestGarage()
    local closest = 100000.0
    local nearestGarage = nil

    for _, garage in pairs(garages) do
        if garage.Owner == "public" or isJobed(garage.Job) or exports.household:HasHouseAccess(garage.houseId, true) then
            if type(garage.SelectCoords) ~= "table" then
                local garageCoords = vec3(garage.SelectCoords.x, garage.SelectCoords.y, garage.SelectCoords.z)
                if playerCoords ~= nil then
                    local distance = #(playerCoords - garageCoords)

                    if distance < closest then
                        closest = distance
                        nearestGarage = garage
                    end
                end
            else
                for _, coords in each(garage.SelectCoords) do
                    if playerCoords ~= nil then
                        local distance = #(playerCoords - coords)

                        if distance < closest then
                            closest = distance
                            nearestGarage = garage
                        end
                    end
                end
            end
        end
    end
    return nearestGarage
end

function openGarageMenu(garage, type)
    if not isOpened then
        isOpened = true
        TriggerServerEvent("garages:getAvailableVehiclesFromGarage", garage, type)
    else
        closeGarageMenu()
    end
end

function getVehicleDetailsList(vehicles, garageType)
    local vehicleList = {}
    local labelname = ""
    local engineState = 100
    local vehicleState = 100
    local fuelState = 100

    for _, vehicle in each(vehicles) do
        if vehicle.data == nil then
            print("GARAGES ERROR! VEHICLE " .. vehicle.Id .. " HAS NO DATA")
        else
            local vehicleData = vehicle.data
            labelname = GetLabelText(GetDisplayNameFromVehicleModel(vehicleData.model))
            if labelname == "NULL" then
                labelname = exports.base_vehicles:getVehicleNameByHash(vehicleData.model)
            end

            local note = ""
            local access = false

            if vehicle.jobdata then
                if vehicle.jobdata.vehNote then
                    note = " (" .. vehicle.jobdata.vehNote .. ")"
                end
                if type(vehicle.owner) == "table" and vehicle.owner.job then
                    if vehicle.jobdata.vehGrade and hasAccessToVeh(vehicle.owner.job, vehicle.jobdata.vehGrade) then
                        access = true
                    elseif tonumber(vehicle.jobdata.vehChar) == exports.data:getCharVar("id") then
                        access = true
                    end
                end
            end

            if vehicleData.engineHealth then
                engineState = vehicleData.engineHealth / 10

                if engineState < 0 then
                    engineState = 0
                end
            end

            if vehicleData.bodyHealth then
                vehicleState = vehicleData.bodyHealth / 10

                if vehicleState < 0 then
                    vehicleState = 0
                end
            end

            if vehicleData.fuelLevel then
                fuelState = vehicleData.fuelLevel

                if fuelState < 0 then
                    fuelState = 0
                end
            end

            local livery = vehicleData.modLivery
            table.insert(vehicleList, {
                label = tostring(labelname),
                model = vehicleData.model,
                class = GetVehicleClassFromName(GetHashKey(vehicleData.model)),
                engineState = engineState,
                vehicleState = vehicleState,
                fuelState = fuelState,
                action = garageType,
                towed = vehicle.towed,
                blocked = vehicle.blocked,
                plate = vehicle.data.actualPlate,
                fakePlate = vehicle.data.plate,
                note = note,
                access = access
            })
            table.sort(vehicleList, function(a, b)
                return a.label < b.label
            end)
        end
    end

    return vehicleList
end

function putVehicleInGarage(garage, vehicle)
    if not vehicle then
        if not inVehicle then
            return "noVehicle"
        end

        vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if playerPed ~= GetPedInVehicleSeat(vehicle, -1) then
            return "notDriver"
        end
    end

    local vehData = exports.base_vehicles:GetVehicleProperties(vehicle)
    if not vehData then
        return "noEntity"
    end
    resetHint()
    TriggerServerEvent("garages:putVehicleInGarage", VehToNet(vehicle), vehData, garage)
end

function closeGarageMenu()
    SendNUIMessage({
        action = "hide"
    })
    SetNuiFocus(false, false)
    canTakeVehicle = true
    isOpened = false
end

function CreateBlip(data, coords)
    local bData = Config.Blips[data.Type][data.Properties.vehicleType]
    local bType = tableLength(data.Job) > 0 and "Soukrom" or "Veřejn"
    local bEnd = data.Properties.vehicleType == "car" and "á" or data.Properties.vehicleType == "plane" and "ý" or
                     "ý"

    local garageLabel = bData.Label
    if data.Type == "garage" then
        garageLabel = bType .. bEnd .. " " .. bData.Label
    end
    return createNewBlip({
        coords = coords,
        sprite = bData.Type,
        display = 4,
        scale = bData.Scale,
        colour = bData.Color,
        text = garageLabel
    })
end

function editBlipData(data, coords)
    local bData = Config.Blips[data.Type][data.Properties.vehicleType]
    local bType = tableLength(data.Job) > 0 and "Soukrom" or "Veřejn"
    local bEnd = data.Properties.vehicleType == "car" and "á" or data.Properties.vehicleType == "plane" and "ý" or
                     "ý"

    local garageLabel = bData.Label
    if data.Type == "garage" then
        garageLabel = bType .. bEnd .. " " .. bData.Label
    end

    SetBlipCoords(closestBlip, coords)
    SetBlipSprite(closestBlip, bData.Type)
    renameExistingBlip({
        blip = closestBlip,
        text = garageLabel
    })
end

function loadJobs(Jobs)
    jobs = {}
    for _, data in pairs(Jobs and Jobs or exports.data:getCharVar("jobs")) do
        jobs[data.job] = {
            Name = data.job,
            Type = exports.base_jobs:getJobVar(data.job, "type"),
            Grade = data.job_grade,
            Duty = data.duty
        }
    end
end

function canStoreTow(call)
    for _, data in pairs(jobs) do
        if not call then
            if Config.CanTow[data.Type] and data.Grade >= Config.CanTow[data.Type] then
                return true
            end
        else
            if Config.CanCallTow[data.Type] or Config.CanCallTow[data.Name] then
                return data.Name
            end
        end
    end
    return false
end

function isJobed(garageJob)
    if garageJob then
        for _, data in pairs(jobs) do
            for _, jobData in each(garageJob) do
                if jobData.job and jobData.job == data.Name and data.Grade >= jobData.grade then
                    return true
                elseif jobData.type and jobData.type == data.Type and data.Grade >= jobData.grade then
                    return true
                end
            end
        end
    end
    return false
end

function tableLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

function IsParkingSpotOccluded(center, heading)
    local flags = 2

    local width = 2.3
    local length = 4.5
    local height = 2.0
    local ray = StartShapeTestBox(center, width, length, height, 0.0, 0.0, heading, 2, flags, 0, 4)

    local _, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(ray)

    return hit > 0
end

function ShapeBoxDraw(center, heading, width, length, height, occluded)
    local diagonal = math.sqrt((width / 2) ^ 2 + (length / 2) ^ 2)
    local fullDiagonal = math.sqrt(width ^ 2 + length ^ 2)
    local boxHeight = vector3(0.0, 0.0, height)

    local newAngle = math.deg(math.asin(length / fullDiagonal))

    local topRight = GetAngledPosition(center, diagonal, heading + newAngle, 1)
    local bottomRight = GetAngledPosition(center, diagonal, heading - newAngle, 1)
    local bottomLeft = GetAngledPosition(center, diagonal, heading + newAngle, -1)
    local topLeft = GetAngledPosition(center, diagonal, heading - newAngle, -1)

    local off = vector3(0.0, 0.0, 5.0)

    local boxColor = {0, 255, 0}

    if occluded then
        boxColor = {255, 0, 0}
    end

    DrawLine(topRight - off, topRight + off, 0, 255, 0, 255)
    DrawLine(bottomRight - off, bottomRight + off, 255, 0, 0, 255)
    DrawLine(bottomLeft - off, bottomLeft + off, 0, 0, 255, 255)
    DrawLine(topLeft - off, topLeft + off, 255, 255, 255, 255)

    DrawPoly(topRight, topLeft, topLeft + boxHeight, boxColor[1], boxColor[2], boxColor[3], 100)
    DrawPoly(topRight, topLeft + boxHeight, topRight + boxHeight, boxColor[1], boxColor[2], boxColor[3], 100)

    DrawPoly(bottomLeft, bottomRight, bottomRight + boxHeight, boxColor[1], boxColor[2], boxColor[3], 100)
    DrawPoly(bottomLeft, bottomRight + boxHeight, bottomLeft + boxHeight, boxColor[1], boxColor[2], boxColor[3], 100)

    DrawPoly(topLeft, bottomLeft, bottomLeft + boxHeight, boxColor[1], boxColor[2], boxColor[3], 100)
    DrawPoly(topLeft, bottomLeft + boxHeight, topLeft + boxHeight, boxColor[1], boxColor[2], boxColor[3], 100)

    DrawPoly(bottomRight, topRight, topRight + boxHeight, boxColor[1], boxColor[2], boxColor[3], 100)
    DrawPoly(bottomRight, topRight + boxHeight, bottomRight + boxHeight, boxColor[1], boxColor[2], boxColor[3], 100)

    DrawPoly(bottomRight + boxHeight, topRight + boxHeight, topLeft + boxHeight, boxColor[1], boxColor[2], boxColor[3],
        100)
    DrawPoly(topLeft + boxHeight, bottomLeft + boxHeight, bottomRight + boxHeight, boxColor[1], boxColor[2],
        boxColor[3], 100)
end

function GetAngledPosition(center, dist, angle, mod)
    local angRad = math.rad(angle)
    return center + mod * dist * vector3(math.cos(angRad), math.sin(angRad), 0.0)
end

function round(number)
    return string.format("%.1f", number)
end

local creatingGarage = false
local newGarage = {}
local debug = false

RegisterCommand("garage_dev", function(source, args)
    if exports.data:getUserVar("admin") > 2 then
        Citizen.CreateThread(function()
            WarMenu.CreateMenu("garage-dev", "Tvorba garáže", "Zvolte akci")
            WarMenu.OpenMenu("garage-dev")
            WarMenu.CreateSubMenu("garage-create", "garage-dev", "Vytvořte garáž!")
            WarMenu.CreateSubMenu("garage-select", "garage-create", "Nastavte pozice menu")
            WarMenu.CreateSubMenu("garage-spawn", "garage-create", "Nastavte pozice spawnu")

            while true do
                if WarMenu.IsMenuOpened("garage-dev") then
                    if WarMenu.MenuButton("Vytvořit garáž", "garage-create") then
                    elseif WarMenu.Button("Zapnout / Vypnout debug mode") then
                        if not debug then
                            debug = true
                        else
                            debug = false
                        end
                    end
                    if debug then
                        for _, coords in each(closestGarage.SpawnLocations) do
                            local occluded = IsParkingSpotOccluded(vec3(coords.x, coords.y, coords.z), coords.h)

                            ShapeBoxDraw(vec3(coords.x, coords.y, coords.z), coords.h, 2.3, 4.5, 2.0, occluded)
                        end
                    end
                    WarMenu.Display()
                elseif WarMenu.IsMenuOpened("garage-create") then
                    if not creatingGarage then
                        if WarMenu.Button("Začít vytvářet") then
                            creatingGarage = true
                            newGarage = {
                                SelectCoords = {},
                                SpawnLocations = {},
                                Owner = "public",
                                Available = 1,
                                Type = "garage",
                                houseId = 0,
                                Properties = {
                                    vehicleType = "car"
                                },
                                Job = {},
                                Postalcode = "Nenastaven"
                            }
                        end
                    end
                    if creatingGarage then
                        if WarMenu.MenuButton("Přidat menu garáže", "garage-select") then
                        elseif WarMenu.MenuButton("Přidat spawn garáže", "garage-spawn") then
                        elseif WarMenu.Button("ID Baráku", newGarage.houseId) then
                            exports.input:openInput("number", {
                                title = "Zadejte číslo baráku",
                                placeholder = ""
                            }, function(house)
                                if house then
                                    newGarage.houseId = house
                                    newGarage.Owner = "private"
                                end
                            end)
                        elseif WarMenu.Button("Nastavit postal code garáže", newGarage.Postalcode) then
                            exports.input:openInput("number", {
                                title = "Zadejte postal code!",
                                placeholder = ""
                            }, function(postal)
                                if postal then
                                    newGarage.Postalcode = postal
                                end
                            end)
                        elseif WarMenu.Button("Nastavit typ garáže", newGarage.Type) then
                            exports.input:openInput("text", {
                                title = "Zadejte typ garáže - garage / tow!",
                                placeholder = ""
                            }, function(type)
                                if type then
                                    if type == "garage" or type == "tow" then
                                        newGarage.Type = type
                                    else
                                        TriggerEvent("chat:addMessage", {
                                            templateId = "error",
                                            args = {"Nesprávně zadaný typ garáže!"}
                                        })
                                    end
                                end
                            end)
                        elseif WarMenu.Button("Uložit garáž") then
                            if tableLength(newGarage.SelectCoords) == 1 and type(newGarage.SelectCoords[1]) == "table" then
                                newGarage.SelectCoords = newGarage.SelectCoords[1]
                            end
                            TriggerServerEvent("garages:createGarage", newGarage)
                            creatingGarage, newGarage = false, {}
                        end
                    end
                    WarMenu.Display()
                elseif WarMenu.IsMenuOpened("garage-select") then
                    if WarMenu.Button("Přidat pozici") then
                        local coords = GetEntityCoords(PlayerPedId())
                        table.insert(newGarage.SelectCoords, {
                            x = coords.x,
                            y = coords.y,
                            z = coords.z
                        })
                        TriggerEvent("chat:addMessage", {
                            templateId = "success",
                            args = {"Přidal jsi pozici menu!"}
                        })
                    end
                    for i, coords in each(newGarage.SelectCoords) do
                        local coords = vec3(coords.x, coords.y, coords.z)
                        DrawMarker(22, coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 15, 15, 255, 150)
                        if WarMenu.Button("Pozice #" .. i,
                            round(coords.x) .. "," .. round(coords.y) .. "," .. round(coords.z)) then
                            table.remove(newGarage.SelectCoords, i)
                        end
                    end
                    WarMenu.Display()
                elseif WarMenu.IsMenuOpened("garage-spawn") then
                    if WarMenu.Button("Přidat spawn pozici") then
                        local currentCoords = GetEntityCoords(PlayerPedId())
                        table.insert(newGarage.SpawnLocations, {
                            x = currentCoords.x,
                            y = currentCoords.y,
                            z = currentCoords.z,
                            h = GetEntityHeading(PlayerPedId())
                        })
                        TriggerEvent("chat:addMessage", {
                            templateId = "success",
                            args = {"Přidal jsi pozici menu!"}
                        })
                    end
                    for i, coords in each(newGarage.SpawnLocations) do
                        if WarMenu.Button("Pozice #" .. i,
                            round(coords.x) .. "," .. round(coords.y) .. "," .. round(coords.z)) then
                            table.remove(newGarage.SpawnLocations, i)
                        end
                        local occluded = IsParkingSpotOccluded(vec3(coords.x, coords.y, coords.z), coords.h)

                        ShapeBoxDraw(vec3(coords.x, coords.y, coords.z), coords.h, 2.3, 4.5, 2.0, occluded)
                    end
                    WarMenu.Display()
                else
                    break
                end

                Citizen.Wait(0)
            end
        end)
    else
        TriggerEvent("chat:addMessage", {
            templateId = "error",
            args = {"Na toto nemáš právo!"}
        })
    end
end)

RegisterCommand("garage_menu", function()
    if closestGarage and not isDead and closestPoint == "select" then
        openGarageMenu(closestGarage.Id, closestGarage.Type)
    end
end)

RegisterCommand("garage_save", function()
    if closestPoint == "store" then
        if inVehicle and not isDead and closestGarage then
            if closestGarage.Type == "garage" or closestGarage.Type == "tow" and canStoreTow() then
                putVehicleInGarage(closestGarage.Id)
            end
        end
    end
end)

createNewKeyMapping({
    command = "garage_menu",
    text = "Otevření menu",
    key = "E"
})
createNewKeyMapping({
    command = "garage_save",
    text = "Uložení vozidla",
    key = "G"
})

function hasPoliceJob()
    for _, data in pairs(jobs) do
        if data.Type == "police" and data.Duty then
            return true
        end
    end
    return false
end

function hasAccessToVeh(job, grade)
    if jobs[job] then
        if jobs[job].Grade == grade then
            return true
        end
    end
    return false
end

AddEventHandler("settings:changed", function(setting, value)
    if setting == "allGarageBlips" then
        showAllBlips = value
        if not showAllBlips then
            for i, blip in each(allGarageBlips) do
                RemoveBlip(blip)
            end
        else
            RemoveBlip(closestBlip)
            createAllBlips()
        end
    end
end)

function createAllBlips()
    while not garages do
        Citizen.Wait(100)
    end

    for i, garage in pairs(garages) do
        if garage.Owner == "public" or isJobed(garage.Job) or exports.household:HasHouseAccess(garage.houseId, true)  then
            local blipCoords = type(garage.SelectCoords) ~= "table" and garage.SelectCoords or garage.SelectCoords[1]
            local bData = Config.Blips[garage.Type][garage.Properties.vehicleType]
            local bType = (tableLength(garage.Job) > 0 or garage.houseId > 0) and "Soukrom" or "Veřejn"
            local bEnd = garage.Properties.vehicleType == "car" and "á" or "ý"

            local garageLabel = bData.Label
            if garage.Type == "garage" then
                garageLabel = bType .. bEnd .. " " .. bData.Label
            end

            local blip = createNewBlip({
                coords = blipCoords,
                sprite = bData.Type,
                display = 4,
                scale = 0.4,
                colour = bData.Color,
                text = garageLabel
            })
            table.insert(allGarageBlips, blip)
        end
    end
end
