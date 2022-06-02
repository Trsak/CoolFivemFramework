AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        adminPower = exports.data:getUserVar("admin")
        charId = exports.data:getCharVar("id")
        jobs = {}
        for _, job in each(exports.data:getCharVar("jobs")) do
            if job ~= nil and next(job) then
                jobs[job.job] = {
                    name = job.job,
                    grade = job.job_grade,
                    duty = job.duty
                }
            end
        end
        TriggerServerEvent('player_near_coords:add_player', { job = jobs, adminPower = adminPower, charId = chardId, ServerID  = GetPlayerServerId(PlayerId()) })
    end
end)

RegisterNetEvent("s:statusUpdated")
AddEventHandler("s:statusUpdated", function(status)
    isDead = (status == "dead")
    if status == "spawned" then
        adminPower = exports.data:getUserVar("admin")
        charId = exports.data:getCharVar("id")
        jobs = {}
        for _, job in each(exports.data:getCharVar("jobs")) do
            if job ~= nil and next(job) then
                jobs[job.job] = {
                    name = job.job,
                    grade = job.job_grade,
                    duty = job.duty
                }
            end
        end
        TriggerServerEvent('player_near_coords:add_player', { job = jobs, adminPower = adminPower, charId = chardId, ServerID  = GetPlayerServerId(PlayerId()) })
    end
end)


RegisterNetEvent("s:jobUpdated")
AddEventHandler("s:jobUpdated", function(dzobs)
    adminPower = exports.data:getUserVar("admin")
    charId = exports.data:getCharVar("id")
    jobs = {}
    for _, job in each(dzobs) do
        if job ~= nil and next(job) then
            jobs[job.job] = {
                name = job.job,
                grade = job.job_grade,
                duty = job.duty
            }
        end
    end
    TriggerServerEvent('player_near_coords:add_player', { job = jobs, adminPower = adminPower, charId = chardId, ServerID  = GetPlayerServerId(PlayerId()) })
end)