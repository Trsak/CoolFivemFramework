local garages = {}

Citizen.CreateThread(function()
    MySQL.ready(function()
        MySQL.Async.fetchAll("SELECT * FROM garages", {}, function(databaseGarages)
            local count = 0
            for _, garage in each(databaseGarages) do
                local decodedSelectCoords = json.decode(garage.select_coords)
                local selectCoords = {}
                if type(decodedSelectCoords) == "table" and not decodedSelectCoords.x then
                    for _, coords in each(decodedSelectCoords) do
                        table.insert(selectCoords, vec3(coords.x, coords.y, coords.z))
                    end
                else
                    selectCoords = vec3(decodedSelectCoords.x, decodedSelectCoords.y, decodedSelectCoords.z)
                end
                garages[tostring(garage.id)] = {
                    Id = garage.id,
                    houseId = garage.houseId,
                    SelectCoords = selectCoords,
                    SpawnLocations = json.decode(garage.spawn_locations),
                    Owner = garage.owner,
                    Available = garage.available,
                    Type = garage.type,
                    Properties = json.decode(garage.properties),
                    Job = json.decode(garage.job),
                    PostalCode = garage.postalcode
                }

                count = count + 1
            end
            print("^2[GARAGES]^7 Successfully loaded with " .. count .. " garages!")

            TriggerLatentClientEvent("garages:sync", -1, 100000, garages)
        end)
    end)
end)

RegisterNetEvent("garages:sync")
AddEventHandler("garages:sync", function()
    local client = source
    while not garages do
        Wait(200)
    end
    TriggerLatentClientEvent("garages:sync", client, 100000, garages)
end)

RegisterNetEvent("garages:getAvailableVehiclesFromGarage")
AddEventHandler("garages:getAvailableVehiclesFromGarage", function(garage, type)
    local client = source

    local charId = exports.data:getCharVar(client, "id")
    local vehicleList = exports.base_vehicles:getAvailableVehiclesFromGarage(client, charId, type ~= "tow" and garage or 0)

    if type == "tow" then
        for i, vehicle in each(vehicleList) do
            if vehicle.type ~= garages[tostring(garage)].Properties.vehicleType then
                table.remove(vehicleList, i)
            end
        end
    end

    TriggerClientEvent("garages:getAvailableVehiclesFromGarage", client, vehicleList, type)
end)

RegisterNetEvent("garages:takeVehicleFromGarage")
AddEventHandler("garages:takeVehicleFromGarage", function(data)
    local client = source
    local isTow = garages[tostring(data.garageid)].Type == "tow"
    local vehicleData = exports.base_vehicles:getVehicle(data.plate)
    local payment, done, jobVeh = "done", "notDone", false
    if isTow then
        if type(vehicleData.owner) == "table" then
            if vehicleData.owner.job then
                jobVeh = true
                local bank = exports.base_jobs:getJobVar(vehicleData.owner.job, "bank")
                payment = exports.bank:payFromAccount(tostring(bank), 100, false, "Platba za odtah - provedl " ..
                    exports.data:getCharNameById(exports.data:getCharVar(client, "id")))
            else
                payment = exports.inventory:removePlayerItem(client, "cash", 100, {})
            end
        else
            payment = exports.inventory:removePlayerItem(client, "cash", 100, {})
        end
    end

    if payment == "done" then
        if vehicleData.in_garage ~= 0 or vehicleData.towed and not vehicleData.blocked then
            done = setVehicleToGarage(vehicleData.data.actualPlate, 0)
            local hasKeys = exports.inventory:checkPlayerItem(client, "car_keys", 1, {
                id = vehicleData.data.actualPlate
            })
            if not hasKeys then
                exports.inventory:addPlayerItem(client, "car_keys", 1, {
                    id = vehicleData.data.actualPlate,
                    spz = vehicleData.data.actualPlate,
                    label = "Klíče pro vozidlo s SPZ: " .. vehicleData.data.actualPlate
                })
            end

            exports.base_vehicles:createVehicle(exports.base_vehicles:getVehicle(vehicleData.data.actualPlate),
                data.spawnpoint, client, false)
        end
    end
    TriggerClientEvent("garages:takeVehicleFromGarage", client, done, payment, jobVeh)
end)

RegisterNetEvent("garages:putVehicleInGarage")
AddEventHandler("garages:putVehicleInGarage", function(vehicle, vehData, garage)
    local client = source
    local garage = tostring(garage)

    local actualVehicle = NetworkGetEntityFromNetworkId(vehicle)
    if DoesEntityExist(actualVehicle) then
        local ent = Entity(actualVehicle)
        local actualPlate = ent.state.actualVehicle
        if actualPlate then
            vehData.actualPlate = actualPlate
        end
    end

    if vehData.actualPlate:match("%W") then
        print("^1[GARAGES]^7 Vehicle's plate contains spaces! - ", vehData.actualPlate)
        vehData.actualPlate = removeSpaces(vehData.actualPlate)
    end
    local done = "notExisting"
    local vehicleData = exports.base_vehicles:getVehicle(vehData.actualPlate)
    if vehicleData then
        local entityModel, vehModel = GetEntityModel(actualVehicle), GetHashKey(vehicleData.data.model)
        if (entityModel % 0x100000000) ~= vehModel and entityModel ~= vehModel then
            print("^1[GARAGES]^7 Vehicle's model is not same! " .. vehData.actualPlate .. " - ", entityModel, vehModel)
            return
        end

        if garages[garage].Properties.vehicleType == vehicleData.type then

            if tonumber(vehicleData.in_garage) == 0 then
                local canStoreVeh = exports.base_vehicles:checkCharVehicleCredibility(client, vehicleData.spz, garages[garage].Type)
                if canStoreVeh then
                    done = setVehicleToGarage(vehicleData.spz, garage)
                    exports.base_vehicles:updateVehicle(vehicleData.spz, vehData, true, true)
                else
                    done = "noCredibility"
                end
            else
                done = "inGarage"
            end
        else
            done = "badGarage"
        end
    end
    
    if done == "done" then
        exports.inventory:removePlayerItem(client, "car_keys", 1, {
            id = vehicleData.spz
        })
        exports.base_vehicles:removeVehicle(actualVehicle)

        TriggerClientEvent("notify:display", client, {
            type = "success",
            title = "Vozidlo uloženo",
            text = "Vozidlo uloženo do garáže!",
            icon = "fas fa-car",
            length = 3000
        })

        -- logging damaged vehicles
        if (vehData and vehData.bodyHealth and vehData.bodyHealth < 900.0) or
            (vehicleData and vehicleData.bodyHealth and vehicleData.bodyHealth < 900) then
            exports.logs:sendToDiscord({
                channel = "garage-destroyed",
                title = "Poškozené vozidlo uloženo do garáže",
                description = "Hráč uložil poškozené vozidlo (actualPlate) " .. vehData.actualPlate ..
                    " do garáže. Poškození: " ..
                    (vehData.bodyHealth ~= nil and vehData.bodyHealth or "neznámo"),
                color = "8782097"
            }, client)
        end
    else
        local text = "Vozidlo nenalezeno v systému!"
        if done == "badGarage" then
            text = "Do této garáže nepatří toto vozidlo!"
        elseif done == "inGarage" then
            text = "Vozidlo je již v nějaké garáži!"
        elseif done == "noCredibility" then
            text = "Tohle vozidlo nemůžeš uložit!"
        end
        TriggerClientEvent("notify:display", client, {
            type = "error",
            title = "Vozidlo neuloženo",
            text = text,
            icon = "fas fa-car",
            length = 5000
        })
    end
end)

function setVehicleToGarage(plate, garage)
    local garage = tostring(garage)
    if not plate then
        return "noPlate"
    end

    if not garage then
        return "noGarageId"
    end

    if tonumber(garage) ~= 0 and not garages[garage] then
        return "notExistingGarageId"
    end

    return exports.base_vehicles:updateVehicleCurrentGarage(plate, tonumber(garage))
end

function getVehicleGarageData(garage)
    if garage ~= 0 then
        return garages[tostring(garage)]
    end
end

RegisterNetEvent("garages:createGarage")
AddEventHandler("garages:createGarage", function(data)
    local client = source
    if exports.data:getUserVar(client, "admin") > 2 then
        createGarage(data)
        TriggerClientEvent("chat:addMessage", client, {
            templateId = "success",
            args = {"Garáž byla úspěšně vytvořena!"}
        })
    else
        exports.admin:banClientForCheating(client, "0", "Cheating", "garages:createGarage",
            "Hráč se pokusil vytvořit garáž!")
    end
end)

function createGarage(garageData)
    local garageId = generateGarageId()
    MySQL.Async.execute(
        "INSERT INTO garages (id, select_coords, spawn_locations, owner, available, type, properties, job, postalcode, houseId) VALUES (:id, :select_coords, :spawn_locations, :owner, :available, :type, :properties, :job, :postalcode, :houseId)",
        {
            id = garageId,
            select_coords = json.encode(garageData.SelectCoords),
            spawn_locations = json.encode(garageData.SpawnLocations),
            owner = garageData.Owner,
            available = garageData.Available,
            type = garageData.Type,
            properties = json.encode(garageData.Properties),
            job = json.encode(garageData.Job),
            postalcode = garageData.Postalcode,
            houseId = garageData.houseId
        }, function()
            return "done"
        end)
    local selectCoords = {}
    if type(garageData.SelectCoords) == "table" and not garageData.SelectCoords.x then
        for _, coords in each(garageData.SelectCoords) do
            table.insert(selectCoords, vec3(coords.x, coords.y, coords.z))
        end
    else
        selectCoords = vec3(garageData.SelectCoords.x, garageData.SelectCoords.y, garageData.SelectCoords.z)
    end
    garages[tostring(garageId)] = {
        Id = garageId,
        SelectCoords = selectCoords,
        SpawnLocations = garageData.SpawnLocations,
        Owner = garageData.Owner,
        Available = garageData.Available,
        Type = garageData.Type,
        Properties = garageData.Properties,
        Job = garageData.Job,
        houseId = garageData.houseId
    }
end

function generateGarageId()
    while true do
        local number = math.random(1000, 9999)

        if not garages[tostring(number)] then
            return number
        end
    end
    return nil
end

function removeSpaces(string)
    local toLower = string:gsub("%s+", "")
    toLower = string.gsub(toLower, "%s+", "")
    return toLower
end
