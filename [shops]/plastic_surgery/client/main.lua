local isSpawned = false
local nearestShop = nil
local nearestDistance = 1000.0

Citizen.CreateThread(
    function()
        Citizen.Wait(500)

        if exports.data:getUserVar("status") == "spawned" or exports.data:getUserVar("status") == "dead" then
            isSpawned = true
        end
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned = false
        elseif status == "spawned" and not isSpawned then
            isSpawned = true
        end
    end
)

Citizen.CreateThread(
    function()
        while not isSpawned do
            Citizen.Wait(500)
        end

        while true do
            local playerCoords = GetEntityCoords(PlayerPedId())
            nearestDistance = 1000.0
            nearestShop = nil

            for k, v in pairs(Config.Shops) do
                local distance = GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, v.x, v.y, v.z, true)
                if distance < 50.0 and distance < nearestDistance then
                    nearestDistance = distance
                    nearestShop = v
                end
            end

            Citizen.Wait(250)
        end
    end
)

RegisterNetEvent("plastic_surgery:notEnoughMoney")
AddEventHandler(
    "plastic_surgery:notEnoughMoney",
    function()
        exports.skinchooser:loadSavedOutfit()
        exports.notify:display({ type = "error", title = "Plastika", text = "Na zaplacení potřebuješ $" .. Config.Price .. "!", icon = "fas fa-dollar-sign", length = 3500 })
    end
)

RegisterNetEvent("plastic_surgery:bought")
AddEventHandler(
    "plastic_surgery:bought",
    function()
        exports.skinchooser:setPlayerOutfit({}, true)
        exports.notify:display({ type = "success", title = "Plastika", text = "Úspěšně jsi zaplatil!", icon = "fas fa-dollar-sign", length = 3500 })
    end
)

function openConfirmBuy()
    WarMenu.CreateMenu("plastic_surgery_confirm", "Plastika", "Vyberte akci")
    WarMenu.SetMenuY("plastic_surgery_confirm", 0.35)
    WarMenu.OpenMenu("plastic_surgery_confirm")

    local paid = false

    while true do
        if WarMenu.IsMenuOpened("plastic_surgery_confirm") then
            isInMenu = true

            if WarMenu.Button("Zaplatit (~r~$" .. Config.Price .. "~s~)") then
                paid = true
                WarMenu.CloseMenu()
                TriggerServerEvent("plastic_surgery:pay")
            end

            if WarMenu.Button("Zrušit") then
                paid = true
                exports.skinchooser:loadSavedOutfit()

                WarMenu.CloseMenu()
            end

            WarMenu.Display()
        else
            isInMenu = false

            if not paid then
                exports.skinchooser:loadSavedOutfit()
            end

            break
        end

        Citizen.Wait(0)
    end
end

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(0)

            if nearestShop then
                DrawMarker(25, nearestShop.x, nearestShop.y, nearestShop.z + 0.1, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.2, 1.2, 1.2, 184, 94, 98, 100, false, true, 2, true, false, false, false)

                if nearestDistance < 1.2 then
                    DrawText3D(nearestShop.x, nearestShop.y, nearestShop.z + 0.5, "[E] Plastická chirurgie")

                    if IsControlJustPressed(1, 38) then
                        local data = {}
                        data.callback = function(clothes)
                            openConfirmBuy()
                        end

                        -- TODO: Skinmenu plastika
                        Citizen.Wait(1000)
                    end
                end
            end
        end
    end
)
