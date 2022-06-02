local playerSettings = Config.DefaultSettings
local isSpawned = false
local isMovieModActive, isCinematicCamDisabled = false, false
local isWeaponMeleeAttackDisabled = true

local UI = {
    x = 0.000,
    y = -0.001
}

Citizen.CreateThread(
    function()
        Citizen.Wait(500)

        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            loadPlayerSettings()
            isSpawned = true
            isMovieModActive = getSettingValue("moviemod")
            isCinematicCamDisabled = getSettingValue("disableCinCam")
            isWeaponMeleeAttackDisabled = getSettingValue("disableMeleeAttack")

            DisableIdleCamera(isCinematicCamDisabled)
            while isWeaponMeleeAttackDisabled do
                Citizen.Wait(0)
                if isSpawned and not isDead and IsPedArmed(PlayerPedId(), 6) then
                    DisableControlAction(1, 140, true)
                    DisableControlAction(1, 141, true)
                    DisableControlAction(1, 142, true)
                end
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
        elseif not isSpawned and (status == "spawned" or status == "dead") then
            loadPlayerSettings()
            isSpawned = true
        end
    end
)

AddEventHandler(
    "settings:changed",
    function(setting, value)
        if setting == "moviemod" then
            isMovieModActive = value
            if isMovieModActive then
                while isMovieModActive do
                    Citizen.Wait(1)
                    HideHUDThisFrame()
                    drawRct(UI.x + 0.0, UI.y + 0.0, 1.0, 0.15, 0, 0, 0, 255) -- Top Bar
                    drawRct(UI.x + 0.0, UI.y + 0.85, 1.0, 0.151, 0, 0, 0, 255) -- Bottom Bar
                end
            end
        elseif setting == "disableCinCam" then
            isCinematicCamDisabled = value
            DisableIdleCamera(value)
        elseif setting == "disableMeleeAttack" then
            isWeaponMeleeAttackDisabled = value
            while isWeaponMeleeAttackDisabled do
                Citizen.Wait(0)
                if isSpawned and not isDead and IsPedArmed(PlayerPedId(), 6) then
                    DisableControlAction(1, 140, true)
                    DisableControlAction(1, 141, true)
                    DisableControlAction(1, 142, true)
                end
            end
        end
    end
)

function loadPlayerSettings()
    local playerLoadedSettings = exports.data:getUserVar("settings")

    if playerLoadedSettings then
        for setting, value in pairs(playerLoadedSettings) do
            playerSettings[setting] = value
            TriggerEvent("settings:changed", setting, value)
        end
    end

    TriggerServerEvent("settings:update", playerSettings)
end

function openSettings()
    local admin = exports.data:getUserVar("admin")
    WarMenu.CreateMenu("settings", "Nastavení", "Změna nastavení")
    WarMenu.OpenMenu("settings")
    WarMenu.SetMenuY("settings", 0.35)

    WarMenu.CreateSubMenu("settings_ui", "settings", "Nastavení uživatelského prostředí")
    WarMenu.CreateSubMenu("status_bars_ui", "settings", "Nastavení status barů")
    WarMenu.CreateSubMenu("map_ui", "settings", "Nastavení mapy")

    while true do
        if WarMenu.IsMenuOpened("settings") then
            if WarMenu.Button("Otevřít Bind menu") then
                WarMenu.CloseMenu()
                exports.bind:openBinding()
            elseif WarMenu.MenuButton("Nastavení uživatelského prostředí", "settings_ui") then
            elseif WarMenu.MenuButton("Nastavení mapy", "map_ui") then
            elseif WarMenu.MenuButton("Nastavení status barů", "status_bars_ui") then
            elseif WarMenu.CheckBox("Výpis /me do chatu", playerSettings["me"]) then
                changeSetting("me", not playerSettings["me"])
            elseif WarMenu.CheckBox("Výpis /do do chatu", playerSettings["do"]) then
                changeSetting("do", not playerSettings["do"])
            elseif WarMenu.CheckBox("Výpis /doc do chatu", playerSettings["doc"]) then
                changeSetting("doc", not playerSettings["doc"])
            elseif WarMenu.CheckBox("Jméno postavy u /me a /do", playerSettings["chatCharName"]) then
                changeSetting("chatCharName", not playerSettings["chatCharName"])
            elseif WarMenu.CheckBox("Vypnou možnost útočit pažbou", playerSettings["disableMeleeAttack"]) then
                changeSetting("disableMeleeAttack", not playerSettings["disableMeleeAttack"])
            end

            WarMenu.Display()
        elseif WarMenu.IsMenuOpened("status_bars_ui") then
            if WarMenu.CheckBox("Zobrazit voice bar", playerSettings["uiStatusMicrophone"]) then
                changeSetting("uiStatusMicrophone", not playerSettings["uiStatusMicrophone"])
            elseif
                WarMenu.Button(
                    "Zobrazení životů (pokud je menší nebo rovno)",
                    tostring(playerSettings["uiStatusHealth"])
                )
             then
                changePercentSetting("uiStatusHealth")
            elseif
                WarMenu.Button(
                    "Zobrazení vesty (pokud je větší nebo rovno)",
                    tostring(playerSettings["uiStatusArmour"])
                )
             then
                changePercentSetting("uiStatusArmour")
            elseif
                WarMenu.Button(
                    "Zobrazení hladu (pokud je menší nebo rovno)",
                    tostring(playerSettings["uiStatusHunger"])
                )
             then
                changePercentSetting("uiStatusHunger")
            elseif
                WarMenu.Button(
                    "Zobrazení žízně (pokud je menší nebo rovno)",
                    tostring(playerSettings["uiStatusThirst"])
                )
             then
                changePercentSetting("uiStatusThirst")
            elseif
                WarMenu.Button(
                    "Zobrazení staminy (pokud je menší nebo rovno)",
                    tostring(playerSettings["uiStatusStamina"])
                )
             then
                changePercentSetting("uiStatusStamina")
            elseif
                WarMenu.Button(
                    "Zobrazení kyslíku (pokud je menší nebo rovno)",
                    tostring(playerSettings["uiStatusOxygen"])
                )
             then
                changePercentSetting("uiStatusOxygen")
            elseif
                WarMenu.Button(
                    "Zobrazení stresu (pokud je větší nebo rovno)",
                    tostring(playerSettings["uiStatusStress"])
                )
             then
                changePercentSetting("uiStatusStress")
            elseif
                WarMenu.Button(
                    "Zobrazení opilosti (pokud je větší nebo rovno)",
                    tostring(playerSettings["uiStatusDrunk"])
                )
             then
                changePercentSetting("uiStatusDrunk")
            end

            WarMenu.Display()
        elseif WarMenu.IsMenuOpened("settings_ui") then
            if WarMenu.Button("Promazat chat (/clear)") then
                ExecuteCommand("clear")
            end

            WarMenu.ComboBox(
                "Zobrazování chatu",
                Config.ChatOptions,
                playerSettings["chat"],
                playerSettings["chat"],
                function(currentIndex, selectedIndex)
                    if playerSettings["chat"] ~= currentIndex then
                        playerSettings["chat"] = currentIndex
                        changeSetting("chat", currentIndex)
                    end
                end
            )
            if WarMenu.CheckBox("Skrýt informace ve vozidle (/hidehud)", playerSettings["hidehud"]) then
                changeSetting("hidehud", not playerSettings["hidehud"])
            elseif WarMenu.CheckBox("Skrýt status bary (/hidebars)", playerSettings["hidebars"]) then
                changeSetting("hidebars", not playerSettings["hidebars"])
            elseif WarMenu.CheckBox("Skrýt minimapu (/hidemap)", playerSettings["hidemap"]) then
                changeSetting("hidemap", not playerSettings["hidemap"])
            elseif WarMenu.CheckBox("Movie mod (/moviemod)", playerSettings["moviemod"]) then
                changeSetting("moviemod", not playerSettings["moviemod"])
            elseif admin > 1 and WarMenu.CheckBox("Streamer Mode", playerSettings["streamerMode"]) then
                changeSetting("streamerMode", not playerSettings["streamerMode"])
            elseif WarMenu.CheckBox("Zobrazovat postal code", playerSettings["postalcode"]) then
                changeSetting("postalcode", not playerSettings["postalcode"])
            elseif WarMenu.CheckBox("Vypnout cinematic kameru", playerSettings["disableCinCam"]) then
                changeSetting("disableCinCam", not playerSettings["disableCinCam"])
            elseif WarMenu.CheckBox("Zobrazení aktuální pozice ve vozidle nahoře", playerSettings["uiAzimutTop"]) then
                changeSetting("uiAzimutTop", not playerSettings["uiAzimutTop"])
            end

            WarMenu.Display()
        elseif WarMenu.IsMenuOpened("map_ui") then
            if WarMenu.CheckBox("Blipy všech garáží", playerSettings["allGarageBlips"]) then
                changeSetting("allGarageBlips", not playerSettings["allGarageBlips"])
            elseif WarMenu.CheckBox("Blipy Barber Shopů", playerSettings["barberBlips"]) then
                changeSetting("barberBlips", not playerSettings["barberBlips"])
            elseif WarMenu.CheckBox("Blipy obchodů s oblečením", playerSettings["clothesBlips"]) then
                changeSetting("clothesBlips", not playerSettings["clothesBlips"])
            elseif WarMenu.CheckBox("Blipy všech benzínek", playerSettings["gasBlips"]) then
                changeSetting("gasBlips", not playerSettings["gasBlips"])
            elseif WarMenu.CheckBox("Blipy tetovacích salónů", playerSettings["tatoosBlips"]) then
                changeSetting("tatoosBlips", not playerSettings["tatoosBlips"])
            elseif WarMenu.CheckBox("Blipy obchodů", playerSettings["shopsBlips"]) then
                changeSetting("shopsBlips", not playerSettings["shopsBlips"])
            elseif WarMenu.CheckBox("Blipy nemovitostí", playerSettings["propertyBlips"]) then
                changeSetting("propertyBlips", not playerSettings["propertyBlips"])
            elseif WarMenu.CheckBox("Blipy podniků (bary, kavárny, úřad...)", playerSettings["jobBlips"]) then
                changeSetting("jobBlips", not playerSettings["jobBlips"])
            elseif WarMenu.CheckBox("Blipy bank", playerSettings["bankBlips"]) then
                changeSetting("bankBlips", not playerSettings["bankBlips"])
            elseif WarMenu.CheckBox("Blipy brigád", playerSettings["brigadeBlips"]) then
                changeSetting("brigadeBlips", not playerSettings["brigadeBlips"])
            end

            WarMenu.Display()
        else
            WarMenu.CloseMenu()
            break
        end

        Citizen.Wait(0)
    end
end

function changePercentSetting(settingName)
    exports.input:openInput(
        "number",
        {title = "Zadejte hodnotu v procentech", placeholder = "0 - 100"},
        function(percentageValue)
            if percentageValue == nil then
                exports.notify:display(
                    {
                        type = "error",
                        title = "Chyba",
                        text = "Musíš zadat procentuální hodnotu!",
                        icon = "fas fa-times",
                        length = 3500
                    }
                )
            else
                percentageValue = tonumber(percentageValue)
                if percentageValue == nil or percentageValue < 0 or percentageValue > 100 then
                    exports.notify:display(
                        {
                            type = "error",
                            title = "Chyba",
                            text = "Musíš zadat procentuální hodnotu (0 - 100)!",
                            icon = "fas fa-times",
                            length = 3500
                        }
                    )
                else
                    playerSettings[settingName] = percentageValue
                    TriggerEvent("settings:changed", settingName, percentageValue)
                    TriggerServerEvent("settings:update", playerSettings)
                end
            end
        end
    )
end

function changeSetting(settingName, value)
    playerSettings[settingName] = value
    TriggerEvent("settings:changed", settingName, playerSettings[settingName])
    TriggerServerEvent("settings:update", playerSettings)
end

function getSettingValue(settingName)
    return playerSettings[settingName]
end

RegisterCommand(
    "moviemod",
    function(source, args)
        changeSetting("moviemod", not playerSettings["moviemod"])
    end
)

RegisterCommand(
    "hidemap",
    function(source, args)
        changeSetting("hidemap", not playerSettings["hidemap"])
    end
)

RegisterCommand(
    "hidehud",
    function(source, args)
        changeSetting("hidehud", not playerSettings["hidehud"])
    end
)

RegisterCommand(
    "hidebars",
    function(source, args)
        changeSetting("hidebars", not playerSettings["hidebars"])
    end
)

function drawRct(x, y, width, height, r, g, b, a)
    DrawRect(x + width / 2, y + height / 2, width, height, r, g, b, a)
end

function HideHUDThisFrame()
    HideHelpTextThisFrame()
    HideHudAndRadarThisFrame()
    HideHudComponentThisFrame(1)
    HideHudComponentThisFrame(2)
    HideHudComponentThisFrame(3)
    HideHudComponentThisFrame(4)
    HideHudComponentThisFrame(6)
    HideHudComponentThisFrame(7)
    HideHudComponentThisFrame(8)
    HideHudComponentThisFrame(9)
    HideHudComponentThisFrame(13)
    HideHudComponentThisFrame(11)
    HideHudComponentThisFrame(12)
    HideHudComponentThisFrame(15)
    HideHudComponentThisFrame(18)
    HideHudComponentThisFrame(19)
end

RegisterCommand(
    "settings",
    function()
        if not WarMenu.IsAnyMenuOpened() then
            openSettings()
        end
    end
)
createNewKeyMapping({command = "settings", text = "Nastavení", key = "F7"})
