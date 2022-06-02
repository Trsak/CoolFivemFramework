math.randomseed(os.time() + math.random(10000, 99999))
local vehicles, vehicleCount = {}, 0
local spawnedVehicles = {}

-- Load Vehicles
MySQL.ready(
    function()
        MySQL.Async.fetchAll(
            "SELECT * FROM vehicles",
            {},
            function(result)
                for i, vehicle in each(result) do
                    local jobdata = vehicle.jobdata
                    if type(jobdata) == "string" then
                        jobdata = json.decode(jobdata)
                    end
                    local vehiclePlate = tostring(vehicle.spz)

                    vehicles[vehiclePlate] = {
                        spz = vehiclePlate,
                        vin = vehicle.vin,
                        owner = json.decode(vehicle.owner),
                        in_garage = vehicle.in_garage,
                        type = vehicle.type,
                        data = json.decode(vehicle.data),
                        towed = (tonumber(vehicle.in_garage) == 0),
                        blocked = (tonumber(vehicle.blocked) == 1),
                        jobdata = jobdata
                    }

                    vehicles[vehiclePlate].data.actualPlate = vehiclePlate

                    vehicleCount = vehicleCount + 1
                end
                print("^2[VEHICLES]^7 Successfully loaded with " .. vehicleCount .. " vehicles!")
            end
        )
    end
)

function getVehicles()
    return vehicles
end

function getVehicle(plate)
    local plate = tostring(plate)
    return vehicles[plate]
end

function doesVehicleExist(plate)
    local plate = tostring(plate)
    return (vehicles[plate] and true or false)
end

function addVehicle(owner, in_garage, data, vehType)
    local spz, spzAccepted, vehData = "", false, data

    while not spzAccepted do
        spz = generateVehicleNumberPlate(spz)

        if vehicles[spz] then
            spzAccepted = false
        end

        spzAccepted = true
    end
    vehData.actualPlate = spz

    local vin, vinAccepted = "", false

    while not vinAccepted do
        for i = 1, 17 do
            vin = vin .. Config.plateChars[math.random(#Config.plateChars)]
        end

        for key, value in pairs(vehicles) do
            if value.vin == vin then
                vinAccepted = false
                break
            end
        end

        vinAccepted = true
    end

    MySQL.Async.execute(
        "INSERT INTO vehicles (spz, vin, owner, in_garage, type, data, blocked, jobdata) VALUES (:spz, :vin, :owner, :in_garage, :type, :data, :blocked, :jobdata)",
        {
            spz = spz,
            vin = vin,
            owner = type(owner) == "table" and json.encode(owner) or owner,
            in_garage = in_garage,
            type = vehType or "car",
            data = json.encode(vehData),
            blocked = 0,
            jobdata = "[]"
        }
    )

    vehicles[spz] = {
        spz = spz,
        vin = vin,
        owner = owner,
        in_garage = in_garage,
        type = vehType or "car",
        data = vehData,
        towed = false,
        blocked = false
    }

    vehicles[spz].data.actualPlate = spz

    vehicleCount = vehicleCount + 1

    return spz, vin
end

function updateVehicle(plate, data, save, updateOnlyChanged)
    local plate = tostring(plate)
    if vehicles[plate] then
        for key, value in pairs(data) do
            if key ~= "model" then
                if not updateOnlyChanged or Config.updatedKeys[key] or not vehicles[plate].data[key] or (key == "plate" and value == vehicles[plate].data.actualPlate) then
                    vehicles[plate].data[key] = data[key]
                end
            end
        end

        if save then
            MySQL.Async.execute(
                "UPDATE vehicles SET data = :data WHERE spz = :spz",
                {
                    spz = plate,
                    data = json.encode(vehicles[plate].data)
                }
            )
        end
    end
end

function generateVehicleNumberPlate(plate)
    for i = 1, 8 do
        plate = plate .. Config.plateChars[math.random(#Config.plateChars)]
    end

    return tostring(plate)
end

function updateVehicleJobData(plate, type, new)
    local plate = tostring(plate)
    if vehicles[plate] then
        if not vehicles[plate].jobdata then
            vehicles[plate].jobdata = {}
        end
        vehicles[plate].jobdata[type] = new

        MySQL.Async.execute(
            "UPDATE vehicles SET jobdata = :jobdata WHERE spz = :spz",
            {
                spz = plate,
                jobdata = json.encode(vehicles[plate].jobdata)
            }
        )
    end
end

function updateVehiclePlate(plate, newPlate)
    local plate = tostring(plate)
    if vehicles[plate] then
        vehicles[newPlate] = vehicles[plate]
        vehicles[newPlate].data.actualPlate = newPlate
        vehicles[newPlate].data.plate = newPlate
        vehicles[newPlate].spz = newPlate
        vehicles[plate] = nil

        MySQL.Async.execute(
            "UPDATE vehicles SET data = :data, spz = :newPlate WHERE spz = :oldPlate",
            {
                oldPlate = plate,
                newPlate = newPlate,
                data = json.encode(vehicles[newPlate].data)
            },
            function()
            end
        )

        exports.inventory:changeVehicleTrunkToNewPlate(plate, newPlate)
        return "done"
    else
        return "vehNotExist"
    end
end

function changeVehicleOwner(type, value, plate)
    local _source = source
    local plate = tostring(plate)
    if vehicles[plate] then
        local toSave = ""
        if type == "person" then
            toSave = exports.data:getCharVar(value, "id")
            vehicles[plate].owner = toSave
        elseif type == "job" then
            vehicles[plate].owner = {
                job = value.job,
                grade = value.grade
            }
            toSave = json.encode(vehicles[plate].owner)
        elseif type == "type" then
            vehicles[plate].owner = {
                type = value.job,
                grade = value.grade
            }
            toSave = json.encode(vehicles[plate].owner)
        end
        MySQL.Async.execute(
            "UPDATE vehicles SET owner = :owner WHERE spz = :spz",
            {
                spz = plate,
                owner = toSave
            }
        )
    end
end

function getOwnedVehicles(char, source)
    local ownedVehicles = {}
    for _, vehicle in pairs(vehicles) do
        local owner = vehicle.owner
        local isTable = false
        if type(owner) == "string" then
            owner = tonumber(owner)
        elseif type(owner) == "table" then
            isTable = true
        end
        local hasAccess = owner == char
        if not hasAccess and isTable and (owner.type ~= nil or owner.job ~= nil) then
            hasAccess = exports.base_jobs:isUserBoss(source, owner.job)
        end
        if not hasAccess and garageType ~= nil then
            hasAccess = garageType == "tow" and exports.base_jobs:hasUserJobType(source, "police")
        end
        if hasAccess then
            table.insert(ownedVehicles, vehicle)
        end
    end

    return ownedVehicles
end

function getVehicleCurrentGarage(plate)
    return (vehicles[plate] and vehicles[plate].in_garage or nil)
end

function getAvailableVehiclesFromGarage(client, char, garage)
    local availableVehicles = {}

    for key, vehicle in pairs(vehicles) do
        local toSend = vehicle
        local owner = vehicle.owner
        local isTable = false

        if type(owner) == "string" then
            owner = tonumber(owner)
        elseif type(owner) == "table" then
            isTable = true
        end
        if tostring(vehicle.in_garage) == tostring(garage) then
            local hasAccess = (owner == char)

            if not hasAccess and isTable and owner.type then
                hasAccess = exports.base_jobs:hasUserJobTypeGrade(client, owner.type, tonumber(owner.grade), true)
            end

            if not hasAccess and isTable and owner.job then
                hasAccess = exports.base_jobs:hasUserJob(client, owner.job, tonumber(owner.grade), true)
                if hasAccess and vehicle.jobdata then
                    if
                    vehicle.jobdata.vehGrade and
                        exports.base_jobs:hasUserJobEqualGrade(
                            client,
                            owner.type,
                            tonumber(vehicle.jobdata.vehGrade),
                            true
                        )
                    then
                    elseif vehicle.jobdata.vehChar == char then
                    elseif not exports.base_jobs:hasUserJob(client, owner.job, tonumber(vehicle.jobdata.vehGrade), true) then
                        hasAccess = false
                    end
                end
            end

            if hasAccess and (garage == 0 and vehicle.towed or garage ~= 0 and not vehicle.towed) then
                table.insert(availableVehicles, vehicle)
            end
        end
    end

    return availableVehicles
end

function updateVehicleCurrentGarage(plate, garage, towed)
    local plate = tostring(plate)
    if vehicles[plate] then
        if towed ~= nil then
            vehicles[plate].towed = towed
        else
            if vehicles[plate].in_garage == 0 and garage ~= 0 then
                local garageData = exports.garages:getVehicleGarageData(garage)
                if garageData.Type == "tow" then
                    vehicles[plate].towed = true
                    garage = 0
                end
            elseif vehicles[plate].in_garage == 0 and garage == 0 then
                vehicles[plate].towed = false
            end
        end
        vehicles[plate].in_garage = garage
        MySQL.Async.execute(
            "UPDATE vehicles SET in_garage = :in_garage WHERE spz = :spz",
            {
                spz = plate,
                in_garage = garage
            }
        )

        return "done"
    end

    return "error"
end

function checkCharVehicleCredibility(source, plate, garageType)
    local plate = tostring(plate)
    if not vehicles[plate] then
        print("^2[VEHICLES]^7 Vehicle with plate " .. plate .. " not exist!")
        return false
    end

    local isTable = false
    local charId = exports.data:getCharVar(source, "id")
    local owner = vehicles[plate].owner

    if type(owner) == "string" then
        owner = tonumber(owner)
    elseif type(owner) == "table" then
        isTable = true
    end

    local successfull = (owner == charId)

    if not successfull and isTable and owner.type then
        successfull = exports.base_jobs:hasUserJobTypeGrade(source, owner.type, tonumber(owner.grade))
    end

    if not successfull and isTable and owner.job then
        successfull = exports.base_jobs:hasUserJob(source, owner.job, tonumber(owner.grade))
    end

    if not successfull and garageType then
        successfull = garageType == "tow" and exports.base_jobs:hasUserJobType(source, "police")
    end

    return successfull
end

function changeVehicleBlockStatus(plate, state)
    local plate = tostring(plate)
    if vehicles[plate] then
        vehicles[plate].blocked = state
        return "done"
    end

    return "notExist"
end

function getVehicleBlockStatus(plate)
    local plate = tostring(plate)
    if vehicles[plate] then
        return vehicles[plate].blocked
    end

    return "notExist"
end

function getJobVehicle(job, tipe)
    local availableVehicles = {}
    for key, vehicle in pairs(vehicles) do
        local owner = vehicle.owner
        if type(owner) == "table" and (owner.job and owner.job == job or owner.type and owner.type == tipe) then
            table.insert(
                availableVehicles,
                {
                    plate = vehicle.data.actualPlate,
                    model = vehicle.data.model,
                    garage = vehicle.in_garage,
                    job = vehicle.jobdata,
                    grade = owner.grade
                }
            )
        end
    end
    return availableVehicles
end

function createVehicle(vehData, spawn, client, locked, instance)
    if type(vehData) == "string" then
        vehData = getVehicle(vehData)
    end

    if not vehData or not vehData.data or not vehData.data.model then
        return 0, "vehNotExist"
    end

    if not data and not spawn then
        return 0, "noSpawnCoords"
    end

    local vehicle = Citizen.InvokeNative(
        GetHashKey("CREATE_AUTOMOBILE"),
        GetHashKey(vehData.data.model),
        spawn.x,
        spawn.y,
        spawn.z,
        spawn.h or spawn.w
    )

    while not DoesEntityExist(vehicle) do
        Wait(0)
    end

    if instance then
        if type(instance) == "number" then
            SetEntityRoutingBucket(vehicle, instance)
        else
            SetEntityRoutingBucket(vehicle, exports.instance:createInstanceIfNotExists(instance))
        end
    end

    local ent = Entity(vehicle)

    if vehData.data.actualPlate then
        ent.state.actualPlate = vehData.data.actualPlate
    end

    if vehData.vin then
        ent.state.vin = tostring(vehData.vin)
    end

    while not NetworkGetEntityOwner(vehicle) or NetworkGetEntityOwner(vehicle) <= 0 do
        Wait(10)
    end

    local vehOwner = NetworkGetEntityOwner(vehicle)
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if NetworkGetNetworkIdFromEntity(vehicle) ~= netId then
        netId = NetworkGetNetworkIdFromEntity(vehicle)
    end

    if GetEntityModel(vehicle) ~= GetHashKey(vehData.data.model) then
        print("Vozidlo se spawnulo s jiným modelem!..", vehicle, json.encode(vehData))
        return
    end

    spawnedVehicles[vehData.data.actualPlate] = {
        data = vehData,
        entity = vehicle,
        coords = vec3(spawn.x, spawn.y, spawn.z),
        heading = spawn.h
    }

    if vehData.data.plate == nil then
        vehData.data.plate = vehData.data.actualPlate
    end

    setVehicleProperties(vehicle, vehData.data)

    local shouldBeLocked = true
    local isStateJob = isStateJob(vehData.owner)
    if not isStateJob then
        shouldBeLocked = false
    elseif locked ~= nil then
        shouldBeLocked = locked
    end

    ent.state.locked = shouldBeLocked
    if shouldBeLocked then
        SetVehicleDoorsLocked(vehicle, 2)
    else
        SetVehicleDoorsLocked(vehicle, 1)
    end
        
    TriggerClientEvent("vehiclelock:setVehicleLockStatus", vehOwner, netId, shouldBeLocked)

    TriggerClientEvent("v:setVehicleProperties", vehOwner, netId, vehData)
    if client and client ~= vehOwner then
        TriggerClientEvent("v:setVehicleProperties", client, netId, vehData)
        TriggerClientEvent("vehiclelock:setVehicleLockStatus", client, netId, shouldBeLocked)
    end

    Citizen.CreateThread(
        function()
            while true do
                Citizen.Wait(800)
                if not DoesEntityExist(vehicle) then
                    return
                end

                if checkVehicleProperties(vehicle, vehData.data) then
                    return
                else
                    vehOwner = NetworkGetEntityOwner(vehicle)
                    if vehOwner > 0 then
                        TriggerClientEvent("v:setVehicleProperties", vehOwner, netId, vehData)
                    end

                    if client and client ~= vehOwner then
                        TriggerClientEvent("v:setVehicleProperties", client, netId, vehData)
                    end
                end
            end
        end
    )
    return vehicle, netId
end

function checkVehicleProperties(veh, props)
    if props.color1 ~= nil and props.color2 ~= nil then
        local primary, secondary = GetVehicleColours(veh)
        if props.color1 ~= primary or props.color2 ~= secondary then
            return false
        end
    end

    if props.plate ~= nil then
        if props.plate ~= GetVehicleNumberPlateText(veh) then
            return false
        end
    end

    if props.pearlescentColor ~= nil and props.wheelColor ~= nil then
        local pearlescentColor, wheelColor = GetVehicleExtraColours(veh)
        if props.pearlescentColor ~= pearlescentColor or props.wheelColor ~= wheelColor then
            return false
        end
    end

    return true
end

function setVehicleProperties(veh, props)
    if props.bodyHealth ~= nil then
        SetVehicleBodyHealth(veh, props.bodyHealth + 0.0)
    end

    if props.dirtLevel ~= nil then
        SetVehicleDirtLevel(veh, props.dirtLevel + 0.0)
    end

    if props.plate ~= nil then
        SetVehicleNumberPlateText(veh, props.plate)
    end
end

function isStateJob(vehOwner, checkSourceJob)
    if vehOwner and type(vehOwner) == "table" then
        if
        vehOwner.job and vehOwner.job == "lspd" or vehOwner.job == "lssd" or vehOwner.job == "sahp" or
            vehOwner.job == "ems" or
            vehOwner.job == "lsfd"
        then
            if checkSourceJob and GetPlayerName(checkSourceJob) then
                return exports.base_jobs:hasUserJob(checkSourceJob, vehOwner.job)
            end
            return false
        elseif vehOwner.type and vehOwner.type == "police" or vehOwner.type == "medic" then
            if checkSourceJob and GetPlayerName(checkSourceJob) then
                return exports.base_jobs:hasUserJobType(checkSourceJob, vehOwner.type)
            end
            return false
        end
    end
    return true
end

RegisterCommand(
    "carowned",
    function(source, args)
        local _source = source
        if exports.data:getUserVar(_source, "admin") > 1 then
            local vehiclePlate = tostring(args[1])

            if vehiclePlate then
                local vehicleInfo = vehicles[vehiclePlate]

                if vehicleInfo then
                    if vehicleInfo.in_garage == 0 then
                        if vehicleInfo.towed then
                            TriggerClientEvent(
                                "chat:addMessage",
                                _source,
                                {
                                    templateId = "error",
                                    args = { "Vozidlo je na odtahovce!" }
                                }
                            )
                        else
                            local playerPed = GetPlayerPed(_source)
                            local pedCoords = GetEntityCoords(playerPed)

                            if spawnedVehicles[vehiclePlate] then
                                local vehEntity = spawnedVehicles[vehiclePlate].entity

                                if DoesEntityExist(vehEntity) then
                                    TriggerClientEvent(
                                        "chat:addMessage",
                                        _source,
                                        {
                                            templateId = "error",
                                            args = { "Vozidlo existuje někde ve světe, použij /gotocar!" }
                                        }
                                    )
                                else
                                    spawnedVehicles[vehiclePlate] = nil

                                    createVehicle(
                                        vehiclePlate,
                                        vec4(pedCoords.x, pedCoords.y, pedCoords.z, GetEntityHeading(playerPed))
                                    )

                                    exports.inventory:addPlayerItem(
                                        _source,
                                        "car_keys",
                                        1,
                                        {
                                            id = vehiclePlate,
                                            spz = vehiclePlate,
                                            label = "Klíče pro vozidlo s SPZ: " .. vehiclePlate
                                        }
                                    )

                                    TriggerClientEvent(
                                        "chat:addMessage",
                                        _source,
                                        {
                                            templateId = "success",
                                            args = { "Úspěšně jsi spawnul hráčské vozidlo!" }
                                        }
                                    )
                                end
                            else
                                createVehicle(
                                    vehiclePlate,
                                    vec4(pedCoords.x, pedCoords.y, pedCoords.z, GetEntityHeading(playerPed))
                                )

                                exports.inventory:addPlayerItem(
                                    _source,
                                    "car_keys",
                                    1,
                                    {
                                        id = vehiclePlate,
                                        spz = vehiclePlate,
                                        label = "Klíče pro vozidlo s SPZ: " .. vehiclePlate
                                    }
                                )

                                TriggerClientEvent(
                                    "chat:addMessage",
                                    _source,
                                    {
                                        templateId = "success",
                                        args = { "Úspěšně jsi spawnul hráčské vozidlo!" }
                                    }
                                )
                            end
                        end
                    else
                        local garageData = exports.garages:getVehicleGarageData(vehicleInfo.in_garage)

                        TriggerClientEvent(
                            "chat:addMessage",
                            _source,
                            {
                                templateId = "error",
                                args = { "Vozidlo je v garáži s postal codem " .. garageData.PostalCode }
                            }
                        )
                    end
                else
                    TriggerClientEvent(
                        "chat:addMessage",
                        _source,
                        {
                            templateId = "error",
                            args = { "Takové vlastněné vozidlo neexistuje!" }
                        }
                    )
                end
            else
                TriggerClientEvent(
                    "chat:addMessage",
                    _source,
                    {
                        templateId = "error",
                        args = { "Musíš zadat SPZ vozidla!" }
                    }
                )
            end
        else
            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "error",
                    args = { "Na toto nemáš právo!" }
                }
            )
        end
    end
)

RegisterCommand(
    "gotocar",
    function(source, args)
        local _source = source
        if exports.data:getUserVar(_source, "admin") > 1 then
            local vehiclePlate = tostring(args[1])

            if vehiclePlate and spawnedVehicles[vehiclePlate] then
                local vehEntity = spawnedVehicles[vehiclePlate].entity

                if DoesEntityExist(vehEntity) then
                    SetEntityCoords(GetPlayerPed(_source), GetEntityCoords(vehEntity))
                else
                    TriggerClientEvent(
                        "chat:addMessage",
                        _source,
                        {
                            templateId = "error",
                            args = { "Entita vozidla nebyla nalezena!" }
                        }
                    )
                end
            else
                TriggerClientEvent(
                    "chat:addMessage",
                    _source,
                    {
                        templateId = "error",
                        args = { "Takové vozidlo není spawnuté!" }
                    }
                )
            end
        else
            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "error",
                    args = { "Na toto nemáš právo!" }
                }
            )
        end
    end
)

RegisterCommand(
    "carloc",
    function(source, args)
        local _source = source
        if exports.data:getUserVar(_source, "admin") > 1 then
            local vehiclePlate = tostring(args[1])

            if vehiclePlate then
                local vehicleInfo = vehicles[vehiclePlate]

                if vehicleInfo then
                    if vehicleInfo.in_garage == 0 then
                        if vehicleInfo.towed then
                            TriggerClientEvent(
                                "chat:addMessage",
                                _source,
                                {
                                    templateId = "success",
                                    args = { "Vozidlo je na odtahovce" }
                                }
                            )
                        else
                            TriggerClientEvent(
                                "chat:addMessage",
                                _source,
                                {
                                    templateId = "success",
                                    args = { "Vozidlo je venku, použij /gotocar" }
                                }
                            )
                        end
                    else
                        local garageData = exports.garages:getVehicleGarageData(vehicleInfo.in_garage)
                        local text = "Vozidlo je v garáži s postal codem " .. garageData.PostalCode
                        TriggerClientEvent(
                            "chat:addMessage",
                            _source,
                            {
                                templateId = "success",
                                args = { text }
                            }
                        )
                    end
                else
                    TriggerClientEvent(
                        "chat:addMessage",
                        _source,
                        {
                            templateId = "error",
                            args = { "Takové vlastněné vozidlo neexistuje!" }
                        }
                    )
                end
            else
                TriggerClientEvent(
                    "chat:addMessage",
                    _source,
                    {
                        templateId = "error",
                        args = { "Musíš zadat SPZ vozidla!" }
                    }
                )
            end
        else
            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "error",
                    args = { "Na toto nemáš právo!" }
                }
            )
        end
    end
)

Citizen.CreateThread(
    function()
        while true do
            Wait(15000)
            for actualPlate, data in pairs(spawnedVehicles) do
                if not DoesEntityExist(data.entity) then
                    spawnedVehicles[actualPlate] = nil

                    if data.coords and data.coords.x and data.coords.y and data.coords.z then
                        local heading = data.heading
                        if not heading then
                            heading = 0.0
                        end

                        createVehicle(actualPlate, vec4(data.coords.x, data.coords.y, data.coords.z, heading))
                    else
                        print("AUTO NEEXISTUJE!", data.coords, data.heading)
                    end
                else
                    spawnedVehicles[actualPlate].coords = GetEntityCoords(data.entity)
                    spawnedVehicles[actualPlate].heading = GetEntityHeading(data.entity)
                end

                Wait(10)
            end
        end
    end
)

RegisterNetEvent("base_vehicles:removeVehicle")
AddEventHandler(
    "base_vehicles:removeVehicle",
    function(netId)
        local vehicle = NetworkGetEntityFromNetworkId(netId)
        if DoesEntityExist(vehicle) then
            removeVehicle(vehicle)
        end
    end
)

function removeVehicle(vehicle)
    for actualPlate, data in pairs(spawnedVehicles) do
        if data.entity == vehicle then
            spawnedVehicles[actualPlate] = nil
            break
        end
    end

    DeleteEntity(vehicle)
end

function removeVehicleByActualPlate(actualPlate)
    actualPlate = tostring(actualPlate)

    if actualPlate and spawnedVehicles[actualPlate] then
        if DoesEntityExist(spawnedVehicles[actualPlate].entity) then
            DeleteEntity(spawnedVehicles[actualPlate].entity)
        end

        spawnedVehicles[actualPlate] = nil
    end
end

RegisterNetEvent("base_vehicles:towVehicle")
AddEventHandler("base_vehicles:towVehicle", function(plate, blockVeh, netId)
    local client = source
    local allowed = false
    local jobs = exports.data:getCharVar(client, "jobs")

    for _, data in pairs(jobs) do
        local type = exports.base_jobs:getJobVar(data.job, "type")
        if type == "police" or data.job == "lsfd" then
            allowed = true
            break
        end
    end

    if allowed or exports.data:getUserVar(client, "admin") > 1 then
        updateVehicleCurrentGarage(plate, 0, true)
        changeVehicleBlockStatus(plate, blockVeh)
        local vehicle = NetworkGetEntityFromNetworkId(netId)
        removeVehicle(vehicle)
    end
end)

RegisterNetEvent("base_vehicles:unblockVehicle")
AddEventHandler("base_vehicles:unblockVehicle", function(plate)
    local client = source

    local allowed = false

    local jobs = exports.data:getCharVar(client, "jobs")
    for _, data in pairs(jobs) do
        local type = exports.base_jobs:getJobVar(data.job, "type")
        if type == "police" then
            allowed = true
            break
        end
    end
    if allowed or exports.data:getUserVar(client, "admin") > 1 then
        changeVehicleBlockStatus(plate, false)
    end
end)