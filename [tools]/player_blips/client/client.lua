local playerBlipHandles, playerABlipHandles, latestBlipsUpdate, latestABlipsUpdate, eliminate, eliminateA, player_data,
    outin, ouAtin, cars, gps = {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
local jobName = nil
local isDuty = nil
local charId = false
local spawned = false
local adminPower, registered = 0, false
local adminToggleTags = false
local sended, sendedE = false, false
local sended2, sendedE2 = false, false
local lastname = nil
local isDead = false
local player_car = nil
local player_stop = false
local player_hide = false
local player_remove = false
local classtype = nil
local class = {
    [0] = "car",
    [1] = "car",
    [2] = "car",
    [3] = "car",
    [4] = "car",
    [5] = "car",
    [6] = "car",
    [7] = "car",
    [8] = "motorcycle",
    [9] = "car",
    [10] = "car",
    [11] = "car",
    [12] = "car",
    [13] = "cycle",
    [14] = "boat",
    [15] = "heli",
    [16] = "plane",
    [17] = "car",
    [18] = "emergency",
    [19] = "car",
    [20] = "car",
    [21] = "car",
    [22] = "foot"
}

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        -- AddTextEntry('TEST_LABEL', '~a~')
        lastname = exports.data:getCharVar("lastname")
        adminPower = exports.data:getUserVar("admin")
        if adminPower > 0 and not registered then
            registered = true
            createNewKeyMapping({
                command = "toggleAdminBlips",
                text = "Zapnutí/Vypnutí Admin blipu",
                key = "F4"
            })
        end
        player_data = {
            classtype = classtype,
            adminPower = adminPower,
            isDead = isDead,
            GPS = gps,
            lastname = lastname
        }
        spawned = true
        jobs = exports.data:getCharVar("jobs")
        for index, v in each(exports.data:getCharVar("jobs")) do
            if v["duty"] then
                if Config.Emergency[v["job"]] then
                    jobName = v["job"]
                    TriggerServerEvent("player_blips:onblips", GetPlayerServerId(PlayerId()), jobName, player_data,
                        player_hide, player_stop, player_remove)
                    break
                end
            end
        end
    end
end)

RegisterNetEvent("s:statusUpdated")
AddEventHandler("s:statusUpdated", function(status)
    isDead = (status == "dead")
    if status == "spawned" then
        spawned = true
        adminPower = exports.data:getUserVar("admin")
        charId = exports.data:getCharVar("id")
        lastname = exports.data:getCharVar("lastname")
        if adminPower > 0 and not registered then
            registered = true
            createNewKeyMapping({
                command = "toggleAdminBlips",
                text = "Zapnutí/Vypnutí Admin blipu",
                key = "F4"
            })
        end
        for index, v in each(exports.data:getCharVar("jobs")) do
            if v["duty"] then
                if Config.Emergency[v["job"]] then
                    jobName = v["job"]
                    player_remove = false
                    TriggerServerEvent("player_blips:onblips", GetPlayerServerId(PlayerId()), jobName, player_data,
                        player_hide, player_stop, player_remove)
                    break
                end
            elseif jobName ~= nil and v["job"] == jobName then
                jobName = nil
                player_remove = true
                TriggerServerEvent("player_blips:onblips", GetPlayerServerId(PlayerId()), jobName, player_data,
                    player_hide, player_stop, player_remove)
            end
        end
    end
    if status == "choosing" then
        spawned = false
        jobName = nil
        player_remove = true
        TriggerServerEvent("player_blips:onblips", GetPlayerServerId(PlayerId()), jobName, player_data, player_hide,
            player_stop, player_remove)
    end
end)

RegisterNetEvent("s:jobUpdated")
AddEventHandler("s:jobUpdated", function(job, grade, duty)
    for index, v in each(job) do
        if v["duty"] then
            if Config.Emergency[v["job"]] then
                jobName = v["job"]
                player_remove = false
                TriggerServerEvent("player_blips:onblips", GetPlayerServerId(PlayerId()), jobName, player_data,
                    player_hide, player_stop, player_remove)
                break
            end
        elseif jobName ~= nil and v["job"] == jobName then
            jobName = nil
            player_remove = true
            TriggerServerEvent("player_blips:onblips", GetPlayerServerId(PlayerId()), jobName, player_data, player_hide,
                player_stop, player_remove)
        end
    end
end)

RegisterNetEvent("player_blips:elimnate")
AddEventHandler("player_blips:elimnate", function(player, admin)
    if admin then
        if adminPower > 2 then
            if latestABlipsUpdate[player] then
                eliminateA[player] = true
            end
        end
    else
        if playerBlipHandles[player] then
            if DoesBlipExist(playerBlipHandles[player]) then
                RemoveBlip(playerBlipHandles[player])
                playerBlipHandles[player] = nil
                latestBlipsUpdate[player] = nil
            end
        end
    end
end)

RegisterNetEvent("player_blips:offblips")
AddEventHandler("player_blips:offblips", function(admin)
    if admin then
        for index, blip in each(playerABlipHandles) do
            RemoveBlip(playerABlipHandles[index])
            playerABlipHandles[index] = nil
        end
        for index, blip in each(latestABlipsUpdate) do
            latestABlipsUpdate[index] = nil
        end
    else
        for index, blip in each(playerBlipHandles) do
            RemoveBlip(playerBlipHandles[index])
            playerBlipHandles[index] = nil
        end
        for index, blip in each(latestBlipsUpdate) do
            latestBlipsUpdate[index] = nil
        end
    end
end)

RegisterNetEvent("player_blips:updateBlips")
AddEventHandler("player_blips:updateBlips", function(blips)
    latestBlipsUpdate = blips
    cars = {}

    for k, v in each(latestBlipsUpdate) do
        if v[9] then
            cars[v[2]] = true
        end
    end

    for k, v in each(latestBlipsUpdate) do
        for index, data in each(cars) do
            if not v[9] and v[10] ~= "undefined" then
                if v[10] == index then
                    v[11] = true
                end
            end
        end
    end

    for index, dat in each(latestBlipsUpdate) do
        if not dat[11] then
            if not NetworkDoesEntityExistWithNetworkId(dat[2]) then
                dat[20] = false
                if outin[dat[1]] == nil then
                    outin[dat[1]] = dat[1]
                end
            else
                if NetworkDoesEntityExistWithNetworkId(dat[2]) then
                    dat[20] = true
                else
                    dat[20] = false
                    if outin[dat[1]] == nil then
                        outin[dat[1]] = dat[1]
                    end
                end
            end
        else
            if DoesBlipExist(playerBlipHandles[dat[1]]) then
                RemoveBlip(playerBlipHandles[dat[1]])
                playerBlipHandles[dat[1]] = nil
                latestBlipsUpdate[dat[1]] = nil
            end
        end
    end

    for _, data in each(latestBlipsUpdate) do
        local player, jobplayer, jobother, playerName, coords = data[1], jobName, data[3], data[4], data[5]
        local dead, heading, vehType, isCar, car, hide, stop, remove = data[6], data[7], class[data[8]], data[9],
            data[10], data[11], data[12], data[13]
        local cansee = nil
        local can = false
        local canGPS = false
        local height = math.ceil(coords[3] * 3.28084) or false

        if Config.Zones[jobplayer] ~= nil then
            cansee = Config.Zones[jobplayer].Blips
            if cansee ~= nil then
                for i = 1, #cansee, 1 do
                    if jobother == cansee[i] then
                        can = true
                    end
                end
            end
        else
            if jobplayer == "ffa" then
                if vehType == 15 or vehType == 16 then
                    can = true
                    if jobother == nil then
                        jobother = "noJob"
                    end

                    if jobplayer == nil then
                        jobplayer = "noJob"
                    end
                end
            end
        end

        -- print(NetworkGetNetworkIdFromEntity(player_car))
        -- print(car)

        local blip = 0
        if not hide then
            if not stop and can then
                if (playerBlipHandles[player] == nil and not DoesBlipExist(playerBlipHandles[player])) then
                    if data[20] then
                        blip = AddBlipForEntity(NetworkGetEntityFromNetworkId(data[2]))
                    else
                        blip = AddBlipForCoord(coords[1], coords[2], coords[3])
                    end
                else
                    blip = playerBlipHandles[player]
                    if data[20] then
                        if DoesBlipExist(playerBlipHandles[player]) then
                            for _, v in each(outin) do
                                if v == player then
                                    RemoveBlip(playerBlipHandles[player])
                                    blip = nil
                                    outin[player] = nil
                                end
                            end
                        end
                    else
                        if DoesBlipExist(playerBlipHandles[player]) then
                            SetBlipCoords(blip, coords[1], coords[2], coords[3])
                        else
                            blip = AddBlipForCoord(coords[1], coords[2], coords[3])
                        end
                    end
                end
                SetBlipRotation(blip, math.ceil(heading)) -- update rotation
            else
                if DoesBlipExist(playerBlipHandles[player]) then
                    RemoveBlip(playerBlipHandles[player])
                    blip = nil
                end
                if stop then
                    blip = AddBlipForCoord(coords[1], coords[2], coords[3])
                end
            end

            SetBlipAsShortRange(blip, 1)
            SetBlipAlpha(blip, 500)
            ShowHeightOnBlip(blip, true)

            if vehType == "plane" or vehType == "heli" then
                if height then
                    heightOnBlip = math.ceil(height / 100)
                    if heightOnBlip >= 99 then
                        heightOnBlip = 99
                    end
                    if heightOnBlip <= 1 then
                        heightOnBlip = 1
                    end
                    ShowNumberOnBlip(blip, heightOnBlip)
                end
            end

            if vehType == "emergency" or vehType == "foot" then
                SetBlipSprite(blip, Config.Markers[vehType][jobother])
            else
                SetBlipSprite(blip, Config.Markers[vehType])
            end

            SetBlipScale(blip, 1.0)
            SetBlipShrink(blip, 1)

            if isCar then
                SetBlipCategory(blip, 11)
            else
                SetBlipCategory(blip, 7)
            end

            SetBlipDisplay(blip, 6)

            if dead then
                -- SetBlipFlashTimer(blip,1500)
            end

            SetBlipColour(blip, Config.BlipColors[jobother])

            -- SetBlipBright(blip, true)

            playerBlipHandles[player] = blip
            BeginTextCommandSetBlipName("STRING")
            -- if jobplayer == 'ffa' and adminPower <= 2 and IsBigmapActive() then
            if height and IsBigmapActive() then
                if height then
                    AddTextComponentString(playerName .. " | " .. height .. " ft")
                    EndTextCommandSetBlipName(blip)
                end
            else
                AddTextComponentString(playerName)
                EndTextCommandSetBlipName(blip)
            end
            -- if jobplayer == 'ffa' and adminPower <= 2 then
            if height then
                DisplayPlayerNameTagsOnBlips(IsBigmapActive())
            end
        end
    end
end)

RegisterNetEvent("player_blips:updateABlips")
AddEventHandler("player_blips:updateABlips", function(blipsA)
    latestABlipsUpdate = blipsA
    for index, dat in each(latestABlipsUpdate) do
        if not eliminateA[dat[1]] then
            if not NetworkDoesEntityExistWithNetworkId(dat[2]) then
                dat[20] = false
                if ouAtin[dat[1]] == nil then
                    ouAtin[dat[1]] = dat[1]
                end
            else
                if NetworkDoesEntityExistWithNetworkId(dat[2]) then
                    dat[20] = true
                else
                    dat[20] = false
                    if ouAtin[dat[1]] == nil then
                        ouAtin[dat[1]] = dat[1]
                    end
                end
            end
        else
            if latestABlipsUpdate[dat[1]] then
                RemoveBlip(playerABlipHandles[dat[1]])
                playerABlipHandles[dat[1]] = nil
                latestABlipsUpdate[dat[1]] = nil
                eliminateA[dat[1]] = nil
            end
        end
    end

    for _, data in each(latestABlipsUpdate) do
        if data[1] ~= GetPlayerServerId(PlayerId()) then
            local player, net, name, coords, status, heading, admin, dead, car, job = data[1], data[2], data[3],
                data[4], data[5], data[6], data[7], data[8], data[9], data[10]
            status = class[status]
            local blip = 0

            if job == nil then
                job = "noJob"
            end

            -- print(NetworkGetNetworkIdFromEntity(player_car))
            -- print(car)

            if (playerABlipHandles[player] == nil and not DoesBlipExist(playerABlipHandles[player])) then
                if data[20] then
                    blip = AddBlipForEntity(NetworkGetEntityFromNetworkId(net))
                else
                    blip = AddBlipForCoord(coords[1], coords[2], coords[3])
                end
            else
                blip = playerABlipHandles[player]
                if data[20] then
                    if DoesBlipExist(playerABlipHandles[player]) then
                        for _, v in each(ouAtin) do
                            if v == player then
                                RemoveBlip(playerABlipHandles[player])
                                blip = nil
                                ouAtin[player] = nil
                            end
                        end
                    end
                else
                    if DoesBlipExist(playerABlipHandles[player]) then
                        SetBlipCoords(blip, coords[1], coords[2], coords[3])
                    else
                        blip = AddBlipForCoord(coords[1], coords[2], coords[3])
                    end
                end
            end

            if status == "foot" then
                ShowHeadingIndicatorOnBlip(blip, true)
            else
                ShowHeadingIndicatorOnBlip(blip, false)
            end

            SetBlipRotation(blip, math.ceil(heading)) -- update rotation
            SetBlipAsShortRange(blip, 1)
            SetBlipAlpha(blip, 500)
            ShowHeightOnBlip(blip, true)

            if status == "emergency" or status == "foot" then
                SetBlipSprite(blip, Config.Markers[status][job])
            else
                SetBlipSprite(blip, Config.Markers[status])
            end

            SetBlipScale(blip, 1.0)
            SetBlipShrink(blip, 1)
            SetBlipCategory(blip, 7)
            SetBlipDisplay(blip, 6)

            if dead then
                -- SetBlipFlashes(blip, 1)
                -- SetBlipFlashTimer(blip, 7000)
                -- SetBlipFlashInterval(blip, 50)
            end

            if admin ~= nil and admin > 2 then
                SetBlipColour(blip, 85)
            else
                SetBlipColour(blip, Config.BlipColors[job])
            end
            -- PulseBlip(blip) -- idk
            -- SetBlipHighDetail(blip, 1)
            -- SetBlipShowCone(blip, 1) -- radar ve předu only veh
            -- SetBlipBright(blip, true)
            if vehType == "plane" or vehType == "heli" then
                height = math.ceil(coords[3] / 10)
                if height >= 99 then
                    height = 99
                end
                if height <= 1 then
                    height = 1
                end
                if height then
                    ShowNumberOnBlip(blip, height)
                end
            end
            playerABlipHandles[player] = blip
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(name)
            EndTextCommandSetBlipName(blip)
            -- BeginTextCommandDisplayText('TEST_LABEL')
            -- EndTextCommandDisplayText(0.5, 0.5)
            -- AddTextComponentSubstringPlayerName('Hello, World!')
            -- SetBlipNameToPlayerName(blip, name)
            -- DisplayPlayerNameTagsOnBlips(true)
            -- DontTiltMinimapThisFrame()
        end
    end
end)

function hideBlip(id)
    if id == GetPlayerServerId(PlayerId()) then
        if not player_hide then
            player_hide = true
        else
            player_hide = false
        end
    end
end

function stopBlip(id)
    if id == GetPlayerServerId(PlayerId()) then
        if not player_stop then
            player_stop = true
        else
            player_stop = false
        end
    end
end

function removeBlip(id)
    if id == GetPlayerServerId(PlayerId()) then
        if not player_remove then
            player_remove = true
        else
            player_remove = false
        end
    end
end

function addGPS(id)
    if id == GetPlayerServerId(PlayerId()) then
        if not player_remove then
            player_remove = true
        else
            player_remove = false
        end
    end
end

RegisterCommand("toggleAdminBlips", function()
    if adminPower >= 2 then
        TriggerServerEvent("player_blips:addAdmin", GetPlayerServerId(PlayerId()))
    end
end)

Citizen.CreateThread(function()
    while true do
        if spawned then
            player_car = GetVehiclePedIsIn(GetPlayerPed(-1), false)
            if GetPedInVehicleSeat(player_car, -1) == GetPlayerPed(-1) then
                local name = string.lower(GetDisplayNameFromVehicleModel(GetEntityModel(player_car)))

                if name and Config.specificVehicleClass[name] then
                    classtype = Config.specificVehicleClass[name]
                else
                    if class[GetVehicleClass(player_car)] then
                        classtype = GetVehicleClass(player_car)
                    end
                end
            else
                classtype = 22
            end

            if classtype == 15 or classtype == 16 then
                jobName = "plane"
            end

            if not Config.Emergency[jobName] then
                if classtype ~= 15 and classtype ~= 16 then
                    jobName = nil
                    player_remove = true
                    TriggerServerEvent("player_blips:onblips", GetPlayerServerId(PlayerId()), jobName, player_data,
                        player_hide, player_stop, player_remove)
                end
            end
        end
        Citizen.Wait(Config.ClientWait)
    end
end)

Citizen.CreateThread(function()
    while true do
        if adminPower >= 2 and spawned then
            if IsControlJustReleased(1, 19) and IsBigmapActive() then
                adminToggleTags = not adminToggleTags
                DisplayPlayerNameTagsOnBlips(adminToggleTags)
            end
        end
        Citizen.Wait(10)
    end
end)

Citizen.CreateThread(function()
    while true do
        if spawned then
            player_data = {
                classtype = classtype,
                adminPower = adminPower,
                isDead = isDead,
                GPS = gps,
                lastname = lastname
            }
            TriggerServerEvent("player_blips:allPlayers", player_data, jobName)
            if jobName ~= nil then
                player_remove = false
                TriggerServerEvent("player_blips:onblips", GetPlayerServerId(PlayerId()), jobName, player_data,
                    player_hide, player_stop, player_remove)
            end
        end
        Citizen.Wait(Config.ClientWait)
    end
end)

RegisterCommand("refresh_blips", function()
    if adminPower >= 2 then
        for index, blip in each(playerABlipHandles) do
            RemoveBlip(playerABlipHandles[index])
            playerABlipHandles[index] = nil
        end
        for index, blip in each(latestABlipsUpdate) do
            latestABlipsUpdate[index] = nil
        end
    end
    for index, blip in each(playerBlipHandles) do
        RemoveBlip(playerBlipHandles[index])
        playerBlipHandles[index] = nil
    end
    for index, blip in each(latestBlipsUpdate) do
        latestBlipsUpdate[index] = nil
    end
    print("Yahooo")
end)

RegisterNetEvent("player_blips:locatorRefresh")
AddEventHandler("player_blips:locatorRefresh", function()
    if adminPower >= 2 then
        for index, blip in each(playerABlipHandles) do
            RemoveBlip(playerABlipHandles[index])
            playerABlipHandles[index] = nil
        end
        for index, blip in each(latestABlipsUpdate) do
            latestABlipsUpdate[index] = nil
        end
    end
    for index, blip in each(playerBlipHandles) do
        RemoveBlip(playerBlipHandles[index])
        playerBlipHandles[index] = nil
    end
    for index, blip in each(latestBlipsUpdate) do
        latestBlipsUpdate[index] = nil
    end
    print("Yahooo")

end)
