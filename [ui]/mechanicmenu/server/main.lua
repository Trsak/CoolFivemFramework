function saveVeh(plate, props)
    local vehicle = exports.base_vehicles:getVehicle(plate)

    if vehicle and vehicle.data then
        exports.base_vehicles:updateVehicle(plate, props, true)
    end
end
RegisterNetEvent("mechanicmenu:buy")
AddEventHandler(
    "mechanicmenu:buy",
    function(job, price, vehicle, carSet)
        local vehicle = NetworkGetEntityFromNetworkId(vehicle)
        --print(job, price, vehicle)
        if job ~= nil then
            local _source = source
            local plate = exports.data:getVehicleActualPlateNumber(vehicle)
            if job == "admin" then
                if exports.data:getUserVar(_source, "admin") > 1 then
                    saveVeh(plate, carSet)
                    exports.logs:sendToDiscord(
                        {
                            channel = "mechanicmenu",
                            title = "Mechanik menu",
                            description = "Admin " ..
                                GetPlayerName(_source) ..
                                    " použil mechanik menu (SPZ: " .. plate .. ", $" .. price .. ")",
                            color = "34749"
                        },
                        source
                    )
                    TriggerClientEvent("mechanicmenu:buy", _source, "done")
                end
            else
                if exports.base_jobs:hasUserJob(_source, job, 0, true) then
                    local bankAccount = exports.base_jobs:getJobVar(job, "bank")
                    if bankAccount ~= nil and bankAccount ~= "" and bankAccount ~= " " then
                        local mechanic =
                            exports.data:getCharVar(_source, "firstname") ..
                            " " .. exports.data:getCharVar(_source, "lastname")
                        local pay =
                            exports.bank:payFromAccount(
                            tostring(bankAccount),
                            price,
                            false,
                            "Nákup dílů pro " .. exports.base_jobs:getJobVar(job, "label") .. " - provedl " .. mechanic
                        )
                        if pay == "done" then
                            saveVeh(plate, carSet)
                            exports.logs:sendToDiscord(
                                {
                                    channel = "mechanicmenu",
                                    title = "Mechanik menu",
                                    description = "Použití mechanik menu " ..
                                        mechanic ..
                                            " (frakce: " ..
                                                exports.base_jobs:getJobVar(job, "label") ..
                                                    ", $" .. price .. ", SPZ: " .. plate .. ")",
                                    color = "34749"
                                },
                                source
                            )
                            TriggerClientEvent("mechanicmenu:buy", _source, pay)
                        else
                            TriggerClientEvent("mechanicmenu:buy", _source, pay)
                        end
                    else
                        TriggerClientEvent("mechanicmenu:buy", _source, "accountNotExist")
                    end
                end
            end
        end
    end
)
