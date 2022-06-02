local isSpawned, isDead = false, false

Citizen.CreateThread(
    function()
        pCoords = GetEntityCoords(PlayerPedId(), false)
        Citizen.Wait(500)
        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            isSpawned = true
        end
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned = false
        elseif status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
        end
    end
)

RegisterNetEvent("v:setVehicleProperties")
AddEventHandler(
    "v:setVehicleProperties",
    function(netId, props)
        while not netId or not NetworkDoesEntityExistWithNetworkId(netId) do
            Citizen.Wait(100)
        end

        local veh = NetToVeh(netId)
        SetVehicleOnGroundProperly(veh)
        WashDecalsFromVehicle(veh, 1.0)
        SetVehicleNeedsToBeHotwired(veh, false)
        SetVehRadioStation(veh, "OFF")
        SetVehicleProperties(veh, props.data)
    end
)

function spawnVehicle(model, vehicle, x, y, z, heading, lock)
    local model = GetHashKey(model)
    if not HasModelLoaded(model) and IsModelInCdimage(model) then
        RequestModel(model)

        while not HasModelLoaded(model) do
            Citizen.Wait(1)
        end
    end

    local veh = CreateVehicle(model, x, y, z, heading, true, true)
    SetModelAsNoLongerNeeded(model)

    while not NetworkGetEntityIsNetworked(veh) do
        NetworkRegisterEntityAsNetworked(veh)
        Citizen.Wait(5)
    end

    local networkId = NetworkGetNetworkIdFromEntity(veh)
    local plate = vehicle.spz

    if vehicle.data.actualPlate then
        plate = vehicle.data.actualPlate
        exports.data:setVehicleActualPlateText(networkId, vehicle.data.actualPlate)
    end

    WashDecalsFromVehicle(veh, 1.0)
    SetNetworkIdCanMigrate(networkId, true)
    SetVehicleNeedsToBeHotwired(veh, false)
    SetVehRadioStation(veh, "OFF")
    SetModelAsNoLongerNeeded(model)

    local timeout = 0
    RequestCollisionAtCoord(x, y, z)

    while not HasCollisionLoadedAroundEntity(veh) and timeout < 2000 do
        Citizen.Wait(0)
        timeout = timeout + 1
    end

    SetVehicleProperties(veh, vehicle.data)
    TriggerServerEvent("vehiclelock:setVehicleLockStatus", networkId, lock)
    return veh
end

function SetVehicleProperties(veh, props)
    SetVehicleModKit(veh, 0)

    if props.plate ~= nil then
        SetVehicleNumberPlateText(veh, props.plate)
    elseif props.actualPlate ~= nil then
        SetVehicleNumberPlateText(veh, props.actualPlate)
    end

    if props.plateIndex ~= nil then
        SetVehicleNumberPlateTextIndex(veh, props.plateIndex)
    end

    if props.bodyHealth ~= nil then
        SetVehicleBodyHealth(veh, props.bodyHealth + 0.0)
    end

    if props.engineHealth ~= nil then
        SetVehicleEngineHealth(veh, props.engineHealth + 0.0)
    end

    if props.fuelLevel ~= nil then
        exports.gas_stations:SetFuel(veh, props.fuelLevel + 0.0)
    else
        exports.gas_stations:SetFuel(veh, 100.0)
    end

    if props.dirtLevel ~= nil then
        SetVehicleDirtLevel(veh, props.dirtLevel + 0.0)
    end

    if props.color1 ~= nil then
        local color1, color2 = GetVehicleColours(veh)
        SetVehicleColours(veh, props.color1, color2)
    end

    if props.color2 ~= nil then
        local color1, color2 = GetVehicleColours(veh)
        SetVehicleColours(veh, color1, props.color2)
    end

    if props.pearlescentColor ~= nil then
        local pearlescentColor, wheelColor = GetVehicleExtraColours(veh)
        SetVehicleExtraColours(veh, props.pearlescentColor, wheelColor)
    end

    if props.wheelColor ~= nil then
        local pearlescentColor, wheelColor = GetVehicleExtraColours(veh)
        SetVehicleExtraColours(veh, pearlescentColor, props.wheelColor)
    end

    if props.wheels ~= nil then
        SetVehicleWheelType(veh, props.wheels)
    end

    if props.windowTint ~= nil then
        SetVehicleWindowTint(veh, props.windowTint)
    end

    if props.neonEnabled ~= nil then
        SetVehicleNeonLightEnabled(veh, 0, props.neonEnabled[1])
        SetVehicleNeonLightEnabled(veh, 1, props.neonEnabled[2])
        SetVehicleNeonLightEnabled(veh, 2, props.neonEnabled[3])
        SetVehicleNeonLightEnabled(veh, 3, props.neonEnabled[4])
    end

    if props.extras ~= nil then
        for id, enabled in pairs(props.extras) do
            if enabled then
                SetVehicleExtra(veh, tonumber(id), 0)
            else
                SetVehicleExtra(veh, tonumber(id), 1)
            end
        end
    end

    if props.dashboardColor ~= nil then
        SetVehicleDashboardColour(veh, props.dashboardColor)
    end

    if props.interiorColor ~= nil then
        SetVehicleInteriorColour(veh, props.interiorColor)
    end

    if props.neonColor ~= nil then
        SetVehicleNeonLightsColour(veh, props.neonColor[1], props.neonColor[2], props.neonColor[3])
    end

    if props.modSmokeEnabled ~= nil then
        ToggleVehicleMod(veh, 20, true)
    end

    if props.tyreSmokeColor ~= nil then
        SetVehicleTyreSmokeColor(veh, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3])
    end

    if props.modSpoilers ~= nil then
        SetVehicleMod(veh, 0, props.modSpoilers, false)
    end

    if props.modFrontBumper ~= nil then
        SetVehicleMod(veh, 1, props.modFrontBumper, false)
    end

    if props.modRearBumper ~= nil then
        SetVehicleMod(veh, 2, props.modRearBumper, false)
    end

    if props.modSideSkirt ~= nil then
        SetVehicleMod(veh, 3, props.modSideSkirt, false)
    end

    if props.modExhaust ~= nil then
        SetVehicleMod(veh, 4, props.modExhaust, false)
    end

    if props.modFrame ~= nil then
        SetVehicleMod(veh, 5, props.modFrame, false)
    end

    if props.modGrille ~= nil then
        SetVehicleMod(veh, 6, props.modGrille, false)
    end

    if props.modHood ~= nil then
        SetVehicleMod(veh, 7, props.modHood, false)
    end

    if props.modFender ~= nil then
        SetVehicleMod(veh, 8, props.modFender, false)
    end

    if props.modRightFender ~= nil then
        SetVehicleMod(veh, 9, props.modRightFender, false)
    end

    if props.modRoof ~= nil then
        SetVehicleMod(veh, 10, props.modRoof, false)
    end

    if props.modEngine ~= nil then
        SetVehicleMod(veh, 11, props.modEngine, false)
    end

    if props.modBrakes ~= nil then
        SetVehicleMod(veh, 12, props.modBrakes, false)
    end

    if props.modTransmission ~= nil then
        SetVehicleMod(veh, 13, props.modTransmission, false)
    end

    if props.modHorns ~= nil then
        SetVehicleMod(veh, 14, props.modHorns, false)
    end

    if props.modSuspension ~= nil then
        SetVehicleMod(veh, 15, props.modSuspension, false)
    end

    if props.modArmor ~= nil then
        SetVehicleMod(veh, 16, props.modArmor, false)
    end

    if props.modTurbo ~= nil then
        ToggleVehicleMod(veh, 18, props.modTurbo)
    end

    if props.modXenon ~= nil then
        ToggleVehicleMod(veh, 22, props.modXenon)
    end

    if props.modFrontWheels ~= nil then
        SetVehicleMod(veh, 23, props.modFrontWheels, false)
    end

    if props.modBackWheels ~= nil then
        SetVehicleMod(veh, 24, props.modBackWheels, false)
    end

    if props.modPlateHolder ~= nil then
        SetVehicleMod(veh, 25, props.modPlateHolder, false)
    end

    if props.modVanityPlate ~= nil then
        SetVehicleMod(veh, 26, props.modVanityPlate, false)
    end

    if props.modTrimA ~= nil then
        SetVehicleMod(veh, 27, props.modTrimA, false)
    end

    if props.modOrnaments ~= nil then
        SetVehicleMod(veh, 28, props.modOrnaments, false)
    end

    if props.modDashboard ~= nil then
        SetVehicleMod(veh, 29, props.modDashboard, false)
    end

    if props.modDial ~= nil then
        SetVehicleMod(veh, 30, props.modDial, false)
    end

    if props.modDoorSpeaker ~= nil then
        SetVehicleMod(veh, 31, props.modDoorSpeaker, false)
    end

    if props.modSeats ~= nil then
        SetVehicleMod(veh, 32, props.modSeats, false)
    end

    if props.modSteeringWheel ~= nil then
        SetVehicleMod(veh, 33, props.modSteeringWheel, false)
    end

    if props.modShifterLeavers ~= nil then
        SetVehicleMod(veh, 34, props.modShifterLeavers, false)
    end

    if props.modAPlate ~= nil then
        SetVehicleMod(veh, 35, props.modAPlate, false)
    end

    if props.modSpeakers ~= nil then
        SetVehicleMod(veh, 36, props.modSpeakers, false)
    end

    if props.modTrunk ~= nil then
        SetVehicleMod(veh, 37, props.modTrunk, false)
    end

    if props.modHydrolic ~= nil then
        SetVehicleMod(veh, 38, props.modHydrolic, false)
    end

    if props.modEngineBlock ~= nil then
        SetVehicleMod(veh, 39, props.modEngineBlock, false)
    end

    if props.modAirFilter ~= nil then
        SetVehicleMod(veh, 40, props.modAirFilter, false)
    end

    if props.modStruts ~= nil then
        SetVehicleMod(veh, 41, props.modStruts, false)
    end

    if props.modArchCover ~= nil then
        SetVehicleMod(veh, 42, props.modArchCover, false)
    end

    if props.modAerials ~= nil then
        SetVehicleMod(veh, 43, props.modAerials, false)
    end

    if props.modTrimB ~= nil then
        SetVehicleMod(veh, 44, props.modTrimB, false)
    end

    if props.modTank ~= nil then
        SetVehicleMod(veh, 45, props.modTank, false)
    end

    if props.modWindows ~= nil then
        SetVehicleMod(veh, 46, props.modWindows, false)
    end

    if props.modLivery ~= nil then
        SetVehicleMod(veh, 48, props.modLivery, false)
    end

    if props.modLiveries ~= nil then
        SetVehicleLivery(veh, props.modLiveries)
    end

    if props.lightsColor ~= nil then
        if props.lightsColor == 255 then
            props.lightsColor = 0
        end

        if props.lightsColor ~= 0 then
            ToggleVehicleMod(veh, 22, true)
            SetVehicleHeadlightsColour(veh, props.lightsColor)
        else
            SetVehicleHeadlightsColour(veh, 0)
        end
    end
end

function GetVehicleProperties(vehicle)
    if DoesEntityExist(vehicle) then
        local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
        local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
        local extras = {}

        for extraId = 0, 12 do
            if DoesExtraExist(vehicle, extraId) then
                local state = IsVehicleExtraTurnedOn(vehicle, extraId) == 1
                extras[tostring(extraId)] = state
            end
        end

        return {
            plate = GetVehicleNumberPlateText(vehicle),
            actualPlate = exports.data:getVehicleActualPlateNumber(vehicle),
            plateIndex = GetVehicleNumberPlateTextIndex(vehicle),
            bodyHealth = GetVehicleBodyHealth(vehicle),
            engineHealth = GetVehicleEngineHealth(vehicle),
            fuelLevel = exports.gas_stations:GetFuel(vehicle),
            dirtLevel = GetVehicleDirtLevel(vehicle),
            lightsColor = GetVehicleHeadlightsColour(vehicle),
            dashboardColor = GetVehicleDashboardColour(vehicle),
            interiorColor = GetVehicleInteriorColour(vehicle),
            color1 = colorPrimary,
            color2 = colorSecondary,
            pearlescentColor = pearlescentColor,
            wheelColor = wheelColor,
            wheels = GetVehicleWheelType(vehicle),
            windowTint = GetVehicleWindowTint(vehicle),
            neonEnabled = {
                IsVehicleNeonLightEnabled(vehicle, 0),
                IsVehicleNeonLightEnabled(vehicle, 1),
                IsVehicleNeonLightEnabled(vehicle, 2),
                IsVehicleNeonLightEnabled(vehicle, 3)
            },
            extras = extras,
            neonColor = table.pack(GetVehicleNeonLightsColour(vehicle)),
            tyreSmokeColor = table.pack(GetVehicleTyreSmokeColor(vehicle)),
            modSpoilers = GetVehicleMod(vehicle, 0),
            modFrontBumper = GetVehicleMod(vehicle, 1),
            modRearBumper = GetVehicleMod(vehicle, 2),
            modSideSkirt = GetVehicleMod(vehicle, 3),
            modExhaust = GetVehicleMod(vehicle, 4),
            modFrame = GetVehicleMod(vehicle, 5),
            modGrille = GetVehicleMod(vehicle, 6),
            modHood = GetVehicleMod(vehicle, 7),
            modFender = GetVehicleMod(vehicle, 8),
            modRightFender = GetVehicleMod(vehicle, 9),
            modRoof = GetVehicleMod(vehicle, 10),
            modEngine = GetVehicleMod(vehicle, 11),
            modBrakes = GetVehicleMod(vehicle, 12),
            modTransmission = GetVehicleMod(vehicle, 13),
            modHorns = GetVehicleMod(vehicle, 14),
            modSuspension = GetVehicleMod(vehicle, 15),
            modArmor = GetVehicleMod(vehicle, 16),
            modTurbo = IsToggleModOn(vehicle, 18),
            modSmokeEnabled = IsToggleModOn(vehicle, 20),
            modXenon = IsToggleModOn(vehicle, 22),
            modFrontWheels = GetVehicleMod(vehicle, 23),
            modBackWheels = GetVehicleMod(vehicle, 24),
            modPlateHolder = GetVehicleMod(vehicle, 25),
            modVanityPlate = GetVehicleMod(vehicle, 26),
            modTrimA = GetVehicleMod(vehicle, 27),
            modOrnaments = GetVehicleMod(vehicle, 28),
            modDashboard = GetVehicleMod(vehicle, 29),
            modDial = GetVehicleMod(vehicle, 30),
            modDoorSpeaker = GetVehicleMod(vehicle, 31),
            modSeats = GetVehicleMod(vehicle, 32),
            modSteeringWheel = GetVehicleMod(vehicle, 33),
            modShifterLeavers = GetVehicleMod(vehicle, 34),
            modAPlate = GetVehicleMod(vehicle, 35),
            modSpeakers = GetVehicleMod(vehicle, 36),
            modTrunk = GetVehicleMod(vehicle, 37),
            modHydrolic = GetVehicleMod(vehicle, 38),
            modEngineBlock = GetVehicleMod(vehicle, 39),
            modAirFilter = GetVehicleMod(vehicle, 40),
            modStruts = GetVehicleMod(vehicle, 41),
            modArchCover = GetVehicleMod(vehicle, 42),
            modAerials = GetVehicleMod(vehicle, 43),
            modTrimB = GetVehicleMod(vehicle, 44),
            modTank = GetVehicleMod(vehicle, 45),
            modWindows = GetVehicleMod(vehicle, 46),
            modLivery = GetVehicleMod(vehicle, 48),
            modLiveries = GetVehicleLivery(vehicle)
        }
    end

    return nil
end

local callingTow = false
RegisterCommand("tow", function()
    local isAdmin = exports.data:getUserVar("admin")
    if exports.base_jobs:hasUserJobType("police", true) or exports.base_jobs:hasUserJob("lsfd", true) or isAdmin > 1 then
        canTow = isAdmin
        if not callingTow then
            callingTow = true
            exports.progressbar:startProgressBar({
                Duration = 5000,
                Label = "Voláš odtahovku..",
                CanBeDead = false,
                CanCancel = true,
                DisableControls = {
                    Movement = false,
                    CarMovement = true,
                    Mouse = false,
                    Combat = true
                },
                Animation = {
                    scenario = "WORLD_HUMAN_STAND_MOBILE"
                }
            }, function(finished)
                callingTow = false
                if finished then
                    local veh = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 5.0, 0, 23)

                    if not DoesEntityExist(veh) then
                        veh = getVehicleInDirection(2.0)
                    end

                    if veh and veh ~= 0 then
                        local plate = exports.data:getVehicleActualPlateNumber(veh)
                        local blockVehicle = false
                        WarMenu.CreateMenu("tow", "Odtažení vozidla", "Zvol akci")
                        WarMenu.OpenMenu("tow")

                        while WarMenu.IsMenuOpened("tow") do
                            if canTow ~= "lsfd" and WarMenu.CheckBox("Zablokovat vozidlo", blockVehicle) then
                                blockVehicle = not blockVehicle
                            elseif WarMenu.Button("Odtáhnout") then
                                WarMenu.CloseMenu()
                                exports.notify:display({
                                    type = "success",
                                    title = "Odtah",
                                    text = "Nezapomeň zavolat znovu!",
                                    icon = "fas fa-car",
                                    length = 3000
                                })
                                TriggerServerEvent("base_vehicles:towVehicle", plate, blockVehicle, VehToNet(veh))
                            end
                            WarMenu.Display()
                            Citizen.Wait(0)
                        end
                    else
                        exports.notify:display({
                            type = "error",
                            title = "Odtah",
                            text = "V okolí není žádné vozidlo",
                            icon = "fas fa-car",
                            length = 3000
                        })
                    end
                end
            end)
        end
    else
        exports.notify:display({
            type = "error",
            title = "Odtah",
            text = "S odtahovou službou nemáš dohodu",
            icon = "fas fa-car",
            length = 3000
        })
    end
end)

local vehToUnregiser = nil
RegisterCommand("unblock", function()
    if exports.base_jobs:hasUserJobType("police", true) then
        WarMenu.CreateMenu("garage-untow", "Odblokování vozidla", "Zvolte akci")
        WarMenu.OpenMenu("garage-untow")

        while WarMenu.IsMenuOpened("garage-untow") do
            if WarMenu.Button("SPZ vozidla:", vehToUnregiser or "Nezadaná") then
                exports.input:openInput("text", {
                    title = "Zadej SPZ vozidla",
                    placeholder = ""
                }, function(plate)
                    if plate and plate ~= "" then
                        vehToUnregiser = plate
                    end
                end)
            elseif WarMenu.Button("Odblokovat") then
                WarMenu.CloseMenu()
                exports.notify:display({
                    type = "success",
                    title = "Blokace",
                    text = "Nezapomeň napsat znovu!",
                    icon = "fas fa-car",
                    length = 3000
                })
                TriggerServerEvent("base_vehicles:unblockVehicle", vehToUnregiser)
                vehToUnregiser = nil
            end
            WarMenu.Display()
            Citizen.Wait(0)
        end
    else
        exports.notify:display({
            type = "error",
            title = "Odtah",
            text = "S odtahovou službou nemáš dohodu",
            icon = "fas fa-car",
            length = 3000
        })
    end
end)

RegisterCommand("vin", function()
    if exports.base_jobs:hasUserJobType("police", true) then
        exports.progressbar:startProgressBar({
            Duration = 10000,
            Label = "Hledáš VIN vozidla..",
            CanBeDead = false,
            CanCancel = true,
            DisableControls = {
                Movement = true,
                CarMovement = true,
                Mouse = false,
                Combat = true
            },
            Animation = {
                scenario = "CODE_HUMAN_MEDIC_KNEEL"
            }
        }, function(finished)
            if finished then
                local veh = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 5.0, 0, 23)

                if not DoesEntityExist(veh) then
                    veh = getVehicleInDirection(2.0)
                end
                if DoesEntityExist(veh) then
                    local vehicleVin = exports.data:getVehicleVin(veh)
                    if vehicleVin and vehicleVin ~= "error" then
                        exports.notify:display({
                            type = "info",
                            title = "VIN vozidla",
                            text = "Vozidlo má VIN " .. vehicleVin,
                            icon = "fas fa-car",
                            length = 3000
                        })
                        exports.copy:copyToInsert(vehicleVin)
                    else
                        exports.notify:display({
                            type = "warning",
                            title = "VIN vozidla",
                            text = "U vozidla nebylo VIN nalezeno",
                            icon = "fas fa-car",
                            length = 4000
                        })
                    end
                else
                    exports.notify:display({
                        type = "error",
                        title = "Odtah",
                        text = "V okolí není žádné vozidlo",
                        icon = "fas fa-car",
                        length = 3000
                    })
                end
            end
        end)
    end
end)

function getVehicleInDirection(range)
    local playerPed = PlayerPedId()
    local coordA = GetEntityCoords(playerPed, 1)
    local coordB = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, range, 0.0)

    local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(coordA.xyz, coordB.xyz, 10, playerPed, 0)
    local a, b, c, d, vehicle = GetShapeTestResult(rayHandle)
    return vehicle
end