local Players = {}
local NearPlayers = {}
local Events = {}
local firstUpdateInterval = 500
local secondUpdateInterval = 250
local thirdUpdateInterval = 250
local threadTimeWarnings = true
local ThreadTimeThreshold = 10

AddEventHandler("playerDropped", function()
    Players[source] = nil
end)

RegisterNetEvent('player_near_coords:add_player')
AddEventHandler('player_near_coords:add_player', function(data)
   local src = source
    Players[src] = data
    Players[src]["PlayerPed"] = GetPlayerPed(src)
    Players[src]["InArea"] = false
    Players[src]["InPlace"] = false
    Players[src]["OnPoint"] = false
    Players[src]["LeftPoint"] = false
end)

function add_event(resourceName, data)
    if resourceName ~= nil and type(resourceName) == "string" then
        if data.coords ~= nil then
            Events[resourceName] = data
        end
    end
end

Citizen.CreateThread(function()
    while true do
        local mt_begin = GetGameTimer()

        for event, event_data in each(Events) do
            local event_coords = event_data.coords
            local event_distance = 100
            if type(event_coords) == "table" then
                for place, coords in each(event_coords) do
                    for player, data in each(Players) do
                        local playerCoords = GetEntityCoords(GetPlayerPed(player))
                        if #(playerCoords - coords.coords) <= event_distance then
                            NearPlayers[player] = data
                        else
                            if NearPlayers[player] then
                                NearPlayers[player] = nil
                            end
                        end
                    end
                end
            else
                for player, data in each(Players) do
                    local playerCoords = GetEntityCoords(player)
                    if #(playerCoords - coords.coords) <= event_distance then
                        NearPlayers[player] = data
                    else
                        if NearPlayers[player] then
                            NearPlayers[player] = nil
                        end
                    end
                end
            end
        end

        if(threadTimeWarnings) then
            local mt_loopTime = GetGameTimer() - mt_begin
            if(mt_loopTime > ThreadTimeThreshold) then
                print(string.format("[^%s^7] First thread loopTime: ^1%i ms ^7(your server is ^1lagging ^7or ^1mainThreadTimeThreshold ^7is too low)", GetCurrentResourceName(), mt_loopTime))
            end
        end
        Citizen.Wait(firstUpdateInterval)
    end
end)

Citizen.CreateThread(function()
    while true do
        local mt_begin = GetGameTimer()

        for event, event_data in each(Events) do
            local event_coords = event_data.coords
            local event_distance = event_data.distance or 1.5
            if type(event_coords) == "table" then
                for place, coords in each(event_coords) do
                    for player, data in each(NearPlayers) do
                        local playerCoords = GetEntityCoords(GetPlayerPed(player))
                        if #(playerCoords - coords.coords) <= event_distance then
                            NearPlayers[player]["InArea"] = event
                            NearPlayers[player]["InPlace"] = place
                        else
                            if NearPlayers[player]["OnPoint"] then
                                if NearPlayers[player]["InPlace"] and NearPlayers[player]["InPlace"] == place and not NearPlayers[player]["LeftPoint"] then
                                    NearPlayers[player]["LeftPoint"] = true
                                end
                            end
                        end
                    end
                end
            else
                for player, data in each(NearPlayers) do
                    local playerCoords = GetEntityCoords(player)
                    if #(playerCoords - coords.coords) <= event_distance then
                        NearPlayers[player]["InArea"] = event
                    else
                        if NearPlayers[player]["OnPoint"] then
                            if NearPlayers[player]["InArea"] and NearPlayers[player]["InArea"] == event then

                                NearPlayers[player]["LeftPoint"] = true
                            end
                        end
                    end
                end
            end
        end

        if(threadTimeWarnings) then
            local mt_loopTime = GetGameTimer() - mt_begin
            if(mt_loopTime > ThreadTimeThreshold) then
                print(string.format("[^%s^7] second thread loopTime: ^1%i ms ^7(your server is ^1lagging ^7or ^1mainThreadTimeThreshold ^7is too low)", GetCurrentResourceName(), mt_loopTime))
            end
        end
        Citizen.Wait(secondUpdateInterval)
    end
end)

Citizen.CreateThread(function()
    while true do
        local mt_begin = GetGameTimer()

        for player, data in each(NearPlayers) do
            local area = data["InArea"]
            local place = data["InPlace"]
            local Event = false
            local player_jobs = data.jobs
            local done = false
            local Handler = false

            if area or place then
                if Events[area] ~= nil then
                    Event = Events[area]
                elseif Events[place] ~= nil then
                    Event = Events[place]
                end
                if Event.handler == "table_key" then
                    Handler = place or area
                else
                    Handler = GetHandler(Event)
                end
            end

            if not data['OnPoint'] then
                if Event then
                    local job_need = Event.job or false
                    if job_need then
                        if type(job_need) == "table" then
                            for _, job in each(job_need) do
                                if player_jobs[job.name] ~= nil then
                                    if player_jobs[job.name].duty then
                                        if player_jobs[job.name].grade >= job.grade then
                                            done = true
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    else
                        done = true
                    end
                    if done then
                        NearPlayers[player]["OnPoint"] = true
                        TriggerClientEvent(string.format("%s",Event.event), player, Handler, "in")
                    end
                end
            else
                if NearPlayers[player]["LeftPoint"] then
                    TriggerClientEvent(string.format("%s",Event.event), player, Handler, "out")
                    NearPlayers[player]["InArea"] = false
                    NearPlayers[player]["InPlace"] = false
                    NearPlayers[player]["OnPoint"] = false
                    NearPlayers[player]["LeftPoint"] = false
                end
            end
        end

        if(threadTimeWarnings) then
            local mt_loopTime = GetGameTimer() - mt_begin
            if(mt_loopTime > ThreadTimeThreshold) then
                print(string.format("[^%s^7] third thread loopTime: ^1%i ms ^7(your server is ^1lagging ^7or ^1mainThreadTimeThreshold ^7is too low)", GetCurrentResourceName(), mt_loopTime))
            end
        end
        Citizen.Wait(thirdUpdateInterval)
    end
end)

function GetHandler(Event)
    local Handler = false
    if type(Event.coords) == "table" then
        for k, v in each(Event.coords) do
            if tostring(k) == Event.handler then
                Handler = v
                break
            else
                if type(v) == "table" then
                    for picus, jeden in each(v) do
                        if tostring(picus) == Event.handler then
                            Handler = v
                            break
                        end
                    end
                end
            end
        end
    else
        Handler = Event.coords
    end

    return Handler
end