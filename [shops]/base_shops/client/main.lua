local isSpawned, isDead = false, false
local inShop = nil
local jobs = {}
local shops = nil

local showBlips, blips = true, {}

Citizen.CreateThread(
    function()
        Citizen.Wait(500)

        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            showBlips = exports.settings:getSettingValue("shopsBlips")
            isSpawned = true
            isDead = (status == "dead")
            loadJobs()

            if showBlips then
                createShopBlips()
            end
        end
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned = false
        elseif status == "spawned" or status == "dead" then
            isDead = (status == "dead")
            if not isSpawned then
                isSpawned = true
                loadJobs()
            end
            if not shops then
                TriggerServerEvent("shops:sync")
            end
        end
    end
)

RegisterNetEvent("s:jobUpdated")
AddEventHandler(
    "s:jobUpdated",
    function(newJobs)
        loadJobs(newJobs)
    end
)

RegisterNetEvent("shops:sync")
AddEventHandler(
    "shops:sync",
    function(shopData, vehicles)
        shops = shopData
        Config.Products.cardealer = vehicles
        if not shops or tableLength(shops) <= 0 then
            TriggerServerEvent("shops:sync")
        end
    end
)

RegisterCommand(
    "createshop",
    function(source, args)
        if exports.data:getUserVar("admin") > 2 then
            local newShop = {
                Coords = nil,
                PedCoords = nil
            }
            WarMenu.CreateMenu("shop-create", "Tvorba obchodu", "Vytvoř obchod!")
            WarMenu.OpenMenu("shop-create")
            while WarMenu.IsMenuOpened("shop-create") do
                if WarMenu.Button("Místo nákupu", not newShop.Coords and "Není" or "Je") then
                    newShop.Coords = GetEntityCoords(PlayerPedId())
                elseif
                WarMenu.Button(
                    "Místo prodavače na vykrádání (není nutné)",
                    not newShop.PedCoords and "Není" or "Je"
                )
                then
                    local playerCoords, playerHeading = GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId())
                    newShop.PedCoords = vec4(playerCoords, playerHeading)
                elseif WarMenu.Button("Typ obchodu", not newShop.Type and "Není" or newShop.Type) then
                    exports.input:openInput(
                        "text",
                        {
                            title = "Zadejte typ (grocery, ammunation, electronic, gardener, youtool, alcohol)",
                            placeholder = ""
                        },
                        function(type)
                            if type and Config.Blips[type] then
                                newShop.Type = type
                            end
                        end
                    )
                elseif WarMenu.Button("Odeslat") then
                    TriggerServerEvent("base_shops:create", newShop)
                end
                WarMenu.Display()
                Citizen.Wait(0)
            end
        end
    end
)

function openBuyMenu(shopId)
    TriggerServerEvent("base_shops:openShop", shopId)
end

Citizen.CreateThread(
    function()
        while true do
            local shouldBeDisplayingHint = false
            Citizen.Wait(1)
            if isSpawned and not isDead and shops then
                local playerCoords = GetEntityCoords(PlayerPedId())
                for i, shop in pairs(shops) do
                    if shop.available and (not Config.Restricted[shop.type] or isAllowed(shop.type)) then
                        local distance = #(playerCoords - shop.coords)

                        if distance <= 1.0 then
                            shouldBeDisplayingHint = true

                            if not isDisplayingHint then
                                isDisplayingHint = true
                                exports.key_hints:displayBottomHint(
                                    { name = "base_shops", key = "~INPUT_PICKUP~", text = shop.name }
                                )
                            end
                            if IsControlJustReleased(0, 38) then
                                TriggerServerEvent("license:sync", true)
                                openBuyMenu(i)
                            end
                        end
                    end
                end
            end
            if not shouldBeDisplayingHint then
                if isDisplayingHint then
                    isDisplayingHint = false
                    exports.key_hints:hideBottomHint({ name = "base_shops" })
                    exports.inventory:closeInventory()
                end
                Citizen.Wait(1500)
            end
        end
    end
)

function createShopBlips()
    if tableLength(blips) <= 0 then
        while not shops do
            Citizen.Wait(1000)
        end
        for shop, shopData in pairs(shops) do
            local type = shopData.type
            if not Config.Restricted[type] or isAllowed(type) then
                local blip = createNewBlip(
                    {
                        coords = shopData.coords,
                        sprite = Config.Blips[type].Sprite,
                        display = 4,
                        scale = Config.Blips[type].Scale,
                        colour = 4,
                        isShortRange = true,
                        text = Config.Blips[type].Label
                    }
                )

                table.insert(blips, blip)
            end
        end
    end
end

function getProductPrice(shopType, name)
    local name = string.lower(name)
    if Config.Products[shopType] and Config.Products[shopType][name] then
        if shopType == "cardealer" then
            return Config.Products.cardealer[name]
        else
            return Config.Products[shopType][name].BasePrice
        end
    end
    return 1
end

function tableLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
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

function isAllowed(type)
    if tableLength(jobs) > 0 then
        for name, jobData in pairs(jobs) do
            for i, job in each(Config.Restricted[type]) do
                if jobData.Type == job then
                    return true
                end
            end
        end
    end
    return false
end

AddEventHandler(
    "settings:changed",
    function(setting, value)
        if setting == "shopsBlips" then
            showBlips = value
            if not showBlips then
                for i, blip in each(blips) do
                    RemoveBlip(blip)
                end
                blips = {}
            else
                createShopBlips()
            end
        end
    end
)
