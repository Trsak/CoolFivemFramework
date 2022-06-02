local Keys = {
    ["LEFTCTRL"] = 36,
    ["ESC"] = 322,
    ["F1"] = 288,
    ["F2"] = 289,
    ["F3"] = 170,
    ["F5"] = 166,
    ["F6"] = 167,
    ["F7"] = 168,
    ["F8"] = 169,
    ["F9"] = 56,
    ["F10"] = 57,
    ["~"] = 243,
    ["1"] = 157,
    ["2"] = 158,
    ["3"] = 160,
    ["4"] = 164,
    ["5"] = 165,
    ["6"] = 159,
    ["7"] = 161,
    ["8"] = 162,
    ["9"] = 163,
    ["-"] = 84,
    ["="] = 83,
    ["BACKSPACE"] = 177,
    ["TAB"] = 37,
    ["Q"] = 44,
    ["W"] = 32,
    ["E"] = 38,
    ["R"] = 45,
    ["T"] = 245,
    ["Y"] = 246,
    ["U"] = 303,
    ["P"] = 199,
    ["["] = 39,
    ["]"] = 40,
    ["ENTER"] = 18,
    ["CAPS"] = 137,
    ["A"] = 34,
    ["S"] = 8,
    ["D"] = 9,
    ["F"] = 23,
    ["G"] = 47,
    ["H"] = 74,
    ["K"] = 311,
    ["L"] = 182,
    ["LEFTSHIFT"] = 21,
    ["Z"] = 20,
    ["X"] = 73,
    ["C"] = 26,
    ["V"] = 0,
    ["B"] = 29,
    ["N"] = 249,
    ["M"] = 244,
    [","] = 82,
    ["."] = 81,
    ["LEFTALT"] = 19,
    ["SPACE"] = 22,
    ["RIGHTCTRL"] = 70,
    ["HOME"] = 213,
    ["PAGEUP"] = 10,
    ["PAGEDOWN"] = 11,
    ["DELETE"] = 178,
    ["LEFT"] = 174,
    ["RIGHT"] = 175,
    ["TOP"] = 27,
    ["DOWN"] = 173,
    ["NENTER"] = 201,
    ["N4"] = 108,
    ["N5"] = 110,
    ["N6"] = 107,
    ["N+"] = 314,
    ["N-"] = 315,
    ["N7"] = 117,
    ["N8"] = 111,
    ["N9"] = 118,
    ["ARROWUP"] = 172,
    ["ARROWDOWN"] = 173,
    ["ARROWLEFT"] = 174,
    ["ARROWRIGHT"] = 175
}

local isSpawned, isDead = false, false
local binds = {}

Citizen.CreateThread(
    function()
        Citizen.Wait(500)

        exports.chat:addSuggestion("/bindmenu", "Otevře bind menu")

        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
            loadBinds()
        end
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned, isDead, binds = false, false, {}
        elseif status == "spawned" or status == "dead" then
            isDead = (status == "dead")

            if not isSpawned then
                isSpawned = true
                loadBinds()
            end
        end
    end
)

function loadBinds()
    binds = {}
    TriggerServerEvent("bind:loadBinds")
end

RegisterCommand(
    "bindmenu",
    function()
        openBinding()
    end
)

function openBinding()
    if not isDead then
        SendNUIMessage({message = "show"})
        SendNUIMessage({message = "updateBind", binds = binds})
        SetNuiFocus(true, true)
    end
end

function closeBinding()
    SendNUIMessage({message = "hide"})
    SetNuiFocus(false, false)
end

RegisterNetEvent("bind:loadBinds")
AddEventHandler(
    "bind:loadBinds",
    function(bindsLoad)
        binds = bindsLoad

        for i = 1, #binds do
            keyToggle(binds[i].key, true)
            if Keys[binds[i].key] == nil then
                Keys[binds[i].key] = nil
            end
        end
    end
)

RegisterNUICallback(
    "NUIFocusOff",
    function(data, cb)
        closeBinding()
        cb("ok")
    end
)

RegisterNUICallback(
    "addBind",
    function(data, cb)
        if Keys[tostring(data.key)] ~= nil then
            openBindMenu(tostring(data.key))
        end
        cb("ok")
    end
)

RegisterNUICallback(
    "removeBind",
    function(data, cb)
        local key = tostring(data.key)
        for i, bind in each(binds) do
            if bind.key == key then
                table.remove(binds, i)
                keyToggle(key, false)
                exports.notify:display(
                    {
                        type = "success",
                        title = "Bind menu",
                        text = "Bind byl úspěšně odebrán",
                        icon = "fas fa-keyboard",
                        length = 4000
                    }
                )
                break
            end
        end

        SendNUIMessage({message = "updateBind", binds = binds})
        TriggerServerEvent("bind:saveBinds", binds)
        cb("ok")
    end
)

function openBindMenu(currentKey)
    Citizen.CreateThread(
        function()
            local usableItems = nil
            local usableWeapons = nil

            WarMenu.CreateMenu("bind_menu", "Nastavení bindu", "Zvolte, co chcete nabindovat")
            WarMenu.SetMenuY("bind_menu", 0.35)
            WarMenu.OpenMenu("bind_menu")

            while true do
                if WarMenu.IsMenuOpened("bind_menu") then
                    usableItems = nil
                    usableWeapons = nil

                    if WarMenu.Button("Příkaz") then
                        WarMenu.CloseMenu()

                        exports.input:openInput(
                            "text",
                            {title = "Zadejte příkaz"},
                            function(commandToBind)
                                if commandToBind then
                                    local firstChar = string.sub(commandToBind, 1, 1)
                                    if firstChar == "/" then
                                        commandToBind = string.sub(commandToBind, 2)
                                    end

                                    addBind(currentKey, "command", commandToBind)
                                else
                                    openBindMenu(currentKey)
                                end
                            end
                        )
                    elseif WarMenu.Button("Předmět nebo zbraň") then
                        WarMenu.CloseMenu()
                        exports.inventory:openInventory(currentKey)
                    end

                    WarMenu.Display()
                else
                    break
                end

                Citizen.Wait(0)
            end
        end
    )
end

function addBind(key, type, value)
    local found = false

    for _, bind in each(binds) do
        if bind.key == key then
            found = true
            bind.type = type
            bind.value = value
            break
        end
    end

    if not found then
        table.insert(binds, {key = key, type = type, value = value})
    end

    keyToggle(key, true)
    exports.notify:display(
        {
            type = "success",
            title = "Bind menu",
            text = "Bind byl úspěšně nastaven",
            icon = "fas fa-keyboard",
            length = 4000
        }
    )
    TriggerServerEvent("bind:saveBinds", binds)
end

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(1)
            for _, bind in each(binds) do
                DisableControlAction(0, Keys[bind.key], true)
            end

            if IsDisabledControlPressed(0, 37) then
                EnableControlAction(0, 37, true)
            end
        end
    end
)

local forceWheel = false
local pressedCtrl = false

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(1)
            pressedCtrl = false

            for i, bind in each(binds) do
                if IsDisabledControlJustPressed(0, Keys[bind.key]) and not pressedCtrl and not IsPauseMenuActive() then
                    if Keys[bind.key] == 36 then
                        pressedCtrl = true
                    end

                    if bind.type == "command" then
                        ExecuteCommand(bind.value)
                    elseif bind.type == "item" or bind.type == "weapon" then
                        exports.inventory:tryToUseItem(bind.value, true)
                    end
                end
            end
        end
    end
)

function keyToggle(key, toggle)
    if key == "1" or key == "2" or key == "3" or key == "4" or key == "5" then
        exports.inventory:setBindOverwritten(tonumber(key), toggle)
    end
end
