math.randomseed(os.time() + math.random(10000, 99999))
local customers = {}
local vehicles = {}

Citizen.CreateThread(
    function()
        for i, coords in each(Config.Customers) do
            customers[tostring(i)] = {
                Coords = coords,
                Taken = false,
                Delivered = false
            }
        end
    end
)

RegisterNetEvent("job_pizza:sync")
AddEventHandler(
    "job_pizza:sync",
    function()
        local _source = source
        TriggerClientEvent("job_pizza:sync", _source, customers)
    end
)

RegisterNetEvent("job_pizza:createNewVehicle")
AddEventHandler(
    "job_pizza:createNewVehicle",
    function()
        local _source = source

        if tableLength(vehicles) > 0 then
            if isPlayerInVeh(_source) then
                TriggerClientEvent(
                    "notify:display",
                    _source,
                    {
                        type = "error",
                        title = "Pizza This...",
                        text = "Již jsi v jiném skůtru..",
                        icon = "fas fa-utensils",
                        length = 3000
                    }
                )
            else
                createVehicle(_source)
            end
        else
            createVehicle(_source)
        end
    end
)

RegisterNetEvent("job_pizza:updateVehicle")
AddEventHandler(
    "job_pizza:updateVehicle",
    function(vehData)
        local _source = source
        if isPlayerInVeh(_source) then
            vehicles[vehData.VehId].VehPlate = vehData.Plate
            vehicles[vehData.VehId].Vehicle = vehData.NetId
            TriggerClientEvent("job_pizza:sync", -1, vehicles, customers)
        end
    end
)

RegisterNetEvent("job_pizza:getPackages")
AddEventHandler(
    "job_pizza:getPackages",
    function(type, count)
        local _source = source
        if isPlayerInVeh(_source) then
            local itemToGive = "pizza_box"
            if type == "ham" then
                itemToGive = "pizza_box2"
            elseif type == "cheese" then
                itemToGive = "pizza_box3"
            end
            local getItem = exports.food:giveItem(_source, itemToGive, count, nil, nil, "-blocked")
            if getItem == "done" then
                local item = exports.inventory:getItem(itemToGive)
                TriggerClientEvent(
                    "notify:display",
                    _source,
                    {
                        type = "success",
                        title = "Pizza This...",
                        text = "Tady máš " .. count .. "krát " .. string.lower(item.label),
                        icon = "fas fa-utensils",
                        length = 3500
                    }
                )
            else
                TriggerClientEvent(
                    "notify:display",
                    _source,
                    {
                        type = "error",
                        title = "Pizza This...",
                        text = "Tohle neuneseš!",
                        icon = "fas fa-utensils",
                        length = 3500
                    }
                )
            end
        end
    end
)

RegisterNetEvent("job_pizza:addPlayerToVeh")
AddEventHandler(
    "job_pizza:addPlayerToVeh",
    function(vehData, target)
        local _source = source
        if isPlayerInVeh(_source) then
            if tableLength(vehicles[vehData.VehId].Players) < 2 then
                if not isPlayerInVeh(tonumber(target)) then
                    table.insert(vehicles[vehData.VehId].Players, tonumber(target))
                    TriggerClientEvent("job_pizza:sync", -1, vehicles, customers)
                    Citizen.Wait(10)
                    TriggerClientEvent("job_pizza:AddPlayerToVeh", tonumber(target), vehData)
                    TriggerClientEvent(
                        "notify:display",
                        _source,
                        {
                            type = "success",
                            title = "Pizza This...",
                            text = "Úspěšně jsi přidal/a kámoše!",
                            icon = "fas fa-utensils",
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
                            text = "Kámoš/ka už pracuje jinde!",
                            icon = "fas fa-utensils",
                            length = 3500
                        }
                    )
                end
            end
        end
    end
)

RegisterNetEvent("job_pizza:deliveryPackage")
AddEventHandler(
    "job_pizza:deliveryPackage",
    function(vehId)
        local _source = source
        if isPlayerInVeh(_source) then
            local customerId = vehicles[vehId].Current.Id
            if not customers[customerId].Delivered then
                local item = vehicles[vehId].Current.Type
                local itemId = item .. "-" .. exports.food:getItem(item).Count .. "-blocked"
                local havePackage = exports.inventory:removePlayerItem(_source, item, 1, {id = itemId})
                if havePackage == "done" then
                    local cash = 60

                    exports.daily_limits:addLimitCount(_source, "pizza", cash)
                    local isOverLimit = exports.daily_limits:checkIfIsOverLimit(_source, "pizza")

                    if isOverLimit then
                        TriggerClientEvent(
                            "notify:display",
                            _source,
                            {
                                type = "warning",
                                title = "Rozvoz pizzy",
                                text = "Dnes jsi již vydělal přes limit, další dnešní zakázky budou hůře placené!",
                                icon = "fas fa-exclamation",
                                length = 5000
                            }
                        )

                        cash = math.ceil(cash / 6)
                    end

                    exports.inventory:addPlayerItem(_source, "cash", cash, {})
                    customers[customerId].Taken = nil
                    customers[customerId].Delivered = true
                    Citizen.SetTimeout(
                        3600000,
                        function()
                            customers[customerId].Delivered = false
                        end
                    )

                    chooseNewDelivery(vehId, _source)
                else
                    local item = exports.inventory:getItem(vehicles[vehId].Current.Type)
                    TriggerClientEvent(
                        "notify:display",
                        _source,
                        {
                            type = "error",
                            title = "Pizza This...",
                            text = "Tuhle nechci.. Chci " .. string.lower(item.label),
                            icon = "fas fa-utensils",
                            length = 4000
                        }
                    )
                end
            else
                chooseNewDelivery(vehId, _source)
                TriggerClientEvent(
                    "notify:display",
                    _source,
                    {
                        type = "error",
                        title = "Pizza This...",
                        text = "Osoba již pizzu má! Jeď na nové místo.",
                        icon = "fas fa-utensils",
                        length = 5000
                    }
                )
            end
        end
    end
)

RegisterNetEvent("job_pizza:endJob")
AddEventHandler(
    "job_pizza:endJob",
    function(vehId)
        local _source, toDelete = source, nil
        if isPlayerInVeh(_source) then
            for _, ply in each(vehicles[vehId].Players) do
                if _source == ply then
                    table.remove(vehicles[vehId].Players, _)
                    if tableLength(vehicles[vehId].Players) == 0 then
                        toDelete = vehicles[vehId].Vehicle
                        vehicles[vehId] = nil
                    end
                    TriggerClientEvent("job_pizza:sync", -1, vehicles, customers)
                    break
                end
            end
            if toDelete then
                local entity = NetworkGetEntityFromNetworkId(toDelete)
                local owner = NetworkGetEntityOwner(entity)
                if owner then
                    if owner > 0 then
                        TriggerClientEvent("job_pizza:deleteVehicle", owner, toDelete)
                    else
                        DeleteEntity(entity)
                    end
                end
            end
            TriggerClientEvent("job_pizza:endJob", _source)
            TriggerClientEvent("job_pizza:sync", -1, vehicles, customers)
        end
    end
)

function createVehicle(source)
    local vehNumber = generateVehNumber()
    local deliveryPointId = generateDeliveryNumber(source, vehNumber)

    if deliveryPointId and deliveryPointId ~= 0 then
        vehicles[vehNumber] = {
            Players = {source},
            VehPlate = nil,
            Vehicle = nil,
            Current = {
                Id = deliveryPointId,
                Type = generatePackageType()
            }
        }
        TriggerClientEvent("job_pizza:sync", -1, vehicles, customers)
        Citizen.Wait(200)
        TriggerClientEvent("job_pizza:startWork", source, vehNumber)
    else
        TriggerClientEvent(
            "notify:display",
            source,
            {
                type = "error",
                title = "Pizza This...",
                text = "Nenašli jsme pro tebe žádnou práci!",
                icon = "fas fa-utensils",
                length = 4000
            }
        )
    end
end

function chooseNewDelivery(vehId, source)
    vehicles[vehId].Current = {
        Id = generateDeliveryNumber(source, vehId),
        Type = generatePackageType()
    }
    if vehicles[vehId].Current.Id ~= 0 then
        TriggerClientEvent("job_pizza:sync", -1, vehicles, customers)
        Citizen.Wait(200)
        for _, ply in each(vehicles[vehId].Players) do
            TriggerClientEvent("job_pizza:nextDelivery", ply, vehId)
        end
    else
        for _, ply in each(vehicles[vehId].Players) do
            TriggerClientEvent("job_pizza:noMoreDelivery", ply)
        end
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

function generateDeliveryNumber(source, vehId)
    local closest, distance = 0, 100000
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    for i, customer in each(customers) do
        if #(playerCoords - customer.Coords) < distance and not customer.Taken and not customer.Delivered then
            closest, distance = i, #(playerCoords - customer.Coords)
        end
    end
    if tonumber(closest) > 0 then
        customers[closest].Taken = vehId
    end
    return closest
end

function generatePackageType()
    local number = math.random(1, 3)

    if number == 1 then
        return "pizza_box"
    elseif number == 2 then
        return "pizza_box2"
    elseif number == 3 then
        return "pizza_box3"
    end
end
