local jobs = {}
local opened = {}
local loaded = false

Citizen.CreateThread(function()
    Citizen.Wait(500)
    prepareData()
end)

RegisterNetEvent("bossmenu:open")
AddEventHandler("bossmenu:open", function(menuJob)
    local client = source
    if tableLength(jobs) == 0 then
        prepareData()
    end
    while not loaded do
        Citizen.Wait(200)
    end

    local char = exports.data:getUserVar(client, "character")

    if not char or not char.id then
        return
    end

    if not menuJob or not jobs[menuJob] or not jobs[menuJob].employees or not jobs[menuJob].employees[tostring(char.id)] then
        return
    end
    local rank = exports.base_jobs:getJobGradeVar(menuJob, jobs[menuJob].employees[tostring(char.id)].Grade, "rank")
    if rank == "boss" or rank == "secondboss" then
        opened[tostring(client)] = menuJob
        jobs[menuJob].vehicles = exports.base_vehicles:getJobVehicle(menuJob)
        jobs[menuJob].invoices = exports.invoices:getSenderInvoiceList(menuJob, 0)
        TriggerClientEvent("bossmenu:open", client, menuJob, jobs[menuJob], {
            firstname = char.firstname,
            lastname = char.lastname
        })
    end
end)

RegisterNetEvent("bossmenu:applications")
AddEventHandler("bossmenu:applications", function()
    local client = source

    local recieveApplications = {}
    for i, job in pairs(jobs) do
        if job.requests and job.requests == 1 then
            recieveApplications[job.name] = job.label
        end
    end
    TriggerClientEvent("bossmenu:applications", client, recieveApplications)
end)

RegisterNetEvent("bossmenu:editJobData")
AddEventHandler("bossmenu:editJobData", function(data)
    local client = source
    local sourceChar = exports.data:getCharVar(client, "id")
    local rank = exports.base_jobs:getJobGradeVar(data.job, jobs[data.job].employees[tostring(sourceChar)].Grade, "rank")
    if rank == "boss" or rank == "secondboss" then
        local jobLabel = exports.base_jobs:getJobVar(data.job, "label")
        if data.type == "employee" or data.type == "grade" then
            local employeeName = exports.data:getCharNameById(tonumber(data.char))
            local textToSend, title = "", "Změna informací"
            if data.type == "employee" then
                local oldData = jobs[data.job].employees[tostring(data.char)].BossData
                local base = {"Zaměstnanec: " .. employeeName .. "\n"}
                table.insert(base, "Poznámky: " .. (oldData.notes or "Nic") .. " na " .. (data.notes or "nic") .. "\n")
                table.insert(base, "Volačka: " .. (oldData.customtag or "Nic") .. " na " .. (data.customtag or "nic") .. "\n")
                table.insert(base, "Bankovní účet: " .. (oldData.bank or "Nic") .. " na " .. (data.bank or "nic"))
                textToSend = table.concat(base)
            else
                local gradeLabel = jobs[data.job].grades[tonumber(data.newData)].label
                local oldData = jobs[data.job].employees[tostring(data.char)]
                local base = {"Zaměstnanec: " .. employeeName .. "\n"}
                table.insert(base, "Stará pozice: " .. oldData.GradeLabel .. " (" .. oldData.Grade .. ")\n")
                table.insert(base, "Nová pozice: " .. gradeLabel .. " (" .. data.newData .. ")")
                title, textToSend = "Změna pozice", table.concat(base)

            end
            exports.logs:sendToDiscord({
                channel = "bossmenu",
                title = jobLabel .. " - " .. title,
                description = textToSend,
                color = "34749"
            }, client)

            if data.type == "employee" then
                jobs[data.job].employees[tostring(data.char)].BossData.notes = data.notes
                jobs[data.job].employees[tostring(data.char)].BossData.customtag = data.customtag
                jobs[data.job].employees[tostring(data.char)].BossData.bank = tonumber(data.bank)
            else
                local gradeLabel = jobs[data.job].grades[tonumber(data.newData)].label
                jobs[data.job].employees[tostring(data.char)].Grade = tonumber(data.newData)
                jobs[data.job].employees[tostring(data.char)].GradeLabel = gradeLabel
            end

            local _, userData = exports.data:getUserByCharId(tonumber(data.char))

            if userData then
                local toUpdate = ""
                if data.type == "employee" then
                    local bossData = userData.character.bossdata
                    if not bossData then
                        bossData = {}
                    end
                    bossData[data.job] = {
                        notes = data.notes,
                        customtag = data.customtag,
                        bank = tonumber(data.bank)
                    }
                    toUpdate = bossData
                else
                    local charJobs = userData.character.jobs
                    for i, job in each(charJobs) do
                        if job.job == data.job then
                            charJobs[i].job_grade = tonumber(data.newData)
                            break
                        end
                    end
                    toUpdate = charJobs
                end
                exports.data:updateCharVar(userData.source, data.type ~= "grade" and "bossdata" or "jobs", toUpdate)

            else
                local toUpdate = (data.type ~= "grade" and "bossdata" or "jobs")
                local result = MySQL.Sync.fetchAll("SELECT " .. toUpdate .. " FROM characters where id = :id", {
                    id = tonumber(data.char)
                })
                if #result > 0 then
                    local toSend = json.decode(result[1][toUpdate])
                    if data.type == "employee" then
                        if not toSend then
                            toSend = {}
                        end
                        toSend[data.job] = {
                            notes = data.notes,
                            customtag = data.customtag,
                            bank = tonumber(data.bank)
                        }
                    else
                        for i, job in each(toSend) do
                            if job.job == data.job then
                                job.job_grade = tonumber(data.newData)
                                break
                            end
                        end
                    end
                    MySQL.Sync.execute("UPDATE characters SET " .. toUpdate .. "= :" .. toUpdate .. " WHERE id = :id", {
                        id = tonumber(data.char),
                        [toUpdate] = json.encode(toSend)
                    })
                end
            end
        elseif data.type == "salary" or data.type == "label" then
            local oldSalary = jobs[data.job].grades[tonumber(data.grade)][data.type]
            local base = {"Pozice: " .. jobs[data.job].grades[tonumber(data.grade)].label}
            table.insert(base, "Stará výplata: " .. getFormattedCurrency(oldSalary) .. "\n")
            table.insert(base, "Nová výplata: " .. getFormattedCurrency(data.newData))
            exports.logs:sendToDiscord({
                channel = "bossmenu",
                title = jobLabel .. " - Změna výplaty",
                description = table.concat(base),
                color = "34749"
            }, client)
            jobs[data.job].grades[tonumber(data.grade)][data.type] = tonumber(data.newData)
            exports.base_jobs:updateJobVar(data.job, "grades", jobs[data.job].grades)
        elseif data.type == "requests" then
            exports.logs:sendToDiscord({
                channel = "bossmenu",
                title = jobLabel .. " - Přijímání žádostí",
                description = (data.newData and "Povolil" or "Zakázal") .. " žádosti o zaměstnání ",
                color = "34749"
            }, client)
            jobs[data.job][data.type] = tonumber(data.newData and 1 or 0)
            exports.base_jobs:updateJobVar(data.job, data.type, jobs[data.job][data.type])
        elseif data.type == "applications" then -- ??
            if data.status == "new" then
                data.application.status = data.status
                exports.logs:sendToDiscord({
                    channel = "bossmenu",
                    title = "Bossmenu",
                    description = (data.application.name) .. " podal žádost o zaměstnání " .. data.label,
                    color = "34749"
                }, source)
                table.insert(jobs[data.job][data.type], data.application)
                exports.base_jobs:updateJobVar(data.job, data.type, jobs[data.job][data.type])
            elseif data.status == "delete" then
                table.remove(jobs[data.job][data.type], data.id)
                exports.base_jobs:updateJobVar(data.job, data.type, jobs[data.job][data.type])
            elseif data.status == "accept" then
                jobs[data.job][data.type][data.id].status = data.status
                exports.base_jobs:updateJobVar(data.job, data.type, jobs[data.job][data.type])
            end
        elseif data.type == "bank" then
            exports.logs:sendToDiscord({
                channel = "bossmenu",
                title = jobLabel .. " - Změna bankovního účtu",
                description = "Starý: " .. (jobs[data.job][data.type] or "Žádný") .. "\nNový: " .. data.newData,
                color = "34749"
            }, client)
            jobs[data.job][data.type] = tonumber(data.newData)
            exports.base_jobs:updateJobVar(data.job, data.type, jobs[data.job][data.type])
        elseif data.type == "car" or data.type == "boat" or data.type == "plane" then
            local job = exports.base_jobs:getJobVar(data.job, "label")
            if not jobs[data.job].garages then
                jobs[data.job].garages = {}
            end
            if not jobs[data.job].garages[data.type] then
                jobs[data.job].garages[data.type] = 0
            end
            local oldGarage = jobs[data.job].garages[data.type]
            exports.logs:sendToDiscord({
                channel = "bossmenu",
                title = jobLabel .. " - Změna čísla garáže",
                description = "Typ: " .. data.type .. "\nStaré: " .. oldGarage .. "\nNové: " .. data.newData,
                color = "34749"
            }, client)
            jobs[data.job].garages[data.type] = tonumber(data.newData)
            exports.base_jobs:updateJobVar(data.job, "garages", jobs[data.job].garages)
        elseif data.type == "vehGrade" or data.type == "vehChar" or data.type == "vehNote" or data.type ==
            "vehLowerGrade" then
            local job = exports.base_jobs:getJobVar(data.job, "label")
            local vehicle = exports.base_vehicles:getVehicle(data.plate)
            local targetExist = true
            if not vehicle.jobdata or not vehicle.jobdata[data.type] then
                targetExist = false
            end
            if data.type == "vehGrade" then
                local des = "Přeřadil vozidlo s SPZ " .. data.plate .. " práce " .. job .. ". "
                local old = not targetExist and "Nepřiřazeno" or
                                jobs[data.job].grades[tonumber(vehicle.jobdata[data.type])].label
                local new = data.newData == "Nepřiřazeno" and "Nepřiřazeno" or
                                jobs[data.job].grades[tonumber(data.newData)].label
                exports.logs:sendToDiscord({
                    channel = "bossmenu",
                    title = "Bossmenu",
                    description = des .. "Z " .. old .. " na " .. new .. ".",
                    color = "34749"
                }, client)
                exports.base_vehicles:updateVehicleJobData(data.plate, data.type, data.newData == "Nepřiřazeno" and
                    nil or tonumber(data.newData))
            elseif data.type == "vehChar" then
                local des = "Přeřadil vozidlo s SPZ " .. data.plate .. " práce " .. job .. ". "
                local old = not targetExist and "nikoho" or
                                exports.data:getCharNameById(tonumber(vehicle.jobdata[data.type]))
                local new = data.newData == "Nepřiřazeno" and "nikoho" or
                                exports.data:getCharNameById(tonumber(data.newData))
                exports.logs:sendToDiscord({
                    channel = "bossmenu",
                    title = "Bossmenu",
                    description = des .. "Od " .. old .. " pro " .. new .. ".",
                    color = "34749"
                }, client)
                exports.base_vehicles:updateVehicleJobData(data.plate, data.type, data.newData == "Nepřiřazeno" and
                    nil or tonumber(data.newData))
            elseif data.type == "vehNote" then
                local des = "Změnil poznámku vozidla s SPZ " .. data.plate .. " práce " .. job .. ". "
                local old = not targetExist and "Ničeho" or vehicle.jobdata[data.type]
                local new = data.newData == "" and "nic" or data.newData
                exports.logs:sendToDiscord({
                    channel = "bossmenu",
                    title = "Bossmenu",
                    description = des .. "Z " .. old .. " na " .. new .. ".",
                    color = "34749"
                }, client)
                exports.base_vehicles:updateVehicleJobData(data.plate, data.type,
                    data.newData == "" and nil or data.newData)
            elseif data.type == "vehLowerGrade" then
                local des = "Změnil minimální pozici vozidla s SPZ " .. data.plate .. " práce " .. job .. ". "
                exports.logs:sendToDiscord({
                    channel = "bossmenu",
                    title = "Bossmenu",
                    description = des .. "Z " .. jobs[data.job].grades[tonumber(vehicle.owner.grade)].label .. " na " ..
                        jobs[data.job].grades[tonumber(data.newData)].label .. ".",
                    color = "34749"
                }, client)
                exports.base_vehicles:changeVehicleOwner("job", {
                    job = data.job,
                    grade = tonumber(data.newData)
                }, data.plate)
            end
            jobs[data.job].vehicles = exports.base_vehicles:getJobVehicle(data.job)
        end

        for player, job in pairs(opened) do
            if data.job == job then
                TriggerClientEvent("bossmenu:recieveUpdatedData", tonumber(player), jobs[data.job])
            end
        end
    end
end)

RegisterNetEvent("bossmenu:sendRequest")
AddEventHandler("bossmenu:sendRequest", function(target, job, grade)
    TriggerClientEvent("bossmenu:recieveRequest", target, source, {
        job = job,
        grade = grade
    }, {
        job = jobs[job].label,
        grade = jobs[job].grades[tonumber(grade)].label
    })
end)
RegisterNetEvent("bossmenu:answerRequest")
AddEventHandler("bossmenu:answerRequest", function(from, accepted, data)
    local client = source
    if not GetPlayerName(from) or not GetPlayerName(client) then
        return
    end
    if accepted then
        TriggerClientEvent("notify:display", from, {
            type = "success",
            title = "Nábor",
            text = "Osoba přijala pracovní nabídku!",
            icon = "fas fa-briefcase",
            length = 3000
        })
        local playerJobs = exports.data:getCharVar(client, "jobs")
        local alreadyInJob = false

        for i, jobData in each(playerJobs) do
            if jobData.job == data.job then
                alreadyInJob = true
                playerJobs[i].job_grade = tonumber(data.grade)
                break
            end
        end

        if not alreadyInJob then
            if not playerJobs then
                playerJobs = {}
            end

            table.insert(playerJobs, {
                job = data.job,
                job_grade = tonumber(data.grade),
                duty = false
            })
        end

        local jobLabel = exports.base_jobs:getJobVar(data.job, "label")
        local char = exports.data:getUserVar(client, "character")
        exports.logs:sendToDiscord({
            channel = "bossmenu",
            title = jobLabel .. " - nábor",
            description = "Zaměstnal " .. char.firstname .. " " .. char.lastname,
            color = "34749"
        }, from)
        exports.data:updateCharVar(client, "jobs", playerJobs)
    else
        TriggerClientEvent("notify:display", from, {
            type = "warning",
            title = "Nábor",
            text = "Osoba odmítla pracovní nabídku!",
            icon = "fas fa-briefcase",
            length = 3000
        })
    end
end)

RegisterNetEvent("bossmenu:fireEmployee")
AddEventHandler("bossmenu:fireEmployee", function(data)
    local client = source
    local sourceChar = exports.data:getCharVar(client, "id")
    local rank = exports.base_jobs:getJobGradeVar(data.job, jobs[data.job].employees[tostring(sourceChar)].Grade, "rank")
    if rank == "boss" or rank == "secondboss" then
        jobs[data.job].employees[tostring(data.char)] = nil
        local users = exports.data:getUsers()
        for _, identifier in each(users) do
            local userData = exports.data:getUserByIdentifier(identifier)
            if userData.status == "spawned" or userData.status == "dead" then
                if userData.character.id == tonumber(data.char) then
                    local charData = userData.character
                    for i, job in each(charData.jobs) do
                        if data.job == job.job then
                            table.remove(charData.jobs, i)
                            exports.data:updateCharVar(userData.source, "jobs", charData.jobs)

                            return
                        end
                    end
                end
            end
        end

        MySQL.Async.fetchAll("SELECT jobs FROM characters where id = @id", {
            ["@id"] = tonumber(data.char)
        }, function(result)
            if #result ~= 0 then
                local jobs = json.decode(result[1].jobs)
                for i, job in each(jobs) do
                    if job.job == data.job then
                        table.remove(jobs, i)
                        break
                    end
                end
                MySQL.Async.execute("UPDATE characters SET jobs=@jobs WHERE id=@charid", {
                    ["@charid"] = tonumber(data.char),
                    ["@jobs"] = json.encode(jobs)
                })
            end
        end)
        local charName = exports.data:getCharNameById(tonumber(data.char))
        exports.logs:sendToDiscord({
            channel = "bossmenu",
            title = "Bossmenu",
            description = "Vyhodil postavu " .. charName .. " z práce " .. exports.base_jobs:getJobVar(data.job, "label"),
            color = "34749"
        }, client)
        TriggerClientEvent("notify:display", client, {
            type = "success",
            title = "Výpověď",
            text = "Vyhodil/a jste zaměstance " .. charName .. "!",
            icon = "fas fa-briefcase",
            length = 3500
        })
    end
end)

RegisterNetEvent("bossmenu:orderVehicle")
AddEventHandler("bossmenu:orderVehicle", function(data, selectedOwner)
    local client, done = source, "missingAccount"
    local sourceChar = exports.data:getCharVar(client, "id")
    local rank = exports.base_jobs:getJobGradeVar(data.job, jobs[data.job].employees[tostring(sourceChar)].Grade, "rank")
    if rank == "boss" or rank == "secondboss" then
        local toGarage = (jobs[data.job].garages ~= nil and jobs[data.job].garages[data.type] or nil)
        if toGarage ~= nil then
            local buyer = exports.data:getCharNameById(exports.data:getCharVar(client, "id"))
            local pay = exports.bank:payFromAccount(tostring(jobs[data.job].bank), tonumber(data.price), false,
                "Koupě firemního vozidla - provedl " .. buyer, client)
            if pay == "done" then
                TriggerClientEvent("notify:display", client, {
                    type = "success",
                    title = "Koupě vozidla",
                    text = "Vozidlo bylo úspěšně zakoupeno!",
                    icon = "fas fa-money-check-alt",
                    length = 3500
                })
                exports.logs:sendToDiscord({
                    channel = "bossmenu",
                    title = "Bossmenu",
                    description = "Zakopil vozidlo " .. data.model .. " pro práci " ..
                        exports.base_jobs:getJobVar(data.job, "label"),
                    color = "34749"
                }, source)
                exports.base_vehicles:addVehicle(selectedOwner, toGarage, {
                    model = data.model,
                    fuelLevel = 100.0,
                    modLivery = tonumber(data.livery)
                }, data.type)
            else
                TriggerClientEvent("notify:display", client, {
                    type = "warning",
                    title = "Koupě vozidla",
                    text = pay == "sourceAccountDoesNotExist" and "Účet neexistuje" or
                        "Na účtu je nedostatek financí!",
                    icon = "fas fa-money-check-alt",
                    length = 4000
                })
            end
        else
            TriggerClientEvent("notify:display", client, {
                type = "warning",
                title = "Koupě vozidla",
                text = "Není zadaná garáž pro dovezení vozidla!",
                icon = "fas fa-warehouse",
                length = 4000
            })
        end
    end
end)

AddEventHandler("playerDropped", function()
    local client = source
    for player, _ in pairs(opened) do
        if tonumber(player) == client then
            opened[player] = nil
            break
        end
    end
end)

function prepareData()
    jobs = exports.base_jobs:getJobs()
    for _, job in pairs(jobs) do
        job.employees = {}
        job.Induty = exports.data:countEmployees(job.name, nil, nil, true)
    end
    local users = exports.data:getUsers()
    for index, identifier in each(users) do
        local userData = exports.data:getUserByIdentifier(identifier)
        if userData.character then
            if userData.status == "spawned" or userData.status == "dead" then
                for _, job in each(userData.character.jobs) do
                    local data = userData.character.bossdata
                    jobs[job.job].employees[tostring(userData.character.id)] = {
                        Name = userData.character.firstname .. " " .. userData.character.lastname,
                        Duty = job.duty,
                        Grade = job.job_grade,
                        GradeLabel = jobs[job.job].grades[job.job_grade].label,
                        BossData = (data and data[job.job]) and data[job.job] or {}
                    }
                end
            end
        end
    end
    MySQL.Async.fetchAll("SELECT `id`, `firstname`, `lastname`, `jobs`, `bossdata` FROM `characters`", {},
        function(result)
            if #result ~= 0 then
                for i, player in each(result) do
                    local playerJobs = player.jobs
                    if type(playerJobs) == "string" then
                        playerJobs = json.decode(playerJobs)
                    end
                    for _, job in each(playerJobs) do
                        if jobs[job.job] and not jobs[job.job].employees[tostring(player.id)] then
                            local data = json.decode(player.bossdata)
                            jobs[job.job].employees[tostring(player.id)] = {
                                Name = player.firstname .. " " .. player.lastname,
                                Duty = job.duty,
                                Grade = job.job_grade,
                                GradeLabel = jobs[job.job].grades[job.job_grade].label,
                                BossData = (data and data[job.job]) and data[job.job] or {}
                            }
                        end
                    end
                end
            end
        end)

    local currentTime = os.time()
    for job, data in pairs(jobs) do
        local newJobLogs = {}
        if data.logs then
            for i, log in each(data.logs) do
                if log.timeStamp and log.timeStamp + 604800 > currentTime then
                    table.insert(newJobLogs, log)
                end
            end
            jobs[job].logs = newJobLogs
            table.sort(jobs[job].logs, function(a, b)
                return a.time > b.time
            end)
        else
            jobs[job].logs = newJobLogs
        end
        exports.base_jobs:updateJobVar(job, "logs", jobs[job].logs)
    end
    loaded = true
end

AddEventHandler("base_jobs:sendDutyChange", function(client, job, grade, duty, care)
    if not care then
        return
    end

    if jobs[job] then
        local charId = exports.data:getCharVar(client, "id")
        local currentTime = os.time()
        local employeName = exports.data:getCharNameById(charId)

        if jobs[job].employees[tostring(charId)] then
            jobs[job].Induty = exports.data:countEmployees(job, nil, nil, true)
            jobs[job].employees[tostring(charId)].Duty = duty
        end

        if not jobs[job].logs then
            jobs[job].logs = {}
        end

        table.insert(jobs[job].logs, {
            employe = employeName,
            grade = jobs[job].grades[grade].label,
            time = os.date("%d.%m.%Y %H:%M:%S", currentTime),
            timeStamp = currentTime,
            action = duty and "on" or "off"
        })

        table.sort(jobs[job].logs, function(a, b)
            return a.time > b.time
        end)

        exports.base_jobs:updateJobVar(job, "logs", jobs[job].logs)

        logToFractionDiscord(job, employeName, duty)

        for player, xJob in pairs(opened) do
            if xJob == job then
                TriggerClientEvent("bossmenu:recieveUpdatedData", tonumber(player), jobs[job])
            end
        end
    end
end)

function tableLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

function logToFractionDiscord(job, employe, duty)
    if not ServerConfig.Webhooks[job] or exports.control:isDev() then
        return
    end
    PerformHttpRequest(ServerConfig.Webhooks[job], function(err, text, headers)
    end, "POST", json.encode({
        embeds = {{
            color = 34749,
            title = "Služba",
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            description = "Zaměstanec " .. employe .. " " .. (duty and "přišel do služby." or "odešel ze služby."),
            footer = {
                text = jobs[job].label,
                icon_url = "https://dunb17ur4ymx4.cloudfront.net/webstore/logos/d0083345917107dd3df76a3a0872c4cd6aa22ef6.png"
            }
        }}
    }), {
        ["Content-Type"] = "application/json"
    })
end
