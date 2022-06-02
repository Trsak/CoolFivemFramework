local display = false
local ped = PlayerPedId()
local vehicle = GetVehiclePedIsIn(ped, false)
local colors = Config.Colors
local neonsOn = false
local isDead = false
local spawn = true
local canUse = nil

Citizen.CreateThread(
    function()
        Citizen.Wait(500)
        while not exports.data:isUserLoaded() do
            Citizen.Wait(100)
        end

        local status = exports.data:getUserVar("status")
        if status == "spawned" or status == "dead" then
            isSpawned = true
            canUse = true
        end
    end
)

RegisterNetEvent("s:statusUpdated")
AddEventHandler(
    "s:statusUpdated",
    function(status)
        if status == "choosing" then
            isSpawned = false
        elseif status == "spawned" or status == "dead" then
            isSpawned = true
            canUse = true
        end
    end
)

AddEventHandler(
    "inventory:usedItem",
    function(itemName, slot, data)
        if string.find(itemName, "neon_remote") ~= nil then
            displayFocus(not display)
        end
    end
)

RegisterNUICallback(
    "neon",
    function(data)
        ped = PlayerPedId()
        vehicle = GetVehiclePedIsIn(ped, false)
        local currentMods = exports.base_vehicles:GetVehicleProperties(vehicle)
        for k, v in pairs(Config.Menus) do
            if data["headlights"] and v.modType == 22 and canUse then
                if currentMods.modXenon then
                    ToggleVehicleMod(vehicle, 22, true)
                    SetVehicleXenonLightsColor(vehicle, data["color"]["index"])
                end
            elseif canUse then
                setColor(data["color"]["rgb"][1], data["color"]["rgb"][2], data["color"]["rgb"][3])
            end
        end
    end
)

RegisterNUICallback(
    "exit",
    function()
        displayFocus(false)
        display = false
    end
)

RegisterNUICallback(
    "main",
    function()
        displayFocus(false)
    end
)

RegisterNUICallback(
    "toggleNeon",
    function()
        toggleNeon()
    end
)

function displayFocus(bool)
    ped = PlayerPedId()
    vehicle = GetVehiclePedIsIn(ped, false)
    if IsPedInAnyVehicle(ped, false) then
        display = bool
        SetNuiFocus(bool, bool)
        r, g, b = GetVehicleNeonLightsColour(vehicle)
        SendNUIMessage({colors = Config.Colors, type = "ui", status = bool, currentVehColor = {r, g, b}})
    end
end

function toggleNeon()
    if canUse then
        if neonsOn then
            neonsOn = false
            DisableVehicleNeonLights(vehicle, true)
        else
            neonsOn = true
            DisableVehicleNeonLights(vehicle, false)
        end
    end
end

function setColor(r, g, b)
    if r ~= nil and g ~= nil and b ~= nil then
        SetVehicleNeonLightsColour(vehicle, r, g, b)
    end
end
