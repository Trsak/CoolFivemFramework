local scoreboardData = {}

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    local isDev = exports.control:isDev()
    if isDev then
        scoreboardData.name = "DEV server.cz"
    else
        scoreboardData.name = "server.cz"
    end
    scoreboardData.maxPlayers = GetConvarInt("sv_maxclients", 64)

    -- RESOURCE START
    local scoreboardList = {}

    local users = exports.data:getUsersBaseData(
        function(userData)
            return userData.status == "spawned" or userData.status == "dead" or userData.status == "choosing"
        end
    )

    for identifier, userData in each(users) do
        table.insert(scoreboardList, {
            source = userData.source,
            name = userData.nickname,
            vipLevel = exports.vip:getVipLevel(identifier)
        })
    end

    scoreboardData.players = scoreboardList
    scoreboardData.currentPlayers = #scoreboardList
    scoreboardData.jobCounts = {
        lsfd = exports.data:countEmployees("lsfd", nil, nil, true),
        paramedics = exports.data:countEmployees("ems", nil, nil, true),
        doctors = exports.data:countEmployees("ems", nil, 10, true),
        taxi = exports.data:countEmployees(nil, "taxi", nil, true)
    }

    scoreboardData.jobCounts.paramedics = scoreboardData.jobCounts.paramedics - scoreboardData.jobCounts.doctors

    TriggerClientEvent("scoreboard:sync", -1, scoreboardData)
end)

AddEventHandler("data:startedChoosing", function(client, identifier, isNewPlayer)
    if isNewPlayer then
        local playerName = GetPlayerName(client)
        if playerName then
            local playerData = {
                source = client,
                name = playerName,
                vipLevel = exports.vip:getVipLevel(identifier)
            }

            table.insert(scoreboardData.players, playerData)

            TriggerClientEvent("scoreboard:addUser", -1, playerData)
            TriggerClientEvent("scoreboard:sync", client, scoreboardData)
        end
    end
end)

AddEventHandler("playerDropped", function()
    local client = source
    for i, data in each(scoreboardData.players) do
        if client == data.source then
            table.remove(scoreboardData.players, i)
            TriggerClientEvent("scoreboard:removeUser", -1, client)
            break
        end
    end
end)

RegisterNetEvent("base_jobs:sendDutyChange")
AddEventHandler("base_jobs:sendDutyChange", function(client, job, grade, duty)
    if scoreboardData.jobCounts[job] then
        scoreboardData.jobCounts[job] = scoreboardData.jobCounts[job] + (duty and 1 or -1)
    elseif job == "ems" then
        if grade >= 10 then
            scoreboardData.jobCounts.doctors = scoreboardData.jobCounts.doctors + (duty and 1 or -1)
            job = "doctors"
        else
            scoreboardData.jobCounts.paramedics = scoreboardData.jobCounts.paramedics + (duty and 1 or -1)
            job = "paramedics"
        end
    end

    if scoreboardData.jobCounts[job] then
        TriggerClientEvent("scoreboard:jobChanged", -1, job, duty)
    end
end)
