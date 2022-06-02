local reportConverstation = {}
local lastPlyInNeed = nil

RegisterCommand(
    "report",
    function(source, args)
        local _source = source
        local message = table.concat(args, " ")

        if message == "" then
            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "error",
                    args = { "Zadejte text nahlášení!" }
                }
            )
            return
        end

        exports.logs:sendToDiscord(
            {
                channel = "admin-chat",
                title = "Report",
                description = message,
                color = "15859772"
            },
            _source
        )

        local sendToAll = true
        local playerName = GetPlayerName(_source)
        if reportConverstation[_source] ~= nil and reportConverstation[_source].admin ~= nil and GetPlayerName(reportConverstation[_source].admin) then
            sendToAll = false
            TriggerClientEvent(
                "chat:addMessage",
                reportConverstation[_source].admin,
                {
                    templateId = "player-msg",
                    args = { playerName .. " [" .. tostring(_source) .. "] ", message }
                }
            )

            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "to-admin-msg",
                    args = { playerName .. " [" .. tostring(_source) .. "] ", message }
                }
            )
        end

        if sendToAll then
            reportConverstation[_source] = {
                admin = nil
            }

            sendMessageToAdmins(_source, 2, {
                templateId = "report",
                args = {
                    playerName .. " [" .. tostring(_source) .. "] ",
                    message
                }
            })

            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "success",
                    args = {
                        "Report byl odeslán. Vyčkejte, až se s vámi spojí administrátor. Pokud se tak nestane do několika minut, založte si ticket na našem Discordu."
                    }
                }
            )
        end
    end
)

RegisterCommand(
    "tr",
    function(source, args)
        local _source = source
        if exports.data:getUserVar(_source, "admin") > 1 then
            if args[1] ~= nil then
                takeReport(tonumber(args[1]), _source)
            else
                TriggerClientEvent(
                    "chat:addMessage",
                    _source,
                    {
                        templateId = "error",
                        args = { "Použij příkaz /tr <ID> !" }
                    }
                )
            end
        else
            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "error",
                    args = { "Na toto nemáš právo!" }
                }
            )
        end
    end
)

RegisterCommand("r",
    function(source, args)
        local _source = source
        if exports.data:getUserVar(_source, "admin") > 1 then
            if lastPlyInNeed ~= nil then
                respondPlayer(_source, lastPlyInNeed, table.concat(args, " "))
            end
        else
            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "error",
                    args = { "Na toto nemáš právo!" }
                }
            )
        end
    end
)

RegisterCommand("cr",
    function(source, args)
        local _source = source
        if exports.data:getUserVar(_source, "admin") > 1 then
            if lastPlyInNeed ~= nil then
                takeReport(lastPlyInNeed, _source)
            end
        else
            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "error",
                    args = { "Na toto nemáš právo!" }
                }
            )
        end
    end
)

RegisterCommand(
    "respond",
    function(source, args)
        local _source = source
        if exports.data:getUserVar(_source, "admin") > 1 then
            if args[1] and args[2] ~= nil then
                local msg = ""
                for i = 2, #args do
                    msg = msg .. " " .. args[i]
                end
                respondPlayer(_source, tonumber(args[1]), msg)
            end
        else
            TriggerClientEvent(
                "chat:addMessage",
                _source,
                {
                    templateId = "error",
                    args = { "Na toto nemáš právo!" }
                }
            )
        end
    end
)

function respondPlayer(adminId, reportId, message)
    if reportId == nil or message == nil then
        TriggerClientEvent(
            "chat:addMessage",
            adminId,
            {
                templateId = "error",
                args = { "Použij příkaz /respond <ID> <TEXT> !" }
            }
        )
        return
    end

    local playerName = GetPlayerName(reportId)
    if not playerName then
        TriggerClientEvent(
            "chat:addMessage",
            adminId,
            {
                templateId = "error",
                args = { "Zadaný hráč není připojen na serveru!" }
            }
        )

        reportConverstation[reportId] = nil

        if reportId == lastPlyInNeed then
            lastPlyInNeed = nil
        end

        return
    end

    if reportConverstation[reportId] == nil then
        TriggerClientEvent(
            "chat:addMessage",
            adminId,
            {
                templateId = "error",
                args = { "Zadaný hráč o nic nepožádal!" }
            }
        )
        return
    end

    if reportConverstation[reportId].admin == nil then
        takeReport(reportId, adminId)
    end

    if reportConverstation[reportId].admin == adminId then
        TriggerClientEvent(
            "chat:addMessage",
            reportId,
            {
                templateId = "admin-msg",
                args = { GetPlayerName(adminId), message .. " (odpovidej /report)" }
            }
        )

        TriggerClientEvent(
            "chat:addMessage",
            reportConverstation[reportId].admin,
            {
                templateId = "respond",
                args = { playerName .. " [" .. tostring(reportId) .. "] ", message }
            }
        )

        exports.logs:sendToDiscord(
            {
                channel = "admin-chat",
                title = "(RESPOND) Zpráva hráči " .. playerName .. " (" .. reportId .. ")",
                description = message,
                color = "13382451"
            },
            adminId
        )
    else
        TriggerClientEvent(
            "chat:addMessage",
            adminId,
            {
                templateId = "error",
                args = { "Zadaný report již někdo řeší!" }
            }
        )
    end
end

function takeReport(reportId, adminId)
    if reportId == nil then
        TriggerClientEvent(
            "chat:addMessage",
            adminId,
            {
                templateId = "error",
                args = { "Použij příkaz /tr <ID> !" }
            }
        )
        return
    end

    local playerName = GetPlayerName(reportId)
    if not playerName then
        TriggerClientEvent(
            "chat:addMessage",
            adminId,
            {
                templateId = "error",
                args = { "Zadaný hráč není připojen na serveru!" }
            }
        )

        reportConverstation[reportId] = nil

        if reportId == lastPlyInNeed then
            lastPlyInNeed = nil
        end
        return
    end

    if reportConverstation[reportId] == nil then
        TriggerClientEvent(
            "chat:addMessage",
            adminId,
            {
                templateId = "error",
                args = { "Zadaný hráč o nic nepožádal!" }
            }
        )
        return
    else
        local adminName = GetPlayerName(adminId)
        if reportConverstation[reportId].admin == nil then
            exports.logs:sendToDiscord(
                {
                    channel = "admin-chat",
                    title = "Report",
                    description = "Vzal report hráče " .. playerName .. " (" .. reportId .. ")",
                    color = "6591981"
                },
                adminId
            )

            reportConverstation[reportId] = {
                admin = adminId
            }

            sendMessageToAdmins(adminId, 2, {
                templateId = "tr",
                args = {
                    adminName,
                    playerName .. " " .. "[" .. reportId .. "]"
                }
            })
            TriggerClientEvent(
                "chat:addMessage",
                reportId,
                {
                    templateId = "player-tr",
                    args = { adminName }
                }
            )

            lastPlyInNeed = reportId
        elseif reportConverstation[reportId].admin == adminId then
            reportConverstation[reportId] = nil

            sendMessageToAdmins(adminId, 2, {
                templateId = "report-done",
                args = {
                    adminName,
                    playerName .. " " .. "[" .. reportId .. "]"
                }
            })

            TriggerClientEvent(
                "chat:addMessage",
                reportId,
                {
                    templateId = "success",
                    args = { "Report byl uzavřen." }
                }
            )
        else
            local adminName = GetPlayerName(reportConverstation[reportId].admin)
            TriggerClientEvent(
                "chat:addMessage",
                adminId,
                {
                    templateId = "error",
                    args = { "Report již řeší admin: " .. (not adminName and "ODPOJIL SE" or adminName) }
                }
            )
        end
    end

end

function sendMessageToAdmins(_source, minAdmin, data)
    local users = exports.data:getUsersBaseData(
        function(userData)
            return (userData.status ~= "disconnected" and userData.admin >= minAdmin) or userData.source == _source
        end
    )

    for _, userData in each(users) do
        TriggerClientEvent(
            "chat:addMessage",
            userData.source,
            data
        )
    end
end