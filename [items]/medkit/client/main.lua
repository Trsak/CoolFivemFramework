local isSpawned, isDead, jobs = false, false, nil

Citizen.CreateThread(
    function()
        Citizen.Wait(500)

        local status = exports.data:getUserVar("status")
        if status == ("spawned" or "dead") then
            isSpawned = true
            isDead = (status == "dead")
            loadJobs()
        end
    end
)
RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned = false
        elseif status == "spawned" or status == "dead" then
            isDead = (status == "dead")
            if not isSpawned then
                isSpawned = true
                loadJobs()
            end
        end
    end
)

RegisterNetEvent("s:jobUpdated")
AddEventHandler(
    "s:jobUpdated",
    function(newJobs)
        loadJobs(newJobs)
    end
)

RegisterNetEvent("inventory:usedItem")
AddEventHandler(
    "inventory:usedItem",
    function(itemName, slot, data)
        if Config.Items[itemName] then
            if canUseitem(itemName) then
                WarMenu.CreateMenu("medkit", exports.inventory:getItem(itemName).label, "Zvolte")
                WarMenu.OpenMenu("medkit")
                while WarMenu.IsMenuOpened("medkit") do
                    if Config.Items[itemName].Type == "heal" and WarMenu.Button("Použít na sebe") then
                        useItemOnYourself(itemName)
                        WarMenu.CloseMenu()
                    elseif WarMenu.Button("Jinou osobu") then
                        TriggerEvent(
                            "util:closestPlayer",
                            {
                                radius = 2.0
                            },
                            function(player)
                                if player then
                                    TriggerServerEvent("medkit:checkHealth", player, itemName)
                                end
                            end
                        )
                        WarMenu.CloseMenu()
                    end
                    WarMenu.Display()
                    Citizen.Wait(0)
                end
            else
                exports.notify:display(
                    {
                        type = "error",
                        title = "Znalosti",
                        text = "Nemáš znalosti na použití!",
                        icon = "fas fa-heartbeat",
                        length = 5000
                    }
                )
            end
        end
    end
)

RegisterNetEvent("medkit:checkHealth")
AddEventHandler(
    "medkit:checkHealth",
    function(target, item, dead)
        if Config.Items[item].Type == "revive" then
            if dead then
                exports.progressbar:startProgressBar({
                    Duration = 15000,
                    Label = "Používáš " .. exports.inventory:getItem(item).label,
                    CanBeDead = false,
                    CanCancel = true,
                    DisableControls = {
                        Movement = true,
                        CarMovement = true,
                        Mouse = false,
                        Combat = true
                    },
                    Animation = Config.Items[item].Anim
                }, function(finished)
                    if finished then
                        TriggerServerEvent("medkit:revive", target, item)
                    end
                end)
            else
                exports.notify:display(
                    {
                        type = "error",
                        title = "Oživení",
                        text = "Člověk není v bezvědomí!",
                        icon = "fas fa-heartbeat",
                        length = 5000
                    }
                )
            end
        elseif Config.Items[item].Type == "heal" then
            if not dead then
                exports.progressbar:startProgressBar({
                    Duration = 10000,
                    Label = "Používáš " .. exports.inventory:getItem(item).label,
                    CanBeDead = false,
                    CanCancel = true,
                    DisableControls = {
                        Movement = true,
                        CarMovement = true,
                        Mouse = false,
                        Combat = true
                    },
                    Animation = Config.Items[item].Anim
                }, function(finished)
                    if finished then
                        if canUseitem(item) then
                            TriggerServerEvent("medkit:heal", target, Config.Items[item].Heal, item)
                        else
                            TriggerServerEvent("medkit:heal", target, Config.Items[item].Heal / 2, item)
                        end
                    end
                end)
            else
                exports.notify:display(
                    {
                        type = "error",
                        title = "Oživení",
                        text = "Této osobě pomoc jinak!",
                        icon = "fas fa-heartbeat",
                        length = 5000
                    }
                )
            end
        elseif Config.Items[item].Type == "food" then
            if not dead then
                exports.progressbar:startProgressBar({
                    Duration = 10000,
                    Label = "Používáš " .. exports.inventory:getItem(item).label,
                    CanBeDead = false,
                    CanCancel = true,
                    DisableControls = {
                        Movement = true,
                        CarMovement = true,
                        Mouse = false,
                        Combat = true
                    },
                    Animation = Config.Items[item].Anim
                }, function(finished)
                    if finished then
                        if canUseitem(item) then
                            TriggerServerEvent("medkit:infusion", target)
                        else
                            TriggerServerEvent("medkit:infusion", target)
                        end
                    end
                end)
            else
                exports.notify:display(
                    {
                        type = "error",
                        title = "Oživení",
                        text = "Této osobě pomoc jinak!",
                        icon = "fas fa-heartbeat",
                        length = 5000
                    }
                )
            end
        end
    end
)

RegisterNetEvent("medkit:heal")
AddEventHandler(
    "medkit:heal",
    function(health)
        local playerPed = PlayerPedId()
        local maxHealth = GetEntityMaxHealth(playerPed)
        local currentHealth = GetEntityHealth(playerPed)

        currentHealth = currentHealth + health
        if currentHealth > maxHealth then
            currentHealth = maxHealth
        end

        SetEntityHealth(playerPed, currentHealth)
    end
)

RegisterNetEvent("medkit:infusion")
AddEventHandler(
    "medkit:infusion",
    function()
        exports.needs:setNeed("hunger", 100.0)
        exports.needs:setNeed("thirst", 100.0)
    end
)

function canUseitem(itemName)
    if Config.Items[itemName].Allowed then
        for job, data in pairs(jobs) do
            if Config.Items[itemName].Allowed[data.Name] or Config.Items[itemName].Allowed[data.Type] then
                return true
            end
        end
    else
        return true
    end
    return false
end

function loadJobs(Jobs)
    jobs = {}
    for _, data in pairs(Jobs ~= nil and Jobs or exports.data:getCharVar("jobs")) do
        jobs[data.job] = {
            Name = data.job,
            Type = exports.base_jobs:getJobVar(data.job, "type"),
            Grade = data.job_grade,
            Duty = data.duty
        }
    end
end

function useItemOnYourself(itemName)
    exports.progressbar:startProgressBar({
        Duration = 10000,
        Label = "Používáš " .. exports.inventory:getItem(item).label,
        CanBeDead = false,
        CanCancel = true,
        DisableControls = {
            Movement = true,
            CarMovement = true,
            Mouse = false,
            Combat = true
        },
        Animation = Config.Items[item].Anim
    }, function(finished)
        if finished then
            local maxHealth = GetEntityMaxHealth(PlayerPedId())
            TriggerServerEvent("medkit:heal", "me", Config.Items[itemName].Heal, itemName)
        end
    end)
end
