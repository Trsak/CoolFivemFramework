local isSpawned, isDead = false, false

local isFueling, fuelSynced = false, false
local currentCost, currentFuel = 0.0, 0.0
local blip, blips = nil, {}
local showAllBlips = false

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned = false
        elseif status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
            isFueling = (isDead and false or isFueling)
        end
    end
)

Citizen.CreateThread(
    function()
        Citizen.Wait(500)

        createTrackedModels()

        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            showAllBlips = exports.settings:getSettingValue("gasBlips")
            isSpawned = true
            isDead = (status == "dead")

            if showAllBlips then
                createBlips()
            elseif not blip then
                createBlip()
            end
        end

        while true do
            Citizen.Wait(0)
            if isSpawned and not isDead then
                pPed = PlayerPedId()
                playerCoords = GetEntityCoords(pPed)
                if IsPedInAnyVehicle(pPed) then
                    local vehicle = GetVehiclePedIsIn(pPed)
                    if GetPedInVehicleSeat(vehicle, -1) == pPed then
                        ManageFuelUsage(vehicle)
                    end
                    Citizen.Wait(1000)
                else
                    if fuelSynced then
                        fuelSynced = false
                    end
                    if not isFueling then
                        local _, weaponHash = GetCurrentPedWeapon(pPed)
                        if weaponHash == GetHashKey("weapon_petrolcan") then
                            local vehicle = GetClosestVehicle(playerCoords, 5.0, 0, 70)
                            if vehicle ~= nil and vehicle ~= 0 then
                                local plcBone = GetEntityBoneIndexByName(vehicle, "engine")
                                local motorCoords = GetWorldPositionOfEntityBone(vehicle, plcBone)
                                if #(playerCoords - motorCoords) <= 3.0 then
                                    if IsControlJustReleased(0, 38) then
                                        startFromJerryCan()
                                    end
                                end
                            end
                        else
                            Citizen.Wait(1000)
                        end
                    else
                        Citizen.Wait(1000)
                    end
                end
                if not showAllBlips then
                    if not DoesBlipExist(blip) then
                        createBlip()
                    end
                    local distance, nearest = 100000.0, nil
                    for i, coords in each(Config.GasStations) do
                        local dst = #(playerCoords - coords)

                        if dst < distance then
                            distance, nearest = dst, i
                        end
                    end
                    SetBlipCoords(blip, Config.GasStations[nearest])
                end
            else
                Citizen.Wait(1000)
            end
        end
    end
)

function ManageFuelUsage(vehicle)
    if not Entity(vehicle).state.fuelLevel then
        SetFuel(vehicle, math.random(200, 800) / 10)
    elseif not fuelSynced then
        SetFuel(vehicle, GetFuel(vehicle))

        fuelSynced = true
    end

    if IsVehicleEngineOn(vehicle) then
        SetFuel(
            vehicle,
            GetVehicleFuelLevel(vehicle) -
                Config.FuelUsage[Round(GetVehicleCurrentRpm(vehicle))] *
                    (Config.Classes[GetVehicleClass(vehicle)] or 1.0) /
                    10
        )
    end
end

function startFuel(closestStation)
    if not IsPedInAnyVehicle(pPed, false) then
        local vehicle = GetClosestVehicle(playerCoords, 3.0, 0, 70)
        if vehicle == nil or vehicle == 0 then
            vehicle = GetClosestVehicle(playerCoords, 3.0, 0, 127)
        end
        if vehicle ~= nil and vehicle ~= 0 then
            if GetVehicleFuelLevel(vehicle) < 95 and GetVehicleClass(vehicle) ~= 13 then
                fuelVehicle(closestStation)
            elseif exports.inventory:getCurrentCash() <= 0 then
                exports.notify:display(
                    {
                        type = "error",
                        title = "Benzínová pumpa",
                        text = "Nemáte dostatek peněz",
                        icon = "fas fa-car",
                        length = 3000
                    }
                )
            else
                exports.notify:display(
                    {
                        type = "error",
                        title = "Benzínová pumpa",
                        text = "Vozidlo má plnou nádrž",
                        icon = "fas fa-car",
                        length = 3000
                    }
                )
            end
        else
            exports.notify:display(
                {
                    type = "error",
                    title = "Benzínová pumpa",
                    text = "Jaké vozidlo chcete natankovat?",
                    icon = "fas fa-car",
                    length = 3000
                }
            )
        end
    else
        exports.notify:display(
            {
                type = "error",
                title = "Benzínová pumpa",
                text = "Musíte vystoupit!",
                icon = "fas fa-car",
                length = 3000
            }
        )
    end
end

function startNpcFuel(closestStation)
    if IsPedInAnyVehicle(pPed, false) then
        local pVeh = GetVehiclePedIsIn(pPed, false)
        if GetVehicleFuelLevel(pVeh) < 95 and GetVehicleClass(pVeh) ~= 13 then
            fuelVehicleByNpc(closestStation)
        elseif exports.inventory:getCurrentCash() <= 0 then
            exports.notify:display(
                {
                    type = "error",
                    title = "Benzínová pumpa",
                    text = "Nemáte dostatek peněz",
                    icon = "fas fa-car",
                    length = 3000
                }
            )
        else
            exports.notify:display(
                {
                    type = "error",
                    title = "Benzínová pumpa",
                    text = "Vozidlo má plnou nádrž",
                    icon = "fas fa-car",
                    length = 3000
                }
            )
        end
    else
        exports.notify:display(
            {
                type = "error",
                title = "Benzínová pumpa",
                text = "Pro toto musíte být ve vozidle",
                icon = "fas fa-car",
                length = 3000
            }
        )
    end
end

function startFromJerryCan()
    if not IsPedInAnyVehicle(pPed, false) then
        local pVeh = GetClosestVehicle(playerCoords, 5.0, 0, 70)
        if GetVehicleFuelLevel(pVeh) < 95 and GetVehicleClass(pVeh) ~= 13 then
            if GetAmmoInPedWeapon(pPed, GetHashKey("weapon_petrolcan")) > 0 then
                fuelFromJerryCan()
            else
                exports.notify:display(
                    {
                        type = "error",
                        title = "Kanystr",
                        text = "Kanystr je prázdný",
                        icon = "fas fa-car",
                        length = 3000
                    }
                )
            end
        else
            exports.notify:display(
                {
                    type = "error",
                    title = "Kanystr",
                    text = "Vozidlo má plnou nádrž",
                    icon = "fas fa-car",
                    length = 3000
                }
            )
        end
    else
        exports.notify:display(
            {
                type = "error",
                title = "Kanystr",
                text = "Pro toto musíte být ve vozidle",
                icon = "fas fa-car",
                length = 3000
            }
        )
    end
end

function fuelVehicle(closestStation)
    local stationCoords = GetEntityCoords(closestStation.entity)
    local vehicle = GetClosestVehicle(playerCoords, 7.0, 0, 70)
    if vehicle == nil or vehicle == 0 then
        vehicle = GetClosestVehicle(playerCoords, 7.0, 0, 127)
    end
    isFueling = true

    TaskTurnPedToFaceEntity(pPed, vehicle, 1000)
    Citizen.Wait(1000)
    SetCurrentPedWeapon(pPed, -1569615261, true)
    LoadAnimDict("timetable@gardener@filling_can")
    TaskPlayAnim(pPed, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 2.0, 8.0, -1, 50, 0, 0, 0, 0)

    Citizen.CreateThread(
        function()
            while isFueling do
                for _, controlIndex in pairs(Config.DisableKeys) do
                    DisableControlAction(0, controlIndex)
                end
                if
                    IsControlJustReleased(0, 38) or DoesEntityExist(GetPedInVehicleSeat(vehicle, -1)) or
                        GetEntityHealth(closestStation.entity) <= 0
                 then
                    isFueling = false
                end
                Citizen.Wait(0)
            end
        end
    )

    currentFuel = GetVehicleFuelLevel(vehicle)
    while isFueling do
        if not IsEntityPlayingAnim(pPed, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 3) then
            TaskPlayAnim(pPed, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 2.0, 8.0, -1, 50, 0, 0, 0, 0)
        end
        if closestStation.entity then
            exports.key_hints:displayHint(
                {
                    name = "gas_station",
                    key = "~INPUT_PICKUP~",
                    text = "Ukončit " .. (Round(currentFuel)) .. "%" .. "(~r~$" .. math.ceil(currentCost) .. "~w~)",
                    coords = stationCoords
                }
            )
        end

        local oldFuel = (Entity(vehicle).state.fuelLevel == nil and 0 or Entity(vehicle).state.fuelLevel)
        local fuelToAdd = math.random(10, 20) / 10.0
        local extraCost = fuelToAdd / 1.5 * Config.CostMultiplier

        if not DoesEntityExist(closestStation.entity) or #(playerCoords - stationCoords) >= 5.0 then
            isFueling = false
        else
            currentFuel = oldFuel + fuelToAdd
        end

        if currentFuel > 100.0 then
            currentFuel = 100.0
            isFueling = false
        end

        currentCost = currentCost + extraCost

        if exports.inventory:getCurrentCash() >= currentCost then
            SetFuel(vehicle, currentFuel)
            TriggerServerEvent("gas_stations:payFuel", extraCost)
        else
            isFueling = false
        end

        Citizen.Wait(500)
    end
    RemoveAnimDict("timetable@gardener@filling_can")

    currentCost, isFueling = 0.0, false

    ClearPedTasks(pPed)
    exports.key_hints:hideHint({name = "gas_station"})
    RemoveAnimDict("timetable@gardener@filling_can")
    exports.notify:display(
        {
            type = "info",
            title = "Benzínová pumpa",
            text = "Díky za nákup!",
            icon = "fas fa-car",
            length = 3000
        }
    )
end

function fuelVehicleByNpc(closestStation)
    local stationCoords = GetEntityCoords(closestStation.entity)
    local vehicle = GetVehiclePedIsIn(pPed, false)
    local model = GetHashKey("a_m_m_hillbilly_01")
    local npcCoords = GetOffsetFromEntityInWorldCoords(pPed, 0.0, -4.5, 0.0)
    ExecuteCommand("engine")
    FreezeEntityPosition(vehicle, true)
    isFueling = true

    loadModel(model)
    LoadAnimDict("mp_character_creation@lineup@male_a")
    local nPed =
        CreatePed(
        5,
        model,
        coords(stationCoords.x, npcCoords.x),
        coords(stationCoords.y, npcCoords.y),
        coords(stationCoords.z, npcCoords.z),
        GetEntityHeading(pPed),
        true,
        false
    )
    SetModelAsNoLongerNeeded(model)

    Citizen.Wait(100)
    TaskPlayAnim(nPed, "mp_character_creation@lineup@male_a", "intro", 1.0, 1.0, 5900, 0, 1, 0, 0, 0)
    Citizen.Wait(3000)
    LoadAnimDict("mp_character_creation@customise@male_a")
    Citizen.Wait(100)
    TaskPlayAnim(nPed, "mp_character_creation@customise@male_a", "loop", 1.0, 1.0, -1, 0, 1, 0, 0, 0)
    TaskTurnPedToFaceEntity(nPed, vehicle, 2000)
    Citizen.Wait(2000)
    SetCurrentPedWeapon(pPed, -1569615261, true)
    LoadAnimDict("timetable@gardener@filling_can")
    TaskPlayAnim(nPed, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 2.0, 8.0, -1, 50, 0, 0, 0, 0)

    Citizen.CreateThread(
        function()
            while isFueling do
                for _, controlIndex in pairs(Config.DisableKeys) do
                    DisableControlAction(0, controlIndex)
                end
                if
                    IsControlJustReleased(0, 38) or not DoesEntityExist(GetPedInVehicleSeat(vehicle, -1)) or
                        GetEntityHealth(closestStation.entity) <= 0
                 then
                    isFueling = false
                end
                Citizen.Wait(0)
            end
        end
    )

    currentFuel = GetVehicleFuelLevel(vehicle)
    while isFueling do
        if not IsEntityPlayingAnim(nPed, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 3) then
            TaskPlayAnim(nPed, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 2.0, 8.0, -1, 50, 0, 0, 0, 0)
        end
        if closestStation.entity then
            exports.key_hints:displayHint(
                {
                    name = "gas_station",
                    key = "~INPUT_PICKUP~",
                    text = "Ukončit " .. Round(currentFuel) .. "%" .. "(~r~$" .. math.floor(currentCost) .. "~w~)",
                    coords = stationCoords
                }
            )
        end

        local oldFuel = Entity(vehicle).state.fuelLevel
        local fuelToAdd = math.random(10, 20) / 10.0
        local extraCost = fuelToAdd / 1.5 * Config.CostMultiplier

        if not DoesEntityExist(closestStation.entity) or #(playerCoords - stationCoords) >= 10.0 then
            isFueling = false
        else
            currentFuel = oldFuel + fuelToAdd
        end

        if currentFuel > 100.0 then
            currentFuel = 100.0
            isFueling = false
        end

        currentCost = currentCost + extraCost

        if exports.inventory:getCurrentCash() >= currentCost then
            SetFuel(vehicle, currentFuel)
            TriggerServerEvent("gas_stations:payFuel", extraCost)
        else
            isFueling = false
        end

        Citizen.Wait(500)
    end
    RemoveAnimDict("mp_character_creation@lineup@male_a")
    RemoveAnimDict("mp_character_creation@customise@male_a")
    RemoveAnimDict("timetable@gardener@filling_can")

    currentCost, isFueling = 0.0, false

    ClearPedTasks(nPed)
    DeleteEntity(nPed)
    FreezeEntityPosition(vehicle, false)
    ExecuteCommand("engine")
    exports.key_hints:hideHint({name = "gas_station"})
    RemoveAnimDict("timetable@gardener@filling_can")
    exports.notify:display(
        {
            type = "info",
            title = "Benzínová pumpa",
            text = "Díky za nákup! $2 pro obsluhu navíc",
            icon = "fas fa-car",
            length = 3000
        }
    )
    TriggerServerEvent("gas_stations:payFuel", 2)
end

function fuelFromJerryCan()
    local vehicle = GetClosestVehicle(playerCoords, 5.0, 0, 70)
    local vehCoords = GetEntityCoords(vehicle)
    isFueling = true

    TaskTurnPedToFaceEntity(pPed, vehicle, 1000)
    Citizen.Wait(1000)
    LoadAnimDict("timetable@gardener@filling_can")
    TaskPlayAnim(pPed, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 2.0, 8.0, -1, 50, 0, 0, 0, 0)

    Citizen.CreateThread(
        function()
            while isFueling do
                for _, controlIndex in pairs(Config.DisableKeys) do
                    DisableControlAction(0, controlIndex)
                end
                if
                    IsControlJustReleased(0, 38) or DoesEntityExist(GetPedInVehicleSeat(vehicle, -1)) or
                        GetEntityHealth(vehicle) <= 0
                 then
                    isFueling = false
                end
                Citizen.Wait(0)
            end
        end
    )
    canisterFuel = GetAmmoInPedWeapon(pPed, GetHashKey("weapon_petrolcan"))
    currentFuel = GetVehicleFuelLevel(vehicle)
    while isFueling do
        if not IsEntityPlayingAnim(pPed, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 3) then
            TaskPlayAnim(pPed, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 2.0, 8.0, -1, 50, 0, 0, 0, 0)
        end
        if vehicle then
            exports.key_hints:displayHint(
                {
                    name = "gas_station",
                    key = "~INPUT_PICKUP~",
                    text = "Ukončit " .. Round(currentFuel) .. "%",
                    coords = vehCoords
                }
            )
        end

        local oldFuel = Entity(vehicle).state.fuelLevel
        local fuelToAdd = math.random(10, 20) / 10.0

        if not DoesEntityExist(vehicle) or #(playerCoords - vehCoords) >= 5.0 then
            isFueling = false
        else
            canisterFuel = canisterFuel - fuelToAdd * 200
            currentFuel = oldFuel + fuelToAdd
        end

        if currentFuel > 100.0 then
            currentFuel = 100.0
            isFueling = false
        end

        if canisterFuel > 0 then
            SetFuel(vehicle, currentFuel)
        else
            isFueling = false
            canisterFuel = 0
        end

        Citizen.Wait(500)
    end
    RemoveAnimDict("timetable@gardener@filling_can")

    isFueling = false
    TriggerServerEvent("inventory:setWeaponAmmo", "weapon_petrolcan", Round(canisterFuel))

    ClearPedTasks(pPed)
    exports.key_hints:hideHint({name = "gas_station"})
    RemoveAnimDict("timetable@gardener@filling_can")
end

function buyCanister()
    if not IsPedInAnyVehicle(pPed) then
        if exports.inventory:getCurrentCash() >= 100.0 then
            TriggerServerEvent("gas_stations:buyJerrycan")
        else
            exports.notify:display(
                {
                    type = "error",
                    title = "Benzínová pumpa",
                    text = "Nemáte dostatek peněz!",
                    icon = "fas fa-car",
                    length = 3000
                }
            )
        end
    else
        exports.notify:display(
            {
                type = "error",
                title = "Benzínová pumpa",
                text = "Musíte si vystoupit z auta!",
                icon = "fas fa-car",
                length = 3000
            }
        )
    end
end

function GetFuel(vehicle)
    if DoesEntityExist(vehicle) then
        local fuelLevel = Entity(vehicle).state.fuelLevel

        if not fuelLevel then
            local wait = 20
            while wait > 0 do
                wait = wait - 1
                Citizen.Wait(100)
            end
            fuelLevel = Entity(vehicle).state.fuelLevel
        end

        if not fuelLevel then
            --print("Returning 100 % fuel")
            return 100.0
        end

        --print("Returning " .. fuelLevel .. " % fuel")
        return fuelLevel
    end
end

function SetFuel(vehicle, fuel)
    if DoesEntityExist(vehicle) then
        if type(fuel) == "number" and fuel >= 0.0 and fuel <= 100.0 then
            SetVehicleFuelLevel(vehicle, fuel + 0.0)
            local ent = Entity(vehicle)
            ent.state:set("fuelLevel", fuel + 0.0, true)
        end
    end
end

function resetHints()
    showingStationHint = false
    exports.key_hints:hideHint({name = "gas_station"})
    exports.key_hints:hideBottomHint({name = "gas_station_jerrycan"})
end

function createBlip()
    blip =
        createNewBlip(
        {
            coords = Config.GasStations[1],
            sprite = 361,
            display = 4,
            scale = 0.4,
            colour = 4,
            isShortRange = true,
            text = "Benzínová pumpa"
        }
    )
end

function createBlips()
    for i, coords in each(Config.GasStations) do
        local blip =
            createNewBlip(
            {
                coords = coords,
                sprite = 361,
                display = 4,
                scale = 0.4,
                colour = 4,
                isShortRange = true,
                text = "Benzínová pumpa"
            }
        )

        table.insert(blips, blip)
    end
end

function LoadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(1)
    end
end

function loadModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(1)
    end
end

function Round(num)
    local mult = 10 ^ (1 or 0)

    return math.floor(num * mult + 0.5) / mult
end

function tableLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

function coords(station, npc)
    local math = ((station + npc) / 2)
    return math
end

function createTrackedModels()
    local models = {}
    for _, model in each(Config.Targets) do
        table.insert(models, model)
    end

    exports.target:AddTargetObject(
        models,
        {
            actions = {
                selfPump = {
                    cb = function(stationData)
                        if not isFueling then
                            startFuel(stationData)
                        end
                    end,
                    icon = "fas fa-gas-pump",
                    label = "Natankovat sám"
                },
                npcPump = {
                    cb = function(stationData)
                        if not isFueling then
                            startNpcFuel(stationData)
                        end
                    end,
                    icon = "fas fa-user-circle",
                    label = "Natankovat obsluhou"
                },
                jerrycan = {
                    cb = function()
                        if not isFueling then
                            buyCanister()
                        end
                    end,
                    icon = "fas fa-oil-can",
                    label = "Zakoupit Kanystr ($100)"
                }
            },
            distance = 10.0
        }
    )
end

AddEventHandler(
    "settings:changed",
    function(setting, value)
        if setting == "gasBlips" then
            showAllBlips = value
            if not showAllBlips then
                for i, xblip in each(blips) do
                    RemoveBlip(xblip)
                end
                blips = {}
            else
                RemoveBlip(blip)
                createBlips()
            end
        end
    end
)