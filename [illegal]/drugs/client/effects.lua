local announces = {
    coke = false,
    meth = false,
    super_pills_orange = false,
    super_pills_purple = false,
    super_pills_blue = false,
    super_pills_white = false
}
local takingPill = false

Citizen.CreateThread(function()
    Citizen.Wait(500)
    local status = exports.data:getUserVar("status")
    if status == "spawned" or status == "dead" then
        checkEffects()
    end
end)

RegisterNetEvent("chars:completelyLoaded")
AddEventHandler("chars:completelyLoaded", function()
    checkEffects()
end)

function checkEffects()
    for drug, _ in pairs(announces) do
        local drugValue = exports.needs:getNeed(drug)
        while not drugValue do
            drugValue = exports.needs:getNeed(drug)
            Citizen.Wait(500)
        end
        if drug == "meth" then
            methEffect(drugValue)
        elseif drug == "coke" then
            cokeEffect(drugValue)
        elseif string.match(drug, "super_pills") then
            super_pillsEffect(drug, drugValue)
        end
    end
end

AddEventHandler("inventory:usedItem", function(itemName, slot, data)
    local isPack = false
    if string.find(itemName, "super_pills_pack") then
        isPack = true
        isPack = "super_pills_" .. string.sub(itemName, 13)
    end
    
    local itemToCheck = (isPack or itemName)
    if announces[itemToCheck] ~= nil and not takingPill then
        if exports.needs:getNeed(itemToCheck) <= 0.0 then
            takePill(false, isPack, itemName, slot, data)
        else
            if not announces[itemToCheck] then
                exports.notify:display({
                    type = "extreme",
                    title = "Mozek",
                    text = "NE NE NE? Ani na to nemysli!",
                    icon = "fas fa-brain",
                    length = 3000
                })
                announces[itemToCheck] = true
            else
                takePill(true, isPack, itemName, slot, data)
                announces[itemToCheck] = false
            end
        end
    end
end)

RegisterNetEvent("needs:needChanged")
AddEventHandler("needs:needChanged", function(need, needValue)
    if need == "coke" then
        cokeEffect(needValue)
    elseif need == "meth" then
        methEffect(needValue)
    elseif need == "super_pills_purple" or need == "super_pills_orange" or need == "super_pills_blue" or need == "super_pills_white" then
        super_pillsEffect(need, needValue)
    end
end)

function takePill(shouldDie, isPack, itemName, slot, data)
    takingPill = true
    local animDict, anim, propData, length = "mp_suicide", "pill", nil, 2300
    local itemLabel = exports.inventory:getItem(itemName).label

    if not isPack then
        TriggerServerEvent("inventory:removePlayerItem", itemName, 1, data, slot)
        if itemName == "coke" or itemName == "meth" then
            animDict, anim, length = "safe@trevor@ig_8", "ig_8_huff_gas_player", 9500
        end
    else
        TriggerServerEvent("drugs:usePack", itemName, data, slot)
        animDict, anim = "friends@frl@ig_1","drink_lamar"
        itemLabel, length = string.sub(itemLabel, 10), 13000
        propData =
        {
            {
                Model = GetHashKey("super_pills_bottle1"),
                Bone = 60309,
                Offset = vec3(0.0, 0.04, -0.03),
                Rotate = vec3(-80.0, 20.0, -10.0)
            }
        }
    end
    
    exports.progressbar:startProgressBar({
        Duration = length,
        Label = "Dáváš si " .. itemLabel,
        CanBeDead = false,
        CanCancel = false,
        DisableControls = {
            Movement = false,
            CarMovement = false,
            Mouse = false,
            Combat = true
        },
        Animation = {
            animDict = animDict,
            anim = anim,
            flags = 51
        },
        Props = propData
    }, function(finished)
        if finished then
            if not shouldDie then
                if itemName == "coke" or itemName == "meth" then
                    exports.needs:setNeed(itemName, 30.0)
                else
                    exports.needs:setNeed((isPack or itemName), 20.0)
                end
                startEffect(itemName, isPack)
            else
                Citizen.SetTimeout(math.random(20000, 60000), function()
                    local playerPed = PlayerPedId()
                    exports.emotes:DisableEmotes(true)
                    animDict = "random@drunk_driver_1"
                    requestAnim(animDict)
                    TaskPlayAnim(playerPed, animDict, "drunk_fall_over", 8.0, -8.0, -1, 0, 0, false, false, false)
                    Citizen.Wait(7500)
                    SetEntityHealth(playerPed, 0.0)
                    exports.emotes:DisableEmotes(false)
                end)
            end
        end
        takingPill = false
    end)
end

function startEffect(itemName, isPack)
    local itemToUse = (isPack or itemName)

    if itemToUse == "coke" then -- DONE
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.2)
    elseif itemToUse == "meth" then -- DONE
        AddArmourToPed(PlayerPedId(), 15)
    elseif itemToUse == "super_pills_orange" then -- DONE
        addHealth(5)
        exports.needs:changeNeed("stress", -30.0)
    elseif itemToUse == "super_pills_purple" then -- FOOD
        exports.needs:changeNeed("stress", -20.0)
    elseif itemToUse == "super_pills_white" then -- DONE
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.2)
        exports.needs:changeNeed("stress", 20.0)
    elseif itemToUse == "super_pills_blue" then -- DONE
        addHealth(2)
        AddArmourToPed(PlayerPedId(), 15)
        exports.needs:changeNeed("stress", 30.0)
    end
end

function cokeEffect(value)

    -- print ("Coke", value)
    local super_pillsWhite = exports.needs:getNeed("super_pills_white")
    while not super_pillsWhite do
        super_pillsWhite = exports.needs:getNeed("super_pills_white")
        Citizen.Wait(100)
    end
    if value <= 20.0 and super_pillsWhite <= 10.0 then
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    end

    if value <= 15.0 then
        resetWalk(value, "coke")
    elseif value > 15.0 and value <= 20.0 then
        setDepressedWalk()
    elseif value > 20.0 and value < 30.0 then
        local effect = 1.2
        if value <= 250.0 then
            effect = 1.1
        end
        SetRunSprintMultiplierForPlayer(PlayerId(), effect)
    end
end

function methEffect(value)

    -- print ("Meth", value)
    if value < 15.0 then
        resetWalk(value, "meth")
    elseif value == 15.0 then
        local playerArmour = GetPedArmour(PlayerPedId())
        if playerArmour >= 15 then
            SetPedArmour(PlayerPedId(), playerArmour - 15)
        end
        resetWalk(value, "meth")
    elseif value > 15.0 and value <= 20.0 then
        setDepressedWalk()
    end
end

function super_pillsEffect(super_pillsType, value)

    if super_pillsType == "super_pills_white" then
        local coke = exports.needs:getNeed("coke")
        while not coke do
            Citizen.Wait(100)
            coke = exports.needs:getNeed("coke")
        end
        if value <= 10.0 and coke <= 20.0 then
            SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
        end
    elseif super_pillsType == "super_pills_blue" then
        if value > 10.0 and value < 20.0 then
            addHealth(2)
        end
    end
end

function setDepressedWalk()
    exports.emotes:DisableWalks(true)
    local walk = "move_m@depressed@a"

    requestWalk(walk)

    SetPedMovementClipset(PlayerPedId(), walk, true)
    RemoveAnimSet(walk)
end

function resetWalk(value, type)
    local secondType = (type == "coke" and "meth" or "coke")
    local secondValue = exports.needs:getNeed(secondType)
    while not secondValue or not value do
        value = exports.needs:getNeed(type)
        secondValue = exports.needs:getNeed(secondType)
        Citizen.Wait(100)
    end
    if (secondValue < 15.0 or secondValue > 20.0) and (value < 15.0 or value > 20.0) then
        -- print ("Reseting walk! Type is:", type, value, secondType, secondValue)
        exports.emotes:DisableWalks(false)
        local walk = exports.data:getCharVar("emotes").walk

        local playerPed = PlayerPedId()
        if walk and walk ~= "reset" then
            requestWalk(walk)

            SetPedMovementClipset(playerPed, walk, 0.2)
            RemoveAnimSet(walk)
        else
            ResetPedMovementClipset(playerPed)
        end
    end
end

function requestAnim(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(10)
    end
end

function requestWalk(walk)
    while not HasAnimSetLoaded(walk) do
        RequestAnimSet(walk)
        Citizen.Wait(1)
    end
end

function addHealth(toAddPercent)
    local playerPed = PlayerPedId()
    local maxHealth = GetEntityMaxHealth(playerPed)
    local currentHealth = GetEntityHealth(playerPed)

    currentHealth = currentHealth + ((maxHealth / 100) * toAddPercent)
    if currentHealth > maxHealth then
        currentHealth = maxHealth
    end

    SetEntityHealth(playerPed, currentHealth)
end