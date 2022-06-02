local PlayerRacing = {}
local Races = {}

MySQL.ready(function()
    MySQL.Async.fetchAll("SELECT * FROM phone_racing", {}, function(routes)
        for _, v in each(routes) do
            v["races"] = json.decode(v["races"])
            v["routes"] = json.decode(v["routes"])
            PlayerRacing[tostring(v.charid)] = v
        end
    end)
end)

RegisterNetEvent('qb-phone:server:getTracks')
AddEventHandler('qb-phone:server:getTracks', function(charid)
    local src = source
    local data = PlayerRacing[tostring(charid)] or {["routes"]={}}

    TriggerClientEvent("qb-phone:client:getTracks", src, data["routes"])
end)

RegisterNetEvent('qb-phone:server:getRaces')
AddEventHandler('qb-phone:server:getRaces', function(charid)
    local src = source
    local data = PlayerRacing[tostring(charid)] or {["races"]={}}

    TriggerClientEvent("qb-phone:client:getRaces", src, data["races"])
end)

RegisterNetEvent('qb-phone:server:createNewTrack')
AddEventHandler('qb-phone:server:createNewTrack', function(charid, track)
    local src = source
    if not PlayerRacing[tostring(charid)] then
        PlayerRacing[tostring(charid)] = {}
        PlayerRacing[tostring(charid)]["routes"] = {}
    else
        if not PlayerRacing[tostring(charid)]["routes"] then
            PlayerRacing[tostring(charid)]["routes"] = {}
        end
    end
    table.insert(PlayerRacing[tostring(charid)]["routes"], track)
end)


function getPlayerRoutes(charid)
    if PlayerRacing[tostring(charid)] then
        return PlayerRacing[tostring(charid)]["routes"]
    end
    return {}
end