local show = false
local sent = false
local spawned = false
local isDead = false

RegisterNetEvent("s:statusUpdated")
AddEventHandler("s:statusUpdated", function(status)
    isDead = (status == "dead")
    if status == "spawned" then
        status = (status == "spawned")
    end
end)

AddEventHandler('plane_sensors:toggle', function()
    if not HasStreamedTextureDictLoaded("flightinstruments") then
        RequestStreamedTextureDict("flightinstruments", true)
        while not HasStreamedTextureDictLoaded("flightinstruments") do
            Wait(1)
        end
    end
    while show do
        local speed = GetEntitySpeed(GetVehiclePedIsIn(PlayerPedId())) * 1.943844492
        local altitude = GetEntityCoords(PlayerPedId()).z * 3.28084
        local heading = GetEntityHeading(GetVehiclePedIsIn(PlayerPedId()))
        local verticalspeed = GetEntityVelocity(GetVehiclePedIsIn(PlayerPedId())).z * 196.850394

        if speed < 40 then speed = 40 end
        if speed > 200 then speed = 200 end
        if altitude<0 then altitude = 0 end
        if verticalspeed>2000 then verticalspeed = 2000 elseif verticalspeed < -2000 then verticalspeed = -2000 end
        DrawSprite("flightinstruments", "speedometer", 0.65, 0.9, 0.08, 0.08*1.77777778, 0, 255, 255, 255, 255)
        DrawSprite("flightinstruments", "speedometer_needle", 0.65, 0.9, 0.08, 0.08*1.77777778, ((speed-20)/20)*36, 255, 255, 255, 255)
        DrawSprite("flightinstruments", "altimeter", 0.55, 0.9, 0.08, 0.08*1.77777778, 0, 255, 255, 255, 255)
        DrawSprite("flightinstruments", "altimeter-needle100", 0.55, 0.9, 0.08, 0.08*1.77777778, altitude/100*36, 255, 255, 255, 255)
        DrawSprite("flightinstruments", "altimeter-needle1000", 0.55, 0.9, 0.08, 0.08*1.77777778, altitude/1000*36, 255, 255, 255, 255)
        DrawSprite("flightinstruments", "altimeter-needle10000", 0.55, 0.9, 0.08, 0.08*1.77777778, altitude/10000*36, 255, 255, 255, 255)
        DrawSprite("flightinstruments", "heading", 0.45, 0.9, 0.08, 0.08*1.77777778, 0, 255, 255, 255, 255)
        DrawSprite("flightinstruments", "heading_needle", 0.45, 0.9, 0.08, 0.08*1.77777778, heading, 255, 255, 255, 255)
        DrawSprite("flightinstruments", "verticalspeedometer", 0.35, 0.9, 0.08, 0.08*1.77777778, 0, 255, 255, 255, 255)
        DrawSprite("flightinstruments", "verticalspeedometer_needle", 0.35, 0.9, 0.08, 0.08*1.77777778, 270+(verticalspeed/1000*90), 255, 255, 255, 255)
        Citizen.Wait(1)
    end
end)

Citizen.CreateThread(function()
    while true do
        wait = 300
        if IsPedInAnyPlane(PlayerPedId()) and not sent then
            show = not show
            sent = not sent
            TriggerEvent('plane_sensors:toggle')
        else
            if not IsPedInAnyPlane(PlayerPedId()) then
                show = false
                sent = false
            end
        end
        if isDead then
            show = false
        end
        Citizen.Wait(wait)
    end
end)

RegisterCommand('plane_sensors', function()
    if IsPedInAnyPlane(PlayerPedId()) then
        show = not show
        if show then
            TriggerEvent('plane_sensors:toggle')
        end
    end
end, false)