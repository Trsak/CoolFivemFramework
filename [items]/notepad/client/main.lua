local isUiOpen = false
local isMoving = false
local openedId = nil

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "dead" then
            if isUiOpen then
                closeNotepad()
            end
        end
    end
)

RegisterNUICallback(
    "movewhile",
    function(data, cb)
        isMoving = true
        SetNuiFocus(false, false)
        exports.key_hints:displayBottomHint({name = "notepad", key = "~INPUT_ENTER_CHEAT_CODE~", text = "Psát"})
        while isMoving do
            Citizen.Wait(0)
            if IsControlJustReleased(0, 243) then
                SetNuiFocus(true, true)
                isMoving = false
                exports.key_hints:displayBottomHint({name = "notepad", key = "~INPUT_DUCK~", text = "Chodit"})
            end -- INPUT_DUCK
        end
    end
)

RegisterNUICallback(
    "escape",
    function(data, cb)
        TriggerServerEvent("notepad:close", data.text, openedId)
        closeNotepad()
    end
)

RegisterNetEvent("notepad:open")
AddEventHandler(
    "notepad:open",
    function(data)
        openNotepad(data)
    end
)

function closeNotepad()
    SendNUIMessage(
        {
            action = "closeNotepad"
        }
    )
    isUiOpen = false
    SetNuiFocus(false, false)
    exports.emotes:cancelEmote()
    exports.key_hints:hideBottomHint({name = "notepad"})
end

function openNotepad(data)
    exports.emotes:playEmoteByName("notepad")
    exports.key_hints:displayBottomHint({name = "notepad", key = "~INPUT_DUCK~", text = "Chodit"})
    openedId = data.id
    SendNUIMessage(
        {
            action = "openNotepad",
            TextRead = data.text == nil and "" or data.text
        }
    )
    isUiOpen = true
    SetNuiFocus(true, true)
end

AddEventHandler('onResourceStop', function(name)
    if GetCurrentResourceName() == name then
        closeNotepad()
    end
end)