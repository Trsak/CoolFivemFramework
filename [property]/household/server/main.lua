local houses = {}
local loaded = false

Citizen.CreateThread(
    function()
        MySQL.ready(
            function()
                Wait(500)
                local currentTime = os.time()
                MySQL.Async.fetchAll(
                    "SELECT * FROM houses",
                    {},
                    function(result)
                        for i, res in each(result) do
                            local loadedHouse, changed = res, true
                            if type(loadedHouse.mates) == "string" then
                                loadedHouse.mates = json.decode(loadedHouse.mates)
                            end
                            if type(loadedHouse.settings) == "string" then
                                loadedHouse.settings = json.decode(loadedHouse.settings)
                            end
                            if type(loadedHouse.points) == "string" then
                                loadedHouse.points = json.decode(loadedHouse.points)
                            end
                            local coords = json.decode(loadedHouse.coords)
                            local houseSign = nil
                            if loadedHouse.type == "open" and (not loadedHouse.mates or tableLength(loadedHouse.mates) <= 0) then
                                houseSign = createSign(vec4(coords.x, coords.y, coords.z, coords.w))
                            end

                            if loadedHouse.settings and tonumber(loadedHouse.settings.payment) and loadedHouse.type ~= "open" then
                                local difference = currentTime - (tonumber(loadedHouse.settings.payment) + 86400 * 7)
                                if difference > 0 then
                                    print (os.date("%X %x", tonumber(loadedHouse.settings.payment)), os.date("%X %x", tonumber(loadedHouse.settings.payment)  + 86400 * 7), difference)
                                    loadedHouse.mates = {}
                                    loadedHouse.settings = {}
                                    changed = true
                                end
                            end



                            houses[tostring(loadedHouse.id)] = {
                                type = loadedHouse.type,
                                prices = json.decode(loadedHouse.prices),
                                coords = vec4(coords.x, coords.y, coords.z, coords.w or 0.0),
                                points = loadedHouse.points,
                                mates = loadedHouse.mates,
                                settings = loadedHouse.settings,
                                sign = houseSign,
                                changed = changed
                            }
                        end
                        print("^3[HOUSEHOLD]^7 Successfully loaded with " .. tableLength(houses) .. " houses!")
                        loaded = true

                        TriggerLatentClientEvent("household:sync", -1, 100000, houses)
                    end
                )
            end
        )
        while true do
            Citizen.Wait(60000)
            saveChangedHouses()
        end
    end
)

function getHouseDetails(houseId)
    return houses[tostring(houseId)]
end

RegisterNetEvent("household:sync")
AddEventHandler(
    "household:sync",
    function()
        local client = source
        while not loaded do
            Citizen.Wait(10)
        end
        TriggerLatentClientEvent("household:sync", client, 100000, houses)
    end
)

RegisterNetEvent("household:rent")
AddEventHandler(
    "household:rent",
    function(houseId)
        if tableLength(houses[houseId].mates) <= 0 then
            local client = source
            local rentPrice = tonumber(houses[houseId].prices.rent)

            local hasEnough = exports.inventory:checkPlayerItem(client, "cash", rentPrice, {})
            if hasEnough then
                exports.inventory:removePlayerItem(client, "cash", rentPrice, {})
                exports.bank:sendToAccount("3217781859", rentPrice, "Pronájem nemovitosti číslo " .. houseId)

                exports.logs:sendToDiscord(
                    {
                        channel = "property",
                        title = "Household",
                        description = "Pronajal nemovitost - " .. houseId,
                        color = "16689183"
                    },
                    client
                )
                houseUpdate(
                    houseId,
                    "mates",
                    {
                        [tostring(exports.data:getCharVar(client, "id"))] = {
                            type = "owner",
                            label = exports.data:getCharVar(client, "firstname") ..
                                " " .. exports.data:getCharVar(client, "lastname"),
                            perms = {
                                manage = true,
                                storage = true,
                                vault = true,
                                cloakroom = true,
                                fridge = true,
                                mates = true
                            }
                        }
                    }
                )
                local newSettings = {
                    locked = true,
                    payment = os.time() + Config.RentDuration
                }
                houseUpdate(houseId, "settings", newSettings)

                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "success",
                        title = "Pronájem domu",
                        text = "Úspěšně jsi pronajal/a dům!",
                        icon = "fas fa-home",
                        length = 3000
                    }
                )
            else
                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "warning",
                        title = "Pronájem domu",
                        text = "Nemáš dostatek hotovosti!",
                        icon = "fas fa-home",
                        length = 3000
                    }
                )
            end
        end
    end
)

RegisterNetEvent("household:requestAccounts") -- DONE
AddEventHandler(
    "household:requestAccounts",
    function(houseId)
        local client = source
        if tableLength(houses[houseId].mates) <= 0 then
            local accountsToSend = getAccounts(client)
            TriggerClientEvent("household:requestAccounts", client, houseId, accountsToSend)
        end
    end
)

RegisterNetEvent("household:cancelRent")
AddEventHandler(
    "household:cancelRent",
    function(houseId)
        local client = source
        local isOwner, _, _ = hasAccess(houseId, client, true)

        if isOwner then
            houseUpdate(houseId, "mates", {})
            houseUpdate(houseId, "settings", {})
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

RegisterNetEvent("household:removeMate")
AddEventHandler(
    "household:removeMate",
    function(houseId, target)
        local client = source
        local isOwner, _, _ = hasAccess(houseId, client, true)

        if isOwner then
            houses[houseId].mates[tostring(target)] = nil
            houseUpdate(houseId, "mates", houses[houseId].mates)

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

RegisterNetEvent("household:buy") -- DONE
AddEventHandler(
    "household:buy",
    function(account, houseId)
        local client = source
        if tableLength(houses[houseId].mates) <= 0 then
            local price = tonumber(houses[houseId].prices.buy)
            local buyer =
                exports.data:getCharVar(client, "firstname") .. " " .. exports.data:getCharVar(client, "lastname")
            local pay =
                exports.bank:payFromAccountToAccount(
                tostring(account),
                "3217781859",
                price,
                false,
                "Koupě nemovitosti - provedl " .. buyer,
                "Koupě nemovitosti - " .. houseId
            )
            if pay == "done" then
                exports.logs:sendToDiscord(
                    {
                        channel = "property",
                        title = "Household",
                        description = "Zakoupil nemovitost - " .. houseId,
                        color = "16689183"
                    },
                    client
                )
                houseUpdate(
                    houseId,
                    "mates",
                    {
                        [tostring(exports.data:getCharVar(client, "id"))] = {
                            type = "owner",
                            label = exports.data:getCharVar(client, "firstname") ..
                                " " .. exports.data:getCharVar(client, "lastname"),
                            perms = {
                                manage = true,
                                storage = true,
                                vault = true,
                                cloakroom = true,
                                fridge = true,
                                mates = true
                            }
                        }
                    }
                )
                local newSettings = {
                    locked = true,
                    payment = "never"
                }
                houseUpdate(houseId, "settings", newSettings)
                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "success",
                        title = "Koupě nemovitosti",
                        text = "Úspěšně jsi zakoupil/a nemovitost!",
                        icon = "fas fa-home",
                        length = 3000
                    }
                )
            else
                print("[HOUSEHOLD] Payment canceled, reason: " .. pay)
                TriggerClientEvent(
                    "notify:display",
                    client,
                    {
                        type = "warning",
                        title = "Koupě nemovitosti",
                        text = "Na účtu je nedostatek financí!",
                        icon = "fas fa-home",
                        length = 4000
                    }
                )
            end
        end
    end
)

RegisterNetEvent("household:doorAction") -- DONE
AddEventHandler(
    "household:doorAction",
    function(houseId, value)
        local client = source
        local isAllowed = false
        local isOwner, isMate, isJobbed = hasAccess(houseId, client)

        if isOwner or isMate or isJobbed then
            isAllowed = true
        end

        if not isAllowed then
            isAllowed =
                exports.base_jobs:hasUserJobType(client, "police", true) or
                exports.data:getUserVar(client, "admin") >= 2
        end

        if isAllowed then
            houseUpdate(houseId, "settings", value)
        else
            exports.admin:banClientForCheating(
                client,
                "0",
                "Cheating",
                "household:doorAction",
                "Pokus o odemknutí / zamknutí dveří bez oprávnění!"
            )
        end
    end
)

RegisterNetEvent("household:mateAction") -- DONE
AddEventHandler(
    "household:mateAction",
    function(houseId, value)
        local client = source
        local isAllowed = false
        local isOwner, isMate, isJobbed = hasAccess(houseId, client)

        if isOwner or isMate or isJobbed then
            isAllowed = true
        end
        if isAllowed then
            houseUpdate(houseId, "mates", value)
        else
            exports.admin:banClientForCheating(
                client,
                "0",
                "Cheating",
                "household:doorAction",
                "Pokus o odemknutí / zamknutí dveří bez oprávnění!"
            )
        end
    end
)

RegisterNetEvent("household:setTag") -- DONE
AddEventHandler(
    "household:setTag",
    function(houseId, newTag)
        local client = source
        local isAllowed = false
        local isOwner, isMate, isJobbed = hasAccess(houseId, client)

        if isOwner or isMate or isJobbed then
            isAllowed = true
        end

        if isAllowed then
            houses[houseId].settings.customTag = newTag
            houseUpdate(houseId, "settings", houses[houseId].settings)
            local expiredate = "never"
            if houses[houseId].settings.payment ~= "never" then
                expiredate = os.date("%X %x", houses[houseId].settings.payment)
            end
            TriggerClientEvent("household:openRoomSettings", client, houseId, expiredate)
        else
            exports.admin:banClientForCheating(
                client,
                "0",
                "Cheating",
                "household:setTag",
                "Pokus o nastavení jmenovky bez oprávnění!"
            )
        end
    end
)

RegisterNetEvent("household:payRent")
AddEventHandler(
    "household:payRent",
    function(houseId)
        local client = source
        local isOwner, isMate, isJobbed = hasAccess(houseId, client)

        if isOwner or isMate or isJobbed then
            local currentTime = os.time()
            local payDate = houses[houseId].settings.payment
            local rentPrice = houses[houseId].prices.rent
            local daysMath = math.floor((currentTime - payDate) / Config.RentDuration)
            local toPay = (rentPrice * (daysMath == 0 and 1 or daysMath))

            local hasEnough = exports.inventory:checkPlayerItem(client, "cash", toPay, {})
            if hasEnough then
                exports.inventory:removePlayerItem(client, "cash", toPay, {})
                exports.bank:sendToAccount(
                    "3217781859",
                    rentPrice,
                    "Prodloužení pronájmu nemovitosti číslo " .. houseId
                )
                local newSettings = houses[houseId].settings
                newSettings.payment = os.time() + Config.RentDuration
                houseUpdate(houseId, "settings", newSettings)

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

RegisterNetEvent("household:checkPayment")
AddEventHandler(
    "household:checkPayment",
    function(houseId)
        local client = source

        local isValid = true
        local date = houses[houseId].settings.payment
        local checkTime = os.time()
        if date < checkTime then
            isValid = false
        end
        TriggerClientEvent(
            "household:checkPayment",
            client,
            houseId,
            houses[houseId].prices.rent,
            isValid,
            (checkTime - date)
        )
    end
)

RegisterNetEvent("household:ring")
AddEventHandler(
    "household:ring",
    function(houseId, type)
        if houses[houseId].type ~= "open" then
            local instance = ""
            if Config.DefaultSettings[houses[houseId].type].Instance then
                instance = "house_" .. houseId
            end
            TriggerEvent(
                "sound:playSound",
                type == "ring" and "doorbell" or "doorknock",
                20.0,
                Config.DefaultSettings[houses[houseId].type].Exit.Coords,
                "house_" .. houseId,
                instance
            )
        else
            TriggerEvent(
                "sound:playSound",
                type == "ring" and "doorbell" or "doorknock",
                20.0,
                vec3(houses[houseId].points.ring.x, houses[houseId].points.ring.y, houses[houseId].points.ring.z),
                "house_" .. houseId
            )
        end
    end
)

RegisterNetEvent("household:openRoomSettings")
AddEventHandler(
    "household:openRoomSettings",
    function(houseId)
        local client = source
        local isOwner, isMate, isJobbed = hasAccess(houseId, client)

        if isOwner or isMate or isJobbed then
            local expiredate = "never"
            if houses[houseId].settings.payment ~= "never" then
                expiredate = os.date("%X %x", houses[houseId].settings.payment)
            end
            TriggerClientEvent("household:openRoomSettings", client, houseId, expiredate)
        end
    end
)

RegisterNetEvent("household:startCharSelect")
AddEventHandler(
    "household:startCharSelect",
    function(houseId)
        local client = source
        local isOwner, isMate, isJobbed = hasAccess(houseId, client)

        if isOwner or isMate or isJobbed then
            exports.chars:startCharSelect(client)
        end
    end
)

RegisterNetEvent("household:addMate") -- DONE
AddEventHandler(
    "household:addMate",
    function(houseId, target)
        local client = source
        local isOwner, _, _ = hasAccess(houseId, client, true)

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
                    label = exports.base_jobs:getJobVar(target, "label")
                }
            end
            if houses[houseId].type == "open" then
                mateData.perms = Config.DefaultPermissions
            end
            if houses[houseId].mates[mateData.id] then
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
                houses[houseId].mates[mateData.id] = {
                    label = mateData.label,
                    type = "mate",
                    perms = mateData.perms
                }
                houseUpdate(houseId, "mates", houses[houseId].mates)
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

RegisterNetEvent("household:update")
AddEventHandler(
    "household:update",
    function(house, var, value)
        if exports.data:getUserVar(client, "admin") > 1 then
            houseUpdate(house, var, value)
        else
            exports.admin:banClientForCheating(
                client,
                "0",
                "Cheating",
                "household:update",
                "Pokus o změnu domu bez oprávnění!"
            )
        end
    end
)

RegisterNetEvent("household:create")
AddEventHandler(
    "household:create",
    function(type, data, prices)
        local client = source
        if exports.data:getUserVar(client, "admin") > 1 then
            createHouse(type, data, prices)

            exports.logs:sendToDiscord(
                {
                    channel = "admin-commands",
                    title = "Vytvoření domu",
                    description = "Vytváří dům",
                    color = "34749"
                },
                client
            )
        else
            exports.admin:banClientForCheating(
                client,
                "0",
                "Cheating",
                "household:create",
                "Pokus o vytvoření domu bez oprávnění!"
            )
        end
    end
)

function createHouse(type, data, prices)
    local houseId = generateHouseId()
    if type ~= "open" then
        MySQL.Async.execute(
            "INSERT INTO houses (id, type, prices, coords, points, mates, settings) VALUES (@id, @type, @prices, @coords, @points, @mates, @settings)",
            {
                ["@id"] = houseId,
                ["@type"] = type,
                ["@prices"] = prices ~= nil and json.encode(prices) or json.encode(Config.DefaultSettings[type].Prices),
                ["@coords"] = json.encode(data.coords),
                ["@points"] = json.encode({}),
                ["@mates"] = json.encode({}),
                ["@settings"] = json.encode({})
            }
        )
        houses[tostring(houseId)] = {
            type = type,
            prices = prices ~= nil and prices or Config.DefaultSettings[type].Prices,
            coords = vec3(data.coords.x, data.coords.y, data.coords.z),
            points = {},
            mates = {},
            settings = {}
        }
    else
        MySQL.Async.execute(
            "INSERT INTO houses (id, type, prices, coords, points, mates, settings) VALUES (@id, @type, @prices, @coords, @points, @mates, @settings)",
            {
                ["@id"] = houseId,
                ["@type"] = type,
                ["@prices"] = json.encode({buy = data.buy, rent = data.rent}),
                ["@coords"] = json.encode(data.sign),
                ["@points"] = json.encode(
                    {
                        fridge = data.fridge,
                        manage = data.manage,
                        cloakroom = data.cloakroom,
                        storage = data.storage,
                        vault = data.vault,
                        ring = data.ring
                    }
                ),
                ["@mates"] = json.encode({}),
                ["@settings"] = json.encode({limited = data.limited})
            }
        )
        houses[tostring(houseId)] = {
            type = type,
            prices = {buy = data.buy, rent = data.rent},
            coords = vec4(data.coords.x, data.coords.y, data.coords.z, data.coords.w),
            points = {
                fridge = data.fridge,
                manage = data.manage,
                cloakroom = data.cloakroom,
                storage = data.storage,
                vault = data.vault,
                ring = data.ring
            },
            mates = {},
            settings = {limited = data.limited},
            sign = createSign(vec4(data.coords.x, data.coords.y, data.coords.z, data.coords.w))
        }
    end

    TriggerLatentClientEvent("household:sync", -1, 100000, houses)
end

function houseUpdate(houseId, var, value)
    if not (houseId or var or value or houses[houseId]) then
        return
    end
    houses[houseId][var] = value
    houses[houseId].changed = true

    TriggerClientEvent("household:updateHouse", -1, houseId, {Var = var, Value = value})
end

function createSign(coords)
    local sign = CreateObject(GetHashKey("prop_forsale_lrg_01"), coords.xy, coords.z - 1.0, true, false)
    Citizen.SetTimeout(
        1500,
        function()
            SetEntityHeading(sign, coords.w)
        end
    )
end

function saveChangedHouses()
    for i, house in pairs(houses) do
        if house.changed then
            house.changed = false
            MySQL.Async.execute(
                "UPDATE houses SET prices = @prices, points = @points, mates = @mates, settings = @settings WHERE id = @id",
                {
                    ["@id"] = tonumber(i),
                    ["@prices"] = json.encode(house.prices),
                    ["@points"] = json.encode(house.points),
                    ["@mates"] = json.encode(house.mates),
                    ["@settings"] = json.encode(house.settings)
                }
            )
        end
    end
end

AddEventHandler(
    "onResourceStop",
    function(resourceName)
        if (GetCurrentResourceName() == resourceName) then
            saveChangedHouses()
        end
    end
)

function tableLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

function generateHouseId()
    while true do
        local number = math.random(1000, 9999)

        if not houses[tostring(number)] then
            return number
        end
    end
    return nil
end

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

--ADMIN CMDS
RegisterCommand(
    "house_removeowner",
    function(source, args)
        local client = source
        if exports.data:getUserVar(client, "admin") < 3 then
            return
        end

        if not args[1] then
            TriggerClientEvent(
                "chat:addMessage",
                client,
                {
                    templateId = "error",
                    args = {"Formulace: /house_removeowner [houseId]"}
                }
            )
            return
        end

        local houseId = args[1]
        if not houses[houseId] then
            TriggerClientEvent(
                "notify:display",
                client,
                {
                    type = "error",
                    title = "Úprava domu",
                    text = "Tento dům neexistuje. Zkontroluj údaje",
                    icon = "fas fa-building",
                    length = 3000
                }
            )
            return
        end
        houseUpdate(houseId, "mates", {})
        houseUpdate(houseId, "settings", {})
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
                title = "Odebrani majitele domu",
                description = "Odebral majitele z domu: " .. houseId,
                color = "34749"
            },
            client
        )
    end
)

function hasAccess(houseId, client, onlyOwner)
    local isOwner, isMate, isJobbed = false, false, false
    local charId = tostring(exports.data:getCharVar(client, "id"))
    if not houseId or not houses[houseId] then
        if not houseId then
            print("hasAccess failed! Missing some args")
        else
            print("hasAccess failed! Invalid house ID!")
        end
        return isOwner, isMate, isJobbed
    end

    if houses[houseId].mates and tableLength(houses[houseId].mates) > 0 then
        if houses[houseId].mates[charId] and houses[houseId].mates[charId].type == "owner" then
            isOwner = true
        end

        if not isOwner and not onlyOwner then
            if houses[houseId].mates[charId] then
                isMate = true
            end
            if not isMate then
                for mate, data in pairs(houses[houseId].mates) do
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
