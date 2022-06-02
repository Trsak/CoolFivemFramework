local isSpawned, isDead = false, false
local currentLocation = nil
local jobs = {}

Citizen.CreateThread(function()
    Citizen.Wait(500)
    while not exports.data:isUserLoaded() do
        Citizen.Wait(100)
    end

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
        isSpawned, isDead, jobs = false, false, {}
    elseif status == "spawned" or status == "dead" then

        isDead = (status == "dead")
        if not isSpawned then
            isSpawned = true
            loadJobs()
            TriggerServerEvent("kathrin:sync")
        end
    end
end)

RegisterNetEvent("s:jobUpdated")
AddEventHandler("s:jobUpdated", function(newJobs)
    loadJobs(newJobs)
end)

RegisterNetEvent("kathrin:sync")
AddEventHandler("kathrin:sync", function(location, npcNetId)
    exports.target:AddCircleZone("kathrin", location, 1.0, {
        actions = {
            action = {
                cb = function()
                    if not (hasWhitelistedJob() and WarMenu.IsAnyMenuOpened()) then
                        TriggerServerEvent("kathrin:openMenu")
                    end
                end,
                icon = "fas fa-book-dead",
                label = "Zaklepat na dveře"
            }
        },
        distance = 0.2
    })
    if npcNetId then
        setHintGuy(npcNetId)
    end
end)

RegisterNetEvent("kathrin:createHintGuy")
AddEventHandler("kathrin:createHintGuy", function(netId)
    setHintGuy(netId)
end)

RegisterNetEvent("kathrin:openMenu")
AddEventHandler("kathrin:openMenu", function()
    exports.emotes:playEmoteByName("knock")
    Citizen.Wait(3300)
    exports.emotes:cancelEmote()
    openMenu()
end)

function openMenu(coords)
    local currentCoords = GetEntityCoords(PlayerPedId())
    Citizen.CreateThread(function()
        WarMenu.CreateMenu("kathrin", "Kathrin", "Vyber předmět, který chceš prodat")
        WarMenu.OpenMenu("kathrin")

        table.sort(Config.Items, function(a, b)
            return a.Label < b.Label
        end)
        while WarMenu.IsMenuOpened("kathrin") do
            if WarMenu.Button("Zeptat se na Ryan") then
                TriggerServerEvent("kathrin:askForRyan")
                WarMenu.CloseMenu()
            end

            for i, itemData in each(Config.Items) do
                if WarMenu.Button("Prodat " .. itemData.Label) then
                    exports.input:openInput("number", {
                        title = "Zadej počet, který chceš prodat!",
                        placeholder = ""
                    }, function(amount)
                        local amount = tonumber(amount)
                        if amount and amount > 0 then
                            sellItem(itemData.Item, itemData.Label, amount)
                        else
                            exports.notify:display({
                                type = "error",
                                title = "Kathrin",
                                text = "Buď něco nabídni, nebo jdi pryč.",
                                icon = "fas fa-book-dead",
                                length = 3000
                            })
                        end
                    end)
                end
            end
            if #(GetEntityCoords(PlayerPedId()) - currentCoords) >= 1.2 then
                WarMenu.CloseMenu()
            end
            WarMenu.Display()

            Citizen.Wait(0)
        end
    end)
end

local shouldStop = false
function sellItem(item, label, itemsToSell)
    exports.progressbar:startProgressBar({
        Duration = 500,
        Label = "Prodáváš " .. label,
        CanBeDead = false,
        CanCancel = true,
        DisableControls = {
            Movement = true,
            CarMovement = true,
            Mouse = false,
            Combat = true
        },
        Animation = {
            animDict = "mp_arresting",
            anim = "a_uncuff",
            flags = 51
        }
    }, function(finished)
        if finished then
            TriggerServerEvent("kathrin:sell", itemsToSell, item)
            itemsToSell = itemsToSell - 1

            if shouldStop then
                shouldStop = false
            elseif itemsToSell > 0 then
                sellItem(item, label, itemsToSell)
            end
        else
            TriggerServerEvent("kathrin:stopSelling")
        end
    end)
end

RegisterNetEvent("kathrin:stopSell")
AddEventHandler("kathrin:stopSell", function()
    shouldStop = true
end)

local debug = false
function setHintGuy(netId)

    while not NetworkDoesEntityExistWithNetworkId(netId) do
        if debug then
            print (":)")
        end
        Citizen.Wait(2500)
    end
    local npcHandle = NetToPed(netId)
    if debug then
        print (NetworkDoesEntityExistWithNetworkId(netId), DoesEntityExist(npcHandle))
    end
    exports.target:AddTargetObject({GetEntityModel(npcHandle)}, {
        actions = {
            ask = {
                cb = function()
                    if not (hasWhitelistedJob() and WarMenu.IsAnyMenuOpened()) then
                        TriggerServerEvent("kathrin:askForKathrin")
                    end
                end,
                icon = "fas fa-comments",
                label = "Oslovit chlapíka"
            }
        },
        netId = netId,
        distance = 1.5
    })
    SetPedResetFlag(npcHandle, 249, 1)
    SetPedConfigFlag(npcHandle, 185, true)
    SetPedConfigFlag(npcHandle, 108, true)
    SetPedConfigFlag(npcHandle, 208, true)
    SetEntityCanBeDamaged(npcHandle, false)
    SetPedCanBeTargetted(npcHandle, false)
    SetPedCanBeDraggedOut(npcHandle, false)
    SetPedCanBeTargettedByPlayer(npcHandle, PlayerId(), false)
    SetBlockingOfNonTemporaryEvents(npcHandle, true)
    SetPedCanRagdollFromPlayerImpact(npcHandle, false)
    SetEntityAsMissionEntity(npcHandle, true, true)
    SetPedHearingRange(npcHandle, 0.0)
    SetPedSeeingRange(npcHandle, 0.0)
    SetPedAlertness(npcHandle, 0.0)
    SetPedFleeAttributes(npcHandle, 0, 0)
    SetPedCombatAttributes(npcHandle, 46, true)
    SetPedFleeAttributes(npcHandle, 0, 0)
    SetEntityInvincible(npcHandle, true)
    TaskPlayAnim(npcHandle, "amb@world_human_drug_dealer_hard@male@base", "base", 1.0, 1.0, -1, 1, 0)
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

function hasWhitelistedJob()
    for _, data in pairs(jobs) do
        if Config.WhitelistedJobs[data.Type] or Config.WhitelistedJobs[data.Name] then
            return true
        end
    end
    return false
end

RegisterCommand("kathrin", function()
    if exports.data:getUserVar("admin") > 1 then
        debug = not debug
        print (debug)
    end
end)