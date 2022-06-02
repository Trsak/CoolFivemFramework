local isUsing = nil

Citizen.CreateThread(
    function()
        Citizen.Wait(500)

        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
        end
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned, isDead = false, false
        elseif status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
        end
    end
)

RegisterNetEvent("food:startDrink")
AddEventHandler(
    "food:startDrink",
    function(drink, amount, glassDrink)
        local playerPed = PlayerPedId()
        local drinkData = getItem(drink)

        if not drinkData.Anim then
            drinkData.Anim = "can"
        end
        isUsing, drinking = drink, false
        exports.emotes:DisableEmotes(true)
        loadModel(drinkData.Model)
        exports.notify:display(
            {
                type = "success",
                title = "Pití",
                text = "Začínáš pít",
                icon = "fas fa-beer",
                length = 3000
            }
        )
        startAnim(Config.Anims[drinkData.Anim].Base[1], Config.Anims[drinkData.Anim].Base[2], 3.0, 1.0, true)
        Citizen.Wait(100)
        local drink = CreateObject(GetHashKey(drinkData.Model), GetEntityCoords(playerPed), true, true, true)
        AttachEntityToEntity(
            drink,
            playerPed,
            GetPedBoneIndex(playerPed, drinkData.Place.Bone),
            drinkData.Place.Offset,
            drinkData.Place.Rotate,
            true,
            true,
            false,
            true,
            1,
            true
        )
        SetEntityCollision(drink, false, true)
        exports.key_hints:displayBottomHint(
            {
                name = "stop_food",
                key = "~INPUT_REPLAY_SHOWHOTKEY~",
                text = "Schovat pití"
            }
        )
        exports.key_hints:displayBottomHint(
            {
                name = "food",
                key = "~INPUT_REPLAY_SCREENSHOT~",
                text = "Napít se"
            }
        )

        while isUsing do
            if IsControlJustReleased(0, 303) and not drinking then
                drinking = true
                startAnim(
                    Config.Anims[drinkData.Anim].Drink[1],
                    Config.Anims[drinkData.Anim].Drink[2],
                    -1.0,
                    -1.0,
                    false
                )

                Citizen.Wait(Config.Anims[drinkData.Anim].Timeout)

                if glassDrink then
                    for need, data in pairs(Config.Drinks[glassDrink].Add) do
                        exports.needs:changeNeed(need, data / (Config.Drinks[glassDrink].Remove / drinkData.Remove))
                    end
                else
                    for need, data in pairs(drinkData.Add) do
                        exports.needs:changeNeed(need, data)
                    end
                end
                drinking, amount = false, (amount - drinkData.Remove <= 0 and 0 or amount - drinkData.Remove)
                startAnim(Config.Anims[drinkData.Anim].Base[1], Config.Anims[drinkData.Anim].Base[2], 1.0, -1.0, true)
                if amount == 0 then
                    hideFood(drink, 0)
                end
            elseif (IsControlJustReleased(0, 311) or isDead or not isSpawned) and not drinking then
                hideFood(drink, amount)
            end
            Citizen.Wait(0)
        end
    end
)

RegisterNetEvent("food:startEat")
AddEventHandler(
    "food:startEat",
    function(food, amount)
        local playerPed = PlayerPedId()
        local foodData = getItem(food)
        isUsing, eating = food, false
        exports.emotes:DisableEmotes(true)
        loadModel(foodData.Model)
        exports.notify:display(
            {
                type = "success",
                title = "Jídlo",
                text = "Začínáš jíst",
                icon = "fas fa-beer",
                length = 3000
            }
        )
        local animDict, animName, stopAnimSlow = Config.Anims[foodData.Anim][1], Config.Anims[foodData.Anim][2], Config.Anims[foodData.Anim][3]
        startAnim(animDict, animName, 3.0, 1.0, true)
        SetEntityAnimSpeed(playerPed, animDict, animName, 0.0)
        Citizen.Wait(100)
        local food = CreateObject(GetHashKey(foodData.Model), GetEntityCoords(playerPed), true, true, true)
        AttachEntityToEntity(
            food,
            playerPed,
            GetPedBoneIndex(playerPed, foodData.Place.Bone),
            foodData.Place.Offset,
            foodData.Place.Rotate,
            true,
            true,
            false,
            true,
            1,
            true
        )
        SetEntityCollision(food, false, true)
        exports.key_hints:displayBottomHint(
            {
                name = "stop_food",
                key = "~INPUT_REPLAY_SHOWHOTKEY~",
                text = "Schovat jídlo"
            }
        )
        exports.key_hints:displayBottomHint(
            {
                name = "food",
                key = "~INPUT_REPLAY_SCREENSHOT~",
                text = "Najíst se"
            }
        )

        while isUsing do
            if IsControlJustReleased(0, 303) and not eating then
                eating = true
                SetEntityAnimSpeed(playerPed, animDict, animName, 1.0)

                Citizen.Wait(1500)

                for need, data in pairs(foodData.Add) do
                    exports.needs:changeNeed(need, data)
                end
                eating, amount = false, (amount - foodData.Remove <= 0 and 0 or amount - foodData.Remove)
                if not stopAnimSlow then
                    SetEntityAnimSpeed(playerPed, animDict, animName, 0.0)
                end
                if amount == 0 then
                    hideFood(food, 0)
                end
            elseif IsControlJustReleased(0, 311) or isDead or not isSpawned and not eating then
                hideFood(food, amount)
            end
            Citizen.Wait(0)
        end
    end
)

function startAnim(dict, anim, blendInSpeed, blendOutSpeed, loop)
    local loopFlag = loop and 1 or 0

    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(0)
    end
    TaskPlayAnim(PlayerPedId(), dict, anim, blendInSpeed, blendOutSpeed, 1.0, 48 + loopFlag, 0.2, 0, 0, 0)
    RemoveAnimDict(dict)
end

function loadModel(model)
    while not HasModelLoaded(GetHashKey(model)) do
        RequestModel(GetHashKey(model))
        Citizen.Wait(0)
    end
end

function hideFood(item, amount)
    exports.key_hints:hideBottomHint({ name = "food" })
    exports.key_hints:hideBottomHint({ name = "stop_food" })
    exports.emotes:DisableEmotes(false)
    DetachEntity(item, 1, 1)
    Citizen.Wait(10)
    DeleteObject(item)
    ClearPedTasks(PlayerPedId())
    isUsing = false
    TriggerServerEvent("food:stopUsing", amount)
end

function getItem(itemName)
    if Config.Drinks[itemName] then
        return (Config.Drinks[itemName])
    elseif Config.Packs[itemName] then
        return (Config.Packs[itemName])
    elseif Config.Food[itemName] then
        return (Config.Food[itemName])
    elseif Config.Glass[itemName] then
        return (Config.Glass[itemName])
    end
end

RegisterNetEvent("food:openDrinkMenu")
AddEventHandler(
    "food:openDrinkMenu",
    function(availableGlass, sourceItem)
        WarMenu.CreateMenu("drink", "Rozlít nápoj", "Zvolte druh skleničky")
        WarMenu.OpenMenu("drink")
        while WarMenu.IsMenuOpened("drink") do
            for glass, data in pairs(availableGlass) do
                if WarMenu.Button(data.Max .. "x " .. data.Label, data.Add .. "ml") then
                    data.item = glass
                    TriggerServerEvent("food:spillDrink", data, sourceItem)
                    WarMenu.CloseMenu()
                end
            end
            WarMenu.Display()
            Citizen.Wait(0)
        end
    end
)

function getEatables()
    local keys = {}
    for key, _ in pairs(Config.Food) do
        table.insert(keys, key)
    end

    return keys
end

function getDrinkables()
    local keys = {}
    for key, _ in pairs(Config.Drinks) do
        table.insert(keys, key)
    end

    return keys
end
