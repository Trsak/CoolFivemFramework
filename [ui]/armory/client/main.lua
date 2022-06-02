local isSpawned, isDead, jobs, isOpened = false, false, nil, false

Citizen.CreateThread(function()
    Citizen.Wait(500)

    local status = exports.data:getUserVar("status")
    if status == "spawned" or status == "dead" then
        isSpawned = true
        isDead = (status == "dead")
        loadJobs()
    end
end)

RegisterNetEvent("s:statusUpdated")
AddEventHandler("s:statusUpdated", function(status)
    if status == "choosing" then
        isSpawned = false
    elseif status == "spawned" or status == "dead" then
        isDead = (status == "dead")
        if not isSpawned then
            isSpawned = true

            loadJobs()
        end
        if isOpened and isDead then
            isOpened = false
            SendNUIMessage({
                action = "hide"
            })
            SetNuiFocus(false, false)
        end
    end
end)

RegisterNetEvent("s:jobUpdated")
AddEventHandler("s:jobUpdated", function(jobsData)
    loadJobs(jobsData)
end)

function openArmory(job)
    if Config.Items[job] and not isOpened then
        local items = {}
        table.insert(items, "<div class='row justify-content-md-center'>")
        for i, item in each(Config.Items[job]) do
            if jobs[job].Grade >= item.Grade then
                table.insert(items,
                    ('<a class=\'col-3 weapon\' href=\'#\' id=\'%s\' onclick="activateWeapon(%s)"><div class=\'weaponImage\'><img src=\'nui://inventory/ui/items/%s.png\'></div>%s</a>'):format(
                        i, i, item.Item, (exports.inventory:getItem(item.Item).label .. " (" ..
                            (item.Count ~= nil and item.Count or 1) .. "x)")))
            end
        end
        table.insert(items,
            '<div class=\'col-12\'><a href=\'#\' class=\'loadButton\' onclick="takeLoadout()">VZÍT VYBAVENÍ</a></div></div>')
        SendNUIMessage({
            action = "show",
            items = table.concat(items),
            job = job
        })
        SetNuiFocus(true, true)
        isOpened = true
    end
end

RegisterNUICallback("close", function(data, cb)
    SendNUIMessage({
        action = "hide"
    })
    SetNuiFocus(false, false)
    isOpened = false
end)

RegisterNUICallback("takeLoadout", function(data, cb)
    SendNUIMessage({
        action = "hide"
    })
    SetNuiFocus(false, false)
    isOpened = false
    if #data.selectedItems > 0 then
        TriggerServerEvent("armory:giveItems", data)
    end
end)

function loadJobs(Jobs)
    jobs = {}
    for _, jobData in pairs(Jobs and Jobs or exports.data:getCharVar("jobs")) do
        jobs[jobData.job] = {
            Name = jobData.job,
            Type = exports.base_jobs:getJobVar(jobData.job, "type"),
            Grade = jobData.job_grade,
            Duty = jobData.duty
        }
    end
end

RegisterNetEvent("inventory:usedItem")
AddEventHandler("inventory:usedItem", function(itemName, slot, data)
    if string.match(itemName, "armor") and Config.Armors[itemName] then
        local playerPed = PlayerPedId()
        if playerPed then
            exports.progressbar:startProgressBar({
                Duration = 7000,
                Label = "Nasazuješ si vestu...",
                CanBeDead = false,
                CanCancel = true,
                DisableControls = {
                    Movement = true,
                    CarMovement = true,
                    Mouse = false,
                    Combat = true
                },
                Animation = {
                    emotes = "armour"
                }
            }, function(finished)
                if finished then
                    SetPedArmour(playerPed, Config.Armors[itemName])
                    TriggerServerEvent("inventory:removePlayerItem", itemName, 1, data, slot)
                end
            end)
        end
    end
end)
