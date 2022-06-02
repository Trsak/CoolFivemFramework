math.randomseed(os.time() + math.random(10000, 99999))

local allowedCharsSelect = {}

RegisterNetEvent("chars:charSelect")
AddEventHandler(
    "chars:charSelect",
    function(identifier)
        local _source = source

        local status = exports.data:getUserVar(_source, "status")

        if (status == "spawned" or status == "dead") and not allowedCharsSelect[_source] then
            exports.admin:banClientForCheating(_source, "0", "Cheating", "chars:charSelect", "Hráč se pokusil respawnout přes event!")
            return
        end

        allowedCharsSelect[_source] = false

        reloadCharlist(exports.data:getSteamIdentifier(_source), _source)
    end
)

function startCharSelect(target)
    allowedCharsSelect[target] = true
    TriggerClientEvent("chars:charSelectStart", target)
end

function decodeJsonData(data)
    local data = data
    if data.tattoos then
        if type(data.tattoos) == "string" then
            data.tattoos = json.decode(data.tattoos)
        end
    else
        data.tattoos = {}
    end

    for i, tattoo in each(data.tattoos) do
        data.tattoos[i].id = tattoo.collection .. "-" .. tattoo.name
    end

    if data.skills and type(data.skills) == "string" then
        data.skills = json.decode(data.skills)
    end

    if data.outfit and type(data.outfit) == "string" then
        data.outfit = json.decode(data.outfit)
    end

    if data.needs and type(data.needs) == "string" then
        data.needs = json.decode(data.needs)
    end

    if data.in_property and type(data.in_property) == "string" then
        data.in_property = json.decode(data.in_property)
    end

    if data.emotes and type(data.emotes) == "string" then
        data.emotes = json.decode(data.emotes)
    end

    if data.jail and type(data.jail) == "string" then
        data.jail = json.decode(data.jail)
    end

    if data.jobs and type(data.jobs) == "string" then
        data.jobs = json.decode(data.jobs)
    end

    if data.bossdata and type(data.bossdata) == "string" then
        data.bossdata = json.decode(data.bossdata)
    end
    return data
end

RegisterNetEvent("chars:newchar")
AddEventHandler(
    "chars:newchar",
    function(data)
        local _source = source
        local identifier = exports.data:getUserVar(_source, "identifier")
        local charsLeft = exports.data:getUserVar(_source, "chars_left")

        if charsLeft <= 0 then
            TriggerClientEvent("chars:error", _source, "charsLimit")
        else
            local startingCoords = Config.SpawnLocations[data.location]
            local randomToken = generateRandomToken()

            MySQL.Async.insert(
                "INSERT INTO characters (identifier, firstname, lastname, jobs, birth, health, sex, coords, secret_token, outfit, emotes, jail, bossdata) VALUES (:identifier, :firstname, :lastname, :jobs, :birth, :health, :sex, :coords, :secret_token, '[]', '[]', '[]', '[]')",
                {
                    identifier = identifier,
                    firstname = data.firstname,
                    lastname = data.lastname,
                    jobs = json.encode({}),
                    birth = data.birthdate,
                    health = 175.0,
                    sex = data.sex,
                    secret_token = randomToken,
                    coords = json.encode(
                        {
                            x = startingCoords.x,
                            y = startingCoords.y,
                            z = startingCoords.z,
                            w = startingCoords.w
                        }
                    )
                },
                function(insertId)
                    if insertId and insertId > 0 then
                        charsLeft = charsLeft - 1
                        if charsLeft >= 0 then
                            exports.data:updateUserVar(_source, "chars_left", charsLeft)
                        end

                        exports.logs:sendToDiscord(
                            {
                                channel = "account",
                                title = "Vytvoření postavy",
                                description = "Vytvořil postavu " ..
                                    data.firstname ..
                                    " " .. data.lastname .. " (" .. insertId .. ")",
                                color = "2419996"
                            },
                            _source
                        )

                        local charData = {
                            id = insertId,
                            identifier = identifier,
                            firstname = data.firstname,
                            lastname = data.lastname,
                            birth = data.birthdate,
                            sex = data.sex,
                            health = 175.0,
                            logoff = 0,
                            armour = 0,
                            jobs = {},
                            jail = {},
                            bonus = 0,
                            bossdata = {},
                            needs = {},
                            emotes = {},
                            skills = {},
                            coords = vec4(startingCoords.x, startingCoords.y, startingCoords.z, startingCoords.w),
                            secret_token = randomToken,
                            in_property = {},
                            bank_accounts_left = 10
                        }
                        chosenChar(
                            _source,
                            charData,
                            vec4(startingCoords.x, startingCoords.y, startingCoords.z, startingCoords.w),
                            true
                        )
                    end
                end
            )
        end
    end
)

RegisterNetEvent("chars:playerSpawned")
AddEventHandler(
    "chars:playerSpawned",
    function(coords)
        local _source = source

        Citizen.CreateThread(
            function()
                Citizen.Wait(2000)

                if exports.data:getUserVar(_source, "status") ~= "dead" then
                    exports.data:updateUserVar(_source, "status", "spawned")
                    TriggerClientEvent("chars:playerSpawned", _source, coords)

                    local charData = exports.data:getUserVar(_source, "character")
                    exports.logs:sendToDiscord(
                        {
                            channel = "account",
                            title = "Výběr postavy",
                            description = "Zvolil si postavu " ..
                                charData.firstname .. " " .. charData.lastname .. " (" .. charData.id .. ")",
                            color = "3135391"
                        },
                        _source
                    )
                end
            end
        )
    end
)

RegisterNetEvent("chars:removeChar")
AddEventHandler(
    "chars:removeChar",
    function(charId)
        local _source = source
        local identifier = exports.data:getUserVar(_source, "identifier")

        MySQL.Async.fetchAll(
            "SELECT id, firstname, lastname FROM characters WHERE id = :char and identifier = :identifier LIMIT 1",
            {
                identifier = identifier,
                char = charId
            },
            function(result)
                if result ~= nil and #result == 1 then
                    exports.logs:sendToDiscord(
                        {
                            channel = "account",
                            title = "Smazání postavy",
                            description = "Smazal postavu " ..
                                result[1].firstname .. " " .. result[1].lastname .. " (" .. result[1].id .. ")",
                            color = "15539236"
                        },
                        _source
                    )

                    MySQL.Sync.execute(
                        "UPDATE `characters` SET `removed` = 1 WHERE id = :char",
                        {
                            char = charId
                        }
                    )
                end

                reloadCharlist(identifier, _source)
            end
        )
    end
)

RegisterNetEvent("chars:chosenChar")
AddEventHandler(
    "chars:chosenChar",
    function(char, location, isNew)
        local _source = source
        local identifier = exports.data:getUserVar(_source, "identifier")

        MySQL.Async.fetchAll(
            "SELECT * FROM characters WHERE id = :char and identifier = :identifier LIMIT 1",
            {
                identifier = identifier,
                char = char.id
            },
            function(result)
                if result and #result == 1 then
                    if Config.SpawnLocations[location] then
                        local locationData = Config.SpawnLocations[location]
                        chosenChar(
                            _source,
                            result[1],
                            vec4(locationData.x, locationData.y, locationData.z, locationData.heading or locationData.w),
                            isNew,
                            false
                        )
                    else
                        local locationData = json.decode(result[1].coords)
                        if not locationData.heading and not locationData.w then
                            locationData.w = 0.0
                        end

                        chosenChar(
                            _source,
                            result[1],
                            vec4(locationData.x, locationData.y, locationData.z, locationData.heading or locationData.w),
                            isNew,
                            true
                        )
                    end
                else
                    exports.admin:banClientForCheating(
                        _source,
                        "0",
                        "Cheating",
                        "chars:chosenChar",
                        "Hráč se pokusil vzít postavu s ID " .. char.id
                    )
                end
            end
        )
    end
)

function chosenChar(client, char, coords, isNew, lastPosition)
    local char = decodeJsonData(char)

    char.secret_token = generateRandomToken()

    MySQL.Async.execute(
        "UPDATE characters SET lastused = NOW(), secret_token = :secret_token WHERE id = :charid",
        {
            charid = char.id,
            secret_token = char.secret_token
        }
    )

    if char.health <= 0 or char.logoff == 1 then
        char.health = 0
        char.armor = 0
        Citizen.SetTimeout(5000, function()
            exports.logs:sendToDiscord(
                {
                    channel = "combat-log",
                    title = "Spawn",
                    description = "Připojil/a se a je mrtvý/á!",
                    color = "15539236"
                },
                client
            )
        end)
    end

    if not lastPosition then
        char.in_property = nil
    end

    exports.data:updateUserVar(client, "character", char)
    TriggerClientEvent("chars:spawnChar", client, char, coords, isNew, lastPosition, char.logoff)
end

function reloadCharlist(identifier, _source)
    MySQL.Async.fetchAll(
        "SELECT * FROM characters WHERE identifier = :identifier AND removed = 0 ORDER BY lastused DESC",
        {
            identifier = identifier
        },
        function(result)
            local job = {}
            for i = 1, #result do
                job = exports.base_jobs:getJob(result[i].job)
                if job then
                    result[i].jobLabel = job.label
                    result[i].jobGrade = job.grades[result[i].job_grade].label
                end
            end

            local userData = exports.data:getUserByIdentifier(identifier)

            if not userData then
                print("DEBUG THIS:", identifier, _source, charsLeft, userData)
                charsLeft = 0
                DropPlayer(_source, "Někde nastala chyba, připojte se znovu!")
                return
            end

            local charsLeft = userData.chars_left

            if charsLeft <= 0 then
                charsLeft = 0

                if Config.AllwaysOnecharAvailable and #result == 0 then
                    charsLeft = 1
                    exports.data:updateUserVar(_source, "chars_left", 1)
                end
            end

            local isWhitelisted = true

            local whitelist = exports.data:getUserVar(_source, "whitelisted")
            if whitelist ~= nil then
                isWhitelisted = whitelist
            end

            TriggerClientEvent("chars:charlist", _source, result, charsLeft, isWhitelisted)
        end
    )
end

function generateRandomToken()
    local character_set = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

    local string_sub = string.sub
    local math_random = math.random
    local table_concat = table.concat
    local character_set_amount = #character_set
    local number_one = 1
    local default_length = 20

    local random_string = {}

    for int = number_one, length or default_length do
        local random_number = math_random(number_one, character_set_amount)
        local character = string_sub(character_set, random_number, random_number)

        random_string[#random_string + number_one] = character
    end

    return table_concat(random_string)
end
