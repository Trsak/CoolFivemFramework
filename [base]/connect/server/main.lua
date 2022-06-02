local ActiveBans = {}
local serverName = nil
local lastServerName = nil
local maxServerSlots = GetConvarInt("sv_maxclients", 32)
local canConnect = false
local resourcesLoaded = false
local isRestarting = false

local quePlayers = {}
local droppedPlayers = {}
local oldPlayerTimes = {}

StopResource("hardcap")

MySQL.ready(
    function()
        ActiveBans = {}

        checkForBanlistChanges()
    end
)

function unescape(str)
    str = string.gsub(str, "<", "")
    str = string.gsub(str, ">", "")
    str = string.gsub(str, '"', "")
    str = string.gsub(str, "'", "")
    return str
end

function checkForBanlistChanges()
    local stats = {
        loadedNew = 0,
        changed = 0,
        unbanned = 0
    }

    for id, ban in pairs(ActiveBans) do
        ban.remove = true
    end

    MySQL.Async.fetchAll(
        "SELECT id, admin_name, player_name, player_identifiers, date_end, permanent, reason FROM `banlist` WHERE (`date_end` > NOW() OR `permanent` = 1) AND `unban` = 0",
        {},
        function(bans)
            for i = 1, #bans do
                if ActiveBans[bans[i].id] then
                    stats.changed = stats.changed + 1

                    ActiveBans[bans[i].id].remove = false
                    ActiveBans[bans[i].id].admin = bans[i].admin_name
                    ActiveBans[bans[i].id].player = bans[i].player_name
                    ActiveBans[bans[i].id].playerIdentifiers = bans[i].player_identifiers
                    ActiveBans[bans[i].id].dateEnd = math.floor(tonumber(bans[i].date_end) / 1000)
                    ActiveBans[bans[i].id].reason = bans[i].reason
                    ActiveBans[bans[i].id].permanent = tonumber(bans[i].permanent)
                else
                    stats.loadedNew = stats.loadedNew + 1

                    local banData = {}
                    banData.remove = false
                    banData.admin = bans[i].admin_name
                    banData.player = bans[i].player_name
                    banData.playerIdentifiers = bans[i].player_identifiers
                    banData.dateEnd = math.floor(tonumber(bans[i].date_end) / 1000)
                    banData.reason = bans[i].reason
                    banData.permanent = tonumber(bans[i].permanent)
                    ActiveBans[bans[i].id] = banData
                end
            end

            for id, ban in pairs(ActiveBans) do
                if ban.remove then
                    stats.unbanned = stats.unbanned + 1
                    ActiveBans[id] = nil
                end
            end
        end
    )

    SetTimeout(300000, checkForBanlistChanges)
end

function addNewBan(id, adminName, playerName, playerIdentifiers, dateEnd, reason, permanent)
    local banData = {}
    banData.admin = adminName
    banData.player = playerName
    banData.playerIdentifiers = playerIdentifiers
    banData.dateEnd = dateEnd
    banData.reason = reason
    banData.permanent = permanent

    ActiveBans[id] = banData
end

AddEventHandler(
    "txAdmin:events:scheduledRestart",
    function(data)
        local actualTime = tonumber(data.secondsRemaining / 60) - 3
        local stringLeftMins = "minut"
        if actualTime == 1 then
            stringLeftMins = "minutu"
        elseif actualTime < 5 then
            stringLeftMins = "minuty"
        end

        TriggerClientEvent(
            "chat:addMessage",
            -1,
            {
                template = '<div style="float: left; padding: 10px; margin: 5px; background-color: rgba(255, 40, 0, 0.75); border-left: 10px solid rgb(255, 40, 0);"><strong>RESTART</strong> Za <strong>{0}</strong> {1} proběhne restart serveru.</div>',
                args = { actualTime, stringLeftMins }
            }
        )

        if tonumber(data.secondsRemaining) <= (13 * 60) then
            TriggerEvent("rob_shops:restartDelaySync", true) -- block rob shops
        end

        if tonumber(data.secondsRemaining) <= (3 * 60) then
            isRestarting = true

            local players = GetPlayers()
            for i = 1, #players do
                DropPlayer(players[i], "Právě probíhá restart serveru. Připojte se za 5 - 10 minut.")
            end
        end
    end
)

function OnPlayerConnecting(name, setKickReason, deferrals)
    local _source = source
    local playerSteam, playerDiscord
    local identifiers = GetPlayerIdentifiers(_source)

    deferrals.defer()
    Wait(0)

    Citizen.CreateThread(
        function()
            for _, v in pairs(identifiers) do
                if string.find(v, "steam") then
                    playerSteam = v
                elseif string.find(v, "discord") then
                    playerDiscord = v:sub(string.len("discord:") + 1)
                end
            end

            for i = Config.AntiSpamTimer, 1, -1 do
                local seconds = "sekund"
                if i == 1 then
                    seconds = "sekundu"
                elseif i < 5 then
                    seconds = "sekundy"
                end

                showAdaptiveCard(deferrals, "Připojování...", "Prosím vyčkej " .. i .. " " .. seconds)
                Wait(1000)
            end

            while not canConnect or not resourcesLoaded do
                showAdaptiveCard(deferrals, "Připojování...", "Server se zapíná, chvíli vydrž.")
                Wait(1000)
            end

            if isPlayerStillConnected(playerSteam) then
                deferrals.done("Pokoušíš se napojit do hry s identitou, která už ve hře je! Zkus to znovu az chvíli.")
                return
            end

            if isRestarting then
                deferrals.done("Právě probíhá restart serveru. Připojte se za 5 - 10 minut.")
            else
                Wait(0)
                showAdaptiveCard(deferrals, "Připojování...", "Probíhá kontrola potřebných údajů")

                if playerSteam == nil then
                    exports.logs:sendToDiscord(
                        {
                            channel = "pripojeni-odpojeni",
                            title = "Steam",
                            description = "Připojení zamítnuto, hráč není přihlášen na Steam",
                            color = "15539236"
                        },
                        _source
                    )

                    deferrals.done("Musíš mít zapnutý steam a být do něj přihlášený!")
                    return
                elseif playerDiscord == nil then
                    exports.logs:sendToDiscord(
                        {
                            channel = "pripojeni-odpojeni",
                            title = "Discord",
                            description = "Připojení zamítnuto, hráč není přihlášen na Discord",
                            color = "15539236"
                        },
                        _source
                    )

                    deferrals.done("Musíš mít zapnutý Discord a být do něj přihlášený!")
                    return
                else
                    Wait(0)
                    if Config.checkBanlist then
                        local currentTime = os.time()
                        for id, ban in pairs(ActiveBans) do
                            if ban.permanent == 1 or ban.dateEnd > currentTime then
                                for _, v in pairs(identifiers) do
                                    if v ~= "ip:127.0.0.1" then
                                        if string.match(ban.playerIdentifiers, v) then
                                            print(
                                                "[SYSTEM MESSAGE] BANNED USER TRIED TO CONNECT. IDENTIFIER: " ..
                                                    v .. " | NICKNAME: " .. name
                                            )
                                            local length = os.date("%d.%m.%Y %H:%M:%S", ban.dateEnd)
                                            if ban.permanent == 1 then
                                                length = "Permanentní ban"
                                            end

                                            exports.logs:sendToDiscord(
                                                {
                                                    channel = "cheater-connect",
                                                    title = "Aktivní ban",
                                                    description = "Připojení zamítnuto, hráč má aktivní ban",
                                                    color = "15539236"
                                                },
                                                _source
                                            )
                                            deferrals.done(
                                                "Na tvém účtu je aktivní ban!\nDůvod banu: " ..
                                                    ban.reason .. "\nAdmin: " .. ban.admin .. "\nDatum vypršení: " .. length
                                            )
                                            return
                                        end
                                    end
                                end
                            end
                        end
                    end

                    Wait(0)

                    local result = MySQL.Sync.fetchAll(
                        "SELECT admin, whitelisted, chars_left, settings FROM users WHERE identifier = :identifier LIMIT 1",
                        {
                            identifier = playerSteam
                        }
                    )

                    if #result == 0 or result[1].whitelisted == 0 then
                        exports.logs:sendToDiscord(
                            {
                                channel = "pripojeni-odpojeni",
                                title = "Whitelist",
                                description = "Připojení zamítnuto, hráč nemá whitelist",
                                color = "15539236"
                            },
                            _source
                        )

                        deferrals.done("Pro hraní na našem serveru musíš být na whitelistu! Více na https://server.cz")
                        return
                    end

                    MySQL.Async.execute(
                        "UPDATE users SET name = :name, discord = :discord, lastconnected = NOW() WHERE identifier = :identifier",
                        {
                            identifier = playerSteam,
                            discord = playerDiscord,
                            name = name
                        }
                    )

                    local newUserAdded = exports.data:newConnectedUser(
                        _source,
                        {
                            identifier = playerSteam,
                            discord = playerDiscord,
                            nickname = name,
                            inAnim = false,
                            source = _source,
                            status = nil,
                            admin = result[1].admin,
                            settings = json.decode(result[1].settings),
                            character = nil,
                            chars_left = result[1].chars_left,
                            connectionTime = 0,
                            whitelisted = true
                        }
                    )

                    if not newUserAdded then
                        deferrals.done("Nastala chyba při načítání uživatelských dat, zkus to znovu!")
                        return
                    end
                    local pointsToAdd = 0
                    if droppedPlayers[playerSteam] ~= nil then
                        if droppedPlayers[playerSteam] + 300 > os.time() then
                            pointsToAdd = 200000
                        end
                    end

                    Wait(0)
                    showAdaptiveCard(deferrals, "Připojování...", "Kontroluji frontu...")
                    quePlayers[playerSteam] = {
                        points = GetUserPoints(playerSteam, true) + pointsToAdd,
                        connectTime = os.time(),
                        id = _source,
                        canConnect = (maxServerSlots - #GetPlayers()) > 5
                    }

                    if oldPlayerTimes[playerSteam] ~= nil then
                        if oldPlayerTimes[playerSteam].leaveTime + 120 > os.time() then
                            quePlayers[playerSteam].connectTime = oldPlayerTimes[playerSteam].actualTime
                        end

                        oldPlayerTimes[playerSteam] = nil
                    end

                    while true do
                        if playerSteam == nil or quePlayers[playerSteam] == nil or quePlayers[playerSteam].points == nil then
                            if playerSteam ~= nil and oldPlayerTimes[playerSteam] ~= nil then
                                quePlayers[playerSteam] = {
                                    points = GetUserPoints(playerSteam, true) + pointsToAdd,
                                    connectTime = oldPlayerTimes[playerSteam].actualTime,
                                    id = _source,
                                    canConnect = false
                                }
                            else
                                deferrals.done("Nastala chyba při připojování! Zkuste to znovu.")
                                return
                            end
                            return
                        end

                        if quePlayers[playerSteam].canConnect then
                            break
                        end

                        if isRestarting then
                            deferrals.done("Právě probíhá restart serveru. Připojte se za 5 - 10 minut.")
                            return
                        end

                        local currentTime = os.time()
                        local connectionTime = GetConnectTime(playerSteam)
                        local waitingTime = currentTime - connectionTime

                        oldPlayerTimes[playerSteam] = {
                            actualTime = connectionTime,
                            leaveTime = currentTime
                        }

                        local queueText = "Aktuálně jsi ve frontě na připojení."
                        queueText = queueText ..
                            "\nTvoje pozice ve frontě: " .. GetQuePosition(playerSteam) .. " / " .. GetQueueCount()

                        if playerSteam ~= nil and quePlayers[playerSteam] ~= nil and quePlayers[playerSteam].points ~= nil then
                            queueText = queueText .. "\nTvoje body: " .. quePlayers[playerSteam].points
                        end

                        queueText = queueText .. "\nČas ve frontě: " .. GetTimeInQue(waitingTime)
                        queueText = queueText ..
                            "\n\nNa webu https://shop.server.cz/ si můžeš zakoupit Queue pointy, podpořit tak server a dostat se na něj rychleji!"

                        deferrals.update(queueText)
                        Wait(800)
                    end

                    Wait(0)
                    exports.logs:sendToDiscord(
                        {
                            channel = "pripojeni-odpojeni",
                            title = "Připojení",
                            description = "Hráč se připojuje na server",
                            color = "42320"
                        },
                        _source
                    )
                    droppedPlayers[playerSteam] = nil

                    if isRestarting then
                        deferrals.done("Právě probíhá restart serveru. Připojte se za 5 - 10 minut.")
                    else
                        deferrals.done()
                        Wait(2000)
                        quePlayers[playerSteam] = nil
                    end
                end
            end
        end
    )
end

AddEventHandler("playerConnecting", OnPlayerConnecting)

function showAdaptiveCard(deferrals, title, text)
    deferrals.presentCard(
        [==[{
        "type": "AdaptiveCard",
        "backgroundImage": {
            "url": "https://static.server.cz/img/banner/3.jpg"
        },
        "body": [
            {
                "type": "Image",
                "url": "https://static.server.cz/img/server.png",
                "size": "Large",
                "horizontalAlignment": "Center"
            },
            {
                "type": "TextBlock",
                "text": "]==] ..
            title ..
            [==[",
            "wrap": true,
            "size": "Large",
            "weight": "Bolder"
        },
        {
            "type": "TextBlock",
            "text": "]==] ..
            text ..
            [==[",
    "wrap": true,
    "size": "Medium"
},
{
    "type": "ColumnSet",
    "columns": [
        {
            "type": "Column",
            "width": "stretch",
            "items": [
                {
                    "type": "ActionSet",
                    "actions": [
                        {
                            "type": "Action.OpenUrl",
                            "title": "Web .cz",
                            "url": "https://.cz/"
                        }
                    ]
                }
            ]
        },
        {
            "type": "Column",
            "width": "stretch",
            "items": [
                {
                    "type": "ActionSet",
                    "actions": [
                        {
                            "type": "Action.OpenUrl",
                            "title": "Podpořit server",
                            "url": "https://shop.server.cz/"
                        }
                    ]
                }
            ]
        }
    ],
    "spacing": "Large"
}
],
"actions": [
{
    "type": "Action.OpenUrl",
    "title": "Discord server",
    "url": "https://discord.gg/Eb3rH7c"
}
],
"$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
"version": "1.3"
}]==]
    )
end

function GetTimeInQue(waitingTime)
    local hours = string.format("%02.f", math.floor(waitingTime / 3600))
    local minutes = string.format("%02.f", math.floor(waitingTime / 60 - (hours * 60)))
    local seconds = string.format("%02.f", math.floor(waitingTime - hours * 3600 - minutes * 60))

    return hours .. ":" .. minutes .. ":" .. seconds
end

function GetConnectTime(steamIdentifier)
    local connectionTime = os.time()
    if quePlayers[steamIdentifier] ~= nil and quePlayers[steamIdentifier].connectTime ~= nil then
        connectionTime = quePlayers[steamIdentifier].connectTime
    end

    return connectionTime
end

function GetUserPoints(steamIdentifier, db)
    return exports.vip:getQueQuePoints(steamIdentifier, db)
end

function SortQueByPoints(a, b)
    return a.points > b.points
end

function GetQuePosition(steamIdentifier)
    local myPoints = 0
    if quePlayers[steamIdentifier] ~= nil and quePlayers[steamIdentifier].points ~= nil then
        myPoints = quePlayers[steamIdentifier].points
    end

    local myId = 0
    if quePlayers[steamIdentifier] ~= nil and quePlayers[steamIdentifier].id ~= nil then
        myId = quePlayers[steamIdentifier].id
    end

    local myConnectTime = GetConnectTime(steamIdentifier)
    if not myConnectTime then
        myConnectTime = os.time()
    end

    local myPosition = 1
    for identifier, data in pairs(quePlayers) do
        if identifier ~= steamIdentifier then
            if data.points > myPoints or (data.points == myPoints and data.connectTime < myConnectTime) or (data.points == myPoints and data.connectTime == myConnectTime and data.id < myId) then
                myPosition = myPosition + 1
            end
        end
    end

    return myPosition
end

function GetQueueCount()
    local count = 0

    for indentifier, info in pairs(quePlayers) do
        count = count + 1
    end

    return count
end

Citizen.CreateThread(
    function()
        while true do
            Wait(1000)
            local freeSlots = maxServerSlots - #GetPlayers()

            for indentifier, info in pairs(quePlayers) do
                if info.canConnect then
                    freeSlots = freeSlots - 1
                end
            end

            for indentifier, info in pairs(quePlayers) do
                local position = GetQuePosition(indentifier)
                if freeSlots > 0 and position == 1 then
                    quePlayers[indentifier].canConnect = true
                end
            end
        end
    end
)

AddEventHandler(
    "playerDropped",
    function(reason)
        local _source = source
        local steamIdentifier = GetPlayerIdentifier(_source, 0)

        if steamIdentifier ~= nil then
            exports.logs:sendToDiscord(
                {
                    channel = "pripojeni-odpojeni",
                    title = "Odpojení",
                    description = "Hráč se odpojil ze serveru (" .. reason .. ")",
                    color = "16752384"
                },
                _source
            )

            droppedPlayers[steamIdentifier] = os.time()
            exports.data:removeUserData(steamIdentifier)
        end
    end
)

Citizen.CreateThread(
    function()
        while true do
            Wait(10000)
            local queueCount = GetQueueCount()

            if serverName then
                local newServerName = serverName
                if queueCount > 0 then
                    newServerName = serverName .. " [" .. queueCount .. "] "
                end

                if lastServerName ~= newServerName then
                    lastServerName = newServerName
                    SetConvar("sv_hostname", newServerName)
                end
            else
                local hostname = GetConvar("sv_hostname")
                if hostname ~= "default FXServer" then
                    serverName = hostname
                    maxServerSlots = GetConvarInt("sv_maxclients", 32)
                    SetConvarServerInfo("Fronta", tostring(queueCount))
                    canConnect = true
                end
            end

            SetConvarServerInfo("Fronta", tostring(queueCount))
        end
    end
)

function isPlayerStillConnected(playerSteam)
    local players = GetPlayers()

    for i = 1, #players do
        local steamIdentifier = GetPlayerIdentifier(players[i], 0)
        if steamIdentifier == playerSteam then
            return true
        end
    end

    return false
end

Citizen.CreateThread(
    function()
        while true do
            Wait(1800000)
            local players = exports.data:getUsers()
            local queries = {}

            for _, identifier in each(players) do
                table.insert(queries, {
                    query = "INSERT INTO time_played VALUES (:identifier, NOW(), 1) ON DUPLICATE KEY UPDATE minutes = minutes + 30",
                    values = {
                        identifier = identifier
                    }
                })
            end
            exports.oxmysql:transaction(queries)
        end
    end
)

Citizen.CreateThread(
    function()
        while true do
            Wait(100)
            local loaded = true
            for i = 1, GetNumResources() do
                local res = GetResourceByFindIndex(i)
                if res then
                    local resState = GetResourceState(res)
                    if resState == "missing" or resState == "starting" or resState == "uninitialized" or resState == "unknown" then
                        loaded = false
                        break
                    end
                end
            end

            if loaded then
                resourcesLoaded = true
                break
            end
        end
    end
)
