local isSpawned = false
local nearestShop = nil
local nearestDistance = 1000.0
local clothesData = {}
local jobsOutfits = {}
local isDisplayingHint = false
local jobs = {}
local showBlips = true
local blips = {}

local loadAgain = false
local selectedOutfitData = nil
Citizen.CreateThread(function()
    Citizen.Wait(500)

    local status = exports.data:getUserVar("status")
    if status == "spawned" or status == "dead" then
        TriggerServerEvent("clothes_shop:loadCharClothes")
        showBlips = exports.settings:getSettingValue("clothesBlips")
        isSpawned = true
        isDead = (status == "dead")
        if showBlips then
            createBlips()
        end

        loadJobs()
    end
end)

RegisterNetEvent("s:jobUpdated")
AddEventHandler("s:jobUpdated", function(toLoad)
    loadJobs(toLoad)
end)

RegisterNetEvent("s:statusUpdated")
AddEventHandler("s:statusUpdated", function(status)
    if status == "choosing" then
        isSpawned, jobs = false, {}
    elseif status == "spawned" and not isSpawned then
        TriggerServerEvent("clothes_shop:loadCharClothes")
        isSpawned = true
        loadJobs()
    end
end)

RegisterNetEvent("clothes_shop:removedClothe")
AddEventHandler("clothes_shop:removedClothe", function(onExit)
    exports.notify:display({
        type = "success",
        title = "Oblečení",
        text = "Oblečení bylo úspěšně odstraněno!",
        icon = "fas fa-tshirt",
        length = 3500
    })
    exports.skinchooser:loadSavedOutfit()
    selectedOutfitData = nil
end)

Citizen.CreateThread(function()
    while not isSpawned do
        Citizen.Wait(500)
    end

    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())
        nearestDistance = 1000.0
        nearestShop = nil

        for k, shop in pairs(Config.Shops) do
            local distance = #(playerCoords - shop.Coords)
            if distance < 50.0 and distance < nearestDistance then
                nearestDistance = distance
                nearestShop = shop.Coords
            end
        end

        Citizen.Wait(250)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if nearestShop then
            if nearestDistance < 2.5 then
                if not isDisplayingHint then
                    isDisplayingHint = true
                    exports.key_hints:displayBottomHint({
                        name = "clothes_shop_open",
                        key = "~INPUT_PICKUP~",
                        text = "Zakoupit oblečení a doplňky"
                    })
                end

                if IsControlJustPressed(1, 38) then
                    openStoreMenu()
                    Citizen.Wait(1000)
                end
            elseif isDisplayingHint then
                isDisplayingHint = false
                exports.key_hints:hideBottomHint({
                    name = "clothes_shop_open"
                })
            end
        elseif isDisplayingHint then
            isDisplayingHint = false
            exports.key_hints:hideBottomHint({
                name = "clothes_shop_open"
            })
        end
    end
end)

function openConfirmBuy(bought)
    if bought then
        WarMenu.CreateMenu("clothes_shop_confirm", "Oblečení", "Vyber akci")
        WarMenu.OpenMenu("clothes_shop_confirm")

        exports.emotes:playEmoteByName(getTryAnimation())

        while WarMenu.IsMenuOpened("clothes_shop_confirm") do

            if WarMenu.Button("Neukládat outfit") then
                WarMenu.CloseMenu()
            elseif #clothesData < 50 and WarMenu.Button("Uložit outfit") then

                exports.input:openInput("text", {
                    title = "Zadejte název outfitu",
                    placeholder = ""
                }, function(outfitName)
                    if outfitName then
                        WarMenu.CloseMenu()
                        local playerOutfit = exports.skinchooser:getPlayerOutfit()
                        TriggerServerEvent("clothes_shop:buyClothes", playerOutfit, outfitName)
                    end
                end)
            end

            WarMenu.Display()
            Citizen.Wait(0)
        end
        exports.emotes:cancelEmote()
    end
end

function openStoreMenu()
    WarMenu.CreateMenu("clothes_shop", "Oblečení", "Vyber akci")
    WarMenu.OpenMenu("clothes_shop")

    while WarMenu.IsMenuOpened("clothes_shop") do

        if WarMenu.Button("Koupit nové oblečení a doplňky") then
            WarMenu.CloseMenu()

            exports.skinchooser:openSkinMenu({
                ped = false,
                headBlend = false,
                faceFeatures = false,
                headOverlays = false,
                components = true,
                props = true,
                mask = true,
                tattoos = false,
                canLeave = true,
                vMenuPedsImportAllow = false,
                isShop = true
            }, {
                save = true,
                callback = function(bought)
                    openConfirmBuy(bought)
                end
            })
        elseif WarMenu.Button("Otevřít šatník") then
            WarMenu.CloseMenu()
            openClothesMenu("clothes")
        end

        WarMenu.Display()

        Citizen.Wait(0)
    end
end

RegisterNetEvent("clothes_shop:loadedCharClothes")
AddEventHandler("clothes_shop:loadedCharClothes", function(clothes)
    clothesData = clothes
    table.sort(clothesData, function(a, b)
        return a.name < b.name
    end)
end)

function openClothesMenu(menuToOpen)
    WarMenu.CreateMenu("clothes", "Šatník", "Vyberte typ šatníku")
    WarMenu.CreateSubMenu("clothes_char", "clothes", "Zvolte outfit")
    WarMenu.CreateSubMenu("clothes_char_edit", "clothes_char", "Zvolte akci")
    WarMenu.CreateSubMenu("clothes_job", "clothes", "Zvolte outfit")
    WarMenu.OpenMenu(menuToOpen or "clothes")

    FreezeEntityPosition(PlayerPedId(), true)

    local lastOption, selectedOutfitData = 0, false
    
    while true do
        if lastOption > 0 and not selectedOutfitData and not WarMenu.IsMenuOpened("clothes_char") and not WarMenu.IsMenuOpened("clothes_job") then
            exports.skinchooser:loadSavedOutfit()
            lastOption = 0
        end
        if WarMenu.IsMenuOpened("clothes") then
            WarMenu.MenuButton("Osobní šatník", "clothes_char")
            WarMenu.MenuButton("Firemní šatník", "clothes_job")

        elseif WarMenu.IsMenuOpened("clothes_char") then
            local index = 2
            local outifts = {}

            if WarMenu.Button("Uložit aktuální oblečení") then

                if #clothesData < 50 then
                    exports.input:openInput("text", {
                        title = "Zadejte název outfitu",
                        placeholder = ""
                    }, function(outfitName)
                        if outfitName and outfitName ~= "" then
                            local playerOutfit = exports.skinchooser:getPlayerOutfit()
                            TriggerServerEvent("clothes_shop:newOutfit", playerOutfit, outfitName)
                        else
                            exports.notify:display({
                                type = "error",
                                title = "Oblečení",
                                text = "Název oblečení nemůže být prázdný!",
                                icon = "fas fa-tshirt",
                                length = 3500
                            })
                        end
                    end)
                else
                    exports.notify:display({
                        type = "error",
                        title = "Oblečení",
                        text = "Můžeš mít uloženo maximálně 50 outfitů!",
                        icon = "fas fa-tshirt",
                        length = 3500
                    })
                end
            end

            for i, outfit in each(clothesData) do
                outifts[index] = outfit.data
                index = index + 1

                if WarMenu.MenuButton(outfit.name, "clothes_char_edit") then
                    selectedOutfitData = outfit
                end
            end

            local currentOption = WarMenu.CurrentOption()
            if lastOption ~= currentOption then
                lastOption = currentOption
                if not selectedOutfitData and currentOption == 1 then
                    exports.skinchooser:loadSavedOutfit()
                else
                    exports.emotes:playEmoteByName(getTryAnimation())
                    exports.skinchooser:setPlayerOutfit(outifts[currentOption], false)
                end
            end
        elseif WarMenu.IsMenuOpened("clothes_job") then
            if #(jobsOutfits) <= 0 then
                WarMenu.CloseMenu()
                WarMenu.OpenMenu("clothes")
                exports.notify:display({
                    type = "error",
                    title = "Šatník",
                    text = "Nemáš žádné dostupné firemní oblečení!",
                    icon = "fas fa-tshirt",
                    length = 3500
                })
            else

                local index, outifts, tookOutfit = 1, {}, false

                for i, outfit in each(jobsOutfits) do
                    outifts[index] = outfit.data
                    index = index + 1

                    if WarMenu.MenuButton(outfit.name, "clothes") then
                        exports.emotes:playEmoteByName(getTryAnimation())
                        exports.skinchooser:setPlayerOutfit(outfit.data, true)
                        tookOutfit, lastOption = true, 0
                        exports.notify:display({
                            type = "success",
                            title = "Oblečení",
                            text = "Oblékl/a sis firemní oblečení!",
                            icon = "fas fa-tshirt",
                            length = 3500
                        })
                    end
                end
                
                local currentOption = WarMenu.CurrentOption()
                if lastOption ~= currentOption and not tookOutfit then
                    lastOption = currentOption
                    exports.emotes:playEmoteByName(getTryAnimation())
                    exports.skinchooser:setPlayerOutfit(outifts[currentOption], false)
                end
            end
        elseif WarMenu.IsMenuOpened("clothes_char_edit") then
            if WarMenu.MenuButton("Obléct", "clothes_char") then
                exports.emotes:playEmoteByName(getTryAnimation())
                exports.skinchooser:setPlayerOutfit(selectedOutfitData.data, true)
                selectedOutfitData = nil
            elseif WarMenu.Button("Přejmenovat") then
                local outfitId = selectedOutfitData.id
                exports.input:openInput("text", {
                    title = "Zadejte nový název outfitu",
                    placeholder = ""
                }, function(outfitName)
                    if outfitName and outfitName ~= "" then
                        TriggerServerEvent("clothes_shop:updateOutfitName", outfitId, outfitName)
                    else
                        exports.notify:display({
                            type = "error",
                            title = "Oblečení",
                            text = "Název oblečení nemůže být prázdný!",
                            icon = "fas fa-tshirt",
                            length = 3500
                        })
                    end
                end)
            elseif WarMenu.MenuButton("Smazat", "clothes_char") then
                TriggerServerEvent("clothes_shop:removeClothe", selectedOutfitData.id)
            end
        else
            FreezeEntityPosition(PlayerPedId(), false)
            exports.emotes:cancelEmote()
            break
        end

        WarMenu.Display()

        Citizen.Wait(0)
    end

end

local savedOutfit = {}
function setSpecialOutfit(type)
    if not type or not Config.SpecialOutfits[type] then
        return
    end
    if not savedOutfit[type] then
        savedOutfit[type] = true
        local playerSex = exports.skinchooser:getPlayerSex() == 0 and "male" or "female"
        exports.skinchooser:setPlayerOutfit(Config.SpecialOutfits[type][playerSex])
    else
        exports.skinchooser:loadSavedOutfit()
        savedOutfit[type] = false
    end
end

function loadJobs(Jobs)
    jobs = {}
    for _, data in pairs(Jobs or exports.data:getCharVar("jobs")) do
        jobs[data.job] = {
            Name = data.job,
            Type = exports.base_jobs:getJobVar(data.job, "type"),
            Grade = data.job_grade,
            Duty = data.duty,
            Label = exports.base_jobs:getJobVar(data.job, "label")
        }
    end
    Citizen.Wait(100)
    jobsOutfits = {}
    local playerSex = (exports.skinchooser:getPlayerSex() == 0 and "male" or "female")

    for job, data in pairs(jobs) do
        if Config.JobsOutfits[job] then
            for grade, gradeOutfits in pairs(Config.JobsOutfits[job]) do
                if data.Grade >= tonumber(grade) then
                    for outfitName, outfit in pairs(gradeOutfits) do
                        table.insert(jobsOutfits, {
                            name = outfitName,
                            data = outfit[playerSex]
                        })
                    end
                end
            end
        end
    end
    table.sort(jobsOutfits, function(a, b)
        return a.name < b.name
    end)
end

function getTryAnimation()
    local sex = exports.skinchooser:getPlayerSex()

    if sex == 0 then
        return "adjusttie"
    else
        return "tryclothes"
    end
end

AddEventHandler("settings:changed", function(setting, value)
    if setting == "clothesBlips" then
        showBlips = value

        if not showBlips then
            for i, blip in each(blips) do
                RemoveBlip(blip)
            end

            blips = {}
        else
            createBlips()
        end
    end
end)

function createBlips()
    for _, shop in each(Config.Shops) do
        if not shop.Hidden then
            local blip = createNewBlip({
                coords = shop.Coords,
                sprite = 73,
                display = 4,
                scale = 0.7,
                colour = 0,
                isShortRange = true,
                text = "Obchod s oblečením"
            })
            table.insert(blips, blip)
        end
    end
end