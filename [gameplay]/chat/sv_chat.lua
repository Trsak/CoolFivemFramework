RegisterNetEvent("chat:init")
RegisterNetEvent("chat:addTemplate")
RegisterNetEvent("chat:addMessage")
RegisterNetEvent("chat:addSuggestion")
RegisterNetEvent("chat:removeSuggestion")
RegisterNetEvent("chat:messageEntered")
RegisterNetEvent("chat:clear")
RegisterNetEvent("__cfx_internal:commandFallback")

exports(
    "addMessage",
    function(target, message)
        if not message then
            message = target
            target = -1
        end

        if not target or not message then
            return
        end

        TriggerClientEvent("chat:addMessage", target, message)
    end
)

local hooks = {}
local hookIdx = 1

local tags = {}

exports(
    "registerMessageHook",
    function(hook)
        local resource = GetInvokingResource()
        hooks[hookIdx + 1] = {
            fn = hook,
            resource = resource
        }

        hookIdx = hookIdx + 1
    end
)

local modes = {}

local function getMatchingPlayers(seObject)
    local players = GetPlayers()
    local retval = {}

    for _, v in each(players) do
        if IsPlayerAceAllowed(v, seObject) then
            retval[#retval + 1] = v
        end
    end

    return retval
end

exports(
    "registerMode",
    function(modeData)
        if not modeData.name or not modeData.displayName or not modeData.cb then
            return false
        end

        local resource = GetInvokingResource()

        modes[modeData.name] = modeData
        modes[modeData.name].resource = resource

        local clObj = {
            name = modeData.name,
            displayName = modeData.displayName,
            color = modeData.color or "#fff",
            isChannel = modeData.isChannel,
            isGlobal = modeData.isGlobal
        }

        if not modeData.seObject then
            TriggerClientEvent("chat:addMode", -1, clObj)
        else
            for _, v in each(getMatchingPlayers(modeData.seObject)) do
                TriggerClientEvent("chat:addMode", v, clObj)
            end
        end

        return true
    end
)

local function unregisterHooks(resource)
    local toRemove = {}

    for k, v in pairs(hooks) do
        if v.resource == resource then
            table.insert(toRemove, k)
        end
    end

    for _, v in each(toRemove) do
        hooks[v] = nil
    end

    toRemove = {}

    for k, v in pairs(modes) do
        if v.resource == resource then
            table.insert(toRemove, k)
        end
    end

    for _, v in each(toRemove) do
        TriggerClientEvent(
            "chat:removeMode",
            -1,
            {
                name = v
            }
        )

        modes[v] = nil
    end
end

local function routeMessage(source, name, message, mode, fromConsole)
    if string.sub(message, 1, string.len("/")) ~= "/" then
        CancelEvent()

        if source == 0 then
            TriggerClientEvent(
                "chat:addMessage",
                -1,
                {
                    templateId = "ooc",
                    args = { "Konzole", message }
                }
            )
        elseif name then
            if exports.data:getUserVar(source, "admin") > 1 and tags[tostring(source)] then
                name = exports.data:getUserVar(source, "admin") < 4 and "^4[ADMIN]^7 " .. name or
                    "^2[DEVELOPER]^7 " .. name
            end

            local targetCoords = GetEntityCoords(GetPlayerPed(source))
            local targetInstance = exports.instance:getPlayerInstance(source)
            local instances = exports.instance:getInstances()

            for _, playerId in each(GetPlayers()) do
                local playerInstance = ""
                local playerRoutingBucket = GetPlayerRoutingBucket(playerId)

                if playerRoutingBucket ~= 0 then
                    playerInstance = instances[tostring(playerRoutingBucket)]
                end

                if playerInstance == targetInstance then
                    local playerCoords = GetEntityCoords(GetPlayerPed(playerId))

                    if #(targetCoords - playerCoords) <= 20.0 then
                        TriggerClientEvent(
                            "chat:addMessage",
                            playerId,
                            {
                                templateId = "looc",
                                args = { name, message }
                            }
                        )
                    end
                end
            end

            exports.logs:sendToDiscord(
                {
                    channel = "chat",
                    title = "LOOC",
                    description = message,
                    color = "10737397"
                },
                source
            )
        end
    end
end

AddEventHandler(
    "chat:messageEntered",
    function(author, color, message, mode)
        if not message or not author then
            return
        end

        local source = source
        routeMessage(source, author, message, mode)
    end
)

AddEventHandler(
    "__cfx_internal:commandFallback",
    function(command)
        local _source = source
        TriggerClientEvent(
            "chat:addMessage",
            _source,
            {
                templateId = "error",
                args = { "Zadaný příkaz neexistuje!" }
            }
        )
        CancelEvent()
    end
)

RegisterCommand(
    "say",
    function(source, args, rawCommand)
        routeMessage(source, (source == 0) and "console" or GetPlayerName(source), rawCommand:sub(5), nil, true)
    end
)

-- command suggestions for clients
local function refreshCommands(player)
    if GetRegisteredCommands then
        local registeredCommands = GetRegisteredCommands()

        local suggestions = {}

        for _, command in each(registeredCommands) do
            if IsPlayerAceAllowed(player, ("command.%s"):format(command.name)) then
                table.insert(
                    suggestions,
                    {
                        name = "/" .. command.name,
                        help = ""
                    }
                )
            end
        end

        TriggerClientEvent("chat:addSuggestions", player, suggestions)
    end
end

AddEventHandler(
    "chat:init",
    function()
        local source = source
        refreshCommands(source)

        for _, modeData in pairs(modes) do
            local clObj = {
                name = modeData.name,
                displayName = modeData.displayName,
                color = modeData.color or "#fff",
                isChannel = modeData.isChannel,
                isGlobal = modeData.isGlobal
            }

            if not modeData.seObject or IsPlayerAceAllowed(source, modeData.seObject) then
                TriggerClientEvent("chat:addMode", source, clObj)
            end
        end
    end
)

AddEventHandler(
    "onServerResourceStart",
    function(resName)
        Wait(500)

        for _, player in each(GetPlayers()) do
            refreshCommands(player)
        end
    end
)

AddEventHandler(
    "onResourceStop",
    function(resName)
        unregisterHooks(resName)
    end
)

RegisterCommand(
    "ooc",
    function(source, args, rawCommand)
        local _source = source
        if exports.data:getUserVar(_source, "admin") > 1 then
            local name = GetPlayerName(_source)

            if not args[1] then
                TriggerClientEvent(
                    "chat:addMessage",
                    _source,
                    {
                        templateId = "error",
                        args = { "Musíte zadat zprávu!" }
                    }
                )
            else
                if name then
                    local message = rawCommand:sub(4)

                    TriggerClientEvent(
                        "chat:addMessage",
                        -1,
                        {
                            templateId = "ooc",
                            args = { name, message }
                        }
                    )

                    exports.logs:sendToDiscord(
                        {
                            channel = "chat",
                            title = "OOC",
                            description = message,
                            color = "6727621"
                        },
                        _source
                    )
                end
            end
        end
    end
)

RegisterCommand(
    "me",
    function(source, args)
        local _source = source
        if not args[1] then
            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "error",
                    args = { "Musíte zadat text!" }
                }
            )
        else
            local userChar = exports.data:getUserVar(_source, "character")
            local userStatus = exports.data:getUserVar(_source, "status")
            if userChar and (userStatus == "spawned" or userStatus == "dead") then
                local text = ""
                local charName = userChar.firstname .. " " .. userChar.lastname

                for i = 1, #args do
                    text = text .. " " .. args[i]
                end

                displayMeDoDoc("me", text, _source, 20.0, false, charName)

                exports.logs:sendToDiscord(
                    {
                        channel = "me-do-doc",
                        title = "ME",
                        description = text,
                        color = "16496242"
                    },
                    _source
                )
            end
        end
    end
)

RegisterCommand(
    "ame",
    function(source, args)
        local _source = source
        if not args[1] then
            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "error",
                    args = { "Musíte zadat text!" }
                }
            )
        elseif exports.data:getUserVar(_source, "admin") < 1 then
            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "error",
                    args = { "Na toto nemáš právo!" }
                }
            )
        else
            local text = ""
            for i = 1, #args do
                text = text .. " " .. args[i]
            end

            displayMeDoDoc("me", text, _source, 20.0, false, nil)

            exports.logs:sendToDiscord(
                {
                    channel = "me-do-doc",
                    title = "AME",
                    description = text,
                    color = "16496242"
                },
                _source
            )
        end
    end
)

RegisterCommand(
    "mec",
    function(source, args, rawCommand)
        local _source = source
        if not args[1] then
            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "error",
                    args = { "Musíte zadat text!" }
                }
            )
        else
            local userChar = exports.data:getUserVar(_source, "character")
            local userStatus = exports.data:getUserVar(_source, "status")
            if userChar and (userStatus == "spawned" or userStatus == "dead") then
                local text = ""
                local charName = userChar.firstname .. " " .. userChar.lastname

                for i = 1, #args do
                    text = text .. " " .. args[i]
                end

                displayMeDoDoc("me", text, _source, 5.0, false, charName)

                exports.logs:sendToDiscord(
                    {
                        channel = "me-do-doc",
                        title = "MEC",
                        description = text,
                        color = "16496242"
                    },
                    _source
                )
            end
        end
    end
)

RegisterCommand(
    "meh",
    function(source, args)
        local _source = source
        if not args[1] then
            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "error",
                    args = { "Musíte zadat text!" }
                }
            )
        else
            local userChar = exports.data:getUserVar(_source, "character")
            local userStatus = exports.data:getUserVar(_source, "status")
            if userChar and (userStatus == "spawned" or userStatus == "dead") then
                local text = ""
                local charName = userChar.firstname .. " " .. userChar.lastname

                for i = 1, #args do
                    text = text .. " " .. args[i]
                end

                displayMeDoDoc("me", text, _source, 20.0, true, charName)

                exports.logs:sendToDiscord(
                    {
                        channel = "me-do-doc",
                        title = "MEH",
                        description = text,
                        color = "16496242"
                    },
                    _source
                )
            end
        end
    end
)

RegisterCommand(
    "do",
    function(source, args)
        local _source = source
        if not args[1] then
            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "error",
                    args = { "Musíte zadat text!" }
                }
            )
        else
            local userChar = exports.data:getUserVar(_source, "character")
            local userStatus = exports.data:getUserVar(_source, "status")
            if userChar and (userStatus == "spawned" or userStatus == "dead") then
                local text = ""
                local charName = userChar.firstname .. " " .. userChar.lastname

                for i = 1, #args do
                    text = text .. " " .. args[i]
                end

                displayMeDoDoc("do", text, _source, 20.0, false, charName)

                exports.logs:sendToDiscord(
                    {
                        channel = "me-do-doc",
                        title = "DO",
                        description = text,
                        color = "15505051"
                    },
                    _source
                )
            end
        end
    end
)

RegisterCommand(
    "ado",
    function(source, args)
        local _source = source
        if not args[1] then
            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "error",
                    args = { "Musíte zadat text!" }
                }
            )
        elseif exports.data:getUserVar(_source, "admin") < 1 then
            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "error",
                    args = { "Na toto nemáš právo!" }
                }
            )
        else
            local text = ""
            for i = 1, #args do
                text = text .. " " .. args[i]
            end

            displayMeDoDoc("do", text, _source, 20.0, false, nil)

            exports.logs:sendToDiscord(
                {
                    channel = "me-do-doc",
                    title = "ADO",
                    description = text,
                    color = "15505051"
                },
                _source
            )
        end
    end
)

RegisterCommand(
    "docl",
    function(source, args)
        local _source = source
        if not args[1] then
            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "error",
                    args = { "Musíte zadat text!" }
                }
            )
        else
            local userChar = exports.data:getUserVar(_source, "character")
            local userStatus = exports.data:getUserVar(_source, "status")
            if userChar and (userStatus == "spawned" or userStatus == "dead") then
                local text = ""
                local charName = userChar.firstname .. " " .. userChar.lastname

                for i = 1, #args do
                    text = text .. " " .. args[i]
                end

                displayMeDoDoc("do", text, _source, 5.0, false, charName)

                exports.logs:sendToDiscord(
                    {
                        channel = "me-do-doc",
                        title = "DOCL",
                        description = text,
                        color = "15505051"
                    },
                    _source
                )
            end
        end
    end
)

RegisterCommand(
    "doh",
    function(source, args)
        local _source = source
        if not args[1] then
            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "error",
                    args = { "Musíte zadat text!" }
                }
            )
        else
            local userChar = exports.data:getUserVar(_source, "character")
            local userStatus = exports.data:getUserVar(_source, "status")
            if userChar and (userStatus == "spawned" or userStatus == "dead") then
                local text = ""
                local charName = userChar.firstname .. " " .. userChar.lastname

                for i = 1, #args do
                    text = text .. " " .. args[i]
                end

                displayMeDoDoc("do", text, _source, 20.0, true, charName)

                exports.logs:sendToDiscord(
                    {
                        channel = "me-do-doc",
                        title = "DOH",
                        description = text,
                        color = "15505051"
                    },
                    _source
                )
            end
        end
    end
)

RegisterCommand(
    "doc",
    function(source, args, rawCommand)
        local _source = source
        if not args[1] then
            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "error",
                    args = { "Musíte zadat počet!" }
                }
            )
        else
            local count = tonumber(args[1])

            if not count or math.floor(count) ~= count then
                TriggerClientEvent(
                    "chat:addMessage",
                    _source,
                    {
                        templateId = "error",
                        args = { "Počet musí být celé číslo!" }
                    }
                )
            elseif count <= 0 or count > 50 then
                TriggerClientEvent(
                    "chat:addMessage",
                    _source,
                    {
                        templateId = "error",
                        args = { "Počet musí být od 1 do 50!" }
                    }
                )
            else
                displayMeDoDoc("doc", count, _source, 20.0, false)

                exports.logs:sendToDiscord(
                    {
                        channel = "me-do-doc",
                        title = "DOC",
                        description = count,
                        color = "15505051"
                    },
                    _source
                )
            end
        end
    end
)

function displayMeDoDoc(type, data, target, distance, shouldBeHidden, charName)
    local targetCoords = GetEntityCoords(GetPlayerPed(target))
    local targetInstance = exports.instance:getPlayerInstance(target)
    local instances = exports.instance:getInstances()

    for _, playerId in each(GetPlayers()) do
        local playerInstance = ""
        local playerRoutingBucket = GetPlayerRoutingBucket(playerId)

        if playerRoutingBucket ~= 0 then
            playerInstance = instances[tostring(playerRoutingBucket)]
        end

        if playerInstance == targetInstance then
            local playerCoords = GetEntityCoords(GetPlayerPed(playerId))
            if #(targetCoords - playerCoords) <= distance then
                if type == "doc" then
                    TriggerClientEvent("chat:doc", playerId, data, target, shouldBeHidden)
                else
                    TriggerClientEvent("chat:triggerDisplay", playerId, data, target, type, shouldBeHidden, charName)
                end
            end
        end
    end
end

RegisterCommand(
    "jobs",
    function(source, args, rawCommand)
        local _source = source
        printJobs(_source)
    end
)

RegisterCommand(
    "prace",
    function(source, args, rawCommand)
        local _source = source
        printJobs(_source)
    end
)

RegisterCommand(
    "id",
    function(source, args, rawCommand)
        local _source = source

        TriggerClientEvent(
            "chat:addMessage",
            _source,
            {
                template = '<div style="float: left; padding: 10px; margin: 5px; background-color: rgba(0, 191, 255, 0.75); border-left: 10px solid rgb(0, 191, 255);"><strong>Tvoje ID:</strong> {0}</div>',
                args = { _source }
            }
        )
    end
)

RegisterCommand(
    "pol",
    function(source, args)
        local _source = source

        if exports.base_jobs:hasUserJobType(_source, "police", true) then
            local text = table.concat(args, " ")
            local playerJob = "LSPD"
            for i, job in each({ "lspd", "lssd", "sahp" }) do
                if exports.base_jobs:hasUserJob(_source, job, 1, true) then
                    playerJob = exports.base_jobs:getJobVar(job, "label")
                    break
                end
            end

            TriggerClientEvent(
                "chat:addMessage",
                -1,
                {
                    templateId = "police",
                    args = { string.upper(playerJob), text }
                }
            )

            exports.logs:sendToDiscord(
                {
                    channel = "chat",
                    title = "Police",
                    description = text,
                    color = "2003199"
                },
                source
            )
        else
            TriggerClientEvent(
                "chat:addMessage",
                source,
                {
                    templateId = "error",
                    args = { "Nejsi policista!" }
                }
            )
        end
    end
)

RegisterCommand(
    "medic",
    function(source, args)
        local _source = source

        if exports.base_jobs:hasUserJobType(_source, "medic", true) then
            local text = table.concat(args, " ")
            local playerJob = "EMS"
            for i, job in each({ "ems", "lsfd" }) do
                if exports.base_jobs:hasUserJob(_source, job, 1, true) then
                    playerJob = exports.base_jobs:getJobVar(job, "label")
                    break
                end
            end

            TriggerClientEvent(
                "chat:addMessage",
                -1,
                {
                    templateId = "medic",
                    args = { string.upper(playerJob), text }
                }
            )

            exports.logs:sendToDiscord(
                {
                    channel = "chat",
                    title = "Medic",
                    description = text,
                    color = "2003199"
                },
                _source
            )
        else
            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "error",
                    args = { "Nejsi medik!" }
                }
            )
        end
    end
)

RegisterCommand(
    "weazel",
    function(source, args)
        local _source = source

        if exports.base_jobs:hasUserJob(_source, "weazel", 1, true) then
            local text = table.concat(args, " ")
            local playerJob = exports.base_jobs:getJobVar("weazel", "label")

            TriggerClientEvent(
                "chat:addMessage",
                -1,
                {
                    templateId = "weazel",
                    args = { string.upper(playerJob), text }
                }
            )

            exports.logs:sendToDiscord(
                {
                    channel = "chat",
                    title = "Weazel News",
                    description = text,
                    color = "2003199"
                },
                _source
            )
        else
            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "error",
                    args = { "Nejsi zaměstnanec Weazel News!" }
                }
            )
        end
    end
)

RegisterCommand(
    "dailyglobe",
    function(source, args)
        local _source = source

        if exports.base_jobs:hasUserJob(_source, "dailyglobe", 1, true) then
            local text = table.concat(args, " ")
            local playerJob = exports.base_jobs:getJobVar("dailyglobe", "label")

            TriggerClientEvent(
                "chat:addMessage",
                -1,
                {
                    templateId = "dailyglobe",
                    args = { string.upper(playerJob), text }
                }
            )

            exports.logs:sendToDiscord(
                {
                    channel = "chat",
                    title = "Daily Globe",
                    description = text,
                    color = "2003199"
                },
                _source
            )
        else
            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "error",
                    args = { "Nejsi zaměstnanec Daily Globe!" }
                }
            )
        end
    end
)

function printJobs(player)
    local jobs = exports.data:getCharVar(player, "jobs")

    if #jobs == 0 then
        TriggerClientEvent(
            "chat:addMessage",
            player,
            {
                template = '<div style="float: left; padding: 10px; margin: 5px; background-color: rgba(0, 191, 255, 0.75); border-left: 10px solid rgb(0, 191, 255);"><strong>Práce:</strong> Nejsi nikde zaměstnaný</div>',
                args = { jobLabel, jobgradeLabel, dutyText }
            }
        )
    else
        jobsText = ""

        for i, jobData in each(jobs) do
            local jobLabel = exports.base_jobs:getJob(jobData.job).label
            local jobgradeLabel = exports.base_jobs:getJobVar(jobData.job, "grades")[jobData.job_grade].label

            local dutyText = ""
            if not jobData.duty then
                dutyText = " (mimo službu)"
            end

            jobsText = jobsText .. " " .. jobLabel .. " - " .. jobgradeLabel .. dutyText
            if i < #jobs then
                jobsText = jobsText .. ", "
            end
        end

        TriggerClientEvent(
            "chat:addMessage",
            player,
            {
                template = '<div style="float: left; padding: 10px; margin: 5px; background-color: rgba(0, 191, 255, 0.75); border-left: 10px solid rgb(0, 191, 255);"><strong>Práce:</strong>{0}</div>',
                args = { jobsText }
            }
        )
    end
end

RegisterCommand(
    "announce",
    function(source, args)
        local _source = source

        if exports.data:getUserVar(_source, "admin") > 1 then
            local text = table.concat(args, " ")

            TriggerClientEvent(
                "chat:addMessage",
                -1,
                {
                    template = '<div style="padding: 10px; margin: 5px; border-left: 10px solid rgb(155, 0, 0); background: rgba(155, 0, 0, 0.75);"><strong>OZNÁMENÍ: </strong>{0}</div>',
                    args = { text }
                }
            )

            exports.logs:sendToDiscord(
                {
                    channel = "admin-commands",
                    title = "Oznámení",
                    description = text,
                    color = "2003199"
                },
                _source
            )
        else
            TriggerClientEvent(
                "chat:addMessage",
                source,
                {
                    templateId = "error",
                    args = { "Nemáš oprávnění!" }
                }
            )
        end
    end
)

RegisterCommand(
    "try",
    function(source, args)
        local _source = source
        local random = math.random(1, 100) > 50 and "Ano" or "Ne"

        local userChar = exports.data:getUserVar(_source, "character")
        local userStatus = exports.data:getUserVar(_source, "status")
        if userChar and (userStatus == "spawned" or userStatus == "dead") then
            local charName = userChar.firstname .. " " .. userChar.lastname

            displayMeDoDoc("try", random, _source, 20.0, false, charName)

            exports.logs:sendToDiscord(
                {
                    channel = "me-do-doc",
                    title = "TRY",
                    description = "Hráč dostal '" .. string.lower(random) .. "'",
                    color = "16496242"
                },
                _source
            )
        end
    end
)

RegisterCommand(
    "tag",
    function(source, args)
        local _source = source

        if exports.data:getUserVar(_source, "admin") > 1 then
            if not tags[tostring(_source)] then
                tags[tostring(_source)] = true
                TriggerClientEvent(
                    "chat:addMessage",
                    source,
                    {
                        templateId = "success",
                        args = { "Zapnul/a sis tag!" }
                    }
                )
            else
                tags[tostring(_source)] = nil
                TriggerClientEvent(
                    "chat:addMessage",
                    source,
                    {
                        templateId = "success",
                        args = { "Vypnul/a sis tag!" }
                    }
                )
            end
            exports.logs:sendToDiscord(
                {
                    channel = "admin-commands",
                    title = "Tag",
                    description = tags[tostring(_source)] and "Zapnul/a svůj tag" or "Vypnul/a svůj tag",
                    color = "34749"
                },
                _source
            )
        else
            TriggerClientEvent(
                "chat:addMessage",
                source,
                {
                    templateId = "error",
                    args = { "Nemáš oprávnění!" }
                }
            )
        end
    end
)
