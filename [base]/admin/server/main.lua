local spectateTargets = {}
local stopSpectating = {}

RegisterNetEvent("admin:getFirstEntityOwner")
AddEventHandler("admin:getFirstEntityOwner", function(netId)
    local client = source
    if exports.data:getUserVar(client, "admin") > 1 then
        local entity = NetworkGetEntityFromNetworkId(netId)
        if DoesEntityExist(entity) then
            local firstOwner = NetworkGetFirstEntityOwner(entity)
            if firstOwner then
                local name = GetPlayerName(firstOwner)
                TriggerClientEvent("chat:addMessage", client, {
                    templateId = "success",
                    args = { "První majitel entity je " .. name .. "(" .. firstOwner .. ")" }
                })
            else
                TriggerClientEvent("chat:addMessage", client, {
                    templateId = "error",
                    args = { "Někde nastala chyba!" }
                })
            end
        else
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "error",
                args = { "Někde nastala chyba!" }
            })
        end
    end
end)

RegisterCommand("giveweapon", function(source, args)
    if exports.data:getUserVar(source, "admin") > 1 then
        if not args[1] or not tonumber(args[1]) then
            TriggerClientEvent("chat:addMessage", source, {
                templateId = "error",
                args = { "Musíš zadat ID hráče!" }
            })
        elseif not args[2] then
            TriggerClientEvent("chat:addMessage", source, {
                templateId = "error",
                args = { "Musíš zadat zbraň!" }
            })
        elseif not args[3] or not tonumber(args[3]) then
            TriggerClientEvent("chat:addMessage", source, {
                templateId = "error",
                args = { "Musíš zadat počet nábojů!" }
            })
        else
            local id = tonumber(args[1])

            if GetPlayerName(id) then
                if exports.data:getUserVar(id, "status") ~= "connecting" and exports.data:getUserVar(id, "status") ~=
                    "choosing" then
                    local weaponName = string.lower(args[2])
                    local item = exports.inventory:getItem(weaponName)

                    if item and item.type == "weapon" then
                        local number = exports.base_shops:generateSerialNumber()
                        if args[4] == "ne" or not args[4] then
                            data = {
                                id = number,
                                number = number,
                                time = os.time(),
                                label = "Seriové číslo: " .. number .. "<br>Datum vydání: " ..
                                    os.date("%x", os.time())
                            }
                        else
                            data = {
                                id = number,
                                label = "Zbraň nemá sériové číslo"
                            }
                        end

                        local reason = exports.inventory:addPlayerItem(id, weaponName, tonumber(args[3]), data)

                        if reason == "done" then
                            TriggerClientEvent("chat:addMessage", source, {
                                templateId = "success",
                                args = { "Hráč obdržel " .. item.label .. " s " .. args[3] .. " náboji" }
                            })

                            exports.logs:sendToDiscord({
                                channel = "admin-commands",
                                title = "Zbraň",
                                description = "Dal hráči " .. GetPlayerName(id) .. " (" .. id .. ") " .. item.label ..
                                    " s " .. args[3] .. " náboji",
                                color = "34749"
                            }, source)
                        else
                            if reason == "weightExceeded" then
                                TriggerClientEvent("chat:addMessage", source, {
                                    templateId = "error",
                                    args = { "U hráče by došlo k překročení maximální váhy!" }
                                })
                            elseif reason == "spaceExceeded" then
                                TriggerClientEvent("chat:addMessage", source, {
                                    templateId = "error",
                                    args = { "Hráč nemá místo v inventáři!" }
                                })
                            else
                                TriggerClientEvent("chat:addMessage", source, {
                                    templateId = "error",
                                    args = { "Nastala chyba (" .. reason .. ")!" }
                                })
                            end
                        end
                    else
                        TriggerClientEvent("chat:addMessage", source, {
                            templateId = "error",
                            args = { "Zadaná zbraň neexistuje, nebo není povolena!" }
                        })
                    end
                else
                    TriggerClientEvent("chat:addMessage", source, {
                        templateId = "error",
                        args = { "Zadaný hráč není plně připojen!" }
                    })
                end
            else
                TriggerClientEvent("chat:addMessage", source, {
                    templateId = "error",
                    args = { "Zadaný hráč nebyl nalezen!" }
                })
            end
        end
    else
        TriggerClientEvent("chat:addMessage", source, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    end
end)

RegisterCommand("findItem", function(source, args)
    local client = source
    if exports.data:getUserVar(client, "admin") > 1 then
        if args[1] then
            local search = (args[1]):lower()
            local items = exports.inventory:getItems()

            local toSend = {}
            for _, data in pairs(items) do
                if string.find(data.name, search) or string.find(data.label:lower(), search) then
                    table.insert(toSend, data.label .. " - " .. data.name)
                end
            end

            TriggerClientEvent("chat:addMessage", client, {
                template = "<div style='background-color: rgba(178, 100, 60, 0.75); float:left; border-left: 10px solid rgb(178, 100, 60); color: white; padding: 0.5vw; margin: 0.25vw;'>Předměty: " ..
                    table.concat(toSend, ", ") .. "</div>"
            })

        else
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "error",
                args = { "Musíš zadat část názvu předmětu!" }
            })
        end
    else
        TriggerClientEvent("chat:addMessage", client, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    end
end)

RegisterCommand("findPlayer", function(source, args)
    local client = source
    if exports.data:getUserVar(client, "admin") > 1 then
        if args[1] then
            local search = (args[1]):lower()
            local players = GetPlayers()

            local toSend = {}
            for _, serverId in each(players) do
                local playerNick = GetPlayerName(serverId)
                if string.find(playerNick:lower(), search) then
                    table.insert(toSend, playerNick .. " - " .. serverId)
                end
            end

            TriggerClientEvent("chat:addMessage", client, {
                template = "<div style='background-color: rgba(178, 100, 60, 0.75); float:left; border-left: 10px solid rgb(178, 100, 60); color: white; padding: 0.5vw; margin: 0.25vw;'>Hráči: " ..
                    table.concat(toSend, ", ") .. "</div>"
            })

        else
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "error",
                args = { "Musíš zadat nick nebo část nicku!" }
            })
        end
    else
        TriggerClientEvent("chat:addMessage", client, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    end
end)

RegisterCommand("cleararea", function(source, args)
    if exports.data:getUserVar(source, "admin") > 1 then
        TriggerClientEvent("admin:clearArea", -1, GetEntityCoords(GetPlayerPed(source)))
        exports.logs:sendToDiscord({
            channel = "admin-commands",
            title = "Clear Area",
            description = "Použil clear area!",
            color = "34749"
        }, source)
    else
        TriggerClientEvent("chat:addMessage", source, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    end
end)

RegisterCommand("charselect", function(source, args)
    local client = source
    if exports.data:getUserVar(source, "admin") > 1 then
        local playerId = nil

        if not args[1] then
            playerId = client
        else
            if not tonumber(args[1]) or not GetPlayerName(tonumber(args[1])) then
                TriggerClientEvent("chat:addMessage", client, {
                    templateId = "error",
                    args = { "Zadaný hráč nebyl nalezen!" }
                })
            else
                playerId = tonumber(args[1])
            end
        end

        if playerId then
            exports.chars:startCharSelect(playerId)
        end
    else
        TriggerClientEvent("chat:addMessage", client, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    end
end)

RegisterCommand("spectate", function(source, args)
    local client = source
    if exports.data:getUserVar(source, "admin") > 1 then
        if not tonumber(args[1]) or not GetPlayerName(tonumber(args[1])) then
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "error",
                args = { "Zadaný hráč nebyl nalezen!" }
            })
        elseif tonumber(args[1]) == client then
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "error",
                args = { "Nemůžeš sledovat sám sebe!" }
            })
        else
            local target = tonumber(args[1])
            local targetped = GetPlayerPed(target)
            TriggerClientEvent("admin:spectate", client, target, GetEntityCoords(targetped))
        end
    else
        TriggerClientEvent("chat:addMessage", client, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    end
end)

RegisterCommand("kick", function(source, args)
    local client = source
    if exports.data:getUserVar(source, "admin") > 1 then
        if not args[1] or not tonumber(args[1]) then
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "error",
                args = { "Musíš zadat ID hráče!" }
            })
        elseif not GetPlayerName(tonumber(args[1])) then
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "error",
                args = { "Zadaný hráč nebyl nalezen!" }
            })
        elseif not args[2] then
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "error",
                args = { "Musíš zadat důvod vyhození!" }
            })
        else
            local reason = args[2]
            for i = 3, #args do
                reason = reason .. " " .. args[i]
            end

            local playerName = GetPlayerName(tonumber(args[1]))
            local adminName = GetPlayerName(client)

            exports.logs:sendToDiscord({
                channel = "admin-commands",
                title = "Vyhození hráče",
                description = "Vyhodil hráče " .. playerName .. " (" .. args[1] .. ") s důvodem: " .. reason,
                color = "9109504"
            }, client)

            TriggerClientEvent("chat:addMessage", client, {
                template = '<div style="float: left; padding: 10px; margin: 5px; background-color: rgba(255, 40, 0, 0.75); border-left: 10px solid rgb(255, 40, 0);">Vyhodil jsi hráče <strong>{0}</strong></div>',
                args = { playerName }
            })
            DropPlayer(args[1], "Byl jsi vyhozen adminem " .. adminName .. "!\nDůvod: " .. reason)
        end
    else
        TriggerClientEvent("chat:addMessage", client, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    end
end)

RegisterCommand("instance", function(source, args)
    local client = source
    if exports.data:getUserVar(source, "admin") > 1 then
        if not args[1] or not tonumber(args[1]) then
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "error",
                args = { "Musíš zadat ID hráče!" }
            })
        elseif not GetPlayerName(tonumber(args[1])) then
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "error",
                args = { "Zadaný hráč nebyl nalezen!" }
            })
        else
            local instanceName = exports.instance:getPlayerInstance(tonumber(args[1]))
            if instanceName == "" or not instanceName then
                instanceName = "Žádná"
            end

            TriggerClientEvent("chat:addMessage", client, {
                template = "<div style='background-color: rgba(178, 100, 60, 0.75); float:left; border-left: 10px solid rgb(178, 100, 60); color: white; padding: 0.5vw; margin: 0.25vw;'>Hráč <b>{0}</b> je v instanci <b>{1}</b></div>",
                args = { GetPlayerName(tonumber(args[1])), instanceName }
            })
        end
    else
        TriggerClientEvent("chat:addMessage", client, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    end
end)

RegisterCommand("ban", function(source, args)
    local client = source
    if exports.data:getUserVar(source, "admin") > 1 then
        if not args[1] or not tonumber(args[1]) then
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "error",
                args = { "Musíš zadat ID hráče!" }
            })
        elseif not args[2] then
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "error",
                args = { "Musíš zadat délku banu!" }
            })
        elseif not args[3] then
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "error",
                args = { "Musíš zadat důvod banu!" }
            })
        else
            local reason = args[3]
            for i = 4, #args do
                reason = reason .. " " .. args[i]
            end

            banPlayer(client, args[1], args[2], reason)
        end
    else
        TriggerClientEvent("chat:addMessage", client, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    end
end)

RegisterCommand("openinventory", function(source, args)
    local client = source
    if exports.data:getUserVar(client, "admin") > 1 then
        if not args[1] or not tonumber(args[1]) then
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "error",
                args = { "Musíš zadat ID hráče!" }
            })
        else
            local id = tonumber(args[1])

            if id == client then
                TriggerClientEvent("chat:addMessage", client, {
                    templateId = "error",
                    args = { "Nemůžeš otevřít svůj inventář!" }
                })
            elseif GetPlayerName(id) then
                TriggerClientEvent("inventory:openPlayerInventory", client, tonumber(args[1]))

                exports.logs:sendToDiscord({
                    channel = "admin-commands",
                    title = "Otevření inventáře",
                    description = "Otevřel inventář hráče " .. GetPlayerName(id) .. " (" .. id .. ")",
                    color = "34749"
                }, source)
            else
                TriggerClientEvent("chat:addMessage", client, {
                    templateId = "error",
                    args = { "Zadaný hráč nebyl nalezen!" }
                })
            end
        end
    else
        TriggerClientEvent("chat:addMessage", client, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    end
end)

RegisterCommand("setjob", function(source, args)
    local client = source
    if exports.data:getUserVar(source, "admin") > 1 then
        if not args[1] or not tonumber(args[1]) then
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "error",
                args = { "Musíš zadat ID hráče!" }
            })
        elseif not args[2] then
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "error",
                args = { "Musíš zadat název zaměstnání!" }
            })
        elseif not args[3] or not tonumber(args[3]) then
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "error",
                args = { "Musíš zadat hodnost!" }
            })
        else
            local id = tonumber(args[1])
            if GetPlayerName(id) then
                local jobData = exports.base_jobs:getJob(args[2])
                if not jobData then
                    TriggerClientEvent("chat:addMessage", client, {
                        templateId = "error",
                        args = { "Zadaná práce neexistuje!" }
                    })
                elseif not exports.base_jobs:getJobGradeVar(args[2], tonumber(args[3]), "salary") then
                    TriggerClientEvent("chat:addMessage", client, {
                        templateId = "error",
                        args = { "Zadaná pozice neexistuje!" }
                    })
                else
                    if exports.data:getUserVar(id, "status") ~= "connecting" and exports.data:getUserVar(id, "status") ~=
                        "choosing" then
                        local playerJobs = exports.data:getCharVar(id, "jobs")
                        local alreadyInJob = false

                        for i, jobData in each(playerJobs) do
                            if jobData.job == args[2] then
                                alreadyInJob = true
                                playerJobs[i].job_grade = tonumber(args[3])
                                break
                            end
                        end

                        if not alreadyInJob then
                            if not playerJobs then
                                playerJobs = {}
                            end

                            table.insert(playerJobs, {
                                ["job"] = args[2],
                                ["job_grade"] = tonumber(args[3]),
                                ["duty"] = false
                            })
                        end

                        exports.data:updateCharVar(id, "jobs", playerJobs)
                        TriggerClientEvent("chat:addMessage", client, {
                            templateId = "success",
                            args = { "Práce byla úspěně nastavena" }
                        })

                        exports.logs:sendToDiscord({
                            channel = "admin-commands",
                            title = "Práce",
                            description = "Nastavil hráči " .. GetPlayerName(id) .. " (" .. id .. ") práci " ..
                                jobData.label .. " - " .. args[3],
                            color = "34749"
                        }, source)
                    else
                        TriggerClientEvent("chat:addMessage", client, {
                            templateId = "error",
                            args = { "Zadaný hráč není plně připojen!" }
                        })
                    end
                end
            else
                TriggerClientEvent("chat:addMessage", client, {
                    templateId = "error",
                    args = { "Zadaný hráč nebyl nalezen!" }
                })
            end
        end
    else
        TriggerClientEvent("chat:addMessage", client, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    end
end)

RegisterCommand("setdutyjob", function(source, args)
    local client = source
    if exports.data:getUserVar(source, "admin") > 1 then
        if not args[1] or not tonumber(args[1]) then
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "error",
                args = { "Musíš zadat ID hráče!" }
            })
        elseif not args[2] then
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "error",
                args = { "Musíš zadat název zaměstnání!" }
            })
        else
            local id = tonumber(args[1])
            if GetPlayerName(id) then
                local jobData = exports.base_jobs:getJob(args[2])
                if not jobData then
                    TriggerClientEvent("chat:addMessage", client, {
                        templateId = "error",
                        args = { "Zadaná práce neexistuje!" }
                    })
                else
                    if exports.data:getUserVar(id, "status") ~= "connecting" and exports.data:getUserVar(id, "status") ~=
                        "choosing" then
                        local playerJobs = exports.data:getCharVar(id, "jobs")
                        local alreadyInJob = false
                        local setOn = true
                        if args[3] and string.lower(args[3]) == "off" then
                            setOn = false
                        end

                        for i, jobData in each(playerJobs) do
                            if jobData.job == args[2] then
                                alreadyInJob = true
                                playerJobs[i].duty = setOn
                            elseif setOn then
                                playerJobs[i].duty = false
                            end
                        end

                        if not alreadyInJob then
                            TriggerClientEvent("chat:addMessage", client, {
                                templateId = "error",
                                args = { "Takovou práci hráč nemá!" }
                            })
                            return
                        end

                        exports.data:updateCharVar(id, "jobs", playerJobs)
                        TriggerClientEvent("chat:addMessage", client, {
                            templateId = "success",
                            args = { "Hráči byla nastavena služba ve zvolené práci" }
                        })

                        exports.logs:sendToDiscord({
                            channel = "admin-commands",
                            title = "Práce",
                            description = "Nastavil hráči " .. GetPlayerName(id) .. " (" .. id .. ") službu na " ..
                                tostring(setOn) .. " pro " .. args[2],
                            color = "34749"
                        }, source)
                    else
                        TriggerClientEvent("chat:addMessage", client, {
                            templateId = "error",
                            args = { "Zadaný hráč není plně připojen!" }
                        })
                    end
                end
            else
                TriggerClientEvent("chat:addMessage", client, {
                    templateId = "error",
                    args = { "Zadaný hráč nebyl nalezen!" }
                })
            end
        end
    else
        TriggerClientEvent("chat:addMessage", client, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    end
end)

RegisterCommand("removejob", function(source, args)
    local client = source
    if exports.data:getUserVar(source, "admin") > 1 then
        if not args[1] or not tonumber(args[1]) then
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "error",
                args = { "Musíš zadat ID hráče!" }
            })
        elseif not args[2] then
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "error",
                args = { "Musíš zadat název zaměstnání!" }
            })
        else
            local id = tonumber(args[1])
            if GetPlayerName(id) then
                local jobData = exports.base_jobs:getJob(args[2])
                if not jobData then
                    TriggerClientEvent("chat:addMessage", client, {
                        templateId = "error",
                        args = { "Zadaná práce neexistuje!" }
                    })
                else
                    if exports.data:getUserVar(id, "status") ~= "connecting" and exports.data:getUserVar(id, "status") ~=
                        "choosing" then
                        local playerJobs = exports.data:getCharVar(id, "jobs")
                        local hasJob = false

                        for i, jobData in each(playerJobs) do
                            if jobData.job == args[2] then
                                hasJob = true
                                table.remove(playerJobs, i)
                                break
                            end
                        end

                        if not hasJob then
                            TriggerClientEvent("chat:addMessage", client, {
                                templateId = "error",
                                args = { "Hráč nemá toto zaměstnání!" }
                            })
                        else
                            exports.data:updateCharVar(id, "jobs", playerJobs)
                            TriggerClientEvent("chat:addMessage", client, {
                                templateId = "success",
                                args = { "Práce byla úspěně odebrána" }
                            })

                            exports.logs:sendToDiscord({
                                channel = "admin-commands",
                                title = "Práce",
                                description = "Odebral hráči " .. GetPlayerName(id) .. " (" .. id .. ") práci " ..
                                    jobData.label,
                                color = "34749"
                            }, source)
                        end
                    else
                        TriggerClientEvent("chat:addMessage", client, {
                            templateId = "error",
                            args = { "Zadaný hráč není plně připojen!" }
                        })
                    end
                end
            else
                TriggerClientEvent("chat:addMessage", client, {
                    templateId = "error",
                    args = { "Zadaný hráč nebyl nalezen!" }
                })
            end
        end
    else
        TriggerClientEvent("chat:addMessage", client, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    end
end)

RegisterCommand("givelicense", function(source, args)
    if exports.data:getUserVar(source, "admin") > 1 then
        if not args[1] or not tonumber(args[1]) then
            TriggerClientEvent("chat:addMessage", source, {
                templateId = "error",
                args = { "Musíš zadat ID hráče!" }
            })
        elseif not args[2] then
            TriggerClientEvent("chat:addMessage", source, {
                templateId = "error",
                args = { "Musíš zadat název licence!" }
            })
        else
            local id = tonumber(args[1])
            if GetPlayerName(id) then
                if exports.data:getUserVar(id, "status") ~= "connecting" and exports.data:getUserVar(id, "status") ~=
                    "choosing" then
                    exports.license:addLicenseToChar({
                        char = exports.data:getCharVar(id, "id"),
                        test = args[2],
                        source = id,
                        license = {
                            status = "done",
                            blocked = 0,
                            points = 5
                        }
                    })

                    TriggerClientEvent("chat:addMessage", source, {
                        templateId = "success",
                        args = { "Licence byla úspěšně nastavena" }
                    })

                    exports.logs:sendToDiscord({
                        channel = "admin-commands",
                        title = "Licence",
                        description = "Dal hráči " .. GetPlayerName(id) .. " (" .. id .. ") licenci " .. args[2],
                        color = "34749"
                    }, source)
                else
                    TriggerClientEvent("chat:addMessage", source, {
                        templateId = "error",
                        args = { "Zadaný hráč není plně připojen!" }
                    })
                end
            else
                TriggerClientEvent("chat:addMessage", source, {
                    templateId = "error",
                    args = { "Zadaný hráč nebyl nalezen!" }
                })
            end
        end
    else
        TriggerClientEvent("chat:addMessage", source, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    end
end)

RegisterCommand("skinmenu", function(source, args)
    if exports.data:getUserVar(source, "admin") > 1 then
        if not args[1] or not tonumber(args[1]) then
            TriggerClientEvent("chat:addMessage", source, {
                templateId = "error",
                args = { "Musíš zadat ID hráče!" }
            })
        else
            local id = tonumber(args[1])
            if GetPlayerName(id) then
                TriggerClientEvent("admin:skinmenu", id)

                exports.logs:sendToDiscord({
                    channel = "admin-commands",
                    title = "Skinmenu",
                    description = "Otevřel hráči " .. GetPlayerName(id) .. " (" .. id .. ") skinmenu",
                    color = "34749"
                }, source)
            else
                TriggerClientEvent("chat:addMessage", source, {
                    templateId = "error",
                    args = { "Zadaný hráč nebyl nalezen!" }
                })
            end
        end
    else
        TriggerClientEvent("chat:addMessage", source, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    end
end)

RegisterCommand("setuservar", function(source, args)
    if exports.data:getUserVar(source, "admin") > 1 then
        if not args[1] or not tonumber(args[1]) then
            TriggerClientEvent("chat:addMessage", source, {
                templateId = "error",
                args = { "Musíš zadat ID hráče!" }
            })
        elseif not args[2] then
            TriggerClientEvent("chat:addMessage", source, {
                templateId = "error",
                args = { "Musíš zadat Variable!" }
            })
        elseif not args[3] then
            TriggerClientEvent("chat:addMessage", source, {
                templateId = "error",
                args = { "Musíš zadat hodnotu!" }
            })
        else
            local id = tonumber(args[1])
            if GetPlayerName(id) then
                exports.data:updateUserVar(id, args[2], args[3])
                TriggerClientEvent("chat:addMessage", source, {
                    templateId = "success",
                    args = { "Proměnná byla úspěšně nastavena" }
                })

                exports.logs:sendToDiscord({
                    channel = "admin-commands",
                    title = "Uživatelská proměnná",
                    description = "Nastavil hráči " .. GetPlayerName(id) .. " (" .. id .. ") proměnnou " .. args[2] ..
                        " " .. args[3],
                    color = "34749"
                }, source)
            else
                TriggerClientEvent("chat:addMessage", source, {
                    templateId = "error",
                    args = { "Zadaný hráč není plně připojen!" }
                })
            end
        end
    else
        TriggerClientEvent("chat:addMessage", source, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    end
end)

RegisterCommand("setcharvar", function(source, args)
    if exports.data:getUserVar(source, "admin") > 1 then
        if not args[1] or not tonumber(args[1]) then
            TriggerClientEvent("chat:addMessage", source, {
                templateId = "error",
                args = { "Musíš zadat ID hráče!" }
            })
        elseif not args[2] then
            TriggerClientEvent("chat:addMessage", source, {
                templateId = "error",
                args = { "Musíš zadat Variable!" }
            })
        elseif not args[3] then
            TriggerClientEvent("chat:addMessage", source, {
                templateId = "error",
                args = { "Musíš zadat hodnotu!" }
            })
        else
            local id = tonumber(args[1])
            if GetPlayerName(id) then
                exports.data:updateCharVar(id, args[2], args[3])
                TriggerClientEvent("chat:addMessage", source, {
                    templateId = "success",
                    args = { "Proměnná byla úspěšně nastavena" }
                })

                exports.logs:sendToDiscord({
                    channel = "admin-commands",
                    title = "Character proměnná",
                    description = "Nastavil hráči " .. GetPlayerName(id) .. " (" .. id .. ") proměnnou " .. args[2] ..
                        " " .. args[3],
                    color = "34749"
                }, source)
            else
                TriggerClientEvent("chat:addMessage", source, {
                    templateId = "error",
                    args = { "Zadaný hráč není připojen!" }
                })
            end
        end
    else
        TriggerClientEvent("chat:addMessage", source, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    end
end)

RegisterCommand("setskill", function(source, args)
    if exports.data:getUserVar(source, "admin") > 1 then
        if not args[1] or not tonumber(args[1]) then
            TriggerClientEvent("chat:addMessage", source, {
                templateId = "error",
                args = { "Musíš zadat ID hráče!" }
            })
        elseif not args[2] then
            TriggerClientEvent("chat:addMessage", source, {
                templateId = "error",
                args = { "Musíš zadat skill!" }
            })
        elseif not args[3] then
            TriggerClientEvent("chat:addMessage", source, {
                templateId = "error",
                args = { "Musíš zadat hodnotu!" }
            })
        else
            local id = tonumber(args[1])
            if GetPlayerName(id) then
                TriggerClientEvent("admin:setskill", id, args[2], tonumber(args[3]))
                TriggerClientEvent("chat:addMessage", source, {
                    templateId = "success",
                    args = { "Proměnná byla úspěšně nastavena" }
                })

                exports.logs:sendToDiscord({
                    channel = "admin-commands",
                    title = "Nastavení skillu",
                    description = "Nastavil hráči " .. GetPlayerName(id) .. " (" .. id .. ") skill " .. args[2] .. " " ..
                        args[3],
                    color = "34749"
                }, source)
            else
                TriggerClientEvent("chat:addMessage", source, {
                    templateId = "error",
                    args = { "Zadaný hráč není připojen!" }
                })
            end
        end
    else
        TriggerClientEvent("chat:addMessage", source, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    end
end)

RegisterCommand("screenshot", function(source, args)
    if exports.data:getUserVar(source, "admin") > 1 then
        if not args[1] or not tonumber(args[1]) then
            TriggerClientEvent("chat:addMessage", source, {
                templateId = "error",
                args = { "Musíš zadat ID hráče!" }
            })
        else
            local id = tonumber(args[1])
            if GetPlayerName(id) then
                takePlayerScreenshot(id, "Vyvolaný screenshot")
                TriggerClientEvent("chat:addMessage", source, {
                    templateId = "success",
                    args = { "Hráče jsi vyfotil a fotografie byla odeslána na Discord" }
                })

                exports.logs:sendToDiscord({
                    channel = "admin-commands",
                    title = "Screenshot",
                    description = "Vyvolal screenshot hráče " .. GetPlayerName(id) .. " (" .. id .. ")",
                    color = "34749"
                }, source)
            else
                TriggerClientEvent("chat:addMessage", source, {
                    templateId = "error",
                    args = { "Zadaný hráč není připojen!" }
                })
            end
        end
    else
        TriggerClientEvent("chat:addMessage", source, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    end
end)

RegisterCommand("getuservar", function(source, args)
    if exports.data:getUserVar(source, "admin") > 1 then
        if not args[1] or not tonumber(args[1]) then
            TriggerClientEvent("chat:addMessage", source, {
                templateId = "error",
                args = { "Musíš zadat ID hráče!" }
            })
        elseif not args[2] then
            TriggerClientEvent("chat:addMessage", source, {
                templateId = "error",
                args = { "Musíš zadat Variable!" }
            })
        else
            local id = tonumber(args[1])
            if GetPlayerName(id) then
                TriggerClientEvent("chat:addMessage", source, {
                    template = "<div style='background-color: rgba(178, 100, 60, 0.75); float:left; border-left: 10px solid rgb(178, 100, 60); color: white; padding: 0.5vw; margin: 0.25vw;'><b>{0} ({1})</b>: {2} = {3}</div>",
                    args = { GetPlayerName(id), id, tostring(args[2]), tostring(exports.data:getUserVar(id, args[2])) }
                })

                exports.logs:sendToDiscord({
                    channel = "admin-commands",
                    title = "Uživatelská proměnná",
                    description = "Zjistil u hráče " .. GetPlayerName(id) .. " (" .. id .. ") proměnnou " .. args[2],
                    color = "34749"
                }, source)
            else
                TriggerClientEvent("chat:addMessage", source, {
                    templateId = "error",
                    args = { "Zadaný hráč není připojen!" }
                })
            end
        end
    else
        TriggerClientEvent("chat:addMessage", source, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    end
end)

RegisterCommand("getcharvar", function(source, args)
    if exports.data:getUserVar(source, "admin") > 1 then
        if not args[1] or not tonumber(args[1]) then
            TriggerClientEvent("chat:addMessage", source, {
                templateId = "error",
                args = { "Musíš zadat ID hráče!" }
            })
        elseif not args[2] then
            TriggerClientEvent("chat:addMessage", source, {
                templateId = "error",
                args = { "Musíš zadat Variable!" }
            })
        else
            local id = tonumber(args[1])
            if GetPlayerName(id) then
                TriggerClientEvent("chat:addMessage", source, {
                    template = "<div style='background-color: rgba(178, 100, 60, 0.75); float:left; border-left: 10px solid rgb(178, 100, 60); color: white; padding: 0.5vw; margin: 0.25vw;'><b>{0} ({1}) [{2} {3}]</b>: {4} = {5}</div>",
                    args = { GetPlayerName(id), id, exports.data:getCharVar(id, "firstname"),
                             exports.data:getCharVar(id, "lastname"), tostring(args[2]),
                             tostring(exports.data:getCharVar(id, args[2])) }
                })

                exports.logs:sendToDiscord({
                    channel = "admin-commands",
                    title = "Character proměnná",
                    description = "Zjistil u hráče " .. GetPlayerName(id) .. " (" .. id .. ") proměnnou " .. args[2],
                    color = "34749"
                }, source)
            else
                TriggerClientEvent("chat:addMessage", source, {
                    templateId = "error",
                    args = { "Zadaný hráč není připojen!" }
                })
            end
        end
    else
        TriggerClientEvent("chat:addMessage", source, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    end
end)

RegisterCommand("revive", function(source, args)
    local client = source
    if exports.data:getUserVar(client, "admin") > 1 then
        local target = client

        if args[1] then
            target = tonumber(args[1])

            if not target then
                TriggerClientEvent("chat:addMessage", source, {
                    templateId = "error",
                    args = { "Špatně zadané ID hráče!" }
                })
            end
        end

        if GetPlayerName(target) then
            if exports.data:getUserVar(target, "status") == "dead" then
                exports.data:updateUserVar(target, "status", "spawned")
                TriggerClientEvent("chat:addMessage", source, {
                    templateId = "success",
                    args = { "Hráč byl oživen" }
                })

                exports.logs:sendToDiscord({
                    channel = "admin-commands",
                    title = "Oživení",
                    description = "Oživil hráče " .. GetPlayerName(target) .. " (" .. target .. ")",
                    color = "34749"
                }, source)
            else
                TriggerClientEvent("chat:addMessage", source, {
                    templateId = "error",
                    args = { "Hráč není mrtvý!" }
                })
            end
        else
            TriggerClientEvent("chat:addMessage", source, {
                templateId = "error",
                args = { "Zadaný hráč nebyl nalezen!" }
            })
        end
    else
        TriggerClientEvent("chat:addMessage", source, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    end
end)

RegisterCommand("needs", function(source, args)
    local client = source
    if exports.data:getUserVar(source, "admin") > 1 then
        local target = client

        if args[1] then
            target = tonumber(args[1])

            if not target then
                TriggerClientEvent("chat:addMessage", source, {
                    templateId = "error",
                    args = { "Špatně zadané ID hráče!" }
                })
            end
        end

        if GetPlayerName(target) then
            TriggerClientEvent("admin:needs", target)
            TriggerClientEvent("chat:addMessage", source, {
                templateId = "success",
                args = { "Hráči byl doplněn hlad a žízeň" }
            })

            exports.logs:sendToDiscord({
                channel = "admin-commands",
                title = "Doplnění hladu a žízně",
                description = "Doplnil hlad a žízeň hráči " .. GetPlayerName(target) .. " (" .. target .. ")",
                color = "34749"
            }, source)
        else
            TriggerClientEvent("chat:addMessage", source, {
                templateId = "error",
                args = { "Zadaný hráč nebyl nalezen!" }
            })
        end
    else
        TriggerClientEvent("chat:addMessage", source, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    end
end)

RegisterCommand("setplayerpedmodel", function(source, args)
    local client = source
    if exports.data:getUserVar(source, "admin") > 1 then
        local target = nil

        if args[1] then
            target = tonumber(args[1])

            if not target then
                TriggerClientEvent("chat:addMessage", source, {
                    templateId = "error",
                    args = { "Špatně zadané ID hráče!" }
                })
            end
        end

        if GetPlayerName(target) then
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "success",
                args = { "Hráči byl nastaven ped na " .. args[2] }
            })

            TriggerClientEvent("admin:setPlayerPed", target, args[2])

            exports.logs:sendToDiscord({
                channel = "admin-commands",
                title = "Ped model hráče",
                description = "Nastavil hráči " .. GetPlayerName(target) .. " model " .. args[2],
                color = "34749"
            }, client)
        else
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "error",
                args = { "Zadaný hráč nebyl nalezen!" }
            })
        end
    else
        TriggerClientEvent("chat:addMessage", client, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    end
end)

RegisterCommand("spawnobject", function(source, args)
    local client = source
    if exports.data:getUserVar(client, "admin") > 1 then
        if args[1] then
            TriggerClientEvent("admin:spawnObject", client, args[1])

            exports.logs:sendToDiscord({
                channel = "admin-commands",
                title = "spawnobject",
                description = "Spawnu objekt " .. args[1],
                color = "34749"
            }, client)
        else
            TriggerClientEvent("chat:addMessage", soclienturce, {
                templateId = "error",
                args = { "Musíš zadat model objektu!" }
            })
        end
    else
        TriggerClientEvent("chat:addMessage", client, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    end
end)

RegisterCommand("deleteobject", function(source, args)
    local client = source
    if exports.data:getUserVar(client, "admin") > 1 then
        if args[1] then
            TriggerClientEvent("admin:deleteobject", client, args[1])

            exports.logs:sendToDiscord({
                channel = "admin-commands",
                title = "deleteobject",
                description = "Smazání objekt " .. args[1],
                color = "34749"
            }, client)
        else
            TriggerClientEvent("chat:addMessage", soclienturce, {
                templateId = "error",
                args = { "Musíš zadat model objektu!" }
            })
        end
    else
        TriggerClientEvent("chat:addMessage", client, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    end
end)

RegisterCommand("heal", function(source, args)
    local client = source
    if exports.data:getUserVar(source, "admin") > 1 then
        local target = client

        if args[1] then
            target = tonumber(args[1])

            if not target then
                TriggerClientEvent("chat:addMessage", source, {
                    templateId = "error",
                    args = { "Špatně zadané ID hráče!" }
                })
            end
        end

        if GetPlayerName(target) then
            setHealth(target, 200.0)
            TriggerClientEvent("needs:needChanged", target, "stress", 0)
            TriggerClientEvent("chat:addMessage", source, {
                templateId = "success",
                args = { "Hráč byl uzdraven" }
            })

            exports.logs:sendToDiscord({
                channel = "admin-commands",
                title = "Doplnění životů",
                description = "Doplnil životy hráči " .. GetPlayerName(target) .. " (" .. target .. ")",
                color = "34749"
            }, source)
        else
            TriggerClientEvent("chat:addMessage", source, {
                templateId = "error",
                args = { "Zadaný hráč nebyl nalezen!" }
            })
        end
    else
        TriggerClientEvent("chat:addMessage", source, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    end
end)

RegisterCommand("armour", function(source, args)
    local client = source
    if exports.data:getUserVar(source, "admin") > 1 then
        local target = client

        if args[1] then
            target = tonumber(args[1])

            if not target then
                TriggerClientEvent("chat:addMessage", source, {
                    templateId = "error",
                    args = { "Špatně zadané ID hráče!" }
                })
            end
        end

        if GetPlayerName(target) then
            setArmour(target, "175.0")
            TriggerClientEvent("chat:addMessage", source, {
                templateId = "success",
                args = { "Hráči byla doplněna vesta" }
            })

            exports.logs:sendToDiscord({
                channel = "admin-commands",
                title = "Armor",
                description = "Doplnil armor hráči " .. GetPlayerName(target) .. " (" .. target .. ")",
                color = "34749"
            }, source)
        else
            TriggerClientEvent("chat:addMessage", source, {
                templateId = "error",
                args = { "Zadaný hráč nebyl nalezen!" }
            })
        end
    else
        TriggerClientEvent("chat:addMessage", source, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    end
end)

RegisterCommand("clearplayerinventory", function(source, args)
    local client = source
    if exports.data:getUserVar(source, "admin") > 1 then
        local target = client

        if args[1] then
            target = tonumber(args[1])

            if not target then
                TriggerClientEvent("chat:addMessage", source, {
                    templateId = "error",
                    args = { "Špatně zadané ID hráče!" }
                })
            end
        end

        if GetPlayerName(target) then
            exports.inventory:clearPlayerInventory(target)
            TriggerClientEvent("chat:addMessage", source, {
                templateId = "success",
                args = { "Vymazal jsi hráčovi inventář!" }
            })

            exports.logs:sendToDiscord({
                channel = "admin-commands",
                title = "Vymazání inventáře",
                description = "Vymazal inventář hráči " .. GetPlayerName(target) .. " (" .. target .. ")",
                color = "34749"
            }, source)
        else
            TriggerClientEvent("chat:addMessage", source, {
                templateId = "error",
                args = { "Zadaný hráč nebyl nalezen!" }
            })
        end
    else
        TriggerClientEvent("chat:addMessage", source, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    end
end)

RegisterCommand("clearchat", function(source, args)
    local client = source
    if exports.data:getUserVar(source, "admin") > 1 then
        TriggerClientEvent("chat:clear", -1)

        TriggerClientEvent("chat:addMessage", client, {
            template = '<div style="float: left; padding: 10px; margin: 5px; background-color: rgba(93, 188, 210, 0.75); border-left: 10px solid rgb(93, 188, 210);">Pročistil jsi chat</div>',
            args = {}
        })

        exports.logs:sendToDiscord({
            channel = "admin-commands",
            title = "Promazání chatu",
            description = "Promazal chat",
            color = "34749"
        }, source)
    else
        TriggerClientEvent("chat:addMessage", source, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    end
end)

RegisterCommand("ac", function(source, args)
    local client = source
    if exports.data:getUserVar(source, "admin") > 1 then
        if table.concat(args) == "" then
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "error",
                args = { "Zadejte text nahlášení!" }
            })
            return
        end

        exports.logs:sendToDiscord({
            channel = "admin-chat",
            title = "Admin chat",
            description = table.concat(args, " "),
            color = "9752266"
        }, client)

        local users = exports.data:getUsersBaseData(
            function(userData)
                return userData.status ~= "disconnected" and userData.admin > 1
            end
        )

        for _, userData in each(users) do
            TriggerClientEvent("chat:addMessage", userData.source, {
                templateId = "ac",
                args = { GetPlayerName(client), table.concat(args, " ") }
            })
        end
    else
        TriggerClientEvent("chat:addMessage", source, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    end
end)

RegisterCommand("msg", function(source, args)
    local client = source
    if exports.data:getUserVar(client, "admin") > 1 then
        local target = nil
        if args[1] then
            target = tonumber(args[1])

            if not target then
                TriggerClientEvent("chat:addMessage", source, {
                    templateId = "error",
                    args = { "Špatně zadané ID hráče!" }
                })
                return
            end
            if not GetPlayerName(target) then
                TriggerClientEvent("chat:addMessage", source, {
                    templateId = "error",
                    args = { "Hráč není připojen!" }
                })
                return
            end
        elseif table.concat(args) == "" then
            TriggerClientEvent("chat:addMessage", source, {
                templateId = "error",
                args = { "Zadejte text zrpávy!" }
            })
            return
        end

        local msg = ""
        for i = 2, #args do
            msg = msg .. " " .. args[i]
        end

        exports.logs:sendToDiscord({
            channel = "admin-chat",
            title = "Zpráva hráči " .. GetPlayerName(target) .. " (" .. target .. ")",
            description = msg,
            color = "13382451"
        }, source)

        TriggerClientEvent("chat:addMessage", target, {
            templateId = "admin-msg",
            args = { GetPlayerName(client), msg }
        })

        TriggerClientEvent("chat:addMessage", client, {
            templateId = "respond",
            args = { GetPlayerName(target) .. "[" .. target .. "]", msg }
        })
    end
end)

RegisterCommand("car", function(source, args)
    local client, type = source, args[1]
    if exports.data:getUserVar(client, "admin") > 1 then
        exports.logs:sendToDiscord({
            channel = "admin-commands",
            title = "Car",
            description = table.concat(args, " "),
            color = "34749"
        }, source)

        TriggerClientEvent("admin:spawnVehicle", client, args)
    else
        TriggerClientEvent("chat:addMessage", client, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    end
end)

RegisterCommand("giveitem", function(source, args)
    local client = source
    if exports.data:getUserVar(client, "admin") > 1 then
        if not args[1] or not tonumber(args[1]) then
            TriggerClientEvent("chat:addMessage", source, {
                templateId = "error",
                args = { "Musíš zadat ID hráče!" }
            })
        elseif not args[2] then
            TriggerClientEvent("chat:addMessage", source, {
                templateId = "error",
                args = { "Musíš zadat název předmětu!" }
            })
        else
            if not args[3] or not tonumber(args[3]) then
                args[3] = 1
            end

            local id = tonumber(args[1])
            if GetPlayerName(id) then
                local itemName = string.lower(args[2])
                local item = exports.inventory:getItem(itemName)

                if item then
                    if item.type == "item" then
                        local reason = "error"
                        if not string.match(item.name, "_glass") and item.name ~= "shot" and
                            exports.food:getItem(item.name) then
                            reason = exports.food:giveItem(id, itemName, tonumber(args[3]))
                        elseif string.match(itemName, "cigs") or string.match(itemName, "cigars") then
                            reason = exports.smokable:givePack(id, itemName, tonumber(args[3]))
                        else
                            reason = exports.inventory:addPlayerItem(id, itemName, tonumber(args[3]), {})
                        end

                        if reason == "done" then
                            TriggerClientEvent("chat:addMessage", source, {
                                templateId = "success",
                                args = { "Hráč obdržel " .. args[3] .. "x " .. item.label }
                            })

                            exports.logs:sendToDiscord({
                                channel = "admin-commands",
                                title = "Předmět",
                                description = "Dal hráči " .. GetPlayerName(id) .. " (" .. id .. ") " .. args[3] ..
                                    "x " .. item.label,
                                color = "34749"
                            }, source)
                        else
                            if reason == "weightExceeded" then
                                TriggerClientEvent("chat:addMessage", source, {
                                    templateId = "error",
                                    args = { "U hráče by došlo k překročení maximální váhy!" }
                                })
                            elseif reason == "spaceExceeded" then
                                TriggerClientEvent("chat:addMessage", source, {
                                    templateId = "error",
                                    args = { "Hráč nemá místo v inventáři!" }
                                })
                            else
                                if reason == nil then
                                    reason = "undefined"
                                end
                                TriggerClientEvent("chat:addMessage", source, {
                                    templateId = "error",
                                    args = { "Nastala chyba (" .. reason .. ")!" }
                                })
                            end
                        end
                    else
                        TriggerClientEvent("chat:addMessage", source, {
                            templateId = "error",
                            args = { "Zadaný předmět není běžný předmět!" }
                        })
                    end
                else
                    TriggerClientEvent("chat:addMessage", source, {
                        templateId = "error",
                        args = { "Zadaný předmět neexistuje!" }
                    })
                end
            else
                TriggerClientEvent("chat:addMessage", source, {
                    templateId = "error",
                    args = { "Zadaný hráč nebyl nalezen!" }
                })
            end
        end
    else
        TriggerClientEvent("chat:addMessage", source, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    end
end)

RegisterNetEvent("admin:isSpectating")
AddEventHandler("admin:isSpectating", function(spectateTarget)
    local client = source
    if exports.data:getUserVar(client, "admin") > 1 then
        if spectateTarget then
            spectateTargets[client] = {
                target = spectateTarget,
                targetPed = GetPlayerPed(spectateTarget),
                sourcePed = GetPlayerPed(client),
                sourceInstance = exports.instance:getPlayerInstance(client),
                start = os.time()
            }

            local targetInstance = exports.instance:getPlayerInstance(spectateTarget)
            if spectateTargets[client].sourceInstance ~= targetInstance then
                exports.instance:playerJoinInstance(client, targetInstance)
            end
        end
    end
end)

RegisterNetEvent("admin:stopSpectating")
AddEventHandler("admin:stopSpectating", function()
    local client = source
    stopSpectating[client] = true
end)

RegisterNetEvent("s:vehicleSync_fix")
AddEventHandler("s:vehicleSync_fix", function(vehicle)
    TriggerClientEvent("s:vehicleSync_fix", -1, vehicle)
end)

RegisterNetEvent("s:vehicleSync_clean")
AddEventHandler("s:vehicleSync_clean", function(vehicle)
    TriggerClientEvent("s:vehicleSync_clean", -1, vehicle)
end)

RegisterNetEvent("admin:heal")
AddEventHandler("admin:heal", function(client)
    TriggerClientEvent("admin:heal", client)
end)

function banPlayer(admin, target, length, reason)
    admin = tonumber(admin)
    target = tonumber(target)

    if not admin then
        TriggerClientEvent("chat:addMessage", admin, {
            templateId = "error",
            args = { "Admin nenalezen!" }
        })

        return
    elseif not target then
        TriggerClientEvent("chat:addMessage", admin, {
            templateId = "error",
            args = { "Špatně zadané ID hráče!" }
        })

        return
    end

    local adminName = "Anticheat"
    local adminIdentifiers = {}

    if admin >= 1 then
        adminName = GetPlayerName(tonumber(admin))
        adminIdentifiers = GetPlayerIdentifiers(admin)
    end

    local playerName = GetPlayerName(tonumber(target))

    if admin < 0 and exports.control:isDev() then
        TriggerClientEvent("chat:addMessage", target, {
            templateId = "error",
            args = { "Dostal bys ban od anticheatu!" }
        })
        return
    end

    if not adminName then
        TriggerClientEvent("chat:addMessage", admin, {
            templateId = "error",
            args = { "Admin nenalezen!" }
        })
    elseif admin > 0 and exports.data:getUserVar(admin, "admin") < 1 then
        TriggerClientEvent("chat:addMessage", admin, {
            templateId = "error",
            args = { "Na toto nemáš právo!" }
        })
    elseif admin == target then
        TriggerClientEvent("chat:addMessage", admin, {
            templateId = "error",
            args = { "Nemůžeš zabanovat sám sebe!" }
        })
    elseif not playerName then
        TriggerClientEvent("chat:addMessage", admin, {
            templateId = "error",
            args = { "Zadaný hráč nebyl nalezen!" }
        })
    elseif not Config.banLengths[length] then
        local lengths = ""
        for key, value in pairs(Config.banLengths) do
            lengths = lengths .. key .. " (" .. value.label .. ") "
        end

        if admin > 0 then
            TriggerClientEvent("chat:addMessage", admin, {
                templateId = "error",
                args = { "Špatná délka banu! Povolené délky: " .. lengths }
            })
        end
    else
        if admin > 0 then
            TriggerClientEvent("chat:addMessage", admin, {
                template = '<div style="float: left; padding: 10px; margin: 5px; background-color: rgba(255, 40, 0, 0.75); border-left: 10px solid rgb(255, 40, 0);">Zabanoval jsi hráče <strong>{0}</strong></div>',
                args = { playerName }
            })
        end

        local isPermanent = 0
        if length == "0" then
            isPermanent = 1
        end

        local playerIdentifiers = json.encode(GetPlayerIdentifiers(target))
        local dateEnd = os.time() + (Config.banLengths[length].minutes * 60)

        MySQL.Async.insert(
            "INSERT INTO `banlist` (`admin_name`, `admin_identifiers`, `player_name`, `player_identifiers`, `date_end`, `reason`, `permanent`) VALUES (@adminName, @adminIdentifiers, @playerName, @playerIdentifiers, FROM_UNIXTIME(" ..
                dateEnd .. "), @reason, @permanent)", {
                ["@adminName"] = adminName,
                ["@adminIdentifiers"] = json.encode(adminIdentifiers),
                ["@playerName"] = playerName,
                ["@playerIdentifiers"] = playerIdentifiers,
                ["@reason"] = reason,
                ["@permanent"] = isPermanent
            }, function(id)
                exports.connect:addNewBan(id, adminName, playerName, playerIdentifiers, dateEnd, reason, permanent)
            end)

        MySQL.Async.execute("UPDATE users SET whitelisted = 0 WHERE identifier = @identifier", {
            ["@identifier"] = exports.data:getSteamIdentifier(target)
        })

        if admin > 1 then
            exports.logs:sendToDiscord({
                channel = "admin-commands",
                title = "Zabanování hráče",
                description = "Zabanoval hráče " .. playerName .. " (" .. target .. ") s důvodem: " .. reason,
                color = "9109504"
            }, admin)
        end
        if adminName ~= "Anticheat" then
            DropPlayer(target,
                "Byl jsi zabanován adminem " .. adminName .. "!\nDůvod banu: " .. reason .. "\nDélka banu: " ..
                    Config.banLengths[length].label)
        else
            DropPlayer(target, "Byl jsi zabanován anticheatem!\nDůvod banu: " .. reason .. "\nDélka banu: " ..
                Config.banLengths[length].label)
        end
    end
end

function setHealth(target, value)
    if GetPlayerName(target) then
        exports.data:updateCharVar(target, "health", value)
        TriggerClientEvent("admin:heal", target, value)
    end
end

function setArmour(target, value)
    if GetPlayerName(target) then
        exports.data:updateCharVar(target, "armour", value)
        TriggerClientEvent("admin:armour", target, value)
    end
end

Citizen.CreateThread(function()
    while true do
        for spectator, spectateData in pairs(spectateTargets) do
            if stopSpectating[spectator] == true or not GetPlayerName(spectateData.target) then
                if spectateData.sourceInstance ~= exports.instance:getPlayerInstance(spectator) then
                    exports.instance:playerJoinInstance(spectator, spectateData.sourceInstance)
                end

                stopSpectating[spectator] = nil
                spectateTargets[spectator] = nil

                TriggerClientEvent("admin:stopSpectate", spectator)

                local playerName = GetPlayerName(spectateData.target)
                if not playerName then
                    playerName = "Odpojený"
                end

                exports.logs:sendToDiscord({
                    channel = "admin-commands",
                    title = "Sledování hráče",
                    description = "Sledoval hráče " .. playerName .. " (" .. spectateData.target .. ") po dobu " ..
                        (os.time() - spectateData.start) .. " vteřin",
                    color = "16752384"
                }, spectator)
            else
                SetEntityCoords(spectateData.sourcePed, GetEntityCoords(spectateData.targetPed))

                local targetInstance = exports.instance:getPlayerInstance(spectateData.target)
                if exports.instance:getPlayerInstance(spectator) ~= targetInstance then
                    exports.instance:playerJoinInstance(spectator, targetInstance)
                end
            end
        end

        Citizen.Wait(50)
    end
end)

RegisterCommand("goto", function(source, args)
    local client = source
    if exports.data:getUserVar(client, "admin") > 1 then
        if not args[1] or not tonumber(args[1]) then
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "error",
                args = { "Musíš zadat ID hráče!" }
            })
        else
            local target = tonumber(args[1])
            if GetPlayerName(target) then
                if client ~= target then
                    if exports.data:getUserVar(target, "status") ~= "choosing" then
                        local toCoords = GetEntityCoords(GetPlayerPed(target))
                        SetEntityCoords(GetPlayerPed(client), toCoords.x, toCoords.y, toCoords.z)
                        exports.logs:sendToDiscord({
                            channel = "admin-commands",
                            title = "Teleport",
                            description = "Se teleportoval/a na hráče " .. GetPlayerName(target),
                            color = "34749"
                        }, source)
                    else
                        TriggerClientEvent("chat:addMessage", client, {
                            templateId = "error",
                            args = { "Daný hráč je ve výběru postavy!" }
                        })
                    end
                else
                    TriggerClientEvent("chat:addMessage", client, {
                        templateId = "error",
                        args = { "Nemůžeš se teleportovat na sebe!" }
                    })
                end
            else
                TriggerClientEvent("chat:addMessage", source, {
                    templateId = "error",
                    args = { "Zadaný hráč nebyl nalezen!" }
                })
            end
        end
    else
        TriggerClientEvent("chat:addMessage", source, {
            templateId = "error",
            args = { "Nemáš oprávnění!" }
        })
    end
end)

RegisterCommand("bring", function(source, args)
    local client = source

    if exports.data:getUserVar(client, "admin") > 1 then
        if not args[1] or not tonumber(args[1]) then
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "error",
                args = { "Musíš zadat ID hráče!" }
            })
        else
            local target = tonumber(args[1])
            if GetPlayerName(target) then
                if client ~= target then
                    if exports.data:getUserVar(target, "status") ~= "choosing" then
                        local toCoords = GetEntityCoords(GetPlayerPed(client))
                        SetEntityCoords(GetPlayerPed(target), toCoords.x, toCoords.y, toCoords.z)
                        exports.logs:sendToDiscord({
                            channel = "admin-commands",
                            title = "Teleport",
                            description = "Teleportoval/a hráče " .. GetPlayerName(target) .. " k sobě!",
                            color = "34749"
                        }, source)
                    else
                        TriggerClientEvent("chat:addMessage", client, {
                            templateId = "error",
                            args = { "Daný hráč je ve výběru postavy!" }
                        })
                    end
                else
                    TriggerClientEvent("chat:addMessage", client, {
                        templateId = "error",
                        args = { "Nemůžeš se teleportovat na sebe!" }
                    })
                end
            else
                TriggerClientEvent("chat:addMessage", source, {
                    templateId = "error",
                    args = { "Zadaný hráč nebyl nalezen!" }
                })
            end
        end
    else
        TriggerClientEvent("chat:addMessage", source, {
            templateId = "error",
            args = { "Nemáš oprávnění!" }
        })
    end
end)

RegisterCommand("setPlayerInstance", function(source, args)
    local client = source

    if exports.data:getUserVar(client, "admin") > 1 then
        if not args[1] or not tonumber(args[1]) then
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "error",
                args = { "Musíš zadat ID hráče!" }
            })
        else
            local target = tonumber(args[1])
            if GetPlayerName(target) then
                if exports.data:getUserVar(target, "status") ~= "choosing" then
                    local instance = args[2]
                    local playerInstance = exports.instance:getPlayerInstance(target)

                    if not instance or instance == "0" then
                        if playerInstance == "" then
                            TriggerClientEvent("chat:addMessage", source, {
                                templateId = "error",
                                args = { "Zadaný hráč není v žádné instanci!" }
                            })
                        else
                            exports.instance:playerQuitInstance(target, 0)
                        end
                    elseif instance then
                        if instance == playerInstance then
                            TriggerClientEvent("chat:addMessage", source, {
                                templateId = "error",
                                args = { "Zadaný hráč je v této instanci!" }
                            })
                        else
                            exports.instance:playerJoinInstance(target, instance)
                        end
                    end
                else
                    TriggerClientEvent("chat:addMessage", client, {
                        templateId = "error",
                        args = { "Daný hráč je ve výběru postavy!" }
                    })
                end
            else
                TriggerClientEvent("chat:addMessage", source, {
                    templateId = "error",
                    args = { "Zadaný hráč nebyl nalezen!" }
                })
            end
        end
    else
        TriggerClientEvent("chat:addMessage", source, {
            templateId = "error",
            args = { "Nemáš oprávnění!" }
        })
    end
end)

RegisterCommand("coords", function(source, args)
    local client = source
    local style = args and args[1] or nil

    if exports.data:getUserVar(client, "admin") > 1 then
        local playerPed = GetPlayerPed(client)
        local coords, heading = GetEntityCoords(playerPed), GetEntityHeading(playerPed)
        local finalText = "x = " .. coords.x .. ", y = " .. coords.y .. ", z = " .. coords.z .. ", heading = " .. heading

        if style == "vector3" or style == "vec3" then
            finalText = tostring(coords)
            print(finalText, "XD")
        elseif style == "vector4" or style == "vec4" then
            finalText = "vec4(" .. coords.x .. ", " .. coords.y .. ", " .. coords.z .. ", " .. heading .. ")"
        elseif style == "database" then
            finalText = '"x": ' .. coords.x .. ', "y": ' .. coords.y .. ', "z": ' .. coords.z .. "'"
        end
        exports.logs:sendToDiscord({
            channel = "admin-commands",
            title = "Souřadnice",
            description = "Použil /coords!\nSouřadnice:\n" .. finalText,
            client = "34749"
        }, source)

        print(finalText)
        TriggerClientEvent("copy:copyToInsert", source, finalText)
        TriggerClientEvent("chat:addMessage", source, {
            templateId = "success",
            args = { "Souřadnice jsou v server konzoli a v CTRL + V!" }
        })
    else
        TriggerClientEvent("chat:addMessage", source, {
            templateId = "error",
            args = { "Nemáš oprávnění!" }
        })
    end
end)

RegisterNetEvent("admin:charData")
AddEventHandler("admin:charData",
    function(target)
        local client = source
        if exports.data:getUserVar(client, "admin") < 2 then
            return
        end

        TriggerClientEvent("admin:charData", client, getCharData(target))
    end)

function getCharData(target)
    local data = nil

    if not GetPlayerName(target) then
        return
    end

    local status = exports.data:getUserVar(target, "status")
    if status ~= "spawned" and status ~= "dead" then
        return
    end

    data = exports.data:getUserVar(target, "character")
    data.source = target
    data.status = status

    -- specific data part
    local ped = GetPlayerPed(target)
    if ped and DoesEntityExist(ped) then
        data.health = GetEntityHealth(ped) - 100
        data.armour = GetPedArmour(ped)
    end
    return data
end

RegisterCommand("charinfo",
    function(source, args)
        local client = source
        if exports.data:getUserVar(client, "admin") < 2 then
            return
        end

        if not args[1] or not tonumber(args[1]) then
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "error",
                args = { "Musíš zadat ID hráče!" }
            })
        end

        TriggerClientEvent("admin:charData", client, getCharData(tonumber(args[1])))
    end
)

RegisterNetEvent("admin:deleteVehicle")
AddEventHandler("admin:deleteVehicle", function(netId)
    local client = source
    if exports.data:getUserVar(client, "admin") then
        local vehicle = NetworkGetEntityFromNetworkId(netId)
        if DoesEntityExist(vehicle) then
            exports.base_vehicles:removeVehicle(vehicle)

            exports.logs:sendToDiscord({
                channel = "admin-commands",
                title = "Cardel",
                description = "Smazal vozidlo",
                color = "34749"
            }, client)
        end
    end
end)

RegisterNetEvent("admin:adminResourceStop")
AddEventHandler("admin:adminResourceStop", function()
    local client = source
    DropPlayer(client, "Detekováno vypnutí scriptu!")
    exports.logs:sendToDiscord({
        channel = "cheating",
        title = "Vypnutí scriptu",
        description = "Vypnul script: " .. GetCurrentResourceName(),
        color = "34749"
    }, client)
end)

RegisterCommand("refreshAllBlips", function(source)
    local client = source
    if exports.data:getUserVar(client, "admin") > 1 then
        TriggerClientEvent("player_blips:locatorRefresh", -1)
    end
end)