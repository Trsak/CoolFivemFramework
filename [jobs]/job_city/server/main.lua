local jobs = nil

Citizen.CreateThread(
    function()
        jobs = {}
        for job, data in pairs(Config.Jobs) do
            jobs[job] = {}
            for _, coords in each(data.Points) do
                table.insert(
                    jobs[job],
                    {
                        Coords = coords,
                        Done = false,
                        Reserved = false,
                        Remain = data.MaxCount
                    }
                )
            end
        end
    end
)

RegisterNetEvent("city:checkAvailable")
AddEventHandler(
    "city:checkAvailable",
    function(job, repeated)
        local client = source

        if not jobs[job] then
            return
        end

        local pointId = nil

        for i, jobData in each(jobs[job]) do
            if not jobData.Done and not jobData.Reserved and jobData.Remain > 0 then
                pointId = i
                jobData.Reserved = client
                break
            end
        end

        if not pointId then
            TriggerClientEvent(
                "notify:display",
                client,
                {
                    type = "warning",
                    title = "Úřad práce",
                    text = "Vše je tady odpracováno, přijď později, určitě se něco najde.",
                    icon = Config.Jobs[job].Texts.Icon,
                    length = 7500
                }
            )
            if repeated then
                TriggerClientEvent("city:endJob", client)
            end
        else
            if repeated then
                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "info",
                        title = "Úřad práce",
                        text = "Dobrá práce. Jdi na další místo!",
                        icon = Config.Jobs[job].Texts.Icon,
                        length = 2500
                    }
                )
            end
            TriggerClientEvent("city:checkAvailable", client, job, pointId, jobs[job][pointId].Coords, repeated)
            SetTimeout(
                Config.TimeToDoPlace,
                function()
                    if jobs[job][pointId].Reserved == client then
                        jobs[job][pointId].Reserved = nil
                        TriggerClientEvent("city:endJob", client)
                        TriggerClientEvent(
                            "notify:display",
                            client,
                            {
                                type = "warning",
                                title = "Úřad práce",
                                text = "Práci jsi po dlouhé době nedokončil/a! Byla ti odebrána.",
                                icon = "fas fa-briefcase",
                                length = 7500
                            }
                        )
                    end
                end
            )
        end
    end
)

RegisterNetEvent("city:unreserveJob")
AddEventHandler(
    "city:unreserveJob",
    function(job, pointId)
        local client = source
        if jobs[job][pointId].Reserved == client then
            jobs[job][pointId].Reserved = false
        end
    end
)

RegisterNetEvent("city:doCurrentJob")
AddEventHandler(
    "city:doCurrentJob",
    function(job, pointId, coords)
        local client = source
        local jobData = jobs[job][pointId]
        if jobData.Remain > 0 and not jobData.Done and jobData.Reserved == client then
            local playerCoords = GetEntityCoords(GetPlayerPed(client))
            if #(playerCoords - vec3(jobs[job][pointId].Coords.xyz)) > 20.0 then
                return
            end

            jobs[job][pointId].Remain = jobs[job][pointId].Remain - 1

            local cash = Config.Jobs[job].Reward
            exports.daily_limits:addLimitCount(client, "city", cash)
            local isOverLimit = exports.daily_limits:checkIfIsOverLimit(client, "city")

            if isOverLimit then
                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "warning",
                        title = "Brigáda pro město",
                        text = "Překročil/a jsi dnešní limit výdělku od města, další výdělek už bude značně menší!",
                        icon = "fas fa-exclamation",
                        length = 7500
                    }
                )

                cash = math.ceil(cash / 6)
            end

            exports.inventory:forceAddPlayerItem(client, "cash", cash, {})
            TriggerClientEvent("city:doCurrentJob", client, jobs[job][pointId].Remain)

            if jobs[job][pointId].Remain <= 0 then
                jobs[job][pointId].Reserved = false
                jobs[job][pointId].Done = true
                SetTimeout(
                    Config.PointResetDuration,
                    function()
                        jobs[job][pointId].Done = false
                        jobs[job][pointId].Remain = Config.Jobs[job].MaxCount
                    end
                )
            end
        end
    end
)
