RegisterNetEvent("mechanic:restrictedOpen")
AddEventHandler(
    "mechanic:restrictedOpen",
    function(plate, job)
        local _source = source

        if exports.base_vehicles:checkCharVehicleCredibility(_source, plate) then
            TriggerClientEvent("mechanic:restrictedOpen", _source, job)
        else
            TriggerClientEvent(
                "notify:display",
                _source,
                {
                    type = "success",
                    title = "Úprava vozidla",
                    text = "Nemůžete upravovat toto vozidlo!",
                    icon = "fas fa-car",
                    length = 4000
                }
            )
        end
    end
)
