local isSpawned = false

Citizen.CreateThread(
    function()
        Citizen.Wait(500)

        local status = exports.data:getUserVar("status")
        if status == ("spawned" or "dead") then
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
        elseif status == ("spawned" or "dead") then
            isSpawned = true
        end
    end
)

RegisterCommand(
    "zraneni",
    function()
        if not inMenu and isSpawned then
            inMenu = true
            openInjuriesMenu()
        end
    end
)

RegisterCommand(
    "odstranitzraneni",
    function()
        removeAllInjuries()
    end
)

function removeAllInjuries()
    ClearPedBloodDamage(PlayerPedId())
    ResetPedVisibleDamage(PlayerPedId())

    for i = 5, 0, -1 do
        removeInjuriesByZone(i)
    end
end

function removeInjuriesByZone(zone)
    ClearPedBloodDamageByZone(PlayerPedId(), zone)
    ClearPedDamageDecalByZone(PlayerPedId(), zone)
end

function openInjuriesMenu()
    WarMenu.CreateMenu("injuries_menu", "Nastavení", "Změna zranění")
    WarMenu.OpenMenu("injuries_menu")
    WarMenu.SetMenuY("injuries_menu", 0.35)

    WarMenu.CreateSubMenu("injuries_menu_clear", "injuries_menu", "Odstranění zranění")
    WarMenu.CreateSubMenu("injuries_menu_set", "injuries_menu", "Nastavení zranění")

    while true do
        if WarMenu.IsMenuOpened("injuries_menu") then
            WarMenu.MenuButton("Odstranění zranění", "injuries_menu_clear")
            WarMenu.MenuButton("Nastavení zranění", "injuries_menu_set")

            WarMenu.Display()
        elseif WarMenu.IsMenuOpened("injuries_menu_clear") then
            if WarMenu.Button("Odstranit všechna zranění") then
                removeAllInjuries()
            elseif WarMenu.Button("Odstranit zranění na trupu") then
                removeInjuriesByZone(0)
            elseif WarMenu.Button("Odstranit zranění na hlavě") then
                removeInjuriesByZone(1)
            elseif WarMenu.Button("Odstranit zranění na levé ruce") then
                removeInjuriesByZone(2)
            elseif WarMenu.Button("Odstranit zranění na pravé ruce") then
                removeInjuriesByZone(3)
            elseif WarMenu.Button("Odstranit zranění na levé noze") then
                removeInjuriesByZone(4)
            elseif WarMenu.Button("Odstranit zranění na pravé noze") then
                removeInjuriesByZone(5)
            end

            WarMenu.Display()
        elseif WarMenu.IsMenuOpened("injuries_menu_set") then
            for _, injury in each(Config.Injuries) do
                if WarMenu.Button(injury.label) then
                    ApplyPedDamagePack(PlayerPedId(), injury.damagePack, injury.damage, injury.mult)
                end
            end

            WarMenu.Display()
        else
            WarMenu.CloseMenu()
            break
        end

        Citizen.Wait(0)
    end

    inMenu = false
end
