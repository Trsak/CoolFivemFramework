local isSpawned, isDead = false, false
local jobs, blips = {}, {}

local property = nil
local inProperty = false
local showingPropertyHint = false

Citizen.CreateThread(function()
    TriggerEvent("chat:removeSuggestion", "/property_dev")
    local status = exports.data:getUserVar("status")
    if status == "spawned" or status == "dead" then
        isSpawned = true
        isDead = (status == "dead")
        checkMisc()
    end
end)

RegisterNetEvent("s:statusUpdated")
AddEventHandler("s:statusUpdated", function(status)
    if status == "choosing" then
        if inProperty then
            deleteZones(property[inProperty.Id].type, inProperty.Property.type)
        end
        Citizen.Wait(100)
        isSpawned, isDead, jobs, inProperty = false, false, {}, false
    elseif status == "spawned" or status == "dead" then
        if not isSpawned then
            isSpawned = true
            checkMisc()
        end
        isDead = (status == "dead")
    end
end)

function checkMisc()
    loadJobs()
    TriggerServerEvent("property:sync")

    local in_property = exports.data:getCharVar("in_property")
    if not inProperty and in_property and in_property.id and in_property.room then
        while not property do
            Wait(250)
        end
        local propertyType = property[in_property.id].type
        local roomType = property[in_property.id].rooms[in_property.room].type
        inProperty = {
            Id = in_property.id,
            Room = in_property.room,
            Onvisit = in_property.onvisit,
            Property = property[in_property.id].rooms[in_property.room]
        }

        createZones(propertyType, roomType, in_property.onvisit)
        if inProperty and Config.DefaultSettings[propertyType][roomType].Instance then
            local propInstance = "property-" .. inProperty.Id .. "-room-" .. inProperty.Room
            local instance = ("char_select_" .. GetPlayerServerId(PlayerId()))
            while exports.instance:getPlayerInstance() == instance do
                Citizen.Wait(100)
            end
            TriggerServerEvent("instance:joinInstance", propInstance)
        end
    end
end

RegisterNetEvent("property:sync")
AddEventHandler("property:sync", function(serverData)
    property = serverData
    showBlips = exports.settings:getSettingValue("propertyBlips")
    if tableLength(blips) == 0 and showBlips then
        createPropertyBlips()
    end
end)

RegisterNetEvent("property:updateProperty")
AddEventHandler("property:updateProperty", function(propId, propData, roomId, roomData)
    while not property do
        Citizen.Wait(200)
    end
    if roomId then
        property[propId].rooms[roomId][roomData.Var] = roomData.Value
    elseif propId and not roomId then
        property[propId][propData.Var] = propData.Value
    end
end)

RegisterNetEvent("s:jobUpdated")
AddEventHandler("s:jobUpdated", function(newJobs)
    loadJobs(newJobs)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if isSpawned and not isDead and property then
            playerCoords = GetEntityCoords(PlayerPedId())
            local shouldBeDisplayingHint = false
            if not inProperty then
                for i, prop in pairs(property) do
                    if #(playerCoords - prop.coords) <= 2.0 then
                        shouldBeDisplayingHint = true
                        nearestProperty = i

                        if not showingPropertyHint then
                            showingPropertyHint = true
                            exports.key_hints:displayHint({
                                name = "property",
                                key = "~INPUT_A7BCE98F~",
                                text = Config.Appendices.Properties[prop.type].Label,
                                coords = prop.coords
                            })
                        end
                        break
                    end

                    for x, room in each(prop.rooms) do
                        if room.customDoors then
                            local roomCoords = vec3(room.customDoors.x, room.customDoors.y, room.customDoors.z)
                            if #(playerCoords - roomCoords) <= 1.0 then
                                shouldBeDisplayingHint = true
                                nearestProperty = i
                                nearestRoom = x

                                if not showingPropertyHint then
                                    showingPropertyHint = true

                                    exports.key_hints:displayHint({
                                        name = "property",
                                        key = "~INPUT_A7BCE98F~",
                                        text = "Pokoj číslo " .. x,
                                        coords = roomCoords
                                    })
                                end
                                break
                            end
                        end
                    end
                end
            else
                Citizen.Wait(1500)
            end
            if not shouldBeDisplayingHint and showingPropertyHint then
                resetHints()
                Citizen.Wait(100)
                WarMenu.CloseMenu()
            end
        else
            Citizen.Wait(1500)
        end
    end
end)

RegisterCommand("property", function()
    if not WarMenu.IsAnyMenuOpened() and nearestProperty then
        if not nearestRoom then
            openPropertyMenu(nearestProperty)
        else
            openRoomMenu(nearestProperty, nearestRoom, property[nearestProperty].rooms[nearestRoom].mates ~= nil)
        end
    end
end)
createNewKeyMapping({
    command = "property",
    text = "Menu nemovitostí",
    key = "E"
})

function openPropertyMenu(propId)
    if property[propId] then
        Citizen.CreateThread(function()
            local propType = Config.Appendices.Properties[property[propId].type].Room
            WarMenu.CreateMenu("property", "Nemovitost", "Zvolte " .. propType)
            WarMenu.OpenMenu("property")
            while WarMenu.IsMenuOpened("property") do
                for i, room in each(property[propId].rooms) do
                    local isOwned = room.mates and "~r~" or ""
                    local customTag = room.mates and room.customTag or ""

                    if WarMenu.Button(isOwned .. propType .. " č. " .. i, customTag) then
                        WarMenu.CloseMenu()
                        if not property[propId].rooms or not room then
                            TriggerEvent("chat:addMessage", {
                                templateId = "error",
                                args = {"Nastala chyba, zkus to prosím znovu"}
                            })
                        else
                            openRoomMenu(propId, i, (room.mates ~= nil), true)
                        end
                    end
                end
                WarMenu.Display()
                Citizen.Wait(0)
            end
        end)
    end
end

function openRoomMenu(propId, roomId, occupied, main)
    local isOwner, isMate, isJobbed = hasAccess(propId, roomId)
    local roomType = Config.Appendices.Properties[property[propId].type].Room
    WarMenu.CreateMenu("property-details", roomType .. " č. " .. roomId, "Vyberte akci")
    WarMenu.OpenMenu("property-details")

    while WarMenu.IsMenuOpened("property-details") do
        local propData = property[propId]
        local roomData = propData.rooms[roomId]
        if occupied then
            if isOwner or isMate or isJobbed then
                if WarMenu.CheckBox("Klíčky", roomData.locked, false, {"Odemknout", "Zamknout"}) then
                    roomData.locked = not roomData.locked
                    TriggerServerEvent("property:doorAction", propId, roomId, roomData.locked)
                end
            elseif (hasWhitelistedJobType() or exports.data:getUserVar("admin") > 1) and roomData.locked then
                if WarMenu.Button("Vykopnout dveře") then
                    menuAction("kickoff", propId, roomId)
                end
            end
            if WarMenu.CheckBox("Vstoupit", roomData.locked, false, {"Zamknuto", "Odemknuto"}) then
                if not roomData.locked or isOwner or isMate or isJobbed then
                    menuAction("enter", propId, roomId)
                else
                    exports.notify:display({
                        type = "warning",
                        title = "Nemovitost",
                        text = "Dveře jsou zamčené!",
                        icon = "fas fa-door-closed",
                        length = 3500
                    })
                end
            end
            if WarMenu.Button("Zazvonit") then
                menuAction("ring", propId, roomId)
            end
            if isOwner then
                if roomData.payment ~= "never" then
                    if WarMenu.Button("Zrušit pronájem") then
                        menuAction("cancelRent", propId, roomId)
                    end
                else
                    if WarMenu.Button("Prodat " .. roomType .. " za 70% ceny") then
                        menuAction("sell", propId, roomId)
                    end
                end
            end
        else
            if WarMenu.Button("Zakoupit " .. roomType, getFormattedCurrency(roomData.prices.buy)) then
                menuAction("buy", propId, roomId)
            elseif WarMenu.Button("Pronajmout " .. roomType, getFormattedCurrency(roomData.prices.rent)) then
                menuAction("rent", propId, roomId)
            elseif WarMenu.Button("Prohlédnout " .. roomType) then
                menuAction("visit", propId, roomId)
            end
        end
        if main then
            if WarMenu.Button("Zpět") then
                WarMenu.CloseMenu()
                Citizen.Wait(50)
                menuAction("back", propId)
            end
        end
        WarMenu.Display()
        Citizen.Wait(0)
    end
end

function hasAccess(propId, roomId)
    local room = property[propId].rooms[roomId]
    local isOwner, isMate, isJobbed = false, false, false
    local charId = tostring(exports.data:getCharVar("id"))

    if room.mates and tableLength(room.mates) > 0 then
        if room.mates[charId] and room.mates[charId].type == "owner" then
            isOwner = true
        end

        if not isOwner then
            if room.mates then
                if room.mates[charId] then
                    isMate = true
                end
            end
            if not isMate and tableLength(jobs) > 0 then
                for job, _ in pairs(jobs) do
                    if room.mates[job] then
                        isJobbed = true
                        break
                    end
                end
            end
        end
    end
    return isOwner, isMate, isJobbed
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

function hasWhitelistedJobType()
    if tableLength(jobs) > 0 then
        for k, v in pairs(jobs) do
            if Config.AbleToKickDoors[v.Type] and v.Duty then
                return true
            end
        end
    end

    return false
end

function teleport(coords)
    local playerPed = PlayerPedId()
    DoScreenFadeOut(1000)
    NetworkFadeOutEntity(PlayerPedId(), true, false)
    resetHints()
    Citizen.Wait(1000)

    FreezeEntityPosition(playerPed, true)
    SetEntityCoords(playerPed, tonumber(coords.x), tonumber(coords.y), tonumber(coords.z))

    while not HasCollisionLoadedAroundEntity(playerPed) do
        RequestCollisionAtCoord(tonumber(coords.x), tonumber(coords.y), tonumber(coords.z))
        Citizen.Wait(0)
    end

    FreezeEntityPosition(playerPed, false)
    Citizen.Wait(1000)
    DoScreenFadeIn(1000)
    NetworkFadeInEntity(playerPed, true)
end
function tableLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

function menuAction(action, propId, roomId, playerId)
    if action == "back" then
        openPropertyMenu(propId)
    elseif action == "visit" then
        enterProperty(propId, roomId, true)
        WarMenu.CloseMenu()
    elseif action == "rent" then
        TriggerServerEvent("property:rent", propId, roomId)
        WarMenu.CloseMenu()
    elseif action == "buy" then
        TriggerServerEvent("property:requestAccounts", propId, roomId)
    elseif action == "ring" then
        TriggerServerEvent("property:ring", propId, roomId, "ring")
        exports.notify:display({
            type = "info",
            title = "Nemovitost",
            text = "Zazvonil/a jsi na " .. Config.Appendices.Properties[property[propId].type].Room .. "!",
            icon = "fas fa-concierge-bell",
            length = 3500
        })
    elseif action == "enter" then
        if property[propId].rooms[roomId].payment == "never" then
            enterProperty(propId, roomId, false)
        else
            TriggerServerEvent("property:checkPayment", propId, roomId)
        end
        WarMenu.CloseMenu()
    elseif action == "kickoff" then
        WarMenu.CloseMenu()
        TriggerServerEvent("property:ring", propId, roomId, "kick")
        exports.progressbar:startProgressBar({
            Duration = 20000,
            Label = "Vykopáváš dveře..",
            CanBeDead = false,
            CanCancel = true,
            DisableControls = {
                Movement = true,
                CarMovement = true,
                Mouse = false,
                Combat = true
            },
            Animation = {
                animDict = "anim@mp_player_intcelebrationfemale@karate_chops",
                anim = "karate_chops"
            }
        }, function(finished)
            if finished then
                TriggerServerEvent("property:doorAction", propId, roomId, false)
            end
        end)
    elseif action == "sell" then
        exports.input:openInput("number", {
            title = "Zadejte bankovní účet",
            placeholder = ""
        }, function(account)
            if account then
                TriggerServerEvent("property:sell", account, propId, roomId)
            end
        end)
        WarMenu.CloseMenu()
    elseif action == "cancelRent" then
        TriggerServerEvent("property:cancelRent", propId, roomId)
        WarMenu.CloseMenu()
    elseif action == "addmate" then
        TriggerEvent("util:closestPlayer", {
            radius = 2.0
        }, function(player)
            if player then
                TriggerServerEvent("property:addMate", propId, roomId, player)
            end
        end)
        WarMenu.CloseMenu()
    elseif action == "addjob" then
        local nearestProperty = property[propId].rooms[roomId]
        Citizen.CreateThread(function()
            WarMenu.CreateMenu("property-addjob", "Přidání zaměstnání", "Zvolte zaměstnání")
            WarMenu.OpenMenu("property-addjob")

            while WarMenu.IsMenuOpened("property-addjob") do
                for jobName, value in pairs(jobs) do
                    if WarMenu.Button(exports.base_jobs:getJobVar(jobName, "label")) then
                        exports.input:openInput("number", {
                            title = "Zadejte číslo nejnižší hodnosti"
                        }, function(grade)
                            if grade and tonumber(grade) then
                                TriggerServerEvent("property:addMate", propId, roomId, jobName, grade)
                                WarMenu.CloseMenu()
                            end
                        end)
                    end
                end
                WarMenu.Display()
                Citizen.Wait(0)
            end
        end)
        WarMenu.CloseMenu()
    elseif action == "remove" then
        TriggerServerEvent("property:removeMate", propId, roomId, playerId)
        WarMenu.CloseMenu()
    elseif action == "tag" then
        local tag = property[propId].rooms[roomId].customTag
        exports.input:openInput("text", {
            title = "Zadejte jmenovku ke zvonku",
            placeholder = tag and tag or ""
        }, function(text)
            if text then
                TriggerServerEvent("property:setTag", propId, roomId, text)
                WarMenu.CloseMenu()
            end
        end)
    end
end

RegisterNetEvent("property:requestAccounts")
AddEventHandler("property:requestAccounts", function(propId, roomId, accounts)
    if tableLength(accounts) > 0 then
        WarMenu.CreateMenu("property-accounts", "Dostupné účty", "Vyberte účet pro transakci")
        WarMenu.OpenMenu("property-accounts")

        while WarMenu.IsMenuOpened("property-accounts") do
            for _, data in each(accounts) do
                if WarMenu.Button(data[2], data[1]) then
                    TriggerServerEvent("property:buy", data[1], propId, roomId)
                    WarMenu.CloseMenu()
                end
            end
            WarMenu.Display()
            Citizen.Wait(0)
        end
    else
        exports.notify:display({
            type = "error",
            title = "Nemovitost",
            text = "Nemáš dostupný žádný bankovní účet!",
            icon = "fas fa-door-closed",
            length = 5000
        })
    end
end)

RegisterNetEvent("property:openRoomSettings")
AddEventHandler("property:openRoomSettings", function(propId, roomId, expires)
    local isOwner, isMate, isJobbed = hasAccess(propId, roomId)
    local isBought = (expires == "never")
    if isOwner or isMate or isJobbed then
        Citizen.CreateThread(function()
            WarMenu.CreateMenu("property-inside", "Správa", "Zvolte akci")
            WarMenu.OpenMenu("property-inside")

            while WarMenu.IsMenuOpened("property-inside") do
                local nearestRoom = property[propId].rooms[roomId]
                if WarMenu.CheckBox("Klíčky", nearestRoom.locked, false, {"Zamknuto", "Odemknuto"}) then
                    nearestRoom.locked = not nearestRoom.locked
                    TriggerServerEvent("property:doorAction", propId, roomId, nearestRoom.locked)
                elseif WarMenu.Button("Nastavit jmenovku zvonku", nearestRoom.customTag) then
                    menuAction("tag", propId, roomId)
                end
                if isOwner then
                    if not isBought then
                        if WarMenu.Button("Datum splacení pronájmu:", expires) then
                        end
                    end
                    if WarMenu.Button("Spolubydlící") then
                        openMatesMenu(propId, roomId)
                    end
                end
                WarMenu.Display()
                Citizen.Wait(0)
            end
        end)
    end
end)

RegisterNetEvent("property:checkPayment")
AddEventHandler("property:checkPayment", function(propId, roomId, data)
    if data.Enter or hasWhitelistedJobType() then
        enterProperty(propId, roomId, false)
    else
        local isOwner, isMate, isJobbed = hasAccess(propId, roomId)
        if isOwner or isMate or isJobbed then
            local daysMath = math.floor(data.TimeToCheck / Config.RentDuration)
            local daysMissing = (daysMath == 0 and 1 or daysMath)
            local price = property[propId].rooms[roomId].prices.rent

            Citizen.CreateThread(function()
                WarMenu.CreateMenu("property-payrent", "Nedoplatek nájmu", "Zvolte vaši možnost")
                WarMenu.OpenMenu("property-payrent")

                while WarMenu.IsMenuOpened("property-payrent") do
                    if WarMenu.Button("Zaplatit nájem", getFormattedCurrency(price * daysMissing)) then
                        WarMenu.CloseMenu()
                        TriggerServerEvent("property:payRent", propId, roomId)
                    elseif WarMenu.Button("Přijít později...") then
                        WarMenu.CloseMenu()
                    end
                    WarMenu.Display()
                    Citizen.Wait(0)
                end
            end)
        else
            exports.notify:display({
                type = "warning",
                title = "Nemovitost",
                text = "Tebe neznám a nevypadáš, že bys mi zaplatil nájem!",
                icon = "fas fa-door-closed",
                length = 5000
            })
        end
    end
end)

function enterProperty(propId, roomId, onvisit)
    local propertyType = property[propId].type
    local roomData = property[propId].rooms[roomId]

    createZones(propertyType, roomData.type, onvisit)

    inProperty = {
        Id = propId,
        Room = roomId,
        Onvisit = onvisit,
        Property = property[propId].rooms[roomId]
    }
    TriggerServerEvent("s:updateInProperty", {
        id = propId,
        room = roomId,
        onvisit = onvisit
    })

    TriggerServerEvent("property:eeLog", inProperty, true)

    teleport(Config.DefaultSettings[propertyType][roomData.type].Exit.Coords)

    if Config.DefaultSettings[propertyType][roomData.type].Instance then
        TriggerServerEvent("instance:joinInstance", "property-" .. propId .. "-room-" .. roomId)
    end
end

AddEventHandler("settings:changed", function(setting, value)
    if setting == "propertyBlips" then
        showBlips = value
        if not showBlips then
            for i, blip in each(blips) do
                RemoveBlip(blip)
            end
            blips = {}
        else
            createPropertyBlips()
        end
    end
end)

function createPropertyBlips()
    while not property do
        Citizen.Wait(0)
    end
    if tableLength(blips) <= 0 then
        for _, prop in each(property) do
            local blip = createNewBlip({
                coords = prop.coords,
                sprite = Config.Appendices.Properties[prop.type].Blip,
                display = 2,
                scale = 0.6,
                colour = 0,
                isShortRange = true,
                text = Config.Appendices.Properties[prop.type].Label
            })

            table.insert(blips, blip)
        end
    end
end

function resetHints()
    if currentPoint == "Exit" then
        exports.key_hints:hideBottomHint({
            name = "property_manage"
        })
    end
    exports.key_hints:hideHint({
        name = "property"
    })
    nearestProperty, nearestRoom, currentPoint = nil, nil, nil
    showingPropertyHint = false
end

function openMatesMenu(propId, roomId)
    Citizen.CreateThread(function()
        WarMenu.CreateMenu("property-flatmates", "Spolubydlící", "Zvolte akci")
        WarMenu.OpenMenu("property-flatmates")

        while WarMenu.IsMenuOpened("property-flatmates") do
            if WarMenu.Button("Přidat spolubydlícího") then
                menuAction("addmate", propId, roomId)
            end
            if tableLength(jobs) > 0 then
                if WarMenu.Button("Přidat spolubydlící firmu") then
                    menuAction("addjob", propId, roomId)
                end
            end
            for playerCharId, value in pairs(property[propId].rooms[roomId].mates) do
                if value.type ~= "owner" then
                    if WarMenu.Button(value.label, (tonumber(playerCharId) and "Osoba" or (value.grade or "0"))) then
                        menuAction("remove", propId, roomId, playerCharId)
                    end
                end
            end
            WarMenu.Display()
            Citizen.Wait(0)
        end
    end)
end

function roomAction(point)
    local exitingProperty = property[inProperty.Id]
    local exitingRoom = exitingProperty.rooms[inProperty.Room]
    if point == "Exit" then
        local isOwner, isMate, isJobbed = hasAccess(inProperty.Id, inProperty.Room)
        if not exitingRoom.locked or inProperty.Onvisit or isOwner or isMate or isJobbed then
            deleteZones(exitingProperty.type, inProperty.Property.type)

            TriggerServerEvent("instance:quitInstance")

            if exitingRoom.customDoors then
                teleport(exitingRoom.customDoors)
            else
                teleport(exitingProperty.coords)
            end
            TriggerServerEvent("property:eeLog", inProperty, false)
            inProperty = false
            TriggerServerEvent("s:updateInProperty", {})
        else
            exports.notify:display({
                type = "warning",
                title = "Nemovitost",
                text = "Dveře jsou zamčené!",
                icon = "fas fa-door-closed",
                length = 3500
            })
        end
    elseif point == "Storage" then
        local neededRoom = inProperty.Property
        local data = Config.DefaultSettings[exitingProperty.type][neededRoom.type].Storage
        TriggerServerEvent("inventory:openStorage", "storage", "prop_" .. inProperty.Id .. "room_" .. inProperty.Room, {
            maxWeight = data.MaxWeight,
            maxSpace = data.MaxSpace,
            label = "Sklad #" .. inProperty.Id .. " #" .. inProperty.Room
        })
    elseif point == "Fridge" then
        local neededRoom = inProperty.Property
        local data = Config.DefaultSettings[exitingProperty.type][neededRoom.type].Fridge
        TriggerServerEvent("inventory:openStorage", "fridge", "prop_" .. inProperty.Id .. "room_" .. inProperty.Room, {
            maxWeight = data.MaxWeight,
            maxSpace = data.MaxSpace,
            label = "Lednice  #" .. inProperty.Id .. " #" .. inProperty.Room
        })
    elseif point == "Cloakroom" then
        exports.clothes_shop:openClothesMenu()
    elseif point == "CharSelect" then
        resetHints()
        TriggerServerEvent("property:startCharSelect", inProperty.Id, inProperty.Room)
    end
end

function createZones(propType, roomType, onvisit)
    for place, data in pairs(Config.DefaultSettings[propType][roomType]) do
        if place ~= "Instance" and place ~= "Prices" and place ~= "AdminName" then
            if place ~= "Exit" and not onvisit or place == "Exit" and onvisit then
                exports.target:AddCircleZone("property-" .. propType .. "-" .. roomType .. "-" .. place, data.Coords,
                    1.0, {
                        actions = {
                            action = {
                                cb = function()
                                    if not WarMenu.IsAnyMenuOpened() then
                                        roomAction(place)
                                    end
                                end,
                                icon = Config.Appendices.Places[place].Icons[1],
                                label = Config.Appendices.Places[place].Labels[1]
                            }
                        },
                        distance = 0.3
                    })
            elseif place == "Exit" and not onvisit then
                exports.target:AddCircleZone("property-" .. propType .. "-" .. roomType .. "-" .. place, data.Coords,
                    1.0, {
                        actions = {
                            action = {
                                cb = function()
                                    if not WarMenu.IsAnyMenuOpened() then
                                        roomAction(place)
                                    end
                                end,
                                icon = Config.Appendices.Places[place].Icons[1],
                                label = Config.Appendices.Places[place].Labels[1]
                            },
                            manage = {
                                cb = function()
                                    if not WarMenu.IsAnyMenuOpened() then
                                        TriggerServerEvent("property:openRoomSettings", inProperty.Id, inProperty.Room)
                                    end
                                end,
                                icon = Config.Appendices.Places[place].Icons[2],
                                label = Config.Appendices.Places[place].Labels[2]
                            }
                        },
                        distance = 0.3
                    })
            end
        end
    end
end

function deleteZones(propType, roomType)
    for place, data in pairs(Config.DefaultSettings[propType][roomType]) do
        if place ~= "Instance" and place ~= "Prices" and place ~= "AdminName" then
            exports.target:RemoveZone("property-" .. propType .. "-" .. roomType .. "-" .. place)
        end
    end
end

RegisterCommand("property_dev", function()
    if exports.data:getUserVar("admin") > 1 then
        Citizen.CreateThread(function()
            WarMenu.CreateMenu("property_dev", "Tvorba nemovitosti", "Zvolte akci")
            WarMenu.OpenMenu("property_dev")
            WarMenu.CreateSubMenu("property_create", "property_dev", "Vyberte typ nemovitosti")
            WarMenu.CreateSubMenu("property_room", "property_dev", "Zvolte typ místnosti")

            while true do
                if WarMenu.IsMenuOpened("property_dev") then
                    if WarMenu.MenuButton("Vytvořit nemovitost", "property_create") then
                    elseif WarMenu.MenuButton("Přidat místnost", "property_room") then
                    elseif WarMenu.Button("Nejbližší nemovitost") then
                        local founded = nil
                        local playerCoords = GetEntityCoords(PlayerPedId())
                        for i, prop in pairs(property) do
                            if #(playerCoords - prop.coords) <= 2.0 then
                                founded = i
                                break
                            end
                        end
                        if founded then
                            TriggerEvent("chat:addMessage", {
                                templateId = "success",
                                args = {"Nejblížší nemovitostí je: " .. founded .. "."}
                            })
                        else
                            TriggerEvent("chat:addMessage", {
                                templateId = "error",
                                args = {"Nejsi poblíž žádné nemovitosti!"}
                            })
                        end
                    elseif WarMenu.Button("Vlastní dveře pro místnost") then
                        exports.input:openInput("number", {
                            title = "Zadejte číslo nemovitosti!",
                            placeholder = ""
                        }, function(propId)
                            if propId then
                                exports.input:openInput("number", {
                                    title = "Zadejte číslo pokoje!",
                                    placeholder = ""
                                }, function(roomId)
                                    if roomId then
                                        if property[tostring(propId)] and
                                            property[tostring(propId)].rooms[tonumber(roomId)] then
                                            local playerCoords = GetEntityCoords(PlayerPedId())
                                            TriggerServerEvent("property:update", tostring(propId), "customDoors", {
                                                x = playerCoords.x,
                                                y = playerCoords.y,
                                                z = playerCoords.z
                                            }, tonumber(roomId))
                                            TriggerEvent("chat:addMessage", {
                                                templateId = "success",
                                                args = {"Úspěšně jsi přidal vlastní dveře bytu"}
                                            })
                                        end
                                    end
                                end)
                            end
                        end)
                    end
                    WarMenu.Display()
                elseif WarMenu.IsMenuOpened("property_create") then
                    for property, _ in pairs(Config.DefaultSettings) do
                        if WarMenu.Button(property) then
                            local playerCoords = GetEntityCoords(PlayerPedId())
                            TriggerServerEvent("property:create", {
                                x = playerCoords.x,
                                y = playerCoords.y,
                                z = playerCoords.z
                            }, property)
                            TriggerEvent("chat:addMessage", {
                                templateId = "success",
                                args = {"Nemovitost vytvořena!"}
                            })
                        end
                    end
                    WarMenu.Display()
                elseif WarMenu.IsMenuOpened("property_room") then
                    local founded = nil
                    for i, prop in pairs(property) do
                        local playerCoords = GetEntityCoords(PlayerPedId())

                        if #(playerCoords - prop.coords) <= 2.0 then
                            founded = i
                            break
                        end
                    end
                    if founded then
                        local propertyType = property[founded].type
                        for room, v in pairs(Config.DefaultSettings[propertyType]) do
                            if WarMenu.Button(room, v.AdminName) then
                                exports.input:openInput("number", {
                                    title = "Zadejte měsíční cenu nájmu!",
                                    placeholder = ""
                                }, function(rent)
                                    if rent then
                                        exports.input:openInput("number", {
                                            title = "Zadejte cenu!",
                                            placeholder = ""
                                        }, function(buy)
                                            if buy then
                                                table.insert(property[founded].rooms, {
                                                    type = room,
                                                    mates = nil,
                                                    prices = {
                                                        rent = tonumber(rent),
                                                        buy = tonumber(buy)
                                                    }
                                                })
                                                TriggerServerEvent("property:update", founded, "rooms",
                                                    property[founded].rooms)
                                                TriggerEvent("chat:addMessage", {
                                                    templateId = "success",
                                                    args = {"Úspěšně přidána místnost!"}
                                                })
                                            end
                                        end)
                                    end
                                end)
                            end
                        end
                    else
                        WarMenu.OpenMenu("property_dev")
                    end
                    WarMenu.Display()
                else
                    break
                end
                Citizen.Wait(0)
            end
        end)
    else
        TriggerEvent("chat:addMessage", {
            templateId = "error",
            args = {"Na toto nemáš právo!"}
        })
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        if inProperty then
            deleteZones(property[inProperty.Id].type, inProperty.Property.type)
        end
    end
end)
