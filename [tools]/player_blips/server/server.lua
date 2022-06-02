local second = 1000
local updateSpacing = 250
local updateIntervals = {
    [256]   = second * 15,       -- once every 15 seconds | during 256-1024 players
    [128]   = second * 10,       -- once every 10 seconds | during 128-256 players
    [96]    = second * 5,       -- once every 5 seconds | during 96-128 players
    [64]    = second,           -- once every second | during 64-96 players
    [0]     = second            -- once every second    | during 0-64 players
}
local players = {}
local admins = {}
local allplayers = {}
local lastBlipsUpdate = {}
local lastABlipsUpdate = {}
local threadTimeWarnings = true
local mainThreadTimeThreshold = 10         -- parent thread
local updateThreadTimeThreshold = 10        -- blip updates thread
local lastIntervalValue = 0
local lastAIntervalValue = 0

function math.clamp(low, n, high)
    return math.min(math.max(n, low), high)
end

-- emitted when a player leaves the server
AddEventHandler("playerDropped", function()
    local admin = false
    if players[tostring(source)] then
        players[tostring(source)]['remove'] = true --[9] = true
    end
    if allplayers[tostring(source)] then
        allplayers[tostring(source)]['remove'] = true--[7] = true
    end
    if admins[tostring(source)] then
        admins[tostring(source)]['remove'] = true--[2] = true
        admin = true
    end
    TriggerClientEvent("player_blips:elimnate", -1, source, admin)
end)

RegisterNetEvent('player_blips:allPlayers')
AddEventHandler('player_blips:allPlayers', function(player_data, job)
    allplayers[tostring(source)] = { classtype = player_data['classtype'],  adminPower = player_data['adminPower'], isDead = player_data['isDead'], GPS = player_data['GPS'], job = job}
end)


RegisterNetEvent('player_blips:car')
AddEventHandler('player_blips:car', function(netId, job, stop, vehicleType, remove)
    addVeh(netId, job, stop, vehicleType, remove)
end)

RegisterNetEvent('player_blips:onblips')
AddEventHandler('player_blips:onblips', function(serverid, job, player_data, hide, stop, remove)
    local client = source
    addPlayer(client, job, player_data, hide, stop, remove)
end)

RegisterNetEvent('player_blips:addAdmin')
AddEventHandler('player_blips:addAdmin', function(source)
    addAdmin(source)
end)

RegisterCommand('adminblip', function(source, args)
    addAdmin(source)
end, false)

function addAdmin(source)
    if admins[tostring(source)] then
        admins[tostring(source)]['remove'] = true
        TriggerClientEvent('notify:display', source, {type = "success", title = "Admin", text = "Vypl sis blipy. 👿", icon = "fas fa-times", length = 5000})
    else
        if exports.data:getUserVar(source, "admin") > 0 then
            admins[tostring(source)] = { serverid = source, remove = false }
            TriggerClientEvent('notify:display', source, {type = "success", title = "Admin", text = "Zapl sis blipy. 👿", icon = "fas fa-times", length = 5000})
        end
    end
end

function addPlayer(serverid, job, player_data, hide, stop, remove)
    if GetPlayerName(serverid) then
        local isCar = false
        local data = {
            serverid = serverid,
            pedID = GetPlayerPed(serverid),
            status = "running",
            job = job,
            isDead = player_data['isDead'],
            classtype = player_data['classtype'],
            lastname = player_data['lastname'],
            isCar = isCar,
            hide = hide,
            stop = stop,
            remove = remove
        }

        if players[tostring(serverid)] then
            data['status'] = players[tostring(serverid)]['status']
        end

        players[tostring(serverid)] = data
    end
end

function addVeh(netId, job, stop, vehicleType, remove)
    local car, dead, isCar = nil, false, false
    local hide = false
    local data = {}

    if NetworkGetEntityFromNetworkId(netId) then
        car = NetworkGetEntityFromNetworkId(netId)
        isCar = true
    end

    local id = netId

    if car ~= nil and job ~= nil and isCar and not remove then
        if Config.Emergency[job] then
            data = {
                serverid = car,
                status = "running",
                job = job,
                isDead = dead,
                classtype = vehicleType,
                lastname = job .. " " ..car,
                isCar = isCar,
                hide = hide,
                stop = stop,
                remove = remove
            }
            if players[tostring(id)] then
                data['status'] = players[tostring(id)]['status']
            end

            players[tostring(id)] = data
        end
    else
        if car ~= nil and (job == nil or remove) and players[tostring(id)] then
            --print(tostring(id))
            players[tostring(id)]['remove'] = true
        end
    end
end

-- this is the main update thread for pushing blip location updates to players
Citizen.CreateThread(function()
    while true do
        local mt_begin = GetGameTimer()
        local updateInterval = 0
        local updateIntervalLimit = 0
        for limit, interval in each(updateIntervals) do
            if(limit <= #players) then
                updateInterval = interval
                updateIntervalLimit = limit
            end
        end

        if(lastIntervalValue ~= updateIntervalLimit) then
            lastIntervalValue = updateIntervalLimit
            --print(string.format("[^Blips^7] Updated blip update interval to ^2%dms (%d) ^7due to ^2%d ^7players being connected.", updateInterval, updateIntervalLimit, #players))
        end

        Citizen.CreateThread(function()
            local up_begin = GetGameTimer()
            -- iterate through the players table above and build an event object
            -- that includes the players' server ID and their in-game position
            local blips = {}
            --Utils.DumpTable(players)
            for index, player in each(players) do
                if players[1] ~= 0 then
                    if player['job'] ~= nil and tonumber(player['serverid']) then
                        local playerID = tonumber(player['serverid'])
                        local playerPed = nil
                        local job = player['job']
                        local dead = player['isDead']
                        local vehType = player['classtype']
                        local isCar = player['isCar']
                        local car = false
                        local hide = player['hide']
                        local stop = player['stop']
                        local remove = player['remove']

                        if not isCar then
                            --local instance = exports.instance:getPlayerInstance(playerID)
                            --if instance ~= nil and instance ~= "" then
                            --    stop = true
                            --end
                        end

                        if isCar then
                            playerPed = playerID
                        else
                            playerPed = player['pedID']
                        end
                        
                        -- check if ped exists to refrain from iterating potentially invalid player entities
                        -- causes some players to not have blips if not double-checked
                        if(DoesEntityExist(playerPed) and not hide) then
                            if not stop and not remove then
                                local coords = GetEntityCoords(playerPed)
                                local heading = GetEntityHeading(playerPed)
                                local lastname = player['lastname'] or GetPlayerName(playerID)
                                local name = ''

                                if isCar == true then
                                    if job == "crime" then
                                        name = "Vozidlo s lokátorem"
                                    else
                                        name = job .. ' ' .. 'CarUnit' .. ' ' .. '#' .. playerID
                                        if vehType == 15 or vehType == 16 then
                                            if job == 'plane' then
                                                name = job .. ' ' .. '#' .. playerID
                                            else
                                                name = job .. 'plane' .. '#' .. playerID
                                            end
                                        end
                                    end
                                else
                                    name = job .. ' ' .. 'Unit' .. ' ' .. '#' .. lastname
                                end


                                if isCar then
                                    if tostring(GetVehicleEngineHealth(playerPed)) == '-nan' then
                                        players[index]['isDead'] = true
                                        dead = true
                                    else
                                        players[index]['isDead'] = false
                                    end
                                else
                                    if vehType ~= 22 then
                                        car = NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(playerPed, false)) or "undefined"
                                    end
                                end

                                local obj = {
                                    playerID, NetworkGetNetworkIdFromEntity(playerPed), job, name, { coords.x, coords.y, coords.z },
                                    dead, heading, vehType, isCar, car, hide, stop, remove

                                }
                                blips[playerPed] = obj
                            else
                                if player['status'] ~= "removed" then
                                    if not player['isCar'] then
                                        TriggerClientEvent("player_blips:offblips", player['serverid'], false)
                                    end
                                    --TriggerClientEvent("player_blips:elimnate", -1, player['serverid'], false)
                                    if players[tostring(player['serverid'])] then
                                        players[tostring(player['serverid'])]['status'] = "removed"
                                    end
                                    player['status'] = "removed"
                                end
                            end
                        else
                            if player['status'] ~= "hidden" then
                                local id = player['serverid']
                                if not isCar then
                                    TriggerClientEvent("player_blips:offblips", id, false)
                                end
                                --TriggerClientEvent("player_blips:elimnate", -1, id, false)
                                players[index]['status'] = "hidden"
                            end
                        end
                    end
                end
            end

            -- create another thread to quickly move-on to the next tick
            Citizen.CreateThread(function()
                for _, player in each(players) do
                    local playerID = tonumber(player['serverid'])
                    local hide = player['hide']
                    local stop = player['stop']
                    local remove = player['remove']
                    if not remove then
                        if not hide or not stop then
                            if playerID ~= 0 then
                                if (DoesEntityExist(playerID)) or (DoesEntityExist(GetPlayerPed(playerID))) then
                                    local final = {}
                                    -- filter-out the players' blip from the blips array being sent
                                    for _, blip in each(blips) do
                                        --if (blip[1] ~= player[1]) then
                                        table.insert(final, blip)
                                        --end
                                    end

                                    if (DoesEntityExist(GetPlayerPed(playerID))) then
                                        TriggerLatentClientEvent("player_blips:updateBlips", playerID, 0, final)
                                    end
                                    Citizen.Wait(math.clamp(10, updateSpacing, 100))
                                end
                            end
                        end
                    else
                        if player['status'] ~= "removed" then
                            if not player['isCar'] then
                                TriggerClientEvent("player_blips:offblips", player['serverid'], false)
                            end
                            --TriggerClientEvent("player_blips:elimnate", -1, player['serverid'], false)
                            if players[tostring(player['serverid'])] then
                                players[tostring(player['serverid'])]['status'] = "removed"
                            end
                            player['status'] = "removed"
                        end
                    end
                end
            end)

            lastBlipsUpdate = blips

            -- if threadTimeWarnings is enabled, then calculate the time it took to run this thread
            -- and if its above the threshold then send a warning to the server console
            if(threadTimeWarnings) then
                local up_loopTime = GetGameTimer() - up_begin
                if(up_loopTime > updateThreadTimeThreshold) then
                    --print(string.format("[^Blips^7] Update thread loopTime: ^3%i ms ^7(your server is ^1lagging ^7or ^3updateThreadTimeThreshold ^7is too low)", up_loopTime))
                end
            end
        end)

        -- if threadTimeWarnings is enabled, then calculate the time it took to run this thread
        -- and if its above the threshold then send a warning to the server console
        if(threadTimeWarnings) then
            local mt_loopTime = GetGameTimer() - mt_begin
            if(mt_loopTime > mainThreadTimeThreshold) then
                --print(string.format("[^Blips^7] Main thread loopTime: ^1%i ms ^7(your server is ^1lagging ^7or ^1mainThreadTimeThreshold ^7is too low)", mt_loopTime))
            end
        end

        Citizen.Wait(updateInterval)
    end
end)


--Admin blips
Citizen.CreateThread(function()
    while true do
        local mt_beginA = GetGameTimer()
        local updateAInterval = 0
        local updateAIntervalLimit = 0
        for limit, interval in each(updateIntervals) do
            if(limit <= #allplayers) then
                updateAInterval = interval
                updateAIntervalLimit = limit
            end
        end

        if(lastAIntervalValue ~= updateAIntervalLimit) then
            lastAIntervalValue = updateAIntervalLimit
            --print(string.format("[^ABlips^7] Updated blip update interval to ^2%dms (%d) ^7due to ^2%d ^7players being connected.", updateAInterval, updateAIntervalLimit, #allplayers))
        end

        Citizen.CreateThread(function()
            local up_beginA = GetGameTimer()

            local blipsA = {}
            for indexE, playerE in each(allplayers) do
                if playerE ~= nil then
                    local playerIDA = tonumber(indexE)
                    local status = playerE['classtype']
                    local playerPedA = GetPlayerPed(indexE)
                    local heading = GetEntityHeading(playerPedA)
                    local adminPower = playerE['adminPower']
                    local dead = playerE['isDead']
                    local car = playerE['GPS']
                    local job = playerE['job']

                    if (DoesEntityExist(playerPedA) and playerE['remove'] == nil) then
                        local coordsA = GetEntityCoords(playerPedA)
                        local nameA = GetPlayerName(playerIDA).. ' | '.. playerIDA
                        local instance =  nil --exports.instance:getPlayerInstance(playerIDA)
                        if instance ~= nil then
                            ----print(instance)
                            job = 'instance'
                        end
                        if status ~= 22 then
                            car = NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(playerPedA, false))
                        end

                        local objA = {
                            playerIDA, NetworkGetNetworkIdFromEntity(playerPedA), nameA, { coordsA.x, coordsA.y, coordsA.z },
                            status, heading, adminPower, dead, car, job
                        }

                        blipsA[playerPedA] = objA
                    else
                        TriggerClientEvent("player_blips:elimnate", -1, indexE, true)
                        allplayers[indexE] = nil
                    end
                end
            end

            Citizen.CreateThread(function()
                for indexA, playerA in each(admins) do
                    if playerA['serverid'] ~= 0 then

                        if DoesEntityExist(GetPlayerPed(playerA['serverid'])) and not playerA['remove'] then
                            local finalA = {}
                            for _, blipA in each(blipsA) do
                                if(blipA[1] ~= playerA) then
                                    table.insert(finalA, blipA)
                                end
                            end
                            TriggerLatentClientEvent("player_blips:updateABlips", playerA['serverid'], 0, finalA)
                            Citizen.Wait(math.clamp(10, updateSpacing, 100))
                        else
                            TriggerClientEvent("player_blips:offblips", indexA, true)
                            admins[indexA] = nil
                        end
                    end
                end
            end)

            lastABlipsUpdate = blipsA

            if(threadTimeWarnings) then
                local up_loopTimeA = GetGameTimer() - up_beginA
                if(up_loopTimeA > updateThreadTimeThreshold) then
                    --print(string.format("[^ABlips^7] Update thread loopTime: ^3%i ms ^7(your server is ^1lagging ^7or ^3updateThreadTimeThreshold ^7is too low)", up_loopTimeA))
                end
            end
        end)

        if(threadTimeWarnings) then
            local mt_loopTimeA = GetGameTimer() - mt_beginA
            if(mt_loopTimeA > mainThreadTimeThreshold) then
                --print(string.format("[^ABlips^7] Main thread loopTime: ^1%i ms ^7(your server is ^1lagging ^7or ^1mainThreadTimeThreshold ^7is too low)", mt_loopTimeA))
            end
        end
        Citizen.Wait(updateAInterval)
    end
end)