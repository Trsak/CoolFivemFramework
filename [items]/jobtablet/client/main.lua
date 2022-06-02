local isOpened = false
local isDead = false

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "dead" then
            isDead = true

            if isOpened then
                isOpened = false
                SendNUIMessage(
                    {
                        type = "close"
                    }
                )
            end
        end
    end
)

RegisterNetEvent("inventory:usedItem")
AddEventHandler(
    "inventory:usedItem",
    function(itemName, slot, data)
        if itemName == "jobtablet" then
            startUsingJobTablet()
        end
    end
)

function startUsingJobTablet()
    local playerJobs = exports.data:getCharVar("jobs")
    local jobsWithTablet = {}

    for _, jobData in each(playerJobs) do
        if Config.JobWebsites[jobData.job] then
            jobData.label = exports.base_jobs:getJob(jobData.job).label
            table.insert(jobsWithTablet, jobData)
        end
    end

    if #jobsWithTablet > 0 then
        useJobTablet(jobsWithTablet)
    else
        exports.notify:display({ type = "error", title = "Chyba", text = "Firmy ve kterých pracuješ nemají žádný firemní tablet!", icon = "fas fa-times", length = 5000 })
    end
end

function useJobTablet(jobsWithTablet)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

    if #jobsWithTablet == 1 then
        TriggerServerEvent("jobtablet:used", jobsWithTablet[1].job, (vehicle ~= 0))
    else
        Citizen.CreateThread(
            function()
                WarMenu.CreateMenu("jobtablet", "Firemní tablet", "Zvolte práci")
                WarMenu.SetMenuY("admin", 0.35)
                WarMenu.OpenMenu("jobtablet")

                while true do
                    if WarMenu.IsMenuOpened("jobtablet") then
                        for _, jobData in each(jobsWithTablet) do
                            if WarMenu.Button(jobData.label) then
                                TriggerServerEvent("jobtablet:used", jobData.job, (vehicle ~= 0))
                                WarMenu.CloseMenu()
                            end
                        end

                        WarMenu.Display()
                    else
                        break
                    end

                    Citizen.Wait(0)
                end
            end
        )
    end
end

RegisterNetEvent("jobtablet:open")
AddEventHandler(
    "jobtablet:open",
    function(url, inVeh)
        if not isDead then
            isOpened = true
            SendNUIMessage(
                {
                    action = "open",
                    url = url
                }
            )
            SetNuiFocus(true, true)

            if inVeh == nil or inVeh == false then
                exports.emotes:playEmoteByName("tablet2")
            end
        end
    end
)

RegisterNetEvent("jobtablet:error")
AddEventHandler(
    "jobtablet:error",
    function(error)
        exports.notify:display({ type = "error", title = "Chyba", text = error, icon = "fas fa-times", length = 5000 })
    end
)

RegisterCommand("tablet", function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh ~= 0 then
        if GetVehicleClass(veh) == 18 then
            startUsingJobTablet()
        else
            exports.notify:display({ type = "error", title = "Chyba", text = "Nejste v emergency vozidle", icon = "fas fa-times", length = 5000 })
        end
    else
        exports.notify:display({ type = "error", title = "Chyba", text = "Nejste v emergency vozidle", icon = "fas fa-times", length = 5000 })
    end
end)

RegisterNUICallback(
    "close",
    function(data, cb)
        isOpened = false
        SetNuiFocus(false, false)

        exports.emotes:cancelEmote()
    end
)
