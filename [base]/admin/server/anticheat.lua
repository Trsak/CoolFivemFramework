local blockedExplosions = { 1, 2, 4, 5, 25, 32, 33, 35, 36, 37, 38 }
local explosionsHistory = {}
local playerObjectSkipCheck = {}
local playerScreenshotTimes = {}
local playerScreenshotTimeout = {}
local playerGodModeChecks = {}
local playerGodModeEnabled = {}
local validResourceList

Citizen.CreateThread(
    function()
        collectValidResourceList()

        for i = 1, #Config.FakeServerEvents do
            local fakeEvent = Config.FakeServerEvents[i]
            RegisterNetEvent(fakeEvent)
            AddEventHandler(
                fakeEvent,
                function()
                    local _source = source
                    banClientForCheating(_source, "0", "Cheating", "Fake event", fakeEvent)
                end
            )

            Citizen.Wait(1)
        end

        while true do
            Citizen.Wait(5000)
            for i = #explosionsHistory, 1, -1 do
                local explosionData = explosionsHistory[i]

                if os.time() > explosionData.time + 30 then
                    table.remove(explosionsHistory, i)
                end
            end
        end
    end
)

AddEventHandler(
    "explosionEvent",
    function(sender, ev)
        if ev.damageScale <= 0 or ev.isInvisible == true or ev.isAudible == false then
            return
        end

        for _, v in each(blockedExplosions) do
            if ev.explosionType == v and ev.damageScale ~= 0.0 and ev.ownerNetId == 0 then
                CancelEvent()

                table.insert(explosionsHistory, { sender = sender, time = os.time() })

                local totalCount = 0
                for _, x in each(explosionsHistory) do
                    if x.sender == sender then
                        totalCount = totalCount + 1
                    end
                end

                if totalCount >= 6 then
                    banClientForCheating(sender, "0", "Cheating", "Vyvolání exploze", json.encode(ev))
                end

                break
            end
        end
    end
)

function banClientForCheating(client, length, reason, reasonLog, description)
    if exports.data:getUserVar(client, "admin") > 1 then
        TriggerClientEvent(
            "chat:addMessage",
            client,
            {
                templateId = "error",
                args = { "Dostal bys ban od anticheatu!" }
            }
        )
        return
    end

    exports.logs:sendToDiscord(
        {
            channel = "cheating",
            title = reasonLog,
            description = description,
            color = "8782097"
        },
        client
    )

    Citizen.CreateThread(
        function()
            Wait(5000)
            if GetPlayerName(client) then
                banPlayer(-1, client, length, reason)
            end
        end
    )

    takePlayerScreenshot(client, reason, function()
        banPlayer(-1, client, length, reason)
    end)
end

function setPlayerObjectSkipCheck(player, value)
    playerObjectSkipCheck[player] = value
end

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(330000)
            local players = GetPlayers()
            local currentTime = os.time()

            for i = 1, #players do
                local playerId = tonumber(players[i])
                if playerScreenshotTimes[playerId] == nil or (currentTime - playerScreenshotTimes[playerId]) > 60 * Config.screenshotsInterval then
                    local playerStatus = exports.data:getUserVar(playerId, "status")

                    if playerStatus == "spawned" or playerStatus == "dead" then
                        if playerScreenshotTimeout[playerId] ~= nil and playerScreenshotTimeout[playerId] > 0 then
                            playerScreenshotTimeout[playerId] = playerScreenshotTimeout[playerId] - 1
                        else
                            takePlayerScreenshot(playerId)
                        end
                    else
                        playerScreenshotTimeout[playerId] = 5
                    end
                end

                if playerGodModeChecks[playerId] == nil then
                    playerGodModeChecks[playerId] = 0
                end

                local passedGodModeCheck = true
                if GetPlayerInvincible(playerId) then
                    if exports.data:getUserVar(playerId, "status") == "spawned" then
                        if playerGodModeEnabled[playerId] ~= true then
                            playerGodModeChecks[playerId] = playerGodModeChecks[playerId] + 1
                            if playerGodModeChecks[playerId] >= 2 then
                                banClientForCheating(playerId, "0", "Cheating", "Nesmrtelnost", "Byla detekována nesmrtelnost")
                            end

                            passedGodModeCheck = false
                        end
                    end
                end

                if passedGodModeCheck then
                    playerGodModeChecks[playerId] = 0
                end

                Citizen.Wait(50)
            end
        end
    end
)

RegisterNetEvent("playerShooting")
AddEventHandler(
    "playerShooting",
    function(player)
        takePlayerScreenshot(player, "Střelba")
    end
)

function takePlayerScreenshot(player, title, cb)
    local currentTime = os.time()

    local dir = "live/"
    if exports.control:isDev() then
        dir = "dev/"
    end

    playerScreenshotTimes[player] = currentTime
    exports["screenshot-basic"]:requestClientScreenshot(
        player,
        {
            fileName = "/home/container/screenshots/" .. dir .. currentTime .. "-" .. player .. ".jpg"
        },
        function(err, data)
            if not err then
                if title == nil then
                    title = "Pravidelný screenshot"
                end

                exports.logs:sendToDiscord(
                    {
                        channel = "screenshots",
                        title = title,
                        screenshot = data,
                        color = "3121663"
                    },
                    player
                )

                if cb then
                    cb(true)
                end
            else
                print(err)

                if cb then
                    cb(false)
                end
            end
        end
    )
end

RegisterNetEvent("admin:playerGodModeWhitelist")
AddEventHandler(
    "admin:playerGodModeWhitelist",
    function(toggle)
        local client = source
        playerGodModeEnabled[client] = toggle
    end
)

RegisterNetEvent("admin:nonAllowedWeapon")
AddEventHandler(
    "admin:nonAllowedWeapon",
    function(weapon)
        local client = source
        banClientForCheating(client, "0", "Cheating", "Má v ruce zbraň kterou nevlastnil", weapon)
    end
)

AddEventHandler(
    "playerDropped",
    function(reason)
        playerObjectSkipCheck[source] = nil
        playerScreenshotTimes[source] = nil
        playerScreenshotTimeout[source] = nil
        playerGodModeChecks[source] = nil
        playerGodModeEnabled[source] = nil
    end
)

function collectValidResourceList()
    validResourceList = {}

    for i = 0, GetNumResources() - 1 do
        validResourceList[GetResourceByFindIndex(i)] = true
    end
end

AddEventHandler("onResourceListRefresh", collectValidResourceList)
RegisterNetEvent("admin:collectAndSendResourceList")
AddEventHandler("admin:collectAndSendResourceList", function(givenList)
    local client = source

    while validResourceList == nil do
        Wait(100)
    end

    local invalidResources = {}
    for _, resource in each(givenList) do
        if not validResourceList[resource] then
            table.insert(invalidResources, resource)
        end
    end

    if #invalidResources > 0 then
        banClientForCheating(client, "0", "Cheating", "Custom resource(s)", json.encode(invalidResources))
    end
end)
