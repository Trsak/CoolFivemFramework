RegisterNetEvent("inventory:openedStorage")
AddEventHandler(
    "inventory:openedStorage",
    function(type, name, storage)
        if not isOpened then
            openedStorage = {
                type = type,
                name = name
            }
            TriggerServerEvent("inventory:setOpenedStorage", type, name)

            isOpened = true
            SetNuiFocus(true, true)

            SendNUIMessage(
                {
                    action = "openStorage",
                    inventory = Inventory,
                    storage = storage
                }
            )
        end
    end
)

RegisterNUICallback(
    "putIntoStorage",
    function(data, cb)
        TriggerServerEvent("inventory:putIntoStorage", openedStorage, data.from, data.to, data.count)
    end
)

RegisterNUICallback(
    "swapStorageItem",
    function(data, cb)
        TriggerServerEvent("inventory:swapStorageItem", openedStorage, data.from, data.to)
    end
)

RegisterNUICallback(
    "sortStorageItems",
    function(data, cb)
        TriggerServerEvent("inventory:sortStorageItems", openedStorage, data.from, data.to)
    end
)

RegisterNUICallback(
    "joinStorageItem",
    function(data, cb)
        TriggerServerEvent("inventory:joinStorageItem", openedStorage, data.from, data.to, data.count, data.data)
    end
)

RegisterNUICallback(
    "splitStorageItems",
    function(data, cb)
        TriggerServerEvent("inventory:splitStorageItems", openedStorage, data.from, data.to, data.count)
    end
)

RegisterNUICallback(
    "takeFromStorage",
    function(data, cb)
        TriggerServerEvent("inventory:takeFromStorage", openedStorage, data.from, data.to, data.count)
    end
)

RegisterNetEvent("inventory:storageChanged")
AddEventHandler(
    "inventory:storageChanged",
    function(storage)
        if openedStorage and openedStorage.type == storage.type and openedStorage.name == storage.name then
            SendNUIMessage(
                {
                    action = "setStorageInventory",
                    storage = storage
                }
            )
        end
    end
)
