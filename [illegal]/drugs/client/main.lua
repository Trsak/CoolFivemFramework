local currentInstance = nil
local closestObject = nil
local isSpawned, isDead = false, false
local isSpawned = false
local refreshCounter = 0

Citizen.CreateThread(function()
    Citizen.Wait(1000)

    local status = exports.data:getUserVar("status")
    if status == "spawned" or status == "dead" then
        isSpawned = true
        isDead = (status == "dead")
    end
end)

RegisterNetEvent("s:statusUpdated")
AddEventHandler("s:statusUpdated", function(status)
    if status == "choosing" then
        isSpawned, isDead = false, false
    elseif status == "spawned" or status == "dead" then
        if not isSpawned then
            TriggerServerEvent("drugs:requestLabs")
            isSpawned = true
        end
        isDead = (status == "dead")
    end
end)

RegisterNetEvent("instance:onEnter")
AddEventHandler("instance:onEnter", function(instance)
    currentInstance = instance
end)

RegisterNetEvent("instance:onLeave")
AddEventHandler("instance:onLeave", function()
    currentInstance = nil
end)

function checkCanPlantCoke()
    local playerPed = PlayerPedId()
    local crs = GetEntityCoords(playerPed)
    local shapeTestHandle = StartExpensiveSynchronousShapeTestLosProbe(crs, crs.xy, crs.z - 3.0, 1, playerPed, 7)
    local x, hit, y, z, material, a = GetShapeTestResultIncludingMaterial(shapeTestHandle)
    print(hit, material)
    print(Config.Materials[material])
    if not Config.Materials[material] then
        exports.notify:display({
            type = "error",
            title = "Chyba",
            text = "Do tohodle těžko něco zasadíš!",
            icon = "fas fa-exclamation-circle",
            length = 5000
        })
        return false
    end
    local zone = tostring(GetNameOfZone(crs.x, crs.y, crs.z))
    if zone ~= "ISHEIST" then
        exports.notify:display({
            type = "error",
            title = "Chyba",
            text = "Tady je na koku moc zima!",
            icon = "fas fa-exclamation-circle",
            length = 5000
        })
        return false
    end
    return true
end

RegisterNetEvent("drugs:itemUsed")
AddEventHandler("drugs:itemUsed", function(itemTemplate)
    if not itemTemplate then
        return
    end
    if IsEntityInWater(playerPed) then
        exports.notify:display({
            type = "error",
            title = "Chyba",
            text =  "Do vody? Vážně?",
            icon = "fas fa-exclamation-circle",
            length = 3000
        })
        return
    end
    if itemTemplate.Item == "cokeseed" and not checkCanPlantCoke() then
        return
    end

    exports.progressbar:startProgressBar({
        Duration = 1500,
        Label = itemTemplate.Item ~= "cokeseed" and "Pokládáš objekt.." or "Sázíš koku..",
        CanBeDead = false,
        CanCancel = true,
        DisableControls = {
            Movement = true,
            CarMovement = true,
            Mouse = false,
            Combat = true
        }
    }, function(finished)
        if finished then
            local newObjectData = {}
            newObjectData.owner = exports.data:getCharVar("id")
            newObjectData.data = makeNewObjectData(itemTemplate.Item)
            newObjectData.data.Instance = currentInstance
            newObjectData.data.Item = itemTemplate.Item

            local playerPed = PlayerPedId()
            local plyPos = GetEntityCoords(playerPed)
            local plyHeading = GetEntityHeading(playerPed)
            local objectProp = Config.Objects[itemTemplate.Item]
            local objectName = type(objectProp) == "string" and objectProp or objectProp[1]
            local dmin, dmax = GetModelDimensions(GetHashKey(objectName))
            local pos = GetOffsetFromEntityInWorldCoords(playerPed, 0, dmax.y * 2.5, 0)
            local npos = {
                x = pos.x,
                y = pos.y,
                z = plyPos.z,
                h = (plyHeading + 180.0 <= 360.0 and plyHeading + 180.0 or plyHeading - 180.0)
            }
            newObjectData.data.Position = npos

            TriggerServerEvent("drugs:newObject", itemTemplate.ObjectID, newObjectData)
        end
    end)
end)

Citizen.CreateThread(function()
    local rfrsh = 0
    while true do
        Citizen.Wait(1000)

        if isSpawned then
            local coords = GetEntityCoords(PlayerPedId())
            local newClosest = nil
            local dist, percent = 100.0, 0.0
            for i, object in pairs(Config.Objects) do
                if type(object) == "string" then
                    dist, newClosest, rfrsh = getClosestObject(object, dist, coords, newClosest, rfrsh)
                    percent = (newClosest and newClosest.Percent or 0.0)
                else
                    for i, obj in each(object) do
                        dist, newClosest, rfrsh = getClosestObject(obj, dist, coords, newClosest, rfrsh)
                        percent = (newClosest and newClosest.Percent or 0.0)
                    end
                end
            end
            
            if newClosest and (not closestObject or closestObject ~= newClosest) then
                exports.key_hints:displayBottomHint({
                    name = "drug_destroy",
                    key = "~INPUT_VEH_HEADLIGHT~",
                    text = "Zničit objekt"
                })
                if percent >= 98.0 then
                    exports.key_hints:displayBottomHint({
                        name = "drug_pickup",
                        key = "~INPUT_PICKUP~",
                        text = "Uklidit objekt"
                    })
                else
                    exports.key_hints:hideBottomHint({
                        name = "drug_pickup"
                    })
                end
            elseif closestObject and not newClosest then
                exports.key_hints:hideBottomHint({
                    name = "drug_pickup"
                })
                exports.key_hints:hideBottomHint({
                    name = "drug_destroy"
                })
            end

            closestObject = newClosest
        end
    end
end)

function makeNewObjectData(item)
    local newData = {}
    if item == "methtable" then
        newData = {
            Quality = 0.0,
            Percent = 0.0,
            Mix = 0.0,
            Battery = 0.0
        }
    elseif item == "tray_meth" then
        newData = {
            Percent = 0.0,
            Stage = 1
        }
    elseif item == "cokeseed" then
        newData = {
            Percent = 0.0
        }
    end
    return newData
end

function getTextForObject()
    local text = ""
    if closestObject then
        local item = closestObject.Item
        text = "Stav: " .. round(closestObject.Percent)
        if item == "methtable" then
            text = text .. "% | " .. "Kvalita: " .. round(closestObject.Quality) .. "% | Mix: " ..
                       round(closestObject.Mix) .. "% | Baterka: " .. round(closestObject.Battery) .. "%"
        elseif item == "tray_meth" or item == "cokeseed" then
            text = "Stav: " .. round(closestObject.Percent) .. "%"
        end
    end
    return text
end

function getClosestObject(targetObject, closestDistance, coords, newClosest, refresh)
    local closeObject = GetClosestObjectOfType(coords, 1.2, GetHashKey(targetObject))

    if DoesEntityExist(closeObject) and NetworkGetEntityIsNetworked(closeObject) then
        local entityCoords = GetEntityCoords(closeObject)
        local distance = #(coords - entityCoords)
        if closestDistance > distance then
            closestDistance = distance

            if closestObject and closestObject.Object == closeObject and refresh < 60 then
                refresh = refresh + 1
                newClosest = closestObject
            else
                refresh = 0

                local ent = Entity(closeObject)

                newClosest = ent.state.DrugData
                newClosest.Position = entityCoords
                newClosest.Object = closeObject
            end
        end
    end
    return closestDistance, newClosest, refresh
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)

        if closestObject then
            local plantText = getTextForObject()

            DrawText3D(closestObject.Position.x, closestObject.Position.y, closestObject.Position.z + 0.2, plantText)

            if IsControlJustReleased(1, 74) then
                destroyObject(closestObject.Id)
            elseif closestObject.Percent >= 98.0 and IsControlJustReleased(0, 38) then
                collectObject(closestObject.Id)
            end
        end
    end
end)

function destroyObject(objectId)
    TaskTurnPedToFaceEntity(PlayerPedId(), closestObject.Object, 1.0)
    exports.progressbar:startProgressBar({
        Duration = 800,
        Label = "Ničíš objekt...",
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
            TriggerServerEvent("drugs:destroyObject", objectId)
        end
    end)
end

function collectObject(objectId)
    TaskTurnPedToFaceEntity(PlayerPedId(), closestObject.Object, 1.0)
    exports.progressbar:startProgressBar({
        Duration = 800,
        Label = "Uklízíš objekt...",
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
            TriggerServerEvent("drugs:collectObject", objectId)
        end
    end)
end

function round(number)
    return string.format("%.1f", number)
end

RegisterNetEvent("drugs:actionDone")
AddEventHandler("drugs:actionDone", function()
    exports.emotes:cancelEmote()
    refreshCounter = 100
end)

RegisterNetEvent("drugs:useItem")
AddEventHandler("drugs:useItem", function(type, itemName, quality)
    local doing, duration = "Zaléváš", 500
    if type == "Mix" or type == "Battery" then
        if itemName == "methmix" then
            doing, duration = "Přiléváš mix...", 5000
        else
            doing, duration = "Připojuješ baterku...", 10000
        end
    end

    if closestObject and Config.Items[itemName].For == closestObject.Item then
        TaskTurnPedToFaceEntity(PlayerPedId(), closestObject.Object, 1.0)
        exports.progressbar:startProgressBar({
            Duration = duration,
            Label = doing,
            CanBeDead = false,
            CanCancel = true,
            DisableControls = {
                Movement = true,
                CarMovement = true,
                Mouse = false,
                Combat = true
            },
            Animation = Config.Items[itemName].Anim
        }, function(finished)
            if finished and closestObject then
                TriggerServerEvent("drugs:useItem", closestObject.Id, type, itemName, quality)
            end
        end)
    end
end)

RegisterNetEvent("drugs:packDrugs")
AddEventHandler("drugs:packDrugs", function(maxMethAmounts, maxCokeAmounts)
    Citizen.CreateThread(function()
        WarMenu.CreateMenu("drugs_pack", "Balení", "Vyber co budeš balit a druh balení")
        WarMenu.OpenMenu("drugs_pack")
        while WarMenu.IsMenuOpened("drugs_pack") do
            if maxMethAmounts then
                showButtons(maxMethAmounts, "meth")
            end
            if maxCokeAmounts then
                showButtons(maxCokeAmounts, "coke")
            end
            WarMenu.Display()

            Citizen.Wait(0)
        end
    end)
end)

function showButtons(amounts, type)
    local packEnd, countEnd = " kokainu", " kokain"
    if type == "meth" then
        packEnd, countEnd = " metamfetaminu", " meth"
    end

    for packType, maxAmount in pairs(amounts) do
        if maxAmount > 0 then
            local isBig = packType == "Big"
            if WarMenu.Button((isBig and "100g balení" or "1g balení") .. packEnd) then
                WarMenu.CloseMenu()
                openInput(type, packType, maxAmount)
            end
            -- if WarMenu.IsItemHovered() then
            --    WarMenu.ToolTip("~y~Potřeba:~s~\n1x sáček\n" .. (isBig and "100x" or "1x") .. countEnd, 0.06, false)
            -- end
        end
    end
end

function openInput(type, selectedPack, maxAmount)
    exports.input:openInput("number", {
        title = "Zadejte počet pytlíků (maximálně " .. maxAmount .. ")",
        placeholder = "0 - " .. maxAmount
    }, function(amount)
        if not amount then
            exports.notify:display({
                type = "error",
                title = "Chyba",
                text = "Musíš zadat počet!",
                icon = "fas fa-times",
                length = 3500
            })
        else
            amount = tonumber(amount)
            if not amount or amount < 0 or amount > maxAmount then
                exports.notify:display({
                    type = "error",
                    title = "Chyba",
                    text = "Počet musí být číslo od 0 do " .. maxAmount .. "!",
                    icon = "fas fa-times",
                    length = 3500
                })
            else
                if type == "meth" then
                    packMeth(amount, selectedPack)
                else
                    packCoke(amount, selectedPack)
                end
            end
        end
    end)
end
