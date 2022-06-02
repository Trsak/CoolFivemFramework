local isShowing = false

RegisterNetEvent("fortunecookie:show")
AddEventHandler("fortunecookie:show", function()
    if isShowing then
        return
    end
    exports.emotes:DisableEmotes(true)

    toggleUi(true)
    local random = math.random(#Config.FortuneCookie)
    local text = Config.FortuneCookie[random]
    SendNUIMessage({
        number = random,
        data = text
    })
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 73) then
            toggleUi(false)
            exports.emotes:DisableEmotes(false)
        end
    end
end)

function toggleUi(state)
    isShowing = state
    SendNUIMessage({
        open = state
    })
end
