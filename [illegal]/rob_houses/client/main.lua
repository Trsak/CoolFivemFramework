local isSpawned, isDead = false, false
local currentHouse = nil
local housesData = {}
local doingAction = false

RegisterNetEvent("s:statusUpdated")
AddEventHandler("s:statusUpdated", function(status)
    if status == "choosing" then
        isSpawned = false
    elseif status == "spawned" or status == "dead" then
        isDead = (status == "dead")
        if not isSpawned then
            isSpawned = true
            loadJobs()
            TriggerServerEvent("rob_houses:sync")
        end
    end
end)

RegisterNetEvent("s:jobUpdated")
AddEventHandler("s:jobUpdated", function(newJobs)
    loadJobs(newJobs)
end)

RegisterNetEvent("rob_houses:sync")
AddEventHandler("rob_houses:sync", function(data, requestedInstance)
    housesData = data
    if requestedInstance then
        local char = exports.data:getCharVar("id")
        for house, houseData in pairs(housesData) do
            if houseData.players then
                for _, player in each(houseData.players) do
                    if player == char then
                        TriggerServerEvent("instance:joinInstance", "rob_house_" .. house)
                        break
                    end
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    Citizen.Wait(500)

    local status = exports.data:getUserVar("status")

    if status == "spawned" or status == "dead" then
        if not isSpawned then
            isSpawned = true
            loadJobs()
        end
        isDead = (status == "dead")
    end
end)

Citizen.CreateThread(function()
    Citizen.Wait(500)

    while true do
        if housesData ~= nil then
            local pCoords = GetEntityCoords(PlayerPedId())
            local shouldBeDisplayingHint = false
            if not currentHouse then
                for house, data in pairs(Config.RobPlaces) do
                    local distance = #(pCoords - data.Coords.xyz)
                    if distance <= 1.2 then
                        shouldBeDisplayingHint = true
                        if not showingHouseHint and not doingAction then
                            showingHouseHint = true
                            local text = "Vstoupit"
                            if not hasWhitelistedJob() and not enterable(house) then
                                text = "Vloupat se do domu"
                            end
                            exports.key_hints:displayHint({
                                name = "rob_house",
                                key = "~INPUT_PICKUP~",
                                text = text,
                                coords = data.Coords
                            })
                        end
                        if IsControlJustReleased(0, 38) and not doingAction then
                            if not hasWhitelistedJob() and not enterable(house) then
                                enterHouse(house, true)
                            else
                                enterHouse(house, false)
                            end
                        end
                        break
                    end
                end
                if not showingHouseHint then
                    Citizen.Wait(1000)
                end
            else
                Citizen.Wait(1000)
            end
            if not shouldBeDisplayingHint and showingHouseHint then
                resetHints()
            end
        else
            Citizen.Wait(2000)
        end
        Citizen.Wait(0)
    end
end)

function enterable(house)
    if housesData[house] == nil or housesData[house].locked == nil or housesData[house].locked then
        return false
    end
    return true
end
function enterHouse(house, locked)
    if locked then
        WarMenu.CreateMenu("rob_house", "Vloupání", "Zvolte akci")
        WarMenu.OpenMenu("rob_house")

        while WarMenu.IsMenuOpened("rob_house") do
            if WarMenu.Button("Vloupat se do domu") then
                TriggerServerEvent("rob_houses:lockpick", house)
                WarMenu.CloseMenu()
            elseif WarMenu.Button("Zrušit") then
                WarMenu.CloseMenu()
            end

            WarMenu.Display()

            Citizen.Wait(1)
        end
    else
        currentHouse = house
        teleport(Config.RobPlaces[house].Residence.InsidePositions.Exit)
        createZones(house)

        TriggerServerEvent("instance:joinInstance", "rob_house_" .. house)
        TriggerServerEvent("rob_houses:joinHouse", house)
    end
end
function canBePlaceRobbed(place)
    if housesData[currentHouse] == nil then
        return true
    else
        for _, robbed in each(housesData[currentHouse].robbed) do
            if robbed == place then
                return false
            end
        end
        return true
    end
end
function searchPlace(currentPlace)
    doingAction = true
    exports.progressbar:startProgressBar({
        Duration = 4500,
        Label = "Prohledáváš..",
        CanBeDead = false,
        CanCancel = true,
        DisableControls = {
            Movement = true,
            CarMovement = true,
            Mouse = false,
            Combat = true
        },
        Animation = {
            scenario = "PROP_HUMAN_BUM_BIN"
        }
    }, function(finished)
        doingAction = false
        if finished then
            local wasRobbed = false
            for _, place in each(housesData[currentHouse].robbed) do
                if place == currentPlace then
                    wasRobbed = true
                    break
                end
            end
            if not wasRobbed then
                table.insert(housesData[currentHouse].robbed, currentPlace)
                TriggerServerEvent("rob_houses:robbedHousePlace", currentHouse, currentPlace)
            else
                exports.notify:display({
                    type = "error",
                    title = "Neúspěch",
                    text = "Tady už je prázdno!",
                    icon = "fas fa-search",
                    length = 3000
                })
            end
        end
    end)
end
function leaveHouse()
    teleport(Config.RobPlaces[currentHouse].Coords)
    deleteZones(currentHouse)
    TriggerServerEvent("instance:quitInstance")
    TriggerServerEvent("rob_houses:leaveHouse", currentHouse)
    Citizen.Wait(1000)
    currentHouse = nil
end
function hasWhitelistedJob()
    for job, data in each(jobs) do
        if Config.WhitelistedJobTypes[data.Type] then
            return true
        end
    end

    return false
end
function resetHints()
    exports.key_hints:hideHint({
        ["name"] = "rob_house"
    })
    showingHouseHint = false
end
function teleport(coords)
    local playerPed = PlayerPedId()
    DoScreenFadeOut(1000)
    NetworkFadeOutEntity(playerPed, true, false)
    resetHints()
    Citizen.Wait(1000)

    FreezeEntityPosition(playerPed, true)
    SetEntityCoords(playerPed, coords.xyz)
    SetEntityHeading(playerPed, coords.w)

    while not HasCollisionLoadedAroundEntity(playerPed) do
        RequestCollisionAtCoord(coords)
        Citizen.Wait(0)
    end

    FreezeEntityPosition(playerPed, false)
    Citizen.Wait(1000)
    DoScreenFadeIn(1000)
    NetworkFadeInEntity(playerPed, true)
end

function loadJobs(Jobs)
    jobs = {}
    for _, data in pairs(Jobs ~= nil and Jobs or exports.data:getCharVar("jobs")) do
        jobs[data.job] = {
            Name = data.job,
            Type = exports.base_jobs:getJobVar(data.job, "type"),
            Grade = data.job_grade,
            Duty = data.duty
        }
    end
end

RegisterNetEvent("rob_houses:lockpick")
AddEventHandler("rob_houses:lockpick", function(house)
    doingAction = true
    local houseData = Config.RobPlaces[house]
    local playerPed = PlayerPedId()
    local playerServerId = GetPlayerServerId(PlayerId())
    SetEntityCoords(playerPed, houseData.Coords.xy, houseData.Coords.z - 0.98)
    SetEntityHeading(playerPed, houseData.Coords.w - 180 > 0 and houseData.Coords.w - 180 or houseData.Coords.w + 180)
    TriggerServerEvent("sound:playSound", "lockpick", 3.0, GetEntityCoords(playerPed), "rob_house_" .. playerServerId)

    exports.progressbar:startProgressBar({
        Duration = 7500,
        Label = "Páčíš zámek..",
        CanBeDead = false,
        CanCancel = true,
        DisableControls = {
            Movement = true,
            CarMovement = true,
            Mouse = false,
            Combat = true
        },
        Animation = {
            animDict = "mini@safe_cracking",
            anim = "idle_base"
        }
    }, function(finished)
        TriggerServerEvent("sound:stopSound", "rob_house_" .. playerServerId)
        doingAction = false
        if finished then
            TriggerServerEvent("rob_houses:unlockHouse", house)
            enterHouse(house, false)
        end
    end)
end)
RegisterNetEvent("rob_houses:searchResult")
AddEventHandler("rob_houses:searchResult", function(item, count)
    if not item then
        exports.notify:display({
            type = "error",
            title = "Neúspěch",
            text = "Nic jsi zde nenašel",
            icon = "fas fa-search",
            length = 3000
        })
    else
        local itemData = exports.inventory:getItem(item)
        exports.notify:display({
            type = "success",
            title = "Úspěch",
            text = "Našel jsi " .. count .. "x " .. itemData.label,
            icon = "fas fa-search",
            length = 3000
        })
    end
end)
RegisterNetEvent("rob_houses:error")
AddEventHandler("rob_houses:error", function(errorMessage)
    if errorMessage == "weightExceeded" then
        errorMessage = "Tolik toho neuneseš!"
    elseif errorMessage == "spaceExceeded" then
        errorMessage = "Nemáš u sebe místo!"
    end

    exports.notify:display({
        type = "error",
        title = "Chyba",
        text = errorMessage,
        icon = "fas fa-times",
        length = 3000
    })
end)

RegisterNetEvent("rob_houses:lotteryResult")
AddEventHandler("rob_houses:lotteryResult", function(winning)
    if winning == 0 then
        exports.notify:display({
            type = "error",
            title = "Tiket",
            text = "Tento tiket není výherní!",
            icon = "fas fa-dollar-sign",
            length = 3000
        })
    else
        exports.notify:display({
            type = "success",
            title = "Tiket",
            text = "Vyhrál jsi $" .. winning .. "!",
            icon = "fas fa-dollar-sign",
            length = 3000
        })
    end
end)

function createZones(house)
    for place, coords in pairs(Config.RobPlaces[house].Residence.InsidePositions) do
        if hasWhitelistedJob() and place == "Exit" then
            exports.target:AddCircleZone("rob-house-" .. place, coords.xyz, 1.0, {
                actions = {
                    action = {
                        cb = function()
                            leaveHouse()
                        end,
                        icon = "fas fa-door-open",
                        label = "Odejít"
                    }
                },
                distance = 1.0
            })
            break
        else
            exports.target:AddCircleZone("rob-house-" .. place, coords.xyz, 1.0, {
                actions = {
                    action = {
                        cb = function(data)
                            if data.Place == "Exit" then
                                leaveHouse()
                            else
                                searchPlace(data.Place)
                            end
                        end,
                        cbData = {
                            Place = place
                        },
                        icon = place == "Exit" and "fas fa-door-open" or "fas fa-search",
                        label = place == "Exit" and "Odejít" or "Prohledat"
                    }
                },
                distance = 1.0
            })
        end
    end
end

function deleteZones(house)
    for place, _ in pairs(Config.RobPlaces[house].Residence.InsidePositions) do
        exports.target:RemoveZone("rob-house-" .. place)
    end
end
