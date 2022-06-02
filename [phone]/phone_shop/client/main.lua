local isDead, isChoosing, isSpawned = false, false, false
local sim, phones = {}, {}
local shop, open, sent = false, false, false

RegisterNetEvent("s:statusUpdated")
AddEventHandler("s:statusUpdated", function(status)
    isDead = (status == "dead")
    isSpawned = (status == "spawned")
    isChoosing = (status == "choosing")

    if isDead or isChoosing then
        TriggerEvent("phone_shop:client:close_shop")
    end
end)

RegisterNetEvent("phone_shop:near_coords")
AddEventHandler("phone_shop:near_coords", function(data, type)
    if type == "in" then
        shop = data
    else
        shop = false
    end
    openClose(type)
end)

RegisterNetEvent("phone_shop:client:open_shop")
AddEventHandler("phone_shop:client:open_shop", function(data)
    local currentShop = Shop_Config.Stores[shop]
    open = true
    for k, v in each(phones) do
        if v.price ~= nil then
            phones[k].price = math.floor(v.price + (v.price * currentShop.tax))
        end
    end
    for k, v in each(sim) do
        if v.price ~= nil then
            sim[k].price = math.floor(v.price + (v.price * currentShop.tax))
        end
    end
    for k, v in each(data) do
        for j, l in each(v) do
            if l.price == nil then
                data[k][j].price = math.floor(Shop_Config.Price["default"] + (Shop_Config.Price["default"] * currentShop.tax))
            end
        end
    end
    SetNuiFocus(open, open)
    SendNUIMessage({
        action = "open",
        shop = currentShop,
        mobile = phones,
        sim = sim,
        recovery = data
    })
    openClose("out")

    while open do
        if LocalPlayer.state.isCuffed then
            TriggerEvent("phone_shop:client:close_shop")
        end
        Citizen.Wait(1000)
    end
end)

AddEventHandler("phone_shop:client:close_shop", function()
    open = false
    SetNuiFocus(open, open)
    SendNUIMessage({action = "close"})
    sent = false
    openClose("in")
end)

RegisterNUICallback('BuyPhone', function(data, cb)
    local type, price = data.payment:split("-")[1], tonumber(data.payment:split("-")[2])
    if (type == "byCard" and data.account ~= "") or type == "byCash" then
        if tonumber(data.account) or type == "byCash" then
            local basket = {
                payment = type,
                price = price,
                account = data.account,
                phoneModel = {}
            }
            for _, v in each(data.basket) do
                if v.model then
                    table.insert(basket.phoneModel, v.model)
                end
            end
            Utils.DumpTable(data)
            TriggerServerEvent("phone_shop:server:buy_phone", basket)
            RegisterNetEvent("phone_shop:client:buy_phone")
            AddEventHandler("phone_shop:client:buy_phone", function(status)
                print(status)
                if status == "done" then
                    exports.notify:display({type = "success", title = "Úspěch", text = "Zakoupil sis nějaký píčoviny! 👿", icon = "fas fa-times", length = 5000})
                end
                cb(status)
            end)
        else
            exports.notify:display({type = "error", title = "Chyba", text = "Špatné číslo účtu! 👿", icon = "fas fa-times", length = 5000})
        end
    else
        exports.notify:display({type = "error", title = "Chyba", text = "Nezadal si číslo účtu! 👿", icon = "fas fa-times", length = 5000})
    end
end)

RegisterNUICallback('Recover', function(data, cb)
    local type, price = data.payment:split("-")[1], tonumber(data.payment:split("-")[2])
    local mobile = exports.inventory:getActiveMobile()
    local mobileID = mobile.data.id
    if (type == "byCard" and data.account ~= "") or type == "byCash" then
        if tonumber(data.account) or type == "byCash" then
            local sync = {
                payment = type,
                price = price,
                phoneid = mobileID,
                account = data.account,
                sync = data.sync[1]
            }
            Utils.DumpTable(data)
            TriggerServerEvent("phone_shop:server:recover", sync)
            RegisterNetEvent("phone_shop:client:recover")
            AddEventHandler("phone_shop:client:recover", function(status)
                if status == "done" then
                    exports.notify:display({type = "success", title = "Úspěch", text = "Obnovil sis nějaké píčoviny! 👿", icon = "fas fa-times", length = 5000})
                end
                cb(status)
            end)
        else
            exports.notify:display({type = "error", title = "Chyba", text = "Špatné číslo účtu! 👿", icon = "fas fa-times", length = 5000})
        end
    else
        exports.notify:display({type = "error", title = "Chyba", text = "Nezadal si číslo účtu! 👿", icon = "fas fa-times", length = 5000})
    end
end)

RegisterNUICallback('Close', function()
    TriggerEvent("phone_shop:client:close_shop")
end)

RegisterCommand("open_shop", function()
    if shop then
        TriggerServerEvent("phone_shop:server:open_shop")
    end
end)

function openClose(type)
    if type == "in" then
        exports.key_hints:displayBottomHint({ name = "phone_shop", key = "~INPUT_PICKUP~", text = "Otevřít obchod" })
    else
        exports.key_hints:hideBottomHint({name = "phone_shop"})
    end
end

Citizen.CreateThread(function()
    for k, v in each(Config.Phones) do
        phones[k] = v
    end
    for k, v in each(Config.Sim) do
        sim[k] = v
    end
    for k, v in each(phones) do
        local Price = 0
        if Shop_Config.Price[v.phoneModel] then
            Price = Shop_Config.Price[v.phoneModel]
        else
            Price = Shop_Config.Price["default"]
        end
        phones[k].price = Price
    end
    for k, v in each(sim) do
        local Price = 0
        if Shop_Config.Price[v.simModel] then
            Price = Shop_Config.Price[v.simModel]
        else
            Price = Shop_Config.Price["default"]
        end
        sim[k].price = Price
    end
end)



createNewKeyMapping({ command = "open_shop", text = "Otevřít obchod s mobily", key = "E" })