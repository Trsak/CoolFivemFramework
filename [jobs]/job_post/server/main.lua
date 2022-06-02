math.randomseed(os.time() + math.random(10000, 99999))
local customers = {}
local vehicles = {}

-- LOAD CUSTOMERS
Citizen.CreateThread(
    function()
        for po, data in pairs(Config.Customers) do
            if customers[po] == nil then
                customers[po] = {}
            end

            for i = 1, #Config.Customers[po] do
                customers[po][i] = {
                    Coords = Config.Customers[po][i],
                    Taken = false,
                    Delivered = false
                }
            end
        end
    end
)

RegisterNetEvent("job_post:sync")
AddEventHandler(
    "job_post:sync",
    function()
        local _source = source
        TriggerClientEvent("job_post:sync", _source, vehicles, customers)
    end
)

RegisterNetEvent("job_post:createNewVehicle")
AddEventHandler(
    "job_post:createNewVehicle",
    function(postoffice)
        local _source = source

        if tableLength(vehicles) > 0 then
            if isPlayerInVeh(_source) then
                TriggerClientEvent(
                    "notify:display",
                    _source,
                    {
                        type = "error",
                        title = "Post OP | " .. postoffice,
                        text = "Již jsi v jiném vozidle..",
                        icon = "fas fa-envelope",
                        length = 3000
                    }
                )
            else
                createVehicle(_source, postoffice)
            end
        else
            createVehicle(_source, postoffice)
        end
    end
)

RegisterNetEvent("job_post:updateVehicle")
AddEventHandler(
    "job_post:updateVehicle",
    function(vehData)
        local _source = source
        if isPlayerInVeh(_source) then
            vehicles[vehData.VehId].VehPlate = vehData.Plate
            vehicles[vehData.VehId].Vehicle = vehData.NetId
            TriggerClientEvent("job_post:sync", -1, vehicles, customers)
        end
    end
)

RegisterNetEvent("job_post:addPlayerToVeh")
AddEventHandler(
    "job_post:addPlayerToVeh",
    function(vehData, target, postoffice)
        local _source = source
        if isPlayerInVeh(_source) then
            if tableLength(vehicles[vehData.VehId].Players) < 4 then
                if not isPlayerInVeh(tonumber(target)) then
                    table.insert(vehicles[vehData.VehId].Players, tonumber(target))
                    TriggerClientEvent("job_post:sync", -1, vehicles, customers)
                    Citizen.Wait(10)
                    TriggerClientEvent("job_post:AddPlayerToVeh", tonumber(target), vehData, postoffice)
                    TriggerClientEvent(
                        "notify:display",
                        _source,
                        {
                            type = "success",
                            title = "Post OP",
                            text = "Úspěšně jsi přidal/a kámoše!",
                            icon = "fas fa-envelope",
                            length = 3500
                        }
                    )
                else
                    TriggerClientEvent(
                        "notify:display",
                        _source,
                        {
                            type = "error",
                            title = "Department Of Sanitation",
                            text = "Kámoš už pracuje jinde!",
                            icon = "fas fa-envelope",
                            length = 3500
                        }
                    )
                end
            end
        end
    end
)

RegisterNetEvent("job_post:getPackages")
AddEventHandler(
    "job_post:getPackages",
    function(type, count)
        local _source = source
        if isPlayerInVeh(_source) then
            local itemToGive = "letter"
            if type == "small" then
                itemToGive = "package_small"
            elseif type == "middle" then
                itemToGive = "package_big2"
            elseif type == "big" then
                itemToGive = "package_big"
            end
            local getItem = exports.inventory:addPlayerItem(_source, itemToGive, count, {})
            if getItem == "done" then
                local item = exports.inventory:getItem(itemToGive)
                TriggerClientEvent(
                    "notify:display",
                    _source,
                    {
                        type = "success",
                        title = "Post OP",
                        text = "Tady máš " .. count .. "krát " .. string.lower(item.label),
                        icon = "fas fa-envelope",
                        length = 3500
                    }
                )
            else
                TriggerClientEvent(
                    "notify:display",
                    _source,
                    {
                        type = "error",
                        title = "Post OP",
                        text = "Tohle neuneseš!",
                        icon = "fas fa-envelope",
                        length = 3500
                    }
                )
            end
        end
    end
)

RegisterNetEvent("job_post:deliveryPackage")
AddEventHandler(
    "job_post:deliveryPackage",
    function(vehId, postoffice)
        local _source = source

        if isPlayerInVeh(_source) then
            local customerId = vehicles[vehId].Current.Id
            if not customers[postoffice][customerId].Delivered then
                local havePackage = exports.inventory:removePlayerItem(_source, vehicles[vehId].Current.Type, 1, {})
                if havePackage == "done" then
                    local cash = 60

                    exports.daily_limits:addLimitCount(_source, "post", cash)
                    local isOverLimit = exports.daily_limits:checkIfIsOverLimit(_source, "post")

                    if isOverLimit then
                        TriggerClientEvent(
                            "notify:display",
                            _source,
                            {
                                type = "warning",
                                title = "Pošťák",
                                text = "Dnes jsi již vydělal přes limit, další dnešní zakázky budou hůře placené!",
                                icon = "fas fa-exclamation",
                                length = 5000
                            }
                        )

                        cash = math.ceil(cash / 6)
                    end

                    exports.inventory:addPlayerItem(_source, "cash", cash, {})
                    customers[postoffice][customerId].Taken = nil
                    customers[postoffice][customerId].Delivered = true
                    Citizen.SetTimeout(
                        3600000,
                        function()
                            customers[postoffice][customerId].Delivered = false
                        end
                    )

                    chooseNewDelivery(vehId, _source, postoffice)
                else
                    local item = exports.inventory:getItem(vehicles[vehId].Current.Type)
                    TriggerClientEvent(
                        "notify:display",
                        _source,
                        {
                            type = "error",
                            title = "Post OP | " .. postoffice,
                            text = "Tenhle nechci.. Chci " .. string.lower(item.label),
                            icon = "fas fa-envelope",
                            length = 4000
                        }
                    )
                end
            else
                chooseNewDelivery(vehId, _source, postoffice)
                TriggerClientEvent(
                    "notify:display",
                    _source,
                    {
                        type = "error",
                        title = "Post OP | " .. postoffice,
                        text = "Osoba již balíček má! Jeď na nové místo.",
                        icon = "fas fa-envelope",
                        length = 5000
                    }
                )
            end
        end
    end
)

RegisterNetEvent("job_post:endJob")
AddEventHandler(
    "job_post:endJob",
    function(vehId, postoffice)
        local _source, toDelete = source, nil
        if isPlayerInVeh(_source) then
            for _, ply in each(vehicles[vehId].Players) do
                if _source == ply then
                    table.remove(vehicles[vehId].Players, _)
                    if tableLength(vehicles[vehId].Players) == 0 then
                        toDelete = vehicles[vehId].Vehicle
                        vehicles[vehId] = nil
                    end
                    TriggerClientEvent("job_post:sync", -1, vehicles, customers)
                    break
                end
            end
            if toDelete then
                local vehicle = NetworkGetEntityFromNetworkId(toDelete)
                if vehicle then
                    local owner = NetworkGetEntityOwner(vehicle)
                    if owner > 0 then
                        TriggerClientEvent("job_post:deleteVehicle", owner, toDelete)
                    else
                        DeleteEntity(vehicle)
                    end
                end
            end
            TriggerClientEvent("job_post:endJob", _source, postoffice)
            TriggerClientEvent("job_post:sync", -1, vehicles, customers)
        end
    end
)

function chooseNewDelivery(vehId, source, postoffice)
    vehicles[vehId].Current = {
        Id = generateDeliveryNumber(source, vehId, postoffice),
        Type = generatePackageType()
    }

    if vehicles[vehId].Current.Id ~= 0 then
        TriggerClientEvent("job_post:sync", -1, vehicles, customers)
        Citizen.Wait(200)
        for _, ply in each(vehicles[vehId].Players) do
            TriggerClientEvent("job_post:nextDelivery", ply, vehId, postoffice)
        end
    else
        for _, ply in each(vehicles[vehId].Players) do
            TriggerClientEvent("job_post:noMoreDelivery", ply, postoffice)
        end
    end
end

-- MISCS

function createVehicle(source, postoffice)
    local vehNumber = generateVehNumber()

    vehicles[vehNumber] = {
        Players = { source },
        VehPlate = nil,
        Vehicle = nil,
        Current = {
            Id = generateDeliveryNumber(source, vehNumber, postoffice),
            Type = generatePackageType()
        }
    }
    if vehicles[vehNumber].Current.Id ~= 0 then
        TriggerClientEvent("job_post:sync", -1, vehicles, customers)
        Citizen.Wait(200)
        TriggerClientEvent("job_post:startWork", source, vehNumber, postoffice)
    else
        TriggerClientEvent(
            "notify:display",
            source,
            {
                type = "error",
                title = "Post OP | " .. postoffice,
                text = "Nenašli jsme pro tebe žádnou práci!",
                icon = "fas fa-envelope",
                length = 4000
            }
        )
    end
end

function tableLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

function isPlayerInVeh(ply)
    for _, vehicle in each(vehicles) do
        for _, player in each(vehicle.Players) do
            if player == tonumber(ply) then
                return true
            end
        end
    end
    return false
end

function generateVehNumber()
    while true do
        number = tostring(math.random(1, 9999))

        if not vehicles[number] then
            return number
        end
    end
end

function generateDeliveryNumber(source, vehId, postoffice)
    local closest, distance = 0, 100000
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    for i, customer in each(customers[postoffice]) do
        if #(playerCoords - customer.Coords) < distance and not customer.Taken and not customer.Delivered then
            closest, distance = i, #(playerCoords - customer.Coords)
        end
    end
    if tonumber(closest) > 0 then
        customers[postoffice][closest].Taken = vehId
    end
    return closest
end

function generatePackageType()
    while true do
        local number = math.random(1, 4)

        if number == 1 then
            return "package_small"
        elseif number == 2 then
            return "package_big"
        elseif number == 3 then
            return "package_big2"
        elseif number == 4 then
            return "letter"
        end
    end
end
