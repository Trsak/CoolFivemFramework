local isSpawned, isDead = false, false
local publicBlips, peds = {}, {}
local practiceBlip, myLicenses = nil, nil

local currentTest = {
    Name = nil,
    Points = 0,
    Step = 0,
    Answered = {}
}

Citizen.CreateThread(
    function()
        Citizen.Wait(500)

        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            TriggerServerEvent("license:sync")
            isSpawned = true
            isDead = status == "dead"
            if isDead then
                cancelTests()
            end
        end
        for i, point in each(Config.LicensePoints) do
            exports.target:AddCircleZone(
                "licenceMaster-" .. i,
                point.Coords.xyz,
                1.5,
                {
                    actions = {
                        action = {
                            cb = function(cbData)
                                openLicenseMenu(cbData.Id)
                                currentPoint = cbData.Id
                            end,
                            cbData = {Id = i},
                            icon = "fas fa-car",
                            label = point.Groups[1] == "TR" and "Teoretická zkouška" or "Praktické testy"
                        }
                    },
                    distance = 1.0
                }
            )
        end

        checkMisc()
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned = false
        elseif status == "spawned" or status == "dead" then
            isDead = status == "dead"
            if not isSpawned then
                isSpawned = true
                TriggerServerEvent("license:sync")
            elseif isDead then
                cancelTests()
            end
        end
    end
)

function openLicenseMenu(license)
    TriggerServerEvent("license:getLicenses", license)
end

RegisterNetEvent("license:sync")
AddEventHandler(
    "license:sync",
    function(licenses)
        myLicenses = licenses
    end
)

function getLicenses()
    return myLicenses
end

function hasLicense(licenseName, checkBlocked)
    if myLicenses and myLicenses[licenseName] then
        if not checkBlocked or (myLicenses[licenseName].status == "done") then
            return true
        end
    end

    return false
end

RegisterNetEvent("license:getLicenses")
AddEventHandler(
    "license:getLicenses",
    function(ownedLicenses, type, time)
        myLicenses = ownedLicenses
        if Config.LicensePoints[type].Groups[1] == "TR" and ownedLicenses["TR"] then
            exports.notify:display(
                {
                    type = "warning",
                    title = "Autoškola",
                    text = "Zde Vám nic nabídnou nemůžeme.",
                    icon = "far fa-id-card",
                    length = 2500
                }
            )
            return
        end
        SendNUIMessage(
            {
                Action = "show",
                Type = Config.LicensePoints[type].Groups[1] == "TR" and "teoretic" or "practic",
                Licenses = ownedLicenses,
                Config = {
                    Points = Config.LicensePoints,
                    Licenses = Config.Licenses,
                    Questions = Config.Questions,
                    Practices = Config.Practices
                }
            }
        )
        SetNuiFocus(true, true)
    end
)

RegisterNetEvent("license:checkedMoney")
AddEventHandler(
    "license:checkedMoney",
    function(test, hasMoney, hasId)
        if hasMoney == "done" and hasId then
            if test == "TR" then
                currentTest.Name = test
                SendNUIMessage(
                    {
                        Action = "show",
                        Type = "teoretic-test"
                    }
                )
            else
                startPractice(test)
            end
        else
            local missing = {}
            if hasMoney ~= "done" then
                table.insert(missing, "Trochu kratší na hotovosti..<br> ")
            end
            if not hasId then
                table.insert(missing, "Je zapotřebí Váš občanský průkaz!")
            end
            exports.notify:display(
                {
                    type = "warning",
                    title = "Autoškola",
                    text = table.concat(missing),
                    icon = "far fa-id-card",
                    length = 2500
                }
            )
        end
    end
)

RegisterNUICallback(
    "closepanel",
    function(data, cb)
        if data.notify then
            exports.notify:display(
                {
                    type = "warning",
                    title = "Praktické zkoušky",
                    text = "Bohužel pro Vás zde nic nemáme.",
                    icon = "far fa-id-card",
                    length = 2500
                }
            )
        end
        SendNUIMessage(
            {
                Action = "hide"
            }
        )
        SetNuiFocus(false, false)

        currentTest = {
            Name = nil,
            Points = 0,
            Step = 0,
            Answered = {}
        }
    end
)

RegisterNUICallback(
    "endTest",
    function(data, cb)
        SendNUIMessage(
            {
                Action = "hide"
            }
        )
        SetNuiFocus(false, false)
        if data.type == "done" then
            if data.points >= Config.Questions[data.test].MinPoints then
                exports.notify:display(
                    {
                        type = "success",
                        title = "Teoretická zkouška",
                        text = "Zvládl/a jste to! Máte " .. data.points .. " bodů z " .. data.steps .. ".",
                        icon = "far fa-id-card",
                        length = 3000
                    }
                )
                TriggerServerEvent("license:successful", data)
            else
                exports.notify:display(
                    {
                        type = "error",
                        title = "Teoretická zkouška",
                        text = "Bohužel, nezvládl/a jste to! Máte " .. data.points .. " bodů z " .. data.steps .. ".",
                        icon = "far fa-id-card",
                        length = 3000
                    }
                )
            end
        elseif data.type == "canceled" then
            exports.notify:display(
                {
                    type = "info",
                    title = "Teoretická zkouška",
                    text = "Ukončil/a jste test. Nárok na vrácení peněz nemáte!",
                    icon = "far fa-id-card",
                    length = 3000
                }
            )
        end
    end
)

RegisterNUICallback(
    "warnExit",
    function(data, cb)
        exports.notify:display(
            {
                type = "warning",
                title = "Teoretická zkouška",
                text = "Máte 5 vteřin na potvrzení zrušení testu!",
                icon = "far fa-id-card",
                length = 3000
            }
        )
    end
)

RegisterNUICallback(
    "chooseTest",
    function(data, cb)
        if data.testname ~= "TR" then
            if isStartingPointOccluded(Config.Practices[data.testname].Routes[1]) then
                exports.notify:display(
                    {
                        type = "info",
                        title = "Praktická zkouška",
                        text = "Chvíli vydrže, než se uvolní místo pro zaparkování auta!",
                        icon = "far fa-id-card",
                        length = 3000
                    }
                )
                return
            end
        end

        TriggerServerEvent("license:checkMoney", data.testname)
    end
)

function createNextBlipPoint(step)
    if practiceBlip then
        RemoveBlip(practiceBlip)
    end
    if currentTest.Practice then
        practiceBlip =
            createNewBlip(
            {
                coords = currentTest.Practice.Steps[step].Coords.xyz,
                sprite = 38,
                display = 4,
                scale = 0.6,
                colour = 5,
                isShortRange = false,
                text = "Bod autoškoly"
            }
        )

        ClearGpsCustomRoute()
        StartGpsMultiRoute(12, false, false)
        AddPointToGpsMultiRoute(currentTest.Practice.Steps[step - 1].Coords.xyz)
        AddPointToGpsMultiRoute(currentTest.Practice.Steps[step].Coords.xyz)
        if currentTest.Practice.Steps[step + 1] then
            AddPointToGpsMultiRoute(currentTest.Practice.Steps[step + 1].Coords.xyz)
        end
        SetGpsMultiRouteRender(true)
    end
end

function cancelTests()
    if currentTest.Vehicle then
        DeleteVehicle(currentTest.Vehicle)
        currentTest.Active = false
        ClearGpsMultiRoute()
        RemoveBlip(practiceBlip)
    end

    SendNuiMessage(
        {
            Action = "hide"
        }
    )
    SetNuiFocus(false, false)
end

function startPractice(test)
    if Config.Practices[test] then
        SendNUIMessage(
            {
                Action = "hide"
            }
        )
        SetNuiFocus(false, false)
        local practice = Config.Practices[test].Routes[math.random(1, #Config.Practices[test].Routes)]

        currentTest.Name = test
        currentTest.Step = 2
        currentTest.Practice = practice
        currentTest.Points = practice.MaxMistakes

        local vehicle = GetHashKey(Config.Practices[test].Vehicles[math.random(1, #Config.Practices[test].Vehicles)])

        while not HasModelLoaded(vehicle) do
            RequestModel(vehicle)
            Citizen.Wait(0)
        end

        currentTest.Vehicle = CreateVehicle(vehicle, practice.Steps[1].Coords, true, true)
        SetVehicleModKit(currentTest.Vehicle, 0)
        SetVehicleNumberPlateText(currentTest.Vehicle, "L-SCHOOL")
        exports.gas_stations:SetFuel(currentTest.Vehicle, 100.0)
        currentTest.Health = GetEntityHealth(currentTest.Vehicle)

        TaskWarpPedIntoVehicle(PlayerPedId(), currentTest.Vehicle, -1)

        local speed = Config.MaxSpeed[currentTest.Practice.Steps[currentTest.Step].InPlace]
        exports.notify:display(
            {
                type = "info",
                title = "Praktická zkouška",
                text = "Pokračujte do dalšího bodu... [max. rychlost: " .. speed .. "]",
                icon = "far fa-id-card",
                length = 3000
            }
        )

        currentTest.Active = true
        createNextBlipPoint(currentTest.Step)

        StartGpsMultiRoute(12, false, false)
        AddPointToGpsMultiRoute(currentTest.Practice.Steps[currentTest.Step].Coords.xyz)
        if currentTest.Practice.Steps[currentTest.Step + 1] then
            AddPointToGpsMultiRoute(currentTest.Practice.Steps[currentTest.Step + 1].Coords.xyz)
        end
        SetGpsMultiRouteRender(true)

        while currentTest.Active do
            Citizen.Wait(0)
            local playerPed = PlayerPedId()
            if IsPedInVehicle(playerPed, currentTest.Vehicle, false) then
                local pointCoords = currentTest.Practice.Steps[currentTest.Step].Coords.xyz
                local distance = #(GetEntityCoords(playerPed) - pointCoords)
                if distance < 50.0 then
                    DrawMarker(
                        30,
                        pointCoords,
                        0.0,
                        0.0,
                        0.0,
                        0.0,
                        0.0,
                        0.0,
                        5.0,
                        5.0,
                        5.0,
                        240,
                        30,
                        30,
                        100,
                        false,
                        true,
                        2,
                        true,
                        false,
                        false,
                        false
                    )
                    if distance <= 7.0 then
                        if currentTest.Step == #currentTest.Practice.Steps then
                            currentTest.Active = false
                            ClearGpsMultiRoute()
                            RemoveBlip(practiceBlip)
                            TaskLeaveVehicle(playerPed, currentTest.Vehicle, 0)

                            local done = true
                            if not currentTest.Practice.IgnoreSpeed or not currentTest.Practice.IgnoreDamage then
                                if currentTest.Points <= 0 then
                                    done = false
                                end
                            end
                            if done then
                                exports.notify:display(
                                    {
                                        type = "success",
                                        title = "Autoškola",
                                        text = "Gratulujeme! Úspěšně jste dokončil praktickou zkoušku z licence skupiny " ..
                                            currentTest.Name,
                                        icon = "far fa-id-card",
                                        length = 3000
                                    }
                                )
                                TriggerServerEvent(
                                    "license:successful",
                                    {test = currentTest.Name, points = currentTest.Points}
                                )
                            else
                                exports.notify:display(
                                    {
                                        type = "error",
                                        title = "Autoškola",
                                        text = "Bohužel jste nedokončil praktickou zkoušku z licence skupiny " ..
                                            currentTest.Name,
                                        icon = "far fa-id-card",
                                        length = 3000
                                    }
                                )
                            end
                            Citizen.Wait(3000)
                            DeleteVehicle(currentTest.Vehicle)
                        else
                            currentTest.Step = currentTest.Step + 1
                            createNextBlipPoint(currentTest.Step)
                            local speed = Config.MaxSpeed[currentTest.Practice.Steps[currentTest.Step].InPlace]
                            exports.notify:display(
                                {
                                    type = "info",
                                    title = "Praktická zkouška",
                                    text = "Pokračujte v jízdě ... [max. rychlost: " .. speed .. "]",
                                    icon = "far fa-id-card",
                                    length = 3000
                                }
                            )
                        end
                    end
                end
                local type = currentTest.Practice.Steps[currentTest.Step].InPlace
                local speed = math.floor(GetEntitySpeed(currentTest.Vehicle) * 2.23694)
                if speed > Config.MaxSpeed[type] then
                    currentTest.Points = currentTest.Points - 1
                    exports.notify:display(
                        {
                            type = "warning",
                            title = "Praktická zkouška",
                            text = "Doporučuji zpomalit!",
                            icon = "far fa-id-card",
                            length = 2000
                        }
                    )
                    Citizen.Wait(5000)
                end

                if DoesEntityExist(currentTest.Vehicle) then
                    local currentHealth = GetEntityHealth(currentTest.Vehicle)
                    if (currentHealth) < currentTest.Health then
                        currentTest.Health = currentHealth
                        currentTest.Points = currentTest.Points - 1
                        exports.notify:display(
                            {
                                type = "warning",
                                title = "Praktická zkouška",
                                text = "Doporučuji takhle nebourat!",
                                icon = "far fa-id-card",
                                length = 2000
                            }
                        )
                    end
                end
            else
                if not currentTest.Timer then
                    currentTest.Timer = 10
                    while true do
                        exports.notify:display(
                            {
                                type = "warning",
                                title = "Praktická zkouška",
                                text = "Máte " .. currentTest.Timer .. " sekund na vrácení se do vozu.",
                                icon = "far fa-id-card",
                                length = 1200
                            }
                        )
                        if IsPedInVehicle(playerPed, currentTest.Vehicle, false) then
                            break
                        end
                        Citizen.Wait(1000)
                        currentTest.Timer = currentTest.Timer - 1
                        if currentTest.Timer <= 0 then
                            break
                        end
                    end
                    currentTest.Timer = nil

                    if not IsPedInVehicle(playerPed, currentTest.Vehicle, false) then
                        currentTest.Active = false
                        ClearGpsMultiRoute()
                        RemoveBlip(practiceBlip)

                        DeleteVehicle(currentTest.Vehicle)
                        exports.notify:display(
                            {
                                type = "error",
                                title = "Praktická zkouška",
                                text = "Bohužel jste nedokončil praktickou zkoušku z licence skupiny " ..
                                    currentTest.Name,
                                icon = "far fa-id-card",
                                length = 3000
                            }
                        )
                    end
                end
            end
        end
    end
end

function checkMisc()
    if #peds <= 0 then
        createPeds()
    end
    if #publicBlips <= 0 then
        for i, office in each(Config.LicensePoints) do
            if office.Name then
                local blip =
                    createNewBlip(
                    {
                        coords = office.Coords,
                        sprite = 525,
                        display = 3,
                        scale = 0.5,
                        colour = 0,
                        isShortRange = true,
                        text = office.Name
                    }
                )

                table.insert(publicBlips, blip)
            end
        end
    end
end

function createPeds()
    for i, point in each(Config.LicensePoints) do
        while not HasModelLoaded(GetHashKey("a_f_y_business_02")) do
            RequestModel(GetHashKey("a_f_y_business_02"))
            Wait(5)
        end
        local ped = CreatePed(4, GetHashKey("a_f_y_business_02"), point.Coords.xy, point.Coords.z - 1.0, false, false)
        SetEntityHeading(ped, point.Coords.w)
        SetEntityAsMissionEntity(ped, true, true)
        SetPedHearingRange(ped, 0.0)
        SetPedSeeingRange(ped, 0.0)
        SetPedAlertness(ped, 0.0)
        SetPedFleeAttributes(ped, 0, 0)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedCombatAttributes(ped, 46, true)
        SetPedFleeAttributes(ped, 0, 0)
        SetEntityInvincible(ped, true)
        FreezeEntityPosition(ped, true)
        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CLIPBOARD", 0, false)
        table.insert(peds, ped)
    end
end

function isStartingPointOccluded(coords)
    local flags = 2 + 4 + 16 + 256

    local width = 2.3
    local length = 4.5
    local height = 2.0
    local ray = StartShapeTestBox(coords.xyz, width, length, height, 0.0, 0.0, coords.w, 2, flags, 0, 4)

    local _, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(ray)

    return hit > 0
end
