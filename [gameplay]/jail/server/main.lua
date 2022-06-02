RegisterNetEvent("jail:sendToJail")
AddEventHandler(
    "jail:sendToJail",
    function(target, penaltyData)
        local client = source

        if target == -1 then
            exports.admin:banClientForCheating(
                client,
                "0",
                "Cheating",
                "jail:sendToJail",
                "Hráč se pokusil poslat všechny do vězení! (target == -1)"
            )
        end
        local allowed = false

        local jobs = exports.data:getCharVar(client, "jobs")
        for _, data in pairs(jobs) do
            if Config.CanJail[exports.base_jobs:getJobVar(data.job, "type")] then
                allowed = true
                break
            end
        end

        if allowed or exports.data:getUserVar(client, "admin") > 1 then
            local sourceCoords = GetEntityCoords(GetPlayerPed(client))
            local targetCoords = GetEntityCoords(GetPlayerPed(target))
            if #(sourceCoords - targetCoords) <= 10.0 then
                local inJail = exports.data:getCharVar(target, "jail")
                if inJail and (not inJail.time or inJail.time <= 0) then
                    local inventory = exports.inventory:getPlayerInventory(target).data

                    local jailData = {
                        outfit = exports.data:getCharVar(target, "outfit"),
                        loadout = inventory,
                        time = penaltyData.jailLength * 60000
                    }
                    exports.inventory:clearPlayerInventory(target)
                    exports.data:updateCharVar(target, "jail", jailData)

                    local userJobs = exports.data:getCharVar(player, "jobs")
                    if userJobs and tableLength(userJobs) > 0 then
                        for job, data in pairs(userJobs) do
                            exports.base_jobs:updateDuty(target, job, false)
                        end
                    end

                    TriggerClientEvent("jail:sendToJail", target, penaltyData.jailLength * 60000, jailData)

                    local citizen = exports.data:getCharVar(target, "id")
                    local officer = exports.data:getCharVar(client, "id")

                    local _yearsLabel = "LET"
                    if penaltyData.penaltyLength == 1 then
                        _yearsLabel = "ROK"
                    elseif penaltyData.penaltyLength >= 2 and penaltyData.penaltyLength <= 4 then
                        _yearsLabel = "ROKY"
                    end
                    MySQL.Async.execute(
                        "INSERT INTO pddb_criminalrecords (citizen, officer, text) VALUES (@citizen, @officer, @text)",
                        {
                            ["@citizen"] = citizen,
                            ["@officer"] = officer,
                            ["@text"] = penaltyData.criminalOffense .. " [ " .. penaltyData.penaltyLength .. " " .. _yearsLabel .. " ]"
                        }
                    )

                    local desc =
                    "Hráč poslal do vězení " ..
                        exports.data:getCharNameById(exports.data:getCharVar(tonumber(target), "id")) ..
                        " (" .. GetPlayerName(target) .. ") na dobu " .. penaltyData.jailLength .. " minut. "
                    exports.logs:sendToDiscord(
                        {
                            channel = "jail",
                            title = "Vězení",
                            description = desc,
                            color = "83711"
                        },
                        client
                    )
                else
                    TriggerClientEvent(
                        "notify:display",
                        client,
                        {
                            type = "warning",
                            title = "Vězení",
                            text = "Osoba je již ve vězení!",
                            icon = "fas fa-times",
                            length = 3000
                        }
                    )
                end
            else
                exports.admin:banClientForCheating(
                    client,
                    "0",
                    "Cheating",
                    "jail:sendTojail",
                    "Hráč se pokusil dát někoho do vězení, kdo není blízko!"
                )
            end
        else
            exports.admin:banClientForCheating(
                client,
                "0",
                "Cheating",
                "jail:sendToJail",
                "Hráč se pokusil dát někoho do vězení, aniž by byl policista!"
            )
        end
    end
)

RegisterNetEvent("jail:sendFromJail")
AddEventHandler(
    "jail:sendFromJail",
    function(target)
        local client = source
        local allowed = false

        local jobs = exports.data:getCharVar(client, "jobs")
        for _, data in pairs(jobs) do
            if Config.CanJail[exports.base_jobs:getJobVar(data.job, "type")] then
                allowed = true
                break
            end
        end

        if allowed or exports.data:getUserVar(client, "admin") > 1 then
            if GetPlayerName(target) then
                local targetPed = GetPlayerPed(target)
                local sourceCoords = GetEntityCoords(GetPlayerPed(client))
                local targetCoords = GetEntityCoords(targetPed)
                if #(sourceCoords - targetCoords) <= 10.0 then
                    local inJail = exports.data:getCharVar(target, "jail")
                    if inJail and (inJail.time or inJail.time > 0) then
                        inJail.time = 0
                        exports.data:updateCharVar(target, "jail", inJail)
                        local charId = exports.data:getCharVar(target, "id")

                        SetEntityCoords(targetPed, Config.ReleaseSpawn.xyz)
                        SetEntityHeading(targetPed, Config.ReleaseSpawn.w)
                        local desc = "Hráč propustil " .. exports.data:getCharNameById(charId) .. " (" .. GetPlayerName(target) .. ")"
                        exports.logs:sendToDiscord(
                            {
                                channel = "jail",
                                title = "Vězení",
                                description = desc,
                                color = "83711"
                            },
                            client
                        )
                        TriggerClientEvent(
                            "notify:display",
                            target,
                            {
                                type = "info",
                                title = "Vězení",
                                text = "Byl/a jsi propuštěn/a!",
                                icon = "fas fa-times",
                                length = 3000
                            }
                        )
                    else
                        TriggerClientEvent(
                            "notify:display",
                            client,
                            {
                                type = "warning",
                                title = "Vězení",
                                text = "Osoba není ve vězení!",
                                icon = "fas fa-times",
                                length = 3000
                            }
                        )
                    end
                else
                    exports.admin:banClientForCheating(
                        client,
                        "0",
                        "Cheating",
                        "jail:sendFromJail",
                        "Hráč se pokusil propustit někoho z vězení, aniž by byl policista!"
                    )
                end
            end
        else
            exports.admin:banClientForCheating(
                client,
                "0",
                "Cheating",
                "jail:sendFromJail",
                "Hráč se pokusil propustit někoho z vězení, aniž by byl policista!"
            )
        end
    end
)

RegisterNetEvent("jail:getItemsBack")
AddEventHandler(
    "jail:getItemsBack",
    function()
        local client = source
        local inJail = exports.data:getCharVar(client, "jail")
        if inJail and inJail.loadout then
            for i, item in each(inJail.loadout) do
                exports.inventory:addPlayerItem(client, item.name, item.count, item.data)
            end
            inJail.loadout = nil
            exports.data:updateCharVar(client, "jail", inJail)
        end
    end
)

RegisterNetEvent("jail:updateJailData")
AddEventHandler(
    "jail:updateJailData",
    function(newData)
        local client = source
        exports.data:updateCharVar(client, "jail", newData)
    end
)

RegisterCommand(
    "isJailed",
    function(source, args)
        local client = source
        local target = tonumber(args[1])
        if exports.data:getUserVar(client, "admin") > 1 then
            if target then
                if GetPlayerName(target) then
                    local jailData = exports.data:getCharVar(target, "jail")
                    if jailData and (jailData.time or jailData.time > 0) then
                        TriggerEvent(
                            "chat:addMessage",
                            {
                                templateId = "success",
                                args = {"Hráč je ve vězení ještě na " .. math.floor(jailData.time / 60000) .. " minut!"}
                            }
                        )
                    else
                        TriggerEvent(
                            "chat:addMessage",
                            {
                                templateId = "success",
                                args = {"Hráč není ve vězení!"}
                            }
                        )
                    end
                else
                    TriggerEvent(
                        "chat:addMessage",
                        {
                            templateId = "error",
                            args = {"Hráč nebyl nalezen!"}
                        }
                    )
                end
            else
                TriggerEvent(
                    "chat:addMessage",
                    {
                        templateId = "error",
                        args = {"Zadej ID hráče!"}
                    }
                )
            end
        else
            TriggerEvent(
                "chat:addMessage",
                {
                    templateId = "error",
                    args = {"Na toto nemáš právo!"}
                }
            )
        end
    end
)

function tableLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end
