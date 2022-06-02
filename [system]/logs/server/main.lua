RegisterNetEvent("logs:sendToLog")
AddEventHandler(
    "logs:sendToLog",
    function(data)
        local _source = source
        sendToDiscord(data, _source)
    end
)

function sendToDiscord(data, player)
    local webhook
    local playerName = "Systém"
    local playerIdentifiers = {}

    if player then
        playerName = GetPlayerName(player)
        playerIdentifiers = GetPlayerIdentifiers(player)
    end
    local isDev = exports.control:isDev()

    if playerName and playerIdentifiers then
        webhook = Webhooks.Main[data.channel]
        if data.channel == "umrti" then
            exports.admin:takePlayerScreenshot(player, "Zemřel")

            if data.killer and GetPlayerName(data.killer)  then
                exports.admin:takePlayerScreenshot(data.killer, "Zabil hráče " .. playerName .. " (" .. player .. ")")
            end
        end

        local preDescription = ""

        if isDev then
            preDescription = "**DEV SERVER**\n"
            webhook = Webhooks.Dev[data.channel]
        end

        local charData = ""
        local userChar = exports.data:getUserVar(player, "character")
        local userStatus = exports.data:getUserVar(player, "status")
        if player and data.channel ~= "me-do-doc" then
            if userChar and (userStatus == "spawned" or userStatus == "dead") then
                charData = "**Postava**\n" .. userChar.firstname .. " " .. userChar.lastname .. " (" .. userChar.id .. ")\n\n"
                local playerPosition = GetEntityCoords(GetPlayerPed(player))
                charData = charData .. "**Souřadnice**"
                charData = charData ..
                    "\n*/tp " .. playerPosition.x .. " " .. playerPosition.y .. " " .. playerPosition.z .. "*"
                charData = charData .. "\n- **X:** " .. playerPosition.x
                charData = charData .. "\n- **Y:** " .. playerPosition.y
                charData = charData .. "\n- **Z:** " .. playerPosition.z .. "\n\n"
            end
        end

        local description = ""
        if data.description then
            description = tostring(data.description) .. "\n\n\n"
        end

        local embedsData = nil

        local fullDescription = ""
        local playerIdentifiersText = ""
        local steamId = nil
        local license = nil
        local license2 = nil
        local discord = nil
        local xbl = nil
        local liveid = nil
        local ip = nil
        local fivem = nil

        if data.channel ~= "me-do-doc" then
            for _, v in pairs(playerIdentifiers) do
                if string.sub(v, 1, string.len("steam:")) == "steam:" then
                    steamId = v:sub(string.len("steam:") + 1)
                elseif string.sub(v, 1, string.len("license:")) == "license:" then
                    license = v:sub(string.len("license:") + 1)
                elseif string.sub(v, 1, string.len("license2:")) == "license2:" then
                    license = v:sub(string.len("license2:") + 1)
                elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
                    xbl = v:sub(string.len("xbl:") + 1)
                elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
                    ip = v:sub(string.len("ip:") + 1)
                elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
                    discord = v:sub(string.len("discord:") + 1)
                elseif string.sub(v, 1, string.len("live:")) == "live:" then
                    liveid = v:sub(string.len("live:") + 1)
                elseif string.sub(v, 1, string.len("fivem:")) == "fivem:" then
                    liveid = v:sub(string.len("fivem:") + 1)
                end
            end

            if steamId then
                local steamDec = tonumber(steamId, 16)
                playerIdentifiersText = playerIdentifiersText ..
                    "\n- **Steam:** steam:" ..
                    steamId .. " ([zobrazit profil](https://steamcommunity.com/profiles/" .. steamDec .. "))"
            end

            if discord then
                playerIdentifiersText = playerIdentifiersText ..
                    "\n- **Discord:** " ..
                    discord .. " ([zobrazit profil](https://discordapp.com/users/" .. discord .. "/))"
            end

            if ip then
                playerIdentifiersText = playerIdentifiersText .. "\n- **IP:** " .. ip .. " ([informace](https://ip-api.com/#" .. ip .. "))"
            end

            if fivem then
                playerIdentifiersText = playerIdentifiersText .. "\n- **Fivem ID:** " .. fivem
            end

            if license then
                playerIdentifiersText = playerIdentifiersText .. "\n- **Licence:** " .. license
            end

            if license2 then
                playerIdentifiersText = playerIdentifiersText .. "\n- **Licence 2:** " .. license2
            end

            if xbl then
                playerIdentifiersText = playerIdentifiersText .. "\n- **Xbox ID:** " .. xbl
            end

            if live then
                playerIdentifiersText = playerIdentifiersText .. "\n- **Microsoft account ID:** " .. live
            end

            local playerId = ""
            if player then
                playerId = "(" .. player .. ")"
            end

            fullDescription = description ..
                preDescription ..
                "**Hráč**\n" ..
                playerName .. " " .. playerId .. "\n\n" .. charData
            if player then
                fullDescription = fullDescription .. "**Identifikátory**" .. playerIdentifiersText
            end
        else
            fullDescription = data.title .. ": " .. data.description
            data.title = userChar.firstname .. " " .. userChar.lastname .. " (" .. playerName .. ")"
        end

        if data.channel == "screenshots" then
            embedsData = {
                {
                    ["color"] = data.color,
                    ["title"] = data.title,
                    ["description"] = fullDescription,
                    ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                    ["image"] = {
                        ["url"] = "https://server.cz/img" .. data.screenshot:sub(16)
                    }
                }
            }
        else
            embedsData = {
                {
                    ["color"] = data.color,
                    ["title"] = data.title,
                    ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                    ["description"] = fullDescription
                }
            }
        end

        PerformHttpRequest(
            webhook,
            function(err, text, headers)
            end,
            "POST",
            json.encode({ embeds = embedsData }),
            { ["Content-Type"] = "application/json" }
        )
    end
end
