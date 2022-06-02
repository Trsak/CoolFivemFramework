local playerDuties = {}
local jobs = nil

MySQL.ready(
    function()
        jobs = {}
        local count = 0
        MySQL.Async.fetchAll("SELECT * FROM jobs", {}, function(result)
            for _, job in each(result) do
    
                jobs[job.name] = {
                    name = job.name,
                    label = job.label,
                    grades = json.decode(job.grades),
                    bank = job.bank,
                    type = job.type,
                    garages = json.decode(job.garages),
                    requests = (job.requests == 1),
                    logs = json.decode(job.logs),
                    applications = json.decode(job.applications)
                }
                count = count + 1
            end
    
            print("^2[BASE_JOBS]^7 Successfully loaded with " .. count .. " jobs!")
            SetTimeout(200, payment)
        end)
    end
)

RegisterNetEvent("base_jobs:askForJobs")
AddEventHandler("base_jobs:askForJobs", function()
    local client = source
    while not jobs do
        Wait(500)
    end
    local toSendJobs = jobs
    for job, data in pairs(toSendJobs) do
        data.requests = nil
        data.logs = nil
        data.applications = nil
    end
    TriggerLatentClientEvent("base_jobs:jobsUpdated", client, 100000, toSendJobs)
end)

function payment()
    local currentTime = os.time()
    for player, data in pairs(playerDuties) do
        local source = tonumber(player)
        if os.difftime(currentTime, data.time) >= 1800 then
            -- == number (in secconds)
            playerDuties[player].time = os.time()
            local job = jobs[data.job]
            if job then
                if hasUserJob(source, data.job, data.grade, true) then
                    local charBossData, targetAccount = exports.data:getCharVar(source, "bossdata"), nil
                    if charBossData and charBossData[data.job] then
                        targetAccount = charBossData[data.job].bank
                    end
                    if not targetAccount or not targetAccount then
                        salaryMessage(source, "destAccountDoesNotExist", 0)
                    else
                        local grade = job.grades[data.grade]
                        local textToSend = job.label .. " výplata - " .. data.name .. " (" .. grade.label .. ")"
                        local payment = exports.bank:payFromAccountToAccount(tostring(job.bank), tostring(targetAccount), grade.salary, false, textToSend, textToSend)
                        local secPayment = nil
                        if payment == "destAccountDoesNotExist" then
                            secPayment = exports.bank:payFromAccount(tostring(job.bank), grade.salary, false, textToSend)
                        end

                        salaryMessage(source, payment, grade.salary, secPayment)
                    end
                else
                    playerDuties[player] = nil
                end
            end
        end
        Citizen.Wait(1000) -- 180000
    end
    SetTimeout(20000, payment)
end

RegisterNetEvent("chars:playerSpawned")
AddEventHandler("chars:playerSpawned", function()
    local client = source
    Citizen.Wait(2000)
    local currentJobs = exports.data:getCharVar(client, "jobs")
    for i, jobData in each(currentJobs) do
        if jobData.duty then
            playerDuties[tostring(client)] = {
                job = jobData.job,
                grade = jobData.job_grade,
                name = exports.data:getCharNameById(exports.data:getCharVar(client, "id")),
                time = os.time()
            }
            TriggerEvent("base_jobs:sendDutyChange", client, jobData.job, jobData.job_grade, true, false)
            break
        end
    end
end)

AddEventHandler("playerDropped", function(reason)
    local client = source
    if playerDuties[tostring(client)] then
        local playerjob = playerDuties[tostring(client)]
        TriggerEvent("base_jobs:sendDutyChange", client, playerjob.job, playerjob.grade, false, false)
        playerDuties[tostring(client)] = nil
    end
end)

RegisterNetEvent("base_jobs:getBonus")
AddEventHandler("base_jobs:getBonus", function(checkIfCheater)
    local client = source
    if checkIfCheater then
        exports.admin:banClientForCheating(client, "0", "Cheating", "base_jobs:getBonus", checkIfCheater)
        return
    end

    local bonus = exports.data:getCharVar(client, "bonus")

    if bonus > 0 then
        local ended = exports.inventory:addPlayerItem(client, "cash", bonus, {})
        if ended == "done" then
            exports.data:updateCharVar(client, "bonus", 0)
            TriggerClientEvent("notify:display", client, {
                type = "success",
                title = "Vyplacení mzdy",
                text = "Mzda vyplacena. Zařiď si bankovní účet u svého nadřízeného!",
                icon = "fas fa-dollar-sign",
                length = 5000
            })
        else
            TriggerClientEvent("chat:addMessage", client, {
                templateId = "error",
                args = {"Někde nastala chyba při výběru bonusu. [" .. ended .. "]"}
            })
        end
    end
end)

RegisterNetEvent("base_jobs:updateDuty")
AddEventHandler("base_jobs:updateDuty", function(job, state)
    local client = source
    updateDuty(client, job, state)
end)

RegisterNetEvent("base_jobs:clearBonus")
AddEventHandler("base_jobs:clearBonus", function()
    local client = source
    exports.data:updateCharVar(client, "bonus", 0)
end)

function updateDuty(player, job, state)
    if not player or not job or state == nil then
        return "missingVariable"
    end

    local currentJobs = exports.data:getCharVar(player, "jobs")
    local setDuty = false
    for i, jobData in each(currentJobs) do
        if jobData.job == job then
            jobData.duty = state
            local status = (state and "Přišel do služby v práci " or "Odešel ze služby v práci ")
            if state then
                setDuty = {
                    job = jobData.job,
                    grade = jobData.job_grade,
                    name = exports.data:getCharNameById(exports.data:getCharVar(player, "id")),
                    time = os.time()
                }
            else
                playerDuties[tostring(player)] = nil
            end
            exports.logs:sendToDiscord({
                channel = "duty",
                title = "Služba",
                description = status .. jobs[jobData.job].label,
                color = "34749"
            }, player)
            TriggerEvent("base_jobs:sendDutyChange", player, jobData.job, jobData.job_grade, state, true)
        elseif jobData.duty then
            jobData.duty = false
            playerDuties[tostring(player)] = nil
            exports.logs:sendToDiscord({
                channel = "duty",
                title = "Služba",
                description = "Odešel ze služby v práci " .. jobs[jobData.job].label,
                color = "34749"
            }, player)
            TriggerEvent("base_jobs:sendDutyChange", player, jobData.job, jobData.job_grade, state, true)

        end
    end
    if setDuty then
        playerDuties[tostring(player)] = setDuty
    end

    exports.data:updateCharVar(player, "jobs", currentJobs)
end

function getUserActiveJob(client)
    local playerJobs = loadPlayerJobs(client)
    if playerJobs or #playerJobs ~= 0 then
        for _, jobData in pairs(playerJobs) do
            if jobData.Duty then
                return jobData.Name, jobData.Grade
            end
        end
    end

    return nil
end

function hasUserJob(client, job, grade, duty)
    local playerJobs = loadPlayerJobs(client)
    if playerJobs and #playerJobs > 0 then
        for _, jobData in pairs(playerJobs) do
            if jobData.Name == job then
                if (not grade or jobData.Grade >= grade) and (not duty or jobData.Duty) then
                    return true
                end
            end
        end
    end

    return false
end

function hasUserJobEqualGrade(client, job, grade, duty)
    local playerJobs = loadPlayerJobs(client)
    if playerJobs and #playerJobs > 0 then
        for _, jobData in pairs(playerJobs) do
            if jobData.Name == job then
                if (not grade or jobData.Grade == grade) and (not duty or jobData.Duty) then
                    return true
                end
            end
        end
    end

    return false
end

function isUserBoss(client, job)
    local playerJobs = loadPlayerJobs(client)
    if playerJobs and #playerJobs > 0 then
        for _, jobData in pairs(playerJobs) do
            if jobData.Name == job then
                if jobData.Grade >= getHighestJobRank(job) then
                    return true
                end
            end
        end
    end

    return false
end

function getHighestJobRank(job)
    local highestRank = 999
    if jobs[job] and jobs[job].grades then
        return #jobs[job].grades
    end
    return highestRank
end

function getHighestJobTypeRank(jobType)
    local highestRank = 999
    for _, jobData in pairs(jobs) do
        if jobData.type == jobType then
            if jobData.grades then
                return #jobData.grades
            end
        end
    end
    return highestRank
end

function hasUserJobType(client, jobType, duty)
    local playerJobs = loadPlayerJobs(client)
    if playerJobs and #playerJobs > 0 then
        for _, jobData in pairs(playerJobs) do
            if jobData.Type == jobType and (not duty or jobData.Duty) then
                return true
            end
        end
    end

    return false
end

function hasUserJobTypeGrade(client, jobType, grade, duty)
    local playerJobs = loadPlayerJobs(client)
    if playerJobs and #playerJobs > 0 then
        for _, jobData in each(playerJobs) do
            if jobData.Type == jobType then
                if (not grade or jobData.Grade >= grade) and (not duty or jobData.Duty) then
                    return true
                end
            end
        end
    end

    return false
end

function loadPlayerJobs(player)
    local recievedData = exports.data:getCharVar(player, "jobs")
    local playerJobs = {}
    for _, jobData in pairs(recievedData) do
        table.insert(playerJobs, {
            Name = jobData.job,
            Type = getJobVar(jobData.job, "type"),
            Grade = jobData.job_grade,
            Duty = jobData.duty
        })
    end
    return playerJobs
end

function salaryMessage(client, status, salary, secStatus)
    if salary <= 0 then
        TriggerClientEvent("notify:display", client, {
            type = "warning",
            title = "Vyplacení mzdy",
            text = "Nemáš žádný plat!",
            icon = "fas fa-dollar-sign",
            length = 3000
        })
        return
    end
    if status == "done" then
        TriggerClientEvent("notify:display", client, {
            type = "info",
            title = "Vyplacení mzdy",
            text = "Mzda ti byla vyplacena na tvůj účet!",
            icon = "fas fa-dollar-sign",
            length = 3000
        })
    else
        local primaryStatus = status
        local status = secStatus or status
        local text = ""
        if status == "notEnoughBalance" then
            text = "Výplatu nelze odeslat, není dostatečný zůstatek na účtu společnosti!"
        elseif status == "sourceAccountDoesNotExist" then
            text = "Výplatu nelze odeslat, společnost nemá platný bankovní účet!"
        elseif status == "sameAccounts" then
            text = "Výplatu nelze odeslat na účet! Účty jsou stejné!"
        elseif status == "destAccountDoesNotExist" and secStatus == "done" then
            local bonus = exports.data:getCharVar(client, "bonus") + salary
            exports.data:updateCharVar(client, "bonus", bonus)
            text = "Nemáš zadaný účet ve firmě! Vyzvedni si výplatu při odchodu ze služby!"
        end
        TriggerClientEvent("notify:display", client, {
            type = "warning",
            title = "Vyplacení mzdy",
            text = text,
            icon = "fas fa-dollar-sign",
            length = 6000
        })
    end
end

-- From Data

function getJobs()
    return jobs
end

function getJob(job)
    return (jobs and jobs[job] or nil)
end

function getJobsTypes()
    local jobTypes = {}

    for _, jobData in pairs(jobs) do
        jobTypes[jobData.name] = jobData.type
    end

    return jobTypes
end

function getJobVar(job, var)
    if jobs and jobs[job] then
        return jobs[job][var]
    else
        return nil
    end
end

function getJobGradeVar(job, grade, var)
    if jobs and jobs[job] and jobs[job].grades and jobs[job].grades[grade] then
        return jobs[job].grades[grade][var]
    else
        return nil
    end
end

function updateJobVar(jobname, var, att)
    if jobs[jobname] then
        local istable = false
        if type(jobs[jobname][var]) == "number" then
            att = tonumber(att)
        elseif type(jobs[jobname][var]) == "table" then
            istable = true
        end
        jobs[jobname][var] = att

        if istable then
            att = json.encode(att)
        end
        saveJobAtts(jobname, jobs[jobname], {
            [var] = att
        })
        -- TriggerClientEvent("data:jobsUpdated", -1, "update", jobname, var, att)
        TriggerEvent("data:jobsUpdated", jobs)
    end
end

function saveJobAtts(jobname, job, atts)
    -- TODO: LOGY DO SAMOSTATNÉ TABULKY!
end
