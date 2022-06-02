isSpawned, isDead, isOpened = false, false, false
Inventory, Items, Weapons, Mobile = nil, nil, {}, nil
openedDrop, openedShop, openedPlayer, openedStorage, currentTrunkVehicle = nil, nil, nil, nil, nil
openedShopSpecial = false
isInVehicle = false
isHandCuffed = false
isDisabled = false
currentInstance = ""
hasRequest = false
currentPlayerWeapons = {}

isBindOverwritten = {
    false,
    false,
    false,
    false,
    false
}

local resetedPedWeapons = false
local bindingKey = nil
local shootingTimer = 0

Citizen.CreateThread(
    function()
        Citizen.Wait(3000)

        if exports.data:getUserVar("status") == "spawned" or exports.data:getUserVar("status") == "dead" then
            TriggerServerEvent("inventory:loadCharInventory")
            isSpawned = true

            if exports.data:getUserVar("status") == "dead" then
                isDead = true
            end

            isHandCuffed = exports.data:getCharVar("cuffed")
        end
    end
)

RegisterNetEvent("instance:onEnter")
AddEventHandler(
    "instance:onEnter",
    function(instance)
        currentInstance = instance
    end
)

RegisterNetEvent("instance:onLeave")
AddEventHandler(
    "instance:onLeave",
    function()
        currentInstance = ""
    end
)

RegisterNetEvent("rp:updateCuffed")
AddEventHandler(
    "rp:updateCuffed",
    function(cuffStatus)
        isHandCuffed = cuffStatus
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned = false
        elseif status == "spawned" then
            if not isSpawned then
                TriggerServerEvent("inventory:loadCharInventory")

                isBindOverwritten = {
                    false,
                    false,
                    false,
                    false,
                    false
                }
            end

            isSpawned = true
            isDead = false
        elseif status == "dead" then
            isSpawned = true
            isDead = true

            SendNUIMessage(
                {
                    action = "closeInventory"
                }
            )
        end
    end
)

RegisterNetEvent("inventory:loadedCharInventory")
AddEventHandler(
    "inventory:loadedCharInventory",
    function(inventory, items)
        Inventory = inventory
        Items = items

        SendNUIMessage(
            {
                action = "setItemsData",
                items = items,
                crafting = CRAFTING_RECIPES,
                weaponComponents = Config.WeaponAddons
            }
        )

        setupPlayerWeapons()
        setupPlayerMobile()
    end
)

RegisterNetEvent("inventory:setCharInventoryWithoutReload")
AddEventHandler(
    "inventory:setCharInventoryWithoutReload",
    function(playerId, inventory)
        if playerId == GetPlayerServerId(PlayerId()) then
            Inventory = inventory
            updatePlayerMobile()
            setupPlayerWeapons()
            if isOpened then
                SendNUIMessage(
                    {
                        action = "setMainInventory",
                        inventory = Inventory
                    }
                )
            end
        elseif openedPlayer == playerId then
            SendNUIMessage(
                {
                    action = "setSecondInventory",
                    inventory = inventory
                }
            )
        end
    end
)

RegisterNetEvent("inventory:setCharInventory")
AddEventHandler(
    "inventory:setCharInventory",
    function(playerId, inventory, phoneRemoved)
        if playerId == GetPlayerServerId(PlayerId()) then
            Inventory = inventory
            setupPlayerWeapons()
            if phoneRemoved then
                print("REMOVING PHONE")
                setupPlayerMobile()
            end
            if isOpened then
                SendNUIMessage(
                    {
                        action = "setMainInventory",
                        inventory = Inventory
                    }
                )
            end
        elseif openedPlayer == playerId then
            SendNUIMessage(
                {
                    action = "setSecondInventory",
                    inventory = inventory
                }
            )
        end
    end
)

RegisterNetEvent("inventory:setCharInventoryMobile")
AddEventHandler(
    "inventory:setCharInventoryMobile",
    function(playerId, inventory)
        if playerId == GetPlayerServerId(PlayerId()) then
            Inventory = inventory
            setupPlayerWeapons()
            setupPlayerMobile()
            if isOpened then
                SendNUIMessage(
                    {
                        action = "setMainInventory",
                        inventory = Inventory
                    }
                )
            end
        elseif openedPlayer == playerId then
            SendNUIMessage(
                {
                    action = "setSecondInventory",
                    inventory = inventory
                }
            )
        end
    end
)

RegisterNetEvent("inventory:reloadInventory")
AddEventHandler(
    "inventory:reloadInventory",
    function(playerId, inventory)
        if playerId == GetPlayerServerId(PlayerId()) then
            Inventory = inventory

            SendNUIMessage(
                {
                    action = "setMainInventory",
                    inventory = Inventory
                }
            )

            setupPlayerWeapons()
            updatePlayerMobile()
        elseif openedPlayer == playerId then
            SendNUIMessage(
                {
                    action = "setSecondInventory",
                    inventory = inventory
                }
            )
        end
    end
)

RegisterNetEvent("inventory:destroySuccess")
AddEventHandler(
    "inventory:destroySuccess",
    function()
        exports.notify:display(
            { type = "success", title = "Úspěch", text = "Předmět byl zničen", icon = "fas fa-box", length = 5000 }
        )
    end
)

RegisterNetEvent("inventory:timerError")
AddEventHandler(
    "inventory:timerError",
    function()
        exports.notify:display(
            {
                type = "error",
                title = "Chyba",
                text = "Provedl jsi akci příliš rychle!",
                icon = "fas fa-hourglass-half",
                length = 3500
            }
        )

        SendNUIMessage(
            {
                action = "enable"
            }
        )
    end
)

RegisterNetEvent("inventory:error")
AddEventHandler(
    "inventory:error",
    function(error)
        local message = ""

        if error == "weightExceeded" then
            message = "Tolik toho neuneseš!"
        elseif error == "spaceExceeded" then
            message = "Nemáš dostatek místa!"
        elseif error == "notInShop" or error == "notInStock" then
            message = "Předmět aktuálně v takovém počtu není na skladě!"
        elseif error == "noMoney" then
            message = "Nemáš dostatek peněz!"
        elseif error == "componentAlreadyOn" then
            message = "Toto rozšíření již na zbrani je!"
        elseif error == "camoAlreadyOn" then
            message = "Tento polep již na zbrani je!"
        elseif error == "scopeAlreadyOn" then
            message = "Na zbrani je již jiný zaměřovač!"
        end

        exports.notify:display({ type = "error", title = "Chyba", text = message, icon = "fas fa-box", length = 5000 })

        SendNUIMessage(
            {
                action = "enable"
            }
        )
    end
)

RegisterNetEvent("inventory:giveError")
AddEventHandler(
    "inventory:giveError",
    function(error)
        local message = ""

        if error == "weightExceeded" then
            message = "Tolik toho zvolená osoba neunese!"
        elseif error == "spaceExceeded" then
            message = "Zvolená osoba nemá dostatek místa!"
        elseif error == "notEnoughItems" then
            message = "Tolik toho nemáš!"
        end

        exports.notify:display({ type = "error", title = "Chyba", text = message, icon = "fas fa-box", length = 5000 })

        SendNUIMessage(
            {
                action = "enable"
            }
        )
    end
)

RegisterNetEvent("inventory:storageError")
AddEventHandler(
    "inventory:storageError",
    function(error)
        local message = ""

        if error == "weightExceeded" then
            message = "Došlo by k překročení maximální váhy!"
        elseif error == "spaceExceeded" then
            message = "Tolik se toho do sem nevejde!"
        elseif error == "notEnoughItems" then
            message = "Tolik toho nemáš!"
        elseif error == "notGoodItem" then
            message = "Toto sem uložit nemůžeš!"
        end

        exports.notify:display({ type = "error", title = "Chyba", text = message, icon = "fas fa-box", length = 5000 })

        SendNUIMessage(
            {
                action = "enable"
            }
        )
    end
)

RegisterNetEvent("inventory:giveSuccess")
AddEventHandler(
    "inventory:giveSuccess",
    function(type, item, count)
        local title = "Obdržel jsi předmět"
        local message = "Obdržel jsi " .. count .. "x " .. Items[item].label

        if type == "gave" then
            title = "Úspěch"
            message = "Dal jsi " .. count .. "x " .. Items[item].label .. " jiné osobě"
        end

        exports.notify:display({ type = "success", title = title, text = message, icon = "fas fa-box", length = 5000 })
    end
)

function setupPlayerWeapons()
    if Items == nil then
        return
    end

    Weapons = {}
    local playerPed = PlayerPedId()

    if not resetedPedWeapons then
        RemoveAllPedWeapons(playerPed, true)
        resetedPedWeapons = true
    end

    currentPlayerWeapons = {}

    for _, item in each(Inventory.data) do
        local itemData = Items[item.name]

        if itemData.type == "weapon" and item.data.activeWeapon then
            local weaponHash = GetHashKey(itemData.name)
            local maxAmmo = GetMaxAmmoInClip(playerPed, weaponHash, 1)
            local ammo = 0

            if item.data.ammo then
                if item.data.ammo <= maxAmmo then
                    ammo = item.data.ammo
                else
                    ammo = maxAmmo
                end

                if ammo < 0 then
                    ammo = 0
                end
            end

            currentPlayerWeapons[weaponHash] = true
            if not HasPedGotWeapon(playerPed, weaponHash, false) then
                GiveWeaponToPed(playerPed, weaponHash, ammo, false, false)
            end

            --if Config.Weapons[item.name].isThrowable then
            SetPedAmmo(playerPed, weaponHash, ammo)
            --end

            for component, data in each(Config.WeaponAddons) do
                if data[item.name] then
                    RemoveWeaponComponentFromPed(PlayerPedId(), weaponHash, data[item.name])
                end
            end

            if item.data.components then
                for i, component in each(item.data.components) do
                    GiveWeaponComponentToPed(PlayerPedId(), weaponHash, component)
                end
            end

            if item.data.color then
                SetPedWeaponTintIndex(PlayerPedId(), weaponHash, item.data.color)
            else
                SetPedWeaponTintIndex(PlayerPedId(), weaponHash, 0)
            end

            --SetAmmoInClip(playerPed, weaponHash, ammo)
            Weapons[item.name] = item
        end
    end

    for _, weapon in each(Config.AllWeapons) do
        if Config.Weapons[string.lower(weapon)] == nil then
            local weaponHash = GetHashKey(weapon)

            if HasPedGotWeapon(playerPed, weaponHash, false) then
                RemoveWeaponFromPed(playerPed, weaponHash)
            end
        elseif Weapons[string.lower(weapon)] == nil then
            local weaponHash = GetHashKey(weapon)

            if HasPedGotWeapon(playerPed, weaponHash, false) then
                RemoveWeaponFromPed(playerPed, weaponHash)
            end
        end
    end
end

function setupPlayerMobile()
    if Items == nil then
        return
    end
    Mobile = nil
    for _, item in each(Inventory.data) do
        local itemData = Items[item.name]

        if itemData.type == "mobile" and item.data.activeMobile then
            Mobile = item
            break
        end
    end
    exports.phone:ActivateMobile(Mobile)
end

function updatePlayerMobile()
    if Items == nil then
        return
    end
    Mobile = nil
    for _, item in each(Inventory.data) do
        local itemData = Items[item.name]

        if itemData.type == "mobile" and item.data.activeMobile then
            Mobile = item
        end
    end
end

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(1)
            if Inventory ~= nil and isSpawned and not isDead then
                if not isSelecting and not isOpened and IsControlJustReleased(1, Config.OpenKey) and not isDisabled then
                    openInventory(nil)
                end

                if isOpened and IsPauseMenuActive() then
                    closeInventory()
                    Citizen.Wait(250)
                end
            else
                Citizen.Wait(300)
            end
        end
    end
)

function openInventory(bindKey)
    if not isOpened then
        bindingKey = bindKey
        isOpened = true
        SetNuiFocus(true, true)

        SendNUIMessage(
            {
                action = "openInventory",
                inventory = Inventory
            }
        )
    end
end

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(1)
            if Inventory ~= nil and isSpawned and not isDead then
                local playerPed = PlayerPedId()
                local _, weaponHash = nil, nil

                while IsPedShooting(playerPed) do
                    _, weaponHash = GetCurrentPedWeapon(playerPed, true) % 0x100000000
                    if shootingTimer <= 0 then
                        shootingTimer = 60

                        if weaponHash then
                            local weapon = getWeaponFromHash(weaponHash)
                            if weapon.isTank == nil or weapon.isTank == false then
                                TriggerServerEvent("playerShooting", GetPlayerServerId(PlayerId()))
                            end
                        end
                    end
                    Citizen.Wait(500)
                end
            else
                Citizen.Wait(300)
            end
        end
    end
)

RegisterNUICallback(
    "closeInventory",
    function(data, cb)
        if openedPlayer ~= nil then
            TriggerServerEvent("inventory:setOpenedInventory", nil)
        end

        if openedStorage ~= nil then
            TriggerServerEvent("inventory:setOpenedStorage", nil, nil)
        end

        if openedShop ~= nil then
            TriggerServerEvent("inventory:setOpenedShop", nil)
        end

        openedDrop = nil
        openedShop = nil
        openedShopSpecial = false
        openedPlayer = nil
        openedStorage = nil

        if currentTrunkVehicle then
            ClearPedTasks(PlayerPedId())
            SetVehicleDoorShut(currentTrunkVehicle, 5, false)
            currentTrunkVehicle = nil
        end

        isOpened = false
        SetNuiFocus(false, false)

        TriggerEvent("inventory:closedInventory", data.type)
    end
)

RegisterNUICallback(
    "sortItems",
    function(data, cb)
        TriggerServerEvent("inventory:sortItems", data.from, data.to)
    end
)

RegisterNUICallback(
    "useItem",
    function(data, cb)
        if Config.Debug then
            print("useItem")
        end

        SendNUIMessage(
            {
                action = "closeInventory"
            }
        )

        if LocalPlayer.state.isCuffed then
            exports.notify:display(
                {
                    type = "error",
                    title = "Předmět",
                    text = "Máš pouta!",
                    icon = "fas fa-times",
                    length = 4000
                }
            )
            return
        end

        local item = Items[data.item]

        if (item.type == "weapon" or item.usable == 1) and bindingKey then
            exports.bind:addBind(bindingKey, item.type, item.name)
            bindingKey = nil
        else
            if item.type == "item" then
                if Config.Debug then
                    print("useItemItem")
                end

                TriggerServerEvent("inventory:usedItem", data.item, data.slot, data.data)
                TriggerEvent("inventory:usedItem", data.item, data.slot, data.data)
            elseif item.type == "weapon" then
                local playerPed = PlayerPedId()
                local _, weaponHash = GetCurrentPedWeapon(playerPed, true)
                if GetHashKey(data.item) == weaponHash then
                    SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_UNARMED"), true)
                end

                TriggerServerEvent("inventory:activateWeapon", data.item, data.slot, data.data)
            elseif item.type == "mobile" then
                TriggerServerEvent("inventory:activateMobile", data.item, data.slot, data.data)
            elseif item.type == "sim" then
                exports.phone:ActiveSim(data.item, data.slot, data.data)
            end
        end
    end
)

RegisterNUICallback(
    "dropItem",
    function(data, cb)
        TriggerServerEvent("inventory:dropItem", data.item, data.slot)
    end
)

RegisterNUICallback(
    "splitItem",
    function(data, cb)
        TriggerServerEvent("inventory:splitItem", data.from, data.to, data.count)
    end
)

RegisterNUICallback(
    "swapItem",
    function(data, cb)
        TriggerServerEvent("inventory:swapItem", data.from, data.to)
    end
)

RegisterNUICallback(
    "joinItem",
    function(data, cb)
        TriggerServerEvent("inventory:joinItem", data.from, data.to, data.count, data.data)
    end
)

function getWeaponAmmo(weaponHash)
    for _, weapon in each(Weapons) do
        if weaponHash == GetHashKey(weapon.name) then
            return weapon.data.ammo
        end
    end

    return -1
end

function getItem(itemName)
    return Items[itemName]
end

function getCurrentCash()
    local cash = 0
    if Inventory ~= nil then
        for _, item in each(Inventory.data) do
            if item.name == "cash" then
                cash = cash + item.count
            end
        end
    end

    return cash
end

function checkTransmitter()
    if Inventory ~= nil then
        for _, item in each(Inventory.data) do
            if item.name == "transmitter" then
                return true
            end
        end
    end

    return false
end

function checkCarKey(plate)
    if Inventory ~= nil then
        for _, item in each(Inventory.data) do
            if item.name == "car_keys" and item.data.spz == plate then
                return true
            end
        end
    end

    return false
end

function checkDoorKey(doorIds)
    if Inventory ~= nil then
        for _, item in each(Inventory.data) do
            if item.name == "door_keys" or item.name == "door_keycard" then
                if type(doorIds) == "string" then
                    if item.data.doorid == doorIds then
                        return item.name
                    end
                elseif type(doorIds) == "table" then
                    for i, keyId in each(doorIds) do
                        if item.data.doorid == keyId then
                            return item.name
                        end
                    end
                end
            end
        end
    end

    return false
end

function getWeaponFromHash(hashKey)
    for name, weapon in each(Config.Weapons) do
        if weapon.hash == hashKey then
            weapon.name = name
            return weapon
        end
    end

    return nil
end

function getWeaponLabel(hashKey)
    for name, weapon in each(Config.Weapons) do
        if weapon.hash == hashKey then
            return weapon.label
        end
    end

    return nil
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy

    if orig_type == "table" then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end

    return copy
end

function closeInventory()
    SendNUIMessage(
        {
            action = "closeInventory"
        }
    )
end

RegisterNUICallback(
    "selectItemAction",
    function(data, cb)
        if LocalPlayer.state.isCuffed then
            exports.notify:display(
                {
                    type = "error",
                    title = "Akce",
                    text = "Máš pouta!",
                    icon = "fas fa-times",
                    length = 4000
                }
            )
            return
        end

        local item = getItemBySlot(data.from)
        local itemData = getItem(item.name)
        local isAmmo = item.data.isAmmo
        local isMenu = (item.name == "restaurant_menu")
        local isMobileUsed = false
        if Mobile ~= nil and item.name == "phone" then
            isMobileUsed = (item.data.id == Mobile.data.id)
        end
        local isBlocked = Config.BlockedItemForTag[item.name]
        local isDrink = not string.match(item.name, "beerpack") and exports.food:getItem(item.name) or false
        local hasSerialNumber = itemData.type == "weapon" and item.data.number

        local isPolice = exports.base_jobs:hasUserJobType("police", true)

        Citizen.CreateThread(
            function()
                WarMenu.CreateMenu("inventory_item_action", "Akce s předmětem", "Zvolte akci")
                WarMenu.OpenMenu("inventory_item_action")

                while true do
                    if WarMenu.IsMenuOpened("inventory_item_action") then
                        if WarMenu.Button("Dát předmět hráči") then
                            WarMenu.CloseMenu()
                            if not isMobileUsed then
                                selectPlayerToGive(data)
                            end
                        elseif WarMenu.Button("Zahodit předmět") then
                            WarMenu.CloseMenu()
                            dropItemToGround(data)
                        elseif itemData.type == "weapon" and WarMenu.Button("Seznam rozšíření zbraně") then
                            WarMenu.CloseMenu()
                            openRemoveWeaponComponentMenu(GetHashKey(itemData.name))
                        elseif item.name == "evidencebag" and item.data.id and WarMenu.Button("Rozbalit sáček s důkazy") then
                            WarMenu.CloseMenu()
                            TriggerServerEvent("inventory:openEvidenceBag", item)
                        elseif item.name == "evidencebag" and isPolice and item.data.id and WarMenu.Button("Rozbalit sáček s důkazy někomu jinému") then
                            WarMenu.CloseMenu()
                            TriggerEvent(
                                "util:closestPlayer",
                                {
                                    radius = 2.0
                                },
                                function(player)
                                    if player then
                                        TriggerServerEvent("inventory:evidenceBagOpenRequest", player, item.data.id)
                                    end
                                end
                            )
                        elseif item.name == "evidencebag" and isPolice and item.data.id and WarMenu.Button("Vložit do sáčku předměty hráče") then
                            WarMenu.CloseMenu()
                            TriggerEvent(
                                "util:closestPlayer",
                                {
                                    radius = 2.0
                                },
                                function(player)
                                    if player then
                                        TriggerServerEvent("inventory:evidenceBagRequest", player, item.data.id)
                                    end
                                end
                            )
                        elseif not isBlocked and WarMenu.Button("Nastavit jmenovku") then
                            WarMenu.CloseMenu()
                            exports.input:openInput(
                                "text",
                                { title = "Zadej jmenovku", placeholder = "" },
                                function(tag)
                                    if tag then
                                        TriggerServerEvent("inventory:addTagForItem", item, tag)
                                    end
                                end
                            )
                        elseif not isBlocked and WarMenu.Button("Odstranit jmenovku") then
                            TriggerServerEvent("inventory:removeTagFromItem", item)
                            WarMenu.CloseMenu()
                        elseif isDrink and item.data.amount and item.data.amount > 0 and (isDrink.Type == "bottle" or isDrink.Type == "can") and WarMenu.Button("Rozlít nápoj") then
                            exports.input:openInput(
                                "number",
                                { title = "Zadejte počet skleniček", placeholder = "" },
                                function(glassCount)
                                    if glassCount then
                                        exports.input:openInput(
                                            "number",
                                            { title = "Zadej množství, které chcete do skleniček v ml.", placeholder = "" },
                                            function(ml)
                                                if ml then
                                                    TriggerServerEvent("food:checkGlasses", item, tonumber(glassCount), tonumber(ml))
                                                end
                                            end
                                        )
                                    end
                                end
                            )
                            WarMenu.CloseMenu()
                        elseif itemData.class == "clothes" and WarMenu.Button("Obléct někoho jiného") then
                            WarMenu.CloseMenu()
                            TriggerEvent(
                                "util:closestPlayer",
                                {
                                    radius = 2.0
                                },
                                function(target)
                                    if target then
                                        TriggerServerEvent("skinchooser:sendRequestForTakeon", target, item.name, item.slot, item.data)
                                    end
                                end
                            )
                        elseif isAmmo and WarMenu.Button("Napáskovat zásobník") then
                            WarMenu.CloseMenu()
                            exports.weapons_scripts:loadAmmoIntoMagazine(item, data)
                        elseif hasSerialNumber and WarMenu.Button("Zkopírovat seriové číslo") then
                            WarMenu.CloseMenu()
                            exports.copy:copyToInsert(item.data.number)
                        elseif isMenu and WarMenu.Button("Vytvořit napojový/jidelní lístek") then
                            WarMenu.CloseMenu()
                            exports.barSystem:makeMenu(item, data)
                        elseif item.data.activeMobile and WarMenu.Button("mobileMenu") then
                            WarMenu.CloseMenu()
                            exports.phone:mobileMenu(item.name, item.slot, item.data)
                        elseif item.data.activeMobile and Items[item.name].type == "sim" and WarMenu.Button("Sim menu") then
                            WarMenu.CloseMenu()
                            exports.phone:ActiveSim(item.name, item.slot, item.data)
                        elseif
                        item and Items[item.name] and Items[item.name].destroyable == 1 and
                            WarMenu.Button("Zničit předmět")
                        then
                            WarMenu.CloseMenu()
                            destroyItem(data)
                        end

                        WarMenu.Display()
                    else
                        break
                    end

                    Citizen.Wait(1)
                end
            end
        )
    end
)

function destroyItem(data)
    TriggerServerEvent("inventory:destroyPlayerItem", data.from, data.count)
end

function selectPlayerToGive(data)
    TriggerEvent(
        "util:closestPlayer",
        {
            radius = 2.0
        },
        function(player)
            if player then
                ClearPedSecondaryTask(PlayerPedId())
                RequestAnimDict("mp_common")
                while (not HasAnimDictLoaded("mp_common")) do
                    Citizen.Wait(10)
                end

                if not IsPedInAnyVehicle(PlayerPedId(), false) then
                    Citizen.CreateThread(
                        function()
                            local targetEntity = GetPlayerPed(GetPlayerFromServerId(player))
                            if DoesEntityExist(targetEntity) then
                                TaskTurnPedToFaceEntity(PlayerPedId(), targetEntity, 1.5)
                            end

                            Citizen.Wait(750)
                            TaskPlayAnim(
                                PlayerPedId(),
                                "mp_common",
                                "givetake1_a",
                                100.0,
                                200.0,
                                0.3,
                                120,
                                0.2,
                                0,
                                0,
                                0
                            )
                        end
                    )
                end

                TriggerServerEvent("inventory:giveToSelectedPlayer", player, data.from, data.count)
                Citizen.Wait(750)
                ClearPedTasks(PlayerPedId())
            end
        end
    )
end

function getActiveWeapons()
    return Weapons
end

function getUsableItems()
    local usableItems = {}

    for _, item in each(Inventory.data) do
        local itemData = Items[item.name]

        if itemData.type == "item" and itemData.usable == 1 then
            item.name = itemData.name
            table.insert(usableItems, item)
        end
    end

    return usableItems
end

function getPlayerItems()
    local playerItems = {}

    for _, item in each(Inventory.data) do
        local itemData = Items[item.name]

        if itemData.type == "item" then
            item.name = itemData.name
            table.insert(playerItems, item)
        end
    end

    return playerItems
end

function getMobiles()
    local Mobiles = {}

    for _, item in each(Inventory.data) do
        local itemData = Items[item.name]

        if itemData.type == "mobile" then
            item.name = itemData.name
            table.insert(Mobiles, item)
        end
    end

    return Mobiles
end

function getSimCards()
    local Sim = {}

    for _, item in each(Inventory.data) do
        local itemData = Items[item.name]

        if itemData.type == "sim" then
            item.name = itemData.name
            table.insert(Sim, item)
        end
    end

    return Sim
end

function checkPlayerMobile()
    local mobileFound = false
    if Mobile then
        mobileFound = true
    end
    return mobileFound
end

function getActiveMobile()
    if Mobile ~= nil then
        return Mobile
    end
    return nil
end

function tryToUseItem(itemName, message, slot)
    local itemData = Items[itemName]
    local used = false

    for _, item in each(Inventory.data) do
        if item.name == itemName and (slot == nil or (slot == item.slot)) then
            if itemData.type == "item" and itemData.usable == 1 then
                TriggerServerEvent("inventory:usedItem", itemName, item.slot, item.data)
                TriggerEvent("inventory:usedItem", itemName, item.slot, item.data)

                used = true
                break
            elseif itemData.type == "weapon" then
                local weaponHash = GetHashKey(item.name)
                local playerPed = PlayerPedId()

                if GetCurrentPedWeapon(playerPed, weaponHash, true) then
                    SetCurrentPedWeapon(playerPed, "weapon_unarmed", true)
                elseif HasPedGotWeapon(playerPed, weaponHash, false) then
                    SetCurrentPedWeapon(playerPed, weaponHash, true)
                end

                used = true
                break
            end
        end
    end

    if not used and message then
        if itemData.type == "weapon" then
            exports.notify:display(
                {
                    type = "error",
                    title = "Zbraň",
                    text = "Nemáš u sebe aktivní " .. getWeaponLabel(GetHashKey(itemName)) .. "!",
                    icon = "fas fa-times",
                    length = 4000
                }
            )
        else
            exports.notify:display(
                {
                    type = "error",
                    title = "Předmět",
                    text = "Nemáš u sebe " .. itemData.label .. "!",
                    icon = "fas fa-times",
                    length = 4000
                }
            )
        end
    end
end

function getItemBySlot(slot)
    for _, item in each(Inventory.data) do
        if item.slot == slot then
            return item
        end
    end

    return nil
end

function disableInventory(disabled)
    isDisabled = disabled
end

function makeEntityFaceEntity(entity1, entity2)
    local p1 = GetEntityCoords(entity1, true)
    local p2 = GetEntityCoords(entity2, true)

    local dx = p2.x - p1.x
    local dy = p2.y - p1.y

    local heading = GetHeadingFromVector_2d(dx, dy)
    SetEntityHeading(entity1, heading)
end

Citizen.CreateThread(
    function()
        Citizen.Wait(1000)
        if shootingTimer > 0 then
            shootingTimer = shootingTimer - 1
        end
    end
)

RegisterNetEvent("inventory:evidenceBagRequest")
AddEventHandler(
    "inventory:evidenceBagRequest",
    function(source, evidencebagId)
        hasRequest = true

        PlaySound(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 0, 0, 1)
        TriggerEvent(
            "chat:addMessage",
            {
                templateId = "warning",
                args = {
                    "Přišla ti žádost o vložení všech předmětů do sáčku na důkazní materiál. Stiskni Z pro přijetí a L pro odmítnutí."
                }
            }
        )

        while hasRequest do
            Citizen.Wait(5)
            if (IsControlJustReleased(0, 246) or IsDisabledControlJustReleased(0, 246)) and hasRequest then
                local closestPlayers = exports.control:getClosestPlayersInDistance(3.5)
                local foundPlayer = false

                for i, player in each(closestPlayers) do
                    if player.playerid == source then
                        foundPlayer = true
                        break
                    end
                end

                if foundPlayer then
                    TriggerServerEvent("inventory:evidenceBagInsertFromPlayer", source, evidencebagId)
                    hasRequest = false
                else
                    TriggerEvent(
                        "chat:addMessage",
                        {
                            templateId = "error",
                            args = { "Hráč se od tebe příliš vzdálil!" }
                        }
                    )

                    hasRequest = false
                end
            elseif (IsControlJustReleased(0, 182) or IsDisabledControlJustReleased(0, 246)) and hasRequest then
                TriggerEvent(
                    "chat:addMessage",
                    {
                        templateId = "success",
                        args = { "Odmítl jsi." }
                    }
                )
                hasRequest = false
            end
        end
    end
)

RegisterNetEvent("inventory:evidenceBagOpenRequest")
AddEventHandler(
    "inventory:evidenceBagOpenRequest",
    function(source, evidencebagId)
        hasRequest = true

        PlaySound(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 0, 0, 1)
        TriggerEvent(
            "chat:addMessage",
            {
                templateId = "warning",
                args = {
                    "Přišla ti žádost o vybrání všech předmětů ze sáčku na důkazní materiál. Stiskni Z pro přijetí a L pro odmítnutí."
                }
            }
        )

        while hasRequest do
            Citizen.Wait(5)
            if (IsControlJustReleased(0, 246) or IsDisabledControlJustReleased(0, 246)) and hasRequest then
                local closestPlayers = exports.control:getClosestPlayersInDistance(3.5)
                local foundPlayer = false

                for i, player in each(closestPlayers) do
                    if player.playerid == source then
                        foundPlayer = true
                        break
                    end
                end

                if foundPlayer then
                    TriggerServerEvent("inventory:evidenceBagInsertToPlayer", source, evidencebagId)
                    hasRequest = false
                else
                    TriggerEvent(
                        "chat:addMessage",
                        {
                            templateId = "error",
                            args = { "Hráč se od tebe příliš vzdálil!" }
                        }
                    )

                    hasRequest = false
                end
            elseif (IsControlJustReleased(0, 182) or IsDisabledControlJustReleased(0, 246)) and hasRequest then
                TriggerEvent(
                    "chat:addMessage",
                    {
                        templateId = "success",
                        args = { "Odmítl jsi." }
                    }
                )
                hasRequest = false
            end
        end
    end
)

AddEventHandler(
    "CEventShockingVisibleWeapon",
    function(entities, eventEntity, args)
        if not eventEntity or eventEntity ~= PlayerPedId() then
            return
        end

        local _, weaponHash = GetCurrentPedWeapon(PlayerPedId(), true)
        if GetWeaponDamageType(weaponHash) < 3 or weaponHash == GetHashKey("weapon_unarmed") or currentPlayerWeapons[weaponHash] or currentPlayerWeapons[weaponHash % 0x100000000] then
            return
        end

        for weaponName, weaponData in pairs(Config.Weapons) do
            if GetHashKey(weaponName) == weaponHash or GetHashKey(weaponName) == weaponHash % 0x100000000 then
                if weaponData.isMelee == false then
                    TriggerServerEvent("admin:nonAllowedWeapon", weaponData.label)
                end
                return
            end
        end

        TriggerServerEvent("admin:nonAllowedWeapon", weaponHash)
    end
)
