RegisterNetEvent("medkit:checkHealth")
AddEventHandler(
    "medkit:checkHealth",
    function(target, item)
        local _source = source
        local isDead = (exports.data:getUserVar(target, "status") == "dead")
        TriggerClientEvent("medkit:checkHealth", _source, target, item, isDead)
    end
)

RegisterNetEvent("medkit:revive")
AddEventHandler(
    "medkit:revive",
    function(target, item)
        local _source = source
        if
            exports.base_jobs:hasUserJobType(_source, "medic", true) or
                exports.base_jobs:hasUserJobType(_source, "police", true)
         then
            exports.data:updateUserVar(target, "status", "spawned")

            if item == "medkit" then
                exports.inventory:removePlayerItem(_source, "medkit", 1, {})
            end
        end
    end
)

RegisterNetEvent("medkit:heal")
AddEventHandler(
    "medkit:heal",
    function(target, health, item)
        local _source = source

        exports.inventory:removePlayerItem(_source, item, 1, {})
        TriggerClientEvent("medkit:heal", target ~= "me" and target or _source, health)
    end
)

RegisterNetEvent("medkit:infusion")
AddEventHandler(
    "medkit:infusion",
    function(target)
        local _source = source

        if not target or target == 0 or target == -1 then
            return
        end

        if exports.base_jobs:hasUserJobType(_source, "medic", true) then
            TriggerClientEvent("medkit:infusion", target)
            exports.inventory:removePlayerItem(_source, "infusion", 1, {})
        end
    end
)
