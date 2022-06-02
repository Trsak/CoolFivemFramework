local koilDebug = false
local vehicleDebug = false
local coordsDebug = false

Citizen.CreateThread(
    function()
        while not exports.data:isUserLoaded() do
            Citizen.Wait(500)
        end

        if exports.data:getUserVar("admin") >0 then
            createNewKeyMapping({command = "adminmenu", text = "Admin menu", key = "F11"})
        end
    end
)

RegisterNetEvent("admin:dev:koil-debug")
AddEventHandler(
    "admin:dev:koil-debug",
    function(isOpen)
        koilDebug = isOpen
    end
)

RegisterNetEvent("admin:dev:vehicles")
AddEventHandler(
    "admin:dev:vehicles",
    function(isOpen)
        vehicleDebug = isOpen
    end
)

RegisterCommand(
    "adminmenu",
    function(source, args)
        if exports.data:getUserVar("admin") > 0 then
            if not WarMenu.IsAnyMenuOpened() then
                TriggerServerEvent("admin:openMenu", args[1])
            end
        else
            TriggerEvent(
                "chat:addMessage",
                {
                    templateId = "error",
                    args = {"Na toto nemáš právo!"}
                }
            )
        end
    end,
    false
)

RegisterNetEvent("admin:openMenu")
AddEventHandler(
    "admin:openMenu",
    function(playersData, targetPlayer)

        Citizen.CreateThread(
            function()
                WarMenu.CreateMenu("admin", "Admin menu", "Zvolte akci")
                WarMenu.SetMenuY("admin", 0.35)

                WarMenu.CreateSubMenu("admin_players", "admin", "Zvolte hráče")
                WarMenu.CreateSubMenu("admin_timeweather", "admin", "Zvolte akci")
                WarMenu.CreateSubMenu("admin_dev", "admin", "Zvolte akci")
                WarMenu.CreateSubMenu("admin_players_action", "admin_players", "Zvolte akci")
                WarMenu.CreateSubMenu("admin_players_action_ban", "admin_players_action", "Zvolte délku banu")

                if targetPlayer == nil or tonumber(targetPlayer) == nil then
                    WarMenu.OpenMenu("admin")
                else
                    WarMenu.OpenMenu("admin_players_action")
                    selectedPlayer = tonumber(targetPlayer)
                end

                while true do
                    if WarMenu.IsMenuOpened("admin") then
                        if WarMenu.MenuButton("Spravovat hráče", "admin_players") then
                        elseif WarMenu.MenuButton("Spravovat čas a počasí", "admin_timeweather") then
                        elseif WarMenu.Button("Mechanik menu") then
                            WarMenu.CloseMenu()
                            exports.mechanicmenu:openMechanicMenu({value = "main", job = "admin"})
                        elseif WarMenu.Button("Ped menu") then
                            WarMenu.CloseMenu()
                            TriggerEvent("admin:skinmenu")
                        elseif WarMenu.Button("Clear Area") then
                            ExecuteCommand("cleararea")
                        end
                        if exports.data:getUserVar("admin") > 1 then
                            if WarMenu.MenuButton("Nástroje pro devy", "admin_dev") then
                            end
                        end
                        if WarMenu.Button("Char select") then
                            WarMenu.CloseMenu()
                            ExecuteCommand("charselect")
                        end

                        WarMenu.Display()
                    elseif WarMenu.IsMenuOpened("admin_dev") then
                        local stateKoilDebug = (koilDebug and "Vypnout" or "Zapnout")
                        local stateVehicleDebug = (vehicleDebug and "Vypnout" or "Zapnout")
                        local stateCoordsDebug = (coordsDebug and "Vypnout" or "Zapnout")

                        if WarMenu.Button(stateKoilDebug .. " koil debug") then
                            TriggerEvent("koil-debug:toggleDebug")
                        elseif WarMenu.Button(stateVehicleDebug .. " vehicle debug") then
                            WarMenu.CloseMenu()
                            TriggerEvent("vehicle-debug:toggleDebug")
                        elseif WarMenu.Button(stateCoordsDebug .. " zobrazování souřadnic") then
                            WarMenu.CloseMenu()
                            coordsDebug = not coordsDebug
                            exports.coords:toggleCoords()
                        end

                        WarMenu.Display()
                    elseif WarMenu.IsMenuOpened("admin_timeweather") then
                        if WarMenu.Button("Nastavit čas") then
                            exports.input:openInput(
                                "number",
                                {title = "Zadejte hodiny", placeholder = ""},
                                function(hours)
                                    if hours then
                                        exports.input:openInput(
                                            "number",
                                            {title = "Zadejte minuty", placeholder = ""},
                                            function(minutes)
                                                if minutes then
                                                    WarMenu.CloseMenu()
                                                    ExecuteCommand("time " .. hours .. " " .. minutes)
                                                end
                                            end
                                        )
                                    end
                                end
                            )
                        elseif WarMenu.Button("Pozastavení času") then
                            ExecuteCommand("freezetime")
                        elseif WarMenu.Button("Nastavit fixní počasí") then
                            exports.input:openInput(
                                "text",
                                {title = "Zadejte nové počasí", placeholder = ""},
                                function(weather)
                                    if weather then
                                        WarMenu.CloseMenu()
                                        ExecuteCommand("weather " .. weather)
                                    end
                                end
                            )
                        elseif WarMenu.Button("Zrušit nastavené počasí") then
                            ExecuteCommand("weatherrestore")
                        end

                        WarMenu.Display()
                    elseif WarMenu.IsMenuOpened("admin_players") then
                        table.sort(playersData, sortPlayers)

                        for _, player in each(playersData) do
                            if WarMenu.MenuButton("[" .. player.source .. "] " .. player.name, "admin_players_action") then
                                selectedPlayer = player.source
                            end
                        end

                        WarMenu.Display()
                    elseif WarMenu.IsMenuOpened("admin_players_action") then
                        if WarMenu.Button("Zobrazit informace") then
                            WarMenu.CloseMenu()
                            TriggerServerEvent("admin:getUserData", selectedPlayer)
                        elseif WarMenu.Button("Zmrazit / Odmrazit hráče") then
                            TriggerServerEvent("admin:freezePlayer", selectedPlayer)
                        elseif WarMenu.Button("Uzdravit hráče") then
                            ExecuteCommand("heal " .. selectedPlayer)
                        elseif WarMenu.Button("Doplnit hráči jídlo a pití") then
                            ExecuteCommand("needs " .. selectedPlayer)
                        elseif WarMenu.Button("Otevřít hráčův inventář") then
                            ExecuteCommand("openinventory " .. selectedPlayer)
                        elseif WarMenu.Button("Sledovat hráče") then
                            ExecuteCommand("spectate " .. selectedPlayer)
                        elseif WarMenu.Button("Teleportovat se k hráči") then
                            TriggerServerEvent("admin:teleportPlayers", GetPlayerServerId(PlayerId()), selectedPlayer)
                        elseif WarMenu.Button("Teleportovat hráče k sobě") then
                            TriggerServerEvent("admin:teleportPlayers", selectedPlayer, GetPlayerServerId(PlayerId()))
                        elseif WarMenu.Button("Vyfotit hráče") then
                            ExecuteCommand("screenshot " .. selectedPlayer)
                        elseif WarMenu.Button("Vyhodit hráče") then
                            exports.input:openInput(
                                "text",
                                {title = "Zadejte důvod vyhození", placeholder = ""},
                                function(kickReason)
                                    if kickReason then
                                        WarMenu.CloseMenu()
                                        ExecuteCommand("kick " .. selectedPlayer .. " " .. kickReason)
                                    end
                                end
                            )
                        elseif WarMenu.MenuButton("Zabanovat hráče", "admin_players_action_ban") then
                        end

                        WarMenu.Display()
                    elseif WarMenu.IsMenuOpened("admin_players_action_ban") then
                        local sortedBans = {}

                        for length, data in pairs(Config.banLengths) do
                            table.insert(sortedBans, data)
                        end
                        table.sort(sortedBans, sortBanLengths)

                        for _, data in each(sortedBans) do
                            if WarMenu.Button(data.label) then
                                exports.input:openInput(
                                    "text",
                                    {title = "Zadejte důvod banu", placeholder = ""},
                                    function(kickReason)
                                        if kickReason then
                                            WarMenu.CloseMenu()
                                            ExecuteCommand(
                                                "ban " ..
                                                    selectedPlayer ..
                                                        " " .. getBanKeyByMinutes(data.minutes) .. " " .. kickReason
                                            )
                                        end
                                    end
                                )
                            end
                        end

                        WarMenu.Display()
                    else
                        inMenu = false
                        break
                    end

                    Citizen.Wait(0)
                end
                inMenu = false
            end
        )
    end
)

RegisterNetEvent("admin:getUserData")
AddEventHandler(
    "admin:getUserData",
    function(player, admin, status, charData)
        Citizen.CreateThread(
            function()
                WarMenu.CreateMenu(
                    "admin_player_info",
                    "[" .. player.source .. "] " .. player.nickname,
                    "Informace o hráči"
                )
                WarMenu.SetMenuY("admin_player_info", 0.35)
                WarMenu.OpenMenu("admin_player_info")

                while true do
                    if WarMenu.IsMenuOpened("admin_player_info") then
                        WarMenu.Button("----- Informace o hráči")

                        WarMenu.Button("Status: " .. getStatusText(status))
                        WarMenu.Button("Práva: " .. getPermissionsText(admin))

                        if status == "spawned" or status == "dead" then
                            if WarMenu.Button("----- Informace o postavě") then
                                WarMenu.CloseMenu()
                                openCharData(player.source)
                            end
                            if WarMenu.Button("Jméno postavy: " .. charData.firstname .. " " .. charData.lastname) then
                                WarMenu.CloseMenu()
                                openCharData(player.source)
                            end
                        end

                        WarMenu.Display()
                    else
                        WarMenu.CloseMenu()
                        break
                    end

                    Citizen.Wait(0)
                end
            end
        )
    end
)

function openCharData(target)
    if exports.data:getUserVar("admin") < 2 then
        return
    end

    TriggerServerEvent("admin:charData", target)
end

RegisterNetEvent("admin:charData")
AddEventHandler("admin:charData",
function(data)
    if exports.data:getUserVar("admin") < 2 then
        return
    end

    if not data then
        print("CHYBA V DATECH")
        return
    end

    WarMenu.CreateMenu(
        "admin_char_info",
        data.firstname .. " " .. data.lastname,
        "ID: " .. data.source
    )
    WarMenu.SetMenuY("admin_char_info", 0.35)
    WarMenu.OpenMenu("admin_char_info")

    Citizen.CreateThread(
        function()
            while true do
                if WarMenu.IsMenuOpened("admin_char_info") then
                    WarMenu.Button("CHAR ID", data.id)
                    WarMenu.Button("FIRSTNAME", data.firstname)
                    WarMenu.Button("LASTNAME", data.lastname)
                    WarMenu.Button("DOB", data.birth)
                    WarMenu.Button("SEX", (data.sex == 0 and "MALE" or "FEMALE"))

                    WarMenu.Button("STATUS", data.status)
                    WarMenu.Button("HP", data.health)
                    WarMenu.Button("ARMOUR", data.armour)

                    if data.jobs then
                        WarMenu.Button("JOBS")
                        for _, v in pairs(data.jobs) do
                            WarMenu.Button("            " .. v.job .. (v.duty and " [ ON ]" or ""), v.job_grade)
                        end
                    else
                        WarMenu.Button("JOB", "UNEMPLOYED")
                    end

                    if data.skills then
                        WarMenu.Button("SKILLS")
                        for k, v in pairs(data.skills) do
                            WarMenu.Button("            " .. k, v)
                        end
                    else
                        WarMenu.Button("SKILLS", "WTF")
                    end

                    WarMenu.Display()
                else
                    WarMenu.CloseMenu()
                    break
                end

                Citizen.Wait(0)
            end
        end
    )
end)

function sortPlayers(a, b)
    return a.source < b.source
end
