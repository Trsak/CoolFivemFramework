--==--==--==--
-- Config
--==--==--==--
local adminPower, isDead, registered = 0, false, false
local noclipActive = false -- [[Wouldn't touch this.]]
local noclipEntity = nil
local followCam = false
index = 1 -- [[Used to determine the index of the speeds table.]]

config = {
    debug = true,
    controls = {
        -- [[Controls, list can be found here : https://docs.fivem.net/game-references/controls/]]
        openKey = 56, -- [[F9]]
        goUp = 85, -- [[Q]]
        followCam = 74, -- [[H]]
        goDown = 48, -- [[Z]]
        turnLeft = 34, -- [[A]]
        turnRight = 35, -- [[D]]
        goForward = 32, -- [[W]]
        goBackward = 33, -- [[S]]
        upSpeed = 21, -- [[L-Shift]]
        lowerSpeed = 36, -- [[L-CTRL]]
    },

    speeds = {
        -- [[If you wish to change the speeds or labels there are associated with then here is the place.]]
        { label = "Velmi pomalé", speed = 0 },
        { label = "Pomalé", speed = 0.5 },
        { label = "Normální", speed = 2 },
        { label = "Rychlé", speed = 4 },
        { label = "Velmi rychlé", speed = 6 },
        { label = "Ultra rychlé", speed = 10 },
        { label = "Ultra Giga rychlé", speed = 20 },
        { label = "Epická rychlost", speed = 25 },
        { label = "Ultimátní rychlost", speed = 100 }
    },

    offsets = {
        y = 0.2, -- [[How much distance you move forward and backward while the respective button is pressed]]
        z = 0.2, -- [[How much distance you move upward and downward while the respective button is pressed]]
        h = 3, -- [[How much you rotate. ]]
    },

    -- [[Background colour of the buttons. (It may be the standard black on first opening, just re-opening.)]]
    bgR = 0, -- [[Red]]
    bgG = 0, -- [[Green]]
    bgB = 0, -- [[Blue]]
    bgA = 80, -- [[Alpha]]
}


--==--==--==--
-- End Of Config
--==--==--==--
if config.debug then
    AddEventHandler('onResourceStart', function(resourceName)
        if resourceName == GetCurrentResourceName() then
            adminPower = exports.data:getUserVar("admin")
            if adminPower > 0 and not registered then
                registered = true
                createNewKeyMapping({ command = "toggleNoclip", text = "No-clip (Zapnutí a vypnutí)", key = "F9" })
                currentSpeed = config.speeds[index].speed
            end
        end
    end)
end

RegisterNetEvent("s:statusUpdated")
AddEventHandler("s:statusUpdated", function(status)
    isDead = (status == "dead")
    if status == "spawned" then
        adminPower = exports.data:getUserVar("admin")
        if adminPower > 0 and not registered then
            registered = true
            createNewKeyMapping({ command = "toggleNoclip", text = "No-clip (Zapnutí a vypnutí)", key = "F9" })
            currentSpeed = config.speeds[index].speed
        end
    end
end)

RegisterCommand(
    "toggleNoclip",
    function()
        if adminPower > 0 and not isDead then
            toggleNoclip()
            exports.injuries:removeAllInjuries()
        end
    end,
    false
)

function toggleNoclip()
    noclipActive = not noclipActive

    if noclipActive then
        exports.key_hints:displayBottomHint({ name = "noclip_toggle", key = "~INPUT_B56A5013~", text = "Vypnout Noclip" })
        exports.key_hints:displayBottomHint({ name = "noclip_speed", key = "~INPUT_SPRINT~", text = "Jiná rychlost (" .. config.speeds[index].label .. ")" })
        exports.key_hints:displayBottomHint({ name = "noclip_cam", key = "~INPUT_VEH_HEADLIGHT~", text = "Kamera" })
        exports.key_hints:displayBottomHint({ name = "noclip_forward", key = "~INPUT_MOVE_UP_ONLY~", text = "Dopředu" })
        exports.key_hints:displayBottomHint({ name = "noclip_backward", key = "~INPUT_MOVE_DOWN_ONLY~", text = "Dozadu" })
        exports.key_hints:displayBottomHint({ name = "noclip_left", key = "~INPUT_MOVE_LEFT_ONLY~", text = "Doleva" })
        exports.key_hints:displayBottomHint({ name = "noclip_right", key = "~INPUT_MOVE_RIGHT_ONLY~", text = "Doprava" })
        exports.key_hints:displayBottomHint({ name = "noclip_up", key = "~INPUT_VEH_RADIO_WHEEL~", text = "Nahoru" })
        exports.key_hints:displayBottomHint({ name = "noclip_down", key = "~INPUT_HUD_SPECIAL~", text = "Dolu" })
    else
        exports.key_hints:hideBottomHint({ ["name"] = "noclip_speed" })
        exports.key_hints:hideBottomHint({ ["name"] = "noclip_toggle" })
        exports.key_hints:hideBottomHint({ ["name"] = "noclip_backward" })
        exports.key_hints:hideBottomHint({ ["name"] = "noclip_forward" })
        exports.key_hints:hideBottomHint({ ["name"] = "noclip_up" })
        exports.key_hints:hideBottomHint({ ["name"] = "noclip_down" })
        exports.key_hints:hideBottomHint({ ["name"] = "noclip_cam" })
        exports.key_hints:hideBottomHint({ ["name"] = "noclip_left" })
        exports.key_hints:hideBottomHint({ ["name"] = "noclip_right" })
    end

    if IsPedInAnyVehicle(PlayerPedId(), false) then
        noclipEntity = GetVehiclePedIsIn(PlayerPedId(), false)
    else
        noclipEntity = PlayerPedId()
    end

    SetEntityCollision(noclipEntity, not noclipActive, not noclipActive)
    SetEntityVisible(noclipEntity, not noclipActive, 0)

    TriggerServerEvent("admin:playerGodModeWhitelist", noclipActive)
    FreezeEntityPosition(noclipEntity, noclipActive)
    SetEntityInvincible(noclipEntity, noclipActive)
    SetVehicleRadioEnabled(noclipEntity, not noclipActive) -- [[Stop radio from appearing when going upwards.]]

    SetEveryoneIgnorePlayer(noclipEntity, noclipActive)
    SetPoliceIgnorePlayer(noclipEntity, noclipActive)

    if not noclipActive then
        ResetEntityAlpha(noclipEntity);
    end
    TriggerEvent('no_clip:noclip')
    return noclipActive
end

AddEventHandler('no_clip:noclip', function()
    while true do
        if noclipActive then
            DisableControls()

            local yoff = 0.0
            local zoff = 0.0
            local heading = followCam and GetGameplayCamRelativeHeading() or GetEntityHeading(noclipEntity)

            if not IsPauseMenuActive() then
                if IsDisabledControlJustPressed(1, config.controls.followCam) then
                    followCam = not followCam
                end

                if IsControlJustPressed(1, config.controls.upSpeed) then
                    if index ~= #config.speeds then
                        index = index + 1
                        currentSpeed = config.speeds[index].speed
                    else
                        currentSpeed = config.speeds[1].speed
                        index = 1
                    end

                    exports.key_hints:displayBottomHint({ name = "noclip_speed", key = "~INPUT_SPRINT~", text = "Jiná rychlost (" .. config.speeds[index].label .. ")" })
                end

                if IsControlJustPressed(1, config.controls.lowerSpeed) then
                    if (index - 1) ~= 0 then
                        index = index - 1
                        currentSpeed = config.speeds[index].speed
                    else
                        currentSpeed = config.speeds[1].speed
                        index = #config.speeds
                    end

                    exports.key_hints:displayBottomHint({ name = "noclip_speed", key = "~INPUT_SPRINT~", text = "Jiná rychlost (" .. config.speeds[index].label .. ")" })
                end

                if IsDisabledControlPressed(0, config.controls.goForward) then
                    yoff = config.offsets.y
                end

                if IsDisabledControlPressed(0, config.controls.goBackward) then
                    yoff = -config.offsets.y
                end

                if not followCam and IsDisabledControlPressed(0, config.controls.turnLeft) then
                    heading = (heading + config.offsets.h)
                    SetEntityHeading(noclipEntity, heading)
                end

                if not followCam and IsDisabledControlPressed(0, config.controls.turnRight) then
                    heading = (heading - config.offsets.h)
                    SetEntityHeading(noclipEntity, heading)
                end

                if IsDisabledControlPressed(0, config.controls.goUp) then
                    zoff = config.offsets.z
                end

                if IsDisabledControlPressed(0, config.controls.goDown) then
                    zoff = -config.offsets.z
                end
            end

            local newPos = GetOffsetFromEntityInWorldCoords(noclipEntity, 0.0, yoff * (currentSpeed + 0.3), zoff * (currentSpeed + 0.3))
            SetEntityVelocity(noclipEntity, 0.0, 0.0, 0.0)
            SetEntityRotation(noclipEntity, 0.0, 0.0, 0.0, 0, false)
            SetEntityHeading(noclipEntity, followCam and GetGameplayCamRelativeHeading() or heading)

            SetEntityCoordsNoOffset(noclipEntity, newPos.x, newPos.y, newPos.z, noclipActive, noclipActive, noclipActive)
            SetLocalPlayerVisibleLocally(true)
            SetEntityAlpha(noclipEntity, 51, false)
        else
            break
        end
        Citizen.Wait(1)
    end
end)
--==--==--==--
-- End Of Script
--==--==--==--
