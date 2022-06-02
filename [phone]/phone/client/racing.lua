-- Recorded checkpoints
local RACE_STATE_NONE = 0
local RACE_STATE_JOINED = 1
local RACE_STATE_RACING = 2
local RACE_STATE_RECORDING = 3
local RACE_CHECKPOINT_TYPE = 45
local RACE_CHECKPOINT_FINISH_TYPE = 9
local recordedCheckpoints = {}
local races = {}
local raceStatus = {
    state = RACE_STATE_NONE,
    index = 0,
    checkpoint = 0
}

AddEventHandler('qb-phone:client:TrackSetup', function(data)
    data.distance = 0
    local firstWayPoint = 0
    while true do
        local playerPed = PlayerPedId()
        local plyCoords = GetEntityCoords(playerPed)
        -- When recording flag is set, save checkpoints
        if IsControlJustReleased(1, config_cl.saveKeyBind) then
            saveRecording(data)
            break
        elseif IsControlJustReleased(1, config_cl.closeKeyBind) then
            cleanupRecording()
            break
        end
        if raceStatus.state == RACE_STATE_RECORDING then
            -- Create new checkpoint when waypoint is set
            if IsWaypointActive() then
                -- Get closest vehicle node to waypoint coordinates and remove waypoint
                local waypointCoords = GetBlipInfoIdCoord(GetFirstBlipInfoId(8))
                local retval, coords = GetClosestVehicleNode(waypointCoords.x, waypointCoords.y, waypointCoords.z, 1)
                SetWaypointOff()

                -- Check if coordinates match any existing checkpoints
                for index, checkpoint in pairs(recordedCheckpoints) do
                    if GetDistanceBetweenCoords(coords.x, coords.y, coords.z, checkpoint.coords.x, checkpoint.coords.y, checkpoint.coords.z, false) < 1.0 then
                        -- Matches existing checkpoint, remove blip and checkpoint from table
                        RemoveBlip(checkpoint.blip)
                        table.remove(recordedCheckpoints, index)
                        coords = nil

                        -- Update existing checkpoint blips
                        for i = index, #recordedCheckpoints do
                            ShowNumberOnBlip(recordedCheckpoints[i].blip, i)
                        end
                        break
                    end
                end

                -- Add new checkpoint
                if (coords ~= nil) then
                    -- Add numbered checkpoint blip
                    if firstWayPoint == 0 then
                        firstWayPoint = coords
                    end
                    data.distance = data.distance + math.floor(GetDistanceBetweenCoords(firstWayPoint.x, firstWayPoint.y, firstWayPoint.z, coords.x, coords.y,coords.z, false))
                    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
                    SetBlipColour(blip, config_cl.checkpointBlipColor)
                    SetBlipAsShortRange(blip, true)
                    ShowNumberOnBlip(blip, #recordedCheckpoints+1)

                    -- Add checkpoint to array
                    table.insert(recordedCheckpoints, {blip = blip, coords = coords})
                end
            end
        else
            -- Not recording, do cleanup
            cleanupRecording()
        end
        Citizen.Wait(0)
    end
end)

RegisterNetEvent('qb-phone:client:RaceNotify')
AddEventHandler('qb-phone:client:RaceNotify', function(message)
    SendNUIMessage({
        action = "PhoneNotification",
        PhoneNotify = {
            title = "Racing",
            text = message,
            icon = "fas fa-flag-checkered",
            color = "#353b48",
            timeout = 3500,
        },
    })
end)

RegisterNUICallback('GetAvailableRaces', function(data, cb)
    TriggerServerEvent("qb-phone:server:getTracks", PhoneData.PlayerData.charid)
    RegisterNetEvent('qb-phone:client:getTracks')
    AddEventHandler('qb-phone:client:getTracks', function(PlayerTracks)
        cb(PlayerTracks)
    end)
end)

RegisterNUICallback('JoinRace', function(data)
    --[[    TriggerServerEvent('qb-lapraces:server:JoinRace', data.RaceData)]]
end)

RegisterNUICallback('LeaveRace', function(data)
    --[[    TriggerServerEvent('qb-lapraces:server:LeaveRace', data.RaceData)]]
end)

RegisterNUICallback('StartRace', function(data)
    --[[    TriggerServerEvent('qb-lapraces:server:StartRace', data.RaceData.RaceId)]]
end)

RegisterNetEvent('qb-phone:client:UpdateLapraces')
AddEventHandler('qb-phone:client:UpdateLapraces', function()
    --[[    SendNUIMessage({
            action = "UpdateRacingApp",
        })]]
end)

RegisterNUICallback('GetRaces', function(data, cb)
    --QBCore.Functions.TriggerCallback('qb-lapraces:server:GetListedRaces', function(Races)
    --    cb(Races)
    --end)
end)

RegisterNUICallback('GetTrackData', function(data, cb)
    --[[    QBCore.Functions.TriggerCallback('qb-lapraces:server:GetTrackData', function(TrackData, CreatorData)
            TrackData.CreatorData = CreatorData
            cb(TrackData)
        end, data.RaceId)]]
end)

RegisterNUICallback('SetupRace', function(data, cb)
    --[[    TriggerServerEvent('qb-lapraces:server:SetupRace', data.RaceId, tonumber(data.AmountOfLaps))]]
end)

RegisterNUICallback('HasCreatedRace', function(data, cb)
    --[[    QBCore.Functions.TriggerCallback('qb-lapraces:server:HasCreatedRace', function(HasCreated)
            cb(HasCreated)
        end)]]
end)

RegisterNUICallback('IsInRace', function(data, cb)
    local InRace = false
    --local InRace = exports['qb-lapraces']:IsInRace()
    cb(InRace)
end)

RegisterNUICallback('IsAuthorizedToCreateRaces', function(data, cb)
    local dataR = {
        IsAuthorized = true,
        IsBusy = false,
        IsNameAvailable = true,
    }
        --[[    QBCore.Functions.TriggerCallback('qb-lapraces:server:IsAuthorizedToCreateRaces', function(IsAuthorized, NameAvailable)
                local data = {
                    IsAuthorized = IsAuthorized,
                    IsBusy = exports['qb-lapraces']:IsInEditor(),
                    IsNameAvailable = NameAvailable,
                }
                cb(data)
            end, data.TrackName)]]
    cb(dataR)
end)

RegisterNUICallback('StartTrackEditor', function(data, cb)
    SetWaypointOff()
    cleanupRecording()
    SendNUIMessage({
        action = "RacingSetupNotification",
    })
    raceStatus.state = RACE_STATE_RECORDING
    TriggerEvent('qb-phone:client:TrackSetup', data)
    --[[    TriggerServerEvent('qb-lapraces:server:CreateLapRace', data.TrackName)]]
end)

RegisterNUICallback('GetRacingLeaderboards', function(data, cb)
    TriggerServerEvent("qb-phone:server:getRaces", PhoneData.PlayerData.charid)
    RegisterNetEvent('qb-phone:client:getRaces')
    AddEventHandler('qb-phone:client:getRaces', function(PlayerTracks)
        cb(PlayerTracks)
    end)
end)

RegisterNUICallback('RaceDistanceCheck', function(data, cb)
    --[[    QBCore.Functions.TriggerCallback('qb-lapraces:server:GetRacingData', function(RaceData)
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local checkpointcoords = RaceData.Checkpoints[1].coords
            local dist = #(coords - vector3(checkpointcoords.x, checkpointcoords.y, checkpointcoords.z))
            if dist <= 115.0 then
                if data.Joined then
                    TriggerEvent('qb-lapraces:client:WaitingDistanceCheck')
                end
                cb(true)
            else
                exports.notify:display({type = "success", title = "GPS", text = "Seš moc daleko. GPS byla přesměrována na závod.", icon = "fas fa-times", length = 5000})
                SetNewWaypoint(checkpointcoords.x, checkpointcoords.y)
                cb(false)
            end
        end, data.RaceId)]]
end)

RegisterNUICallback('IsBusyCheck', function(data, cb)
    if data.check == "editor" then
        cb(false)
    else
        cb(false)
    end
end)

RegisterNUICallback('CanRaceSetup', function(data, cb)
    --[[QBCore.Functions.TriggerCallback('qb-lapraces:server:CanRaceSetup', function(CanSetup)
            cb(CanSetup)
        end)]]
end)

-- Helper function to clean up recording blips
function cleanupRecording()
    SendNUIMessage({
        action = "DeleteRacingSetupNotification",
    })
    -- Remove map blips and clear recorded checkpoints
    for _, checkpoint in pairs(recordedCheckpoints) do
        RemoveBlip(checkpoint.blip)
        checkpoint.blip = nil
    end
    recordedCheckpoints = {}
end

function saveRecording(data)
    local playerTrack = {
        name = data.TrackName,
        owner = PhoneData.PlayerData.charid,
        distance = data.distance,
        data = recordedCheckpoints,
        winner = {},
        racers = {}
    }
    SendNUIMessage({
        action = "DeleteRacingSetupNotification",
    })
    if #recordedCheckpoints ~= 0 then
        --Utils.DumpTable(playerTrack)
        --TriggerServerEvent("qb-phone:server:createNewTrack", PhoneData.PlayerData.charid, playerTrack)
    end
    SendNUIMessage({
        action = "ReloadRaces",
    })
    cleanupRecording()
end

-- Helper function to clean up race blips, checkpoints and status
function cleanupRace()
    -- Cleanup active race
    if raceStatus.index ~= 0 then
        -- Cleanup map blips and checkpoints
        local race = races[raceStatus.index]
        local checkpoints = race.checkpoints
        for _, checkpoint in pairs(checkpoints) do
            if checkpoint.blip then
                RemoveBlip(checkpoint.blip)
            end
            if checkpoint.checkpoint then
                DeleteCheckpoint(checkpoint.checkpoint)
            end
        end

        -- Set new waypoint to finish if racing
        if raceStatus.state == RACE_STATE_RACING then
            local lastCheckpoint = checkpoints[#checkpoints]
            SetNewWaypoint(lastCheckpoint.coords.x, lastCheckpoint.coords.y)
        end

        -- Unfreeze vehicle
        local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
        FreezeEntityPosition(vehicle, false)
    end
end