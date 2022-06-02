RegisterNetEvent("dice:roll")
AddEventHandler(
    "dice:roll",
    function()
        local _source = source
        TriggerClientEvent("dice:roll", -1, _source, math.random(6))
    end
)
