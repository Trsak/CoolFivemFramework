local TE, TCE, TSE, RNE, RSE, AEH, CCT, SNM, RNC = TriggerEvent, TriggerClientEvent, TriggerServerEvent, RegisterNetEvent, RegisterNetEvent, AddEventHandler, Citizen.CreateThread, SendNUIMessage, RegisterNUICallback
isDead, spawned, jobName, gradeNumber, jobType, isOpen, craftingDrinks, isShowingHint, isClose = false, false, nil, nil, nil, false, false, false, false
local consumables = {}

AEH('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        spawned = true
        for _, v in each(exports.data:getCharVar("jobs")) do
            if v['duty'] then
                jobName = v.job
                gradeNumber = v.job_grade
                jobType = exports.base_jobs:getJobVar(v.job, "type")
                break
            end
        end
    end
end)

RNE("s:statusUpdated")
AEH("s:statusUpdated", function(status)
    isDead = (status == "dead")
    if status == "spawned" then
        spawned = true
        local anyJob = false
        for _, v in each(exports.data:getCharVar("jobs")) do
            if v['duty'] then
                anyJob = true
                jobName = v.job
                gradeNumber = v.job_grade
                jobType = exports.base_jobs:getJobVar(v.job, "type")
                break
            end
        end
        if not anyJob then
            jobName = nil
            gradeNumber =  nil
            jobType =  nil
        end
        TSE(GetHandlerName('getMeConsumables'))
    end
end)

RNE("s:jobUpdated")
AEH("s:jobUpdated", function(job)
    local anyJob = false
    for _, v in each(job) do
        if v['duty'] then
            anyJob = true
            jobName = v.job
            gradeNumber = v.job_grade
            jobType = exports.base_jobs:getJobVar(v.job, "type")
            break
        end
    end
    if not anyJob then
        jobName = nil
        gradeNumber =  nil
        jobType =  nil
    end
end)

RNE(GetHandlerName('getMeConsumables'))
AEH(GetHandlerName('getMeConsumables'), function(consumabl)
    consumables = consumabl
end)

RNE(GetHandlerName('refreshMenu'))
AEH(GetHandlerName('refreshMenu'), function(restaurant, itemName, drinks)
    if Config.Menus[restaurant] then
        local menu = (itemName == 'restaurant_menu')
        local boss = (exports.base_jobs:getJobGradeVar(jobName, gradeNumber, "rank") == "boss")
        craftingDrinks = drinks
        if Config.Debug then
            jobName = "namaste"
            boss = true
        end
        SNM({ action = "refresh", data = { menu = Config.Menus[restaurant], categories = Config.Categories, alcohol = drinks }, restaurant = restaurant, isMenu = menu, isBoss = boss, translate = Config.Translate})
    end
end)

RNE(GetHandlerName('openMenu'))
AEH(GetHandlerName('openMenu'), function(restaurant, itemName, drinks)
    if Config.Menus[restaurant] then
        local menu = (itemName == 'restaurant_menu')
        local boss = exports.base_jobs:getJobGradeVar(jobName, gradeNumber, "rank") == "boss"
        craftingDrinks = drinks
        isOpen = not isOpen
        if Config.Debug then
            jobName = "namaste"
            boss = true
        end
        SNM({ action = "open", data = { menu = Config.Menus[restaurant], categories = Config.Categories, alcohol = drinks }, restaurant = restaurant, isMenu = menu, isBoss = boss, translate = Config.Translate})
        SetNuiFocus(isOpen, isOpen)
    end
end)

function getConsumable(drinkId)
    if type(drinkId) == "number" then
        for type, item in each(consumables) do
            for name, data in each(item) do
                if data.id == drinkId then
                    return consumables[type][name]
                end
            end
        end
    elseif type(drinkId) == "string" then
        for type, item in each(consumables) do
            for name, data in each(item) do
                if data.img == drinkId then
                    return consumables[type][name]
                end
            end
        end
    end
    return nil
end

RNC('close', function()
    isOpen = not isOpen
    SetNuiFocus(isOpen, isOpen)
end)

RNC('addToMenu', function(data)
    Utils.DumpTable(data)
    TSE(GetHandlerName("UpdateItem"), 'addToMenu', data, jobName)
end)

RNC('removeFromMenu', function(data)
    TSE(GetHandlerName("UpdateItem"), "removeFromMenu", data, jobName)
end)

RNC('changePrice', function(data)
    TSE(GetHandlerName("UpdateItem"), "changePrice", data, jobName)
end)

RNC('craft', function(data)
    local drink = getConsumable(tonumber(data.drinkId))
    local playerItems = exports.inventory:getPlayerItems()
    local ready = true
    local usingItems = {}
    local craftTime = 0
    for _, item in each(playerItems) do
        if drink.production[item.name] then
            if item.count > drink.production[item.name] then
                craftTime = craftTime + drink.production[item.name]
                usingItems[item.name] ={
                    count = drink.production[item.name],
                    slot = item.slot,
                    data = item.data
                }
            end
        end
    end
    for k, v in each(drink.production) do
        if usingItem[k] == nil then
            ready = false
        end
    end

    if ready then
        exports.emotes:SecretEmotePlayByName(barpour, false)
        TriggerEvent("mythic_progbar:client:progress",
                {
                    name = "reload_magazine",
                    duration = Config.CraftTime * craftTime,
                    label = "Mícháš drink...",
                    useWhileDead = false,
                    canCancel = true,
                    controlDisables = {
                        disableMovement = false,
                        disableCarMovement = false,
                        disableMouse = false,
                        disableCombat = true
                    }
                },
                function(status)
                    if not status then
                        exports.emotes:cancelEmote()
                        --TSE('inventory:removeMultiplePlayerItems', usingItems)
                    end
                end
        )
    else
        exports.notify:display({type = "error", title = "Chyba", text = "Něco se posralo! 👿", icon = "fas fa-times", length = 5000})
    end
end)

RNC('newItem', function(data)
    if data.data then
        TSE(GetHandlerName("CreateDrink"), data.data)
    else
        exports.notify:display({type = "error", title = "Chyba", text = "Musíš vyplnit všechna pole! 👿", icon = "fas fa-times", length = 5000})
    end
end)