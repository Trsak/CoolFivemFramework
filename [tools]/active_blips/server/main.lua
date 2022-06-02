local activeAdmin = {}
local customBlips = {}
local jobPlayerList = {}
local _jobPlayerList = {}
local currentPlayers = nil

local floatingPlayers = {}
local flyingPlayers = {}
local flashBlips = {}

Citizen.CreateThread(function()
    while true do
        updateJobBlips()
        Citizen.Wait(Config.newIncomersDelay)
    end
end)

-- only jobs refresh [NOT AN ADMIN]
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.refreshTime)
        if currentPlayers then
            refresh()
        end
    end
end)

-- admin refresh
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.refreshTime)
        if currentPlayers then
            refreshAdmin()
        end
    end
end)

-- job shit + custom blips
function updateJobBlips()
    currentPlayers = exports.data:getUsersBlipData()
    local _blips = {}
    for _, userData in pairs(currentPlayers) do
        if GetPlayerName(userData.source) then
            userData.type = "foot"
            local priority = 1
            if userData.ped and DoesEntityExist(userData.ped) then
                userData.entity = userData.ped
                if userData.vehicle and DoesEntityExist(userData.vehicle) and GetPedInVehicleSeat(userData.vehicle, -1) == userData.ped then
                    userData.type = GetVehicleType(userData.vehicle)
                    userData.entity = userData.vehicle
                    local vehModel = tostring(GetEntityModel(userData.vehicle))
                    if Config.specificVehicle[vehModel] then
                        userData.type = Config.specificVehicle[vehModel]
                    end

                    priority = 2
                end

                userData.entityNetId = NetworkGetNetworkIdFromEntity(userData.entity)
            end

            if userData.job and Config.jobSettings[userData.job] and Config.jobSettings[userData.job].specificallySee then
                userData.blipData = {
                    coords = (DoesEntityExist(userData.entity) and GetEntityCoords(userData.entity) or { x = 0, y = 0, z = 0}),
                    sprite = Config.defaultBlipSettings.sprite[userData.type],
                    display = (not Config.jobSettings[userData.job].blipSettings.display and Config.defaultBlipSettings.display or Config.jobSettings[userData.job].blipSettings.display),
                    scale = (not Config.jobSettings[userData.job].blipSettings.scale and Config.defaultBlipSettings.scale or Config.jobSettings[userData.job].blipSettings.scale),
                    colour = Config.defaultBlipSettings.colour,
                    isShortRange = (not Config.jobSettings[userData.job].blipSettings.isShortRange and Config.defaultBlipSettings.isShortRange or Config.jobSettings[userData.job].blipSettings.isShortRange),
                    text = (userData.customtag and userData.customtag or string.upper(userData.job)),
                    category = (not Config.jobSettings[userData.job].blipSettings.category and Config.defaultBlipSettings.category or Config.jobSettings[userData.job].blipSettings.category),
                    heading = (DoesEntityExist(userData.entity) and math.ceil(GetEntityHeading(userData.entity)) or 0.0),
                    priority = priority
                }

                if Config.jobSettings[userData.job].blipSettings.sprite and Config.jobSettings[userData.job].blipSettings.sprite[userData.type] then
                    userData.blipData.sprite = Config.jobSettings[userData.job].blipSettings.sprite[userData.type].default
                    if Config.jobSettings[userData.job].blipSettings.sprite[userData.type].grade then
                        local customSprite = getHighestGrade(userData.type, userData.job, userData.grade, Config.jobSettings[userData.job].blipSettings.sprite[userData.type].grade)
                        if customSprite then
                            userData.blipData.sprite = Config.jobSettings[userData.job].blipSettings.sprite[userData.type].grade[tostring(customSprite)]
                        end
                    end
                end

                if Config.jobSettings[userData.job].blipSettings.colour then
                    userData.blipData.colour = Config.jobSettings[userData.job].blipSettings.colour.default
                    if Config.jobSettings[userData.job].blipSettings.colour.grade then
                        local gradeColour = getHighestGrade(userData.type, userData.job, userData.grade, Config.jobSettings[userData.job].blipSettings.colour.grade)
                        if gradeColour then
                            userData.blipData.colour = Config.jobSettings[userData.job].blipSettings.colour.grade[tostring(gradeColour)]
                        end
                    end
                end

                -- make circle smaller, but keep others bigger
                if userData.type == 'foot' and userData.blipData.sprite == 57 then
                    userData.blipData.scale = userData.blipData.scale - 0.3
                end

                _blips[userData.identifier] = userData
            end

            if Config.floatingBlip[userData.type] then
                Citizen.Wait(1)
                if DoesEntityExist(userData.vehicle) then
                    floatingPlayers[userData.identifier] = {
                        entity = userData.vehicle,
                        entityNetId = NetworkGetNetworkIdFromEntity(userData.vehicle),
                        job = userData.job,
                        type = userData.type,
                        client = userData.source
                    }
                end
                if not _blips[userData.identifier] then
                    _blips[userData.identifier] = userData
                end
            else
                if floatingPlayers[userData.identifier] then
                    floatingPlayers[userData.identifier] = nil
                end
            end
            Citizen.Wait(1)
            if Config.flyingBlip[userData.type] then
                Citizen.Wait(1)
                if DoesEntityExist(userData.vehicle) then
                    flyingPlayers[userData.identifier] = {
                        entity = userData.vehicle,
                        entityNetId = NetworkGetNetworkIdFromEntity(userData.vehicle),
                        job = userData.job,
                        type = userData.type,
                        client = userData.source
                    }
                end
                if not _blips[userData.identifier] then
                    _blips[userData.identifier] = userData
                end
            else
                if flyingPlayers[userData.identifier] then
                    flyingPlayers[userData.identifier] = nil
                end
            end

            if userData.job and Config.jobSettings[userData.job] and userData.job and Config.jobSettings[userData.job].seeAir then
                if not _blips[userData.identifier] then
                    _blips[userData.identifier] = userData
                end
            end

            if not _blips[userData.identifier] and not activeAdmin[userData.source] then
                TriggerClientEvent("active_blips:refresh", userData.source, {})
            end
        end

        Citizen.Wait(2)
    end

    jobPlayerList = _blips
end

RegisterNetEvent("base_jobs:updateDuty")
AddEventHandler("base_jobs:updateDuty", function(job, state)
    local client = source

    if not state and Config.jobSettings[job] then
        TriggerClientEvent("active_blips:refresh", client, {})
    end
end)

function refresh()
    _jobPlayerList = jobPlayerList
    for k, userData in pairs(_jobPlayerList) do
        if _jobPlayerList[k] and not activeAdmin[userData.source] then
            local _blips = {}
            if userData.job and Config.jobSettings[userData.job] and Config.jobSettings[userData.job].specificallySee then
                for _, blipUserData in pairs(_jobPlayerList) do
                    -- general properties
                    if blipUserData.source ~= userData.source and blipUserData.blipData and GetPlayerName(blipUserData.source) and (blipUserData.job and not blipUserData.secret and  Config.jobSettings[userData.job] and Config.jobSettings[userData.job].specificallySee and Config.jobSettings[userData.job].specificallySee[blipUserData.job]) then
                        if blipUserData.entity and DoesEntityExist(blipUserData.entity) then
                            blipUserData.blipData.coords = GetEntityCoords(blipUserData.entity)
                            blipUserData.blipData.heading = math.ceil(GetEntityHeading(blipUserData.entity))
                            blipUserData.blipData.text = (blipUserData.customtag and blipUserData.customtag or string.upper(blipUserData.job))
                        end

                        if flashBlips[blipUserData.identifier] then
                            blipUserData.blipData.flash = true
                            flashBlips[blipUserData.identifier] = nil
                        end

                        _blips[blipUserData.identifier] = {
                            entityNetId = blipUserData.entityNetId,
                            blipData = blipUserData.blipData
                        }
                    end
                end
            end

            insertCustomBlips(userData.source, userData.job, userData.grade, _blips)
            if floatingPlayers[userData.identifier] then
                insertFloatingBlips(userData.source, userData.job, _blips)
            end

            if flyingPlayers[userData.identifier] or (userData.job and Config.jobSettings[userData.job] and Config.jobSettings[userData.job].seeAir) then
                insertFlyingBlips(userData.source, userData.job, _blips)
            end

            Citizen.Wait(1)

            TriggerLatentClientEvent("active_blips:refresh", userData.source, 0, _blips)
        end
    end
end
function refreshAdmin()
    for k, _ in pairs(activeAdmin) do
        if GetPlayerName(k) and activeAdmin[k] then
            local _blips = {}
            for _, blipUserData in pairs(currentPlayers) do
                local blipUserClient = blipUserData.source
                if GetPlayerName(blipUserClient) then
                    if not jobPlayerList[blipUserData.identifier] and not blipUserData.blipData then
                        local priority = 1
                        blipUserData.type = "foot"
                        if blipUserData.ped and DoesEntityExist(blipUserData.ped) then
                            blipUserData.entity = blipUserData.ped
                            if blipUserData.vehicle and DoesEntityExist(blipUserData.vehicle) and GetPedInVehicleSeat(blipUserData.vehicle, -1) == blipUserData.ped then
                                blipUserData.type = GetVehicleType(blipUserData.vehicle)
                                blipUserData.entity = blipUserData.vehicle
                                local vehModel = tostring(GetEntityModel(blipUserData.vehicle))
                                if Config.specificVehicle[vehModel] then
                                    blipUserData.type = Config.specificVehicle[vehModel]
                                end

                                priority = 2
                            end
                        end

                        blipUserData.blipData = {
                            sprite = Config.defaultBlipSettings.sprite[blipUserData.type],
                            display = Config.defaultBlipSettings.display,
                            scale = Config.defaultBlipSettings.scale,
                            colour = Config.defaultBlipSettings.colour,
                            isShortRange = Config.defaultBlipSettings.isShortRange,
                            category = Config.defaultBlipSettings.category,
                            priority = priority
                        }
                    end
                    if blipUserData.blipData then
                        if blipUserData.blipData.scale >= Config.defaultBlipSettings.scale then
                            blipUserData.blipData.scale = (blipUserData.type == "foot" and Config.defaultBlipSettings.scale - 0.1 or Config.defaultBlipSettings.scale)
                        end
                        blipUserData.blipData.text = blipUserData.nickname .. " [ " .. blipUserData.source .. " ]"

                        local _entityNetId = nil
                        if blipUserData.entity and DoesEntityExist(blipUserData.entity) then
                            blipUserData.blipData.coords = GetEntityCoords(blipUserData.entity)
                            blipUserData.blipData.heading = math.ceil(GetEntityHeading(blipUserData.entity))
                            _entityNetId = NetworkGetNetworkIdFromEntity(blipUserData.entity)
                        end

                        _blips[blipUserData.identifier] = {
                            entityNetId = _entityNetId,
                            blipData = blipUserData.blipData
                        }
                    end
                end
            end
            TriggerLatentClientEvent("active_blips:refresh", k, 1000000, _blips)
            Citizen.Wait(1)
        else
            activeAdmin[k] = nil
        end
    end
end
function insertCustomBlips(client, clientJob, clientGrade, insertTo)
    for blipId, data in pairs(customBlips) do
        if isClientAllowed(client, blipId, clientJob, clientGrade) then
            update(blipId)

            insertTo[blipId] = {
                entityNetId = data.entityNetId,
                blipData = data.blipData,
                fixedCoords = data.fixedCoords
            }
        end
    end
end
function insertFloatingBlips(client, clientJob, insertTo)
    for k, v in pairs(floatingPlayers) do
        if client ~= v.client and v.entity and DoesEntityExist(v.entity) then
            if not clientJob or (clientJob and not v.job or (v.job and Config.jobSettings[clientJob] and Config.jobSettings[clientJob].specificallySee and not Config.jobSettings[clientJob].specificallySee[v.job])) then
                local _blipData = table.table_copy(Config.defaultFloatingBlipSettings)
                _blipData.coords = GetEntityCoords(v.entity)
                _blipData.heading = math.ceil(GetEntityHeading(v.entity))
                insertTo["FLOAT_" .. v.entityNetId] = {
                    entityNetId = v.entityNetId,
                    blipData = _blipData
                }
            end
        else
            floatingPlayers[k] = nil
        end

        Citizen.Wait(0)
    end
end
function table.table_copy(t)
    local t2 = {}
    for k,v in pairs(t) do
        t2[k] = v
    end
    return t2
end
function insertFlyingBlips(client, clientJob, insertTo)
    for k, v in pairs(flyingPlayers) do
        if client ~= v.client and v.entity and DoesEntityExist(v.entity) then
            if not clientJob or (clientJob and Config.jobSettings[clientJob] and Config.jobSettings[clientJob].seeAir) or (clientJob and not v.job or (v.job and Config.jobSettings[clientJob] and Config.jobSettings[clientJob].specificallySee and not Config.jobSettings[clientJob].specificallySee[v.job])) then
                local blipData = table.table_copy(Config.defaultFlyingBlipSettings)
                blipData.text = (v.type == "heli" and "HELIKOPTÉRA" or "LETADLO")
                blipData.sprite = (v.type == "heli" and 64 or 584)
                blipData.coords = GetEntityCoords(v.entity)
                blipData.heading = math.ceil(GetEntityHeading(v.entity))
                insertTo["FLY_" .. v.entityNetId] = {
                    entityNetId = v.entityNetId,
                    blipData = blipData
                }
            end
        else
            floatingPlayers[k] = nil
        end

        Citizen.Wait(0)
    end
end
function remove(blipId)
    if not customBlips[blipId] then
        if not customBlips["custom_" .. blipId] then
            return "doesntExist"
        end

        blipId = "custom_" .. blipId
    end

    customBlips[blipId] = nil

    return "done"
end
function add(entityNetId, blipData, customData)
    if customBlips["custom_" .. entityNetId] then
        return "exists"
    end

    if not blipData then
        return "missingBlipData"
    end

    if not blipData.coords
        or not blipData.sprite
        or not blipData.display
        or not blipData.scale
        or not blipData.colour
        or not blipData.isShortRange
        or not blipData.text then
        return "missingSpecificBlipData"
    end

    customBlips["custom_" .. entityNetId] = {
        blipData = blipData,
        entityNetId = entityNetId,
        visibleFor = {
            job = customData.job,
            type = customData.type,
            grade = customData.grade,
            everyone = customData.everyone
        },
        fixedCoords = customData.fixedCoords
    }

    return "done"
end
function isClientAllowed(client, blipId, clientJob, clientGrade)
    if not customBlips[blipId] or not GetPlayerName(client) then
        return false
    end

    local blip = customBlips[blipId]
    if ((not blip.visibleFor.job or (blip.visibleFor.job and clientJob and clientJob == blip.visibleFor.job))
        and (not blip.visibleFor.grade or (blip.visibleFor.grade and clientGrade and clientGrade >= blip.visibleFor.grade))
        and (not blip.visibleFor.type or (blip.visibleFor.type and exports.base_jobs:hasUserJobType(client, blip.visibleFor.type, true) )))
        or blip.visibleFor.everyone then
        return true
    end

    return false
end
function update(blipId)
    if not customBlips[blipId] then
        return "doesntExist"
    end

    if not customBlips[blipId].fixedCoords then
        local entity = NetworkGetEntityFromNetworkId(customBlips[blipId].entityNetId)

        if DoesEntityExist(entity) then
            customBlips[blipId].blipData.coords = GetEntityCoords(entity)
            customBlips[blipId].blipData.heading = math.ceil(GetEntityHeading(entity))
        else
            remove(blipId)
        end
    end
end

RegisterCommand("agent007",
    function(source, args)
        local client = source
        local clientJob, clientGrade = exports.base_jobs:getUserActiveJob(client)
        if clientJob and Config.jobSettings[clientJob] and (Config.jobSettings[clientJob].secretAvailable and clientGrade >= Config.jobSettings[clientJob].secretAvailable.grade) or (exports.data:getUserVar(client, "admin") >= 2) then

            local _bossData = exports.data:getCharVar(client, "bossdata")
            if not _bossData then
                _bossData = {}
            end

            if not _bossData[clientJob] then
                _bossData[clientJob] = {}
            end

            if _bossData[clientJob].secret == nil then _bossData[clientJob].secret = false end

            _bossData[clientJob].secret = not _bossData[clientJob].secret

            exports.data:updateCharVar(client, "bossdata", _bossData)

            TriggerClientEvent(
                "notify:display",
                client,
                {
                    type = "info",
                    title = "MI6 Confirmation",
                    text = (_bossData[clientJob].secret and "Aktivace pláště" or "Deaktivace pláště"),
                    icon = "fas fa-user",
                    length = 3000
                }
            )
        else
            TriggerClientEvent(
                "notify:display",
                client,
                {
                    type = "error",
                    title = "MI6 Confirmation",
                    text = "Aktivace neúspěšná.",
                    icon = "fas fa-user",
                    length = 3000
                }
            )
        end

    end
)
RegisterCommand("tagme",
    function(source, args)
        local client = source
        local clientJob, clientGrade = exports.base_jobs:getUserActiveJob(client)
        if clientJob and Config.jobSettings[clientJob] and Config.jobSettings[clientJob].tagAvailable and clientGrade >= Config.jobSettings[clientJob].tagAvailable.grade then
            if not args then
                return
            end

            local newTag = table.concat(args, " ")

            if string.len(newTag) < 3 then
                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "error",
                        title = clientJob,
                        text = "Zadej delší TAG! (min. 3 znaky)",
                        icon = "fas fa-tags",
                        length = 3000
                    }
                )
                return
            end

            local _bossData = exports.data:getCharVar(client, "bossdata")
            if not _bossData then
                _bossData = {}
            end

            if not _bossData[clientJob] then
                _bossData[clientJob] = {}
            end


            _bossData[clientJob].customtag = newTag

            exports.data:updateCharVar(client, "bossdata", _bossData)

            TriggerClientEvent(
                "notify:display",
                client,
                {
                    type = "info",
                    title = clientJob,
                    text = "Nyní budete na mapě viděn jako: " .. newTag,
                    icon = "fas fa-tags",
                    length = 3000
                }
            )
        else
            TriggerClientEvent(
                "notify:display",
                client,
                {
                    type = "error",
                    title = clientJob,
                    text = "Na TAG nemáte právo",
                    icon = "fas fa-tags",
                    length = 3000
                }
            )
        end
    end
)

RegisterCommand("adminblips",
    function(source, args)
        local client = source
        if exports.data:getUserVar(client, "admin") >= 2 then
            if activeAdmin[client] == nil then activeAdmin[client] = false end

            activeAdmin[client] = not activeAdmin[client]

            TriggerClientEvent("active_blips:refresh", client, {})

            TriggerClientEvent(
                "notify:display",
                client,
                {
                    type = "info",
                    title = "ADMIN BLIPY",
                    text = (activeAdmin[client] and "Zapnul" or "Vypnul") .. " sis ADMIN BLIPY",
                    icon = "fas fa-user",
                    length = 3000
                }
            )

            exports.logs:sendToDiscord(
                {
                    channel = "admin-commands",
                    title = "ADMIN BLIPY",
                    description = (activeAdmin[client] and "Zapnul" or "Vypnul") .. " admin blipy",
                    color = "9109504"
                },
                client
            )
        end
    end
)

function getHighestGrade(type, job, grade, inarray)
    local highest, found = 1, false
    if Config.jobSettings[job] and Config.jobSettings[job].blipSettings and inarray then
        for k, v in pairs(inarray) do
            local compGrade = tonumber(k)
            if grade >= compGrade and highest < compGrade then
                highest = compGrade
                found = true
            end
        end
    end

    if not found then
        return nil
    end

    return highest
end

function activateFlash(client)
    if GetPlayerName(client) then
        local identifier = exports.data:getUserVar(client, "identifier")
        if identifier and not flashBlips[identifier] then
            flashBlips[identifier] = client
        end
    end
end