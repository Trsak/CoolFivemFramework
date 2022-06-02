local isSpawned, isOpened = false, false
local savedChatsetting = 1
local isFocused = false
local scoreboard = nil
local adminLevel = nil

Citizen.CreateThread(
    function()
        Citizen.Wait(500)
        while not exports.data:isUserLoaded() do
            Citizen.Wait(100)
        end
        adminLevel = exports.data:getUserVar("admin")

        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            isSpawned = true
        end
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned = false
        elseif status == "spawned" or status == "dead" then
            isSpawned = true
        end
    end
)

RegisterNetEvent("scoreboard:sync")
AddEventHandler(
    "scoreboard:sync",
    function(scoreboardData)
        while not exports.data:isUserLoaded() do
            Wait(250)
        end

        scoreboard = scoreboardData
        table.sort(scoreboard.players, sortPlayers)

        updateRichPresence()

        SendNUIMessage(
            {
                action = "refresh",
                data = scoreboard,
                adminLevel = adminLevel
            }
        )
    end
)

RegisterNetEvent("scoreboard:addUser")
AddEventHandler(
    "scoreboard:addUser",
    function(user)
        if not scoreboard then
            return
        end

        table.insert(scoreboard.players, user)

        scoreboard.currentPlayers = #scoreboard.players
        table.sort(scoreboard.players, sortPlayers)

        updateRichPresence()

        SendNUIMessage(
            {
                action = "refresh",
                data = scoreboard,
                adminLevel = adminLevel
            }
        )
    end
)

RegisterNetEvent("scoreboard:removeUser")
AddEventHandler(
    "scoreboard:removeUser",
    function(user)
        if not scoreboard then
            return
        end
        
        for i, data in each(scoreboard.players) do
            if user == data.source then
                table.remove(scoreboard.players, i)
                break
            end
        end
        scoreboard.currentPlayers = #scoreboard.players
        table.sort(scoreboard.players, sortPlayers)

        updateRichPresence()

        SendNUIMessage(
            {
                action = "refresh",
                data = scoreboard,
                adminLevel = adminLevel
            }
        )
    end
)

RegisterNetEvent("scoreboard:jobChanged")
AddEventHandler(
    "scoreboard:jobChanged",
    function(job, duty)
        if not scoreboard then
            return
        end

        scoreboard.jobCounts[job] = scoreboard.jobCounts[job] + (duty and 1 or -1)

        SendNUIMessage(
            {
                action = "jobs",
                counts = scoreboard.jobCounts
            }
        )
    end
)

RegisterCommand(
    "+scoreboard",
    function()
        if not IsPauseMenuActive() then
            if isSpawned and not isOpened then
                savedChatsetting = exports.settings:getSettingValue("chat")
                exports.settings:changeSetting("chat", 3)

                isOpened = true
                isFocused = false
                SendNUIMessage(
                    {
                        action = "show"
                    }
                )
                while isOpened do
                    if not isFocused then
                        DisableControlAction(0, 18)
                        DisableControlAction(0, 24)
                        DisableControlAction(0, 69)
                        DisableControlAction(0, 25)
                        DisableControlAction(0, 68)
                        DisableControlAction(0, 70)
                    end

                    if not isFocused and IsDisabledControlJustReleased(0, 25) then
                        isFocused = true
                        SetNuiFocus(true, true)
                    end

                    Wait(1)
                end
            end
        end
    end
)

RegisterCommand(
    "-scoreboard",
    function()
        if isOpened and not isFocused then
            closeScoreboard()
        end
    end
)

createNewKeyMapping({command = "+scoreboard", text = "Tabulka hráčů", key = "F10"})

function sortPlayers(a, b)
    return a.source < b.source
end

function updateRichPresence()
    if not scoreboard then
        return
    end
    SetDiscordAppId(815211329987018763)

    SetRichPresence(scoreboard.name .. " (" .. scoreboard.currentPlayers .. "/" .. scoreboard.maxPlayers .. ")")
    SetDiscordRichPresenceAsset("logo")
    SetDiscordRichPresenceAssetText("server.cz | Join us")
    SetDiscordRichPresenceAssetSmall("info")
    SetDiscordRichPresenceAssetSmallText("Whitelist: server.cz")
    SetDiscordRichPresenceAction(0, "server.cz Web", "https://server.cz/")
    SetDiscordRichPresenceAction(1, "server.cz Discord", "https://discord.gg/Eb3rH7c")
end

function closeScoreboard()
    if isFocused then
        SetNuiFocus(false, false)
        isFocused = false
    end

    isOpened = false
    SendNUIMessage(
        {
            action = "hide"
        }
    )
    exports.settings:changeSetting("chat", savedChatsetting)
end

RegisterNUICallback(
    "closeMenu",
    function(data, cb)
        closeScoreboard()

        local openPlayer = tonumber(data.openPlayer)
        if openPlayer then
            if exports.data:getUserVar("admin") > 1 then
                ExecuteCommand("adminmenu " .. openPlayer)
            end
        end

        cb("ok")
    end
)