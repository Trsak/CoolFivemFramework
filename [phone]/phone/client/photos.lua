phone = false
phoneId = 0
takePhoto = false
frontCam = false

RegisterNUICallback('takePhoto', function(data, cb)
    CreateMobilePhone(1)
    CellCamActivate(true, true)
    takePhoto = true
    Citizen.Wait(0)
    if PhoneData.isOpen == true then
        SendNUIMessage({
            action = "close"
        })
    end
    while takePhoto do
        Citizen.Wait(0)

        if IsControlJustPressed(1, 27) then -- Toogle Mode
            frontCam = not frontCam
            CellFrontCamActivate(frontCam)
        elseif IsControlJustPressed(1, 322) or IsControlJustPressed(1, 177) then -- CANCEL
            DestroyMobilePhone()
            CellCamActivate(false, false)
            cb(json.encode({ url = nil }))
            takePhoto = false
            break
        elseif IsControlJustPressed(1, 176) or IsControlJustPressed(1, 18) then -- TAKE.. PIC
            TriggerServerEvent('qb-phone:server:TakeScreenshot')
            RegisterNetEvent('qb-phone:client:TakeScreenshot')
            AddEventHandler('qb-phone:client:TakeScreenshot', function(url)
                cb({ url = url })
                takePhoto = false
                OpenPhone()
            end)
        end
        HideHudComponentThisFrame(7)
        HideHudComponentThisFrame(8)
        HideHudComponentThisFrame(9)
        HideHudComponentThisFrame(6)
        HideHudComponentThisFrame(19)
        HideHudAndRadarThisFrame()
    end
    Citizen.Wait(1000)
    --PhonePlayAnim('text', false, true)
end)

function CellFrontCamActivate(activate)
    return Citizen.InvokeNative(0x2491A93618B7D838, activate)
end

--[[Citizen.CreateThread(function()
    DestroyMobilePhone()
    while true do
        Citizen.Wait(0)

        if IsControlJustPressed(1, 177) and phone == true then -- CLOSE PHONE
            DestroyMobilePhone()
            phone = false
            CellCamActivate(false, false)
            if firstTime == true then
                firstTime = false
                Citizen.Wait(2500)
                displayDoneMission = true
            end
        end

        if IsControlJustPressed(1, 27) and phone == true then -- SELFIE MODE
            frontCam = not frontCam
            CellFrontCamActivate(frontCam)
        end

        if phone == true then
            HideHudComponentThisFrame(7)
            HideHudComponentThisFrame(8)
            HideHudComponentThisFrame(9)
            HideHudComponentThisFrame(6)
            HideHudComponentThisFrame(19)
            HideHudAndRadarThisFrame()
        end

        ren = GetMobilePhoneRenderId()
        SetTextRenderId(ren)

        -- Everything rendered inside here will appear on your phone.

        SetTextRenderId(1) -- NOTE: 1 is default
    end
end)]]
