local isSpawned, isDead, isOpened, inVehicle = false, false, false, false
local showPostal = false

local nearest = nil
local hasBlip = false

Citizen.CreateThread(function()
    Citizen.Wait(500)
    exports.chat:addSuggestion("/pc", "Nastavit navigaci na Postal Code", {{
        name = "číslo",
        help = "PC číslo"
    }})

    local status = exports.data:getUserVar("status")

    if status == "spawned" or status == "dead" then
        isSpawned = true
        isDead = (status == "dead")
        showPostal = exports.settings:getSettingValue("postalcode")
        if GetVehiclePedIsIn(PlayerPedId(), false) ~= 0 then
            createCycle()
        end
    end
end)

RegisterNetEvent("s:statusUpdated")
AddEventHandler("s:statusUpdated", function(status)
    if status == "choosing" then
        isSpawned, isDead, showPostal = false, false, false
    elseif status == "spawned" or status == "dead" then
        isSpawned = true
        isDead = (status == "dead")
        showPostal = exports.settings:getSettingValue("postalcode")
    end
end)

RegisterNetEvent("settings:changed")
AddEventHandler("settings:changed", function(setting, value)
    if setting == "postalcode" then
        showPostal = value
        createCycle()
    end
end)

AddEventHandler("gameEventTriggered", function(name, args)
    if name == "CEventNetworkPlayerEnteredVehicle" then
        if args[1] ~= PlayerId() then
            return
        end
        createCycle()
    end
end)

function createCycle()
    local playerPed = PlayerPedId()
    local playerVeh = GetVehiclePedIsIn(playerPed)
    local nearestPostal = nil

    if GetVehicleClass(playerVeh) == 13 then
        return
    end

    Citizen.CreateThread(function()
        while showPostal and playerVeh ~= 0 do
            playerVeh = GetVehiclePedIsIn(playerPed)
            local playerCoords = GetEntityCoords(playerPed)
            nearestPostal = nil
            for i, postal in each(Config.Postals) do
                local distance = #(playerCoords - vec3(postal.Coords.xy, playerCoords.z))
                if not nearestPostal or distance < nearestPostal.Distance then
                    nearestPostal = {
                        Id = i,
                        Distance = distance
                    }
                end
            end

            if hasBlip then
                local distance = #(playerCoords - vec3(hasBlip.Coords.xy, playerCoords.z))
                if distance < 20.0 then
                    RemoveBlip(hasBlip.Blip)
                    hasBlip = false
                end
            end
            Citizen.Wait(200)
        end
    end)
    while showPostal and playerVeh ~= 0 do
        while not nearestPostal do
            Citizen.Wait(500)
        end
        local distance = math.sqrt(nearestPostal.Distance ^ 2)
        local text = ("PC: %s - %.2fm"):format(Config.Postals[nearestPostal.Id].Code, distance)
        SetTextScale(0.42, 0.42)
        SetTextFont(4)
        SetTextOutline()
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(text)

        local y = 0.775
        if IsBigmapActive() then
            y = 0.545
        end
        EndTextCommandDisplayText(0.015, y)
        Citizen.Wait(1)
    end
end

RegisterNetEvent("settings:changed")
AddEventHandler("settings:changed", function(setting, value)
    if setting == "postalcode" then
        showPostal = value
    end
end)

RegisterCommand("pc", function(_, args)
    local playerPed = PlayerPedId()
    local playerVeh = GetVehiclePedIsIn(playerPed)
    if playerVeh ~= 0 then
        if hasBlip and (not args or #args <= 0) then
            exports.notify:display({
                type = "info",
                title = "Navigace - Postal Code",
                text = "Navigace na Postal Code odebrána!",
                icon = "fas fa-map-marked-alt",
                length = 3500
            })
            RemoveBlip(hasBlip.Blip)
            hasBlip = false
        elseif hasBlip and hasBlip.Code == args[1] then
            exports.notify:display({
                type = "warning",
                title = "Navigace - Postal Code",
                text = "Tenhle Postal Code už v navigaci je nastavený!",
                icon = "fas fa-map-marked-alt",
                length = 4000
            })
        elseif args and tonumber(args[1]) then
            setGPS(args[1])
        else
            exports.notify:display({
                type = "warning",
                title = "Navigace - Postal Code",
                text = "Musíš zadat Postal Code!",
                icon = "fas fa-map-marked-alt",
                length = 3500
            })
        end
    end
end)

function setGPS(pc)
    local foundPostal = nil
    for _, code in each(Config.Postals) do
        if code.Code == pc then
            foundPostal = code
            break
        end
    end

    if foundPostal then
        local hadBlip = false
        if hasBlip then
            RemoveBlip(hasBlip.Blip)
            hadBlip = true
        end

        hasBlip = {
            Coords = foundPostal.Coords,
            Blip = createNewBlip({
                coords = vec3(foundPostal.Coords.xy, 0.0),
                sprite = 8,
                display = 2,
                scale = 0.8,
                colour = 3,
                isShortRange = false,
                text = ("GPS - POSTAL CODE %s"):format(foundPostal.Code)
            }),
            Code = foundPostal.Code
        }
        SetBlipRoute(hasBlip.Blip, true)
        SetBlipRouteColour(hasBlip.Blip, 3)

        local text = "Navigace nastavena na Postal Code " .. foundPostal.Code
        exports.notify:display({
            type = "info",
            title = "Navigace - Postal Code",
            text = text .. (hadBlip and " a stará navigace zrušena!" or "!"),
            icon = "fas fa-map-marked-alt",
            length = 3500
        })
    else
        exports.notify:display({
            type = "warning",
            title = "Navigace - Postal Code",
            text = "Zadaný Postal Code nenalezen!",
            icon = "fas fa-map-marked-alt",
            length = 3500
        })
    end
end
