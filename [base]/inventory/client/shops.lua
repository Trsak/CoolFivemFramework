RegisterNetEvent("inventory:loadShop")
AddEventHandler("inventory:loadShop", function(shop, shopData, isSpecial)
    openedShop = shop
    openedShopSpecial = isSpecial == true

    TriggerServerEvent("inventory:setOpenedShop", shop)

    local shopItems = {}

    for name, data in pairs(shopData.items) do
        if data and data.count and data.count > 0 then
            if shopData.type ~= "ammunation" then
                table.insert(shopItems, data)
            else
                if not data.license then 
                    table.insert(shopItems, data)
                else 
                    if exports.license:hasLicense(data.license, true) then 
                        table.insert(shopItems, data)
                    end
                end
            end
        end
    end

    table.sort(shopItems, tableSortLabel)

    if #shopItems == 0 then
        exports.notify:display(
            {
                type = "error",
                title = "Obchod",
                text = "Obchod nic nenabízí, nebo ti nic nemůže prodat!",
                icon = "fas fa-box",
                length = 5000
            }
        )
    elseif not isOpened then
        isOpened = true
        SetNuiFocus(true, true)

        SendNUIMessage(
            {
                action = "openShop",
                inventory = Inventory,
                shop = shopItems,
                shopData = shopData
            }
        )
    end
end)

RegisterNetEvent("inventory:shopUpdated")
AddEventHandler(
    "inventory:shopUpdated",
    function(shop, shopData)
        if openedShop and openedShop == shop and isOpened then
            local shopItems = {}

            for name, data in pairs(shopData.items) do
                if data and data.count and data.count > 0 then
                    if shopData.type ~= "ammunation" then
                        table.insert(shopItems, data)
                    else
                        if not data.license then 
                            table.insert(shopItems, data)
                        else 
                            if exports.license:hasLicense(data.license, true) then 
                                table.insert(shopItems, data)
                            end
                        end
                    end
                end
            end

            table.sort(shopItems, tableSortLabel)

            SendNUIMessage(
                {
                    action = "openShop",
                    inventory = Inventory,
                    shop = shopItems,
                    shopData = shopData
                }
            )
        end
    end
)

RegisterNUICallback(
    "buyShopItem",
    function(data, cb)
        TriggerServerEvent("inventory:buyShopItem", openedShop, data.item, data.to, data.count, openedShopSpecial)
    end
)

function tableSortLabel(a, b)
    if (a.label < b.label) then
        return true
    else
        return false
    end
end
