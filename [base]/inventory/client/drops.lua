local Drops = {}
local openTimer = nil
local isShowingHint = false
local currentDrop = nil

RegisterNetEvent("inventory:loadDrops")
AddEventHandler(
    "inventory:loadDrops",
    function(drops)
        Drops = drops
    end
)

RegisterNetEvent("inventory:changedDrop")
AddEventHandler(
    "inventory:changedDrop",
    function(changedDrop)
        if openedDrop and openedDrop.coords == changedDrop.coords then
            openedDrop = changedDrop

            SendNUIMessage(
                {
                    action = "openDrop",
                    inventory = Inventory,
                    drop = formatDrop(openedDrop)
                }
            )
        end

        for i, drop in each(Drops) do
            if drop.coords == changedDrop.coords then
                Drops[i] = changedDrop
                break
            end
        end
    end
)

RegisterNetEvent("inventory:removeDrop")
AddEventHandler(
    "inventory:removeDrop",
    function(removedDrop)
        if openedDrop and openedDrop.coords == removedDrop.coords then
            openedDrop = nil

            SendNUIMessage(
                {
                    action = "closeInventory"
                }
            )
        end

        for i, drop in each(Drops) do
            if drop.coords == removedDrop.coords then
                table.remove(Drops, i)
                break
            end
        end
    end
)

RegisterNetEvent("inventory:newDrop")
AddEventHandler(
    "inventory:newDrop",
    function(drop)
        table.insert(Drops, drop)
    end
)

Citizen.CreateThread(
    function()
        while true do
            if isSpawned then
                reloadDrops()
            end
            Citizen.Wait(2500)
        end
    end
)

function reloadDrops()
    local playerCoords = GetEntityCoords(PlayerPedId())
    isInVehicle = IsPedInAnyVehicle(PlayerPedId(), false)

    for _, drop in each(Drops) do
        if not isInVehicle and (drop.instance == currentInstance or (currentInstance == "" and drop.instance == nil)) then
            local distance = #(playerCoords - drop.coords)
            if distance < 25.0 then
                drop.canOpen = false
                if #drop.data > 0 then
                    drop.drawMarker = true

                    if distance <= 1.5 then
                        drop.canOpen = true
                    end
                end
            else
                drop.drawMarker = false
            end
        else
            drop.drawMarker = false
        end
    end
end

RegisterCommand(
    "pickupitems",
    function()
        if currentDrop ~= nil and not openTimer then
            openTimer = 2
            currentDrop = OpenDrop(currentDrop)
        end
    end,
    false
)
createNewKeyMapping({ command = "pickupitems", text = "Předměty na zemi", key = "Y" })

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(1)
            local isNear = false

            for _, drop in each(Drops) do
                if drop.drawMarker and not isInVehicle then
                    DrawMarker(21, drop.coords.x, drop.coords.y, drop.coords.z - 0.5, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.4, 0.4, 0.4, 184, 94, 98, 100, true, true, 2, true, false, false, false)

                    if drop.canOpen then
                        if drop ~= currentDrop then
                            currentDrop = nil
                            isShowingHint = false
                            exports["key_hints"]:hideHint({ ["name"] = "drop_hint" })
                        end
                        currentDrop = drop
                        isNear = true

                        if not isShowingHint then
                            isShowingHint = true
                            exports["key_hints"]:displayHint({ ["name"] = "drop_hint", ["key"] = "~INPUT_FC152B91~", ["text"] = "Předměty na zemi", ["coords"] = vec3(drop.coords.x, drop.coords.y, drop.coords.z) })
                        end
                    end
                end
            end

            if isShowingHint and not isNear then
                currentDrop = nil
                isShowingHint = false
                exports["key_hints"]:hideHint({ ["name"] = "drop_hint" })
            end
        end
    end
)

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(1000)

            if openTimer then
                openTimer = openTimer - 1

                if openTimer <= 0 then
                    openTimer = nil
                end
            end
        end
    end
)

function OpenDrop(drop)
    openedDrop = drop

    if not isOpened then
        isOpened = true
        SetNuiFocus(true, true)

        SendNUIMessage(
            {
                action = "openDrop",
                inventory = Inventory,
                drop = formatDrop(openedDrop)
            }
        )
    end
end

function formatDrop(drop)
    local formattedDrop = deepcopy(drop)
    formattedDrop.coords = { ["x"] = drop.coords.x, ["y"] = drop.coords.y, ["z"] = drop.coords.z }
    return formattedDrop
end

RegisterNUICallback(
    "takeFromDrop",
    function(data, cb)
        TriggerServerEvent("inventory:takeFromDrop", openedDrop, data.from, data.to, data.count)
        exports.emotes:playEmoteByName("pickup")
    end
)

RegisterNUICallback(
    "dropItemToGround",
    function(data, cb)
        dropItemToGround(data)
    end
)

function dropItemToGround(data)
    if isHandCuffed then
        return
    end

    local position = GetEntityCoords(PlayerPedId())
    TriggerServerEvent("inventory:dropItemToGround", data.from, data.count, position, currentInstance, data.to)

    if not IsPedInAnyVehicle(PlayerPedId(), false) then
        exports.emotes:playEmoteByName("pickup")
    end
end

RegisterNUICallback(
    "sortDropItems",
    function(data, cb)
        TriggerServerEvent("inventory:sortDropItems", openedDrop, data.from, data.to)
    end
)

RegisterNUICallback(
    "splitDropItem",
    function(data, cb)
        TriggerServerEvent("inventory:splitDropItem", openedDrop, data.from, data.to, data.count)
    end
)

RegisterNUICallback(
    "joinDropItem",
    function(data, cb)
        TriggerServerEvent("inventory:joinDropItem", openedDrop, data.from, data.to, data.count, data.data)
    end
)

RegisterNUICallback(
    "swapDropItem",
    function(data, cb)
        TriggerServerEvent("inventory:swapDropItem", openedDrop, data.from, data.to)
    end
)
