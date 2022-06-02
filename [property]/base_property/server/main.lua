local property = {}
local loaded = false

Citizen.CreateThread(
    function()
        MySQL.ready(
            function()
                Wait(500)

                local currentTime = os.time()

                MySQL.Async.fetchAll(
                    "SELECT * FROM property",
                    {},
                    function(result)
                        if #result > 0 then
                            for _, res in each(result) do
                                local loadedProperty, propertyChanged = res, false
                                if type(loadedProperty.rooms) == "string" then
                                    loadedProperty.rooms = json.decode(loadedProperty.rooms)
                                end
                                for x, room in each(loadedProperty.rooms) do
                                    if tonumber(room.payment) and room.mates then
                                        local difference = currentTime - (tonumber(room.payment) + 86400 * 7)
                                        if difference > 0 then
                                            print (os.date("%X %x", tonumber(room.payment)), os.date("%X %x", tonumber(room.payment)  + 86400 * 7), difference)
                                            loadedProperty.rooms[x].mates = nil
                                            loadedProperty.rooms[x].payment = nil
                                            loadedProperty.rooms[x].customTag = nil
                                            loadedProperty.rooms[x].locked = true
                                            propertyChanged = true
                                        end
                                    end
                                end
                                local decodedCoords = json.decode(res.coords)
                                property[tostring(res.id)] = {
                                    coords = vec3(decodedCoords.x, decodedCoords.y, decodedCoords.z),
                                    type = loadedProperty.type,
                                    rooms = loadedProperty.rooms,
                                    changed = propertyChanged
                                }
                            end
                        end

                        print("^3[PROPERTY]^7 Successfully loaded with " .. tableLength(property) .. " properties!")
                        loaded = true
                        TriggerLatentClientEvent("property:sync", -1, 100000, property)
                    end
                )
            end
        )
        while true do
            Citizen.Wait(60000)
            saveChangedProperties()
        end
    end
)

function getPropertyData(propertyId)
    return property[tostring(propertyId)]
end

RegisterNetEvent("property:sync")
AddEventHandler(
    "property:sync",
    function()
        local client = source
        while not loaded do
            Citizen.Wait(10)
        end
        TriggerLatentClientEvent("property:sync", client, 100000, property)
    end
)

RegisterNetEvent("property:requestAccounts")
AddEventHandler(
    "property:requestAccounts",
    function(propId, roomId)
        local client = source
        if not property[propId].rooms[roomId].mates then
            local accountsToSend = getAccounts(client)
            TriggerClientEvent("property:requestAccounts", client, propId, roomId, accountsToSend)
        end
    end
)

RegisterNetEvent("property:eeLog")
AddEventHandler(
    "property:eeLog",
    function(inProperty, status)
        local client = source
        exports.logs:sendToDiscord(
            {
                channel = "ee-property",
                title = (not status and "Odchází z bytu" or "Vstupuje do bytu"),
                description = "Byt/dům č. " ..
                    inProperty.Id ..
                        (inProperty.Room ~= nil and (" | Pokoj č. " .. inProperty.Room) or "") ..
                            (inProperty.Onvisit and " POUZE NÁVŠTĚVA" or ""),
                color = "8782097"
            },
            client
        )
    end
)

RegisterNetEvent("property:buy")
AddEventHandler(
    "property:buy",
    function(account, propId, roomId)
        local client = source
        if not property[propId].rooms[roomId].mates then
            local price = property[propId].rooms[roomId].prices.buy
            local buyer =
                exports.data:getCharVar(client, "firstname") .. " " .. exports.data:getCharVar(client, "lastname")
            local pay =
                exports.bank:payFromAccountToAccount(
                tostring(account),
                "3217781859",
                price,
                false,
                "Koupě nemovitosti - provedl " .. buyer,
                "Koupě nemovitosti - " .. propId .. ", byt - " .. roomId
            )
            if pay == "done" then
                exports.logs:sendToDiscord(
                    {
                        channel = "property",
                        title = "Property",
                        description = "Koupil nemovitost - " .. propId .. ", byt - " .. roomId,
                        color = "16689183"
                    },
                    client
                )
                propertyUpdate(
                    propId,
                    "mates",
                    {
                        [tostring(exports.data:getCharVar(client, "id"))] = {
                            type = "owner",
                            label = buyer
                        }
                    },
                    roomId
                )
                propertyUpdate(propId, "payment", "never", roomId)
                propertyUpdate(propId, "locked", true, roomId)
                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "success",
                        title = "Koupě nemovitosti",
                        text = "Úspěšně jsi zakoupil/a nemovitost!",
                        icon = "fas fa-building",
                        length = 3000
                    }
                )
            else
                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "warning",
                        title = "Koupě nemovitosti",
                        text = "Na účtu je nedostatek financí!",
                        icon = "fas fa-building",
                        length = 4000
                    }
                )
            end
        end
    end
)

RegisterNetEvent("property:sell")
AddEventHandler(
    "property:sell",
    function(account, propId, roomId)
        local client = source
        local isOwner, _, _ = hasAccess(propId, roomId, client, true)
        if isOwner then
            local accounts = exports.bank:getPlayerAccesibleAccounts(client, "send")
            if accounts[account] then
                local seller =
                    exports.data:getCharVar(client, "firstname") .. " " .. exports.data:getCharVar(client, "lastname")
                local sell =
                    exports.bank:sendToAccount(
                    account,
                    property[propId].rooms[roomId].prices.buy * 0.7,
                    "Prodej nemovitosti - provedl " .. seller
                )
                if sell == "done" then
                    propertyUpdate(propId, "mates", nil, roomId)
                    propertyUpdate(propId, "payment", nil, roomId)
                    propertyUpdate(propId, "customTag", nil, roomId)
                    propertyUpdate(propId, "locked", true, roomId)
                    TriggerClientEvent(
                        "notify:display",
                        client,
                        {
                            type = "success",
                            title = "Prodej nemovitosti",
                            text = "Úspěšně jsi prodal/a nemovitost!",
                            icon = "fas fa-building",
                            length = 3000
                        }
                    )
                else
                    TriggerClientEvent(
                        "notify:display",
                        client,
                        {
                            type = "warning",
                            title = "Prodej nemovitosti",
                            text = "Zadaný účet neexistuje!",
                            icon = "fas fa-building",
                            length = 5000
                        }
                    )
                end
                TriggerClientEvent("property:sell", client, done)
            else
                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "warning",
                        title = "Prodej nemovitosti",
                        text = "K účtu nemáš přístup!",
                        icon = "fas fa-building",
                        length = 5000
                    }
                )
            end
        end
    end
)

RegisterNetEvent("property:rent")
AddEventHandler(
    "property:rent",
    function(propId, roomId)
        if not property[propId].rooms[roomId].mates then
            local client = source
            local rentPrice = property[propId].rooms[roomId].prices.rent

            local hasEnough = exports.inventory:checkPlayerItem(client, "cash", rentPrice, {})
            if hasEnough then
                exports.inventory:removePlayerItem(client, "cash", rentPrice, {})

                exports.bank:sendToAccount(
                    "3217781859",
                    rentPrice,
                    "Pronájem nemovitosti číslo " .. propId .. ", byt " .. roomId
                )
                exports.logs:sendToDiscord(
                    {
                        channel = "property",
                        title = "Property",
                        description = "Pronajal nemovitost - " .. propId .. ", byt - " .. roomId,
                        color = "16689183"
                    },
                    client
                )
                propertyUpdate(
                    propId,
                    "mates",
                    {
                        [tostring(exports.data:getCharVar(client, "id"))] = {
                            type = "owner",
                            label = exports.data:getCharVar(client, "firstname") ..
                                " " .. exports.data:getCharVar(client, "lastname")
                        }
                    },
                    roomId
                )
                propertyUpdate(propId, "payment", os.time() + Config.RentDuration, roomId)
                propertyUpdate(propId, "locked", true, roomId)

                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "success",
                        title = "Pronájem nemovitosti",
                        text = "Úspěšně jsi pronajal/a nemovitost!",
                        icon = "fas fa-building",
                        length = 3000
                    }
                )
            else
                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "warning",
                        title = "Pronájem nemovitosti",
                        text = "Nemáš dostatek hotovosti!",
                        icon = "fas fa-building",
                        length = 3000
                    }
                )
            end
        end
    end
)

RegisterNetEvent("property:checkPayment")
AddEventHandler(
    "property:checkPayment",
    function(propId, roomId)
        local client = source
        local isValid, toSend = true, {Enter = true}
        local payDate = property[propId].rooms[roomId].payment
        if payDate ~= "never" then
            local rentPrice = property[propId].rooms[roomId].prices.rent
            local currentTime = os.time()
            if payDate < currentTime then
                isValid = false
                toSend = {
                    Price = rentPrice,
                    TimeToCheck = (currentTime - payDate)
                }
            end
        end
        TriggerClientEvent("property:checkPayment", client, propId, roomId, toSend)
    end
)

RegisterNetEvent("property:payRent")
AddEventHandler(
    "property:payRent",
    function(propId, roomId)
        local client = source
        local isOwner, isMate, isJobbed = hasAccess(propId, roomId, client)
        if isOwner or isMate or isJobbed then
            local currentTime = os.time()
            local payDate = property[propId].rooms[roomId].payment
            local rentPrice = property[propId].rooms[roomId].prices.rent
            local daysMath = math.floor((currentTime - payDate) / Config.RentDuration)
            local toPay = (rentPrice * (daysMath == 0 and 1 or daysMath))

            local hasEnough = exports.inventory:checkPlayerItem(client, "cash", toPay, {})
            if hasEnough then
                exports.inventory:removePlayerItem(client, "cash", toPay, {})
                exports.bank:sendToAccount(
                    "3217781859",
                    rentPrice,
                    "Prodloužení pronájmu nemovitosti číslo " .. propId .. ", byt " .. roomId
                )
                propertyUpdate(propId, "payment", os.time() + Config.RentDuration, roomId)

                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "success",
                        title = "Prodloužení nájmu",
                        text = "Úspěšně jsi prodloužil/a pronájem nemovitosti!",
                        icon = "fas fa-building",
                        length = 4000
                    }
                )
            else
                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "warning",
                        title = "Prodloužení nájmu",
                        text = "Nemáš dostatek hotovosti!",
                        icon = "fas fa-building",
                        length = 3000
                    }
                )
            end
        end
    end
)

RegisterNetEvent("property:startCharSelect")
AddEventHandler(
    "property:startCharSelect",
    function(propId, roomId)
        local client = source
        local isOwner, isMate, isJobbed = hasAccess(propId, roomId, client)
        if isOwner or isMate or isJobbed then
            exports.chars:startCharSelect(client)
        end
    end
)

RegisterNetEvent("property:cancelRent")
AddEventHandler(
    "property:cancelRent",
    function(propId, roomId)
        local client = source
        local isOwner, _, _ = hasAccess(propId, roomId, client)
        if isOwner then
            propertyUpdate(propId, "mates", nil, roomId)
            propertyUpdate(propId, "payment", nil, roomId)
            propertyUpdate(propId, "customTag", nil, roomId)
            propertyUpdate(propId, "locked", true, roomId)
            TriggerClientEvent(
                "notify:display",
                client,
                {
                    type = "success",
                    title = "Zrušení pronájmu",
                    text = "Úspěšně jsi zrušil/a pronájem nemovitosti!",
                    icon = "fas fa-building",
                    length = 5000
                }
            )
        end
    end
)

RegisterNetEvent("property:doorAction")
AddEventHandler(
    "property:doorAction",
    function(propId, roomId, value)
        local client = source
        local isAllowed = false

        local isOwner, isMate, isJobbed = hasAccess(propId, roomId, client)
        if isOwner or isMate or isJobbed then
            isAllowed = true
        end

        if not isAllowed then
            isAllowed = exports.base_jobs:hasUserJobType(client, "police", true)
        end

        if not isAllowed then
            isAllowed = exports.data:getUserVar(client, "admin") > 1
        end

        if isAllowed then
            propertyUpdate(propId, "locked", value, roomId)
        else
            exports.admin:banClientForCheating(
                client,
                "0",
                "Cheating",
                "property:doorAction",
                "Pokus o odemknutí / zamknutí dveří bez oprávnění!"
            )
        end
    end
)

RegisterNetEvent("property:ring")
AddEventHandler(
    "property:ring",
    function(propId, roomId, type)
        local instace = ""
        if Config.DefaultSettings[property[propId].type][property[propId].rooms[roomId].type].Instance then
            instance = "property-" .. propId .. "-room-" .. roomId
        end
        TriggerEvent(
            "sound:playSound",
            type == "ring" and "doorbell" or "doorknock",
            20.0,
            Config.DefaultSettings[property[propId].type][property[propId].rooms[roomId].type].Exit.Coords.xyz,
            instance,
            instance
        )
    end
)

RegisterNetEvent("property:openRoomSettings")
AddEventHandler(
    "property:openRoomSettings",
    function(propId, roomId)
        local client = source
        local isAllowed = false

        local isOwner, isMate, isJobbed = hasAccess(propId, roomId, client)
        if isOwner or isMate or isJobbed then
            local expiredate = "never"
            if property[propId].rooms[roomId].payment ~= "never" then
                expiredate = os.date("%X %x", property[propId].rooms[roomId].payment)
            end
            TriggerClientEvent("property:openRoomSettings", client, propId, roomId, expiredate)
        end
    end
)

RegisterNetEvent("property:setTag")
AddEventHandler(
    "property:setTag",
    function(propId, roomId, newTag)
        local client = source
        local isOwner, isMate, isJobbed = hasAccess(propId, roomId, client)
        if isOwner or isMate or isJobbed then
            property[propId].rooms[roomId].customTag = newTag
            propertyUpdate(propId, "customTag", newTag, roomId)
            local expiredate = "never"
            if property[propId].rooms[roomId].payment ~= "never" then
                expiredate = os.date("%X %x", property[propId].rooms[roomId].payment)
            end
            TriggerClientEvent("property:openRoomSettings", client, propId, roomId, expiredate)
        else
            exports.admin:banClientForCheating(
                client,
                "0",
                "Cheating",
                "property:setTag",
                "Pokus o nastavení jmenovky bez oprávnění!"
            )
        end
    end
)

RegisterNetEvent("property:addMate")
AddEventHandler(
    "property:addMate",
    function(propId, roomId, target, grade)
        local client = source
        local isOwner, _, _ = hasAccess(propId, roomId, client, true)
        if isOwner then
            local mateData = {}
            local actuallyAdded = "Osoba je již spolubydlícím!"

            if type(target) == "number" then
                mateData = {
                    id = tostring(exports.data:getCharVar(target, "id")),
                    label = exports.data:getCharVar(target, "firstname") ..
                        " " .. exports.data:getCharVar(target, "lastname")
                }
            else
                actuallyAdded = "Zaměstnání je již přidáno!"
                mateData = {
                    id = target,
                    label = exports.base_jobs:getJobVar(target, "label"),
                    grade = tonumber(grade)
                }
            end

            if property[propId].rooms[roomId].mates[mateData.id] then
                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "warning",
                        title = "Nemovitost",
                        text = actuallyAdded,
                        icon = "fas fa-user-slash",
                        length = 3500
                    }
                )
            else
                property[propId].rooms[roomId].mates[mateData.id] = {
                    label = mateData.label,
                    type = "mate",
                    grade = mateData.grade
                }
                propertyUpdate(propId, "mates", property[propId].rooms[roomId].mates, roomId)
                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "success",
                        title = "Nemovitost",
                        text = "Užívej nového spolubydlícího!",
                        icon = "fas fa-users",
                        length = 3500
                    }
                )
                if mateData.id ~= target then
                    TriggerClientEvent(
                        "notify:display",
                        target,
                        {
                            type = "success",
                            title = "Nemovitost",
                            text = "Uživej spolubydlení!",
                            icon = "fas fa-users",
                            length = 3500
                        }
                    )
                end
            end
        end
    end
)

RegisterNetEvent("property:removeMate")
AddEventHandler(
    "property:removeMate",
    function(propId, roomId, target)
        local client = source

        local isOwner, _, _ = hasAccess(propId, roomId, client, true)
        if isOwner then
            property[propId].rooms[roomId].mates[tostring(target)] = nil
            propertyUpdate(propId, "mates", property[propId].rooms[roomId].mates, roomId)

            TriggerClientEvent(
                "notify:display",
                client,
                {
                    type = "info",
                    title = "Nemovitost",
                    text = "Odebral/a jsi osobu ze spolubydlení",
                    icon = "fas fa-user-minus",
                    length = 3500
                }
            )
        end
    end
)

RegisterNetEvent("property:create")
AddEventHandler(
    "property:create",
    function(coords, type)
        if exports.data:getUserVar(source, "admin") > 2 then
            createProperty(coords, type)
        else
            exports.admin:banClientForCheating(
                source,
                "0",
                "Cheating",
                "property:create",
                "Pokus o vytvoření nemovitosti bez oprávnění!"
            )
        end
    end
)
RegisterNetEvent("property:update")
AddEventHandler(
    "property:update",
    function(propId, var, value, roomId)
        local client = source
        if exports.data:getUserVar(client, "admin") > 1 then
            propertyUpdate(propId, var, value, roomId)
        else
            exports.admin:banClientForCheating(
                client,
                "0",
                "Cheating",
                "property:update",
                "Pokus o upravení nemovitosti bez oprávnění!"
            )
        end
    end
)

function createProperty(coords, type)
    local propertyId = generatePropertyId()

    MySQL.Async.execute(
        "INSERT INTO property (id, coords, type, rooms) VALUES (@id, @coords, @type, @rooms)",
        {
            ["@id"] = propertyId,
            ["@coords"] = json.encode(coords),
            ["@type"] = type,
            ["@rooms"] = json.encode({})
        }
    )
    property[tostring(propertyId)] = {
        coords = vec3(coords.x, coords.y, coords.z),
        type = type,
        rooms = {}
    }
    TriggerLatentClientEvent("property:sync", -1, 100000, property)
end

function propertyUpdate(propId, var, value, roomId)
    if roomId then
        property[propId].rooms[roomId][var] = value
    else
        property[propId][var] = value
    end
    property[propId].changed = true

    saveChangedProperties()
    if roomId then
        TriggerClientEvent(
            "property:updateProperty",
            -1,
            propId,
            nil,
            roomId,
            {Var = var, Value = value}
        )
    else
        TriggerClientEvent("property:updateProperty", -1, propId, {Var = var, Value = value})
    end
end

function saveChangedProperties()
    for i, prop in each(property) do
        if prop.changed then
            prop.changed = false
            MySQL.Async.execute(
                "UPDATE property SET rooms = @rooms WHERE id = @id",
                {
                    ["@id"] = tonumber(i),
                    ["@rooms"] = json.encode(prop.rooms)
                }
            )
        end
    end
end

AddEventHandler(
    "onResourceStop",
    function(resourceName)
        if (GetCurrentResourceName() == resourceName) then
            saveChangedProperties()
        end
    end
)

function getAccounts(source)
    local accountsToSend = {}
    local canAccessChar = exports.bank:getPlayerAccesibleAccounts(source, "send")
    for number, accountData in pairs(canAccessChar) do
        table.insert(accountsToSend, {tostring(number), accountData.name})
    end
    local jobs = exports.data:getCharVar(source, "jobs")
    for i, job in each(jobs) do
        local canAccessAcount = exports.bank:getJobAccesibleAccounts(job.job, job.job_grade, "send")
        for number, accountData in pairs(canAccessAcount) do
            table.insert(accountsToSend, {tostring(number), accountData.name})
        end
    end
    return accountsToSend
end

function tableLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

function generatePropertyId()
    while true do
        local number = math.random(1000, 9999)

        if not property[tostring(number)] then
            return number
        end
    end
    return nil
end

AddEventHandler(
    "txAdmin:events:scheduledRestart",
    function(eventData)
        if eventData.secondsRemaining == 60 then
            for i, prop in each(property) do
                MySQL.Async.execute(
                    "UPDATE property SET rooms = @rooms WHERE id = @id",
                    {
                        ["@id"] = tonumber(i),
                        ["@rooms"] = json.encode(prop.rooms)
                    }
                )
            end
        end
    end
)

--ADMIN CMDS
RegisterCommand(
    "property_removeowner",
    function(source, args)
        local client = source
        if exports.data:getUserVar(client, "admin") < 3 then
            return
        end

        if not args[2] then
            TriggerClientEvent(
                "chat:addMessage",
                client,
                {
                    templateId = "error",
                    args = {"Formulace: /property_removeowner [propId] [roomId]"}
                }
            )
            return
        end

        local propId = args[1]
        local roomId = tonumber(args[2])
        if not property[propId] or not property[propId].rooms[roomId] then
            TriggerClientEvent(
                "notify:display",
                client,
                {
                    type = "error",
                    title = "Úprava bytu",
                    text = "Tento byt neexistuje. Zkontroluj údaje",
                    icon = "fas fa-building",
                    length = 3000
                }
            )
            return
        end
        propertyUpdate(propId, "mates", nil, roomId)
        propertyUpdate(propId, "payment", nil, roomId)
        propertyUpdate(propId, "customTag", nil, roomId)
        propertyUpdate(propId, "locked", true, roomId)
        TriggerClientEvent(
            "notify:display",
            client,
            {
                type = "success",
                title = "Nemovitosti",
                text = "Úspěšně jsi smazal majitele nemovitosti",
                icon = "fas fa-building",
                length = 3000
            }
        )

        exports.logs:sendToDiscord(
            {
                channel = "admin-commands",
                title = "Odebrani majitele bytu",
                description = "Odebral majitele z bytu: " .. propId .. " a pokoje: " .. roomId,
                color = "34749"
            },
            client
        )
    end
)

function hasAccess(propId, roomId, client, onlyOwner)
    local isOwner, isMate, isJobbed = false, false, false
    if not propId or not roomId or not property[propId] or not property[propId].rooms[roomId] then
        if not propId or not roomId then
            print("hasAccess failed! Missing some args")
        elseif not property[propId].rooms[roomId] then
            print("hasAccess failed! Invalid property ID!")
        else
            print("hasAccess failed! Invalid Room ID!")
        end
        return isOwner, isMate, isJobbed
    end
    local room = property[propId].rooms[roomId]
    local charId = tostring(exports.data:getCharVar(client, "id"))

    if room.mates and tableLength(room.mates) > 0 then
        if room.mates[charId] and room.mates[charId].type == "owner" then
            isOwner = true
        end

        if not isOwner and not onlyOwner then
            if room.mates[charId] then
                isMate = true
            end
            if not isMate then
                for mate, data in pairs(room.mates) do
                    if exports.base_jobs:getJob(mate) then
                        if exports.base_jobs:hasUserJob(client, mate, (data.grade or 1), false) then
                            isJobbed = true
                            break
                        end
                    end
                end
            end
        end
    end
    return isOwner, isMate, isJobbed
end