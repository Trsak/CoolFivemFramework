local playersFines = {}
local finesList = {}
local loaded = false

MySQL.ready(
    function()
        Wait(5)

        MySQL.Async.fetchAll(
            "SELECT * FROM fine_label ORDER BY paragraph ASC",
            {},
            function(fines)
                finesList = {}
                if #fines > 0 then
                    for i, fine in each(fines) do
                        table.insert(
                            finesList,
                            {
                                PriceMin = fine.price_min,
                                PriceMax = fine.price_max,
                                Paragraph = fine.paragraph,
                                Label = "§" .. fine.paragraph .. " " .. fine.name
                            }
                        )
                    end
                end
            end
        )

        MySQL.Async.fetchAll(
            "SELECT * FROM fines",
            {},
            function(result)
                playersFines = {}
                if #result > 0 then
                    for i, fineData in each(result) do
                        local charId = tonumber(fineData.person)

                        if playersFines[charId] == nil then
                            playersFines[charId] = {}
                        end

                        table.insert(
                            playersFines[charId],
                            {
                                Id = tableLength(playersFines[charId]) + 1,
                                Dbid = fineData.id,
                                Price = fineData.price,
                                Person = tonumber(fineData.person),
                                Officer = tonumber(fineData.officer),
                                Job = fineData.job,
                                Paid = fineData.paid,
                                Date = fineData.date,
                                Datelabel = os.date("%x %X", fineData.date),
                                Label = fineData.label,
                                Changed = false
                            }
                        )
                    end
                end
                loaded = true
                local counted = 0
                for _, x in pairs(playersFines) do
                    counted = counted + tableLength(x)
                end
                print("^5[FINES]^7 Successfully loaded with " .. counted .. " fines!")
                SetTimeout(30000, saveFines)
                TriggerClientEvent("fines:sync", -1, finesList)
            end
        )
    end
)

function saveFines()
    for key, fineData in pairs(playersFines) do
        for i, data in each(fineData) do
            if data.Changed then
                data.Changed = false
                MySQL.Async.execute(
                    "UPDATE fines SET label=@label, price=@price, person=@person, officer=@officer, job=@job, paid=@paid, date=@date WHERE id=@dbid",
                    {
                        ["@dbid"] = data.Dbid,
                        ["@label"] = data.Label,
                        ["@price"] = data.Price,
                        ["@person"] = data.Person,
                        ["@officer"] = data.Officer,
                        ["@job"] = data.Job,
                        ["@paid"] = data.Paid,
                        ["@date"] = data.Date
                    }
                )
            end
        end
    end

    SetTimeout(30000, saveFines)
end

RegisterNetEvent("fines:sync")
AddEventHandler(
    "fines:sync",
    function()
        local _source = source
        while not loaded do
            Citizen.Wait(200)
        end
        TriggerClientEvent("fines:sync", _source, finesList)
    end
)

RegisterNetEvent("fines:giveFine")
AddEventHandler(
    "fines:giveFine",
    function(target, finesToGive)
        local _source = source
        local allowed = false

        local jobs = exports.data:getCharVar(_source, "jobs")
        for _, data in pairs(jobs) do
            local type = exports.base_jobs:getJobVar(data.job, "type")
            if Config.CanFine[type] then
                allowed = data.job
                break
            end
        end

        if allowed or exports.data:getUserVar(_source, "admin") > 1 then
            local sourceCoords = GetEntityCoords(GetPlayerPed(_source))
            local targetCoords = GetEntityCoords(GetPlayerPed(target))
            if #(sourceCoords - targetCoords) <= 50.0 then
                for _, fineLabel in each(finesToGive) do
                    addFine(
                        _source,
                        target,
                        {
                            price = fineLabel.Price,
                            label = fineLabel.Label,
                            job = allowed
                        }
                    )
                end

                TriggerClientEvent("fines:give", _source, "gave")
            else
                exports.admin:banClientForCheating(
                    _source,
                    "0",
                    "Cheating",
                    "fines:giveFine",
                    "Hráč se pokusil dát pokutu někomu (" ..
                        target .. "), kdo není blízko! " .. #(sourceCoords - targetCoords)
                )
            end
        else
            exports.admin:banClientForCheating(
                _source,
                "0",
                "Cheating",
                "fines:giveFine",
                "Hráč se pokusil dát někomu pokutu, aniž by byl policista!"
            )
        end
    end
)

function addFine(_source, target, fineData)
    local char = exports.data:getCharVar(target, "id")
    if playersFines[char] == nil then
        playersFines[char] = {}
    end

    local sourceCharId = exports.data:getCharVar(_source, "id")
    local id = tableLength(playersFines[char]) + 1
    table.insert(
        playersFines[char],
        {
            Id = id,
            Price = fineData.price,
            Person = tonumber(char),
            Officer = tonumber(sourceCharId),
            Paid = 0,
            Date = os.time(),
            Datelabel = os.date("%x %X", os.time()),
            Label = fineData.label,
            Changed = true,
            Job = fineData.job
        }
    )
    logToPoliceDiscord(
        {
            Price = fineData.price,
            Officer = exports.data:getCharNameById(sourceCharId),
            Person = exports.data:getCharNameById(char),
            Label = fineData.label
        }
    )

    MySQL.Async.insert(
        "INSERT INTO fines (label, price, person, officer, job, paid, date) VALUES (@label, @price, @person, @officer, @job, @paid, @date)",
        {
            ["@label"] = fineData.label,
            ["@price"] = fineData.price,
            ["@person"] = char,
            ["@officer"] = sourceCharId,
            ["@job"] = fineData.job,
            ["@paid"] = 0,
            ["@date"] = os.time()
        },
        function(insertedId)
            playersFines[char][id].Dbid = insertedId

            TriggerClientEvent("fines:give", target, "got", fineData)
        end
    )
end

function markFineAsPaid(client, charId, fineId)
    if playersFines[charId] == nil then
        return
    end

    for id, fine in each(playersFines[charId]) do
        if fine.Dbid == fineId then
            playersFines[charId][id].Paid = os.time()
            playersFines[charId][id].Changed = true
            break
        end
    end

    TriggerClientEvent("fines:pay", client, "done")
    TriggerClientEvent("bank:refreshFines", client, "done", playersFines[charId])
end

function getFineList(charId, paid)
    if charId == nil then
        return {}
    end

    if playersFines[charId] == nil then
        return {}
    end

    if paid ~= nil then
        local tempFines = {}
        for _, fine in each(playersFines[charId]) do
            if fine.Paid <= paid then
                table.insert(tempFines, fine)
            end
        end
        return tempFines
    else
        return playersFines[charId]
    end
end

function getFineData(charId, fineId)
    for _, fine in each(playersFines[charId]) do
        if fine.Dbid == fineId then
            return fine
        end
    end

    return nil
end

function tableLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end


function logToPoliceDiscord(data)
    PerformHttpRequest(
        "https://discord.com/api/webhooks/",
        function(err, text, headers)
        end,
        "POST",
        json.encode(
            {
                embeds = {
                    {
                        ["color"] = 34749,
                        ["title"] = "Vydání pokuty",
                        ["timestamp"] = os.date("!%Y-%m-%dT%TZ"),
                        ["description"] = "Zaměstanec: " .. data.Officer .. "\nOsoba: " .. data.Person .. "\nPokuta: " .. data.Label .. "\nCena: $" .. data.Price 
                    }
                }
            }
        ),
        {["Content-Type"] = "application/json"}
    )
end