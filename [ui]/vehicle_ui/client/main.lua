local isSpawned, isDead, isOpened = false, false, false

local lastLimitedVeh = nil
local CurrentMaxSpeedMetersPerSecond = nil
local SpeedDiffTolerance = (2 / 3.6)
local LastForcedRpm = nil

local isSeatbeltOn, currentCruiserMaxSpeed = false, nil
local lastVeh = nil
local hideHud, hideMinimap = false, false

local multiply = 2.23694

Citizen.CreateThread(function()
    Citizen.Wait(500)
    DisplayRadar(false)
    SetMapZoomDataLevel(0, 0.96, 0.9, 0.08, 0.0, 0.0) -- Level 0
    SetMapZoomDataLevel(1, 1.6, 0.9, 0.08, 0.0, 0.0) -- Level 1
    SetMapZoomDataLevel(2, 8.6, 0.9, 0.08, 0.0, 0.0) -- Level 2
    SetMapZoomDataLevel(3, 12.3, 0.9, 0.08, 0.0, 0.0) -- Level 3
    SetMapZoomDataLevel(4, 24.3, 0.9, 0.08, 0.0, 0.0) -- Level 4
    SetMapZoomDataLevel(5, 55.0, 0.0, 0.1, 2.0, 1.0) -- ZOOM_LEVEL_GOLF_COURSE
    SetMapZoomDataLevel(6, 450.0, 0.0, 0.1, 1.0, 1.0) -- ZOOM_LEVEL_INTERIOR
    SetMapZoomDataLevel(7, 4.5, 0.0, 0.0, 0.0, 0.0) -- ZOOM_LEVEL_GALLERY
    SetMapZoomDataLevel(8, 11.0, 0.0, 0.0, 2.0, 3.0) -- ZOOM_LEVEL_GALLERY_MAXIMIZE

    SetPedConfigFlag(PlayerPedId(), 32, true)
    SetFlyThroughWindscreenParams(Config.Seatbelts.Without, 1.0, 1.0, 1.0)
    local status = exports.data:getUserVar("status")
    if status == "spawned" or status == "dead" then
        isSpawned = true
        isDead = (status == "dead")
        hideHud = exports.settings:getSettingValue("hidehud")
        hideMinimap = exports.settings:getSettingValue("hidemap")
        if IsPedInAnyVehicle(PlayerPedId()) then
            createCycle()
        end
    end
end)

AddEventHandler("gameEventTriggered", function(name, args)
    if name == "CEventNetworkPlayerEnteredVehicle" then
        if args[1] ~= PlayerId() then
            return
        end
        createCycle()
    end
end)

AddEventHandler("settings:changed", function(setting, value)
    if setting == "hidemap" then
        hideMinimap = value
        if isOpened then
            DisplayRadar(not hideMinimap)
        end
    elseif setting == "hidehud" then
        hideHud = value
        if isOpened then
            SendNUIMessage({
                action = (hideHud and "hide" or "show")
            })
        end
    elseif setting == "uiAzimutTop" then
        if isOpened then
            SendNUIMessage({
                action = "refresh",
                azimutTop = value
            })
        end
    end
end)

RegisterNetEvent("s:statusUpdated")
AddEventHandler("s:statusUpdated", function(status)
    if status == "choosing" then
        isSpawned = false
    elseif status == "spawned" or status == "dead" then
        isSpawned = true
        isDead = (status == "dead")
        if isDead then
            if isOpened then
                isOpened = false
                isSeatbeltOn = false

                SendNUIMessage({
                    action = "hide"
                })
            end
        end
    end
end)

function getStreetName(playerPed)
    local playerCoords = (type(playerPed) == "number" and GetEntityCoords(playerPed) or playerPed)
    local x, y, z = table.unpack(playerCoords)
    local currentStreetHash, intersectStreetHash = GetStreetNameAtCoord(x, y, z, currentStreetHash, intersectStreetHash)
    local currentStreetName = GetStreetNameFromHashKey(currentStreetHash)
    local intersectStreetName = GetStreetNameFromHashKey(intersectStreetHash)
    local zone = tostring(GetNameOfZone(x, y, z))
    local streetsLocation = Config.ZoneNames[tostring(zone)]

    if not zone then
        zone = "Neznámá"
        Config.ZoneNames["Neznámá"] = zone
    elseif not Config.ZoneNames[tostring(zone)] then
        Config.ZoneNames[tostring(zone)] = "Neznámá zóna"
    end

    if intersectStreetName and intersectStreetName ~= "" then
        streetsLocation =
            currentStreetName .. " | " .. intersectStreetName .. " [" .. Config.ZoneNames[tostring(zone)] .. "]"
    elseif currentStreetName and currentStreetName ~= "" then
        streetsLocation = currentStreetName .. " [" .. Config.ZoneNames[tostring(zone)] .. "]"
    else
        streetsLocation = "[" .. Config.ZoneNames[tostring(zone)] .. "]"
    end

    return streetsLocation
end

function createCycle()
    local playerPed = PlayerPedId()
    local playerVeh = GetVehiclePedIsIn(playerPed)

    if GetVehicleClass(playerVeh) == 13 then
        return
    end

    local hasOpenedPauseMenu, vehFuel, vehSpeed = false, 0.0, 0.0
    lastVeh, isOpened = playerVeh, true

    SendNUIMessage({
        action = "refresh",
        azimutTop = exports.settings:getSettingValue("uiAzimutTop")
    })
    DisplayRadar(not hideMinimap)

    Citizen.CreateThread(function()
        while playerVeh ~= 0 do
            Citizen.Wait(0)
            playerVeh = GetVehiclePedIsIn(playerPed)
            vehSpeed = GetEntitySpeed(playerVeh)
            if lastLimitedVeh then

                if playerVeh ~= lastLimitedVeh then
                    ResetVehicleMaxSpeed(lastLimitedVeh)
                    lastLimitedVeh = nil
                else
                    local rpm = GetVehicleCurrentRpm(playerVeh)

                    local diff = CurrentMaxSpeedMetersPerSecond - vehSpeed

                    if diff < SpeedDiffTolerance then
                        -- lower RPM while speed is max
                        local newRpm = nil
                        if LastForcedRpm then
                            newRpm = LastForcedRpm - 0.03
                            LastForcedRpm = newRpm
                        else
                            newRpm = rpm - 0.03
                            LastForcedRpm = newRpm
                        end

                        if newRpm > 0.35 then
                            SetVehicleCurrentRpm(playerVeh, newRpm)
                        end
                    end
                end
            end

            if isSeatbeltOn then
                DisableControlAction(2, 75) -- F
            end
            SetRadarZoom(1100)
        end
    end)

    Citizen.CreateThread(function()
        local hiddenHud = true
        while playerVeh ~= 0 do
            vehFuel = math.floor((exports.gas_stations:GetFuel(playerVeh) or 100.0))
            hasOpenedPauseMenu = IsPauseMenuActive()
            if hasOpenedPauseMenu and not hiddenHud then
                hiddenHud = true
                SendNUIMessage({
                    action = "hide"
                })
            elseif hiddenHud and not hideHud then
                hiddenHud = false
                SendNUIMessage({
                    action = "show"
                })
            end
            Citizen.Wait(1500)
        end
        SendNUIMessage({
            action = "hide"
        })
    end)

    local hasSeatbelt = hasVehSeatbelt(playerVeh)
    local vehicleType = getVehicleType(playerVeh)
    local speedType = (vehicleType ~= "plane" and "MPH" or "Knots")
    local width = calculateWidth()
    SendNUIMessage({
        action = "refresh",
        vehicleType = vehicleType,
        hasSeatbelt = hasSeatbelt,
        speedType = speedType,
        minimapWidth = width,
        seatbelt = false,
        limit = false
    })

    Wait(100)

    while playerVeh ~= 0 do
        local calculatedSpeed = math.ceil(vehSpeed * multiply)
        if vehicleType == "plane" then
            local mult = 10 ^ 2
            calculatedSpeed = math.floor((calculatedSpeed * 0.8689762) * mult + 0.5) / mult
        end

        SendNUIMessage({
            action = "refresh",
            isDriver = isDriver(playerVeh, playerPed),
            speed = calculatedSpeed,
            gas = vehFuel,
            streetname = getStreetName(playerPed),
            direction = math.floor(calcHeading(-GetEntityHeading(playerPed) % 360))
        })
        Citizen.Wait(Config.refreshTime)
    end
    endCycle()
end

function endCycle()

    SetFlyThroughWindscreenParams(Config.Seatbelts.Without, 1.0, 1.0, 1.0)
    DisplayRadar(false)
    isOpened = false
    isSeatbeltOn = false
    TriggerEvent("vehicle:seatBeltStatus", isSeatbeltOn)
    currentCruiserMaxSpeed = nil
    if DoesEntityExist(lastVeh) then
        SetEntityMaxSpeed(lastVeh, GetVehicleHandlingFloat(lastVeh, "CHandlingData", "fInitialDriveMaxFlatVel"))
    end
    SendNUIMessage({
        action = "hide"
    })
    Citizen.Wait(500)
end

function calculateWidth()
    local aspect_ratio = GetAspectRatio(0)
    local res_x, res_y = GetActiveScreenResolution()
    local xscale = 1.0 / res_x
    return xscale * (res_x / (2.8 * aspect_ratio))
end

function calcHeading(direction)
    local imageWidth = 100
    local containerWidth = 100

    local width = 0
    local south = (-imageWidth) + width
    local west = (-imageWidth * 2) + width
    local north = (-imageWidth * 3) + width
    local east = (-imageWidth * 4) + width
    local south2 = (-imageWidth * 5) + width

    local function rangePercent(min, max, amt)
        return (((amt - min) * 100) / (max - min)) / 100
    end
    local function lerp(min, max, amt)
        return (1 - amt) * min + amt * max
    end

    if (direction < 90) then
        return lerp(north, east, direction / 90)
    elseif (direction < 180) then
        return lerp(east, south2, rangePercent(90, 180, direction))
    elseif (direction < 270) then
        return lerp(south, west, rangePercent(180, 270, direction))
    elseif (direction <= 360) then
        return lerp(west, north, rangePercent(270, 360, direction))
    end
end

function LimitVehicleSpeed(mpsSpeed)
    local veh = GetVehiclePedIsIn(PlayerPedId())

    lastLimitedVeh = veh
    CurrentMaxSpeedMetersPerSecond = mpsSpeed

    SlowDownToLimitSpeed(veh, mpsSpeed)

    SetVehicleMaxSpeed(veh, mpsSpeed)
end

function SlowDownToLimitSpeed(veh, wantedSpeed)
    local timeout = 4.0 -- limits the slowing down to 4 seconds at most

    while timeout > 0.0 do
        Wait(0)

        timeout = timeout - GetFrameTime()

        local speed = GetEntitySpeed(veh)
        if wantedSpeed > speed then
            return
        else
            SetControlNormal(0, 72, 1.0)
            SetControlNormal(0, 71, 0.0)
        end
    end
end

function ResetCurrentVehicleMaxSpeed()
    if lastLimitedVeh then
        ResetVehicleMaxSpeed(lastLimitedVeh)
    else
        ResetVehicleMaxSpeed(GetVehiclePedIsIn(PlayerPedId()))
    end
end

function ResetVehicleMaxSpeed(veh)
    local maxSpeed = GetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveMaxFlatVel")
    SetVehicleMaxSpeed(veh, maxSpeed)
    lastLimitedVeh = nil
    CurrentMaxSpeedMetersPerSecond = nil
    LastForcedRpm = nil
end

RegisterCommand("togglebigmap", function()
    if isOpened then
        local expanded = IsBigmapActive()
        SetBigmapActive(not expanded, false)
        SetRadarZoom(not expanded and 5 or 1100)
        SendNUIMessage({
            action = "refresh",
            isBigMapActive = not expanded
        })
    end
end)

RegisterCommand("belt", function()
    if isOpened then
        local playerPed = PlayerPedId()
        local playerVeh = GetVehiclePedIsIn(playerPed)
        if hasVehSeatbelt(playerVeh) then
            isSeatbeltOn = not isSeatbeltOn
            TriggerEvent("vehicle:seatBeltStatus", isSeatbeltOn)

            SetFlyThroughWindscreenParams(Config.Seatbelts[(isSeatbeltOn and "With" or "Without")], 1.0, 1.0, 1.0)
            exports.notify:display({
                type = (isSeatbeltOn and "success" or "info"),
                title = "Pásy",
                text = (isSeatbeltOn and "Zapnul/a" or "Odepnul/a") .. " sis pásy.",
                icon = "fas fa-user-slash",
                length = 3500
            })
            SendNUIMessage({
                action = "refresh",
                seatbelt = isSeatbeltOn
            })
        end
    end
end)

RegisterCommand("omezovac", function(_, args)
    local limit = nil
    if args and args[1] and tonumber(args[1]) then
        limit = tonumber(args[1])
    end
    setCruiser(limit)
end)

RegisterCommand("cruiser", function(_, args)
    local limit = nil
    if args and args[1] and tonumber(args[1]) then
        limit = tonumber(args[1])
    end
    setCruiser(limit)
end)

function setCruiser(limit)
    local playerPed = PlayerPedId()
    local playerVeh = GetVehiclePedIsIn(playerPed)
    if isDriver(playerVeh, playerPed) and getVehicleType(playerVeh) == "car" then
        if not currentCruiserMaxSpeed then
            if not limit then
                local currentSpeed = GetEntitySpeed(playerVeh)
                if currentSpeed >= 1 then
                    currentCruiserMaxSpeed = GetEntitySpeed(playerVeh)
                    LimitVehicleSpeed(currentCruiserMaxSpeed)
                else
                    exports.notify:display({
                        type = "error",
                        title = "Omezovač",
                        text = "Pro nastavení omezovače musíš být v pohybu!",
                        icon = "fas fa-tachometer-alt",
                        length = 3500
                    })
                end
            else
                currentCruiserMaxSpeed = limit / multiply
                LimitVehicleSpeed(currentCruiserMaxSpeed)
            end
            if currentCruiserMaxSpeed then
                SendNUIMessage({
                    action = "refresh",
                    limit = true
                })
                local newSpeed = math.ceil(currentCruiserMaxSpeed * multiply)
                exports.notify:display({
                    type = "success",
                    title = "Omezovač",
                    text = "Omezovač rychlosti nastaven na " .. newSpeed .. " MPH!",
                    icon = "fas fa-tachometer-alt",
                    length = 3500
                })
                createCruiserCycle()
            end
        else
            currentCruiserMaxSpeed = nil
            ResetCurrentVehicleMaxSpeed()
            SendNUIMessage({
                action = "refresh",
                limit = false
            })
            exports.notify:display({
                type = "info",
                title = "Omezovač",
                text = "Omezovač rychlosti vypnut!",
                icon = "fas fa-tachometer-alt",
                length = 3500
            })
        end
    end
end

function createCruiserCycle()

    while currentCruiserMaxSpeed do
        Citizen.Wait(0)
        if IsControlJustReleased(0, 96) then
            -- +
            currentCruiserMaxSpeed = (currentCruiserMaxSpeed * multiply + 1) / multiply
            LimitVehicleSpeed(currentCruiserMaxSpeed)
        elseif IsControlJustReleased(0, 97) then
            -- -
            local newSpeed = (currentCruiserMaxSpeed * multiply - 1) / multiply

            if newSpeed >= 1 then
                currentCruiserMaxSpeed = newSpeed
                SendNUIMessage({
                    action = "refresh",
                    limit = true
                })
                LimitVehicleSpeed(currentCruiserMaxSpeed)
            else
                exports.notify:display({
                    type = "error",
                    title = "Omezovač",
                    text = "Omezovač nemůže být tak nízko!",
                    icon = "fas fa-tachometer-alt",
                    length = 3500
                })
            end
        end
    end
end

createNewKeyMapping({
    command = "togglebigmap",
    text = "Velká mapa ve vozidle",
    key = "LSHIFT"
})
createNewKeyMapping({
    command = "belt",
    text = "Pásy ve vozidle",
    key = "B"
})
createNewKeyMapping({
    command = "cruiser",
    text = "Omezovač ve vozidle",
    key = "Y"
})

function hasVehSeatbelt(playerVeh)
    local vehModel = GetEntityModel(playerVeh)
    local vehClass = GetVehicleClass(playerVeh)
    if not Config.DisableSeatBelts[vehModel] and vehClass ~= 8 then
        return true
    end
    return false
end

function getVehicleType(playerVeh)
    local vehClass = GetVehicleClass(playerVeh)
    if vehClass == 15 or vehClass == 16 then
        return "plane"
    elseif vehClass == 14 then
        return "boat"
    elseif vehClass == 13 then
        return "bike"
    end
    return "car"
end

function isDriver(playerVeh, playerPed)
    return (GetPedInVehicleSeat(playerVeh, -1) == playerPed)
end
