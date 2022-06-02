math.randomseed(os.time() + math.random(10000, 99999))
local trashCans = {}
local vehicles = {}

Citizen.CreateThread(
    function()
        trashCans = {}
        for index, coords in each(Config.Pickups) do
            trashCans[tostring(index)] = {
                Coords = coords,
                Trash = 5
            }
        end
    end
)

RegisterNetEvent("job_garbage:createNewVehicle")
AddEventHandler(
    "job_garbage:createNewVehicle",
    function()
        local _source = source

        if tableLength(vehicles) > 0 then
            if isPlayerInVeh(_source) then
                TriggerClientEvent(
                    "notify:display",
                    _source,
                    {
                        type = "error",
                        title = "Department Of Sanitation",
                        text = "Již jsi v jiném vozidle..",
                        icon = "fas fa-trash",
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

RegisterNetEvent("job_garbage:updateVehicle")
AddEventHandler(
    "job_garbage:updateVehicle",
    function(vehData)
        local _source = source
        if isPlayerInVeh(_source) then
            vehicles[vehData.VehId].VehPlate = vehData.Plate
            vehicles[vehData.VehId].Vehicle = vehData.NetId
            for i, player in each(vehicles[vehData.VehId].Players) do
                TriggerClientEvent("job_garbage:sync", player, vehicles, trashCans)
            end
        end
    end
)

RegisterNetEvent("job_garbage:addPlayerToVeh")
AddEventHandler(
    "job_garbage:addPlayerToVeh",
    function(vehData, target)
        local _source = source
        if isPlayerInVeh(_source) then
            if tableLength(vehicles[vehData.VehId].Players) < 4 then
                if not isPlayerInVeh(tonumber(target)) then
                    table.insert(vehicles[vehData.VehId].Players, tonumber(target))
                    for i, player in each(vehicles[vehData.VehId].Players) do
                        TriggerClientEvent("job_garbage:sync", player, vehicles, trashCans)
                    end
                    Citizen.Wait(10)
                    TriggerClientEvent("job_garbage:AddPlayerToVeh", tonumber(target), vehData)
                    TriggerClientEvent(
                        "notify:display",
                        _source,
                        {
                            type = "success",
                            title = "Department Of Sanitation",
                            text = "Úspěšně jsi přidal kámoše!",
                            icon = "fas fa-trash",
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
                            icon = "fas fa-trash",
                            length = 3500
                        }
                    )
                end
            end
        end
    end
)

RegisterNetEvent("job_garbage:pickupGarbage")
AddEventHandler(
    "job_garbage:pickupGarbage",
    function(trashCanId)
        local _source = source
        if isPlayerInVeh(_source) then
            if trashCans[trashCanId].Trash > 0 then
                TriggerClientEvent(
                    "notify:display",
                    _source,
                    {
                        type = "success",
                        title = "Department Of Sanitation",
                        text = "Vybíráš popelnici!",
                        icon = "fas fa-trash",
                        length = 3500
                    }
                )
                trashCans[trashCanId].Trash = trashCans[trashCanId].Trash - 1
                if trashCans[trashCanId].Trash <= 0 then
                    Citizen.SetTimeout(
                        2700000,
                        function()
                            trashCans[trashCanId].Trash = 5
                        end
                    )
                end
                TriggerClientEvent("job_garbage:pickupGarbage", _source)
            else
                TriggerClientEvent(
                    "notify:display",
                    _source,
                    {
                        type = "warning",
                        title = "Department Of Sanitation",
                        text = "Tady je prázdno!",
                        icon = "fas fa-trash",
                        length = 3000
                    }
                )
            end
        end
    end
)

RegisterNetEvent("job_garbage:throwGarbageToVeh")
AddEventHandler(
    "job_garbage:throwGarbageToVeh",
    function(vehId)
        local _source = source
        if isPlayerInVeh(_source) then
            if vehicles[vehId].InVehicle < 50 then
                TriggerClientEvent(
                    "notify:display",
                    _source,
                    {
                        type = "success",
                        title = "Department Of Sanitation",
                        text = "Házíš pytel do auta!",
                        icon = "fas fa-trash",
                        length = 3500
                    }
                )
                vehicles[vehId].InVehicle = vehicles[vehId].InVehicle + 1
                for i, player in each(vehicles[vehId].Players) do
                    TriggerClientEvent("job_garbage:sync", player, vehicles, trashCans)
                end
                Citizen.Wait(10)
                TriggerClientEvent("job_garbage:throwGarbageToVeh", _source)
            else
                TriggerClientEvent(
                    "notify:display",
                    _source,
                    {
                        type = "warning",
                        title = "Department Of Sanitation",
                        text = "Vozidlo je již plné!",
                        icon = "fas fa-trash",
                        length = 3000
                    }
                )
            end
        end
    end
)

RegisterNetEvent("job_garbage:unloadTrash")
AddEventHandler(
    "job_garbage:unloadTrash",
    function(vehId)
        local _source = source
        if isPlayerInVeh(_source) then
            if vehicles[vehId].Players[1] == _source then
                if vehicles[vehId].InVehicle > 0 then
                    if vehicles[vehId].Delivered >= 200 then
                        TriggerClientEvent(
                            "notify:display",
                            _source,
                            {
                                type = "success",
                                title = "Department Of Sanitation",
                                text = "Váš vyhrazený prostor je plný!",
                                icon = "fas fa-trash",
                                length = 3500
                            }
                        )
                    else
                        local newDelivered = vehicles[vehId].Delivered + vehicles[vehId].InVehicle
                        if newDelivered <= 200 then
                            vehicles[vehId].Delivered = newDelivered
                            vehicles[vehId].InVehicle = 0

                            for i, player in each(vehicles[vehId].Players) do
                                TriggerClientEvent("job_garbage:sync", player, vehicles, trashCans)
                            end
                            TriggerClientEvent(
                                "notify:display",
                                _source,
                                {
                                    type = "success",
                                    title = "Department Of Sanitation",
                                    text = "Vyložil jsi vozidlo..",
                                    icon = "fas fa-trash",
                                    length = 4000
                                }
                            )
                        else
                            TriggerClientEvent(
                                "notify:display",
                                _source,
                                {
                                    type = "success",
                                    title = "Department Of Sanitation",
                                    text = "Není tu místo, vyplaťte si uskladněné věci!",
                                    icon = "fas fa-trash",
                                    length = 4000
                                }
                            )
                        end
                    end
                end
            end
        end
    end
)

RegisterNetEvent("job_garbage:sellTrash")
AddEventHandler(
    "job_garbage:sellTrash",
    function(vehId)
        local _source = source
        if isPlayerInVeh(_source) then
            if vehicles[vehId].Players[1] == _source then
                if vehicles[vehId].Delivered > 0 then
                    local cash = tonumber(15 * vehicles[vehId].Delivered)

                    exports.daily_limits:addLimitCount(_source, "garbage", cash)
                    local isOverLimit = exports.daily_limits:checkIfIsOverLimit(_source, "garbage")

                    if isOverLimit then
                        TriggerClientEvent(
                            "notify:display",
                            _source,
                            {
                                type = "warning",
                                title = "Popelář",
                                text = "Dnes jsi již vydělal přes limit, další dnešní zakázky budou hůře placené!",
                                icon = "fas fa-exclamation",
                                length = 5000
                            }
                        )

                        cash = math.ceil(cash / 7)
                    end

                    exports.inventory:forceAddPlayerItem(_source, "cash", cash, {})
                    vehicles[vehId].Delivered = 0
                    for i, player in each(vehicles[vehId].Players) do
                        TriggerClientEvent("job_garbage:sync", player, vehicles, trashCans)
                    end
                end
            end
        end
    end
)

RegisterNetEvent("job_garbage:endJob")
AddEventHandler(
    "job_garbage:endJob",
    function(vehId)
        local _source = source
        if isPlayerInVeh(_source) then
            for _, ply in each(vehicles[vehId].Players) do
                if _source == ply then
                    table.remove(vehicles[vehId].Players, _)
                    if tableLength(vehicles[vehId].Players) <= 0 then
                        local entity = NetworkGetEntityFromNetworkId(vehicles[vehId].Vehicle)
                        local owner = NetworkGetEntityOwner(entity)
                        if owner then
                            if owner > 0 then
                                TriggerClientEvent("job_garbage:deleteVehicle", owner, vehicles[vehId].Vehicle)
                            else
                                DeleteEntity(entity)
                            end
                        end
                        vehicles[vehId] = nil
                    else
                        for i, player in each(vehicles[vehId].Players) do
                            TriggerClientEvent("job_garbage:sync", player, vehicles, trashCans)
                        end
                    end
                    break
                end
            end
            TriggerClientEvent("job_garbage:endJob", _source)
        end
    end
)

AddEventHandler(
    "playerDropped",
    function()
        for _, vehicle in each(vehicles) do
            for x, player in each(vehicle.Players) do
                if source == player then
                    table.remove(vehicle.Players, x)
                    for i, p in each(vehicle.Players) do
                        TriggerClientEvent("job_garbage:sync", p, vehicles, trashCans)
                    end
                    break
                end
            end
        end
    end
)

function createVehicle(source)
    local vehNumber = generateVehNumber()

    vehicles[vehNumber] = {
        Players = { source },
        VehPlate = nil,
        Vehicle = nil,
        InVehicle = 0,
        Delivered = 0,
        NewTrash = true
    }
    TriggerClientEvent("job_garbage:sync", source, vehicles, trashCans)
    Citizen.Wait(200)
    TriggerClientEvent("job_garbage:startWork", source, vehNumber)
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

        if vehicles[number] == nil then
            return number
        end
    end
end
