local radioChannel = nil
local radioMenu = false
local prop = "prop_cs_hand_radio"
local propHandle = nil

local Dictionary = {
    "cellphone@",
    "cellphone@in_car@ds",
    "cellphone@str",
    "random@arrests"
}
local Animation = {
    "cellphone_text_in",
    "cellphone_text_out",
    "cellphone_call_listen_a",
    "generic_radio_chatter"
}

Citizen.CreateThread(
    function()
        Citizen.Wait(500)

        exports.chat:addSuggestion(
            "/frekvence",
            "Nastaví frekvenci vysílačky",
            {
                { name = "frekvence", help = "Číslo frekvence" }
            }
        )

        exports.chat:addSuggestion(
            "/frequence",
            "Nastaví frekvenci vysílačky",
            {
                { name = "frekvence", help = "Číslo frekvence" }
            }
        )

        exports.chat:addSuggestion(
            "/radiovolume",
            "Nastaví hlasitost vysílačky",
            {   
                {name = "hlasitost",help = "0-100"}
            }
        )

        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            isSpawned = true
            isDead = (status == "dead")
            loadJobs()
            if isDead then
                closeOnDeath()
            end

            SendNUIMessage(
                {
                    type = "volume",
                    volume = exports["pma-voice"]:getRadioVolume("radio")
                }
            )
        end

        while true do
            if radioChannel and not exports.inventory:checkTransmitter() then
                leaveRadio()
            end
            Citizen.Wait(1000)
        end
    end
)

Citizen.CreateThread(
    function()

        while true do
            Citizen.Wait(0)
            if radioMenu then
                DisableControlAction(0, 1, true)
                DisableControlAction(0, 2, true)
                DisableControlAction(0, 3, true)
                DisableControlAction(0, 4, true)
                DisableControlAction(0, 5, true)
                DisableControlAction(0, 6, true)
                DisableControlAction(1, 18, true)
                DisableControlAction(1, 24, true)
                DisableControlAction(1, 25, true)
                DisableControlAction(1, 68, true)
                DisableControlAction(1, 69, true)
                DisableControlAction(1, 70, true)
                DisableControlAction(0, 177, true)
                DisableControlAction(0, 200, true)
                DisableControlAction(0, 202, true)
            end
        end
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned, isDead = false, false
            if radioChannel then
                leaveRadio()
            end
        elseif status == "spawned" or status == "dead" then
            isDead = (status == "dead")
            if not isSpawned then
                isSpawned = true
                loadJobs()
            elseif isDead then
                closeOnDeath()
            end
        end
    end
)

RegisterCommand('frekvence', function(source, args)
    joinRadio(args[1])
end)

RegisterCommand('frequence', function(source, args)
    joinRadio(args[1])
end)

RegisterCommand('radiovolume',function (source, args)
    SendNUIMessage( {
        type = "volume",
        volume = args[1]
    })
end)

RegisterNetEvent("s:jobUpdated")
AddEventHandler(
    "s:jobUpdated",
    function(newJobs)
        loadJobs(newJobs)
        if radioChannel and tonumber(radioChannel) <= Config.RestrictedChannels then
            if not isAllowed() then
                leaveRadio()
            end
        end
    end
)

function enableRadio(enable)
    radioMenu = enable

    SendNUIMessage(
        {
            type = "enableui",
            enable = enable
        }
    )

    SetNuiFocus(enable, enable)
    if enable then
        SetNuiFocusKeepInput(true)
    else
        SetNuiFocusKeepInput(false)
    end

    local playerPed = PlayerPedId()
    local dictionaryType = 1 + (IsPedInAnyVehicle(playerPed, false) and 1 or 0)
    local animationType = 1 + (radioMenu and 0 or 1)
    local dictionary = Dictionary[dictionaryType]
    local animation = Animation[animationType]

    while not HasAnimDictLoaded(dictionary) do
        RequestAnimDict(dictionary)
        Citizen.Wait(150)
    end

    if enable then
        if not IsPedInAnyVehicle(playerPed, true) then
            local model = GetHashKey(prop)
            RequestModel(model)
            while (not HasModelLoaded(model)) do
                Citizen.Wait(1)
            end

            local coords = GetEntityCoords(playerPed)
            propHandle = CreateObject(model, coords, true, true, false)
            local bone = GetPedBoneIndex(playerPed, 28422)

            SetCurrentPedWeapon(playerPed, "weapon_unarmed", true)
            AttachEntityToEntity(
                propHandle,
                playerPed,
                bone,
                0.0,
                0.0,
                0.0,
                0.0,
                0.0,
                0.0,
                true,
                false,
                false,
                false,
                2,
                true
            )

            SetEntityCollision(propHandle, false, true)
            SetModelAsNoLongerNeeded(model)
            TaskPlayAnim(playerPed, dictionary, animation, 4.0, -1, -1, 50, 0, false, false, false)
        end
    elseif propHandle then
        while not DoesEntityExist(propHandle) do
            Citizen.Wait(200)
        end
        local playerPed = PlayerPedId()
        TaskPlayAnim(playerPed, dictionary, animation, 4.0, -1, -1, 50, 0, false, false, false)

        Citizen.Wait(700)

        StopAnimTask(playerPed, dictionary, animation, 1.0)

        NetworkRequestControlOfEntity(propHandle)
        local count = 0
        while not NetworkHasControlOfEntity(propHandle) and count < 5000 do
            Citizen.Wait(0)
            count = count + 1
        end

        DetachEntity(propHandle, true, false)
        DeleteEntity(propHandle)
        propHandle = nil
    end
end

RegisterNUICallback(
    "joinRadio",
    function(data, cb)
        joinRadio(data.channel)
        cb("ok")
    end
)

function joinRadio(channel)
    if not exports.inventory:checkTransmitter() then
        exports.notify:display(
            {
                type = "error",
                title = "Vysílačka",
                text = "K tomu potřebuješ mít vysílačku!",
                icon = "fas fa-headset",
                length = 4000
            }
        )
        return
    end

    if channel == nil or tonumber(channel) == nil then
        if radioChannel then
            leaveRadio()
        end

        return
    end

    if not radioChannel or tonumber(channel) ~= tonumber(radioChannel) then
        if tonumber(channel) <= Config.RestrictedChannels then
            if isAllowed() then
                if radioChannel then
                    exports["pma-voice"]:removePlayerFromRadio()
                end

                radioChannel = tonumber(channel)
                exports["pma-voice"]:setVoiceProperty("radioEnabled", true)
                exports["pma-voice"]:setRadioChannel(tonumber(channel))
                exports.notify:display(
                    {
                        type = "success",
                        title = "Vysílačka",
                        text = "Připojil jsi se na frekvenci " .. channel .. ".00 MHz",
                        icon = "fas fa-headset",
                        length = 4000
                    }
                )
            elseif not isAllowed() then
                exports.notify:display(
                    {
                        type = "error",
                        title = "Vysílačka",
                        text = "Na zadanou frekvenci se nelze připojit kvůli šifrování!",
                        icon = "fas fa-headset",
                        length = 4000
                    }
                )
            end
        elseif tonumber(channel) > Config.RestrictedChannels then
            if radioChannel then
                exports["pma-voice"]:removePlayerFromRadio()
            end

            radioChannel = tonumber(channel)
            exports["pma-voice"]:setVoiceProperty("radioEnabled", true)
            exports["pma-voice"]:setRadioChannel(tonumber(channel))
            exports.notify:display(
                {
                    type = "success",
                    title = "Vysílačka",
                    text = "Připojil jsi se na frekvenci " .. channel .. ".00 MHz",
                    icon = "fas fa-headset",
                    length = 4000
                }
            )
        end
    else
        exports.notify:display(
            {
                type = "info",
                title = "Vysílačka",
                text = "Tvoje aktuální frekvence je " .. channel .. ".00 MHz",
                icon = "fas fa-headset",
                length = 4000
            }
        )
    end
end

RegisterNUICallback(
    "leaveRadio",
    function(data, cb)
        leaveRadio()

        cb("ok")
    end
)

RegisterNUICallback(
    "escape",
    function(data, cb)
        enableRadio(false)
        SetNuiFocus(false, false)
        cb("ok")
    end
)

RegisterNUICallback(
    "changeRadioVolume",
    function(data, cb)
        if data.volume then
            volume = tonumber(data.volume)
            exports["pma-voice"]:setRadioVolume(volume --[[/ 100.0 ~= 1 and data.volume / 100 or 1.0]])
            cb("ok")
            exports.notify:display(
                {
                    type = "success",
                    title = "Vysílačka",
                    text = "Změnil si hlasitost na: " .. volume,
                    icon = "fas fa-headset",
                    length = 2500
                })
        else
            exports.notify:display({
                type = "error",
                title = "Vysílačka",
                text = "Nepodařilo se změnit hlasitost",
                icon = "fas fa-headset",
                length = 2500
            })
        end
    end
)

function leaveRadio()
    if not radioChannel then
        exports.notify:display(
            {
                type = "error",
                title = "Vysílačka",
                text = "Aktuálně nejsi připojen k žádné frekvenci",
                icon = "fas fa-headset",
                length = 4000
            }
        )
    else
        exports["pma-voice"]:setVoiceProperty("radioEnabled", false)
        exports["pma-voice"]:removePlayerFromRadio()
        exports.notify:display(
            {
                type = "error",
                title = "Vysílačka",
                text = "Opustil jsi frekvenci " .. radioChannel .. ".00 MHz",
                icon = "fas fa-headset",
                length = 4000
            }
        )
        radioChannel = nil
        SendNUIMessage(
            {
                type = "clear"
            }
        )
    end
end

function closeOnDeath()
    enableRadio(false)
    SetNuiFocus(false, false)
end

AddEventHandler(
    "inventory:usedItem",
    function(itemName, slot, data)
        if itemName == "transmitter" then
            Citizen.CreateThread(
                function()
                    Citizen.Wait(100)
                    enableRadio(true)
                end
            )
        end
    end
)
function isAllowed()
    if tableLength(jobs) > 0 then
        for _, data in pairs(jobs) do
            if Config.AllowedTypes[data.Type] and (Config.AllowedTypes[data.Type].onlyDuty == false or Config.AllowedTypes[data.Type].onlyDuty == data.Duty) then
                return true
            end
        end
    end
    return false
end

function loadJobs(Jobs)
    jobs = {}
    for _, data in pairs(Jobs ~= nil and Jobs or exports.data:getCharVar("jobs")) do
        jobs[data.job] = {
            Name = data.job,
            Type = exports.base_jobs:getJobVar(data.job, "type"),
            Grade = data.job_grade,
            Duty = data.duty
        }
    end
end

function tableLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end
