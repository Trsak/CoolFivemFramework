RegisterNetEvent("settings:update")
AddEventHandler("settings:update",
    function(settings)
        local _source = source

        exports.data:updateUserVar(_source, "settings", settings)
    end
)