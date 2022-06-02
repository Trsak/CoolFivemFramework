RegisterNetEvent("gas_stations:payFuel")
AddEventHandler(
    "gas_stations:payFuel",
    function(cost)
        local _source = source
        exports.inventory:removePlayerItem(_source, "cash", math.ceil(cost), {})
    end
)
RegisterNetEvent("gas_stations:buyJerrycan")
AddEventHandler(
    "gas_stations:buyJerrycan",
    function()
        local _source = source
        local number = exports.base_shops:generateSerialNumber()
        data = {
            id = number,
            number = number
        }
        local reason = exports.inventory:addPlayerItem(_source, "weapon_petrolcan", 5000, data)

        if reason == "done" then
            exports.inventory:removePlayerItem(_source, "cash", 100, {})
            TriggerClientEvent(
                "notify:display",
                _source,
                {
                    type = "success",
                    title = "Benzínová pumpa",
                    text = "Hlavě pozor!",
                    icon = "fas fa-car",
                    length = 3000
                }
            )
        else
            TriggerClientEvent(
                "notify:display",
                _source,
                {
                    type = "error",
                    title = "Benzínová pumpa",
                    text = "Nemáte dostatek místa u sebe",
                    icon = "fas fa-car",
                    length = 3000
                }
            )
        end
    end
)
