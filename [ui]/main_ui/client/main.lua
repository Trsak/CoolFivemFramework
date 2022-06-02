local isSpawned, isDead, isInPauseMenu, isTalking = false, false, false, false
local minimapWidth = nil

-- Config
local forceHidden = false

local uiStatuses = {
    uiStatusMicrophone = true,
    uiStatusHealth = 100,
    uiStatusArmour = 100,
    uiStatusHunger = 100,
    uiStatusThirst = 100,
    uiStatusStamina = 100,
    uiStatusOxygen = 100,
    uiStatusStress = 0,
    uiStatusDrunk = 0,
}

Citizen.CreateThread(
    function()
        Citizen.Wait(500)

        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            SendNUIMessage({action = "enableUi"})
            isSpawned, isDead = true, (status == "dead")

            forceHidden = exports.settings:getSettingValue("hidebars")

            if not forceHidden then
                SendNUIMessage({action = "toggleUi", value = true})
            end

            for status, _ in pairs(uiStatuses) do
                uiStatuses[status] = exports.settings:getSettingValue(status)
            end
        end
    end
)

AddEventHandler(
    "settings:changed",
    function(setting, value)
        if setting == "hidebars" then
            forceHidden = value
            SendNUIMessage({action = "toggleUi", value = not value})
        elseif uiStatuses[setting] ~= nil then
            uiStatuses[setting] = value
            SendNUIMessage({action = "toggleUiStatus", uiStatuses = uiStatuses})
        end
    end
)

RegisterNetEvent("chars:completelyLoaded")
AddEventHandler(
    "chars:completelyLoaded",
    function()
        SendNUIMessage({action = "enableUi"})

        if not forceHidden then
            SendNUIMessage({action = "toggleUi", value = true})
        end
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned = false
            SendNUIMessage({action = "toggleUi", value = false})
        elseif status == "spawned" then
            isSpawned = true
            isDead = false
            sendUserData()
        elseif status == "dead" then
            isDead = true
        end
    end
)

RegisterNetEvent("voip:voiceMode")
AddEventHandler(
    "voip:voiceMode",
    function(voiceRange)
        SendNUIMessage({action = "setData", voiceRange = voiceRange})
    end
)

RegisterNetEvent("needs:needChanged")
AddEventHandler(
    "needs:needChanged",
    function(need, value)
        SendNUIMessage({action = "setNeeds", need = need, value = value})
    end
)

Citizen.CreateThread(
    function()
        local isInPauseMenu = false

        while true do
            Citizen.Wait(0)

            if IsPauseMenuActive() then -- ESC Key
                if not isInPauseMenu then
                    isInPauseMenu = true
                    SendNUIMessage({action = "toggleUi", value = false})
                end
            else
                if isInPauseMenu then
                    calculateWidth()
                    isInPauseMenu = false

                    if not forceHidden then
                        SendNUIMessage({action = "toggleUi", value = true})
                    end
                end

                HideHudComponentThisFrame(1) -- Wanted Stars
                HideHudComponentThisFrame(2) -- Weapon Icon
                HideHudComponentThisFrame(3) -- Cash
                HideHudComponentThisFrame(4) -- MP Cash
                HideHudComponentThisFrame(6) -- Vehicle Name
                HideHudComponentThisFrame(7) -- Area Name
                HideHudComponentThisFrame(8) -- Vehicle Class
                HideHudComponentThisFrame(9) -- Street Name
                HideHudComponentThisFrame(13) -- Cash Change
                HideHudComponentThisFrame(14) -- Crosshair
                HideHudComponentThisFrame(17) -- Save Game
                HideHudComponentThisFrame(20) -- Weapon Stats
            end
        end
    end
)

function sendUserData()
    local playerPed = PlayerPedId()
    local health = GetEntityHealth(playerPed) - 100
    local armor = GetPedArmour(playerPed)
    local stamina = 100 - GetPlayerSprintStaminaRemaining(PlayerId())
    local oxygen = GetPlayerUnderwaterTimeRemaining(PlayerId()) * 10.00
    isTalking = NetworkIsPlayerTalking(PlayerId())

    if not minimapWidth then
        calculateWidth()
    end

    SendNUIMessage({action = "setData", health = health, armor = armor, stamina = stamina, oxygen = oxygen, dead = isDead, minimapWidth = minimapWidth, talking = isTalking})
end

Citizen.CreateThread(
    function()
        while true do
            if isSpawned then
                sendUserData()
            end

            Citizen.Wait(1000)
        end
    end
)

function calculateWidth()
    local aspect_ratio = GetAspectRatio(0)
    local res_x, res_y = GetActiveScreenResolution()
    local xscale = 1.0 / res_x
    minimapWidth = xscale * (res_x / (2.8 * aspect_ratio))
end
