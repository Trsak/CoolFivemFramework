local isSpawned = false
local Jobs = nil
local jobs = {}

Citizen.CreateThread(function()
    Citizen.Wait(500)

    local status = exports.data:getUserVar("status")
    if status == "spawned" or status == "dead" then
        isSpawned = true
        loadJobs()
    end
end)

RegisterNetEvent("s:statusUpdated")
AddEventHandler("s:statusUpdated", function(status)
    if status == "choosing" then
        isSpawned = false
    elseif status == "spawned" or status == "dead" then
        if not isSpawned then
            loadJobs()
            TriggerEvent("s:jobsUpdated", exports.data:getCharVar("jobs"))
        end
        isSpawned = true
    end
end)

RegisterNetEvent("s:jobUpdated")
AddEventHandler("s:jobUpdated", function(jobsData)
    loadJobs(jobsData)
end)

function forceBonus()
    local bonus = exports.data:getCharVar("bonus")
    if bonus > 0 then
        TriggerServerEvent("base_jobs:getBonus")
    end
end

function getJobs()
    return Jobs
end

function checkJobs()
    return (Jobs and true or false)
end

function getJob(job)
    return (Jobs and Jobs[job] or nil)
end

function getJobGradeVar(job, grade, var)
    if Jobs and Jobs[job] then
        return Jobs[job].grades[grade][var]
    else
        return nil
    end
end

function getJobVar(job, var)
    if Jobs and Jobs[job] then
        return Jobs[job][var]
    else
        return nil
    end
end

function hasUserJobType(jobType, duty, grade)
    if jobs and #jobs ~= 0 then
        for _, jobData in each(jobs) do
            if jobData.Type == jobType and (not duty or jobData.Duty) and (not grade or jobData.Grade >= grade) then
                return true
            end
        end
    end
    return false
end

function hasUserJob(job, duty, grade)
    if jobs and #jobs ~= 0 then
        for _, jobData in each(jobs) do
            if jobData.Name == job and (not duty or jobData.Duty) and (not grade or jobData.Grade >= grade) then
                return true
            end
        end
    end
    return false
end

function loadJobs(Jobs)
    local recievedData = (Jobs or exports.data:getCharVar("jobs"))
    jobs = {}
    for _, jobData in pairs(recievedData) do
        table.insert(jobs, {
            Name = jobData.job,
            Type = getJobVar(jobData.job, "type"),
            Grade = jobData.job_grade,
            Duty = jobData.duty
        })
    end
end

RegisterNetEvent("base_jobs:jobsUpdated")
AddEventHandler("base_jobs:jobsUpdated", function(serverJobs)
    Jobs = serverJobs
end)