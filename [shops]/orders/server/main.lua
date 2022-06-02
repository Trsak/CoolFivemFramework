local orders = nil

MySQL.ready(
    function()
        Wait(5)
        MySQL.Async.execute("DELETE FROM orders WHERE `recieved` = 1", {})

        MySQL.Async.fetchAll(
            "SELECT * FROM orders",
            {},
            function(result)
                orders = {}
                for i, res in each(result) do
                    if res.order ~= nil then
                        orders[res.order] = {
                            order = res.order,
                            shop = res.shop,
                            ordered = tonumber(res.ordered),
                            orderedLabel = os.date("%X %x", tonumber(res.ordered)),
                            delivered = tonumber(res.delivered),
                            deliveredLabel = os.date("%X %x", tonumber(res.delivered)),
                            bywho = res.bywho,
                            products = json.decode(res.products),
                            price = res.price,
                            recieved = res.recieved,
                            processing = false
                        }
                    end
                end

                while true do
                    if orders then
                        local currentTime = os.time()
                        local tempOrders = orders
        
                        for order, orderData in pairs(tempOrders) do
                            if not orderData.processing and not orderData.recieved then
                                if orderData.delivered <= currentTime then
                                    processOrder(order)
                                end
                            end
                        end
                    end
                    Citizen.Wait(300000)
                end
            end
        )
    end
)

function createOrder(shop, shopType, products, price, creator)
    local sender = "City"
    if creator then
        sender = exports.data:getCharVar(creator, "firstname") .. " " .. exports.data:getCharVar(creator, "lastname")
    end
    local order = "FA" .. shop .. tostring(math.random(10000000, 99999999))

    local endDate = os.time() + Config.DeliveringDate[shopType] + math.random(5, 150)
    local startDate = os.time()
    MySQL.Async.execute(
        "INSERT INTO `orders` (`order`, `shop`, `ordered`, `delivered`, `bywho`, `products`, `price`, `recieved`) VALUES (@order, @shop, @ordered, @delivered, @bywho, @products, @price, @recieved)",
        {
            ["@order"] = order,
            ["@shop"] = shop,
            ["@ordered"] = startDate,
            ["@delivered"] = endDate,
            ["@bywho"] = sender,
            ["@products"] = json.encode(products),
            ["@price"] = price,
            ["@recieved"] = 0
        },
        function(rowAdded)
            if rowAdded then
                --print("ORDERED " .. order .. " FOR SHOP " .. shop)
                orders[order] = {
                    order = order,
                    shop = shop,
                    ordered = startDate,
                    orderedLabel = os.date("%X %x", startDate),
                    delivered = endDate,
                    deliveredLabel = os.date("%X %x", endDate),
                    bywho = sender,
                    products = products,
                    price = price,
                    recieved = false,
                    processing = false
                }
            else
                print("WARNING! ORDER NEVER RECIEVED! " .. shop .. " " .. sender)
            end
        end
    )
end

function processOrder(order)
    orders[order].processing = true
    --print("PROCESSING AN ORDER: " .. order .. " FOR SHOP: " .. orders[order].shop)
    for item, itemData in pairs(orders[order].products) do
        --print(item .. " Count: " .. itemData.count .. " Price: $" .. itemData.price .. " Order: " .. orders[order].shop)
        exports.base_shops:addItemToShop(tostring(orders[order].shop), item, itemData.count, itemData.price, itemData.license, true)
        Wait(150)
    end
    removeOrder(order)
end

function removeOrder(order)
    orders[order].recieved = true

    MySQL.Async.execute(
        "UPDATE `orders` SET `recieved` = 1 WHERE `order` = @id",
        {
            ["@id"] = order
        }
    )
    --print("PROCESSED AN ORDER: " .. order .. " FOR SHOP: " .. orders[order].shop)
end

function getOrdersInShop(shop)
    local shopOrders = {}
    for order, orderData in pairs(orders) do
        if orderData.shop == shop then
            table.insert(shopOrders, orderData)
        end
    end

    return shopOrders
end

function getOrders()
    return orders
end
