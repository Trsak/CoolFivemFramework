local isSpawned, isDead, jobs = false, false, {}
local timers, alertsHistory = {}, {}
local dispatchMenu = false

AddEventHandler(
    "CEventGunShot",
    function(entities, eventEntity, args)
        if not eventEntity then
            return
        end
        if eventEntity == PlayerPedId() and not timers.shooting then
            local data, playerPed = Config.Alerts.shooting, PlayerPedId()
            if not hasAllowedJob(data.WhitelistJobs) and not hasBlockedWeapon() then
                if isNearNPC(data.NpcDistance) and math.random(1, 100) <= data.ReportChance then
                    local isWeaponSilenced = IsPedCurrentWeaponSilenced(playerPed)

                    if not isWeaponSilenced or math.random(1, 100) <= data.ReportChanceWithSuppresor then
                        local weaponLabel = nil

                        if math.random(1, 100) <= data.WeaponModelReportChance then
                            local _, currentWeapon = GetCurrentPedWeapon(playerPed, true)
                            weaponLabel = exports.inventory:getWeaponLabel(currentWeapon)
                        end

                        local playerCoords = GetEntityCoords(playerPed)
                        TriggerServerEvent(
                            "outlawalert:sendAlert",
                            {
                                Type = "shooting",
                                Coords = playerCoords,
                                Weapon = weaponLabel,
                                Street = exports.vehicle_ui:getStreetName(playerCoords)
                            }
                        )
                        setReportTimeout("shooting", data.Timer)
                    end
                end
            end
        end
    end
)

AddEventHandler(
    "CEventShockingSeenMeleeAction",
    function(entities, eventEntity, args)
        if not eventEntity then
            return
        end
        if eventEntity == PlayerPedId() and not timers.combat then
            local data = Config.Alerts.combat
            if isNearNPC(data.NpcDistance) and not hasAllowedJob(data.WhitelistJobs) and math.random(1, 100) <= data.ReportChance then
                local playerCoords = GetEntityCoords(PlayerPedId())
                TriggerServerEvent(
                    "outlawalert:sendAlert",
                    {
                        Type = "combat",
                        Coords = playerCoords,
                        Street = exports.vehicle_ui:getStreetName(playerCoords)
                    }
                )
                setReportTimeout("combat", data.Timer)
            end
        end
    end
)

AddEventHandler(
    "CEventShockingCarAlarm",
    function(entities, eventEntity, args)
        if not eventEntity then
            return
        end
        if eventEntity == PlayerPedId() and not timers.carJack then
            reportCarJack()
        end
    end
)

AddEventHandler(
    "CEventPedJackingMyVehicle",
    function(entities, eventEntity, args)
        if not eventEntity then
            return
        end
        Citizen.Wait(math.random(100, 200))
        if eventEntity == PlayerPedId() and not timers.carJack then
            reportCarJack()
        end
    end
)

function reportCarJack()
    local data = Config.Alerts.carJack
    local playerPed = PlayerPedId()
    if isNearNPC(data.NpcDistance) and not hasAllowedJob(data.WhitelistJobs) then
        if IsPedTryingToEnterALockedVehicle(playerPed) or IsPedJacking(playerPed) then
            while IsPedTryingToEnterALockedVehicle(playerPed) or IsPedJacking(playerPed) do
                Citizen.Wait(50)
            end

            local currentVehicle, vehicleModel, vehiclePlate, vehicleColor = GetVehiclePedIsIn(playerPed, true), nil, nil, nil

            if currentVehicle and currentVehicle ~= 0 then
                if math.random(1, 100) <= data.VehicleModelReportChance then
                    vehicleModel = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(currentVehicle)))
                end

                if math.random(1, 100) <= data.VehiclePlateReportChance then
                    vehiclePlate = exports.data:getVehicleActualPlateNumber(currentVehicle)
                end

                if math.random(1, 100) <= data.VehicleColorReportChance then
                    local primary, secondary = GetVehicleColours(currentVehicle)
                    vehicleColor = getColorLabel(primary)
                end
            end

            local playerCoords = GetEntityCoords(playerPed)
            TriggerServerEvent(
                "outlawalert:sendAlert",
                {
                    Type = "carJack",
                    Coords = playerCoords,
                    Model = vehicleModel,
                    Plate = vehiclePlate,
                    Street = exports.vehicle_ui:getStreetName(playerCoords),
                    Color = vehicleColor
                }
            )
            setReportTimeout("carJack", data.Timer)
        end
    end
end

Citizen.CreateThread(
    function()
        Citizen.Wait(500)
        exports.chat:addSuggestion("/lastalert", "Nastaví GPS na poslední nahlášení")
        exports.chat:addSuggestion("/dispatch", "Otevře seznam všech nahlášení")
        exports.chat:addSuggestion("/removegps", "Odebere z mapy aktuální GPS k Waypointu")
        local status = exports.data:getUserVar("status")

        if status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
            loadJobs()
        end
    end
)

RegisterNetEvent("s:jobUpdated")
AddEventHandler(
    "s:jobUpdated",
    function(newJobs)
        loadJobs(newJobs)
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned, isDead, jobs = false, false, {}
        elseif status == "spawned" or status == "dead" then
            isDead = (status == "dead")
            if not isSpawned then
                isSpawned = true
                loadJobs()
            end

            if isDead then
                startDeadTimeout()
            end
        end
    end
)

RegisterNetEvent("outlawalert:recieveAlert")
AddEventHandler(
    "outlawalert:recieveAlert",
    function(data)
        if hasAllowedJob(Config.Alerts[data.Type].Jobs) then
            if data.Type == "panic" or data.Type == "officerdown" then
                PlaySound(-1, "Event_Message_Purple", "GTAO_FM_Events_Soundset", 0, 0, 1)
            end
            insertToHistory(
                {
                    type = data.Type,
                    title = data.Title or Config.Alerts[data.Type].Notify.Text,
                    coords = data.Coords,
                    location = data.Street or exports.vehicle_ui:getStreetName(data.Coords),
                    code = Config.Alerts[data.Type].Code,
                    weapon = data.Weapon or nil,
                    plate = data.Plate or nil,
                    vehicle = data.Model or nil,
                    time = data.TimeLabel,
                    color = data.Color or nil
                }
            )

            exports.notify:outlawAlert(
                {
                    type = Config.Alerts[data.Type].Notify.Type,
                    title = data.Title or Config.Alerts[data.Type].Notify.Text,
                    code = Config.Alerts[data.Type].Code,
                    location = data.Street or exports.vehicle_ui:getStreetName(data.Coords),
                    weapon = data.Weapon or nil,
                    icon = Config.Alerts[data.Type].Notify.Icon,
                    length = Config.Alerts[data.Type].Notify.Time,
                    plate = data.Plate or nil,
                    vehicle = data.Model or nil,
                    color = data.Color or nil
                }
            )

            displayBlip(
                data.Coords,
                Config.Alerts[data.Type].Blip.Text,
                Config.Alerts[data.Type].Blip.Time,
                Config.Alerts[data.Type].Blip.Color,
                Config.Alerts[data.Type].Blip.Size,
                Config.Alerts[data.Type].Blip.Sprite or 487
            )
        end
    end
)

function startDeadTimeout()
    local calledHelp, canRespawn = false, false
    local untilRespawn = math.ceil(600000 / 1000)
    Citizen.CreateThread(
        function()
            while not canRespawn do
                Citizen.Wait(1000)
                untilRespawn = untilRespawn - 1
                if untilRespawn <= 0 then
                    canRespawn = true
                end
            end
        end
    )
    local font = RegisterFontId("AMSANSL")
    while isDead do
        Citizen.Wait(1)
        SetTextFont(font)
        SetTextScale(0.4, 0.4)
        SetTextColour(255, 255, 255, 255)
        SetTextOutline()
        SetTextEntry("STRING")
        if not canRespawn then
            AddTextComponentString(
                "Krvácíš nebo jsi omdlel. " ..
                    (not calledHelp and 'Pro zavolání pomoci využij "~r~G~w~".~n~' or "") ..
                    "Zbývá: ~r~" .. untilRespawn .. "~w~ sekund"
            )
        else
            AddTextComponentString('Podrž "~r~G~w~" pro odvezení do nemocnice')
        end
        DrawText(0.45, 0.85)
        if not calledHelp and IsDisabledControlJustReleased(0, 47) then
            calledHelp = true
            local playerCoords = GetEntityCoords(PlayerPedId())
            if hasAllowedJob(Config.Alerts.officerdown.ReportedJobs) then
                if math.random(1, 100) <= Config.Alerts.officerdown.ReportChance then
                    TriggerServerEvent(
                        "outlawalert:sendAlert",
                        {
                            Type = "officerdown",
                            Coords = playerCoords
                        }
                    )
                end
            else
                TriggerServerEvent(
                    "outlawalert:sendAlert",
                    {
                        Type = "mandown",
                        Coords = playerCoords
                    }
                )
            end
        end
        if canRespawn and IsDisabledControlPressed(0, 47) then
            local checks = 50

            while IsDisabledControlPressed(0, 47) and checks > 0 do
                checks = checks - 1

                Wait(25)
            end
            if checks <= 0 then
                sendToHospital()
            end
        end
    end
end

function setReportTimeout(type, length)
    timers[type] = true
    Citizen.SetTimeout(
        length * 1000,
        function()
            timers[type] = false
        end
    )
end

function sendToHospital()
    local playerPed = PlayerPedId()
    if IsEntityOnFire() then
        StopEntityFire(playerPed)
    end
    canRespawn, calledHelp = false, false
    Citizen.Wait(100)
    local jail = exports.data:getCharVar("jail")
    if jail == nil or jail.Time == nil or (jail.Time ~= nil and jail.Time <= 0) then
        SetEntityCoords(playerPed, Config.Respawn.Hospital.xyz)
        SetEntityHeading(playerPed, Config.Respawn.Hospital.w)

        TriggerServerEvent("outlawalert:checkInsurance", exports.data:getCharVar("id"))
    else
        exports.notify:display(
            {
                type = "warning",
                title = "Lékař",
                text = "Našli vás vězni a odvedli na ošetřovnu, máte štěstí.",
                icon = "fas fa-clinic-medical",
                length = 4000
            }
        )
        SetEntityCoords(playerPed, Config.Respawn.Jail.xyz)
        SetEntityHeading(playerPed, Config.Respawn.Jail.w)
    end
end

function hasAllowedJob(allowedJobs)
    if tableLength(jobs) > 0 then
        for i, job in each(allowedJobs) do
            for jobName, jobData in pairs(jobs) do
                if job == jobName and jobData.Duty then
                    return true
                elseif job == jobData.Type and jobData.Duty then
                    return true
                end
            end
        end
    end
    return false
end

function isNearNPC(distance)
    local closestPed = 0
    local playerCoords = GetEntityCoords(PlayerPedId())

    local entityEnumerator = {
        __gc = function(enum)
            if enum.destructor and enum.handle then
                enum.destructor(enum.handle)
            end
            enum.destructor = nil
            enum.handle = nil
        end
    }

    local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
        return coroutine.wrap(
            function()
                local iter, id = initFunc()
                if not id or id == 0 then
                    disposeFunc(iter)
                    return
                end

                local enum = { handle = iter, destructor = disposeFunc }
                setmetatable(enum, entityEnumerator)

                local next = true
                repeat
                    coroutine.yield(id)
                    next, id = moveFunc(iter)
                until not next

                enum.destructor, enum.handle = nil, nil
                disposeFunc(iter)
            end
        )
    end

    local function EnumeratePeds()
        return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
    end

    for ped in EnumeratePeds() do
        if ped ~= GetPlayerPed(-1) and (GetPedType(ped) == 4 or GetPedType(ped) == 5) then
            local distanceCheck = #(playerCoords - GetEntityCoords(ped))
            if distanceCheck <= distance then
                return true
            end
        end
    end

    return false
end

function insertToHistory(data)
    lastAlert = data.coords.xy
    table.sort(
        alertsHistory,
        function(a, b)
            return a.time < b.time
        end
    )

    table.insert(alertsHistory, data)
    if #(alertsHistory) >= 20 then
        alertsHistory[#(alertsHistory)] = nil
    end

    local alertsList = {}
    for i, alert in each(alertsHistory) do
        table.insert(alertsList, alert)
        alertsList[i].coords = { x = alert.coords.x, y = alert.coords.y }
    end

    SendNUIMessage(
        {
            action = "updateList",
            alerts = alertsList
        }
    )
end

function setBlipToAlert(data)
    if data == "last" then
        if lastAlert == nil then
            return
        end

        SetNewWaypoint(lastAlert.x, lastAlert.y)
        exports.notify:display(
            {
                type = "success",
                title = "Úspěch",
                text = "Navigace byla nastavena na poslední hlášení",
                icon = "fas fa-map-marker",
                length = 4000
            }
        )
    else
        SetNewWaypoint(tonumber(data.x), tonumber(data.y))
        exports.notify:display(
            {
                type = "success",
                title = "Úspěch",
                text = "Navigace byla nastavena na zvolené hlášení",
                icon = "fas fa-map-marker",
                length = 4000
            }
        )
    end
end

RegisterNUICallback(
    "closeui",
    function(data, cb)
        SendNUIMessage(
            {
                action = "close"
            }
        )
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
        dispatchMenu = false

        if data.x and data.y and data.title then
            setBlipToAlert(data)
        end

        cb("ok")
    end
)

Citizen.CreateThread(
    function()

        while true do
            Citizen.Wait(0)
            if dispatchMenu then
                DisableControlAction(0, 1, true)
                DisableControlAction(0, 2, true)
                DisableControlAction(0, 3, true)
                DisableControlAction(0, 4, true)
                DisableControlAction(0, 5, true)
                DisableControlAction(0, 6, true)
                DisableControlAction(1, 18, true)
                DisableControlAction(1, 24, true)
                DisableControlAction(1, 25, true)
                DisableControlAction(1, 68, true)
                DisableControlAction(1, 69, true)
                DisableControlAction(1, 70, true)
                DisableControlAction(0, 177, true)
                DisableControlAction(0, 200, true)
                DisableControlAction(0, 202, true)
            end
        end
    end
)

function displayBlip(coords, reason, time, color, size, blip)
    local blip = createNewBlip(
        {
            coords = coords,
            sprite = blip,
            display = 2,
            scale = size,
            colour = color,
            isShortRange = false,
            text = reason
        }
    )
    SetBlipCategory(blip, 11)

    Citizen.SetTimeout(
        time,
        function()
            RemoveBlip(blip)
        end
    )
end

function loadJobs(Jobs)
    jobs = {}
    for _, data in pairs(Jobs and Jobs or exports.data:getCharVar("jobs")) do
        jobs[data.job] = {
            Name = data.job,
            Type = exports.base_jobs:getJobVar(data.job, "type"),
            Grade = data.job_grade,
            Duty = data.duty
        }
    end
end

function tableLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

RegisterCommand(
    "lastalert",
    function()
        setBlipToAlert("last")
    end
)

RegisterCommand(
    "removegps",
    function()
        ClearGpsPlayerWaypoint()
        DeleteWaypoint()
    end
)

RegisterCommand(
    "dispatch",
    function()
        if #(alertsHistory) > 0 then
            dispatchMenu = true
            SetNuiFocus(true, true)
            SetNuiFocusKeepInput(true)
            SendNUIMessage({ action = "openList" })
        else
            exports.notify:display(
                { type = "error", title = "Chyba", text = "Nemáš v historii žádná hlášení!", icon = "fas fa-times", length = 4000 }
            )
        end
    end
)

function hasBlockedWeapon()
    local _, currentWeapon = GetCurrentPedWeapon(PlayerPedId(), true)
    for i, weapon in each(Config.Alerts.shooting.IgnoreWeapons) do
        if currentWeapon == GetHashKey(weapon) then
            return true
        end
    end

    return false
end

function getColorLabel(colorIndex)
    for i, color in each(Config.Colors) do
        if color.Index == tonumber(colorIndex) then
            return color.Label
        end
    end
end
