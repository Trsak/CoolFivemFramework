local vehicles, stocks = {}, {}

Citizen.CreateThread(
    function()
        Citizen.Wait(1000)
        loadStock()
    end
)

function loadStock()
    while VEHICLE == nil or next(VEHICLE) == nil do
        Citizen.Wait(250)
    end

    for shopName, _ in pairs(Config.Places) do
        if not stocks[shopName] then
            stocks[shopName] = {}
        end

        for vehName, v in pairs(VEHICLE) do
            if stocks[shopName] then
                stocks[shopName][vehName] = {}

                stocks[shopName][vehName] = {
                    price = v.baseprice,
                    vehName = vehName,
                    label = v.label,
                    baseprice = v.baseprice,
                    maxspeed = v.maxspeed,
                    seats = v.seats,
                    model = v.model,
                    trunk = v.trunk,
                    class = tostring(v.class),
                    manufacturer = tostring(v.manufacturer),
                    drivetrain = v.drivetrain
                }
            end
        end
    end

    vehicles = {}

    for vehName, v in pairs(VEHICLE) do
        vehicles[vehName] = {
            label = v.label,
            baseprice = v.baseprice,
            maxspeed = v.maxspeed,
            seats = v.seats,
            model = v.model,
            trunk = v.trunk,
            class = tostring(v.class),
            manufacturer = tostring(v.manufacturer),
            drivetrain = v.drivetrain
        }
    end
    print("INFO: Vehicle Shop is loaded, resource start.")
    TriggerClientEvent("vehicles_shop:sync", -1, vehicles, stocks)
end

RegisterNetEvent("vehicles_shop:sync")
AddEventHandler(
    "vehicles_shop:sync",
    function()
        local _source = source
        TriggerClientEvent("vehicles_shop:sync", _source, vehicles, stocks)
    end
)

RegisterNetEvent("vehicles_shop:buyVehicle")
AddEventHandler(
    "vehicles_shop:buyVehicle",
    function(data, forwho, shopId, spawnIndex)
        local _source = source

        local targetId = forwho ~= nil and forwho or _source

        if Config.Places[shopId] == nil then
            print(
                "ERROR: Player with serverid [" ..
                    _source .. "] try to register vehicle, when he is not close to shop [" .. shopId .. "]"
            )
            return
        end

        if exports.inventory:removePlayerItem(_source, "cash", data.price, {}) == "done" then
            TriggerClientEvent(
                "notify:display",
                _source,
                {
                    type = "success",
                    title = "Prodejce vozidel",
                    text = "Zakoupil/a jsi vozidlo! Je za obchodem!",
                    icon = "fas fa-car",
                    length = 6000
                }
            )

            if targetId then
                local vehData = {
                    model = data.model,
                    fuelLevel = 100.0
                }

                local plate = exports.base_vehicles:addVehicle(exports.data:getCharVar(targetId, "id"), 0, vehData)
                if plate then
                    exports.inventory:forceAddPlayerItem(
                        _source,
                        "car_keys",
                        1,
                        {
                            id = plate,
                            spz = plate,
                            label = "Klíče pro vozidlo s SPZ: " .. plate
                        }
                    )
                    vehData.actualPlate = plate
                    exports.base_vehicles:createVehicle(
                        { spz = plate, data = vehData },
                        Config.Places[shopId].vehicleDelivery.spawnPos[spawnIndex],
                        _source
                    )
                    exports.bank:sendToAccount(
                        "3217781859",
                        data.price,
                        "Koupě vozidla - " .. data.model
                    )
                    exports.logs:sendToDiscord(
                        {
                            channel = "pdm",
                            title = "Koupě vozidla",
                            description = "Zakopil vozidlo: " ..
                                data.model .. " \n Cena: $" .. data.price .. " \n SPZ: " .. plate,
                            color = "497825"
                        },
                        _source
                    )
                end
                if targetId ~= _source then
                    TriggerClientEvent(
                        "notify:display",
                        targetId,
                        {
                            type = "success",
                            title = "Prodejce vozidel",
                            text = "Obdržel/a jsi vozidlo. Je za obchodem!",
                            icon = "fas fa-car",
                            length = 6000
                        }
                    )
                end
            end
        else
            TriggerClientEvent(
                "notify:display",
                _source,
                {
                    type = "error",
                    title = "Prodejce vozidel",
                    text = "Nemáš dostatek peněz na vozidlo " .. data.model .. " | " .. data.price,
                    icon = "fas fa-car",
                    length = 3000
                }
            )
        end
    end
)
