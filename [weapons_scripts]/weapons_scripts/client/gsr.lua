AddEventHandler(
        "inventory:usedItem",
        function(itemName, slot, data)
            if itemName == "gsr_testkit" then
                if data.amount == nil then
                    data.amount = 5
                end
                if data.amount == nil or data.amount ~= nil then
                    data.amount = data.amount - 1
                    TriggerEvent(
                            "util:closestPlayer",
                            {
                                radius = Config.maxDistance
                            },
                            function(player)
                                if player then
                                    local menu = {
                                        main = {
                                            action = 'gsr_testkit_action',
                                            label = "Použití GSR testu",
                                            subLabel = "Zvolte, odkud budete odebírat vzorek"
                                        },
                                        submenu = getClothes(GetPlayerPed(GetPlayerFromServerId(player))),
                                        trigger = "weapons_scripts:client:gsr_test",
                                        data = {
                                            player = player,
                                            itemData = data,
                                            itemName = itemName,
                                            itemSlot = slot,
                                            clothes = getClothes(GetPlayerPed(GetPlayerFromServerId(player)))
                                        }
                                    }
                                    createMenu(menu)
                                end
                            end
                    )
                end
            end
            if itemName == "bucket" then
                local menu = {
                    main = {
                        action = 'water_cleanup_action',
                        label = "Za pomocí kýble, se můžeš umýt.",
                        subLabel = "Zvol, co si umyješ"
                    },
                    submenu = getClothes(PlayerPedId()),
                    trigger = "weapons_scripts:client:clean",
                    data = {
                        player = GetPlayerServerId(PlayerId()),
                        type = itemName,
                        clothes = getClothes(PlayerPedId())
                    }
                }
                createMenu(menu)
            end
        end
)

AddEventHandler("weapons_scripts:client:gsr_test", function(data)
    if data.itemData.amount == 5 then
        data.itemData.label = "Nerozbaleno"
    else
        data.itemData.label = "Rozbaleno"
    end
    --TriggerServerEvent('inventory:removePlayerItem', data.itemName, 1, data.data, data.slot)
    --TriggerServerEvent('weapons_scripts:server:giveGSR', data.itemName, 1, data.data, data.slot)
    TriggerServerEvent('weapons_scripts:server:GSR', data)
end)

AddEventHandler("weapons_scripts:client:clean", function(data)
    TriggerServerEvent('weapons_scripts:server:clean', data)
end)

RegisterNetEvent('weapons_scripts:client:shot')
AddEventHandler('weapons_scripts:client:shot', function()

end)

local stop = false

Citizen.CreateThread(function()
    while true do
        if IsPedFatallyInjured(PlayerPedId()) and not stop then
            ---local coords = GetEntityCoords(PlayerPedId())
            --local found, newZ = GetGroundZFor_3dCoord(coords.x,coords.y,coords.z,false)
            --coords = vector3(coords.x,coords.y,newZ - 0.2)
            --TriggerServerEvent("weapons_scripts:server:getshot", coords, FireMode.Weapons[Active_Weapon])
            stop = true
        else
            stop = true
        end
        Citizen.Wait(200)
    end
end)

function getClothes(ped)
    local clothes = {}
    for k, v in each(exports['fivem-appearance']:getPedComponents(ped)) do
        for _, e in each(Config.AllowedClothes) do
            if k == e then
                data = {
                    component_id = v.component_id,
                    number = v.drawable,
                    texture = v.texture,
                    name = Config.Clothes[k],
                    powder = 0
                }
                table.insert(clothes, data)
            end
        end
    end
    return clothes
end

function createMenu(menu)
    Citizen.CreateThread(function()
        WarMenu.CreateMenu(menu.main.action, menu.main.label, menu.main.subLabel)
        WarMenu.OpenMenu(menu.main.action)
        while true do
            if WarMenu.IsMenuOpened(menu.main.action) then
                for i=1, #menu.submenu do
                    if WarMenu.Button(menu.submenu[i].name) then
                        menu.data.selected = i
                        TriggerEvent(menu.trigger, menu.data)
                        WarMenu.CloseMenu()
                    end
                end
                WarMenu.Display()
            else
                break
            end
            Citizen.Wait(1)
        end
    end)
end

RegisterCommand("cleanInWater", function()
    if IsEntityInWater(PlayerPedId()) then
        local data = {
            player = GetPlayerServerId(PlayerId()),
            type = "water",
            clothes = getClothes(PlayerPedId())
        }
        TriggerServerEvent('weapons_scripts:server:clean', data)
    end
end)

createNewKeyMapping({command = "cleanInWater", text = "Umytí pro GSR", key = "E"})