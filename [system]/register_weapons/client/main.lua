local selectedPlayer = nil

local openedWeapon = {
    serialnumber = "",
    name = "",
    type = "",
    status = "registered"
}

RegisterNetEvent("rw:checkSerialnumber")
AddEventHandler("rw:checkSerialnumber", function(isRegistered, data)
    if isRegistered then
        openedWeapon = data
        exports.notify:display({
            type = "info",
            title = "Registr zbraní",
            text = "Zbraň je v systému",
            icon = "fas fa-atlas",
            length = 3500
        })
        WarMenu.CreateMenu("inregister", "REGISTR ZBRANÍ", "")
        WarMenu.OpenMenu("inregister")
        WarMenu.CreateSubMenu("edit_status", "inregister", "")

        while true do
            if WarMenu.IsMenuOpened("inregister") then
                if WarMenu.Button("Seriové číslo: ~b~" .. openedWeapon.serialnumber) then
                elseif WarMenu.Button("Majitel: ~b~" .. (openedWeapon.name or "nenalezen")) then
                elseif WarMenu.Button("Model zbraně: ~b~" .. openedWeapon.type) then
                    exports.input:openInput("text", {
                        title = "Zadejte model zbraně",
                        placeholder = ""
                    }, function(model)
                        if model then
                            openedWeapon.type = model
                        end
                    end)

                elseif WarMenu.MenuButton("Status: ~b~" .. Config.status[openedWeapon.status], "edit_status") then

                elseif WarMenu.Button("Odeslat úpravy do systému") then
                    if openedWeapon.serialnumber ~= "" and openedWeapon.type ~= "" and openedWeapon.status ~= "" then
                        TriggerServerEvent("rw:edit", openedWeapon.serialnumber, openedWeapon.type, openedWeapon.status)
                        openedWeapon = {
                            serialnumber = "",
                            name = "",
                            type = "",
                            status = "registered"
                        }
                        WarMenu.CloseMenu()
                    else
                        exports.notify:display({
                            type = "warning",
                            title = "Registr zbraní",
                            text = "Musíš zadat všechny položky!",
                            icon = "fas fa-atlas",
                            length = 4500
                        })
                    end

                elseif WarMenu.Button("Smazat ze systému") then
                    TriggerServerEvent("rw:remove", openedWeapon.serialnumber)
                    WarMenu.CloseMenu()
                end
                WarMenu.Display()
            elseif WarMenu.IsMenuOpened("edit_status") then
                for key, value in pairs(Config.status) do
                    if WarMenu.Button((key == openedWeapon.status and "~b~" or "") .. value) then
                        openedWeapon.status = key
                    end
                end
                WarMenu.Display()
            else
                openedWeapon = {
                    serialnumber = "",
                    name = "",
                    type = "",
                    status = "registered"
                }
                break
            end
            Citizen.Wait(0)
        end
    else
        exports.notify:display({
            type = "warning",
            title = "Registr zbraní",
            text = "Zbraň není v systému registrována!",
            icon = "fas fa-atlas",
            length = 5000
        })
        WarMenu.CreateMenu("addtoregister", "REGISTR ZBRANÍ", "")
        WarMenu.OpenMenu("addtoregister")

        WarMenu.CreateSubMenu("register_actions", "addtoregister", "")

        while WarMenu.IsMenuOpened("addtoregister") do
            if WarMenu.Button("Registrovat zbraň") then
                WarMenu.CloseMenu()
                TriggerEvent("util:closestPlayer", {
                    radius = 4.0
                }, function(player)
                    if player then
                        openAddNewWeapon(player)
                    end
                end)
            end
            WarMenu.Display()
            Citizen.Wait(0)
        end
    end
end)

function openAddNewWeapon(selectedPlayer)
    WarMenu.CreateMenu("register_actions", "REGISTR ZBRANÍ", "")
    WarMenu.OpenMenu("register_actions")

    while WarMenu.IsMenuOpened("register_actions") do
        if WarMenu.Button("Seriové číslo: ~b~" .. openedWeapon.serialnumber) then

        elseif WarMenu.Button("Model zbraně: ~b~" .. openedWeapon.type) then
            exports.input:openInput("text", {
                title = "Zadejte typ zbraně",
                placeholder = ""
            }, function(type)
                if type then
                    openedWeapon.type = type
                end
            end)
        elseif WarMenu.Button("Odeslat do systému") then
            if openedWeapon.serialnumber ~= "" and openedWeapon.type ~= "" then
                TriggerServerEvent("rw:add", openedWeapon.serialnumber, selectedPlayer, openedWeapon.type)
                openedWeapon = {
                    serialnumber = "",
                    type = "",
                    status = "registered"
                }
                WarMenu.CloseMenu()
            else
                exports.notify:display({
                    type = "warning",
                    title = "Registr zbraní",
                    text = "Zadej všechny položky!",
                    icon = "fas fa-atlas",
                    length = 3500
                })
            end
        end
        WarMenu.Display()
        Citizen.Wait(0)
    end
end

function registerWeapon()
    exports.input:openInput("text", {
        title = "Zadejte seriové číslo zbraně",
        value = openedWeapon.serialnumber
    }, function(serialnumber)
        if serialnumber then
            openedWeapon.serialnumber = serialnumber
            TriggerServerEvent("rw:checkSerialnumber", serialnumber)
        end
    end)
end
