RegisterNetEvent("plastic_surgery:pay")
AddEventHandler(
    "plastic_surgery:pay",
    function()
        local _source = source

        if exports.inventory:checkPlayerItem(_source, "cash", Config.Price, {}) then
            exports.inventory:removePlayerItem(_source, "cash", Config.Price, {})
            
            local account = exports.base_jobs:getJobVar(Config.medicJob, "bank")
            if account ~= nil or account ~= "" then 
                local done = exports.bank:addFunds(account, Config.Price)
            end
            TriggerClientEvent("plastic_surgery:bought", _source)
        else
            TriggerClientEvent("plastic_surgery:notEnoughMoney", _source)
        end
    end
)
