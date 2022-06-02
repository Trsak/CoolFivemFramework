local isSpawned, isDead = false, false
local inHouse, showingHouseHint = false, false
local houses, jobs, signs = nil, {}, {}
local currentHouse, currentPoint = nil, nil

Citizen.CreateThread(function()
    Citizen.Wait(500)

    TriggerEvent("chat:removeSuggestion", "/house_dev")
    local status = exports.data:getUserVar("status")
    if status == "spawned" or status == "dead" then
        isSpawned = true
        isDead = (status == "dead")
        checkMisc()

        Citizen.Wait(2000)
    end
end)

RegisterNetEvent("s:statusUpdated")
AddEventHandler("s:statusUpdated", function(status)
    if status == "choosing" then
        isSpawned = false
        if inHouse then
            deleteZones(inHouse.Type)
        end
        Citizen.Wait(100)
        isSpawned, isDead, jobs, inHouse = false, false, {}, false
    elseif status == "spawned" or status == "dead" then
        if not isSpawned then
            checkMisc()
        end

        isSpawned = true
        isDead = (status == "dead")
    end
end)

function checkMisc()
    loadJobs()
    TriggerServerEvent("household:sync")

    while not houses do
        Citizen.Wait(10)
    end
    local in_property = exports.data:getCharVar("in_property")
    if not inHouse and in_property and in_property.type == "house" then
        inHouse = {
            Id = in_property.id,
            Onvisit = in_property.onvisit,
            Type = houses[in_property.id].type
        }
        createZones(inHouse.Type, in_property.onvisit)
        if Config.DefaultSettings[houses[in_property.id].type].Instance then
            local instance = ("char_select_" .. GetPlayerServerId(PlayerId()))
            while exports.instance:getPlayerInstance() == instance do
                Citizen.Wait(100)
            end
            TriggerServerEvent("instance:joinInstance", "house_" .. in_property.id)
        end
    end
end

RegisterNetEvent("s:jobUpdated")
AddEventHandler("s:jobUpdated", function(newJobs)
    loadJobs(newJobs)
end)

RegisterNetEvent("household:sync")
AddEventHandler("household:sync", function(houseSync)
    houses = houseSync
end)

RegisterNetEvent("household:updateHouse")
AddEventHandler("household:updateHouse", function(houseId, houseData)
    while not houses do
        Citizen.Wait(200)
    end
    if houseId and houseData and houseData.Var and houseData.Value then
        houses[houseId][houseData.Var] = houseData.Value
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if isSpawned and not isDead and houses then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local shouldBeDisplayingHint = false
            if not inHouse then
                for i, house in pairs(houses) do
                    local houseFree = (house.type == "open" and tableLength(house.mates) == 0)

                    if houseFree or house.type ~= "open" then
                        if #(playerCoords - house.coords.xyz) <= 2.5 then
                            shouldBeDisplayingHint = true
                            currentHouse = i

                            if not showingHouseHint then
                                showingHouseHint = true
                                exports.key_hints:displayHint({
                                    name = "house",
                                    key = "~INPUT_5611B1B0~",
                                    text = houseFree and "Otevřít nabídku" or "Dům č." .. i,
                                    coords = house.coords.xyz
                                })
                            end
                            break
                        end
                    end
                    if house.type == "open" and not houseFree then
                        for name, coords in each(house.points) do
                            if coords then
                                local pointCoords = vec3(coords.x, coords.y, coords.z)
                                if #(playerCoords - pointCoords) <= 1.0 then
                                    if name == "ring" or hasPerm(i, name) or hasJobPerm(i, name) then
                                        shouldBeDisplayingHint = true
                                        currentHouse = i
                                        currentPoint = name

                                        if not showingHouseHint then
                                            showingHouseHint = true

                                            exports.key_hints:displayHint({
                                                name = "house",
                                                key = "~INPUT_5611B1B0~",
                                                text = Config.Appendices.Places.Labels[name][1],
                                                coords = pointCoords
                                            })
                                        end
                                    end
                                    break
                                end
                            else
                                print("REPORT HOUSEHOLD", i)
                            end
                        end
                    end
                end
            else
                Citizen.Wait(1000)
            end
            if not shouldBeDisplayingHint and showingHouseHint then
                resetHints()
                Citizen.Wait(100)
                WarMenu.CloseMenu()
            end
        end
    end
end)

function openDynastyMenu(houseId)
    WarMenu.CreateMenu("house-buy", "Koupě domu č." .. houseId, "Vyberte akci")
    WarMenu.OpenMenu("house-buy")

    while WarMenu.IsMenuOpened("house-buy") do
        if WarMenu.Button("Zakoupit dům", getFormattedCurrency(houses[houseId].prices.buy)) then
            menuAction("buy", houseId)
        elseif WarMenu.Button("Pronajmout dům", getFormattedCurrency(houses[houseId].prices.rent)) then
            menuAction("rent", houseId)
        end
        WarMenu.Display()
        Citizen.Wait(0)
    end
end
function openHouseMenu(houseId, occupied)
    local isOwner, isMate, isJobbed = hasAccess(houseId)
    WarMenu.CreateMenu("house-details", "Dům č." .. houseId, "Vyberte akci")
    WarMenu.OpenMenu("house-details")

    while WarMenu.IsMenuOpened("house-details") do
        if occupied then
            if isOwner or isMate or isJobbed then
                if WarMenu.CheckBox("Klíčky", houses[houseId].settings.locked, false, { "Odemknout", "Zamknout" }) then
                    houses[houseId].settings.locked = not houses[houseId].settings.locked
                    TriggerServerEvent("household:doorAction", houseId, houses[houseId].settings)
                end
            elseif (hasWhitelistedJobType() or exports.data:getUserVar("admin") >= 2) and
                houses[houseId].settings.locked then
                if WarMenu.Button("Vykopnout dveře") then
                    menuAction("kickoff", houseId)
                end
            end
            if WarMenu.CheckBox("Vstoupit", houses[houseId].settings.locked, false, { "Zamknuto", "Odemknuto" }) then
                if not houses[houseId].settings.locked or isOwner or isMate or isJobbed then
                    menuAction("enter", houseId)
                else
                    exports.notify:display({
                        type = "warning",
                        title = "Dům",
                        text = "Dveře jsou zamčené!",
                        icon = "fas fa-door-closed",
                        length = 3500
                    })
                end
            elseif WarMenu.Button("Zazvonit") then
                menuAction("ring", houseId)
            end
            if isOwner then
                if houses[houseId].payment ~= "never" then
                    if WarMenu.Button("Zrušit pronájem") then
                        menuAction("cancelRent", houseId)
                    end
                else
                    if WarMenu.Button("Prodat dům za poloviční cenu") then
                        menuAction("sell", houseId)
                    end
                end
            end
        else
            if WarMenu.Button("Zakoupit dům", getFormattedCurrency(houses[houseId].prices.buy)) then
                menuAction("buy", houseId)
            elseif WarMenu.Button("Pronajmout dům", getFormattedCurrency(houses[houseId].prices.rent)) then
                menuAction("rent", houseId)
            elseif WarMenu.Button("Prohlédnout dům") then
                menuAction("visit", houseId)
            end
        end
        WarMenu.Display()
        Citizen.Wait(0)
    end
end

function openRingMenu(houseId)
    local streetHash, _ = GetStreetNameAtCoord(houses[houseId].coords.x, houses[houseId].coords.y,
        houses[houseId].coords.z)
    WarMenu.CreateMenu("house-ring", "Dům č." .. houseId, "Vyberte akci")
    WarMenu.OpenMenu("house-ring")

    while WarMenu.IsMenuOpened("house-ring") do
        local tag = houses[houseId].settings.customTag
        if WarMenu.Button("Zazvonit", tag and tag or "") then
            menuAction("ring", houseId, "open")
        elseif WarMenu.Button("Veřejná adresa", GetStreetNameFromHashKey(streetHash)) then
        end
        WarMenu.Display()
        Citizen.Wait(0)
    end
end

function menuAction(action, houseId, other)
    if action == "visit" then
        enterHouse(houseId, true)
        WarMenu.CloseMenu()
    elseif action == "rent" then
        if not isForFaction(houseId) then
            WarMenu.CloseMenu()
            TriggerServerEvent("household:rent", houseId, tonumber(houses[houseId].prices.rent))
        end
    elseif action == "buy" then
        if not isForFaction(houseId) then
            WarMenu.CloseMenu()
            TriggerServerEvent("household:requestAccounts", houseId)
        end
    elseif action == "ring" then
        TriggerServerEvent("household:ring", houseId, "ring")
        exports.notify:display({
            type = "info",
            title = "Nemovitost",
            text = "Zazvonil/a jsi na dům.",
            icon = "fas fa-concierge-bell",
            length = 3500
        })
    elseif action == "enter" then
        if houses[houseId].settings.payment == "never" then
            enterHouse(houseId)
        else
            TriggerServerEvent("household:checkPayment", houseId)
        end
        WarMenu.CloseMenu()
    elseif action == "kickoff" then
        WarMenu.CloseMenu()
        TriggerServerEvent("household:ring", houseId, "doorknock")

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
                houses[houseId].settings.locked = not houses[houseId].settings.locked
                TriggerServerEvent("household:doorAction", currentHouse, houses[houseId].settings)
            end
        end)
    elseif action == "sell" then
        return exports.input:openInput("number", {
            title = "Zadejte váš bankovní účet, na který bude poloviční čáska odeslána",
            placeholder = ""
        }, function(account)
            if account then
                TriggerServerEvent("property:sellroom", account, math.floor(houses[houseId].prices.buy / 2), houseId)
                WarMenu.CloseMenu()
            else
                TriggerEvent("chat:addMessage", {
                    templateId = "error",
                    args = { "Zadávej pouze číslo a správný bankovní účet" }
                })
            end
        end)
    elseif action == "cancelRent" then
        TriggerServerEvent("household:cancelRent", houseId)
        WarMenu.CloseMenu()
    elseif action == "addmate" then
        TriggerEvent("util:closestPlayer", {
            radius = 2.0
        }, function(player)
            if player then
                TriggerServerEvent("household:addMate", houseId, tonumber(player))
            end
        end)
        WarMenu.CloseMenu()
    elseif action == "addjob" then
        Citizen.CreateThread(function()
            WarMenu.CreateMenu("house-addjob", "Přidání zaměstnání", "Zvolte zaměstnání")
            WarMenu.OpenMenu("house-addjob")

            while WarMenu.IsMenuOpened("house-addjob") do
                for jobName, value in pairs(jobs) do
                    if WarMenu.Button(exports.base_jobs:getJobVar(jobName, "label")) then
                        exports.input:openInput("number", {
                            title = "Zadejte číslo nejnižší hodnosti"
                        }, function(grade)
                            if grade and tonumber(grade) then
                                TriggerServerEvent("household:addMate", houseId, jobName, grade)
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
        TriggerServerEvent("household:removeMate", houseId, other)
        WarMenu.CloseMenu()
    elseif action == "tag" then
        local tag = houses[houseId].customTag
        exports.input:openInput("text", {
            title = "Zadejte jmenovku ke zvonku",
            placeholder = tag and tag or ""
        }, function(text)
            if text then
                TriggerServerEvent("household:setTag", houseId, text)
                WarMenu.CloseMenu()
            end
        end)
    end
end
function enterHouse(house, onvisit)
    local houseType = houses[house].type
    createZones(houseType, onvisit)

    inHouse = {
        Id = house,
        Onvisit = onvisit
    }
    TriggerServerEvent("property:eeLog", inHouse, true)
    TriggerServerEvent("s:updateInProperty", {
        id = house,
        onvisit = onvisit,
        type = "house"
    })
    teleport(Config.DefaultSettings[houseType].Exit.Coords)

    if Config.DefaultSettings[houseType].Instance then
        TriggerServerEvent("instance:joinInstance", "house_" .. house)
    end
end
function openMatesMenu(house)
    Citizen.CreateThread(function()
        WarMenu.CreateMenu("house-mates", "Spolubydlící", "Zvolte akci")
        WarMenu.OpenMenu("house-mates")
        local selected = nil

        while WarMenu.IsMenuOpened("house-mates") do
            if WarMenu.Button("Přidat spolubydlícího") then
                menuAction("addmate", house)
            end
            if tableLength(jobs) > 0 then
                if WarMenu.Button("Přidat spolubydlící firmu") then
                    menuAction("addjob", house)
                end
            end
            for charId, value in pairs(houses[house].mates) do
                if value.type ~= "owner" then
                    if houses[house].type ~= "open" then
                        if WarMenu.Button(value.label) then
                            menuAction("remove", house, charId)
                        end
                    else
                        if WarMenu.Button(value.label) then
                            WarMenu.CloseMenu()
                            openMatePerms(house, charId)
                        end
                    end
                end
            end
            WarMenu.Display()
            Citizen.Wait(0)
        end
    end)
end

function openMatePerms(houseId, player)
    WarMenu.CreateMenu("house-permissions", houses[houseId].mates[player].label, "Vyberte oprávnění")
    WarMenu.OpenMenu("house-permissions")

    while WarMenu.IsMenuOpened("house-permissions") do
        for perm, state in pairs(houses[houseId].mates[player].perms) do
            if WarMenu.CheckBox(Config.Appendices.Permissions[perm], houses[houseId].mates[player].perms[perm]) then
                houses[houseId].mates[player].perms[perm] = not houses[houseId].mates[player].perms[perm]
                TriggerServerEvent("household:mateAction", houseId, houses[houseId].mates)
            end
        end

        if WarMenu.Button("~r~Odebrat spolubydlícího") then
            menuAction("remove", houseId, player)
        end
        WarMenu.Display()
        Citizen.Wait(0)
    end
end

function hasAccess(id, achjo)
    if id == 0 or id == "0" or not houses then
        return
    end
    local houseId = tostring(id)
    local isOwner, isMate, isJobbed = false, false, false
    local charId = tostring(exports.data:getCharVar("id"))
    if houses[houseId] and houses[houseId].mates and tableLength(houses[houseId].mates) > 0 then
        if houses[houseId].mates[charId] and houses[houseId].mates[charId].type == "owner" then
            isOwner = true
        end

        if not isOwner then
            if houses[houseId].mates[charId] then
                isMate = true
            end
            if not isMate and tableLength(jobs) > 0 then
                for job, _ in pairs(jobs) do
                    if houses[houseId].mates[job] then
                        isJobbed = true
                        break
                    end
                end
            end
        end
    end
    if achjo then return isOwner or isMate or isJobbed end
    return isOwner, isMate, isJobbed
end exports("HasHouseAccess", hasAccess)

function hasPerm(house, perm)
    local menuHouse = houses[house]
    local charId = tostring(exports.data:getCharVar("id"))

    if menuHouse.mates[charId] then
        if perm == "charselect" then
            return true
        end
        if menuHouse.mates[charId].perms[perm] then
            return true
        end
    end
    return false
end

function hasJobPerm(house, perm)
    local menuHouse = houses[house]
    if tableLength(jobs) > 0 then
        for name, _ in pairs(jobs) do
            if menuHouse.mates[name] then
                if perm == "charselect" then
                    return true
                end
                if menuHouse.mates[name].perms[perm] then
                    return true
                end
            end
        end
    end
    return false
end

function teleport(coords)
    local playerPed = PlayerPedId()
    DoScreenFadeOut(1000)
    NetworkFadeOutEntity(playerPed, true, false)
    resetHints()
    Citizen.Wait(1000)

    FreezeEntityPosition(playerPed, true)
    SetEntityCoords(playerPed, coords.xyz)

    if coords.w then
        SetEntityHeading(playerPed, coords.w)
    end

    while not HasCollisionLoadedAroundEntity(playerPed) do
        RequestCollisionAtCoord(coords)
        Citizen.Wait(0)
    end

    FreezeEntityPosition(playerPed, false)
    Citizen.Wait(1000)
    DoScreenFadeIn(1000)
    NetworkFadeInEntity(playerPed, true)
end

function loadJobs(Jobs)
    jobs = {}
    for _, data in pairs(Jobs and Jobs or exports.data:getCharVar("jobs")) do
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

function resetHints()
    exports.key_hints:hideHint({
        name = "house"
    })
    currentPoint, currentHouse = nil, nil
    showingHouseHint = false
end

function tableLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

RegisterNetEvent("household:checkPayment")
AddEventHandler("household:checkPayment", function(houseId, price, canEnter, timeToCheck)
    if canEnter or hasWhitelistedJobType() then
        enterHouse(houseId)
    else
        local isOwner, isMate, isJobbed = hasAccess(houseId)
        if isOwner or isMate or isJobbed then
            local daysMissing = (math.floor(timeToCheck / Config.RentDuration) == 0 and 1 or
                math.floor(timeToCheck / Config.RentDuration))

            WarMenu.CreateMenu("house-payrent", "Nedoplatek nájmu", "Zvolte vaši možnost")
            WarMenu.OpenMenu("house-payrent")

            while WarMenu.IsMenuOpened("house-payrent") do
                if WarMenu.Button("Zaplatit nájem", getFormattedCurrency(price * daysMissing)) then
                    WarMenu.CloseMenu()
                    TriggerServerEvent("household:payRent", houseId)
                elseif WarMenu.Button("Přijít později...") then
                    WarMenu.CloseMenu()
                end
                WarMenu.Display()
                Citizen.Wait(0)
            end
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

RegisterNetEvent("household:requestAccounts")
AddEventHandler("household:requestAccounts", function(houseId, accounts)
    if tableLength(accounts) > 0 then
        WarMenu.CreateMenu("household-accounts", "Dostupné účty", "Vyberte účet pro transkaci")
        WarMenu.OpenMenu("household-accounts")

        while WarMenu.IsMenuOpened("household-accounts") do
            for _, data in each(accounts) do
                if WarMenu.Button(data[2], data[1]) then
                    TriggerServerEvent("household:buy", data[1], houseId)
                    WarMenu.CloseMenu()
                end
            end
            WarMenu.Display()
            Citizen.Wait(0)
        end
    else
        exports.notify:display({
            type = "error",
            title = "Dům",
            text = "Nemáš dostupný žádný bankovní účet!",
            icon = "fas fa-door-closed",
            length = 5000
        })
    end
end)

RegisterNetEvent("household:openRoomSettings")
AddEventHandler("household:openRoomSettings", function(houseId, expires)
    local isBought = (expires == "never")
    local customTag = houses[houseId].settings.customTag and houses[houseId].settings.customTag or ""
    if houses[houseId].type ~= "open" then
        local isOwner, isMate, isJobbed = hasAccess(houseId)
        if isOwner or isMate or isJobbed then
            WarMenu.CreateMenu("household-inside", "Správa domu", "Zvolte akci")
            WarMenu.OpenMenu("household-inside")

            while WarMenu.IsMenuOpened("household-inside") do
                if WarMenu.CheckBox("Klíčky", houses[houseId].settings.locked, false, { "Zamknuto", "Odemknuto" }) then
                    houses[houseId].settings.locked = not houses[houseId].settings.locked
                    TriggerServerEvent("household:doorAction", houseId, houses[houseId].settings)
                elseif WarMenu.Button("Nastavit jmenovku zvonku", customTag) then
                    menuAction("tag", houseId)
                end
                if isOwner then
                    if not isBought then
                        if WarMenu.Button("Datum splacení pronájmu:", expires) then
                        end
                    end
                    if WarMenu.Button("Spolubydlící") then
                        openMatesMenu(houseId)
                    end
                end
                WarMenu.Display()
                Citizen.Wait(0)
            end
        end
    else
        local canManage = hasPerm(houseId, "manage")
        local canMates = hasPerm(houseId, "mates")
        if canManage then
            WarMenu.CreateMenu("household-manage", "Správa domu", "Zvolte akci")
            WarMenu.OpenMenu("household-manage")

            while WarMenu.IsMenuOpened("household-manage") do
                if WarMenu.Button("Nastavit jmenovku zvonku", customTag) then
                    menuAction("tag", houseId)
                end
                if not isBought then
                    if WarMenu.Button("Datum splacení pronájmu:", expires) then
                    end
                end
                if canMates and WarMenu.Button("Spolubydlící") then
                    openMatesMenu(houseId)
                end
                WarMenu.Display()
                Citizen.Wait(0)
            end
        end
    end
end)

RegisterCommand("house_dev", function()
    if exports.data:getUserVar("admin") > 1 then
        local pCoords = GetEntityCoords(PlayerPedId())
        local newHouse = {
            sign = nil,
            rent = nil,
            buy = nil,
            fridge = nil,
            manage = nil,
            storage = nil,
            vault = nil,
            cloakroom = nil,
            ring = nil,
            limited = false
        }
        WarMenu.CreateMenu("house-create", "Nemovitosti", "Zvolte akci")
        WarMenu.OpenMenu("house-create")
        WarMenu.CreateSubMenu("house-port", "house-create", "Zvolte typ domu")
        WarMenu.CreateSubMenu("house-open", "house-create", "Vyplňte informace")

        while true do
            if WarMenu.IsMenuOpened("house-create") then
                if WarMenu.MenuButton("Vytvořit dům na port", "house-port") then
                elseif WarMenu.MenuButton("Vytvořit MLO dům", "house-open") then
                end
                WarMenu.Display()
            elseif WarMenu.IsMenuOpened("house-port") then
                for house, data in pairs(Config.DefaultSettings) do
                    if WarMenu.Button(house, data.AdminName) then
                        exports.input:openInput("number", {
                            title = "Zadejte měsíční cenu nájmu!",
                            placeholder = ""
                        }, function(rent)
                            if rent then
                                exports.input:openInput("number", {
                                    title = "Zadejte kupní cenu!",
                                    placeholder = ""
                                }, function(buy)
                                    if buy then
                                        local pCoords = GetEntityCoords(PlayerPedId())
                                        TriggerServerEvent("household:create", house, {
                                            coords = {
                                                x = pCoords.x,
                                                y = pCoords.y,
                                                z = pCoords.z
                                            }
                                        }, {
                                            buy = tonumber(buy),
                                            rent = tonumber(rent)
                                        })
                                        WarMenu.CloseMenu()
                                        TriggerEvent("chat:addMessage", {
                                            templateId = "success",
                                            args = {"Úspěšně jsi vytvořil dům!"}
                                        })
                                    end
                                end)
                            end
                        end)
                    end
                end
                WarMenu.Display()
            elseif WarMenu.IsMenuOpened("house-open") then
                if WarMenu.Button("Cena pronájmu", "$" .. tostring(not newHouse.rent and 0 or newHouse.rent)) then
                    exports.input:openInput("number", {
                        title = "Zadejte cenu pronájmu"
                    }, function(rent)
                        if rent and tonumber(rent) then
                            newHouse.rent = rent
                        end
                    end)
                elseif WarMenu.Button("Cena koupě", "$" .. tostring(not newHouse.buy and 0 or newHouse.buy)) then
                    exports.input:openInput("number", {
                        title = "Zadejte cenu koupě"
                    }, function(buy)
                        if buy and tonumber(buy) then
                            newHouse.buy = buy
                        end
                    end)
                elseif WarMenu.Button("Schválení A-Teamu", newHouse.limited and "Ano" or "Ne") then
                    newHouse.limited = not newHouse.limited
                elseif WarMenu.Button("Cedule na prodej", not newHouse.sign and "Není" or "Ano") then
                    local pCoords, playerHeading = GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId())
                    local heading = playerHeading + 180.0 <= 360.0 and playerHeading + 180.0 or playerHeading - 180.0
                    newHouse.sign = {
                        x = pCoords.x,
                        y = pCoords.y,
                        z = pCoords.z,
                        w = heading
                    }
                elseif WarMenu.Button("Lednice", not newHouse.fridge and "Není" or "Ano") then
                    local pCoords = GetEntityCoords(PlayerPedId())
                    newHouse.fridge = {
                        x = pCoords.x,
                        y = pCoords.y,
                        z = pCoords.z
                    }
                elseif WarMenu.Button("Sklad", not newHouse.storage and "Není" or "Ano") then
                    local pCoords = GetEntityCoords(PlayerPedId())
                    newHouse.storage = {
                        x = pCoords.x,
                        y = pCoords.y,
                        z = pCoords.z
                    }
                elseif WarMenu.Button("Šatna", not newHouse.cloakroom and "Není" or "Ano") then
                    local pCoords = GetEntityCoords(PlayerPedId())
                    newHouse.cloakroom = {
                        x = pCoords.x,
                        y = pCoords.y,
                        z = pCoords.z
                    }
                elseif WarMenu.Button("Trezor", not newHouse.vault and "Není" or "Ano") then
                    local pCoords = GetEntityCoords(PlayerPedId())
                    newHouse.vault = {
                        x = pCoords.x,
                        y = pCoords.y,
                        z = pCoords.z
                    }
                elseif WarMenu.Button("Správa", not newHouse.manage and "Není" or "Ano") then
                    local pCoords = GetEntityCoords(PlayerPedId())
                    newHouse.manage = {
                        x = pCoords.x,
                        y = pCoords.y,
                        z = pCoords.z
                    }
                elseif WarMenu.Button("Zvonek", not newHouse.ring and "Není" or "Ano") then
                    local pCoords = GetEntityCoords(PlayerPedId())
                    newHouse.ring = {
                        x = pCoords.x,
                        y = pCoords.y,
                        z = pCoords.z
                    }
                elseif WarMenu.Button("Odeslat") then
                    if newHouse.sign and newHouse.buy and newHouse.rent then
                        TriggerServerEvent("household:create", "open", newHouse)
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
end)


RegisterCommand("house", function()
    if not WarMenu.IsAnyMenuOpened() then
        if currentHouse and not currentPoint then
            local house = not currentHouse and inHouse.Id or currentHouse
            if houses[house].type ~= "open" then
                openHouseMenu(house, (tableLength(houses[house].mates) > 0))
            else
                openDynastyMenu(house)
            end
        elseif currentHouse and currentPoint or inHouse and currentPoint then
            houseAction(currentPoint)
        end
    end
end)
createNewKeyMapping({
    command = "house",
    text = "Interakce v domech",
    key = "E"
})

function houseAction(point)
    local house = not currentHouse and inHouse.Id or currentHouse
    if not currentHouse then
        data = Config.DefaultSettings[houses[house].type]
    else
        if houses[house].settings.weight then
            data = houses[house].settings
        else
            data = {
                storage = {
                    weight = 2000,
                    slots = 200
                },
                fridge = {
                    weight = 50,
                    slots = 25
                },
                vault = {
                    weight = 10,
                    slots = 100
                }
            }
        end
    end
    local isOwner, isMate, isJobbed = hasAccess(house)
    if point == "exit" then
        if not houses[house].settings.locked or inHouse.Onvisit or isOwner or isMate or isJobbed then
            deleteZones(houses[house].type)
            TriggerServerEvent("instance:quitInstance")
            teleport(houses[house].coords.xyz)
            TriggerServerEvent("property:eeLog", inHouse, false)
            inHouse = false
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
    elseif point == "storage" then
        TriggerServerEvent("inventory:openStorage", "storage", "house_" .. house, {
            maxWeight = data.storage.weight or data.storage.MaxWeight,
            maxSpace = data.storage.slots or data.storage.MaxSlots,
            label = "Sklad #" .. house
        })
    elseif point == "fridge" then
        TriggerServerEvent("inventory:openStorage", "fridge", "house_" .. house, {
            maxWeight = data.fridge.weight or data.fridge.MaxWeight,
            maxSpace = data.fridge.slots or data.fridge.MaxSlots,
            label = "Lednice #" .. house
        })
    elseif point == "vault" then
        TriggerServerEvent("inventory:openStorage", "vault", "house_" .. house, {
            maxWeight = data.vault.weight or data.vault.MaxWeight,
            maxSpace = data.vault.slots or data.vault.MaxSlots,
            label = "Trezor #" .. house
        })
    elseif point == "cloakroom" then
        exports.clothes_shop:openClothesMenu()
    elseif point == "ring" then
        openRingMenu(house)
    elseif point == "manage" then
        TriggerServerEvent("household:openRoomSettings", currentHouse)
    elseif point == "charselect" then
        resetHints()
        TriggerServerEvent("household:startCharSelect", house)
    end
end

function createZones(houseType, onvisit)
    for place, data in pairs(Config.DefaultSettings[houseType]) do
        if place ~= "Instance" and place ~= "Prices" and place ~= "AdminName" then
            if place ~= "Exit" and not onvisit or place == "Exit" and onvisit then
                exports.target:AddCircleZone("household-" .. houseType .. "-" .. string.lower(place), data.Coords.xyz, 1.0,
                    {
                        actions = {
                            action = {
                                cb = function()
                                    if not WarMenu.IsAnyMenuOpened() then
                                        houseAction(string.lower(place))
                                    end
                                end,
                                icon = Config.Appendices.Places.Icons[string.lower(place)][1],
                                label = Config.Appendices.Places.Labels[string.lower(place)][1]
                            }
                        },
                        distance = 0.2
                    })
            elseif place == "Exit" and not onvisit then
                exports.target:AddCircleZone("household-" .. houseType .. "-" .. string.lower(place), data.Coords.xyz, 1.0,
                    {
                        actions = {
                            action = {
                                cb = function()
                                    if not WarMenu.IsAnyMenuOpened() then
                                        houseAction(string.lower(place))
                                    end
                                end,
                                icon = Config.Appendices.Places.Icons[string.lower(place)][1],
                                label = Config.Appendices.Places.Labels[string.lower(place)][1]
                            },
                            manage = {
                                cb = function()
                                    if not WarMenu.IsAnyMenuOpened() then
                                        TriggerServerEvent("household:openRoomSettings", inHouse.Id)
                                    end
                                end,
                                icon = Config.Appendices.Places.Icons[string.lower(place)][2],
                                label = Config.Appendices.Places.Labels[string.lower(place)][2]
                            }
                        },
                        distance = 0.2
                    })
            end
        end
    end
end

function deleteZones(houseType)
    if houseType then
        for place, data in pairs(Config.DefaultSettings[houseType]) do
            if place ~= "Instance" and place ~= "Prices" and place ~= "AdminName" then
                exports.target:RemoveZone("household-" .. houseType .. "-" .. string.lower(place))
            end
        end
    end
end

function isForFaction(houseId)
    if not houses[houseId].settings.limited then
        return false
    else
        TriggerEvent("chat:addMessage", {
            templateId = "warning",
            args = { "Tato nemovitost musí být schválena admin týmem!" }
        })
        exports.notify:display({
            type = "warning",
            title = "Nemovitost",
            text = "Ohledně této nemovitosti si domluv schůzi na Governmentu!",
            icon = "fas fa-house-user",
            length = 5000
        })
        return true
    end
end

AddEventHandler("onResourceStop", function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        if inHouse then
            deleteZones(inHouse.Type)
        end
    end
end)
