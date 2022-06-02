local users = {}
local charNames = {}
local playerIdentifiers = {}
local saveQue = {}

function getCachedPlayerIdentifier(playerId)
    if not playerIdentifiers[playerId] then
        playerIdentifiers[playerId] = getSteamIdentifier(playerId)
    end

    return playerIdentifiers[playerId]
end

function getSteamIdentifier(playerId)
    if GetPlayerName(playerId) then
        for _, v in pairs(GetPlayerIdentifiers(playerId)) do
            if string.find(v, "steam") then
                return v
            end
        end
    end
    return nil
end

RegisterNetEvent("data:saveChar")
AddEventHandler(
    "data:saveChar",
    function(status)
        local client = source

        for _, queData in each(saveQue) do
            if queData.target == client then
                return
            end
        end

        if not isInQue then
            table.insert(saveQue, {
                target = client,
                status = status
            })
        end
    end
)

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(333)

            if #saveQue > 0 then
                local saveCharData = table.remove(saveQue, 1)
                if saveCharData then
                    saveChar(saveCharData.target, saveCharData.status)
                end
            end
        end
    end
)

function newConnectedUser(client, data)
    if data.identifier and client then
        if users[data.identifier] then
            removeUserData(data.identifier)
            Wait(200)
        end

        data.status = "connecting"
        users[data.identifier] = data
        return true
    else
        return false
    end
end

function removeUserData(identifier)
    if identifier and users[identifier] then
        for _, playerId in each(GetPlayers()) do
            local steamId = getSteamIdentifier(playerId)
            if steamId == identifier and GetPlayerName(playerId) then
                return
            end
        end

        if users[identifier].status == "dead" and users[identifier].character then
            users[identifier].character.logoff = 1
            users[identifier].character.health = 200

            exports.logs:sendToDiscord(
                {
                    channel = "combat-log",
                    title = "Odpojil",
                    description = "Odpojil/a se, když byl mrtvý/á!",
                    color = "9509659"
                },
                users[identifier].source
            )
        elseif users[identifier].character then
            users[identifier].character.logoff = 0
        end

        if users[identifier].character then
            savePlayerPedData(identifier, users[identifier].source)
        end

        saveChar(users[identifier].source, "disconnected")
        users[identifier] = nil

        for i, queData in each(saveQue) do
            if queData.target == playerId then
                table.remove(saveQue, i)
                break
            end
        end
    end
end

function updateCharVar(client, var, att)
    local identifier = getCachedPlayerIdentifier(client)

    if identifier and users[identifier] and users[identifier].character then
        if type(users[identifier].character[var]) == "number" then
            att = tonumber(att)
        end
        --local oldatt = users[identifier].character[var]
        users[identifier].character[var] = att
        --TriggerEvent("data:charUpdated", client, users[identifier].character, var, oldatt)
        TriggerClientEvent("data:charUpdated", client, var, att)
        if var == "jobs" then
            TriggerClientEvent("s:jobUpdated", client, att)
        end
    else
        print("DEBUG: updateCharVar", client, var, att)
    end
end

function unescape(str)
    str = string.gsub(str, "<", "")
    str = string.gsub(str, ">", "")
    str = string.gsub(str, '"', "")
    str = string.gsub(str, "'", "")
    return str
end

function updateUserVar(client, var, att)
    local identifier = getCachedPlayerIdentifier(client)

    if identifier and users[identifier] then
        if var == "nickname" then
            att = unescape(att)
        end

        if type(users[identifier][var]) == "number" then
            att = tonumber(att)
        end

        users[identifier][var] = att
        --TriggerEvent("data:userUpdated", client, users[identifier], var)
        if var == "character" then
            TriggerClientEvent("data:userUpdated", client, users[identifier])
        else
            TriggerClientEvent("data:userDataUpdated", client, var, att)
        end

        if var == "status" then
            if att == 'spawned' then
                TriggerEvent('characterSpawn', client)
                TriggerClientEvent('characterSpawn', client)
            end

            TriggerClientEvent("s:statusUpdated", client, att)
        end

        if users[identifier].source > 1000 and client < 1000 then
            updateUserVar(client, "source", client)
        end
    end
end

function getUsers()
    local usersData = {}

    for key, value in pairs(users) do
        table.insert(usersData, key)
    end

    return usersData
end

function getUsersBaseData(predicate, includeCharData)
    local usersData = {}

    for identifier, userData in pairs(users) do
        if predicate == nil or predicate(userData) then
            usersData[identifier] = {
                source = userData.source,
                nickname = userData.nickname
            }
        end
    end

    return usersData
end

function countEmployees(job, type, grade, duty, dead)
    local employeeCount = 0
    local jobTypes = exports.base_jobs:getJobsTypes()

    for _, userData in each(users) do
        if (not dead and userData.status == "spawned") or (dead and (userData.status == "spawned" or userData.status == "dead")) then
            for _, jobData in each(userData.character.jobs) do
                if (not type or jobTypes[jobData.job] == type) and (not job or jobData.job == job) and
                    (not duty or jobData.duty) and (not grade or grade >= jobData.job_grade) then
                    employeeCount = employeeCount + 1
                end
            end
        end
    end

    return employeeCount
end

function getUsersBlipData()
    local usersData = {}

    for _, user in pairs(users) do
        if user.status == "spawned" or user.status == "dead" then
            local data = {
                source = user.source,
                identifier = user.identifier,
                nickname = user.nickname
            }
            if user.character then
                for _, j in pairs(user.character.jobs) do
                    if j.duty then
                        data.job = j.job
                        data.grade = j.job_grade
                        break
                    end
                end
                if user.character.bossdata and data.job and user.character.bossdata[data.job] then
                    data.customtag = user.character.bossdata[data.job].customtag
                    data.secret = user.character.bossdata[data.job].secret
                end
                data.ped = GetPlayerPed(user.source)
                if data.ped and DoesEntityExist(data.ped) then
                    data.vehicle = GetVehiclePedIsIn(data.ped)
                end
            end

            if data then
                table.insert(usersData, data)
            end
        end
    end

    return usersData
end

function getUserByIdentifier(identifier)
    return users[identifier]
end

function getUserByCharId(charId)
    local charId = tonumber(charId)

    for identifier, userData in pairs(users) do
        if userData.character and userData.character.id == charId then
            return identifier, userData
        end
    end
    return nil, nil
end

function getUser(client)
    local identifier = getCachedPlayerIdentifier(client)
    return users[identifier]
end

function getUserVar(client, var)
    if client then
        local identifier = getCachedPlayerIdentifier(client)

        if not identifier or not users[identifier] then
            return nil
        end

        return users[identifier][var]
    end

    return nil
end

function getCharVar(client, var)
    if client then
        local identifier = getCachedPlayerIdentifier(client)

        if not identifier or not users[identifier] or not users[identifier].character then
            return nil
        end

        return users[identifier].character[var]
    end
    return nil
end

function getCharNameById(charId)
    local charId = tonumber(charId)
    if not charNames[charId] then
        local result = MySQL.Sync.fetchAll('SELECT firstname, lastname FROM characters WHERE id = :charId LIMIT 1', {
            charId = charId
        })
        if not result or #result <= 0 then
            return nil
        end

        charNames[charId] = result[1].firstname .. " " .. result[1].lastname
    end

    return charNames[charId]
end

function saveChar(client, status)
    if client then
        local identifier = getCachedPlayerIdentifier(client)

        if identifier and users[identifier] and (users[identifier].status ~= "connecting" and users[identifier].status ~= "choosing") and users[identifier].character then
            exports.inventory:savePlayerInventory(identifier)
            local savingchar = users[identifier].character

            MySQL.Async.execute(
                "UPDATE characters SET firstname = :firstname, lastname = :lastname, birth = :birth, coords = :coords, bonus = :bonus, in_property= :in_property, health= :health, armour= :armour, logoff= :logoff, jobs= :jobs, needs= :needs, outfit= :outfit, tattoos= :tattoos, emotes= :emotes, skills= :skills, secret_token= :secret_token, jail= :jail, bossdata= :bossdata, bank_accounts_left= :bank_accounts_left WHERE id= :charid",
                {
                    firstname = savingchar.firstname,
                    lastname = savingchar.lastname,
                    birth = savingchar.birth,
                    coords = json.encode(
                        {
                            x = savingchar.coords.x,
                            y = savingchar.coords.y,
                            z = savingchar.coords.z,
                            w = savingchar.coords.heading or savingchar.coords.w
                        }
                    ),
                    in_property = json.encode(savingchar.in_property),
                    health = savingchar.health,
                    armour = savingchar.armour,
                    logoff = savingchar.logoff or 0,
                    bonus = savingchar.bonus,
                    jobs = json.encode(savingchar.jobs),
                    needs = json.encode(savingchar.needs),
                    outfit = json.encode(savingchar.outfit),
                    tattoos = json.encode(tattosSave(savingchar.tattoos)),
                    skills = json.encode(savingchar.skills),
                    emotes = json.encode(savingchar.emotes),
                    charid = savingchar.id,
                    secret_token = status == "disconnected" and "" or savingchar.secret_token,
                    jail = json.encode(savingchar.jail),
                    bossdata = json.encode(savingchar.bossdata),
                    bank_accounts_left = savingchar.bank_accounts_left == nil and 2 or savingchar.bank_accounts_left
                }
            )

            MySQL.Async.execute(
                "UPDATE users SET chars_left= :chars_left, settings= :settings, lastconnected=NOW() WHERE identifier= :identifier",
                {
                    chars_left = users[identifier].chars_left,
                    settings = json.encode(users[identifier].settings),
                    identifier = identifier
                }
            )

            --print("^2[SYSTEM MESSAGE]^5 SAVED USER ^4" .. users[identifier].nickname .. "^5 WITH CHARACTER ^4" .. savingchar.firstname .. " " .. savingchar.lastname .. " (" .. savingchar.id .. ")")

            if status and status ~= -1 then
                users[identifier].status = status
            end
        end
    end
end

function updateCharacterIfOnline(charId, atts)
    local identifier, userData = getUserByCharId(charId)
    if identifier and userData then
        for key, value in pairs(atts) do
            updateCharVar(users[identifier].source, key, value)
        end
        return "success"
    else
        return "notOnline"
    end
end

RegisterNetEvent("s:updateInProperty")
AddEventHandler(
    "s:updateInProperty",
    function(value)
        local client = source
        if value then
            updateCharVar(client, "in_property", value)
        end
    end
)

RegisterNetEvent("s:playerStatus")
AddEventHandler(
    "s:playerStatus",
    function(status)
        local client = source

        if status ~= "dead" then
            return
        end

        if getUserVar(client, "status") ~= status then
            updateUserVar(client, "status", status)
        end
    end
)

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(600000)

            for identifier, userData in pairs(users) do
                if identifier and userData and (userData.status ~= "choosing" and userData.status ~= "connecting") and userData.character then
                    savePlayerPedData(identifier, userData.source)
                    Wait(10)
                end
            end
        end
    end
)

function savePlayerPedData(identifier, player)
    if identifier and users[identifier] then
        local playerPed = GetPlayerPed(player)
        local playerCoords = GetEntityCoords(playerPed)

        users[identifier].character.health = GetEntityHealth(playerPed)
        users[identifier].character.armour = GetPedArmour(playerPed)
        users[identifier].character.coords = {
            x = playerCoords.x,
            y = playerCoords.y,
            z = playerCoords.z + 0.01,
            w = GetEntityHeading(playerPed)
        }
    end
end

RegisterNetEvent("data:setStatusChoosing")
AddEventHandler(
    "data:setStatusChoosing",
    function()
        local client = source

        Citizen.CreateThread(
            function()
                local identifier = getCachedPlayerIdentifier(client)
                local isNew = true

                if identifier and users[identifier] and users[identifier].character then
                    isNew = false
                    if users[identifier].status == "dead" and users[identifier].character ~= nil then
                        users[identifier].character.logoff = 1
                        users[identifier].character.health = 200

                        exports.logs:sendToDiscord(
                            {
                                channel = "combat-log",
                                title = "Charselect",
                                description = "Šel/Šla do výběru postav a je mrtvý/á!",
                                color = "9509659"
                            },
                            users[identifier].source
                        )
                    elseif users[identifier].character ~= nil then
                        users[identifier].character.logoff = 0
                    end

                    savePlayerPedData(identifier, client)
                    saveChar(client, "choosing")
                end

                updateUserVar(client, "status", "choosing")
                TriggerEvent("data:startedChoosing", client, identifier, isNew)
                TriggerClientEvent("s:statusUpdated", client, "choosing")
            end
        )
    end
)

function tattosSave(tattoos)
    for i, _ in each(tattoos) do
        tattoos[i].group = nil
        tattoos[i].price = nil
        tattoos[i].label = nil
        tattoos[i].id = nil
    end

    return tattoos
end
